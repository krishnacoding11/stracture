import 'dart:async';
import 'dart:isolate';

import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/offline_injection_container.dart' as di;
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/utils/extensions.dart';

import '../logger/logger.dart';
import '../utils/field_enums.dart';

typedef SyncResultCallback = void Function(ESyncType eSyncType, ESyncStatus eSyncStatus, dynamic data);

class SyncExecutor {
  SyncRequestTask syncRequestTask;
  String syncTaskTag;

  SyncExecutor(this.syncRequestTask, this.syncTaskTag);

  late SendPort sendPort;
  int _taskCounter = 0;
  int _completedTaskCounter = 0;
  SyncResultCallback? syncResultCallback;

  void execute(SyncResultCallback syncResultCallback, SendPort port) {
    this.syncResultCallback = syncResultCallback;
    sendPort = port;
    final syncRequestTime = DateTime.now();
    di.getIt<TaskPool>().taskStatusStreamController?.stream.listen((task) {
      if (task.taskData is SyncRequestTask) {
        SyncRequestTask requestTask = task.taskData;
        if (requestTask.syncRequestId == syncRequestTask.syncRequestId) {
          if (task.isDone) {
            _taskCounter--;
            _completedTaskCounter++;
            Log.d("$syncTaskTag Sync TaskPool Task Done ${task.taskTag} completed=$_completedTaskCounter pending=$_taskCounter");
            taskNotifyListener(task, _taskCounter, _completedTaskCounter);
            if (_taskCounter == 0) {
              Duration duration = DateTime.now().difference(syncRequestTime);
              Log.d("$syncTaskTag Sync End TotalSyncTime(H:M:S)= ${duration.toHoursMinutesSeconds()}");
            }
          } else {
            _taskCounter++;
            Log.d("$syncTaskTag Sync TaskPool Task Added ${task.taskTag} completed=$_completedTaskCounter pending=$_taskCounter");
            taskNotifyListener(task, _taskCounter, _completedTaskCounter);
          }
        }
      }
    });
  }

  Future<T> addTask<T>(FutureOr<T> Function(Task? task) callback, {TaskPriority taskPriority = TaskPriority.regular, String? taskTag}) {
    return di.getIt<TaskPool>().execute(callback, taskPriority: taskPriority, taskTag: taskTag, taskData: syncRequestTask);
  }

  void taskNotifyListener(Task task, int pendingTaskCounter, int completedTaskCounter) {}
}
