import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:field/bloc/image_annotation/annotation_selection_cubit.dart';
import 'package:field/bloc/image_annotation/image_annotation_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/logger/logger.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:field/widgets/elevatedbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_painter/flutter_painter.dart';
import 'package:flutter_phosphor_icons/flutter_phosphor_icons.dart';
import 'package:native_exif/native_exif.dart';

import '../bloc/image_annotation/annotation_state.dart';
import '../bloc/image_annotation/image_annotation_state.dart';
import '../presentation/managers/routes_manager.dart';
import '../utils/constants.dart';
import '../utils/image_compress_utils.dart';
import '../widgets/a_file_picker.dart';
import '../widgets/behaviors/custom_scroll_behavior.dart';
import '../widgets/normaltext.dart';
import 'paint.dart';

typedef MyBuilder = void Function(
    BuildContext context, void Function(AnnotationOptions type) method);

enum AnnotationOptions {
  none,
  undo,
  redo,
  delete,
  clear,
  erase,
  arrow,
  square,
  freeHand,
  text,
  flip,
  swipe,
  settings
}

// A widget that displays the picture taken by the user.
class ImageAnnotationWidget extends StatefulWidget {
  final dynamic arguments;
  const ImageAnnotationWidget({super.key, required this.arguments});

  @override
  State<ImageAnnotationWidget> createState() => _ImageAnnotationWidgetState();
}

class _ImageAnnotationWidgetState extends State<ImageAnnotationWidget> {
  late PageController pageController;

