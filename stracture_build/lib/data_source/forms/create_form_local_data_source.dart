import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:asite_plugins/asite_plugins.dart';
import 'package:field/data/dao/attribute_set_dao.dart';
import 'package:field/data/dao/form_dao.dart';
import 'package:field/data/dao/form_message_action_dao.dart';
import 'package:field/data/dao/form_message_attachAndAssoc_dao.dart';
import 'package:field/data/dao/form_message_dao.dart';
import 'package:field/data/dao/formtype_dao.dart';
import 'package:field/data/dao/manage_type_dao.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/form_message_attach_assoc_vo.dart';
import 'package:field/data/model/form_message_vo.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/offline_activity_vo.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/data_source/forms/form_local_data_source.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/file_form_utility.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../data/dao/form_status_history_dao.dart';
import '../../data/dao/location_dao.dart';
import '../../data/dao/offline_activity_dao.dart';
import '../../data/model/form_status_history_vo.dart';
import '../../data/model/site_location.dart';
import '../../logger/logger.dart';
import '../../utils/app_path_helper.dart';
import '../../utils/field_enums.dart';
import '../../utils/file_utils.dart';
import '../../utils/form_html_utility.dart';

class CreateFormLocalDataSource extends FormLocalDataSource {
  static CreateFormLocalDataSource? _instance;

  CreateFormLocalDataSource._();

  factory CreateFormLocalDataSource() => _instance ??= CreateFormLocalDataSource._();

  Future<String?> getCreateOrRespondHtmlJson(EHtmlRequestType eHtmlRequestType, Map<String, dynamic> paramData) async {
    String createHtmlData = "";
    switch (eHtmlRequestType) {
      case EHtmlRequestType.create:
        createHtmlData = await _getCreateHtmlFormData(paramData, eHtmlRequestType);
        break;
      case EHtmlRequestType.respond:
      case EHtmlRequestType.reply:
      case EHtmlRequestType.replyAll:
        createHtmlData = await _getReplyRespondHtmlFormData(paramData, eHtmlRequestType);
        break;
      case EHtmlRequestType.editDraft:
        createHtmlData = await editDraftHtmlFormData(paramData, eHtmlRequestType);
        break;
      case EHtmlRequestType.editAndDistribute:
        createHtmlData = await _getEditAndDistributeHtmlData(paramData, eHtmlRequestType);
        break;
      case EHtmlRequestType.editOri:
        createHtmlData = await _editOriHtmlFormData(paramData, eHtmlRequestType);
        break;
      default:
        break;
    }

    return createHtmlData;
  }

  Future<String> _getEditAndDistributeHtmlData(Map<String, dynamic> paramData, EHtmlRequestType eHtmlRequestType) async {
    String htmlData = "";
    try {
      String strProjectId = paramData["projectId"].toString().plainValue();
      String strFormTypeId = paramData["formTypeId"].toString().plainValue();
      String strFormId = paramData["formId"].toString().plainValue();
      String strParentMsgId = paramData["parent_msg_id"].toString().plainValue();
      String strMsgSubQuery = "(SELECT MAX(CAST(MsgId AS INTEGER)) FROM ${FormMessageDao.tableName} WHERE ProjectId=$strProjectId AND FormId=$strFormId AND MsgTypeId IN (1,3) AND IsDraft=0)";
      FormMessageVO? existFormMsgData = await getFormMessageVOFromDB(projectId: strProjectId, msgId: strMsgSubQuery, formId: strFormId);
      var strMsgId = existFormMsgData?.msgId.toString();
      var strLocationId = existFormMsgData?.locationId.toString();
      paramData["locationId"] = strLocationId;
      paramData["msgId"] = strMsgId;
      if (existFormMsgData != null) {
        String? strDataJsonFileData = existFormMsgData.jsonData;
        String strViewFileDir = await AppPathHelper().getAppDataFormTypeDirectory(projectId: strProjectId, formTypeId: strFormTypeId);
        String strViewFilePath = "${strViewFileDir}/ORI_VIEW.html";
        String strCustomAttributeViewName = "ORI_VIEW";
        // Logger::log("CFieldFormDatabaseManager::", std::string("getFieldCreateOrRespondHtmlJson EditOri strViewFilePath=").append(strViewFilePath));
        String? strHtmlFileData = await readDataFromFile(File(strViewFilePath));
        if (strHtmlFileData != "" && strDataJsonFileData != "") {
          strDataJsonFileData = await getHTML5ChangeSPDataInJsonData(EHtmlRequestType.editAndDistribute, strDataJsonFileData!, paramData);
          strDataJsonFileData = updateJsonDataForInlineAttachments(jsonDecode(strDataJsonFileData), (String strOldValue, String strKeyName) {
            return getFormMessageInlineAttachmentContentValue(FormMessageActionDao.tableName, strOldValue, strKeyName);
          });

          String strOriView = "<script type=\"text/javascript\">var isOriView=true</script></head>";
          strDataJsonFileData = strDataJsonFileData.replaceAll("\"", "&quot;");
          strHtmlFileData = strHtmlFileData?.replaceAll("<script attr=\"src=", "<script src=\"");
          strHtmlFileData = strHtmlFileData?.replaceAll("\${JSON_DATA}", strDataJsonFileData);
          User? loginUser = await user;
          Usersessionprofile? userSessionProfile = loginUser!.usersessionprofile;
          String? userId = userSessionProfile?.userID;
          String finalDBPathForHTML5 = "${await AppPathHelper().getAssetHTML5FormZipPath()}/ ${userId.toString().plainValue()}";
          // std::string finalDBPathForHTML5 = databasepath + "/" + Utils::deHashString(userId);
          strHtmlFileData = strHtmlFileData?.replaceAll("\${staticContentPath}", finalDBPathForHTML5);
          strHtmlFileData = strHtmlFileData?.replaceAll("\${TEMPLATE_JSON_DATA}", "");
          strHtmlFileData = strHtmlFileData?.replaceAll("\${DS_CLOSE_DUE_DATE}", "");
          strHtmlFileData = strHtmlFileData?.replaceAll("</head>", strOriView);
          String strCustomAttribute = await getFormTypeViewCustomAttributeData(projectId: strProjectId, formTypeId: strFormTypeId, viewName: strCustomAttributeViewName);
          if (strCustomAttribute != "") {
            strHtmlFileData = await addFormTypeCustomAttributeInHtml(strHtmlFileData!, strCustomAttribute, strProjectId, strFormTypeId);
          }
          String strSPAttribute = await getFormTypeViewFixFieldSPData(projectId: strProjectId, formTypeId: strFormTypeId, viewName: strCustomAttributeViewName);
          if (strSPAttribute != "") {
            strHtmlFileData = await addFormTypeSPDataInHtml(strHtmlFileData!, strSPAttribute, paramData, existFormMsgData.fixFieldData!);
          }
          String createHtmlFilePath = "${await AppPathHelper().getAssetHTML5FormZipPath()}/offlineCreateForm.html";
          var strCreateHtmlData = readFromFile(createHtmlFilePath);
          if (strCreateHtmlData.isNotEmpty) {
            var hiddenFieldMap = {"msg_type_id": EFormMessageType.fwd.value, "msg_type_code": EFormMessageType.fwd.name, "parent_msg_id": strParentMsgId, "dist_list": "", "formAction": "create", "assocLocationSelection": "", "project_id": strProjectId, "offlineProjectId": strProjectId, "offlineFormTypeId": strFormTypeId, "requestType": eHtmlRequestType.value};
            String htmlHiddenField = FormHtmlUtility().getHTMLHiddenFieldAttributeData(htmlAttributeMap: hiddenFieldMap);
            strCreateHtmlData = strCreateHtmlData.replaceAll("<div id=\"offlineCreateHiddenForm\"></div>", htmlHiddenField);
            strCreateHtmlData = strCreateHtmlData.replaceAll("<div id=\"sHtml\"></div>", strHtmlFileData ?? "");
            String strConfigData = await getOfflineConfigDataJson(paramData, EHtmlRequestType.editAndDistribute);
            if (strConfigData != "") {
              strConfigData = strConfigData.replaceAll("\\", "\\\\");
              strConfigData = strConfigData.replaceAll("\"", "\\\"");
              strCreateHtmlData = strCreateHtmlData.replaceAll("REPLACE_CONFIG_DATA", strConfigData);
            }
            htmlData = strCreateHtmlData;
          } else {
            htmlData = "offlineCreateForm.html reading error";
          }
        } else {
          htmlData = "File reading error";
        }
      } else {
        htmlData = "Draft reading error";
      }
    } catch (e) {
      Log.e("CFormDatabaseManager::", "EditAndDistributeHtmlData update JsonData exception:: $e");
    }
    return htmlData;
  }

  Future<String> _getCreateHtmlFormData(Map<String, dynamic> paramData, EHtmlRequestType eHtmlRequestType) async {
    String createHtmlData = "";
    String projectId = paramData["projectId"].toString().plainValue();
    String formTypeId = paramData["formTypeId"].toString().plainValue();
    String createFormFileDir = "${await AppPathHelper().getAppDataFormTypeDirectory(projectId: projectId, formTypeId: formTypeId)}/";
    String createFormPath = "${createFormFileDir}ORI_VIEW.html";
    String dataJsonPath = "${createFormFileDir}data.json";
    String customAttributeViewName = "ORI_VIEW";
    Log.d("CreateFormLocalDataSource::getCreateOrRespondHtmlJson Create strViewFilePath=$createFormPath");
    Log.d("CreateFormLocalDataSource::getCreateOrRespondHtmlJson Create strDataJsonFile=$dataJsonPath");
    String innerCreateHtmlFormData = readFromFile(createFormPath);
    String dataJsonFileData = readFromFile(dataJsonPath);
    if (innerCreateHtmlFormData.isNotEmpty && dataJsonFileData.isNotEmpty) {
      dataJsonFileData = await getHTML5ChangeSPDataInJsonData(EHtmlRequestType.create, dataJsonFileData, paramData);
      String oriView = "<script type=\"text/javascript\">var isOriView=true</script></head>";
      dataJsonFileData = dataJsonFileData.replaceAll("\"", "&quot;");
      innerCreateHtmlFormData = innerCreateHtmlFormData.replaceAll("<script attr=\"src=", "<script src=\"");
      innerCreateHtmlFormData = innerCreateHtmlFormData.replaceAll("\${JSON_DATA}", dataJsonFileData);
      innerCreateHtmlFormData = innerCreateHtmlFormData.replaceAll("\${staticContentPath}", createFormFileDir);
      innerCreateHtmlFormData = innerCreateHtmlFormData.replaceAll("</head>", oriView);
      String customAttribute = await getFormTypeViewCustomAttributeData(formTypeId: formTypeId, projectId: projectId, viewName: customAttributeViewName);
      if (customAttribute.isNotEmpty) {
        innerCreateHtmlFormData = await addFormTypeCustomAttributeInHtml(innerCreateHtmlFormData, customAttribute, projectId, formTypeId);
      }
      String sPAttribute = await getFormTypeViewFixFieldSPData(formTypeId: formTypeId, projectId: projectId, viewName: customAttributeViewName);
      if (sPAttribute.isNotEmpty) {
        innerCreateHtmlFormData = await addFormTypeSPDataInHtml(innerCreateHtmlFormData, sPAttribute, paramData, "");
      }
      String createHtmlFilePath = "${await AppPathHelper().getAssetHTML5FormZipPath()}/offlineCreateForm.html";
      createHtmlData = readFromFile(createHtmlFilePath);
      if (createHtmlData.isNotEmpty) {
        var hiddenFieldMap = {"msg_type_id": EFormMessageType.ori.value.toString(), "msg_type_code": EFormMessageType.ori.name, "dist_list": "", "formAction": "create", "project_id": projectId, "offlineProjectId": projectId, "offlineFormTypeId": formTypeId, "assocLocationSelection": "", "requestType": eHtmlRequestType.value};
        String annotationId = paramData["annotationId"]?.toString() ?? "";
        String coordinates = paramData["coordinates"]?.toString() ?? "";
        if (annotationId.isNotEmpty) {
          hiddenFieldMap["annotationId"] = annotationId;
        }
        if (coordinates.isNotEmpty) {
          hiddenFieldMap["coordinates"] = coordinates;
        }
        String htmlHiddenField = FormHtmlUtility().getHTMLHiddenFieldAttributeData(htmlAttributeMap: hiddenFieldMap);
        createHtmlData = createHtmlData.replaceAll("<div id=\"offlineCreateHiddenForm\"></div>", htmlHiddenField);
        createHtmlData = createHtmlData.replaceAll("<div id=\"sHtml\"></div>", innerCreateHtmlFormData);
        String configData = await getOfflineConfigDataJson(paramData, EHtmlRequestType.create);
        if (configData.isNotEmpty) {
          configData = configData.replaceAll("\\", "\\\\");
          configData = configData.replaceAll("\"", "\\\"");
          createHtmlData = createHtmlData.replaceAll("REPLACE_CONFIG_DATA", configData);
        }
      }
    }
    return createHtmlData;
  }

