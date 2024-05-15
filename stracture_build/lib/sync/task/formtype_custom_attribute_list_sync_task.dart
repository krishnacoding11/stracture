import 'package:field/networking/network_request.dart';
import 'package:field/offline_injection_container.dart' as offline_di;
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/base_sync_task.dart';
import 'package:field/utils/file_utils.dart';

import '../../domain/use_cases/formtype/formtype_use_case.dart';
import '../../logger/logger.dart';
import '../../networking/network_response.dart';
import '../../utils/app_path_helper.dart';
import '../../utils/field_enums.dart';

class FormTypeCustomAttributeListSyncTask extends BaseSyncTask {
  final FormTypeUseCase _formTypeUseCase = offline_di.getIt<FormTypeUseCase>();

  FormTypeCustomAttributeListSyncTask(super.syncRequestTask, super.syncCallback);

  Future<void> getFormTypeCustomAttributeList({required String projectId, required String formTypeId, Task? task}) async {
    await _formTypeCustomAttributeList(projectId, formTypeId, task);
  }

  Future<void> _formTypeCustomAttributeList(String projectId, String formTypeId, Task? task) async {
    if (projectId.isNotEmpty && formTypeId.isNotEmpty) {
      final requestParam = {"projectId": projectId, "formTypeId": formTypeId, "networkExecutionType": NetworkExecutionType.SYNC};
      final taskStartTime = DateTime.now();
      try {
        Log.d("FormTypeCustomAttributeListSyncTask _formTypeCustomAttributeList \"$projectId\" and \"$formTypeId\" started ");
        Result result = await _formTypeUseCase.getFormTypeCustomAttributeList(projectId: projectId, formTypeId: formTypeId, networkExecutionType: NetworkExecutionType.SYNC, taskNumber: task?.taskNumber);
        if (result is SUCCESS) {
          String filePath = await AppPathHelper().getFormTypeCustomAttributeFilePath(projectId: projectId, formTypeId: formTypeId);
          Log.d("FormTypeCustomAttributeListSyncTask _formTypeCustomAttributeList filePath=\"$filePath\"");
          Log.d("FormTypeCustomAttributeListSyncTask _formTypeCustomAttributeList response=\"${result.data}\"");
          await deleteFileAtPath(filePath);
          await writeDataToFile(filePath, result.data);
          await passDataToSyncCallback(ESyncTaskType.formTypeCustomAttributeListSyncTask, ESyncStatus.success, {"projectId": projectId, "formTypeId": formTypeId});
          taskLogger(
            task: task,
            requestParam: requestParam,
            responseType: TaskSyncResponseType.success,
            message: TaskSyncResponseType.success.name,
            taskStarTime: taskStartTime,
          );
        } else {
          await passDataToSyncCallback(ESyncTaskType.formTypeCustomAttributeListSyncTask, ESyncStatus.failed, {"projectId": projectId, "formTypeId": formTypeId});
          taskLogger(
            task: task,
            requestParam: requestParam,
            responseType: TaskSyncResponseType.failure,
            message: result.failureMessage.toString(),
            taskStarTime: taskStartTime,
          );
          Log.d("FormTypeCustomAttributeListSyncTask _formTypeCustomAttributeList \"$projectId\" and \"$formTypeId\" finished with error=${result.data.toString()}");
        }
      } catch (e) {
        await passDataToSyncCallback(ESyncTaskType.formTypeCustomAttributeListSyncTask, ESyncStatus.failed, {"projectId": projectId, "formTypeId": formTypeId});
        taskLogger(
          task: task,
          requestParam: requestParam,
          responseType: TaskSyncResponseType.exception,
          message: e.toString(),
          taskStarTime: taskStartTime,
        );
        Log.d("FormTypeCustomAttributeListSyncTask _formTypeCustomAttributeList \"$projectId\" and \"$formTypeId\" failed exception=$e");
      }
    } else {
      Log.d("FormTypeCustomAttributeListSyncTask _formTypeCustomAttributeList projectId or formTypeId is empty");
    }
  }
}
