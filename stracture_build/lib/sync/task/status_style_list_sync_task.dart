import 'dart:async';
import 'dart:convert';

import 'package:field/data/dao/status_style_dao.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/status_style_list_vo.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/base_sync_task.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';

class StatusStyleListSyncTask extends BaseSyncTask {
  final ProjectListUseCase _projectListUseCase = di.getIt<ProjectListUseCase>();

  StatusStyleListSyncTask(super.syncRequestTask, super.syncCallback);

  void syncStatusStyleData(List<Project> projectList) {
    addTask((task) async {
      await _getStatusStyleDataFromServer(projectList, task);
    }, taskPriority: TaskPriority.high,taskTag: ESyncTaskType.statusStyleListSyncTask.value);
  }

  Future<void> _getStatusStyleDataFromServer(List<Project> projectList, Task? task) async {
    final taskStartTime = DateTime.now();
    try {
      Map<String, dynamic> requestMap = await _getRequestMapData(projectList);
      if (requestMap.isNotEmpty) {
        Result result = await _projectListUseCase.getStatusStyleFromServer(requestMap);
        if (result is SUCCESS) {
          StatusStyleListVo statusStyleListVo = StatusStyleListVo.fromJson(jsonDecode(result.data));
          if (statusStyleListVo.statusStyleVO != null) {
            StatusStyleListDao statusStyleListDaoObj = StatusStyleListDao();
            await statusStyleListDaoObj.insert(statusStyleListVo.statusStyleVO!);
          }
          passDataToSyncCallback(ESyncTaskType.statusStyleListSyncTask, ESyncStatus.success, {"projectId": projectList[0].projectID.plainValue()});
          taskLogger(
            task: task,
            requestParam: requestMap,
            responseType: TaskSyncResponseType.success,
            message: TaskSyncResponseType.success.name,
            taskStarTime: taskStartTime,
          );
        } else {
          passDataToSyncCallback(ESyncTaskType.statusStyleListSyncTask, ESyncStatus.failed, {"projectId": projectList[0].projectID.plainValue()});
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
      passDataToSyncCallback(ESyncTaskType.statusStyleListSyncTask, ESyncStatus.failed, {"projectId": syncRequestTask.projectId!.plainValue()});
      Log.d("_getStatusStyleDataFromServer exception $e");
      Log.d("_getStatusStyleDataFromServer exception $stacktrace");
      taskLogger(
        task: task,
        requestParam: {},
        responseType: TaskSyncResponseType.exception,
        message: e.toString(),
        taskStarTime: taskStartTime,
      );
    }
  }

  Future<Map<String, dynamic>> _getRequestMapData(List<Project> projectList) async {
    Map<String, dynamic> requestMap = {};
    String strProjectId = projectList[0].projectID.plainValue();
    requestMap["selectedProjectIds"] = strProjectId;
    requestMap["requireAllStatus"] = "true";
    return requestMap;
  }
}
