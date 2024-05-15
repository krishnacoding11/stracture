import 'dart:io';

import 'package:field/data/dao/user_reference_formtype_template_dao.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/offline_injection_container.dart' as offline_di;
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/base_sync_task.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';

import '../../data/model/apptype_vo.dart';
import '../../data_source/forms/form_local_data_source.dart';
import '../../domain/use_cases/formtype/formtype_use_case.dart';
import '../../logger/logger.dart';
import '../../networking/network_response.dart';
import '../../utils/field_enums.dart';
import '../../utils/file_utils.dart';
import '../../utils/form_html_utility.dart';
import 'formtype_attribute_set_details_sync_task.dart';
import 'formtype_custom_attribute_list_sync_task.dart';

class FormTypeTemplateDownloadSyncTask extends BaseSyncTask {
  final FormTypeUseCase _formTypeUseCase = offline_di.getIt<FormTypeUseCase>();

  FormTypeTemplateDownloadSyncTask(super.syncRequestTask, super.syncCallback);

  Future<void> getFormTypeHTMLTemplateDownload(
    List<AppType> appTypeList, {
    required String projectId,
    required String instanceGroupId,
    required String formTypeId,
    Task? task,
  }) async {
    await _formTypeHTMLTemplateDownload(projectId, formTypeId, task, appTypeList);
  }

  Future<void> _formTypeHTMLTemplateDownload(String projectId, String formTypeId, Task? task, List<AppType> appTypeList) async {
    if (projectId.isNotEmpty && formTypeId.isNotEmpty) {
      final requestParam = {"projectId": projectId, "formTypeId": formTypeId};
      final taskStartTime = DateTime.now();
      try {
        Log.d("FormTypeTemplateDownloadSyncTask _formTypeHTMLTemplateDownload \"$projectId\" and \"$formTypeId\" started ");
        Result result = await _formTypeUseCase.getFormTypeHTMLTemplateZipDownload(projectId: projectId, formTypeId: formTypeId, networkExecutionType: NetworkExecutionType.SYNC, taskNumber: task?.taskNumber);
        if (result is SUCCESS) {
          Log.d("FormTypeTemplateDownloadSyncTask _formTypeHTMLTemplateDownload \"$projectId\" and \"$formTypeId\" finished success");
          String templateDirPath = await AppPathHelper().getAppDataFormTypeDirectory(projectId: projectId, formTypeId: formTypeId);
          var templatePath = await AppPathHelper().getFormTypeTemplateFilePath(projectId: projectId, formTypeId: formTypeId);
          Log.d("FormTypeTemplateDownloadSyncTask _formTypeHTMLTemplateDownload templatePath=\"$templatePath\"");
          var file = File(templatePath);
          file.createSync(recursive: true);
          file.writeAsBytesSync(result.data);
          bool isSuccess = await ZipUtility().extractZipFile(strZipFilePath: templatePath, strExtractDirectory: templateDirPath);
          await passDataToSyncCallback(ESyncTaskType.formTypeTemplateDownloadSyncTask, isSuccess ? ESyncStatus.success : ESyncStatus.failed, requestParam);
          if (isSuccess) {
            FormHtmlUtility().updateHTML5FormTemplatePath(zipFilePath: templatePath, templateDirPath: templateDirPath, appDirPath: await AppPathHelper().getAssetHTML5FormZipPath(), basePath: await AppPathHelper().getBasePath());
            FormLocalDataSource formLocalDataSource = FormLocalDataSource();
            String attributeData = await formLocalDataSource.getFormTypeViewCustomAttributeData(projectId: projectId, formTypeId: formTypeId);
            if (attributeData != "") {
              addTask((task) async {
                await FormTypeCustomAttributeListSyncTask(super.syncRequestTask, super.syncCallback).getFormTypeCustomAttributeList(projectId: projectId, formTypeId: formTypeId, task: task);
              }, taskTag: ESyncTaskType.formTypeCustomAttributeListSyncTask.value);
            } else {
              await passDataToSyncCallback(ESyncTaskType.formTypeCustomAttributeListSyncTask, ESyncStatus.success, requestParam);
            }
            //add task for hierachycal
            String attributeSetData = await formLocalDataSource.getFormTypeViewCustomAttributeSetData(projectId: projectId, formTypeId: formTypeId);
            if (!attributeSetData.isNullOrEmpty()) {
              addTask((task) async {
                await FormTypeAttributeSetDetailSyncTask(super.syncRequestTask, super.syncCallback).getFormTypeAttributeSetDetail(projectId: projectId, attributeSetId: attributeSetData, callingArea: "form", task: task);
              }, taskTag: ESyncTaskType.formTypeAttributeSetDetailSyncTask.value);
            } else {
              await passDataToSyncCallback(ESyncTaskType.formTypeAttributeSetDetailSyncTask, ESyncStatus.success, {"projectId": projectId, "attributeSetId": attributeSetData});
            }
          } else {
            file.deleteSync();
            await passDataToSyncCallback(ESyncTaskType.formTypeCustomAttributeListSyncTask, ESyncStatus.failed, requestParam);
            await passDataToSyncCallback(ESyncTaskType.formTypeAttributeSetDetailSyncTask, ESyncStatus.failed, requestParam);
          }
          taskLogger(
            task: task,
            requestParam: requestParam,
            responseType: isSuccess ? TaskSyncResponseType.success : TaskSyncResponseType.failure,
            message: TaskSyncResponseType.success.name,
            taskStarTime: taskStartTime,
          );
        } else {
          await passDataToSyncCallback(ESyncTaskType.formTypeCustomAttributeListSyncTask, ESyncStatus.failed, requestParam);
          await passDataToSyncCallback(ESyncTaskType.formTypeAttributeSetDetailSyncTask, ESyncStatus.failed, requestParam);
          await passDataToSyncCallback(ESyncTaskType.formTypeTemplateDownloadSyncTask, ESyncStatus.failed, requestParam);
          taskLogger(
            task: task,
            requestParam: requestParam,
            responseType: TaskSyncResponseType.failure,
            message: result.failureMessage.toString(),
            taskStarTime: taskStartTime,
          );
          Log.d("FormTypeTemplateDownloadSyncTask _formTypeHTMLTemplateDownload \"$projectId\" and \"$formTypeId\" finished with error=${result.data.toString()}");
        }
      } catch (e) {
        await passDataToSyncCallback(ESyncTaskType.formTypeCustomAttributeListSyncTask, ESyncStatus.failed, requestParam);
        await passDataToSyncCallback(ESyncTaskType.formTypeAttributeSetDetailSyncTask, ESyncStatus.failed, requestParam);
        await passDataToSyncCallback(ESyncTaskType.formTypeTemplateDownloadSyncTask, ESyncStatus.failed, requestParam);
        taskLogger(
          task: task,
          requestParam: requestParam,
          responseType: TaskSyncResponseType.exception,
          message: e.toString(),
          taskStarTime: taskStartTime,
        );
        Log.d("FormTypeTemplateDownloadSyncTask _formTypeHTMLTemplateDownload \"$projectId\" and \"$formTypeId\" failed exception=$e");
      }
    } else {
      Log.d("FormTypeTemplateDownloadSyncTask _formTypeHTMLTemplateDownload projectId or formTypeId is empty");
    }
  }

