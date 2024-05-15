
import 'package:field/networking/network_request.dart';
import 'package:field/offline_injection_container.dart' as offline_di;
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/base_sync_task.dart';
import 'package:field/utils/extensions.dart';

import '../../data/dao/attribute_set_dao.dart';
import '../../data/model/custom_attribute_set_vo.dart';
import '../../domain/use_cases/formtype/formtype_use_case.dart';
import '../../injection_container.dart';
import '../../logger/logger.dart';
import '../../networking/network_response.dart';
import '../../utils/app_config.dart';
import '../../utils/field_enums.dart';

class FormTypeAttributeSetDetailSyncTask extends BaseSyncTask{
  final FormTypeUseCase _formTypeUseCase = offline_di.getIt<FormTypeUseCase>();

  FormTypeAttributeSetDetailSyncTask(super.syncRequestTask, super.syncCallback);

  Future<void> getFormTypeAttributeSetDetail({required String projectId, required String attributeSetId, required String callingArea,Task? task}) async {
    var attributeSetIds = attributeSetId.split(",").map((x) => x.trim()).where((element) => element.isNotEmpty).toList();
    AppConfig appConfig = getIt<AppConfig>();
    int maxSizeOfCustomAttributeSetIdList = appConfig.syncPropertyDetails!.fieldCustomAttributeSetIdLimit;
    for (var i = 0; i < attributeSetIds.length; i += maxSizeOfCustomAttributeSetIdList) {
      var attributeSetIdsList = (attributeSetIds.sublist(i, ((i + maxSizeOfCustomAttributeSetIdList) > attributeSetIds.length) ? attributeSetIds.length : (i + maxSizeOfCustomAttributeSetIdList)));
      ///Add tasks for get custom attribute set data.
      if (attributeSetIdsList.isNotEmpty) {
        await _formTypeAttributeSetDetail(projectId, attributeSetIdsList.join(','), callingArea,task);
      }
    }

  }

  Future<void> _formTypeAttributeSetDetail(String projectId, String attributeSetId, String callingArea,Task? task) async {
    if (projectId.isNotEmpty && attributeSetId.isNotEmpty) {
      final requestParam = {"projectId": projectId, "attributeSetId": attributeSetId,"callingArea":callingArea, "networkExecutionType": NetworkExecutionType.SYNC};
      final taskStartTime = DateTime.now();
      try {
        Log.d(
            "FormTypeAttributeSetDetailSyncTask _formTypeAttributeSetDetail \"$projectId\" and \"$attributeSetId\" started ");
        Result result = await _formTypeUseCase.getFormTypeAttributeSetDetail(
            projectId: projectId, attributeSetId: attributeSetId,callingArea:callingArea, networkExecutionType: NetworkExecutionType.SYNC, taskNumber: task?.taskNumber);
        Log.d("FormTypeAttributeSetDetailSyncTask result ${result.data}");

        if (result is SUCCESS) {
          CustomAttributeSetDao manageTypeDaoObj = CustomAttributeSetDao();
          for(CustomAttributeSetVo attributeSetVo in result.data){
            attributeSetVo.projectId = projectId.plainValue();
          }
          manageTypeDaoObj.insert(result.data);
          passDataToSyncCallback(
              ESyncTaskType.formTypeAttributeSetDetailSyncTask,
              ESyncStatus.success,
              {"projectId": projectId, "attributeSetId": attributeSetId,"callingArea":callingArea});
          taskLogger(
            task: task,
            requestParam: requestParam,
            responseType: TaskSyncResponseType.success,
            message: TaskSyncResponseType.success.name,
            taskStarTime: taskStartTime,
          );
        } else {
          passDataToSyncCallback(ESyncTaskType.formTypeAttributeSetDetailSyncTask, ESyncStatus.failed,  {"projectId": projectId, "attributeSetId": attributeSetId,"callingArea":callingArea});
          taskLogger(
            task: task,
            requestParam: requestParam,
            responseType: TaskSyncResponseType.failure,
            message: result.failureMessage.toString(),
            taskStarTime: taskStartTime,
          );
        }
      } catch (e) {
        await passDataToSyncCallback(ESyncTaskType.formTypeAttributeSetDetailSyncTask, ESyncStatus.failed, {"projectId": projectId, "attributeSetId": attributeSetId,"callingArea":callingArea});
        taskLogger(
          task: task,
          requestParam: requestParam,
          responseType: TaskSyncResponseType.exception,
          message: e.toString(),
          taskStarTime: taskStartTime,
        );
        Log.d("FormTypeCustomAttributeListSyncTask _formTypeCustomAttributeList \"$projectId\" and \"$attributeSetId\" failed exception=$e");
      }
    } else {
      Log.d("FormTypeCustomAttributeListSyncTask _formTypeCustomAttributeList projectId or formTypeId is empty");
    }
  }
}