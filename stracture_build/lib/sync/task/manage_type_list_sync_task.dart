import 'dart:async';

import 'package:field/data/dao/manage_type_dao.dart';
import 'package:field/data/model/manage_type_list_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/base_sync_task.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';

class ManageTypeListSyncTask extends BaseSyncTask {
  final ProjectListUseCase _projectListUseCase = di.getIt<ProjectListUseCase>();

  ManageTypeListSyncTask(super.syncRequestTask, super.syncCallback);

  void syncManageTypeListData(List<Project> projectList) {
    addTask((task) async {
      await _getManageTypeListDataFromServer(projectList, task);
    },taskPriority: TaskPriority.high, taskTag: ESyncTaskType.manageTypeListSyncTask.value);
  }

  Future<void> _getManageTypeListDataFromServer(List<Project> projectList, Task? task) async {
    final taskStartTime = DateTime.now();
    try {
      Map<String, dynamic> requestMap = await _getRequestMapData(projectList, task?.taskNumber);
      if (requestMap.isNotEmpty) {
        Result result = await _projectListUseCase.getManageTypeListFromServer(requestMap);
        if (result is SUCCESS) {
          ManageTypeListVO manageTypeListVO = ManageTypeListVO.fromJson(result.data);
          ManageTypeDao manageTypeDaoObj = ManageTypeDao();
          await manageTypeDaoObj.insert(manageTypeListVO.distData!.defTypeJson!);
          passDataToSyncCallback(ESyncTaskType.manageTypeListSyncTask, ESyncStatus.success, {"projectId": projectList[0].projectID!.plainValue()});
          taskLogger(
            task: task,
            requestParam: requestMap,
            responseType: TaskSyncResponseType.success,
            message: TaskSyncResponseType.success.name,
            taskStarTime: taskStartTime,
          );
        } else {
          passDataToSyncCallback(ESyncTaskType.manageTypeListSyncTask, ESyncStatus.failed, {"projectId": projectList[0]!.projectID!.plainValue()});
          taskLogger(
            task: task,
            requestParam: requestMap,
            responseType: TaskSyncResponseType.failure,
            message: result.failureMessage.toString(),
            taskStarTime: taskStartTime,
          );
        }
      }
    } catch (e, stacktrace) {
      passDataToSyncCallback(ESyncTaskType.manageTypeListSyncTask, ESyncStatus.failed, {"projectId": syncRequestTask.projectId!.plainValue()});
      Log.d("_getManageTypeListDataFromServer exception $e");
      Log.d("_getManageTypeListDataFromServer exception $stacktrace");
      taskLogger(
        task: task,
        requestParam: {},
        responseType: TaskSyncResponseType.exception,
        message: e.toString(),
        taskStarTime: taskStartTime,
      );
    }
  }

  Future<Map<String, dynamic>> _getRequestMapData(List<Project> projectList, num? taskNumber) async {
    Map<String, dynamic> requestMap = {};
    String strProjectId = projectList[0].projectID!;
    requestMap["projectId"] = strProjectId;
    requestMap["includeDeactivated"] = "true";
    requestMap["applicationId"] = 3;
    requestMap["statusTypeId"] = 1;
    requestMap["networkExecutionType"] = NetworkExecutionType.SYNC;
    requestMap["taskNumber"] = taskNumber;
    return requestMap;
  }
}
