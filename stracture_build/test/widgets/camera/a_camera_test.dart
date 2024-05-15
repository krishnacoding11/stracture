import 'dart:math';

import 'package:bloc_test/bloc_test.dart';
import 'package:camera/camera.dart';
import 'package:field/bloc/a_camera/a_camera_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/widgets/camera/a_camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../bloc/mock_method_channel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:field/injection_container.dart' as di;

import 'mock_camera.dart';

class MockACameraCubit extends MockCubit<FlowState>
    implements ACameraCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  late Widget cameraScreen;

  const arguments = {
    'allowMultiple': "true",
    'onlyImage': "false"
  };

  final mockCameraController = MockCameraController();
  MockCameraPlatform mockCameraPlatform = MockCameraPlatform();

  final mockACameraCubit = MockACameraCubit();
  final cameraDescription = CameraDescription(name: "camBack", lensDirection: CameraLensDirection.back, sensorOrientation: 90);

  configureCubitDependencies() {
    di.init(test: true);
  }

  configureCubitDependencies();
  setUp(() {
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();

    mockACameraCubit.controller = MockCameraController();
    CameraPlatform.instance = MockCameraPlatform();

    // mockCameraController.value = mockCameraController.value.copyWith(
    //   isInitialized: true,
    //   previewSize: const Size(480, 640),
    // );
    cameraScreen = MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => di.getIt<ACameraCubit>(),
          child: const MaterialApp(localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ], home: ACamera(arguments)),
        ));
  });

  testWidgets("When only Photo and no Video", (WidgetTester tester) async {
    const args = {
    'allowMultiple': "true",
    'onlyImage': "true"
    };

    Widget tempcameraScreen = MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => di.getIt<ACameraCubit>(),
          child: const MaterialApp(localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ], home: ACamera(args)),
        ));

    await tester.pumpWidget(tempcameraScreen);

    expect(find.text("PHOTO"), findsOneWidget);
    expect(find.text("VIDEO"), findsNothing);
  });

  testWidgets("When both Photo and Video option available", (WidgetTester tester) async {
    await tester.pumpWidget(cameraScreen);

    expect(find.text("PHOTO"), findsOneWidget);
    expect(find.text("VIDEO"), findsOneWidget);
  });

  testWidgets("When clicked on close icon of Camera", (widgetTester) async {
    await widgetTester.pumpWidget(cameraScreen);

    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    await widgetTester.tap(find.byIcon(Icons.close_rounded));

    expect(find.byWidget(ACamera(arguments)), findsNothing);
  });

  Widget tempCameraScreenWithCubit(ACameraCubit aCameraCubit) {
    Widget tempCameraScreen = MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => aCameraCubit,
          child: const MaterialApp(localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ], home: ACamera(arguments)),
        ));

    return tempCameraScreen;
  }

  testWidgets("test videoCaptureWidget with cameraType enable", (WidgetTester tester) async {
    final aCameraCubit = di.getIt<ACameraCubit>();
    aCameraCubit.cameraType = true;
    aCameraCubit.controller = CameraController(cameraDescription, ResolutionPreset.max, enableAudio: false);

    Widget tempCameraScreen = tempCameraScreenWithCubit(aCameraCubit);

    await tester.pumpWidget(tempCameraScreen);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets("test videoCaptureWidget with isTakePicture enable", (WidgetTester tester) async {
    final aCameraCubit = di.getIt<ACameraCubit>();
    aCameraCubit.isTakePicture = true;
    aCameraCubit.controller = CameraController(cameraDescription, ResolutionPreset.max, enableAudio: false);

    Widget tempCameraScreen = tempCameraScreenWithCubit(aCameraCubit);

    await tester.pumpWidget(tempCameraScreen);
    expect(find.byType(Image), findsAtLeastNWidgets(1));
  });

  testWidgets("test buildTimer", (WidgetTester tester) async {
    final aCameraCubit = di.getIt<ACameraCubit>();
    aCameraCubit.controller = MockCameraController();
    aCameraCubit.controller?.value = CameraValue(
      isInitialized: true,
      isRecordingVideo: true,
      isTakingPicture: true,
      isStreamingImages: true,
      isRecordingPaused: true,
      flashMode: FlashMode.auto,
      exposureMode: ExposureMode.auto,
      focusMode: FocusMode.auto,
      exposurePointSupported: true,
      focusPointSupported: true,
      deviceOrientation: DeviceOrientation.landscapeRight,
      description: cameraDescription,
      recordingOrientation: DeviceOrientation.landscapeRight,
      previewSize: Size(20.0, 20.0),
      errorDescription: "Camera Error",
      isPreviewPaused: true,
      lockedCaptureOrientation: DeviceOrientation.landscapeRight,
      previewPauseOrientation: DeviceOrientation.landscapeRight,
    );

    Widget tempCameraScreen = tempCameraScreenWithCubit(aCameraCubit);

    await tester.pumpWidget(tempCameraScreen);
    expect(find.byType(Text), findsAtLeastNWidgets(1));
  });

  testWidgets("test captureControlRowWidget", (WidgetTester tester) async {
    final aCameraCubit = di.getIt<ACameraCubit>();
    aCameraCubit.controller = CameraController(cameraDescription, ResolutionPreset.medium, imageFormatGroup: ImageFormatGroup.jpeg, enableAudio: false);
    aCameraCubit.cameraType = false;

    Widget tempCameraScreen = tempCameraScreenWithCubit(aCameraCubit);

    await tester.pumpWidget(tempCameraScreen);
    final inkWell = find.byType(InkWell).at(3);
    await tester.tap(inkWell);

    expect(inkWell, findsAtLeastNWidgets(1));
  });
}
