import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/domain/use_cases/site/create_form_use_case.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/task/push_to_server_form_sync_task.dart';
import 'package:field/utils/field_enums.dart';
import 'package:field/utils/file_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/offline_injection_container.dart' as di;
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/common.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';

class DBServiceMock extends Mock implements DBService {}

class CreateFormUseCaseMock extends Mock implements CreateFormUseCase {}

class FileUtilityMock extends Mock implements FileUtility {}

class ProjectListUseCaseMock extends Mock implements ProjectListUseCase {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  FileUtilityMock? mockFileUtility;
  DBServiceMock? mockDb;
  CreateFormUseCaseMock? mockUseCase;
  ProjectListUseCaseMock? mockProjectUseCase;
  await di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  configureDependencies() {
    mockFileUtility = FileUtilityMock();
    mockDb = DBServiceMock();
    mockUseCase = CreateFormUseCaseMock();
    mockProjectUseCase = ProjectListUseCaseMock();
    di.getIt.unregister<FileUtility>();
    di.getIt.unregister<DBService>();
    di.getIt.unregister<CreateFormUseCase>();
    di.getIt.unregister<ProjectListUseCase>();
    di.getIt.registerLazySingleton<FileUtility>(() => mockFileUtility!);
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
    di.getIt.registerLazySingleton<CreateFormUseCase>(() => mockUseCase!);
    di.getIt.registerLazySingleton<ProjectListUseCase>(() => mockProjectUseCase!);
  }
  tearDown(() {
    reset(mockFileUtility);
    reset(mockDb);
    reset(mockUseCase);
    reset(mockProjectUseCase);
  });

  setUpAll(() {
    configureDependencies();
  });

  tearDownAll(() {
    mockFileUtility = null;
    mockDb = null;
    mockUseCase = null;
    mockProjectUseCase = null;
  });

