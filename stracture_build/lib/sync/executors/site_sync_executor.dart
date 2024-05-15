import 'dart:async';
import 'dart:isolate';

import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/data/model/sync_status.dart';
import 'package:field/data/remote/dashboard/homepage_remote_repository_impl.dart';
import 'package:field/logger/logger.dart';
import 'package:field/sync/calculation/site_sync_status_manager.dart';
import 'package:field/sync/executor.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/project_and_location_sync_task.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/field_enums.dart';
import 'package:field/utils/store_preference.dart';
import 'package:flutter/foundation.dart';

import '../../offline_injection_container.dart';
import '../sync_task_factory.dart';

class SiteSyncExecutor extends SyncExecutor {
  SiteSyncStatusManager? _siteSyncStatusManager;

  SiteSyncRequestTask siteSyncRequestTask;

  SiteSyncExecutor(this.siteSyncRequestTask) : super(siteSyncRequestTask, "SiteSyncExecutor");

  @override
  Future<void> execute(SyncResultCallback syncResultCallback, SendPort port) async {
    super.execute(syncResultCallback, port);
    _siteSyncStatusManager ??= await SiteSyncStatusManager.getInstance();
    addTask(
      (task) async => await syncProject(syncResultCallback, task),
      taskPriority: TaskPriority.immediately,
      taskTag: "Site Sync Start",
    );
    addTask((task) async {
      final syncTask = getIt<SyncTaskFactory>().getColumnHeaderListSyncTask(siteSyncRequestTask, syncCallback);
      await syncTask.syncColumnHeaderListData(task);
    }, taskPriority: TaskPriority.high, taskTag: ESyncTaskType.columnHeaderListSyncTask.value);
    Log.d("SiteSyncExecutor Object >> ${describeIdentity(this)}");

    getIt<SyncTaskFactory>().getManageHomePageConfigurationTask(syncRequestTask, syncCallback).manageHomePageConfiguration(projectId: siteSyncRequestTask.projectId!,);
  }

  @override
  void taskNotifyListener(Task task, int pendingTaskCounter, int completedTaskCounter) {
    Log.d("taskNotifyListener[${describeIdentity(this)}] >> pendingTaskCounter >> $pendingTaskCounter completedTaskCounter $completedTaskCounter");
    if (task.isDone) {
      if (pendingTaskCounter <= 0 || task.taskTag == ESyncTaskType.formAttachmentDownloadBatchSyncTask.value ||completedTaskCounter % (siteSyncRequestTask.thresholdCompletedTask ?? AConstants.thresholdCompletedTask) == 0) {
        Map? syncResultMap = _siteSyncStatusManager?.syncStatusResultMap(siteSyncRequestTask);
        if (syncResultMap != null && syncResultMap.length > 1 && syncResultCallback != null) {
          syncResultCallback!(siteSyncRequestTask.eSyncType!, pendingTaskCounter == 0 ? ESyncStatus.success : ESyncStatus.inProgress, syncResultMap);
        }
        if (pendingTaskCounter == 0) {
          _siteSyncStatusManager?.removeSyncRequestData(siteSyncRequestTask);
        }
      }
    }
  }

  Future<void> syncProject(SyncResultCallback syncResultCallback, Task? task) async {
    try {
      ProjectAndLocationSyncTask prjAndLocObj = getIt<SyncTaskFactory>().getProjectAndLocationSyncTask(siteSyncRequestTask, syncCallback);
      SyncStatus syncStatus = await prjAndLocObj.syncProjectAndLocationData(task?.taskNumber);
      if (syncStatus is SyncSuccessProjectLocationState) {
        Log.d("SiteSyncExecutor Object Project & Location>> ${describeIdentity(this)}");
        addTask(
            (task) async => await getIt<SyncTaskFactory>().getFormListSyncTask(syncRequestTask, syncCallback).syncFormListData(syncStatus.projectList, syncStatus.siteLocationList, task?.taskNumber).then((formListSyncTaskStatus) async {
                  if (formListSyncTaskStatus is SyncSuccessFormListState) {
                    List<String>? allFormListFormTypeIdList = formListSyncTaskStatus.formList.map((element) => element.formTypeId.toString()).toSet().toList();
                    Log.d("SiteSyncExecutor >> before FormTypeListSyncTask ");
                    await getIt<SyncTaskFactory>().getFormTypeListSyncTask(syncRequestTask, syncCallback).getFormTypeList(projectId: syncStatus.projectList[0].projectID ?? "", formsFormTypeIds: allFormListFormTypeIdList);
                    Log.d("SiteSyncExecutor >> after FormTypeListSyncTask ");
                    if (formListSyncTaskStatus.formList.isNotEmpty) {
                      // fetch message batch only if forms are available
                      Log.d("SiteSyncExecutor >> before FormMessageBatchListSyncTask ");
                      await getIt<SyncTaskFactory>().getFormMessageBatchListSyncTask(syncRequestTask, syncCallback).syncFormMessageBatchListData(syncStatus.projectList, formListSyncTaskStatus.formList);
                      Log.d("SiteSyncExecutor >> after FormMessageBatchListSyncTask ");
                    }
                  }
                }),
            taskPriority: TaskPriority.high,
            taskTag: ESyncTaskType.formListSyncTask.value);
        // Sync Pdf and XFDF Files for all Site location
        getIt<SyncTaskFactory>().getFilterSyncTask(syncRequestTask, syncCallback).getAttributeList(projectId: syncStatus.projectList[0].projectID!, appTypeId: "2");
        getIt<SyncTaskFactory>().getLocationPlanSyncTask(syncRequestTask, syncCallback).downloadPlanFile(syncStatus.projectList, syncStatus.siteLocationList);
        getIt<SyncTaskFactory>().getStatusStyleListSyncTask(syncRequestTask, syncCallback).syncStatusStyleData(syncStatus.projectList);
        getIt<SyncTaskFactory>().getManageTypeListSyncTask(syncRequestTask, syncCallback).syncManageTypeListData(syncStatus.projectList);
      } else if (syncStatus is SyncErrorState) {
        sendPort.send("SiteSyncExecutor exception ${syncStatus.className} ${syncStatus.msg}");
      }
    } catch (e) {
      Log.d("SiteSyncExecutor exception $e");
      sendPort.send("SiteSyncExecutor exception $e");
    }
  }

  Future<void> syncCallback(ESyncTaskType eSyncTaskType, ESyncStatus eSyncStatus, dynamic data) async {
    await _siteSyncStatusManager?.syncCallback(eSyncTaskType, eSyncStatus, siteSyncRequestTask, data);
  }
}