  Future<String> editDraftHtmlFormData(Map<String, dynamic> paramData, EHtmlRequestType eHtmlRequestType) async {
    String editDraftHtmlData = "";

    try {
      var strProjectId = paramData["projectId"].toString();
      var strMsgId = paramData["msgId"].toString();
      var strFormId = paramData["formId"].toString();
      FormMessageVO? frmMsgVo = await getFormMessageVOFromDB(projectId: strProjectId, formId: strFormId, msgId: strMsgId);
      if (frmMsgVo != null) {
        var strFormTypeId = frmMsgVo.formTypeId.toString();
        var strLocationId = frmMsgVo.locationId.toString();
        var strObservationId = frmMsgVo.observationId.toString();
        paramData["formTypeId"] = strFormTypeId;
        paramData["locationId"] = strLocationId;
        paramData["observationId"] = strObservationId;
        var strDataJsonFileData = frmMsgVo.jsonData.toString();

        String strViewFileDir = "${await AppPathHelper().getAppDataFormTypeDirectory(projectId: strProjectId, formTypeId: strFormTypeId)}/";
        String strViewFilePath = "${strViewFileDir}RES_VIEW.html";
        var strCustomAttributeViewName = "RES_VIEW";

        var strParentMsgId = frmMsgVo.parentMsgId;
        if (frmMsgVo.msgTypeId == "1" || frmMsgVo.msgTypeId == "3") {
          strViewFilePath = "${strViewFileDir}ORI_VIEW.html";
          strCustomAttributeViewName = "ORI_VIEW";
        }
        Log.e("CFieldFormDatabaseManager::", "_editDraftHtmlFormData strViewFilePath= $strViewFilePath");

        String innerCreateHtmlFormData = readFromFile(strViewFilePath);

        if (!innerCreateHtmlFormData.isNullOrEmpty() && !strDataJsonFileData.isNullOrEmpty()) {
          strDataJsonFileData = await getHTML5ChangeSPDataInJsonData(EHtmlRequestType.editDraft, strDataJsonFileData, paramData);

          strDataJsonFileData = updateJsonDataForInlineAttachments(jsonDecode(strDataJsonFileData), (String strOldValue, String strKeyName) {
            return getFormMessageInlineAttachmentContentValue(FormMessageAttachAndAssocDao.tableName, strOldValue, strKeyName);
          });
          String strOriView = "<script type=\"text/javascript\">var isOriView=true</script></head>";
          strDataJsonFileData = strDataJsonFileData.replaceAll("\"", "&quot;");
          innerCreateHtmlFormData = innerCreateHtmlFormData.replaceAll("<script attr=\"src=", "<script src=\"");
          innerCreateHtmlFormData = innerCreateHtmlFormData.replaceAll("\${JSON_DATA}", strDataJsonFileData);
          innerCreateHtmlFormData = innerCreateHtmlFormData.replaceAll("\${staticContentPath}", strViewFileDir);
          innerCreateHtmlFormData = innerCreateHtmlFormData.replaceAll("</head>", strOriView);

          String customAttribute = await getFormTypeViewCustomAttributeData(formTypeId: strFormTypeId, projectId: strProjectId, viewName: strCustomAttributeViewName);
          if (customAttribute.isNotEmpty) {
            innerCreateHtmlFormData = await addFormTypeCustomAttributeInHtml(innerCreateHtmlFormData, customAttribute, strProjectId, strFormTypeId);
          }
          String sPAttribute = await getFormTypeViewFixFieldSPData(formTypeId: strFormTypeId, projectId: strProjectId, viewName: strCustomAttributeViewName);
          if (sPAttribute.isNotEmpty) {
            innerCreateHtmlFormData = await addFormTypeSPDataInHtml(innerCreateHtmlFormData, sPAttribute, paramData, frmMsgVo.fixFieldData!);
          }
          String createHtmlFilePath = "${await AppPathHelper().getAssetHTML5FormZipPath()}/offlineCreateForm.html";
          editDraftHtmlData = readFromFile(createHtmlFilePath);
          if (editDraftHtmlData.isNotEmpty) {
            var hiddenFieldMap = {"msg_type_id": frmMsgVo.msgTypeId, "msg_type_code": frmMsgVo.msgTypeCode, "parent_msg_id": strParentMsgId, "dist_list": "", "assocLocationSelection": "", "project_id": strProjectId, "offlineProjectId": strProjectId, "offlineFormTypeId": strFormTypeId, "editORI": "false", "requestType": eHtmlRequestType.value};
            if (strMsgId != "" && strMsgId != "0") {
              hiddenFieldMap["msgId"] = strMsgId;
            }
            if (frmMsgVo.isOfflineCreated == true) {
              hiddenFieldMap["formAction"] = "create";
              hiddenFieldMap["editDraft"] = "false";
            } else {
              hiddenFieldMap["formAction"] = "edit";
              hiddenFieldMap["editDraft"] = "true";
            }
            if (frmMsgVo.msgHasAssocAttach == true) {
              String strQuery = "SELECT AttachmentType, count(*) AS TotalCount FROM ${FormMessageAttachAndAssocDao.tableName}";
              strQuery = "$strQuery WHERE ProjectId=$strProjectId AND FormId=$strFormId";
              strQuery = "$strQuery AND MsgId=$strMsgId GROUP BY AttachmentType";
              var mapAttachAssocList = databaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strQuery);
              for (var attachItem in mapAttachAssocList) {
                EAttachmentAndAssociationType eAttachType = EAttachmentAndAssociationType.fromNumber(int.parse(attachItem["AttachmentType"] ?? "-1"));
                switch (eAttachType) {
                  case EAttachmentAndAssociationType.files:
                    if ((int.parse(attachItem["TotalCount"].toString())) > 0) {
                      hiddenFieldMap["assocDocSelection"] = "true";
                    }
                    break;
                  case EAttachmentAndAssociationType.discussions:
                    if ((int.parse(attachItem["TotalCount"].toString())) > 0) {
                      hiddenFieldMap["assocCommentSelection"] = "true";
                    }
                    break;
                  default:
                    break;
                }
              }
            }
            String htmlHiddenField = FormHtmlUtility().getHTMLHiddenFieldAttributeData(htmlAttributeMap: hiddenFieldMap);
            editDraftHtmlData = editDraftHtmlData.replaceAll("<div id=\"offlineCreateHiddenForm\"></div>", htmlHiddenField);
            editDraftHtmlData = editDraftHtmlData.replaceAll("<div id=\"sHtml\"></div>", innerCreateHtmlFormData);
            String strConfigData = await getOfflineConfigDataJson(paramData, EHtmlRequestType.editDraft);
            if (strConfigData != "") {
              strConfigData = strConfigData.replaceAll("\\", "\\\\");
              strConfigData = strConfigData.replaceAll("\"", "\\\"");
              editDraftHtmlData = editDraftHtmlData.replaceAll("REPLACE_CONFIG_DATA", strConfigData);
            }
          }
        }
      }
    } catch (e) {
      Log.e("CFormDatabaseManager::", "editDraftHtmlFormData update JsonData exception:: $e");
    }
    return editDraftHtmlData;
  }

  Future<Map<String, dynamic>> saveFormOffline(Map<String, dynamic> paramData) async {
    Map<String, dynamic> response = {};
    bool isDistribute = false, autoPublishToFolder = false, isNeedToUpdateAttachAssoc = false;
    bool isRemoveAttachment = false;
    List<FormMessageVO> formMessageList = [];
    List<SiteForm> formList = [];
    List<FormMessageAttachAndAssocVO> formAttachList = [];
    List<String> vecInlineAttachRevIdList = [];
    SiteForm tmpOfflineFormData = await parseJsonDataToFormVo(paramData);
    paramData["offlineFormCreatedDateInMS"] = tmpOfflineFormData.formCreationDateInMS.toString();
    String strDateFormat = await Utility.getUserDateFormat();
    paramData["userDateFormat"] = strDateFormat;
    AppType? appType = await getFormTypeVOFromDB(projectId: tmpOfflineFormData.projectId!, formTypeId: tmpOfflineFormData.formTypeId!);
    if (appType != null) {
      tmpOfflineFormData.formTypeCode ??= appType.code;
      tmpOfflineFormData.formTypeName ??= appType.formTypeName;
      tmpOfflineFormData.instanceGroupId = appType.instanceGroupId;
      tmpOfflineFormData.appTypeId = appType.appTypeId;
      tmpOfflineFormData.code = appType.code;
      tmpOfflineFormData.templateType = appType.templateType;
      tmpOfflineFormData.appBuilderId = appType.appBuilderCode;
      if ((tmpOfflineFormData.isDraft ?? false) == false) {
        autoPublishToFolder = appType.isAutoPublishToFolder();
      }
    }
    SiteForm? existFormData = await getFormVOFromDB(projectId: tmpOfflineFormData.projectId!, formId: tmpOfflineFormData.formId!);
    if (existFormData != null) {
      String strMsgDescription = "";
      String strMsgCreatedDateOffline = "";
      paramData["formTypeCode"] = existFormData.formTypeCode ?? tmpOfflineFormData.formTypeCode;
      paramData["formTypeName"] = existFormData.formTypeName ?? tmpOfflineFormData.formTypeName;
      paramData["instanceGroupId"] = (existFormData.instanceGroupId ?? tmpOfflineFormData.instanceGroupId)?.plainValue();
      paramData["observationId"] = existFormData.observationId;
      // paramData["revisionId"] = existFormData.revisionId;
      existFormData.controllerUserId = tmpOfflineFormData.controllerUserId;
      if (tmpOfflineFormData.templateType.isXSN || tmpOfflineFormData.eHtmlRequestType == EHtmlRequestType.editOri || (int.parse(tmpOfflineFormData.msgTypeId.toString()) == 3 && !(tmpOfflineFormData.isDraft ?? false)) || (int.parse(existFormData.msgTypeId.toString())) == 1 && (existFormData.isDraft ?? false)) {
        existFormData.title = tmpOfflineFormData.title;
      }
      if (int.parse(existFormData.msgTypeId.toString()) == 1 && (existFormData.isDraft ?? false) && (tmpOfflineFormData.isDraft == false)) {
        existFormData.code = tmpOfflineFormData.code;
      }
      if ((existFormData.isOfflineCreated ?? false) && (existFormData.locationId ?? 0) != 0) {
        paramData["locationId"] = existFormData.locationId;
        paramData["coordinates"] = existFormData.observationCoordinates;
        paramData["annotationId"] = existFormData.annotationId;
        paramData["page_number"] = existFormData.pageNumber;
      }
      FormMessageVO? frmMsgVo;
      if (!tmpOfflineFormData.msgId.isNullEmptyZeroOrFalse()) {
        Log.d("CreateFormLocalDataSource:: saveFormOffline MessageId= ${tmpOfflineFormData.msgId}");
        frmMsgVo = await getFormMessageVOFromDB(projectId: tmpOfflineFormData.projectId.toString(), formId: tmpOfflineFormData.formId.toString(), msgId: tmpOfflineFormData.msgId.toString());
        if (frmMsgVo != null) {
          if (frmMsgVo.isDraft! && frmMsgVo.msgHasAssocAttach!) {
            isRemoveAttachment = true;
          }
          if ((int.parse(existFormData.msgTypeId.toString()) == 1 || int.parse(existFormData.msgTypeId.toString()) == 3) && frmMsgVo.offlineRequestData != "" && !(tmpOfflineFormData.isDraft ?? false)) {
            existFormData.title = tmpOfflineFormData.title;
          }

          if (frmMsgVo.msgTypeId == EFormMessageType.ori.value.toString() && tmpOfflineFormData.msgTypeId == EFormMessageType.ori.value.toString()) {
            tmpOfflineFormData.msgCode = frmMsgVo.msgCode;
            if ((frmMsgVo.isDraft! || (frmMsgVo.isOfflineCreated ?? false)) && !paramData.containsKey("assocLocationSelection")) {
              var assocLocationSelectionData = {
                "locationId": frmMsgVo.locationId,
                "projectId": frmMsgVo.projectId,
                //"folderId": frmMsgVo.folderId,
              };
              paramData["assocLocationSelection"] = jsonEncode(assocLocationSelectionData);
            }
          }
          frmMsgVo.setResponseRequestBy = tmpOfflineFormData.responseRequestBy;
        }
        if (tmpOfflineFormData.templateType.isHTML) {
          isNeedToUpdateAttachAssoc = autoPublishToFolder;
          isRemoveAttachment = true;
          String strDelFormIds = frmMsgVo?.delFormIds ?? "";
          try {
            var myFieldsNode = paramData["offlineFormDataJson"];
            String strLocalDelFormIds = myFieldsNode["myFields"]["create_hidden_list"]["delformIds"] ?? "";
            if (!strLocalDelFormIds.isNullOrEmpty()) {
              if (!strDelFormIds.isNullOrEmpty()) {
                strDelFormIds = "$strDelFormIds,";
              }
              strDelFormIds = strDelFormIds + strLocalDelFormIds;
            }
          } catch (_) {}
          frmMsgVo?.setDelFormIds = strDelFormIds;
        }
      } else {
        tmpOfflineFormData.msgId = tmpOfflineFormData.updatedDateInMS;

        existFormData.instanceGroupId = tmpOfflineFormData.instanceGroupId;
        //existFormData.MsgCode(tmpOfflineFormData->getMsgCode());
        existFormData.msgId = tmpOfflineFormData.msgId;
        existFormData.parentMsgId = tmpOfflineFormData.parentMsgId;
        frmMsgVo = FormMessageVO();
        frmMsgVo.setAppTypeId = existFormData.appTypeId.toString();
        frmMsgVo.setProjectId = existFormData.projectId;
        frmMsgVo.setFormTypeId = existFormData.formTypeId;
        frmMsgVo.setFormId = existFormData.formId;
        frmMsgVo.setLocationId = existFormData.locationId.toString();
        frmMsgVo.setObservationId = existFormData.observationId.toString();
        frmMsgVo.setMsgId = existFormData.msgId;
        frmMsgVo.setParentMsgId = existFormData.parentMsgId;
        frmMsgVo.setIsOfflineCreated = true;
        frmMsgVo.setResponseRequestBy = tmpOfflineFormData.responseRequestBy;

        String strMsgCodeQry = "SELECT * FROM ";
        strMsgCodeQry = "$strMsgCodeQry${FormMessageDao.tableName} WHERE ProjectId=${tmpOfflineFormData.projectId.plainValue()}";
        strMsgCodeQry = "$strMsgCodeQry AND FormId=${tmpOfflineFormData.formId!} AND MsgTypeId=${tmpOfflineFormData.msgTypeId!}";

        var mapFormMsgList = databaseManager.executeSelectFromTable(FormMessageDao.tableName, strMsgCodeQry);
        String strTmpCode = (mapFormMsgList.length + 1).toString();
        switch (strTmpCode.length) {
          case 1:
            {
              strTmpCode = "00$strTmpCode";
            }
            break;
          case 2:
            {
              strTmpCode = "0$strTmpCode";
            }
            break;
          default:
            break;
        }

        String strTmpMsgCode = tmpOfflineFormData.msgTypeCode! + strTmpCode;

        frmMsgVo.setMsgCode = strTmpMsgCode;
        existFormData.msgCode = strTmpMsgCode;
        tmpOfflineFormData.msgCode = strTmpMsgCode;
        if (tmpOfflineFormData.isDraft ?? false) {
          FormMessageVO? existFormMsgData = await getFormMessageVOFromDB(projectId: frmMsgVo.projectId.toString(), formId: frmMsgVo.formId.toString(), msgId: frmMsgVo.msgId.toString());
          existFormMsgData?.setLatestDraftId = frmMsgVo.msgId;
          if (existFormMsgData != null) {
            formMessageList.add(existFormMsgData);
          }
        }
      }
      String strStatusData = "";
      bool bIsStatusReq = false;
      if (existFormData.templateType.isHTML) {
        var offlineFormDataJsonNode = jsonDecode(paramData["offlineFormDataJson"]);
        String strStatusId = "", strStatusName = "";
        if (tmpOfflineFormData.isDraft!) {
          strStatusId = existFormData.statusid ?? "";
          strStatusName = existFormData.statusName ?? "";
        } else {
          try {
            strStatusData = offlineFormDataJsonNode["myFields"]["Asite_System_Data_Read_Only"]["_5_Form_Data"]["Status_Data"]["DS_ALL_FORMSTATUS"]; //"1001 # Open",
            bIsStatusReq = true;
          } catch (_) {
            strStatusId = existFormData.statusid ?? "";
            strStatusName = existFormData.statusName ?? "";
          }
        }
        existFormData.statusid = strStatusId;
        existFormData.statusName = strStatusName;
        switch (EFormMessageType.fromString(tmpOfflineFormData.msgTypeId?.toString() ?? "")) {
          case EFormMessageType.ori:
          case EFormMessageType.fwd:
            try {
              if (offlineFormDataJsonNode["myFields"]?["FORM_CUSTOM_FIELDS"]?["ORI_MSG_Custom_Fields"]?["DefectDescription"] != null) {
                strMsgDescription = offlineFormDataJsonNode["myFields"]["FORM_CUSTOM_FIELDS"]["ORI_MSG_Custom_Fields"]["DefectDescription"];
              }
              if (strMsgDescription.isEmpty) {
                if (offlineFormDataJsonNode["myFields"]?["FORM_CUSTOM_FIELDS"]?["ORI_MSG_Custom_Fields"]?["Defect_Description"] != null) {
                  strMsgDescription = offlineFormDataJsonNode["myFields"]["FORM_CUSTOM_FIELDS"]["ORI_MSG_Custom_Fields"]["Defect_Description"];
                } else if (offlineFormDataJsonNode["myFields"]?["FORM_CUSTOM_FIELDS"]?["RES_MSG_Custom_Fields"]?["Defect_Description"] != null) {
                  strMsgDescription = offlineFormDataJsonNode["myFields"]["FORM_CUSTOM_FIELDS"]["RES_MSG_Custom_Fields"]["Defect_Description"];
                }
              }
            } catch (_) {}
            break;
          default:
            if (offlineFormDataJsonNode["myFields"]?["FORM_CUSTOM_FIELDS"]?["RES_MSG_Custom_Fields"]?["Comments"] != null) {
              strMsgDescription = offlineFormDataJsonNode["myFields"]["FORM_CUSTOM_FIELDS"]["RES_MSG_Custom_Fields"]["Comments"];
            }
            break;
        }
      } /*else {
        var formJsonNode = jsonDecode(paramData["offlineFormDataJson"]);
        try {
          strStatusData = formJsonNode["xdoc_0_1_4_17_5_my:DS_ALL_FORMSTATUS"];
          bIsStatusReq = true;
        } catch (_) {}
        try {
          strMsgDescription = formJsonNode["xdoc_0_1_4_11_my:DS_FORMCONTENT"]; // offline test msg
        } catch (_) {}
        try {
          strMsgCreatedDateOffline = formJsonNode["xdoc_0_0_0_20_my:FormCreationDate"];
        } catch (_) {}
      }*/
      if (bIsStatusReq) {
        List<String> formStatusDataList = strStatusData.split('#');
        if (formStatusDataList.length < 2) {
          Log.d("CreateFormLocalDataSource:: saveFieldFormDetailOffline status not found in json data");
          throw "status not found";
        }
        existFormData.statusid = formStatusDataList[0].toString().trim();
        existFormData.statusName = formStatusDataList[1].toString().trim();
      }
      existFormData.status = existFormData.statusName;
      frmMsgVo?.setMsgOriginDisplayOrgName = tmpOfflineFormData.orgName;
      frmMsgVo?.setMsgOriginDisplayUserName = tmpOfflineFormData.originatorDisplayName;
      String strMsgQuery = "SELECT * FROM ${FormMessageDao.tableName} WHERE ProjectId=${tmpOfflineFormData.projectId.toString()}";
      strMsgQuery = "$strMsgQuery AND FormId=${tmpOfflineFormData.formId.toString()} AND MsgTypeId=${tmpOfflineFormData.msgTypeId.toString()}";
      var mapFormMsgList = databaseManager.executeSelectFromTable(FormMessageDao.tableName, strMsgQuery);
      if (!(frmMsgVo!.isDraft ?? false) || frmMsgVo.msgNum.isNullOrEmpty()) {
        frmMsgVo.setMsgNum = (mapFormMsgList.length + 1).toString();
      }
      existFormData.msgTypeId = tmpOfflineFormData.msgTypeId;
      existFormData.msgTypeCode = tmpOfflineFormData.msgTypeCode;
      existFormData.msgOriginatorId = tmpOfflineFormData.msgOriginatorId;
      existFormData.updated = tmpOfflineFormData.updated;
      existFormData.updatedDateInMS = tmpOfflineFormData.updatedDateInMS;
      if (EFormMessageType.fromString(existFormData.msgTypeId?.toString() ?? "") == EFormMessageType.ori) {
        existFormData.isDraft = tmpOfflineFormData.isDraft;
      }
      frmMsgVo.setIsDraft = tmpOfflineFormData.isDraft;
      frmMsgVo.setMsgContent = strMsgDescription;
      frmMsgVo.setMsgCreatedDateOffline = strMsgCreatedDateOffline;
      frmMsgVo.setHasAttach = tmpOfflineFormData.isUploadAttachmentInTemp;
      frmMsgVo.setMsgCreatedDate = existFormData.updated;
      frmMsgVo.setMsgOriginatorId = existFormData.msgOriginatorId.toString();
      frmMsgVo.setMsgHasAssocAttach = tmpOfflineFormData.isUploadAttachmentInTemp;
      frmMsgVo.setJsonData = tmpOfflineFormData.formJsonData;
      frmMsgVo.setUpdatedDateInMS = existFormData.updatedDateInMS;
      frmMsgVo.setFormCreationDateInMS = existFormData.updatedDateInMS;
      frmMsgVo.setMsgCreatedDateInMS = existFormData.updatedDateInMS;
      if (tmpOfflineFormData.msgId != "" && frmMsgVo.msgTypeId == "2") {
      } else {
        frmMsgVo.setMsgTypeId = existFormData.msgTypeId;
        frmMsgVo.setMsgTypeCode = existFormData.msgTypeCode;
      }
      frmMsgVo.setMsgStatusId = "20"; // 19 - Draft, 20 - Form
      if (tmpOfflineFormData.isDraft!) {
        frmMsgVo.setMsgStatusId = "19"; // 19 - Draft, 20 - Form
      }
      try {
        var myFieldsNode = jsonDecode(paramData["offlineFormDataJson"]);

        if (EFormMessageType.fromString(existFormData.msgTypeId?.toString() ?? "") == EFormMessageType.ori) {
          try {
            frmMsgVo.setResponseRequestBy = myFieldsNode["myFields"]["respondBy"];
          } catch (_) {}
        }
        String strSentNames = "", strUserActionJson = "";
        isDistribute = await getFormDistributionDataFromDistList(
            projectId: tmpOfflineFormData.projectId!,
            formTypeId: tmpOfflineFormData.formTypeId!,
            jsonData: paramData["offlineFormDataJson"].toString(),
            onReturnReferences: (String sentNames, String userActionJson) {
              strSentNames = sentNames;
              strUserActionJson = userActionJson;
            });
        if (frmMsgVo.isDraft!) {
          frmMsgVo.setDraftSentActions = strUserActionJson;
        } else {
          frmMsgVo.setSentActions = strUserActionJson;
          frmMsgVo.setSentNames = strSentNames;
        }
      } catch (_) {}
      String requestFilePath = await AppPathHelper().getOfflineRequestDataFilePath(projectId: frmMsgVo.projectId ?? "", msgId: frmMsgVo.msgId ?? "");
      await writeDataToFile(requestFilePath, jsonEncode(paramData));
      frmMsgVo.setOfflineRequestData = "1";
      try {
        String strOfflineJsonData = paramData["offlineFormDataJson"];
        frmMsgVo.setJsonData = strOfflineJsonData; //No need for Defect-XSN form
      } catch (_) {}

      if (tmpOfflineFormData.templateType.isHTML) {
        String strMsgJsonData = paramData["offlineFormDataJson"] ?? "";
        String strAttachmentPath = await AppPathHelper().getAttachmentDirectory(projectId: tmpOfflineFormData.projectId.toString());
        strMsgJsonData = await getInlineAttachmentListFromJsonData(strMsgJsonData, tmpOfflineFormData.appBuilderId ?? "", strAttachmentPath, tmpOfflineFormData, autoPublishToFolder, (List<FormMessageAttachAndAssocVO> inlineAttachList, List<String> inlineAttachRevIdList) {
          if (inlineAttachList.isNotEmpty) {
            formAttachList.addAll(inlineAttachList);
          }
          if (inlineAttachRevIdList.isNotEmpty) {
            vecInlineAttachRevIdList = inlineAttachRevIdList;
          }
        });

        frmMsgVo.setJsonData = strMsgJsonData;
      }
      formMessageList.add(frmMsgVo);
      if (frmMsgVo.msgHasAssocAttach == false) {
        String selectQuery = "SELECT * FROM ";
        selectQuery = "$selectQuery${FormMessageAttachAndAssocDao.tableName} WHERE ProjectId=${existFormData.projectId.toString()}";
        selectQuery = "$selectQuery AND FormId=${existFormData.formId}";
        selectQuery = "$selectQuery AND MsgId<>${frmMsgVo.msgId}";

        Log.d("CreateFormLocalDataSource:: saveFieldFormDetailOffline Attach selectQuery=$selectQuery");
        var mapSize = databaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, selectQuery);
        Log.d("CreateFormLocalDataSource:: saveFieldFormDetailOffline msgSize=${mapSize.length}");

        if (mapSize.isEmpty) {
          existFormData.isUploadAttachmentInTemp = false;
          existFormData.formHasAssocAttach = false;
        }
      }
      if (existFormData.isUploadAttachmentInTemp == false || existFormData.formHasAssocAttach == false) {
        existFormData.isUploadAttachmentInTemp = tmpOfflineFormData.isUploadAttachmentInTemp;
        existFormData.formHasAssocAttach = tmpOfflineFormData.isUploadAttachmentInTemp;
        existFormData.hasAttachments = tmpOfflineFormData.isUploadAttachmentInTemp;
      }
      existFormData.formJsonData = "";
      formList.add(existFormData);
    } else {
      tmpOfflineFormData.msgId = tmpOfflineFormData.updatedDateInMS;
      tmpOfflineFormData.hasAttachments = tmpOfflineFormData.isUploadAttachmentInTemp;
      tmpOfflineFormData.formHasAssocAttach = tmpOfflineFormData.isUploadAttachmentInTemp;
      String strStatusData = "", strMsgDescription = "", strMsgCreatedDateOffline = "";
      bool bIsStatusReq = false;
      if (tmpOfflineFormData.templateType.isHTML) {
        var offlineFormDataJsonNode = jsonDecode(paramData["offlineFormDataJson"]);
        String strStatusId = "", strStatusName = "";
        if (tmpOfflineFormData.isDraft!) {
          strStatusId = "2";
          strStatusName = "Open";
        } else {
          try {
            strStatusData = offlineFormDataJsonNode["myFields"]["Asite_System_Data_Read_Only"]["_5_Form_Data"]["Status_Data"]["DS_ALL_FORMSTATUS"]; //"1001 # Open",
            bIsStatusReq = true;
          } catch (_) {}
        }
        tmpOfflineFormData.statusid = strStatusId;
        tmpOfflineFormData.statusName = strStatusName;
        try {
          var ORI_MSG_Custom_FieldsNode = offlineFormDataJsonNode["myFields"]["FORM_CUSTOM_FIELDS"]["ORI_MSG_Custom_Fields"];
          strMsgDescription = ORI_MSG_Custom_FieldsNode["Defect_Description"];
        } catch (_) {}
      } /*else {
        String strFormJsonData = "";
        try {
          strFormJsonData = paramData["offlineFormDataJson"];
        } catch (_) {}
        var formJsonNode = jsonDecode(strFormJsonData);
        try {
          strStatusData = formJsonNode["xdoc_0_1_4_17_5_my:DS_ALL_FORMSTATUS"]; // 1003 # Open
          bIsStatusReq = true;
        } catch (_) {}
        try {
          strMsgDescription = formJsonNode["xdoc_0_1_4_12_my:DS_FORMCONTENT1"]; // offline test msg
        } catch (_) {}
        try {
          strMsgCreatedDateOffline = formJsonNode["xdoc_0_0_0_20_my:FormCreationDate"];
        } catch (_) {}
      }*/
      if (bIsStatusReq) {
        List<String> formStatusDataList = strStatusData.split('#');
        if (formStatusDataList.length < 2) {
          Log.d("CreateFormLocalDataSource:: saveFieldFormDetailOffline status not found in json data");
          throw "status not found";
        }
        tmpOfflineFormData.statusid = formStatusDataList[0].toString().trim();
        tmpOfflineFormData.statusName = formStatusDataList[1].toString().trim();
      }
      tmpOfflineFormData.status = tmpOfflineFormData.statusName;
      if (!tmpOfflineFormData.observationDefectType.isNullOrEmpty()) {
        String strManageTypeQuery = "SELECT ManageTypeId FROM ${ManageTypeDao.tableName} WHERE ProjectId=${tmpOfflineFormData.projectId} AND";
        strManageTypeQuery = "$strManageTypeQuery ManageTypeName='${tmpOfflineFormData.observationDefectType}'";
        Log.d("CreateFormLocalDataSource:: saveFieldFormDetailOffline strManageTypeQuery=$strManageTypeQuery");
        var mapManageTypeList = databaseManager.executeSelectFromTable(ManageTypeDao.tableName, strManageTypeQuery);
        Log.d("CreateFormLocalDataSource:: saveFieldFormDetailOffline mapManageTypeList size=${mapManageTypeList.length}");
        if (mapManageTypeList.isNotEmpty) {
          tmpOfflineFormData.observationDefectTypeId = mapManageTypeList[0]["ManageTypeId"];
        }
      }
      tmpOfflineFormData.orgId = "0";
      tmpOfflineFormData.noOfActions = 0;
      tmpOfflineFormData.msgNum = 0;
      tmpOfflineFormData.msgCode = "${tmpOfflineFormData.msgTypeCode}001";
      tmpOfflineFormData.isActive = true;
      tmpOfflineFormData.isMarkOffline = true;
      tmpOfflineFormData.canRemoveOffline = false;
      FormMessageVO frmMsgVo = FormMessageVO();

      frmMsgVo.setAppTypeId = tmpOfflineFormData.appTypeId.toString();
      frmMsgVo.setProjectId = tmpOfflineFormData.projectId;
      frmMsgVo.setFormTypeId = tmpOfflineFormData.formTypeId;
      frmMsgVo.setFormId = tmpOfflineFormData.formId;
      frmMsgVo.setLocationId = tmpOfflineFormData.locationId.toString();
      frmMsgVo.setObservationId = tmpOfflineFormData.observationId.toString();
      frmMsgVo.setMsgId = tmpOfflineFormData.msgId;
      frmMsgVo.setMsgOriginDisplayUserName = tmpOfflineFormData.originatorDisplayName;
      frmMsgVo.setMsgOriginDisplayOrgName = tmpOfflineFormData.orgName;
      frmMsgVo.setOriginUserId = tmpOfflineFormData.originatorId;
      frmMsgVo.setMsgCreatedDate = tmpOfflineFormData.updated;
      frmMsgVo.setMsgOriginatorId = tmpOfflineFormData.originatorId;
      frmMsgVo.setParentMsgId = tmpOfflineFormData.parentMsgId;
      frmMsgVo.setMsgHasAssocAttach = tmpOfflineFormData.isUploadAttachmentInTemp;
      frmMsgVo.setHasAttach = tmpOfflineFormData.hasAttachments;
      frmMsgVo.setUpdatedDateInMS = tmpOfflineFormData.updatedDateInMS;
      frmMsgVo.setFormCreationDateInMS = tmpOfflineFormData.updatedDateInMS;
      frmMsgVo.setMsgCreatedDateInMS = tmpOfflineFormData.updatedDateInMS;
      frmMsgVo.setMsgTypeId = tmpOfflineFormData.msgTypeId;
      frmMsgVo.setMsgTypeCode = tmpOfflineFormData.msgTypeCode;
      frmMsgVo.setMsgCode = tmpOfflineFormData.msgCode;
      frmMsgVo.setInstanceGroupId = tmpOfflineFormData.instanceGroupId;
      frmMsgVo.setMsgCreatedDateOffline = ""; // to do
      frmMsgVo.setTotalActions = "0";
      frmMsgVo.setMsgNum = "1";
      frmMsgVo.setMsgStatusId = "20"; // 19 - Draft, 20 - Form
      frmMsgVo.setIsOfflineCreated = true;
      frmMsgVo.setIsDraft = tmpOfflineFormData.isDraft!;
      frmMsgVo.setResponseRequestBy = tmpOfflineFormData.responseRequestBy;
      if (tmpOfflineFormData.isDraft!) {
        frmMsgVo.setMsgStatusId = "19"; // 19 - Draft, 20 - Form
      }
      frmMsgVo.setMsgContent = strMsgDescription;
      frmMsgVo.setMsgCreatedDateOffline = strMsgCreatedDateOffline;
      try {
        var myFieldsNode = paramData["offlineFormDataJson"];
        try {
          frmMsgVo.setResponseRequestBy = myFieldsNode["myFields"]["respondBy"];
        } catch (_) {
          frmMsgVo.setResponseRequestBy = tmpOfflineFormData.responseRequestBy;
        }
        String strSentNames = "", strUserActionJson = "";
        isDistribute = await getFormDistributionDataFromDistList(
            projectId: tmpOfflineFormData.projectId!,
            formTypeId: tmpOfflineFormData.formTypeId!,
            jsonData: paramData["offlineFormDataJson"].toString(),
            onReturnReferences: (String sentNames, String userActionJson) {
              strSentNames = sentNames;
              strUserActionJson = userActionJson;
            });
        if (frmMsgVo.isDraft!) {
          frmMsgVo.setDraftSentActions = strUserActionJson;
        } else {
          frmMsgVo.setSentActions = strUserActionJson;
          frmMsgVo.setSentNames = strSentNames;
        }
      } catch (e) {
        Log.d("CreateFormLocalDataSource:: saveFieldFormDetailOffline exception=$e");
      }
      SiteLocation? locationVO = await getLocationVOFromDB(projectId: tmpOfflineFormData.projectId!, locationId: tmpOfflineFormData.locationId?.toString() ?? "");
      String? strMsgJsonData = paramData["offlineFormDataJson"];
      try {
        if (tmpOfflineFormData.templateType.isHTML) {
          String strAttachmentPath = await AppPathHelper().getAttachmentDirectory(projectId: tmpOfflineFormData.projectId.toString());
          strMsgJsonData = await getInlineAttachmentListFromJsonData(strMsgJsonData ?? "", tmpOfflineFormData.appBuilderId ?? "", strAttachmentPath, tmpOfflineFormData, autoPublishToFolder, (List<FormMessageAttachAndAssocVO> inlineAttachList, List<String> inlineAttachRevIdList) {
            if (inlineAttachList.isNotEmpty) {
              formAttachList.addAll(inlineAttachList);
            }
            if (inlineAttachRevIdList.isNotEmpty) {
              vecInlineAttachRevIdList = inlineAttachRevIdList;
            }
          });

          var tmpParserNode = jsonDecode(strMsgJsonData);
          Log.d("CreateFormLocalDataSource:: saveFieldFormDetailOffline ExpectedFinishDate=${tmpOfflineFormData.expectedFinishDate}");
          if (tmpOfflineFormData.expectedFinishDate != null && tmpOfflineFormData.expectedFinishDate!.isNotEmpty) {
            try {
              tmpParserNode["myFields"]["FORM_CUSTOM_FIELDS"]["ORI_MSG_Custom_Fields"]["ExpectedFinishDate"] = tmpOfflineFormData.expectedFinishDate;
            } catch (_) {
              Log.d("CreateFormLocalDataSource:: saveFieldFormDetailOffline ExpectedFinishDate exception");
            }
          }
          if (tmpParserNode["myFields"]["FORM_CUSTOM_FIELDS"]["ORI_MSG_Custom_Fields"]["Location"] != null) {
            String strLocationDetail = tmpParserNode["myFields"]["FORM_CUSTOM_FIELDS"]["ORI_MSG_Custom_Fields"]["Location"];
            String strLocationId = strLocationDetail.trim().split("|")[0];
            if (strLocationId != tmpOfflineFormData.locationId.toString() && locationVO != null) {
              String strTmpValue = locationVO.folderPath ?? "";
              tmpParserNode["myFields"]["FORM_CUSTOM_FIELDS"]["ORI_MSG_Custom_Fields"]["LocationName"] = strTmpValue;
              strTmpValue = "${locationVO.pfLocationTreeDetail?.locationId?.toString() ?? ""}|${locationVO.folderTitle ?? ""}|${locationVO.folderPath ?? ""}";
              tmpParserNode["myFields"]["FORM_CUSTOM_FIELDS"]["ORI_MSG_Custom_Fields"]["Location"] = strTmpValue;
              strTmpValue = "${locationVO.pfLocationTreeDetail?.locationId?.toString() ?? ""}|${locationVO.pfLocationTreeDetail?.revisionId ?? ""}|${locationVO.pfLocationTreeDetail?.locationCoordinates ?? ""}|${locationVO.pfLocationTreeDetail?.pageNumber?.toString() ?? ""}";
              tmpParserNode["myFields"]["FORM_CUSTOM_FIELDS"]["ORI_MSG_Custom_Fields"]["PF_Location_Detail"] = strTmpValue;
            }
          }
          strMsgJsonData = jsonEncode(tmpParserNode);
        }
      } catch (_) {}
      if (locationVO != null && !paramData.containsKey("assocLocationSelection")) {
        var assocLocationSelectionData = {
          "locationId": locationVO.pfLocationTreeDetail?.locationId,
          "projectId": locationVO.projectId,
          "folderId": locationVO.folderId,
        };
        paramData["assocLocationSelection"] = jsonEncode(assocLocationSelectionData);
      }

      ///generate random pin if location is calibrated and is not created from the plan view.
      if (!paramData.containsKey('coordinates') && !tmpOfflineFormData.locationId.toString().isNullEmptyZeroOrFalse()) {
        Map randomCoordinateMap = _generateRandomPin(tmpOfflineFormData.projectId.toString(), tmpOfflineFormData.locationId.toString());
        if (randomCoordinateMap.isNotEmpty) {
          Map<String, double> coordinateRectMap = {};
          coordinateRectMap["x1"] = randomCoordinateMap['X'];
          coordinateRectMap["y1"] = randomCoordinateMap['Y'];
          coordinateRectMap["x2"] = randomCoordinateMap['X'] + 10.0;
          coordinateRectMap["y2"] = randomCoordinateMap['Y'] + 10.0;
          String uniqueAnnotationId = await AsitePlugins().getUniqueAnnotationId() ?? "";
          paramData['coordinates'] = json.encode(coordinateRectMap);
          paramData['annotationId'] = uniqueAnnotationId;
          paramData['locationId'] = tmpOfflineFormData.locationId;
          paramData['page_number'] = randomCoordinateMap["page_number"] ?? 0;
          tmpOfflineFormData.observationCoordinates = paramData['coordinates'];
          tmpOfflineFormData.annotationId = uniqueAnnotationId;
          tmpOfflineFormData.pageNumber = paramData['page_number'];
        }
      }
      if (strMsgJsonData.isNullOrEmpty()) {
        frmMsgVo.setJsonData = tmpOfflineFormData.formJsonData;
      } else {
        frmMsgVo.setJsonData = strMsgJsonData;
      }
      String requestFilePath = await AppPathHelper().getOfflineRequestDataFilePath(projectId: frmMsgVo.projectId ?? "", msgId: frmMsgVo.msgId ?? "");
      await writeDataToFile(requestFilePath, jsonEncode(paramData));
      frmMsgVo.setOfflineRequestData = "1";

      formMessageList.add(frmMsgVo);
      tmpOfflineFormData.formJsonData = "";
      tmpOfflineFormData.isOfflineCreated = true;
      formList.add(tmpOfflineFormData);
      Log.d("CreateFormLocalDataSource:: saveFieldFormDetailOffline Created Successfully");
    }
    if (tmpOfflineFormData.isUploadAttachmentInTemp ?? false) {
      List<FormMessageAttachAndAssocVO> externalAttachmentList = await _saveExternalFormAttachments(tmpOfflineFormData, paramData);
      formAttachList.addAll(externalAttachmentList);
    }
    if (formList.isNotEmpty) {
      await FormDao().insert(formList);
      response = {"formId": formList.first.formId.toString(), "msgId": formList.first.msgId.toString(), "locationId": formList.first.locationId ?? 0, "projectId": formList.first.projectId ?? "", "isCopySiteTask": paramData["isCopySiteTask"] ?? false};
    }
    if (formMessageList.isNotEmpty) {
      await FormMessageDao().insert(formMessageList);
    }

    if (isRemoveAttachment) {
      try {
        if (tmpOfflineFormData.templateType.isHTML) {
          var myFieldsNode = jsonDecode(paramData["offlineFormDataJson"]);
          await removeFormMsgAttachAndAssocData(FormMessageAttachAndAssocDao.tableName, tmpOfflineFormData.projectId.toString(), tmpOfflineFormData.formId.toString(), tmpOfflineFormData.msgId.toString(), myFieldsNode["myFields"]["create_hidden_list"], vecInlineAttachRevIdList);
        }/* else {
          String strQuery = "DELETE FROM ${FormMessageAttachAndAssocDao.tableName}";
          strQuery = "$strQuery WHERE ProjectId=${tmpOfflineFormData.projectId}";
          strQuery = "$strQuery AND FormId=${tmpOfflineFormData.formId} AND MsgId=${tmpOfflineFormData.msgId}";
          Log.d("CreateFormLocalDataSource:: saveFieldFormDetailOffline strQuery=$strQuery");
          var strQueryResult = databaseManager.executeTableRequest(strQuery);
          Log.d("CreateFormLocalDataSource:: saveFieldFormDetailOffline strQueryResult=$strQueryResult");
        }*/
      } catch (_) {}
    }

    if (isNeedToUpdateAttachAssoc && vecInlineAttachRevIdList.isNotEmpty) {
      await updateFormMsgAttachAndAssocData(FormMessageAttachAndAssocDao.tableName, tmpOfflineFormData.projectId.toString(), tmpOfflineFormData.formId.toString(), vecInlineAttachRevIdList, formAttachList);
    }

    if (formAttachList.isNotEmpty) {
      await FormMessageAttachAndAssocDao().insert(formAttachList);
    }
    if (EFormMessageType.fromString(tmpOfflineFormData.msgTypeId?.toString() ?? "") == EFormMessageType.res && tmpOfflineFormData.isDraft! == false) {
      String strNewMsgCheckQuery = "SELECT count(*) AS MsgCount FROM ";
      strNewMsgCheckQuery = "$strNewMsgCheckQuery${FormMessageDao.tableName} WHERE ProjectId=${tmpOfflineFormData.projectId}";
      strNewMsgCheckQuery = "$strNewMsgCheckQuery AND FormId=${tmpOfflineFormData.formId}";
      strNewMsgCheckQuery = "$strNewMsgCheckQuery AND MsgId=${tmpOfflineFormData.msgId}";

      Log.d("CreateFormLocalDataSource:: saveFieldFormDetailOffline strNewMsgCheckQuery=$strNewMsgCheckQuery");
      var msgSize = databaseManager.executeSelectFromTable(FormMessageDao.tableName, strNewMsgCheckQuery);
      Log.d("CreateFormLocalDataSource:: saveFieldFormDetailOffline msgSize=${msgSize.length}");

      if (msgSize.isNotEmpty) {
        if (int.parse(msgSize[0]["MsgCount"].toString()) > 0) {
          String tmpActionIds = EFormActionType.forRespond.value.toString();
          if (isDistribute) {
            tmpActionIds = "$tmpActionIds,${EFormActionType.forDistribution.value.toString()}";
          }
          if (formAttachList.isNotEmpty) {
            tmpActionIds = "$tmpActionIds,${EFormActionType.forAttachedDoc.value.toString()}";
          }
          updateOfflineFieldFormMessageActionStatus(tmpOfflineFormData.projectId.toString(), tmpOfflineFormData.formId.toString(), tmpOfflineFormData.parentMsgId, tmpActionIds);
        }
      }
    }
    updateOfflineFieldFormMessageActionStatus(tmpOfflineFormData.projectId.toString(), tmpOfflineFormData.formId.toString(), tmpOfflineFormData.msgId.toString(), EFormActionType.forReviewDraft.value.toString());
    return response;
  }

  Future<String> discardDraft(Map<String, dynamic> paramData) async {
    String discardDraftData = "";

    try {
      String strProjectId = paramData["projectId"]?.toString().plainValue() ?? "";
      String strFormId = paramData["formId"]?.toString().plainValue() ?? "";
      String strMsgId = paramData["msgId"]?.toString().plainValue() ?? "";
      FormMessageVO? frmMsgVo = await getFormMessageVOFromDB(projectId: strProjectId, formId: strFormId, msgId: strMsgId);
      if (frmMsgVo != null) {
        String queryWhere = "";
        List<String> deleteTableNameList = [];
        switch (EFormMessageType.fromString(frmMsgVo.msgTypeId?.toString() ?? "")) {
          case EFormMessageType.ori:
            queryWhere = "WHERE ProjectId=$strProjectId AND FormId=$strFormId";
            deleteTableNameList = [FormMessageActionDao.tableName, FormMessageAttachAndAssocDao.tableName, FormMessageDao.tableName, FormDao.tableName];
            break;
          case EFormMessageType.res:
          case EFormMessageType.fwd:
            queryWhere = "WHERE ProjectId=$strProjectId AND FormId=$strFormId AND MsgId=$strMsgId";
            deleteTableNameList = [FormMessageActionDao.tableName, FormMessageAttachAndAssocDao.tableName, FormMessageDao.tableName];
            String strUpdateQuery = "UPDATE ${FormDao.tableName} SET MsgId=\n"
                "(SELECT MAX(CAST(MsgId AS INTEGER)) FROM ${FormMessageDao.tableName}\n"
                "WHERE ProjectId=$strProjectId AND FormId=$strFormId AND MsgId<>$strMsgId)\n"
                "WHERE ProjectId=$strProjectId AND FormId=$strFormId";
            databaseManager.executeTableRequest(strUpdateQuery);
            break;
          default:
            break;
        }
        if (deleteTableNameList.isNotEmpty) {
          for (var tableName in deleteTableNameList) {
            String deleteQuery = "DELETE FROM $tableName\n$queryWhere";
            databaseManager.executeTableRequest(deleteQuery);
          }
          if (frmMsgVo.isOfflineCreated == false) {
            await completeOfflineFormActivityForActions(paramData);
          }
          discardDraftData = "SUCCESS";
        }
      }
    } catch (e) {
      Log.e("CreateFormLocalDataSource::discardDraft exception $e");
    }
    return discardDraftData;
  }

  Future<SiteForm> parseJsonDataToFormVo(Map<String, dynamic> paramData) async {
    User? loginUser = await user;
    Usersessionprofile? userSessionProfile = loginUser!.usersessionprofile;
    SiteForm form = SiteForm();
    form.appBuilderId = paramData['appBuilderId']?.toString();
    form.appType = paramData['appTypeId']?.toString();
    form.projectId = paramData['projectId']?.toString().plainValue();
    if (paramData.containsKey('offlineFormId')) {
      form.observationId = paramData['offlineFormId'];
      form.formId = paramData['offlineFormId'].toString();
    } else {
      form.observationId = int.tryParse(paramData['observationId'].toString());
      form.formId = paramData['formId'];
    }
    form.commId = form.formId;
    form.locationId = int.tryParse(paramData['locationId']?.toString() ?? "0") ?? 0;
    form.revisionId = paramData['revisionId']?.toString();
    form.formTypeId = paramData['formTypeId']?.toString();
    form.templateType = paramData['templateType'];
    form.instanceGroupId = paramData['instanceGroupId'];
    form.isDraft = paramData['isDraft'] ?? false;
    form.annotationId = paramData['annotationId'];
    form.observationCoordinates = paramData['coordinates'];
    form.pageNumber = paramData['page_number'];
    form.controllerUserId = paramData['selectedControllerUserId'];
    form.code = paramData['formTypeCode'];
    form.firstName = userSessionProfile?.firstName;
    form.lastName = userSessionProfile?.lastName;
    form.orgName = userSessionProfile?.tpdOrgName;
    form.originatorDisplayName = "${userSessionProfile?.firstName} ${userSessionProfile?.lastName}, ${userSessionProfile?.tpdOrgName}";
    form.originatorId = userSessionProfile?.userID;
    form.msgOriginatorId = int.parse(userSessionProfile?.userID?.toString() ?? "0");
    String strTimeStampMS = DateTime.now().millisecondsSinceEpoch.toString();
    form.updatedDateInMS = strTimeStampMS;
    form.formCreationDateInMS = strTimeStampMS;
    String strDateTimeFormat = "yyyy-MM-dd HH:mm:ss.sss";
    DateTime creationDate = DateTime.fromMillisecondsSinceEpoch(int.parse(strTimeStampMS));
    String strCreatedDate = DateFormat(strDateTimeFormat).format(creationDate);
    form.updated = strCreatedDate;
    form.formCreationDate = strCreatedDate;
    String? strJsonData = paramData['offlineFormDataJson'];
    if (!strJsonData.isNullOrEmpty()) {
      var offlineFormDataJsonNode = jsonDecode(strJsonData!);
      if (form.pageNumber == null && offlineFormDataJsonNode['page_number'] != null) {
        form.pageNumber = offlineFormDataJsonNode['page_number'];
      }
      if (offlineFormDataJsonNode['myFields'] != null) {
        var myFieldsNode = offlineFormDataJsonNode['myFields'];
        if (myFieldsNode["create_hidden_list"] != null && myFieldsNode["create_hidden_list"] is Map) {
          form.eHtmlRequestType = myFieldsNode["create_hidden_list"]["requestType"] != null ? EHtmlRequestType.fromNumber(int.tryParse(myFieldsNode["create_hidden_list"]["requestType"].toString()) ?? 0) : null;
          var createHiddenListNode = myFieldsNode["create_hidden_list"] as Map<String, dynamic>;
          form.isUploadAttachmentInTemp = createHiddenListNode.containsKey("upFile0");
        }
        if (myFieldsNode['FORM_CUSTOM_FIELDS'] != null) {
          var formCustomFieldsNode = myFieldsNode['FORM_CUSTOM_FIELDS'];
          if (myFieldsNode["create_hidden_list"] != null) {
            var createHiddenListNode = myFieldsNode["create_hidden_list"];
            form.parentMsgId = createHiddenListNode["parent_msg_id"] ?? "0";
            if (createHiddenListNode["msg_type_id"] != null && createHiddenListNode["msg_type_code"] != null) {
              form.msgTypeId = createHiddenListNode["msg_type_id"]; //1 ORI, 2 RES, 3 FWD
              form.msgTypeCode = createHiddenListNode["msg_type_code"]; //1 ORI, 2 RES, 3 FWD
            } else {
              form.msgTypeId = "1"; //1 ORI, 2 RES, 3 FWD
              form.msgTypeCode = "ORI"; //1 ORI, 2 RES, 3 FWD
            }
            form.msgId = createHiddenListNode["msgId"] ?? "";
            if (form.locationId.toString().isNullEmptyZeroOrFalse()) {
              try {
                form.locationId = jsonDecode(myFieldsNode["create_hidden_list"]["assocLocationSelection"])['locationId'];
              } catch (_) {
                form.locationId = 0;
              }
            }
          }
          if (formCustomFieldsNode["ORI_MSG_Custom_Fields"] != null) {
            var oriMsgCustomFieldsNode = formCustomFieldsNode["ORI_MSG_Custom_Fields"];

            if (form.locationId.toString().isNullEmptyZeroOrFalse()) {
              String strLocationDetail = oriMsgCustomFieldsNode["Location"] ?? "";
              String strLocationId = strLocationDetail.split("|")[0];
              form.locationId = int.tryParse(strLocationId) ?? 0;
            }
            form.title = oriMsgCustomFieldsNode["ORI_FORMTITLE"];
            form.startDate = oriMsgCustomFieldsNode["StartDate"];
            form.workPackage = oriMsgCustomFieldsNode["DefectTyoe"].toString().toWorkPackage();
            if(oriMsgCustomFieldsNode["Dropdown_3"] != null && oriMsgCustomFieldsNode["Dropdown_3"].toString().isNotEmpty){
              form.workPackage = oriMsgCustomFieldsNode["Dropdown_3"].toString().toWorkPackage();
            } else {
              form.workPackage = oriMsgCustomFieldsNode["DefectTyoe"].toString().toWorkPackage();
            }
            form.responseRequestBy = setDueDate(oriMsgCustomFieldsNode);
            if (oriMsgCustomFieldsNode["ExpectedFinishDays"] != null) {
              form.formDueDays = int.tryParse(oriMsgCustomFieldsNode["ExpectedFinishDays"]?.toString() ?? "0");
              if (!form.startDate.isNullOrEmpty()) {
                String strExpectedFinishDate = FileFormUtility.getExpectedFinishedDate("yyyy-MM-dd", form.startDate!, form.formDueDays);
                form.expectedFinishDate = strExpectedFinishDate;
              }
            }
            if (oriMsgCustomFieldsNode["AssignedToUsersGroup"]?["AssignedToUsers"]?["AssignedToUser"] != null) {
              String strAssignedToUser = oriMsgCustomFieldsNode["AssignedToUsersGroup"]["AssignedToUsers"]["AssignedToUser"];
              if (strAssignedToUser.split("#").length > 1) {
                String strAssignedToUserId = strAssignedToUser.trim().split("#")[0];
                String strAssignedToUserNameAndOrg = strAssignedToUser.trim().split("#")[1];
                if (strAssignedToUserNameAndOrg.split(",").length > 1) {
                  String strAssignedToUserName = strAssignedToUserNameAndOrg.trim().split(",")[0];
                  String strAssignedToUserOrg = strAssignedToUserNameAndOrg.trim().split(",")[1];
                  form.assignedToUserId = strAssignedToUserId.plainValue();
                  form.assignedToUserName = strAssignedToUserName;
                  form.assignedToUserOrgName = strAssignedToUserOrg;
                }
              }
            }
            String strOriginatorUserData = oriMsgCustomFieldsNode["OriginatorId"] ?? ""; // "707447 | Vijay Mavadiya (5336), Asite Solutions # Vijay Mavadiya (5336), Asite Solutions"
            String strOriginatorUserId = "", strOriginatorUserName = "", strOriginatorUserOrg = "", strOriginatorDisplayName = "";
            if (strOriginatorUserData != "") {
              if (strOriginatorUserData.split("|").length > 1) {
                String strSplitString = strOriginatorUserData.split("|")[0];
                strOriginatorUserId = strSplitString.trim();
                strSplitString = strOriginatorUserData.split("|")[1];
                strSplitString = strSplitString.split("#")[0];
                strOriginatorDisplayName = strSplitString;
                if (strSplitString.split(",").length > 1) {
                  strOriginatorUserName = strSplitString.split(",")[0].trim();
                  strOriginatorUserOrg = strSplitString.split(",")[1].trim();
                }
              }
            }
            if (strOriginatorUserId == "" || strOriginatorDisplayName == "") {
              strOriginatorUserId = userSessionProfile?.userID ?? "";
              strOriginatorUserName = "${userSessionProfile?.firstName} ${userSessionProfile?.lastName}";
              strOriginatorUserOrg = userSessionProfile?.tpdOrgName ?? "";
              strOriginatorDisplayName = "$strOriginatorUserName, $strOriginatorUserOrg";
            }
            form.originatorId = strOriginatorUserId.plainValue();
            form.msgOriginatorId = int.tryParse(form.originatorId.toString());
            form.originatorDisplayName = strOriginatorDisplayName;
            form.orgName = strOriginatorUserOrg;
            if (form.code.isNullOrEmpty()) {
              form.code = myFieldsNode["Asite_System_Data_Read_Only"]["_4_Form_Type_Data"]["DS_FORMGROUPCODE"] ?? "";
            }
            form.observationDefectType = oriMsgCustomFieldsNode["DefectTyoe"] ?? oriMsgCustomFieldsNode["IssueType"];
            form.lastResponderForOriginator = oriMsgCustomFieldsNode["LastResponder_For_Originator"];
            form.lastResponderForAssignedTo = oriMsgCustomFieldsNode["LastResponder_For_AssignedTo"];
          }
        } else {
          dynamic createHiddenListNode = myFieldsNode["create_hidden_list"];
          form.parentMsgId = createHiddenListNode["parent_msg_id"] ?? "0";
          if (createHiddenListNode["msg_type_id"] != null && createHiddenListNode["msg_type_code"] != null) {
            form.msgTypeId = createHiddenListNode["msg_type_id"]; //1 ORI, 2 RES, 3 FWD
            form.msgTypeCode = createHiddenListNode["msg_type_code"]; //1 ORI, 2 RES, 3 FWD
          } else {
            form.msgTypeId = "1"; //1 ORI, 2 RES, 3 FWD
            form.msgTypeCode = "ORI"; //1 ORI, 2 RES, 3 FWD
          }
          form.msgId = createHiddenListNode["msgId"] ?? "";
          form.title = myFieldsNode["ORI_FORMTITLE"] ?? "";
          if(myFieldsNode["DefectTyoe"] != null && myFieldsNode["DefectTyoe"].toString().isNotEmpty){
            form.workPackage = myFieldsNode["DefectTyoe"].toString().toWorkPackage();
          }else {
            form.workPackage = myFieldsNode["Dropdown_3"].toString().toWorkPackage();
          }
          form.responseRequestBy = setDueDate(myFieldsNode);
          try {
            myFieldsNode.removeKey("dist_list");
          } catch (_) {}
        }
        if (form.locationId.toString().isNullEmptyZeroOrFalse()) {
          try {
            form.locationId = jsonDecode(myFieldsNode["create_hidden_list"]["assocLocationSelection"])['locationId'];
          } catch (_) {
            form.locationId = 0;
          }
        }
      } else {
        form.pageNumber = paramData["page_number"] ?? 1;
        form.parentMsgId = paramData["parent_msg_id"] ?? "0";
        form.msgId = paramData["msgId"] ?? "";
        if (paramData["msg_type_id"] != null && paramData["msg_type_code"] != null) {
          form.msgTypeId = paramData["msg_type_id"]; //1 ORI, 2 RES, 3 FWD
          form.msgTypeCode = paramData["msg_type_code"]; //1 ORI, 2 RES, 3 FWD
        } else {
          form.msgTypeId = "1"; //1 ORI, 2 RES, 3 FWD
          form.msgTypeCode = "ORI"; //1 ORI, 2 RES, 3 FWD
        }
        if (!form.formTypeId.isNullOrEmpty()) {
          String tmpFormSelectRadiobutton = paramData["formSelectRadiobutton"] ?? "";
          if (tmpFormSelectRadiobutton.split("_").length > 2) {
            form.formTypeId = tmpFormSelectRadiobutton.split("_")[2];
          }
        }
        if (offlineFormDataJsonNode["_0_0_0_0_my:ORI_FORMTITLE"] != null) {
          form.title = offlineFormDataJsonNode["_0_0_0_0_my:ORI_FORMTITLE"];
        } else {
          for (var key in offlineFormDataJsonNode) {
            if (key.toString().endsWith("my:ORI_FORMTITLE@JetId")) {
              form.title = offlineFormDataJsonNode[key].toString();
              break;
            }
          }
        }
        if (form.code.isNullOrEmpty()) {
          form.code = offlineFormDataJsonNode["xdoc_0_1_3_1_my:DS_FORMGROUPCODE"];
        }
        form.observationDefectType = offlineFormDataJsonNode["_0_0_0_3_my:DefectTyoe"];
        if (offlineFormDataJsonNode["xdoc_0_0_0_8_my:OriginatorId"] != null) {
          String tmpOriginUserData = offlineFormDataJsonNode["xdoc_0_0_0_8_my:OriginatorId"]; // 669780 | Rachir Bulsara, Asite Solutions Ltd. # Rachir Bulsara, Asite Solutions Ltd.
          List<String> originData = tmpOriginUserData.split('|');
          if (originData.length > 1) {
            String tmpOriginatorUserId = originData[0];
            List<String> originUserData = originData[1].split('#');
            if (originUserData.length > 1) {
              if (originUserData[1].split(',').length > 1) {
                String tmpOriginatorOrgName = originUserData[1].split(',')[1];
                form.orgName = tmpOriginatorOrgName;
              }
              form.originatorDisplayName = originUserData[1];
            }
            form.originatorId = tmpOriginatorUserId.trim();
          }
        }
        if (offlineFormDataJsonNode["_0_0_0_10_0_0_my:AssignedToUser"] != null) {
          String tmpAssignedUser = offlineFormDataJsonNode["_0_0_0_10_0_0_my:AssignedToUser"]; // 702544#Kush Patel, Asite Solutions Ltd.
          List<String> assignData = tmpAssignedUser.split('#');
          if (assignData.length > 1) {
            String tmpAssignUserId = assignData[0];
            form.assignedToUserId = tmpAssignUserId.trim();
            if (assignData[1].split(',').length > 1) {
              String tmpAssignUserName = assignData[1].split(',')[0];
              String tmpAssignOrgName = assignData[1].split(',')[1];
              form.assignedToUserName = tmpAssignUserName;
              form.assignedToUserOrgName = tmpAssignOrgName;
              if (tmpAssignUserName.split(' ').length > 1) {
                String tmpFirstName = tmpAssignUserName.split(' ')[0];
                String tmpLastName = tmpAssignUserName.split(' ')[1];
                form.firstName = (tmpFirstName);
                form.lastName = (tmpLastName);
              }
            }
          }
        }
        form.startDate = offlineFormDataJsonNode["_0_0_0_6_my:StartDate"];
        form.expectedFinishDate = offlineFormDataJsonNode["_0_0_0_7_my:ExpectedFinishDate"];
        form.lastResponderForAssignedTo = offlineFormDataJsonNode["xdoc_0_0_0_18_my:LastResponder_For_AssignedTo"];
        form.lastResponderForOriginator = offlineFormDataJsonNode["xdoc_0_0_0_19_my:LastResponder_For_Originator"];
        if (offlineFormDataJsonNode["xdoc_0_0_0_16_my:ExpectedFinishDays"] != null) {
          String strDueDays = offlineFormDataJsonNode["xdoc_0_0_0_16_my:ExpectedFinishDays"];
          Log.d("CreateFormLocalDataSource::", "parseJsonDataToFormVo Create strDueDays=$strDueDays");
          form.formDueDays = int.parse(strDueDays);
          form.expectedFinishDate = FileFormUtility.getExpectedFinishedDate("yyyy-MM-dd", form.startDate!, form.formDueDays);
        }
      }
    }
    form.msgCode = EFormMessageType.fromNumber(int.parse(form.msgTypeId?.toString() ?? "1")).name;
    if (form.templateType.isHTML) {
      form.formJsonData = strJsonData;
    }
    if (form.isUploadAttachmentInTemp ?? false) {
      form.attachmentImageName = "icons/assocform.png";
      form.formHasAssocAttach = true;
      form.hasAttachments = true;
    }
    form.typeImage = "icons/form.png";
    //setDocType("Apps");
    //setStatus("Unsync");
    form.statusName = form.status;
    form.isMarkOffline = true;
    //form.isForDefect =true;
    form.isActive = true;
    form.syncStatus = ESyncStatus.success;
    return form;
  }

  String setDueDate(dynamic filed){
    if(filed["respondBy"] != null && filed["respondBy"].toString().isNotEmpty){
      return filed["respondBy"].toString().toDateFormat();
    }

    if(filed["DS_CLOSE_DUE_DATE"] != null && filed["DS_CLOSE_DUE_DATE"].toString().isNotEmpty){
      return filed["DS_CLOSE_DUE_DATE"].toString().toDateFormat();
    }

    if(filed["StartDateDisplay"] != null && filed["StartDateDisplay"].toString().isNotEmpty){
      return filed["StartDateDisplay"].toString().toDateFormat();
    }

    return "";
  }

  Future<List<FormMessageAttachAndAssocVO>> _saveExternalFormAttachments(SiteForm tmpOfflineFormData, Map<String, dynamic> paramData) async {
    List<FormMessageAttachAndAssocVO> formAttachList = [];
    var attachListNode;
    if (tmpOfflineFormData.templateType.isHTML) {
      var myFieldsNode = jsonDecode(paramData["offlineFormDataJson"]);
      attachListNode = myFieldsNode["myFields"]["create_hidden_list"];
    } else {
      attachListNode = paramData;
    }
    String strAttachmentPath = await AppPathHelper().getAttachmentDirectory(projectId: tmpOfflineFormData.projectId.toString());
    if (attachListNode is Map) {
      User? loginUser = await user;
      Usersessionprofile? userSessionProfile = loginUser!.usersessionprofile;
      for (var attachNode in attachListNode.entries) {
        if (attachNode.key.toString().contains("upFile")) {
          String strAttachedFile = attachNode.value;
          File attachedFile = File(strAttachedFile);
          String strAttachUserFullName = "${userSessionProfile?.firstName} ${userSessionProfile?.lastName}";
          String strAttachUserId = userSessionProfile?.userID ?? "";
          String strFileName = "", strFileSize = "", strFileType = "", strAttachDocId = "";
          int fileLength = attachedFile.lengthSync();
          strFileSize = "${fileLength ~/ 1024} KB";
          strFileType = "filetype/${p.extension(strAttachedFile).replaceAll(".", "")}.gif";
          strAttachDocId = DateTime.now().microsecondsSinceEpoch.toString();
          strFileName = getFileNameFromPath(strAttachedFile);
          String strAttachmentFilePath = "$strAttachmentPath/$strAttachDocId${p.extension(strAttachedFile)}";
          FormMessageAttachAndAssocVO tmpMsgAttachData = getFormMessageAttachAndAssocVO(tmpOfflineFormData, {"attachedFile": strAttachedFile, "fileName": "$strFileName", "fileSize": strFileSize, "fileType": strFileType, "attachUserId": strAttachUserId, "attachUserFullName": strAttachUserFullName, "attachDocId": strAttachDocId});
          fileUtility.copySyncFile(attachedFile.path,strAttachmentFilePath);
          // ASITEFLD-2830 Field 2.0 - IOS/Android - Offline created site task attachments are not displayed in Online
          String relativeZipDirPath = strAttachedFile.replaceAll(AppPathHelper().basePath, "./../..");
          tmpMsgAttachData.setOfflineUploadFilePath = relativeZipDirPath; // add attachment
          // ASITEFLD-2830 Field 2.0 - IOS/Android - Offline created site task attachments are not displayed in Online
          formAttachList.add(tmpMsgAttachData);
        }
      }
    }
    return formAttachList;
  }

  Future<String> getInlineAttachmentListFromJsonData(String strJsonData, String strAppBuilderId, String strAttachmentPath, SiteForm pFormData, bool bAutoPublishToFolder, Function returnValues) async {
    String strNewJsonData = strJsonData;
    List<FormMessageAttachAndAssocVO> vecInlineAttachList = [];
    List<String> vecInlineAttachRevIdList = [];
    if (strJsonData.isNotEmpty) {
      try {
        dynamic pData = jsonDecode(strNewJsonData);
        List<String> vecKeyList = [];
        pData = await getInlineAttachmentListFromJsonObject(pData, (String strKeyName, String strUploadFilePath) async {
          FormMessageAttachAndAssocVO pAttachVO = FormMessageAttachAndAssocVO();
          if (bAutoPublishToFolder) {
            pAttachVO = await getAssocFileVOFromFilePath(strUploadFilePath, strAppBuilderId, strAttachmentPath, pFormData);
          } else {
            pAttachVO = await getAttachmentVOFromFilePath(strUploadFilePath, strAppBuilderId, strAttachmentPath, pFormData);
          }
          String strContentValue = "";
          if (pAttachVO != null) {
            vecKeyList.add(strKeyName);
            vecInlineAttachList.add(pAttachVO);
            String tmpPrjId = pAttachVO.projectId.plainValue();
            String tmpFrmTpId = pAttachVO.formTypeId.plainValue();
            String tmpFrmMsgId = pAttachVO.formMsgId.plainValue();
            String tmpInlnRevId = (EAttachmentAndAssociationType.fromString(pAttachVO.attachType!) == EAttachmentAndAssociationType.attachments) ? pAttachVO.attachRevId! : pAttachVO.assocDocRevisionId!;
            tmpInlnRevId = tmpInlnRevId;
            strContentValue = "$tmpPrjId#";
            strContentValue = "$strContentValue$tmpFrmTpId#";
            strContentValue = "$strContentValue$tmpFrmMsgId#";
            strContentValue = "$strContentValue${tmpFrmMsgId}_${strKeyName.split(':')[0]}#";
            strContentValue = "$strContentValue${tmpFrmMsgId}_${strKeyName.split(':')[0]}_$tmpInlnRevId#";
            strContentValue = strContentValue + tmpInlnRevId;
          }
          return strContentValue;
        }, (String strKeyName, String strContentValue) {
          vecKeyList.add(strKeyName);
          if (strContentValue != "") {
            vecInlineAttachRevIdList.add((strContentValue.split('#')[5]).plainValue());
          }
        });
        try {
          String strKeyListData = vecKeyList.join("#");
          pData["myFields"]["attachment_fields"] = strKeyListData;
        } catch (_) {}
        strNewJsonData = jsonEncode(pData);
        returnValues(vecInlineAttachList, vecInlineAttachRevIdList);
      } catch (e) {
        Log.d("CreateFormLocalDataSource::getInlineAttachmentListFromJsonData parse error");
      }
    }
    return strNewJsonData;
  }

  Future<dynamic> getInlineAttachmentListFromJsonObject(dynamic jsonNode, Function getContentValueCallback, Function getInlineDataCallback) async {
    if (jsonNode is List) {
      for (int i = 0; i < jsonNode.length; i++) {
        jsonNode[i] = await getInlineAttachmentListFromJsonObject(jsonNode[i], getContentValueCallback, getInlineDataCallback);
      }
    } else if (jsonNode is Map) {
      for (var entry in jsonNode.entries) {
        var key = entry.key;
        var value = entry.value;
        if (key.toString() == "content") {
          if (jsonNode.containsKey("@inline")) {
            String strKeyName = jsonNode["@inline"].toString();
            String strContent = value.toString();
            if (jsonNode.containsKey("OfflineContent") && strContent.isEmpty) {
              String strUploadFileName = jsonNode["OfflineContent"]["upFilePath"].toString();
              jsonNode[key] = await getContentValueCallback(strKeyName, strUploadFileName);
            } else {
              getInlineDataCallback(strKeyName, strContent);
            }
          }
        } else {
          jsonNode[key] = await getInlineAttachmentListFromJsonObject(jsonNode[key], getContentValueCallback, getInlineDataCallback);
        }
      }
    }
    return jsonNode;
  }

  Future<FormMessageAttachAndAssocVO> getAssocFileVOFromFilePath(String strFilePath, String strAppBuilderId, String strAttachmentPath, SiteForm pFormItem, {bool bIsNeedToWrite = true}) async {
    FormMessageAttachAndAssocVO tmpMsgAttachData = FormMessageAttachAndAssocVO();
    if (strFilePath.isNotEmpty && pFormItem != null) {
      String strAttachedFile = strFilePath;
      String? strFileName = "", strAttacDocId = "";
      int lliFileSize = await getFileSize(strAttachedFile);
      strFileName = getFileNameFromPath(strAttachedFile);
      strAttacDocId = DateTime.now().microsecondsSinceEpoch.toString();

      tmpMsgAttachData.setProjectId = pFormItem.projectId;
      tmpMsgAttachData.setFormTypeId = pFormItem.formTypeId;
      tmpMsgAttachData.setFormId = pFormItem.formId;
      tmpMsgAttachData.setFormMsgId = pFormItem.msgId;
      tmpMsgAttachData.setAssocProjectId = pFormItem.projectId;
      tmpMsgAttachData.setLocationId = pFormItem.locationId.toString();
      tmpMsgAttachData.setAssocDocRevisionId = strAttacDocId;
      tmpMsgAttachData.setAttachType = EAttachmentAndAssociationType.files.value.toString();
      tmpMsgAttachData.setAttachFileName = strFileName;

      tmpMsgAttachData = await getAssocFileVOFromAttachVO(pFormItem, tmpMsgAttachData, {
        "attachedFile": strAttachedFile,
        "fileName": strFileName,
        "fileSize": "${lliFileSize ~/ 1024} KB",
        "fileType": "filetype/${Utility.getFileExtension(strFileName)}.gif",
        "attachDocId": strAttacDocId,
        "publishDate": pFormItem.updated,
        "msgCreationDate": pFormItem.updated,
        "parentMsgCode": pFormItem.msgCode,
      });

      String strTimeStampInMSForFileName = strAttacDocId;
      String strAttachmentFilePath = "$strAttachmentPath/$strTimeStampInMSForFileName.${Utility.getFileExtension(strAttachedFile)}";
      if (bIsNeedToWrite) {
        fileUtility.copySyncFile(strAttachedFile, strAttachmentFilePath);
      }
    }
    return tmpMsgAttachData;
  }

  Future<FormMessageAttachAndAssocVO> getAttachmentVOFromFilePath(String strFilePath, String strAppBuilderId, String strAttachmentPath, SiteForm pFormItem, {bool bIsNeedToWrite = true}) async {
    FormMessageAttachAndAssocVO tmpMsgAttachData = FormMessageAttachAndAssocVO();
    if (strFilePath.isNotEmpty) {
      var pUsp = await StorePreference.getUserData();
      String strAttachedFile = strFilePath;
      String strAttachUserFullName = pUsp!.usersessionprofile!.tpdUserName.toString();
      String strAttachUserId = pUsp.usersessionprofile!.userID.plainValue();
      String strFileName = "", strFileSize = "", strFileType = "",strAttachDocId = "";
      int lliFileSize = await getFileSize(strAttachedFile);
      strFileName = getFileNameFromPath(strAttachedFile);
      strFileSize = "${lliFileSize ~/ 1024} KB";
      strFileType = "filetype/${strAttachedFile.getFileExtension()}.gif";
      strAttachDocId = DateTime.now().microsecondsSinceEpoch.toString();
      String strAttachmentFilePath = await AppPathHelper().getAttachmentFilePath(projectId: pFormItem.projectId ?? "", revisionId: strAttachDocId, fileExtention: Utility.getFileExtension(strAttachedFile));
      tmpMsgAttachData = getFormMessageAttachAndAssocVO(pFormItem, {"attachedFile": strAttachedFile, "fileName": strFileName, "fileSize": strFileSize, "fileType": strFileType, "attachUserId": strAttachUserId, "attachUserFullName": strAttachUserFullName, "attachDocId": strAttachDocId});
      if (bIsNeedToWrite) {
        fileUtility.copySyncFile(strAttachedFile, strAttachmentFilePath);
      }
    }
    return tmpMsgAttachData;
  }

  FormMessageAttachAndAssocVO getFormMessageAttachAndAssocVO(SiteForm tmpOfflineFormData, Map<String, dynamic> paramObj) {
    String strAttachDate = "";
    strAttachDate = tmpOfflineFormData.updated ?? "";
    FormMessageAttachAndAssocVO tmpMsgAttachData = FormMessageAttachAndAssocVO();
    //tmpMsgAttachData.appTypeId = (tmpOfflineFormData.getAppTypeId();
    tmpMsgAttachData.setProjectId = tmpOfflineFormData.projectId;
    // tmpMsgAttachData.setInstanceGroupId = tmpOfflineFormData.getInstanceGroupId();
    tmpMsgAttachData.setFormTypeId = tmpOfflineFormData.formTypeId;
    // tmpMsgAttachData.setObservationId = (tmpOfflineFormData.getObservationId();
    tmpMsgAttachData.setLocationId = (tmpOfflineFormData.locationId ?? 0).toString();
    tmpMsgAttachData.setFormId = tmpOfflineFormData.formId;
    tmpMsgAttachData.setFormMsgId = tmpOfflineFormData.msgId;
    tmpMsgAttachData.setAttachDocId = paramObj["attachDocId"];
    tmpMsgAttachData.setAttachRevId = paramObj["attachDocId"];
    tmpMsgAttachData.setAttachFileName = paramObj["fileName"];
    // tmpMsgAttachData.setAttachSize = fileLength;

    //change according to old defect-logic , offline path is for defect [/Defect/Attachments]
    // tmpMsgAttachData.setOfflineAttachFilePath(strAttachedFile);

    tmpMsgAttachData.setAttachType = EAttachmentAndAssociationType.attachments.value.toString();

    Map<String, dynamic> pAttachDataNode = {};
    pAttachDataNode["fileType"] = paramObj["fileType"]; // "filetype/noicon.gif",
    pAttachDataNode["fileName"] = paramObj["fileName"];
    pAttachDataNode["revisionId"] = paramObj["attachDocId"]; //: "7804330$$baLp6F",
    pAttachDataNode["fileSize"] = paramObj["fileSize"];
    pAttachDataNode["hasAccess"] = false;
    pAttachDataNode["canDownload"] = false;
    pAttachDataNode["publisherUserId"] = 0;
    pAttachDataNode["hasBravaSupport"] = false;
    pAttachDataNode["docId"] = paramObj["attachDocId"]; //: "10928201$$pXXxiM",
    pAttachDataNode["attachedBy"] = "";
    pAttachDataNode["attachedDateInTimeStamp"] = strAttachDate; //: "Jan 4] = 2020 6:03:00 AM",
    pAttachDataNode["attachedDate"] = strAttachDate; //: "04-Jan-2020#06:03 WET",
    pAttachDataNode["attachedById"] = paramObj["attachUserId"];
    pAttachDataNode["attachedByName"] = paramObj["attachUserFullName"];
    pAttachDataNode["isLink"] = false;
    pAttachDataNode["linkType"] = "Static";
    pAttachDataNode["isHasXref"] = false;
    pAttachDataNode["documentTypeId"] = 0;
    pAttachDataNode["isRevPrivate"] = false;
    pAttachDataNode["isAccess"] = true;
    pAttachDataNode["isDocActive"] = true;
    pAttachDataNode["folderPermissionValue"] = 0;
    pAttachDataNode["isRevInDistList"] = false;
    pAttachDataNode["isPasswordProtected"] = false;
    pAttachDataNode["attachmentId"] = "0";
    pAttachDataNode["type"] = EAttachmentAndAssociationType.attachments.value.toString();
    pAttachDataNode["msgId"] = int.tryParse(tmpMsgAttachData.formMsgId.toString()); //: "10530159$$Zrxgpq",
    pAttachDataNode["msgCreationDate"] = strAttachDate; //: "Jan 4] = 2020 6:03:00 AM",
    pAttachDataNode["projectId"] = tmpMsgAttachData.projectId; //: "2112709$$TyX4sl",
    pAttachDataNode["folderId"] = "0"; //: "84758422$$gZbhz2",
    pAttachDataNode["dcId"] = 1; //: 1,
    pAttachDataNode["childProjectId"] = 0;
    pAttachDataNode["userId"] = 0;
    pAttachDataNode["resourceId"] = 0;
    pAttachDataNode["parentMsgId"] = int.tryParse(tmpMsgAttachData.formMsgId.toString()); //: 10530159,
    pAttachDataNode["parentMsgCode"] = tmpOfflineFormData.msgCode; //: "ORI001",
    pAttachDataNode["assocsParentId"] = "0";
    pAttachDataNode["generateURI"] = true;
    pAttachDataNode["hasOnlineViewerSupport"] = false;
    pAttachDataNode["downloadImageName"] = ""; //: "icons/downloads.png"
    tmpMsgAttachData.setAttachAssocDetailJson = jsonEncode(pAttachDataNode);
    return tmpMsgAttachData;
  }

  Future<bool> removeFormMsgAttachAndAssocData(String strTableName, String strProjectId1, String strFormId1, String strMsgId1, var createHiddenListNode, List<String> vecInlineAttacRevIds) async {
    bool isSuccess = false;
    try {
      String strProjectId = strProjectId1.plainValue();
      String strFormId = strFormId1.plainValue();
      String? strMsgId = strMsgId1;
      String strForeignKeys = "";
      String strForeignKeysQuery = "PRAGMA foreign_keys";
      Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData strForeignKeysQuery=$strForeignKeysQuery");
      var strForeignKeysMap = databaseManager.executeSelectFromTable(strTableName, strForeignKeysQuery);
      if (strForeignKeysMap.isNotEmpty) {
        strForeignKeys = strForeignKeysMap[0]["foreign_keys"].toString();
      }
      Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData strForeignKeys=$strForeignKeys");

      String strQuery = "";

      if (strForeignKeys == "1") {
        strQuery = "PRAGMA foreign_keys=0";
        Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData strQuery=$strQuery");
        var strQueryResult = databaseManager.executeSelectFromTable(strTableName, strQuery);
        Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData strQueryResult=$strQueryResult");
      }

      String strTempTable = "${strTableName}_TEMP";

      strQuery = "CREATE TABLE $strTempTable AS SELECT * FROM $strTableName";
      strQuery = "$strQuery WHERE ProjectId=$strProjectId";
      strQuery = "$strQuery AND FormId=$strFormId AND MsgId=$strMsgId";
      String strAttachTypeNotRemove = "${EAttachmentAndAssociationType.files.value},${EAttachmentAndAssociationType.discussions.value}";
      strAttachTypeNotRemove = "$strAttachTypeNotRemove,${EAttachmentAndAssociationType.apps.value},${EAttachmentAndAssociationType.attachments.value}";
      strQuery = "$strQuery AND ((AttachmentType NOT IN ($strAttachTypeNotRemove))";

      String strAttachQuery = "", strFileAssocQuery = "", strCommAssocQuery = "", strAppAssocQuery = "";
      var createHiddenMapNode = createHiddenListNode as Map;
      for (var createHiddenNode in createHiddenMapNode.entries) {
        if (createHiddenNode.key.toString().startsWith("assocDocSelection")) {
          String strJsonValueData = createHiddenNode.value.toString();
          try {
            var assocDocSelectionNodeList = jsonDecode(strJsonValueData);
            for (var createChildNode in assocDocSelectionNodeList) {
              try {
                String tmpPrjId = createChildNode["projectId"];
                String tmpFldId = createChildNode["folderId"];
                String tmpRvsId = createChildNode["revision_id"];
                if (strFileAssocQuery != "") {
                  strFileAssocQuery = "$strFileAssocQuery OR ";
                }
                strFileAssocQuery = "$strFileAssocQuery(AssocProjectId=$tmpPrjId AND AssocDocFolderId=$tmpFldId AND AssocDocRevisionId=$tmpRvsId)";
              } catch (_) {
                Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData assocDocSelection default::exception ");
              }
            }
          } catch (_) {
            Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData assocDocSelection parse error strJsonValueData=$strJsonValueData");
          }
        } else if (createHiddenNode.key.toString().startsWith("assocCommentSelection")) {
          String strJsonValueData = createHiddenNode.value.toString();
          try {
            var assocCommentSelectionNodeList = jsonDecode(strJsonValueData);
            for (var createChildNode in assocCommentSelectionNodeList) {
              try {
                String tmpPrjId = createChildNode["projectId"];
                String tmpCommId = createChildNode["commentid"];
                String tmpCommMsgId = createChildNode["commentMsgId"];
                String tmpRvsId = createChildNode["revision_id"];
                if (strCommAssocQuery != "") {
                  strCommAssocQuery = "$strCommAssocQuery OR ";
                }
                strCommAssocQuery = "$strCommAssocQuery(";
                strCommAssocQuery = "${strCommAssocQuery}AssocProjectId=$tmpPrjId AND AssocCommentMsgId=$tmpCommMsgId";
                strCommAssocQuery = "$strCommAssocQuery AND AssocCommentId=$tmpCommId AND AssocCommentRevisionId=$tmpRvsId";
                strCommAssocQuery = "$strCommAssocQuery)";
              } catch (_) {
                Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData assocCommentSelection default::exception");
              }
            }
          } catch (_) {
            Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData assocCommentSelection parse error strJsonValueData=$strJsonValueData");
          }
        } else if (createHiddenNode.key.toString().startsWith("selformIds")) {
          String strSelFormId = createHiddenNode.value.toString();
          List<String> formVec = strSelFormId.split("#");
          if (strAppAssocQuery != "") {
            strAppAssocQuery = "$strAppAssocQuery OR ";
          }
          strAppAssocQuery = "$strAppAssocQuery(AssocProjectId=${formVec[0]} AND AssocFormCommId=${formVec[1]})";
        } else if (createHiddenNode.key.toString().startsWith("attachedDocs") && createHiddenNode.key.toString().startsWith("attachedDocs_") == false) {
          if (strAttachQuery != "") {
            strAttachQuery = "$strAttachQuery,";
          }
          strAttachQuery = strAttachQuery + createHiddenNode.value.toString();
        }
      }
      if (strFileAssocQuery != "") {
        strFileAssocQuery = "(AttachmentType=${EAttachmentAndAssociationType.files.value} AND ($strFileAssocQuery))";
        strQuery = "$strQuery OR $strFileAssocQuery";
      }
      if (strCommAssocQuery != "") {
        strCommAssocQuery = "(AttachmentType=${EAttachmentAndAssociationType.discussions.value} AND ($strCommAssocQuery))";
        strQuery = "$strQuery OR $strCommAssocQuery";
      }
      if (strAppAssocQuery != "") {
        strAppAssocQuery = "(AttachmentType=${EAttachmentAndAssociationType.apps.value} AND ($strAppAssocQuery))";
        strQuery = "$strQuery OR $strAppAssocQuery";
      }
      if (strAttachQuery != "") {
        strAttachQuery = "(AttachmentType=${EAttachmentAndAssociationType.attachments.value} AND AttachDocId IN ($strAttachQuery))";
        strQuery = "$strQuery OR $strAttachQuery";
      }
      if (vecInlineAttacRevIds.isNotEmpty) {
        String strInlineAttachRevIds = vecInlineAttacRevIds.toList().join(",");
        String strInlineAttachQuery = "(AttachRevId IN ($strInlineAttachRevIds) OR AssocDocRevisionId IN ($strInlineAttachRevIds))";
        strQuery = "$strQuery OR $strInlineAttachQuery";
      }
      strQuery = "$strQuery)";
      Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData strQuery=$strQuery");
      // var strQueryResult = databaseManager.executeSelectFromTable(strTableName, strQuery);
      var strQueryResult = databaseManager.executeTableRequest(strQuery);
      Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData strQueryResult=${strQueryResult.toString()}");

      // if (strQueryResult.isNotEmpty) {
      strQuery = "SELECT tmpTbl.ProjectId,tmpTbl.AttachRevId,tmpTbl.AssocDocRevisionId,tmpTbl.AttachmentType,tmpTbl.AttachAssocDetailJson FROM $strTableName tmpTbl\n";
      strQuery = "${strQuery}LEFT JOIN $strTempTable attachTbl\n";
      strQuery = "${strQuery}ON tmpTbl.ProjectId=attachTbl.ProjectId AND tmpTbl.FormId=attachTbl.FormId AND tmpTbl.MsgId=attachTbl.MsgId\n";
      strQuery = "${strQuery}AND ((tmpTbl.AttachRevId=attachTbl.AttachRevId AND tmpTbl.AttachRevId<>'')\n";
      strQuery = "${strQuery}OR (tmpTbl.AssocDocRevisionId=attachTbl.AssocDocRevisionId AND tmpTbl.AssocDocRevisionId<>''))\n";
      strQuery = "${strQuery}WHERE attachTbl.ProjectId ISNULL AND tmpTbl.ProjectId=$strProjectId\n";
      strQuery = "${strQuery}AND tmpTbl.FormId=$strFormId AND tmpTbl.MsgId=$strMsgId";
      Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData strQuery=$strQuery");
      var tableResult = databaseManager.executeSelectFromTable(strTableName, strQuery);
      String strAttachmentPathDir = await AppPathHelper().getAttachmentDirectory(projectId: strProjectId.toString());

      for (var tblColums in tableResult) {
        String strFilePath = "";
        try {
          switch (EAttachmentAndAssociationType.fromString(tblColums["AttachmentType"].toString())) {
            case EAttachmentAndAssociationType.attachments:
              {
                String strFilename = jsonDecode(tblColums["AttachAssocDetailJson"])["fileName"];
                strFilePath = "$strAttachmentPathDir/${tblColums["AttachRevId"]}.${Utility.getFileExtension(strFilename)}";
              }
              break;
            case EAttachmentAndAssociationType.files:
              {
                String strFilename = tblColums["AttachAssocDetailJson"]["uploadFileName"];
                strFilePath = "${strAttachmentPathDir + tblColums["AssocDocRevisionId"]}.${p.extension(strFilename)}";
              }
              break;
            default:
              break;
          }
        } catch (_) {
          Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData InlineAttach parse error");
        }
        if (strFilePath.isNotEmpty && isFileExist(strFilePath)) {
          deleteFile(File(strFilePath));
        }
      }

      strQuery = "DELETE FROM $strTableName";
      strQuery = "$strQuery WHERE ProjectId=$strProjectId";
      strQuery = "$strQuery AND FormId=$strFormId AND MsgId=$strMsgId";
      Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData strQuery=$strQuery");
      strQueryResult = databaseManager.executeSelectFromTable(strTableName, strQuery);
      Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData strQueryResult=$strQueryResult");

      strQuery = "INSERT INTO $strTableName SELECT * FROM $strTempTable";
      Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData strQuery=$strQuery");
      strQueryResult = databaseManager.executeSelectFromTable(strTableName, strQuery);
      Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData strQueryResult=$strQueryResult");

      strQuery = "DROP TABLE $strTempTable";
      Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData strQuery=$strQuery");

      strQueryResult = databaseManager.executeSelectFromTable(strTempTable, strQuery);
      Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData strQueryResult=$strQueryResult");
      // }

      if (strForeignKeys == "1") {
        strQuery = "PRAGMA foreign_keys=1";
        Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData strQuery=$strQuery");
        strQueryResult = databaseManager.executeSelectFromTable(strTableName, strQuery);
        Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData strQueryResult=$strQueryResult");
      }
      isSuccess = true;
    } catch (e) {
      Log.d("CreateFormLocalDataSource::removeFormMsgAttachAndAssocData default::exception::$e");
    }
    return isSuccess;
  }

  Future<String> changeFieldFormHistoryStatus(Map<String, dynamic> paramData) async {
    String value = "";
    try {
      User? currentUser = await user;
      if (currentUser != null) {
        FormStatusHistoryVO formStatusHistoryVO = FormStatusHistoryVO.fromJsonOffline(paramData, currentUser);
        String strProjectId = formStatusHistoryVO.strProjectId ?? "";
        String strFormId = formStatusHistoryVO.strFormId ?? "";
        if (strProjectId.isNotEmpty && strProjectId != "0" && strFormId.isNotEmpty && strFormId != "0") {
          SiteForm? existingFormData = await getFormVOFromDB(projectId: strProjectId, formId: strFormId);
          if (existingFormData != null) {
            existingFormData.statusid = paramData["statusId"].toString();
            existingFormData.status = paramData["statusName"].toString();
            existingFormData.statusChangeUserId = int.tryParse(formStatusHistoryVO.strActionUserId.toString()) ?? 0;
            existingFormData.statusChangeUserName = formStatusHistoryVO.strActionUserName;
            existingFormData.statusChangeUserOrg = formStatusHistoryVO.strActionUserOrgName;
            existingFormData.statusUpdateDate = formStatusHistoryVO.strActionDate;
            removeOfflineOldStatusHistoryDetails(strProjectId, strFormId);
            await FormStatusHistoryDao().insert([formStatusHistoryVO]);
            await FormDao().insert([existingFormData]);
            updateOfflineFieldFormMessageActionStatus(existingFormData.projectId.toString(), existingFormData.formId.toString(), "", EFormActionType.forAssignStatus.value.toString());
            value = "Status Change Successfully";
          }
        }
      }
    } catch (e) {
      value = "changeFieldFormHistoryStatus default::exception";
      Log.e(value);
    }
    return value;
  }

  Future<void> completeOfflineFormActivityForActions(Map<String, dynamic> paramData) async {
    try {
      String strProjectId = paramData["projectId"];
      String strFormTypeId = paramData["form_type_id"] ?? paramData["rmft"] ?? "";
      String strFormId = paramData["formId"];
      String strMsgId = paramData["msgId"];
      String strActionId = paramData["actionId"]?.toString() ?? "0";
      String currentTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      OfflineActivityVo offlineActivityVo = OfflineActivityVo();
      offlineActivityVo.projectId = strProjectId;
      offlineActivityVo.formTypeId = strFormTypeId;
      offlineActivityVo.formId = strFormId;
      offlineActivityVo.msgId = strMsgId;
      offlineActivityVo.actionId = strActionId;
      offlineActivityVo.distListId = "0";
      offlineActivityVo.offlineRequestData = jsonEncode(paramData);
      offlineActivityVo.createdDateInMs = currentTimeStamp;

      await OfflineActivityDao().insert([offlineActivityVo]);
      updateOfflineFieldFormMessageActionStatus(strProjectId, strFormId, strMsgId, strActionId);
    } catch (e) {
      Log.e("CreateFormLocalDataSource::completeOfflineFormActivityForActions default::exception$e");
    }
  }

  removeOfflineOldStatusHistoryDetails(String strProjectId, String strFormId) {
    String strQuery = "DELETE FROM ${FormStatusHistoryDao.tableName}";
    strQuery = "$strQuery WHERE ProjectId=$strProjectId";
    strQuery = "$strQuery AND FormId=$strFormId AND JsonData=''";
    Log.d("CreateFormLocalDataSource::removeOfflineOldStatusHistoryDetails strQuery=$strQuery");
    var strQueryResult = databaseManager.executeSelectFromTable(FormStatusHistoryDao.tableName, strQuery);
    Log.d("CreateFormLocalDataSource::removeOfflineOldStatusHistoryDetails strQueryResult=$strQueryResult");
  }

  Map<String, dynamic> _generateRandomPin(String projectId, String locationId) {
    Map<String, dynamic> randomCoordinateMap = {};
    try {
      String selectQuery = "SELECT * FROM ${LocationDao.tableName}";
      selectQuery = "$selectQuery WHERE ProjectId=$projectId AND LocationId=$locationId";
      Log.d("CreateFormLocalDataSource::_generateRandomPin Location Detail query=$selectQuery");
      var mapOfLocationList = databaseManager.executeSelectFromTable(LocationDao.tableName, selectQuery);
      Log.d("CreateFormLocalDataSource::_generateRandomPin mapOfLocationList size=${mapOfLocationList.length}");
      if (mapOfLocationList.length == 1) {
        var locationItem = mapOfLocationList.first;
        if (locationItem[LocationDao.locationCoordinateField] != null && locationItem[LocationDao.locationCoordinateField].toString().isNotEmpty) {
          Map<String, dynamic> coordinateMap = jsonDecode(locationItem[LocationDao.locationCoordinateField]);
          double? x_1 = double.parse(coordinateMap["x1"].toString());
          double? y_1 = double.parse(coordinateMap["y1"].toString());
          double? x_2 = double.parse(coordinateMap["x2"].toString());
          double? y_2 = double.parse(coordinateMap["y2"].toString());

          Map<String, double> maxMinXMap = _getMaxMin(x_1, x_2);
          Map<String, double> maxMinYMap = _getMaxMin(y_1, y_2);
          int? maxX = 0;
          int? minX = 0;
          int? maxY = 0;
          int? minY = 0;
          num randX;
          num randY;
          if (maxMinXMap.isNotEmpty) {
            maxX = maxMinXMap["MAX"]?.toInt();
            minX = maxMinXMap["MIN"]?.toInt();
          }
          if (maxMinYMap.isNotEmpty) {
            maxY = maxMinYMap["MAX"]?.toInt();
            minY = maxMinYMap["MIN"]?.toInt();
          }
          if (minX != null && minY != null && maxX != null && maxY != null) {
            do {
              randX = minX + Random().nextInt(maxX - minX);
            } while (randX == minX || randX == maxX);
            do {
              randY = minY + Random().nextInt(maxY - minY);
            } while (randY == minY || randY == maxY);

            if (randX != 0 && randY != 0) {
              randomCoordinateMap["X"] = randX.toDouble();
              randomCoordinateMap["Y"] = randY.toDouble();
              randomCoordinateMap["page_number"] = locationItem[LocationDao.pageNumberField];
            }
          }
        }
      }
    } catch (_) {
      Log.d("CreateFormLocalDataSource::_generateRandomPin exception");
    }
    return randomCoordinateMap;
  }

  Map<String, double> _getMaxMin(double? x1, double? x2) {
    Map<String, double> maxminMap = {};
    if (x1 != null && x2 != null) {
      if (x1 > x2) {
        maxminMap["MAX"] = x1;
        maxminMap["MIN"] = x2;
      } else {
        maxminMap["MAX"] = x2;
        maxminMap["MIN"] = x1;
      }
    }
    return maxminMap;
  }

  Future<String> _getReplyRespondHtmlFormData(Map<String, dynamic> paramData, EHtmlRequestType eHtmlRequestType) async {
    String replyHtmlData = "";
    String projectId = paramData["projectId"].toString().plainValue();
    String formTypeId = (paramData["formTypeId"] ?? "").toString().plainValue();
    String msgId = (paramData["msgId"] ?? "").toString().plainValue();
    String formId = (paramData["formId"] ?? "").toString().plainValue();
    String parentMsgId = (paramData["parent_msg_id"] ?? "").toString().plainValue();
    String replyFormFileDir = "${await AppPathHelper().getAppDataFormTypeDirectory(projectId: projectId, formTypeId: formTypeId)}/";
    String replyFormPath = "${replyFormFileDir}RES_VIEW.html";
    String dataJsonPath = "${replyFormFileDir}data.json";
    String customAttributeViewName = "RES_VIEW";
    if (!isFileExist(replyFormPath)) {
      replyFormPath = "${replyFormFileDir}ORI_VIEW.html";
      customAttributeViewName = "ORI_VIEW";
    }
    Log.d("CreateFormLocalDataSource::getReplyRespondHtmlFormData Create strViewFilePath=$replyFormPath");
    Log.d("CreateFormLocalDataSource::getReplyRespondHtmlFormData Create strDataJsonFile=$dataJsonPath");
    String innerCreateHtmlFormData = readFromFile(replyFormPath);
    String dataJsonFileData = readFromFile(dataJsonPath);
    // String? strFixFieldDataJson = "";
    if (!msgId.isNullEmptyZeroOrFalse() && !formId.isNullOrEmpty()) {
      FormMessageVO? existFormMsgData = await getFormMessageVOFromDB(projectId: projectId, formId: formId, msgId: msgId);

      if (existFormMsgData != null) {
        dataJsonFileData = existFormMsgData.jsonData.toString();
        if (parentMsgId.isNullEmptyZeroOrFalse()) {
          parentMsgId = existFormMsgData.parentMsgId ?? "";
        }
        //strFixFieldDataJson = existFormMsgData.fixFieldData;
      } else {
        dataJsonFileData = readFromFile(dataJsonPath);
      }
    } else {
      FormMessageVO? existFormMsgData = await getFormMessageVOFromDB(projectId: projectId, formId: formId, msgId: parentMsgId);
      if (existFormMsgData != null) {
        dataJsonFileData = existFormMsgData.jsonData.toString();
      } else {
        dataJsonFileData = readFromFile(dataJsonPath);
      }
    }
    if (innerCreateHtmlFormData.isNotEmpty && dataJsonFileData.isNotEmpty) {
      dataJsonFileData = await getHTML5ChangeSPDataInJsonData(eHtmlRequestType, dataJsonFileData, paramData);
      dataJsonFileData = updateJsonDataForInlineAttachments(jsonDecode(dataJsonFileData), (String strOldValue, String strKeyName) {
        return getFormMessageInlineAttachmentContentValue(FormMessageAttachAndAssocDao.tableName, strOldValue, strKeyName);
      });

      String oriView = "<script type=\"text/javascript\">var isOriView=true</script></head>";
      dataJsonFileData = dataJsonFileData.replaceAll("\"", "&quot;");
      innerCreateHtmlFormData = innerCreateHtmlFormData.replaceAll("<script attr=\"src=", "<script src=\"");
      innerCreateHtmlFormData = innerCreateHtmlFormData.replaceAll("\${JSON_DATA}", dataJsonFileData);
      innerCreateHtmlFormData = innerCreateHtmlFormData.replaceAll("</head>", oriView);
      String customAttribute = await getFormTypeViewCustomAttributeData(formTypeId: formTypeId, projectId: projectId, viewName: customAttributeViewName);
      if (customAttribute.isNotEmpty) {
        innerCreateHtmlFormData = await addFormTypeCustomAttributeInHtml(innerCreateHtmlFormData, customAttribute, projectId, formTypeId);
      }
      String sPAttribute = await getFormTypeViewFixFieldSPData(formTypeId: formTypeId, projectId: projectId, viewName: customAttributeViewName);
      if (sPAttribute.isNotEmpty) {
        innerCreateHtmlFormData = await addFormTypeSPDataInHtml(innerCreateHtmlFormData, sPAttribute, paramData, "");
      }
      String replyHtmlFilePath = "${await AppPathHelper().getAssetHTML5FormZipPath()}/offlineCreateForm.html";
      replyHtmlData = readFromFile(replyHtmlFilePath);
      if (replyHtmlData.isNotEmpty) {
        var hiddenFieldMap = {"msg_type_id": EFormMessageType.res.value, "msg_type_code": EFormMessageType.res.name, "parent_msg_id": parentMsgId, "dist_list": "", "assocLocationSelection": "", "project_id": projectId, "offlineProjectId": projectId, "offlineFormTypeId": formTypeId, "requestType": eHtmlRequestType.value};
        String formAction = "create";
        if (msgId != "" && msgId != "0") {
          hiddenFieldMap["msgId"] = msgId;
          formAction = "edit";
        }
        hiddenFieldMap["formAction"] = formAction;
        String htmlHiddenField = FormHtmlUtility().getHTMLHiddenFieldAttributeData(htmlAttributeMap: hiddenFieldMap);
        replyHtmlData = replyHtmlData.replaceAll("<div id=\"offlineCreateHiddenForm\"></div>", htmlHiddenField);

        replyHtmlData = replyHtmlData.replaceAll("<div id=\"sHtml\"></div>", innerCreateHtmlFormData);
        String configData = await getOfflineConfigDataJson(paramData, eHtmlRequestType);
        if (configData.isNotEmpty) {
          configData = configData.replaceAll("\\", "\\\\");
          configData = configData.replaceAll("\"", "\\\"");
          replyHtmlData = replyHtmlData.replaceAll("REPLACE_CONFIG_DATA", configData);
        }
      }
    }

    return replyHtmlData;
  }

  Future<String> getFieldCopyFormHtml5Json(Map<String, dynamic> paramData) async {
    String createHtmlData = "";
    String projectId = paramData["projectId"]?.toString().plainValue() ?? "";
    String formId = paramData["formId"]?.toString().plainValue() ?? "";
    if (projectId.isNotEmpty && formId.isNotEmpty) {
      String query = "SELECT frmMsgTbl.LocationId,locTbl.IsCalibrated,frmTpTbl.AppBuilderId,frmTpTbl.TemplateTypeId,frmTpTbl.InstanceGroupId,frmTpTbl.AppTypeId,frmTpTbl.FormTypeId,frmTpTbl.FormTypeGroupCode,frmTpTbl.FormTypeName,frmMsgTbl.JsonData FROM ${FormMessageDao.tableName} frmMsgTbl\n"
          "INNER JOIN ${LocationDao.tableName} locTbl ON locTbl.ProjectId=frmMsgTbl.ProjectId AND locTbl.LocationId=frmMsgTbl.LocationId\n"
          "INNER JOIN ${FormTypeDao.tableName} frmTpTbl ON frmTpTbl.ProjectId=frmMsgTbl.ProjectId AND frmTpTbl.FormTypeId=(\n"
          "SELECT MAX(FormTypeId) FROM ${FormTypeDao.tableName} WHERE ProjectId=frmMsgTbl.ProjectId AND InstanceGroupId=(\n"
          "SELECT InstanceGroupId FROM ${FormTypeDao.tableName} WHERE ProjectId=frmMsgTbl.ProjectId AND FormTypeId=frmMsgTbl.FormTypeId\n)\n)\n"
          "WHERE frmMsgTbl.ProjectId=$projectId AND frmMsgTbl.FormId=$formId AND frmMsgTbl.MsgTypeId=${EFormMessageType.ori.value.toString()}";
      Log.d("CreateFormLocalDataSource::getFieldCopyFormHtml5Json query=$query");
      var mapOfDataList = databaseManager.executeSelectFromTable(FormMessageDao.tableName, query);
      if (mapOfDataList.isNotEmpty) {
        var rowData = mapOfDataList.first;
        String locationId = rowData["LocationId"].toString();
        String formTypeId = rowData["FormTypeId"].toString();
        bool bIsCalibrated = (rowData["IsCalibrated"] == 1) ? true : false;
        String strDataJson = rowData["JsonData"];
        paramData["formTypeId"] = formTypeId;
        paramData["locationId"] = locationId;
        paramData["isCalibrated"] = bIsCalibrated;
        String createFormFileDir = await AppPathHelper().getAppDataFormTypeDirectory(projectId: projectId, formTypeId: formTypeId);
        String createFormPath = "$createFormFileDir/ORI_VIEW.html";
        String customAttributeViewName = "ORI_VIEW";
        String oriViewHtmlData = readFromFile(createFormPath);
        strDataJson = readFromFile("$createFormFileDir/data.json");
        if (oriViewHtmlData != "" && strDataJson != "") {
          String oriView = "<script type=\"text/javascript\">var isOriView=true</script></head>";
          String fixFieldJson = await getFormTypeFixFieldDataJson(projectId, formTypeId);
          try {
            var dataJsonNode = jsonDecode(strDataJson);
            try {
              if (paramData.containsKey("DYNAMIC_TOTALMAPPING") && paramData["DYNAMIC_TOTALMAPPING"] > 0) {
                var fieldValueMap = fieldValueMapFromCopyParamData(paramData);
                dataJsonNode = updateJsonDataFieldValue(dataJsonNode, fieldValueMap);
              }
              paramData.remove("formId");
              paramData.remove("msgId");
              paramData['formCreationDate'] = Utility.offlineFormCreationDate();
              paramData['appTypeId'] = rowData["AppTypeId"].toString();
              paramData['instanceGroupId'] = rowData["InstanceGroupId"].toString();
              paramData['templateType'] = rowData["TemplateTypeId"].toString();
              paramData['appBuilderId'] = rowData["AppBuilderId"].toString();
              if (dataJsonNode.containsKey("Asite_System_Data_Read_Only")) {
                if (dataJsonNode["FORM_CUSTOM_FIELDS"]["ORI_MSG_Custom_Fields"]["OriginatorId"] != null) {
                  dataJsonNode["FORM_CUSTOM_FIELDS"]["ORI_MSG_Custom_Fields"]["OriginatorId"] = "";
                }
                if (dataJsonNode["Asite_System_Data_Read_Only"]["_1_User_Data"]["DS_WORKINGUSER"] != null) {
                  dataJsonNode["Asite_System_Data_Read_Only"]["_1_User_Data"]["DS_WORKINGUSER"] = await getSPData_DS_WORKINGUSER(paramData, fixFieldJson);
                }
                if (dataJsonNode["Asite_System_Data_Read_Only"]["_5_Form_Data"]["DS_ISDRAFT"] != null) {
                  dataJsonNode["Asite_System_Data_Read_Only"]["_5_Form_Data"]["DS_ISDRAFT"] = "NO";
                }
                if (dataJsonNode["Asite_System_Data_Read_Only"]["_5_Form_Data"]["DS_ISDRAFT_FWD_MSG"] != null) {
                  dataJsonNode["Asite_System_Data_Read_Only"]["_5_Form_Data"]["DS_ISDRAFT_FWD_MSG"] = "NO";
                }
                if (dataJsonNode["Asite_System_Data_Read_Only"]["_4_Form_Type_Data"]["DS_FORMNAME"] != null) {
                  dataJsonNode["Asite_System_Data_Read_Only"]["_4_Form_Type_Data"]["DS_FORMNAME"] = await getSPData_DS_FORMNAME(paramData, fixFieldJson);
                }
                if (dataJsonNode["Asite_System_Data_Read_Only"]["_4_Form_Type_Data"]["DS_FORMGROUPCODE"] != null) {
                  dataJsonNode["Asite_System_Data_Read_Only"]["_4_Form_Type_Data"]["DS_FORMGROUPCODE"] = await getSPData_DS_FORMGROUPCODE(paramData, fixFieldJson);
                }
              }
            } catch (e) {
              Log.d("CreateFormLocalDataSource::getHTML5ChangeSPDataInJsonData exception=$e");
            }
            strDataJson = jsonEncode(dataJsonNode);
            strDataJson = strDataJson.replaceAll("\"", "&quot;");
            oriViewHtmlData = oriViewHtmlData.replaceAll("<script attr=\"src=", "<script src=\"");
            oriViewHtmlData = oriViewHtmlData.replaceAll("\${JSON_DATA}", strDataJson);
            oriViewHtmlData = oriViewHtmlData.replaceAll("</head>", oriView);
            String customAttribute = await getFormTypeViewCustomAttributeData(formTypeId: formTypeId, projectId: projectId, viewName: customAttributeViewName);
            if (customAttribute.isNotEmpty) {
              oriViewHtmlData = await addFormTypeCustomAttributeInHtml(oriViewHtmlData, customAttribute, projectId, formTypeId);
            }
            String sPAttribute = await getFormTypeViewFixFieldSPData(formTypeId: formTypeId, projectId: projectId, viewName: customAttributeViewName);
            if (sPAttribute.isNotEmpty) {
              oriViewHtmlData = await addFormTypeSPDataInHtml(oriViewHtmlData, sPAttribute, paramData, "");
            }
            String createHtmlFilePath = "${await AppPathHelper().getAssetHTML5FormZipPath()}/offlineCreateForm.html";
            createHtmlData = readFromFile(createHtmlFilePath);
            if (createHtmlData.isNotEmpty) {
              var hiddenFieldMap = {
                "msg_type_id": EFormMessageType.ori.value.toString(),
                "msg_type_code": EFormMessageType.ori.name,
                "dist_list": "",
                "formAction": "create",
                "project_id": projectId,
                "offlineProjectId": projectId,
                "offlineFormTypeId": formTypeId,
                "assocLocationSelection": "",
              };
              String annotationId = paramData["annotationId"]?.toString() ?? "";
              String coordinates = paramData["coordinates"]?.toString() ?? "";
              if (annotationId.isNotEmpty) {
                hiddenFieldMap["annotationId"] = annotationId;
              }
              if (coordinates.isNotEmpty) {
                hiddenFieldMap["coordinates"] = coordinates;
              }
              String htmlHiddenField = FormHtmlUtility().getHTMLHiddenFieldAttributeData(htmlAttributeMap: hiddenFieldMap);
              createHtmlData = createHtmlData.replaceAll("<div id=\"offlineCreateHiddenForm\"></div>", htmlHiddenField);
              createHtmlData = createHtmlData.replaceAll("<div id=\"sHtml\"></div>", oriViewHtmlData);
              String configData = await getOfflineConfigDataJson(paramData, EHtmlRequestType.create);
              if (configData.isNotEmpty) {
                configData = configData.replaceAll("\\", "\\\\");
                configData = configData.replaceAll("\"", "\\\"");
                createHtmlData = createHtmlData.replaceAll("REPLACE_CONFIG_DATA", configData);
              }
            }
          } catch (e) {}
        } else {
          Log.d("CreateFormLocalDataSource::getFieldCopyFormHtml5Json empty ${(oriViewHtmlData.isEmpty) ? "htmlFileData" : ""} ${(strDataJson.isEmpty) ? "dataJson" : ""}");
        }
      } else {
        Log.d("CreateFormLocalDataSource::getFieldCopyFormHtml5Json query result empty");
      }
    } else {
      Log.d("CreateFormLocalDataSource::getFieldCopyFormHtml5Json empty ${(projectId.isEmpty) ? "projectId" : ""} ${(formId.isEmpty) ? "formId" : ""}");
    }
    return createHtmlData;
  }

  Map<String, dynamic> fieldValueMapFromCopyParamData(Map<String, dynamic> paramData) {
    Map<String, dynamic> dataMap = {};
    int fieldCount = int.parse(paramData["DYNAMIC_TOTALMAPPING"]?.toString() ?? "0");
    if (fieldCount > 0) {
      for (int iCount = 1; iCount <= fieldCount; iCount++) {
        dataMap[paramData["TG$iCount"]] = paramData["SRC$iCount"];
      }
    }
    return dataMap;
  }

  dynamic updateJsonDataFieldValue(dynamic jsonNode, Map<String, dynamic> fieldValueMap) {
    if (jsonNode is List) {
      for (var i = 0; i < jsonNode.length; i++) {
        jsonNode[i] = updateJsonDataFieldValue(jsonNode[i], fieldValueMap);
      }
    } else if (jsonNode is Map) {
      for (var entry in jsonNode.entries) {
        var key = entry.key;
        if (fieldValueMap.containsKey(key.toString())) {
          jsonNode[key] = fieldValueMap[key.toString()];
        } else {
          jsonNode[key] = updateJsonDataFieldValue(jsonNode[key], fieldValueMap);
        }
      }
    }
    return jsonNode;
  }

  Future<String> _editOriHtmlFormData(Map<String, dynamic> paramData, EHtmlRequestType eHtmlRequestType) async {
    String editOriHtmlData = "";
    var strProjectId = paramData["projectId"].toString();
    String strMsgId = (paramData["msgId"] ?? "").toString().plainValue();
    String strParentMsgId = (paramData["parent_msg_id"] ?? "").toString().plainValue();
    var strFormId = paramData["formId"].toString();
    var strFormTypeId = paramData["formTypeId"].toString();
    FormMessageVO? frmMsgVo = await getFormMessageVOFromDB(projectId: strProjectId, formId: strFormId, msgId: strMsgId);
    if (frmMsgVo != null) {
      var strDataJsonFileData = frmMsgVo.jsonData.toString();
      String createFormFileDir = "${await AppPathHelper().getAppDataFormTypeDirectory(projectId: strProjectId, formTypeId: strFormTypeId)}/";
      String createFormPath = "${createFormFileDir}ORI_VIEW.html";
      String customAttributeViewName = "ORI_VIEW";
      String strHtmlFileData = "";
      strHtmlFileData = readFromFile(createFormPath);
      if (strHtmlFileData != "" && strDataJsonFileData != "") {
        strDataJsonFileData = await getHTML5ChangeSPDataInJsonData(eHtmlRequestType, strDataJsonFileData, paramData);
        strDataJsonFileData = updateJsonDataForInlineAttachments(jsonDecode(strDataJsonFileData), (String strOldValue, String strKeyName) {
          return getFormMessageInlineAttachmentContentValue(FormMessageAttachAndAssocDao.tableName, strOldValue, strKeyName);
        });
        String oriView = "<script type=\"text/javascript\">var isOriView=true</script></head>";
        strDataJsonFileData = strDataJsonFileData.replaceAll("\"", "&quot;");
        strHtmlFileData = strHtmlFileData.replaceAll("<script attr=\"src=", "<script src=\"");
        strHtmlFileData = strHtmlFileData.replaceAll("\${JSON_DATA}", strDataJsonFileData);
        strHtmlFileData = strHtmlFileData.replaceAll("</head>", oriView);
        String customAttribute = await getFormTypeViewCustomAttributeData(formTypeId: strFormTypeId, projectId: strProjectId, viewName: customAttributeViewName);
        if (customAttribute.isNotEmpty) {
          strHtmlFileData = await addFormTypeCustomAttributeInHtml(strHtmlFileData, customAttribute, strProjectId, strFormTypeId);
        }
        String sPAttribute = await getFormTypeViewFixFieldSPData(formTypeId: strFormTypeId, projectId: strProjectId, viewName: customAttributeViewName);
        if (sPAttribute.isNotEmpty) {
          strHtmlFileData = await addFormTypeSPDataInHtml(strHtmlFileData, sPAttribute, paramData, "");
        }
        String replyHtmlFilePath = "${await AppPathHelper().getAssetHTML5FormZipPath()}/offlineCreateForm.html";
        editOriHtmlData = readFromFile(replyHtmlFilePath);
        var hiddenFieldMap = {"msg_type_id": EFormMessageType.ori.value, "msg_type_code": EFormMessageType.ori.name, "msgId": strParentMsgId, "dist_list": "", "formAction": "edit", "editORI": "true", "editDraft": "false", "assocLocationSelection": "", "project_id": strProjectId, "offlineProjectId": strProjectId, "offlineFormTypeId": strFormTypeId, "requestType": eHtmlRequestType.value};
        String htmlHiddenField = FormHtmlUtility().getHTMLHiddenFieldAttributeData(htmlAttributeMap: hiddenFieldMap);
        editOriHtmlData = editOriHtmlData.replaceAll("<div id=\"offlineCreateHiddenForm\"></div>", htmlHiddenField);
        editOriHtmlData = editOriHtmlData.replaceAll("<div id=\"sHtml\"></div>", strHtmlFileData);
        String configData = await getOfflineConfigDataJson(paramData, eHtmlRequestType);
        if (configData.isNotEmpty) {
          configData = configData.replaceAll("\\", "\\\\");
          configData = configData.replaceAll("\"", "\\\"");
          editOriHtmlData = editOriHtmlData.replaceAll("REPLACE_CONFIG_DATA", configData);
        }
      }
    }
    return editOriHtmlData;
  }

  String? getCustomAttributeSetDataByAttributeSetId(String projectId, String attributeSetId) {
    String strCustAttr = "";
    String selectQuery = "SELECT * FROM ${CustomAttributeSetDao.tableName}";
    selectQuery = "$selectQuery WHERE ProjectId=$projectId AND AttributeSetId=$attributeSetId";
    Log.d("CreateFormLocalDataSource::_generateRandomPin Location Detail query=$selectQuery");
    var mapOfLocationList = databaseManager.executeSelectFromTable(LocationDao.tableName, selectQuery);
    if (mapOfLocationList.isNotEmpty) {
      strCustAttr = mapOfLocationList.first[CustomAttributeSetDao.serverResponseField];
    }
    return strCustAttr;
  }

  Future<bool> updateFormMsgAttachAndAssocData(String strTableName, String strProjectId1, String strFormId1, List<String> vecInlineAttachRevIdList, formAttachList) async {
    bool isSuccess = false;
    try {
      String strProjectId = strProjectId1.plainValue();
      String strFormId = strFormId1.plainValue();
      String strInlineAttachRevIds = vecInlineAttachRevIdList.toList().join(",");
      String strQuery = "", strSelectQuery = "", strDeleteQuery = "";
      strQuery = "$strQuery WHERE ProjectId=$strProjectId";
      strQuery = "$strQuery AND FormId=$strFormId";
      strQuery = "$strQuery AND AttachmentType=${EAttachmentAndAssociationType.attachments.value}";
      strQuery = "$strQuery AND AttachRevId IN ($strInlineAttachRevIds)";
      strSelectQuery = "SELECT * FROM $strTableName$strQuery";
      strDeleteQuery = "DELETE FROM $strTableName$strQuery";
      var tableResult = databaseManager.executeSelectFromTable(strTableName, strSelectQuery);
      if (tableResult.isNotEmpty) {
        for (var colm in tableResult) {
          FormMessageAttachAndAssocVO pItem = await getFormFileAssocFromAttachJson(colm);
          formAttachList.add(pItem);
        }
        Log.e(strDeleteQuery);
        databaseManager.executeTableRequest(strDeleteQuery);
      }
      isSuccess = true;
    } catch (e) {
      Log.e("::updateFormMsgAttachAndAssocData::", e);
    }
    return isSuccess;
  }

  Future<FormMessageAttachAndAssocVO> getFormFileAssocFromAttachJson(data) {
    FormMessageAttachAndAssocVO tmpMsgAttachData = FormMessageAttachAndAssocVO();
    tmpMsgAttachData.setProjectId = data[FormMessageAttachAndAssocDao.projectIdField];
    tmpMsgAttachData.setFormTypeId = data[FormMessageAttachAndAssocDao.formTypeIdField];
    tmpMsgAttachData.setFormId = data[FormMessageAttachAndAssocDao.formIdField];
    tmpMsgAttachData.setFormMsgId = data[FormMessageAttachAndAssocDao.msgIdField];
    tmpMsgAttachData.setAssocProjectId = data[FormMessageAttachAndAssocDao.projectIdField];
    tmpMsgAttachData.setAssocDocRevisionId = data[FormMessageAttachAndAssocDao.attachRevIdField];
    tmpMsgAttachData.setAttachType = EAttachmentAndAssociationType.files.value.toString();
    Map<String, dynamic> attachJson = jsonDecode(data[FormMessageAttachAndAssocDao.attachAssocDetailJsonField]);
    return getAssocFileVOFromAttachVO(attachJson, tmpMsgAttachData, {
      "fileName": attachJson["fileName"],
      "fileSize": attachJson["fileSize"],
      "fileType": attachJson["fileType"],
      "attachDocId": attachJson["docId"],
      "publishDate": attachJson["attachedDate"],
      "msgCreationDate": attachJson["msgCreationDate"],
      "parentMsgCode": attachJson["parentMsgCode"],
    });
  }

  Future<FormMessageAttachAndAssocVO> getAssocFileVOFromAttachVO(pItem, FormMessageAttachAndAssocVO tmpMsgAttachData, Map<String, dynamic> paramObj) async {
    var pUsp = await user;
    String attachUserId = pUsp?.usersessionprofile!.userID.plainValue();
    String docRef = getFileNameWithoutExtention(paramObj["fileName"]);

    Map<String, dynamic> pAssocData = {};
    pAssocData["fileType"] = paramObj["fileType"]; // "filetype/noicon.gif",
    pAssocData["fileName"] = paramObj["fileName"];
    pAssocData["filePath"] = "";
    pAssocData["status"] = "";
    pAssocData["statusId"] = 0;
    pAssocData["purposeOfIssue"] = "";
    pAssocData["poiId"] = 0;
    pAssocData["directLink"] = "";
    pAssocData["revisionId"] = paramObj["attachDocId"]; //: "7804330$$baLp6F",
    pAssocData["fileSize"] = paramObj["fileSize"];
    pAssocData["folderPath"] = "";
    pAssocData["isLock"] = false;
    pAssocData["hasAccess"] = false;
    pAssocData["docTypeId"] = 0;
    pAssocData["modelId"] = "0";
    pAssocData["viewerId"] = 0;
    pAssocData["canDownload"] = false;
    pAssocData["publisherUserId"] = int.tryParse(attachUserId) ?? 0;
    pAssocData["hasBravaSupport"] = false;
    pAssocData["docId"] = paramObj["attachDocId"]; //: "10928201$$pXXxiM",
    pAssocData["docRef"] = docRef;
    pAssocData["title"] = docRef;
    pAssocData["uploadFileName"] = paramObj["fileName"];
    pAssocData["revisionNum"] = "1";
    pAssocData["is_public"] = false;
    pAssocData["is_private"] = false;
    pAssocData["has_assoc_form"] = false;
    pAssocData["has_comment_type"] = false;
    pAssocData["has_comments"] = false;
    pAssocData["is_link"] = false;
    pAssocData["has_attachment"] = false;
    pAssocData["hasXref"] = false;
    pAssocData["has_markup"] = false;
    pAssocData["viewer_id"] = 0;
    pAssocData["publishDate"] = paramObj["publishDate"]; //: "Jan 4, 2020 6:03:00 AM",
    pAssocData["linked_rev_id"] = 0;
    pAssocData["linkType"] = "";
    pAssocData["documentTypeId"] = 1;
    pAssocData["bim_model_id"] = 0;
    pAssocData["proxy_user_id"] = 0;
    pAssocData["publisherName"] = pUsp?.usersessionprofile?.firstName;
    pAssocData["checkOutStatus"] = false;
    pAssocData["checkOutUserId"] = 0;
    pAssocData["issueNo"] = 1;
    pAssocData["firstName"] = "";
    pAssocData["lastName"] = "";
    pAssocData["isUserFolderAdmin"] = false;
    pAssocData["flagType"] = 0;
    pAssocData["isAccess"] = true;
    pAssocData["isDocActive"] = true;
    pAssocData["folderPermissionValue"] = 1023;
    pAssocData["isRevInDistList"] = true;
    pAssocData["viewAlwaysFormAssociationParent"] = false;
    pAssocData["viewAlwaysDocAssociationParent"] = false;
    pAssocData["allowDownloadToken"] = "0";
    pAssocData["publisherOrgName"] = "";
    pAssocData["attachmentId"] = "0";
    pAssocData["isEntireDocActive"] = true;
    pAssocData["canAccessDeactivatedDocs"] = true;
    pAssocData["type"] = EAttachmentAndAssociationType.files.value;
    pAssocData["msgId"] = tmpMsgAttachData.formMsgId; //: "10530159$$Zrxgpq",
    pAssocData["msgCreationDate"] = paramObj["msgCreationDate"]; //: "Jan 4, 2020 6:03:00 AM",
    pAssocData["projectId"] = tmpMsgAttachData.projectId; //: "2112709$$TyX4sl",
    pAssocData["folderId"] = "0"; //: "84758422$$gZbhz2",
    pAssocData["dcId"] = 1; //: 1,
    pAssocData["projectName"] = "";
    pAssocData["childProjectId"] = 0;
    pAssocData["userId"] = 0;
    pAssocData["resourceId"] = 0;
    pAssocData["parentMsgId"] = int.tryParse(tmpMsgAttachData.formMsgId.toString()) ?? 0; //: 10530159,
    pAssocData["parentMsgCode"] = paramObj["parentMsgCode"]; //: "ORI001",
    pAssocData["assocsParentId"] = "0";
    pAssocData["totalDocCount"] = 1;
    pAssocData["generateURI"] = true;
    pAssocData["publisherImage"] = "";
    pAssocData["hasOnlineViewerSupport"] = false;
    pAssocData["hasOnlineViewerSupportForAttachment"] = false;
    pAssocData["downloadImageName"] = ""; //: "icons/downloads.png"
    pAssocData["flagTypeImageName"] = "";
    pAssocData["commentImgName"] = "";
    pAssocData["attachmentImgName"] = "";
    pAssocData["assocFormImgName"] = "";
    pAssocData["chkStatusImgName"] = "";

    tmpMsgAttachData.setAttachAssocDetailJson = jsonEncode(pAssocData);
    return tmpMsgAttachData;
  }
}
