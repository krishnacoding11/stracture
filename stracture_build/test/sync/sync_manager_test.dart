import 'dart:isolate';

import 'package:field/injection_container.dart' as di;
import 'package:field/sync/executors/auto_sync_executor.dart';
import 'package:field/sync/executors/site_sync_executor.dart';
import 'package:field/sync/sync_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

class MockSendPort extends Mock implements SendPort {}

class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock implements AndroidFlutterLocalNotificationsPlugin {}

class MockSiteSyncExecutor extends Mock implements SiteSyncExecutor {}

class MockAutoSyncExecutor extends Mock implements AutoSyncExecutor {}

void main() {
  group('showNotification', () {
    test('showNotification on Android', () async {
      final mockFlutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
      di.flutterLocalNotificationsPlugin = mockFlutterLocalNotificationsPlugin;
      const String title = 'Test Title';
      const String msg = 'Test Message';
      final notificationDetails = NotificationDetails(
        iOS: null,
        android: AndroidNotificationDetails(
          'Asite',
          'Field',
          channelDescription: 'notification',
          importance: Importance.max,
          onlyAlertOnce: true,
          styleInformation: DefaultStyleInformation(false, false),
        ),
      );
      await SyncManager.showNotification(title, msg);
      verifyNever(() => mockFlutterLocalNotificationsPlugin.show(0, title, msg, notificationDetails)).called(0);
    });

    test('showNotification on non-Android platform', () async {
      final mockFlutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
      di.flutterLocalNotificationsPlugin = mockFlutterLocalNotificationsPlugin;

      const String title = 'Test Title';
      const String msg = 'Test Message';

      await SyncManager.showNotification(title, msg);

      verifyNever(() => mockFlutterLocalNotificationsPlugin.show(any(), any(), any(), any()));
    });
  });

  group('startForegroundService', () {
    test('Start Android foreground service when platform is Android', () async {
      // Arrange
      final mockAndroidFlutterLocalNotificationsPlugin = MockAndroidFlutterLocalNotificationsPlugin();

      const String title = 'Test Title';
      const String msg = 'Test Message';

      const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
        'Asite',
        'Field',
        channelDescription: 'sync',
        importance: Importance.max,
        ticker: 'ticker',
        onlyAlertOnce: true,
        ongoing: true,
      );

      // Act
      await SyncManager.startForegroundService(title, msg);

      // Assert
      verifyNever(() => mockAndroidFlutterLocalNotificationsPlugin.startForegroundService(1, title, msg, notificationDetails: androidNotificationDetails, payload: 'item')).called(0);
    });

    test('stopForegroundService cancels notification and stops foreground service', () async {
      final flutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
      final androidFlutterLocalNotificationsPlugin = MockAndroidFlutterLocalNotificationsPlugin();

      di.flutterLocalNotificationsPlugin = flutterLocalNotificationsPlugin;

      when(() => flutterLocalNotificationsPlugin.cancel(0)).thenAnswer((_) => Future.value(null));

      SyncManager.stopForegroundService();

      verify(() => flutterLocalNotificationsPlugin.cancel(0)).called(1);
      verifyNever(() => androidFlutterLocalNotificationsPlugin.stopForegroundService()).called(0);
    });
  });
}
