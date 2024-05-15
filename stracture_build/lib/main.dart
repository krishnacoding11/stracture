import 'dart:async';
import 'dart:io';

import 'package:field/bloc/app_bloc_observer.dart';
import 'package:field/bloc/cBim_settings/cBim_settings_cubit.dart';
import 'package:field/bloc/deeplink/deeplink_cubit.dart';
import 'package:field/bloc/formsetting/form_settings_change_event_cubit.dart';
import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/bloc/notification/notification_cubit.dart';
import 'package:field/bloc/notification/notification_state.dart';
import 'package:field/bloc/online_model_viewer/model_tree_cubit.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart';
import 'package:field/bloc/online_model_viewer/task_form_list_cubit.dart';
import 'package:field/bloc/pdf_tron/pdf_tron_cubit.dart';
import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/bloc/project_list_item/project_item_cubit.dart';
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart';
import 'package:field/bloc/sidebar/sidebar_cubit.dart';
import 'package:field/bloc/site/location_tree_cubit.dart';
import 'package:field/bloc/sync/sync_cubit.dart';
import 'package:field/bloc/task_action_count/task_action_count_cubit.dart';
import 'package:field/bloc/toolbar/model_tree_title_click_event_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_title_click_event_cubit.dart';
import 'package:field/locale_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/routes_manager.dart';
import 'package:field/presentation/managers/string_manager.dart';
import 'package:field/presentation/screen/splash_screen.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/global.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/notification_navigator.dart';
import 'package:field/utils/qrcode_utils.dart';
import 'package:field/utils/sharedpreference.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:field/widgets/atheme.dart';
import 'package:field/widgets/behaviors/custom_scroll_behavior.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:field/analytics/service_analytics.dart';
import 'bloc/bim_model_list/bim_project_model_cubit.dart';
import 'bloc/dashboard/home_page_cubit.dart';
import 'bloc/language_change/language_change_cubit.dart';
import 'bloc/model_list/model_list_cubit.dart';
import 'bloc/navigation/navigation_cubit.dart';
import 'bloc/recent_location/recent_location_cubit.dart';
import 'bloc/storage_details/storage_details_cubit.dart';
import 'bloc/toolbar/toolbar_cubit.dart';
import 'firebase/firebase_options.dart';
import 'firebase/notification_service.dart';
import 'injection_container.dart' as di;
import 'injection_container.dart';
import 'networking/internet_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPathHelper().getBasePath();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();
  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    Log.d(error.toString());
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: false);
    return true;
  };

  await di.init(test: false);
  await PreferenceUtils.init();
  Bloc.observer = AppBlocObserver();
  await AConstants.loadProperty();
  //Set values in global variable for write log
  isLogEnable = await StorePreference.isIncludeLogsEnable();
  runApp(const App());
}

