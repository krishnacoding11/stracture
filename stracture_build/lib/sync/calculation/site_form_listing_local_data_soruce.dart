import 'dart:convert';

import 'package:field/data/dao/form_dao.dart';
import 'package:field/data/dao/form_message_action_dao.dart';
import 'package:field/data/dao/form_message_dao.dart';
import 'package:field/data/dao/formtype_dao.dart';
import 'package:field/data/dao/location_dao.dart';
import 'package:field/data/dao/manage_type_dao.dart';
import 'package:field/data/dao/project_dao.dart';
import 'package:field/data/dao/status_style_dao.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/request_body.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/utils.dart';

import '../../data_source/forms/site_form_local_data_source.dart';
import '../../enums.dart';
import '../../networking/network_response.dart';

class SiteFormListingLocalDataSource extends SiteFormLocalDataSource {
  Future<Result> getOfflineObservationListJson(Map<String, dynamic> request) async {
    try {
      const queryViewName = "CTE_ObservationView";
      const aliasName = "obsrvTbl";
      int totalDocs = 0;
      int recordBatchSize = 25;
      int listingType = 51;
      int currentPageNo = 0;
      int recordStartFrom = 0;
      String sortField = request["sortField"]?.toString() ?? ListSortField.lastUpdatedDate.fieldName;
      String sortFieldType = request["sortFieldType"]?.toString() ?? "text";
      String sortOrder = request["sortOrder"]?.toString() ?? "DESC";
      bool editable = true;

      String projectId = request["projectId"]?.toString().plainValue() ?? "";
      String locationId = request["locationId"] ?? "";
      String filterJsonData = request["jsonData"] ?? "";

      String formListViewQuery = siteFormListViewQuery(queryViewName);
      String totalFormCountQuery = "$formListViewQuery\nSELECT COUNT(1) AS TotalCount FROM $queryViewName $aliasName";
      String formListQuery = "$formListViewQuery\nSELECT * FROM $queryViewName $aliasName";
      String conditionQuery = "WHERE ($aliasName.AppTypeId='2' OR $aliasName.AllowLocationAssociation=1)";
      if (projectId.isNotEmpty) {
        String tmpSelectQuery = "AND";
        if (projectId.contains(",")) {
          tmpSelectQuery = "$tmpSelectQuery $aliasName.ProjectId IN ($projectId)";
        } else {
          projectId = projectId.plainValue();
          tmpSelectQuery = "$tmpSelectQuery $aliasName.ProjectId=$projectId";
          if (locationId.isNotEmpty && locationId != "0") {
            String locationIds = await _getChildLocationIds(projectId, locationId, true);
            if (locationIds != "") {
              locationId = "$locationId,$locationIds";
            }
            tmpSelectQuery = "$tmpSelectQuery AND $aliasName.LocationId IN ($locationId)";
          }
        }
        conditionQuery = "$conditionQuery $tmpSelectQuery";
      }
      String filterSqlDataQuery = await siteFormFilterQuery(aliasName, filterJsonData);
      conditionQuery = "$conditionQuery\nAND $filterSqlDataQuery";
      //fetch offlinecreated forms only to inject data in site listing while auto-sync is running
      if (request.containsKey("onlyOfflineCreatedDataReq") && request["onlyOfflineCreatedDataReq"] == true) {
        conditionQuery = "$conditionQuery\nAND $aliasName.IsOfflineCreated=1";
      }

      //search data query put here
      recordBatchSize = int.tryParse(request["recordBatchSize"]?.toString() ?? "25") ?? 25;
      recordStartFrom = int.tryParse(request["recordStartFrom"]?.toString() ?? "0") ?? 0;
      final path = await AppPathHelper().getUserDataDBFilePath();
      final db = DatabaseManager(path);
      totalFormCountQuery = "$totalFormCountQuery\n$conditionQuery";
      formListQuery = "$formListQuery\n$conditionQuery\n${siteFormSortingOrderQuery(aliasName, request)}\n${siteFormLimitSizeQuery(recordStartFrom, recordBatchSize)}";
      Log.d("SiteFormListingLocalDataSource::getOfflineObservationListJson totalFormCountQuery=$totalFormCountQuery");
      var totalCountResult = db.executeSelectFromTable(FormDao.tableName, totalFormCountQuery);
      if (totalCountResult.isNotEmpty) {
        totalDocs = int.tryParse(totalCountResult[0]["TotalCount"].toString()) ?? 0;
      }
      Log.d("SiteFormListingLocalDataSource::getOfflineObservationListJson totalDocs count=$totalDocs");
      List<dynamic> dataListNode = [];
      if (recordBatchSize + recordStartFrom > totalDocs) {
        recordBatchSize = totalDocs;
      }
      if (totalDocs > 0) {
        Log.d("SiteFormListingLocalDataSource::getOfflineObservationListJson formListQuery=$formListQuery");
        var mapOfObservationList = db.executeSelectFromTable(FormDao.tableName, formListQuery);
        for (var observationItem in mapOfObservationList) {
          Map<String, dynamic> observationDataMap = {};
          bool isAvailableInQuality = false;
          /*if (observationItem["QualityFormId"] != "") {
          isAvailableInQuality = true;
          }*/
          String tmpProjectId = observationItem["ProjectId"].toString();
          String tmpLocationId = observationItem["LocationId"].toString();
          String tmpObservationId = observationItem["ObservationId"].toString();
          String tmpStatusId = observationItem["StatusId"].toString();
          String tmpMsgId = observationItem["MessageId"].toString();
          String tmpObservCode = observationItem["Code"];
          String tmpObservRequestJson = observationItem["RequestJsonForOffline"];
          String tmpFormId = observationItem["FormId"];
          String tmpAppTypeId = observationItem["AppTypeId"];
          String? tmpStatus = observationItem["Status"];
          observationDataMap["CFID_Assigned"] = "${observationItem["AssignedToUserName"].toString()}, ${observationItem["AssignedToUserOrgName"].toString()}";
          observationDataMap["responseRequestBy"] = observationItem["ResponseRequestBy"];
          observationDataMap["isAvailableInQuality"] = isAvailableInQuality;
          observationDataMap["observationId"] = int.tryParse(tmpObservationId) ?? 0;
          observationDataMap["locationId"] = int.tryParse(tmpLocationId) ?? 0;
          observationDataMap["locationPath"] = observationItem['locationPath'] ?? '';
          observationDataMap["parentMsgId"] = int.tryParse(observationItem["ParentMsgId"].toString()) ?? 0;
          observationDataMap["templateType"] = int.tryParse(observationItem["TemplateTypeId"].toString()) ?? 0;
          observationDataMap["dcId"] = int.tryParse(observationItem["dcId"].toString()) ?? 0;
          observationDataMap["statusid"] = int.tryParse(tmpStatusId) ?? 0;
          observationDataMap["originatorId"] = int.tryParse(observationItem["OriginatorId"].toString()) ?? 0;
          observationDataMap["updatedDateInMS"] = int.tryParse(observationItem["UpdatedDateInMS"].toString()) ?? 0;
          observationDataMap["formCreationDateInMS"] = int.tryParse(observationItem["FormCreationDateInMS"].toString()) ?? 0;
          observationDataMap["lastSyncStatus"] = (observationItem["SyncStatus"].toString() == "1") ? 1 : 0;
          observationDataMap["hasAttachments"] = (observationItem["HasAttachments"].toString() == "1") ? true : false;
          observationDataMap["hasAssocations"] = (observationItem["HasDocAssocations"].toString() == "1") ? true : false;
          observationDataMap["formHasAssocAttach"] = (observationItem["FormHasAssocAttach"].toString() == "1") ? true : false;
          observationDataMap["isDraft"] = (observationItem["IsDraft"].toString() == "1") ? true : false;
          observationDataMap["canRemoveOffline"] = (observationItem["CanRemoveOffline"].toString() == "1") ? true : false;
          observationDataMap["isMarkOffline"] = (observationItem["IsMarkOffline"].toString() == "1") ? true : false;
          observationDataMap["projectId"] = tmpProjectId;
          observationDataMap["formId"] = tmpFormId;
          observationDataMap["commId"] = tmpFormId;
          observationDataMap["msgId"] = tmpMsgId;
          observationDataMap["formTypeId"] = observationItem["FormTypeId"].toString();
          observationDataMap["title"] = observationItem["FormTitle"];
          observationDataMap["orgId"] = observationItem["OrgId"].toString();
          observationDataMap["msgCode"] = observationItem["MsgCode"];
          if (observationItem["IsDraft"].toString() == "1") {
            observationDataMap["code"] = "DRAFT";
          } else {
            observationDataMap["code"] = observationItem["Code"];
            observationDataMap["id"] = observationItem["Code"];
          }
          observationDataMap["instanceGroupId"] = observationItem["InstanceGroupId"].toString();
          observationDataMap["appType"] = tmpAppTypeId;
          observationDataMap["appTypeId"] = tmpAppTypeId;
          observationDataMap["status"] = tmpStatus;
          observationDataMap["originatorDisplayName"] = observationItem["OriginatorDisplayName"];
          observationDataMap["formTypeName"] = observationItem["FormTypeName"];
          observationDataMap["workPackage"] = observationItem["ObservationDefectType"];
          observationDataMap["appBuilderId"] = observationItem["AppBuilderId"];
          observationDataMap["statusText"] = tmpStatus;
          observationDataMap["CFID_DefectTyoe"] = observationItem["ManageTypeName"];
          if ((!tmpObservRequestJson.isNullOrEmpty()) && tmpObservCode == "DEF") {
            observationDataMap["isServerSyncStatus"] = 0;
          }
          if ((!tmpStatusId.isNullOrEmpty()) && (tmpStatusId != "2")) {
            Map<String, dynamic> observationStatusStyleDataMap = {};
            observationStatusStyleDataMap["statusID"] = int.tryParse(observationItem["StatusId"].toString()) ?? 0;
            observationStatusStyleDataMap["statusTypeID"] = int.tryParse(observationItem["StatusTypeId"].toString()) ?? 0;
            observationStatusStyleDataMap["isDeactive"] = (observationItem["StatusIsActive"].toString() == "1") ? true : false;
            observationStatusStyleDataMap["fontType"] = observationItem["FontType"];
            observationStatusStyleDataMap["fontEffect"] = observationItem["FontEffect"];
            observationStatusStyleDataMap["fontColor"] = observationItem["FontColor"];
            observationStatusStyleDataMap["backgroundColor"] = observationItem["BackgroundColor"];
            observationStatusStyleDataMap["statusName"] = observationItem["StatusName"];
            observationStatusStyleDataMap["projectId"] = tmpProjectId;
            observationStatusStyleDataMap["settingApplyOn"] = 1;
            observationStatusStyleDataMap["always_active"] = false;
            observationStatusStyleDataMap["userId"] = 0;
            observationStatusStyleDataMap["defaultPermissionId"] = 0;
            observationStatusStyleDataMap["orgId"] = "0";
            observationStatusStyleDataMap["generateURI"] = true;
            observationDataMap["statusRecordStyle"] = observationStatusStyleDataMap;
          }
          var userId = await StorePreference.getUserId();
          String strActionQuery = "SELECT * FROM ${FormMessageActionDao.tableName}\n"
              "WHERE ProjectId=$tmpProjectId AND FormId=$tmpFormId\n"
              "AND MsgId=$tmpMsgId AND RecipientUserId=${userId.plainValue()}\n"
              //" AND ActionId IN (3,7)"
              "ORDER BY ActionDueDateMilliSecond ASC";
          var mapOfObservationActionList = db.executeSelectFromTable(FormDao.tableName, strActionQuery);
          if (mapOfObservationActionList.isNotEmpty) {
            List<dynamic> observationActionListNode = [];
            for (var observationActionItem in mapOfObservationActionList) {
              Map<String, dynamic> observationActionDataMap = {};
              observationActionDataMap["resourceParentId"] = int.tryParse(observationActionItem["ResourceParentId"].toString()) ?? 0;
              observationActionDataMap["resourceId"] = int.tryParse(observationActionItem["ResourceId"].toString()) ?? 0;
              observationActionDataMap["actionId"] = int.tryParse(observationActionItem["ActionId"].toString()) ?? 0;
              observationActionDataMap["actionStatus"] = int.tryParse(observationActionItem["ActionStatus"].toString()) ?? 0;
              observationActionDataMap["distributorUserId"] = int.tryParse(observationActionItem["DistributorUserId"].toString()) ?? 0;
              observationActionDataMap["recipientId"] = int.tryParse(observationActionItem["RecipientUserId"].toString()) ?? 0;
              observationActionDataMap["distListId"] = int.tryParse(observationActionItem["DistListId"].toString()) ?? 0;
              observationActionDataMap["isActive"] = (observationActionItem["IsActive"] == "1") ? true : false;
              observationActionDataMap["generateURI"] = true;
              observationActionDataMap["projectId"] = tmpProjectId;
              observationActionDataMap["msgId"] = tmpMsgId;
              observationActionDataMap["actionName"] = observationActionItem["ActionName"];
              observationActionDataMap["dueDate"] = observationActionItem["ActionDueDate"];
              observationActionDataMap["actionTime"] = observationActionItem["ActionTime"];
              observationActionListNode.add(observationActionDataMap);
            }
            observationDataMap["actions"] = observationActionListNode;
          }
          dataListNode.add(observationDataMap);
        }
      }
      List<String> columnHeaderListNode = [];
      Map<String, dynamic> observationParentNode = {
        "totalDocs": totalDocs,
        "recordBatchSize": recordBatchSize,
        "listingType": listingType,
        "currentPageNo": currentPageNo,
        "recordStartFrom": recordStartFrom,
        "columnHeader": columnHeaderListNode,
        "data": dataListNode,
        "sortField": sortField,
        "sortFieldType": sortFieldType,
        "sortOrder": sortOrder,
        "editable": editable,
      };
      return SUCCESS(jsonEncode(observationParentNode), null, 200, requestData: NetworkRequestBody.json(request));
    } catch (e, stacktrace) {
      Log.d("SiteFormListingLocalDataSource::getOfflineObservationListJson exception $e");
      Log.d("SiteFormListingLocalDataSource::getOfflineObservationListJson exception $stacktrace");
      return FAIL("SiteFormListingLocalDataSource::getOfflineObservationListJson default::exception", 999);
    }
  }

