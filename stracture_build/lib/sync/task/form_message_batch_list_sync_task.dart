import 'dart:async';
import 'dart:convert';

import 'package:field/data/dao/form_message_action_dao.dart';
import 'package:field/data/dao/form_message_attachAndAssoc_dao.dart';
import 'package:field/data/dao/form_message_dao.dart';
import 'package:field/data/dao/user_reference_attachment_dao.dart';
import 'package:field/data/model/form_message_attach_assoc_vo.dart';
import 'package:field/data/model/form_message_vo.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/site_form_action.dart';
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/base_sync_task.dart';
import 'package:field/sync/task/mark_offline_project_and_location.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/extensions.dart';

import '../../utils/field_enums.dart';
import '../../utils/form_parser_utility.dart';
import 'form_attachment_download_batch_sync_task.dart';

class FormMessageBatchListSyncTask extends BaseSyncTask {
  final ProjectListUseCase _projectListUseCase = di.getIt<ProjectListUseCase>();
  int count = 0;

  FormMessageBatchListSyncTask(super.syncRequestTask, super.syncCallback);

  Future<void> syncFormMessageBatchListData(List<Project> projectList, List<SiteForm> formList) async {
    try {
      AppConfig appConfig = di.getIt<AppConfig>();
      int maxSizeOfSiteFormList = appConfig.syncPropertyDetails!.fieldFormMessageListCount;
      for (var project in projectList) {
        List<SiteForm> tmpFormList = formList.where((e) => (e.projectId == project.projectID)).toList();
        for (var i = 0; i < tmpFormList.length; i += maxSizeOfSiteFormList) {
          var siteFormList = (tmpFormList.sublist(i, ((i + maxSizeOfSiteFormList) > tmpFormList.length) ? tmpFormList.length : (i + maxSizeOfSiteFormList)));
          count++;
          addTask((task) async {
            await _getMessageBatchListFromServer([...siteFormList], task);
          }, taskPriority: TaskPriority.regular, taskTag: "${ESyncTaskType.formMessageBatchListSyncTask.value} $count");
        }
      }
    } catch (e) {
      Log.e("FormMessageBatchListSyncTask syncFormMessageBatchListData exception $e");
    }
  }

  Future<void> _getMessageBatchListFromServer(List<SiteForm> siteFormList, Task? task) async {
    Log.d("TaskPool Task Start Fun ${ESyncTaskType.formMessageBatchListSyncTask.value}");
    List<String> successCommId = [];
    List<String> failCommId = [];
    Map<String, dynamic> chunkOfFormList = _getRequestMapDataForMessageBatchList(siteFormList, task?.taskNumber);
    final taskStartTime = DateTime.now();
    try {
      Result result = await _projectListUseCase.getFormMessageBatchList(chunkOfFormList);
      if (result is SUCCESS) {
        successCommId = await _parseFormMessageBatchList(result, siteFormList);
        taskLogger(
          task: task,
          requestParam: chunkOfFormList,
          responseType: TaskSyncResponseType.success,
          message: TaskSyncResponseType.success.name,
          taskStarTime: taskStartTime,
        );
      } else {
        taskLogger(
          task: task,
          requestParam: chunkOfFormList,
          responseType: TaskSyncResponseType.failure,
          message: result.failureMessage.toString(),
          taskStarTime: taskStartTime,
        );
      }
    } catch (e) {
      taskLogger(
        task: task,
        requestParam: chunkOfFormList,
        responseType: TaskSyncResponseType.exception,
        message: e.toString(),
        taskStarTime: taskStartTime,
      );
      Log.d("FormMessageBatchListSyncTask _getMessageBatchListFromServer exception $e");
    }
    Log.d("TaskPool Task End Fun ${ESyncTaskType.formMessageBatchListSyncTask.value}");
    count--;
    if (count == 0) {
      Log.d("TaskPool Task Fun ${ESyncTaskType.formMessageBatchListSyncTask.value} Done All");
      if (syncRequestTask.isMediaSyncEnable ?? false) {
        await FormAttachmentDownloadBatchSyncTask(syncRequestTask as SiteSyncRequestTask, syncCallback).syncFormAttachmentDataInBatch();
      }
    }
    if (siteFormList.isNotEmpty) {
      failCommId = (siteFormList.map((e) => e.formId?.plainValue().toString() ?? "").toList());
      failCommId.removeWhere((element) => successCommId.contains(element));
    }
    if (successCommId.isNotEmpty) {
      String successFormIds = successCommId.join(', ');
      await passDataToSyncCallback(ESyncTaskType.formMessageBatchListSyncTask, ESyncStatus.success, {"projectId": siteFormList[0].projectId.plainValue(), "formIds": successFormIds});
    }
    if (failCommId.isNotEmpty) {
      String failedFormIds = failCommId.join(', ');
      await passDataToSyncCallback(ESyncTaskType.formMessageBatchListSyncTask, ESyncStatus.success, {"projectId": siteFormList[0].projectId.plainValue(), "formIds": failedFormIds});
    }
  }

