import 'dart:convert';

import 'package:field/data/dao/form_message_action_dao.dart';
import 'package:field/data/dao/formtype_dao.dart';
import 'package:field/data/dao/project_dao.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/utils/extensions.dart';

import '../../data/dao/form_dao.dart';
import '../../data/dao/form_message_attachAndAssoc_dao.dart';
import '../../data/dao/form_message_dao.dart';
import '../../logger/logger.dart';
import '../../utils/app_path_helper.dart';
import '../../utils/field_enums.dart';
import '../../utils/file_utils.dart';
import 'form_local_data_source.dart';

class ViewFormLocalDataSource extends FormLocalDataSource {
  static ViewFormLocalDataSource? _instance;

  ViewFormLocalDataSource._();

  factory ViewFormLocalDataSource() => _instance ??= ViewFormLocalDataSource._();

  Future<String> getOfflineHTML5ProjectPrivilegeListJson(Map<String, dynamic> paramData) async {
    String data = "";
    try {
      String projectId = (paramData["projectId"]?.toString() ?? "").plainValue();
      String query = "SELECT ${ProjectDao.privilegeField} FROM ${ProjectDao.tableName}\n"
          "WHERE ${ProjectDao.projectIdField}=$projectId";
      var result = databaseManager.executeSelectFromTable(ProjectDao.tableName, query);
      if (result.isNotEmpty) {
        var dataRow = result.first;
        var dataMap = {"privileges": dataRow[ProjectDao.privilegeField].toString()};
        data = jsonEncode(dataMap);
      }
    } on Exception catch (e) {
      Log.d("ViewFormLocalDataSource::getOfflineHTML5ProjectPrivilegeListJson error=${e.toString()}");
    }
    return data;
  }

  Future<String> getOfflineFormMessagePrivilegeListJson(Map<String, dynamic> paramData) async {
    String data = "";
    try {
      String projectId = (paramData["projectId"]?.toString() ?? "").plainValue();
      String formId = (paramData["formId"]?.toString() ?? "").plainValue();
      String msgId = (paramData["msgId"]?.toString() ?? "").plainValue();
      String query = "SELECT ${FormMessageDao.formPermissionsMapField} FROM ${FormMessageDao.tableName}\n"
          "WHERE ${FormMessageDao.projectIdField}=$projectId AND ${FormMessageDao.formIdField}=$formId AND ${FormMessageDao.msgIdField}=$msgId";
      var result = databaseManager.executeSelectFromTable(FormMessageDao.tableName, query);
      if (result.isNotEmpty) {
        var dataRow = result.first;
        data = dataRow[FormMessageDao.formPermissionsMapField].toString();
      }
    } on Exception catch (e) {
      Log.d("ViewFormLocalDataSource::getOfflineFormMessagePrivilegeListJson error=${e.toString()}");
    }
    return data.isNullOrEmpty() ? "{}" : data;
  }