  Future<Result> getOfflineAttachmentListJson(Map<String, dynamic> request) async {
    try {
      String strProjectId = request["projectId"].toString().plainValue() ?? "";

      String selectQuery = "SELECT * FROM FormMsgAttachAndAssocListTbl WHERE ProjectId = $strProjectId AND AttachDocId !='' AND AttachDocId IS NOT NULL";

      final path = await AppPathHelper().getUserDataDBFilePath();
      final db = DatabaseManager(path);
      var totalCountResult = db.executeSelectFromTable("FormMsgAttachAndAssocListTbl", selectQuery);

      List<dynamic> attachmentList = [];
      for (var attachmentItem in totalCountResult) {
        Map<String, dynamic> attachment = {};

        attachment["formId"] = attachmentItem["FormId"];
        attachment["revisionId"] = attachmentItem["AttachRevId"];
        attachment["fileExtensionType"] = attachmentItem["AttachFileName"].toString().getFileExtension()?.replaceAll(".", "");
        attachment["realPath"] = await AppPathHelper().getAttachmentFilePath(projectId: strProjectId, revisionId: attachmentItem['AttachRevId'], fileExtention: attachmentItem['AttachFileName'].toString().getFileExtension()?.replaceAll(".", "") ?? "");
        attachmentList.add(attachment);
      }

      return SUCCESS(jsonEncode(attachmentList), null, 200, requestData: NetworkRequestBody.json(request));
    } catch (e, stacktrace) {
      Log.d("SiteFormListingLocalDataSource getOfflineAttachmentListJson exception $e");
      Log.d("SiteFormListingLocalDataSource getOfflineAttachmentListJson exception $stacktrace");
      return FAIL("SiteFormListingLocalDataSource getOfflineAttachmentListJson default::exception", 999);
    }
  }