  group("PushToServerFormSyncTask Test", () {
    test('syncFormDataToServer site task form test', () async {
      SyncRequestTask syncTask = SyncRequestTask();
      var paramData = {
        "RequestType": EOfflineSyncRequestType.CreateOrRespond.value.toString(),
        "ProjectId": "2130192",
        "FormId": "1690785287567",
        "MsgId": "1690785341103",
        "UpdatedDateInMS": "1690785341103",
      };

      String requestData = "{\"projectId\":\"2130192\",\"locationId\":183678,\"coordinates\":\"{}\",\"annotationId\":\"61c6ef9a-19e0-4088-a6ee-b39f831db26e-1690785287551\",\"isFromMapView\":true,\"isCalibrated\":true,\"page_number\":1,\"appTypeId\":2,\"formSelectRadiobutton\":\"1_2130192_11103151\",\"formTypeId\":\"11103151\",\"instanceGroupId\":\"10940318\",\"templateType\":2,\"appBuilderId\":\"ASI-SITE\",\"revisionId\":\"0\",\"offlineFormId\":1690785287567,\"isUploadAttachmentInTemp\":true,\"formCreationDate\":\"2023-07-31 12:04:47\",\"url\":\"file:///data/user/0/com.asite.field/app_flutter/database/HTML5Form/createFormHTML.html\",\"offlineFormDataJson\":\"{\\\"myFields\\\":{\\\"FORM_CUSTOM_FIELDS\\\":{\\\"ORI_MSG_Custom_Fields\\\":{\\\"ORI_FORMTITLE\\\":\\\"Test Offlinr VJ\\\",\\\"ORI_USERREF\\\":\\\"\\\",\\\"DefectTyoe\\\":\\\"Computer\\\",\\\"TaskType\\\":\\\"Defect\\\",\\\"DefectDescription\\\":\\\"\\\",\\\"Location\\\":\\\"183678|01 Vijay_Test|01 Vijay_Test\\\",\\\"LocationName\\\":\\\"01 Vijay_Test\\\",\\\"StartDate\\\":\\\"2023-07-31\\\",\\\"StartDateDisplay\\\":\\\"31-Jul-2023\\\",\\\"ExpectedFinishDate\\\":\\\"\\\",\\\"OriginatorId\\\":\\\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\\\",\\\"ActualFinishDate\\\":\\\"\\\",\\\"Recent_Defects\\\":\\\"\\\",\\\"AssignedToUsersGroup\\\":{\\\"AssignedToUsers\\\":{\\\"AssignedToUser\\\":\\\"707447#Vijay Mavadiya (5336), Asite Solutions\\\"}},\\\"CurrStage\\\":\\\"1\\\",\\\"PF_Location_Detail\\\":\\\"183678|0|null|0\\\",\\\"Defect_Description\\\":\\\"test description\\\",\\\"Username\\\":\\\"\\\",\\\"Organization\\\":\\\"\\\",\\\"ExpectedFinishDays\\\":\\\"5\\\",\\\"DistributionDays\\\":\\\"0\\\",\\\"LastResponder_For_AssignedTo\\\":\\\"707447\\\",\\\"LastResponder_For_Originator\\\":\\\"2017529\\\",\\\"FormCreationDate\\\":\\\"\\\",\\\"Assigned\\\":\\\"Vijay Mavadiya (5336), Asite Solutions\\\",\\\"attachements\\\":[{\\\"attachedDocs\\\":\\\"\\\"}],\\\"DS_Logo\\\":\\\"images/asite.gif\\\",\\\"isCalibrated\\\":true},\\\"RES_MSG_Custom_Fields\\\":{\\\"Comments\\\":\\\"\\\",\\\"ShowHideFlag\\\":\\\"Yes\\\",\\\"SHResponse\\\":\\\"Yes\\\"},\\\"CREATE_FWD_RES\\\":{\\\"Can_Reply\\\":\\\"\\\"},\\\"DS_AUTONUMBER\\\":{\\\"DS_FORMAUTONO_CREATE\\\":\\\"\\\",\\\"DS_SEQ_LENGTH\\\":\\\"\\\",\\\"DS_FORMAUTONO_ADD\\\":\\\"\\\",\\\"DS_GET_APP_ACTION_DETAILS\\\":\\\"\\\"},\\\"DS_DATASOURCE\\\":{\\\"DS_ASI_SITE_getAllLocationByProject_PF\\\":\\\"\\\",\\\"DS_Response_PARAM\\\":\\\"#Comments#DS_ALL_FORMSTATUS\\\",\\\"DS_Get_All_Responses\\\":\\\"\\\",\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\":\\\"\\\",\\\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\\\":\\\"\\\",\\\"DS_Holiday_Calender_Param\\\":\\\"\\\",\\\"DS_CALL_METHOD\\\":\\\"1\\\",\\\"DS_ASI_SITE_GET_RECENT_DEFECTS\\\":\\\"\\\",\\\"DS_CHECK_FORM_PERMISSION_USER\\\":\\\"\\\",\\\"DS_ASI_Configurable_Attributes\\\":\\\"\\\"}},\\\"Asite_System_Data_Read_Only\\\":{\\\"_1_User_Data\\\":{\\\"DS_WORKINGUSER\\\":\\\"Mayur Raval m., Asite Solutions Ltd\\\",\\\"DS_WORKINGUSERROLE\\\":\\\"\\\",\\\"DS_WORKINGUSER_ID\\\":\\\"\\\",\\\"DS_WORKINGUSER_ALL_ROLES\\\":\\\"\\\"},\\\"_2_Printing_Data\\\":{\\\"DS_PRINTEDBY\\\":\\\"\\\",\\\"DS_PRINTEDON\\\":\\\"\\\"},\\\"_3_Project_Data\\\":{\\\"DS_PROJECTNAME\\\":\\\"Site Quality Demo\\\",\\\"DS_CLIENT\\\":\\\"\\\"},\\\"_4_Form_Type_Data\\\":{\\\"DS_FORMNAME\\\":\\\"Site Tasks\\\",\\\"DS_FORMGROUPCODE\\\":\\\"SITE\\\",\\\"DS_FORMAUTONO\\\":\\\"\\\"},\\\"_5_Form_Data\\\":{\\\"DS_FORMID\\\":\\\"\\\",\\\"DS_ORIGINATOR\\\":\\\"\\\",\\\"DS_DATEOFISSUE\\\":\\\"\\\",\\\"DS_DISTRIBUTION\\\":\\\"\\\",\\\"DS_CONTROLLERNAME\\\":\\\"\\\",\\\"DS_ATTRIBUTES\\\":\\\"\\\",\\\"DS_MAXFORMNO\\\":\\\"\\\",\\\"DS_MAXORGFORMNO\\\":\\\"\\\",\\\"DS_ISDRAFT\\\":\\\"NO\\\",\\\"DS_ISDRAFT_RES\\\":\\\"\\\",\\\"DS_FORMAUTONO_PREFIX\\\":\\\"\\\",\\\"DS_FORMCONTENT\\\":\\\"\\\",\\\"DS_FORMCONTENT1\\\":\\\"\\\",\\\"DS_FORMCONTENT2\\\":\\\"\\\",\\\"DS_FORMCONTENT3\\\":\\\"\\\",\\\"DS_ISDRAFT_RES_MSG\\\":\\\"NO\\\",\\\"DS_ISDRAFT_FWD_MSG\\\":\\\"NO\\\",\\\"Status_Data\\\":{\\\"DS_FORMSTATUS\\\":\\\"\\\",\\\"DS_CLOSEDUEDATE\\\":\\\"\\\",\\\"DS_APPROVEDBY\\\":\\\"\\\",\\\"DS_APPROVEDON\\\":\\\"\\\",\\\"DS_CLOSE_DUE_DATE\\\":\\\"\\\",\\\"DS_ALL_FORMSTATUS\\\":\\\"1001 # Open\\\",\\\"DS_ALL_ACTIVE_FORM_STATUS\\\":\\\"\\\"}},\\\"_6_Form_MSG_Data\\\":{\\\"DS_MSGID\\\":\\\"\\\",\\\"DS_MSGCREATOR\\\":\\\"\\\",\\\"DS_MSGDATE\\\":\\\"\\\",\\\"DS_MSGSTATUS\\\":\\\"\\\",\\\"DS_MSGRELEASEDATE\\\":\\\"\\\",\\\"ORI_MSG_Data\\\":{\\\"DS_DOC_ASSOCIATIONS_ORI\\\":\\\"\\\",\\\"DS_FORM_ASSOCIATIONS_ORI\\\":\\\"\\\",\\\"DS_ATTACHMENTS_ORI\\\":\\\"\\\"}}},\\\"Asite_System_Data_Read_Write\\\":{\\\"ORI_MSG_Fields\\\":{\\\"SP_ORI_VIEW\\\":\\\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\\\",\\\"SP_ORI_PRINT_VIEW\\\":\\\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\\\",\\\"SP_FORM_PRINT_VIEW\\\":\\\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\\\",\\\"SP_RES_VIEW\\\":\\\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\\\",\\\"SP_RES_PRINT_VIEW\\\":\\\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\\\"},\\\"DS_PROJORGANISATIONS\\\":\\\"\\\",\\\"DS_PROJUSERS\\\":\\\"\\\",\\\"DS_PROJDISTGROUPS\\\":\\\"\\\",\\\"DS_AUTODISTRIBUTE\\\":\\\"401\\\",\\\"DS_INCOMPLETE_ACTIONS\\\":\\\"\\\",\\\"DS_PROJORGANISATIONS_ID\\\":\\\"\\\",\\\"DS_PROJUSERS_ALL_ROLES\\\":\\\"\\\",\\\"Auto_Distribute_Group\\\":{\\\"Auto_Distribute_Users\\\":[{\\\"DS_PROJDISTUSERS\\\":\\\"707447\\\",\\\"DS_FORMACTIONS\\\":\\\"3#Respond\\\",\\\"DS_ACTIONDUEDATE\\\":\\\"5\\\"}]}},\\\"attachments\\\":[],\\\"dist_list\\\":\\\"{\\\\\\\"selectedDistGroups\\\\\\\":\\\\\\\"\\\\\\\",\\\\\\\"selectedDistUsers\\\\\\\":[],\\\\\\\"selectedDistOrgs\\\\\\\":[],\\\\\\\"selectedDistRoles\\\\\\\":[],\\\\\\\"prePopulatedDistGroups\\\\\\\":\\\\\\\"\\\\\\\"}\\\",\\\"respondBy\\\":\\\"\\\",\\\"selectedControllerUserId\\\":\\\"\\\",\\\"create_hidden_list\\\":{\\\"msg_type_id\\\":\\\"1\\\",\\\"msg_type_code\\\":\\\"ORI\\\",\\\"dist_list\\\":\\\"{\\\\\\\"selectedDistGroups\\\\\\\":\\\\\\\"\\\\\\\",\\\\\\\"selectedDistUsers\\\\\\\":[],\\\\\\\"selectedDistOrgs\\\\\\\":[],\\\\\\\"selectedDistRoles\\\\\\\":[],\\\\\\\"prePopulatedDistGroups\\\\\\\":\\\\\\\"\\\\\\\"}\\\",\\\"formAction\\\":\\\"create\\\",\\\"project_id\\\":\\\"2130192\\\",\\\"offlineProjectId\\\":\\\"2130192\\\",\\\"offlineFormTypeId\\\":\\\"11103151\\\",\\\"assocLocationSelection\\\":\\\"{\\\\\\\"locationId\\\\\\\":183678}\\\",\\\"requestType\\\":\\\"0\\\",\\\"annotationId\\\":\\\"61c6ef9a-19e0-4088-a6ee-b39f831db26e-1690785287551\\\",\\\"coordinates\\\":\\\"{}\\\",\\\"appTypeId\\\":\\\"2\\\"}}}\",\"isDraft\":false,\"offlineFormCreatedDateInMS\":\"1690785341103\",\"assocLocationSelection\":\"{\\\"locationId\\\":183678,\\\"projectId\\\":\\\"2130192\\\",\\\"folderId\\\":\\\"115096348\\\"}\"}";
      String reqFilePath = "./test/fixtures/database/1_808581/2130192/OfflineRequestData/1690785341103.txt";
      when(() => mockFileUtility!.readFromFile(reqFilePath))
          .thenReturn(requestData);

      ResultSet resultSet = ResultSet([], null, []);
      String attachQuery = "SELECT AttachRevId,OfflineUploadFilePath FROM FormMsgAttachAndAssocListTbl WHERE ProjectId=2130192 AND FormId=1690785287567 AND MsgId=1690785341103 AND OfflineUploadFilePath <> ''";
      String attachTableName = "FormMsgAttachAndAssocListTbl";
      when(() => mockDb!.selectFromTable(attachTableName, attachQuery))
          .thenReturn(resultSet);

      final saveFormResult = {
        "formDetailsVO": {
          "templateType": 2,
          "responseRequestByInMS": 1691470799000,
          "pfLocFolderId": 115096348,
          "workflowStatus": "",
          "isDraft": false,
          "formCreationDate": "31-Jul-2023#04:12 CST",
          "userID": "2017529\$\$WQWzza",
          "observationVO": {
            "msgNum": 0,
            "pageNumber": 1,
            "attachments": [],
            "assignedToUserOrgName": "Asite Solutions",
            "isDraft": false,
            "formDueDays": 5,
            "msgId": "0\$\$NQLyUb",
            "isActive": true,
            "taskTypeName": "Defect",
            "orgId": "0\$\$kVxfxX",
            "noOfActions": 0,
            "observationTypeId": 0,
            "observationId": 0,
            "hasAttachment": false,
            "locationId": 0,
            "appType": 0,
            "noOfMessages": 0,
            "isCloseOut": false,
            "originatorId": 0,
            "formId": "0\$\$FPUasW",
            "assignedToUserId": 707447,
            "lastResponderForOriginator": "2017529",
            "formTypeId": "0\$\$FPUasW",
            "formSyncDate": "2023-07-31 10:12:59.157",
            "lastResponderForAssignedTo": "707447",
            "annotationId": "61c6ef9a-19e0-4088-a6ee-b39f831db26e-1690785287551",
            "observationCoordinates": "{}",
            "generateURI": true,
            "manageTypeVo": {"isDeactive": false, "name": "Computer", "id": "310493", "projectId": "2130192\$\$i5DqWs", "generateURI": true},
            "expectedFinishDate": "2023-08-07",
            "statusId": 0,
            "assignedToUserName": "Vijay Mavadiya (5336)",
            "isStatusChangeRestricted": false,
            "allowReopenForm": false,
            "messages": [],
            "instanceGroupId": "0\$\$FPUasW",
            "projectId": "0\$\$eOptjB",
            "startDate": "2023-07-31"
          },
          "msgStatusId": 20,
          "statusid": 1001,
          "canControllerChangeStatus": false,
          "appTypeId": "2",
          "invoiceCountAgainstOrder": "-1",
          "workflowStage": "",
          "hasBimViewAssociations": false,
          "id": "SITE399",
          "msgCode": "ORI001",
          "formGroupName": "Site Tasks",
          "statusChangeUserId": 0,
          "originatorDisplayName": "Mayur Raval m., Asite Solutions Ltd",
          "msgUserOrgId": 5763307,
          "allowReopenForm": false,
          "canAccessHistory": true,
          "latestDraftId": "0\$\$NQLyUb",
          "status": "Open",
          "canOrigChangeStatus": false,
          "lastName": "Raval m.",
          "originatorName": "Mayur Raval m.",
          "controllerUserId": 0,
          "msgId": "12329329\$\$ZvNboh",
          "originatorEmail": "m.raval@asite.com",
          "msgUserName": "Mayur Raval m.",
          "orgId": "5763307\$\$OrOFEZ",
          "msgHasAssocAttach": false,
          "locationId": 183678,
          "appType": "Field",
          "noOfMessages": 0,
          "originatorOrgId": 5763307,
          "isCloseOut": false,
          "originatorId": 2017529,
          "hasAttachments": false,
          "formHasAssocAttach": false,
          "actionDateInMS": 0,
          "msgUserOrgName": "Asite Solutions Ltd",
          "hasFormAccess": false,
          "docType": "Apps",
          "generateURI": true,
          "responseRequestBy": "07-Aug-2023#23:59 CST",
          "parentMsgId": 0,
          "commId": "11622489\$\$wMy9Is",
          "ownerOrgId": 3,
          "instanceGroupId": "10940318\$\$Z3lWz4",
          "isThumbnailSupports": false,
          "hasBimListAssociations": false,
          "msgTypeCode": "ORI",
          "appBuilderId": "ASI-SITE",
          "hasDocAssocations": false,
          "noOfActions": 0,
          "statusRecordStyle": {"fontType": "PT Sans", "backgroundColor": "#e03ae0", "isDeactive": false, "isForOnlyStyleUpdate": false, "statusTypeID": 1, "proxyUserId": 0, "userId": 0, "generateURI": true, "fontEffect": "0#0#0#0", "orgId": "0\$\$kVxfxX", "always_active": false, "statusID": 1001, "defaultPermissionId": 0, "statusName": "Open", "settingApplyOn": 1, "isEnableForReviewComment": false, "projectId": "2130192\$\$i5DqWs", "fontColor": "#000000"},
          "observationId": 107704,
          "formTypeName": "Site Tasks",
          "statusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "formId": "11622489\$\$7Hdyy5",
          "hasOverallStatus": false,
          "orgName": "Asite Solutions Ltd",
          "msgOriginatorId": 2017529,
          "formTypeId": "11103151\$\$Cje8bs",
          "folderId": "0\$\$i02Uqc",
          "firstName": "Mayur",
          "lastmodified": "2023-07-31T10:12:59Z",
          "formPrintEnabled": false,
          "project_APD_folder_id": "0\$\$i02Uqc",
          "projectName": "Site Quality Demo",
          "formNum": 399,
          "projectId": "2130192\$\$i5DqWs",
          "updated": "31-Jul-2023#04:12 CST",
          "messageTypeImageName": "icons/form.png",
          "code": "SITE399",
          "indent": -1,
          "statusUpdateDate": "31-Jul-2023#04:12 CST",
          "originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "title": "Test Offlinr VJ",
          "flagTypeImageName": "flag_type/flag_0.png",
          "ownerOrgName": "Asite Solutions",
          "dcId": 1,
          "formCreationDateInMS": 1690794779000,
          "isPublic": false,
          "projectStatusId": 5,
          "updatedDateInMS": 1690794779000,
          "statusChangeUserName": "Mayur Raval m.",
          "showPrintIcon": 0,
          "invoiceColourCode": "-1",
          "msgCreatedDateInMS": 0,
          "flagType": 0,
          "hasFormAssocations": false,
          "hasCommentAssocations": false,
          "statusChangeUserEmail": "m.raval@asite.com",
          "statusChangeUserOrg": "Asite Solutions Ltd",
          "msgTypeId": 1,
          "isStatusChangeRestricted": false,
          "formUserSet": [],
          "statusText": "Open",
          "typeImage": "icons/form.png",
          "attachmentImageName": ""
        },
        "viewFormJson": "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"DistributionDays\":\"0\",\"Organization\":\"\",\"DefectTyoe\":\"Computer\",\"ExpectedFinishDate\":\"2023-08-07\",\"DefectDescription\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"707447#Vijay Mavadiya (5336), Asite Solutions\"}},\"Defect_Description\":\"test description\",\"LocationName\":\"01 Vijay_Test\",\"StartDate\":\"2023-07-31\",\"ActualFinishDate\":\"\",\"ExpectedFinishDays\":\"5\",\"DS_Logo\":\"images/asite.gif\",\"LastResponder_For_AssignedTo\":\"707447\",\"TaskType\":\"Defect\",\"isCalibrated\":true,\"ORI_FORMTITLE\":\"Test Offlinr VJ\",\"attachements\":[{\"attachedDocs\":\"\"}],\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"Assigned\":\"Vijay Mavadiya (5336), Asite Solutions\",\"CurrStage\":\"1\",\"Recent_Defects\":\"\",\"FormCreationDate\":\"\",\"StartDateDisplay\":\"31-Jul-2023\",\"LastResponder_For_Originator\":\"2017529\",\"PF_Location_Detail\":\"183678|0|null|0\",\"Username\":\"\",\"ORI_USERREF\":\"\",\"Location\":\"183678|01 Vijay_Test|01 Vijay_Test\"},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"SHResponse\":\"Yes\",\"ShowHideFlag\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_CREATE\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\",\"DS_FORMAUTONO_ADD\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_Get_All_Responses\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"attachments\":[],\"Asite_System_Data_Read_Only\":{\"_2_Printing_Data\":{\"DS_PRINTEDON\":\"\",\"DS_PRINTEDBY\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\",\"DS_FORMNAME\":\"Site Tasks\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_5_Form_Data\":{\"DS_DATEOFISSUE\":\"\",\"DS_ISDRAFT_RES_MSG\":\"NO\",\"Status_Data\":{\"DS_APPROVEDON\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_APPROVEDBY\":\"\",\"DS_CLOSE_DUE_DATE\":\"2023-08-07\",\"DS_FORMSTATUS\":\"\"},\"DS_DISTRIBUTION\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT_RES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_FORMID\":\"\"},\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_6_Form_MSG_Data\":{\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGID\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_PROJUSERS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_ACTIONDUEDATE\":\"5\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_PROJDISTUSERS\":\"707447\"}]}},\"selectedControllerUserId\":\"\"}}",
        "offlineFormId": "1690785287567"
      };
      when(() => mockUseCase!.saveFormToServer(any()))
          .thenAnswer((_) => Future.value(SUCCESS(saveFormResult, null, 200)));

      final formDetailResult = {
        "11622489": {
          "combinedAttachAssocList": "",
          "messages": [
            {
              "projectId": "2130192\$\$i5DqWs",
              "projectName": "Site Quality Demo",
              "code": "SITE399",
              "commId": "11622489\$\$wMy9Is",
              "formId": "11622489\$\$7Hdyy5",
              "title": "Test Offlinr VJ",
              "userID": "2017529\$\$WQWzza",
              "orgId": "5763307\$\$OrOFEZ",
              "firstName": "Mayur",
              "lastName": "Raval m.",
              "orgName": "Asite Solutions Ltd",
              "originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
              "originatorDisplayName": "Mayur Raval m., Asite Solutions Ltd",
              "actions": [],
              "allActions": [],
              "noOfActions": 0,
              "observationId": 107704,
              "locationId": 183678,
              "pfLocFolderId": 0,
              "updated": "2023-07-31T10:12:59Z",
              "duration": "9 mins ago",
              "hasAttachments": false,
              "msgCode": "ORI001",
              "docType": "Apps",
              "formTypeName": "Site Tasks",
              "userRefCode": "N/A",
              "status": "Open",
              "responseRequestBy": "07-Aug-2023#23:59 CST",
              "controllerName": "N/A",
              "hasDocAssocations": false,
              "hasBimViewAssociations": false,
              "hasBimListAssociations": false,
              "hasFormAssocations": false,
              "hasCommentAssocations": false,
              "formHasAssocAttach": false,
              "msgHasAssocAttach": false,
              "formCreationDate": "2023-07-31T10:12:59Z",
              "msgCreatedDate": "31-Jul-2023#04:12 CST",
              "folderId": "0\$\$i02Uqc",
              "msgId": "12329329\$\$ZvNboh",
              "parentMsgId": 0,
              "msgTypeId": 1,
              "msgStatusId": 20,
              "msgStatusName": "Sent",
              "indent": -1,
              "formTypeId": "11103151\$\$Cje8bs",
              "formNum": 399,
              "msgOriginatorId": 2017529,
              "hashedMsgOriginatorId": "2017529\$\$WQWzza",
              "formPrintEnabled": true,
              "showPrintIcon": 1,
              "sentNames": ["Vijay Mavadiya (5336), Asite Solutions"],
              "templateType": 2,
              "instanceGroupId": "10940318\$\$Z3lWz4",
              "noOfMessages": 0,
              "isDraft": false,
              "dcId": 1,
              "statusid": 1001,
              "originatorId": 2017529,
              "isCloseOut": false,
              "isStatusChangeRestricted": false,
              "project_APD_folder_id": "110997340\$\$u6qFCB",
              "allowReopenForm": true,
              "hasOverallStatus": true,
              "formUserSet": [],
              "canOrigChangeStatus": false,
              "canControllerChangeStatus": false,
              "appType": "2",
              "msgTypeCode": "ORI",
              "formGroupName": "Site Tasks",
              "id": "SITE399",
              "statusText": "Open",
              "statusChangeUserId": 0,
              "originatorEmail": "m.raval@asite.com",
              "statusRecordStyle": {"settingApplyOn": 1, "fontType": "PT Sans", "fontEffect": "0#0#0#0", "fontColor": "#000000", "backgroundColor": "#e03ae0", "isForOnlyStyleUpdate": false, "always_active": false, "userId": 0, "isDeactive": false, "defaultPermissionId": 0, "statusName": "Open", "statusID": 1001, "statusTypeID": 1, "projectId": "2130192\$\$i5DqWs", "orgId": "0\$\$kVxfxX", "proxyUserId": 0, "isEnableForReviewComment": false, "generateURI": true},
              "invoiceCountAgainstOrder": "-1",
              "invoiceColourCode": "-1",
              "controllerUserId": 0,
              "offlineFormId": "1690785287567",
              "customFieldsValueVOs": {},
              "updatedDateInMS": 1690794779000,
              "formCreationDateInMS": 1690794779000,
              "msgCreatedDateInMS": 1690794779000,
              "flagType": 0,
              "latestDraftId": "0\$\$NQLyUb",
              "hasFormAccess": false,
              "jsonData": "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"DistributionDays\":\"0\",\"Organization\":\"\",\"DefectTyoe\":\"Computer\",\"ExpectedFinishDate\":\"2023-08-07\",\"DefectDescription\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"707447#Vijay Mavadiya (5336), Asite Solutions\"}},\"Defect_Description\":\"test description\",\"LocationName\":\"01 Vijay_Test\",\"StartDate\":\"2023-07-31\",\"ActualFinishDate\":\"\",\"ExpectedFinishDays\":\"5\",\"DS_Logo\":\"images/asite.gif\",\"LastResponder_For_AssignedTo\":\"707447\",\"TaskType\":\"Defect\",\"isCalibrated\":true,\"ORI_FORMTITLE\":\"Test Offlinr VJ\",\"attachements\":[{\"attachedDocs\":\"\"}],\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"Assigned\":\"Vijay Mavadiya (5336), Asite Solutions\",\"CurrStage\":\"1\",\"Recent_Defects\":\"\",\"FormCreationDate\":\"\",\"StartDateDisplay\":\"31-Jul-2023\",\"LastResponder_For_Originator\":\"2017529\",\"PF_Location_Detail\":\"183678|0|null|0\",\"Username\":\"\",\"ORI_USERREF\":\"\",\"Location\":\"183678|01 Vijay_Test|01 Vijay_Test\"},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"SHResponse\":\"Yes\",\"ShowHideFlag\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_CREATE\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\",\"DS_FORMAUTONO_ADD\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_Get_All_Responses\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"attachments\":[],\"Asite_System_Data_Read_Only\":{\"_2_Printing_Data\":{\"DS_PRINTEDON\":\"\",\"DS_PRINTEDBY\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\",\"DS_FORMNAME\":\"Site Tasks\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_5_Form_Data\":{\"DS_DATEOFISSUE\":\"\",\"DS_ISDRAFT_RES_MSG\":\"NO\",\"Status_Data\":{\"DS_APPROVEDON\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_APPROVEDBY\":\"\",\"DS_CLOSE_DUE_DATE\":\"2023-08-07\",\"DS_FORMSTATUS\":\"\"},\"DS_DISTRIBUTION\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT_RES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_FORMID\":\"\"},\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_6_Form_MSG_Data\":{\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGID\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_PROJUSERS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_ACTIONDUEDATE\":\"5\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_PROJDISTUSERS\":\"707447\"}]}},\"selectedControllerUserId\":\"\"}}",
              "formPermissions": {"can_edit_ORI": false, "can_respond": false, "restrictChangeFormStatus": false, "controllerUserId": 0, "isProjectArchived": false, "can_distribute": false, "can_forward": false, "oriMsgId": "12329329\$\$ZvNboh"},
              "sentActions": [
                {
                  "projectId": "0\$\$eOptjB",
                  "resourceParentId": 11622489,
                  "resourceId": 12329329,
                  "resourceCode": "ORI001",
                  "resourceStatusId": 0,
                  "msgId": "12329329\$\$ZvNboh",
                  "commentMsgId": "12329329\$\$eYZaPQ",
                  "actionId": 3,
                  "actionName": "Respond",
                  "actionStatus": 0,
                  "priorityId": 0,
                  "actionDate": "Mon Jul 31 11:12:59 BST 2023",
                  "dueDate": "Tue Aug 08 06:59:59 BST 2023",
                  "distributorUserId": 2017529,
                  "recipientId": 707447,
                  "remarks": "",
                  "distListId": 13737770,
                  "transNum": "-1",
                  "actionTime": "7 Days",
                  "actionCompleteDate": "",
                  "instantEmailNotify": "true",
                  "actionNotes": "",
                  "entityType": 0,
                  "instanceGroupId": "0\$\$FPUasW",
                  "isActive": true,
                  "modelId": "0\$\$stjQAs",
                  "assignedBy": "Mayur Raval m.,Asite Solutions Ltd",
                  "recipientName": "Vijay Mavadiya (5336), Asite Solutions",
                  "recipientOrgId": "3",
                  "id": "ACTC13737770_707447_3_1_12329329_11622489",
                  "viewDate": "",
                  "assignedByOrgName": "Asite Solutions Ltd",
                  "distributionLevel": 0,
                  "distributionLevelId": "0\$\$o7Lr5i",
                  "dueDateInMS": 1691474399000,
                  "actionCompleteDateInMS": 0,
                  "actionDelegated": false,
                  "actionCleared": false,
                  "actionCompleted": false,
                  "assignedByEmail": "m.raval@asite.com",
                  "assignedByRole": "",
                  "generateURI": true
                }
              ],
              "fixedFormData": {
                "DS_ALL_ACTIVE_FORM_STATUS": "{\"Items\":{\"Item\":[{\"Value\":\"23 # Deactivated\",\"Name\":\"Deactivated\"},{\"Value\":\"1001 # Open\",\"Name\":\"Open\"},{\"Value\":\"1002 # Resolved\",\"Name\":\"Resolved\"},{\"Value\":\"1003 # Verified\",\"Name\":\"Verified\"}]}}",
                "DS_WORKINGUSER_ID": "{\"Items\":{\"Item\":[{\"Value\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"Name\":\"Mayur Raval m., Asite Solutions Ltd\"}]}}",
                "DS_ORIGINATOR": "Mayur Raval m., Asite Solutions Ltd",
                "DS_MSGCREATOR": "Mayur Raval m., Asite Solutions Ltd",
                "DS_INCOMPLETE_ACTIONS": "{\"Items\":{\"Item\":[{\"Value\":\"|707447| # Respond\",\"Name\":\"Respond\"}]}}",
                "DS_ISDRAFT": "NO",
                "DS_ISDRAFT_FWD_MSG": "NO",
                "DS_MSGDATE": "2023-07-31 10:12:59",
                "DS_PROJDISTUSERS": "{\"Items\":{\"Item\":[{\"Value\":\"1161363#Chandresh Patel, Asite Solutions\",\"Name\":\"Chandresh Patel, Asite Solutions\"},{\"Value\":\"514806#Dhaval Vekaria (5226), Asite Solutions\",\"Name\":\"Dhaval Vekaria (5226), Asite Solutions\"},{\"Value\":\"859155#Saurabh Banethia (5327), Asite Solutions\",\"Name\":\"Saurabh Banethia (5327), Asite Solutions\"},{\"Value\":\"650044#savita dangee (5231), Asite Solutions\",\"Name\":\"savita dangee (5231), Asite Solutions\"},{\"Value\":\"707447#Vijay Mavadiya (5336), Asite Solutions\",\"Name\":\"Vijay Mavadiya (5336), Asite Solutions\"},{\"Value\":\"2017529#Mayur Raval m., Asite Solutions Ltd\",\"Name\":\"Mayur Raval m., Asite Solutions Ltd\"}]}}",
                "DS_FORMID": "SITE399",
                "DS_ALL_FORMSTATUS": "{\"Items\":{\"Item\":[{\"Value\":\"1001 # Open\",\"Name\":\"Open\"},{\"Value\":\"1002 # Resolved\",\"Name\":\"Resolved\"},{\"Value\":\"1003 # Verified\",\"Name\":\"Verified\"}]}}",
                "comboList": "DS_ALL_FORMSTATUS,DS_WORKINGUSER_ID,DS_ALL_ACTIVE_FORM_STATUS,DS_INCOMPLETE_ACTIONS,DS_Get_All_Responses,DS_PROJDISTUSERS,DS_CHECK_FORM_PERMISSION_USER,DS_ASI_SITE_getDefectTypesForProjects_pf",
                "DS_Get_All_Responses": "{\"Items\":{\"Item\":[]}}",
                "DS_ASI_SITE_getDefectTypesForProjects_pf": "{\"Items\":{\"Item\":[{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Architectural\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Civil\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Computer\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"EC\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Electrical\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Fire Safety\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Mechanical\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"}]}}",
                "DS_ISDRAFT_EDITORI": "NO",
                "DS_PROJECTNAME": "Site Quality Demo",
                "DS_FORMSTATUS": "Open",
                "DS_WORKINGUSER": "Mayur Raval m., Asite Solutions Ltd",
                "DS_FORMNAME": "Site Tasks",
                "DS_DATEOFISSUE": "2023-07-31 10:12:59",
                "DS_CHECK_FORM_PERMISSION_USER": "{\"Items\":{\"Item\":[{\"Value3\":\"All_Org\",\"Value4\":\"Yes\",\"Value1\":\"2130192\",\"Value2\":\"2017529\",\"Name\":\"DS_MTA_CHECK_FORM_PERMISSION_USER\"}]}}"
              },
              "ownerOrgName": "Asite Solutions",
              "ownerOrgId": 3,
              "originatorOrgId": 5763307,
              "msgUserOrgId": 5763307,
              "msgUserOrgName": "Asite Solutions Ltd",
              "msgUserName": "Mayur Raval m.",
              "originatorName": "Mayur Raval m.",
              "isPublic": false,
              "responseRequestByInMS": 0,
              "actionDateInMS": 0,
              "formGroupCode": "SITE",
              "isThumbnailSupports": false,
              "canAccessHistory": false,
              "projectStatusId": 5,
              "generateURI": true
            }
          ]
        }
      };
      when(() => mockProjectUseCase!.getFormMessageBatchList(any()))
          .thenAnswer((_) => Future.value(SUCCESS(formDetailResult, null, 200)));

      String removeFormQuery = "DELETE FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=1690785287567";
      when(() => mockDb!.executeQuery(removeFormQuery))
          .thenReturn(null);

      String removeFormMsgQuery = "DELETE FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=1690785287567";
      when(() => mockDb!.executeQuery(removeFormMsgQuery))
          .thenReturn(null);

      String removeFormMsgActQuery = "DELETE FROM FormMsgActionListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=1690785287567";
      when(() => mockDb!.executeQuery(removeFormMsgActQuery))
          .thenReturn(null);

      String removeFormMsgAttachQuery = "DELETE FROM FormMsgAttachAndAssocListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=1690785287567";
      when(() => mockDb!.executeQuery(removeFormMsgAttachQuery))
          .thenReturn(null);
      //Below changes for Form DAO mock
      String formTableName = "FormListTbl";
      String formTableQuery = "CREATE TABLE IF NOT EXISTS FormListTbl(ProjectId INTEGER NOT NULL,FormId TEXT NOT NULL,AppTypeId INTEGER,FormTypeId INTEGER,InstanceGroupId INTEGER NOT NULL,FormTitle TEXT,Code TEXT,CommentId INTEGER,MessageId INTEGER,ParentMessageId INTEGER,OrgId INTEGER,FirstName TEXT,LastName TEXT,OrgName TEXT,Originator TEXT,OriginatorDisplayName TEXT,NoOfActions INTEGER,ObservationId INTEGER,LocationId INTEGER,PfLocFolderId INTEGER,Updated TEXT,AttachmentImageName TEXT,MsgCode TEXT,TypeImage TEXT,DocType TEXT,HasAttachments INTEGER NOT NULL DEFAULT 0,HasDocAssocations INTEGER NOT NULL DEFAULT 0,HasBimViewAssociations INTEGER NOT NULL DEFAULT 0,HasFormAssocations INTEGER NOT NULL DEFAULT 0,HasCommentAssocations INTEGER NOT NULL DEFAULT 0,FormHasAssocAttach INTEGER NOT NULL DEFAULT 0,FormCreationDate TEXT,FolderId INTEGER,MsgTypeId INTEGER,MsgStatusId INTEGER,FormNumber INTEGER,MsgOriginatorId INTEGER,TemplateType INTEGER,IsDraft INTEGER NOT NULL DEFAULT 0,StatusId INTEGER,OriginatorId INTEGER,IsStatusChangeRestricted INTEGER NOT NULL DEFAULT 0,AllowReopenForm INTEGER NOT NULL DEFAULT 0,CanOrigChangeStatus INTEGER NOT NULL DEFAULT 0,MsgTypeCode TEXT,Id TEXT,StatusChangeUserId INTEGER,StatusUpdateDate TEXT,StatusChangeUserName TEXT,StatusChangeUserPic TEXT,StatusChangeUserEmail TEXT,StatusChangeUserOrg TEXT,OriginatorEmail TEXT,ControllerUserId INTEGER,UpdatedDateInMS INTEGER,FormCreationDateInMS INTEGER,ResponseRequestByInMS INTEGER,FlagType INTEGER,LatestDraftId INTEGER,FlagTypeImageName TEXT,MessageTypeImageName TEXT,CanAccessHistory INTEGER NOT NULL DEFAULT 0,FormJsonData TEXT,Status TEXT,AttachedDocs TEXT,IsUploadAttachmentInTemp INTEGER NOT NULL DEFAULT 0,IsSync INTEGER NOT NULL DEFAULT 0,UserRefCode TEXT,HasActions INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,IsOfflineCreated INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,IsForDefect INTEGER NOT NULL DEFAULT 0,IsForApps INTEGER NOT NULL DEFAULT 0,ObservationDefectTypeId TEXT NOT NULL DEFAULT '0',StartDate TEXT NOT NULL,ExpectedFinishDate TEXT NOT NULL,IsActive INTEGER NOT NULL DEFAULT 0,ObservationCoordinates TEXT,AnnotationId TEXT,IsCloseOut INTEGER NOT NULL DEFAULT 0,AssignedToUserId INTEGER NOT NULL,AssignedToUserName TEXT,AssignedToUserOrgName TEXT,MsgNum INTEGER,RevisionId INTEGER,RequestJsonForOffline TEXT,FormDueDays TEXT NOT NULL DEFAULT 0,FormSyncDate TEXT NOT NULL DEFAULT 0,LastResponderForAssignedTo TEXT NOT NULL DEFAULT '',LastResponderForOriginator TEXT NOT NULL DEFAULT '',PageNumber TEXT NOT NULL DEFAULT 0,ObservationDefectType TEXT,StatusName TEXT,AppBuilderId TEXT,TaskTypeName TEXT,AssignedToRoleName TEXT,PRIMARY KEY(ProjectId,FormId))";
      when(() => mockDb!.executeQuery(formTableQuery))
          .thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(formTableName))
          .thenReturn(["ProjectId", "FormId"]);
      String formSelectQuery = "SELECT ProjectId FROM FormListTbl WHERE ProjectId='2130192' AND FormId='11622489'";
      when(() => mockDb!.selectFromTable(formTableName, formSelectQuery))
          .thenReturn(ResultSet([], null, []));
      String frmBulkInsertQuery = "INSERT INTO FormListTbl (ProjectId,FormId,AppTypeId,FormTypeId,InstanceGroupId,FormTitle,Code,CommentId,MessageId,ParentMessageId,OrgId,FirstName,LastName,OrgName,Originator,OriginatorDisplayName,NoOfActions,ObservationId,LocationId,PfLocFolderId,Updated,AttachmentImageName,MsgCode,TypeImage,DocType,HasAttachments,HasDocAssocations,HasBimViewAssociations,HasFormAssocations,HasCommentAssocations,FormHasAssocAttach,FormCreationDate,FolderId,MsgTypeId,MsgStatusId,FormNumber,MsgOriginatorId,TemplateType,IsDraft,StatusId,OriginatorId,IsStatusChangeRestricted,AllowReopenForm,CanOrigChangeStatus,MsgTypeCode,Id,StatusChangeUserId,StatusUpdateDate,StatusChangeUserName,StatusChangeUserPic,StatusChangeUserEmail,StatusChangeUserOrg,OriginatorEmail,ControllerUserId,UpdatedDateInMS,FormCreationDateInMS,ResponseRequestByInMS,FlagType,LatestDraftId,FlagTypeImageName,MessageTypeImageName,CanAccessHistory,FormJsonData,Status,AttachedDocs,IsUploadAttachmentInTemp,IsSync,UserRefCode,HasActions,CanRemoveOffline,IsMarkOffline,IsOfflineCreated,SyncStatus,IsForDefect,IsForApps,ObservationDefectTypeId,StartDate,ExpectedFinishDate,IsActive,ObservationCoordinates,AnnotationId,IsCloseOut,AssignedToUserId,AssignedToUserName,AssignedToUserOrgName,MsgNum,RevisionId,RequestJsonForOffline,FormDueDays,FormSyncDate,LastResponderForAssignedTo,LastResponderForOriginator,PageNumber,ObservationDefectType,StatusName,AppBuilderId,TaskTypeName,AssignedToRoleName) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      final frmValueList = [
        [
          "2130192",
          "11622489",
          "2",
          "11103151",
          "10940318",
          "Test Offlinr VJ",
          "SITE399",
          "11622489",
          "12329329",
          "0",
          "5763307",
          "Mayur",
          "Raval m.",
          "Asite Solutions Ltd",
          "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "Mayur Raval m., Asite Solutions Ltd",
          "0",
          "107704",
          "183678",
          "115096348",
          "31-Jul-2023#04:12 CST",
          "",
          "ORI001",
          "icons/form.png",
          "Apps",
          0,
          0,
          0,
          0,
          0,
          0,
          "31-Jul-2023#04:12 CST",
          "0",
          "1",
          "20",
          "399",
          "2017529",
          "2",
          0,
          "1001",
          "2017529",
          0,
          0,
          0,
          "ORI",
          "",
          "0",
          "31-Jul-2023#04:12 CST",
          "Mayur Raval m.",
          "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "m.raval@asite.com",
          "Asite Solutions Ltd",
          "m.raval@asite.com",
          "0",
          "1690794779000",
          "1690794779000",
          "1691470799000",
          "0",
          "0",
          "flag_type/flag_0.png",
          "icons/form.png",
          1,
          "",
          "Open",
          "",
          0,
          0,
          "",
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          "310493",
          "2023-07-31",
          "2023-08-07",
          1,
          "{}",
          "61c6ef9a-19e0-4088-a6ee-b39f831db26e-1690785287551",
          0,
          "707447",
          "Vijay Mavadiya (5336)",
          "Asite Solutions",
          "",
          "",
          "",
          "5",
          "2023-07-31 10:12:59.157",
          "707447",
          "2017529",
          "1",
          "",
          "Open",
          "ASI-SITE",
          "",
          ""
        ]
      ];
      when(() => mockDb!.executeBulk(formTableName, frmBulkInsertQuery, frmValueList))
          .thenAnswer((_) async=> null);

      //Below changes for FormMessage DAO mock
      String frmMsgTableName = "FormMessageListTbl";
      String frmMsgTableQuery = "CREATE TABLE IF NOT EXISTS FormMessageListTbl(ProjectId TEXT NOT NULL,FormTypeId TEXT NOT NULL,FormId TEXT NOT NULL,MsgId TEXT NOT NULL,Originator TEXT,OriginatorDisplayName TEXT,MsgCode TEXT,MsgCreatedDate TEXT,ParentMsgId TEXT,MsgOriginatorId TEXT,MsgHasAssocAttach INTEGER NOT NULL DEFAULT 0,JsonData TEXT,UserRefCode TEXT,UpdatedDateInMS TEXT,FormCreationDateInMS TEXT,MsgCreatedDateInMS TEXT,MsgTypeId TEXT,MsgTypeCode TEXT,MsgStatusId TEXT,SentNames TEXT,SentActions TEXT,DraftSentActions TEXT,FixFieldData TEXT,FolderId TEXT,LatestDraftId TEXT,IsDraft INTEGER NOT NULL DEFAULT 0,AssocRevIds TEXT,ResponseRequestBy TEXT,DelFormIds TEXT,AssocFormIds TEXT,AssocCommIds TEXT,FormUserSet TEXT,FormPermissionsMap TEXT,CanOrigChangeStatus INTEGER NOT NULL DEFAULT 0,CanControllerChangeStatus INTEGER NOT NULL DEFAULT 0,IsStatusChangeRestricted INTEGER NOT NULL DEFAULT 0,HasOverallStatus INTEGER NOT NULL DEFAULT 0,IsCloseOut INTEGER NOT NULL DEFAULT 0,AllowReopenForm INTEGER NOT NULL DEFAULT 0,OfflineRequestData TEXT NOT NULL DEFAULT \"\",IsOfflineCreated INTEGER NOT NULL DEFAULT 0,LocationId INTEGER,ObservationId INTEGER,MsgNum INTEGER,MsgContent TEXT,ActionComplete INTEGER NOT NULL DEFAULT 0,ActionCleared INTEGER NOT NULL DEFAULT 0,HasAttach INTEGER NOT NULL DEFAULT 0,TotalActions INTEGER,InstanceGroupId INTEGER,AttachFiles TEXT,HasViewAccess INTEGER NOT NULL DEFAULT 0,MsgOriginImage TEXT,IsForInfoIncomplete INTEGER NOT NULL DEFAULT 0,MsgCreatedDateOffline TEXT,LastModifiedTime TEXT,LastModifiedTimeInMS TEXT,CanViewDraftMsg INTEGER NOT NULL DEFAULT 0,CanViewOwnorgPrivateForms INTEGER NOT NULL DEFAULT 0,IsAutoSavedDraft INTEGER NOT NULL DEFAULT 0,MsgStatusName TEXT,ProjectAPDFolderId TEXT,ProjectStatusId TEXT,HasFormAccess INTEGER NOT NULL DEFAULT 0,CanAccessHistory INTEGER NOT NULL DEFAULT 0,HasDocAssocations INTEGER NOT NULL DEFAULT 0,HasBimViewAssociations INTEGER NOT NULL DEFAULT 0,HasBimListAssociations INTEGER NOT NULL DEFAULT 0,HasFormAssocations INTEGER NOT NULL DEFAULT 0,HasCommentAssocations INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId,FormId,MsgId))";
      when(() => mockDb!.executeQuery(frmMsgTableQuery))
          .thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(frmMsgTableName))
          .thenReturn(["ProjectId", "FormId", "MsgId"]);
      String frmMsgSelectQuery = "SELECT ProjectId FROM FormMessageListTbl WHERE ProjectId='2130192' AND FormId='11622489' AND MsgId='12329329'";
      when(() => mockDb!.selectFromTable(frmMsgTableName, frmMsgSelectQuery))
          .thenReturn(ResultSet([], null, []));
      String frmMsgBulkInsertQuery = "INSERT INTO FormMessageListTbl (ProjectId,FormTypeId,FormId,MsgId,Originator,OriginatorDisplayName,MsgCode,MsgCreatedDate,ParentMsgId,MsgOriginatorId,MsgHasAssocAttach,JsonData,UserRefCode,UpdatedDateInMS,FormCreationDateInMS,MsgCreatedDateInMS,MsgTypeId,MsgTypeCode,MsgStatusId,SentNames,SentActions,DraftSentActions,FixFieldData,FolderId,LatestDraftId,IsDraft,AssocRevIds,ResponseRequestBy,DelFormIds,AssocFormIds,AssocCommIds,FormUserSet,FormPermissionsMap,CanOrigChangeStatus,CanControllerChangeStatus,IsStatusChangeRestricted,HasOverallStatus,IsCloseOut,AllowReopenForm,OfflineRequestData,IsOfflineCreated,LocationId,ObservationId,MsgNum,MsgContent,ActionComplete,ActionCleared,HasAttach,TotalActions,InstanceGroupId,AttachFiles,HasViewAccess,MsgOriginImage,IsForInfoIncomplete,MsgCreatedDateOffline,LastModifiedTime,LastModifiedTimeInMS,CanViewDraftMsg,CanViewOwnorgPrivateForms,IsAutoSavedDraft,MsgStatusName,ProjectAPDFolderId,ProjectStatusId,HasFormAccess,CanAccessHistory,HasDocAssocations,HasBimViewAssociations,HasBimListAssociations,HasFormAssocations,HasCommentAssocations) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      final frmMsgValueList = [
        [
          "2130192",
          "11103151",
          "11622489",
          "12329329",
          "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "Mayur Raval m., Asite Solutions Ltd",
          "ORI001",
          "31-Jul-2023#04:12 CST",
          "0",
          "2017529",
          0,
          "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"DistributionDays\":\"0\",\"Organization\":\"\",\"DefectTyoe\":\"Computer\",\"ExpectedFinishDate\":\"2023-08-07\",\"DefectDescription\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"707447#Vijay Mavadiya (5336), Asite Solutions\"}},\"Defect_Description\":\"test description\",\"LocationName\":\"01 Vijay_Test\",\"StartDate\":\"2023-07-31\",\"ActualFinishDate\":\"\",\"ExpectedFinishDays\":\"5\",\"DS_Logo\":\"images/asite.gif\",\"LastResponder_For_AssignedTo\":\"707447\",\"TaskType\":\"Defect\",\"isCalibrated\":true,\"ORI_FORMTITLE\":\"Test Offlinr VJ\",\"attachements\":[{\"attachedDocs\":\"\"}],\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"Assigned\":\"Vijay Mavadiya (5336), Asite Solutions\",\"CurrStage\":\"1\",\"Recent_Defects\":\"\",\"FormCreationDate\":\"\",\"StartDateDisplay\":\"31-Jul-2023\",\"LastResponder_For_Originator\":\"2017529\",\"PF_Location_Detail\":\"183678|0|null|0\",\"Username\":\"\",\"ORI_USERREF\":\"\",\"Location\":\"183678|01 Vijay_Test|01 Vijay_Test\"},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"SHResponse\":\"Yes\",\"ShowHideFlag\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_CREATE\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\",\"DS_FORMAUTONO_ADD\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_Get_All_Responses\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"attachments\":[],\"Asite_System_Data_Read_Only\":{\"_2_Printing_Data\":{\"DS_PRINTEDON\":\"\",\"DS_PRINTEDBY\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\",\"DS_FORMNAME\":\"Site Tasks\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_5_Form_Data\":{\"DS_DATEOFISSUE\":\"\",\"DS_ISDRAFT_RES_MSG\":\"NO\",\"Status_Data\":{\"DS_APPROVEDON\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_APPROVEDBY\":\"\",\"DS_CLOSE_DUE_DATE\":\"2023-08-07\",\"DS_FORMSTATUS\":\"\"},\"DS_DISTRIBUTION\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT_RES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_FORMID\":\"\"},\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_6_Form_MSG_Data\":{\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGID\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_PROJUSERS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_ACTIONDUEDATE\":\"5\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_PROJDISTUSERS\":\"707447\"}]}},\"selectedControllerUserId\":\"\"}}",
          "N/A",
          "1690794779000",
          "1690794779000",
          "1690794779000",
          "1",
          "ORI",
          "20",
          "[\"Vijay Mavadiya (5336), Asite Solutions\"]",
          "[{\"projectId\":\"0\$\$eOptjB\",\"resourceParentId\":11622489,\"resourceId\":12329329,\"resourceCode\":\"ORI001\",\"resourceStatusId\":0,\"msgId\":\"12329329\$\$ZvNboh\",\"commentMsgId\":\"12329329\$\$eYZaPQ\",\"actionId\":3,\"actionName\":\"Respond\",\"actionStatus\":0,\"priorityId\":0,\"actionDate\":\"Mon Jul 31 11:12:59 BST 2023\",\"dueDate\":\"Tue Aug 08 06:59:59 BST 2023\",\"distributorUserId\":2017529,\"recipientId\":707447,\"remarks\":\"\",\"distListId\":13737770,\"transNum\":\"-1\",\"actionTime\":\"7 Days\",\"actionCompleteDate\":\"\",\"instantEmailNotify\":\"true\",\"actionNotes\":\"\",\"entityType\":0,\"instanceGroupId\":\"0\$\$FPUasW\",\"isActive\":true,\"modelId\":\"0\$\$stjQAs\",\"assignedBy\":\"Mayur Raval m.,Asite Solutions Ltd\",\"recipientName\":\"Vijay Mavadiya (5336), Asite Solutions\",\"recipientOrgId\":\"3\",\"id\":\"ACTC13737770_707447_3_1_12329329_11622489\",\"viewDate\":\"\",\"assignedByOrgName\":\"Asite Solutions Ltd\",\"distributionLevel\":0,\"distributionLevelId\":\"0\$\$o7Lr5i\",\"dueDateInMS\":1691474399000,\"actionCompleteDateInMS\":0,\"actionDelegated\":false,\"actionCleared\":false,\"actionCompleted\":false,\"assignedByEmail\":\"m.raval@asite.com\",\"assignedByRole\":\"\",\"generateURI\":true}]",
          "",
          "{\"DS_ALL_ACTIVE_FORM_STATUS\":\"{\\\"Items\\\":{\\\"Item\\\":[{\\\"Value\\\":\\\"23 # Deactivated\\\",\\\"Name\\\":\\\"Deactivated\\\"},{\\\"Value\\\":\\\"1001 # Open\\\",\\\"Name\\\":\\\"Open\\\"},{\\\"Value\\\":\\\"1002 # Resolved\\\",\\\"Name\\\":\\\"Resolved\\\"},{\\\"Value\\\":\\\"1003 # Verified\\\",\\\"Name\\\":\\\"Verified\\\"}]}}\",\"DS_WORKINGUSER_ID\":\"{\\\"Items\\\":{\\\"Item\\\":[{\\\"Value\\\":\\\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\\\",\\\"Name\\\":\\\"Mayur Raval m., Asite Solutions Ltd\\\"}]}}\",\"DS_ORIGINATOR\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_MSGCREATOR\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_INCOMPLETE_ACTIONS\":\"{\\\"Items\\\":{\\\"Item\\\":[{\\\"Value\\\":\\\"|707447| # Respond\\\",\\\"Name\\\":\\\"Respond\\\"}]}}\",\"DS_ISDRAFT\":\"NO\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_MSGDATE\":\"2023-07-31 10:12:59\",\"DS_PROJDISTUSERS\":\"{\\\"Items\\\":{\\\"Item\\\":[{\\\"Value\\\":\\\"1161363#Chandresh Patel, Asite Solutions\\\",\\\"Name\\\":\\\"Chandresh Patel, Asite Solutions\\\"},{\\\"Value\\\":\\\"514806#Dhaval Vekaria (5226), Asite Solutions\\\",\\\"Name\\\":\\\"Dhaval Vekaria (5226), Asite Solutions\\\"},{\\\"Value\\\":\\\"859155#Saurabh Banethia (5327), Asite Solutions\\\",\\\"Name\\\":\\\"Saurabh Banethia (5327), Asite Solutions\\\"},{\\\"Value\\\":\\\"650044#savita dangee (5231), Asite Solutions\\\",\\\"Name\\\":\\\"savita dangee (5231), Asite Solutions\\\"},{\\\"Value\\\":\\\"707447#Vijay Mavadiya (5336), Asite Solutions\\\",\\\"Name\\\":\\\"Vijay Mavadiya (5336), Asite Solutions\\\"},{\\\"Value\\\":\\\"2017529#Mayur Raval m., Asite Solutions Ltd\\\",\\\"Name\\\":\\\"Mayur Raval m., Asite Solutions Ltd\\\"}]}}\",\"DS_FORMID\":\"SITE399\",\"DS_ALL_FORMSTATUS\":\"{\\\"Items\\\":{\\\"Item\\\":[{\\\"Value\\\":\\\"1001 # Open\\\",\\\"Name\\\":\\\"Open\\\"},{\\\"Value\\\":\\\"1002 # Resolved\\\",\\\"Name\\\":\\\"Resolved\\\"},{\\\"Value\\\":\\\"1003 # Verified\\\",\\\"Name\\\":\\\"Verified\\\"}]}}\",\"comboList\":\"DS_ALL_FORMSTATUS,DS_WORKINGUSER_ID,DS_ALL_ACTIVE_FORM_STATUS,DS_INCOMPLETE_ACTIONS,DS_Get_All_Responses,DS_PROJDISTUSERS,DS_CHECK_FORM_PERMISSION_USER,DS_ASI_SITE_getDefectTypesForProjects_pf\",\"DS_Get_All_Responses\":\"{\\\"Items\\\":{\\\"Item\\\":[]}}\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"{\\\"Items\\\":{\\\"Item\\\":[{\\\"Value3\\\":\\\"\\\",\\\"Value4\\\":\\\"\\\",\\\"Value1\\\":\\\"Architectural\\\",\\\"Value2\\\":\\\"\\\",\\\"Name\\\":\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\"},{\\\"Value3\\\":\\\"\\\",\\\"Value4\\\":\\\"\\\",\\\"Value1\\\":\\\"Civil\\\",\\\"Value2\\\":\\\"\\\",\\\"Name\\\":\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\"},{\\\"Value3\\\":\\\"\\\",\\\"Value4\\\":\\\"\\\",\\\"Value1\\\":\\\"Computer\\\",\\\"Value2\\\":\\\"\\\",\\\"Name\\\":\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\"},{\\\"Value3\\\":\\\"\\\",\\\"Value4\\\":\\\"\\\",\\\"Value1\\\":\\\"EC\\\",\\\"Value2\\\":\\\"\\\",\\\"Name\\\":\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\"},{\\\"Value3\\\":\\\"\\\",\\\"Value4\\\":\\\"\\\",\\\"Value1\\\":\\\"Electrical\\\",\\\"Value2\\\":\\\"\\\",\\\"Name\\\":\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\"},{\\\"Value3\\\":\\\"\\\",\\\"Value4\\\":\\\"\\\",\\\"Value1\\\":\\\"Fire Safety\\\",\\\"Value2\\\":\\\"\\\",\\\"Name\\\":\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\"},{\\\"Value3\\\":\\\"\\\",\\\"Value4\\\":\\\"\\\",\\\"Value1\\\":\\\"Mechanical\\\",\\\"Value2\\\":\\\"\\\",\\\"Name\\\":\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\"}]}}\",\"DS_ISDRAFT_EDITORI\":\"NO\",\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_FORMSTATUS\":\"Open\",\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_FORMNAME\":\"Site Tasks\",\"DS_DATEOFISSUE\":\"2023-07-31 10:12:59\",\"DS_CHECK_FORM_PERMISSION_USER\":\"{\\\"Items\\\":{\\\"Item\\\":[{\\\"Value3\\\":\\\"All_Org\\\",\\\"Value4\\\":\\\"Yes\\\",\\\"Value1\\\":\\\"2130192\\\",\\\"Value2\\\":\\\"2017529\\\",\\\"Name\\\":\\\"DS_MTA_CHECK_FORM_PERMISSION_USER\\\"}]}}\"}",
          "0",
          "0",
          0,
          "",
          "07-Aug-2023#23:59 CST",
          "",
          "",
          "",
          "[]",
          "{\"can_edit_ORI\":false,\"can_respond\":false,\"restrictChangeFormStatus\":false,\"controllerUserId\":0,\"isProjectArchived\":false,\"can_distribute\":false,\"can_forward\":false,\"oriMsgId\":\"12329329\$\$ZvNboh\"}",
          0,
          0,
          0,
          1,
          0,
          1,
          "",
          0,
          "183678",
          "107704",
          "",
          "",
          0,
          0,
          0,
          "",
          "10940318",
          "",
          0,
          "",
          0,
          "",
          "",
          "",
          0,
          0,
          0,
          "Sent",
          "110997340",
          "5",
          0,
          0,
          0,
          0,
          0,
          0,
          0
        ]
      ];
      when(() => mockDb!.executeBulk(frmMsgTableName, frmMsgBulkInsertQuery, frmMsgValueList))
          .thenAnswer((_) async=> null);

      String requestFilePath = "./test/fixtures/database/1_808581/2130192/OfflineRequestData/1690785341103.txt";
      when(() => mockFileUtility!.deleteFileAtPath(requestFilePath, recursive: false))
          .thenAnswer((_) => Future.value(null));
      await PushToServerFormSyncTask(syncTask, (eSyncTaskType, eSyncStatus, data) async {},).syncFormDataToServer(paramData, null);
      verify(() => mockFileUtility!.readFromFile(reqFilePath)).called(1);
      verify(() => mockDb!.selectFromTable(attachTableName, attachQuery)).called(1);
      verify(() => mockUseCase!.saveFormToServer(any())).called(1);
      verify(() => mockProjectUseCase!.getFormMessageBatchList(any())).called(1);

      verify(() => mockDb!.executeQuery(removeFormQuery)).called(1);
      verify(() => mockDb!.executeQuery(removeFormMsgQuery)).called(1);
      verify(() => mockDb!.executeQuery(removeFormMsgActQuery)).called(1);
      verify(() => mockDb!.executeQuery(removeFormMsgAttachQuery)).called(1);
      //Below changes for Form DAO mock
      verify(() => mockDb!.executeQuery(formTableQuery)).called(1);
      verify(() => mockDb!.getPrimaryKeys(formTableName)).called(1);
      verify(() => mockDb!.selectFromTable(formTableName, formSelectQuery)).called(1);
      verify(() => mockDb!.executeBulk(formTableName, frmBulkInsertQuery, frmValueList)).called(1);
      //Below changes for FormMessage DAO mock
      verify(() => mockDb!.executeQuery(frmMsgTableQuery)).called(1);
      verify(() => mockDb!.getPrimaryKeys(frmMsgTableName)).called(1);
      verify(() => mockDb!.selectFromTable(frmMsgTableName, frmMsgSelectQuery)).called(1);
      verify(() => mockDb!.executeBulk(frmMsgTableName, frmMsgBulkInsertQuery, frmMsgValueList)).called(1);

      verify(() => mockFileUtility!.deleteFileAtPath(requestFilePath, recursive: false)).called(1);
    });

    test('syncFormDataToServer site task form with attachment test', () async {
      SyncRequestTask syncTask = SyncRequestTask();
      var paramData = {
        "RequestType": EOfflineSyncRequestType.CreateOrRespond.value.toString(),
        "ProjectId": "2130192",
        "FormId": "1690869631580",
        "MsgId": "1690869955199",
        "UpdatedDateInMS": "1690869955199",
      };

      String requestData = "{\"projectId\":\"2130192\",\"locationId\":\"0\",\"observationId\":\"107704\",\"formTypeId\":\"11103151\",\"templateType\":2,\"appTypeId\":2,\"appBuilderId\":\"ASI-SITE\",\"formSelectRadiobutton\":\"1_2130192_11103151\",\"isUploadAttachmentInTemp\":null,\"offlineFormId\":1690869631580,\"isCopySiteTask\":true,\"offlineFormDataJson\":\"{\\\"myFields\\\":{\\\"FORM_CUSTOM_FIELDS\\\":{\\\"ORI_MSG_Custom_Fields\\\":{\\\"ORI_FORMTITLE\\\":\\\"Test Offlinr VJ Attachment\\\",\\\"ORI_USERREF\\\":\\\"\\\",\\\"DefectTyoe\\\":\\\"Computer\\\",\\\"TaskType\\\":\\\"Defect\\\",\\\"DefectDescription\\\":\\\"\\\",\\\"Location\\\":\\\"183678|01 Vijay_Test|01 Vijay_Test\\\",\\\"LocationName\\\":\\\"01 Vijay_Test\\\",\\\"StartDate\\\":\\\"2023-08-01\\\",\\\"StartDateDisplay\\\":\\\"01-Aug-2023\\\",\\\"ExpectedFinishDate\\\":\\\"\\\",\\\"OriginatorId\\\":\\\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\\\",\\\"ActualFinishDate\\\":\\\"\\\",\\\"Recent_Defects\\\":\\\"\\\",\\\"AssignedToUsersGroup\\\":{\\\"AssignedToUsers\\\":{\\\"AssignedToUser\\\":\\\"707447#Vijay Mavadiya (5336), Asite Solutions\\\"}},\\\"CurrStage\\\":\\\"1\\\",\\\"PF_Location_Detail\\\":\\\"183678|0|null|0\\\",\\\"Defect_Description\\\":\\\"test description\\\",\\\"Username\\\":\\\"\\\",\\\"Organization\\\":\\\"\\\",\\\"ExpectedFinishDays\\\":\\\"5\\\",\\\"DistributionDays\\\":\\\"0\\\",\\\"LastResponder_For_AssignedTo\\\":\\\"707447\\\",\\\"LastResponder_For_Originator\\\":\\\"2017529\\\",\\\"FormCreationDate\\\":\\\"\\\",\\\"Assigned\\\":\\\"Vijay Mavadiya (5336), Asite Solutions\\\",\\\"attachements\\\":[{\\\"attachedDocs\\\":\\\"\\\"}],\\\"DS_Logo\\\":\\\"images/asite.gif\\\",\\\"isCalibrated\\\":false},\\\"RES_MSG_Custom_Fields\\\":{\\\"Comments\\\":\\\"\\\",\\\"ShowHideFlag\\\":\\\"Yes\\\",\\\"SHResponse\\\":\\\"Yes\\\"},\\\"CREATE_FWD_RES\\\":{\\\"Can_Reply\\\":\\\"\\\"},\\\"DS_AUTONUMBER\\\":{\\\"DS_FORMAUTONO_CREATE\\\":\\\"\\\",\\\"DS_SEQ_LENGTH\\\":\\\"\\\",\\\"DS_FORMAUTONO_ADD\\\":\\\"\\\",\\\"DS_GET_APP_ACTION_DETAILS\\\":\\\"\\\"},\\\"DS_DATASOURCE\\\":{\\\"DS_ASI_SITE_getAllLocationByProject_PF\\\":\\\"\\\",\\\"DS_Response_PARAM\\\":\\\"#Comments#DS_ALL_FORMSTATUS\\\",\\\"DS_Get_All_Responses\\\":\\\"\\\",\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\":\\\"\\\",\\\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\\\":\\\"\\\",\\\"DS_Holiday_Calender_Param\\\":\\\"\\\",\\\"DS_CALL_METHOD\\\":\\\"1\\\",\\\"DS_ASI_SITE_GET_RECENT_DEFECTS\\\":\\\"\\\",\\\"DS_CHECK_FORM_PERMISSION_USER\\\":\\\"\\\",\\\"DS_ASI_Configurable_Attributes\\\":\\\"\\\"}},\\\"Asite_System_Data_Read_Only\\\":{\\\"_1_User_Data\\\":{\\\"DS_WORKINGUSER\\\":\\\"Mayur Raval m., Asite Solutions Ltd\\\",\\\"DS_WORKINGUSERROLE\\\":\\\"\\\",\\\"DS_WORKINGUSER_ID\\\":\\\"\\\",\\\"DS_WORKINGUSER_ALL_ROLES\\\":\\\"\\\"},\\\"_2_Printing_Data\\\":{\\\"DS_PRINTEDBY\\\":\\\"\\\",\\\"DS_PRINTEDON\\\":\\\"\\\"},\\\"_3_Project_Data\\\":{\\\"DS_PROJECTNAME\\\":\\\"\\\",\\\"DS_CLIENT\\\":\\\"\\\"},\\\"_4_Form_Type_Data\\\":{\\\"DS_FORMNAME\\\":\\\"Site Tasks\\\",\\\"DS_FORMGROUPCODE\\\":\\\"SITE\\\",\\\"DS_FORMAUTONO\\\":\\\"\\\"},\\\"_5_Form_Data\\\":{\\\"DS_FORMID\\\":\\\"\\\",\\\"DS_ORIGINATOR\\\":\\\"\\\",\\\"DS_DATEOFISSUE\\\":\\\"\\\",\\\"DS_DISTRIBUTION\\\":\\\"\\\",\\\"DS_CONTROLLERNAME\\\":\\\"\\\",\\\"DS_ATTRIBUTES\\\":\\\"\\\",\\\"DS_MAXFORMNO\\\":\\\"\\\",\\\"DS_MAXORGFORMNO\\\":\\\"\\\",\\\"DS_ISDRAFT\\\":\\\"NO\\\",\\\"DS_ISDRAFT_RES\\\":\\\"\\\",\\\"DS_FORMAUTONO_PREFIX\\\":\\\"\\\",\\\"DS_FORMCONTENT\\\":\\\"\\\",\\\"DS_FORMCONTENT1\\\":\\\"\\\",\\\"DS_FORMCONTENT2\\\":\\\"\\\",\\\"DS_FORMCONTENT3\\\":\\\"\\\",\\\"DS_ISDRAFT_RES_MSG\\\":\\\"\\\",\\\"DS_ISDRAFT_FWD_MSG\\\":\\\"NO\\\",\\\"Status_Data\\\":{\\\"DS_FORMSTATUS\\\":\\\"\\\",\\\"DS_CLOSEDUEDATE\\\":\\\"\\\",\\\"DS_APPROVEDBY\\\":\\\"\\\",\\\"DS_APPROVEDON\\\":\\\"\\\",\\\"DS_CLOSE_DUE_DATE\\\":\\\"\\\",\\\"DS_ALL_FORMSTATUS\\\":\\\"1001 # Open\\\",\\\"DS_ALL_ACTIVE_FORM_STATUS\\\":\\\"\\\"}},\\\"_6_Form_MSG_Data\\\":{\\\"DS_MSGID\\\":\\\"\\\",\\\"DS_MSGCREATOR\\\":\\\"\\\",\\\"DS_MSGDATE\\\":\\\"\\\",\\\"DS_MSGSTATUS\\\":\\\"\\\",\\\"DS_MSGRELEASEDATE\\\":\\\"\\\",\\\"ORI_MSG_Data\\\":{\\\"DS_DOC_ASSOCIATIONS_ORI\\\":\\\"\\\",\\\"DS_FORM_ASSOCIATIONS_ORI\\\":\\\"\\\",\\\"DS_ATTACHMENTS_ORI\\\":\\\"\\\"}}},\\\"Asite_System_Data_Read_Write\\\":{\\\"ORI_MSG_Fields\\\":{\\\"SP_ORI_VIEW\\\":\\\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\\\",\\\"SP_ORI_PRINT_VIEW\\\":\\\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\\\",\\\"SP_FORM_PRINT_VIEW\\\":\\\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\\\",\\\"SP_RES_VIEW\\\":\\\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\\\",\\\"SP_RES_PRINT_VIEW\\\":\\\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\\\"},\\\"DS_PROJORGANISATIONS\\\":\\\"\\\",\\\"DS_PROJUSERS\\\":\\\"\\\",\\\"DS_PROJDISTGROUPS\\\":\\\"\\\",\\\"DS_AUTODISTRIBUTE\\\":\\\"401\\\",\\\"DS_INCOMPLETE_ACTIONS\\\":\\\"\\\",\\\"DS_PROJORGANISATIONS_ID\\\":\\\"\\\",\\\"DS_PROJUSERS_ALL_ROLES\\\":\\\"\\\",\\\"Auto_Distribute_Group\\\":{\\\"Auto_Distribute_Users\\\":[{\\\"DS_PROJDISTUSERS\\\":\\\"707447\\\",\\\"DS_FORMACTIONS\\\":\\\"3#Respond\\\",\\\"DS_ACTIONDUEDATE\\\":\\\"5\\\"}]}},\\\"attachments\\\":[],\\\"dist_list\\\":\\\"{\\\\\\\"selectedDistGroups\\\\\\\":\\\\\\\"\\\\\\\",\\\\\\\"selectedDistUsers\\\\\\\":[],\\\\\\\"selectedDistOrgs\\\\\\\":[],\\\\\\\"selectedDistRoles\\\\\\\":[],\\\\\\\"prePopulatedDistGroups\\\\\\\":\\\\\\\"\\\\\\\"}\\\",\\\"respondBy\\\":\\\"\\\",\\\"selectedControllerUserId\\\":\\\"\\\",\\\"create_hidden_list\\\":{\\\"msg_type_id\\\":\\\"1\\\",\\\"msg_type_code\\\":\\\"ORI\\\",\\\"dist_list\\\":\\\"{\\\\\\\"selectedDistGroups\\\\\\\":\\\\\\\"\\\\\\\",\\\\\\\"selectedDistUsers\\\\\\\":[],\\\\\\\"selectedDistOrgs\\\\\\\":[],\\\\\\\"selectedDistRoles\\\\\\\":[],\\\\\\\"prePopulatedDistGroups\\\\\\\":\\\\\\\"\\\\\\\"}\\\",\\\"formAction\\\":\\\"create\\\",\\\"project_id\\\":\\\"2130192\\\",\\\"offlineProjectId\\\":\\\"2130192\\\",\\\"offlineFormTypeId\\\":\\\"11103151\\\",\\\"assocLocationSelection\\\":\\\"{\\\\\\\"locationId\\\\\\\":183678}\\\",\\\"attachedDocs_0\\\":\\\"Image_1690869946283.jpg_2017529\\\",\\\"upFile0\\\":\\\"/data/user/0/com.asite.field/app_flutter/database/1_2017529/2130192/tempAttachments/Image_1690869946283.jpg\\\",\\\"attachedDocs_1\\\":\\\"Image_1690869946713.jpg_2017529\\\",\\\"upFile1\\\":\\\"/data/user/0/com.asite.field/app_flutter/database/1_2017529/2130192/tempAttachments/Image_1690869946713.jpg\\\",\\\"appTypeId\\\":\\\"2\\\"}}}\",\"isDraft\":false,\"offlineFormCreatedDateInMS\":\"1690869955199\",\"assocLocationSelection\":\"{\\\"locationId\\\":183678,\\\"projectId\\\":\\\"2130192\\\",\\\"folderId\\\":\\\"115096348\\\"}\"}";
      String reqFilePath = "./test/fixtures/database/1_808581/2130192/OfflineRequestData/1690869955199.txt";
      when(() => mockFileUtility!.readFromFile(reqFilePath))
          .thenReturn(requestData);

      ResultSet resultSet = ResultSet(["AttachRevId", "OfflineUploadFilePath"], null, [
        ["1690869955462337", "./test/fixtures/database/1_808581/2130192/tempAttachments/Image_1690869946283.jpg"],
        ["1690869955475827", "./test/fixtures/database/1_808581/2130192/tempAttachments/Image_1690869946713.jpg"],
      ]);
      String attachQuery = "SELECT AttachRevId,OfflineUploadFilePath FROM FormMsgAttachAndAssocListTbl WHERE ProjectId=2130192 AND FormId=1690869631580 AND MsgId=1690869955199 AND OfflineUploadFilePath <> ''";
      String attachTableName = "FormMsgAttachAndAssocListTbl";
      when(() => mockDb!.selectFromTable(attachTableName, attachQuery))
          .thenReturn(resultSet);

      final saveFormResult = {
        "formDetailsVO": {
          "templateType": 2,
          "responseRequestByInMS": 1691557199000,
          "pfLocFolderId": 115096348,
          "workflowStatus": "",
          "isDraft": false,
          "formCreationDate": "01-Aug-2023#01:45 CST",
          "userID": "2017529\$\$w5oy4u",
          "observationVO": {
            "msgNum": 0,
            "pageNumber": 0,
            "attachments": [],
            "assignedToUserOrgName": "Asite Solutions",
            "isDraft": false,
            "formDueDays": 5,
            "msgId": "0\$\$y5zyZ6",
            "isActive": true,
            "taskTypeName": "Defect",
            "orgId": "0\$\$b0XNVl",
            "noOfActions": 0,
            "observationTypeId": 0,
            "observationId": 0,
            "hasAttachment": false,
            "locationId": 0,
            "appType": 0,
            "noOfMessages": 0,
            "isCloseOut": false,
            "originatorId": 0,
            "formId": "0\$\$Kvun3Z",
            "assignedToUserId": 707447,
            "lastResponderForOriginator": "2017529",
            "formTypeId": "0\$\$Kvun3Z",
            "formSyncDate": "2023-08-01 07:45:17.883",
            "lastResponderForAssignedTo": "707447",
            "annotationId": "",
            "observationCoordinates": "",
            "generateURI": true,
            "manageTypeVo": {"isDeactive": false, "name": "Computer", "id": "310493", "projectId": "2130192\$\$W0Hsid", "generateURI": true},
            "expectedFinishDate": "2023-08-08",
            "statusId": 0,
            "assignedToUserName": "Vijay Mavadiya (5336)",
            "isStatusChangeRestricted": false,
            "allowReopenForm": false,
            "messages": [],
            "instanceGroupId": "0\$\$Kvun3Z",
            "projectId": "0\$\$xxvKpe",
            "startDate": "2023-08-01"
          },
          "msgStatusId": 20,
          "statusid": 1001,
          "canControllerChangeStatus": false,
          "appTypeId": "2",
          "invoiceCountAgainstOrder": "-1",
          "workflowStage": "",
          "hasBimViewAssociations": false,
          "id": "SITE400",
          "msgCode": "ORI001",
          "formGroupName": "Site Tasks",
          "statusChangeUserId": 0,
          "originatorDisplayName": "Mayur Raval m., Asite Solutions Ltd",
          "msgUserOrgId": 5763307,
          "allowReopenForm": false,
          "canAccessHistory": true,
          "latestDraftId": "0\$\$y5zyZ6",
          "status": "Open",
          "canOrigChangeStatus": false,
          "lastName": "Raval m.",
          "originatorName": "Mayur Raval m.",
          "controllerUserId": 0,
          "msgId": "12331468\$\$xotfl6",
          "originatorEmail": "m.raval@asite.com",
          "msgUserName": "Mayur Raval m.",
          "orgId": "5763307\$\$aZTKET",
          "msgHasAssocAttach": false,
          "locationId": 183678,
          "appType": "Field",
          "noOfMessages": 0,
          "originatorOrgId": 5763307,
          "isCloseOut": false,
          "originatorId": 2017529,
          "hasAttachments": false,
          "formHasAssocAttach": true,
          "actionDateInMS": 0,
          "msgUserOrgName": "Asite Solutions Ltd",
          "hasFormAccess": false,
          "docType": "Apps",
          "generateURI": true,
          "responseRequestBy": "08-Aug-2023#23:59 CST",
          "parentMsgId": 0,
          "commId": "11624015\$\$TUFVZ2",
          "ownerOrgId": 3,
          "instanceGroupId": "10940318\$\$KA7T2Y",
          "isThumbnailSupports": false,
          "hasBimListAssociations": false,
          "msgTypeCode": "ORI",
          "appBuilderId": "ASI-SITE",
          "hasDocAssocations": false,
          "noOfActions": 0,
          "statusRecordStyle": {"fontType": "PT Sans", "backgroundColor": "#e03ae0", "isDeactive": false, "isForOnlyStyleUpdate": false, "statusTypeID": 1, "proxyUserId": 0, "userId": 0, "generateURI": true, "fontEffect": "0#0#0#0", "orgId": "0\$\$b0XNVl", "always_active": false, "statusID": 1001, "defaultPermissionId": 0, "statusName": "Open", "settingApplyOn": 1, "isEnableForReviewComment": false, "projectId": "2130192\$\$W0Hsid", "fontColor": "#000000"},
          "observationId": 107745,
          "formTypeName": "Site Tasks",
          "statusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "formId": "11624015\$\$ZDccq0",
          "hasOverallStatus": false,
          "orgName": "Asite Solutions Ltd",
          "msgOriginatorId": 2017529,
          "formTypeId": "11103151\$\$0PXUZZ",
          "folderId": "0\$\$HEdZT0",
          "firstName": "Mayur",
          "lastmodified": "2023-08-01T07:45:18Z",
          "formPrintEnabled": false,
          "project_APD_folder_id": "0\$\$HEdZT0",
          "projectName": "Site Quality Demo",
          "formNum": 400,
          "projectId": "2130192\$\$W0Hsid",
          "updated": "01-Aug-2023#01:45 CST",
          "messageTypeImageName": "icons/form.png",
          "code": "SITE400",
          "indent": -1,
          "statusUpdateDate": "01-Aug-2023#01:45 CST",
          "originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "title": "Test Offlinr VJ Attachment",
          "flagTypeImageName": "flag_type/flag_0.png",
          "ownerOrgName": "Asite Solutions",
          "dcId": 1,
          "formCreationDateInMS": 1690872317000,
          "isPublic": false,
          "projectStatusId": 5,
          "updatedDateInMS": 1690872318000,
          "statusChangeUserName": "Mayur Raval m.",
          "showPrintIcon": 0,
          "invoiceColourCode": "-1",
          "msgCreatedDateInMS": 0,
          "flagType": 0,
          "hasFormAssocations": false,
          "hasCommentAssocations": false,
          "statusChangeUserEmail": "m.raval@asite.com",
          "statusChangeUserOrg": "Asite Solutions Ltd",
          "msgTypeId": 1,
          "isStatusChangeRestricted": false,
          "formUserSet": [],
          "statusText": "Open",
          "typeImage": "icons/form.png",
          "attachmentImageName": "icons/assocform.png"
        },
        "viewFormJson": "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"DistributionDays\":\"0\",\"Organization\":\"\",\"DefectTyoe\":\"Computer\",\"ExpectedFinishDate\":\"2023-08-08\",\"DefectDescription\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"707447#Vijay Mavadiya (5336), Asite Solutions\"}},\"Defect_Description\":\"test description\",\"LocationName\":\"01 Vijay_Test\",\"StartDate\":\"2023-08-01\",\"ActualFinishDate\":\"\",\"ExpectedFinishDays\":\"5\",\"DS_Logo\":\"images/asite.gif\",\"LastResponder_For_AssignedTo\":\"707447\",\"TaskType\":\"Defect\",\"isCalibrated\":false,\"ORI_FORMTITLE\":\"Test Offlinr VJ Attachment\",\"attachements\":[{\"attachedDocs\":\"\"}],\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"Assigned\":\"Vijay Mavadiya (5336), Asite Solutions\",\"CurrStage\":\"1\",\"Recent_Defects\":\"\",\"FormCreationDate\":\"\",\"StartDateDisplay\":\"01-Aug-2023\",\"LastResponder_For_Originator\":\"2017529\",\"PF_Location_Detail\":\"183678|0|null|0\",\"Username\":\"\",\"ORI_USERREF\":\"\",\"Location\":\"183678|01 Vijay_Test|01 Vijay_Test\"},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"SHResponse\":\"Yes\",\"ShowHideFlag\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_CREATE\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\",\"DS_FORMAUTONO_ADD\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_Get_All_Responses\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"attachments\":[],\"Asite_System_Data_Read_Only\":{\"_2_Printing_Data\":{\"DS_PRINTEDON\":\"\",\"DS_PRINTEDBY\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\",\"DS_FORMNAME\":\"Site Tasks\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"\",\"DS_CLIENT\":\"\"},\"_5_Form_Data\":{\"DS_DATEOFISSUE\":\"\",\"DS_ISDRAFT_RES_MSG\":\"\",\"Status_Data\":{\"DS_APPROVEDON\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_APPROVEDBY\":\"\",\"DS_CLOSE_DUE_DATE\":\"2023-08-08\",\"DS_FORMSTATUS\":\"\"},\"DS_DISTRIBUTION\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT_RES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_FORMID\":\"\"},\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_6_Form_MSG_Data\":{\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGID\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_PROJUSERS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_ACTIONDUEDATE\":\"5\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_PROJDISTUSERS\":\"707447\"}]}},\"selectedControllerUserId\":\"\"}}",
        "offlineFormId": "1690869631580"
      };
      when(() => mockUseCase!.saveFormToServer(any()))
          .thenAnswer((_) => Future.value(SUCCESS(saveFormResult, null, 200)));

      final formDetailResult = {
        "11624015": {
          "combinedAttachAssocList": [
            {
              "fileType": "filetype/jpg.gif",
              "fileName": "Image_1690869946283.jpg",
              "revisionId": "27196803\$\$aYMqpV",
              "fileSize": "353 KB",
              "hasAccess": true,
              "canDownload": true,
              "publisherUserId": "0",
              "hasBravaSupport": true,
              "docId": "13652680\$\$BbXfr6",
              "attachedBy": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
              "attachedDateInTimeStamp": "Aug 1, 2023 7:45:00 AM",
              "attachedDate": "01-Aug-2023#01:45 CST",
              "createdDateInTimeStamp": "Aug 1, 2023 7:45:00 AM",
              "attachedById": "2017529",
              "attachedByName": "Mayur Raval m.",
              "isLink": false,
              "linkType": "Static",
              "isHasXref": false,
              "documentTypeId": "0",
              "isRevPrivate": false,
              "isAccess": true,
              "isDocActive": true,
              "folderPermissionValue": "0",
              "isRevInDistList": false,
              "isPasswordProtected": false,
              "attachmentId": "0\$\$VPkE1m",
              "viewAlwaysFormAssociationParent": false,
              "viewAlwaysDocAssociationParent": false,
              "allowDownloadToken": "1\$\$YloLLn",
              "isHoopsSupported": false,
              "isPDFTronSupported": false,
              "downloadImageName": "icons/downloads.png",
              "hasOnlineViewerSupport": true,
              "newSysLocation": "project_2130192/formtype_11103151/form_11103151/msg_12331468/27196803.jpg",
              "hashedAttachedById": "2017529\$\$w5oy4u",
              "hasGeoTagInfo": false,
              "locationPath": "Site Quality Demo\\01 Vijay_Test",
              "type": "3",
              "msgId": "12331468\$\$xotfl6",
              "msgCreationDate": "Aug 1, 2023 7:45:00 AM",
              "projectId": "2130192\$\$W0Hsid",
              "folderId": "116256200\$\$kS1ZDH",
              "dcId": "1",
              "childProjectId": "0",
              "userId": "0",
              "resourceId": "0",
              "parentMsgId": "12331468",
              "parentMsgCode": "ORI001",
              "assocsParentId": "0\$\$Kvun3Z",
              "totalDocCount": "0",
              "generateURI": true,
              "hasHoopsViewerSupport": false
            },
            {
              "fileType": "filetype/jpg.gif",
              "fileName": "Image_1690869946713.jpg",
              "revisionId": "27196802\$\$gwpqK9",
              "fileSize": "279 KB",
              "hasAccess": true,
              "canDownload": true,
              "publisherUserId": "0",
              "hasBravaSupport": true,
              "docId": "13652679\$\$A5fwpX",
              "attachedBy": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
              "attachedDateInTimeStamp": "Aug 1, 2023 7:45:00 AM",
              "attachedDate": "01-Aug-2023#01:45 CST",
              "createdDateInTimeStamp": "Aug 1, 2023 7:45:00 AM",
              "attachedById": "2017529",
              "attachedByName": "Mayur Raval m.",
              "isLink": false,
              "linkType": "Static",
              "isHasXref": false,
              "documentTypeId": "0",
              "isRevPrivate": false,
              "isAccess": true,
              "isDocActive": true,
              "folderPermissionValue": "0",
              "isRevInDistList": false,
              "isPasswordProtected": false,
              "attachmentId": "0\$\$VPkE1m",
              "viewAlwaysFormAssociationParent": false,
              "viewAlwaysDocAssociationParent": false,
              "allowDownloadToken": "1\$\$YloLLn",
              "isHoopsSupported": false,
              "isPDFTronSupported": false,
              "downloadImageName": "icons/downloads.png",
              "hasOnlineViewerSupport": true,
              "newSysLocation": "project_2130192/formtype_11103151/form_11103151/msg_12331468/27196802.jpg",
              "hashedAttachedById": "2017529\$\$w5oy4u",
              "hasGeoTagInfo": false,
              "locationPath": "Site Quality Demo\\01 Vijay_Test",
              "type": "3",
              "msgId": "12331468\$\$xotfl6",
              "msgCreationDate": "Aug 1, 2023 7:45:00 AM",
              "projectId": "2130192\$\$W0Hsid",
              "folderId": "116256200\$\$kS1ZDH",
              "dcId": "1",
              "childProjectId": "0",
              "userId": "0",
              "resourceId": "0",
              "parentMsgId": "12331468",
              "parentMsgCode": "ORI001",
              "assocsParentId": "0\$\$Kvun3Z",
              "totalDocCount": "0",
              "generateURI": true,
              "hasHoopsViewerSupport": false
            },
            {"Location Name": "01 Vijay_Test", "Location Path": "Site Quality Demo\\01 Vijay_Test"}
          ],
          "messages": [
            {
              "projectId": "2130192\$\$W0Hsid",
              "projectName": "Site Quality Demo",
              "code": "SITE400",
              "commId": "11624015\$\$TUFVZ2",
              "formId": "11624015\$\$ZDccq0",
              "title": "Test Offlinr VJ Attachment",
              "userID": "2017529\$\$w5oy4u",
              "orgId": "5763307\$\$aZTKET",
              "firstName": "Mayur",
              "lastName": "Raval m.",
              "orgName": "Asite Solutions Ltd",
              "originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
              "originatorDisplayName": "Mayur Raval m., Asite Solutions Ltd",
              "actions": [],
              "allActions": [],
              "noOfActions": 0,
              "observationId": 107745,
              "locationId": 183678,
              "pfLocFolderId": 0,
              "updated": "2023-08-01T07:45:18Z",
              "duration": "1 min ago",
              "hasAttachments": true,
              "msgCode": "ORI001",
              "docType": "Apps",
              "formTypeName": "Site Tasks",
              "userRefCode": "N/A",
              "status": "Open",
              "responseRequestBy": "08-Aug-2023#23:59 CST",
              "controllerName": "N/A",
              "hasDocAssocations": false,
              "hasBimViewAssociations": false,
              "hasBimListAssociations": false,
              "hasFormAssocations": false,
              "hasCommentAssocations": false,
              "formHasAssocAttach": true,
              "msgHasAssocAttach": true,
              "formCreationDate": "2023-08-01T07:45:17Z",
              "msgCreatedDate": "01-Aug-2023#01:45 CST",
              "folderId": "0\$\$HEdZT0",
              "msgId": "12331468\$\$xotfl6",
              "parentMsgId": 0,
              "msgTypeId": 1,
              "msgStatusId": 20,
              "msgStatusName": "Sent",
              "indent": -1,
              "formTypeId": "11103151\$\$0PXUZZ",
              "formNum": 400,
              "msgOriginatorId": 2017529,
              "hashedMsgOriginatorId": "2017529\$\$w5oy4u",
              "formPrintEnabled": true,
              "showPrintIcon": 1,
              "sentNames": ["Vijay Mavadiya (5336), Asite Solutions"],
              "templateType": 2,
              "instanceGroupId": "10940318\$\$KA7T2Y",
              "noOfMessages": 0,
              "isDraft": false,
              "dcId": 1,
              "statusid": 1001,
              "originatorId": 2017529,
              "isCloseOut": false,
              "isStatusChangeRestricted": false,
              "project_APD_folder_id": "110997340\$\$zu768r",
              "allowReopenForm": true,
              "hasOverallStatus": true,
              "formUserSet": [],
              "canOrigChangeStatus": false,
              "canControllerChangeStatus": false,
              "appType": "2",
              "msgTypeCode": "ORI",
              "formGroupName": "Site Tasks",
              "id": "SITE400",
              "statusText": "Open",
              "statusChangeUserId": 0,
              "originatorEmail": "m.raval@asite.com",
              "statusRecordStyle": {"settingApplyOn": 1, "fontType": "PT Sans", "fontEffect": "0#0#0#0", "fontColor": "#000000", "backgroundColor": "#e03ae0", "isForOnlyStyleUpdate": false, "always_active": false, "userId": 0, "isDeactive": false, "defaultPermissionId": 0, "statusName": "Open", "statusID": 1001, "statusTypeID": 1, "projectId": "2130192\$\$W0Hsid", "orgId": "0\$\$b0XNVl", "proxyUserId": 0, "isEnableForReviewComment": false, "generateURI": true},
              "invoiceCountAgainstOrder": "-1",
              "invoiceColourCode": "-1",
              "controllerUserId": 0,
              "offlineFormId": "1690869631580",
              "customFieldsValueVOs": {},
              "updatedDateInMS": 1690872318000,
              "formCreationDateInMS": 1690872317000,
              "msgCreatedDateInMS": 1690872317000,
              "flagType": 0,
              "latestDraftId": "0\$\$y5zyZ6",
              "hasFormAccess": false,
              "jsonData": "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"DistributionDays\":\"0\",\"Organization\":\"\",\"DefectTyoe\":\"Computer\",\"ExpectedFinishDate\":\"2023-08-08\",\"DefectDescription\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"707447#Vijay Mavadiya (5336), Asite Solutions\"}},\"Defect_Description\":\"test description\",\"LocationName\":\"01 Vijay_Test\",\"StartDate\":\"2023-08-01\",\"ActualFinishDate\":\"\",\"ExpectedFinishDays\":\"5\",\"DS_Logo\":\"images/asite.gif\",\"LastResponder_For_AssignedTo\":\"707447\",\"TaskType\":\"Defect\",\"isCalibrated\":false,\"ORI_FORMTITLE\":\"Test Offlinr VJ Attachment\",\"attachements\":[{\"attachedDocs\":\"\"}],\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"Assigned\":\"Vijay Mavadiya (5336), Asite Solutions\",\"CurrStage\":\"1\",\"Recent_Defects\":\"\",\"FormCreationDate\":\"\",\"StartDateDisplay\":\"01-Aug-2023\",\"LastResponder_For_Originator\":\"2017529\",\"PF_Location_Detail\":\"183678|0|null|0\",\"Username\":\"\",\"ORI_USERREF\":\"\",\"Location\":\"183678|01 Vijay_Test|01 Vijay_Test\"},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"SHResponse\":\"Yes\",\"ShowHideFlag\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_CREATE\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\",\"DS_FORMAUTONO_ADD\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_Get_All_Responses\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"attachments\":[],\"Asite_System_Data_Read_Only\":{\"_2_Printing_Data\":{\"DS_PRINTEDON\":\"\",\"DS_PRINTEDBY\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\",\"DS_FORMNAME\":\"Site Tasks\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"\",\"DS_CLIENT\":\"\"},\"_5_Form_Data\":{\"DS_DATEOFISSUE\":\"\",\"DS_ISDRAFT_RES_MSG\":\"\",\"Status_Data\":{\"DS_APPROVEDON\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_APPROVEDBY\":\"\",\"DS_CLOSE_DUE_DATE\":\"2023-08-08\",\"DS_FORMSTATUS\":\"\"},\"DS_DISTRIBUTION\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT_RES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_FORMID\":\"\"},\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_6_Form_MSG_Data\":{\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGID\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_PROJUSERS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_ACTIONDUEDATE\":\"5\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_PROJDISTUSERS\":\"707447\"}]}},\"selectedControllerUserId\":\"\"}}",
              "formPermissions": {"can_edit_ORI": false, "can_respond": false, "restrictChangeFormStatus": false, "controllerUserId": 0, "isProjectArchived": false, "can_distribute": false, "can_forward": false, "oriMsgId": "12331468\$\$xotfl6"},
              "sentActions": [
                {
                  "projectId": "0\$\$xxvKpe",
                  "resourceParentId": 11624015,
                  "resourceId": 12331468,
                  "resourceCode": "ORI001",
                  "resourceStatusId": 0,
                  "msgId": "12331468\$\$xotfl6",
                  "commentMsgId": "12331468\$\$tUZdFh",
                  "actionId": 3,
                  "actionName": "Respond",
                  "actionStatus": 0,
                  "priorityId": 0,
                  "actionDate": "Tue Aug 01 08:45:17 BST 2023",
                  "dueDate": "Wed Aug 09 06:59:59 BST 2023",
                  "distributorUserId": 2017529,
                  "recipientId": 707447,
                  "remarks": "",
                  "distListId": 13739622,
                  "transNum": "-1",
                  "actionTime": "7 Days",
                  "actionCompleteDate": "",
                  "instantEmailNotify": "true",
                  "actionNotes": "",
                  "entityType": 0,
                  "instanceGroupId": "0\$\$Kvun3Z",
                  "isActive": true,
                  "modelId": "0\$\$664Fru",
                  "assignedBy": "Mayur Raval m.,Asite Solutions Ltd",
                  "recipientName": "Vijay Mavadiya (5336), Asite Solutions",
                  "recipientOrgId": "3",
                  "id": "ACTC13739622_707447_3_1_12331468_11624015",
                  "viewDate": "",
                  "assignedByOrgName": "Asite Solutions Ltd",
                  "distributionLevel": 0,
                  "distributionLevelId": "0\$\$LjDDAG",
                  "dueDateInMS": 1691560799000,
                  "actionCompleteDateInMS": 0,
                  "actionDelegated": false,
                  "actionCleared": false,
                  "actionCompleted": false,
                  "assignedByEmail": "m.raval@asite.com",
                  "assignedByRole": "",
                  "generateURI": true
                }
              ],
              "fixedFormData": {
                "DS_ALL_ACTIVE_FORM_STATUS": "{\"Items\":{\"Item\":[{\"Value\":\"23 # Deactivated\",\"Name\":\"Deactivated\"},{\"Value\":\"1001 # Open\",\"Name\":\"Open\"},{\"Value\":\"1002 # Resolved\",\"Name\":\"Resolved\"},{\"Value\":\"1003 # Verified\",\"Name\":\"Verified\"}]}}",
                "DS_WORKINGUSER_ID": "{\"Items\":{\"Item\":[{\"Value\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"Name\":\"Mayur Raval m., Asite Solutions Ltd\"}]}}",
                "DS_ORIGINATOR": "Mayur Raval m., Asite Solutions Ltd",
                "DS_MSGCREATOR": "Mayur Raval m., Asite Solutions Ltd",
                "DS_INCOMPLETE_ACTIONS": "{\"Items\":{\"Item\":[{\"Value\":\"|707447| # Respond\",\"Name\":\"Respond\"}]}}",
                "DS_ISDRAFT": "NO",
                "DS_ISDRAFT_FWD_MSG": "NO",
                "DS_MSGDATE": "2023-08-01 07:45:17",
                "DS_PROJDISTUSERS": "{\"Items\":{\"Item\":[{\"Value\":\"1161363#Chandresh Patel, Asite Solutions\",\"Name\":\"Chandresh Patel, Asite Solutions\"},{\"Value\":\"514806#Dhaval Vekaria (5226), Asite Solutions\",\"Name\":\"Dhaval Vekaria (5226), Asite Solutions\"},{\"Value\":\"859155#Saurabh Banethia (5327), Asite Solutions\",\"Name\":\"Saurabh Banethia (5327), Asite Solutions\"},{\"Value\":\"650044#savita dangee (5231), Asite Solutions\",\"Name\":\"savita dangee (5231), Asite Solutions\"},{\"Value\":\"707447#Vijay Mavadiya (5336), Asite Solutions\",\"Name\":\"Vijay Mavadiya (5336), Asite Solutions\"},{\"Value\":\"2017529#Mayur Raval m., Asite Solutions Ltd\",\"Name\":\"Mayur Raval m., Asite Solutions Ltd\"}]}}",
                "DS_FORMID": "SITE400",
                "DS_ALL_FORMSTATUS": "{\"Items\":{\"Item\":[{\"Value\":\"1001 # Open\",\"Name\":\"Open\"},{\"Value\":\"1002 # Resolved\",\"Name\":\"Resolved\"},{\"Value\":\"1003 # Verified\",\"Name\":\"Verified\"}]}}",
                "comboList": "DS_ALL_FORMSTATUS,DS_WORKINGUSER_ID,DS_ALL_ACTIVE_FORM_STATUS,DS_INCOMPLETE_ACTIONS,DS_Get_All_Responses,DS_PROJDISTUSERS,DS_CHECK_FORM_PERMISSION_USER,DS_ASI_SITE_getDefectTypesForProjects_pf",
                "DS_Get_All_Responses": "{\"Items\":{\"Item\":[]}}",
                "DS_ASI_SITE_getDefectTypesForProjects_pf": "{\"Items\":{\"Item\":[{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Architectural\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Civil\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Computer\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"EC\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Electrical\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Fire Safety\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Mechanical\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"}]}}",
                "DS_ISDRAFT_EDITORI": "NO",
                "DS_PROJECTNAME": "Site Quality Demo",
                "DS_FORMSTATUS": "Open",
                "DS_WORKINGUSER": "Mayur Raval m., Asite Solutions Ltd",
                "DS_FORMNAME": "Site Tasks",
                "DS_DATEOFISSUE": "2023-08-01 07:45:17",
                "DS_CHECK_FORM_PERMISSION_USER": "{\"Items\":{\"Item\":[{\"Value3\":\"All_Org\",\"Value4\":\"Yes\",\"Value1\":\"2130192\",\"Value2\":\"2017529\",\"Name\":\"DS_MTA_CHECK_FORM_PERMISSION_USER\"}]}}"
              },
              "ownerOrgName": "Asite Solutions",
              "ownerOrgId": 3,
              "originatorOrgId": 5763307,
              "msgUserOrgId": 5763307,
              "msgUserOrgName": "Asite Solutions Ltd",
              "msgUserName": "Mayur Raval m.",
              "originatorName": "Mayur Raval m.",
              "isPublic": false,
              "responseRequestByInMS": 0,
              "actionDateInMS": 0,
              "formGroupCode": "SITE",
              "isThumbnailSupports": false,
              "canAccessHistory": false,
              "projectStatusId": 5,
              "generateURI": true
            }
          ]
        }
      };
      when(() => mockProjectUseCase!.getFormMessageBatchList(any()))
          .thenAnswer((_) => Future.value(SUCCESS(formDetailResult, null, 200)));

      String selectOldAttachQuery = "SELECT * FROM FormMsgAttachAndAssocListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=1690869631580";
      ResultSet attchResultSet = ResultSet(
          ["ProjectId", "FormTypeId", "FormId", "MsgId", "AttachmentType", "AttachAssocDetailJson", "OfflineUploadFilePath", "AttachDocId", "AttachRevId", "AttachFileName", "AssocProjectId", "AssocDocFolderId", "AssocDocRevisionId", "AssocFormCommId", "AssocCommentMsgId", "AssocCommentId", "AssocCommentRevisionId", "AssocViewModelId", "AssocViewId", "AssocListModelId", "AssocListId", "AttachSize",]
          , null, [
        [
          "2130192",
          "11103151",
          "1690869631580",
          "1690869955199",
          "3",
          "{\"fileType\":\"filetype/jpg.gif\",\"fileName\":\"Image_1690869946283.jpg\",\"revisionId\":\"1690869955462337\",\"fileSize\":\"353 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690869955462337\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-08-01 11:35:55.055\",\"attachedDate\":\"2023-08-01 11:35:55.055\",\"attachedById\":\"2017529\",\"attachedByName\":\"Mayur Raval m.\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":1690869955199,\"msgCreationDate\":\"2023-08-01 11:35:55.055\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":1690869955199,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}",
          "./test/fixtures/database/1_808581/2130192/tempAttachments/Image_1690869946283.jpg",
          "1690869955462337",
          "1690869955462337",
          "Image_1690869946283.jpg",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "0"
        ],
        [
          "2130192",
          "11103151",
          "1690869631580",
          "1690869955199",
          "3",
          "{\"fileType\":\"filetype/jpg.gif\",\"fileName\":\"Image_1690869946713.jpg\",\"revisionId\":\"1690869955475827\",\"fileSize\":\"279 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690869955475827\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-08-01 11:35:55.055\",\"attachedDate\":\"2023-08-01 11:35:55.055\",\"attachedById\":\"2017529\",\"attachedByName\":\"Mayur Raval m.\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":1690869955199,\"msgCreationDate\":\"2023-08-01 11:35:55.055\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":1690869955199,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}",
          "./test/fixtures/database/1_808581/2130192/tempAttachments/Image_1690869946713.jpg",
          "1690869955475827",
          "1690869955475827",
          "Image_1690869946713.jpg",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "0"
        ]
      ]);
      when(() => mockDb!.selectFromTable(attachTableName, selectOldAttachQuery))
          .thenReturn(attchResultSet);
      String attachPath1 = "./test/fixtures/files/2130192/Attachments/27196803.jpg";
      when(() => mockFileUtility!.isFileExist(attachPath1))
          .thenReturn(false);
      String attachPath2 = "./test/fixtures/files/2130192/Attachments/27196802.jpg";
      when(() => mockFileUtility!.isFileExist(attachPath2))
          .thenReturn(false);
      String attachOldPath1 = "./test/fixtures/files/2130192/Attachments/1690869955462337.jpg";
      when(() => mockFileUtility!.isFileExist(attachOldPath1))
          .thenReturn(true);
      String attachOldPath2 = "./test/fixtures/files/2130192/Attachments/1690869955475827.jpg";
      when(() => mockFileUtility!.isFileExist(attachOldPath2))
          .thenReturn(true);
      when(() => mockFileUtility!.renameFile(any(), any()))
          .thenReturn(null);

      String removeFormQuery = "DELETE FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=1690869631580";
      when(() => mockDb!.executeQuery(removeFormQuery))
          .thenReturn(null);
      String removeFormMsgQuery = "DELETE FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=1690869631580";
      when(() => mockDb!.executeQuery(removeFormMsgQuery))
          .thenReturn(null);
      String removeFormMsgActQuery = "DELETE FROM FormMsgActionListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=1690869631580";
      when(() => mockDb!.executeQuery(removeFormMsgActQuery))
          .thenReturn(null);
      String removeFormMsgAttachQuery = "DELETE FROM FormMsgAttachAndAssocListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=1690869631580";
      when(() => mockDb!.executeQuery(removeFormMsgAttachQuery))
          .thenReturn(null);
      //Below changes for Form DAO mock
      String formTableName = "FormListTbl";
      String formTableQuery = "CREATE TABLE IF NOT EXISTS FormListTbl(ProjectId INTEGER NOT NULL,FormId TEXT NOT NULL,AppTypeId INTEGER,FormTypeId INTEGER,InstanceGroupId INTEGER NOT NULL,FormTitle TEXT,Code TEXT,CommentId INTEGER,MessageId INTEGER,ParentMessageId INTEGER,OrgId INTEGER,FirstName TEXT,LastName TEXT,OrgName TEXT,Originator TEXT,OriginatorDisplayName TEXT,NoOfActions INTEGER,ObservationId INTEGER,LocationId INTEGER,PfLocFolderId INTEGER,Updated TEXT,AttachmentImageName TEXT,MsgCode TEXT,TypeImage TEXT,DocType TEXT,HasAttachments INTEGER NOT NULL DEFAULT 0,HasDocAssocations INTEGER NOT NULL DEFAULT 0,HasBimViewAssociations INTEGER NOT NULL DEFAULT 0,HasFormAssocations INTEGER NOT NULL DEFAULT 0,HasCommentAssocations INTEGER NOT NULL DEFAULT 0,FormHasAssocAttach INTEGER NOT NULL DEFAULT 0,FormCreationDate TEXT,FolderId INTEGER,MsgTypeId INTEGER,MsgStatusId INTEGER,FormNumber INTEGER,MsgOriginatorId INTEGER,TemplateType INTEGER,IsDraft INTEGER NOT NULL DEFAULT 0,StatusId INTEGER,OriginatorId INTEGER,IsStatusChangeRestricted INTEGER NOT NULL DEFAULT 0,AllowReopenForm INTEGER NOT NULL DEFAULT 0,CanOrigChangeStatus INTEGER NOT NULL DEFAULT 0,MsgTypeCode TEXT,Id TEXT,StatusChangeUserId INTEGER,StatusUpdateDate TEXT,StatusChangeUserName TEXT,StatusChangeUserPic TEXT,StatusChangeUserEmail TEXT,StatusChangeUserOrg TEXT,OriginatorEmail TEXT,ControllerUserId INTEGER,UpdatedDateInMS INTEGER,FormCreationDateInMS INTEGER,ResponseRequestByInMS INTEGER,FlagType INTEGER,LatestDraftId INTEGER,FlagTypeImageName TEXT,MessageTypeImageName TEXT,CanAccessHistory INTEGER NOT NULL DEFAULT 0,FormJsonData TEXT,Status TEXT,AttachedDocs TEXT,IsUploadAttachmentInTemp INTEGER NOT NULL DEFAULT 0,IsSync INTEGER NOT NULL DEFAULT 0,UserRefCode TEXT,HasActions INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,IsOfflineCreated INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,IsForDefect INTEGER NOT NULL DEFAULT 0,IsForApps INTEGER NOT NULL DEFAULT 0,ObservationDefectTypeId TEXT NOT NULL DEFAULT '0',StartDate TEXT NOT NULL,ExpectedFinishDate TEXT NOT NULL,IsActive INTEGER NOT NULL DEFAULT 0,ObservationCoordinates TEXT,AnnotationId TEXT,IsCloseOut INTEGER NOT NULL DEFAULT 0,AssignedToUserId INTEGER NOT NULL,AssignedToUserName TEXT,AssignedToUserOrgName TEXT,MsgNum INTEGER,RevisionId INTEGER,RequestJsonForOffline TEXT,FormDueDays TEXT NOT NULL DEFAULT 0,FormSyncDate TEXT NOT NULL DEFAULT 0,LastResponderForAssignedTo TEXT NOT NULL DEFAULT '',LastResponderForOriginator TEXT NOT NULL DEFAULT '',PageNumber TEXT NOT NULL DEFAULT 0,ObservationDefectType TEXT,StatusName TEXT,AppBuilderId TEXT,TaskTypeName TEXT,AssignedToRoleName TEXT,PRIMARY KEY(ProjectId,FormId))";
      when(() => mockDb!.executeQuery(formTableQuery))
          .thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(formTableName))
          .thenReturn(["ProjectId", "FormId"]);
      String formSelectQuery = "SELECT ProjectId FROM FormListTbl WHERE ProjectId='2130192' AND FormId='11624015'";
      when(() => mockDb!.selectFromTable(formTableName, formSelectQuery))
          .thenReturn(ResultSet([], null, []));
      String frmBulkInsertQuery = "INSERT INTO FormListTbl (ProjectId,FormId,AppTypeId,FormTypeId,InstanceGroupId,FormTitle,Code,CommentId,MessageId,ParentMessageId,OrgId,FirstName,LastName,OrgName,Originator,OriginatorDisplayName,NoOfActions,ObservationId,LocationId,PfLocFolderId,Updated,AttachmentImageName,MsgCode,TypeImage,DocType,HasAttachments,HasDocAssocations,HasBimViewAssociations,HasFormAssocations,HasCommentAssocations,FormHasAssocAttach,FormCreationDate,FolderId,MsgTypeId,MsgStatusId,FormNumber,MsgOriginatorId,TemplateType,IsDraft,StatusId,OriginatorId,IsStatusChangeRestricted,AllowReopenForm,CanOrigChangeStatus,MsgTypeCode,Id,StatusChangeUserId,StatusUpdateDate,StatusChangeUserName,StatusChangeUserPic,StatusChangeUserEmail,StatusChangeUserOrg,OriginatorEmail,ControllerUserId,UpdatedDateInMS,FormCreationDateInMS,ResponseRequestByInMS,FlagType,LatestDraftId,FlagTypeImageName,MessageTypeImageName,CanAccessHistory,FormJsonData,Status,AttachedDocs,IsUploadAttachmentInTemp,IsSync,UserRefCode,HasActions,CanRemoveOffline,IsMarkOffline,IsOfflineCreated,SyncStatus,IsForDefect,IsForApps,ObservationDefectTypeId,StartDate,ExpectedFinishDate,IsActive,ObservationCoordinates,AnnotationId,IsCloseOut,AssignedToUserId,AssignedToUserName,AssignedToUserOrgName,MsgNum,RevisionId,RequestJsonForOffline,FormDueDays,FormSyncDate,LastResponderForAssignedTo,LastResponderForOriginator,PageNumber,ObservationDefectType,StatusName,AppBuilderId,TaskTypeName,AssignedToRoleName) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      //final frmValueList = [["2130192","11624015","2","11103151","10940318","Test Offlinr VJ Attachment","SITE400","11624015","12331468","0","5763307","Mayur","Raval m.","Asite Solutions Ltd","https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur","Mayur Raval m., Asite Solutions Ltd","0","107745","183678","115096348","01-Aug-2023#01:45 CST","icons/assocform.png","ORI001","icons/form.png","Apps",0,0,0,0,0,1,"01-Aug-2023#01:45 CST","0","1","20","400","2017529","2",0,"1001","2017529",0,0,0,"ORI","",0,"01-Aug-2023#01:45 CST","Mayur Raval m.","https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur","m.raval@asite.com","Asite Solutions Ltd","m.raval@asite.com","0","1690872318000","1690872317000","1691557199000","0","0","flag_type/flag_0.png","icons/form.png",1,"","Open","",0,0,"",0,0,0,0,0,0,0,"310493","2023-08-01","2023-08-08",1,"","",0,"707447","Vijay Mavadiya (5336)","Asite Solutions","","","","5","2023-08-01 07:45:17.883","707447","2017529","0","","Open","ASI-SITE","",""]];
      when(() => mockDb!.executeBulk(formTableName, frmBulkInsertQuery, any()))
          .thenAnswer((_) async=> null);

      //Below changes for FormMessage DAO mock
      String frmMsgTableName = "FormMessageListTbl";
      String frmMsgTableQuery = "CREATE TABLE IF NOT EXISTS FormMessageListTbl(ProjectId TEXT NOT NULL,FormTypeId TEXT NOT NULL,FormId TEXT NOT NULL,MsgId TEXT NOT NULL,Originator TEXT,OriginatorDisplayName TEXT,MsgCode TEXT,MsgCreatedDate TEXT,ParentMsgId TEXT,MsgOriginatorId TEXT,MsgHasAssocAttach INTEGER NOT NULL DEFAULT 0,JsonData TEXT,UserRefCode TEXT,UpdatedDateInMS TEXT,FormCreationDateInMS TEXT,MsgCreatedDateInMS TEXT,MsgTypeId TEXT,MsgTypeCode TEXT,MsgStatusId TEXT,SentNames TEXT,SentActions TEXT,DraftSentActions TEXT,FixFieldData TEXT,FolderId TEXT,LatestDraftId TEXT,IsDraft INTEGER NOT NULL DEFAULT 0,AssocRevIds TEXT,ResponseRequestBy TEXT,DelFormIds TEXT,AssocFormIds TEXT,AssocCommIds TEXT,FormUserSet TEXT,FormPermissionsMap TEXT,CanOrigChangeStatus INTEGER NOT NULL DEFAULT 0,CanControllerChangeStatus INTEGER NOT NULL DEFAULT 0,IsStatusChangeRestricted INTEGER NOT NULL DEFAULT 0,HasOverallStatus INTEGER NOT NULL DEFAULT 0,IsCloseOut INTEGER NOT NULL DEFAULT 0,AllowReopenForm INTEGER NOT NULL DEFAULT 0,OfflineRequestData TEXT NOT NULL DEFAULT \"\",IsOfflineCreated INTEGER NOT NULL DEFAULT 0,LocationId INTEGER,ObservationId INTEGER,MsgNum INTEGER,MsgContent TEXT,ActionComplete INTEGER NOT NULL DEFAULT 0,ActionCleared INTEGER NOT NULL DEFAULT 0,HasAttach INTEGER NOT NULL DEFAULT 0,TotalActions INTEGER,InstanceGroupId INTEGER,AttachFiles TEXT,HasViewAccess INTEGER NOT NULL DEFAULT 0,MsgOriginImage TEXT,IsForInfoIncomplete INTEGER NOT NULL DEFAULT 0,MsgCreatedDateOffline TEXT,LastModifiedTime TEXT,LastModifiedTimeInMS TEXT,CanViewDraftMsg INTEGER NOT NULL DEFAULT 0,CanViewOwnorgPrivateForms INTEGER NOT NULL DEFAULT 0,IsAutoSavedDraft INTEGER NOT NULL DEFAULT 0,MsgStatusName TEXT,ProjectAPDFolderId TEXT,ProjectStatusId TEXT,HasFormAccess INTEGER NOT NULL DEFAULT 0,CanAccessHistory INTEGER NOT NULL DEFAULT 0,HasDocAssocations INTEGER NOT NULL DEFAULT 0,HasBimViewAssociations INTEGER NOT NULL DEFAULT 0,HasBimListAssociations INTEGER NOT NULL DEFAULT 0,HasFormAssocations INTEGER NOT NULL DEFAULT 0,HasCommentAssocations INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId,FormId,MsgId))";
      when(() => mockDb!.executeQuery(frmMsgTableQuery))
          .thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(frmMsgTableName))
          .thenReturn(["ProjectId", "FormId", "MsgId"]);
      String frmMsgSelectQuery = "SELECT ProjectId FROM FormMessageListTbl WHERE ProjectId='2130192' AND FormId='11624015' AND MsgId='12331468'";
      when(() => mockDb!.selectFromTable(frmMsgTableName, frmMsgSelectQuery))
          .thenReturn(ResultSet([], null, []));
      String frmMsgBulkInsertQuery = "INSERT INTO FormMessageListTbl (ProjectId,FormTypeId,FormId,MsgId,Originator,OriginatorDisplayName,MsgCode,MsgCreatedDate,ParentMsgId,MsgOriginatorId,MsgHasAssocAttach,JsonData,UserRefCode,UpdatedDateInMS,FormCreationDateInMS,MsgCreatedDateInMS,MsgTypeId,MsgTypeCode,MsgStatusId,SentNames,SentActions,DraftSentActions,FixFieldData,FolderId,LatestDraftId,IsDraft,AssocRevIds,ResponseRequestBy,DelFormIds,AssocFormIds,AssocCommIds,FormUserSet,FormPermissionsMap,CanOrigChangeStatus,CanControllerChangeStatus,IsStatusChangeRestricted,HasOverallStatus,IsCloseOut,AllowReopenForm,OfflineRequestData,IsOfflineCreated,LocationId,ObservationId,MsgNum,MsgContent,ActionComplete,ActionCleared,HasAttach,TotalActions,InstanceGroupId,AttachFiles,HasViewAccess,MsgOriginImage,IsForInfoIncomplete,MsgCreatedDateOffline,LastModifiedTime,LastModifiedTimeInMS,CanViewDraftMsg,CanViewOwnorgPrivateForms,IsAutoSavedDraft,MsgStatusName,ProjectAPDFolderId,ProjectStatusId,HasFormAccess,CanAccessHistory,HasDocAssocations,HasBimViewAssociations,HasBimListAssociations,HasFormAssocations,HasCommentAssocations) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      final frmMsgValueList = [
        [
          "2130192",
          "11103151",
          "11624015",
          "12331468",
          "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "Mayur Raval m., Asite Solutions Ltd",
          "ORI001",
          "01-Aug-2023#01:45 CST",
          "0",
          "2017529",
          1,
          "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"DistributionDays\":\"0\",\"Organization\":\"\",\"DefectTyoe\":\"Computer\",\"ExpectedFinishDate\":\"2023-08-08\",\"DefectDescription\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"707447#Vijay Mavadiya (5336), Asite Solutions\"}},\"Defect_Description\":\"test description\",\"LocationName\":\"01 Vijay_Test\",\"StartDate\":\"2023-08-01\",\"ActualFinishDate\":\"\",\"ExpectedFinishDays\":\"5\",\"DS_Logo\":\"images/asite.gif\",\"LastResponder_For_AssignedTo\":\"707447\",\"TaskType\":\"Defect\",\"isCalibrated\":false,\"ORI_FORMTITLE\":\"Test Offlinr VJ Attachment\",\"attachements\":[{\"attachedDocs\":\"\"}],\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"Assigned\":\"Vijay Mavadiya (5336), Asite Solutions\",\"CurrStage\":\"1\",\"Recent_Defects\":\"\",\"FormCreationDate\":\"\",\"StartDateDisplay\":\"01-Aug-2023\",\"LastResponder_For_Originator\":\"2017529\",\"PF_Location_Detail\":\"183678|0|null|0\",\"Username\":\"\",\"ORI_USERREF\":\"\",\"Location\":\"183678|01 Vijay_Test|01 Vijay_Test\"},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"SHResponse\":\"Yes\",\"ShowHideFlag\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_CREATE\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\",\"DS_FORMAUTONO_ADD\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_Get_All_Responses\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"attachments\":[],\"Asite_System_Data_Read_Only\":{\"_2_Printing_Data\":{\"DS_PRINTEDON\":\"\",\"DS_PRINTEDBY\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\",\"DS_FORMNAME\":\"Site Tasks\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"\",\"DS_CLIENT\":\"\"},\"_5_Form_Data\":{\"DS_DATEOFISSUE\":\"\",\"DS_ISDRAFT_RES_MSG\":\"\",\"Status_Data\":{\"DS_APPROVEDON\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_APPROVEDBY\":\"\",\"DS_CLOSE_DUE_DATE\":\"2023-08-08\",\"DS_FORMSTATUS\":\"\"},\"DS_DISTRIBUTION\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT_RES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_FORMID\":\"\"},\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_6_Form_MSG_Data\":{\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGID\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_PROJUSERS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_ACTIONDUEDATE\":\"5\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_PROJDISTUSERS\":\"707447\"}]}},\"selectedControllerUserId\":\"\"}}",
          "N/A",
          "1690872318000",
          "1690872317000",
          "1690872317000",
          "1",
          "ORI",
          "20",
          "[\"Vijay Mavadiya (5336), Asite Solutions\"]",
          "[{\"projectId\":\"0\$\$xxvKpe\",\"resourceParentId\":11624015,\"resourceId\":12331468,\"resourceCode\":\"ORI001\",\"resourceStatusId\":0,\"msgId\":\"12331468\$\$xotfl6\",\"commentMsgId\":\"12331468\$\$tUZdFh\",\"actionId\":3,\"actionName\":\"Respond\",\"actionStatus\":0,\"priorityId\":0,\"actionDate\":\"Tue Aug 01 08:45:17 BST 2023\",\"dueDate\":\"Wed Aug 09 06:59:59 BST 2023\",\"distributorUserId\":2017529,\"recipientId\":707447,\"remarks\":\"\",\"distListId\":13739622,\"transNum\":\"-1\",\"actionTime\":\"7 Days\",\"actionCompleteDate\":\"\",\"instantEmailNotify\":\"true\",\"actionNotes\":\"\",\"entityType\":0,\"instanceGroupId\":\"0\$\$Kvun3Z\",\"isActive\":true,\"modelId\":\"0\$\$664Fru\",\"assignedBy\":\"Mayur Raval m.,Asite Solutions Ltd\",\"recipientName\":\"Vijay Mavadiya (5336), Asite Solutions\",\"recipientOrgId\":\"3\",\"id\":\"ACTC13739622_707447_3_1_12331468_11624015\",\"viewDate\":\"\",\"assignedByOrgName\":\"Asite Solutions Ltd\",\"distributionLevel\":0,\"distributionLevelId\":\"0\$\$LjDDAG\",\"dueDateInMS\":1691560799000,\"actionCompleteDateInMS\":0,\"actionDelegated\":false,\"actionCleared\":false,\"actionCompleted\":false,\"assignedByEmail\":\"m.raval@asite.com\",\"assignedByRole\":\"\",\"generateURI\":true}]",
          "",
          "{\"DS_ALL_ACTIVE_FORM_STATUS\":\"{\\\"Items\\\":{\\\"Item\\\":[{\\\"Value\\\":\\\"23 # Deactivated\\\",\\\"Name\\\":\\\"Deactivated\\\"},{\\\"Value\\\":\\\"1001 # Open\\\",\\\"Name\\\":\\\"Open\\\"},{\\\"Value\\\":\\\"1002 # Resolved\\\",\\\"Name\\\":\\\"Resolved\\\"},{\\\"Value\\\":\\\"1003 # Verified\\\",\\\"Name\\\":\\\"Verified\\\"}]}}\",\"DS_WORKINGUSER_ID\":\"{\\\"Items\\\":{\\\"Item\\\":[{\\\"Value\\\":\\\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\\\",\\\"Name\\\":\\\"Mayur Raval m., Asite Solutions Ltd\\\"}]}}\",\"DS_ORIGINATOR\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_MSGCREATOR\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_INCOMPLETE_ACTIONS\":\"{\\\"Items\\\":{\\\"Item\\\":[{\\\"Value\\\":\\\"|707447| # Respond\\\",\\\"Name\\\":\\\"Respond\\\"}]}}\",\"DS_ISDRAFT\":\"NO\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_MSGDATE\":\"2023-08-01 07:45:17\",\"DS_PROJDISTUSERS\":\"{\\\"Items\\\":{\\\"Item\\\":[{\\\"Value\\\":\\\"1161363#Chandresh Patel, Asite Solutions\\\",\\\"Name\\\":\\\"Chandresh Patel, Asite Solutions\\\"},{\\\"Value\\\":\\\"514806#Dhaval Vekaria (5226), Asite Solutions\\\",\\\"Name\\\":\\\"Dhaval Vekaria (5226), Asite Solutions\\\"},{\\\"Value\\\":\\\"859155#Saurabh Banethia (5327), Asite Solutions\\\",\\\"Name\\\":\\\"Saurabh Banethia (5327), Asite Solutions\\\"},{\\\"Value\\\":\\\"650044#savita dangee (5231), Asite Solutions\\\",\\\"Name\\\":\\\"savita dangee (5231), Asite Solutions\\\"},{\\\"Value\\\":\\\"707447#Vijay Mavadiya (5336), Asite Solutions\\\",\\\"Name\\\":\\\"Vijay Mavadiya (5336), Asite Solutions\\\"},{\\\"Value\\\":\\\"2017529#Mayur Raval m., Asite Solutions Ltd\\\",\\\"Name\\\":\\\"Mayur Raval m., Asite Solutions Ltd\\\"}]}}\",\"DS_FORMID\":\"SITE400\",\"DS_ALL_FORMSTATUS\":\"{\\\"Items\\\":{\\\"Item\\\":[{\\\"Value\\\":\\\"1001 # Open\\\",\\\"Name\\\":\\\"Open\\\"},{\\\"Value\\\":\\\"1002 # Resolved\\\",\\\"Name\\\":\\\"Resolved\\\"},{\\\"Value\\\":\\\"1003 # Verified\\\",\\\"Name\\\":\\\"Verified\\\"}]}}\",\"comboList\":\"DS_ALL_FORMSTATUS,DS_WORKINGUSER_ID,DS_ALL_ACTIVE_FORM_STATUS,DS_INCOMPLETE_ACTIONS,DS_Get_All_Responses,DS_PROJDISTUSERS,DS_CHECK_FORM_PERMISSION_USER,DS_ASI_SITE_getDefectTypesForProjects_pf\",\"DS_Get_All_Responses\":\"{\\\"Items\\\":{\\\"Item\\\":[]}}\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"{\\\"Items\\\":{\\\"Item\\\":[{\\\"Value3\\\":\\\"\\\",\\\"Value4\\\":\\\"\\\",\\\"Value1\\\":\\\"Architectural\\\",\\\"Value2\\\":\\\"\\\",\\\"Name\\\":\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\"},{\\\"Value3\\\":\\\"\\\",\\\"Value4\\\":\\\"\\\",\\\"Value1\\\":\\\"Civil\\\",\\\"Value2\\\":\\\"\\\",\\\"Name\\\":\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\"},{\\\"Value3\\\":\\\"\\\",\\\"Value4\\\":\\\"\\\",\\\"Value1\\\":\\\"Computer\\\",\\\"Value2\\\":\\\"\\\",\\\"Name\\\":\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\"},{\\\"Value3\\\":\\\"\\\",\\\"Value4\\\":\\\"\\\",\\\"Value1\\\":\\\"EC\\\",\\\"Value2\\\":\\\"\\\",\\\"Name\\\":\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\"},{\\\"Value3\\\":\\\"\\\",\\\"Value4\\\":\\\"\\\",\\\"Value1\\\":\\\"Electrical\\\",\\\"Value2\\\":\\\"\\\",\\\"Name\\\":\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\"},{\\\"Value3\\\":\\\"\\\",\\\"Value4\\\":\\\"\\\",\\\"Value1\\\":\\\"Fire Safety\\\",\\\"Value2\\\":\\\"\\\",\\\"Name\\\":\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\"},{\\\"Value3\\\":\\\"\\\",\\\"Value4\\\":\\\"\\\",\\\"Value1\\\":\\\"Mechanical\\\",\\\"Value2\\\":\\\"\\\",\\\"Name\\\":\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\"}]}}\",\"DS_ISDRAFT_EDITORI\":\"NO\",\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_FORMSTATUS\":\"Open\",\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_FORMNAME\":\"Site Tasks\",\"DS_DATEOFISSUE\":\"2023-08-01 07:45:17\",\"DS_CHECK_FORM_PERMISSION_USER\":\"{\\\"Items\\\":{\\\"Item\\\":[{\\\"Value3\\\":\\\"All_Org\\\",\\\"Value4\\\":\\\"Yes\\\",\\\"Value1\\\":\\\"2130192\\\",\\\"Value2\\\":\\\"2017529\\\",\\\"Name\\\":\\\"DS_MTA_CHECK_FORM_PERMISSION_USER\\\"}]}}\"}",
          "0",
          "0",
          0,
          "",
          "08-Aug-2023#23:59 CST",
          "",
          "",
          "",
          "[]",
          "{\"can_edit_ORI\":false,\"can_respond\":false,\"restrictChangeFormStatus\":false,\"controllerUserId\":0,\"isProjectArchived\":false,\"can_distribute\":false,\"can_forward\":false,\"oriMsgId\":\"12331468\$\$xotfl6\"}",
          0,
          0,
          0,
          1,
          0,
          1,
          "",
          0,
          "183678",
          "107745",
          "",
          "",
          0,
          0,
          1,
          "",
          "10940318",
          "",
          0,
          "",
          0,
          "",
          "",
          "",
          0,
          0,
          0,
          "Sent",
          "110997340",
          "5",
          0,
          0,
          0,
          0,
          0,
          0,
          0
        ]
      ];
      when(() => mockDb!.executeBulk(frmMsgTableName, frmMsgBulkInsertQuery, frmMsgValueList))
          .thenAnswer((_) async=> null);

      //Below changes for FormMessageAttach DAO mock
      String frmMsgAttachTableName = "FormMsgAttachAndAssocListTbl";
      String frmMsgAttachTableQuery = "CREATE TABLE IF NOT EXISTS FormMsgAttachAndAssocListTbl(ProjectId TEXT NOT NULL,FormTypeId TEXT NOT NULL,FormId TEXT NOT NULL,MsgId TEXT NOT NULL,AttachmentType TEXT NOT NULL,AttachAssocDetailJson TEXT NOT NULL,OfflineUploadFilePath TEXT,AttachDocId TEXT,AttachRevId TEXT,AttachFileName TEXT,AssocProjectId TEXT,AssocDocFolderId TEXT,AssocDocRevisionId TEXT,AssocFormCommId TEXT,AssocCommentMsgId TEXT,AssocCommentId TEXT,AssocCommentRevisionId TEXT,AssocViewModelId TEXT,AssocViewId TEXT,AssocListModelId TEXT,AssocListId TEXT,AttachSize TEXT)";
      when(() => mockDb!.executeQuery(frmMsgAttachTableQuery))
          .thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(frmMsgAttachTableName))
          .thenReturn([""]);
      String frmMsgAttachSelectQuery = "SELECT  FROM FormMsgAttachAndAssocListTbl WHERE ='null'";
      when(() => mockDb!.selectFromTable(frmMsgAttachTableName, frmMsgAttachSelectQuery))
          .thenReturn(ResultSet([], null, []));
      when(() => mockDb!.executeBulk(frmMsgAttachTableName, any(), any()))
          .thenAnswer((_) async=> null);

      String requestFilePath = "./test/fixtures/database/1_808581/2130192/OfflineRequestData/1690869955199.txt";
      when(() => mockFileUtility!.deleteFileAtPath(requestFilePath, recursive: false))
          .thenAnswer((_) => Future.value(null));

      await PushToServerFormSyncTask(syncTask, (eSyncTaskType, eSyncStatus, data) async {},).syncFormDataToServer(paramData, null);
      verify(() => mockFileUtility!.readFromFile(reqFilePath)).called(1);
      verify(() => mockDb!.selectFromTable(attachTableName, attachQuery)).called(1);
      verify(() => mockUseCase!.saveFormToServer(any())).called(1);
      verify(() => mockProjectUseCase!.getFormMessageBatchList(any())).called(1);

      verify(() => mockDb!.selectFromTable(attachTableName, selectOldAttachQuery)).called(1);
      verify(() => mockFileUtility!.isFileExist(attachPath1)).called(1);
      verify(() => mockFileUtility!.isFileExist(attachPath2)).called(1);
      verify(() => mockFileUtility!.isFileExist(attachOldPath1)).called(1);
      verify(() => mockFileUtility!.isFileExist(attachOldPath2)).called(1);
      verify(() => mockFileUtility!.renameFile(any(), any())).called(2);
      verify(() => mockDb!.executeQuery(removeFormQuery)).called(1);
      verify(() => mockDb!.executeQuery(removeFormMsgQuery)).called(1);
      verify(() => mockDb!.executeQuery(removeFormMsgActQuery)).called(1);
      verify(() => mockDb!.executeQuery(removeFormMsgAttachQuery)).called(1);
      //Below changes for Form DAO mock
      verify(() => mockDb!.executeQuery(formTableQuery)).called(1);
      verify(() => mockDb!.getPrimaryKeys(formTableName)).called(1);
      verify(() => mockDb!.selectFromTable(formTableName, formSelectQuery)).called(1);
      verify(() => mockDb!.executeBulk(formTableName, frmBulkInsertQuery, any())).called(1);
      //Below changes for FormMessage DAO mock
      verify(() => mockDb!.executeQuery(frmMsgTableQuery)).called(1);
      verify(() => mockDb!.getPrimaryKeys(frmMsgTableName)).called(1);
      verify(() => mockDb!.selectFromTable(frmMsgTableName, frmMsgSelectQuery)).called(1);
      verify(() => mockDb!.executeBulk(frmMsgTableName, frmMsgBulkInsertQuery, frmMsgValueList)).called(1);

      verify(() => mockDb!.executeQuery(frmMsgAttachTableQuery)).called(1);
      verify(() => mockDb!.getPrimaryKeys(frmMsgAttachTableName)).called(1);
      verify(() => mockDb!.selectFromTable(frmMsgAttachTableName, frmMsgAttachSelectQuery)).called(3);
      verify(() => mockDb!.executeBulk(frmMsgAttachTableName, any(), any())).called(1);

      verify(() => mockFileUtility!.deleteFileAtPath(requestFilePath, recursive: false)).called(1);
    });

    test('syncFormDataToServer edit draft form with inline attachment test', () async {
      SyncRequestTask syncTask = SyncRequestTask();
      var paramData = {
        "RequestType": EOfflineSyncRequestType.CreateOrRespond.value.toString(),
        "ProjectId": "2130192",
        "FormId": "11626957",
        "MsgId": "12336222",
        "UpdatedDateInMS": "1690981655584",
      };

      String requestData = "{\"projectId\":\"2130192\",\"locationId\":183885,\"observationId\":107888,\"formId\":\"11626957\",\"formTypeId\":\"11070450\",\"templateType\":2,\"appTypeId\":2,\"appBuilderId\":\"Att-Inline\",\"formSelectRadiobutton\":\"1_2130192_11070450\",\"isUploadAttachmentInTemp\":null,\"offlineFormDataJson\":\"{\\\"myFields\\\":{\\\"attachments\\\":[],\\\"Attachment_1\\\":[],\\\"Attachment_2\\\":[{\\\"@inline\\\":\\\"xdoc_0_4_9_9_my:Attachment_2\\\",\\\"@caption\\\":\\\"flower-1.jpg\\\",\\\"content\\\":\\\"2130192#11070450#12336222#12336222_xdoc_0_4_9_9_my#12336222_xdoc_0_4_9_9_my_flower-1.jpg#27205191\\\"}],\\\"Attachment_3\\\":[{\\\"@inline\\\":\\\"xdoc_0_6_1_9_my:Attachment_3\\\",\\\"content\\\":\\\"\\\",\\\"@caption\\\":\\\"emulator-self.jpg\\\",\\\"OfflineContent\\\":{\\\"fileType\\\":6,\\\"isThumbnailSupports\\\":true,\\\"upFilePath\\\":\\\"./test/fixtures/database/1_808581/2130192/tempAttachments/emulator-self.jpg\\\"}}],\\\"extraParams\\\":null,\\\"Attachment\\\":[{\\\"@inline\\\":\\\"xdoc_0_3_9_0_my:Attachment\\\",\\\"@caption\\\":\\\"23346556.jpg\\\",\\\"content\\\":\\\"2130192#11070450#12336222#12336222_xdoc_0_3_9_0_my#12336222_xdoc_0_3_9_0_my_23346556.jpg#27205192\\\"}],\\\"City\\\":\\\"Ahmadabad\\\",\\\"Asite_System_Data_Read_Write\\\":{\\\"ORI_MSG_Fields\\\":{\\\"SP_ORI_VIEW_HTML\\\":\\\"\\\",\\\"SP_RES_PRINT_VIEW\\\":\\\"\\\",\\\"CA_ORI_PRINT_VIEW_HTML\\\":\\\"State##City\\\",\\\"attributeSetId\\\":\\\"118281\\\",\\\"CA_ORI_VIEW\\\":\\\"State##City\\\",\\\"SP_ORI_PRINT_VIEW\\\":\\\"\\\",\\\"SP_ORI_VIEW\\\":\\\"\\\",\\\"SP_RES_VIEW\\\":\\\"\\\",\\\"SP_ORI_PRINT_VIEW_HTML\\\":\\\"\\\",\\\"SP_RES_VIEW_HTML\\\":\\\"\\\",\\\"CA_ORI_VIEW_HTML\\\":\\\"State##City\\\",\\\"SP_RES_PRINT_VIEW_HTML\\\":\\\"\\\",\\\"CA_ORI_PRINT_VIEW\\\":\\\"State##City\\\"}},\\\"ORI_FORMTITLE_Copy\\\":\\\"Inline Attachment VJ Test\\\",\\\"attachment_fields\\\":\\\"xdoc_0_9_6_0_my:Attachment_2#xdoc_0_4_9_9_my:Attachment_2#xdoc_0_3_9_0_my:Attachment\\\",\\\"State\\\":\\\"Gujarat\\\",\\\"ORI_FORMTITLE\\\":\\\"Inline Attachment VJ Test\\\",\\\"selectedControllerUserId\\\":\\\"\\\",\\\"dist_list\\\":\\\"{\\\\\\\"selectedDistGroups\\\\\\\":\\\\\\\"\\\\\\\",\\\\\\\"selectedDistUsers\\\\\\\":[],\\\\\\\"selectedDistOrgs\\\\\\\":[],\\\\\\\"selectedDistRoles\\\\\\\":[],\\\\\\\"prePopulatedDistGroups\\\\\\\":\\\\\\\"\\\\\\\"}\\\",\\\"respondBy\\\":\\\"30-Aug-2023\\\",\\\"create_hidden_list\\\":{\\\"msg_type_id\\\":\\\"1\\\",\\\"msg_type_code\\\":\\\"ORI\\\",\\\"parent_msg_id\\\":\\\"0\\\",\\\"dist_list\\\":\\\"{\\\\\\\"selectedDistGroups\\\\\\\":\\\\\\\"\\\\\\\",\\\\\\\"selectedDistUsers\\\\\\\":[],\\\\\\\"selectedDistOrgs\\\\\\\":[],\\\\\\\"selectedDistRoles\\\\\\\":[],\\\\\\\"prePopulatedDistGroups\\\\\\\":\\\\\\\"\\\\\\\"}\\\",\\\"assocLocationSelection\\\":\\\"{\\\\\\\"locationId\\\\\\\":183885}\\\",\\\"project_id\\\":\\\"2130192\\\",\\\"offlineProjectId\\\":\\\"2130192\\\",\\\"offlineFormTypeId\\\":\\\"11070450\\\",\\\"editORI\\\":\\\"false\\\",\\\"requestType\\\":\\\"2\\\",\\\"msgId\\\":\\\"12336222\\\",\\\"formAction\\\":\\\"edit\\\",\\\"editDraft\\\":\\\"true\\\",\\\"attachedDocs0\\\":\\\"13658735\\\",\\\"attachedDocs1\\\":\\\"13658734\\\",\\\"respondBy\\\":\\\"30-Aug-2023\\\",\\\"appTypeId\\\":\\\"2\\\",\\\"isThumbnailSupports\\\":\\\"true\\\"}}}\",\"isDraft\":true,\"offlineFormCreatedDateInMS\":\"1690981655584\",\"formTypeCode\":\"INAT\",\"formTypeName\":\"Attachment\",\"instanceGroupId\":\"11062773\",\"assocLocationSelection\":\"{\\\"locationId\\\":\\\"183885\\\",\\\"projectId\\\":\\\"2130192\\\"}\"}";
      String reqFilePath = "./test/fixtures/database/1_808581/2130192/OfflineRequestData/12336222.txt";
      when(() => mockFileUtility!.readFromFile(reqFilePath))
          .thenReturn(requestData);

      ResultSet resultSet = ResultSet([], null, []);
      String attachQuery = "SELECT AttachRevId,OfflineUploadFilePath FROM FormMsgAttachAndAssocListTbl WHERE ProjectId=2130192 AND FormId=11626957 AND MsgId=12336222 AND OfflineUploadFilePath <> ''";
      String attachTableName = "FormMsgAttachAndAssocListTbl";
      when(() => mockDb!.selectFromTable(attachTableName, attachQuery))
          .thenReturn(resultSet);

      ResultSet resultSet1 = ResultSet(
          ["AttachmentType", "AttachAssocDetailJson", "AttachFileName"],
          null,
          [
            [
              "3",
              "{\"fileType\":\"filetype/jpg.gif\",\"fileName\":\"flower-1.jpg\",\"revisionId\":\"27205191\",\"fileSize\":\"416 KB\",\"hasAccess\":true,\"canDownload\":true,\"publisherUserId\":\"0\",\"hasBravaSupport\":true,\"docId\":\"13658734\",\"attachedBy\":\"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur\",\"attachedDateInTimeStamp\":\"Aug 2, 2023 10:55:00 AM\",\"attachedDate\":\"02-Aug-2023#04:55 CST\",\"createdDateInTimeStamp\":\"Aug 2, 2023 10:55:00 AM\",\"attachedById\":\"2017529\",\"attachedByName\":\"Mayur Raval m.\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":\"0\",\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":\"0\",\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"viewAlwaysFormAssociationParent\":true,\"viewAlwaysDocAssociationParent\":false,\"allowDownloadToken\":\"1\",\"isHoopsSupported\":false,\"isPDFTronSupported\":false,\"downloadImageName\":\"icons/downloads.png\",\"hasOnlineViewerSupport\":true,\"newSysLocation\":\"project_2130192/formtype_11070450/form_11070450/msg_12336222/27205191.jpg\",\"hashedAttachedById\":\"2017529\$\$wmohiM\",\"hasGeoTagInfo\":false,\"locationPath\":\"Site Quality Demo\\\\01 Vijay_Test\\\\Plan-3\\\\Loc_3\",\"type\":\"3\",\"msgId\":\"12336222\",\"msgCreationDate\":\"Aug 2, 2023 10:55:00 AM\",\"projectId\":\"2130192\",\"folderId\":\"116305143\",\"dcId\":\"1\",\"childProjectId\":\"0\",\"userId\":\"0\",\"resourceId\":\"0\",\"parentMsgId\":\"12336222\",\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"totalDocCount\":\"0\",\"generateURI\":true,\"hasHoopsViewerSupport\":false}",
              "flower-1.jpg"
            ]
          ]);
      String attachQuery1 = "SELECT AttachmentType,AttachAssocDetailJson,AttachFileName FROM FormMsgAttachAndAssocListTbl WHERE ProjectId=2130192 AND (AttachRevId=27205191 OR AssocDocRevisionId=27205191)";
      when(() => mockDb!.selectFromTable(attachTableName, attachQuery1))
          .thenReturn(resultSet1);
      ResultSet resultSet2 = ResultSet(
          ["AttachmentType", "AttachAssocDetailJson", "AttachFileName"],
          null,
          [
            [
              "3",
              "{\"fileType\":\"filetype/jpg.gif\",\"fileName\":\"23346556.jpg\",\"revisionId\":\"27205192\",\"fileSize\":\"1169 KB\",\"hasAccess\":true,\"canDownload\":true,\"publisherUserId\":\"0\",\"hasBravaSupport\":true,\"docId\":\"13658735\",\"attachedBy\":\"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur\",\"attachedDateInTimeStamp\":\"Aug 2, 2023 10:55:00 AM\",\"attachedDate\":\"02-Aug-2023#04:55 CST\",\"createdDateInTimeStamp\":\"Aug 2, 2023 10:55:00 AM\",\"attachedById\":\"2017529\",\"attachedByName\":\"Mayur Raval m.\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":\"0\",\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":\"0\",\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"viewAlwaysFormAssociationParent\":true,\"viewAlwaysDocAssociationParent\":false,\"allowDownloadToken\":\"1\",\"isHoopsSupported\":false,\"isPDFTronSupported\":false,\"downloadImageName\":\"icons/downloads.png\",\"hasOnlineViewerSupport\":true,\"newSysLocation\":\"project_2130192/formtype_11070450/form_11070450/msg_12336222/27205192.jpg\",\"hashedAttachedById\":\"2017529\$\$wmohiM\",\"hasGeoTagInfo\":false,\"locationPath\":\"Site Quality Demo\\\\01 Vijay_Test\\\\Plan-3\\\\Loc_3\",\"type\":\"3\",\"msgId\":\"12336222\",\"msgCreationDate\":\"Aug 2, 2023 10:55:00 AM\",\"projectId\":\"2130192\",\"folderId\":\"116305143\",\"dcId\":\"1\",\"childProjectId\":\"0\",\"userId\":\"0\",\"resourceId\":\"0\",\"parentMsgId\":\"12336222\",\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"totalDocCount\":\"0\",\"generateURI\":true,\"hasHoopsViewerSupport\":false}",
              "23346556.jpg"
            ]
          ]);
      String attachQuery2 = "SELECT AttachmentType,AttachAssocDetailJson,AttachFileName FROM FormMsgAttachAndAssocListTbl WHERE ProjectId=2130192 AND (AttachRevId=27205192 OR AssocDocRevisionId=27205192)";
      when(() => mockDb!.selectFromTable(attachTableName, attachQuery2))
          .thenReturn(resultSet2);
      String strInlineUpFile = "./test/fixtures/database/1_808581/2130192/tempAttachments/emulator-self.jpg";
      when(() => mockFileUtility!.getFileSizeSync(strInlineUpFile))
          .thenReturn(1000);

      final saveFormResult = {
        "formDetailsVO": {
          "templateType": 2,
          "responseRequestByInMS": 1693457999000,
          "pfLocFolderId": 115333487,
          "workflowStatus": "",
          "isDraft": true,
          "formCreationDate": "02-Aug-2023#04:54 CST",
          "userID": "2017529\$\$wmohiM",
          "observationVO": {"msgNum": 0, "pageNumber": 1, "attachments": [], "isDraft": false, "formDueDays": 0, "msgId": "0\$\$wJQOqu", "isActive": true, "orgId": "0\$\$cENRKN", "noOfActions": 0, "observationTypeId": 0, "observationId": 0, "hasAttachment": false, "locationId": 0, "appType": 0, "noOfMessages": 0, "isCloseOut": false, "originatorId": 0, "formId": "0\$\$PcGnvl", "assignedToUserId": 0, "formTypeId": "0\$\$PcGnvl", "formSyncDate": "2023-08-02 14:16:47.25", "annotationId": "ee8302f6-1064-46f3-9386-2f6a73a14047-1690959854669", "observationCoordinates": "{\"x1\":544.4387379807692,\"y1\":224.61046577515856,\"x2\":554.4387379807692,\"y2\":234.61046577515856}", "generateURI": true, "manageTypeVo": {"isDeactive": false, "id": "0", "projectId": "2130192\$\$lpO1g2", "generateURI": true}, "statusId": 0, "isStatusChangeRestricted": false, "allowReopenForm": false, "messages": [], "instanceGroupId": "0\$\$PcGnvl", "projectId": "0\$\$XboXFB"},
          "msgStatusId": 19,
          "statusid": 2,
          "canControllerChangeStatus": false,
          "appTypeId": "2",
          "invoiceCountAgainstOrder": "-1",
          "workflowStage": "",
          "hasBimViewAssociations": false,
          "id": "DRAFT",
          "msgCode": "ORI001",
          "formGroupName": "Attachment",
          "statusChangeUserId": 0,
          "originatorDisplayName": "Mayur Raval m., Asite Solutions Ltd",
          "msgUserOrgId": 5763307,
          "allowReopenForm": false,
          "canAccessHistory": true,
          "latestDraftId": "0\$\$wJQOqu",
          "status": "Open",
          "canOrigChangeStatus": false,
          "lastName": "Raval m.",
          "originatorName": "Mayur Raval m.",
          "controllerUserId": 0,
          "msgId": "12336222\$\$A2C5Du",
          "originatorEmail": "m.raval@asite.com",
          "msgUserName": "Mayur Raval m.",
          "orgId": "5763307\$\$ZxLI32",
          "msgHasAssocAttach": false,
          "locationId": 183885,
          "appType": "Field",
          "noOfMessages": 0,
          "originatorOrgId": 5763307,
          "isCloseOut": false,
          "originatorId": 2017529,
          "hasAttachments": false,
          "formHasAssocAttach": true,
          "actionDateInMS": 0,
          "msgUserOrgName": "Asite Solutions Ltd",
          "hasFormAccess": false,
          "docType": "Apps",
          "generateURI": true,
          "responseRequestBy": "30-Aug-2023#23:59 CST",
          "parentMsgId": 0,
          "commId": "11626957\$\$zdr6oQ",
          "ownerOrgId": 3,
          "instanceGroupId": "11062773\$\$WPG4nZ",
          "isThumbnailSupports": false,
          "hasBimListAssociations": false,
          "msgTypeCode": "ORI",
          "appBuilderId": "Att-Inline",
          "hasDocAssocations": false,
          "noOfActions": 0,
          "observationId": 107888,
          "formTypeName": "Attachment",
          "statusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "formId": "11626957\$\$ru4m4R",
          "hasOverallStatus": false,
          "orgName": "Asite Solutions Ltd",
          "msgOriginatorId": 2017529,
          "formTypeId": "11070450\$\$BECT4X",
          "folderId": "0\$\$02dNOR",
          "firstName": "Mayur",
          "lastmodified": "2023-08-02T10:54:59Z",
          "formPrintEnabled": false,
          "project_APD_folder_id": "0\$\$02dNOR",
          "projectName": "Site Quality Demo",
          "formNum": 0,
          "projectId": "2130192\$\$lpO1g2",
          "updated": "02-Aug-2023#04:54 CST",
          "messageTypeImageName": "icons/form.png",
          "code": "DRAFT",
          "indent": -1,
          "statusUpdateDate": "02-Aug-2023#04:54 CST",
          "originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "title": "Inline Attachment VJ Test",
          "flagTypeImageName": "flag_type/flag_0.png",
          "ownerOrgName": "Asite Solutions",
          "dcId": 1,
          "formCreationDateInMS": 1690970098000,
          "isPublic": false,
          "projectStatusId": 5,
          "updatedDateInMS": 1690970098000,
          "statusChangeUserName": "Mayur Raval m.",
          "showPrintIcon": 0,
          "invoiceColourCode": "-1",
          "msgCreatedDateInMS": 0,
          "flagType": 0,
          "hasFormAssocations": false,
          "hasCommentAssocations": false,
          "statusChangeUserEmail": "m.raval@asite.com",
          "statusChangeUserOrg": "Asite Solutions Ltd",
          "msgTypeId": 1,
          "isStatusChangeRestricted": false,
          "formUserSet": [],
          "statusText": "Open",
          "typeImage": "icons/form.png",
          "attachmentImageName": "icons/assocform.png"
        },
        "viewFormJson": "{\"myFields\":{\"attachments\":[],\"Attachment_1\":[],\"Attachment_2\":[{\"@inline\":\"xdoc_0_4_9_9_my:Attachment_2\",\"@caption\":\"flower-1.jpg\",\"content\":\"2130192#11070450#12336222#12336222_xdoc_0_4_9_9_my#12336222_xdoc_0_4_9_9_my_27205191#27205191\"}],\"Attachment_3\":[{\"@inline\":\"xdoc_0_6_1_9_my:Attachment_3\",\"@caption\":\"emulator-self.jpg\",\"content\":\"2130192#11070450#12336222#12336222_xdoc_0_6_1_9_my#12336222_xdoc_0_6_1_9_my_emulator-self.jpg#27210190\"}],\"extraParams\":null,\"Attachment\":[{\"@inline\":\"xdoc_0_3_9_0_my:Attachment\",\"@caption\":\"23346556.jpg\",\"content\":\"2130192#11070450#12336222#12336222_xdoc_0_3_9_0_my#12336222_xdoc_0_3_9_0_my_27205192#27205192\"}],\"City\":\"Ahmadabad\",\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW_HTML\":\"\",\"SP_RES_PRINT_VIEW\":\"\",\"CA_ORI_PRINT_VIEW_HTML\":\"State##City\",\"attributeSetId\":\"118281\",\"CA_ORI_VIEW\":\"State##City\",\"SP_ORI_PRINT_VIEW\":\"\",\"SP_ORI_VIEW\":\"\",\"SP_RES_VIEW\":\"\",\"SP_ORI_PRINT_VIEW_HTML\":\"\",\"SP_RES_VIEW_HTML\":\"\",\"CA_ORI_VIEW_HTML\":\"State##City\",\"SP_RES_PRINT_VIEW_HTML\":\"\",\"CA_ORI_PRINT_VIEW\":\"State##City\"}},\"ORI_FORMTITLE_Copy\":\"Inline Attachment VJ Test\",\"attachment_fields\":\"xdoc_0_4_9_9_my:Attachment_2#xdoc_0_3_9_0_my:Attachment#xdoc_0_6_1_9_my:Attachment_3\",\"State\":\"Gujarat\",\"ORI_FORMTITLE\":\"Inline Attachment VJ Test\",\"selectedControllerUserId\":\"\"}}",
        "offlineFormId": ""
      };
      when(() => mockUseCase!.saveFormToServer(any()))
          .thenAnswer((_) => Future.value(SUCCESS(saveFormResult, null, 200)));

      final formDetailResult = {
        "11626957": {
          "combinedAttachAssocList": [
            {
              "fileType": "filetype/jpg.gif",
              "fileName": "23346556.jpg",
              "revisionId": "27205192\$\$V8Uh7q",
              "fileSize": "1169 KB",
              "hasAccess": true,
              "canDownload": true,
              "publisherUserId": "0",
              "hasBravaSupport": true,
              "docId": "13658735\$\$9tu2tU",
              "attachedBy": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
              "attachedDateInTimeStamp": "Aug 2, 2023 10:55:00 AM",
              "attachedDate": "02-Aug-2023#04:55 CST",
              "createdDateInTimeStamp": "Aug 2, 2023 10:55:00 AM",
              "attachedById": "2017529",
              "attachedByName": "Mayur Raval m.",
              "isLink": false,
              "linkType": "Static",
              "isHasXref": false,
              "documentTypeId": "0",
              "isRevPrivate": false,
              "isAccess": true,
              "isDocActive": true,
              "folderPermissionValue": "0",
              "isRevInDistList": false,
              "isPasswordProtected": false,
              "attachmentId": "0\$\$CWmWSr",
              "viewAlwaysFormAssociationParent": true,
              "viewAlwaysDocAssociationParent": false,
              "allowDownloadToken": "1\$\$gg7DQg",
              "isHoopsSupported": false,
              "isPDFTronSupported": false,
              "downloadImageName": "icons/downloads.png",
              "hasOnlineViewerSupport": true,
              "newSysLocation": "project_2130192/formtype_11070450/form_11070450/msg_12336222/27205192.jpg",
              "hashedAttachedById": "2017529\$\$wmohiM",
              "hasGeoTagInfo": false,
              "locationPath": "Site Quality Demo\\01 Vijay_Test\\Plan-3\\Loc_3",
              "type": "3",
              "msgId": "12336222\$\$A2C5Du",
              "msgCreationDate": "Aug 2, 2023 10:55:00 AM",
              "projectId": "2130192\$\$lpO1g2",
              "folderId": "116305143\$\$SZTS3A",
              "dcId": "1",
              "childProjectId": "0",
              "userId": "0",
              "resourceId": "0",
              "parentMsgId": "12336222",
              "parentMsgCode": "ORI001",
              "assocsParentId": "0\$\$PcGnvl",
              "totalDocCount": "0",
              "generateURI": true,
              "hasHoopsViewerSupport": false
            },
            {
              "fileType": "filetype/jpg.gif",
              "fileName": "emulator-self.jpg",
              "revisionId": "27210190\$\$BBkHDV",
              "fileSize": "418 KB",
              "hasAccess": true,
              "canDownload": true,
              "publisherUserId": "0",
              "hasBravaSupport": true,
              "docId": "13663353\$\$ugimz8",
              "attachedBy": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
              "attachedDateInTimeStamp": "Aug 2, 2023 2:17:00 PM",
              "attachedDate": "02-Aug-2023#08:17 CST",
              "createdDateInTimeStamp": "Aug 2, 2023 2:17:00 PM",
              "attachedById": "2017529",
              "attachedByName": "Mayur Raval m.",
              "isLink": false,
              "linkType": "Static",
              "isHasXref": false,
              "documentTypeId": "0",
              "isRevPrivate": false,
              "isAccess": true,
              "isDocActive": true,
              "folderPermissionValue": "0",
              "isRevInDistList": false,
              "isPasswordProtected": false,
              "attachmentId": "0\$\$CWmWSr",
              "viewAlwaysFormAssociationParent": true,
              "viewAlwaysDocAssociationParent": false,
              "allowDownloadToken": "1\$\$gg7DQg",
              "isHoopsSupported": false,
              "isPDFTronSupported": false,
              "downloadImageName": "icons/downloads.png",
              "hasOnlineViewerSupport": true,
              "newSysLocation": "project_2130192/formtype_11070450/form_11070450/msg_12336222/27210190.jpg",
              "hashedAttachedById": "2017529\$\$wmohiM",
              "hasGeoTagInfo": false,
              "locationPath": "Site Quality Demo\\01 Vijay_Test\\Plan-3\\Loc_3",
              "type": "3",
              "msgId": "12336222\$\$A2C5Du",
              "msgCreationDate": "Aug 2, 2023 2:17:00 PM",
              "projectId": "2130192\$\$lpO1g2",
              "folderId": "116305143\$\$SZTS3A",
              "dcId": "1",
              "childProjectId": "0",
              "userId": "0",
              "resourceId": "0",
              "parentMsgId": "12336222",
              "parentMsgCode": "ORI001",
              "assocsParentId": "0\$\$PcGnvl",
              "totalDocCount": "0",
              "generateURI": true,
              "hasHoopsViewerSupport": false
            },
            {
              "fileType": "filetype/jpg.gif",
              "fileName": "flower-1.jpg",
              "revisionId": "27205191\$\$xlDvSz",
              "fileSize": "416 KB",
              "hasAccess": true,
              "canDownload": true,
              "publisherUserId": "0",
              "hasBravaSupport": true,
              "docId": "13658734\$\$9KUSKw",
              "attachedBy": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
              "attachedDateInTimeStamp": "Aug 2, 2023 10:55:00 AM",
              "attachedDate": "02-Aug-2023#04:55 CST",
              "createdDateInTimeStamp": "Aug 2, 2023 10:55:00 AM",
              "attachedById": "2017529",
              "attachedByName": "Mayur Raval m.",
              "isLink": false,
              "linkType": "Static",
              "isHasXref": false,
              "documentTypeId": "0",
              "isRevPrivate": false,
              "isAccess": true,
              "isDocActive": true,
              "folderPermissionValue": "0",
              "isRevInDistList": false,
              "isPasswordProtected": false,
              "attachmentId": "0\$\$CWmWSr",
              "viewAlwaysFormAssociationParent": true,
              "viewAlwaysDocAssociationParent": false,
              "allowDownloadToken": "1\$\$gg7DQg",
              "isHoopsSupported": false,
              "isPDFTronSupported": false,
              "downloadImageName": "icons/downloads.png",
              "hasOnlineViewerSupport": true,
              "newSysLocation": "project_2130192/formtype_11070450/form_11070450/msg_12336222/27205191.jpg",
              "hashedAttachedById": "2017529\$\$wmohiM",
              "hasGeoTagInfo": false,
              "locationPath": "Site Quality Demo\\01 Vijay_Test\\Plan-3\\Loc_3",
              "type": "3",
              "msgId": "12336222\$\$A2C5Du",
              "msgCreationDate": "Aug 2, 2023 10:55:00 AM",
              "projectId": "2130192\$\$lpO1g2",
              "folderId": "116305143\$\$SZTS3A",
              "dcId": "1",
              "childProjectId": "0",
              "userId": "0",
              "resourceId": "0",
              "parentMsgId": "12336222",
              "parentMsgCode": "ORI001",
              "assocsParentId": "0\$\$PcGnvl",
              "totalDocCount": "0",
              "generateURI": true,
              "hasHoopsViewerSupport": false
            },
            {"Location Name": "Loc_3", "Location Path": "Site Quality Demo\\01 Vijay_Test\\Plan-3\\Loc_3"}
          ],
          "messages": [
            {
              "projectId": "2130192\$\$lpO1g2",
              "projectName": "Site Quality Demo",
              "code": "INAT000",
              "commId": "11626957\$\$zdr6oQ",
              "formId": "11626957\$\$ru4m4R",
              "title": "Inline Attachment VJ Test",
              "userID": "2017529\$\$wmohiM",
              "orgId": "5763307\$\$ZxLI32",
              "firstName": "Mayur",
              "lastName": "Raval m.",
              "orgName": "Asite Solutions Ltd",
              "originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
              "originatorDisplayName": "Mayur Raval m., Asite Solutions Ltd",
              "noOfActions": 0,
              "observationId": 107888,
              "locationId": 183885,
              "pfLocFolderId": 0,
              "updated": "2023-08-02T14:16:47Z",
              "duration": "48 secs ago",
              "hasAttachments": true,
              "msgCode": "ORI001",
              "docType": "Apps",
              "formTypeName": "Attachment",
              "userRefCode": "N/A",
              "status": "Open",
              "responseRequestBy": "30-Aug-2023#23:59 CST",
              "controllerName": "N/A",
              "hasDocAssocations": false,
              "hasBimViewAssociations": false,
              "hasBimListAssociations": false,
              "hasFormAssocations": false,
              "hasCommentAssocations": false,
              "formHasAssocAttach": true,
              "msgHasAssocAttach": true,
              "formCreationDate": "2023-08-02T14:16:47Z",
              "msgCreatedDate": "02-Aug-2023#08:16 CST",
              "folderId": "0\$\$02dNOR",
              "msgId": "12336222\$\$A2C5Du",
              "parentMsgId": 0,
              "msgTypeId": 1,
              "msgStatusId": 19,
              "msgStatusName": "Draft",
              "indent": -1,
              "formTypeId": "11070450\$\$BECT4X",
              "formNum": 0,
              "msgOriginatorId": 2017529,
              "hashedMsgOriginatorId": "2017529\$\$wmohiM",
              "formPrintEnabled": true,
              "showPrintIcon": 1,
              "templateType": 2,
              "instanceGroupId": "11062773\$\$WPG4nZ",
              "noOfMessages": 0,
              "isDraft": true,
              "dcId": 1,
              "statusid": 2,
              "originatorId": 2017529,
              "isCloseOut": false,
              "isStatusChangeRestricted": false,
              "project_APD_folder_id": "110997340\$\$y9kONl",
              "allowReopenForm": true,
              "hasOverallStatus": true,
              "formUserSet": ["orig_change_status"],
              "canOrigChangeStatus": true,
              "canControllerChangeStatus": false,
              "appType": "2",
              "msgTypeCode": "ORI",
              "formGroupName": "Attachment",
              "id": "INAT000",
              "statusText": "Open",
              "statusChangeUserId": 0,
              "originatorEmail": "m.raval@asite.com",
              "invoiceCountAgainstOrder": "-1",
              "invoiceColourCode": "-1",
              "controllerUserId": 0,
              "offlineFormId": "1690959854717",
              "customFieldsValueVOs": {},
              "updatedDateInMS": 1690982207000,
              "formCreationDateInMS": 1690982207000,
              "msgCreatedDateInMS": 1690982207000,
              "flagType": 0,
              "latestDraftId": "0\$\$wJQOqu",
              "hasFormAccess": false,
              "jsonData": "{\"myFields\":{\"attachments\":[],\"Attachment_1\":[],\"Attachment_2\":[{\"@inline\":\"xdoc_0_4_9_9_my:Attachment_2\",\"@caption\":\"flower-1.jpg\",\"content\":\"2130192#11070450#12336222#12336222_xdoc_0_4_9_9_my#12336222_xdoc_0_4_9_9_my_27205191#27205191\"}],\"Attachment_3\":[{\"@inline\":\"xdoc_0_6_1_9_my:Attachment_3\",\"@caption\":\"emulator-self.jpg\",\"content\":\"2130192#11070450#12336222#12336222_xdoc_0_6_1_9_my#12336222_xdoc_0_6_1_9_my_emulator-self.jpg#27210190\"}],\"extraParams\":null,\"Attachment\":[{\"@inline\":\"xdoc_0_3_9_0_my:Attachment\",\"@caption\":\"23346556.jpg\",\"content\":\"2130192#11070450#12336222#12336222_xdoc_0_3_9_0_my#12336222_xdoc_0_3_9_0_my_27205192#27205192\"}],\"City\":\"Ahmadabad\",\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW_HTML\":\"\",\"SP_RES_PRINT_VIEW\":\"\",\"CA_ORI_PRINT_VIEW_HTML\":\"State##City\",\"attributeSetId\":\"118281\",\"CA_ORI_VIEW\":\"State##City\",\"SP_ORI_PRINT_VIEW\":\"\",\"SP_ORI_VIEW\":\"\",\"SP_RES_VIEW\":\"\",\"SP_ORI_PRINT_VIEW_HTML\":\"\",\"SP_RES_VIEW_HTML\":\"\",\"CA_ORI_VIEW_HTML\":\"State##City\",\"SP_RES_PRINT_VIEW_HTML\":\"\",\"CA_ORI_PRINT_VIEW\":\"State##City\"}},\"ORI_FORMTITLE_Copy\":\"Inline Attachment VJ Test\",\"attachment_fields\":\"xdoc_0_4_9_9_my:Attachment_2#xdoc_0_3_9_0_my:Attachment#xdoc_0_6_1_9_my:Attachment_3\",\"State\":\"Gujarat\",\"ORI_FORMTITLE\":\"Inline Attachment VJ Test\",\"selectedControllerUserId\":\"\"}}",
              "formPermissions": {"can_edit_ORI": false, "can_respond": true, "restrictChangeFormStatus": false, "controllerUserId": 0, "isProjectArchived": false, "can_distribute": false, "can_forward": false, "oriMsgId": "12336222\$\$A2C5Du"},
              "fixedFormData": {"comboList": "", "DS_FORMID": "INAT000"},
              "ownerOrgName": "Asite Solutions",
              "ownerOrgId": 3,
              "originatorOrgId": 5763307,
              "msgUserOrgId": 5763307,
              "msgUserOrgName": "Asite Solutions Ltd",
              "msgUserName": "Mayur Raval m.",
              "originatorName": "Mayur Raval m.",
              "isPublic": false,
              "responseRequestByInMS": 0,
              "actionDateInMS": 0,
              "formGroupCode": "INAT",
              "isThumbnailSupports": false,
              "canAccessHistory": false,
              "projectStatusId": 5,
              "generateURI": true
            }
          ]
        }
      };
      when(() => mockProjectUseCase!.getFormMessageBatchList(any()))
          .thenAnswer((_) => Future.value(SUCCESS(formDetailResult, null, 200)));

      String selectOldAttachQuery = "SELECT * FROM FormMsgAttachAndAssocListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11626957";
      ResultSet attchResultSet = ResultSet(
          ["ProjectId", "FormTypeId", "FormId", "MsgId", "AttachmentType", "AttachAssocDetailJson", "OfflineUploadFilePath", "AttachDocId", "AttachRevId", "AttachFileName", "AssocProjectId", "AssocDocFolderId", "AssocDocRevisionId", "AssocFormCommId", "AssocCommentMsgId", "AssocCommentId", "AssocCommentRevisionId", "AssocViewModelId", "AssocViewId", "AssocListModelId", "AssocListId", "AttachSize",]
          , null, [
        [
          "2130192",
          "11070450",
          "11626957",
          "",
          "",
          "{\"Location Name\":\"Loc_3\",\"Location Path\":\"Site Quality Demo\\\\01 Vijay_Test\\\\Plan-3\\\\Loc_3\"}",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "0"
        ],
        [
          "2130192",
          "11070450",
          "11626957",
          "12336222",
          "3",
          "{\"fileType\":\"filetype/jpg.gif\",\"fileName\":\"23346556.jpg\",\"revisionId\":\"27205192\",\"fileSize\":\"1169 KB\",\"hasAccess\":true,\"canDownload\":true,\"publisherUserId\":\"0\",\"hasBravaSupport\":true,\"docId\":\"13658735\",\"attachedBy\":\"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur\",\"attachedDateInTimeStamp\":\"Aug 2, 2023 10:55:00 AM\",\"attachedDate\":\"02-Aug-2023#04:55 CST\",\"createdDateInTimeStamp\":\"Aug 2, 2023 10:55:00 AM\",\"attachedById\":\"2017529\",\"attachedByName\":\"Mayur Raval m.\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":\"0\",\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":\"0\",\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"viewAlwaysFormAssociationParent\":true,\"viewAlwaysDocAssociationParent\":false,\"allowDownloadToken\":\"1\",\"isHoopsSupported\":false,\"isPDFTronSupported\":false,\"downloadImageName\":\"icons/downloads.png\",\"hasOnlineViewerSupport\":true,\"newSysLocation\":\"project_2130192/formtype_11070450/form_11070450/msg_12336222/27205192.jpg\",\"hashedAttachedById\":\"2017529\$\$wmohiM\",\"hasGeoTagInfo\":false,\"locationPath\":\"Site Quality Demo\\\\01 Vijay_Test\\\\Plan-3\\\\Loc_3\",\"type\":\"3\",\"msgId\":\"12336222\",\"msgCreationDate\":\"Aug 2, 2023 10:55:00 AM\",\"projectId\":\"2130192\",\"folderId\":\"116305143\",\"dcId\":\"1\",\"childProjectId\":\"0\",\"userId\":\"0\",\"resourceId\":\"0\",\"parentMsgId\":\"12336222\",\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"totalDocCount\":\"0\",\"generateURI\":true,\"hasHoopsViewerSupport\":false}",
          "",
          "13658735",
          "27205192",
          "23346556.jpg",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "1169"
        ],
        [
          "2130192",
          "11070450",
          "11626957",
          "12336222",
          "3",
          "{\"fileType\":\"filetype/jpg.gif\",\"fileName\":\"flower-1.jpg\",\"revisionId\":\"27205191\",\"fileSize\":\"416 KB\",\"hasAccess\":true,\"canDownload\":true,\"publisherUserId\":\"0\",\"hasBravaSupport\":true,\"docId\":\"13658734\",\"attachedBy\":\"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur\",\"attachedDateInTimeStamp\":\"Aug 2, 2023 10:55:00 AM\",\"attachedDate\":\"02-Aug-2023#04:55 CST\",\"createdDateInTimeStamp\":\"Aug 2, 2023 10:55:00 AM\",\"attachedById\":\"2017529\",\"attachedByName\":\"Mayur Raval m.\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":\"0\",\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":\"0\",\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"viewAlwaysFormAssociationParent\":true,\"viewAlwaysDocAssociationParent\":false,\"allowDownloadToken\":\"1\",\"isHoopsSupported\":false,\"isPDFTronSupported\":false,\"downloadImageName\":\"icons/downloads.png\",\"hasOnlineViewerSupport\":true,\"newSysLocation\":\"project_2130192/formtype_11070450/form_11070450/msg_12336222/27205191.jpg\",\"hashedAttachedById\":\"2017529\$\$wmohiM\",\"hasGeoTagInfo\":false,\"locationPath\":\"Site Quality Demo\\\\01 Vijay_Test\\\\Plan-3\\\\Loc_3\",\"type\":\"3\",\"msgId\":\"12336222\",\"msgCreationDate\":\"Aug 2, 2023 10:55:00 AM\",\"projectId\":\"2130192\",\"folderId\":\"116305143\",\"dcId\":\"1\",\"childProjectId\":\"0\",\"userId\":\"0\",\"resourceId\":\"0\",\"parentMsgId\":\"12336222\",\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"totalDocCount\":\"0\",\"generateURI\":true,\"hasHoopsViewerSupport\":false}",
          "",
          "13658734",
          "27205191",
          "flower-1.jpg",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "416"
        ],
        [
          "2130192",
          "11070450",
          "11626957",
          "12336222",
          "3",
          "{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"emulator-self.jpg\",\"revisionId\":\"1690981655690307\",\"fileSize\":\"418 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690981655690307\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-08-02 18:37:35.035\",\"attachedDate\":\"2023-08-02 18:37:35.035\",\"attachedById\":\"2017529\",\"attachedByName\":\"Mayur Raval m.\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":12336222,\"msgCreationDate\":\"2023-08-02 18:37:35.035\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":12336222,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}",
          "",
          "1690981655690307",
          "1690981655690307",
          "emulator-self.jpg",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "0"
        ]
      ]);
      when(() => mockDb!.selectFromTable(attachTableName, selectOldAttachQuery))
          .thenReturn(attchResultSet);
      var attachPathAns1 = [false, true];
      String attachPath1 = "./test/fixtures/files/2130192/Attachments/27205192.jpg";
      when(() => mockFileUtility!.isFileExist(attachPath1))
          .thenReturn(attachPathAns1.removeAt(0));
      String attachPath2 = "./test/fixtures/files/2130192/Attachments/27210190.jpg";
      when(() => mockFileUtility!.isFileExist(attachPath2))
          .thenReturn(false);
      var attachPathAns3 = [false, true];
      String attachPath3 = "./test/fixtures/files/2130192/Attachments/27205191.jpg";
      when(() => mockFileUtility!.isFileExist(attachPath3))
          .thenReturn(attachPathAns3.removeAt(0));
      String attachOldPath1 = "./test/fixtures/files/2130192/Attachments/1690981655690307.jpg";
      when(() => mockFileUtility!.isFileExist(attachOldPath1))
          .thenReturn(true);
      when(() => mockFileUtility!.renameFile(attachOldPath1, attachPath2))
          .thenReturn(null);

      String removeFormQuery = "DELETE FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11626957";
      when(() => mockDb!.executeQuery(removeFormQuery))
          .thenReturn(null);
      String removeFormMsgQuery = "DELETE FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11626957";
      when(() => mockDb!.executeQuery(removeFormMsgQuery))
          .thenReturn(null);
      String removeFormMsgActQuery = "DELETE FROM FormMsgActionListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11626957";
      when(() => mockDb!.executeQuery(removeFormMsgActQuery))
          .thenReturn(null);
      String removeFormMsgAttachQuery = "DELETE FROM FormMsgAttachAndAssocListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11626957";
      when(() => mockDb!.executeQuery(removeFormMsgAttachQuery))
          .thenReturn(null);
      //Below changes for Form DAO mock
      String formTableName = "FormListTbl";
      String formTableQuery = "CREATE TABLE IF NOT EXISTS FormListTbl(ProjectId INTEGER NOT NULL,FormId TEXT NOT NULL,AppTypeId INTEGER,FormTypeId INTEGER,InstanceGroupId INTEGER NOT NULL,FormTitle TEXT,Code TEXT,CommentId INTEGER,MessageId INTEGER,ParentMessageId INTEGER,OrgId INTEGER,FirstName TEXT,LastName TEXT,OrgName TEXT,Originator TEXT,OriginatorDisplayName TEXT,NoOfActions INTEGER,ObservationId INTEGER,LocationId INTEGER,PfLocFolderId INTEGER,Updated TEXT,AttachmentImageName TEXT,MsgCode TEXT,TypeImage TEXT,DocType TEXT,HasAttachments INTEGER NOT NULL DEFAULT 0,HasDocAssocations INTEGER NOT NULL DEFAULT 0,HasBimViewAssociations INTEGER NOT NULL DEFAULT 0,HasFormAssocations INTEGER NOT NULL DEFAULT 0,HasCommentAssocations INTEGER NOT NULL DEFAULT 0,FormHasAssocAttach INTEGER NOT NULL DEFAULT 0,FormCreationDate TEXT,FolderId INTEGER,MsgTypeId INTEGER,MsgStatusId INTEGER,FormNumber INTEGER,MsgOriginatorId INTEGER,TemplateType INTEGER,IsDraft INTEGER NOT NULL DEFAULT 0,StatusId INTEGER,OriginatorId INTEGER,IsStatusChangeRestricted INTEGER NOT NULL DEFAULT 0,AllowReopenForm INTEGER NOT NULL DEFAULT 0,CanOrigChangeStatus INTEGER NOT NULL DEFAULT 0,MsgTypeCode TEXT,Id TEXT,StatusChangeUserId INTEGER,StatusUpdateDate TEXT,StatusChangeUserName TEXT,StatusChangeUserPic TEXT,StatusChangeUserEmail TEXT,StatusChangeUserOrg TEXT,OriginatorEmail TEXT,ControllerUserId INTEGER,UpdatedDateInMS INTEGER,FormCreationDateInMS INTEGER,ResponseRequestByInMS INTEGER,FlagType INTEGER,LatestDraftId INTEGER,FlagTypeImageName TEXT,MessageTypeImageName TEXT,CanAccessHistory INTEGER NOT NULL DEFAULT 0,FormJsonData TEXT,Status TEXT,AttachedDocs TEXT,IsUploadAttachmentInTemp INTEGER NOT NULL DEFAULT 0,IsSync INTEGER NOT NULL DEFAULT 0,UserRefCode TEXT,HasActions INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,IsOfflineCreated INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,IsForDefect INTEGER NOT NULL DEFAULT 0,IsForApps INTEGER NOT NULL DEFAULT 0,ObservationDefectTypeId TEXT NOT NULL DEFAULT '0',StartDate TEXT NOT NULL,ExpectedFinishDate TEXT NOT NULL,IsActive INTEGER NOT NULL DEFAULT 0,ObservationCoordinates TEXT,AnnotationId TEXT,IsCloseOut INTEGER NOT NULL DEFAULT 0,AssignedToUserId INTEGER NOT NULL,AssignedToUserName TEXT,AssignedToUserOrgName TEXT,MsgNum INTEGER,RevisionId INTEGER,RequestJsonForOffline TEXT,FormDueDays TEXT NOT NULL DEFAULT 0,FormSyncDate TEXT NOT NULL DEFAULT 0,LastResponderForAssignedTo TEXT NOT NULL DEFAULT '',LastResponderForOriginator TEXT NOT NULL DEFAULT '',PageNumber TEXT NOT NULL DEFAULT 0,ObservationDefectType TEXT,StatusName TEXT,AppBuilderId TEXT,TaskTypeName TEXT,AssignedToRoleName TEXT,PRIMARY KEY(ProjectId,FormId))";
      when(() => mockDb!.executeQuery(formTableQuery))
          .thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(formTableName))
          .thenReturn(["ProjectId", "FormId"]);
      String formSelectQuery = "SELECT ProjectId FROM FormListTbl WHERE ProjectId='2130192' AND FormId='11626957'";
      when(() => mockDb!.selectFromTable(formTableName, formSelectQuery))
          .thenReturn(ResultSet([], null, []));
      String frmBulkInsertQuery = "INSERT INTO FormListTbl (ProjectId,FormId,AppTypeId,FormTypeId,InstanceGroupId,FormTitle,Code,CommentId,MessageId,ParentMessageId,OrgId,FirstName,LastName,OrgName,Originator,OriginatorDisplayName,NoOfActions,ObservationId,LocationId,PfLocFolderId,Updated,AttachmentImageName,MsgCode,TypeImage,DocType,HasAttachments,HasDocAssocations,HasBimViewAssociations,HasFormAssocations,HasCommentAssocations,FormHasAssocAttach,FormCreationDate,FolderId,MsgTypeId,MsgStatusId,FormNumber,MsgOriginatorId,TemplateType,IsDraft,StatusId,OriginatorId,IsStatusChangeRestricted,AllowReopenForm,CanOrigChangeStatus,MsgTypeCode,Id,StatusChangeUserId,StatusUpdateDate,StatusChangeUserName,StatusChangeUserPic,StatusChangeUserEmail,StatusChangeUserOrg,OriginatorEmail,ControllerUserId,UpdatedDateInMS,FormCreationDateInMS,ResponseRequestByInMS,FlagType,LatestDraftId,FlagTypeImageName,MessageTypeImageName,CanAccessHistory,FormJsonData,Status,AttachedDocs,IsUploadAttachmentInTemp,IsSync,UserRefCode,HasActions,CanRemoveOffline,IsMarkOffline,IsOfflineCreated,SyncStatus,IsForDefect,IsForApps,ObservationDefectTypeId,StartDate,ExpectedFinishDate,IsActive,ObservationCoordinates,AnnotationId,IsCloseOut,AssignedToUserId,AssignedToUserName,AssignedToUserOrgName,MsgNum,RevisionId,RequestJsonForOffline,FormDueDays,FormSyncDate,LastResponderForAssignedTo,LastResponderForOriginator,PageNumber,ObservationDefectType,StatusName,AppBuilderId,TaskTypeName,AssignedToRoleName) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      when(() => mockDb!.executeBulk(formTableName, frmBulkInsertQuery, any()))
          .thenAnswer((_) async=> null);

      //Below changes for FormMessage DAO mock
      String frmMsgTableName = "FormMessageListTbl";
      String frmMsgTableQuery = "CREATE TABLE IF NOT EXISTS FormMessageListTbl(ProjectId TEXT NOT NULL,FormTypeId TEXT NOT NULL,FormId TEXT NOT NULL,MsgId TEXT NOT NULL,Originator TEXT,OriginatorDisplayName TEXT,MsgCode TEXT,MsgCreatedDate TEXT,ParentMsgId TEXT,MsgOriginatorId TEXT,MsgHasAssocAttach INTEGER NOT NULL DEFAULT 0,JsonData TEXT,UserRefCode TEXT,UpdatedDateInMS TEXT,FormCreationDateInMS TEXT,MsgCreatedDateInMS TEXT,MsgTypeId TEXT,MsgTypeCode TEXT,MsgStatusId TEXT,SentNames TEXT,SentActions TEXT,DraftSentActions TEXT,FixFieldData TEXT,FolderId TEXT,LatestDraftId TEXT,IsDraft INTEGER NOT NULL DEFAULT 0,AssocRevIds TEXT,ResponseRequestBy TEXT,DelFormIds TEXT,AssocFormIds TEXT,AssocCommIds TEXT,FormUserSet TEXT,FormPermissionsMap TEXT,CanOrigChangeStatus INTEGER NOT NULL DEFAULT 0,CanControllerChangeStatus INTEGER NOT NULL DEFAULT 0,IsStatusChangeRestricted INTEGER NOT NULL DEFAULT 0,HasOverallStatus INTEGER NOT NULL DEFAULT 0,IsCloseOut INTEGER NOT NULL DEFAULT 0,AllowReopenForm INTEGER NOT NULL DEFAULT 0,OfflineRequestData TEXT NOT NULL DEFAULT \"\",IsOfflineCreated INTEGER NOT NULL DEFAULT 0,LocationId INTEGER,ObservationId INTEGER,MsgNum INTEGER,MsgContent TEXT,ActionComplete INTEGER NOT NULL DEFAULT 0,ActionCleared INTEGER NOT NULL DEFAULT 0,HasAttach INTEGER NOT NULL DEFAULT 0,TotalActions INTEGER,InstanceGroupId INTEGER,AttachFiles TEXT,HasViewAccess INTEGER NOT NULL DEFAULT 0,MsgOriginImage TEXT,IsForInfoIncomplete INTEGER NOT NULL DEFAULT 0,MsgCreatedDateOffline TEXT,LastModifiedTime TEXT,LastModifiedTimeInMS TEXT,CanViewDraftMsg INTEGER NOT NULL DEFAULT 0,CanViewOwnorgPrivateForms INTEGER NOT NULL DEFAULT 0,IsAutoSavedDraft INTEGER NOT NULL DEFAULT 0,MsgStatusName TEXT,ProjectAPDFolderId TEXT,ProjectStatusId TEXT,HasFormAccess INTEGER NOT NULL DEFAULT 0,CanAccessHistory INTEGER NOT NULL DEFAULT 0,HasDocAssocations INTEGER NOT NULL DEFAULT 0,HasBimViewAssociations INTEGER NOT NULL DEFAULT 0,HasBimListAssociations INTEGER NOT NULL DEFAULT 0,HasFormAssocations INTEGER NOT NULL DEFAULT 0,HasCommentAssocations INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId,FormId,MsgId))";
      when(() => mockDb!.executeQuery(frmMsgTableQuery))
          .thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(frmMsgTableName))
          .thenReturn(["ProjectId", "FormId", "MsgId"]);
      String frmMsgSelectQuery = "SELECT ProjectId FROM FormMessageListTbl WHERE ProjectId='2130192' AND FormId='11626957' AND MsgId='12336222'";
      when(() => mockDb!.selectFromTable(frmMsgTableName, frmMsgSelectQuery))
          .thenReturn(ResultSet([], null, []));
      String frmMsgBulkInsertQuery = "INSERT INTO FormMessageListTbl (ProjectId,FormTypeId,FormId,MsgId,Originator,OriginatorDisplayName,MsgCode,MsgCreatedDate,ParentMsgId,MsgOriginatorId,MsgHasAssocAttach,JsonData,UserRefCode,UpdatedDateInMS,FormCreationDateInMS,MsgCreatedDateInMS,MsgTypeId,MsgTypeCode,MsgStatusId,SentNames,SentActions,DraftSentActions,FixFieldData,FolderId,LatestDraftId,IsDraft,AssocRevIds,ResponseRequestBy,DelFormIds,AssocFormIds,AssocCommIds,FormUserSet,FormPermissionsMap,CanOrigChangeStatus,CanControllerChangeStatus,IsStatusChangeRestricted,HasOverallStatus,IsCloseOut,AllowReopenForm,OfflineRequestData,IsOfflineCreated,LocationId,ObservationId,MsgNum,MsgContent,ActionComplete,ActionCleared,HasAttach,TotalActions,InstanceGroupId,AttachFiles,HasViewAccess,MsgOriginImage,IsForInfoIncomplete,MsgCreatedDateOffline,LastModifiedTime,LastModifiedTimeInMS,CanViewDraftMsg,CanViewOwnorgPrivateForms,IsAutoSavedDraft,MsgStatusName,ProjectAPDFolderId,ProjectStatusId,HasFormAccess,CanAccessHistory,HasDocAssocations,HasBimViewAssociations,HasBimListAssociations,HasFormAssocations,HasCommentAssocations) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      when(() => mockDb!.executeBulk(frmMsgTableName, frmMsgBulkInsertQuery, any()))
          .thenAnswer((_) async=> null);

      //Below changes for FormMessageAttach DAO mock
      String frmMsgAttachTableName = "FormMsgAttachAndAssocListTbl";
      String frmMsgAttachTableQuery = "CREATE TABLE IF NOT EXISTS FormMsgAttachAndAssocListTbl(ProjectId TEXT NOT NULL,FormTypeId TEXT NOT NULL,FormId TEXT NOT NULL,MsgId TEXT NOT NULL,AttachmentType TEXT NOT NULL,AttachAssocDetailJson TEXT NOT NULL,OfflineUploadFilePath TEXT,AttachDocId TEXT,AttachRevId TEXT,AttachFileName TEXT,AssocProjectId TEXT,AssocDocFolderId TEXT,AssocDocRevisionId TEXT,AssocFormCommId TEXT,AssocCommentMsgId TEXT,AssocCommentId TEXT,AssocCommentRevisionId TEXT,AssocViewModelId TEXT,AssocViewId TEXT,AssocListModelId TEXT,AssocListId TEXT,AttachSize TEXT)";
      when(() => mockDb!.executeQuery(frmMsgAttachTableQuery))
          .thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(frmMsgAttachTableName))
          .thenReturn([""]);
      String frmMsgAttachSelectQuery = "SELECT  FROM FormMsgAttachAndAssocListTbl WHERE ='null'";
      when(() => mockDb!.selectFromTable(frmMsgAttachTableName, frmMsgAttachSelectQuery))
          .thenReturn(ResultSet([], null, []));
      String frmMsgAttachBulkInsertQuery = "INSERT INTO FormMsgAttachAndAssocListTbl (ProjectId,FormTypeId,FormId,MsgId,AttachmentType,AttachAssocDetailJson,OfflineUploadFilePath,AttachDocId,AttachRevId,AttachFileName,AssocProjectId,AssocDocFolderId,AssocDocRevisionId,AssocFormCommId,AssocCommentMsgId,AssocCommentId,AssocCommentRevisionId,AssocViewModelId,AssocViewId,AssocListModelId,AssocListId,AttachSize) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      when(() => mockDb!.executeBulk(frmMsgAttachTableName, frmMsgAttachBulkInsertQuery, any()))
          .thenAnswer((_) async=> null);

      when(() => mockFileUtility!.deleteFileAtPath(reqFilePath, recursive: false))
          .thenAnswer((_) => Future.value(null));

      await PushToServerFormSyncTask(syncTask, (eSyncTaskType, eSyncStatus, data) async {},).syncFormDataToServer(paramData, null);
      verify(() => mockFileUtility!.readFromFile(reqFilePath)).called(1);
      verify(() => mockDb!.selectFromTable(attachTableName, attachQuery)).called(1);
      verify(() => mockDb!.selectFromTable(attachTableName, attachQuery1)).called(1);
      verify(() => mockDb!.selectFromTable(attachTableName, attachQuery2)).called(1);
      verify(() => mockFileUtility!.getFileSizeSync(strInlineUpFile)).called(1);
      verify(() => mockUseCase!.saveFormToServer(any())).called(1);
      verify(() => mockProjectUseCase!.getFormMessageBatchList(any())).called(1);
      verify(() => mockDb!.selectFromTable(attachTableName, selectOldAttachQuery)).called(1);
      verify(() => mockFileUtility!.isFileExist(attachPath1)).called(2);
      verify(() => mockFileUtility!.isFileExist(attachPath2)).called(1);
      verify(() => mockFileUtility!.isFileExist(attachPath3)).called(2);
      verify(() => mockFileUtility!.isFileExist(attachOldPath1)).called(1);
      verify(() => mockFileUtility!.renameFile(attachOldPath1, attachPath2)).called(1);
      verify(() => mockDb!.executeQuery(removeFormQuery)).called(1);
      verify(() => mockDb!.executeQuery(removeFormMsgQuery)).called(1);
      verify(() => mockDb!.executeQuery(removeFormMsgActQuery)).called(1);
      verify(() => mockDb!.executeQuery(removeFormMsgAttachQuery)).called(1);
      //Below changes for Form DAO mock
      verify(() => mockDb!.executeQuery(formTableQuery)).called(1);
      verify(() => mockDb!.getPrimaryKeys(formTableName)).called(1);
      verify(() => mockDb!.selectFromTable(formTableName, formSelectQuery)).called(1);
      verify(() => mockDb!.executeBulk(formTableName, frmBulkInsertQuery, any())).called(1);
      //Below changes for FormMessage DAO mock
      verify(() => mockDb!.executeQuery(frmMsgTableQuery)).called(1);
      verify(() => mockDb!.getPrimaryKeys(frmMsgTableName)).called(1);
      verify(() => mockDb!.selectFromTable(frmMsgTableName, frmMsgSelectQuery)).called(1);
      verify(() => mockDb!.executeBulk(frmMsgTableName, frmMsgBulkInsertQuery, any())).called(1);

      verify(() => mockDb!.executeQuery(frmMsgAttachTableQuery)).called(1);
      verify(() => mockDb!.getPrimaryKeys(frmMsgAttachTableName)).called(1);
      verify(() => mockDb!.selectFromTable(frmMsgAttachTableName, frmMsgAttachSelectQuery)).called(4);
      verify(() => mockDb!.executeBulk(frmMsgAttachTableName, frmMsgAttachBulkInsertQuery, any())).called(1);

      verify(() => mockFileUtility!.deleteFileAtPath(reqFilePath, recursive: false)).called(1);
    });

    test('syncFormDataToServer site task form respond with attachment test', () async {
      SyncRequestTask syncTask = SyncRequestTask();
      var paramData = {
        "RequestType": EOfflineSyncRequestType.CreateOrRespond.value.toString(),
        "ProjectId": "2130192",
        "FormId": "11628410",
        "MsgId": "1691046952544",
        "UpdatedDateInMS": "1691046952544",
      };

      String requestData = "{\"projectId\":\"2130192\",\"locationId\":\"183882\",\"observationId\":107961,\"formId\":\"11628410\",\"formTypeId\":\"11103151\",\"templateType\":2,\"appTypeId\":2,\"appBuilderId\":\"ASI-SITE\",\"formSelectRadiobutton\":\"1_2130192_11103151\",\"isUploadAttachmentInTemp\":null,\"offlineFormDataJson\":\"{\\\"myFields\\\":{\\\"FORM_CUSTOM_FIELDS\\\":{\\\"ORI_MSG_Custom_Fields\\\":{\\\"DistributionDays\\\":\\\"12\\\",\\\"Organization\\\":\\\"\\\",\\\"DefectTyoe\\\":\\\"Architectural\\\",\\\"ExpectedFinishDate\\\":\\\"2023-08-21\\\",\\\"DefectDescription\\\":\\\"\\\",\\\"AssignedToUsersGroup\\\":{\\\"AssignedToUsers\\\":{\\\"AssignedToUser\\\":\\\"2017529#Mayur Raval m., Asite Solutions Ltd\\\"}},\\\"Defect_Description\\\":\\\"Test\\\",\\\"LocationName\\\":\\\"01 Vijay_Test>Plan-3\\\",\\\"StartDate\\\":\\\"2023-08-03\\\",\\\"ActualFinishDate\\\":\\\"\\\",\\\"ExpectedFinishDays\\\":\\\"12\\\",\\\"DS_Logo\\\":\\\"images/asite.gif\\\",\\\"LastResponder_For_AssignedTo\\\":\\\"2017529\\\",\\\"TaskType\\\":\\\"Damages\\\",\\\"isCalibrated\\\":false,\\\"ORI_FORMTITLE\\\":\\\"Respond Test case Vijay\\\",\\\"attachements\\\":[{\\\"attachedDocs\\\":\\\"\\\"}],\\\"OriginatorId\\\":\\\"707447 | Vijay Mavadiya (5336), Asite Solutions # Vijay Mavadiya (5336), Asite Solutions\\\",\\\"Assigned\\\":\\\"Mayur Raval m., Asite Solutions Ltd\\\",\\\"Todays_Date\\\":\\\"2023-08-03T07:49:36\\\",\\\"CurrStage\\\":\\\"1\\\",\\\"Recent_Defects\\\":\\\"\\\",\\\"FormCreationDate\\\":\\\"\\\",\\\"StartDateDisplay\\\":\\\"03-Aug-2023\\\",\\\"LastResponder_For_Originator\\\":\\\"707447\\\",\\\"PF_Location_Detail\\\":\\\"183882|26846988|null|0\\\",\\\"Username\\\":\\\"\\\",\\\"ORI_USERREF\\\":\\\"\\\",\\\"Location\\\":\\\"183882|Plan-3|01 Vijay_Test>Plan-3\\\"},\\\"RES_MSG_Custom_Fields\\\":{\\\"Comments\\\":\\\"Resolved offline\\\",\\\"SHResponse\\\":\\\"Yes\\\",\\\"ShowHideFlag\\\":\\\"Yes\\\"},\\\"CREATE_FWD_RES\\\":{\\\"Can_Reply\\\":\\\"\\\"},\\\"DS_AUTONUMBER\\\":{\\\"DS_SEQ_LENGTH\\\":\\\"\\\",\\\"DS_FORMAUTONO_CREATE\\\":\\\"\\\",\\\"DS_GET_APP_ACTION_DETAILS\\\":\\\"\\\",\\\"DS_FORMAUTONO_ADD\\\":\\\"\\\"},\\\"DS_DATASOURCE\\\":{\\\"DS_ASI_SITE_GET_RECENT_DEFECTS\\\":\\\"\\\",\\\"DS_ASI_SITE_getDefectTypesForProjects_pf\\\":\\\"\\\",\\\"DS_Response_PARAM\\\":\\\"#Comments#DS_ALL_FORMSTATUS\\\",\\\"DS_ASI_SITE_getAllLocationByProject_PF\\\":\\\"\\\",\\\"DS_CALL_METHOD\\\":\\\"1\\\",\\\"DS_CHECK_FORM_PERMISSION_USER\\\":\\\"\\\",\\\"DS_Get_All_Responses\\\":\\\"\\\",\\\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\\\":\\\"\\\",\\\"DS_Holiday_Calender_Param\\\":\\\"\\\",\\\"DS_ASI_Configurable_Attributes\\\":\\\"\\\"}},\\\"attachments\\\":[],\\\"Asite_System_Data_Read_Only\\\":{\\\"_2_Printing_Data\\\":{\\\"DS_PRINTEDON\\\":\\\"\\\",\\\"DS_PRINTEDBY\\\":\\\"\\\"},\\\"_4_Form_Type_Data\\\":{\\\"DS_FORMGROUPCODE\\\":\\\"\\\",\\\"DS_FORMAUTONO\\\":\\\"\\\",\\\"DS_FORMNAME\\\":\\\"Site Tasks\\\"},\\\"_3_Project_Data\\\":{\\\"DS_PROJECTNAME\\\":\\\"Site Quality Demo\\\",\\\"DS_CLIENT\\\":\\\"\\\"},\\\"_5_Form_Data\\\":{\\\"DS_DATEOFISSUE\\\":\\\"\\\",\\\"DS_ISDRAFT_RES_MSG\\\":\\\"\\\",\\\"Status_Data\\\":{\\\"DS_APPROVEDON\\\":\\\"\\\",\\\"DS_CLOSEDUEDATE\\\":\\\"\\\",\\\"DS_ALL_ACTIVE_FORM_STATUS\\\":\\\"\\\",\\\"DS_ALL_FORMSTATUS\\\":\\\"1002 # Resolved\\\",\\\"DS_APPROVEDBY\\\":\\\"\\\",\\\"DS_CLOSE_DUE_DATE\\\":\\\"\\\",\\\"DS_FORMSTATUS\\\":\\\"Open\\\"},\\\"DS_DISTRIBUTION\\\":\\\"\\\",\\\"DS_ISDRAFT\\\":\\\"NO\\\",\\\"DS_FORMCONTENT\\\":\\\"\\\",\\\"DS_FORMCONTENT3\\\":\\\"\\\",\\\"DS_ORIGINATOR\\\":\\\"\\\",\\\"DS_FORMCONTENT2\\\":\\\"\\\",\\\"DS_FORMCONTENT1\\\":\\\"\\\",\\\"DS_CONTROLLERNAME\\\":\\\"\\\",\\\"DS_MAXORGFORMNO\\\":\\\"\\\",\\\"DS_ISDRAFT_RES\\\":\\\"\\\",\\\"DS_MAXFORMNO\\\":\\\"\\\",\\\"DS_FORMAUTONO_PREFIX\\\":\\\"\\\",\\\"DS_ATTRIBUTES\\\":\\\"\\\",\\\"DS_CLOSE_DUE_DATE\\\":\\\"2023-08-21\\\",\\\"DS_ISDRAFT_FWD_MSG\\\":\\\"NO\\\",\\\"DS_FORMID\\\":\\\"\\\"},\\\"_1_User_Data\\\":{\\\"DS_WORKINGUSER\\\":\\\"Mayur Raval m., Asite Solutions Ltd\\\",\\\"DS_WORKINGUSERROLE\\\":\\\"\\\",\\\"DS_WORKINGUSER_ID\\\":\\\"\\\",\\\"DS_WORKINGUSER_ALL_ROLES\\\":\\\"\\\"},\\\"_6_Form_MSG_Data\\\":{\\\"DS_MSGCREATOR\\\":\\\"\\\",\\\"DS_MSGDATE\\\":\\\"\\\",\\\"DS_MSGID\\\":\\\"\\\",\\\"DS_MSGRELEASEDATE\\\":\\\"\\\",\\\"DS_MSGSTATUS\\\":\\\"\\\",\\\"ORI_MSG_Data\\\":{\\\"DS_DOC_ASSOCIATIONS_ORI\\\":\\\"\\\",\\\"DS_FORM_ASSOCIATIONS_ORI\\\":\\\"\\\",\\\"DS_ATTACHMENTS_ORI\\\":\\\"\\\"}}},\\\"Asite_System_Data_Read_Write\\\":{\\\"ORI_MSG_Fields\\\":{\\\"SP_RES_PRINT_VIEW\\\":\\\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\\\",\\\"SP_RES_VIEW\\\":\\\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\\\",\\\"SP_ORI_PRINT_VIEW\\\":\\\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\\\",\\\"SP_FORM_PRINT_VIEW\\\":\\\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\\\",\\\"SP_ORI_VIEW\\\":\\\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\\\"},\\\"DS_PROJORGANISATIONS\\\":\\\"\\\",\\\"DS_PROJUSERS_ALL_ROLES\\\":\\\"\\\",\\\"DS_PROJDISTGROUPS\\\":\\\"\\\",\\\"DS_AUTODISTRIBUTE\\\":\\\"411\\\",\\\"DS_PROJUSERS\\\":\\\"\\\",\\\"DS_PROJORGANISATIONS_ID\\\":\\\"\\\",\\\"DS_INCOMPLETE_ACTIONS\\\":\\\"\\\",\\\"Auto_Distribute_Group\\\":{\\\"Auto_Distribute_Users\\\":[{\\\"DS_ACTIONDUEDATE\\\":\\\"7\\\",\\\"DS_FORMACTIONS\\\":\\\"3#Respond\\\",\\\"DS_PROJDISTUSERS\\\":\\\"707447\\\"}]}},\\\"dist_list\\\":\\\"{\\\\\\\"selectedDistGroups\\\\\\\":\\\\\\\"\\\\\\\",\\\\\\\"selectedDistUsers\\\\\\\":[],\\\\\\\"selectedDistOrgs\\\\\\\":[],\\\\\\\"selectedDistRoles\\\\\\\":[],\\\\\\\"prePopulatedDistGroups\\\\\\\":\\\\\\\"\\\\\\\"}\\\",\\\"respondBy\\\":\\\"\\\",\\\"selectedControllerUserId\\\":\\\"\\\",\\\"create_hidden_list\\\":{\\\"msg_type_id\\\":\\\"2\\\",\\\"msg_type_code\\\":\\\"RES\\\",\\\"parent_msg_id\\\":\\\"12338091\\\",\\\"dist_list\\\":\\\"{\\\\\\\"selectedDistGroups\\\\\\\":\\\\\\\"\\\\\\\",\\\\\\\"selectedDistUsers\\\\\\\":[],\\\\\\\"selectedDistOrgs\\\\\\\":[],\\\\\\\"selectedDistRoles\\\\\\\":[],\\\\\\\"prePopulatedDistGroups\\\\\\\":\\\\\\\"\\\\\\\"}\\\",\\\"assocLocationSelection\\\":\\\"\\\",\\\"project_id\\\":\\\"2130192\\\",\\\"offlineProjectId\\\":\\\"2130192\\\",\\\"offlineFormTypeId\\\":\\\"11103151\\\",\\\"requestType\\\":\\\"1\\\",\\\"formAction\\\":\\\"create\\\",\\\"attachedDocs_0\\\":\\\"emulator-self.jpg_2017529\\\",\\\"upFile0\\\":\\\"./test/fixtures/database/1_808581/2130192/tempAttachments/emulator-self.jpg\\\",\\\"appTypeId\\\":\\\"2\\\"}}}\",\"isDraft\":false,\"offlineFormCreatedDateInMS\":\"1691046952544\",\"formTypeCode\":\"SITE\",\"formTypeName\":\"Site Tasks\",\"instanceGroupId\":\"10940318\"}";
      String reqFilePath = "./test/fixtures/database/1_808581/2130192/OfflineRequestData/1691046952544.txt";
      when(() => mockFileUtility!.readFromFile(reqFilePath))
          .thenReturn(requestData);

      ResultSet resultSet = ResultSet(
          ["AttachRevId", "OfflineUploadFilePath"],
          null,
          [["1691046952732472", "./test/fixtures/database/1_808581/2130192/tempAttachments/emulator-self.jpg"]]);
      String attachQuery = "SELECT AttachRevId,OfflineUploadFilePath FROM FormMsgAttachAndAssocListTbl WHERE ProjectId=2130192 AND FormId=11628410 AND MsgId=1691046952544 AND OfflineUploadFilePath <> ''";
      String attachTableName = "FormMsgAttachAndAssocListTbl";
      when(() => mockDb!.selectFromTable(attachTableName, attachQuery))
          .thenReturn(resultSet);

      final saveFormResult = {
        "formDetailsVO": {
          "templateType": 2,
          "responseRequestByInMS": 1692658799000,
          "pfLocFolderId": 115333480,
          "workflowStatus": "",
          "isDraft": false,
          "formCreationDate": "03-Aug-2023#01:50 CST",
          "userID": "707447\$\$GM6t1V",
          "observationVO": {
            "msgNum": 0,
            "pageNumber": 0,
            "attachments": [],
            "assignedToUserOrgName": "Asite Solutions Ltd",
            "isDraft": false,
            "formDueDays": 12,
            "msgId": "0\$\$9EeG5Z",
            "isActive": true,
            "taskTypeName": "Damages",
            "orgId": "0\$\$OeTQL2",
            "noOfActions": 0,
            "observationTypeId": 0,
            "observationId": 0,
            "hasAttachment": false,
            "locationId": 0,
            "appType": 0,
            "noOfMessages": 0,
            "isCloseOut": false,
            "originatorId": 0,
            "formId": "0\$\$T0pCQX",
            "assignedToUserId": 2017529,
            "lastResponderForOriginator": "707447",
            "formTypeId": "0\$\$T0pCQX",
            "formSyncDate": "2023-08-03 07:50:05.393",
            "lastResponderForAssignedTo": "2017529",
            "generateURI": true,
            "manageTypeVo": {"isDeactive": false, "name": "Architectural", "id": "310497", "projectId": "2130192\$\$oBlSEE", "generateURI": true},
            "expectedFinishDate": "2023-08-21",
            "statusId": 0,
            "assignedToUserName": "Mayur Raval m.",
            "isStatusChangeRestricted": false,
            "allowReopenForm": false,
            "messages": [],
            "instanceGroupId": "0\$\$T0pCQX",
            "projectId": "0\$\$OTy7Kh",
            "startDate": "2023-08-03"
          },
          "msgStatusId": 20,
          "statusid": 1002,
          "canControllerChangeStatus": false,
          "appTypeId": "2",
          "invoiceCountAgainstOrder": "-1",
          "workflowStage": "",
          "hasBimViewAssociations": false,
          "id": "SITE401(2)",
          "msgCode": "RES001",
          "formGroupName": "Site Tasks",
          "statusChangeUserId": 2017529,
          "originatorDisplayName": "Vijay Mavadiya (5336), Asite Solutions",
          "msgUserOrgId": 5763307,
          "allowReopenForm": false,
          "canAccessHistory": true,
          "latestDraftId": "0\$\$9EeG5Z",
          "actions": [
            {
              "distributorUserId": 707447,
              "resourceId": 12338091,
              "resourceStatusId": 0,
              "actionTime": "18 Days",
              "actionCompleteDate": "Thu Aug 03 10:32:00 BST 2023",
              "modelId": "0\$\$jdAtoL",
              "actionCleared": false,
              "dueDate": "Tue Aug 22 00:59:59 BST 2023",
              "msgId": "12338091\$\$SR56ut",
              "isActive": true,
              "viewDate": "",
              "assignedByEmail": "vmavadiya@asite.com",
              "priorityId": 0,
              "assignedByOrgName": "Asite Solutions",
              "resourceCode": "ORI001",
              "actionStatus": 1,
              "resourceParentId": 11628410,
              "recipientId": 2017529,
              "recipientName": "Mayur Raval m., Asite Solutions Ltd",
              "actionCompleted": false,
              "id": "ACTC13744707_2017529_3_1_12338091_11628410",
              "actionDate": "Thu Aug 03 08:50:05 BST 2023",
              "actionDelegated": false,
              "actionNotes": "",
              "assignedBy": "Vijay Mavadiya (5336),Asite Solutions",
              "transNum": "-1",
              "entityType": 0,
              "recipientOrgId": "5763307",
              "generateURI": true,
              "assignedByRole": "",
              "commentMsgId": "12338091\$\$4sYtf2",
              "distListId": 13744707,
              "distributionLevel": 0,
              "actionCompleteDateInMS": 0,
              "actionId": 3,
              "instanceGroupId": "0\$\$T0pCQX",
              "distributionLevelId": "0\$\$7PyQw2",
              "dueDateInMS": 0,
              "projectId": "0\$\$OTy7Kh",
              "remarks": "",
              "actionName": "Respond",
              "instantEmailNotify": "true"
            }
          ],
          "status": "Resolved",
          "canOrigChangeStatus": false,
          "lastName": "Mavadiya (5336)",
          "originatorName": "Vijay Mavadiya (5336)",
          "controllerUserId": 0,
          "msgId": "12338443\$\$B7jKMm",
          "originatorEmail": "vmavadiya@asite.com",
          "msgUserName": "Mayur Raval m.",
          "orgId": "3\$\$R9nrQZ",
          "msgHasAssocAttach": false,
          "locationId": 183882,
          "appType": "Field",
          "noOfMessages": 2,
          "originatorOrgId": 3,
          "isCloseOut": false,
          "originatorId": 707447,
          "hasAttachments": false,
          "formHasAssocAttach": true,
          "actionDateInMS": 0,
          "msgUserOrgName": "Asite Solutions Ltd",
          "hasFormAccess": false,
          "docType": "Apps",
          "generateURI": true,
          "responseRequestBy": "21-Aug-2023#17:59 CST",
          "parentMsgId": 12338091,
          "commId": "11628410\$\$TiyXR9",
          "ownerOrgId": 3,
          "instanceGroupId": "10940318\$\$sVooIT",
          "isThumbnailSupports": false,
          "hasBimListAssociations": false,
          "msgTypeCode": "RES",
          "appBuilderId": "ASI-SITE",
          "hasDocAssocations": false,
          "noOfActions": 0,
          "statusRecordStyle": {"fontType": "PT Sans", "backgroundColor": "#22e0da", "isDeactive": false, "isForOnlyStyleUpdate": false, "statusTypeID": 1, "proxyUserId": 0, "userId": 0, "generateURI": true, "fontEffect": "0#0#0#0", "orgId": "0\$\$OeTQL2", "always_active": false, "statusID": 1002, "defaultPermissionId": 0, "statusName": "Resolved", "settingApplyOn": 1, "isEnableForReviewComment": false, "projectId": "2130192\$\$oBlSEE", "fontColor": "#070ff2"},
          "observationId": 107961,
          "formTypeName": "Site Tasks",
          "statusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000",
          "formId": "11628410\$\$khBZQO",
          "hasOverallStatus": false,
          "orgName": "Asite Solutions",
          "msgOriginatorId": 2017529,
          "formTypeId": "11103151\$\$7K0KWx",
          "folderId": "0\$\$bTnRIK",
          "firstName": "Vijay",
          "lastmodified": "2023-08-03T09:32:30Z",
          "formPrintEnabled": false,
          "project_APD_folder_id": "0\$\$bTnRIK",
          "projectName": "Site Quality Demo",
          "formNum": 401,
          "projectId": "2130192\$\$oBlSEE",
          "updated": "03-Aug-2023#03:32 CST",
          "messageTypeImageName": "icons/form.png",
          "code": "SITE401(2)",
          "indent": -1,
          "statusUpdateDate": "03-Aug-2023#03:32 CST",
          "originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_707447_thumbnail.jpg?v=1650517948000#Vijay",
          "title": "Respond Test case Vijay",
          "flagTypeImageName": "flag_type/flag_0.png",
          "ownerOrgName": "Asite Solutions",
          "dcId": 1,
          "formCreationDateInMS": 1691045405000,
          "isPublic": false,
          "projectStatusId": 5,
          "updatedDateInMS": 1691051549000,
          "statusChangeUserName": "Mayur Raval m.",
          "showPrintIcon": 0,
          "invoiceColourCode": "-1",
          "msgCreatedDateInMS": 0,
          "flagType": 0,
          "hasFormAssocations": false,
          "hasCommentAssocations": false,
          "statusChangeUserEmail": "m.raval@asite.com",
          "statusChangeUserOrg": "Asite Solutions Ltd",
          "msgTypeId": 2,
          "isStatusChangeRestricted": false,
          "formUserSet": [],
          "statusText": "Resolved",
          "typeImage": "icons/form.png",
          "attachmentImageName": "icons/assocform.png"
        },
        "viewFormJson": "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"DistributionDays\":\"12\",\"Organization\":\"\",\"DefectTyoe\":\"Architectural\",\"ExpectedFinishDate\":\"2023-08-21\",\"DefectDescription\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"2017529#Mayur Raval m., Asite Solutions Ltd\"}},\"Defect_Description\":\"Test\",\"LocationName\":\"01 Vijay_Test>Plan-3\",\"StartDate\":\"2023-08-03\",\"ActualFinishDate\":\"\",\"ExpectedFinishDays\":\"12\",\"DS_Logo\":\"images/asite.gif\",\"LastResponder_For_AssignedTo\":\"2017529\",\"TaskType\":\"Damages\",\"isCalibrated\":false,\"ORI_FORMTITLE\":\"Respond Test case Vijay\",\"attachements\":[{\"attachedDocs\":\"\"}],\"OriginatorId\":\"707447 | Vijay Mavadiya (5336), Asite Solutions # Vijay Mavadiya (5336), Asite Solutions\",\"Assigned\":\"Mayur Raval m., Asite Solutions Ltd\",\"Todays_Date\":\"2023-08-03T07:49:36\",\"CurrStage\":\"1\",\"Recent_Defects\":\"\",\"FormCreationDate\":\"\",\"StartDateDisplay\":\"03-Aug-2023\",\"LastResponder_For_Originator\":\"707447\",\"PF_Location_Detail\":\"183882|26846988|null|0\",\"Username\":\"\",\"ORI_USERREF\":\"\",\"Location\":\"183882|Plan-3|01 Vijay_Test>Plan-3\"},\"RES_MSG_Custom_Fields\":{\"Comments\":\"Resolved offline\",\"SHResponse\":\"Yes\",\"ShowHideFlag\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_CREATE\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\",\"DS_FORMAUTONO_ADD\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_Get_All_Responses\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"attachments\":[],\"Asite_System_Data_Read_Only\":{\"_2_Printing_Data\":{\"DS_PRINTEDON\":\"\",\"DS_PRINTEDBY\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMGROUPCODE\":\"\",\"DS_FORMAUTONO\":\"\",\"DS_FORMNAME\":\"Site Tasks\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_5_Form_Data\":{\"DS_DATEOFISSUE\":\"\",\"DS_ISDRAFT_RES_MSG\":\"\",\"Status_Data\":{\"DS_APPROVEDON\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\",\"DS_ALL_FORMSTATUS\":\"1002 # Resolved\",\"DS_APPROVEDBY\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_FORMSTATUS\":\"Open\"},\"DS_DISTRIBUTION\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT_RES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_CLOSE_DUE_DATE\":\"2023-08-21\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_FORMID\":\"\"},\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_6_Form_MSG_Data\":{\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGID\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"411\",\"DS_PROJUSERS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_ACTIONDUEDATE\":\"7\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_PROJDISTUSERS\":\"707447\"}]}},\"selectedControllerUserId\":\"\"}}",
        "offlineFormId": "11628410"
      };
      when(() => mockUseCase!.saveFormToServer(any()))
          .thenAnswer((_) => Future.value(SUCCESS(saveFormResult, null, 200)));

      final formDetailResult = {
        "11628410": {
          "combinedAttachAssocList": [
            {
              "fileType": "filetype/jpg.gif",
              "fileName": "emulator-self.jpg",
              "revisionId": "27212679\$\$BwDTnG",
              "fileSize": "418 KB",
              "hasAccess": true,
              "canDownload": true,
              "publisherUserId": "0",
              "hasBravaSupport": true,
              "docId": "13664226\$\$zbKLSL",
              "attachedBy": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
              "attachedDateInTimeStamp": "Aug 3, 2023 9:32:00 AM",
              "attachedDate": "03-Aug-2023#03:32 CST",
              "createdDateInTimeStamp": "Aug 3, 2023 9:32:00 AM",
              "attachedById": "2017529",
              "attachedByName": "Mayur Raval m.",
              "isLink": false,
              "linkType": "Static",
              "isHasXref": false,
              "documentTypeId": "0",
              "isRevPrivate": false,
              "isAccess": true,
              "isDocActive": true,
              "folderPermissionValue": "0",
              "isRevInDistList": false,
              "isPasswordProtected": false,
              "attachmentId": "0\$\$frWseo",
              "viewAlwaysFormAssociationParent": false,
              "viewAlwaysDocAssociationParent": false,
              "allowDownloadToken": "1\$\$sONifq",
              "isHoopsSupported": false,
              "isPDFTronSupported": false,
              "downloadImageName": "icons/downloads.png",
              "hasOnlineViewerSupport": true,
              "newSysLocation": "project_2130192/formtype_11103151/form_11103151/msg_12338443/27212679.jpg",
              "hashedAttachedById": "2017529\$\$3NMzXW",
              "hasGeoTagInfo": false,
              "type": "3",
              "msgId": "12338443\$\$B7jKMm",
              "msgCreationDate": "Aug 3, 2023 9:32:00 AM",
              "projectId": "2130192\$\$oBlSEE",
              "folderId": "116314555\$\$ySVrm4",
              "dcId": "1",
              "childProjectId": "0",
              "userId": "0",
              "resourceId": "0",
              "parentMsgId": "12338443",
              "parentMsgCode": "RES001",
              "assocsParentId": "0\$\$T0pCQX",
              "totalDocCount": "0",
              "generateURI": true,
              "hasHoopsViewerSupport": false
            },
            {"Location Name": "Plan-3", "Location Path": "Site Quality Demo\\01 Vijay_Test\\Plan-3"}
          ],
          "messages": [
            {
              "projectId": "2130192\$\$oBlSEE",
              "projectName": "Site Quality Demo",
              "code": "SITE401",
              "commId": "11628410\$\$TiyXR9",
              "formId": "11628410\$\$khBZQO",
              "title": "Respond Test case Vijay",
              "userID": "707447\$\$GM6t1V",
              "orgId": "3\$\$R9nrQZ",
              "firstName": "Vijay",
              "lastName": "Mavadiya (5336)",
              "orgName": "Asite Solutions",
              "originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_707447_thumbnail.jpg?v=1650517948000#Vijay",
              "originatorDisplayName": "Vijay Mavadiya (5336), Asite Solutions",
              "actions": [],
              "allActions": [
                {
                  "projectId": "0\$\$OTy7Kh",
                  "resourceParentId": 11628410,
                  "resourceId": 12338091,
                  "resourceCode": "ORI001",
                  "resourceStatusId": 0,
                  "msgId": "12338091\$\$SR56ut",
                  "commentMsgId": "12338091\$\$4sYtf2",
                  "actionId": 3,
                  "actionName": "Respond",
                  "actionStatus": 1,
                  "priorityId": 0,
                  "actionDate": "Thu Aug 03 08:50:05 BST 2023",
                  "dueDate": "Tue Aug 22 00:59:59 BST 2023",
                  "distributorUserId": 707447,
                  "recipientId": 2017529,
                  "remarks": "",
                  "distListId": 13744707,
                  "transNum": "-1",
                  "actionTime": "18 Days",
                  "actionCompleteDate": "Thu Aug 03 10:32:00 BST 2023",
                  "instantEmailNotify": "true",
                  "actionNotes": "",
                  "entityType": 0,
                  "instanceGroupId": "0\$\$T0pCQX",
                  "isActive": true,
                  "modelId": "0\$\$jdAtoL",
                  "assignedBy": "Vijay Mavadiya (5336),Asite Solutions",
                  "recipientName": "Mayur Raval m., Asite Solutions Ltd",
                  "recipientOrgId": "5763307",
                  "id": "ACTC13744707_2017529_3_1_12338091_11628410",
                  "viewDate": "",
                  "assignedByOrgName": "Asite Solutions",
                  "distributionLevel": 0,
                  "distributionLevelId": "0\$\$7PyQw2",
                  "dueDateInMS": 1692662399000,
                  "actionCompleteDateInMS": 1691055120000,
                  "actionDelegated": false,
                  "actionCleared": false,
                  "actionCompleted": true,
                  "assignedByEmail": "vmavadiya@asite.com",
                  "assignedByRole": "",
                  "generateURI": true
                }
              ],
              "noOfActions": 0,
              "observationId": 107961,
              "locationId": 183882,
              "pfLocFolderId": 0,
              "updated": "2023-08-03T09:32:29Z",
              "duration": "1 hour ago",
              "hasAttachments": true,
              "msgCode": "ORI001",
              "docType": "Apps",
              "formTypeName": "Site Tasks",
              "userRefCode": "N/A",
              "status": "Resolved",
              "responseRequestBy": "21-Aug-2023#17:59 CST",
              "controllerName": "N/A",
              "hasDocAssocations": false,
              "hasBimViewAssociations": false,
              "hasBimListAssociations": false,
              "hasFormAssocations": false,
              "hasCommentAssocations": false,
              "formHasAssocAttach": true,
              "msgHasAssocAttach": false,
              "formCreationDate": "2023-08-03T07:50:05Z",
              "msgCreatedDate": "03-Aug-2023#01:50 CST",
              "folderId": "0\$\$bTnRIK",
              "msgId": "12338091\$\$SR56ut",
              "parentMsgId": 0,
              "msgTypeId": 1,
              "msgStatusId": 20,
              "msgStatusName": "Sent",
              "indent": -1,
              "formTypeId": "11103151\$\$7K0KWx",
              "formNum": 401,
              "msgOriginatorId": 707447,
              "hashedMsgOriginatorId": "707447\$\$GM6t1V",
              "formPrintEnabled": true,
              "showPrintIcon": 1,
              "sentNames": ["Mayur Raval m., Asite Solutions Ltd"],
              "templateType": 2,
              "instanceGroupId": "10940318\$\$sVooIT",
              "noOfMessages": 0,
              "isDraft": false,
              "dcId": 1,
              "statusid": 1002,
              "originatorId": 707447,
              "isCloseOut": false,
              "isStatusChangeRestricted": false,
              "project_APD_folder_id": "110997340\$\$VInsq6",
              "allowReopenForm": true,
              "hasOverallStatus": true,
              "formUserSet": [],
              "canOrigChangeStatus": false,
              "canControllerChangeStatus": false,
              "appType": "2",
              "msgTypeCode": "ORI",
              "formGroupName": "Site Tasks",
              "id": "SITE401",
              "statusText": "Resolved",
              "statusChangeUserId": 2017529,
              "statusUpdateDate": "2023-08-03T09:32:29Z",
              "statusChangeUserName": "Mayur Raval m.",
              "statusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000",
              "statusChangeUserEmail": "m.raval@asite.com",
              "statusChangeUserOrg": "Asite Solutions Ltd",
              "originatorEmail": "vmavadiya@asite.com",
              "statusRecordStyle": {"settingApplyOn": 1, "fontType": "PT Sans", "fontEffect": "0#0#0#0", "fontColor": "#070ff2", "backgroundColor": "#22e0da", "isForOnlyStyleUpdate": false, "always_active": false, "userId": 0, "isDeactive": false, "defaultPermissionId": 0, "statusName": "Resolved", "statusID": 1002, "statusTypeID": 1, "projectId": "2130192\$\$oBlSEE", "orgId": "0\$\$OeTQL2", "proxyUserId": 0, "isEnableForReviewComment": false, "generateURI": true},
              "invoiceCountAgainstOrder": "-1",
              "invoiceColourCode": "-1",
              "controllerUserId": 0,
              "offlineFormId": "-1",
              "customFieldsValueVOs": {},
              "updatedDateInMS": 1691051549000,
              "formCreationDateInMS": 1691045405000,
              "msgCreatedDateInMS": 1691045405000,
              "flagType": 0,
              "latestDraftId": "0\$\$9EeG5Z",
              "hasFormAccess": false,
              "jsonData": "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"DistributionDays\":\"12\",\"Organization\":\"\",\"DefectTyoe\":\"Architectural\",\"ExpectedFinishDate\":\"2023-08-21\",\"DefectDescription\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"2017529#Mayur Raval m., Asite Solutions Ltd\"}},\"Defect_Description\":\"Test\",\"LocationName\":\"01 Vijay_Test>Plan-3\",\"StartDate\":\"2023-08-03\",\"ActualFinishDate\":\"\",\"ExpectedFinishDays\":\"12\",\"DS_Logo\":\"images/asite.gif\",\"LastResponder_For_AssignedTo\":\"2017529\",\"TaskType\":\"Damages\",\"isCalibrated\":false,\"ORI_FORMTITLE\":\"Respond Test case Vijay\",\"attachements\":[{\"attachedDocs\":\"\"}],\"OriginatorId\":\"707447 | Vijay Mavadiya (5336), Asite Solutions # Vijay Mavadiya (5336), Asite Solutions\",\"Assigned\":\"Mayur Raval m., Asite Solutions Ltd\",\"Todays_Date\":\"2023-08-03T07:49:36\",\"CurrStage\":\"1\",\"Recent_Defects\":\"\",\"FormCreationDate\":\"\",\"StartDateDisplay\":\"03-Aug-2023\",\"LastResponder_For_Originator\":\"707447\",\"PF_Location_Detail\":\"183882|26846988|null|0\",\"Username\":\"\",\"ORI_USERREF\":\"\",\"Location\":\"183882|Plan-3|01 Vijay_Test>Plan-3\"},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"SHResponse\":\"Yes\",\"ShowHideFlag\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_CREATE\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\",\"DS_FORMAUTONO_ADD\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_Get_All_Responses\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"attachments\":[],\"Asite_System_Data_Read_Only\":{\"_2_Printing_Data\":{\"DS_PRINTEDON\":\"\",\"DS_PRINTEDBY\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMGROUPCODE\":\"\",\"DS_FORMAUTONO\":\"\",\"DS_FORMNAME\":\"Site Tasks\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_5_Form_Data\":{\"DS_DATEOFISSUE\":\"\",\"DS_ISDRAFT_RES_MSG\":\"\",\"Status_Data\":{\"DS_APPROVEDON\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_APPROVEDBY\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_FORMSTATUS\":\"\"},\"DS_DISTRIBUTION\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT_RES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_CLOSE_DUE_DATE\":\"2023-08-21\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_FORMID\":\"\"},\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Vijay Mavadiya (5336), Asite Solutions\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_6_Form_MSG_Data\":{\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGID\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_PROJUSERS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_ACTIONDUEDATE\":\"12\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_PROJDISTUSERS\":\"2017529\"}]}}}}",
              "formPermissions": {"can_edit_ORI": false, "can_respond": true, "restrictChangeFormStatus": false, "controllerUserId": 0, "isProjectArchived": false, "can_distribute": false, "can_forward": false, "oriMsgId": "12338091\$\$SR56ut"},
              "sentActions": [
                {
                  "projectId": "0\$\$OTy7Kh",
                  "resourceParentId": 11628410,
                  "resourceId": 12338091,
                  "resourceCode": "ORI001",
                  "resourceStatusId": 0,
                  "msgId": "12338091\$\$SR56ut",
                  "commentMsgId": "12338091\$\$4sYtf2",
                  "actionId": 3,
                  "actionName": "Respond",
                  "actionStatus": 1,
                  "priorityId": 0,
                  "actionDate": "Thu Aug 03 08:50:05 BST 2023",
                  "dueDate": "Tue Aug 22 00:59:59 BST 2023",
                  "distributorUserId": 707447,
                  "recipientId": 2017529,
                  "remarks": "",
                  "distListId": 13744707,
                  "transNum": "-1",
                  "actionTime": "18 Days",
                  "actionCompleteDate": "Thu Aug 03 10:32:00 BST 2023",
                  "instantEmailNotify": "true",
                  "actionNotes": "",
                  "entityType": 0,
                  "instanceGroupId": "0\$\$T0pCQX",
                  "isActive": true,
                  "modelId": "0\$\$jdAtoL",
                  "assignedBy": "Vijay Mavadiya (5336),Asite Solutions",
                  "recipientName": "Mayur Raval m., Asite Solutions Ltd",
                  "recipientOrgId": "5763307",
                  "id": "ACTC13744707_2017529_3_1_12338091_11628410",
                  "viewDate": "",
                  "assignedByOrgName": "Asite Solutions",
                  "distributionLevel": 0,
                  "distributionLevelId": "0\$\$7PyQw2",
                  "dueDateInMS": 1692662399000,
                  "actionCompleteDateInMS": 1691055120000,
                  "actionDelegated": false,
                  "actionCleared": false,
                  "actionCompleted": true,
                  "assignedByEmail": "vmavadiya@asite.com",
                  "assignedByRole": "",
                  "generateURI": true
                }
              ],
              "fixedFormData": {
                "DS_ALL_ACTIVE_FORM_STATUS": "{\"Items\":{\"Item\":[{\"Value\":\"23 # Deactivated\",\"Name\":\"Deactivated\"},{\"Value\":\"1001 # Open\",\"Name\":\"Open\"},{\"Value\":\"1002 # Resolved\",\"Name\":\"Resolved\"},{\"Value\":\"1003 # Verified\",\"Name\":\"Verified\"}]}}",
                "DS_WORKINGUSER_ID": "{\"Items\":{\"Item\":[{\"Value\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"Name\":\"Mayur Raval m., Asite Solutions Ltd\"}]}}",
                "DS_ORIGINATOR": "Vijay Mavadiya (5336), Asite Solutions",
                "DS_MSGCREATOR": "Vijay Mavadiya (5336), Asite Solutions",
                "DS_INCOMPLETE_ACTIONS": "{\"Items\":{\"Item\":[{\"Value\":\"|707447| # Respond\",\"Name\":\"Respond\"}]}}",
                "DS_ISDRAFT": "NO",
                "DS_ISDRAFT_FWD_MSG": "NO",
                "DS_MSGDATE": "2023-08-03 07:50:05",
                "DS_PROJDISTUSERS": "{\"Items\":{\"Item\":[{\"Value\":\"1161363#Chandresh Patel, Asite Solutions\",\"Name\":\"Chandresh Patel, Asite Solutions\"},{\"Value\":\"514806#Dhaval Vekaria (5226), Asite Solutions\",\"Name\":\"Dhaval Vekaria (5226), Asite Solutions\"},{\"Value\":\"859155#Saurabh Banethia (5327), Asite Solutions\",\"Name\":\"Saurabh Banethia (5327), Asite Solutions\"},{\"Value\":\"650044#savita dangee (5231), Asite Solutions\",\"Name\":\"savita dangee (5231), Asite Solutions\"},{\"Value\":\"707447#Vijay Mavadiya (5336), Asite Solutions\",\"Name\":\"Vijay Mavadiya (5336), Asite Solutions\"},{\"Value\":\"2017529#Mayur Raval m., Asite Solutions Ltd\",\"Name\":\"Mayur Raval m., Asite Solutions Ltd\"}]}}",
                "DS_FORMID": "SITE401",
                "DS_ALL_FORMSTATUS": "{\"Items\":{\"Item\":[{\"Value\":\"1001 # Open\",\"Name\":\"Open\"},{\"Value\":\"1002 # Resolved\",\"Name\":\"Resolved\"},{\"Value\":\"1003 # Verified\",\"Name\":\"Verified\"}]}}",
                "comboList": "DS_ALL_FORMSTATUS,DS_WORKINGUSER_ID,DS_ALL_ACTIVE_FORM_STATUS,DS_INCOMPLETE_ACTIONS,DS_Get_All_Responses,DS_PROJDISTUSERS,DS_CHECK_FORM_PERMISSION_USER,DS_ASI_SITE_getDefectTypesForProjects_pf",
                "DS_Get_All_Responses": "{\"Items\":{\"Item\":[{\"Value3\":\"03/08/2023\",\"Value4\":\"Resolved offline\",\"Value1\":\"RES001\",\"Value2\":\"Mayur Raval m., Asite Solutions Ltd\",\"Value7\":\"03/08/2023 09:32:29\",\"Value5\":\"1002\",\"Name\":\"DS_Get_All_Responses\",\"Value6\":\"Resolved\"}]}}",
                "DS_ASI_SITE_getDefectTypesForProjects_pf": "{\"Items\":{\"Item\":[{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Architectural\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Civil\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Computer\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"EC\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Electrical\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Fire Safety\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"},{\"Value3\":\"\",\"Value4\":\"\",\"Value1\":\"Mechanical\",\"Value2\":\"\",\"Name\":\"DS_ASI_SITE_getDefectTypesForProjects_pf\"}]}}",
                "DS_ISDRAFT_EDITORI": "NO",
                "DS_PROJECTNAME": "Site Quality Demo",
                "DS_FORMSTATUS": "Resolved",
                "DS_WORKINGUSER": "Mayur Raval m., Asite Solutions Ltd",
                "DS_FORMNAME": "Site Tasks",
                "DS_DATEOFISSUE": "2023-08-03 07:50:05",
                "DS_CHECK_FORM_PERMISSION_USER": "{\"Items\":{\"Item\":[{\"Value3\":\"All_Org\",\"Value4\":\"Yes\",\"Value1\":\"2130192\",\"Value2\":\"2017529\",\"Name\":\"DS_MTA_CHECK_FORM_PERMISSION_USER\"}]}}"
              },
              "ownerOrgName": "Asite Solutions",
              "ownerOrgId": 3,
              "originatorOrgId": 3,
              "msgUserOrgId": 3,
              "msgUserOrgName": "Asite Solutions",
              "msgUserName": "Vijay Mavadiya (5336)",
              "originatorName": "Vijay Mavadiya (5336)",
              "isPublic": false,
              "responseRequestByInMS": 0,
              "actionDateInMS": 0,
              "formGroupCode": "SITE",
              "isThumbnailSupports": false,
              "canAccessHistory": false,
              "projectStatusId": 5,
              "generateURI": true
            },
            {
              "projectId": "2130192\$\$oBlSEE",
              "projectName": "Site Quality Demo",
              "code": "SITE401",
              "commId": "11628410\$\$TiyXR9",
              "formId": "11628410\$\$khBZQO",
              "title": "Respond Test case Vijay",
              "userID": "707447\$\$GM6t1V",
              "orgId": "3\$\$R9nrQZ",
              "firstName": "Vijay",
              "lastName": "Mavadiya (5336)",
              "orgName": "Asite Solutions",
              "originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
              "originatorDisplayName": "Mayur Raval m., Asite Solutions Ltd",
              "actions": [],
              "allActions": [
                {
                  "projectId": "0\$\$OTy7Kh",
                  "resourceParentId": 11628410,
                  "resourceId": 12338091,
                  "resourceCode": "ORI001",
                  "resourceStatusId": 0,
                  "msgId": "12338091\$\$SR56ut",
                  "commentMsgId": "12338091\$\$4sYtf2",
                  "actionId": 3,
                  "actionName": "Respond",
                  "actionStatus": 1,
                  "priorityId": 0,
                  "actionDate": "Thu Aug 03 08:50:05 BST 2023",
                  "dueDate": "Tue Aug 22 00:59:59 BST 2023",
                  "distributorUserId": 707447,
                  "recipientId": 2017529,
                  "remarks": "",
                  "distListId": 13744707,
                  "transNum": "-1",
                  "actionTime": "18 Days",
                  "actionCompleteDate": "Thu Aug 03 10:32:00 BST 2023",
                  "instantEmailNotify": "true",
                  "actionNotes": "",
                  "entityType": 0,
                  "instanceGroupId": "0\$\$T0pCQX",
                  "isActive": true,
                  "modelId": "0\$\$jdAtoL",
                  "assignedBy": "Vijay Mavadiya (5336),Asite Solutions",
                  "recipientName": "Mayur Raval m., Asite Solutions Ltd",
                  "recipientOrgId": "5763307",
                  "id": "ACTC13744707_2017529_3_1_12338091_11628410",
                  "viewDate": "",
                  "assignedByOrgName": "Asite Solutions",
                  "distributionLevel": 0,
                  "distributionLevelId": "0\$\$7PyQw2",
                  "dueDateInMS": 1692662399000,
                  "actionCompleteDateInMS": 0,
                  "actionDelegated": false,
                  "actionCleared": false,
                  "actionCompleted": false,
                  "assignedByEmail": "vmavadiya@asite.com",
                  "assignedByRole": "",
                  "generateURI": true
                }
              ],
              "noOfActions": 0,
              "observationId": 107961,
              "locationId": 183882,
              "pfLocFolderId": 0,
              "updated": "2023-08-03T09:32:29Z",
              "duration": "1 min ago",
              "hasAttachments": true,
              "msgCode": "RES001",
              "docType": "Apps",
              "formTypeName": "Site Tasks",
              "userRefCode": "N/A",
              "status": "Resolved",
              "responseRequestBy": "21-Aug-2023#17:59 CST",
              "controllerName": "N/A",
              "hasDocAssocations": false,
              "hasBimViewAssociations": false,
              "hasBimListAssociations": false,
              "hasFormAssocations": false,
              "hasCommentAssocations": false,
              "formHasAssocAttach": true,
              "msgHasAssocAttach": true,
              "formCreationDate": "2023-08-03T07:50:05Z",
              "msgCreatedDate": "03-Aug-2023#03:32 CST",
              "folderId": "0\$\$bTnRIK",
              "msgId": "12338443\$\$B7jKMm",
              "parentMsgId": 12338091,
              "msgTypeId": 2,
              "msgStatusId": 20,
              "msgStatusName": "Sent",
              "indent": 0,
              "formTypeId": "11103151\$\$7K0KWx",
              "formNum": 401,
              "msgOriginatorId": 2017529,
              "hashedMsgOriginatorId": "2017529\$\$3NMzXW",
              "formPrintEnabled": true,
              "showPrintIcon": 1,
              "sentNames": ["Vijay Mavadiya (5336), Asite Solutions"],
              "templateType": 2,
              "instanceGroupId": "10940318\$\$sVooIT",
              "noOfMessages": 0,
              "isDraft": false,
              "dcId": 1,
              "statusid": 1002,
              "originatorId": 707447,
              "isCloseOut": false,
              "isStatusChangeRestricted": false,
              "project_APD_folder_id": "110997340\$\$VInsq6",
              "allowReopenForm": true,
              "hasOverallStatus": true,
              "formUserSet": [],
              "canOrigChangeStatus": false,
              "canControllerChangeStatus": false,
              "appType": "2",
              "msgTypeCode": "RES",
              "formGroupName": "Site Tasks",
              "id": "SITE401",
              "statusText": "Resolved",
              "statusChangeUserId": 2017529,
              "statusUpdateDate": "2023-08-03T09:32:29Z",
              "statusChangeUserName": "Mayur Raval m.",
              "statusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000",
              "statusChangeUserEmail": "m.raval@asite.com",
              "statusChangeUserOrg": "Asite Solutions Ltd",
              "originatorEmail": "vmavadiya@asite.com",
              "statusRecordStyle": {"settingApplyOn": 1, "fontType": "PT Sans", "fontEffect": "0#0#0#0", "fontColor": "#070ff2", "backgroundColor": "#22e0da", "isForOnlyStyleUpdate": false, "always_active": false, "userId": 0, "isDeactive": false, "defaultPermissionId": 0, "statusName": "Resolved", "statusID": 1002, "statusTypeID": 1, "projectId": "2130192\$\$oBlSEE", "orgId": "0\$\$OeTQL2", "proxyUserId": 0, "isEnableForReviewComment": false, "generateURI": true},
              "invoiceCountAgainstOrder": "-1",
              "invoiceColourCode": "-1",
              "controllerUserId": 0,
              "offlineFormId": "-1",
              "customFieldsValueVOs": {},
              "updatedDateInMS": 1691051549000,
              "formCreationDateInMS": 1691045405000,
              "msgCreatedDateInMS": 1691051549000,
              "flagType": 0,
              "latestDraftId": "0\$\$9EeG5Z",
              "hasFormAccess": false,
              "jsonData": "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"DistributionDays\":\"12\",\"Organization\":\"\",\"DefectTyoe\":\"Architectural\",\"ExpectedFinishDate\":\"2023-08-21\",\"DefectDescription\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"2017529#Mayur Raval m., Asite Solutions Ltd\"}},\"Defect_Description\":\"Test\",\"LocationName\":\"01 Vijay_Test>Plan-3\",\"StartDate\":\"2023-08-03\",\"ActualFinishDate\":\"\",\"ExpectedFinishDays\":\"12\",\"DS_Logo\":\"images/asite.gif\",\"LastResponder_For_AssignedTo\":\"2017529\",\"TaskType\":\"Damages\",\"isCalibrated\":false,\"ORI_FORMTITLE\":\"Respond Test case Vijay\",\"attachements\":[{\"attachedDocs\":\"\"}],\"OriginatorId\":\"707447 | Vijay Mavadiya (5336), Asite Solutions # Vijay Mavadiya (5336), Asite Solutions\",\"Assigned\":\"Mayur Raval m., Asite Solutions Ltd\",\"Todays_Date\":\"2023-08-03T07:49:36\",\"CurrStage\":\"1\",\"Recent_Defects\":\"\",\"FormCreationDate\":\"\",\"StartDateDisplay\":\"03-Aug-2023\",\"LastResponder_For_Originator\":\"707447\",\"PF_Location_Detail\":\"183882|26846988|null|0\",\"Username\":\"\",\"ORI_USERREF\":\"\",\"Location\":\"183882|Plan-3|01 Vijay_Test>Plan-3\"},\"RES_MSG_Custom_Fields\":{\"Comments\":\"Resolved offline\",\"SHResponse\":\"Yes\",\"ShowHideFlag\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_CREATE\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\",\"DS_FORMAUTONO_ADD\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_Get_All_Responses\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"attachments\":[],\"Asite_System_Data_Read_Only\":{\"_2_Printing_Data\":{\"DS_PRINTEDON\":\"\",\"DS_PRINTEDBY\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMGROUPCODE\":\"\",\"DS_FORMAUTONO\":\"\",\"DS_FORMNAME\":\"Site Tasks\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_5_Form_Data\":{\"DS_DATEOFISSUE\":\"\",\"DS_ISDRAFT_RES_MSG\":\"\",\"Status_Data\":{\"DS_APPROVEDON\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\",\"DS_ALL_FORMSTATUS\":\"1002 # Resolved\",\"DS_APPROVEDBY\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_FORMSTATUS\":\"Open\"},\"DS_DISTRIBUTION\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT_RES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_CLOSE_DUE_DATE\":\"2023-08-21\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_FORMID\":\"\"},\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_6_Form_MSG_Data\":{\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGID\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"411\",\"DS_PROJUSERS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_ACTIONDUEDATE\":\"7\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_PROJDISTUSERS\":\"707447\"}]}},\"selectedControllerUserId\":\"\"}}",
              "formPermissions": {"can_edit_ORI": false, "can_respond": false, "restrictChangeFormStatus": false, "controllerUserId": 0, "isProjectArchived": false, "can_distribute": false, "can_forward": false, "oriMsgId": "12338091\$\$SR56ut"},
              "sentActions": [
                {
                  "projectId": "0\$\$OTy7Kh",
                  "resourceParentId": 11628410,
                  "resourceId": 12338443,
                  "resourceCode": "RES001",
                  "resourceStatusId": 0,
                  "msgId": "12338443\$\$B7jKMm",
                  "commentMsgId": "12338443\$\$QT5IHj",
                  "actionId": 3,
                  "actionName": "Respond",
                  "actionStatus": 0,
                  "priorityId": 0,
                  "actionDate": "Thu Aug 03 10:32:29 BST 2023",
                  "dueDate": "Tue Aug 15 06:59:59 BST 2023",
                  "distributorUserId": 2017529,
                  "recipientId": 707447,
                  "remarks": "",
                  "distListId": 13745056,
                  "transNum": "-1",
                  "actionTime": "11 Days",
                  "actionCompleteDate": "",
                  "instantEmailNotify": "true",
                  "actionNotes": "",
                  "entityType": 0,
                  "instanceGroupId": "0\$\$T0pCQX",
                  "isActive": true,
                  "modelId": "0\$\$jdAtoL",
                  "assignedBy": "Mayur Raval m.,Asite Solutions Ltd",
                  "recipientName": "Vijay Mavadiya (5336), Asite Solutions",
                  "recipientOrgId": "3",
                  "id": "ACTC13745056_707447_3_1_12338443_11628410",
                  "viewDate": "",
                  "assignedByOrgName": "Asite Solutions Ltd",
                  "distributionLevel": 0,
                  "distributionLevelId": "0\$\$7PyQw2",
                  "dueDateInMS": 1692079199000,
                  "actionCompleteDateInMS": 0,
                  "actionDelegated": false,
                  "actionCleared": false,
                  "actionCompleted": false,
                  "assignedByEmail": "m.raval@asite.com",
                  "assignedByRole": "",
                  "generateURI": true
                }
              ],
              "fixedFormData": {
                "DS_ALL_ACTIVE_FORM_STATUS": "{\"Items\":{\"Item\":[{\"Value\":\"23 # Deactivated\",\"Name\":\"Deactivated\"},{\"Value\":\"1001 # Open\",\"Name\":\"Open\"},{\"Value\":\"1002 # Resolved\",\"Name\":\"Resolved\"},{\"Value\":\"1003 # Verified\",\"Name\":\"Verified\"}]}}",
                "DS_WORKINGUSER_ID": "{\"Items\":{\"Item\":[{\"Value\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"Name\":\"Mayur Raval m., Asite Solutions Ltd\"}]}}",
                "DS_ORIGINATOR": "Vijay Mavadiya (5336), Asite Solutions",
                "DS_MSGCREATOR": "Mayur Raval m., Asite Solutions Ltd",
                "DS_INCOMPLETE_ACTIONS": "{\"Items\":{\"Item\":[{\"Value\":\"|707447| # Respond\",\"Name\":\"Respond\"}]}}",
                "DS_ISDRAFT": "NO",
                "DS_ISDRAFT_FWD_MSG": "NO",
                "DS_MSGDATE": "2023-08-03 09:32:29",
                "DS_FORMID": "SITE401",
                "DS_ALL_FORMSTATUS": "{\"Items\":{\"Item\":[{\"Value\":\"1001 # Open\",\"Name\":\"Open\"},{\"Value\":\"1002 # Resolved\",\"Name\":\"Resolved\"},{\"Value\":\"1003 # Verified\",\"Name\":\"Verified\"}]}}",
                "comboList": "DS_GET_APP_ACTION_DETAILS,DS_ALL_FORMSTATUS,DS_WORKINGUSER_ID,DS_ALL_ACTIVE_FORM_STATUS,DS_INCOMPLETE_ACTIONS,DS_Get_All_Responses,DS_CHECK_FORM_PERMISSION_USER",
                "DS_Get_All_Responses": "{\"Items\":{\"Item\":[{\"Value3\":\"03/08/2023\",\"Value4\":\"Resolved offline\",\"Value1\":\"RES001\",\"Value2\":\"Mayur Raval m., Asite Solutions Ltd\",\"Value7\":\"03/08/2023 09:32:29\",\"Value5\":\"1002\",\"Name\":\"DS_Get_All_Responses\",\"Value6\":\"Resolved\"}]}}",
                "DS_ISDRAFT_EDITORI": "NO",
                "DS_PROJECTNAME": "Site Quality Demo",
                "DS_FORMSTATUS": "Resolved",
                "DS_GET_APP_ACTION_DETAILS": "{\"Items\":{\"Item\":[{\"Value3\":\"7\",\"Value1\":\"ASI-SITE\",\"Value2\":\"Respond\",\"Name\":\"DS_GET_APP_ACTION_DETAILS\"},{\"Value3\":\"-1\",\"Value1\":\"ASI-SITE\",\"Value2\":\"For Information\",\"Name\":\"DS_GET_APP_ACTION_DETAILS\"}]}}",
                "DS_WORKINGUSER": "Mayur Raval m., Asite Solutions Ltd",
                "DS_FORMNAME": "Site Tasks",
                "DS_DATEOFISSUE": "2023-08-03 07:50:05",
                "DS_CHECK_FORM_PERMISSION_USER": "{\"Items\":{\"Item\":[{\"Value3\":\"All_Org\",\"Value4\":\"Yes\",\"Value1\":\"2130192\",\"Value2\":\"2017529\",\"Name\":\"DS_MTA_CHECK_FORM_PERMISSION_USER\"}]}}"
              },
              "ownerOrgName": "Asite Solutions",
              "ownerOrgId": 3,
              "originatorOrgId": 3,
              "msgUserOrgId": 5763307,
              "msgUserOrgName": "Asite Solutions Ltd",
              "msgUserName": "Mayur Raval m.",
              "originatorName": "Vijay Mavadiya (5336)",
              "isPublic": false,
              "responseRequestByInMS": 0,
              "actionDateInMS": 0,
              "formGroupCode": "SITE",
              "isThumbnailSupports": false,
              "canAccessHistory": false,
              "projectStatusId": 5,
              "generateURI": true
            }
          ]
        }
      };
      when(() => mockProjectUseCase!.getFormMessageBatchList(any()))
          .thenAnswer((_) => Future.value(SUCCESS(formDetailResult, null, 200)));

      String selectOldAttachQuery = "SELECT * FROM FormMsgAttachAndAssocListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11628410";
      ResultSet attchResultSet = ResultSet(
          ["ProjectId", "FormTypeId", "FormId", "MsgId", "AttachmentType", "AttachAssocDetailJson", "OfflineUploadFilePath", "AttachDocId", "AttachRevId", "AttachFileName", "AssocProjectId", "AssocDocFolderId", "AssocDocRevisionId", "AssocFormCommId", "AssocCommentMsgId", "AssocCommentId", "AssocCommentRevisionId", "AssocViewModelId", "AssocViewId", "AssocListModelId", "AssocListId", "AttachSize",]
          , null, [
        [
          "2130192",
          "11103151",
          "11628410",
          "1691046952544",
          "3",
          "{\"fileType\":\"filetype/jpg.gif\",\"fileName\":\"emulator-self.jpg\",\"revisionId\":\"1691046952732472\",\"fileSize\":\"418 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1691046952732472\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-08-03 12:45:52.052\",\"attachedDate\":\"2023-08-03 12:45:52.052\",\"attachedById\":\"2017529\",\"attachedByName\":\"Mayur Raval m.\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":1691046952544,\"msgCreationDate\":\"2023-08-03 12:45:52.052\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":1691046952544,\"parentMsgCode\":\"RES001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}",
          "./test/fixtures/database/1_808581/2130192/tempAttachments/emulator-self.jpg",
          "1691046952732472",
          "1691046952732472",
          "emulator-self.jpg",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "",
          "0"
        ]
      ]);
      when(() => mockDb!.selectFromTable(attachTableName, selectOldAttachQuery))
          .thenReturn(attchResultSet);

      String attachPath1 = "./test/fixtures/files/2130192/Attachments/27212679.jpg";
      when(() => mockFileUtility!.isFileExist(attachPath1))
          .thenReturn(false);
      String attachOldPath1 = "./test/fixtures/files/2130192/Attachments/1691046952732472.jpg";
      when(() => mockFileUtility!.isFileExist(attachOldPath1))
          .thenReturn(true);
      when(() => mockFileUtility!.renameFile(attachOldPath1, attachPath1))
          .thenReturn(null);

      String removeFormQuery = "DELETE FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11628410";
      when(() => mockDb!.executeQuery(removeFormQuery))
          .thenReturn(null);
      String removeFormMsgQuery = "DELETE FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11628410";
      when(() => mockDb!.executeQuery(removeFormMsgQuery))
          .thenReturn(null);
      String removeFormMsgActQuery = "DELETE FROM FormMsgActionListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11628410";
      when(() => mockDb!.executeQuery(removeFormMsgActQuery))
          .thenReturn(null);
      String removeFormMsgAttachQuery = "DELETE FROM FormMsgAttachAndAssocListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11628410";
      when(() => mockDb!.executeQuery(removeFormMsgAttachQuery))
          .thenReturn(null);
      //Below changes for Form DAO mock
      String formTableName = "FormListTbl";
      String formTableQuery = "CREATE TABLE IF NOT EXISTS FormListTbl(ProjectId INTEGER NOT NULL,FormId TEXT NOT NULL,AppTypeId INTEGER,FormTypeId INTEGER,InstanceGroupId INTEGER NOT NULL,FormTitle TEXT,Code TEXT,CommentId INTEGER,MessageId INTEGER,ParentMessageId INTEGER,OrgId INTEGER,FirstName TEXT,LastName TEXT,OrgName TEXT,Originator TEXT,OriginatorDisplayName TEXT,NoOfActions INTEGER,ObservationId INTEGER,LocationId INTEGER,PfLocFolderId INTEGER,Updated TEXT,AttachmentImageName TEXT,MsgCode TEXT,TypeImage TEXT,DocType TEXT,HasAttachments INTEGER NOT NULL DEFAULT 0,HasDocAssocations INTEGER NOT NULL DEFAULT 0,HasBimViewAssociations INTEGER NOT NULL DEFAULT 0,HasFormAssocations INTEGER NOT NULL DEFAULT 0,HasCommentAssocations INTEGER NOT NULL DEFAULT 0,FormHasAssocAttach INTEGER NOT NULL DEFAULT 0,FormCreationDate TEXT,FolderId INTEGER,MsgTypeId INTEGER,MsgStatusId INTEGER,FormNumber INTEGER,MsgOriginatorId INTEGER,TemplateType INTEGER,IsDraft INTEGER NOT NULL DEFAULT 0,StatusId INTEGER,OriginatorId INTEGER,IsStatusChangeRestricted INTEGER NOT NULL DEFAULT 0,AllowReopenForm INTEGER NOT NULL DEFAULT 0,CanOrigChangeStatus INTEGER NOT NULL DEFAULT 0,MsgTypeCode TEXT,Id TEXT,StatusChangeUserId INTEGER,StatusUpdateDate TEXT,StatusChangeUserName TEXT,StatusChangeUserPic TEXT,StatusChangeUserEmail TEXT,StatusChangeUserOrg TEXT,OriginatorEmail TEXT,ControllerUserId INTEGER,UpdatedDateInMS INTEGER,FormCreationDateInMS INTEGER,ResponseRequestByInMS INTEGER,FlagType INTEGER,LatestDraftId INTEGER,FlagTypeImageName TEXT,MessageTypeImageName TEXT,CanAccessHistory INTEGER NOT NULL DEFAULT 0,FormJsonData TEXT,Status TEXT,AttachedDocs TEXT,IsUploadAttachmentInTemp INTEGER NOT NULL DEFAULT 0,IsSync INTEGER NOT NULL DEFAULT 0,UserRefCode TEXT,HasActions INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,IsOfflineCreated INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,IsForDefect INTEGER NOT NULL DEFAULT 0,IsForApps INTEGER NOT NULL DEFAULT 0,ObservationDefectTypeId TEXT NOT NULL DEFAULT '0',StartDate TEXT NOT NULL,ExpectedFinishDate TEXT NOT NULL,IsActive INTEGER NOT NULL DEFAULT 0,ObservationCoordinates TEXT,AnnotationId TEXT,IsCloseOut INTEGER NOT NULL DEFAULT 0,AssignedToUserId INTEGER NOT NULL,AssignedToUserName TEXT,AssignedToUserOrgName TEXT,MsgNum INTEGER,RevisionId INTEGER,RequestJsonForOffline TEXT,FormDueDays TEXT NOT NULL DEFAULT 0,FormSyncDate TEXT NOT NULL DEFAULT 0,LastResponderForAssignedTo TEXT NOT NULL DEFAULT '',LastResponderForOriginator TEXT NOT NULL DEFAULT '',PageNumber TEXT NOT NULL DEFAULT 0,ObservationDefectType TEXT,StatusName TEXT,AppBuilderId TEXT,TaskTypeName TEXT,AssignedToRoleName TEXT,PRIMARY KEY(ProjectId,FormId))";
      when(() => mockDb!.executeQuery(formTableQuery))
          .thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(formTableName))
          .thenReturn(["ProjectId", "FormId"]);
      String formSelectQuery = "SELECT ProjectId FROM FormListTbl WHERE ProjectId='2130192' AND FormId='11628410'";
      when(() => mockDb!.selectFromTable(formTableName, formSelectQuery))
          .thenReturn(ResultSet([], null, []));
      String frmBulkInsertQuery = "INSERT INTO FormListTbl (ProjectId,FormId,AppTypeId,FormTypeId,InstanceGroupId,FormTitle,Code,CommentId,MessageId,ParentMessageId,OrgId,FirstName,LastName,OrgName,Originator,OriginatorDisplayName,NoOfActions,ObservationId,LocationId,PfLocFolderId,Updated,AttachmentImageName,MsgCode,TypeImage,DocType,HasAttachments,HasDocAssocations,HasBimViewAssociations,HasFormAssocations,HasCommentAssocations,FormHasAssocAttach,FormCreationDate,FolderId,MsgTypeId,MsgStatusId,FormNumber,MsgOriginatorId,TemplateType,IsDraft,StatusId,OriginatorId,IsStatusChangeRestricted,AllowReopenForm,CanOrigChangeStatus,MsgTypeCode,Id,StatusChangeUserId,StatusUpdateDate,StatusChangeUserName,StatusChangeUserPic,StatusChangeUserEmail,StatusChangeUserOrg,OriginatorEmail,ControllerUserId,UpdatedDateInMS,FormCreationDateInMS,ResponseRequestByInMS,FlagType,LatestDraftId,FlagTypeImageName,MessageTypeImageName,CanAccessHistory,FormJsonData,Status,AttachedDocs,IsUploadAttachmentInTemp,IsSync,UserRefCode,HasActions,CanRemoveOffline,IsMarkOffline,IsOfflineCreated,SyncStatus,IsForDefect,IsForApps,ObservationDefectTypeId,StartDate,ExpectedFinishDate,IsActive,ObservationCoordinates,AnnotationId,IsCloseOut,AssignedToUserId,AssignedToUserName,AssignedToUserOrgName,MsgNum,RevisionId,RequestJsonForOffline,FormDueDays,FormSyncDate,LastResponderForAssignedTo,LastResponderForOriginator,PageNumber,ObservationDefectType,StatusName,AppBuilderId,TaskTypeName,AssignedToRoleName) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      when(() => mockDb!.executeBulk(formTableName, frmBulkInsertQuery, any()))
          .thenAnswer((_) async=> null);

      //Below changes for FormMessage DAO mock
      String frmMsgTableName = "FormMessageListTbl";
      String frmMsgTableQuery = "CREATE TABLE IF NOT EXISTS FormMessageListTbl(ProjectId TEXT NOT NULL,FormTypeId TEXT NOT NULL,FormId TEXT NOT NULL,MsgId TEXT NOT NULL,Originator TEXT,OriginatorDisplayName TEXT,MsgCode TEXT,MsgCreatedDate TEXT,ParentMsgId TEXT,MsgOriginatorId TEXT,MsgHasAssocAttach INTEGER NOT NULL DEFAULT 0,JsonData TEXT,UserRefCode TEXT,UpdatedDateInMS TEXT,FormCreationDateInMS TEXT,MsgCreatedDateInMS TEXT,MsgTypeId TEXT,MsgTypeCode TEXT,MsgStatusId TEXT,SentNames TEXT,SentActions TEXT,DraftSentActions TEXT,FixFieldData TEXT,FolderId TEXT,LatestDraftId TEXT,IsDraft INTEGER NOT NULL DEFAULT 0,AssocRevIds TEXT,ResponseRequestBy TEXT,DelFormIds TEXT,AssocFormIds TEXT,AssocCommIds TEXT,FormUserSet TEXT,FormPermissionsMap TEXT,CanOrigChangeStatus INTEGER NOT NULL DEFAULT 0,CanControllerChangeStatus INTEGER NOT NULL DEFAULT 0,IsStatusChangeRestricted INTEGER NOT NULL DEFAULT 0,HasOverallStatus INTEGER NOT NULL DEFAULT 0,IsCloseOut INTEGER NOT NULL DEFAULT 0,AllowReopenForm INTEGER NOT NULL DEFAULT 0,OfflineRequestData TEXT NOT NULL DEFAULT \"\",IsOfflineCreated INTEGER NOT NULL DEFAULT 0,LocationId INTEGER,ObservationId INTEGER,MsgNum INTEGER,MsgContent TEXT,ActionComplete INTEGER NOT NULL DEFAULT 0,ActionCleared INTEGER NOT NULL DEFAULT 0,HasAttach INTEGER NOT NULL DEFAULT 0,TotalActions INTEGER,InstanceGroupId INTEGER,AttachFiles TEXT,HasViewAccess INTEGER NOT NULL DEFAULT 0,MsgOriginImage TEXT,IsForInfoIncomplete INTEGER NOT NULL DEFAULT 0,MsgCreatedDateOffline TEXT,LastModifiedTime TEXT,LastModifiedTimeInMS TEXT,CanViewDraftMsg INTEGER NOT NULL DEFAULT 0,CanViewOwnorgPrivateForms INTEGER NOT NULL DEFAULT 0,IsAutoSavedDraft INTEGER NOT NULL DEFAULT 0,MsgStatusName TEXT,ProjectAPDFolderId TEXT,ProjectStatusId TEXT,HasFormAccess INTEGER NOT NULL DEFAULT 0,CanAccessHistory INTEGER NOT NULL DEFAULT 0,HasDocAssocations INTEGER NOT NULL DEFAULT 0,HasBimViewAssociations INTEGER NOT NULL DEFAULT 0,HasBimListAssociations INTEGER NOT NULL DEFAULT 0,HasFormAssocations INTEGER NOT NULL DEFAULT 0,HasCommentAssocations INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId,FormId,MsgId))";
      when(() => mockDb!.executeQuery(frmMsgTableQuery))
          .thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(frmMsgTableName))
          .thenReturn(["ProjectId", "FormId", "MsgId"]);
      String frmMsgSelectQuery1 = "SELECT ProjectId FROM FormMessageListTbl WHERE ProjectId='2130192' AND FormId='11628410' AND MsgId='12338091'";
      when(() => mockDb!.selectFromTable(frmMsgTableName, frmMsgSelectQuery1))
          .thenReturn(ResultSet([], null, []));
      String frmMsgSelectQuery2 = "SELECT ProjectId FROM FormMessageListTbl WHERE ProjectId='2130192' AND FormId='11628410' AND MsgId='12338443'";
      when(() => mockDb!.selectFromTable(frmMsgTableName, frmMsgSelectQuery2))
          .thenReturn(ResultSet([], null, []));
      String frmMsgBulkInsertQuery = "INSERT INTO FormMessageListTbl (ProjectId,FormTypeId,FormId,MsgId,Originator,OriginatorDisplayName,MsgCode,MsgCreatedDate,ParentMsgId,MsgOriginatorId,MsgHasAssocAttach,JsonData,UserRefCode,UpdatedDateInMS,FormCreationDateInMS,MsgCreatedDateInMS,MsgTypeId,MsgTypeCode,MsgStatusId,SentNames,SentActions,DraftSentActions,FixFieldData,FolderId,LatestDraftId,IsDraft,AssocRevIds,ResponseRequestBy,DelFormIds,AssocFormIds,AssocCommIds,FormUserSet,FormPermissionsMap,CanOrigChangeStatus,CanControllerChangeStatus,IsStatusChangeRestricted,HasOverallStatus,IsCloseOut,AllowReopenForm,OfflineRequestData,IsOfflineCreated,LocationId,ObservationId,MsgNum,MsgContent,ActionComplete,ActionCleared,HasAttach,TotalActions,InstanceGroupId,AttachFiles,HasViewAccess,MsgOriginImage,IsForInfoIncomplete,MsgCreatedDateOffline,LastModifiedTime,LastModifiedTimeInMS,CanViewDraftMsg,CanViewOwnorgPrivateForms,IsAutoSavedDraft,MsgStatusName,ProjectAPDFolderId,ProjectStatusId,HasFormAccess,CanAccessHistory,HasDocAssocations,HasBimViewAssociations,HasBimListAssociations,HasFormAssocations,HasCommentAssocations) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      when(() => mockDb!.executeBulk(frmMsgTableName, frmMsgBulkInsertQuery, any()))
          .thenAnswer((_) async=> null);

      //Below changes for FormMessageAction DAO mock
      String frmMsgActTableName = "FormMsgActionListTbl";
      String frmMsgActTableQuery = "CREATE TABLE IF NOT EXISTS FormMsgActionListTbl(ProjectId TEXT NOT NULL,FormId TEXT NOT NULL,MsgId TEXT NOT NULL,ActionId TEXT NOT NULL,ActionName TEXT,ActionStatus TEXT,PriorityId TEXT,ActionDate TEXT,ActionDueDate TEXT,DistributorUserId TEXT,RecipientUserId TEXT,Remarks TEXT,DistListId TEXT,TransNum TEXT,ActionTime TEXT,ActionCompleteDate TEXT,ActionNotes TEXT,EntityType TEXT,ModelId TEXT,AssignedBy TEXT,RecipientName TEXT,RecipientOrgId TEXT,Id TEXT,ViewDate TEXT,IsActive INTEGER NOT NULL DEFAULT 0,ResourceId TEXT,ResourceParentId TEXT,ResourceCode TEXT,CommentMsgId TEXT,IsActionComplete INTEGER NOT NULL DEFAULT 0,IsActionClear INTEGER NOT NULL DEFAULT 0,ActionStatusName TEXT,ActionDueDateMilliSecond INTEGER NOT NULL DEFAULT 0,ActionDateMilliSecond INTEGER NOT NULL DEFAULT 0,ActionCompleteDateMilliSecond INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId,FormId,MsgId,ActionId))";
      when(() => mockDb!.executeQuery(frmMsgActTableQuery))
          .thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(frmMsgActTableName))
          .thenReturn(["ProjectId", "FormId", "MsgId", "ActionId"]);
      String frmMsgActSelectQuery = "SELECT ProjectId FROM FormMsgActionListTbl WHERE ProjectId='2130192' AND FormId='11628410' AND MsgId='12338091' AND ActionId='3'";
      when(() => mockDb!.selectFromTable(frmMsgActTableName, frmMsgActSelectQuery))
          .thenReturn(ResultSet([], null, []));
      String frmMsgActBulkInsertQuery = "INSERT INTO FormMsgActionListTbl (ProjectId,FormId,MsgId,ActionId,ActionName,ActionStatus,PriorityId,ActionDate,ActionDueDate,DistributorUserId,RecipientUserId,Remarks,DistListId,TransNum,ActionTime,ActionCompleteDate,ActionNotes,EntityType,ModelId,AssignedBy,RecipientName,RecipientOrgId,Id,ViewDate,IsActive,ResourceId,ResourceParentId,ResourceCode,CommentMsgId,IsActionComplete,IsActionClear,ActionStatusName,ActionDueDateMilliSecond,ActionCompleteDateMilliSecond,ActionDateMilliSecond) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      when(() => mockDb!.executeBulk(frmMsgActTableName, frmMsgActBulkInsertQuery, any()))
          .thenAnswer((_) async=> null);

      //Below changes for FormMessageAttach DAO mock
      String frmMsgAttachTableName = "FormMsgAttachAndAssocListTbl";
      String frmMsgAttachTableQuery = "CREATE TABLE IF NOT EXISTS FormMsgAttachAndAssocListTbl(ProjectId TEXT NOT NULL,FormTypeId TEXT NOT NULL,FormId TEXT NOT NULL,MsgId TEXT NOT NULL,AttachmentType TEXT NOT NULL,AttachAssocDetailJson TEXT NOT NULL,OfflineUploadFilePath TEXT,AttachDocId TEXT,AttachRevId TEXT,AttachFileName TEXT,AssocProjectId TEXT,AssocDocFolderId TEXT,AssocDocRevisionId TEXT,AssocFormCommId TEXT,AssocCommentMsgId TEXT,AssocCommentId TEXT,AssocCommentRevisionId TEXT,AssocViewModelId TEXT,AssocViewId TEXT,AssocListModelId TEXT,AssocListId TEXT,AttachSize TEXT)";
      when(() => mockDb!.executeQuery(frmMsgAttachTableQuery))
          .thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(frmMsgAttachTableName))
          .thenReturn([""]);
      String frmMsgAttachSelectQuery = "SELECT  FROM FormMsgAttachAndAssocListTbl WHERE ='null'";
      when(() => mockDb!.selectFromTable(frmMsgAttachTableName, frmMsgAttachSelectQuery))
          .thenReturn(ResultSet([], null, []));
      String frmMsgAttachBulkInsertQuery = "INSERT INTO FormMsgAttachAndAssocListTbl (ProjectId,FormTypeId,FormId,MsgId,AttachmentType,AttachAssocDetailJson,OfflineUploadFilePath,AttachDocId,AttachRevId,AttachFileName,AssocProjectId,AssocDocFolderId,AssocDocRevisionId,AssocFormCommId,AssocCommentMsgId,AssocCommentId,AssocCommentRevisionId,AssocViewModelId,AssocViewId,AssocListModelId,AssocListId,AttachSize) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      when(() => mockDb!.executeBulk(frmMsgAttachTableName, frmMsgAttachBulkInsertQuery, any()))
          .thenAnswer((_) async=> null);

      when(() => mockFileUtility!.deleteFileAtPath(reqFilePath, recursive: false))
          .thenAnswer((_) => Future.value(null));

      await PushToServerFormSyncTask(syncTask, (eSyncTaskType, eSyncStatus, data) async {},).syncFormDataToServer(paramData, null);
      verify(() => mockFileUtility!.readFromFile(reqFilePath)).called(1);
      verify(() => mockDb!.selectFromTable(attachTableName, attachQuery)).called(1);
      verify(() => mockUseCase!.saveFormToServer(any())).called(1);
      verify(() => mockProjectUseCase!.getFormMessageBatchList(any())).called(1);
      verify(() => mockDb!.selectFromTable(attachTableName, selectOldAttachQuery)).called(1);
      verify(() => mockFileUtility!.isFileExist(attachPath1)).called(1);
      verify(() => mockFileUtility!.isFileExist(attachOldPath1)).called(1);
      verify(() => mockFileUtility!.renameFile(attachOldPath1, attachPath1)).called(1);
      verify(() => mockDb!.executeQuery(removeFormQuery)).called(1);
      verify(() => mockDb!.executeQuery(removeFormMsgQuery)).called(1);
      verify(() => mockDb!.executeQuery(removeFormMsgActQuery)).called(1);
      verify(() => mockDb!.executeQuery(removeFormMsgAttachQuery)).called(1);
      //Below changes for Form DAO mock
      verify(() => mockDb!.executeQuery(formTableQuery)).called(1);
      verify(() => mockDb!.getPrimaryKeys(formTableName)).called(1);
      verify(() => mockDb!.selectFromTable(formTableName, formSelectQuery)).called(1);
      verify(() => mockDb!.executeBulk(formTableName, frmBulkInsertQuery, any())).called(1);
      //Below changes for FormMessage DAO mock
      verify(() => mockDb!.executeQuery(frmMsgTableQuery)).called(1);
      verify(() => mockDb!.getPrimaryKeys(frmMsgTableName)).called(1);
      verify(() => mockDb!.selectFromTable(frmMsgTableName, frmMsgSelectQuery1)).called(1);
      verify(() => mockDb!.selectFromTable(frmMsgTableName, frmMsgSelectQuery2)).called(1);
      verify(() => mockDb!.executeBulk(frmMsgTableName, frmMsgBulkInsertQuery, any())).called(1);
      //Below changes for FormMessageAction DAO mock
      verify(() => mockDb!.executeQuery(frmMsgActTableQuery)).called(1);
      verify(() => mockDb!.getPrimaryKeys(frmMsgActTableName)).called(1);
      verify(() => mockDb!.selectFromTable(frmMsgActTableName, frmMsgActSelectQuery)).called(1);
      verify(() => mockDb!.executeBulk(frmMsgActTableName, frmMsgActBulkInsertQuery, any())).called(1);
      //Below changes for FormMessageAttachment DAO mock
      verify(() => mockDb!.executeQuery(frmMsgAttachTableQuery)).called(1);
      verify(() => mockDb!.getPrimaryKeys(frmMsgAttachTableName)).called(1);
      verify(() => mockDb!.selectFromTable(frmMsgAttachTableName, frmMsgAttachSelectQuery)).called(2);
      verify(() => mockDb!.executeBulk(frmMsgAttachTableName, frmMsgAttachBulkInsertQuery, any())).called(1);

      verify(() => mockFileUtility!.deleteFileAtPath(reqFilePath, recursive: false)).called(1);
    });
  });
}