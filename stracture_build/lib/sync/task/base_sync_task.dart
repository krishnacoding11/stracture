import 'dart:async';

import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/logger/logger.dart';
import 'package:field/offline_injection_container.dart' as di;
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';

import '../pool/task_pool.dart';

typedef SyncCallback = Future<void> Function(ESyncTaskType eSyncTaskType, ESyncStatus eSyncStatus, dynamic data);

abstract class BaseSyncTask {
  SyncRequestTask syncRequestTask;
  SyncCallback syncCallback;

  BaseSyncTask(this.syncRequestTask, this.syncCallback);

  Future<void> passDataToSyncCallback(ESyncTaskType eSyncTaskType, ESyncStatus eSyncStatus, dynamic data) async {
    await syncCallback(eSyncTaskType, eSyncStatus, data);
  }

  Future<T> addTask<T>(FutureOr<T> Function(Task? task) callback, {TaskPriority taskPriority = TaskPriority.regular, String? taskTag}) {
    return di.getIt<TaskPool>().execute(callback, taskPriority: taskPriority, taskTag: taskTag, taskData: syncRequestTask);
  }

  void taskLogger({
    Task? task,
    Map<String, dynamic>? requestParam,
    required TaskSyncResponseType responseType,
    required String message,
    required DateTime taskStarTime,
  }) {
    final number = "No: ${task?.taskNumber},";
    final tag = "Tag: ${task?.taskTag},";
    final parameter = requestParam == null ? "" : "Param: $requestParam,";
    final type = "Type: ${responseType.name},";
    final responseMsg = "Message: $message}";
    Duration duration = DateTime.now().difference(taskStarTime);
    final taskEnd = " API response taken time : ${duration.toHoursMinutesSeconds()}, ";
    final logMsg = number + tag + parameter + type + responseMsg + taskEnd;
    _printLog(logMsg);
  }

  Future<void> _printLog(String logMsg) async {
    Log.d(logMsg);
  }
}
