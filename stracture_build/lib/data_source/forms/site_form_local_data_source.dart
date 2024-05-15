import 'dart:convert';

import 'package:field/data/dao/location_dao.dart';

import '../../data/dao/form_dao.dart';
import '../../data/dao/form_message_action_dao.dart';
import '../../data/dao/form_message_dao.dart';
import '../../data/dao/formtype_dao.dart';
import '../../data/dao/manage_type_dao.dart';
import '../../data/dao/project_dao.dart';
import '../../data/dao/status_style_dao.dart';
import '../../enums.dart';
import '../../logger/logger.dart';
import '../../utils/field_enums.dart';
import '../../utils/utils.dart';
import 'form_local_data_source.dart';

class SiteFormLocalDataSource extends FormLocalDataSource {
  String filterAttributeTableColumnName(String fieldName) {
    switch (fieldName.toLowerCase()) {
      case 'cfid_locationname':
        return "BaseLocationPath";
      case 'form_status':
        return "StatusName";
      case 'cfid_defecttyoe':
        return "ObservationDefectType";
      case 'cfid_assignedtouser':
        return "AssignedToUserId";
      case 'action_status':
        return FormMessageActionDao.actionStatusNameField;
      case 'status_id':
        return "IsActive";
      case 'distribution_list':
        return FormMessageActionDao.recipientUserIdField;
      case 'recipient_org':
        return FormMessageActionDao.recipientOrgIdField;
      case 'originator_user_id':
        return "OriginatorId";
      case 'originator_organisation':
        return "OrgId";
      case 'form_creation_date':
        return FormDao.formCreationDateInMSField;
      case 'due_date':
        return FormMessageActionDao.actionDueDateMilliSecondField;
      case 'form_title':
        return FormDao.formTitleField;
      case 'form_type_name':
        return "FormTypeName";
      case 'cfid_tasktype':
        return "";
      case 'summary':
        return "OriginatorDisplayName#FormTitle#ObservationDefectType#ManageTypeName#UserRefCode#Code#FormCreationDate#StatusName#Status";
    }
    return "";
  }