  var imageAnnotationCubit = getIt<ImageAnnotationCubit>();
  var annotationSelectionCubit = getIt<AnnotationSelectionCubit>();
  late ScrollController scrollController;
  List<dynamic> imagePaths = [];
  List<dynamic> inValidFiles = [];
  String mimeType = "";
  String? imagesFrom;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    imagePaths = widget.arguments["capturedFile"];
    imagesFrom = widget.arguments["imagesFrom"];
    inValidFiles = widget.arguments["inValidFiles"] ?? [];
    mimeType = widget.arguments["mimeType"] ?? "";
    Utility.isTablet
        ? SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeRight,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ])
        : SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
    imagePaths.reversed;

    imageAnnotationCubit.initImagepathData(imagePaths);
    Log.d("InitState annotation====>${imageAnnotationCubit.imagePathList.length}");
    if (imageAnnotationCubit.imagePathList.isEmpty) {
      Navigator.of(context).pop(imageAnnotationCubit.docPathList);
    }

    pageController = PageController(initialPage: 0, viewportFraction: 1.0, keepPage: false);

    pageController.addListener(() {
      setState(() {
        Log.e("pageController addListener==> ${pageController.page?.toInt()}");
        imageAnnotationCubit.updateSelected(pageController.page?.toInt() ?? 0);
      });
    });
    methodsMap = {};
    painterControllerMap = {};
    pathList = [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(inValidFiles.isNotEmpty){
        Utility.showAlertWithOk(context, inValidFiles[0]);
      }
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  late Map<int, Function> methodsMap;
  late Map<int, PainterController> painterControllerMap;
  late List<String> pathList;

  void _remove() {
    setState(() {
      imageAnnotationCubit.removeData(imageAnnotationCubit.getActivePage);
    });
  }

  /// Used to process all images and save to file and
  /// send all processed images to attachment list page.
  void navigateToNext() async {
    var aProgress = AProgressDialog(context, isAnimationRequired: true);
    aProgress.show();

    await saveImagesToFile().then((value) {
      pathList.addAll(value);
    });

    Log.d("TAG SAved image pathList length ===> ${pathList.length}");

    for (var element in imageAnnotationCubit.docPathList) {
      pathList.add(element);
    }
    aProgress.dismiss();
    // Exif? exif = await Exif.fromPath(pathList[0]);
    // Log.d("FINAL pathList latlong ==> ${await exif.getLatLong()}");
    // Log.d("FINAL pathList originaldate ==> ${await exif.getOriginalDate()}");
    Navigator.of(context).pop(pathList);
  }

  void _add(PainterController controller) {
    painterControllerMap.update(imageAnnotationCubit.getActivePage, (value) => controller,
        ifAbsent: () => controller);
    Log.d("TAG _add Size ${painterControllerMap.length}");
  }

  Future<List<String>> saveImagesToFile() async {
    List<String> listPath = [];
    await Future.forEach(imageAnnotationCubit.imagePathList, (AnnotatedImageClass element) async {
      final imagePathString = await saveImageWithAnnotation(element);
      listPath.add(imagePathString);
    });
    return listPath;
  }

  Future<String> saveImageWithAnnotation(AnnotatedImageClass imgClass) async {
    if (imgClass.imgDrawables != null && imgClass.imgDrawables!.isNotEmpty) {
      ui.Image? img = await decodeImageFromList(File(imgClass.imgPath).readAsBytesSync());

      PainterController painterController = PainterController();
      painterController.addDrawables(imgClass.imgDrawables as Iterable<Drawable>, newAction: true);
      painterController.background = img.backgroundDrawable;

      ui.Image? nImage = await painterController.renderImage(Size(
          imgClass.renderBox?.size.width ?? img.width.toDouble() / 2,
          imgClass.renderBox?.size.height ?? img.height.toDouble() / 2));

      if (nImage != null) {
        File file = File(
            '${(await AppPathHelper().getDocumentDirectory()).path}/Image_${DateTime.now().millisecondsSinceEpoch}.jpg');

        final byteData = await nImage.toByteData(
          format: ui.ImageByteFormat.png,
        );

        final bytes = byteData?.buffer.asUint8List();

        file = await file.writeAsBytes(bytes!, flush: true);

        var compressedImagePath = await compressImageFile(file.path);
        painterController.dispose();
        img.dispose();
        await imageAnnotationCubit.copyEXIfData(
            originalPath: imgClass.imgPath, compressedImagePath: compressedImagePath);
        return Future<String>.value(compressedImagePath);
      } else {
        return Future<String>.value();
      }
    } else {
      var compressedImagePath = await compressImageFile(imgClass.imgPath);
      await imageAnnotationCubit.copyEXIfData(
          originalPath: imgClass.imgPath, compressedImagePath: compressedImagePath);
      return Future<String>.value(compressedImagePath);
    }
  }

  Widget widgetBottomAttach() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
          color: Colors.white, border: Border(top: BorderSide(color: AColors.dividerColor))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AElevatedButtonWidget(
            height: 39,
            fontWeight: AFontWight.medium,
            borderRadius: 4,
            fontFamily: AFonts.fontFamily,
            fontSize: 15,
            btnLabelClr: AColors.aPrimaryColor,
            btnBackgroundClr: AColors.white,
            btnLabel: context.toLocale!.lbl_cancel,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(
            width: 15,
          ),
          AElevatedButtonWidget(
            height: 39,
            fontWeight: AFontWight.medium,
            borderRadius: 4,
            fontFamily: AFonts.fontFamily,
            fontSize: 15,
            btnLabelClr: imageAnnotationCubit.attachmentClicked?AColors.textColor:AColors.white,
            btnBackgroundClr: imageAnnotationCubit.attachmentClicked?AColors.lightGreyColor:AColors.themeBlueColor,
            btnLabel: context.toLocale!.lbl_attach,
            onPressed: imageAnnotationCubit.attachmentClicked?null:() async {
              imageAnnotationCubit.addAttachmentClickEvent();
              setImageData(imageAnnotationCubit.getActivePage);
              navigateToNext();
            },
          ),
        ],
      ),
    );
  }

  Widget annotationOption(dynamic icon, {required dynamic method, VoidCallback? onPressed}) {
    return BlocBuilder<AnnotationSelectionCubit, FlowState>(
      builder: (_, state) {
        dynamic stateMethod;
        if(state is AnnotationSelectionState){
          stateMethod = state.selectedAnnotation;
        }
        return Container(
          height: 45,
          width: 45,
          margin: Utility.isTablet ? const EdgeInsets.only(bottom: 15) : EdgeInsets.zero,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: (method == stateMethod)
                  ? Border.all(color: AColors.aPrimaryColor, width: 1.5)
                  : const Border()),
          child: IconButton(
            iconSize: 25,
            icon: Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: onPressed,
          ),
        );
      },
    );
  }

  _canvasView(int activePage) {
    return PageView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: imageAnnotationCubit.imagePathList.length,
          pageSnapping: true,
          scrollDirection: Axis.vertical,
          controller: pageController,
          onPageChanged: (page) {
            Log.d("TAG onPageChanged ====> $page");
          },
          itemBuilder: (context, pagePosition) {
            // Need this key to remove item and navigate to next relevant item
            var pageItemKey = GlobalKey<State>();
            var pagePaintKey = GlobalKey<State>();

            Timer(const Duration(milliseconds: 100), () {
              methodsMap[activePage]?.call(AnnotationOptions.swipe);
            });

            return Container(
              key: pageItemKey,
              padding: const EdgeInsets.all(10),
              child: FlutterPainterEx(
                key: pagePaintKey,
                imageAnnotationCubit.imagePathList[pagePosition],
                _add,
                _remove,
                builder: (BuildContext context, void Function(AnnotationOptions type) method) {
                  methodsMap[pagePosition] = method;
                },
              ),
            );
          });
  }

  setImageData(int index) {
    PainterController? controller;

    Log.d("setImageData : index : $index");
    Log.d("setImageData : painterControllerMap : ${painterControllerMap.length}");
    if (painterControllerMap.isNotEmpty && painterControllerMap.containsKey(index)) {
      controller = painterControllerMap[index];
      imageAnnotationCubit.setImageData(imageAnnotationCubit.getActivePage, controller);
    }
  }

  _addAttachment() {
    return InkWell(
      key: const Key("AddAttachment"),
      splashColor: AColors.themeBlueColor, // splash color
      onTap: () async {
        setImageData(imageAnnotationCubit.getActivePage);
        if (imagesFrom == AConstants.gallery) {
          await AFilePicker().getMultipleImages(null,null,(selectImage){
            if(selectImage["validFiles"] != null){
              Log.d("File => ${selectImage["validFiles"].toString()}");
              imageAnnotationCubit.initImagepathData(selectImage["validFiles"]);
            }
            if(selectImage["inValidFiles"] != null){
              Utility.showAlertWithOk(context, selectImage["inValidFiles"][0]);
            }
          }, mimeType);
        } else {
          Navigator.pushNamed(context, Routes.aCamera, arguments : {"allowMultiple": "true", "onlyImage": "false"})
              .then((dynamic capturedImage) {
            if (capturedImage != null) {
              imageAnnotationCubit.initImagepathData(capturedImage);
            }
          });
        }
      },
      child: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(color: AColors.themeBlueColor, shape: BoxShape.circle),
        child: const Icon(
          Icons.add,
          color: AColors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _previewList(int activePage) {
    return BlocBuilder<ImageAnnotationCubit, FlowState>(
        buildWhen: (prev, current) => current is AddAttachmentState,
        builder: (context, state) {
          return ListView.builder(
              shrinkWrap: true,
              scrollDirection: Utility.isTablet ? Axis.vertical : Axis.horizontal,
              padding: const EdgeInsets.only(top: 10, left: 10),
              itemCount: imageAnnotationCubit.imagePathList.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Log.d("onTap is ====> $activePage");
                    setImageData(activePage);

                    methodsMap[activePage]?.call(AnnotationOptions.swipe);
                    setState(() {
                      pageController.jumpToPage(index);
                    });
                  },
                  child: Container(
                    height: 85,
                    width: 95,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      border: (activePage == index)
                          ? Border.all(color: AColors.aPrimaryColor, width: 2)
                          : Border.all(color: AColors.white, width: 2),
                    ),
                    child: Image.file(
                      File(imageAnnotationCubit.imagePathList[index].imgPath),
                      cacheHeight: 83,
                      cacheWidth: 93,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final annotationWidget = SafeArea(
      child: Container(
        decoration:
            BoxDecoration(border: Border(right: BorderSide(width: 1, color: AColors.lightGreyColor))),
        child: Utility.isTablet
            ? RawScrollbar(
                thickness: 2,
                controller: scrollController,
                trackVisibility: true,
                trackColor: AColors.greyColor,
                thumbColor: AColors.aPrimaryColor,
                thumbVisibility: true,
                child: ScrollConfiguration(
                  behavior: CustomScrollBehavior(),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10,bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Free-style drawing
                          annotationOption(PhosphorIcons.scribble_loop,
                              method: AnnotationOptions.freeHand, onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.freeHand);
                          }),

                          // Add text
                          annotationOption(PhosphorIcons.text_t, method: AnnotationOptions.text,
                              onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.text);
                          }),

                          // rectangle
                          annotationOption(PhosphorIcons.rectangle, method: AnnotationOptions.square,
                              onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.square);
                          }),

                          // Arrow
                          annotationOption(PhosphorIcons.arrow_up_right,
                              method: AnnotationOptions.arrow, onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.arrow);
                          }),

                          // Redo action
                          annotationOption(PhosphorIcons.arrow_clockwise,
                              method: AnnotationOptions.redo, onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.redo);
                          }),

                          // Undo action
                          annotationOption(PhosphorIcons.arrow_counter_clockwise,
                              method: AnnotationOptions.undo, onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.undo);
                          }),

                          //setting
                          annotationOption(PhosphorIcons.paint_brush,
                              method: AnnotationOptions.settings, onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.settings);
                          }),

                          //FreeStyleErase
                          annotationOption(PhosphorIcons.eraser, method: AnnotationOptions.erase,
                              onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.erase);
                          }),

                          //ClearAll
                          annotationOption(PhosphorIcons.x, method: AnnotationOptions.clear,
                              onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.clear);
                          }),

                          //Remove
                          annotationOption(PhosphorIcons.trash, method: AnnotationOptions.delete,
                              onPressed: () {
                            if (imageAnnotationCubit.imagePathList.length <= 1) {
                              Navigator.of(context).pop();
                            } else {
                              methodsMap[imageAnnotationCubit.getActivePage]
                                  ?.call(AnnotationOptions.delete);
                              if (painterControllerMap.isNotEmpty &&
                                  painterControllerMap
                                      .containsKey(imageAnnotationCubit.getActivePage)) {
                                painterControllerMap.remove(imageAnnotationCubit.getActivePage);
                              }
                            }
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : RawScrollbar(
                thickness: 2,
                minThumbLength: 5,
                controller: scrollController,
                trackVisibility: true,
                trackColor: AColors.greyColor,
                thumbColor: AColors.aPrimaryColor,
                thumbVisibility: true,
                scrollbarOrientation: ScrollbarOrientation.bottom,
                child: ScrollConfiguration(
                  behavior: CustomScrollBehavior(),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Free-style drawing
                          annotationOption(PhosphorIcons.scribble_loop,
                              method: AnnotationOptions.freeHand, onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.freeHand);
                          }),

                          // Add text
                          annotationOption(PhosphorIcons.text_t, method: AnnotationOptions.text,
                              onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.text);
                          }),

                          // Rectangle
                          annotationOption(PhosphorIcons.rectangle, method: AnnotationOptions.square,
                              onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.square);
                          }),

                          // Arrow
                          annotationOption(PhosphorIcons.arrow_up_right,
                              method: AnnotationOptions.arrow, onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.arrow);
                          }),

                          // Redo action
                          annotationOption(PhosphorIcons.arrow_clockwise,
                              method: AnnotationOptions.redo, onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.redo);
                          }),

                          // Undo action
                          annotationOption(PhosphorIcons.arrow_counter_clockwise,
                              method: AnnotationOptions.undo, onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.undo);
                          }),

                          //setting
                          annotationOption(PhosphorIcons.paint_brush,
                              method: AnnotationOptions.settings, onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.settings);
                          }),

                          //FreeStyleErase
                          annotationOption(PhosphorIcons.eraser, method: AnnotationOptions.erase,
                              onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.erase);
                          }),

                          // ClearAll
                          annotationOption(PhosphorIcons.x, method: AnnotationOptions.clear,
                              onPressed: () {
                            methodsMap[imageAnnotationCubit.getActivePage]
                                ?.call(AnnotationOptions.clear);
                          }),

                          //Remove
                          annotationOption(PhosphorIcons.trash, method: AnnotationOptions.delete,
                              onPressed: () {
                            if (imageAnnotationCubit.imagePathList.length <= 1) {
                              Navigator.of(context).pop();
                            } else {
                              methodsMap[imageAnnotationCubit.getActivePage]
                                  ?.call(AnnotationOptions.delete);
                            }
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
        title:  NormalTextWidget(
          context.toLocale!.lbl_images,
          fontSize: 16,
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => imageAnnotationCubit),
          BlocProvider(create: (_) => annotationSelectionCubit),
        ],
        child: BlocBuilder<ImageAnnotationCubit, FlowState>(builder: (_, state) {
          int activePage = imageAnnotationCubit.getActivePage;
          Log.d("BlocBuilder activePage is +========> $activePage");

          return Column(
            children: [
              Expanded(
                child: Utility.isTablet
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 8, child: annotationWidget),
                          Expanded(flex: 77, child: _canvasView(activePage)),
                          Expanded(
                              flex: 15,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 10, right: 10),
                                child: Column(
                                  children: [
                                    _addAttachment(),
                                    Expanded(child: _previewList(activePage)),
                                  ],
                                ),
                              ))
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 13, child: annotationWidget),
                          Expanded(flex: 72, child: _canvasView(activePage)),
                          Expanded(
                              flex: 15,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Row(
                                  children: [
                                    _addAttachment(),
                                    Expanded(child: _previewList(activePage)),
                                  ],
                                ),
                              ))
                        ],
                      ),
              ),
              widgetBottomAttach(),
            ],
          );
        }),
      ),
    );
  }
}
