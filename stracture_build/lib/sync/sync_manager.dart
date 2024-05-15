import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:field/data/model/sync/sync_property_detail_vo.dart';
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/data/model/sync/sync_status_result.dart';
import 'package:field/firebase/notification_service.dart';
import 'package:field/logger/logger.dart';
import 'package:field/offline_injection_container.dart' as offline_di;
import 'package:field/sync/executors/site_sync_executor.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/global.dart';
import 'package:field/utils/store_preference.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../utils/field_enums.dart';
import '../utils/sharedpreference.dart';
import 'executor.dart';
import 'executors/auto_sync_executor.dart';

class SyncManager {
  SendPort? mSendPort;
  late SyncResultCallback syncResultCallback;
  ReceivePort? receivePort = ReceivePort();

  execute(Map<String, dynamic> argsMap, SyncResultCallback syncResultCallback) async {
    this.syncResultCallback = syncResultCallback;
    receivePort ??= ReceivePort();
    argsMap["port"] = receivePort?.sendPort;
    if (mSendPort == null) {
      mSendPort = await _syncData(startSync, argsMap);
    } else {
      sendDataToIsolate(argsMap);
    }
  }

  @pragma('vm:entry-point')
  static Future<void> startSync(Map mSyncMap) async {
    var mainToIsolateStream = ReceivePort();
    mSyncMap["port"].send(mainToIsolateStream.sendPort);
    await AConstants.setUrlPropertyByBuildFlavor(mSyncMap["buildFlavor"]);
    await PreferenceUtils.init();
    await offline_di.init(test: false);
    //Set values in global variable for write log
    isLogEnable = await StorePreference.isIncludeLogsEnable();

    try {
      var stringValue = await PreferenceUtils.getString(AConstants.keyAppConfig);
      offline_di.getIt<AppConfig>().syncPropertyDetails = SyncManagerPropertyDetails.fromJson(stringValue);
      offline_di.getIt<TaskPool>().maxAllocatedTask = offline_di.getIt<AppConfig>().syncPropertyDetails?.maxThreadForMobileDevice ?? AConstants.maxThreadForMobileDevice;
    } catch (e) {}
    mainToIsolateStream.listen((data) async {
      syncInit(data);
    });
    syncInit(mSyncMap);
  }

  static Map<int, Map<String, dynamic>> syncRequestList = {};

  static syncInit(Map mSyncMap) async {
    List<String> isolateIds = await FlutterIsolate.runningIsolates;
    Log.d("FlutterIsolate.runningIsolates ${isolateIds.toString()}");
    switch (mSyncMap["tab"]) {
      case AConstants.siteTab:
        if (mSyncMap['syncRequest'] != null) {
          var request = await jsonDecode(mSyncMap['syncRequest']);
          if (syncRequestList.isEmpty) {
            startForegroundService("Field", "Sync In progress");
          }
          syncRequestList[request['syncRequestId']] = request;
          bool isAnySyncTaskFailed = false;
          SiteSyncRequestTask siteSyncRequestTask = SiteSyncRequestTask.fromJson(jsonDecode(mSyncMap['syncRequest']));
          SiteSyncExecutor(siteSyncRequestTask).execute((eSyncType, eSyncStatus, data) async {
            SendPort sendPort = mSyncMap["port"];
            SyncStatusResult syncStatusResult = SyncStatusResult()
              ..eSyncType = eSyncType
              ..eSyncStatus = eSyncStatus
              ..data = jsonEncode(data);
            if (eSyncStatus == ESyncStatus.failed) {
              isAnySyncTaskFailed = true;
            }
            if (eSyncStatus == ESyncStatus.success || eSyncStatus == ESyncStatus.failed) {
              syncRequestList.remove(siteSyncRequestTask.syncRequestId);
            }
            if (syncRequestList.isEmpty) {
              await stopForegroundService();
              offline_di.getIt<TaskPool>().clearAllTask();
              if (isAnySyncTaskFailed) {
                await showNotification("Field", "Sync process has failed, please re-initiate the sync process again.");
              } else {
                await showNotification("Field", "Sync completed successfully");
              }
            }
            sendPort.send(syncStatusResult.toJson());
          }, mSyncMap["port"]);
        }
        break;
      case AConstants.autoSyncTab:
        //if (mSyncMap['syncRequest'] != null) {
        AutoSyncRequestTask siteSyncRequestTask = AutoSyncRequestTask();
        siteSyncRequestTask.eSyncType = ESyncType.pushToServer;
        AutoSyncExecutor(siteSyncRequestTask).execute((eSyncType, eSyncStatus, data) {
          SendPort sendPort = mSyncMap["port"];
          SyncStatusResult syncStatusResult = SyncStatusResult()
            ..eSyncType = eSyncType
            ..eSyncStatus = eSyncStatus
            ..data = jsonEncode(data);
          sendPort.send(syncStatusResult.toJson());
        }, mSyncMap["port"]);
        //}
        break;
    }
  }

