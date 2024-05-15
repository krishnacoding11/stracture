import 'dart:async';

import 'package:camera/camera.dart';
import 'package:field/bloc/a_camera/a_camera_state.dart';
import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as location_package;
import 'package:native_exif/native_exif.dart';

import '../../logger/logger.dart';
import '../../presentation/base/state_renderer/state_renderer.dart';
import '../../utils/store_preference.dart';

class ACameraCubit extends BaseCubit {
  ACameraCubit() : super(FlowState());

  List<CameraDescription> cameras = <CameraDescription>[];

  CameraController? controller;
  List<XFile>? imageFile = [];
  double minAvailableZoom = 1.0;
  double maxAvailableZoom = 1.0;
  double currentScale = 1.0;
  double baseScale = 1.0;
  int pointers = 0;
  bool isPreviewBuild = false;
  bool _isVideoSelected = false;
  bool _isTakePicture = false;
  bool _isGeoTagEnabled = false;
  final dateFormat = DateFormat('yyyy:MM:dd HH:mm:ss');

  List<XFile>? get imagesList => imageFile;

  bool get isVideoSelected => _isVideoSelected;
  bool get isTakePicture => _isTakePicture;

  Future<bool> getGeoTagSettings() async {
    String isGeoTagEnabled = await StorePreference.getProjectGeoTagSettings();
    _isGeoTagEnabled = isGeoTagEnabled == "true" ? true : false;
    return _isGeoTagEnabled;
  }

  location_package.Location locationService = new location_package.Location();
  late location_package.PermissionStatus _permissionGranted;
  location_package.LocationData? location;

  int _recordDuration = 0;
  Timer? _timer;
  final maxDuration = 31;

  get recordDuration => _recordDuration;

