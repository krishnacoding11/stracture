
import 'dart:async';
import 'dart:convert';

import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/offline_injection_container.dart' as offline_di;
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/form_message_batch_list_sync_task.dart';
import 'package:field/utils/field_enums.dart';
import 'package:field/utils/file_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/common.dart';

import '../bloc/mock_method_channel.dart';
import '../fixtures/appconfig_test_data.dart';
import '../fixtures/fixture_reader.dart';

class MockProjectListUseCase extends Mock implements ProjectListUseCase {}

class DBServiceMock extends Mock implements DBService {}

class FileUtilityMock extends Mock implements FileUtility {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  offline_di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  MockProjectListUseCase? mockProjectListUseCase;
  DBServiceMock? mockDb;
  FileUtilityMock mockFileUtility = FileUtilityMock();
  TaskPool? taskPool = offline_di.getIt<TaskPool>();

  configureDependencies() async {
    mockProjectListUseCase = MockProjectListUseCase();
    mockDb = DBServiceMock();
    offline_di.getIt.unregister<ProjectListUseCase>();
    offline_di.getIt.unregister<DBService>();
    offline_di.getIt.unregister<FileUtility>();
    offline_di.getIt.registerLazySingleton<ProjectListUseCase>(() => mockProjectListUseCase!);
    offline_di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
    offline_di.getIt.registerLazySingleton<FileUtility>(() => mockFileUtility);
  }

  setUp(() {
    configureDependencies();
  });

  tearDown(() {

    mockProjectListUseCase = null;
  });

