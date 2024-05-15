import 'dart:async';
import 'dart:convert';

import 'package:field/data/dao/formtype_dao.dart';
import 'package:field/data/dao/user_reference_formtype_template_dao.dart';
import 'package:field/domain/use_cases/formtype/formtype_use_case.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/offline_injection_container.dart' as offline_di;
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/base_sync_task.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';

import '../../data/model/apptype_vo.dart';
import '../../data/model/user_vo.dart';
import '../../data_source/forms/form_local_data_source.dart';
import '../../utils/app_path_helper.dart';
import '../../utils/file_utils.dart';
import '../../utils/store_preference.dart';
import 'formtype_attribute_set_details_sync_task.dart';
import 'formtype_controller_user_list_sync_task.dart';
import 'formtype_custom_attribute_list_sync_task.dart';
import 'formtype_distribution_list_sync_task.dart';
import 'formtype_fixfield_list_sync_task.dart';
import 'formtype_status_list_sync_task.dart';
import 'formtype_template_dowload_sync_task.dart';

class FormTypeListSyncTask extends BaseSyncTask {
  final FormTypeUseCase _formTypeUseCase = offline_di.getIt<FormTypeUseCase>();

  FormTypeListSyncTask(super.syncRequestTask, super.syncCallback);

  Future<void> getFormTypeList({required String projectId, String? formTypeIds, List<String>? formsFormTypeIds}) async {
    await passDataToSyncCallback(ESyncTaskType.formTypeListSyncTask, ESyncStatus.inProgress, {"projectId": projectId});
    addTask((task) async => await _formTypeList(projectId, formTypeIds, task, formsFormTypeIds), taskPriority: TaskPriority.high, taskTag: ESyncTaskType.formTypeListSyncTask.value);
  }

