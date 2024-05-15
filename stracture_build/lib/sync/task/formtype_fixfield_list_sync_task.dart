
import 'dart:io';

import 'package:field/networking/network_request.dart';
import 'package:field/offline_injection_container.dart' as offline_di;
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/base_sync_task.dart';

import '../../domain/use_cases/formtype/formtype_use_case.dart';
import '../../logger/logger.dart';
import '../../networking/network_response.dart';
import '../../utils/app_path_helper.dart';
import '../../utils/field_enums.dart';

class FormTypeFixFieldListSyncTask extends BaseSyncTask {
  final FormTypeUseCase _formTypeUseCase = offline_di.getIt<FormTypeUseCase>();

  FormTypeFixFieldListSyncTask(super.syncRequestTask, super.syncCallback);

  Future<void> getFormTypeFixFieldList({required String projectId, required String formTypeId, required String userId, Task? task}) async {
    await _formTypeFixFieldList(projectId, formTypeId, userId, task);
  }

  Future<void> _formTypeFixFieldList(String projectId, String formTypeId, String userId, Task? task) async {
    if (projectId.isNotEmpty && formTypeId.isNotEmpty && userId.isNotEmpty) {
      final requestParam = {"projectId": projectId, "formTypeId": formTypeId};
      final taskStartTime = DateTime.now();
      try {
        Log.d(
            "FormTypeFixFieldListSyncTask _formTypeFixFieldList \"$projectId\" and \"$formTypeId\" started ");
        Result result = await _formTypeUseCase.getFormTypeFixFieldList(
            projectId: projectId, formTypeId: formTypeId, userId: userId, networkExecutionType: NetworkExecutionType.SYNC, taskNumber: task?.taskNumber);
        if (result is SUCCESS) {
          String filePath = await AppPathHelper().getFormTypeFixFieldFilePath(
              projectId: projectId, formTypeId: formTypeId);
          Log.d(
              "FormTypeFixFieldListSyncTask _formTypeFixFieldList filePath=\"$filePath\"");
          await _writeDataToFile(filePath, result.data);
          await passDataToSyncCallback(
              ESyncTaskType.formTypeFixFieldListSyncTask,
              ESyncStatus.success,
              requestParam);
          taskLogger(
            task: task,
            requestParam: requestParam,
            responseType: TaskSyncResponseType.success,
            message: TaskSyncResponseType.success.name,
            taskStarTime: taskStartTime,
          );
        } else {
          await passDataToSyncCallback(ESyncTaskType.formTypeFixFieldListSyncTask, ESyncStatus.failed, requestParam);
          taskLogger(
            task: task,
            requestParam: requestParam,
            responseType: TaskSyncResponseType.failure,
            message: result.failureMessage.toString(),
            taskStarTime: taskStartTime,
          );
          Log.d("FormTypeFixFieldListSyncTask _formTypeFixFieldList \"$projectId\" and \"$formTypeId\" finished with error=${result.data.toString()}");
        }
      } catch (e) {
        await passDataToSyncCallback(ESyncTaskType.formTypeFixFieldListSyncTask, ESyncStatus.failed, requestParam);
        taskLogger(
          task: task,
          requestParam: requestParam,
          responseType: TaskSyncResponseType.exception,
          message: e.toString(),
          taskStarTime: taskStartTime,
        );
        Log.d("FormTypeFixFieldListSyncTask _formTypeFixFieldList \"$projectId\" and \"$formTypeId\" failed exception=$e");
      }
    } else {
      Log.d("FormTypeFixFieldListSyncTask _formTypeFixFieldList projectId or formTypeId is empty");
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