  String siteFormListViewQuery(String queryViewName) {
    return "WITH $queryViewName AS (\n"
        "SELECT locTbl.LocationPath AS locationPath,prjTbl.DcId AS dcId,frmTbl.ProjectId,frmTbl.FormId,frmTbl.FormTypeId,frmTbl.ResponseRequestByInMS,frmTbl.FormTitle,frmTbl.Code,frmTbl.CommentId,"
        "frmTbl.MessageId,frmTbl.OrgId,frmTbl.FirstName,frmTbl.LastName,frmTbl.OrgName,frmTbl.Originator,frmTbl.OriginatorDisplayName,frmTbl.NoOfActions,frmTbl.TaskTypeName,"
        "frmTbl.ObservationId,frmTbl.LocationId,frmTbl.PfLocFolderId,frmTbl.Updated,frmTbl.AttachmentImageName,frmTbl.TypeImage,frmTbl.DocType,frmTbl.HasAttachments,"
        "frmTbl.HasDocAssocations,frmTbl.HasBimViewAssociations,frmTbl.HasFormAssocations,frmTbl.HasCommentAssocations,frmTbl.FormHasAssocAttach,frmTbl.FormCreationDate,"
        "frmTbl.FormNumber,frmTbl.IsDraft,frmTbl.StatusId,frmTbl.OriginatorId,frmTbl.Id,frmTbl.StatusChangeUserId,frmTbl.StatusUpdateDate,frmTbl.StatusChangeUserName,"
        "frmTbl.StatusChangeUserPic,frmTbl.StatusChangeUserEmail,frmTbl.StatusChangeUserOrg,frmTbl.OriginatorEmail,frmTbl.ControllerUserId,frmTbl.UpdatedDateInMS,"
        "frmTbl.FormCreationDateInMS,frmTbl.FlagType,frmTbl.LatestDraftId,frmTbl.FlagTypeImageName,frmTbl.MessageTypeImageName,frmTbl.FormJsonData,frmTbl.AttachedDocs,"
        "frmTbl.IsUploadAttachmentInTemp,frmTbl.IsSync,frmTbl.HasActions,frmTbl.CanRemoveOffline,frmTbl.IsMarkOffline,frmTbl.IsOfflineCreated,frmTbl.SyncStatus,"
        "frmTbl.IsForDefect,frmTbl.IsForApps,frmTbl.ObservationDefectTypeId,frmTbl.StartDate,frmTbl.ExpectedFinishDate,frmTbl.IsActive,frmTbl.ObservationCoordinates,"
        "frmTbl.AnnotationId,frmTbl.AssignedToUserId,frmTbl.AssignedToUserName,frmTbl.AssignedToUserOrgName,frmTbl.AssignedToRoleName,frmTbl.RevisionId,frmTbl.PageNumber,"
        "frmTbl.RequestJsonForOffline,frmTbl.FormDueDays,frmTbl.FormSyncDate,frmTbl.LastResponderForAssignedTo,frmTbl.LastResponderForOriginator,frmTbl.ObservationDefectType,"
        "IIF(frmTbl.StatusName='',frmTbl.Status,frmTbl.StatusName) AS StatusName,IFNULL(frmTpTbl.AllowLocationAssociation,0) AS AllowLocationAssociation,IFNULL(frmTpTbl.AppTypeId,frmTbl.AppTypeId) AS AppTypeId,IFNULL(frmTpTbl.InstanceGroupId,frmTbl.InstanceGroupId) AS InstanceGroupId,"
        "IFNULL(frmTpTbl.TemplateTypeId,frmTbl.TemplateType) AS TemplateTypeId,IFNULL(frmTpTbl.AppBuilderId,frmTbl.AppBuilderId) AS AppBuilderId,IFNULL(frmTpTbl.FormTypeName,'') AS FormTypeName,"
        "IFNULL(frmTpTbl.FormTypeGroupName,'') AS FormTypeGroupName,IFNULL(frmTpTbl.FormTypeGroupCode,'') AS FormTypeGroupCode,IFNULL(ManTpTbl.ManageTypeId,frmTbl.ObservationDefectTypeId) AS ManageTypeId,"
        "IFNULL(ManTpTbl.ManageTypeName,frmTbl.ObservationDefectType) AS ManageTypeName,IFNULL(StatStyTbl.StatusName,frmTbl.Status) AS Status,IFNULL(StatStyTbl.FontColor,'') AS FontColor,"
        "IFNULL(StatStyTbl.BackgroundColor,'') AS BackgroundColor,IFNULL(StatStyTbl.FontEffect,'') AS FontEffect,IFNULL(StatStyTbl.FontType,'') AS FontType,IFNULL(StatStyTbl.StatusTypeId,'') AS StatusTypeId,"
        "IFNULL(StatStyTbl.IsActive,'') AS StatusIsActive,IFNULL(MsgLst.Originator,'') AS MsgOriginator,IFNULL(MsgLst.OriginatorDisplayName,'') AS MsgOriginatorDisplayName,IFNULL(MsgLst.MsgCode,frmTbl.MsgCode) AS MsgCode,"
        "IFNULL(MsgLst.MsgCreatedDate,'') AS MsgCreatedDate,IFNULL(MsgLst.ParentMsgId,frmTbl.ParentMessageId) AS ParentMsgId,IFNULL(MsgLst.MsgOriginatorId,frmTbl.MsgOriginatorId) AS MsgOriginatorId,"
        "IFNULL(MsgLst.MsgHasAssocAttach,'') AS MsgHasAssocAttach,IFNULL(MsgLst.UserRefCode,frmTbl.UserRefCode) AS UserRefCode,IFNULL(MsgLst.UpdatedDateInMS,'') AS MsgUpdatedDateInMS,"
        "IFNULL(MsgLst.MsgCreatedDateInMS,'') AS MsgCreatedDateInMS,IFNULL(MsgLst.MsgTypeId,frmTbl.MsgTypeId) AS MsgTypeId,IFNULL(MsgLst.MsgTypeCode,frmTbl.MsgTypeCode) AS MsgTypeCode,"
        "IFNULL(MsgLst.MsgStatusId,frmTbl.MsgStatusId) AS MsgStatusId,IFNULL(MsgLst.FolderId,frmTbl.FolderId) AS FolderId,IFNULL(MsgLst.LatestDraftId,'') AS MsgLatestDraftId,"
        "IFNULL(MsgLst.IsDraft,'') AS MsgIsDraft,IFNULL(MsgLst.AssocRevIds,'') AS AssocRevIds,IFNULL(MsgLst.ResponseRequestBy,'') AS ResponseRequestBy,IFNULL(MsgLst.DelFormIds,'') AS DelFormIds,"
        "IFNULL(MsgLst.AssocFormIds,'') AS AssocFormIds,IFNULL(MsgLst.AssocCommIds,'') AS AssocCommIds,IFNULL(MsgLst.FormUserSet,'') AS FormUserSet,IFNULL(MsgLst.FormPermissionsMap,'') AS FormPermissionsMap,"
        "IFNULL(MsgLst.CanOrigChangeStatus,frmTbl.CanOrigChangeStatus) AS CanOrigChangeStatus,IFNULL(MsgLst.CanControllerChangeStatus,'') AS CanControllerChangeStatus,IFNULL(MsgLst.IsStatusChangeRestricted,frmTbl.IsStatusChangeRestricted) AS IsStatusChangeRestricted,"
        "IFNULL(MsgLst.HasOverallStatus,'') AS HasOverallStatus,IFNULL(MsgLst.IsCloseOut,frmTbl.IsCloseOut) AS IsCloseOut,IFNULL(MsgLst.AllowReopenForm,frmTbl.AllowReopenForm) AS AllowReopenForm,IFNULL(MsgLst.OfflineRequestData,'') AS OfflineRequestData,"
        "IFNULL(MsgLst.IsOfflineCreated,'') AS MsgIsOfflineCreated,IFNULL(MsgLst.MsgNum,frmTbl.MsgNum) AS MsgNum,IFNULL(MsgLst.MsgContent,'') AS MsgContent,IFNULL(MsgLst.ActionComplete,'') AS ActionComplete,IFNULL(MsgLst.ActionCleared,'') AS ActionCleared,"
        "IFNULL(MsgLst.HasAttach,'') AS HasAttach,IFNULL(MsgLst.TotalActions,'') AS TotalActions,IFNULL(MsgLst.AttachFiles,'') AS AttachFiles,IFNULL(MsgLst.HasViewAccess,'') AS HasViewAccess,IFNULL(MsgLst.MsgOriginImage,'') AS MsgOriginImage,"
        "IFNULL(MsgLst.IsForInfoIncomplete,'') AS IsForInfoIncomplete,IFNULL(MsgLst.MsgCreatedDateOffline,'') AS MsgCreatedDateOffline,IFNULL(MsgLst.LastModifiedTime,'') AS LastModifiedTime,IFNULL(MsgLst.LastModifiedTimeInMS,'') AS LastModifiedTimeInMS,"
        "IFNULL(MsgLst.CanViewDraftMsg,'') AS CanViewDraftMsg,IFNULL(MsgLst.CanViewOwnorgPrivateForms,'') AS CanViewOwnorgPrivateForms,IFNULL(MsgLst.IsAutoSavedDraft,'') AS IsAutoSavedDraft,IFNULL(MsgLst.MsgStatusName,'') AS MsgStatusName,"
        "IFNULL(MsgLst.ProjectAPDFolderId,'') AS ProjectAPDFolderId,IFNULL(MsgLst.ProjectStatusId,'') AS ProjectStatusId,IFNULL(MsgLst.HasFormAccess,'') AS HasFormAccess,IFNULL(MsgLst.CanAccessHistory,frmTbl.CanAccessHistory) AS CanAccessHistory,"
        "IFNULL(MsgLst.HasDocAssocations,'') AS MsgHasDocAssocations,IFNULL(MsgLst.HasBimViewAssociations,'') AS MsgHasBimViewAssociations,IFNULL(MsgLst.HasBimListAssociations,'') AS HasBimListAssociations,"
        "IFNULL(MsgLst.HasFormAssocations,'') AS MsgHasFormAssocations,IFNULL(MsgLst.HasCommentAssocations,'') AS MsgHasCommentAssocations "
        "FROM ${FormDao.tableName} frmTbl\n"
        "INNER JOIN ${ProjectDao.tableName} prjTbl ON prjTbl.ProjectId=frmTbl.ProjectId AND prjTbl.StatusId<>${EProjectStatus.archived.value}\n"
        "LEFT JOIN ${FormTypeDao.tableName} frmTpTbl ON frmTpTbl.ProjectId=frmTbl.ProjectId AND frmTpTbl.FormTypeId=frmTbl.FormTypeId\n"
        "LEFT JOIN ${FormMessageDao.tableName} MsgLst ON MsgLst.ProjectId=frmTbl.ProjectId AND MsgLst.FormId=frmTbl.FormId AND MsgLst.MsgId=frmTbl.MessageId\n"
        "LEFT JOIN ${StatusStyleListDao.tableName} StatStyTbl ON StatStyTbl.ProjectId=frmTbl.ProjectId AND StatStyTbl.StatusId=frmTbl.StatusId\n"
        "LEFT JOIN ${ManageTypeDao.tableName} ManTpTbl ON ManTpTbl.ProjectId=frmTbl.ProjectId AND ManTpTbl.ManageTypeId=frmTbl.ObservationDefectTypeId\n"
        "LEFT JOIN ${LocationDao.tableName} locTbl ON locTbl.ProjectId = frmTbl.ProjectId AND locTbl.LocationId = frmTbl.LocationId\n"
        ")";
  }

