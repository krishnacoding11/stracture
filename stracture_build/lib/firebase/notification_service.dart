import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:field/utils/extensions.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/model/user_vo.dart';
import '../logger/logger.dart';
import '../utils/store_preference.dart';
import '../utils/utils.dart';
import 'firebase_options.dart';

typedef HandleReceiveNotificationResponseCallback = Function(RemoteMessage? remoteMessage);

final StreamController<RemoteMessage> didReceiveLocalNotificationSubject = StreamController<RemoteMessage>();

/// Created by Chandresh Patel on 12-06-2022.
/// Notification Service for showing notification
class NotificationService {
  static FirebaseMessaging? _firebaseMessaging;

  static FirebaseMessaging get firebaseMessaging => _firebaseMessaging ?? FirebaseMessaging.instance;

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create a [AndroidNotificationChannel] for heads up notifications
  static AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'Asite', // id
    'Field', // title
    description: 'This channel is used for important notifications.',
    // description
    importance: Importance.high,
  );

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeFirebaseNotification();
    await initializeLocalNotifications();
    await listingFirebaseNotificationMessage();
  }

  /// initialize Firebase
  static Future<void> initializeFirebaseNotification() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  /// get Firebase token
  static Future<String?> getDeviceToken() async => await firebaseMessaging.getToken();

  ///Show Local Notification
  ///while the application is in the foreground
  static Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    Map<String, dynamic> notificationData = message.data;
    if (message.data['eventCategory']=="4" && message.data['languageId'] != null)
    {
      try {
        if(NavigationUtils.mainNavigationKey.currentContext != null) {
          Utility.showAlertWithOk(NavigationUtils.mainNavigationKey.currentContext!, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.preferred_language_change);
          User? userData = await StorePreference.getUserData();
          userData!.usersessionprofile!.languageId = message.data['languageId'];
          StorePreference.setUserData(userData);
          StorePreference.setUserCurrentLanguage(message.data['languageId']);
        }
      } catch (e) {
        Log.d("Your preferred language is updated on Asite. Please Re-login/Relaunch to view the application in your preferred language");
    }
      return;
    }
    if (notificationData.isNotEmpty && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
          message.hashCode,
          notificationData['title'],
          notificationData['body'],
          NotificationDetails(
            iOS: null,
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              /*   icon: 'launch_background',*/
            ),
          ),
          payload: jsonEncode(message.toMap()));
    }
  }
  ///Delete Token
  static Future<void>deleteToken()
  async {
    _firebaseMessaging?.deleteToken();
    cancelAllNotifications();
  }
  ///for receiving message when app is in background or foreground
  static Future<void> listingFirebaseNotificationMessage() async {
    //Foreground Notification Message Listening and showing local notification
    FirebaseMessaging.onMessage.listen(showNotification);
    //Background Notification Message Listening.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    Log.d('FirebaseMessaging.onBackgroundMessage');
  }

  ///It's calling when application is in background or terminate state
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    Log.d('Handling a background message ${message.messageId}');
    showNotification(message);
  }

  ///It's calling when clicking on local notification
  static void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
      RemoteMessage? localMessage = RemoteMessage.fromMap(jsonDecode(notificationResponse.payload!));
      didReceiveLocalNotificationSubject.add(localMessage);
    }
  }

  ///initialize local notification settings
  static Future<void> initializeLocalNotifications() async {
    channel = const AndroidNotificationChannel(
      'Asite', // id
      'Field', // title
      description: 'This channel is used for important notifications.',
      // description
      importance: Importance.high,
    );

    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  static Future<void> cancelNotifications(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<bool> isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      return await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.areNotificationsEnabled() ?? false;
    } else {
      return true;
    }
  }

  static Future<void> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
            critical: true,
          );
    } else if (Platform.isAndroid) {
      await isAndroidPermissionGranted();
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestPermission();
    }
  }

  ///Get any messages which caused the application to open from local notification while application is in terminate state
  static Future<NotificationAppLaunchDetails?> getNotificationAppLaunchDetails() async {
    return await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  }

  ///Interact notification message when clicking on firebase notification while application is in terminate or background state
  static Future<void> handleNotificationMessage(HandleReceiveNotificationResponseCallback handleReceiveNotificationResponseCallback) async {
    //For handling Local Notification
    //Tap on local notification while application is in foreground
    didReceiveLocalNotificationSubject.stream.listen((RemoteMessage remoteMessage) {
      handleReceiveNotificationResponseCallback(remoteMessage);
    });
    //Tap on local notification while application is in terminate state
    NotificationAppLaunchDetails? notificationAppLaunchDetails = await getNotificationAppLaunchDetails();
    if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
      RemoteMessage? localMessage = RemoteMessage.fromMap(jsonDecode(notificationAppLaunchDetails!.notificationResponse!.payload!));
      handleReceiveNotificationResponseCallback(localMessage);
    }

    //For handling Firebase Notification
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage = await firebaseMessaging.getInitialMessage();

    // If the message also contains a data property",
    // navigate to a specific screen
    if (initialMessage != null) {
      handleReceiveNotificationResponseCallback(initialMessage);
    }
    // Also handle any interaction when the app is in the background via a Stream listener
    //onResume
    FirebaseMessaging.onMessageOpenedApp.listen(handleReceiveNotificationResponseCallback);
    Log.d("notification detail:$handleReceiveNotificationResponseCallback");
  }

  static dispose() {
    didReceiveLocalNotificationSubject.close();
  }
}
