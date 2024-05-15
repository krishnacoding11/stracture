
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/offline_injection_container.dart' as offline_di;
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/parser_utility.dart';
import 'package:intl/intl.dart';

import '../../data/model/form_message_attach_assoc_vo.dart';
import '../../data/model/form_message_vo.dart';
import '../../data/model/form_vo.dart';
import '../../data/model/site_form_action.dart';
import '../../data_source/forms/form_local_data_source.dart';
import '../../domain/use_cases/project_list/project_list_use_case.dart';
import '../../domain/use_cases/site/create_form_use_case.dart';
import '../../logger/logger.dart';
import '../../networking/network_request.dart';
import '../../utils/field_enums.dart';
import '../../utils/form_parser_utility.dart';
import '../../utils/utils.dart';
import 'base_sync_task.dart';

class PushToServerFormSyncTask extends BaseSyncTask {
  final ProjectListUseCase _projectListUseCase = offline_di.getIt<ProjectListUseCase>();
  final CreateFormUseCase useCase = offline_di.getIt<CreateFormUseCase>();


  PushToServerFormSyncTask(super.syncRequestTask, super.syncCallback);

  Future<void> syncFormDataToServer(Map<String,dynamic> paramData, num?  taskNumber) async {
    FormLocalDataSource frmDb = await getDatabaseManager();
    var result = await frmDb.getPushToServerRequestData(paramData);
    //Log.d("SyncFormData $result");
    if (result.isNotEmpty) {
     Map<String, String> offlineAttachmentList = await frmDb.getOfflineAttachFileList(paramData["ProjectId"].toString(), paramData["FormId"]?.toString().plainValue() ?? "", paramData["MsgId"]?.toString().plainValue() ?? "");
      var postDataNode = await _requestPostData(result,offlineAttachmentList);
      //Log.d("SyncFormPostData $postDataNode");
      //Log.d("SyncFormOfflineAttachmentList $offlineAttachmentList");
      if (postDataNode.isNotEmpty) {
        if (postDataNode.containsKey("url")) {
          postDataNode.remove("url");
        }
        postDataNode["networkExecutionType"] = NetworkExecutionType.SYNC;
        postDataNode["taskNumber"] = taskNumber;
        Result response = await useCase.saveFormToServer(postDataNode);
        if (response is SUCCESS) {
          try {
            var data = response.data;
            SiteForm tmpForm = SiteForm.offlineformSyncJson(data["formDetailsVO"]);
            try {
              Map<String, dynamic> requestData = _getRequestDataForMessageBatchList(tmpForm, taskNumber);
              Result msgListResponse = await _projectListUseCase.getFormMessageBatchList(requestData);
              if (msgListResponse is SUCCESS) {
                if (msgListResponse.data is Map && (msgListResponse.data as Map).containsKey(tmpForm.commId!.plainValue())) {
                  List<FormMessageVO> formMessageList = [];
                  List<SiteFormAction> formMessagesActionList = [];
                  List<FormMessageAttachAndAssocVO> formMessageAttachList = [];
                  List<String> listOfInlineRevisionId = [];
                  bool isTrue = await FormParserUtility.parseFormMessageList(responseData: msgListResponse.data[tmpForm.commId!.plainValue()], tmpForm: tmpForm, returnValueCallback: (
                      List<FormMessageVO> frmMsgList,List<SiteFormAction> frmMsgActList, List<FormMessageAttachAndAssocVO> frmMsgAttachList, List<String> inlineRevisionIds) {
                    formMessageList.addAll(frmMsgList);
                    formMessagesActionList.addAll(frmMsgActList);
                    formMessageAttachList.addAll(frmMsgAttachList);
                    listOfInlineRevisionId.addAll(inlineRevisionIds);
                  });
                  if (isTrue && formMessageList.isNotEmpty) {
                    FormLocalDataSource frmDb = await getDatabaseManager();
                    await frmDb.updateOfflineCreatedOrRespondedFormData(
                        paramData: paramData,
                        requestData: postDataNode,
                        frmVO: tmpForm,
                        frmMsgList: formMessageList,
                        frmMsgActList: formMessagesActionList,
                        frmMsgAttachList: formMessageAttachList,
                        inlineRevisionIdList: listOfInlineRevisionId);
                  }
                }
              }
            } catch (e) {
              Log.d("FormMessageBatchListSyncTask _getMessageBatchListFromServer exception $e");
            }
          } catch (e) {
            Log.d("FormMessageBatchListSyncTask _getMessageBatchListFromServer exception $e");
          }
        }
      }
    }
  }