  Future<String> filterDateFormattedQuery(String aliasName, String tableFieldName, String attributeValue) async {
    String strQuery = "";
    aliasName = (aliasName.isNotEmpty) ? "$aliasName." : aliasName;
    if (tableFieldName != "" && attributeValue != "") {
      String startTime = "", endTime = "";
      if (attributeValue.startsWith("rptbetween#from#")) {
        attributeValue = attributeValue.replaceFirst("rptbetween#from#", "");
        startTime = attributeValue.split("|")[0];
        endTime = attributeValue.split("|")[1];
      } else {
        attributeValue = attributeValue.replaceFirst("rpton#on#", "");
        startTime = attributeValue;
        endTime = attributeValue;
      }
      String dateFormat = await Utility.getUserDateFormat();
      startTime = Utility.getTimeStampFromDate("$startTime 00:00:00", dateFormat).toString();
      endTime = Utility.getTimeStampFromDate("$endTime 23:59:59", dateFormat).toString();
      strQuery = "$aliasName$tableFieldName BETWEEN $startTime AND $endTime";
    }
    return strQuery;
  }

  Future<String> siteFormFilterQuery(String aliasName, String filterJsonData, {String currentTimeInMs = ""}) async {
    aliasName = (aliasName.isNotEmpty && !aliasName.endsWith(".")) ? "$aliasName." : aliasName;
    String filterQuery = "";
    const formTableAlias = "frmTbl", formTypeTableAlias = "frmTpTbl", formActionTableAlias = "frmActTbl", manageTableAlias = "mngTbl";
    String formTableCause = "WHERE ($formTableAlias.IsActive=1)";
    String formTypeTableCause = "";
    String formActionTableCause = "";
    String manageTypeTableCause = "";
    if (filterJsonData.isNotEmpty) {
      var filterVO = jsonDecode(filterJsonData);
      var filterVOList = filterVO["filterQueryVOs"];
      for (var filterVo in filterVOList) {
        String attributeQuery = "";
        String indexFieldName = filterVo["indexField"]?.toString() ?? "";
        if (indexFieldName.isNotEmpty) {
          var dataListNode = filterVo["popupTo"]["data"];
          String strTableFieldName = filterAttributeTableColumnName(indexFieldName);
          switch (indexFieldName.toLowerCase()) {
            case 'cfid_locationname':
              break;
            case 'form_status':
            case 'cfid_defecttyoe':
              String includeData = "";
              String notIncludeData = "";
              for (var valueMapNode in dataListNode) {
                String notInStatus = valueMapNode['notInStatus']?.toString() ?? "";
                String tmpDataValue = valueMapNode['value']?.toString().trim() ?? "";
                if (notInStatus.isNotEmpty && tmpDataValue.toLowerCase() == "other") {
                  notInStatus = notInStatus.split(",").map((e) => "'${e.trim()}'").toList().join(",");
                  notIncludeData = "${(notIncludeData.isNotEmpty) ? "$notIncludeData," : ""}$notInStatus";
                } else {
                  includeData = "${(includeData.isNotEmpty) ? "$includeData," : ""}'$tmpDataValue'";
                }
              }
              if (includeData.isNotEmpty) {
                attributeQuery = "$formTableAlias.$strTableFieldName COLLATE NOCASE IN ($includeData)";
              }
              if (notIncludeData.isNotEmpty) {
                attributeQuery = "${(attributeQuery.isNotEmpty) ? "$attributeQuery OR " : ""}$formTableAlias.$strTableFieldName COLLATE NOCASE NOT IN ($notIncludeData)";
              }
              if (attributeQuery.isNotEmpty) {
                formTableCause = "${(formTableCause.isNotEmpty) ? "$formTableCause\nAND " : ""}($attributeQuery)";
              }
              break;
            case 'cfid_assignedtouser':
            case 'originator_user_id':
            case 'originator_organisation':
              String includeData = "";
              for (var valueMapNode in dataListNode) {
                String tmpDataValue = valueMapNode['id']?.toString().trim().replaceAll("'", "''") ?? "";
                includeData = "${(includeData.isNotEmpty) ? "$includeData," : ""}'$tmpDataValue'";
              }
              if (includeData.isNotEmpty) {
                attributeQuery = "$formTableAlias.$strTableFieldName COLLATE NOCASE IN ($includeData)";
              }
              if (attributeQuery.isNotEmpty) {
                formTableCause = "${(formTableCause.isNotEmpty) ? "$formTableCause\nAND " : ""}($attributeQuery)";
              }
              break;
            case 'form_type_name':
              String includeData = "";
              for (var valueMapNode in dataListNode) {
                String tmpDataValue = valueMapNode['id']?.toString().trim().replaceAll("'", "''") ?? "";
                includeData = "${(includeData.isNotEmpty) ? "$includeData," : ""}'$tmpDataValue'";
              }
              if (includeData.isNotEmpty) {
                attributeQuery = "$formTypeTableAlias.$strTableFieldName COLLATE NOCASE IN ($includeData)";
              }
              if (attributeQuery.isNotEmpty) {
                formTypeTableCause = "${(formTypeTableCause.isNotEmpty) ? "$formTypeTableCause\nAND " : ""}($attributeQuery)";
              }
              break;
            case 'action_status':
              currentTimeInMs = (currentTimeInMs.isEmpty) ? (DateTime.now().millisecondsSinceEpoch.toString()) : currentTimeInMs;
              for (var valueMapNode in dataListNode) {
                String tmpDataValue = valueMapNode['value']?.toString().trim() ?? "";
                String includeData = "";
                switch (tmpDataValue.toLowerCase()) {
                  case 'cleared':
                    includeData = "$formActionTableAlias.${FormMessageActionDao.isActionClearField}=1";
                    break;
                  case 'incomplete':
                    includeData = "$formActionTableAlias.${FormMessageActionDao.isActionCompleteField}=0 AND $formActionTableAlias.${FormMessageActionDao.actionCompleteDateMilliSecondField}=0";
                    break;
                  case 'incomplete and overdue':
                    includeData = "$formActionTableAlias.${FormMessageActionDao.isActionCompleteField}=0 AND $formActionTableAlias.${FormMessageActionDao.actionCompleteDateMilliSecondField}=0 AND $formActionTableAlias.${FormMessageActionDao.actionDueDateMilliSecondField}<$currentTimeInMs";
                    break;
                  case 'complete':
                    includeData = "$formActionTableAlias.${FormMessageActionDao.isActionCompleteField}=1 AND $formActionTableAlias.${FormMessageActionDao.isActionClearField}<>1";
                    break;
                  case 'completed late':
                    includeData = "$formActionTableAlias.${FormMessageActionDao.isActionCompleteField}=1 AND $formActionTableAlias.${FormMessageActionDao.actionCompleteDateMilliSecondField}>$formActionTableAlias.${FormMessageActionDao.actionDueDateMilliSecondField}";
                    break;
                  case 'completed on time':
                    includeData = "$formActionTableAlias.${FormMessageActionDao.isActionCompleteField}=1 AND $formActionTableAlias.${FormMessageActionDao.actionCompleteDateMilliSecondField}<=$formActionTableAlias.${FormMessageActionDao.actionDueDateMilliSecondField}";
                    break;
                  case 'deactivated':
                    includeData = "$formActionTableAlias.${FormMessageActionDao.isActiveField}=0";
                    break;
                }
                if (includeData.isNotEmpty) {
                  attributeQuery = "${(attributeQuery.isNotEmpty) ? "$attributeQuery OR " : ""}($includeData)";
                }
              }
              if (attributeQuery.isNotEmpty) {
                formActionTableCause = "${(formActionTableCause.isNotEmpty) ? "$formActionTableCause\nAND " : ""}($attributeQuery)";
              }
              break;
            case 'status_id':
              break;
            case 'distribution_list':
            case 'recipient_org':
              String includeData = "";
              for (var valueMapNode in dataListNode) {
                String tmpDataValue = valueMapNode['id']?.toString().trim().replaceAll("'", "''") ?? "";
                includeData = "${(includeData.isNotEmpty) ? "$includeData," : ""}'$tmpDataValue'";
              }
              if (includeData.isNotEmpty) {
                attributeQuery = "$formActionTableAlias.$strTableFieldName COLLATE NOCASE IN ($includeData)";
              }
              if (attributeQuery.isNotEmpty) {
                formActionTableCause = "${(formActionTableCause.isNotEmpty) ? "$formActionTableCause\nAND " : ""}($attributeQuery)";
              }
              break;
            case 'form_creation_date':
              String includeData = "";
              for (var valueMapNode in dataListNode) {
                String tmpDataValue = valueMapNode['value']?.toString().trim() ?? "";
                tmpDataValue = await filterDateFormattedQuery(formTableAlias, strTableFieldName, tmpDataValue);
                includeData = "${(includeData.isNotEmpty) ? "$includeData OR " : ""}($tmpDataValue)";
              }
              if (includeData.isNotEmpty) {
                attributeQuery = includeData;
              }
              if (attributeQuery.isNotEmpty) {
                formTableCause = "${(formTableCause.isNotEmpty) ? "$formTableCause\nAND " : ""}($attributeQuery)";
              }
              break;
            case 'due_date':
              String includeData = "";
              for (var valueMapNode in dataListNode) {
                String tmpDataValue = valueMapNode['value']?.toString().trim() ?? "";
                tmpDataValue = await filterDateFormattedQuery(formActionTableAlias, strTableFieldName, tmpDataValue);
                includeData = "${(includeData.isNotEmpty) ? "$includeData OR " : ""}($tmpDataValue)";
              }
              if (includeData.isNotEmpty) {
                attributeQuery = includeData;
              }
              if (attributeQuery.isNotEmpty) {
                formActionTableCause = "${(formActionTableCause.isNotEmpty) ? "$formActionTableCause\nAND " : ""}($attributeQuery)";
              }
              break;
            case 'form_title':
              break;
            case 'cfid_tasktype':
              break;
            case 'summary':
              //OriginatorDisplayName#FormTitle#ObservationDefectType#ManageTypeName#UserRefCode#Code#FormCreationDate#StatusName#Status

              var strTableFieldList = strTableFieldName.split('#');
              for (var valueMapNode in dataListNode) {
                var tmpDataValueList = valueMapNode['value']?.trim().toLowerCase().split(" or ") ?? [];
                for (var strFieldValue in tmpDataValueList) {
                  for (var strTblFldName in strTableFieldList) {
                    if (strTblFldName != "ManageTypeName") {
                      if (attributeQuery.isNotEmpty) {
                        attributeQuery = "$attributeQuery OR ";
                      }
                      attributeQuery = "$attributeQuery$formTableAlias.$strTblFldName LIKE '%$strFieldValue%'";
                    } else {
                      manageTypeTableCause = "ManageTypeName";
                      if (attributeQuery.isNotEmpty) {
                        attributeQuery = "$attributeQuery OR ";
                      }
                      attributeQuery = "$attributeQuery$manageTableAlias.$strTblFldName LIKE '%$strFieldValue%'";
                    }
                  }
                }
              }
              if (attributeQuery.isNotEmpty) {
                formTableCause = "${(formTableCause.isNotEmpty) ? "$formTableCause\nAND " : ""}($attributeQuery)";
              }
              break;
          }
        }
      }
    }
    if (formTableCause.isNotEmpty) {
      filterQuery = "SELECT DISTINCT frmTbl.FormId FROM ${FormDao.tableName} $formTableAlias";
      if (formTypeTableCause.isNotEmpty) {
        filterQuery = "$filterQuery\nINNER JOIN ${FormTypeDao.tableName} $formTypeTableAlias ON $formTypeTableAlias.ProjectId=$formTableAlias.ProjectId AND $formTypeTableAlias.FormTypeId=$formTableAlias.FormTypeId";
      }
      if (formActionTableCause.isNotEmpty) {
        filterQuery = "$filterQuery\nINNER JOIN ${FormMessageActionDao.tableName} frmActTbl ON frmActTbl.ProjectId=$formTableAlias.ProjectId AND frmActTbl.FormId=$formTableAlias.FormId";
      }
      if (manageTypeTableCause.isNotEmpty) {
        filterQuery = "$filterQuery\nINNER JOIN ${ManageTypeDao.tableName} $manageTableAlias ON  $manageTableAlias.ManageTypeId=$formTableAlias.ObservationDefectTypeId";
      }
      filterQuery = "$filterQuery"
          "\n$formTableCause"
          "${formTypeTableCause.isNotEmpty ? "\nAND $formTypeTableCause" : ""}"
          "${formActionTableCause.isNotEmpty ? "\nAND $formActionTableCause" : ""}";
    }
    if (filterQuery.isNotEmpty) {
      filterQuery = "$aliasName${FormDao.formIdField} IN (\n$filterQuery\n)";
    }
    return filterQuery;
  }

