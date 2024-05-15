import 'dart:io';

import 'package:camera/camera.dart';
import 'package:field/bloc/a_camera/a_camera_cubit.dart';
import 'package:field/bloc/a_camera/a_camera_state.dart';
import 'package:field/logger/logger.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/routes_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../presentation/base/state_renderer/state_render_impl.dart';

class ACamera extends StatefulWidget {
  final dynamic arguments;

  const ACamera(this.arguments, {Key? key}) : super(key: key);

  @override
  State<ACamera> createState() {
    return _ACameraState();
  }
}

class _ACameraState extends State<ACamera> with WidgetsBindingObserver, TickerProviderStateMixin {
  ACameraCubit? aCameraCubit;
  String? allowMultiple = "false";
  String? onlyImage = "false";
  bool _isControllerDisposed = false;

  @override
  void initState() {
    super.initState();

    allowMultiple = widget.arguments["allowMultiple"];
    onlyImage = widget.arguments["onlyImage"];

    WidgetsBinding.instance.addObserver(this);
    aCameraCubit = BlocProvider.of<ACameraCubit>(context);
    aCameraCubit!.getAvailableCameras();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    Future.delayed(Duration(milliseconds: 100));
    aCameraCubit!.fetchCurrentLocation();
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    if(aCameraCubit!.controller != null){
      aCameraCubit!.controller!.dispose();
    }
    _controller.dispose();
    _isControllerDisposed = true;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = aCameraCubit!.controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive && !aCameraCubit!.controller!.value.isInitialized) {
      // cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      aCameraCubit!.onNewCameraSelected(cameraController.description);
    }
  }

  late AnimationController _controller;
  GlobalKey previewKey = GlobalKey();
  late double screenWidth, screenHeight;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenHeight = size.height;
    screenWidth = size.width;
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Material(
      color: Colors.black,
      child: Container(
        margin: EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top + 20),
        child: BlocListener<ACameraCubit, FlowState>(
          listener: (context, state) {
            if (state is ErrorState && state.stateRendererType == StateRendererType.DEFAULT) {
              if (state.code == 1) {
                showInSnackBar(context.toLocale!.error_select_camera);
              } else {
                Log.d("Error => ${state.message}");
              }
            }
          },
          child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
            final Size biggest = constraints.biggest;
            return Stack(
              children: <Widget>[
                BlocBuilder<ACameraCubit, FlowState>(builder: (context, state) {
                  return Positioned.fill(
                    child: Align(
                      alignment: Alignment.center,
                      child: _cameraPreviewWidget(),
                    ),
                  );
                }),
                // Positioned.fill(
                //   child: overlayCameraPreview(),
                // ),
                Positioned.fill(
                    child: Align(
                  alignment: Alignment.topCenter,
                  child: cameraOrVideoSelection(),
                )),
                Positioned.fill(
                    left: 15,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: AColors.black.withOpacity(0.5),
                              border: Border.all(
                                color: Colors.white,
                                width: 2.0,
                              ),
                              shape: BoxShape.circle),
                          padding: const EdgeInsets.all(6.0),
                          child: const Icon(
                            Icons.close_rounded,
                            color: AColors.white,
                          ),
                        ),
                      ),
                    )),
                Positioned.fill(
                  top: 10,
                  child: Align(
                    alignment: Alignment.topRight,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _modeControlRowWidget(),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: BlocBuilder<ACameraCubit, FlowState>(builder: (context, state) {
                            return _cameraTogglesRowWidget();
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(child: OrientationBuilder(builder: (context, orientation) {
                  Alignment captureAlignment = orientation == Orientation.landscape ? Alignment.centerRight : Alignment.bottomCenter;
                  return Align(alignment: captureAlignment, child: _captureControlRowWidget());
                })),
                BlocBuilder<ACameraCubit, FlowState>(builder: (_, state) {
                  double animtaionStartSize = screenWidth * 0.8; //screenWidth /2
                  var offset = const Offset(50.0, 75.0);
                  const double animationEndSize = 0;
                  var previewRect = previewKey.globalPaintBounds;

                  if (aCameraCubit!.isTakePicture) {
                    var rect = RelativeRectTween(
                      begin: RelativeRect.fromSize(Rect.fromLTWH(offset.dx, offset.dy, (previewRect != null) ? previewRect.left - offset.dx : animtaionStartSize, (previewRect != null) ? previewRect.top - offset.dy - MediaQuery.of(context).viewPadding.top : screenHeight * 0.8), biggest),
                      end: RelativeRect.fromSize(
                          Rect.fromLTWH(
                              (previewRect != null) ? previewRect.left + previewRect.width / 2 : screenWidth * 0.9,
                              (previewRect != null)
                                  ? previewRect.top - MediaQuery.of(context).viewPadding.top /*-
                                        MediaQuery.of(context).viewPadding.bottom +
                                        10*/ // previewRect.height / 2
                                  : screenHeight * 0.9,
                              animationEndSize,
                              animationEndSize),
                          biggest),
                    );
                    String imgFile = "";
                    if (aCameraCubit!.imagesList != null && aCameraCubit!.imagesList!.isNotEmpty) {
                      imgFile = (aCameraCubit!.imagesList![aCameraCubit!.imagesList!.length - 1]).path;
                    }
                    return Visibility(
                      visible: aCameraCubit!.isTakePicture ? true : false,
                      child: PositionedTransition(
                          rect: rect.animate(CurvedAnimation(
                            parent: _controller,
                            curve: Curves.fastOutSlowIn,
                          )),
                          child: Align(
                            alignment: Alignment.center,
                            child: Image.file(
                              File(imgFile),
                              frameBuilder: (
                                BuildContext context,
                                Widget child,
                                int? frame,
                                bool wasSynchronouslyLoaded,
                              ) {
                                if (frame != null) {
                                  Future.delayed(const Duration(milliseconds: 500)).then((value) {
                                    if (!_isControllerDisposed) {
                                      _controller.forward(from: 0).whenComplete(() {
                                        aCameraCubit!.isTakePicture = false;
                                        aCameraCubit!.emitAnimationEndState();
                                      });
                                    }
                                  });
                                }
                                return Container(
                                    decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                                  border: Border.all(color: Colors.white, width: 2),
                                  image: DecorationImage(fit: BoxFit.fill, image: FileImage(File(imgFile))),
                                ));
                              },
                            ),
                          )),
                    );
                  } else {
                    return const Visibility(
                      visible: false,
                      child: SizedBox(
                        width: 0,
                        height: 0,
                      ),
                    );
                  }
                }),
                if (allowMultiple == "true")
                  BlocBuilder<ACameraCubit, FlowState>(
                      buildWhen: (prev, curr) => curr is CameraState,
                      builder: (context, state) {
                        return Positioned.fill(
                            child: Align(
                          alignment: Alignment.bottomRight,
                          child: _capturedPreviewWidget(),
                        ));
                      }),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTimer() {
    final String minutes = aCameraCubit!.formatNumber(aCameraCubit!.recordDuration ~/ 60);
    final String seconds = aCameraCubit!.formatNumber(aCameraCubit!.recordDuration % 60);
    if (aCameraCubit!.recordDuration >= aCameraCubit!.maxDuration) {
      _onStopButtonPressed();
      return Container();
    }
    return NormalTextWidget(
      '$minutes : $seconds',
      color: Colors.red,
      fontSize: 18,
    );
  }

  Widget cameraOrVideoSelection() {
    return BlocBuilder<ACameraCubit, FlowState>(builder: (_, state) {
      return (aCameraCubit != null && aCameraCubit!.controller != null && aCameraCubit!.controller!.value.isInitialized && aCameraCubit!.controller!.value.isRecordingVideo)
          ? _buildTimer()
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: () {
                    if (aCameraCubit != null && aCameraCubit!.controller != null && aCameraCubit!.controller!.value.isInitialized && !aCameraCubit!.controller!.value.isRecordingVideo) {
                      aCameraCubit!.cameraType = false;
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(color: !aCameraCubit!.isVideoSelected ? AColors.grColor.withOpacity(0.5) : Colors.transparent, borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.only(left: 15, right: 15, top: 7, bottom: 5),
                    child: const NormalTextWidget(
                      'PHOTO',
                      color: AColors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                if (onlyImage == "false")
                  InkWell(
                    onTap: () {
                      if (aCameraCubit != null && aCameraCubit!.controller != null && aCameraCubit!.controller!.value.isInitialized && !aCameraCubit!.controller!.value.isRecordingVideo) {
                        aCameraCubit!.cameraType = true;
                      }
                    },
                    child: Container(decoration: BoxDecoration(color: aCameraCubit!.isVideoSelected ? AColors.grColor.withOpacity(0.5) : Colors.transparent, borderRadius: BorderRadius.circular(20)), padding: const EdgeInsets.only(left: 15, right: 15, top: 7, bottom: 5), child: const NormalTextWidget('VIDEO', color: AColors.white)),
                  ),
              ],
            );
    });
  }

  //Commenting code as this function not ben used..
  // Widget overlayCameraPreview() {
  //   final size = MediaQuery.of(context).size;
  //
  //   // calculate scale depending on screen and camera ratios
  //   // this is actually size.aspectRatio / (1 / camera.aspectRatio)
  //   // because camera preview size is received as landscape
  //   // but we're calculating for portrait orientation
  //
  //   var scale = Utility.isTablet
  //       ? size.aspectRatio
  //       : size.aspectRatio; // * aCameraCubit?.controller?.value.aspectRatio??1;
  //
  //   // to prevent scaling down, invert the value
  //   if (scale < 1) scale = 1 / scale;
  //
  //   return BlocBuilder<ACameraCubit, FlowState>(builder: (context, state) {
  //     return Transform.scale(
  //         scale: scale,
  //         child: Visibility(
  //           visible: aCameraCubit!.isTakePicture ? true : false,
  //           child: Container(
  //             margin:
  //                 EdgeInsets.only(top: MediaQuery.of(context).viewPadding.top + 10),
  //             decoration: BoxDecoration(
  //               color: Colors.black.withOpacity(0.8),
  //               // border: Border.all(
  //               //   color: Colors.red,
  //               //   width: 3.0,
  //               // ),
  //             ),
  //           ),
  //         ));
  //   });
  // }

  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = aCameraCubit!.controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return Container();
    } else {
      final size = MediaQuery.of(context).size;

      // calculate scale depending on screen and camera ratios
      // this is actually size.aspectRatio / (1 / camera.aspectRatio)
      // because camera preview size is received as landscape
      // but we're calculating for portrait orientation

      var scale = Utility.isTablet ? size.aspectRatio : size.aspectRatio * cameraController.value.aspectRatio;

      // to prevent scaling down, invert the value
      if (scale < 1) scale = 1 / scale;

      final cameraWidget = CameraPreview(aCameraCubit!.controller!, child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (TapDownDetails details) => onViewFinderTap(details, constraints),
          );
        },
      ));
      return Listener(
          onPointerDown: (_) => aCameraCubit!.pointers++,
          onPointerUp: (_) => aCameraCubit!.pointers--,
          child: Transform.scale(scale: scale, child: cameraWidget
              // Utility.isTablet
              //     ? cameraWidget
              // AspectRatio(
              //         aspectRatio: cameraController.value.aspectRatio,
              //         child: cameraWidget,
              //       )
              //     : cameraWidget,
              ));
    }
  }

  Widget _modeControlRowWidget() {
    return BlocBuilder<ACameraCubit, FlowState>(
        buildWhen: (current, prev) => current is! ErrorState,
        builder: (context, state) {
          return IconButton(
            icon: aCameraCubit!.controller?.value.flashMode == FlashMode.off || aCameraCubit!.controller?.value.flashMode == FlashMode.auto
                ? Icon(
                    Icons.flash_off,
                    color: AColors.darkGreyColor,
                    size: 28,
                  )
                : Icon(
                    Icons.flash_on,
                    color: AColors.darkGreyColor,
                    size: 28,
                  ),
            color: aCameraCubit!.controller?.value.flashMode == FlashMode.off || aCameraCubit!.controller?.value.flashMode == FlashMode.auto ? AColors.iconGreyColor : AColors.themeBlueColor,
            onPressed: aCameraCubit!.controller != null
                ? () {
                    if (aCameraCubit!.controller?.value.flashMode != null) {
                      if (aCameraCubit!.controller?.value.flashMode == FlashMode.off || aCameraCubit!.controller?.value.flashMode == FlashMode.auto) {
                        aCameraCubit!.onSetFlashModeButtonPressed(FlashMode.torch);
                      } else {
                        aCameraCubit!.onSetFlashModeButtonPressed(FlashMode.off);
                      }
                    }
                  }
                : null,
          );
        });
  }

  Widget imageCaptureWidget() {
    return Image.asset(
      "assets/images/ic_camera_capture.png",
      height: 55,
      color: (aCameraCubit!.isTakePicture) ? AColors.lightGreyColor : Colors.white,
    );
  }

  Widget videoCaptureWidget() {
    return (aCameraCubit?.controller != null && aCameraCubit!.controller!.value.isInitialized && aCameraCubit!.controller!.value.isRecordingVideo) ? Image.asset("assets/images/ic_video_stop.png", height: 55) : Image.asset("assets/images/ic_video_capture.png", height: 55);
  }

  Widget _capturedPreviewWidget() {
    String imgFile = "";
    if (aCameraCubit!.imagesList != null && aCameraCubit!.imagesList!.isNotEmpty) {
      imgFile = (aCameraCubit!.imagesList![aCameraCubit!.imagesList!.length - 1]).path;
    }

    return Container(
      width: 75,
      alignment: Alignment.center,
      height: 75,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 10),
      child: Stack(
        children: [
          InkWell(
            key: previewKey,
            onTap: () {
              if (aCameraCubit?.controller != null && aCameraCubit!.controller!.value.isInitialized && aCameraCubit!.controller!.value.isRecordingVideo) {
                aCameraCubit!.stopVideoRecording().then((result) {
                  Navigator.pop(context, aCameraCubit!.imagesList);
                });
              } else {
                Navigator.pop(context, aCameraCubit!.imagesList);
              }
            },
            child: (imgFile.isNotEmpty)
                ? Container(
                    decoration: BoxDecoration(
                      color: AColors.black.withOpacity(0.5),
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(fit: BoxFit.fill, image: FileImage(File(imgFile))),
                        )))
                : null,
          ),
          Visibility(
            visible: (aCameraCubit!.imagesList != null && aCameraCubit!.imagesList!.isNotEmpty) ? true : false,
            child: Positioned(
              top: 0.0,
              right: 0.0,
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.5),
                ),
                constraints: const BoxConstraints(
                  minWidth: 15,
                  minHeight: 15,
                ),
                child: NormalTextWidget(
                  '${aCameraCubit!.imagesList?.length}',
                  textAlign: TextAlign.center,
                  color: AColors.black,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _captureControlRowWidget() {
    return Container(
      height: 75,
      width: 75,
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom + 10),
      child: InkWell(onTap: () {
        if (!aCameraCubit!.isVideoSelected) {
          if (!aCameraCubit!.isTakePicture) {
            aCameraCubit!.isTakePicture = true;
            final clearList = allowMultiple == "false";
            aCameraCubit!.onTakePictureButtonPressed(clearList)!.then((List<XFile>? imageFile) {
              Log.d("Image path ==> ${imageFile.toString()}");
              // _controller.stop();
              if (imageFile != null && allowMultiple == "false") {
                Navigator.pushNamed(NavigationUtils.mainNavigationKey.currentContext!, Routes.imagePreview, arguments: {"capturedFile": imageFile[0]}).then((dynamic capturedImage) {
                  if (capturedImage != null) {
                    Navigator.pop(context, imageFile);
                  } else {
                    aCameraCubit!.isTakePicture = false;
                    aCameraCubit!.emitAnimationEndState();
                  }
                });
              }
            });
          }
        } else {
          aCameraCubit?.controller != null && aCameraCubit!.controller!.value.isInitialized && aCameraCubit!.controller!.value.isRecordingVideo ? _onStopButtonPressed() : _onRecordButtonPressed();
        }
      }, child: BlocBuilder<ACameraCubit, FlowState>(builder: (_, state) {
        return Container(
          child: !aCameraCubit!.isVideoSelected ? imageCaptureWidget() : videoCaptureWidget(),
        );
      })),
    );
  }

  void _onRecordButtonPressed() {
    aCameraCubit!.startVideoRecording().then((_) {});
  }

  void _onStopButtonPressed() {
    aCameraCubit!.stopVideoRecording().then((result) {
      if (allowMultiple == "false") {
        Navigator.pop(context, aCameraCubit!.imagesList);
      } else {
        aCameraCubit!.emitAnimationEndState();
      }
    });
  }

  Widget _cameraTogglesRowWidget() {
    if (aCameraCubit!.cameras.isEmpty) {
      _ambiguate(SchedulerBinding.instance)?.addPostFrameCallback((_) async {});
      return const Text('None');
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
          onTap: () {
            if (aCameraCubit!.controller!.description != null) {
              if (aCameraCubit!.controller!.description.lensDirection == CameraLensDirection.front) {
                aCameraCubit!.onNewCameraSelected(aCameraCubit!.cameras.where((element) => element.lensDirection == CameraLensDirection.back).first);
              } else {
                aCameraCubit!.onNewCameraSelected(aCameraCubit!.cameras.where((element) => element.lensDirection == CameraLensDirection.front).first);
              }
            }
          },
          child: Icon(
            Icons.flip_camera_ios_rounded,
            color: AColors.darkGreyColor,
            size: 28,
          )),
    );
  }

  void showInSnackBar(String message) {
    context.showSnack(message);
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (aCameraCubit!.controller == null) {
      return;
    }

    final CameraController cameraController = aCameraCubit!.controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
  }
}

T? _ambiguate<T>(T? value) => value;
