import 'dart:convert';

import 'package:field/data/dao/form_dao.dart';
import 'package:field/data/dao/form_message_attachAndAssoc_dao.dart';
import 'package:field/data/dao/formtype_dao.dart';
import 'package:field/database/db_service.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/sync/calculation/site_form_listing_local_data_soruce.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/common.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/fixture_reader.dart';

class DBServiceMock extends Mock implements DBService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setAsitePluginsMethodChannel();
  di.init(test: true);

  DBServiceMock mockDb = DBServiceMock();

  late SiteFormListingLocalDataSource siteFormListingLocalDataSource;

  configureDependencies() {
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json")});
    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb);
  }

  setUp(() async {
    configureDependencies();
    siteFormListingLocalDataSource = SiteFormListingLocalDataSource();
  });

  group("test getOfflineObservationListJson", () {
    test("test getOfflineObservationListJson pass valid result expected success", () async {
      String requestJson = """{"appType":"2","applicationId":"3","checkHashing":"false","isRequiredTemplateData":"true","requiredCustomAttributes":"CFID_Assigned,CFID_DefectTyoe,CFID_TaskType","customAttributeFieldPresent":"true","projectId":"2089700","folderId":"115418607","locationId":"185266","projectIds":"2089700","currentPageNo":"1","recordBatchSize":"25","recordStartFrom":"0","sortField":"formCreationDate","sortFieldType":"timestamp","sortOrder":"desc","lastApiCallTimeStamp":1691740412298,"isFromSyncCall":"true","action_id":"100","controller":"/commonapi/pfobservationservice/getObservationList","listingType":"31","isExcludeClosesOutForms":"true"}""";
      Map<String, dynamic> requestMap = jsonDecode(requestJson);

      String totalFormCountQuery = """WITH CTE_ObservationView AS (
SELECT prjTbl.DcId AS dcId,frmTbl.ProjectId,frmTbl.FormId,frmTbl.FormTypeId,frmTbl.ResponseRequestByInMS,frmTbl.FormTitle,frmTbl.Code,frmTbl.CommentId,frmTbl.MessageId,frmTbl.OrgId,frmTbl.FirstName,frmTbl.LastName,frmTbl.OrgName,frmTbl.Originator,frmTbl.OriginatorDisplayName,frmTbl.NoOfActions,frmTbl.TaskTypeName,frmTbl.ObservationId,frmTbl.LocationId,frmTbl.PfLocFolderId,frmTbl.Updated,frmTbl.AttachmentImageName,frmTbl.TypeImage,frmTbl.DocType,frmTbl.HasAttachments,frmTbl.HasDocAssocations,frmTbl.HasBimViewAssociations,frmTbl.HasFormAssocations,frmTbl.HasCommentAssocations,frmTbl.FormHasAssocAttach,frmTbl.FormCreationDate,frmTbl.FormNumber,frmTbl.IsDraft,frmTbl.StatusId,frmTbl.OriginatorId,frmTbl.Id,frmTbl.StatusChangeUserId,frmTbl.StatusUpdateDate,frmTbl.StatusChangeUserName,frmTbl.StatusChangeUserPic,frmTbl.StatusChangeUserEmail,frmTbl.StatusChangeUserOrg,frmTbl.OriginatorEmail,frmTbl.ControllerUserId,frmTbl.UpdatedDateInMS,frmTbl.FormCreationDateInMS,frmTbl.FlagType,frmTbl.LatestDraftId,frmTbl.FlagTypeImageName,frmTbl.MessageTypeImageName,frmTbl.FormJsonData,frmTbl.AttachedDocs,frmTbl.IsUploadAttachmentInTemp,frmTbl.IsSync,frmTbl.HasActions,frmTbl.CanRemoveOffline,frmTbl.IsMarkOffline,frmTbl.IsOfflineCreated,frmTbl.SyncStatus,frmTbl.IsForDefect,frmTbl.IsForApps,frmTbl.ObservationDefectTypeId,frmTbl.StartDate,frmTbl.ExpectedFinishDate,frmTbl.IsActive,frmTbl.ObservationCoordinates,frmTbl.AnnotationId,frmTbl.AssignedToUserId,frmTbl.AssignedToUserName,frmTbl.AssignedToUserOrgName,frmTbl.AssignedToRoleName,frmTbl.RevisionId,frmTbl.PageNumber,frmTbl.RequestJsonForOffline,frmTbl.FormDueDays,frmTbl.FormSyncDate,frmTbl.LastResponderForAssignedTo,frmTbl.LastResponderForOriginator,frmTbl.ObservationDefectType,IIF(frmTbl.StatusName='',frmTbl.Status,frmTbl.StatusName) AS StatusName,IFNULL(frmTpTbl.AllowLocationAssociation,0) AS AllowLocationAssociation,IFNULL(frmTpTbl.AppTypeId,frmTbl.AppTypeId) AS AppTypeId,IFNULL(frmTpTbl.InstanceGroupId,frmTbl.InstanceGroupId) AS InstanceGroupId,IFNULL(frmTpTbl.TemplateTypeId,frmTbl.TemplateType) AS TemplateTypeId,IFNULL(frmTpTbl.AppBuilderId,frmTbl.AppBuilderId) AS AppBuilderId,IFNULL(frmTpTbl.FormTypeName,'') AS FormTypeName,IFNULL(frmTpTbl.FormTypeGroupName,'') AS FormTypeGroupName,IFNULL(frmTpTbl.FormTypeGroupCode,'') AS FormTypeGroupCode,IFNULL(ManTpTbl.ManageTypeId,frmTbl.ObservationDefectTypeId) AS ManageTypeId,IFNULL(ManTpTbl.ManageTypeName,frmTbl.ObservationDefectType) AS ManageTypeName,IFNULL(StatStyTbl.StatusName,frmTbl.Status) AS Status,IFNULL(StatStyTbl.FontColor,'') AS FontColor,IFNULL(StatStyTbl.BackgroundColor,'') AS BackgroundColor,IFNULL(StatStyTbl.FontEffect,'') AS FontEffect,IFNULL(StatStyTbl.FontType,'') AS FontType,IFNULL(StatStyTbl.StatusTypeId,'') AS StatusTypeId,IFNULL(StatStyTbl.IsActive,'') AS StatusIsActive,IFNULL(MsgLst.Originator,'') AS MsgOriginator,IFNULL(MsgLst.OriginatorDisplayName,'') AS MsgOriginatorDisplayName,IFNULL(MsgLst.MsgCode,frmTbl.MsgCode) AS MsgCode,IFNULL(MsgLst.MsgCreatedDate,'') AS MsgCreatedDate,IFNULL(MsgLst.ParentMsgId,frmTbl.ParentMessageId) AS ParentMsgId,IFNULL(MsgLst.MsgOriginatorId,frmTbl.MsgOriginatorId) AS MsgOriginatorId,IFNULL(MsgLst.MsgHasAssocAttach,'') AS MsgHasAssocAttach,IFNULL(MsgLst.UserRefCode,frmTbl.UserRefCode) AS UserRefCode,IFNULL(MsgLst.UpdatedDateInMS,'') AS MsgUpdatedDateInMS,IFNULL(MsgLst.MsgCreatedDateInMS,'') AS MsgCreatedDateInMS,IFNULL(MsgLst.MsgTypeId,frmTbl.MsgTypeId) AS MsgTypeId,IFNULL(MsgLst.MsgTypeCode,frmTbl.MsgTypeCode) AS MsgTypeCode,IFNULL(MsgLst.MsgStatusId,frmTbl.MsgStatusId) AS MsgStatusId,IFNULL(MsgLst.FolderId,frmTbl.FolderId) AS FolderId,IFNULL(MsgLst.LatestDraftId,'') AS MsgLatestDraftId,IFNULL(MsgLst.IsDraft,'') AS MsgIsDraft,IFNULL(MsgLst.AssocRevIds,'') AS AssocRevIds,IFNULL(MsgLst.ResponseRequestBy,'') AS ResponseRequestBy,IFNULL(MsgLst.DelFormIds,'') AS DelFormIds,IFNULL(MsgLst.AssocFormIds,'') AS AssocFormIds,IFNULL(MsgLst.AssocCommIds,'') AS AssocCommIds,IFNULL(MsgLst.FormUserSet,'') AS FormUserSet,IFNULL(MsgLst.FormPermissionsMap,'') AS FormPermissionsMap,IFNULL(MsgLst.CanOrigChangeStatus,frmTbl.CanOrigChangeStatus) AS CanOrigChangeStatus,IFNULL(MsgLst.CanControllerChangeStatus,'') AS CanControllerChangeStatus,IFNULL(MsgLst.IsStatusChangeRestricted,frmTbl.IsStatusChangeRestricted) AS IsStatusChangeRestricted,IFNULL(MsgLst.HasOverallStatus,'') AS HasOverallStatus,IFNULL(MsgLst.IsCloseOut,frmTbl.IsCloseOut) AS IsCloseOut,IFNULL(MsgLst.AllowReopenForm,frmTbl.AllowReopenForm) AS AllowReopenForm,IFNULL(MsgLst.OfflineRequestData,'') AS OfflineRequestData,IFNULL(MsgLst.IsOfflineCreated,'') AS MsgIsOfflineCreated,IFNULL(MsgLst.MsgNum,frmTbl.MsgNum) AS MsgNum,IFNULL(MsgLst.MsgContent,'') AS MsgContent,IFNULL(MsgLst.ActionComplete,'') AS ActionComplete,IFNULL(MsgLst.ActionCleared,'') AS ActionCleared,IFNULL(MsgLst.HasAttach,'') AS HasAttach,IFNULL(MsgLst.TotalActions,'') AS TotalActions,IFNULL(MsgLst.AttachFiles,'') AS AttachFiles,IFNULL(MsgLst.HasViewAccess,'') AS HasViewAccess,IFNULL(MsgLst.MsgOriginImage,'') AS MsgOriginImage,IFNULL(MsgLst.IsForInfoIncomplete,'') AS IsForInfoIncomplete,IFNULL(MsgLst.MsgCreatedDateOffline,'') AS MsgCreatedDateOffline,IFNULL(MsgLst.LastModifiedTime,'') AS LastModifiedTime,IFNULL(MsgLst.LastModifiedTimeInMS,'') AS LastModifiedTimeInMS,IFNULL(MsgLst.CanViewDraftMsg,'') AS CanViewDraftMsg,IFNULL(MsgLst.CanViewOwnorgPrivateForms,'') AS CanViewOwnorgPrivateForms,IFNULL(MsgLst.IsAutoSavedDraft,'') AS IsAutoSavedDraft,IFNULL(MsgLst.MsgStatusName,'') AS MsgStatusName,IFNULL(MsgLst.ProjectAPDFolderId,'') AS ProjectAPDFolderId,IFNULL(MsgLst.ProjectStatusId,'') AS ProjectStatusId,IFNULL(MsgLst.HasFormAccess,'') AS HasFormAccess,IFNULL(MsgLst.CanAccessHistory,frmTbl.CanAccessHistory) AS CanAccessHistory,IFNULL(MsgLst.HasDocAssocations,'') AS MsgHasDocAssocations,IFNULL(MsgLst.HasBimViewAssociations,'') AS MsgHasBimViewAssociations,IFNULL(MsgLst.HasBimListAssociations,'') AS HasBimListAssociations,IFNULL(MsgLst.HasFormAssocations,'') AS MsgHasFormAssocations,IFNULL(MsgLst.HasCommentAssocations,'') AS MsgHasCommentAssocations FROM FormListTbl frmTbl
INNER JOIN ProjectDetailTbl prjTbl ON prjTbl.ProjectId=frmTbl.ProjectId AND prjTbl.StatusId<>7
LEFT JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=frmTbl.ProjectId AND frmTpTbl.FormTypeId=frmTbl.FormTypeId
LEFT JOIN FormMessageListTbl MsgLst ON MsgLst.ProjectId=frmTbl.ProjectId AND MsgLst.FormId=frmTbl.FormId AND MsgLst.MsgId=frmTbl.MessageId
LEFT JOIN StatusStyleListTbl StatStyTbl ON StatStyTbl.ProjectId=frmTbl.ProjectId AND StatStyTbl.StatusId=frmTbl.StatusId
LEFT JOIN ManageTypeListTbl ManTpTbl ON ManTpTbl.ProjectId=frmTbl.ProjectId AND ManTpTbl.ManageTypeId=frmTbl.ObservationDefectTypeId
)
SELECT COUNT(1) AS TotalCount FROM CTE_ObservationView obsrvTbl
WHERE (obsrvTbl.AppTypeId='2' OR obsrvTbl.AllowLocationAssociation=1) AND obsrvTbl.ProjectId=2089700 AND obsrvTbl.LocationId IN (185266)
AND obsrvTbl.FormId IN (
SELECT DISTINCT frmTbl.FormId FROM FormListTbl frmTbl
WHERE (frmTbl.IsActive=1)
)""";

      ResultSet resultSetTotalFormCountQuery = ResultSet(
          ["TotalCount"],
          null,
          [
            [70]
          ]);

      String observationListQuery = """WITH CTE_ObservationView AS (
SELECT prjTbl.DcId AS dcId,frmTbl.ProjectId,frmTbl.FormId,frmTbl.FormTypeId,frmTbl.ResponseRequestByInMS,frmTbl.FormTitle,frmTbl.Code,frmTbl.CommentId,frmTbl.MessageId,frmTbl.OrgId,frmTbl.FirstName,frmTbl.LastName,frmTbl.OrgName,frmTbl.Originator,frmTbl.OriginatorDisplayName,frmTbl.NoOfActions,frmTbl.TaskTypeName,frmTbl.ObservationId,frmTbl.LocationId,frmTbl.PfLocFolderId,frmTbl.Updated,frmTbl.AttachmentImageName,frmTbl.TypeImage,frmTbl.DocType,frmTbl.HasAttachments,frmTbl.HasDocAssocations,frmTbl.HasBimViewAssociations,frmTbl.HasFormAssocations,frmTbl.HasCommentAssocations,frmTbl.FormHasAssocAttach,frmTbl.FormCreationDate,frmTbl.FormNumber,frmTbl.IsDraft,frmTbl.StatusId,frmTbl.OriginatorId,frmTbl.Id,frmTbl.StatusChangeUserId,frmTbl.StatusUpdateDate,frmTbl.StatusChangeUserName,frmTbl.StatusChangeUserPic,frmTbl.StatusChangeUserEmail,frmTbl.StatusChangeUserOrg,frmTbl.OriginatorEmail,frmTbl.ControllerUserId,frmTbl.UpdatedDateInMS,frmTbl.FormCreationDateInMS,frmTbl.FlagType,frmTbl.LatestDraftId,frmTbl.FlagTypeImageName,frmTbl.MessageTypeImageName,frmTbl.FormJsonData,frmTbl.AttachedDocs,frmTbl.IsUploadAttachmentInTemp,frmTbl.IsSync,frmTbl.HasActions,frmTbl.CanRemoveOffline,frmTbl.IsMarkOffline,frmTbl.IsOfflineCreated,frmTbl.SyncStatus,frmTbl.IsForDefect,frmTbl.IsForApps,frmTbl.ObservationDefectTypeId,frmTbl.StartDate,frmTbl.ExpectedFinishDate,frmTbl.IsActive,frmTbl.ObservationCoordinates,frmTbl.AnnotationId,frmTbl.AssignedToUserId,frmTbl.AssignedToUserName,frmTbl.AssignedToUserOrgName,frmTbl.AssignedToRoleName,frmTbl.RevisionId,frmTbl.PageNumber,frmTbl.RequestJsonForOffline,frmTbl.FormDueDays,frmTbl.FormSyncDate,frmTbl.LastResponderForAssignedTo,frmTbl.LastResponderForOriginator,frmTbl.ObservationDefectType,IIF(frmTbl.StatusName='',frmTbl.Status,frmTbl.StatusName) AS StatusName,IFNULL(frmTpTbl.AllowLocationAssociation,0) AS AllowLocationAssociation,IFNULL(frmTpTbl.AppTypeId,frmTbl.AppTypeId) AS AppTypeId,IFNULL(frmTpTbl.InstanceGroupId,frmTbl.InstanceGroupId) AS InstanceGroupId,IFNULL(frmTpTbl.TemplateTypeId,frmTbl.TemplateType) AS TemplateTypeId,IFNULL(frmTpTbl.AppBuilderId,frmTbl.AppBuilderId) AS AppBuilderId,IFNULL(frmTpTbl.FormTypeName,'') AS FormTypeName,IFNULL(frmTpTbl.FormTypeGroupName,'') AS FormTypeGroupName,IFNULL(frmTpTbl.FormTypeGroupCode,'') AS FormTypeGroupCode,IFNULL(ManTpTbl.ManageTypeId,frmTbl.ObservationDefectTypeId) AS ManageTypeId,IFNULL(ManTpTbl.ManageTypeName,frmTbl.ObservationDefectType) AS ManageTypeName,IFNULL(StatStyTbl.StatusName,frmTbl.Status) AS Status,IFNULL(StatStyTbl.FontColor,'') AS FontColor,IFNULL(StatStyTbl.BackgroundColor,'') AS BackgroundColor,IFNULL(StatStyTbl.FontEffect,'') AS FontEffect,IFNULL(StatStyTbl.FontType,'') AS FontType,IFNULL(StatStyTbl.StatusTypeId,'') AS StatusTypeId,IFNULL(StatStyTbl.IsActive,'') AS StatusIsActive,IFNULL(MsgLst.Originator,'') AS MsgOriginator,IFNULL(MsgLst.OriginatorDisplayName,'') AS MsgOriginatorDisplayName,IFNULL(MsgLst.MsgCode,frmTbl.MsgCode) AS MsgCode,IFNULL(MsgLst.MsgCreatedDate,'') AS MsgCreatedDate,IFNULL(MsgLst.ParentMsgId,frmTbl.ParentMessageId) AS ParentMsgId,IFNULL(MsgLst.MsgOriginatorId,frmTbl.MsgOriginatorId) AS MsgOriginatorId,IFNULL(MsgLst.MsgHasAssocAttach,'') AS MsgHasAssocAttach,IFNULL(MsgLst.UserRefCode,frmTbl.UserRefCode) AS UserRefCode,IFNULL(MsgLst.UpdatedDateInMS,'') AS MsgUpdatedDateInMS,IFNULL(MsgLst.MsgCreatedDateInMS,'') AS MsgCreatedDateInMS,IFNULL(MsgLst.MsgTypeId,frmTbl.MsgTypeId) AS MsgTypeId,IFNULL(MsgLst.MsgTypeCode,frmTbl.MsgTypeCode) AS MsgTypeCode,IFNULL(MsgLst.MsgStatusId,frmTbl.MsgStatusId) AS MsgStatusId,IFNULL(MsgLst.FolderId,frmTbl.FolderId) AS FolderId,IFNULL(MsgLst.LatestDraftId,'') AS MsgLatestDraftId,IFNULL(MsgLst.IsDraft,'') AS MsgIsDraft,IFNULL(MsgLst.AssocRevIds,'') AS AssocRevIds,IFNULL(MsgLst.ResponseRequestBy,'') AS ResponseRequestBy,IFNULL(MsgLst.DelFormIds,'') AS DelFormIds,IFNULL(MsgLst.AssocFormIds,'') AS AssocFormIds,IFNULL(MsgLst.AssocCommIds,'') AS AssocCommIds,IFNULL(MsgLst.FormUserSet,'') AS FormUserSet,IFNULL(MsgLst.FormPermissionsMap,'') AS FormPermissionsMap,IFNULL(MsgLst.CanOrigChangeStatus,frmTbl.CanOrigChangeStatus) AS CanOrigChangeStatus,IFNULL(MsgLst.CanControllerChangeStatus,'') AS CanControllerChangeStatus,IFNULL(MsgLst.IsStatusChangeRestricted,frmTbl.IsStatusChangeRestricted) AS IsStatusChangeRestricted,IFNULL(MsgLst.HasOverallStatus,'') AS HasOverallStatus,IFNULL(MsgLst.IsCloseOut,frmTbl.IsCloseOut) AS IsCloseOut,IFNULL(MsgLst.AllowReopenForm,frmTbl.AllowReopenForm) AS AllowReopenForm,IFNULL(MsgLst.OfflineRequestData,'') AS OfflineRequestData,IFNULL(MsgLst.IsOfflineCreated,'') AS MsgIsOfflineCreated,IFNULL(MsgLst.MsgNum,frmTbl.MsgNum) AS MsgNum,IFNULL(MsgLst.MsgContent,'') AS MsgContent,IFNULL(MsgLst.ActionComplete,'') AS ActionComplete,IFNULL(MsgLst.ActionCleared,'') AS ActionCleared,IFNULL(MsgLst.HasAttach,'') AS HasAttach,IFNULL(MsgLst.TotalActions,'') AS TotalActions,IFNULL(MsgLst.AttachFiles,'') AS AttachFiles,IFNULL(MsgLst.HasViewAccess,'') AS HasViewAccess,IFNULL(MsgLst.MsgOriginImage,'') AS MsgOriginImage,IFNULL(MsgLst.IsForInfoIncomplete,'') AS IsForInfoIncomplete,IFNULL(MsgLst.MsgCreatedDateOffline,'') AS MsgCreatedDateOffline,IFNULL(MsgLst.LastModifiedTime,'') AS LastModifiedTime,IFNULL(MsgLst.LastModifiedTimeInMS,'') AS LastModifiedTimeInMS,IFNULL(MsgLst.CanViewDraftMsg,'') AS CanViewDraftMsg,IFNULL(MsgLst.CanViewOwnorgPrivateForms,'') AS CanViewOwnorgPrivateForms,IFNULL(MsgLst.IsAutoSavedDraft,'') AS IsAutoSavedDraft,IFNULL(MsgLst.MsgStatusName,'') AS MsgStatusName,IFNULL(MsgLst.ProjectAPDFolderId,'') AS ProjectAPDFolderId,IFNULL(MsgLst.ProjectStatusId,'') AS ProjectStatusId,IFNULL(MsgLst.HasFormAccess,'') AS HasFormAccess,IFNULL(MsgLst.CanAccessHistory,frmTbl.CanAccessHistory) AS CanAccessHistory,IFNULL(MsgLst.HasDocAssocations,'') AS MsgHasDocAssocations,IFNULL(MsgLst.HasBimViewAssociations,'') AS MsgHasBimViewAssociations,IFNULL(MsgLst.HasBimListAssociations,'') AS HasBimListAssociations,IFNULL(MsgLst.HasFormAssocations,'') AS MsgHasFormAssocations,IFNULL(MsgLst.HasCommentAssocations,'') AS MsgHasCommentAssocations FROM FormListTbl frmTbl
INNER JOIN ProjectDetailTbl prjTbl ON prjTbl.ProjectId=frmTbl.ProjectId AND prjTbl.StatusId<>7
LEFT JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=frmTbl.ProjectId AND frmTpTbl.FormTypeId=frmTbl.FormTypeId
LEFT JOIN FormMessageListTbl MsgLst ON MsgLst.ProjectId=frmTbl.ProjectId AND MsgLst.FormId=frmTbl.FormId AND MsgLst.MsgId=frmTbl.MessageId
LEFT JOIN StatusStyleListTbl StatStyTbl ON StatStyTbl.ProjectId=frmTbl.ProjectId AND StatStyTbl.StatusId=frmTbl.StatusId
LEFT JOIN ManageTypeListTbl ManTpTbl ON ManTpTbl.ProjectId=frmTbl.ProjectId AND ManTpTbl.ManageTypeId=frmTbl.ObservationDefectTypeId
)
SELECT * FROM CTE_ObservationView obsrvTbl
WHERE (obsrvTbl.AppTypeId='2' OR obsrvTbl.AllowLocationAssociation=1) AND obsrvTbl.ProjectId=2089700 AND obsrvTbl.LocationId IN (185266)
AND obsrvTbl.FormId IN (
SELECT DISTINCT frmTbl.FormId FROM FormListTbl frmTbl
WHERE (frmTbl.IsActive=1)
)
ORDER BY obsrvTbl.FormCreationDateInMS DESC
LIMIT 0, 25""";

      Map<String, dynamic> observationListJson = jsonDecode(
          """{"dcId":1,"ProjectId":2089700,"FormId":"11640609","FormTypeId":10991549,"ResponseRequestByInMS":1691834399000,"FormTitle":"Test b1","Code":"DEF1740","CommentId":11640609,"MessageId":12353042,"OrgId":5763307,"FirstName":"hardik111","LastName":"Asite","OrgName":"Asite Solutions Ltd","Originator":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1684818268000#hardik111","OriginatorDisplayName":"hardik111 Asite, Asite Solutions Ltd","NoOfActions":0,"TaskTypeName":"","ObservationId":113296,"LocationId":185266,"PfLocFolderId":115418607,"Updated":"09-Aug-2023#00:44 HST","AttachmentImageName":"","TypeImage":"icons/form.png","DocType":"Apps","HasAttachments":0,"HasDocAssocations":0,"HasBimViewAssociations":0,"HasFormAssocations":0,"HasCommentAssocations":0,"FormHasAssocAttach":0,"FormCreationDate":"09-Aug-2023#00:44 HST","FormNumber":1740,"IsDraft":0,"StatusId":1001,"OriginatorId":1906453,"Id":"","StatusChangeUserId":0,"StatusUpdateDate":"09-Aug-2023#00:44 HST","StatusChangeUserName":"hardik111 Asite","StatusChangeUserPic":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1684818268000#hardik111","StatusChangeUserEmail":"hardik111@asite.com","StatusChangeUserOrg":"Asite Solutions Ltd","OriginatorEmail":"hardik111@asite.com","ControllerUserId":0,"UpdatedDateInMS":1691577850000,"FormCreationDateInMS":1691577850000,"FlagType":0,"LatestDraftId":0,"FlagTypeImageName":"flag_type/flag_0.png","MessageTypeImageName":"icons/form.png","FormJsonData":"","AttachedDocs":"","IsUploadAttachmentInTemp":0,"IsSync":0,"HasActions":0,"CanRemoveOffline":0,"IsMarkOffline":0,"IsOfflineCreated":0,"SyncStatus":1,"IsForDefect":0,"IsForApps":0,"ObservationDefectTypeId":"44463","StartDate":"2023-08-09","ExpectedFinishDate":"2023-08-11","IsActive":1,"ObservationCoordinates":"","AnnotationId":"5a4deb8f-1ce0-4370-a4df-b5510c706f6d-1691577850393","AssignedToUserId":1959897,"AssignedToUserName":"Hardik121 Asite","AssignedToUserOrgName":"My Asite Organisation","AssignedToRoleName":"","RevisionId":"","PageNumber":"1","RequestJsonForOffline":"","FormDueDays":"2","FormSyncDate":"2023-08-09 11:44:10.393","LastResponderForAssignedTo":"1959897","LastResponderForOriginator":"1906453","ObservationDefectType":"","StatusName":"Open","AllowLocationAssociation":1,"AppTypeId":"2","InstanceGroupId":10121200,"TemplateTypeId":1,"AppBuilderId":"SNG-DEF","FormTypeName":"Defect form","FormTypeGroupName":"Defects","FormTypeGroupCode":"DEF","ManageTypeId":44463,"ManageTypeName":"Architectural","Status":"Open","FontColor":"#000000","BackgroundColor":"#e81c1c","FontEffect":"0#0#0#0","FontType":"PT Sans","StatusTypeId":1,"StatusIsActive":1,"MsgOriginator":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1684818268000#hardik111","MsgOriginatorDisplayName":"hardik111 Asite, Asite Solutions Ltd","MsgCode":"ORI001","MsgCreatedDate":"09-Aug-2023#00:44 HST","ParentMsgId":"0","MsgOriginatorId":"1906453","MsgHasAssocAttach":0,"UserRefCode":"N/A","MsgUpdatedDateInMS":"1691577850000","MsgCreatedDateInMS":"1691577850000","MsgTypeId":"1","MsgTypeCode":"ORI","MsgStatusId":"20","FolderId":"0","MsgLatestDraftId":"0","MsgIsDraft":0,"AssocRevIds":"","ResponseRequestBy":"11-Aug-2023#23:59 HST","DelFormIds":"","AssocFormIds":"","AssocCommIds":"","FormUserSet":"","FormPermissionsMap":"","CanOrigChangeStatus":1,"CanControllerChangeStatus":0,"IsStatusChangeRestricted":1,"HasOverallStatus":1,"IsCloseOut":0,"AllowReopenForm":1,"OfflineRequestData":"","MsgIsOfflineCreated":0,"MsgNum":"","MsgContent":"","ActionComplete":0,"ActionCleared":0,"HasAttach":0,"TotalActions":"","AttachFiles":"","HasViewAccess":0,"MsgOriginImage":"","IsForInfoIncomplete":0,"MsgCreatedDateOffline":"","LastModifiedTime":"","LastModifiedTimeInMS":"","CanViewDraftMsg":0,"CanViewOwnorgPrivateForms":0,"IsAutoSavedDraft":0,"MsgStatusName":"Sent","ProjectAPDFolderId":"15697133","ProjectStatusId":"5","HasFormAccess":0,"CanAccessHistory":0,"MsgHasDocAssocations":0,"MsgHasBimViewAssociations":0,"HasBimListAssociations":0,"MsgHasFormAssocations":0,"MsgHasCommentAssocations":0}""");

      ResultSet resultSetObservationListQuery = ResultSet(observationListJson.keys.toList(), null, [observationListJson.values.toList()]);

      String observationActionSelectQuery = """SELECT * FROM FormMsgActionListTbl
WHERE ProjectId=2089700 AND FormId=11640609
AND MsgId=12353042 AND RecipientUserId=808581
ORDER BY ActionDueDateMilliSecond ASC""";

      Map<String, dynamic> observationActionJson = jsonDecode("""{"ProjectId":"2089700","FormTypeId":"11129195","FormId":"11639029","MsgId":"12350719","AttachmentType":"3","AttachAssocDetailJson":"","OfflineUploadFilePath":"","AttachDocId":"13693277","AttachRevId":"27247951","AttachFileName":"IMG_0140.jpeg","AssocProjectId":"","AssocDocFolderId":"","AssocDocRevisionId":"","AssocFormCommId":"","AssocCommentMsgId":"","AssocCommentId":"","AssocCommentRevisionId":"","AssocViewModelId":"","AssocViewId":"","AssocListModelId":"","AssocListId":"","AttachSize":"2767"}""");

      ResultSet resultSetObservationAction = ResultSet(observationActionJson.keys.toList(), null, [observationActionJson.values.toList()]);

      when(() => mockDb.selectFromTable(FormDao.tableName, totalFormCountQuery)).thenReturn(resultSetTotalFormCountQuery);
      when(() => mockDb.selectFromTable(FormDao.tableName, observationListQuery)).thenReturn(resultSetObservationListQuery);
      when(() => mockDb.selectFromTable(FormDao.tableName, observationActionSelectQuery)).thenReturn(resultSetObservationAction);

      final result = await siteFormListingLocalDataSource.getOfflineObservationListJson(requestMap);
      expect(result, isA<SUCCESS>());
    });

    test("test getOfflineObservationListJson throw exception expected fail", () async {
      when(() => mockDb.selectFromTable(FormDao.tableName, any())).thenThrow(Exception());

      final result = await siteFormListingLocalDataSource.getOfflineObservationListJson({});
      expect(result, isA<FAIL>());
    });
  });

  group("test getOfflineAttachmentListJson", () {
    test("test getOfflineAttachmentListJson pass valid result expected success", () async {
      String selectQuery = """SELECT * FROM FormMsgAttachAndAssocListTbl WHERE ProjectId = 2089700 AND AttachDocId !='' AND AttachDocId IS NOT NULL""";

      Map<String, dynamic> attachmentJson = jsonDecode("""{"ProjectId":"2089700","FormTypeId":"11129195","FormId":"11639029","MsgId":"12350719","AttachmentType":"3","AttachAssocDetailJson":"","OfflineUploadFilePath":"","AttachDocId":"13693277","AttachRevId":"27247951","AttachFileName":"IMG_0140.jpeg","AssocProjectId":"","AssocDocFolderId":"","AssocDocRevisionId":"","AssocFormCommId":"","AssocCommentMsgId":"","AssocCommentId":"","AssocCommentRevisionId":"","AssocViewModelId":"","AssocViewId":"","AssocListModelId":"","AssocListId":"","AttachSize":"2767"}""");

      ResultSet resultSetAttachment = ResultSet(attachmentJson.keys.toList(), null, [attachmentJson.values.toList()]);

      when(() => mockDb.selectFromTable(FormMessageAttachAndAssocDao.tableName, selectQuery)).thenReturn(resultSetAttachment);

      final result = await siteFormListingLocalDataSource.getOfflineAttachmentListJson({"projectId": "2089700", "formIds": "11639029"});
      expect(result, isA<SUCCESS>());
    });

    test("test getOfflineAttachmentListJson throw exception expected fail", () async {
      when(() => mockDb.selectFromTable(FormMessageAttachAndAssocDao.tableName, any())).thenThrow(Exception());

      final result = await siteFormListingLocalDataSource.getOfflineAttachmentListJson({"projectId": "2089700", "formIds": "11639029"});
      expect(result, isA<FAIL>());
    });
  });

  group("test getUpdatedObservationListItemData", () {
    test("test getUpdatedObservationListItemData pass valid result expected success", () async {
      String selectQuery =
          """WITH ObservationView AS (SELECT prjTbl.DcId AS dcId,frmTbl.ProjectId, frmTbl.FormId, frmTbl.FormTypeId, frmTbl.FormTitle, frmTbl.Code, frmTbl.CommentId,frmTbl.MessageId, frmTbl.OrgId, frmTbl.FirstName, frmTbl.LastName, frmTbl.OrgName, frmTbl.Originator, frmTbl.OriginatorDisplayName,frmTbl.NoOfActions, frmTbl.ObservationId, frmTbl.LocationId, frmTbl.PfLocFolderId, frmTbl.Updated, frmTbl.AttachmentImageName,frmTbl.TypeImage, frmTbl.DocType, frmTbl.HasAttachments, frmTbl.HasDocAssocations, frmTbl.HasBimViewAssociations, frmTbl.HasFormAssocations,frmTbl.HasCommentAssocations, frmTbl.FormHasAssocAttach, frmTbl.FormCreationDate, frmTbl.FormNumber, frmTbl.IsDraft, frmTbl.StatusId,frmTbl.OriginatorId, frmTbl.Id, frmTbl.StatusChangeUserId, frmTbl.StatusUpdateDate, frmTbl.StatusChangeUserName, frmTbl.StatusChangeUserPic,frmTbl.StatusChangeUserEmail, frmTbl.StatusChangeUserOrg, frmTbl.OriginatorEmail, frmTbl.ControllerUserId, frmTbl.UpdatedDateInMS,frmTbl.FormCreationDateInMS, frmTbl.FlagType, frmTbl.LatestDraftId, frmTbl.FlagTypeImageName, frmTbl.MessageTypeImageName, frmTbl.FormJsonData,frmTbl.AttachedDocs, frmTbl.IsUploadAttachmentInTemp, frmTbl.IsSync, frmTbl.HasActions, frmTbl.CanRemoveOffline, frmTbl.IsMarkOffline,frmTbl.IsOfflineCreated, frmTbl.SyncStatus, frmTbl.IsForDefect, frmTbl.IsForApps, frmTbl.ObservationDefectTypeId, frmTbl.StartDate,frmTbl.ExpectedFinishDate, frmTbl.IsActive, frmTbl.ObservationCoordinates, frmTbl.AnnotationId, frmTbl.AssignedToUserId, frmTbl.AssignedToUserName,frmTbl.AssignedToUserOrgName,frmTbl.AssignedToRoleName, frmTbl.RevisionId, frmTbl.RequestJsonForOffline, frmTbl.FormDueDays, frmTbl.FormSyncDate,frmTbl.LastResponderForAssignedTo, frmTbl.LastResponderForOriginator, frmTbl.PageNumber, frmTbl.ObservationDefectType,frmTbl.TaskTypeName,CASE frmTbl.StatusName WHEN '' THEN frmTbl.Status ELSE frmTbl.StatusName END AS StatusName,IFNULL(frmTpTbl.AppTypeId,frmTbl.AppTypeId) AS AppTypeId, IFNULL(frmTpTbl.InstanceGroupId,frmTbl.InstanceGroupId) AS InstanceGroupId,IFNULL(frmTpTbl.TemplateTypeId,frmTbl.TemplateType) AS TemplateTypeId, IFNULL(frmTpTbl.AppBuilderId,frmTbl.AppBuilderId) AS AppBuilderId,IFNULL(frmTpTbl.FormTypeGroupName,'') AS FormTypeGroupName, IFNULL(frmTpTbl.FormTypeGroupCode,'') AS FormTypeGroupCode,IFNULL(frmTpTbl.FormTypeName,'') AS FormTypeName,IFNULL(ManTpTbl.ManageTypeId,frmTbl.ObservationDefectTypeId) AS ManageTypeId,IFNULL(ManTpTbl.ManageTypeName,frmTbl.ObservationDefectType) AS ManageTypeName, IFNULL(StatStyTbl.StatusName,frmTbl.Status) AS Status,IFNULL(StatStyTbl.FontColor,'') AS FontColor,IFNULL(StatStyTbl.BackgroundColor,'') AS BackgroundColor,IFNULL(StatStyTbl.FontEffect,'') AS FontEffect,IFNULL(StatStyTbl.FontType,'') AS FontType,IFNULL(StatStyTbl.StatusTypeId,'') AS StatusTypeId,IFNULL(StatStyTbl.IsActive,'') AS StatusIsActive, IFNULL(MsgLst.Originator,'') AS MsgOriginator,IFNULL(MsgLst.OriginatorDisplayName,'') AS MsgOriginatorDisplayName,IFNULL(MsgLst.MsgCode,frmTbl.MsgCode) AS MsgCode,IFNULL(MsgLst.MsgCreatedDate,'') AS MsgCreatedDate,IFNULL(MsgLst.ParentMsgId,frmTbl.ParentMessageId) AS ParentMsgId,IFNULL(MsgLst.MsgOriginatorId,frmTbl.MsgOriginatorId) AS MsgOriginatorId,IFNULL(MsgLst.MsgHasAssocAttach,'') AS MsgHasAssocAttach,IFNULL(MsgLst.UserRefCode,frmTbl.UserRefCode) AS UserRefCode,IFNULL(MsgLst.UpdatedDateInMS,'') AS MsgUpdatedDateInMS,IFNULL(MsgLst.MsgCreatedDateInMS,'') AS MsgCreatedDateInMS,IFNULL(MsgLst.MsgTypeId,frmTbl.MsgTypeId) AS MsgTypeId,IFNULL(MsgLst.MsgTypeCode,frmTbl.MsgTypeCode) AS MsgTypeCode,IFNULL(MsgLst.MsgStatusId,frmTbl.MsgStatusId) AS MsgStatusId,IFNULL(MsgLst.FolderId,frmTbl.FolderId) AS FolderId,IFNULL(MsgLst.LatestDraftId,'') AS MsgLatestDraftId,IFNULL(MsgLst.IsDraft,'') AS MsgIsDraft,IFNULL(MsgLst.AssocRevIds,'') AS AssocRevIds,IFNULL(MsgLst.ResponseRequestBy,'') AS ResponseRequestBy,IFNULL(MsgLst.DelFormIds,'') AS DelFormIds,IFNULL(MsgLst.AssocFormIds,'') AS AssocFormIds,IFNULL(MsgLst.AssocCommIds,'') AS AssocCommIds,IFNULL(MsgLst.FormUserSet,'') AS FormUserSet,IFNULL(MsgLst.FormPermissionsMap,'') AS FormPermissionsMap,IFNULL(MsgLst.CanOrigChangeStatus,frmTbl.CanOrigChangeStatus) AS CanOrigChangeStatus,IFNULL(MsgLst.CanControllerChangeStatus,'') AS CanControllerChangeStatus,IFNULL(MsgLst.IsStatusChangeRestricted,frmTbl.IsStatusChangeRestricted) AS IsStatusChangeRestricted,IFNULL(MsgLst.HasOverallStatus,'') AS HasOverallStatus,IFNULL(MsgLst.IsCloseOut,frmTbl.IsCloseOut) AS IsCloseOut,IFNULL(MsgLst.AllowReopenForm,frmTbl.AllowReopenForm) AS AllowReopenForm,IFNULL(MsgLst.OfflineRequestData,'') AS OfflineRequestData,IFNULL(MsgLst.IsOfflineCreated,'') AS MsgIsOfflineCreated,IFNULL(MsgLst.MsgNum,frmTbl.MsgNum) AS MsgNum,IFNULL(MsgLst.MsgContent,'') AS MsgContent,IFNULL(MsgLst.ActionComplete,'') AS ActionComplete,IFNULL(MsgLst.ActionCleared,'') AS ActionCleared,IFNULL(MsgLst.HasAttach,'') AS HasAttach,IFNULL(MsgLst.TotalActions,'') AS TotalActions,IFNULL(MsgLst.AttachFiles,'') AS AttachFiles,IFNULL(MsgLst.HasViewAccess,'') AS HasViewAccess,IFNULL(MsgLst.MsgOriginImage,'') AS MsgOriginImage,IFNULL(MsgLst.IsForInfoIncomplete,'') AS IsForInfoIncomplete,IFNULL(MsgLst.MsgCreatedDateOffline,'') AS MsgCreatedDateOffline,IFNULL(MsgLst.LastModifiedTime,'') AS LastModifiedTime,IFNULL(MsgLst.LastModifiedTimeInMS,'') AS LastModifiedTimeInMS,IFNULL(MsgLst.CanViewDraftMsg,'') AS CanViewDraftMsg,IFNULL(MsgLst.CanViewOwnorgPrivateForms,'') AS CanViewOwnorgPrivateForms,IFNULL(MsgLst.IsAutoSavedDraft,'') AS IsAutoSavedDraft,IFNULL(MsgLst.MsgStatusName,'') AS MsgStatusName,IFNULL(MsgLst.ProjectAPDFolderId,'') AS ProjectAPDFolderId,IFNULL(MsgLst.ProjectStatusId,'') AS ProjectStatusId,IFNULL(MsgLst.HasFormAccess,'') AS HasFormAccess,IFNULL(MsgLst.CanAccessHistory,frmTbl.CanAccessHistory) AS CanAccessHistory,IFNULL(MsgLst.HasDocAssocations,'') AS MsgHasDocAssocations,IFNULL(MsgLst.HasBimViewAssociations,'') AS MsgHasBimViewAssociations,IFNULL(MsgLst.HasBimListAssociations,'') AS HasBimListAssociations,IFNULL(MsgLst.HasFormAssocations,'') AS MsgHasFormAssocations,IFNULL(MsgLst.HasCommentAssocations,'') AS MsgHasCommentAssocations FROM FormListTbl frmTbl 
INNER JOIN ProjectDetailTbl prjTbl ON prjTbl.ProjectId=frmTbl.ProjectId AND prjTbl.StatusId<>7 
LEFT JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=frmTbl.ProjectId AND frmTpTbl.FormTypeId=frmTbl.FormTypeId 
LEFT JOIN FormMessageListTbl MsgLst ON MsgLst.ProjectId=frmTbl.ProjectId AND MsgLst.FormTypeId=frmTbl.FormTypeId AND MsgLst.ObservationId=frmTbl.ObservationId AND MsgLst.MsgId=frmTbl.MessageId
LEFT JOIN StatusStyleListTbl StatStyTbl ON StatStyTbl.ProjectId=frmTbl.ProjectId AND StatStyTbl.StatusId=frmTbl.StatusId 
LEFT JOIN ManageTypeListTbl ManTpTbl ON ManTpTbl.ProjectId=frmTbl.ProjectId AND ManTpTbl.ManageTypeId=frmTbl.ObservationDefectTypeId 
) SELECT * FROM ObservationView obsrvTbl  WHERE obsrvTbl.ProjectId=2089700 AND obsrvTbl.FormId=11640552""";

      Map<String, dynamic> observationListItemJson = jsonDecode(
          """{"dcId":1,"ProjectId":2089700,"FormId":"11640552","FormTypeId":11131108,"FormTitle":"hello test","Code":"HBHT487","CommentId":11640552,"MessageId":12352922,"OrgId":5763307,"FirstName":"hardik111","LastName":"Asite","OrgName":"Asite Solutions Ltd","Originator":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1684818268000#hardik111","OriginatorDisplayName":"hardik111 Asite, Asite Solutions Ltd","NoOfActions":0,"ObservationId":113278,"LocationId":185266,"PfLocFolderId":115418607,"Updated":"09-Aug-2023#00:24 HST","AttachmentImageName":"","TypeImage":"icons/form.png","DocType":"Apps","HasAttachments":0,"HasDocAssocations":0,"HasBimViewAssociations":0,"HasFormAssocations":0,"HasCommentAssocations":0,"FormHasAssocAttach":0,"FormCreationDate":"09-Aug-2023#00:24 HST","FormNumber":487,"IsDraft":0,"StatusId":100,"OriginatorId":1906453,"Id":"","StatusChangeUserId":0,"StatusUpdateDate":"09-Aug-2023#00:24 HST","StatusChangeUserName":"hardik111 Asite","StatusChangeUserPic":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1684818268000#hardik111","StatusChangeUserEmail":"hardik111@asite.com","StatusChangeUserOrg":"Asite Solutions Ltd","OriginatorEmail":"hardik111@asite.com","ControllerUserId":0,"UpdatedDateInMS":1691576646000,"FormCreationDateInMS":1691576646000,"FlagType":0,"LatestDraftId":0,"FlagTypeImageName":"flag_type/flag_0.png","MessageTypeImageName":"icons/form.png","FormJsonData":"","AttachedDocs":"","IsUploadAttachmentInTemp":0,"IsSync":0,"HasActions":0,"CanRemoveOffline":0,"IsMarkOffline":0,"IsOfflineCreated":0,"SyncStatus":0,"IsForDefect":0,"IsForApps":0,"ObservationDefectTypeId":"0","StartDate":"","ExpectedFinishDate":"","IsActive":1,"ObservationCoordinates":"","AnnotationId":"2603254f-c59c-4e0e-a9e1-a750e71c7c57-1691576438904","AssignedToUserId":0,"AssignedToUserName":"","AssignedToUserOrgName":"","AssignedToRoleName":"","RevisionId":"","RequestJsonForOffline":"","FormDueDays":"0","FormSyncDate":"2023-08-09 11:24:06.397","LastResponderForAssignedTo":"","LastResponderForOriginator":"","PageNumber":"1","ObservationDefectType":"","TaskTypeName":"","StatusName":"Open","AppTypeId":"2","InstanceGroupId":10796407,"TemplateTypeId":2,"AppBuilderId":"HB-HTML","FormTypeGroupName":"Hardik HTML","FormTypeGroupCode":"HBHT","FormTypeName":"HB HTML 123","ManageTypeId":"0","ManageTypeName":"","Status":"Open","FontColor":"#ffffff","BackgroundColor":"#848484","FontEffect":"0#0#0#0","FontType":"PT Sans","StatusTypeId":1,"StatusIsActive":1,"MsgOriginator":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1906453_thumbnail.jpg?v=1684818268000#hardik111","MsgOriginatorDisplayName":"hardik111 Asite, Asite Solutions Ltd","MsgCode":"ORI001","MsgCreatedDate":"09-Aug-2023#00:24 HST","ParentMsgId":"0","MsgOriginatorId":"1906453","MsgHasAssocAttach":0,"UserRefCode":"N/A","MsgUpdatedDateInMS":"1691576646000","MsgCreatedDateInMS":"1691576646000","MsgTypeId":"1","MsgTypeCode":"ORI","MsgStatusId":"20","FolderId":"0","MsgLatestDraftId":"0","MsgIsDraft":0,"AssocRevIds":"","ResponseRequestBy":"24-Aug-2023#23:59 HST","DelFormIds":"","AssocFormIds":"","AssocCommIds":"","FormUserSet":"","FormPermissionsMap":"","CanOrigChangeStatus":1,"CanControllerChangeStatus":0,"IsStatusChangeRestricted":0,"HasOverallStatus":1,"IsCloseOut":0,"AllowReopenForm":1,"OfflineRequestData":"","MsgIsOfflineCreated":0,"MsgNum":"","MsgContent":"","ActionComplete":0,"ActionCleared":0,"HasAttach":0,"TotalActions":"","AttachFiles":"","HasViewAccess":0,"MsgOriginImage":"","IsForInfoIncomplete":0,"MsgCreatedDateOffline":"","LastModifiedTime":"","LastModifiedTimeInMS":"","CanViewDraftMsg":0,"CanViewOwnorgPrivateForms":0,"IsAutoSavedDraft":0,"MsgStatusName":"Sent","ProjectAPDFolderId":"15697133","ProjectStatusId":"5","HasFormAccess":0,"CanAccessHistory":0,"MsgHasDocAssocations":0,"MsgHasBimViewAssociations":0,"HasBimListAssociations":0,"MsgHasFormAssocations":0,"MsgHasCommentAssocations":0}""");

      ResultSet resultSetObservationListItem = ResultSet(observationListItemJson.keys.toList(), null, [observationListItemJson.values.toList()]);

      when(() => mockDb.selectFromTable(FormDao.tableName, selectQuery)).thenReturn(resultSetObservationListItem);

      final result = await siteFormListingLocalDataSource.getUpdatedObservationListItemData({"projectId": "2089700", "formId": "11640552"});
      expect(result, isA<SUCCESS>());
    });

    test("test getUpdatedObservationListItemData throw exception expected fail", () async {
      when(() => mockDb.selectFromTable(FormDao.tableName, any())).thenThrow(Exception());

      final result = await siteFormListingLocalDataSource.getUpdatedObservationListItemData({"projectId": "2089700", "formId": "11640552"});
      expect(result, isA<FAIL>());
    });
  });

  group("test fetchAppTypeList", () {
    test("test fetchAppTypeList pass valid result expected empty list", () async {
      String selectQuery = """WITH RecentFormTypeData AS (
SELECT InstanceGroupId, MAX(FormCreationDateInMS) AS FormCreationDateInMS FROM FormListTbl
WHERE ProjectId=2089700 AND FormCreationDateInMS>=1689169066228
GROUP BY InstanceGroupId
ORDER BY FormCreationDateInMS DESC
LIMIT 5
)
SELECT frmGrpTpTbl.*, prjTbl.dcId, prjTbl.ProjectName,IFNULL(recentData.FormCreationDateInMS,0) AS FormCreationDateInMS FROM FormGroupAndFormTypeListTbl frmGrpTpTbl
INNER JOIN ProjectDetailTbl prjTbl ON frmGrpTpTbl.ProjectId = prjTbl.ProjectId
LEFT JOIN RecentFormTypeData recentData ON recentData.InstanceGroupId=frmGrpTpTbl.InstanceGroupId
WHERE frmGrpTpTbl.ProjectId=2089700 AND frmGrpTpTbl.CanCreateForms=1 AND
frmGrpTpTbl.FormTypeId IN (
SELECT MAX(FormTypeId) FROM FormGroupAndFormTypeListTbl
WHERE ProjectId=2089700 AND AllowLocationAssociation=1
GROUP BY InstanceGroupId
)
ORDER BY FormCreationDateInMS DESC, formTypeName COLLATE NOCASE ASC
""";

      ResultSet resultSet = ResultSet([], null, [[]]);

      when(() => mockDb.selectFromTable(FormTypeDao.tableName, selectQuery)).thenReturn(resultSet);

      final result = await siteFormListingLocalDataSource.fetchAppTypeList("2089700");
      expect(result.length, 0);
    });

    test("test fetchAppTypeList throw exception expected empty list", () async {
      when(() => mockDb.selectFromTable(FormTypeDao.tableName, any())).thenThrow(Exception());

      final result = await siteFormListingLocalDataSource.fetchAppTypeList("2089700");
      expect(result.length, 0);
    });
  });
}