  Future<List<String>> _parseFormMessageBatchList(final result, List<SiteForm> siteFormList) async {
    List<String> successCommId = [];
    try {
      List<FormMessageVO> formMessageList = [];
      List<SiteFormAction> formMessagesActionList = [];
      List<FormMessageAttachAndAssocVO> formMessageAttachList = [];
      List<String> listOfInlineRevisionId = [];
      for (final siteForm in siteFormList) {
        bool isParseSuccess = false;
        List<String> msgIdList = [];
        if (result.data.keys.toString().contains(siteForm.commId.plainValue())) {
          isParseSuccess = await FormParserUtility.parseFormMessageList(
              responseData: result.data[siteForm.commId.plainValue()],
              tmpForm: siteForm,
              returnValueCallback: (List<FormMessageVO> frmMsgList, List<SiteFormAction> frmMsgActList, List<FormMessageAttachAndAssocVO> frmMsgAttachList, List<String> inlineRevisionIds) {
                formMessageList.addAll(frmMsgList);
                formMessagesActionList.addAll(frmMsgActList);
                formMessageAttachList.addAll(frmMsgAttachList);
                listOfInlineRevisionId.addAll(inlineRevisionIds);
                msgIdList = frmMsgList.map((e) => e.msgId?.toString().plainValue()??"").toList().cast<String>();
              });
        }
        if (isParseSuccess) {
          await MarkOfflineLocationProject().removeFormMessagesFromDatabase(siteForm.projectId?.plainValue()??"",siteForm.commId?.plainValue()??"",msgIdList);
          successCommId.add(siteForm.commId.plainValue());
        }
      }
      if (formMessageList.isNotEmpty) {
        FormMessageDao formMessageDaoObj = FormMessageDao();
        await formMessageDaoObj.insert(formMessageList);
      }
      if (formMessagesActionList.isNotEmpty) {
        FormMessageActionDao formMessageActionDaoObj = FormMessageActionDao();
        await formMessageActionDaoObj.insert(formMessagesActionList);
      }
      if (formMessageAttachList.isNotEmpty) {
        FormMessageAttachAndAssocDao formMessageAttachAndAssocDaoObj = FormMessageAttachAndAssocDao();
        UserReferenceAttachmentDao userReferenceAttachmentDao = UserReferenceAttachmentDao();
        await formMessageAttachAndAssocDaoObj.insert(formMessageAttachList);
        await userReferenceAttachmentDao.insertAttachmentDetailsInUserReference(formMessageAttachList);
        if (syncRequestTask.isMediaSyncEnable ?? false) {
          List<FormMessageAttachAndAssocVO> tmpListOfFormMessageAttachment = await formMessageAttachAndAssocDaoObj.getValidDownloadAttachmentList(formMessageAttachList);
          if (tmpListOfFormMessageAttachment.isNotEmpty) {
            await passDataToSyncCallback(ESyncTaskType.formAttachmentDownloadBatchSyncTask, ESyncStatus.inProgress, {"attachmentList": tmpListOfFormMessageAttachment});
          }
        }
      }
    } catch (e, stacktrace) {
      Log.d("FormMessageBatchListSyncTask _parseFormMessageBatchList exception $e");
      Log.d("FormMessageBatchListSyncTask _parseFormMessageBatchList exception $stacktrace");
    }
    return successCommId;
  }

  Map<String, dynamic> _getRequestMapDataForMessageBatchList(List<SiteForm> formMessageTaskDSList, num? taskNumber) {
    Map<String, dynamic> map = {};
    Map<String, dynamic> formDataJsonMap = {};
    map["resourceTypeId"] = "3";
    map["isOriMsgId"] = "false";
    map["networkExecutionType"] = NetworkExecutionType.SYNC;
    map["taskNumber"] = taskNumber;

    for (var formMessageTaskDS in formMessageTaskDSList) {
      Map<String, dynamic> formMessageTaskDSMap = {};
      formMessageTaskDSMap["projectId"] = formMessageTaskDS.projectId.plainValue();
      formMessageTaskDSMap["commId"] = formMessageTaskDS.commId.plainValue();
      formMessageTaskDSMap["formTypeId"] = formMessageTaskDS.formTypeId.plainValue();
      formDataJsonMap[formMessageTaskDS.commId.plainValue()!] = (formMessageTaskDSMap);
    }
    map["formDataJson"] = jsonEncode(formDataJsonMap);
    return map;
  }
}
