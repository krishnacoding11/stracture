
import 'dart:io';

import 'package:field/networking/network_request.dart';
import 'package:field/offline_injection_container.dart' as offline_di;
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/base_sync_task.dart';
import 'package:field/utils/parser_utility.dart';

import '../../domain/use_cases/formtype/formtype_use_case.dart';
import '../../logger/logger.dart';
import '../../networking/network_response.dart';
import '../../utils/app_path_helper.dart';
import '../../utils/field_enums.dart';
class FormTypeControllerUserListSyncTask extends BaseSyncTask{
  final FormTypeUseCase _formTypeUseCase = offline_di.getIt<FormTypeUseCase>();

  FormTypeControllerUserListSyncTask(super.syncRequestTask, super.syncCallback);

  Future<void> getFormTypeControllerUserList({required String projectId, required String formTypeId, Task? task}) async {
    await _formTypeControllerUserList(projectId, formTypeId, task);
  }

  Future<void> _formTypeControllerUserList(String projectId, String formTypeId, Task? task) async {
    if (projectId.isNotEmpty && formTypeId.isNotEmpty) {
      final requestParam = {"projectId": projectId, "formTypeId": formTypeId, "networkExecutionType": NetworkExecutionType.SYNC};
      final taskStartTime = DateTime.now();
      try {
        Log.d(
            "FormTypeControllerUserListSyncTask _formTypeControllerUserList \"$projectId\" and \"$formTypeId\" started ");
        _formTypeUseCase
            .getFormTypeControllerUserList(
                projectId: projectId, formTypeId: formTypeId, networkExecutionType: NetworkExecutionType.SYNC, taskNumber: task?.taskNumber)
            .then((value) async {
          if (value is SUCCESS) {
            String filePath = await AppPathHelper()
                .getFormTypeControllerUserListFilePath(
                    projectId: projectId, formTypeId: formTypeId);
            Log.d(
                "FormTypeControllerUserListSyncTask _formTypeControllerUserList filePath=\"$filePath\"");
            await _writeDataToFile(
                filePath,
                ParserUtility.formTypeControllerUserJsonDeHashed(
                    jsonData: value.data));
            await passDataToSyncCallback(
                ESyncTaskType.formTypeControllerUserListSyncTask,
                ESyncStatus.success,
                {"projectId": projectId, "formTypeId": formTypeId});
            taskLogger(
              task: task,
              requestParam: requestParam,
              responseType: TaskSyncResponseType.success,
              message: TaskSyncResponseType.success.name,
              taskStarTime: taskStartTime,
            );
          } else {
           await passDataToSyncCallback(ESyncTaskType.formTypeControllerUserListSyncTask, ESyncStatus.failed, {"projectId" : projectId,"formTypeId":formTypeId});
           taskLogger(
              task: task,
              requestParam: requestParam,
              responseType: TaskSyncResponseType.failure,
              message: value.failureMessage.toString(),
              taskStarTime: taskStartTime,
            );
           Log.d("FormTypeControllerUserListSyncTask _formTypeControllerUserList \"$projectId\" and \"$formTypeId\" finished with error=${value.data.toString()}");
          }
        });
      } catch (e) {
        await passDataToSyncCallback(ESyncTaskType.formTypeControllerUserListSyncTask, ESyncStatus.failed, {"projectId" : projectId,"formTypeId":formTypeId});
        taskLogger(
          task: task,
          requestParam: requestParam,
          responseType: TaskSyncResponseType.exception,
          message: e.toString(),
          taskStarTime: taskStartTime,
        );
        Log.d("FormTypeControllerUserListSyncTask _formTypeControllerUserList \"$projectId\" and \"$formTypeId\" failed exception=$e");
      }
    } else {
      Log.d("FormTypeControllerUserListSyncTask _formTypeControllerUserList projectId or formTypeId is empty");
    }
  }

  Future<void> _writeDataToFile(String filePath, dynamic data) async {
    var file = File(filePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync(recursive: true);
    await file.writeAsString(data);
  }
}