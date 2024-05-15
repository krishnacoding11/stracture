import 'package:camera/camera.dart';
import 'package:field/bloc/a_camera/a_camera_cubit.dart';
import 'package:field/logger/logger.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideoRecorderExample extends StatefulWidget {
  @override
  _VideoRecorderExampleState createState() {
    return _VideoRecorderExampleState();
  }
}

class _VideoRecorderExampleState extends State<VideoRecorderExample>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  String? videoPath;
  ACameraCubit? aCameraCubit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    aCameraCubit = BlocProvider.of<ACameraCubit>(context);
    aCameraCubit!.getAvailableCameras();
  }

  @override
  void dispose() {
    _ambiguate(WidgetsBinding.instance)?.removeObserver(this);
    aCameraCubit!.controller!.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = aCameraCubit!.controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive &&
        !aCameraCubit!.controller!.value.isInitialized) {
      // cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      aCameraCubit!.onNewCameraSelected(cameraController.description);
    }
  }

  void showInSnackBar(String message) {
    context.showSnack(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const NormalTextWidget('Video record',color: AColors.white,fontSize: 18,),
      ),
      body: BlocListener<ACameraCubit, FlowState>(
          listener: (context, state) {
            if (state is ErrorState &&
                state.stateRendererType == StateRendererType.DEFAULT) {
              if (state.code == 1) {
                showInSnackBar(context.toLocale!.error_select_camera);
              } else {
                showInSnackBar(state.message);
              }
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _modeControlRowWidget(),
                  !Utility.isIos
                      ? Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: BlocBuilder<ACameraCubit, FlowState>(
                              builder: (context, state) {
                            return _cameraTogglesRowWidget();
                          }),
                        )
                      : Container(),
                ],
              ),
              Expanded(
                child: BlocBuilder<ACameraCubit, FlowState>(
                  builder: (context, state) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        border: Border.all(
                          color: aCameraCubit!.controller != null &&
                                  aCameraCubit!.controller!.value.isRecordingVideo
                              ? Colors.redAccent
                              : Colors.grey,
                          width: 3.0,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: Center(child: BlocBuilder<ACameraCubit, FlowState>(
                          builder: (context, state) {
                            return _cameraPreviewWidget();
                          },
                        )),
                      ),
                    );
                  },
                ),
              ),
              _captureControlRowWidget(),
            ],
          )),
    );
  }

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
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

  // Display 'Loading' text when the camera is still loading.
  Widget _cameraPreviewWidget() {
    final CameraController? cameraController = aCameraCubit!.controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return Container();
    } else {
      return Listener(
          onPointerDown: (_) => aCameraCubit!.pointers++,
          onPointerUp: (_) => aCameraCubit!.pointers--,
          child: CameraPreview(aCameraCubit!.controller!, child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (TapDownDetails details) =>
                    onViewFinderTap(details, constraints),
              );
            },
          )));
    }
  }

  Widget _modeControlRowWidget() {
    return BlocBuilder<ACameraCubit, FlowState>(builder: (context, state) {
      return IconButton(
        icon: aCameraCubit!.controller?.value.flashMode == FlashMode.off ||
                aCameraCubit!.controller?.value.flashMode == FlashMode.auto
            ? const Icon(Icons.flash_off)
            : const Icon(Icons.flash_on),
        color: aCameraCubit!.controller?.value.flashMode == FlashMode.off ||
                aCameraCubit!.controller?.value.flashMode == FlashMode.auto
            ? AColors.iconGreyColor
            : AColors.themeBlueColor,
        onPressed: aCameraCubit!.controller != null
            ? () {
                if (aCameraCubit!.controller?.value.flashMode == FlashMode.off ||
                    aCameraCubit!.controller?.value.flashMode == FlashMode.auto) {
                  aCameraCubit!.onSetFlashModeButtonPressed(FlashMode.torch);
                } else {
                  aCameraCubit!.onSetFlashModeButtonPressed(FlashMode.off);
                }
              }
            : null,
      );
    });
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
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
              if (aCameraCubit!.controller!.description ==
                  aCameraCubit!.cameras.first) {
                aCameraCubit!.onNewCameraSelected(aCameraCubit!.cameras.last);
              } else {
                aCameraCubit!.onNewCameraSelected(aCameraCubit!.cameras.first);
              }
            }
          },
          child: Icon(
            Icons.flip_camera_android,
            color: AColors.themeBlueColor,
          )),
    );
  }

  /// Display the control bar with buttons to record videos.
  Widget _captureControlRowWidget() {
    return Align(
      alignment: Alignment.center,
      child: BlocBuilder<ACameraCubit, FlowState>(
        builder: (context, state) {
          Log.d("Bloc builder ====> $state");
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: IconButton(
                  iconSize: 55,
                  padding: EdgeInsets.zero,
                  onPressed: aCameraCubit?.controller != null &&
                          aCameraCubit!.controller!.value.isInitialized &&
                          aCameraCubit!.controller!.value.isRecordingVideo
                      ? _onStopButtonPressed
                      : _onRecordButtonPressed,
                  icon: Icon(
                    color: AColors.aPrimaryColor,
                    aCameraCubit?.controller != null &&
                            aCameraCubit!.controller!.value.isInitialized &&
                            aCameraCubit!.controller!.value.isRecordingVideo
                        ? Icons.stop_circle_rounded
                        : Icons.camera,
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void _onRecordButtonPressed() {
    aCameraCubit!.startVideoRecording().then((_) {
      // var timer = Timer(Duration(seconds: 31), () {});
    });
  }

  void _onStopButtonPressed() {
    aCameraCubit!.stopVideoRecording().then((result) {
      Log.d("Video path ===> $result");
      Navigator.of(context).pop(result);
    });
  }
}

T? _ambiguate<T>(T? value) => value;