  Future<dynamic> _syncData(void Function(Map) entryPoint, Map<String, dynamic> argsMap) async {
    Completer completer = Completer<SendPort>();
    await FlutterIsolate.spawn(entryPoint, argsMap);
    receivePort?.listen(
      (dynamic response) async {
        Log.d("SyncManager >> response");
        if (response is SendPort) {
          var isolateToMainStream = response;
          completer.complete(isolateToMainStream);
        } else {
          if (response is Map<String, dynamic>) {
            try {
              if (response.containsKey("syncType")) {
                SyncStatusResult syncStatusResult = SyncStatusResult.fromJson(response);
                syncResultCallback(syncStatusResult.eSyncType, syncStatusResult.eSyncStatus, syncStatusResult.data);
              }
            } catch (e) {
              Log.e("ReceivePort Listen Json Parsing $e");
            }
          } else if (response is Error) {}
        }
        // stopIsolate();
      },
    );
    return completer.future;
  }

  Future<void> stopIsolate() async {
    Log.d("SyncManager::stopIsolate");
    FlutterIsolate.killAll();
    mSendPort = null;
    receivePort?.close();
    receivePort = null;
  }

  void sendDataToIsolate(Object? data) {
    mSendPort?.send(data);
  }

  static Future<void> stopForegroundService() async {
    try {
      if (Platform.isAndroid) {
        Log.d("SyncManager >> _stopForegroundService");
        await NotificationService.flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.stopForegroundService();
        await NotificationService.flutterLocalNotificationsPlugin.cancel(1);
      }
    } catch (e) {
      Log.e("SyncManager >> stopForegroundService exception >> $e");
    }
  }

  static Future startForegroundService(String title, String msg) async {
    try {
      if (Platform.isAndroid) {
        AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails(
          'Asite',
          'Field',
          channelDescription: 'sync',
          importance: Importance.max,
          ticker: 'ticker',
          onlyAlertOnce: false,
          ongoing: true,
        );
        await NotificationService.flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.startForegroundService(1, title, msg, notificationDetails: androidNotificationDetails, payload: 'item');
      }
    } catch (e) {
      Log.e("SyncManager >> startForegroundService exception >> $e");
    }
  }

  static Future showNotification(String title, String msg) async {
    try {
      Log.e("SyncManager >> showNotification $title ${Platform.isAndroid}");
      if (Platform.isAndroid) {
        Log.e("SyncManager >> showNotification $title ");
        await NotificationService.flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.show(1, title, msg,
            notificationDetails: AndroidNotificationDetails(
              'Asite',
              'Field',
              channelDescription: 'notification',
              importance: Importance.max,
              onlyAlertOnce: false,
              styleInformation: DefaultStyleInformation(
                false,
                false,
              ),
            ),
            payload: "payload");
      }
    } catch (e) {
      Log.e("SyncManager >> showNotification exception >> $e");
    }
  }
}