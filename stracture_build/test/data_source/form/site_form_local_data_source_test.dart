import 'package:field/data_source/forms/site_form_local_data_source.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/enums.dart';
import 'package:field/injection_container.dart' as di;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';

class MockDatabaseManager extends Mock implements DatabaseManager {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  await di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();

  SiteFormLocalDataSource dbManager = SiteFormLocalDataSource();

  group("SiteFormLocalDataSource Test", () {
    test("filterAttributeTableColumnName CFID_LocationName Test", () {
      final columnName = dbManager.filterAttributeTableColumnName('CFID_LocationName');
      expect(columnName == "BaseLocationPath", true);
    });

    test("filterAttributeTableColumnName CFID_TaskType Test", () {
      final columnName = dbManager.filterAttributeTableColumnName('CFID_TaskType');
      expect(columnName.isEmpty, true);
    });

    test("filterAttributeTableColumnName summary Test", () {
      final columnName = dbManager.filterAttributeTableColumnName('summary');
      expect(columnName == "OriginatorDisplayName#FormTitle#ObservationDefectType#ManageTypeName#UserRefCode#Code#FormCreationDate#StatusName#Status", true);
    });

    test("siteFormListViewQuery Test", () {
      final outputQuery = "WITH CTE_ObservationView AS (\n"
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
          "FROM FormListTbl frmTbl\n"
          "INNER JOIN ProjectDetailTbl prjTbl ON prjTbl.ProjectId=frmTbl.ProjectId AND prjTbl.StatusId<>7\n"
          "LEFT JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=frmTbl.ProjectId AND frmTpTbl.FormTypeId=frmTbl.FormTypeId\n"
          "LEFT JOIN FormMessageListTbl MsgLst ON MsgLst.ProjectId=frmTbl.ProjectId AND MsgLst.FormId=frmTbl.FormId AND MsgLst.MsgId=frmTbl.MessageId\n"
          "LEFT JOIN StatusStyleListTbl StatStyTbl ON StatStyTbl.ProjectId=frmTbl.ProjectId AND StatStyTbl.StatusId=frmTbl.StatusId\n"
          "LEFT JOIN ManageTypeListTbl ManTpTbl ON ManTpTbl.ProjectId=frmTbl.ProjectId AND ManTpTbl.ManageTypeId=frmTbl.ObservationDefectTypeId\n"
          "LEFT JOIN LocationDetailTbl locTbl ON locTbl.ProjectId = frmTbl.ProjectId AND locTbl.LocationId = frmTbl.LocationId\n"
          ")";
      final queryStr = dbManager.siteFormListViewQuery('CTE_ObservationView');
      expect(queryStr, outputQuery);
    });

    test("siteFormFilterQuery Test", () async {
      String filterJsonData =
          "{\"creationDate\":\"\",\"filterName\":\"Unsaved Filter\",\"filterQueryVOs\":[{\"dataType\":\"Text\",\"fieldName\":\"form_type_name\",\"id\":860,\"indexField\":\"form_type_name\",\"isBlankSearchAllowed\":false,\"isCustomAttribute\":false,\"labelName\":\"Form Type\",\"operatorId\":11,\"logicalOperator\":\"AND\",\"popupTo\":{\"data\":[{\"dataCenterId\":1,\"id\":\"Site Tasks\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Site Tasks\"},{\"dataCenterId\":1,\"id\":\"Edit ORI\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Edit ORI\"}],\"recordBatchSize\":\"0\"},\"returnIndexFields\":\"form_type_name,form_type_id\",\"sequenceId\":1,\"solrCollections\":\"forms\"},{\"dataType\":\"Text\",\"fieldName\":\"originator_user_id\",\"id\":764,\"indexField\":\"originator_user_id\",\"isBlankSearchAllowed\":false,\"isCustomAttribute\":false,\"labelName\":\"Originator\",\"operatorId\":11,\"logicalOperator\":\"AND\",\"popupTo\":{\"data\":[{\"dataCenterId\":1,\"id\":707447,\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Vijay Mavadiya (5336), Asite Solutions\"},{\"dataCenterId\":1,\"id\":2017529,\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Mayur Raval m., Asite Solutions Ltd\"}],\"recordBatchSize\":\"0\"},\"returnIndexFields\":\"originator_user_id\",\"sequenceId\":1,\"solrCollections\":\"users\"},{\"dataType\":\"Text\",\"fieldName\":\"originator_organisation\",\"id\":765,\"indexField\":\"originator_organisation\",\"isBlankSearchAllowed\":false,\"isCustomAttribute\":false,\"labelName\":\"Originator Organisation\",\"operatorId\":11,\"logicalOperator\":\"AND\",\"popupTo\":{\"data\":[{\"dataCenterId\":1,\"id\":5763307,\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Asite Solutions Ltd\"}],\"recordBatchSize\":\"0\"},\"returnIndexFields\":\"orgId,orgName\",\"sequenceId\":1,\"solrCollections\":\"users\"},{\"dataType\":\"Text\",\"fieldName\":\"distribution_list\",\"id\":380,\"indexField\":\"distribution_list\",\"isBlankSearchAllowed\":false,\"isCustomAttribute\":false,\"labelName\":\"Recipient\",\"operatorId\":11,\"logicalOperator\":\"AND\",\"popupTo\":{\"data\":[{\"dataCenterId\":1,\"id\":\"707447\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Vijay Mavadiya (5336), Asite Solutions\"}],\"recordBatchSize\":\"0\"},\"returnIndexFields\":\"distribution_list\",\"sequenceId\":1,\"solrCollections\":\"users\"},{\"dataType\":\"Text\",\"fieldName\":\"recipient_org\",\"id\":767,\"indexField\":\"recipient_org\",\"isBlankSearchAllowed\":false,\"isCustomAttribute\":false,\"labelName\":\"Recipient Organization\",\"operatorId\":11,\"logicalOperator\":\"AND\",\"popupTo\":{\"data\":[{\"dataCenterId\":1,\"id\":\"3\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Asite Solutions\"}],\"recordBatchSize\":\"0\"},\"returnIndexFields\":\"orgId,orgName\",\"sequenceId\":1,\"solrCollections\":\"users\"},{\"dataType\":\"text\",\"fieldName\":\"form_status\",\"id\":364,\"indexField\":\"form_status\",\"isBlankSearchAllowed\":false,\"isCustomAttribute\":false,\"labelName\":\"Status\",\"operatorId\":1,\"logicalOperator\":\"AND\",\"popupTo\":{\"data\":[{\"dataCenterId\":1,\"id\":\"Open\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Open\"},{\"dataCenterId\":1,\"id\":\"Resolved\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Resolved\"},{\"dataCenterId\":1,\"id\":\"Verified\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Verified\"}],\"recordBatchSize\":\"0\"},\"returnIndexFields\":\"status_id,status_name\",\"sequenceId\":1,\"solrCollections\":\"docstatuscache\"},{\"dataType\":\"Dropdown\",\"fieldName\":\"action_status\",\"id\":374,\"indexField\":\"action_status\",\"isBlankSearchAllowed\":false,\"isCustomAttribute\":false,\"labelName\":\"Task Status\",\"operatorId\":1,\"logicalOperator\":\"AND\",\"popupTo\":{\"data\":[{\"dataCenterId\":1,\"id\":\"2\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Complete\"},{\"dataCenterId\":1,\"id\":\"5\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Incomplete\"}],\"recordBatchSize\":\"0\"},\"returnIndexFields\":\"-1\",\"sequenceId\":1,\"solrCollections\":\"actionscomments\"}],\"id\":\"-1\",\"isUnsavedFilter\":true,\"listingTypeId\":\"31\",\"selectedFolderIds\":\"-1\",\"selectedProjectIds\":\"2130192\",\"subListingTypeId\":\"1\",\"userId\":\"-1\"}";
      String outputResult = "obsrvTbl.FormId IN (\n"
          "SELECT DISTINCT frmTbl.FormId FROM FormListTbl frmTbl\n"
          "INNER JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=frmTbl.ProjectId AND frmTpTbl.FormTypeId=frmTbl.FormTypeId\n"
          "INNER JOIN FormMsgActionListTbl frmActTbl ON frmActTbl.ProjectId=frmTbl.ProjectId AND frmActTbl.FormId=frmTbl.FormId\n"
          "WHERE (frmTbl.IsActive=1)\n"
          "AND (frmTbl.OriginatorId COLLATE NOCASE IN ('707447','2017529'))\n"
          "AND (frmTbl.OrgId COLLATE NOCASE IN ('5763307'))\n"
          "AND (frmTbl.StatusName COLLATE NOCASE IN ('Open','Resolved','Verified'))\n"
          "AND (frmTpTbl.FormTypeName COLLATE NOCASE IN ('Site Tasks','Edit ORI'))\n"
          "AND (frmActTbl.RecipientUserId COLLATE NOCASE IN ('707447'))\n"
          "AND (frmActTbl.RecipientOrgId COLLATE NOCASE IN ('3'))\n"
          "AND ((frmActTbl.IsActionComplete=1 AND frmActTbl.IsActionClear<>1) OR (frmActTbl.IsActionComplete=0 AND frmActTbl.ActionCompleteDateMilliSecond=0))\n"
          ")";
      var result = await dbManager.siteFormFilterQuery("obsrvTbl", filterJsonData);
      expect(result, outputResult);
    });

    test("siteFormFilterQuery Date Test", () async {
      String filterJsonData =
          "{\"creationDate\":\"\",\"filterName\":\"Unsaved Filter\",\"filterQueryVOs\":[{\"dataType\":\"Date\",\"fieldName\":\"form_creation_date\",\"id\":766,\"indexField\":\"form_creation_date\",\"isBlankSearchAllowed\":false,\"isCustomAttribute\":false,\"labelName\":\"Created Date\",\"operatorId\":11,\"logicalOperator\":\"AND\",\"popupTo\":{\"data\":[{\"dataCenterId\":1,\"id\":\"rpton#on#19-Jul-2023\",\"imgId\":0,\"isActive\":false,\"isSelected\":false,\"rangeFilterData\":{\"dataType\":\"date\",\"fromVal\":\"19-Jul-2023\",\"targetId\":\"On\"},\"value\":\"rpton#on#19-Jul-2023\"}],\"recordBatchSize\":\"0\"},\"returnIndexFields\":\"-1\",\"sequenceId\":1,\"solrCollections\":\"forms\"},{\"dataType\":\"Date\",\"fieldName\":\"due_date\",\"id\":768,\"indexField\":\"due_date\",\"isBlankSearchAllowed\":true,\"isCustomAttribute\":false,\"labelName\":\"Task due date\",\"operatorId\":11,\"logicalOperator\":\"AND\",\"popupTo\":{\"data\":[{\"dataCenterId\":1,\"id\":\"rpton#on#27-Jul-2023\",\"imgId\":0,\"isActive\":false,\"isSelected\":false,\"rangeFilterData\":{\"dataType\":\"date\",\"fromVal\":\"27-Jul-2023\",\"targetId\":\"On\"},\"value\":\"rpton#on#27-Jul-2023\"}],\"recordBatchSize\":\"0\"},\"returnIndexFields\":\"-1\",\"sequenceId\":1,\"solrCollections\":\"actioncomments\"}],\"id\":\"-1\",\"isUnsavedFilter\":true,\"listingTypeId\":\"31\",\"selectedFolderIds\":\"-1\",\"selectedProjectIds\":\"2130192\",\"subListingTypeId\":\"1\",\"userId\":\"-1\"}";
      String outputResult = "frmTbl.FormId IN (\n"
          "SELECT DISTINCT frmTbl.FormId FROM FormListTbl frmTbl\n"
          "INNER JOIN FormMsgActionListTbl frmActTbl ON frmActTbl.ProjectId=frmTbl.ProjectId AND frmActTbl.FormId=frmTbl.FormId\n"
          "WHERE (frmTbl.IsActive=1)\n"
          "AND ((frmTbl.FormCreationDateInMS BETWEEN 1689705000000 AND 1689791399000))\n"
          "AND ((frmActTbl.ActionDueDateMilliSecond BETWEEN 1690396200000 AND 1690482599000))\n"
          ")";
      var result = await dbManager.siteFormFilterQuery("frmTbl", filterJsonData);
      expect(result, outputResult);
    });

    test("siteFormFilterQuery Date between & status not in Test", () async {
      String filterJsonData =
          "{\"creationDate\":\"\",\"filterName\":\"Unsaved Filter\",\"filterQueryVOs\":[{\"dataType\":\"text\",\"fieldName\":\"form_status\",\"id\":364,\"indexField\":\"form_status\",\"isBlankSearchAllowed\":false,\"isCustomAttribute\":false,\"labelName\":\"Status\",\"operatorId\":1,\"logicalOperator\":\"AND\",\"popupTo\":{\"data\":[{\"dataCenterId\":1,\"id\":\"Other\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"notInStatus\":\"Resolved, Verified\",\"rangeFilterData\":{},\"value\":\"Other\"}],\"recordBatchSize\":\"0\"},\"returnIndexFields\":\"status_id,status_name\",\"sequenceId\":1,\"solrCollections\":\"docstatuscache\"},{\"dataType\":\"Date\",\"fieldName\":\"form_creation_date\",\"id\":766,\"indexField\":\"form_creation_date\",\"isBlankSearchAllowed\":false,\"isCustomAttribute\":false,\"labelName\":\"Created Date\",\"operatorId\":11,\"logicalOperator\":\"AND\",\"popupTo\":{\"data\":[{\"dataCenterId\":1,\"id\":\"rptbetween#from#19-Jul-2023|20-Jul-2023\",\"imgId\":0,\"isActive\":false,\"isSelected\":false,\"rangeFilterData\":{\"dataType\":\"date\",\"fromVal\":\"19-Jul-2023\",\"toVal\":\"20-Jul-2023\",\"targetId\":\"between\"},\"value\":\"rptbetween#from#19-Jul-2023|20-Jul-2023\"}],\"recordBatchSize\":\"0\"},\"returnIndexFields\":\"-1\",\"sequenceId\":1,\"solrCollections\":\"forms\"}],\"id\":\"-1\",\"isUnsavedFilter\":true,\"listingTypeId\":\"31\",\"selectedFolderIds\":\"-1\",\"selectedProjectIds\":\"2130192\",\"subListingTypeId\":\"1\",\"userId\":\"-1\"}";
      String outputResult = "frmTbl.FormId IN (\n"
          "SELECT DISTINCT frmTbl.FormId FROM FormListTbl frmTbl\n"
          "WHERE (frmTbl.IsActive=1)\n"
          "AND (frmTbl.StatusName COLLATE NOCASE NOT IN ('Resolved','Verified'))\n"
          "AND ((frmTbl.FormCreationDateInMS BETWEEN 1689705000000 AND 1689877799000))\n"
          ")";
      var result = await dbManager.siteFormFilterQuery("frmTbl", filterJsonData);
      expect(result, outputResult);
    });

    test("siteFormFilterQuery Search Filter with other filter Test", () async {
      String filterJsonData =
          "{\"creationDate\":\"\",\"filterName\":\"Unsaved Filter\",\"filterQueryVOs\":[{\"dataType\":\"Text\",\"fieldName\":\"summary\",\"id\":1499,\"indexField\":\"summary\",\"isBlankSearchAllowed\":false,\"isCustomAttribute\":false,\"labelName\":\"Content\",\"operatorId\":11,\"logicalOperator\":\"AND\",\"popupTo\":{\"data\":[{\"dataCenterId\":1,\"id\":\"search test\",\"imgId\":0,\"isActive\":false,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"search test\"}],\"recordBatchSize\":\"0\"},\"returnIndexFields\":\"-1\",\"sequenceId\":1,\"solrCollections\":\"forms\"},{\"dataType\":\"Date\",\"fieldName\":\"form_creation_date\",\"id\":766,\"indexField\":\"form_creation_date\",\"isBlankSearchAllowed\":false,\"isCustomAttribute\":false,\"labelName\":\"Created Date\",\"operatorId\":11,\"logicalOperator\":\"AND\",\"popupTo\":{\"data\":[{\"dataCenterId\":1,\"id\":\"rpton#on#19-Jul-2023\",\"imgId\":0,\"isActive\":false,\"isSelected\":false,\"rangeFilterData\":{\"dataType\":\"date\",\"fromVal\":\"19-Jul-2023\",\"targetId\":\"On\"},\"value\":\"rpton#on#19-Jul-2023\"}],\"recordBatchSize\":\"0\"},\"returnIndexFields\":\"-1\",\"sequenceId\":1,\"solrCollections\":\"forms\"},{\"dataType\":\"Date\",\"fieldName\":\"due_date\",\"id\":768,\"indexField\":\"due_date\",\"isBlankSearchAllowed\":true,\"isCustomAttribute\":false,\"labelName\":\"Task due date\",\"operatorId\":11,\"logicalOperator\":\"AND\",\"popupTo\":{\"data\":[{\"dataCenterId\":1,\"id\":\"rpton#on#27-Jul-2023\",\"imgId\":0,\"isActive\":false,\"isSelected\":false,\"rangeFilterData\":{\"dataType\":\"date\",\"fromVal\":\"27-Jul-2023\",\"targetId\":\"On\"},\"value\":\"rpton#on#27-Jul-2023\"}],\"recordBatchSize\":\"0\"},\"returnIndexFields\":\"-1\",\"sequenceId\":1,\"solrCollections\":\"actioncomments\"},{\"dataType\":\"Dropdown\",\"fieldName\":\"action_status\",\"id\":374,\"indexField\":\"action_status\",\"isBlankSearchAllowed\":false,\"isCustomAttribute\":false,\"labelName\":\"Task Status\",\"operatorId\":1,\"logicalOperator\":\"AND\",\"popupTo\":{\"data\":[{\"dataCenterId\":1,\"id\":\"1\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Cleared\"},{\"dataCenterId\":1,\"id\":\"2\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Complete\"},{\"dataCenterId\":1,\"id\":\"3\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Completed Late\"},{\"dataCenterId\":1,\"id\":\"4\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Completed on Time\"},{\"dataCenterId\":1,\"id\":\"7\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Deactivated\"},{\"dataCenterId\":1,\"id\":\"5\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Incomplete\"},{\"dataCenterId\":1,\"id\":\"6\",\"imgId\":-1,\"isActive\":true,\"isSelected\":true,\"rangeFilterData\":{},\"value\":\"Incomplete and Overdue\"}],\"recordBatchSize\":\"0\"},\"returnIndexFields\":\"-1\",\"sequenceId\":1,\"solrCollections\":\"actionscomments\"}],\"id\":\"-1\",\"isUnsavedFilter\":true,\"listingTypeId\":\"31\",\"selectedFolderIds\":\"-1\",\"selectedProjectIds\":\"2130192\",\"subListingTypeId\":\"1\",\"userId\":\"-1\"}";
      final currentTimeInMs = DateTime.now().millisecondsSinceEpoch.toString();
      String outputResult = "frmTbl.FormId IN (\n"
          "SELECT DISTINCT frmTbl.FormId FROM FormListTbl frmTbl\n"
          "INNER JOIN FormMsgActionListTbl frmActTbl ON frmActTbl.ProjectId=frmTbl.ProjectId AND frmActTbl.FormId=frmTbl.FormId\n"
          "WHERE (frmTbl.IsActive=1)\n"
          "AND (frmTbl.OriginatorDisplayName LIKE '%search test%' OR frmTbl.FormTitle LIKE '%search test%' OR frmTbl.ObservationDefectType LIKE '%search test%' OR frmTbl.UserRefCode LIKE '%search test%' OR frmTbl.Code LIKE '%search test%' OR frmTbl.FormCreationDate LIKE '%search test%' OR frmTbl.StatusName LIKE '%search test%' OR frmTbl.Status LIKE '%search test%')\n"
          "AND ((frmTbl.FormCreationDateInMS BETWEEN 1689705000000 AND 1689791399000))\n"
          "AND ((frmActTbl.ActionDueDateMilliSecond BETWEEN 1690396200000 AND 1690482599000))\n"
          "AND ((frmActTbl.IsActionClear=1) OR (frmActTbl.IsActionComplete=1 AND frmActTbl.IsActionClear<>1) OR (frmActTbl.IsActionComplete=1 AND frmActTbl.ActionCompleteDateMilliSecond>frmActTbl.ActionDueDateMilliSecond) OR (frmActTbl.IsActionComplete=1 AND frmActTbl.ActionCompleteDateMilliSecond<=frmActTbl.ActionDueDateMilliSecond) OR (frmActTbl.IsActive=0) OR (frmActTbl.IsActionComplete=0 AND frmActTbl.ActionCompleteDateMilliSecond=0) OR (frmActTbl.IsActionComplete=0 AND frmActTbl.ActionCompleteDateMilliSecond=0 AND frmActTbl.ActionDueDateMilliSecond<$currentTimeInMs))\n"
          ")";
      var result = await dbManager.siteFormFilterQuery("frmTbl", filterJsonData, currentTimeInMs: currentTimeInMs);
      expect(result, outputResult);
    });

    test('siteFormSortingOrderQuery default Test', () {
      final result = dbManager.siteFormSortingOrderQuery("obsrvTbl", {});
      expect(result, "ORDER BY obsrvTbl.UpdatedDateInMS DESC");
    });

    test('siteFormSortingOrderQuery default with other field Test', () {
      final result = dbManager.siteFormSortingOrderQuery("obsrvTbl", {"sortField": "test", "sortOrder": "asc"});
      expect(result, "ORDER BY obsrvTbl.UpdatedDateInMS ASC");
    });

    test('siteFormSortingOrderQuery creationDate Test', () {
      final result = dbManager.siteFormSortingOrderQuery("obsrvTbl", {"sortField": ListSortField.creationDate.fieldName, "sortOrder": "asc"});
      expect(result, "ORDER BY obsrvTbl.FormCreationDateInMS ASC");
    });

    test('siteFormSortingOrderQuery creation_date Test', () {
      final result = dbManager.siteFormSortingOrderQuery("obsrvTbl", {"sortField": ListSortField.creation_date.fieldName, "sortOrder": "asc"});
      expect(result, "ORDER BY obsrvTbl.FormCreationDateInMS ASC");
    });

    test('siteFormSortingOrderQuery due_date Test', () {
      final result = dbManager.siteFormSortingOrderQuery("obsrvTbl", {"sortField": ListSortField.due_date.fieldName, "sortOrder": "asc"});
      expect(result, "ORDER BY obsrvTbl.ResponseRequestByInMS ASC");
    });

    test('siteFormSortingOrderQuery lastUpdatedDate Test', () {
      final result = dbManager.siteFormSortingOrderQuery("obsrvTbl", {"sortField": ListSortField.lastUpdatedDate.fieldName, "sortOrder": "asc"});
      expect(result, "ORDER BY obsrvTbl.UpdatedDateInMS ASC");
    });

    test('siteFormSortingOrderQuery siteTitle Test', () {
      final result = dbManager.siteFormSortingOrderQuery("obsrvTbl", {"sortField": ListSortField.siteTitle.fieldName, "sortOrder": "asc"});
      expect(result, "ORDER BY obsrvTbl.FormTitle COLLATE NOCASE ASC");
    });

    test('siteFormLimitSizeQuery Test', () {
      final result = dbManager.siteFormLimitSizeQuery(25, 50);
      expect(result, "LIMIT 25, 50");
    });
  });
}