  Future<String> _getChildLocationIds(String strProjectId, String strLocationId, bool includeSubLocation) async {
    String strLocationIds = "";
    try {
      String strSelectQuery = "WITH children(LocationId) AS (";
      strSelectQuery = "$strSelectQuery SELECT LocationId FROM ${LocationDao.tableName}";
      strSelectQuery = "$strSelectQuery WHERE ProjectId=${strProjectId.plainValue()}";
      if (strLocationId.isEmpty || strLocationId == "0") {
        strSelectQuery = "$strSelectQuery AND ParentLocationId=0";
      } else {
        strSelectQuery = "$strSelectQuery AND ParentLocationId IN ($strLocationId)";
      }
      if (includeSubLocation) {
        strSelectQuery = "$strSelectQuery UNION ALL";
        strSelectQuery = "$strSelectQuery SELECT f.LocationId FROM ${LocationDao.tableName} f, children c";
        strSelectQuery = "$strSelectQuery WHERE f.ParentLocationId=c.LocationId";
      }
      strSelectQuery = "$strSelectQuery) SELECT DISTINCT LocationId FROM children";
      Log.d("SiteFormListingLocalDataSource _getChildLocationIds strLocationQuery=$strSelectQuery");
      final path = await AppPathHelper().getUserDataDBFilePath();
      final db = DatabaseManager(path);
      var result = db.executeSelectFromTable(LocationDao.tableName, strSelectQuery);
      Log.d("SiteFormListingLocalDataSource _getChildLocationIds mapLocationData size=${result.length}");
      strLocationIds = result.map((e) => e["LocationId"]).toList().join(',');
    } catch (e) {
      strLocationIds = "";
      Log.d("SiteFormListingLocalDataSource _getChildLocationIds default::exception.");
    }
    return strLocationIds;
  }