  Future<String?> getOfflineFormMessageListJson({required String projectId, required String formId}) async {
    try {
      projectId = projectId.plainValue();
      formId = formId.plainValue();
      String selectQuery = "WITH MsgTreeLevel AS (SELECT MsgId,-1 AS Indent FROM \n"
          "${FormMessageDao.tableName} WHERE ProjectId=$projectId AND FormId=$formId AND ParentMsgId=0 UNION \n"
          "SELECT frmMsg.MsgId,t.Indent+1 FROM ${FormMessageDao.tableName} frmMsg, MsgTreeLevel t WHERE \n"
          "frmMsg.ProjectId=$projectId AND frmMsg.FormId=$formId AND frmMsg.ParentMsgId=t.MsgId)\n"
          "SELECT msgTrLvl.Indent, frmTbl.StatusChangeUserId, frmTbl.FlagType, frmTbl.Code, frmTbl.OriginatorId, frmTbl.FormTitle, frmTbl.OrgId,\n"
          "frmTbl.FirstName, frmTbl.LastName, frmTbl.OrgName, frmTbl.DocType, frmTbl.FormCreationDate, frmTbl.FormNumber, frmTbl.FormHasAssocAttach,\n"
          "frmTbl.StatusId, frmTbl.Status, frmTbl.FormTypeId, frmTypeTbl.TemplateTypeId, frmTypeTbl.FormTypeName, frmTypeTbl.FormTypeGroupName,\n"
          "prjTbl.ProjectName, prjTbl.DcId AS DcId, frmMsgTbl.* FROM ${FormMessageDao.tableName} frmMsgTbl\n"
          "INNER JOIN ${ProjectDao.tableName} prjTbl ON prjTbl.ProjectId=frmMsgTbl.ProjectId\n"
          "INNER JOIN ${FormTypeDao.tableName} frmTypeTbl ON frmTypeTbl.ProjectId=frmMsgTbl.ProjectId AND frmTypeTbl.FormTypeId=frmTbl.FormTypeId\n"
          "INNER JOIN ${FormDao.tableName} frmTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId\n"
          "INNER JOIN MsgTreeLevel msgTrLvl ON msgTrLvl.MsgId=frmMsgTbl.MsgId\n"
          "WHERE frmMsgTbl.ProjectId=$projectId\n"
          "AND frmMsgTbl.FormId=$formId\n"
          "ORDER BY frmMsgTbl.MsgCreatedDateInMS ASC";
      Log.d("getOfflineFormMessagesListJson query=$selectQuery");
      var mapOfFormMessageList = databaseManager.executeSelectFromTable(FormMessageDao.tableName, selectQuery);
      Log.d("getOfflineFormMessagesListJson mapOfFormMessageList size=${mapOfFormMessageList.length}");
      Map formMessageMap = <String, dynamic>{};
      formMessageMap["totalDocs"] = mapOfFormMessageList.length;
      formMessageMap["recordBatchSize"] = 25;
      formMessageMap["listingType"] = 31;
      formMessageMap["currentPageNo"] = 0;
      formMessageMap["recordStartFrom"] = 0;
      formMessageMap["totalListData"] = 0;
      formMessageMap["editable"] = false;
      formMessageMap["isIncludeSubFolder"] = true;
      List<Map<String, dynamic>> formMessageList = [];
      for (var element in mapOfFormMessageList) {
        Map<String, dynamic> messageMap = {};
        messageMap["appType"] = element['TemplateTypeId'];
        messageMap["projectId"] = element['ProjectId'];
        messageMap["formTypeId"] = element['FormTypeId'];
        messageMap["formId"] = element['FormId'];
        messageMap["msgId"] = element['MsgId'];
        messageMap["dcId"] = element['DcId'];
        messageMap["originatorId"] = element['OriginatorId'];
        messageMap["originator"] = element['Originator'];
        messageMap["originatorDisplayName"] = element['OriginatorDisplayName'];
        messageMap["msgCode"] = element['MsgCode'];
        messageMap["msgCreatedDate"] = element['MsgCreatedDate'];
        messageMap["parentMsgId"] = element['ParentMsgId'];
        messageMap["msgOriginatorId"] = element['MsgOriginatorId'];
        messageMap["msgTypeId"] = element['MsgTypeId'];
        messageMap["msgTypeCode"] = element['MsgTypeCode'];
        messageMap["folderId"] = element['FolderId'] ?? "0";
        messageMap["msgHasAssocAttach"] = (element['MsgHasAssocAttach'] as int).isOne;
        messageMap["jsonData"] = element['JsonData'];
        messageMap["userRefCode"] = element['UserRefCode'];
        messageMap["updatedDateInMS"] = element['UpdatedDateInMS'];
        messageMap["formCreationDateInMS"] = element['FormCreationDateInMS'];
        messageMap["msgCreatedDateInMS"] = element['MsgCreatedDateInMS'];
        messageMap["duration"] = "";
        messageMap["projectName"] = element['ProjectName'];
        messageMap["code"] = element['Code'];
        messageMap["title"] = element['FormTitle'];
        messageMap["orgId"] = element['OrgId'];
        messageMap["firstName"] = element["FirstName"];
        messageMap["lastName"] = element["LastName"];
        messageMap["orgName"] = element["OrgName"];
        messageMap["docType"] = element["DocType"];
        messageMap["formCreationDate"] = element["FormCreationDate"];
        messageMap["formNum"] = element["FormNumber"];
        messageMap["templateType"] = element["TemplateTypeId"];
        messageMap["instanceGroupId"] = element["InstanceGroupId"];
        messageMap["formTypeName"] = element["FormTypeName"];
        messageMap["latestDraftId"] = element["LatestDraftId"];
        bool isEditFormOffline = (element["OfflineRequestData"].toString().isNotEmpty && !((element["IsDraft"] as int).isOne));
        messageMap["isEditFormOffline"] = isEditFormOffline;
        messageMap["isDraft"] = (element["OfflineRequestData"].toString().isNotEmpty || (element["IsDraft"] as int).isOne);
        messageMap["canOrigChangeStatus"] = (element["CanOrigChangeStatus"] as int).isOne;
        messageMap["canControllerChangeStatus"] = (element["CanControllerChangeStatus"] as int).isOne;
        messageMap["isStatusChangeRestricted"] = (element["IsStatusChangeRestricted"] as int).isOne;
        messageMap["isCloseOut"] = (element["IsCloseOut"] as int).isOne;
        messageMap["allowReopenForm"] = element["AllowReopenForm"] == 1 ? true : false;
        messageMap["statusid"] = element["StatusId"];
        messageMap["status"] = element["Status"];
        messageMap["statusText"] = element["Status"];
        messageMap["formGroupName"] = element["FormTypeGroupName"];
        messageMap["commId"] = element["FormId"];
        messageMap["msgStatusName"] = element["MsgStatusName"];
        messageMap["project_APD_folder_id"] = element["ProjectAPDFolderId"];
        messageMap["observationId"] = element["ObservationId"];
        messageMap["locationId"] = element["LocationId"];
        messageMap["msgStatusId"] = (element["OfflineRequestData"] != "") ? "19" : element["MsgStatusId"];
        messageMap["showPrintIcon"] = 1;
        messageMap["statusChangeUserId"] = element["StatusChangeUserId"];
        messageMap["flagType"] = element["FlagType"];
        messageMap["projectStatusId"] = element["ProjectStatusId"];
        messageMap["hasAttachments"] = (element["HasAttach"] as int).isOne;
        messageMap["hasDocAssocations"] = (element["HasDocAssocations"] as int).isOne;
        messageMap["hasBimViewAssociations"] = (element["HasBimViewAssociations"] as int).isOne;
        messageMap["hasBimListAssociations"] = (element["HasBimListAssociations"] as int).isOne;
        messageMap["hasFormAssocations"] = (element["HasFormAssocations"] as int).isOne;
        messageMap["hasCommentAssocations"] = (element["HasCommentAssocations"] as int).isOne;
        messageMap["hasOverallStatus"] = (element["HasOverallStatus"] as int).isOne;
        messageMap["formHasAssocAttach"] = (element["FormHasAssocAttach"] as int).isOne;
        messageMap["formPrintEnabled"] = true;
        messageMap["hasFormAccess"] = (element["HasFormAccess"] as int).isOne;
        messageMap["canAccessHistory"] = (element["CanAccessHistory"] as int).isOne;
        if (!element["SentNames"].toString().isNullOrEmpty()) {
          messageMap["sentNames"] = jsonDecode(element["SentNames"]);
        }
        if (!element["ResponseRequestBy"].toString().isNullOrEmpty()) {
          messageMap["responseRequestBy"] = element["ResponseRequestBy"];
        }
        if (!element["AssocRevIds"].toString().isNullOrEmpty()) {
          messageMap["assocRevIds"] = jsonDecode(element["AssocRevIds"]);
        }
        if (!element["AssocFormIds"].toString().isNullOrEmpty()) {
          messageMap["assocFormIds"] = jsonDecode(element["AssocFormIds"]);
        }
        if (!element["AssocCommIds"].toString().isNullOrEmpty()) {
          messageMap["assocCommIds"] = jsonDecode(element["AssocCommIds"]);
        }
        if (!element["FormUserSet"].toString().isNullOrEmpty()) {
          messageMap["formUserSet"] = jsonDecode(element["FormUserSet"]);
        }
        String? actionResponse = await getOfflineMessagesActionList(projectId: projectId, formId: formId, msgId: messageMap["msgId"], actionId: null, isForAll: false);
        messageMap['actions'] = actionResponse != null ? jsonDecode(actionResponse) : [];
        String? allActionResponse = await getOfflineMessagesActionList(projectId: projectId, formId: formId, msgId: null, actionId: null, isForAll: true);
        messageMap['allActions'] = allActionResponse != null ? jsonDecode(allActionResponse) : [];
        messageMap['sentActions'] = [];
        formMessageList.add(messageMap);
      }
      formMessageMap['data'] = formMessageList;
      return jsonEncode(formMessageMap);
    } catch (e) {
      Log.d("getOfflineFormMessagesListJson error=${e.toString()}");
    }
    return null;
  }