  Future<void> _formTypeList(String projectId, String? formTypeIds, Task? task, List<String>? formsFormTypeIds) async {
    ESyncStatus eSyncStatus = ESyncStatus.failed;
    final requestParam = {"projectId": projectId, "formTypeIds": formTypeIds};
    final taskStartTime = DateTime.now();
    UserReferenceFormTypeTemplateDao userReferenceFormTypeTemplateDao = UserReferenceFormTypeTemplateDao();
    try {
      Log.d("FormTypeListSync _formTypeList \"$projectId\" and \"${formTypeIds.toString()}\" started ");
      Result result = await _formTypeUseCase.getProjectFormTypeListFromSync(projectId: projectId, formTypeIds: formTypeIds, networkExecutionType: NetworkExecutionType.SYNC, taskNumber: task?.taskNumber);
      if (result is SUCCESS) {
        final appTypeList = (result.data == null || result.data.toString().isNullOrEmpty()) ? <AppType>[] : AppType.fromJsonListSync(jsonDecode(result.data ?? "[]"));
        Log.d("FormTypeListSync _formTypeList \"$projectId\" and \"${formTypeIds.toString()}\" appTypeList=${appTypeList.length}");
        try {
          List<String> allFormTypeIdList = appTypeList.map((e) => e.formTypeID.plainValue().toString()).toList();
          String? uniqueFormTypeIds = formsFormTypeIds?.where((item) => !allFormTypeIdList.contains(item.plainValue())).toSet().toList().join(",");
          if (!uniqueFormTypeIds.isNullOrEmpty()) {
            Result result = await _formTypeUseCase.getProjectFormTypeListFromSync(projectId: projectId, formTypeIds: uniqueFormTypeIds, networkExecutionType: NetworkExecutionType.SYNC, taskNumber: task?.taskNumber);
            if (result is SUCCESS) {
              appTypeList.addAll(AppType.fromJsonListSync(jsonDecode(result.data ?? "[]")));
            }
          }
        } catch (e) {
          taskLogger(
            task: task,
            requestParam: requestParam,
            responseType: TaskSyncResponseType.exception,
            message: e.toString(),
            taskStarTime: taskStartTime,
          );
          Log.d("FormTypeListSync _formTypeList fromJsonListSync \"$projectId\" and \"${formTypeIds.toString()}\" failed exception=$e");
        }
        FormTypeDao daoObj = FormTypeDao();
        await daoObj.insert(appTypeList);
        await userReferenceFormTypeTemplateDao.insertFormTypeTemplateDetailsInUserReferenceBulk(appTypeList);
        eSyncStatus = ESyncStatus.success;
        await passDataToSyncCallback(ESyncTaskType.formTypeListSyncTask, ESyncStatus.success, {"projectId": projectId, "appTypeList": appTypeList});
        User? userDetails = await StorePreference.getUserData();
        String userId = userDetails?.usersessionprofile?.hUserID ?? "";
        for (var element in appTypeList) {
          ETemplateType eTemplateType = ETemplateType.fromNumber(element.templateType ?? 1);
          String formTypeId = element.formTypeID ?? "";
          switch (eTemplateType) {
            case ETemplateType.html:
              var templatePath = await AppPathHelper().getFormTypeTemplateFilePath(projectId: projectId, formTypeId: formTypeId);
              if (!ZipUtility().isZipFileExist(strZipFilePath: templatePath)) {
                addTask((task) async {
                  await FormTypeTemplateDownloadSyncTask(super.syncRequestTask, super.syncCallback).getFormTypeHTMLTemplateDownload(appTypeList, projectId: projectId, instanceGroupId: element.instanceGroupId ?? "", formTypeId: formTypeId, task: task);
                }, taskPriority: TaskPriority.regular, taskTag: ESyncTaskType.formTypeTemplateDownloadSyncTask.value);
              } else {
                await passDataToSyncCallback(ESyncTaskType.formTypeTemplateDownloadSyncTask, ESyncStatus.success, {"projectId": projectId, "formTypeId": formTypeId});
                FormLocalDataSource formLocalDataSource = FormLocalDataSource();
                String attributeData = await formLocalDataSource.getFormTypeViewCustomAttributeData(projectId: projectId, formTypeId: formTypeId);
                if (attributeData != "") {
                  addTask((task) async {
                    await FormTypeCustomAttributeListSyncTask(super.syncRequestTask, super.syncCallback).getFormTypeCustomAttributeList(projectId: projectId, formTypeId: formTypeId, task: task);
                  }, taskPriority: TaskPriority.regular, taskTag: ESyncTaskType.formTypeCustomAttributeListSyncTask.value);
                } else {
                  await passDataToSyncCallback(ESyncTaskType.formTypeCustomAttributeListSyncTask, ESyncStatus.success, {"projectId": projectId, "formTypeId": formTypeId});
                }
                //add task for hierarchical
                String attributeSetData = await formLocalDataSource.getFormTypeViewCustomAttributeSetData(projectId: projectId, formTypeId: formTypeId);
                if (!attributeSetData.isNullOrEmpty()) {
                  addTask((task) async {
                    await FormTypeAttributeSetDetailSyncTask(super.syncRequestTask, super.syncCallback).getFormTypeAttributeSetDetail(projectId: projectId, attributeSetId: attributeSetData, callingArea: "form", task: task);
                  }, taskPriority: TaskPriority.regular, taskTag: ESyncTaskType.formTypeAttributeSetDetailSyncTask.value);
                } else {
                  await passDataToSyncCallback(ESyncTaskType.formTypeAttributeSetDetailSyncTask, ESyncStatus.success, {"projectId": projectId, "attributeSetId": attributeSetData});
                }
              }
              addTask((task) async {
                await FormTypeDistributionListSyncTask(super.syncRequestTask, super.syncCallback).getFormTypeDistributionList(projectId: projectId, formTypeId: formTypeId, task: task);
              }, taskPriority: TaskPriority.regular, taskTag: ESyncTaskType.formTypeDistributionListSyncTask.value);
              if (element.isUseController ?? false) {
                addTask((task) async {
                  await FormTypeControllerUserListSyncTask(super.syncRequestTask, super.syncCallback).getFormTypeControllerUserList(projectId: projectId, formTypeId: formTypeId, task: task);
                }, taskPriority: TaskPriority.regular, taskTag: ESyncTaskType.formTypeControllerUserListSyncTask.value);
              } else {
                await passDataToSyncCallback(ESyncTaskType.formTypeControllerUserListSyncTask, ESyncStatus.success, {"projectId": projectId, "formTypeId": formTypeId});
              }
              addTask((task) async {
                await FormTypeStatusListSyncTask(super.syncRequestTask, super.syncCallback).getFormTypeStatusList(projectId: projectId, formTypeId: formTypeId, task: task);
              }, taskPriority: TaskPriority.regular, taskTag: ESyncTaskType.formTypeStatusListSyncTask.value);
              addTask((task) async {
                await FormTypeFixFieldListSyncTask(super.syncRequestTask, super.syncCallback).getFormTypeFixFieldList(projectId: projectId, formTypeId: formTypeId, userId: userId, task: task);
              }, taskPriority: TaskPriority.regular, taskTag: ESyncTaskType.formTypeFixFieldListSyncTask.value);
              break;
            case ETemplateType.xsn:
              var templatePath = await AppPathHelper().getFormTypeTemplateFilePath(projectId: projectId, formTypeId: formTypeId);
              if (!ZipUtility().isZipFileExist(strZipFilePath: templatePath)) {
                addTask((task) async {
                  await FormTypeTemplateDownloadSyncTask(super.syncRequestTask, super.syncCallback).getFormTypeXSNTemplateDownload(projectId: projectId, formTypeId: formTypeId, userId: userId, task: task);
                }, taskPriority: TaskPriority.regular, taskTag: "${ESyncTaskType.formTypeTemplateDownloadSyncTask.value} XSN");
              } else {
                await passDataToSyncCallback(ESyncTaskType.formTypeTemplateDownloadSyncTask, ESyncStatus.success, {"projectId": projectId, "formTypeId": formTypeId});
              }
              break;
            case ETemplateType.invalid:
              break;
          }
        }
        taskLogger(
          task: task,
          requestParam: requestParam,
          responseType: TaskSyncResponseType.success,
          message: TaskSyncResponseType.success.name,
          taskStarTime: taskStartTime,
        );
      } else {
        taskLogger(
          task: task,
          requestParam: requestParam,
          responseType: TaskSyncResponseType.failure,
          message: result.failureMessage ?? "",
          taskStarTime: taskStartTime,
        );
        Log.d("FormTypeListSync _formTypeList \"$projectId\" and \"${formTypeIds.toString()}\" finished with error=${result.data.toString()}");
      }
    } catch (e) {
      taskLogger(
        task: task,
        requestParam: requestParam,
        responseType: TaskSyncResponseType.exception,
        message: e.toString(),
        taskStarTime: taskStartTime,
      );
      Log.d("FormTypeListSync _formTypeList \"$projectId\" and \"${formTypeIds.toString()}\" failed exception=$e");
    }
    await passDataToSyncCallback(ESyncTaskType.formTypeListSyncTask, eSyncStatus, {"projectId": projectId});
  }
}