  Future<Result> getUpdatedObservationListItemData(Map<String, dynamic> request) async {
    try {
      int totalDocs = 0;
      int recordBatchSize = 25;
      int listingType = 39;
      int currentPageNo = 0;
      int recordStartFrom = 0;
      String sortField = "UpdatedDateInMS";
      String sortFieldType = "text";
      String sortOrder = "DESC";
      bool editable = true;

      String strProjectId = request["projectId"] ?? "";
      String strformId = request["formId"] ?? "";

      String selectQuery = "";
      selectQuery = "${selectQuery}WITH ObservationView AS (";
      selectQuery = "${selectQuery}SELECT prjTbl.DcId AS dcId,frmTbl.ProjectId, frmTbl.FormId, frmTbl.FormTypeId, frmTbl.FormTitle, frmTbl.Code, frmTbl.CommentId,";
      selectQuery = "${selectQuery}frmTbl.MessageId, frmTbl.OrgId, frmTbl.FirstName, frmTbl.LastName, frmTbl.OrgName, frmTbl.Originator, frmTbl.OriginatorDisplayName,";
      selectQuery = "${selectQuery}frmTbl.NoOfActions, frmTbl.ObservationId, frmTbl.LocationId, frmTbl.PfLocFolderId, frmTbl.Updated, frmTbl.AttachmentImageName,";
      selectQuery = "${selectQuery}frmTbl.TypeImage, frmTbl.DocType, frmTbl.HasAttachments, frmTbl.HasDocAssocations, frmTbl.HasBimViewAssociations, frmTbl.HasFormAssocations,";
      selectQuery = "${selectQuery}frmTbl.HasCommentAssocations, frmTbl.FormHasAssocAttach, frmTbl.FormCreationDate, frmTbl.FormNumber, frmTbl.IsDraft, frmTbl.StatusId,";
      selectQuery = "${selectQuery}frmTbl.OriginatorId, frmTbl.Id, frmTbl.StatusChangeUserId, frmTbl.StatusUpdateDate, frmTbl.StatusChangeUserName, frmTbl.StatusChangeUserPic,";
      selectQuery = "${selectQuery}frmTbl.StatusChangeUserEmail, frmTbl.StatusChangeUserOrg, frmTbl.OriginatorEmail, frmTbl.ControllerUserId, frmTbl.UpdatedDateInMS,";
      selectQuery = "${selectQuery}frmTbl.FormCreationDateInMS, frmTbl.FlagType, frmTbl.LatestDraftId, frmTbl.FlagTypeImageName, frmTbl.MessageTypeImageName, frmTbl.FormJsonData,";
      selectQuery = "${selectQuery}frmTbl.AttachedDocs, frmTbl.IsUploadAttachmentInTemp, frmTbl.IsSync, frmTbl.HasActions, frmTbl.CanRemoveOffline, frmTbl.IsMarkOffline,";
      selectQuery = "${selectQuery}frmTbl.IsOfflineCreated, frmTbl.SyncStatus, frmTbl.IsForDefect, frmTbl.IsForApps, frmTbl.ObservationDefectTypeId, frmTbl.StartDate,";
      selectQuery = "${selectQuery}frmTbl.ExpectedFinishDate, frmTbl.IsActive, frmTbl.ObservationCoordinates, frmTbl.AnnotationId, frmTbl.AssignedToUserId, frmTbl.AssignedToUserName,";
      selectQuery = "${selectQuery}frmTbl.AssignedToUserOrgName,frmTbl.AssignedToRoleName, frmTbl.RevisionId, frmTbl.RequestJsonForOffline, frmTbl.FormDueDays, frmTbl.FormSyncDate,";
      selectQuery = "${selectQuery}frmTbl.LastResponderForAssignedTo, frmTbl.LastResponderForOriginator, frmTbl.PageNumber, frmTbl.ObservationDefectType,frmTbl.TaskTypeName,";
      selectQuery = "${selectQuery}CASE frmTbl.StatusName WHEN '' THEN frmTbl.Status ELSE frmTbl.StatusName END AS StatusName,";
      selectQuery = "${selectQuery}IFNULL(frmTpTbl.AppTypeId,frmTbl.AppTypeId) AS AppTypeId, IFNULL(frmTpTbl.InstanceGroupId,frmTbl.InstanceGroupId) AS InstanceGroupId,";
      selectQuery = "${selectQuery}IFNULL(frmTpTbl.TemplateTypeId,frmTbl.TemplateType) AS TemplateTypeId, IFNULL(frmTpTbl.AppBuilderId,frmTbl.AppBuilderId) AS AppBuilderId,";
      selectQuery = "${selectQuery}IFNULL(frmTpTbl.FormTypeGroupName,'') AS FormTypeGroupName, IFNULL(frmTpTbl.FormTypeGroupCode,'') AS FormTypeGroupCode,";
      selectQuery = "${selectQuery}IFNULL(frmTpTbl.FormTypeName,'') AS FormTypeName,";
      //selectQuery = "${selectQuery}IFNULL(frmTpTbl.ParamJsonTemplate,'') AS ParamJsonTemplate, ";
      selectQuery = "${selectQuery}IFNULL(ManTpTbl.ManageTypeId,frmTbl.ObservationDefectTypeId) AS ManageTypeId,IFNULL(ManTpTbl.ManageTypeName,frmTbl.ObservationDefectType) AS ManageTypeName, ";
      selectQuery = "${selectQuery}IFNULL(StatStyTbl.StatusName,frmTbl.Status) AS Status,IFNULL(StatStyTbl.FontColor,'') AS FontColor,IFNULL(StatStyTbl.BackgroundColor,'') AS BackgroundColor,IFNULL(StatStyTbl.FontEffect,'') AS FontEffect,IFNULL(StatStyTbl.FontType,'') AS FontType,IFNULL(StatStyTbl.StatusTypeId,'') AS StatusTypeId,IFNULL(StatStyTbl.IsActive,'') AS StatusIsActive, ";
      selectQuery =
          "${selectQuery}IFNULL(MsgLst.Originator,'') AS MsgOriginator,IFNULL(MsgLst.OriginatorDisplayName,'') AS MsgOriginatorDisplayName,IFNULL(MsgLst.MsgCode,frmTbl.MsgCode) AS MsgCode,IFNULL(MsgLst.MsgCreatedDate,'') AS MsgCreatedDate,IFNULL(MsgLst.ParentMsgId,frmTbl.ParentMessageId) AS ParentMsgId,IFNULL(MsgLst.MsgOriginatorId,frmTbl.MsgOriginatorId) AS MsgOriginatorId,IFNULL(MsgLst.MsgHasAssocAttach,'') AS MsgHasAssocAttach,IFNULL(MsgLst.UserRefCode,frmTbl.UserRefCode) AS UserRefCode,IFNULL(MsgLst.UpdatedDateInMS,'') AS MsgUpdatedDateInMS,IFNULL(MsgLst.MsgCreatedDateInMS,'') AS MsgCreatedDateInMS,IFNULL(MsgLst.MsgTypeId,frmTbl.MsgTypeId) AS MsgTypeId,IFNULL(MsgLst.MsgTypeCode,frmTbl.MsgTypeCode) AS MsgTypeCode,IFNULL(MsgLst.MsgStatusId,frmTbl.MsgStatusId) AS MsgStatusId,IFNULL(MsgLst.FolderId,frmTbl.FolderId) AS FolderId,IFNULL(MsgLst.LatestDraftId,'') AS MsgLatestDraftId,IFNULL(MsgLst.IsDraft,'') AS MsgIsDraft,IFNULL(MsgLst.AssocRevIds,'') AS AssocRevIds,IFNULL(MsgLst.ResponseRequestBy,'') AS ResponseRequestBy,IFNULL(MsgLst.DelFormIds,'') AS DelFormIds,IFNULL(MsgLst.AssocFormIds,'') AS AssocFormIds,IFNULL(MsgLst.AssocCommIds,'') AS AssocCommIds,IFNULL(MsgLst.FormUserSet,'') AS FormUserSet,IFNULL(MsgLst.FormPermissionsMap,'') AS FormPermissionsMap,IFNULL(MsgLst.CanOrigChangeStatus,frmTbl.CanOrigChangeStatus) AS CanOrigChangeStatus,IFNULL(MsgLst.CanControllerChangeStatus,'') AS CanControllerChangeStatus,IFNULL(MsgLst.IsStatusChangeRestricted,frmTbl.IsStatusChangeRestricted) AS IsStatusChangeRestricted,IFNULL(MsgLst.HasOverallStatus,'') AS HasOverallStatus,IFNULL(MsgLst.IsCloseOut,frmTbl.IsCloseOut) AS IsCloseOut,IFNULL(MsgLst.AllowReopenForm,frmTbl.AllowReopenForm) AS AllowReopenForm,IFNULL(MsgLst.OfflineRequestData,'') AS OfflineRequestData,IFNULL(MsgLst.IsOfflineCreated,'') AS MsgIsOfflineCreated,IFNULL(MsgLst.MsgNum,frmTbl.MsgNum) AS MsgNum,IFNULL(MsgLst.MsgContent,'') AS MsgContent,IFNULL(MsgLst.ActionComplete,'') AS ActionComplete,IFNULL(MsgLst.ActionCleared,'') AS ActionCleared,IFNULL(MsgLst.HasAttach,'') AS HasAttach,IFNULL(MsgLst.TotalActions,'') AS TotalActions,IFNULL(MsgLst.AttachFiles,'') AS AttachFiles,IFNULL(MsgLst.HasViewAccess,'') AS HasViewAccess,IFNULL(MsgLst.MsgOriginImage,'') AS MsgOriginImage,IFNULL(MsgLst.IsForInfoIncomplete,'') AS IsForInfoIncomplete,IFNULL(MsgLst.MsgCreatedDateOffline,'') AS MsgCreatedDateOffline,IFNULL(MsgLst.LastModifiedTime,'') AS LastModifiedTime,IFNULL(MsgLst.LastModifiedTimeInMS,'') AS LastModifiedTimeInMS,IFNULL(MsgLst.CanViewDraftMsg,'') AS CanViewDraftMsg,IFNULL(MsgLst.CanViewOwnorgPrivateForms,'') AS CanViewOwnorgPrivateForms,IFNULL(MsgLst.IsAutoSavedDraft,'') AS IsAutoSavedDraft,IFNULL(MsgLst.MsgStatusName,'') AS MsgStatusName,IFNULL(MsgLst.ProjectAPDFolderId,'') AS ProjectAPDFolderId,IFNULL(MsgLst.ProjectStatusId,'') AS ProjectStatusId,IFNULL(MsgLst.HasFormAccess,'') AS HasFormAccess,IFNULL(MsgLst.CanAccessHistory,frmTbl.CanAccessHistory) AS CanAccessHistory,IFNULL(MsgLst.HasDocAssocations,'') AS MsgHasDocAssocations,IFNULL(MsgLst.HasBimViewAssociations,'') AS MsgHasBimViewAssociations,IFNULL(MsgLst.HasBimListAssociations,'') AS HasBimListAssociations,IFNULL(MsgLst.HasFormAssocations,'') AS MsgHasFormAssocations,IFNULL(MsgLst.HasCommentAssocations,'') AS MsgHasCommentAssocations ";
      selectQuery = "${selectQuery}FROM ${FormDao.tableName} frmTbl \n";
      selectQuery = "${selectQuery}INNER JOIN ${ProjectDao.tableName} prjTbl ON prjTbl.ProjectId=frmTbl.ProjectId AND prjTbl.StatusId<>7 \n";
      selectQuery = "${selectQuery}LEFT JOIN ${FormTypeDao.tableName} frmTpTbl ON frmTpTbl.ProjectId=frmTbl.ProjectId AND frmTpTbl.FormTypeId=frmTbl.FormTypeId \n";
      selectQuery = "${selectQuery}LEFT JOIN ${FormMessageDao.tableName} MsgLst ON MsgLst.ProjectId=frmTbl.ProjectId AND MsgLst.FormTypeId=frmTbl.FormTypeId AND MsgLst.ObservationId=frmTbl.ObservationId AND MsgLst.MsgId=frmTbl.MessageId\n";
      selectQuery = "${selectQuery}LEFT JOIN ${StatusStyleListDao.tableName} StatStyTbl ON StatStyTbl.ProjectId=frmTbl.ProjectId AND StatStyTbl.StatusId=frmTbl.StatusId \n";
      selectQuery = "${selectQuery}LEFT JOIN ${ManageTypeDao.tableName} ManTpTbl ON ManTpTbl.ProjectId=frmTbl.ProjectId AND ManTpTbl.ManageTypeId=frmTbl.ObservationDefectTypeId \n";
      selectQuery = "$selectQuery) ";
      String detailDataSelectQuery = "${selectQuery}SELECT * FROM ObservationView obsrvTbl ";
      String conditionQuery = "WHERE obsrvTbl.ProjectId=$strProjectId AND obsrvTbl.FormId=$strformId";

      String strRecorBatchSz = request["recordBatchSize"] ?? "25";
      String strrecordStartFrom = request["recordStartFrom"] ?? "0";
      if (strRecorBatchSz.isNullOrEmpty() || strRecorBatchSz == "0") {
        strRecorBatchSz = "25";
      }
      if (strrecordStartFrom.isNullOrEmpty()) {
        strrecordStartFrom = "0";
      }
      recordBatchSize = int.tryParse(strRecorBatchSz) ?? 25;
      recordStartFrom = int.tryParse(strrecordStartFrom) ?? 0;
      final path = await AppPathHelper().getUserDataDBFilePath();
      final db = DatabaseManager(path);

      Log.d("SiteFormListingLocalDataSource getUpdatedObservationListItemData selectQuery=$conditionQuery");
      detailDataSelectQuery = "$detailDataSelectQuery $conditionQuery";
      var mapOfObservationList = db.executeSelectFromTable(FormDao.tableName, detailDataSelectQuery);

      List<dynamic> dataListNode = [];
      totalDocs = mapOfObservationList.length;

      Log.d("SiteFormListingLocalDataSource getUpdatedObservationListItemData recordBatchSize=$recordBatchSize");
      Log.d("SiteFormListingLocalDataSource getUpdatedObservationListItemData recordStartFrom=$recordStartFrom");

      for (var observationItem in mapOfObservationList) {
        Map<String, dynamic> observationDataMap = {};

        bool isAvailableInQuality = false;

        String tmpProjectId = observationItem["ProjectId"].toString();
        String tmpLocationId = observationItem["LocationId"].toString();
        String tmpObservationId = observationItem["ObservationId"].toString();
        String tmpStatusId = observationItem["StatusId"].toString();
        String tmpMsgId = observationItem["MessageId"].toString();
        String tmpObservCode = observationItem["Code"];
        String tmpObservRequestJson = observationItem["RequestJsonForOffline"];
        String tmpFormId = observationItem["FormId"];
        String tmpAppTypeId = observationItem["AppTypeId"];
        String? tmpStatus = observationItem["Status"];
        Log.d("SiteFormListingLocalDataSource getUpdatedObservationListItemData observationId=$tmpObservationId");

        observationDataMap["CFID_Assigned"] = "${observationItem["AssignedToUserName"].toString()}, ${observationItem["AssignedToUserOrgName"].toString()}";
        observationDataMap["responseRequestBy"] = observationItem["ResponseRequestBy"];

        observationDataMap["isAvailableInQuality"] = isAvailableInQuality;
        observationDataMap["observationId"] = int.tryParse(tmpObservationId) ?? 0;
        observationDataMap["locationId"] = int.tryParse(tmpLocationId) ?? 0;
        observationDataMap["parentMsgId"] = int.tryParse(observationItem["ParentMsgId"].toString()) ?? 0;
        observationDataMap["templateType"] = int.tryParse(observationItem["TemplateTypeId"].toString()) ?? 0;
        observationDataMap["dcId"] = int.tryParse(observationItem["dcId"].toString()) ?? 0;
        observationDataMap["statusid"] = int.tryParse(tmpStatusId) ?? 0;
        observationDataMap["originatorId"] = int.tryParse(observationItem["OriginatorId"].toString()) ?? 0;
        observationDataMap["updatedDateInMS"] = int.tryParse(observationItem["UpdatedDateInMS"].toString()) ?? 0;
        observationDataMap["formCreationDateInMS"] = int.tryParse(observationItem["FormCreationDateInMS"].toString()) ?? 0;
        observationDataMap["lastSyncStatus"] = (observationItem["SyncStatus"].toString() == "1") ? 1 : 0;
        observationDataMap["hasAttachments"] = (observationItem["HasAttachments"].toString() == "1") ? true : false;
        observationDataMap["hasAssocations"] = (observationItem["HasDocAssocations"].toString() == "1") ? true : false;
        observationDataMap["formHasAssocAttach"] = (observationItem["FormHasAssocAttach"].toString() == "1") ? true : false;
        observationDataMap["isDraft"] = (observationItem["IsDraft"].toString() == "1") ? true : false;
        observationDataMap["canRemoveOffline"] = (observationItem["CanRemoveOffline"].toString() == "1") ? true : false;
        observationDataMap["isMarkOffline"] = (observationItem["IsMarkOffline"].toString() == "1") ? true : false;
        observationDataMap["projectId"] = tmpProjectId;
        observationDataMap["formId"] = tmpFormId;
        observationDataMap["commId"] = tmpFormId;
        observationDataMap["msgId"] = tmpMsgId;
        observationDataMap["formTypeId"] = observationItem["FormTypeId"].toString();
        observationDataMap["title"] = observationItem["FormTitle"];
        observationDataMap["orgId"] = observationItem["OrgId"].toString();
        observationDataMap["msgCode"] = observationItem["MsgCode"];
        if (observationItem["IsDraft"].toString() == "1") {
          observationDataMap["code"] = "DRAFT";
        } else {
          observationDataMap["code"] = observationItem["Code"];
          observationDataMap["id"] = observationItem["Code"];
        }
        observationDataMap["instanceGroupId"] = observationItem["InstanceGroupId"].toString();
        observationDataMap["appType"] = tmpAppTypeId;
        observationDataMap["appTypeId"] = tmpAppTypeId;
        observationDataMap["status"] = tmpStatus;
        observationDataMap["originatorDisplayName"] = observationItem["OriginatorDisplayName"];
        observationDataMap["formTypeName"] = observationItem["FormTypeName"];
        observationDataMap["workPackage"] = observationItem["ObservationDefectType"];
        observationDataMap["appBuilderId"] = observationItem["AppBuilderId"];
        observationDataMap["statusText"] = tmpStatus;
        observationDataMap["CFID_DefectTyoe"] = observationItem["ObservationDefectType"];
        if ((!tmpObservRequestJson.isNullOrEmpty()) && tmpObservCode == "DEF") {
          observationDataMap["isServerSyncStatus"] = 0;
        }

        if ((!tmpStatusId.isNullOrEmpty()) && (tmpStatusId != "2")) {
          Map<String, dynamic> observationStatusStyleDataMap = {};
          observationStatusStyleDataMap["statusID"] = int.tryParse(observationItem["StatusId"].toString()) ?? 0;
          observationStatusStyleDataMap["statusTypeID"] = int.tryParse(observationItem["StatusTypeId"].toString()) ?? 0;
          observationStatusStyleDataMap["isDeactive"] = (observationItem["StatusIsActive"].toString() == "1") ? true : false;
          observationStatusStyleDataMap["fontType"] = observationItem["FontType"];
          observationStatusStyleDataMap["fontEffect"] = observationItem["FontEffect"];
          observationStatusStyleDataMap["fontColor"] = observationItem["FontColor"];
          observationStatusStyleDataMap["backgroundColor"] = observationItem["BackgroundColor"];
          observationStatusStyleDataMap["statusName"] = observationItem["StatusName"];
          observationStatusStyleDataMap["projectId"] = tmpProjectId;
          observationStatusStyleDataMap["settingApplyOn"] = 1;
          observationStatusStyleDataMap["always_active"] = false;
          observationStatusStyleDataMap["userId"] = 0;
          observationStatusStyleDataMap["defaultPermissionId"] = 0;
          observationStatusStyleDataMap["orgId"] = "0";
          observationStatusStyleDataMap["generateURI"] = true;
          observationDataMap["statusRecordStyle"] = observationStatusStyleDataMap;
        }
        dataListNode.add(observationDataMap);
      }

      Map<String, dynamic> observationParentNode = {};
      observationParentNode["totalDocs"] = totalDocs;
      observationParentNode["recordBatchSize"] = recordBatchSize;
      observationParentNode["listingType"] = listingType;
      observationParentNode["currentPageNo"] = currentPageNo;
      observationParentNode["recordStartFrom"] = recordStartFrom;
      List<String> columnHeaderListNode = [];
      observationParentNode["columnHeader"] = columnHeaderListNode;
      observationParentNode["data"] = dataListNode;
      observationParentNode["sortField"] = sortField;
      observationParentNode["sortFieldType"] = sortFieldType;
      observationParentNode["sortOrder"] = sortOrder;
      observationParentNode["editable"] = editable;
      return SUCCESS(jsonEncode(observationParentNode), null, 200, requestData: NetworkRequestBody.json(request));
      //DirectoryManager::writeDataToFile("/sdcard/Field_offline_observationListJson.txt", response.responseData);
    } catch (e, stacktrace) {
      Log.d("SiteFormListingLocalDataSource getUpdatedObservationListItemData exception $e");
      Log.d("SiteFormListingLocalDataSource getUpdatedObservationListItemData exception $stacktrace");
      return FAIL("SiteFormListingLocalDataSource getUpdatedObservationListItemData default::exception", 999);
    }
  }