  fetchCurrentLocation() async {
    var isGeoTagEnabled = await getGeoTagSettings();
    if(!isGeoTagEnabled) {
      return;
    }
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      bool serviceStatus = await locationService.serviceEnabled();
      Log.d("Service status: $serviceStatus");

      await locationService.requestPermission().then(
        (value) {
          _permissionGranted = value;
        },
      );

      if (serviceStatus) {
        Log.d("Permission: $_permissionGranted");
        if (_permissionGranted == location_package.PermissionStatus.granted) {
          await locationService.changeSettings(
              accuracy: location_package.LocationAccuracy.high, interval: 1000000);
          location = await locationService.getLocation();

          Log.d("Location: ${location?.latitude} , ${location?.longitude}");
        }
      } else {
        bool serviceStatusResult = await locationService.requestService();
        Log.d("Service status activated after request: $serviceStatusResult");
        if (serviceStatusResult) {
          fetchCurrentLocation();
        }
      }
    } on PlatformException catch (e) {
      Log.d(e);
      if (e.code == 'PERMISSION_DENIED') {
        //error = e.message;
      } else if (e.code == 'SERVICE_STATUS_ERROR') {
        //error = e.message;
      }
      location = null;
    }
  }

  set cameraType(bool type) {
    _isVideoSelected = type;
    emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  set isTakePicture(bool type) {
    _isTakePicture = type;
    if(!type) {
      emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
    }
  }

  getAvailableCameras() {
    imageFile!.clear();
    try {
      availableCameras().then((List<CameraDescription> value) {
        if (value.isNotEmpty) {
          cameras = value;
          initCamera();
          Log.d("Available camera ====> ${value}");
        }
      });
    } on CameraException catch (e) {
      _showCameraException(e);
    }
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    if (controller == null) {
      return;
    }

    final CameraController cameraController = controller!;

    final Offset offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    cameraController.setExposurePoint(offset);
    cameraController.setFocusPoint(offset);
    cameraController.setFlashMode(FlashMode.off);
  }

  Future<void> onNewCameraSelected(CameraDescription cameraDescription) async {
    final CameraController? oldController = controller;
    if (oldController != null) {
      controller = null;
      await oldController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    controller = cameraController;

    cameraController.addListener(() {
      if (cameraController.value.hasError) {
        emitState(ErrorState(StateRendererType.DEFAULT,
            'Camera error ${cameraController.value.errorDescription}'));
      }
    });

    try {
      await cameraController.initialize();
      if (!Utility.isTablet) {
        await cameraController.lockCaptureOrientation();
      }
      await Future.wait(<Future<Object?>>[
        cameraController
            .getMaxZoomLevel()
            .then((double value) => maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => minAvailableZoom = value),
      ]);
      emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
    } on CameraException catch (e) {
      switch (e.code) {
        case 'CameraAccessDenied':
          _showCameraException(e);
          break;
        case 'CameraAccessDeniedWithoutPrompt':
          // iOS only
          _showCameraException(e);
          break;
        case 'CameraAccessRestricted':
          // iOS only
          _showCameraException(e);
          break;
        default:
          _showCameraException(e);
          break;
      }
    }
  }

  Future<List<XFile>?>? onTakePictureButtonPressed(isRequiredToClearList) async {
    XFile? file = await takePicture();

    if (file != null) {
      try {
        if(_isGeoTagEnabled) {
                Exif? exif = await Exif.fromPath(file.path);
                await exif.writeAttributes({
                  'GPSLatitude': '${location?.latitude}',
                  'GPSLongitude': '${location?.longitude}',
                  'GPSAltitude': '${location?.altitude}',
                  'DateTimeOriginal': dateFormat.format(DateTime.now()),
                });
              }
      } catch (e) {}
      if(isRequiredToClearList) {
        imageFile!.clear();
      }
      imageFile!.add(file);

      emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
      // await exif.close();
      return imageFile!;
    } else {
      return null;
    }
  }

  emitAnimationEndState(){
    emitState(CameraState(isAnimEnd: true));
  }

  void onSetFlashModeButtonPressed(FlashMode mode) {
    setFlashMode(mode).then((_) {
      emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
    });
  }

  Future<void> setFlashMode(FlashMode mode) async {
    if (controller == null) {
      return;
    }

    try {
      await controller!.setFlashMode(mode);
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<XFile?> takePicture() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      emitState(ErrorState(StateRendererType.DEFAULT, '',
          time: DateTime.now().millisecondsSinceEpoch.toString(), code: 1));
      return null;
    }

    if (cameraController.value.isTakingPicture) {
      return null;
    }

    try {
      await cameraController.setFocusMode(FocusMode.locked);
      await cameraController.setExposureMode(ExposureMode.locked);

      final XFile file = await cameraController.takePicture();

      await cameraController.setFocusMode(FocusMode.auto);
      await cameraController.setExposureMode(ExposureMode.auto);
      return file;
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      emitState(ErrorState(StateRendererType.DEFAULT, '',
          time: DateTime.now().millisecondsSinceEpoch.toString(), code: 1));
      return null;
    }

    // Do nothing if a recording is on progress
    if (controller!.value.isRecordingVideo) {
      return null;
    }

    // final Directory appDirectory = await getApplicationDocumentsDirectory();
    // final String videoDirectory = '${appDirectory.path}/Videos';
    // await Directory(videoDirectory).create(recursive: true);
    // final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();
    // final String filePath = '$videoDirectory/${currentTime}.mp4';

    try {
      await controller?.startVideoRecording();
      //videoPath = filePath;
      emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
      _recordDuration = 0;
      _startTimer();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<String?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      return null;
    }

    try {
      var file = await controller?.stopVideoRecording();
      Log.d("File is => ${file?.path}");
      _timer?.cancel();
      _recordDuration = 0;
      if (file != null) {
        imageFile!.add(file);
        emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
        return file.path;
      } else {
        return null;
      }
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  void _logError(CameraException e, String? message) {
    if (message != null) {
      Log.d('Error: ${e.code}\nError Message: $message');
    } else {
      Log.d('Error: ${e.code}');
    }
  }

  void _showCameraException(CameraException e) {
    _logError(e, e.description);
    emitState(ErrorState(StateRendererType.DEFAULT, 'Error: ${e.code}\n${e.description}',
        time: DateTime.now().millisecondsSinceEpoch.toString(), code: 0));
  }

  String formatNumber(int number) {
    String numberStr = number.toString();
    if (number < 10) {
      numberStr = '0$numberStr';
    }
    return numberStr;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (_recordDuration >= maxDuration) {
        //_timer?.cancel();
      } else {
        _recordDuration++;
      }
      emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
    });
  }

  initCamera({bool enableAudio = true}) {
    if (cameras.isNotEmpty) {
      controller = CameraController(cameras[0], ResolutionPreset.high, enableAudio: enableAudio);
      controller!.addListener(() {});
      controller?.initialize().then((_) {
        if (!Utility.isTablet) {
          controller?.lockCaptureOrientation();
        }
        emitState(ContentState(
            time: DateTime.now().millisecondsSinceEpoch.toString()));
      }).catchError((Object e) {
        if (e is CameraException) {
          switch (e.code) {
            case 'CameraAccessDenied':
              Log.d('User denied camera access.');
              _showCameraException(e);
              break;
            case 'AudioAccessDenied':
              Log.d('User or system denied audio access.');
              initCamera(enableAudio: false);
              break;
            case "AudioAccessDeniedWithoutPrompt":
            case "AudioAccessRestricted":
              Log.d('User or system denied audio access.');
              initCamera(enableAudio: false);
              break;
            default:
              Log.d('Handle other errors.');
              _showCameraException(e);
              break;
          }
        }
      });
    }
  }
}
