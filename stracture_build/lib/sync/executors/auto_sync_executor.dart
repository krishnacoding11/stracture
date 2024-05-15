import 'dart:isolate';

import 'package:field/offline_injection_container.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/sync_task_factory.dart';

import '../../data/model/sync/sync_request_task.dart';
import '../../data_source/forms/form_local_data_source.dart';
import '../../utils/field_enums.dart';
import '../executor.dart';

class AutoSyncExecutor extends SyncExecutor {
  AutoSyncRequestTask autoSyncRequestTask;

  AutoSyncExecutor(this.autoSyncRequestTask) : super(autoSyncRequestTask, "AutoSyncExecutor");

  @override
  Future<void> execute(SyncResultCallback syncResultCallback, SendPort port) async {
    super.execute(syncResultCallback, port);
    addTask((task) async {
      FormLocalDataSource frmDb = FormLocalDataSource();
      await frmDb.init();
      var result = await frmDb.getPushToServerFormData();
      if (result.isNotEmpty) {
        for (var element in result) {
          if (element.isNotEmpty) {
            EOfflineSyncRequestType eRequestType = EOfflineSyncRequestType.fromString(element["RequestType"].toString());
            switch (eRequestType) {
              case EOfflineSyncRequestType.CreateOrRespond:
                addTask((task) async {
                  await getIt<SyncTaskFactory>().getFormSyncTask(autoSyncRequestTask, syncCallback).syncFormDataToServer(element, task?.taskNumber);
                }, taskTag: ESyncTaskType.createOrRespondFormSyncTask.value);
                break;
              case EOfflineSyncRequestType.StatusChange:
                addTask((task) async {
                  await getIt<SyncTaskFactory>().getForStatusChangeSyncTask(autoSyncRequestTask, syncCallback).formStatusChangeTask(element);
                }, taskTag: ESyncTaskType.formStatusChangeTask.value);
                break;
              case EOfflineSyncRequestType.DistributeAction:
                addTask((task) async {
                  await getIt<SyncTaskFactory>().getFormDistributeActionSyncTask(autoSyncRequestTask, syncCallback).formDistributionActionTask(element);
                }, taskTag: ESyncTaskType.distributionFormActionSyncTask.value);
                break;
              case EOfflineSyncRequestType.OtherAction:
                addTask((task) async {
                  await getIt<SyncTaskFactory>().getFormOtherActionSyncTask(autoSyncRequestTask, syncCallback).formOtherActionTask(element);
                }, taskTag: ESyncTaskType.otherActionSyncTask.value);
                break;
              default:
                break;
            }
          }
        }
      }
    }, taskTag: "Auto Sync Start");
  }

  Future<void> syncCallback(ESyncTaskType eSyncTaskType, ESyncStatus eSyncStatus, dynamic data) async {
    // if (_taskCounter == 0) {
    //   Duration duration = DateTime.now().difference(_syncRequestTime);
    //   Log.d("AutoSyncExecutor Sync End TotalSyncTime(H:M:S)= ${duration.toHoursMinutesSeconds()}");
    // }
    //_sendPort.send(syncStatusResult.toJson());
    //await _siteSyncStatusManager?.syncCallback(eSyncTaskType, eSyncStatus, siteSyncRequestTask, data);
  }

  @override
  void taskNotifyListener(Task task, int pendingTaskCounter, int completedTaskCounter) {
    if (task.isDone) {
      if (pendingTaskCounter == 0) {
        syncResultCallback!(autoSyncRequestTask.eSyncType!, ESyncStatus.success, null);
      }
    }
  }
}