  Future<List<Map<String, dynamic>>> fetchAppTypeList(String projectId) async {
    final previous30DaysTimeStamp = Utility.getPreviousDaysTimeStamp(days: 30);

    final selectQuery = "WITH RecentFormTypeData AS (\n"
        "SELECT InstanceGroupId, MAX(FormCreationDateInMS) AS FormCreationDateInMS FROM FormListTbl\n"
        "WHERE ProjectId=$projectId AND FormCreationDateInMS>=$previous30DaysTimeStamp\n"
        "GROUP BY InstanceGroupId\n"
        "ORDER BY FormCreationDateInMS DESC\n"
        "LIMIT 5\n"
        ")\n"
        "SELECT frmGrpTpTbl.*, prjTbl.dcId, prjTbl.ProjectName,IFNULL(recentData.FormCreationDateInMS,0) AS FormCreationDateInMS FROM ${FormTypeDao.tableName} frmGrpTpTbl\n"
        "INNER JOIN ProjectDetailTbl prjTbl ON frmGrpTpTbl.ProjectId = prjTbl.ProjectId\n"
        "LEFT JOIN RecentFormTypeData recentData ON recentData.InstanceGroupId=frmGrpTpTbl.InstanceGroupId\n"
        "WHERE frmGrpTpTbl.ProjectId=$projectId AND frmGrpTpTbl.CanCreateForms=1 AND\n"
        "frmGrpTpTbl.FormTypeId IN (\n"
        "SELECT MAX(FormTypeId) FROM ${FormTypeDao.tableName}\n"
        "WHERE ProjectId=$projectId AND AllowLocationAssociation=1\n"
        "GROUP BY InstanceGroupId\n"
        ")\n"
        "ORDER BY FormCreationDateInMS DESC, formTypeName COLLATE NOCASE ASC\n";

    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(FormTypeDao.tableName, selectQuery);
      return qurResult;
    } on Exception catch (e) {
      Log.d("SiteFormListingLocalDataSource fetchSiteFormList exception $e");
      return [];
    }
  }
}