  String siteFormSortingOrderQuery(String aliasName, Map<String, dynamic> request) {
    String sortField = ListSortField.lastUpdatedDate.fieldName;
    String sortOrder = "DESC";
    try {
      if (request.containsKey("sortField")) {
        sortField = request["sortField"]?.toString() ?? ListSortField.lastUpdatedDate.fieldName;
        sortOrder = request["sortOrder"]?.toString().toUpperCase() ?? sortOrder;
      }
    } catch (e) {
      Log.d("SiteFormListingLocalDataSource::_sortingOrderQuery exception $e");
    }
    switch (ListSortField.fromString(sortField)) {
      case ListSortField.creationDate:
      case ListSortField.creation_date:
        sortField = "FormCreationDateInMS";
        break;
      case ListSortField.due_date:
        sortField = "ResponseRequestByInMS";
        break;
      case ListSortField.lastUpdatedDate:
        sortField = "UpdatedDateInMS";
        break;
      case ListSortField.siteTitle:
        sortField = "FormTitle COLLATE NOCASE";
        break;
      default:
        break;
    }
    return "ORDER BY $aliasName.$sortField $sortOrder";
  }

  String siteFormLimitSizeQuery(int startFrom, int batchSize) {
    return "LIMIT $startFrom, $batchSize";
  }
}