class App extends StatefulWidget {
  const App({
    Key? key,
  }) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  AProgressDialog? _aProgressDialog;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    NotificationService.requestPermissions();
    NotificationService.handleNotificationMessage(_handleNotificationMessage);
    getDeviceToken();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          BlocProvider(create: (context) => di.getIt<LocationTreeCubit>()),
          //BlocProvider(create: (context) => di.getIt<UserProfileSettingCubit>()),
          BlocProvider(create: (context) => di.getIt<DeepLinkCubit>()),
          BlocProvider(create: (context) => di.getIt<LoginCubit>()),
          BlocProvider(create: (context) => di.getIt<ProjectListCubit>()),
          BlocProvider(create: (context) => di.getIt<SidebarCubit>()),
          BlocProvider(create: (context) => di.getIt<NavigationCubit>()),
          BlocProvider(create: (context) => di.getIt<ToolbarCubit>()),
          BlocProvider(create: (context) => di.getIt<RecentLocationCubit>()),
          BlocProvider(create: (context) => di.getIt<TaskActionCountCubit>()),
          BlocProvider(create: (context) => di.getIt<SideToolBarCubit>()),
          BlocProvider(create: (context) => di.getIt<PdfTronCubit>()),
          BlocProvider(create: (context) => di.getIt<ModelListCubit>()),
          BlocProvider(create: (context) => di.getIt<StorageDetailsCubit>()),
          BlocProvider(create: (context) => di.getIt<BimProjectModelListCubit>()),
          BlocProvider(create: (context) => di.getIt<ModelTreeCubit>()),
          BlocProvider(create: (context) => di.getIt<TaskFormListingCubit>()),
          BlocProvider(create: (context) => di.getIt<ToolbarTitleClickEventCubit>()),
          BlocProvider(create: (context) => di.getIt<ModelTreeTitleClickEventCubit>()),
          BlocProvider(create: (context) => di.getIt<FormSettingsChangeEventCubit>()),
          BlocProvider(create: (context) => di.getIt<OnlineModelViewerCubit>()),
          BlocProvider(create: (context) => di.getIt<InternetCubit>()),
          BlocProvider(create: (context) => di.getIt<SyncCubit>()),
          BlocProvider(create: (context) => di.getIt<ProjectItemCubit>()),
          BlocProvider(create: (context) => di.getIt<NotificationCubit>()),
          BlocProvider(create: (context) => di.getIt<CBIMSettingsCubit>()),
          BlocProvider(create: (context) => di.getIt<LanguageChangeCubit>()),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<DeepLinkCubit, FlowState>(listener: (context, state) async {
              if (state is SuccessState) {
                Log.d("DeepLink uri1:" + state.response);
                String currentUri = state.response;
                final loginCubit = di.getIt<LoginCubit>();
                final deepLinkCubit = di.getIt<DeepLinkCubit>();
                deepLinkCubit.uri = state.response;
                if (currentUri.isNotEmpty) {
                  if (currentUri.contains("action_id=417")) {
                    deepLinkCubit.getRequestURLForDeeplink(state.response, onSuccess: () {
                      loginCubit.isForgotPassword = true;
                      deepLinkCubit.uri = state.response;
                      NavigationUtils.mainPushNamed(context, Routes.onboardingLogin);
                    }, onFail: (String message) {
                      Future.delayed(const Duration(seconds: 2), () {
                        String strExpire = "expired";
                        String strVerify = "verified";
                        loginCubit.isForgotPassword = false;
                        if (message.contains(strExpire)) {
                          Log.d("Link has expired. Please click here to receive new verification email.");
                          NavigationUtils.mainNavigationKey.currentContext?.showSnack("Link has expired. Please click here to receive new verification email.");
                        } else if (message.contains(strVerify)) {
                          Log.d("Email ID has been already verified. Login Now!!!");
                          NavigationUtils.mainNavigationKey.currentContext?.showSnack("Email ID has been already verified. Login Now!!!");
                        }
                        NavigationUtils.mainPushNamed(context, Routes.onboardingLogin);
                      });
                    });
                  } else if (QrCodeUtility.isAsiteQrCodeUrl(currentUri)) {
                    NavigationUtils.mainPushNamedAndRemoveUntil(Routes.splash);
                  }
                }
              } else if (state is EmptyState) {
                context.showSnack(state.message);
              }
            }),
            BlocListener<NotificationCubit, FlowState>(listener: (_, state) async {
              if (state is NotificationDetailSuccessState) {
                  _aProgressDialog?.dismiss();
                 await notificationNavigatorView(state.notificationDetailVo, state.data, state.entityType);
              } else if (state is NotificationErrorState) {
                _aProgressDialog?.dismiss();
                NavigationUtils.mainNavigationKey.currentContext?.showSnack("Something went wrong!");
               }
              else if (state is NotificationLoading) {
                var context = NavigationUtils.mainNavigationKey.currentContext;
                if (context != null) {
                  _aProgressDialog ??= AProgressDialog(context);
                  _aProgressDialog?.show();
                }
              }
            })
          ],
          child: MyApp(),
        ));
  }

  Future<void> getDeviceToken() async {
    String? token = await NotificationService.getDeviceToken();
    await StorePreference.setDeviceToken(token);
    // NotificationService.getDeviceToken();
    Log.d('Token:$token');
  }

  Future<void> _handleNotificationMessage(RemoteMessage? message) async {
    if (message != null) {
      Log.d(message.data);
      final notificationCubit = di.getIt<NotificationCubit>();
      Map<String, dynamic> detailData = message.data;
      if (detailData.isNotEmpty) {
        notificationCubit.getTaskDetailRequest(detailData);
      }
      NotificationService.cancelNotifications(message.hashCode);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      if (di.getIt<SyncCubit>().isSyncPending && Platform.isIOS) {
        di.flutterLocalNotificationsPlugin.show(
          0,
          "Field",
          "Sync process has stopped, please re-initiate the sync process again.",
          const NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: true,
            ),
          ),
        );
      }
    }
  }

  @override
  dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  String? langValue;
  @override
  void initState() {
    di.getIt<LanguageChangeCubit>().setCurrentLanguageId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageChangeCubit, FlowState>(builder: (context, state) {
      return MaterialApp(
        navigatorKey: NavigationUtils.mainNavigationKey,
        localizationsDelegates: const [AppLocalizations.delegate, GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: di.getIt<LanguageChangeCubit>().langId != "ga_IE" ? LocaleManager().localeList[di.getIt<LanguageChangeCubit>().langId] : LocaleManager().localeList["en_IE"],
        debugShowCheckedModeBanner: false,
        title: context.toLocale?.app_title ?? AStrings.appTitle,
        theme: ATheme.lightTheme,
        scrollBehavior: CustomScrollBehavior(),
        // home: SplashScreen(),
        initialRoute: Routes.splash,
        onGenerateRoute: RouteGenerator.generateRoute,
        navigatorObservers: <NavigatorObserver>[ServiceAnalytics.observer],
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: Utility.getFontScale(context)),
            child: child!,
          );
        },
      );
    });
  }

  @override
  void dispose() {
    localhostServer.close();
    super.dispose();
  }
}
