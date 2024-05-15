
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

class FormTypeDistributionListSyncTask extends BaseSyncTask {
  final FormTypeUseCase _formTypeUseCase = offline_di.getIt<FormTypeUseCase>();

  FormTypeDistributionListSyncTask(super.syncRequestTask, super.syncCallback);

  Future<void> getFormTypeDistributionList({required String projectId, required String formTypeId, Task? task}) async {
   await _formTypeDistributionList(projectId, formTypeId, task);
  }

  Future<void> _formTypeDistributionList(String projectId, String formTypeId, Task? task) async {
    if (projectId.isNotEmpty && formTypeId.isNotEmpty) {
      final requestParam = {"projectId": projectId, "formTypeId": formTypeId};
      final taskStartTime = DateTime.now();
      try {
        Log.d(
            "FormTypeDistributionListSyncTask _formTypeDistributionList \"$projectId\" and \"$formTypeId\" started ");
        Result result = await _formTypeUseCase.getFormTypeDistributionList(
            projectId: projectId, formTypeId: formTypeId, networkExecutionType: NetworkExecutionType.SYNC, taskNumber: task?.taskNumber);
        if (result is SUCCESS) {
          String filePath = await AppPathHelper()
              .getFormTypeDistributionFilePath(
                  projectId: projectId, formTypeId: formTypeId);
          Log.d("FormTypeDistributionListSyncTask _formTypeDistributionList filePath=\"$filePath\"");
          Log.d("FormTypeDistributionListSyncTask _formTypeDistributionList response=\"${result.data}\"");

          await _writeDataToFile(
              filePath,
              ParserUtility.formTypeDistributionJsonDeHashed(
                  jsonData: result.data));
          await passDataToSyncCallback(
              ESyncTaskType.formTypeDistributionListSyncTask,
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
          await passDataToSyncCallback(ESyncTaskType.formTypeDistributionListSyncTask, ESyncStatus.failed, requestParam);
          taskLogger(
            task: task,
            requestParam: requestParam,
            responseType: TaskSyncResponseType.failure,
            message: result.failureMessage ?? "",
            taskStarTime: taskStartTime,
          );
          Log.d("FormTypeDistributionListSyncTask _formTypeDistributionList \"$projectId\" and \"$formTypeId\" finished with error=${result.data.toString()}");
        }
      } catch (e) {
        await passDataToSyncCallback(ESyncTaskType.formTypeDistributionListSyncTask, ESyncStatus.failed, requestParam);
        taskLogger(
          task: task,
          requestParam: requestParam,
          responseType: TaskSyncResponseType.exception,
          message: e.toString(),
          taskStarTime: taskStartTime,
        );
        Log.d("FormTypeDistributionListSyncTask _formTypeDistributionList \"$projectId\" and \"$formTypeId\" failed exception=$e");
      }
    } else {
      Log.d("FormTypeDistributionListSyncTask _formTypeDistributionList projectId or formTypeId is empty");
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