  Future<String?> getOfflineMessagesActionList({required String projectId, required String formId, required String? msgId, required String? actionId, bool isForAll = true, String? sortField, String? sortType}) async {
    try {
      User? loginUser = await user;
      if (loginUser != null && loginUser.usersessionprofile != null) {
        String actionQuery = "SELECT * FROM ${FormMessageActionDao.tableName} \n"
            "WHERE RecipientUserId= ${loginUser.usersessionprofile!.userID} \n"
            "AND ProjectId= ${projectId.plainValue()} \n"
            "AND FormId= ${formId.plainValue()} \n";

        if (!msgId.isNullEmptyZeroOrFalse()) {
          actionQuery = "$actionQuery AND MsgId=$msgId \n";
        }
        if (!actionId.isNullOrEmpty() && actionId == "-1") {
          actionQuery = "$actionQuery AND ActionId=$actionId \n";
        }
        if (!isForAll) {
          actionQuery = "$actionQuery AND ActionStatus=0 \n";
        }
        if (!sortField.isNullOrEmpty() && !sortType.isNullOrEmpty()) {
          actionQuery = "$actionQuery ORDER BY =$sortField $sortType \n";
        }
        Log.d("getOfflineMessagesActionList query=$actionQuery");
        var mapOfMessageActionList = databaseManager.executeSelectFromTable(FormMessageActionDao.tableName, actionQuery);
        Log.d("getOfflineFormMessagesListJson mapOfMessageActionList size=${mapOfMessageActionList.length}");
        List<Map<String, dynamic>> formMessageActionList = [];
        for (var element in mapOfMessageActionList) {
          Map<String, dynamic> actionMap = {};
          actionMap["actionName"] = element["ActionName"];
          actionMap["actionDate"] = element["ActionDate"];
          actionMap["dueDate"] = element["ActionDueDate"];
          actionMap["remarks"] = element["Remarks"];
          actionMap["transNum"] = element["TransNum"];
          actionMap["actionTime"] = element["ActionTime"];
          actionMap["actionCompleteDate"] = element["ActionCompleteDate"];
          actionMap["actionNotes"] = element["ActionNotes"];
          actionMap["modelId"] = element["ModelId"];
          actionMap["assignedBy"] = element["AssignedBy"];
          actionMap["recipientName"] = element["RecipientName"];
          actionMap["recipientOrgId"] = element["RecipientOrgId"];
          actionMap["id"] = element["Id"];
          actionMap["viewDate"] = element["ViewDate"];
          actionMap["projectId"] = element["ProjectId"];
          actionMap["formTypeId"] = element["FormTypeId"];
          actionMap["formId"] = element["FormId"];
          actionMap["msgId"] = element["MsgId"];
          if (element["IsActive"] == "true" || element["IsActive"].toString() == "1") {
            actionMap["isActive"] = true;
          } else {
            actionMap["isActive"] = false;
          }
          actionMap["actionId"] = int.tryParse(element["ActionId"].toString());
          actionMap["actionStatus"] = int.tryParse(element["ActionStatus"].toString());
          actionMap["priorityId"] = int.tryParse(element["PriorityId"].toString());
          actionMap["distributorUserId"] = int.tryParse(element["DistributorUserId"].toString());
          actionMap["recipientId"] = int.tryParse(element["RecipientUserId"].toString());
          actionMap["distListId"] = int.tryParse(element["DistListId"].toString());
          actionMap["entityType"] = int.tryParse(element["EntityType"].toString());
          actionMap["resourceCode"] = element["ResourceCode"];
          actionMap["resourceParentId"] = int.tryParse(element["ResourceParentId"].toString());
          actionMap["resourceId"] = int.tryParse(element["ResourceId"].toString());
          actionMap["commentMsgId"] = element["CommentMsgId"];
          actionMap["notification_pushed"] = false;
          formMessageActionList.add(actionMap);
        }

        return jsonEncode(formMessageActionList);
      }
    } catch (e) {
      Log.d("ViewFormLocalDataSource::getOfflineFormMessagesListJson error=${e.toString()}");
    }
    return null;
  }

