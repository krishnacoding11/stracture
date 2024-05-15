import 'dart:io';
import 'dart:ui' as ui;

import 'package:field/bloc/image_annotation/image_annotation_cubit.dart';
import 'package:field/image_annotation/image_annotation.dart';
import 'package:field/logger/logger.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/elevatedbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_painter/flutter_painter.dart';

import '../bloc/image_annotation/annotation_selection_cubit.dart';

class FlutterPainterEx extends StatefulWidget {
  AnnotatedImageClass imgClass;
  final MyBuilder builder;
  Function addCallback;
  Function removeCallback;
  GlobalKey? key;

  FlutterPainterEx(this.imgClass, this.addCallback, this.removeCallback,
      {super.key, required this.builder});

  @override
  _FlutterPainterExState createState() =>
      _FlutterPainterExState( builder);
}

class _FlutterPainterExState extends State<FlutterPainterEx>
    with SingleTickerProviderStateMixin {
  static const Color red = Color(0xFFFF0000);
  FocusNode textFocusNode = FocusNode();
  ui.Image? backgroundImage;
  Paint shapePaint = Paint()
    ..strokeWidth = 5
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  late PainterController controller;
  MyBuilder builder;

  _FlutterPainterExState(this.builder);

  var imageAnnotationCubit;
  var annotationSelectionCubit;
  late AnimationController animController;
  late Animation<Offset> offset;
  double strok = 5;
  double fontSize = 18;
  Color color = red;
  bool fill = false;
  bool animation = false;
  @override
  void initState() {
    super.initState();
    animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    offset = Tween(begin: const Offset(0.0, -1.0), end: Offset.zero)
        .animate(animController);
    imageAnnotationCubit = BlocProvider.of<ImageAnnotationCubit>(context);
    annotationSelectionCubit = BlocProvider.of<AnnotationSelectionCubit>(context);
    controller = PainterController(
        settings: PainterSettings(
            text: TextSettings(
              focusNode: textFocusNode,
              textStyle: const TextStyle(
                  fontWeight: FontWeight.bold, color: red, fontSize: 18),
            ),
            freeStyle: const FreeStyleSettings(
              color: red,
              strokeWidth: 5,
            ),
            shape: ShapeSettings(
              drawOnce: false,
              paint: shapePaint,
            ),
            scale: const ScaleSettings(
              enabled: false,
              minScale: 1,
              maxScale: 5,
            )));
    // Listen to focus events of the text field
    textFocusNode.addListener(onFocus);
    // Initialize background
    initBackground();
  }

  // Future<ui.Image> getUiImage(String imgPath,
  //     {double? height, double? width}) async {
  //   // final ByteData assetImageByteData =
  //   //     (await rootBundle.load(widget.imgClass.imgPath)) as ByteData;
  //
  //   Uint8List imgbytes = await File(imgPath).readAsBytes();
  //
  //   img.Image? baseSizeImage = img.decodeImage(imgbytes.buffer.asUint8List());
  //   img.Image resizeImage = img.copyResize(baseSizeImage!,
  //       height: height?.toInt(), width: width?.toInt());
  //   ui.Codec codec = await ui
  //       .instantiateImageCodec(Uint8List.fromList(img.encodePng(resizeImage)));
  //   ui.FrameInfo frameInfo = await codec.getNextFrame();
  //   return frameInfo.image;
  // }

  /// Fetches image from an [ImageProvider] (in this example, [NetworkImage])
  /// to use it as a background
  void initBackground() async {
    ui.Image? image =
        await decodeImageFromList(File(widget.imgClass.imgPath).readAsBytesSync());

    Log.d(
        "initBackground width is ====> ${widget.key?.currentContext?.size!.width}");
    setState(() {
      backgroundImage = image;
      if (widget.imgClass.drawables != null &&
          widget.imgClass.drawables!.isNotEmpty) {
        controller.addDrawables(widget.imgClass.drawables as Iterable<Drawable>,
            newAction: true);
      }
      controller.background = image.backgroundDrawable;
    });

    widget.addCallback(controller);

    Log.d("Height is ====> ${backgroundImage?.height}");
    Log.d("Width is ====> ${backgroundImage?.width}");
    widget.imgClass.size = Size(
        widget.key?.currentContext?.size!.width.toDouble() ?? 0,
        widget.key?.currentContext?.size!.height.toDouble() ?? 0);
  }

  method(dynamic type) {
    Log.d("Method called $type");
    annotationSelectionCubit.showSelectedAnnotation(type);
    if(type != AnnotationOptions.text){
      if(textFocusNode.hasFocus){
        textFocusNode.unfocus();
      }
    }
    if (type == AnnotationOptions.delete) {
      widget.removeCallback();
    } else if (type == AnnotationOptions.flip) {
      if (controller.selectedObjectDrawable != null &&
          controller.selectedObjectDrawable is ImageDrawable) {
        flipSelectedImageDrawable();
      }
    } else if (type == AnnotationOptions.redo) {
      swipe();
      if (controller.canRedo) {
        redo();
      }
    } else if (type == AnnotationOptions.undo) {
      swipe();
      if (controller.canUndo) {
        undo();
      }
    } else if (type == AnnotationOptions.erase) {
      swipe();
      toggleFreeStyleErase();
    } else if (type == AnnotationOptions.freeHand) {
      swipe();
      toggleFreeStyleDraw();
    } else if (type == AnnotationOptions.text) {
      if(controller.selectedObjectDrawable != null) {
        setState(() {
          controller.selectObjectDrawable(null);
        });
      }
      swipe();
      addText();
    } else if (type == AnnotationOptions.square) {
      swipe();
      selectShape(RectangleFactory(
          borderRadius: const BorderRadius.all(Radius.circular(2))));
    } else if (type == AnnotationOptions.arrow) {
      swipe();
      selectShape(ArrowFactory());
    } else if (type == AnnotationOptions.swipe) {
      swipe();
    } else if (type == AnnotationOptions.clear) {
      swipe();
      controller.clearDrawables();
    } else if (type == AnnotationOptions.settings) {
      drawer();
    }
  }

  void drawer() {
    switch (animController.status) {
      case AnimationStatus.completed:
        animController.reverse();
        break;
      case AnimationStatus.dismissed:
        animController.forward();
        break;
      default:
    }
  }

  /// Updates UI when the focus changes
  void onFocus() {
    setState(() {});
    if(controller.selectedObjectDrawable != null) controller.selectedObjectDrawable?.copyWith(hidden: textFocusNode.hasFocus);
    if(textFocusNode.hasFocus) {
      annotationSelectionCubit.showSelectedAnnotation(AnnotationOptions.text);
    }
  }

  GlobalKey key = GlobalKey();

  Widget buildDefault(BuildContext context) {
    builder.call(context, method);
    return Stack(
      children: [
        if (backgroundImage != null)
          // Enforces constraints
          Positioned.fill(
            child: Center(
              child: AspectRatio(
                aspectRatio: backgroundImage!.width / backgroundImage!.height,
                child: FlutterPainter(
                  key: key,
                  controller: controller,
                  onDrawableCreated: (drawable) {},
                  onDrawableDeleted: (drawable) {},
                  onPainterSettingsChanged: (value) {},
                  onSelectedObjectDrawableChanged: (value) {},
                ),
              ),
            ),
          ),
        Positioned(
            top: -5,
            right: 0,
            left: 0,
            child: SlideTransition(
              position: offset,
              child: Center(
                child: Container(
                  height: 272,
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20)),
                    color: Colors.white,
                  ),
                  child: Column(
                    // direction: Axis.horizontal,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 15),
                      const Text(
                        "Settings",
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Expanded(
                              flex: 2,
                              child: Text(
                                "Font Size",
                              )),
                          Expanded(
                            flex: 6,
                            child: Slider.adaptive(
                                min: 8,
                                max: 96,
                                value: controller.textStyle.fontSize ?? 14,
                                onChanged:
                                  setTextFontSize)

                          ),
                          Expanded(
                              child: Text(controller.textStyle.fontSize!
                                  .round()
                                  .toString())),
                        ],),
                        Row(
                          children: [
                            const Expanded(flex: 2, child: Text("Stroke Width")),
                          Expanded(
                            flex: 6,
                            child: Slider.adaptive(
                                min: 2,
                                max: 25,
                                value: controller.freeStyleStrokeWidth,
                                onChanged: (value) {
                                  strokeWidth(value);
                                  setShapeFactoryPaint(
                                      (controller.shapePaint ?? shapePaint)
                                          .copyWith(
                                    strokeWidth: value,
                                  ));
                                }),
                          ),
                          Expanded(
                            child: Text(
                              controller.freeStyleStrokeWidth
                                  .round()
                                  .toString(),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Expanded(flex: 2, child: Text("Color")),
                          // Control free style color hue
                          Expanded(
                            flex: 6,
                              child: Slider.adaptive(
                                  min: 0,
                                  max: 359.99,
                                  value:
                                      HSVColor.fromColor(controller.freeStyleColor)
                                          .hue,
                                  activeColor: controller.freeStyleColor,
                                  thumbColor: controller.freeStyleColor,
                                  onChanged: ((value) {
                                    setStyleColor(value);
                                    setShapeFactoryPaint(
                                        (controller.shapePaint ?? shapePaint)
                                            .copyWith(
                                      color: HSVColor.fromAHSV(1, value, 1, 1)
                                          .toColor(),
                                    ));
                                  })),
                            ),Expanded(child: Container()),
                          ],
                        ),
                        Row(
                          children: [
                            const Expanded(flex: 1, child: Text("Fill shape")),
                            Expanded(
                              flex: 3,
                              child: Center(
                                child: Switch(
                                    value: (controller.shapePaint ?? shapePaint)
                                            .style ==
                                        PaintingStyle.fill,
                                    onChanged: (value) => setShapeFactoryPaint(
                                            (controller.shapePaint ?? shapePaint)
                                                .copyWith(
                                          style: value
                                              ? PaintingStyle.fill
                                              : PaintingStyle.stroke,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          AElevatedButtonWidget(
                            height: 30,
                            fontWeight: AFontWight.medium,
                            borderRadius: 4,
                            fontFamily: AFonts.fontFamily,
                            fontSize: 15,
                            btnLabelClr: AColors.aPrimaryColor,
                            btnBackgroundClr: AColors.white,
                            btnLabel: context.toLocale!.lbl_btn_cancel,
                            onPressed: () {
                              cancleBtn();
                              drawer();
                            },
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          AElevatedButtonWidget(
                            height: 30,
                            fontWeight: AFontWight.medium,
                            borderRadius: 4,
                            fontFamily: AFonts.fontFamily,
                            fontSize: 15,
                            btnLabelClr: AColors.white,
                            btnBackgroundClr: AColors.themeBlueColor,
                            btnLabel: context.toLocale!.lbl_btn_apply,
                            onPressed: () {
                              strok = controller.freeStyleStrokeWidth;
                              fontSize = controller.textStyle.fontSize ?? 18;
                              color = controller.freeStyleColor;
                              fill = (controller.shapePaint ?? shapePaint).style ==
                                      PaintingStyle.fill
                                  ? true
                                  : false;
                              drawer();
                              updateSelectedDrawable();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildDefault(context);
  }

  void cancleBtn() {
    setStyleColor(HSVColor.fromColor(color).hue);
    strokeWidth(strok);
    setShapeFactoryPaint((controller.shapePaint ?? shapePaint).copyWith(
        style: fill ? PaintingStyle.fill : PaintingStyle.stroke,
        strokeWidth: strok,
        color: color));
    setTextFontSize(fontSize);
  }

  void undo() {
    controller.undo();
  }

  void redo() {
    controller.redo();
  }

  void toggleFreeStyleDraw() {
    controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.draw
        ? FreeStyleMode.draw
        : FreeStyleMode.none;
  }

  void swipe() {
    animController.reverse();
   cancleBtn();
    controller.shapeFactory = null;
    if (controller.freeStyleMode != FreeStyleMode.none) {
      controller.freeStyleMode = FreeStyleMode.none;
    }
  }

  void toggleFreeStyleErase() {
    controller.freeStyleMode = controller.freeStyleMode != FreeStyleMode.erase
        ? FreeStyleMode.erase
        : FreeStyleMode.none;
  }

  void addText() {
    if (controller.freeStyleMode != FreeStyleMode.none) {
      controller.freeStyleMode = FreeStyleMode.none;
    }
    controller.addText();
  }

  void strokeWidth(double value) {
    controller.freeStyleStrokeWidth = value;
  }

  void setStyleColor(double hue) {
    controller.freeStyleColor = HSVColor.fromAHSV(1, hue, 1, 1).toColor();
    controller.textStyle = controller.textStyle
        .copyWith(color: HSVColor.fromAHSV(1, hue, 1, 1).toColor());
  }

  void setTextFontSize(double size) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.textSettings = controller.textSettings.copyWith(
          textStyle: controller.textSettings.textStyle.copyWith(fontSize: size));
    });
  }

  void setShapeFactoryPaint(Paint paint) {
    // Set state is just to update the current UI, the [FlutterPainter] UI updates without it
    setState(() {
      controller.shapePaint = paint;
    });
  }

  void selectShape(ShapeFactory? factory) {
    controller.shapeFactory = factory;
  }

  void removeSelectedDrawable() {
    final selectedDrawable = controller.selectedObjectDrawable;
    if (selectedDrawable != null) controller.removeDrawable(selectedDrawable);
  }

  void flipSelectedImageDrawable() {
    final imageDrawable = controller.selectedObjectDrawable;
    if (imageDrawable is! ImageDrawable) return;

    controller.replaceDrawable(
        imageDrawable, imageDrawable.copyWith(flipped: !imageDrawable.flipped));
  }

  @override
  void dispose() {
    Log.d("TAG dispose called");
    // Dispose of the controller when the widget is disposed.
    if (controller != null) {
      controller.dispose();
      Log.d("TAG dispose controller");
    }
    if (backgroundImage != null) {
      backgroundImage?.dispose();
      Log.d("TAG dispose backgroundImage");
    }
    super.dispose();
  }

  updateSelectedDrawable() {
    if (controller.selectedObjectDrawable != null) {
      if (controller.selectedObjectDrawable
      is ShapeDrawable) {
        var currentPaint = controller.shapePaint;
        var newPaint = (controller.selectedObjectDrawable
        as ShapeDrawable)
            .paint;
        if (currentPaint != newPaint &&
            controller.selectedObjectDrawable
            is ShapeDrawable) {
          setState(() {
            var paint = (controller.selectedObjectDrawable
            as ShapeDrawable)
                .paint;
            paint.color = color;
            paint.strokeWidth = strok;
            paint.style = controller.shapePaint!.style;
          });
        }
      } else if (controller.selectedObjectDrawable
      is TextDrawable) {
        setState(() {
          var oldDrawable = (controller.selectedObjectDrawable as TextDrawable);
          var drawable = (controller.selectedObjectDrawable as TextDrawable)
              .copyWith(
              style: TextStyle(color: color, fontSize: fontSize));
          controller.replaceDrawable(oldDrawable, drawable);
        });
      }
    }
  }
}