  Future<void> getFormTypeXSNTemplateDownload({required String projectId, required String formTypeId, required String userId, Task? task}) async {
    await _formTypeXSNTemplateDownload(projectId, formTypeId, userId, task);
  }

  Future<void> _formTypeXSNTemplateDownload(String projectId, String formTypeId, String userId, Task? task) async {
    UserReferenceFormTypeTemplateDao userReferenceFormTypeTemplateDao = UserReferenceFormTypeTemplateDao();
    if (projectId.isNotEmpty && formTypeId.isNotEmpty) {
      final requestParam = {"projectId": projectId, "formTypeId": formTypeId};
      final taskStartTime = DateTime.now();
      try {
        Log.d("FormTypeTemplateDownloadSyncTask _formTypeXSNTemplateDownload \"$projectId\" and \"$formTypeId\" started ");
        String offlineJsFolderPath = "file:///offlineJsFolder/";
        bool isMobileView = !(Utility.isTablet);
        Result result = await _formTypeUseCase.getFormTypeXSNTemplateZipDownload(
          projectId: projectId,
          formTypeId: formTypeId,
          userId: userId,
          jSFolderPath: offlineJsFolderPath,
          isMobileView: isMobileView,
          networkExecutionType: NetworkExecutionType.SYNC,
          taskNumber: task?.taskNumber,
        );
        if (result is SUCCESS) {
          Log.d("FormTypeTemplateDownloadSyncTask _formTypeXSNTemplateDownload \"$projectId\" and \"$formTypeId\" finished success");
          String templateDirPath = await AppPathHelper().getAppDataFormTypeDirectory(projectId: projectId, formTypeId: formTypeId);
          String templatePath = await AppPathHelper().getFormTypeTemplateFilePath(projectId: projectId, formTypeId: formTypeId);
          Log.d("FormTypeTemplateDownloadSyncTask _formTypeXSNTemplateDownload templatePath=\"$templatePath\"");
          var file = File(templatePath);
          file.createSync(recursive: true);
          file.writeAsBytesSync(result.data);
          await ZipUtility().extractZipFile(strZipFilePath: templatePath, strExtractDirectory: templateDirPath);
          await userReferenceFormTypeTemplateDao.insertFormTypeTemplateDetailsInUserReference(projectId: projectId.plainValue(), formTypeId: formTypeId.plainValue());
          await passDataToSyncCallback(ESyncTaskType.formTypeTemplateDownloadSyncTask, ESyncStatus.success, requestParam);
          taskLogger(
            task: task,
            requestParam: requestParam,
            responseType: TaskSyncResponseType.success,
            message: TaskSyncResponseType.success.name,
            taskStarTime: taskStartTime,
          );
        } else {
          Log.d("FormTypeTemplateDownloadSyncTask _formTypeXSNTemplateDownload \"$projectId\" and \"$formTypeId\" finished with error=${result.data.toString()}");
          await passDataToSyncCallback(ESyncTaskType.formTypeTemplateDownloadSyncTask, ESyncStatus.failed, {"projectId": projectId, "formTypeId": formTypeId});
          taskLogger(
            task: task,
            requestParam: requestParam,
            responseType: TaskSyncResponseType.failure,
            message: result.failureMessage.toString(),
            taskStarTime: taskStartTime,
          );
        }
      } catch (e) {
        await passDataToSyncCallback(ESyncTaskType.formTypeTemplateDownloadSyncTask, ESyncStatus.failed, {"projectId": projectId, "formTypeId": formTypeId});
        taskLogger(
          task: task,
          requestParam: requestParam,
          responseType: TaskSyncResponseType.exception,
          message: e.toString(),
          taskStarTime: taskStartTime,
        );
        Log.d("FormTypeTemplateDownloadSyncTask _formTypeXSNTemplateDownload \"$projectId\" and \"$formTypeId\" failed exception=$e");
      }
    } else {
      Log.d("FormTypeTemplateDownloadSyncTask _formTypeXSNTemplateDownload projectId or formTypeId is empty");
    }
  }
}
