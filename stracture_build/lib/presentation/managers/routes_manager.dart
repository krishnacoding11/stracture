import 'dart:io';

import 'package:field/bloc/a_camera/a_camera_cubit.dart';
import 'package:field/bloc/audio/audio_cubit.dart';
import 'package:field/bloc/site/create_form_selection_cubit.dart';
import 'package:field/bloc/site/plan_cubit.dart';
import 'package:field/bloc/user_first_login_setup/user_first_login_setup_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';
import 'package:field/data/model/online_model_viewer_arguments.dart';
import 'package:field/image_annotation/image_annotation.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/onboarding_login_screen.dart';
import 'package:field/presentation/screen/project_tabbar_screen.dart';
import 'package:field/presentation/screen/site_routes/site_plan_viewer_screen.dart';
import 'package:field/presentation/screen/splash_screen.dart';
import 'package:field/presentation/screen/task_listing/task_listing_screen.dart';
import 'package:field/presentation/screen/user_first_login/user_first_login_screen.dart';
import 'package:field/video_trimmer/trimmer_view.dart';
import 'package:field/widgets/camera/a_audio.dart';
import 'package:field/widgets/camera/a_camera.dart';
import 'package:field/widgets/camera/a_video.dart';
import 'package:field/widgets/image_preview/image_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/constants.dart';
import '../screen/dashboard.dart';
import '../screen/online_model_viewer/online_model_viewer_screen.dart';
import '../screen/url_web_view.dart';
import '../screen/user_profile_setting/user_avatar_setting_screen.dart';
import '../screen/user_profile_setting/user_profile_screen.dart';

class Routes {
  static const String splash = 'splash';
  static const String dashboard = 'dashboard';
  static const String onboardingLogin = 'onboarding_login_screen';
  static const String projectList = 'project_list';
  static const String sites = 'sites';
  static const String settings = 'settings';
  static const String help = 'help';
  static const String about = 'about';
  static const String sitePlanView = 'sitePlanView';
  static const String userFirstLoginSetup = 'userFirstLoginSetup';
  static const String createPassword = 'createPassword';
  static const String aCamera = 'aCamera';
  static const String aVideo = 'aVideo';
  static const String imageAnnotation = 'imageAnnotation';
  static const String imagePreview = 'imagePreview';
  static const String videoTrimmer = 'videoTrimmer';
  static const String audioRecord = 'audioRecord';
  static const String userUpdateAvatarView = 'userAvatarUpdateView';
  static const String tasks = 'tasks';
  static const String modelScreen = 'modelScreen';
  static const String onlineModelViewer = 'onlineModelViewer';
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splash:
        return FadeRoute(page:  SplashScreen());
      case Routes.dashboard:
        return FadeRoute(page: const DashboardWidget());
      case Routes.onboardingLogin:
        return FadeRoute(page: const OnBoardingLoginScreen());
      case Routes.onlineModelViewer:
        return FadeRoute(
            page: OnlineModelViewerScreen(
              onlineModelViewerArguments:
              settings.arguments as OnlineModelViewerArguments,
            ));
      case Routes.projectList:
      // return;
        return FadeRoute(page: ProjectTabbar(arguments: settings.arguments));
      case Routes.sitePlanView:
        return FadeRoute(
            page: MultiBlocProvider(
                providers: [
                  BlocProvider<PlanCubit>(
                    create: (BuildContext context) => di.getIt<PlanCubit>(),
                  ),
                  BlocProvider<CreateFormSelectionCubit>(
                    create: (BuildContext context) =>
                        di.getIt<CreateFormSelectionCubit>(),
                  ),
                ],
                child: SitePlanViewerScreen(
                  arguments: settings.arguments,
                )));
      case Routes.settings:
        return FadeRoute(
            page: MultiBlocProvider(providers: [
              BlocProvider<UserProfileSettingCubit>(
                create: (BuildContext context) =>
                    di.getIt<UserProfileSettingCubit>(),
              ),
            ], child: const UserProfileSettingScreen()));
      case Routes.tasks:
        return FadeRoute(
          page: TaskListingScreen(
            arguments: settings.arguments,
          ),
        );
    //return FadeRoute(page: UserProfileSettingScreen());
      case Routes.userFirstLoginSetup:
        return FadeRoute(
            page: MultiBlocProvider(providers: [
              BlocProvider<UserFirstLoginSetupCubit>(
                  create: (BuildContext context) =>
                      di.getIt<UserFirstLoginSetupCubit>())
            ], child: UserFirstLogin(settings.arguments)));
      case Routes.aCamera:
        return FadeRoute(
            page: MultiBlocProvider(providers: [
              BlocProvider<ACameraCubit>(
                  create: (BuildContext context) => di.getIt<ACameraCubit>())
            ], child: ACamera(settings.arguments)));
      case Routes.aVideo:
        return FadeRoute(
            page: MultiBlocProvider(providers: [
              BlocProvider<ACameraCubit>(
                  create: (BuildContext context) => di.getIt<ACameraCubit>())
            ], child: VideoRecorderExample()));
      case Routes.imageAnnotation:
        return FadeRoute(
            page: ImageAnnotationWidget(
              arguments: settings.arguments,
            ));
      case Routes.imagePreview:
        return FadeRoute(
            page: ImagePreviewWidget(
              arguments: settings.arguments,
            ));
      case Routes.videoTrimmer:
        return FadeRoute(page: TrimmerView(settings.arguments as File));
      case Routes.audioRecord:
        return FadeRoute(
            page: MultiBlocProvider(providers: [
              BlocProvider<AudioCubit>(
                  create: (BuildContext context) => di.getIt<AudioCubit>())
            ], child: const AudioRecorder()));
      case Routes.userUpdateAvatarView:
        return FadeRoute(
            page: MultiBlocProvider(providers: [
              BlocProvider<UserFirstLoginSetupCubit>(
                  create: (BuildContext context) =>
                      di.getIt<UserFirstLoginSetupCubit>())
            ], child: const UserAvatarSettingScreen()));
      case Routes.help:
        return FadeRoute(
            page: const UrlWebView(url: AConstants.urlHelp, title: "Help"));
      case Routes.about:
        return FadeRoute(
            page: const UrlWebView(url: AConstants.urlAbout, title: "About"));
      default:
        return MaterialPageRoute(builder: (_) {
          return const Scaffold(
            body: Center(
              child: Text('No route defined.'),
            ),
          );
        });
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text("No Routes found"),
          ),
          body: const Center(child: Text("No Routes found")),
        ));
  }
}

class FadeRoute extends PageRouteBuilder {
  final Widget page;

  FadeRoute({required this.page})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    page,
    transitionsBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        FadeTransition(
          opacity: animation,
          child: child,
        ),
  );
}