  Future<Map<String, dynamic>> _requestPostData(String result,  Map<String, String> offlineAttachmentList) async {
    Map<String, dynamic> postDataNode = {};
    String appBasePath = AppPathHelper().basePath;
    bool isUploadAttachmentInTemp = false;
    var requestPostDataNode = jsonDecode(result);
    if (requestPostDataNode is Map) {
      postDataNode = requestPostDataNode as Map<String, dynamic>;
      postDataNode.removeWhere((key, value) => (value == null));
      postDataNode["hasAttachement"] = true;
      if (!postDataNode.containsKey("appType") && postDataNode.containsKey("appTypeId")) {
        postDataNode["appType"] = postDataNode["appTypeId"];
        postDataNode.remove("appTypeId");
      }
      if (!postDataNode.containsKey("template_type_id") && postDataNode.containsKey("templateType")) {
        postDataNode["template_type_id"] = postDataNode["templateType"];
      }
      ETemplateType eTemplateType = ETemplateType.fromString(postDataNode["template_type_id"]?.toString() ?? "");
      if (eTemplateType == ETemplateType.html /* || (eTemplateType==ETemplateType.xsn && postDataNode["appBuilderId"]?.toString()!="SNG-DEF")*/) {
        postDataNode["save_draft"] = (postDataNode["isDraft"]?.toString() == "true") ? "1" : "0";
        String jsonData = postDataNode["offlineFormDataJson"]?.toString() ?? "{}";
         //inline attachment code
        try {
          FormLocalDataSource dbOperation = await getDatabaseManager();
          jsonData = await dbOperation.getInlineAttachmentServerRequestData(
            jsonData,
                (String strInlineAttDetailsList, String strInlineAttReqParamList, Map strInlineAttUploadPath) async {
              if (strInlineAttDetailsList != "") {
                postDataNode["inlineAttDetails"] = strInlineAttDetailsList;
              }
              if (strInlineAttReqParamList != "") {
                postDataNode["inlineAttReqParam"] = strInlineAttReqParamList;
              }
              if (strInlineAttUploadPath.isNotEmpty) {
                isUploadAttachmentInTemp = true;
                for (var rowData in strInlineAttUploadPath.entries) {
                  String offlineInlineFilePath = rowData.value.toString().replaceAll("./../..", appBasePath);
                  postDataNode[rowData.key.toString()] = await MultipartFile.fromFile(offlineInlineFilePath);
                }
              }
            },
          );
        } catch (e) {
          Log.d("FormLocalDataSource::getInlineAttachmentServerRequestData exception=$e");
        }
        var jsonDataNode = jsonDecode(jsonData);
        if (jsonDataNode is Map) {
          if (jsonDataNode["myFields"]["dist_list"] != null) {
            postDataNode["dist_list"] = jsonDataNode["myFields"]["dist_list"];
            jsonDataNode["myFields"].remove("dist_list");
          }
          if (jsonDataNode["myFields"]["respondBy"] != null) {
            String userDateFormat = requestPostDataNode["userDateFormat"] ?? "";
            if (userDateFormat.isNotEmpty && userDateFormat != Utility.defaultDateFormat) {
              try {
                postDataNode["respondBy"] = DateFormat(Utility.defaultDateFormat).format(DateFormat(userDateFormat).parse(jsonDataNode["myFields"]["respondBy"]));
              } catch (e) {
                postDataNode["respondBy"] = jsonDataNode["myFields"]["respondBy"];
              }
            } else {
              postDataNode["respondBy"] = jsonDataNode["myFields"]["respondBy"];
            }
            jsonDataNode["myFields"].remove("respondBy");
          }
          var createHiddenListNode = jsonDataNode["myFields"]["create_hidden_list"];
          if (createHiddenListNode != null && createHiddenListNode is Map) {
            String attachmentKey = "attachedDocs";
            int iCounter = 0;
            List<String> attachmentValues = [];

            while (createHiddenListNode.containsKey("$attachmentKey$iCounter")) {
              String attachRevisionId = createHiddenListNode["$attachmentKey$iCounter"]?.toString() ?? "";
              if (offlineAttachmentList.containsKey(attachRevisionId)) {
                createHiddenListNode.remove("$attachmentKey$iCounter");
              } else {
                attachmentValues.add(attachRevisionId);
              }
              iCounter++;
            }

            if (attachmentValues.isNotEmpty) {
              postDataNode[attachmentKey] = attachmentValues.join(",");
            }

            postDataNode = ParserUtility.removeKeysFromMap(postDataNode, ["formAction", "msg_type_id", "msg_type_code"]);
            if (createHiddenListNode["formAction"] != null) {
              postDataNode["formAction"] = createHiddenListNode["formAction"];
              if (createHiddenListNode["msg_type_id"] != null) {
                postDataNode["msg_type_id"] = createHiddenListNode["msg_type_id"];
                if (createHiddenListNode["msg_type_code"] != null) {
                  postDataNode["msg_type_code"] = createHiddenListNode["msg_type_code"];
                }
                EFormMessageType eMsgType = EFormMessageType.fromString(postDataNode["msg_type_id"]?.toString() ?? "");
                if (eMsgType == EFormMessageType.ori) {
                  if ((createHiddenListNode["formAction"]?.toString() ?? "") == "edit") {
                    if (createHiddenListNode["msgId"] != null) {
                      postDataNode["msgId"] = createHiddenListNode["msgId"];
                    }
                  } else {
                    if (postDataNode.containsKey("formId")) {
                      postDataNode["offlineFormId"] = postDataNode["formId"];
                      postDataNode.remove("formId");
                    }
                    if (postDataNode.containsKey("observationId")) {
                      postDataNode.remove("observationId");
                    }
                    if (postDataNode.containsKey("parent_msg_id")) {
                      postDataNode.remove("parent_msg_id");
                    }
                  }
                } else {
                  if (createHiddenListNode["parent_msg_id"] != null) {
                    postDataNode["parent_msg_id"] = createHiddenListNode["parent_msg_id"];
                  }
                  if (createHiddenListNode["msgId"] != null) {
                    postDataNode["msgId"] = createHiddenListNode["msgId"];
                  }
                }
              }
              if (createHiddenListNode["editDraft"] != null) {
                postDataNode["editDraft"] = createHiddenListNode["editDraft"];
              }
              if (createHiddenListNode["editORI"] != null) {
                postDataNode["editORI"] = createHiddenListNode["editORI"];
              }
              if (postDataNode.containsKey("assocLocationSelection") && (postDataNode["assocLocationSelection"]?.toString() ?? "").isEmpty) {
                postDataNode.remove("assocLocationSelection");
                postDataNode["assocLocationSelection"] = createHiddenListNode["assocLocationSelection"];
              } /*else {
                if (createHiddenListNode.containsKey("assocLocationSelection") && (createHiddenListNode["assocLocationSelection"]?.toString() ?? "").isEmpty) {
                  postDataNode["assocLocationSelection"] = "{\"locationId\":\"${postDataNode["locationId"]}\",\"projectId\":\"${postDataNode["projectId"]}\",\"folderId\":\"115096348\"}";
                } else {
                  postDataNode["assocLocationSelection"] = createHiddenListNode["assocLocationSelection"];
                }
              }*/
            }
            (jsonDataNode["myFields"] as Map).remove("create_hidden_list");
          }
          postDataNode["offlineFormDataJson"] = jsonEncode(jsonDataNode);
          postDataNode = ParserUtility.removeKeysFromMap(postDataNode, ["projectIds", "checkHashing", "isResponseRequired"]);
          if ((postDataNode["parent_msg_id"]?.toString().plainValue() ?? "") == "0") {
            postDataNode.remove("parent_msg_id");
          }
        }
      } /*else {
        postDataNode = ParserUtility.removeKeysFromMap(postDataNode, ["projectIds", "checkHashing", "ASessionID"]);
        if (!postDataNode.containsKey("isDraft")) {
          postDataNode["isDraft"] = "false";
        }
        if (!postDataNode.containsKey("save_draft")) {
          postDataNode["save_draft"] = "0";
        }
        if (!postDataNode.containsKey("formAction")) {
          postDataNode["formAction"] = "create";
        }
        if (!postDataNode.containsKey("msg_type_id")) {
          postDataNode["msg_type_id"] = (postDataNode.containsKey("offlineFormId")) ? EFormMessageType.ori.value : EFormMessageType.res.value;
        }
        if (!postDataNode.containsKey("msg_type_code")) {
          postDataNode["msg_type_code"] = (postDataNode.containsKey("offlineFormId")) ? EFormMessageType.ori.name : EFormMessageType.res.name;
        }
      }*/
      int attachmentCounter = 0;

      await Future.forEach(offlineAttachmentList.entries, (MapEntry entry) async {
        String offlineFilePath = entry.value.toString().replaceAll("./../..", appBasePath);
        postDataNode["upFile$attachmentCounter"] = await MultipartFile.fromFile(offlineFilePath);
        attachmentCounter++;
      });
      if (offlineAttachmentList.isNotEmpty) {
        isUploadAttachmentInTemp = true;
      }
      postDataNode["isFromApps"] = "true";
      postDataNode["isFromAndroidApp"] = "true";
      postDataNode["applicationId"] = "3";
      postDataNode["isUploadAttachmentInTemp"] = isUploadAttachmentInTemp;

      if (postDataNode.containsKey("projectId")) {
        postDataNode["project_id"] = postDataNode["projectId"];
        postDataNode["projectIds"] = postDataNode["projectId"];
        postDataNode["checkHashing"] = "false";
        postDataNode.remove("projectId");
      }
    }
    return postDataNode;
  }

  Future<FormLocalDataSource> getDatabaseManager() async {
    FormLocalDataSource db = FormLocalDataSource();
    await db.init();
    return db;
  }

  Map<String, dynamic> _getRequestDataForMessageBatchList(SiteForm tmpForm, num? taskNumber) {
    Map<String, dynamic> formDataMap = {
      tmpForm.commId!.plainValue(): {
        "projectId": tmpForm.projectId!.plainValue(),
        "commId": tmpForm.commId!.plainValue(),
        "formTypeId": tmpForm.formTypeId!.plainValue(),
      },
    };
    Map<String, dynamic> requestData = {
      "resourceTypeId": "3",
      "isOriMsgId": "false",
      "formDataJson": jsonEncode(formDataMap),
      "networkExecutionType": NetworkExecutionType.SYNC,
      "taskNumber": taskNumber,
    };
    return requestData;
  }
}