  group("FormMessageBatchListSyncTask Test", () {
    test("FormMessageBatchListSyncTask Success", () async {
      Map<String, dynamic> projectjson;
      projectjson = {
        "iProjectId": 0,
        "dcId": 1,
        "projectName": "Site Quality Demo",
        "privilege": ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,1",
        "projectID": "2130192\$\$cJT4po",
        "parentId": -1,
        "isWorkspace": 1,
        "projectBaseUrl": "",
        "projectBaseUrlForCollab": "",
        "isUserAdminforProj": true,
        "bimEnabled": false,
        "isFavorite": true,
        "canManageWorkspaceRoles": true,
        "canManageWorkspaceFormStatus": true,
        "isFromExchange": false,
        "spaceTypeId": "1\$\$HHkGSl",
        "isTemplate": false,
        "isCloned": false,
        "activeFilesCount": 0,
        "formsCount": 0,
        "statusId": 5,
        "users": 0,
        "fetchRuleId": 0,
        "canManageWorkspaceDocStatus": true,
        "canCreateAutoFetchRule": true,
        "ownerOrgId": 3,
        "canManagePurposeOfIssue": true,
        "canManageMailBox": true,
        "editWorkspaceFormSettings": true,
        "canAssignApps": true,
        "canManageDistributionGroup": true,
        "defaultpermissiontypeid": 0,
        "checkoutPref": false,
        "restrictDownloadOnCheckout": false,
        "canManageAppSetting": true,
        "projectsubscriptiontypeid": 0,
        "canManageCustomAttribute": true,
        "isAdminAccess": false,
        "isUseAccess": false,
        "canManageWorkflowRules": true,
        "canAccessAuditInformation": true,
        "countryId": 0,
        "projectSpaceTypeId": 0,
        "isWatching": false,
        "canManageRolePrivileges": true,
        "canManageFormPermissions": true,
        "canManageProjectInvitations": true,
        "enableCommentReview": false,
        "projectViewerId": 7,
        "isShared": false,
        "insertInStorageSpace": false,
        "colorid": 0,
        "iconid": 0,
        "businessid": 0,
        "childfolderTreeVOList": null,
        "generateURI": true,
        "postalCode": "W1J 5JA",
        "canRemoveOffline": true,
        "isMarkOffline": true,
        "syncStatus": "ESyncStatus.failed",
        "lastSyncTimeStamp": null,
        "newSyncTimeStamp": "2023-08-01 11:36:59.19",
        "projectSizeInByte": "253288002",
        "progress": null
      };
      List<Project> projectList = [Project.fromJson(projectjson)];
      //List<SiteFormAction> siteFormAction = [SiteFormAction.fromJson(jsonDecode(fixture("site_form_action.json")))];
      //List<SiteFormAction> siteFormAction = SiteFormAction.siteFormActionFromJson([fixture("site_form_action.json")]);
      // final siteFormAction = SiteFormAction(
      //   actionId: "3",
      //   actionName: "Respond",
      //   actionStatus: "0",
      //   actionDate: "Wed Jul 19 07:12:20 BST 2023",
      //   dueDate: "Wed Sep 06 00:59:59 BST 2023",
      //   recipientId: "2017529",
      //   remarks: "",
      //   actionTime: "29 Days",
      //   actionCompleteDate: "",
      //   isActive: true,
      //   assignedBy: "Vijay Mavadiya (5336),Asite Solutions",
      //   recipientName: "Mayur Raval m., Asite Solutions Ltd",
      //   dueDateInMS: "1693958399000",
      //   actionCompleteDateInMS: "0",
      //   actionDelegated: null,
      //   actionCleared: null,
      //   actionCompleted: null,
      // );

      Map<String, dynamic> formListjson = {
      "projectId" : "2130192\$\$cJT4po",
      "projectName" : null,
      "code" : "DISC083",
      "commId" : "11579710\$\$POOe0Y",
      "formId" : "11579710\$\$dE2L2Z",
      "title" : "Take Action 001",
      "userID" : null,
      "orgId" : "3\$\$NVxv5L",
      "originator" : "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v:1656996305000#Dhaval",
      "originatorDisplayName" : "Dhaval Vekaria (5226), Asite Solutions",
      "noOfActions" : 0,
      "observationId" : 104871,
      "locationId" : 177294,
      "pfLocFolderId" : 114159245,
      "locationName" : null,
      "locationPath" : null,
      "updated" : "23-Jun-2023#02:37 CST",
      "hasAttachments" : false,
      "msgCode" : "ORI001",
      "docType" : "Apps",
      "formTypeName" : "Discussion",
      "statusText" : null,
      "responseRequestBy" : null,
      "hasDocAssocations" : false,
      "hasBimViewAssociations" : false,
      "hasBimListAssociations" : false,
      "hasFormAssocations" : false,
      "hasCommentAssocations" : false,
      "formHasAssocAttach" : false,
      "msgHasAssocAttach" : false,
      "formCreationDate" : "23-Jun-2023#02:37 CST",
      "msgCreatedDate" : null,
      "msgId" : "12274857\$\$ZIS54V",
      "parentMsgId" : "0",
      "msgTypeId" : "1",
      "msgStatusId" : "20",
      "formTypeId" : "11076066\$\$Y9vZRK",
      "templateType" : 2,
      "instanceGroupId" : "11018088\$\$MZiMll",
      "noOfMessages" : null,
      "isDraft" : false,
      "dcId" : null,
      "statusid" : "2",
      "originatorId" : "514806",
      "isCloseOut" : false,
      "isStatusChangeRestricted" : false,
      "allowReopenForm" : false,
      "hasOverallStatus" : null,
      "canOrigChangeStatus" : false,
      "canControllerChangeStatus" : null,
      "appType" : null,
      "msgTypeCode" : "ORI",
      "formGroupName" : null,
      "id" : null,
      "appTypeId" : 2,
      "lastmodified" : "2023-06-23T08:43:05Z",
      "appBuilderId" : "STD-DIS",
      "CFID_TaskType" : null,
      "CFID_DefectTyoe" : null,
      "CFID_Assigned" : null,
      "statusRecordStyle" : null,
      "isSiteFormSelected" : false,
      "statusUpdateDate" : "23-Jun-2023#02:37 CST",
      "actions" : jsonDecode(fixture("site_form_action.json")),
      "attachmentImageName" : "",
      "firstName" : "Dhaval",
      "lastName" : "Vekaria (5226)",
      "folderId" : "0\$\$9jYMd3",
      "formCreationDateInMS" : "1687505868000",
      "responseRequestByInMS" : "1687890599000",
      "updatedDateInMS" : "1687505868000",
      "typeImage" : "icons/form.png",
      "status" : "Open",
      "statusName" : "Open",
      "statusChangeUserId" : 0,
      "statusChangeUserPic" : "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v:1656996305000#Dhaval",
      "statusChangeUserOrg" : "Asite Solutions",
      "statusChangeUserName" : "Dhaval Vekaria (5226)",
      "statusChangeUserEmail" : "dvekaria@asite.com",
      "orgName" : "Asite Solutions",
      "originatorEmail" : "dvekaria@asite.com",
      "msgOriginatorId" : 514806,
      "formNum" : 83,
      "controllerUserId" : "0",
      "userRefCode" : null,
      "flagTypeImageName" : "flag_type/flag_0.png",
      "formTypeCode" : null,
      "latestDraftId" : "0\$\$MuYV2W",
      "canAccessHistory" : true,
      "observationCoordinates" : "{\"x1\":330.57,\"y1\":486.67,\"x2\":378.57,\"y2\":438.67}",
      "annotationId" : "0acbf158-1845-423c-c117-3f760580ebb6",
      "pageNumber" : 1,
      "isActive" : true,
      "formDueDays" : 0,
      "formSyncDate" : "2023-06-23 08:37:48.7",
      "startDate" : null,
      "expectedFinishDate" : null,
      "assignedToUserId" : "0",
      "assignedToUserName" : null,
      "assignedToUserOrgName" : null,
      "assignedToRoleName" : null,
      "lastResponderForAssignedTo" : null,
      "lastResponderForOriginator" : null,
      "manageTypeId" : "0",
      "manageTypeName" : null,
      "hasActions" : false,
      "flagType" : 0,
      "messageTypeImageName" : "icons/form.png",
      "formJsonData" : null,
      "attachedDocs" : null,
      "isUploadAttachmentInTemp" : null,
      "isSync" : null,
      "canRemoveOffline" : null,
      "isMarkOffline" : null,
      "isOfflineCreated" : null,
      "syncStatus" : ESyncStatus.failed,
      "isForDefect" : null,
      "isForApps" : null,
      "observationDefectTypeId" : null,
      "msgNum" : null,
      "revisionId" : null,
      "requestJsonForOffline" : null,
      "observationDefectType" : null,
      "taskTypeName" : null,
      "workPackage" : null,
      "eHtmlRequestType" : null
      };
      List<SiteForm> formList = [SiteForm.fromJson(formListjson)];

      var taskNumber = -9007199254740859;
      var createQuery = "CREATE TABLE IF NOT EXISTS FormMessageListTbl(ProjectId TEXT NOT NULL,FormTypeId TEXT NOT NULL,FormId TEXT NOT NULL,MsgId TEXT NOT NULL,Originator TEXT,OriginatorDisplayName TEXT,MsgCode TEXT,MsgCreatedDate TEXT,ParentMsgId TEXT,MsgOriginatorId TEXT,MsgHasAssocAttach INTEGER NOT NULL DEFAULT 0,JsonData TEXT,UserRefCode TEXT,UpdatedDateInMS TEXT,FormCreationDateInMS TEXT,MsgCreatedDateInMS TEXT,MsgTypeId TEXT,MsgTypeCode TEXT,MsgStatusId TEXT,SentNames TEXT,SentActions TEXT,DraftSentActions TEXT,FixFieldData TEXT,FolderId TEXT,LatestDraftId TEXT,IsDraft INTEGER NOT NULL DEFAULT 0,AssocRevIds TEXT,ResponseRequestBy TEXT,DelFormIds TEXT,AssocFormIds TEXT,AssocCommIds TEXT,FormUserSet TEXT,FormPermissionsMap TEXT,CanOrigChangeStatus INTEGER NOT NULL DEFAULT 0,CanControllerChangeStatus INTEGER NOT NULL DEFAULT 0,IsStatusChangeRestricted INTEGER NOT NULL DEFAULT 0,HasOverallStatus INTEGER NOT NULL DEFAULT 0,IsCloseOut INTEGER NOT NULL DEFAULT 0,AllowReopenForm INTEGER NOT NULL DEFAULT 0,OfflineRequestData TEXT NOT NULL DEFAULT "",IsOfflineCreated INTEGER NOT NULL DEFAULT 0,LocationId INTEGER,ObservationId INTEGER,MsgNum INTEGER,MsgContent TEXT,ActionComplete INTEGER NOT NULL DEFAULT 0,ActionCleared INTEGER NOT NULL DEFAULT 0,HasAttach INTEGER NOT NULL DEFAULT 0,TotalActions INTEGER,InstanceGroupId INTEGER,AttachFiles TEXT,HasViewAccess INTEGER NOT NULL DEFAULT 0,MsgOriginImage TEXT,IsForInfoIncomplete INTEGER NOT NULL DEFAULT 0,MsgCreatedDateOffline TEXT,LastModifiedTime TEXT,LastModifiedTimeInMS TEXT,CanViewDraftMsg INTEGER NOT NULL DEFAULT 0,CanViewOwnorgPrivateForms INTEGER NOT NULL DEFAULT 0,IsAutoSavedDraft INTEGER NOT NULL DEFAULT 0,MsgStatusName TEXT,ProjectAPDFolderId TEXT,ProjectStatusId TEXT,HasFormAccess INTEGER NOT NULL DEFAULT 0,CanAccessHistory INTEGER NOT NULL DEFAULT 0,HasDocAssocations INTEGER NOT NULL DEFAULT 0,HasBimViewAssociations INTEGER NOT NULL DEFAULT 0,HasBimListAssociations INTEGER NOT NULL DEFAULT 0,HasFormAssocations INTEGER NOT NULL DEFAULT 0,HasCommentAssocations INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId,FormId,MsgId))";
      var createQuery1 = "CREATE TABLE IF NOT EXISTS FormMsgActionListTbl(ProjectId TEXT NOT NULL,FormId TEXT NOT NULL,MsgId TEXT NOT NULL,ActionId TEXT NOT NULL,ActionName TEXT,ActionStatus TEXT,PriorityId TEXT,ActionDate TEXT,ActionDueDate TEXT,DistributorUserId TEXT,RecipientUserId TEXT,Remarks TEXT,DistListId TEXT,TransNum TEXT,ActionTime TEXT,ActionCompleteDate TEXT,ActionNotes TEXT,EntityType TEXT,ModelId TEXT,AssignedBy TEXT,RecipientName TEXT,RecipientOrgId TEXT,Id TEXT,ViewDate TEXT,IsActive INTEGER NOT NULL DEFAULT 0,ResourceId TEXT,ResourceParentId TEXT,ResourceCode TEXT,CommentMsgId TEXT,IsActionComplete INTEGER NOT NULL DEFAULT 0,IsActionClear INTEGER NOT NULL DEFAULT 0,ActionStatusName TEXT,ActionDueDateMilliSecond INTEGER NOT NULL DEFAULT 0,ActionDateMilliSecond INTEGER NOT NULL DEFAULT 0,ActionCompleteDateMilliSecond INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId,FormId,MsgId,ActionId))";
      var createQuery2 = "CREATE TABLE IF NOT EXISTS FormMsgAttachAndAssocListTbl(ProjectId TEXT NOT NULL,FormTypeId TEXT NOT NULL,FormId TEXT NOT NULL,MsgId TEXT NOT NULL,AttachmentType TEXT NOT NULL,AttachAssocDetailJson TEXT NOT NULL,OfflineUploadFilePath TEXT,AttachDocId TEXT,AttachRevId TEXT,AttachFileName TEXT,AssocProjectId TEXT,AssocDocFolderId TEXT,AssocDocRevisionId TEXT,AssocFormCommId TEXT,AssocCommentMsgId TEXT,AssocCommentId TEXT,AssocCommentRevisionId TEXT,AssocViewModelId TEXT,AssocViewId TEXT,AssocListModelId TEXT,AssocListId TEXT,AttachSize TEXT)";
      var createQuery3 = "CREATE TABLE IF NOT EXISTS UserReferenceAttachmentTbl(UserId TEXT NOT NULL,ProjectId TEXT NOT NULL,RevisionId TEXT NOT NULL,UserCloudId TEXT NOT NULL)";
      var tableName = "FormMessageListTbl";
      var tableName1 = "FormMsgActionListTbl";
      var tableName2 = "FormMsgAttachAndAssocListTbl";
      var tableName3 = "UserReferenceAttachmentTbl";
      List<String> primaryKeysList = ["ProjectId"];

      List<Map<String, dynamic>> rowList = [
        {"ProjectId":"2130192", "FormTypeId":"11072582", "FormId":"11620660", "MsgId":"12326738", "Originator":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval", "OriginatorDisplayName":"Dhaval Vekaria (5226), Asite Solutions", "MsgCode":"ORI001", "MsgCreatedDate":"28-Jul-2023#02:07 CST", "ParentMsgId":0, "MsgOriginatorId":514806, "MsgHasAssocAttach":0, "JsonData":{"myFields":{"attachments":[],"questions":[{"question":"Assigned to Saurabh","answer":""},{"question":"Assigned to Saurabh","answer":""},{"question":"Assigned to Saurabh","answer":""}],"ORI_FORMTITLE":"Assigned to Saurabh"}}, "UserRefCode":"N/A", "UpdatedDateInMS":1690528022000, "FormCreationDateInMS":1690528022000, "MsgCreatedDateInMS":1690528022000,"MsgTypeId":1,"MsgTypeCode":"ORI","MsgStatusId":20,"SentNames":["Saurabh Banethia (5327), Asite Solutions"],"SentActions":[{"projectId":"0\$\$u6RzDt","resourceParentId":11620660,"resourceId":12326738,"resourceCode":"ORI001","resourceStatusId":0,"msgId":"12326738\$\$K0R9Zw","commentMsgId":"12326738\$\$mwJf08","actionId":36,"actionName":"For Action","actionStatus":2,"priorityId":0,"actionDate":"Fri Jul 28 09:07:02 BST 2023","dueDate":"Wed Aug 02 20:29:59 BST 2023","distributorUserId":514806,"recipientId":859155,"remarks":"","distListId":13735255,"transNum":"-1","actionTime":"1 Day","actionCompleteDate":"Fri Jul 28 09:10:01 BST 2023","instantEmailNotify":"true","actionNotes":"","entityType":0,"instanceGroupId":"0\$\$lFWvh6","isActive":true,"modelId":"0\$\$sDhUZZ","assignedBy":"Dhaval Vekaria (5226), Asite Solutions","recipientName":"Saurabh Banethia (5327), Asite Solutions","recipientOrgId":"3","id":"ACTC13735255_859155_36_1_12326738_11620660","viewDate":"","assignedByOrgName":"Asite Solutions","distributionLevel":0,"distributionLevelId":"0\$\$HcDZZr","dueDateInMS":1691004599000,"actionCompleteDateInMS":1690531801000,"actionDelegated":false,"actionCleared":true,"actionCompleted":true,"assignedByEmail":"dvekaria@asite.com","assignedByRole":"","generateURI":true}],"DraftSentActions":"","FixFieldData":{"DS_WORKINGUSERROLE":"Field Inspector","DS_PRINTEDON":"1970-01-01 00:00:00","comboList":"","DS_PROJECTNAME":"Site Quality Demo","DS_PRINTEDBY":"DS_PRINTEDBY_VALUE","DS_FORMID":"THG019"},"FolderId":0,"LatestDraftId":0,"IsDraft":0,"AssocRevIds":"","ResponseRequestBy":"31-Jul-2023#13:29 CST","DelFormIds":"","AssocFormIds":"","AssocCommIds":"","FormUserSet":[],"FormPermissionsMap":{"can_edit_ORI":false,"can_respond":false,"restrictChangeFormStatus":false,"controllerUserId":0,"isProjectArchived":false,"can_distribute":false,"can_forward":false,"oriMsgId":"12326738\$\$K0R9Zw"},"CanOrigChangeStatus":1,"CanControllerChangeStatus":0,"IsStatusChangeRestricted":0,"HasOverallStatus":1,"IsCloseOut":0,"AllowReopenForm":1,"OfflineRequestData":"","IsOfflineCreated":0,"LocationId":"185553","ObservationId":"107617","MsgNum":"","MsgContent":"","ActionComplete":0,"ActionCleared":0,"HasAttach":0,"TotalActions":"","InstanceGroupId":"11072520","AttachFiles":"","HasViewAccess":0,"MsgOriginImage":"","IsForInfoIncomplete":0,"MsgCreatedDateOffline":"","LastModifiedTime":"","LastModifiedTimeInMS":"","CanViewDraftMsg":0,"CanViewOwnorgPrivateForms":0,"IsAutoSavedDraft":0,"MsgStatusName":"Sent","ProjectAPDFolderID":"110997340","ProjectStatusId":5,"HasFormAccess":0,"CanAccessHistory":0,"HasDocAssociations":0,"HasBimViewAssociations":0,"HasBimListAssociations":0,"HasFormAssociations":0,"HasCommentAssociations":0}
      ];
      var selectQuery = "SELECT ProjectId FROM FormMessageListTbl WHERE ProjectId='2130192'";
      var selectQuery1 = "SELECT ProjectId FROM FormMsgActionListTbl WHERE ProjectId='2130192'";
      var selectQuery2 = "SELECT ProjectId FROM FormMsgAttachAndAssocListTbl WHERE ProjectId='2130192'";
      var selectQuery3 = "SELECT ProjectId FROM UserReferenceAttachmentTbl WHERE ProjectId='2130192'";
      List<String> columnNames = ["ProjectId", "FormTypeId", "FormId", "MsgId", "Originator", "OriginatorDisplayName", "MsgCode", "MsgCreatedDate", "ParentMsgId", "MsgOriginatorId", "MsgHasAssocAttach", "JsonData", "UserRefCode", "UpdatedDateInMS", "FormCreationDateInMS", "MsgCreatedDateInMS","MsgTypeId","MsgTypeCode","MsgStatusId","SentNames","SentActions","DraftSentActions","FixFieldData","FolderId","LatestDraftId","IsDraft","AssocRevIds","ResponseRequestBy","DelFormIds","AssocFormIds","AssocCommIds","FormUserSet","FormPermissionsMap","CanOrigChangeStatus","CanControllerChangeStatus","IsStatusChangeRestricted","HasOverallStatus","IsCloseOut","AllowReopenForm","OfflineRequestData","IsOfflineCreated","LocationId","ObservationId","MsgNum","MsgContent","ActionComplete","ActionCleared","HasAttach","TotalActions","InstanceGroupId","AttachFiles","HasViewAccess","MsgOriginImage","IsForInfoIncomplete","MsgCreatedDateOffline","LastModifiedTime","LastModifiedTimeInMS","CanViewDraftMsg","CanViewOwnorgPrivateForms","IsAutoSavedDraft","MsgStatusName","ProjectAPDFolderID","ProjectStatusId","HasFormAccess","CanAccessHistory","HasDocAssociations","HasBimViewAssociations","HasBimListAssociations","HasFormAssociations","HasCommentAssociations"];
      List<String> columnNames1 = ["ProjectId","FormId","MsgId","ActionId","ActionName","ActionStatus","PriorityId","ActionDate","ActionDueDate","DistributorUserId","RecipientUserId","Remarks","DistListId","TransNum","ActionTime","ActionCompleteDate","ActionNotes","EntityType","ModelId","AssignedBy","RecipientName","RecipientOrgId","Id","ViewDate","IsActive","ResourceId","ResourceParentId","ResourceCode","CommentMsgId","IsActionComplete","IsActionClear","ActionStatusName","ActionDueDateMilliSecond","ActionDateMilliSecond","ActionCompleteDateMilliSecond"];
      List<String> columnNames2 = ["ProjectId","FormTypeId","FormId","MsgId","AttachmentType","AttachAssocDetailJson","OfflineUploadFilePath","AttachDocId","AttachRevId","AttachFileName","AssocProjectId","AssocDocFolderId","AssocDocRevisionId","AssocFormCommId","AssocCommentMsgId","AssocCommentId","AssocCommentRevisionId","AssocViewModelId","AssocViewId","AssocListModelId","AssocListId","AttachSize"];
      List<String> columnNames3 = ["UserId","ProjectId","RevisionId","UserCloudId"];
      List<List<Object?>> rows = [];
      List<List<Object?>> rows1 = [];
      List<List<Object?>> rows2 = [];
      List<List<Object?>> rows3 = [];

      var sqlQuery = "INSERT INTO FormMessageListTbl (ProjectId,FormTypeId,FormId,MsgId,Originator,OriginatorDisplayName,MsgCode,MsgCreatedDate,ParentMsgId,MsgOriginatorId,MsgHasAssocAttach,JsonData,UserRefCode,UpdatedDateInMS,FormCreationDateInMS,MsgCreatedDateInMS,MsgTypeId,MsgTypeCode,MsgStatusId,SentNames,SentActions,DraftSentActions,FixFieldData,FolderId,LatestDraftId,IsDraft,AssocRevIds,ResponseRequestBy,DelFormIds,AssocFormIds,AssocCommIds,FormUserSet,FormPermissionsMap,CanOrigChangeStatus,CanControllerChangeStatus,IsStatusChangeRestricted,HasOverallStatus,IsCloseOut,AllowReopenForm,OfflineRequestData,IsOfflineCreated,LocationId,ObservationId,MsgNum,MsgContent,ActionComplete,ActionCleared,HasAttach,TotalActions,InstanceGroupId,AttachFiles,HasViewAccess,MsgOriginImage,IsForInfoIncomplete,MsgCreatedDateOffline,LastModifiedTime,LastModifiedTimeInMS,CanViewDraftMsg,CanViewOwnorgPrivateForms,IsAutoSavedDraft,MsgStatusName,ProjectAPDFolderID,ProjectStatusId,HasFormAccess,CanAccessHistory,HasDocAssociations,HasBimViewAssociations,HasBimListAssociations,HasFormAssociations,HasCommentAssociations) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      var sqlQuery1 = "INSERT INTO FormMsgActionListTbl(ProjectId,FormId,MsgId,ActionId,ActionName,ActionStatus,PriorityId,ActionDate,ActionDueDate,DistributorUserId,RecipientUserId,Remarks,DistListId,TransNum,ActionTime,ActionCompleteDate,ActionNotes,EntityType,ModelId,AssignedBy,RecipientName,RecipientOrgId,Id,ViewDate,IsActive,ResourceId,ResourceParentId,ResourceCode,CommentMsgId,IsActionComplete,IsActionClear,ActionStatusName,ActionDueDateMilliSecond,ActionDateMilliSecond,ActionCompleteDateMilliSecond) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      var sqlQuery2 = "INSERT INTO FormMsgAttachAndAssocListTbl(ProjectId,FormTypeId,FormId,MsgId,AttachmentType,AttachAssocDetailJson,OfflineUploadFilePath,AttachDocId,AttachRevId,AttachFileName,AssocProjectId,AssocDocFolderId,AssocDocRevisionId,AssocFormCommId,AssocCommentMsgId,AssocCommentId,AssocCommentRevisionId,AssocViewModelId,AssocViewId,AssocListModelId,AssocListId,AttachSize) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      var sqlQuery3 = "INSERT INTO UserReferenceAttachmentTbl(UserId,ProjectId,RevisionId,UserCloudId) VALUES (?,?,?,?)";
      List<List<dynamic>> insertValues = [
        ["2130192","11072582","11579710","12311786","https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000#Dhaval","Dhaval Vekaria (5226), Asite Solutions","ORI001","28-Jul-2023#02:07 CST",0,514806,0,{"myFields":{"attachments":[],"questions":[{"question":"Assigned to Saurabh","answer":""},{"question":"Assigned to Saurabh","answer":""},{"question":"Assigned to Saurabh","answer":""}],"ORI_FORMTITLE":"Assigned to Saurabh"}},"N/A",1690528022000,1690528022000,1,"ORI",20,["Saurabh Banethia (5327), Asite Solutions"],[{"projectId":"0\$\$u6RzDt","resourceParentId":11620660,"resourceId":12326738,"resourceCode":"ORI001","resourceStatusId":0,"msgId":"12326738\$\$K0R9Zw","commentMsgId":"12326738\$\$mwJf08","actionId":36,"actionName":"For Action","actionStatus":2,"priorityId":0,"actionDate":"Fri Jul 28 09:07:02 BST 2023","dueDate":"Wed Aug 02 20:29:59 BST 2023","distributorUserId":514806,"recipientId":859155,"remarks":"","distListId":13735255,"transNum":"-1","actionTime":"1 Day","actionCompleteDate":"Fri Jul 28 09:10:01 BST 2023","instantEmailNotify":"true","actionNotes":"","entityType":0,"instanceGroupId":"0\$\$lFWvh6","isActive":true,"modelId":"0\$\$sDhUZZ","assignedBy":"Dhaval Vekaria (5226), Asite Solutions","recipientName":"Saurabh Banethia (5327), Asite Solutions","recipientOrgId":"3","id":"ACTC13735255_859155_36_1_12326738_11620660","viewDate":"","assignedByOrgName":"Asite Solutions","distributionLevel":0,"distributionLevelId":"0\$\$HcDZZr","dueDateInMS":1691004599000,"actionCompleteDateInMS":1690531801000,"actionDelegated":false,"actionCleared":true,"actionCompleted":true,"assignedByEmail":"dvekaria@asite.com","assignedByRole":"","generateURI":true}],"",{"DS_WORKINGUSERROLE":"Field Inspector","DS_PRINTEDON":"1970-01-01 00:00:00","comboList":"","DS_PROJECTNAME":"Site Quality Demo","DS_PRINTEDBY":"DS_PRINTEDBY_VALUE","DS_FORMID":"THG019"},0,0,0,"","31-Jul-2023#13:29 CST","","","",[],{"can_edit_ORI":false,"can_respond":false,"restrictChangeFormStatus":false,"controllerUserId":0,"isProjectArchived":false,"can_distribute":false,"can_forward":false,"oriMsgId":"12326738\$\$K0R9Zw"},1,0,0,1,0,1,"",0,185553,107617,"","",0,0,0,"",11072520,"",0,"",0,"","","",0,0,0,"Sent",110997340,5,0,0,0,0,0,0,0]
      ];
      List<List<dynamic>> insertValues1 = [
        ["2130192","11596804","12296701",7,"For Information",1,0,"Mon Jul 10 06:56:21 BST 2023","",707447,2017529,"",13702887,-1,"","Mon Jul 10 06:58:00 BST 2023","","",0,"Vijay Mavadiya (5336),Asite Solutions","Mayur Raval m., Asite Solutions Ltd",5763307,"ACTC13702887_2017529_7_1_12296701_11596804","Mon Jul 10 06:58:00 BST 2023",1,12296701,11596804,"ORI001",12296701,0,0,"",0,0,1688968680000]
      ];
      List<List<dynamic>> insertValues2 = [
        ["2130192","11103151","11624015","12331468",3,{"fileType":"filetype/jpg.gif","fileName":"Image_1690869946283.jpg","revisionId":"27196803","fileSize":"353 KB","hasAccess":true,"canDownload":true,"publisherUserId":"0","hasBravaSupport":true,"docId":"13652680","attachedBy":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur","attachedDateInTimeStamp":"Aug 1, 2023 7:45:00 AM","attachedDate":"01-Aug-2023#01:45 CST","createdDateInTimeStamp":"Aug 1, 2023 7:45:00 AM","attachedById":"2017529","attachedByName":"Mayur Raval m.","isLink":false,"linkType":"Static","isHasXref":false,"documentTypeId":"0","isRevPrivate":false,"isAccess":true,"isDocActive":true,"folderPermissionValue":"0","isRevInDistList":false,"isPasswordProtected":false,"attachmentId":"0","viewAlwaysFormAssociationParent":false,"viewAlwaysDocAssociationParent":false,"allowDownloadToken":"1","isHoopsSupported":false,"isPDFTronSupported":false,"downloadImageName":"icons/downloads.png","hasOnlineViewerSupport":true,"newSysLocation":"project_2130192/formtype_11103151/form_11103151/msg_12331468/27196803.jpg","hashedAttachedById":"2017529\$\$0P0Uq4","hasGeoTagInfo":false,"locationPath":"Site Quality Demo\\01 Vijay_Test","type":"3","msgId":"12331468","msgCreationDate":"Aug 1, 2023 7:45:00 AM","projectId":"2130192","folderId":"116256200","dcId":"1","childProjectId":"0","userId":"0","resourceId":"0","parentMsgId":"12331468","parentMsgCode":"ORI001","assocsParentId":"0","totalDocCount":"0","generateURI":true,"hasHoopsViewerSupport":false},"",13652680,27196803,"Image_1690869946283.jpg","","","","","","","","","","","",353]
      ];
      List<List<dynamic>> insertValues3 = [
        ["808581","2130192","27093923","1"]
      ];

          SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2130192\$\$cJT4po"
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.project
        ..projectSizeInByte = "253288002";

      Map<String, dynamic> chunkOfFormList = {
      "resourceTypeId" : "3",
      "isOriMsgId" : "false",
      "networkExecutionType" : NetworkExecutionType.SYNC,
      "taskNumber" : -9007199254740991,
      "formDataJson" : "{\"11579710\":{\"projectId\":\"2130192\",\"commId\":\"11579710\",\"formTypeId\":\"11076066\"}}"
      };
      ResultSet resultSet = ResultSet(columnNames, null, rows);
      ResultSet resultSet1 = ResultSet(columnNames1, null, rows1);
      ResultSet resultSet2 = ResultSet(columnNames2, null, rows2);
      ResultSet resultSet3 = ResultSet(columnNames3, null, rows3);

      when(() => mockProjectListUseCase!.getFormMessageBatchList(chunkOfFormList)).thenAnswer((_) async {
        return SUCCESS(jsonDecode(fixture("form_message_batch_size_data.json")), null, 200);
      });
      String discardAttachQuery = "SELECT ProjectId,AttachRevId,AttachFileName FROM FormMsgAttachAndAssocListTbl\n"
      "WHERE ProjectId=2130192 AND FormId=11579710 AND MsgId IN (SELECT MsgId FROM FormMessageListTbl\n"
      "WHERE IsOfflineCreated=0 AND ProjectId=2130192\n"
          "AND FormId=11579710 AND MsgId NOT IN (12311786)) AND AttachRevId<>''";
      when(() => mockDb!.selectFromTable("FormMsgAttachAndAssocListTbl", discardAttachQuery)).thenReturn(ResultSet(
          ["ProjectId","AttachRevId","AttachFileName"],
          null,
          [
            [2130192,10391015,"test.png"]
          ]
      ));
      when(() => mockDb!.executeQuery("delete from userreferenceattachmenttbl where projectid=2130192 and revisionid=10391015 and userid=808581 and usercloudid=1")).thenReturn(null);
      when(() => mockDb!.selectFromTable("UserReferenceAttachmentTbl", "SELECT * FROM UserReferenceAttachmentTbl WHERE ProjectId=2130192 AND RevisionId=10391015 AND UserCloudId=1")).thenReturn(ResultSet(
          [],
          null,
          []
      ));
      when(() => mockFileUtility.deleteFileAtPath(any())).thenAnswer((_) => Future.value(null));
      String discAttachQry = "DELETE FROM FormGroupAndFormTypeListTbl\n"
          "WHERE ProjectId=2130192 AND FormTypeId IN (SELECT DISTINCT FormTypeId FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId IN (10391015,10567609) AND FormTypeId NOT IN (\n"
          "SELECT DISTINCT FormTypeId FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId NOT IN (10391015,10567609)\n"
          "))";
      when(() => mockDb!.executeQuery(discAttachQry)).thenReturn(null);
      when(() => mockDb!.executeQuery("DELETE FROM FormMsgActionListTbl\nWHERE ProjectId=2130192 AND FormId=11579710 AND MsgId IN (SELECT MsgId FROM FormMessageListTbl\nWHERE IsOfflineCreated=0 AND ProjectId=2130192\nAND FormId=11579710 AND MsgId NOT IN (12311786))")).thenReturn(null);
      when(() => mockDb!.executeQuery("DELETE FROM FormMsgAttachAndAssocListTbl\nWHERE ProjectId=2130192 AND FormId=11579710 AND MsgId IN (SELECT MsgId FROM FormMessageListTbl\nWHERE IsOfflineCreated=0 AND ProjectId=2130192\nAND FormId=11579710 AND MsgId NOT IN (12311786))")).thenReturn(null);
      when(() => mockDb!.executeQuery("DELETE FROM FormMessageListTbl\nWHERE ProjectId=2130192 AND FormId=11579710 AND MsgId IN (SELECT MsgId FROM FormMessageListTbl\nWHERE IsOfflineCreated=0 AND ProjectId=2130192\nAND FormId=11579710 AND MsgId NOT IN (12311786))")).thenReturn(null);
      when(() => mockDb!.executeQuery("VACUUM")).thenReturn(null);

      //FormMessageActionDao
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);

      //FormMessageActionDao
      when(() => mockDb!.executeQuery(createQuery1)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName1)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName1, selectQuery1)).thenReturn(resultSet1);
      when(() => mockDb!.executeBulk(tableName1, sqlQuery1, insertValues1)).thenAnswer((_) async=> null);

      //FormMessageAttachAndAssocVO
      when(() => mockDb!.executeQuery(createQuery2)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName2)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName2, selectQuery2)).thenReturn(resultSet2);
      when(() => mockDb!.executeBulk(tableName2, sqlQuery2, insertValues2)).thenAnswer((_) async=> null);

      //UserReferenceAttachmentDao
      when(() => mockDb!.executeQuery(createQuery3)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName3)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName3, selectQuery3)).thenReturn(resultSet3);
      when(() => mockDb!.executeBulk(tableName3, sqlQuery3, insertValues3)).thenAnswer((_) async=> null);

      Completer completer = Completer();
      taskPool?.taskStatusStreamController?.stream.listen((task) {
        if (task.isDone) {
          completer.complete();
        }
      });

      await FormMessageBatchListSyncTask(
        siteSyncTask,
            (eSyncTaskType, eSyncStatus, data) async {},
      ).syncFormMessageBatchListData(projectList,formList);

      await completer.future;
      verify(() => mockProjectListUseCase!.getFormMessageBatchList(chunkOfFormList)).called(1);
    }
    );
  });
}