  Future<String> getOfflineFormMessageViewHtml(Map<String, dynamic> paramData) async {
    String viewHtml = "";
    String projectId = paramData["projectId"]?.toString().plainValue() ?? "";
    String formId = paramData["formId"]?.toString().plainValue() ?? "";
    String? msgId = paramData["msgId"]?.toString().plainValue();
    try {
      if (projectId.isNotEmpty && formId.isNotEmpty) {
        String curUserId = (await currentUserId)?.plainValue() ?? "";
        String query = "SELECT frmTypTbl.AppTypeId, frmTypTbl.AppBuilderId, frmTypTbl.FormTypeGroupCode, frmTypTbl.FormTypeName, frmTbl.ProjectId, frmTbl.FormTypeId, frmTbl.FormId, frmTbl.TemplateType, frmTbl.LocationId, frmTbl.ObservationId,\n"
            "frmTbl.FormTitle, frmTbl.OriginatorId, frmTbl.Code, frmTbl.Updated, frmMsgTbl.MsgOriginatorId, frmMsgTbl.OriginatorDisplayName, frmMsgTbl.MsgCode,\n"
            "frmMsgTbl.MsgCreatedDate, frmMsgTbl.MsgId, frmMsgTbl.MsgStatusId, frmMsgTbl.ParentMsgId, frmMsgTbl.MsgTypeId, frmTbl.IsDraft,\n"
            "frmMsgTbl.FixFieldData, frmMsgTbl.SentNames, frmMsgTbl.JsonData FROM ${FormDao.tableName} frmTbl\n"
            "INNER JOIN ${FormTypeDao.tableName} frmTypTbl ON frmTbl.ProjectId=frmTypTbl.ProjectId AND frmTbl.FormTypeId=frmTypTbl.FormTypeId\n"
            "INNER JOIN ${FormMessageDao.tableName} frmMsgTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId\n";
        if (msgId.isNullOrEmpty()) {
          query = "${query}AND frmTbl.MessageId=frmMsgTbl.MsgId";
        } else {
          query = "$query WHERE frmTbl.ProjectId=$projectId AND frmTbl.FormId=$formId AND frmMsgTbl.MsgId=${msgId!}";
        }
        var dbResult = databaseManager.executeSelectFromTable(FormDao.tableName, query);
        List<dynamic> data = [];
        if (dbResult.isNotEmpty) {
          var rowData = dbResult.first;
          String sentName = "";
          if (rowData["SentNames"].toString().isNotEmpty) {
            var sentNameListNode = jsonDecode(rowData["SentNames"].toString());
            for (var sentNameNode in sentNameListNode) {
              sentName = "$sentName${sentNameNode.toString().replaceAll(",", "#")},";
            }
            if (sentName.isNotEmpty) {
              sentName = sentName.substring(0, sentName.length - 1);
            }
          }
          updateOfflineFieldFormMessageActionStatus(rowData["ProjectId"].toString(), rowData["FormId"].toString(), rowData["MsgId"].toString(), EFormActionType.forInformation.value.toString()); /// Completed For-Info Action while viewing form
          var dataMap = {
            "appTypeId": rowData["AppTypeId"].toString(),
            "templateType": int.tryParse(rowData["TemplateType"].toString()),
            "msgId": rowData["MsgId"].toString(),
            "title": rowData["FormTitle"].toString(),
            "appBuilderFormIDCode": rowData["AppBuilderId"].toString(),
            "msgStatusId": int.parse(rowData["MsgStatusId"].toString()),
            "originatorId": int.parse(rowData["OriginatorId"].toString()),
            "id": rowData["Code"].toString(),
            "originator_user_id": rowData["MsgOriginatorId"].toString(),
            "msgCode": rowData["MsgCode"].toString(),
            "formId": rowData["FormId"].toString(),
            "formTypeId": rowData["FormTypeId"].toString(),
            "parentMsgId": rowData["ParentMsgId"].toString(),
            "isUserMsgOriginator": (rowData["MsgOriginatorId"].toString() == curUserId) ? true : false,
            "sent": sentName,
            "msgOriginator": rowData["OriginatorDisplayName"].toString(),
            "updated": rowData["Updated"].toString(),
            "projectId": rowData["ProjectId"].toString(),
            // bellow need to set
            "noOfAssocDocs": 0,
            "can_respond": false,
            "controllerUserId": 0,
            "can_forward": false,
            "viewAlwaysFormAssociation": false,
            "editORIDraftMsgId": "0",
            "dcId": 1,
            "allowDownloadToken": "",
            "allowViewRes": "true",
            "can_distribute": false,
            "viewAlwaysDocAssociation": true,
            "can_edit_ORI": false,
            "formUserSet": false,
            "originatorImage": "",
            "notificationLinkURL": "",
            "actions": [],
            "noOfAssociations": 0,
            //on demand of Android Team...
            "appBuilderId": rowData["AppBuilderId"].toString(),
            "formTypeCode": rowData["FormTypeGroupCode"].toString(),
            "formTypeName": rowData["FormTypeName"].toString(),
          };
          String htmlViewFileDir = await AppPathHelper().getAppDataFormTypeDirectory(projectId: rowData["ProjectId"].toString(), formTypeId: rowData["FormTypeId"].toString());
          String htmlViewFilePath = "", customAttributeViewName = "";
          if (EFormMessageType.fromString(rowData["MsgTypeId"].toString()) == EFormMessageType.res) {
            htmlViewFilePath = "$htmlViewFileDir/RES_PRINT_VIEW.html";
            customAttributeViewName = "RES_PRINT_VIEW";
            if (isFileExist(htmlViewFilePath) == false) {
              htmlViewFilePath = "$htmlViewFileDir/RES_VIEW.html";
              customAttributeViewName = "RES_VIEW";
              if (isFileExist(htmlViewFilePath) == false) {
                htmlViewFilePath = "";
                customAttributeViewName = "";
              }
            }
          }
          if (htmlViewFilePath.isEmpty) {
            htmlViewFilePath = "$htmlViewFileDir/ORI_PRINT_VIEW.html";
            customAttributeViewName = "ORI_PRINT_VIEW";
            if (isFileExist(htmlViewFilePath) == false) {
              htmlViewFilePath = "$htmlViewFileDir/ORI_VIEW.html";
              customAttributeViewName = "ORI_VIEW";
            }
          }
          String htmlFileContent = readFromFile(htmlViewFilePath);
          if (htmlFileContent.isNotEmpty) {
            String msgJsonData = rowData["JsonData"].toString();
            var paramMap = {
              "projectId": rowData["ProjectId"].toString(),
              "formTypeId": rowData["FormTypeId"].toString(),
              "formId": rowData["FormId"].toString(),
              "msgId": rowData["MsgId"].toString(),
            };
            msgJsonData = await getHTML5ChangeSPDataInJsonData(EHtmlRequestType.viewForm, msgJsonData, paramMap);
            //Need to check for inline here
            //Currently commented because of inline attachment issue
           msgJsonData = updateJsonDataForInlineAttachments(jsonDecode(msgJsonData), (String strOldValue, String strKeyName){
             return getFormMessageInlineAttachmentContentValue(FormMessageAttachAndAssocDao.tableName,strOldValue,strKeyName);
             });
            msgJsonData = msgJsonData.replaceAll("\"", "&quot;");

            htmlFileContent = htmlFileContent.replaceAll("<script attr=\"src=", "<script src=\"");
            htmlFileContent = htmlFileContent.replaceAll("\${JSON_DATA}", msgJsonData);
            htmlFileContent = htmlFileContent.replaceAll("\${staticContentPath}", "$htmlViewFileDir\\");
            htmlFileContent = htmlFileContent.replaceAll("</head>", "<script type=\"text/javascript\">var isOriView=true</script></head>");
            String strCustomAttribute = await getFormTypeViewCustomAttributeData(projectId: rowData["ProjectId"].toString(), formTypeId: rowData["FormTypeId"].toString(), viewName: customAttributeViewName);
            if (strCustomAttribute != "") {
              htmlFileContent = await addFormTypeCustomAttributeInHtml(htmlFileContent, strCustomAttribute, rowData["ProjectId"].toString(), rowData["FormTypeId"].toString());
            }
            String strSPAttribute = await getFormTypeViewFixFieldSPData(projectId: rowData["ProjectId"].toString(), formTypeId: rowData["FormTypeId"].toString(), viewName: customAttributeViewName);
            if (strSPAttribute != "") {
              htmlFileContent = await addFormTypeSPDataInHtml(htmlFileContent, strSPAttribute, paramMap, rowData["FixFieldData"].toString());
            }
            dataMap["html"] = htmlFileContent;
          }
          int attachCount = 0, assocDocCount = 0, assocDiscussionCount = 0, assocFormCount = 0, refFormCount = 0, assocViewsCount = 0, objectListCount = 0;
          query = "SELECT ${FormMessageAttachAndAssocDao.attachmentTypeField},COUNT(1) AS TotalCount FROM ${FormMessageAttachAndAssocDao.tableName}\n"
              "WHERE ${FormMessageAttachAndAssocDao.projectIdField}=${rowData["ProjectId"].toString()} AND ${FormMessageAttachAndAssocDao.formIdField}=${rowData["FormId"].toString()} AND ${FormMessageAttachAndAssocDao.msgIdField} IN (${rowData["MsgId"].toString()},0)\n"
              "GROUP BY ${FormMessageAttachAndAssocDao.attachmentTypeField}";
          var dbAttachResult = databaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, query);
          for (var element in dbAttachResult) {
            switch (EAttachmentAndAssociationType.fromString(element[FormMessageAttachAndAssocDao.attachmentTypeField].toString())) {
              case EAttachmentAndAssociationType.files:
                assocDocCount = int.parse(element["TotalCount"].toString());
                break;
              case EAttachmentAndAssociationType.discussions:
                assocDiscussionCount = int.parse(element["TotalCount"].toString());
                break;
              case EAttachmentAndAssociationType.apps:
                assocFormCount = int.parse(element["TotalCount"].toString());
                break;
              case EAttachmentAndAssociationType.attachments:
                attachCount = int.parse(element["TotalCount"].toString());
                break;
              case EAttachmentAndAssociationType.references:
                refFormCount = int.parse(element["TotalCount"].toString());
                break;
              case EAttachmentAndAssociationType.views:
                assocViewsCount = int.parse(element["TotalCount"].toString());
                break;
              case EAttachmentAndAssociationType.lists:
                objectListCount = int.parse(element["TotalCount"].toString());
                break;
              default:
                break;
            }
          }
          var assocCountMap = {
            "assoc_doc_count": assocDocCount,
            "assoc_discussion_count": assocDiscussionCount,
            "assoc_form_count": assocFormCount,
            "attach_count": attachCount,
            "ref_form_count": refFormCount,
            "assoc_views_count": assocViewsCount,
            "objectList_count": objectListCount,
            "ref_file_count": 0,
            "serialversionuid": 0,
            "disableLink": false,
            "ref_discussion_count": 0,
          };
          dataMap["assocCount"] = assocCountMap;
          dataMap["noOfAttachments"] = attachCount;
          data.add(dataMap);
        }
        viewHtml = jsonEncode(data);
      }
    } on Exception catch (e) {
      Log.d("ViewFormLocalDataSource::getOfflineFormMessageViewHtml error=${e.toString()}");
    }
    return viewHtml;
  }

  Future<String> getOfflineFormViewHtml(Map<String, dynamic> paramData) async {
    await init();
    String htmlFilePath = await AppPathHelper().getOfflineViewFormHTMLFilePath();
    String htmlData = readFromFile(htmlFilePath);
    if (htmlData.isNotEmpty) {
      String configData = await getOfflineConfigDataJson(paramData, EHtmlRequestType.viewForm);
      if (configData.isNotEmpty) {
        configData = configData.replaceAll("\\", "\\\\");
        configData = configData.replaceAll("\"", "\\\"");
        configData = "\"$configData\"";
        htmlData = htmlData.replaceAll("Field.getDataForView()", configData);
      }
    }
    return htmlData;
  }

  Future<String> getOfflineFormStatusHistoryListJson(Map<String, dynamic> paramData) async {
    String data = "";
    try {
      String projectId = (paramData["projectId"]?.toString() ?? "").plainValue();
      String formId = (paramData["formId"]?.toString() ?? "").plainValue();
      String query = "SELECT * FROM ${FormDao.tableName}\n"
          "WHERE ${FormDao.projectIdField}=$projectId AND ${FormDao.formIdField}=$formId";
      var result = databaseManager.executeSelectFromTable(FormDao.tableName, query);
      if (result.isNotEmpty) {
        var dataRow = result.first;
        var dataMap = {
          "msgOriginatorId": dataRow["OriginatorId"].toString(), //"msgOriginatorId": "707447$$L1XUjX",
          //"Actions": [],
          "formTypeId": dataRow["FormTypeId"].toString(), //"formTypeId": "10333236$$pudYB8",
          "selectedFormId": int.parse(dataRow["FormId"].toString()), //"selectedFormId": 10400987,
          //"messageId": 0,//"messageId": 10514976,
          "StatusName": dataRow["Status"].toString(), //"StatusName": "Resolved",
          "originator": dataRow["Originator"].toString(), //"originator": "https://portalqa2.asite.com/adoddleprofilefiles/member_photos/photo_707447_thumbnail.jpg?v=1544605518000#Vijay",
          //"dcId": 1,//"dcId": 1,
          "publisher": dataRow["OriginatorDisplayName"].toString(), //"publisher": "Vijay Mavadiya (5336), Asite Solutions",
          //"isCloseOut":false,//"isCloseOut": false,
          "instanceGroupId": dataRow["InstanceGroupId"].toString(), //"instanceGroupId": "10329977$$RrjsYB",
          "ID": dataRow["Code"].toString(), //"ID": "H5F113",
          "Tittle": dataRow["FormTitle"].toString(), //"Tittle": "Distributed",
          "formNum": dataRow["FormNumber"].toString(), //"formNum": 113,
          "updated": dataRow["Updated"].toString(), //"updated": "2019-12-18T09:12:56Z",
          "projectId": dataRow["ProjectId"].toString(), //"projectId": "2112709$$5mWZlX",
          "status": "ORI".toString(), //"status": "ORI",
          "chkPriv": true, //"chkPriv": true *****need to POC
        };
        List<dynamic> statusList = [], statusHistoryList = [];
        //get status history from db
        /*query = "SELECT * FROM FormStatusHistoryListTable\n"
            "WHERE ProjectId=${dataRow["ProjectId"].toString()} AND FormId=${dataRow["FormId"].toString()}\n"
            "ORDER BY CreateDateInMS DESC";
        var historyResult = databaseManager.executeSelectFromTable("FormStatusHistoryListTable", query);
        for (var element in historyResult) {
          var hstryDataMap = {
            "form_id": element["FormId"].toString(), //"form_id": "10400987$$mQylsF",
            //"form_msg_id": 0,
            "action_date": element["ActionDate"].toString(), //"action_date": "18-Dec-2019#09:12:56:903 WET",
            //"action_datetime": "Dec 18, 2019 9:12:56 AM",
            "description": element["Description"].toString(), //"description": "Status Changed to Resolved",
            "remark": element["Remarks"].toString(), //"remark": "test",
            "action_id": element["ActionId"].toString(), //"action_id": 26,
            "username": element["ActionUserName"].toString(), //"username": "Mayur Raval (5372)",
            "organisationName": element["ActionUserOrgName"].toString(), //"organisationName": "Asite Solutions",
            //"use_controller": "0",
            //"msgIdSet": {},
            //"strMsgId": "",
            //"controller_user_id": 0,
            //"form_originator_user_id": 707447,
            //"status_id": 0,
            //"msg_originator": 0,
            //"responders_collaborate": "0",
            "longDate": int.parse(element["CreateDateInMS"].toString()), //"longDate": 1576660376903,
            //"is_in_dist_list": false,
            //"is_in_parent_msg_dist_list": false,
            //"is_public": true,
            //"instance_group_id": "10329977$$RrjsYB",
            "userID": element["ActionUserId"].toString(), //"userID": "808581$$5cVykH",
            "userTypeId": element["ActionUserTypeId"].toString(), //"userTypeId": 1,
            "proxyUserId": element["ActionProxyUserId"].toString(), //"proxyUserId": 808581,
            "hProxyUserId": element["ActionProxyUserId"].toString(), //"hProxyUserId": "808581$$5cVykH",
            "proxyUserName": element["ActionProxyUserName"].toString(), //"proxyUserName": "Mayur Raval (5372)",
            "proxyOrgName": element["ActionProxyUserOrgName"].toString(), //"proxyOrgName": "Asite Solutions",
            //"assignedByName": "Mayur Raval (5372)",
            "accessType": "Status Changed", //"accessType": "Status Changed",
            //"canViewDraftMsg": false,
            //"canViewOwnorgPrivateForms": false,
            //"formEditVersionId": 0,
            //"audit_seq_id": 0,
            //"projectId": "0$$9Y0aXB",
            //"allowSolrUpdate": true,
            //"msgDistListId": 0,
            //"actionDuration": "5 mins ago",
            "userImage": "", //"userImage": "https://portalqa2.asite.com/profilefiles/member_photos/photo_808581_thumbnail.jpg?v=1575537113000",
          };
          statusHistoryList.add(hstryDataMap);
        }*/
        dataMap["statusHistory"] = statusHistoryList;
        String statusFilePath = await AppPathHelper().getFormTypeStatusListFilePath(projectId: dataRow["ProjectId"].toString(), formTypeId: dataRow["FormTypeId"].toString());
        String fileContent = readFromFile(statusFilePath);
        if (fileContent.isNotEmpty) {
          try {
            statusList = (jsonDecode(fileContent))["statusList"] ?? [];
          } on Exception {}
        }
        dataMap["statusList"] = statusList;
        data = jsonEncode([dataMap]);
      }
    } on Exception catch (e) {
      Log.d("ViewFormLocalDataSource::getOfflineFormStatusHistoryListJson error=${e.toString()}");
    }
    return data;
  }

}
