import 'dart:convert';

import 'package:field/data/dao/form_dao.dart';
import 'package:field/data/dao/form_message_action_dao.dart';
import 'package:field/data/dao/form_message_attachAndAssoc_dao.dart';
import 'package:field/data/dao/form_message_dao.dart';
import 'package:field/data/dao/form_status_history_dao.dart';
import 'package:field/data/dao/formtype_dao.dart';
import 'package:field/data/dao/location_dao.dart';
import 'package:field/data/dao/manage_type_dao.dart';
import 'package:field/data/dao/offline_activity_dao.dart';
import 'package:field/data/dao/project_dao.dart';
import 'package:field/data/model/form_message_attach_assoc_vo.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data_source/forms/create_form_local_data_source.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/database/db_service.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';
import 'package:field/utils/file_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/common.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';

class MockDatabaseManager extends Mock implements DatabaseManager {}

class MockFileUtility extends Mock implements FileUtility {}

class DBServiceMock extends Mock implements DBService {}

void main() {
  MockDatabaseManager mockDatabaseManager = MockDatabaseManager();
  MockFileUtility mockFileUtility = MockFileUtility();
  TestWidgetsFlutterBinding.ensureInitialized();
  String formId = "11607652";
  String projectId = "2130192\$\$NMiycJ";
  String formTypeId = "11103151";
  CreateFormLocalDataSource createFormLocalDataSource = CreateFormLocalDataSource();
  createFormLocalDataSource.databaseManager = mockDatabaseManager;
  DBServiceMock? mockDb;

  setUpAll(() async {
    MockMethodChannel().setNotificationMethodChannel();
    mockDb = DBServiceMock();
    await di.init(test: true);
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AppConfigTestData().setupAppConfigTestData();
    MockMethodChannel().setAsitePluginsMethodChannel();
    di.getIt.unregister<DBService>();
    di.getIt.unregister<FileUtility>();
    di.getIt.registerLazySingleton<FileUtility>(() => mockFileUtility);
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json"), "cloud_type_data": "1", "1_u1_project_": fixture("project.json")});
  });
  tearDown(() {
    reset(mockFileUtility);
    reset(mockDb);
  });

  tearDownAll(() {
    mockDb = null;
  });

  group("Testing for Attachemnt are not carried", () {
    var datajson = fixture('create_form_local_data_source.json');
    final jsonObj = jsonDecode(datajson);
    Map<String, dynamic> mapValue = jsonObj['valueMap'];

    test("mapping value for source and destination", () {
      expect(jsonObj['DYNAMIC_TOTALMAPPING'], greaterThanOrEqualTo(0));
      expect(mapValue.length, equals(jsonObj['DYNAMIC_TOTALMAPPING']));
    });

    test("testing that updating value correctly", () {
      Map<String, dynamic> decoded = jsonObj;
      for (var entries in decoded.entries) {
        var value = entries.value;
        if (mapValue.containsKey(value.toString())) {
          expect(mapValue[value], isNotNull);
        }
      }
    });
  });

  group("Save Form Offline)", () {
    configMockResponse() {
      when(() => mockFileUtility.writeDataToFile(any(), any())).thenAnswer((_) async {});
      when(() => mockFileUtility.copySyncFile(any(), any())).thenAnswer((_) async {});
      String formTypeQuery = "SELECT * FROM FormGroupAndFormTypeListTbl\nWHERE ProjectId=2130192 AND FormTypeId=11103151";
      String manageTypeQuery = "SELECT ManageTypeId FROM ManageTypeListTbl WHERE ProjectId=2130192 AND ManageTypeName='Computer'";
      String locationQuery = "SELECT * FROM LocationDetailTbl\nWHERE ProjectId=2130192 AND LocationId=183682";
      when(() => mockDatabaseManager.executeSelectFromTable(FormTypeDao.tableName, formTypeQuery)).thenReturn([
        {
          "ProjectId": 2130192,
          "FormTypeId": 11103151,
          "FormTypeGroupId": 423,
          "FormTypeGroupName": "Site Tasks",
          "FormTypeGroupCode": "SITE",
          "FormTypeName": "Site Tasks",
          "AppBuilderId": "ASI-SITE",
          "InstanceGroupId": 10940318,
          "TemplateTypeId": 2,
          "FormTypeDetailJson":
              "{\"createFormsLimit\":0,\"canAccessPrivilegedForms\":true,\"formTypeID\":\"11103151\",\"allow_attachments\":true,\"formTypesDetail\":{\"formTypeVO\":{\"formTypeID\":\"11103151\",\"formTypeName\":\"Site Tasks\",\"code\":\"SITE\",\"use_controller\":false,\"response_allowed\":true,\"show_responses\":true,\"allow_reopening_form\":true,\"default_action\":\"-1\",\"is_default\":false,\"allow_forwarding\":false,\"allow_distribution_after_creation\":false,\"allow_distribution_originator\":false,\"allow_distribution_recipients\":false,\"allow_forward_originator\":false,\"allow_forward_recipients\":false,\"responders_collaborate\":true,\"continue_discussion\":true,\"hide_orgs_and_users\":false,\"has_hyperlink\":false,\"allow_attachments\":true,\"allow_doc_associates\":false,\"allow_form_associations\":false,\"allow_attributes\":false,\"associations_extend_doc_issue\":false,\"public_message\":false,\"browsable_attachment_folder\":false,\"has_overall_status\":true,\"is_instance\":true,\"form_type_group_id\":423,\"instance_group_id\":\"10940318\",\"ctrl_change_status\":false,\"parent_formtype_id\":\"10449466\",\"orig_change_status\":false,\"orig_can_close\":false,\"upload_logo\":false,\"user_ref\":false,\"allow_comment_associations\":false,\"is_public\":false,\"is_active\":true,\"signatureBox\":\"000\",\"xsnFile\":\"2615928.zip\",\"xmlData\":\"<my:myFields xmlns:my=\\\"http://schemas.microsoft.com/office/infopath/2003/myXSD/2015-08-11T07:43:54\\\"><my:FORM_CUSTOM_FIELDS><my:ORI_MSG_Custom_Fields><my:DistributionDays>0</my:DistributionDays><my:Organization/><my:DefectTyoe/><my:ExpectedFinishDate/><my:DefectDescription/><my:AssignedToUsersGroup><my:AssignedToUsers><my:AssignedToUser/></my:AssignedToUsers></my:AssignedToUsersGroup><my:Defect_Description/><my:LocationName/><my:StartDate/><my:ActualFinishDate/><my:ExpectedFinishDays/><my:LastResponder_For_AssignedTo/><my:TaskType/><my:ORI_FORMTITLE/><my:attachements my:ASITE_JSON_ARRAY=\\\"true\\\"><my:attachedDocs/></my:attachements><my:OriginatorId/><my:Assigned/><my:Todays_Date/><my:CurrStage/><my:Recent_Defects/><my:FormCreationDate/><my:StartDateDisplay/><my:LastResponder_For_Originator/><my:PF_Location_Detail/><my:Username/><my:ORI_USERREF/><my:Location/></my:ORI_MSG_Custom_Fields><my:RES_MSG_Custom_Fields><my:Comments/><my:SHResponse>Yes</my:SHResponse><my:ShowHideFlag>Yes</my:ShowHideFlag></my:RES_MSG_Custom_Fields><my:CREATE_FWD_RES><my:Can_Reply/></my:CREATE_FWD_RES><my:DS_AUTONUMBER><my:DS_SEQ_LENGTH/><my:DS_FORMAUTONO_CREATE/><my:DS_GET_APP_ACTION_DETAILS/><my:DS_FORMAUTONO_ADD/></my:DS_AUTONUMBER><my:DS_DATASOURCE><my:DS_ASI_SITE_GET_RECENT_DEFECTS/><my:DS_ASI_SITE_getDefectTypesForProjects_pf/><my:DS_Response_PARAM>#Comments#DS_ALL_FORMSTATUS</my:DS_Response_PARAM><my:DS_ASI_SITE_getAllLocationByProject_PF/><my:DS_CALL_METHOD>1</my:DS_CALL_METHOD><my:DS_CHECK_FORM_PERMISSION_USER/><my:DS_Get_All_Responses/><my:DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY/><my:DS_Holiday_Calender_Param/><my:DS_ASI_Configurable_Attributes/></my:DS_DATASOURCE></my:FORM_CUSTOM_FIELDS><my:Asite_System_Data_Read_Only><my:_2_Printing_Data><my:DS_PRINTEDON/><my:DS_PRINTEDBY/></my:_2_Printing_Data><my:_4_Form_Type_Data><my:DS_FORMGROUPCODE/><my:DS_FORMAUTONO/><my:DS_FORMNAME/></my:_4_Form_Type_Data><my:_3_Project_Data><my:DS_PROJECTNAME/><my:DS_CLIENT/></my:_3_Project_Data><my:_5_Form_Data><my:DS_DATEOFISSUE/><my:DS_ISDRAFT_RES_MSG/><my:Status_Data><my:DS_APPROVEDON/><my:DS_CLOSEDUEDATE/><my:DS_ALL_ACTIVE_FORM_STATUS/><my:DS_ALL_FORMSTATUS/><my:DS_APPROVEDBY/><my:DS_CLOSE_DUE_DATE/><my:DS_FORMSTATUS/></my:Status_Data><my:DS_DISTRIBUTION/><my:DS_ISDRAFT/><my:DS_FORMCONTENT/><my:DS_FORMCONTENT3/><my:DS_ORIGINATOR/><my:DS_FORMCONTENT2/><my:DS_FORMCONTENT1/><my:DS_CONTROLLERNAME/><my:DS_MAXORGFORMNO/><my:DS_ISDRAFT_RES/><my:DS_MAXFORMNO/><my:DS_FORMAUTONO_PREFIX/><my:DS_ATTRIBUTES/><my:DS_ISDRAFT_FWD_MSG/><my:DS_FORMID/></my:_5_Form_Data><my:_1_User_Data><my:DS_WORKINGUSER/><my:DS_WORKINGUSERROLE/><my:DS_WORKINGUSER_ID/><my:DS_WORKINGUSER_ALL_ROLES/></my:_1_User_Data><my:_6_Form_MSG_Data><my:DS_MSGCREATOR/><my:DS_MSGDATE/><my:DS_MSGID/><my:DS_MSGRELEASEDATE/><my:DS_MSGSTATUS/><my:ORI_MSG_Data><my:DS_DOC_ASSOCIATIONS_ORI/><my:DS_FORM_ASSOCIATIONS_ORI/><my:DS_ATTACHMENTS_ORI/></my:ORI_MSG_Data></my:_6_Form_MSG_Data></my:Asite_System_Data_Read_Only><my:Asite_System_Data_Read_Write><my:ORI_MSG_Fields><my:SP_RES_PRINT_VIEW>DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses</my:SP_RES_PRINT_VIEW><my:SP_RES_VIEW>DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS</my:SP_RES_VIEW><my:SP_ORI_PRINT_VIEW>DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER</my:SP_ORI_PRINT_VIEW><my:SP_FORM_PRINT_VIEW>DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER</my:SP_FORM_PRINT_VIEW><my:SP_ORI_VIEW>DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes</my:SP_ORI_VIEW></my:ORI_MSG_Fields><my:DS_PROJORGANISATIONS/><my:DS_PROJUSERS_ALL_ROLES/><my:DS_PROJDISTGROUPS/><my:DS_AUTODISTRIBUTE/><my:DS_PROJUSERS/><my:DS_PROJORGANISATIONS_ID/><my:DS_INCOMPLETE_ACTIONS/><my:Auto_Distribute_Group><my:Auto_Distribute_Users my:ASITE_JSON_ARRAY=\\\"true\\\"><my:DS_ACTIONDUEDATE/><my:DS_FORMACTIONS/><my:DS_PROJDISTUSERS/></my:Auto_Distribute_Users></my:Auto_Distribute_Group></my:Asite_System_Data_Read_Write></my:myFields>\",\"templateType\":2,\"responsePattern\":0,\"fixedFieldIds\":\"1663,1722,2929,3278,3732,4822,5198,5199,5200,4,5,7,8,18,19,20,22,23,25,43,308,563,628,639,671,\",\"displayFileName\":\"sitetask.zip\",\"viewIds\":\"3,1,2,5,4,\",\"mandatoryDistribution\":2,\"responseFromAll\":false,\"subTemplateType\":0,\"integrateExchange\":false,\"allowEditingORI\":false,\"allowImportExcelInEditORI\":false,\"isOverwriteExcelInEditORI\":true,\"enableECatalague\":false,\"formGroupName\":\"Site Tasks\",\"projectId\":\"2130192\",\"clonedFormTypeId\":0,\"appBuilderFormIDCode\":\"ASI-SITE\",\"loginUserId\":2017529,\"xslFileName\":\"\",\"allowImportForm\":false,\"allowWorkspaceLink\":false,\"linkedWorkspaceProjectId\":\"-1\",\"createFormsLimit\":0,\"spellCheckPrefs\":\"00\",\"isMobile\":false,\"createFormsLimitLevel\":0,\"restrictChangeFormStatus\":0,\"enableDraftResponses\":1,\"isDistributionFromGroupOnly\":false,\"isAutoCreateOnStatusChange\":false,\"docAssociationType\":1,\"viewFieldIdsData\":\"<root><views><viewid>2</viewid><view_name>ORI_PRINT_VIEW</view_name><fieldids>20,7,308,1722,22,628,671,563,8,4,5,1663,639,19,18,43,25,23,5199,3732,4822</fieldids></views><views><viewid>4</viewid><view_name>RES_PRINT_VIEW</view_name><fieldids>20,7,308,1722,22,628,671,563,8,4,5,1663,639,19,18,25,23,3278,3732,4822</fieldids></views><views><viewid>5</viewid><view_name>FORM_PRINT_VIEW</view_name><fieldids>20,7,22,628,563,8,4,5,19,18,25,23,3732</fieldids></views><views><viewid>3</viewid><view_name>RES_VIEW</view_name><fieldids>20,7,308,1722,22,628,671,563,8,4,5,1663,639,19,18,25,23,3278</fieldids></views><views><viewid>1</viewid><view_name>ORI_VIEW</view_name><fieldids>20,7,308,1722,22,628,671,563,8,4,5,1663,639,19,18,43,25,23,5198,5199,5200,2929</fieldids></views></root>\",\"createdMsgCount\":0,\"draft_count\":0,\"draftMsgId\":0,\"view_always_form_association\":false,\"view_always_doc_association\":false,\"auto_publish_to_folder\":false,\"default_folder_path\":\"\",\"default_folder_id\":\"\",\"allowExternalAccess\":0,\"embedFormContentInEmail\":0,\"canReplyViaEmail\":0,\"externalUsersOnly\":0,\"appTypeId\":2,\"dataCenterId\":0,\"allowViewAssociation\":0,\"infojetServerVersion\":0,\"isFormAvailableOffline\":0,\"allowDistributionByAll\":false,\"allowDistributionByRoles\":false,\"allowDistributionRoleIds\":\"\",\"canEditWithAppbuilder\":false,\"hasAppbuilderTemplateDraft\":false,\"isTemplateChanged\":false,\"viewsList\":[{\"viewId\":1,\"viewName\":\"ORI_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"20,7,308,1722,22,628,671,563,8,4,5,1663,639,19,18,43,25,23,5198,5199,5200,2929\",\"generateURI\":true},{\"viewId\":2,\"viewName\":\"ORI_PRINT_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"20,7,308,1722,22,628,671,563,8,4,5,1663,639,19,18,43,25,23,5199,3732,4822\",\"generateURI\":true},{\"viewId\":3,\"viewName\":\"RES_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"20,7,308,1722,22,628,671,563,8,4,5,1663,639,19,18,25,23,3278\",\"generateURI\":true},{\"viewId\":4,\"viewName\":\"RES_PRINT_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"20,7,308,1722,22,628,671,563,8,4,5,1663,639,19,18,25,23,3278,3732,4822\",\"generateURI\":true},{\"viewId\":5,\"viewName\":\"FORM_PRINT_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"20,7,22,628,563,8,4,5,19,18,25,23,3732\",\"generateURI\":true}],\"isRecent\":false,\"allowLocationAssociation\":true,\"isLocationAssocMandatory\":false,\"bfpc\":\"0\",\"had\":\"0\",\"isFromMarketplace\":false,\"isMarkDefault\":false,\"isNewlyCreated\":false,\"isAsycnProcess\":false},\"actionList\":[{\"is_default\":false,\"is_associated\":false,\"actionName\":\"Assign Status\",\"actionID\":\"2\",\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":false,\"actionName\":\"Attach Docs\",\"actionID\":\"5\",\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":false,\"actionName\":\"Distribute\",\"actionID\":\"6\",\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":false,\"actionName\":\"For Acknowledgement\",\"actionID\":\"37\",\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":false,\"actionName\":\"For Action\",\"actionID\":\"36\",\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Information\",\"actionID\":\"7\",\"num_days\":-1,\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Respond\",\"actionID\":\"3\",\"num_days\":7,\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":false,\"actionName\":\"Review Draft\",\"actionID\":\"34\",\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true}],\"formTypeGroupVO\":{\"formTypeGroupID\":423,\"formTypeGroupName\":\"Site Tasks\",\"generateURI\":true},\"statusList\":[{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed\",\"statusID\":3,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved\",\"statusID\":4,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved with Comments\",\"statusID\":5,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Rejected\",\"statusID\":6,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Open\",\"statusID\":1001,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Resolved\",\"statusID\":1002,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":true,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Verified\",\"statusID\":1003,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true}],\"isFormInherited\":false,\"generateURI\":true},\"createdFormsCount\":0,\"draftFormsCount\":0,\"templatetype\":2,\"appId\":2,\"formTypeName\":\"Site Tasks\",\"totalForms\":0,\"formtypeGroupid\":423,\"isFavourite\":true,\"appBuilderID\":\"ASI-SITE\",\"canViewDraftMsg\":false,\"formTypeGroupName\":\"Site Tasks\",\"formGroupCode\":\"SITE\",\"canCreateForm\":true,\"numActions\":1,\"crossWorkspaceID\":-1,\"instanceGroupId\":10940318,\"allow_associate_location\":true,\"numOverdueActions\":0,\"is_location_assoc_mandatory\":false,\"workspaceid\":2130192}",
          "AllowLocationAssociation": 1,
          "CanCreateForms": 1,
          "AppTypeId": "2"
        }
      ]);
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, any())).thenReturn([]);
      when(() => mockDatabaseManager.executeSelectFromTable(ManageTypeDao.tableName, manageTypeQuery)).thenReturn([
        {"ManageTypeId": 310493}
      ]);
      when(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, locationQuery)).thenReturn([
        {"ProjectId": "2130192", "FolderId": "115096357", "LocationId": 183682, "LocationTitle": "Basement", "ParentFolderId": 115096349, "ParentLocationId": 183679, "PermissionValue": 0, "LocationPath": "Site Quality Demo\\01 Vijay_Test\\Plan-1\\Basement", "SiteId": 0, "DocumentId": "13351081", "RevisionId": "26773045", "AnnotationId": "1fc95526-3610-5163-e2c8-c915a692c3d4", "LocationCoordinate": "{\"x1\":593.98,\"y1\":669.61,\"x2\":803.92,\"y2\":522.8199999999999}", "PageNumber": 1, "IsPublic": 0, "IsFavorite": 0, "IsSite": 0, "IsCalibrated": 1, "IsFileUploaded": 0, "IsActive": 1, "HasSubFolder": 0, "CanRemoveOffline": 0, "IsMarkOffline": 1, "SyncStatus": 1, "LastSyncTimeStamp": ""}
      ]);
      var distributionJsonData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/DistributionData.json');
      when(() => mockFileUtility.readFromFile(captureAny(that: contains("DistributionData.json")))).thenReturn(distributionJsonData);
      when(() => mockFileUtility.copySyncFile(any(), any())).thenReturn(null);
      when(() => mockFileUtility.getFileNameFromPath(captureAny(that: contains("temp_img_annotation.png")))).thenReturn("temp_img_annotation.png");
      when(() => mockFileUtility.getFileNameFromPath(captureAny(that: contains("test.pdf")))).thenReturn("test.pdf");
      when(() => mockFileUtility.getFileSize(captureAny(that: contains("test.pdf")))).thenAnswer((_) => Future(() => 1024));
      when(() => mockDb!.executeQuery(FormDao().createTableQuery)).thenReturn({});
      when(() => mockDb!.executeQuery(FormMessageDao().createTableQuery)).thenReturn({});
      when(() => mockDb!.executeQuery(FormMessageAttachAndAssocDao().createTableQuery)).thenReturn({});
      when(() => mockDb!.getPrimaryKeys(FormDao.tableName)).thenReturn([]);
      when(() => mockDb!.getPrimaryKeys(FormMessageDao.tableName)).thenReturn([]);
      when(() => mockDb!.getPrimaryKeys(FormMessageAttachAndAssocDao.tableName)).thenReturn([]);
      when(() => mockDb!.executeBulk(FormDao.tableName, any(), any())).thenAnswer((_) => Future.value(null));;
      when(() => mockDb!.executeBulk(FormMessageDao.tableName, any(), any())).thenAnswer((_) => Future.value(null));;
      when(() => mockDb!.executeBulk(FormMessageAttachAndAssocDao.tableName, any(), any())).thenAnswer((_) => Future.value(null));;
    }
    setUp(() {
      configMockResponse();
    });
    removeFormMsgAttachAndAssocDataMock(){
      String strForeignKeysQuery = "PRAGMA foreign_keys";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strForeignKeysQuery)).thenReturn([{"foreign_keys": 1}]);
      String strQuery = "PRAGMA foreign_keys=0";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strQuery)).thenReturn([{"foreign_keys": 1}]);

      strQuery = "CREATE TABLE FormMsgAttachAndAssocListTbl_TEMP AS SELECT * FROM FormMsgAttachAndAssocListTbl WHERE ProjectId=2130192 AND FormId=1691478052496 AND MsgId=1691478133747 AND ((AttachmentType NOT IN (0,1,2,3)) OR (AttachmentType=0 AND ((AssocProjectId=2130192 AND AssocDocFolderId=0 AND AssocDocRevisionId=123))) OR (AttachmentType=3 AND AttachDocId IN (1691478133808128)))";
      when(() => mockDatabaseManager.executeTableRequest(strQuery)).thenReturn([]);

      when(() => mockFileUtility.isFileExist(any())).thenReturn(true);
      when(() => mockFileUtility.deleteFile(any())).thenAnswer((_) => Future.value(null));
      strQuery = "SELECT tmpTbl.ProjectId,tmpTbl.AttachRevId,tmpTbl.AssocDocRevisionId,tmpTbl.AttachmentType,tmpTbl.AttachAssocDetailJson FROM FormMsgAttachAndAssocListTbl tmpTbl\n";
      strQuery = "${strQuery}LEFT JOIN FormMsgAttachAndAssocListTbl_TEMP attachTbl\n";
      strQuery = "${strQuery}ON tmpTbl.ProjectId=attachTbl.ProjectId AND tmpTbl.FormId=attachTbl.FormId AND tmpTbl.MsgId=attachTbl.MsgId\n";
      strQuery = "${strQuery}AND ((tmpTbl.AttachRevId=attachTbl.AttachRevId AND tmpTbl.AttachRevId<>'')\n";
      strQuery = "${strQuery}OR (tmpTbl.AssocDocRevisionId=attachTbl.AssocDocRevisionId AND tmpTbl.AssocDocRevisionId<>''))\n";
      strQuery = "${strQuery}WHERE attachTbl.ProjectId ISNULL AND tmpTbl.ProjectId=2130192\n";
      strQuery = "${strQuery}AND tmpTbl.FormId=1691478052496 AND tmpTbl.MsgId=1691478133747";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strQuery)).thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":1691478133747,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      strQuery = "DELETE FROM FormMsgAttachAndAssocListTbl";
      strQuery = "$strQuery WHERE ProjectId=2130192";
      strQuery = "$strQuery AND FormId=1691478052496 AND MsgId=1691478133747";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strQuery)).thenReturn([]);

      strQuery = "INSERT INTO FormMsgAttachAndAssocListTbl SELECT * FROM FormMsgAttachAndAssocListTbl_TEMP";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strQuery)).thenReturn([]);

      strQuery = "DROP TABLE FormMsgAttachAndAssocListTbl_TEMP";
      when(() => mockDatabaseManager.executeSelectFromTable("FormMsgAttachAndAssocListTbl_TEMP", strQuery)).thenReturn([]);

      strQuery = "PRAGMA foreign_keys=1";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strQuery)).thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":1691478133747,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);
    }
    test("Test Create Form with Attachment From the Plan and Save it", () async {
      Map<String, dynamic> saveFormParam = {
        "projectId": "2130192",
        "locationId": 183682,
        "coordinates": "{\"x1\":646.694607498723,\"y1\":633.3538860379657,\"x2\":656.694607498723,\"y2\":643.3538860379657}",
        "annotationId": "4a31a24d-2c87-4d8a-aa26-a7c71a600580-1691147798919",
        "isFromMapView": true,
        "isCalibrated": true,
        "page_number": 1,
        "appTypeId": 2,
        "formSelectRadiobutton": "1_2130192_11103151",
        "formTypeId": "11103151",
        "instanceGroupId": "10940318",
        "templateType": 2,
        "appBuilderId": "ASI-SITE",
        "revisionId": "26773045",
        "offlineFormId": 1691147798938,
        "isUploadAttachmentInTemp": true,
        "formCreationDate": "2023-08-04 16:46:38",
        "url": "file:///data/user/0/com.asite.field/app_flutter/database/HTML5Form/createFormHTML.html",
        "offlineFormDataJson":
            "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"ORI_FORMTITLE\":\"Test offline\",\"ORI_USERREF\":\"\",\"DefectTyoe\":\"Computer\",\"TaskType\":\"Defect\",\"DefectDescription\":\"\",\"Location\":\"183682|Basement|01 Vijay_Test>Plan-1>Basement\",\"LocationName\":\"01 Vijay_Test>Plan-1>Basement\",\"StartDate\":\"2023-08-04\",\"StartDateDisplay\":\"04-Aug-2023\",\"ExpectedFinishDate\":\"\",\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"ActualFinishDate\":\"\",\"Recent_Defects\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"707447#Vijay Mavadiya (5336), Asite Solutions\"}},\"CurrStage\":\"1\",\"PF_Location_Detail\":\"183682|26773045|{\\\"x1\\\":593.98,\\\"y1\\\":669.61,\\\"x2\\\":803.92,\\\"y2\\\":522.8199999999999}|1\",\"Defect_Description\":\"edittred\",\"Username\":\"\",\"Organization\":\"\",\"ExpectedFinishDays\":\"5\",\"DistributionDays\":\"0\",\"LastResponder_For_AssignedTo\":\"707447\",\"LastResponder_For_Originator\":\"2017529\",\"FormCreationDate\":\"\",\"Assigned\":\"Vijay Mavadiya (5336), Asite Solutions\",\"attachements\":[{\"attachedDocs\":\"\"}],\"DS_Logo\":\"images/asite.gif\",\"isCalibrated\":true},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"ShowHideFlag\":\"Yes\",\"SHResponse\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_FORMAUTONO_CREATE\":\"\",\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_ADD\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_Get_All_Responses\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"Asite_System_Data_Read_Only\":{\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_2_Printing_Data\":{\"DS_PRINTEDBY\":\"\",\"DS_PRINTEDON\":\"\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMNAME\":\"Site Tasks\",\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\"},\"_5_Form_Data\":{\"DS_FORMID\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_DATEOFISSUE\":\"\",\"DS_DISTRIBUTION\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_ISDRAFT_RES\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ISDRAFT_RES_MSG\":\"NO\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"Status_Data\":{\"DS_FORMSTATUS\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_APPROVEDBY\":\"\",\"DS_APPROVEDON\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\"}},\"_6_Form_MSG_Data\":{\"DS_MSGID\":\"\",\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_PROJDISTUSERS\":\"707447\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_ACTIONDUEDATE\":\"5\"}]}},\"attachments\":[],\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"formAction\":\"create\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11103151\",\"assocLocationSelection\":\"{\\\"locationId\\\":183682}\",\"requestType\":\"0\",\"annotationId\":\"4a31a24d-2c87-4d8a-aa26-a7c71a600580-1691147798919\",\"coordinates\":\"{\\\"x1\\\":646.694607498723,\\\"y1\\\":633.3538860379657,\\\"x2\\\":656.694607498723,\\\"y2\\\":643.3538860379657}\",\"attachedDocs_0\":\"temp_img_annotation.png_2017529\",\"upFile0\":\"./test/fixtures/files/temp_img_annotation.png\",\"attachedDocs_1\":\"test.pdf_2017529\",\"upFile1\":\"./test/fixtures/files/test.pdf\",\"appTypeId\":\"2\"}}}",
        "isDraft": false
      };
      Map saveResponse = await createFormLocalDataSource.saveFormOffline(saveFormParam);
      expect(saveResponse.isNotEmpty, true);
      expect(saveResponse.containsKey('formId'), true);
      expect(saveResponse.containsKey('msgId'), true);
      expect(saveResponse.containsKey('locationId'), true);
    });
    test("Test Create Form with Attachment From the Dashboard and Save it", () async {
      Map<String, dynamic> saveFormParam = {
        "projectId": "2130192",
        "appTypeId": 2,
        "formSelectRadiobutton": "1_2130192_11103151",
        "formTypeId": "11103151",
        "instanceGroupId": "10940318",
        "templateType": 2,
        "appBuilderId": "ASI-SITE",
        "revisionId": "26773045",
        "offlineFormId": 1691147798938,
        "isUploadAttachmentInTemp": true,
        "formCreationDate": "2023-08-04 16:46:38",
        "url": "file:///data/user/0/com.asite.field/app_flutter/database/HTML5Form/createFormHTML.html",
        "offlineFormDataJson":
            "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"ORI_FORMTITLE\":\"Test offline\",\"ORI_USERREF\":\"\",\"DefectTyoe\":\"Computer\",\"TaskType\":\"Defect\",\"DefectDescription\":\"\",\"Location\":\"183682|Basement|01 Vijay_Test>Plan-1>Basement\",\"LocationName\":\"01 Vijay_Test>Plan-1>Basement\",\"StartDate\":\"2023-08-04\",\"StartDateDisplay\":\"04-Aug-2023\",\"ExpectedFinishDate\":\"\",\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"ActualFinishDate\":\"\",\"Recent_Defects\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"707447#Vijay Mavadiya (5336), Asite Solutions\"}},\"CurrStage\":\"1\",\"PF_Location_Detail\":\"183682|26773045|{\\\"x1\\\":593.98,\\\"y1\\\":669.61,\\\"x2\\\":803.92,\\\"y2\\\":522.8199999999999}|1\",\"Defect_Description\":\"edittred\",\"Username\":\"\",\"Organization\":\"\",\"ExpectedFinishDays\":\"5\",\"DistributionDays\":\"0\",\"LastResponder_For_AssignedTo\":\"707447\",\"LastResponder_For_Originator\":\"2017529\",\"FormCreationDate\":\"\",\"Assigned\":\"Vijay Mavadiya (5336), Asite Solutions\",\"attachements\":[{\"attachedDocs\":\"\"}],\"DS_Logo\":\"images/asite.gif\",\"isCalibrated\":true},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"ShowHideFlag\":\"Yes\",\"SHResponse\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_FORMAUTONO_CREATE\":\"\",\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_ADD\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_Get_All_Responses\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"Asite_System_Data_Read_Only\":{\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_2_Printing_Data\":{\"DS_PRINTEDBY\":\"\",\"DS_PRINTEDON\":\"\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMNAME\":\"Site Tasks\",\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\"},\"_5_Form_Data\":{\"DS_FORMID\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_DATEOFISSUE\":\"\",\"DS_DISTRIBUTION\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_ISDRAFT_RES\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ISDRAFT_RES_MSG\":\"NO\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"Status_Data\":{\"DS_FORMSTATUS\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_APPROVEDBY\":\"\",\"DS_APPROVEDON\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\"}},\"_6_Form_MSG_Data\":{\"DS_MSGID\":\"\",\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_PROJDISTUSERS\":\"707447\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_ACTIONDUEDATE\":\"5\"}]}},\"attachments\":[],\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"formAction\":\"create\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11103151\",\"assocLocationSelection\":\"{\\\"locationId\\\":183682}\",\"requestType\":\"0\",\"annotationId\":\"4a31a24d-2c87-4d8a-aa26-a7c71a600580-1691147798919\",\"coordinates\":\"{\\\"x1\\\":646.694607498723,\\\"y1\\\":633.3538860379657,\\\"x2\\\":656.694607498723,\\\"y2\\\":643.3538860379657}\",\"attachedDocs_0\":\"temp_img_annotation.png_2017529\",\"upFile0\":\"./test/fixtures/files/temp_img_annotation.png\",\"attachedDocs_1\":\"test.pdf_2017529\",\"upFile1\":\"./test/fixtures/files/test.pdf\",\"appTypeId\":\"2\"}}}",
        "isDraft": false
      };
      String locationQuery = "SELECT * FROM LocationDetailTbl WHERE ProjectId=2130192 AND LocationId=183682";
      when(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, locationQuery)).thenReturn([
        {"ProjectId": "2130192", "FolderId": "115096357", "LocationId": 183682, "LocationTitle": "Basement", "ParentFolderId": 115096349, "ParentLocationId": 183679, "PermissionValue": 0, "LocationPath": "Site Quality Demo\\01 Vijay_Test\\Plan-1\\Basement", "SiteId": 0, "DocumentId": "13351081", "RevisionId": "26773045", "AnnotationId": "1fc95526-3610-5163-e2c8-c915a692c3d4", "LocationCoordinate": "{\"x1\":593.98,\"y1\":669.61,\"x2\":803.92,\"y2\":522.8199999999999}", "PageNumber": 1, "IsPublic": 0, "IsFavorite": 0, "IsSite": 0, "IsCalibrated": 1, "IsFileUploaded": 0, "IsActive": 1, "HasSubFolder": 0, "CanRemoveOffline": 0, "IsMarkOffline": 1, "SyncStatus": 1, "LastSyncTimeStamp": ""}
      ]);
      Map saveResponse = await createFormLocalDataSource.saveFormOffline(saveFormParam);
      expect(saveResponse.isNotEmpty, true);
      expect(saveResponse.containsKey('formId'), true);
      expect(saveResponse.containsKey('msgId'), true);
      expect(saveResponse.containsKey('locationId'), true);
    });
    test("Test Create Form with Attachment From the Dashboard and Save it without coordinate data", () async {
      Map<String, dynamic> saveFormParam = {
        "projectId": "2130192",
        "appTypeId": 2,
        "formSelectRadiobutton": "1_2130192_11103151",
        "formTypeId": "11103151",
        "instanceGroupId": "10940318",
        "templateType": 2,
        "appBuilderId": "ASI-SITE",
        "revisionId": "26773045",
        "offlineFormId": 1691147798938,
        "isUploadAttachmentInTemp": true,
        "formCreationDate": "2023-08-04 16:46:38",
        "url": "file:///data/user/0/com.asite.field/app_flutter/database/HTML5Form/createFormHTML.html",
        "offlineFormDataJson":
        "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"ORI_FORMTITLE\":\"Test offline\",\"ORI_USERREF\":\"\",\"DefectTyoe\":\"Computer\",\"TaskType\":\"Defect\",\"DefectDescription\":\"\",\"Location\":\"183682|Basement|01 Vijay_Test>Plan-1>Basement\",\"LocationName\":\"01 Vijay_Test>Plan-1>Basement\",\"StartDate\":\"2023-08-04\",\"StartDateDisplay\":\"04-Aug-2023\",\"ExpectedFinishDate\":\"\",\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"ActualFinishDate\":\"\",\"Recent_Defects\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"707447#Vijay Mavadiya (5336), Asite Solutions\"}},\"CurrStage\":\"1\",\"PF_Location_Detail\":\"183682|26773045|{\\\"x1\\\":593.98,\\\"y1\\\":669.61,\\\"x2\\\":803.92,\\\"y2\\\":522.8199999999999}|1\",\"Defect_Description\":\"edittred\",\"Username\":\"\",\"Organization\":\"\",\"ExpectedFinishDays\":\"5\",\"DistributionDays\":\"0\",\"LastResponder_For_AssignedTo\":\"707447\",\"LastResponder_For_Originator\":\"2017529\",\"FormCreationDate\":\"\",\"Assigned\":\"Vijay Mavadiya (5336), Asite Solutions\",\"attachements\":[{\"attachedDocs\":\"\"}],\"DS_Logo\":\"images/asite.gif\",\"isCalibrated\":true},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"ShowHideFlag\":\"Yes\",\"SHResponse\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_FORMAUTONO_CREATE\":\"\",\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_ADD\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_Get_All_Responses\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"Asite_System_Data_Read_Only\":{\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_2_Printing_Data\":{\"DS_PRINTEDBY\":\"\",\"DS_PRINTEDON\":\"\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMNAME\":\"Site Tasks\",\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\"},\"_5_Form_Data\":{\"DS_FORMID\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_DATEOFISSUE\":\"\",\"DS_DISTRIBUTION\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_ISDRAFT_RES\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ISDRAFT_RES_MSG\":\"NO\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"Status_Data\":{\"DS_FORMSTATUS\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_APPROVEDBY\":\"\",\"DS_APPROVEDON\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\"}},\"_6_Form_MSG_Data\":{\"DS_MSGID\":\"\",\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_PROJDISTUSERS\":\"707447\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_ACTIONDUEDATE\":\"5\"}]}},\"attachments\":[],\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"formAction\":\"create\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11103151\",\"assocLocationSelection\":\"{\\\"locationId\\\":183682}\",\"requestType\":\"0\",\"annotationId\":\"4a31a24d-2c87-4d8a-aa26-a7c71a600580-1691147798919\",\"coordinates\":\"{\\\"x1\\\":,\\\"y1\\\":633.3538860379657,\\\"x2\\\":656.694607498723,\\\"y2\\\":643.3538860379657}\",\"attachedDocs_0\":\"temp_img_annotation.png_2017529\",\"upFile0\":\"./test/fixtures/files/temp_img_annotation.png\",\"attachedDocs_1\":\"test.pdf_2017529\",\"upFile1\":\"./test/fixtures/files/test.pdf\",\"appTypeId\":\"2\"}}}",
        "isDraft": false
      };
      String locationQuery = "SELECT * FROM LocationDetailTbl WHERE ProjectId=2130192 AND LocationId=183682";
      when(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, locationQuery)).thenReturn([
        {"ProjectId": "2130192", "FolderId": "115096357", "LocationId": 183682, "LocationTitle": "Basement", "ParentFolderId": 115096349, "ParentLocationId": 183679, "PermissionValue": 0, "LocationPath": "Site Quality Demo\\01 Vijay_Test\\Plan-1\\Basement", "SiteId": 0, "DocumentId": "13351081", "RevisionId": "26773045", "AnnotationId": "1fc95526-3610-5163-e2c8-c915a692c3d4", "LocationCoordinate": "{\"x1\":,\"y1\":669.0,\"x2\":803.92,\"y2\":522.8199999999999}", "PageNumber": 1, "IsPublic": 0, "IsFavorite": 0, "IsSite": 0, "IsCalibrated": 1, "IsFileUploaded": 0, "IsActive": 1, "HasSubFolder": 0, "CanRemoveOffline": 0, "IsMarkOffline": 1, "SyncStatus": 1, "LastSyncTimeStamp": ""}
      ]);
      Map saveResponse = await createFormLocalDataSource.saveFormOffline(saveFormParam);
      expect(saveResponse.isNotEmpty, true);
      expect(saveResponse.containsKey('formId'), true);
      expect(saveResponse.containsKey('msgId'), true);
      expect(saveResponse.containsKey('locationId'), true);

      String insertDataString = """2130192, 1691147798938, 2, 11103151, 10940318, Test offline, SITE, 1691147798938, 1691658862345, 0, 0, Mayur, Raval (5372), Asite Solutions Ltd, ,  Mayur Raval m., Asite Solutions Ltd , 0, 1691147798938, 183682, , 2023-08-10 14:44:22.022, icons/assocform.png, ORI001, icons/form.png, , 1, 0, 0, 0, 0, 1, 2023-08-10 14:44:22.022, , 1, , , 2017529, 2, 0, 1001, 2017529, 0, 0, 0, ORI, , , , , , , , , , 1691658862345, 1691658862345, , , , , , 0, , Open, , 1, 0, , 0, 0, 1, 1, 1, 0, 0, 310493, 2023-08-04, 2023-08-09, 1, , , 0, 707447, Vijay Mavadiya (5336),  Asite Solutions, 0, 26773045, , 5, , 707447, 2017529, , Computer, Open, ASI-SITE, , """;
      List<dynamic> insertData = insertDataString.split(",");

      String insertQuery = "INSERT INTO FormListTbl (ProjectId,FormId,AppTypeId,FormTypeId,InstanceGroupId,FormTitle,Code,CommentId,MessageId,ParentMessageId,OrgId,FirstName,LastName,OrgName,Originator,OriginatorDisplayName,NoOfActions,ObservationId,LocationId,PfLocFolderId,Updated,AttachmentImageName,MsgCode,TypeImage,DocType,HasAttachments,HasDocAssocations,HasBimViewAssociations,HasFormAssocations,HasCommentAssocations,FormHasAssocAttach,FormCreationDate,FolderId,MsgTypeId,MsgStatusId,FormNumber,MsgOriginatorId,TemplateType,IsDraft,StatusId,OriginatorId,IsStatusChangeRestricted,AllowReopenForm,CanOrigChangeStatus,MsgTypeCode,Id,StatusChangeUserId,StatusUpdateDate,StatusChangeUserName,StatusChangeUserPic,StatusChangeUserEmail,StatusChangeUserOrg,OriginatorEmail,ControllerUserId,UpdatedDateInMS,FormCreationDateInMS,ResponseRequestByInMS,FlagType,LatestDraftId,FlagTypeImageName,MessageTypeImageName,CanAccessHistory,FormJsonData,Status,AttachedDocs,IsUploadAttachmentInTemp,IsSync,UserRefCode,HasActions,CanRemoveOffline,IsMarkOffline,IsOfflineCreated,SyncStatus,IsForDefect,IsForApps,ObservationDefectTypeId,StartDate,ExpectedFinishDate,IsActive,ObservationCoordinates,AnnotationId,IsCloseOut,AssignedToUserId,AssignedToUserName,AssignedToUserOrgName,MsgNum,RevisionId,RequestJsonForOffline,FormDueDays,FormSyncDate,LastResponderForAssignedTo,LastResponderForOriginator,PageNumber,ObservationDefectType,StatusName,AppBuilderId,TaskTypeName,AssignedToRoleName) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      verifyNever(() => mockDb?.executeBulk(FormDao.tableName, insertQuery, [insertData]));
    });
    test("Test Create Draft Form with Attachment From the Plan and Save it", () async {
      Map<String, dynamic> saveFormParam = {
        "projectId": "2130192",
        "locationId": 183682,
        "coordinates": "{\"x1\":646.694607498723,\"y1\":633.3538860379657,\"x2\":656.694607498723,\"y2\":643.3538860379657}",
        "annotationId": "4a31a24d-2c87-4d8a-aa26-a7c71a600580-1691147798919",
        "isFromMapView": true,
        "isCalibrated": true,
        "page_number": 1,
        "appTypeId": 2,
        "formSelectRadiobutton": "1_2130192_11103151",
        "formTypeId": "11103151",
        "instanceGroupId": "10940318",
        "templateType": 2,
        "appBuilderId": "ASI-SITE",
        "revisionId": "26773045",
        "offlineFormId": 1691147798938,
        "isUploadAttachmentInTemp": true,
        "formCreationDate": "2023-08-04 16:46:38",
        "url": "file:///data/user/0/com.asite.field/app_flutter/database/HTML5Form/createFormHTML.html",
        "offlineFormDataJson":
            "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"ORI_FORMTITLE\":\"Test offline\",\"ORI_USERREF\":\"\",\"DefectTyoe\":\"Computer\",\"TaskType\":\"Defect\",\"DefectDescription\":\"\",\"Location\":\"183682|Basement|01 Vijay_Test>Plan-1>Basement\",\"LocationName\":\"01 Vijay_Test>Plan-1>Basement\",\"StartDate\":\"2023-08-04\",\"StartDateDisplay\":\"04-Aug-2023\",\"ExpectedFinishDate\":\"\",\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"ActualFinishDate\":\"\",\"Recent_Defects\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"707447#Vijay Mavadiya (5336), Asite Solutions\"}},\"CurrStage\":\"1\",\"PF_Location_Detail\":\"183682|26773045|{\\\"x1\\\":593.98,\\\"y1\\\":669.61,\\\"x2\\\":803.92,\\\"y2\\\":522.8199999999999}|1\",\"Defect_Description\":\"edittred\",\"Username\":\"\",\"Organization\":\"\",\"ExpectedFinishDays\":\"5\",\"DistributionDays\":\"0\",\"LastResponder_For_AssignedTo\":\"707447\",\"LastResponder_For_Originator\":\"2017529\",\"FormCreationDate\":\"\",\"Assigned\":\"Vijay Mavadiya (5336), Asite Solutions\",\"attachements\":[{\"attachedDocs\":\"\"}],\"DS_Logo\":\"images/asite.gif\",\"isCalibrated\":true},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"ShowHideFlag\":\"Yes\",\"SHResponse\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_FORMAUTONO_CREATE\":\"\",\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_ADD\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_Get_All_Responses\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"Asite_System_Data_Read_Only\":{\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_2_Printing_Data\":{\"DS_PRINTEDBY\":\"\",\"DS_PRINTEDON\":\"\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMNAME\":\"Site Tasks\",\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\"},\"_5_Form_Data\":{\"DS_FORMID\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_DATEOFISSUE\":\"\",\"DS_DISTRIBUTION\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_ISDRAFT_RES\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ISDRAFT_RES_MSG\":\"NO\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"Status_Data\":{\"DS_FORMSTATUS\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_APPROVEDBY\":\"\",\"DS_APPROVEDON\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\"}},\"_6_Form_MSG_Data\":{\"DS_MSGID\":\"\",\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_PROJDISTUSERS\":\"707447\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_ACTIONDUEDATE\":\"5\"}]}},\"attachments\":[],\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"formAction\":\"create\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11103151\",\"assocLocationSelection\":\"{\\\"locationId\\\":183682}\",\"requestType\":\"0\",\"annotationId\":\"4a31a24d-2c87-4d8a-aa26-a7c71a600580-1691147798919\",\"coordinates\":\"{\\\"x1\\\":646.694607498723,\\\"y1\\\":633.3538860379657,\\\"x2\\\":656.694607498723,\\\"y2\\\":643.3538860379657}\",\"attachedDocs_0\":\"temp_img_annotation.png_2017529\",\"upFile0\":\"./test/fixtures/files/temp_img_annotation.png\",\"attachedDocs_1\":\"test.pdf_2017529\",\"upFile1\":\"./test/fixtures/files/test.pdf\",\"appTypeId\":\"2\"}}}",
        "isDraft": true
      };
      Map saveResponse = await createFormLocalDataSource.saveFormOffline(saveFormParam);
      expect(saveResponse.isNotEmpty, true);
      expect(saveResponse.containsKey('formId'), true);
      expect(saveResponse.containsKey('msgId'), true);
      expect(saveResponse.containsKey('locationId'), true);
    });
    test("Test Respond/Reply action with Attachment and Save it", () async {
      Map<String, dynamic> saveFormParam = {
        "projectId": "2130192",
        "locationId": "185571",
        "formId": "11637822",
        "formTypeId": "11103151",
        "templateType": 2,
        "appBuilderId": "ASI-SITE",
        "appTypeId": 2,
        "formSelectRadiobutton": "1_2130192_11103151",
        "isUploadAttachmentInTemp": true,
        "offlineFormDataJson":
            "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"DistributionDays\":\"12\",\"Organization\":\"\",\"DefectTyoe\":\"Architectural\",\"ExpectedFinishDate\":\"2023-08-24\",\"DefectDescription\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"2017529#Mayur Raval m., Asite Solutions Ltd\"}},\"Defect_Description\":\"Test Cases\",\"LocationName\":\"01 Vijay_Test>Plan-4>Family Room\",\"StartDate\":\"2023-08-08\",\"ActualFinishDate\":\"\",\"ExpectedFinishDays\":\"12\",\"DS_Logo\":\"images/asite.gif\",\"LastResponder_For_AssignedTo\":\"2017529\",\"TaskType\":\"Damages\",\"isCalibrated\":true,\"ORI_FORMTITLE\":\"Respond Test Case\",\"attachements\":[{\"attachedDocs\":\"\"}],\"OriginatorId\":\"1161363 | Chandresh Patel, Asite Solutions # Chandresh Patel, Asite Solutions\",\"Assigned\":\"Mayur Raval m., Asite Solutions Ltd\",\"Todays_Date\":\"2023-08-08T05:51:48\",\"CurrStage\":\"1\",\"Recent_Defects\":\"\",\"FormCreationDate\":\"\",\"StartDateDisplay\":\"08-Aug-2023\",\"LastResponder_For_Originator\":\"1161363\",\"PF_Location_Detail\":\"185571|27187964|{\\\"x1\\\":465.3,\\\"y1\\\":1021.97,\\\"x2\\\":594.08,\\\"y2\\\":822.3399999999999}|1\",\"Username\":\"\",\"ORI_USERREF\":\"\",\"Location\":\"185571|Family Room|01 Vijay_Test>Plan-4>Family Room\"},\"RES_MSG_Custom_Fields\":{\"Comments\":\"Responded\",\"SHResponse\":\"Yes\",\"ShowHideFlag\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_CREATE\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\",\"DS_FORMAUTONO_ADD\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_Get_All_Responses\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"attachments\":[],\"Asite_System_Data_Read_Only\":{\"_2_Printing_Data\":{\"DS_PRINTEDON\":\"\",\"DS_PRINTEDBY\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMGROUPCODE\":\"\",\"DS_FORMAUTONO\":\"\",\"DS_FORMNAME\":\"Site Tasks\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_5_Form_Data\":{\"DS_DATEOFISSUE\":\"\",\"DS_ISDRAFT_RES_MSG\":\"\",\"Status_Data\":{\"DS_APPROVEDON\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\",\"DS_ALL_FORMSTATUS\":\"1002 # Resolved\",\"DS_APPROVEDBY\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_FORMSTATUS\":\"Open\"},\"DS_DISTRIBUTION\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT_RES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_CLOSE_DUE_DATE\":\"2023-08-24\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_FORMID\":\"\"},\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_6_Form_MSG_Data\":{\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGID\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"411\",\"DS_PROJUSERS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_ACTIONDUEDATE\":\"7\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_PROJDISTUSERS\":\"1161363\"}]}},\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"2\",\"msg_type_code\":\"RES\",\"parent_msg_id\":\"12349105\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"assocLocationSelection\":\"\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11103151\",\"requestType\":\"4\",\"formAction\":\"create\",\"attachedDocs_0\":\"test.pdf_2017529\",\"upFile0\":\"./test/fixtures/files/test.pdf\",\"appTypeId\":\"2\"}}}",
        "isDraft": false
      };
      String formQuery =
          "WITH OfflineSyncData AS (SELECT  CASE frmMsgTbl.OfflineRequestData WHEN 2 THEN 5 ELSE 1 END AS Type, frmTypeTbl.AppTypeId, frmMsgTbl.ProjectId, frmMsgTbl.FormTypeId, frmTypeTbl.InstanceGroupId, frmTypeTbl.TemplateTypeId, frmMsgTbl.FormId, frmMsgTbl.MsgId, frmMsgTbl.MsgTypeId, frmMsgTbl.OfflineRequestData, frmMsgTbl.UpdatedDateInMS, frmMsgTbl.IsDraft, frmMsgTbl.DelFormIds FROM FormMessageListTbl frmMsgTbl INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId INNER JOIN FormGroupAndFormTypeListTbl frmTypeTbl ON frmTypeTbl.ProjectId=frmMsgTbl.ProjectId AND frmTypeTbl.FormTypeId=frmMsgTbl.FormTypeId WHERE frmMsgTbl.OfflineRequestData<>'' AND ((frmTypeTbl.TemplateTypeId=1 AND frmMsgTbl.IsDraft<>1) OR frmTypeTbl.TemplateTypeId<>1)) SELECT IFNULL(fldSycDataView.OfflineRequestData,'') AS NewOfflineRequestData,frmTbl.* FROM FormListTbl frmTbl LEFT JOIN OfflineSyncData  fldSycDataView ON frmTbl.ProjectId=fldSycDataView.ProjectId AND frmTbl.FormId=fldSycDataView.FormId AND fldSycDataView.Type IN (1,2,5) WHERE frmTbl.ProjectId=2130192  AND frmTbl.FormId=11637822";
      String formMsgQuery = "SELECT * FROM FormMessageListTbl WHERE ProjectId=2130192 AND FormId=11637822 AND MsgTypeId=2";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, formQuery)).thenReturn([
        {
          "NewOfflineRequestData": "",
          "ProjectId": 2130192,
          "FormId": "11637822",
          "AppTypeId": 2,
          "FormTypeId": 11103151,
          "InstanceGroupId": 10940318,
          "FormTitle": "Respond Test Case",
          "Code": "SITE409",
          "CommentId": 11637822,
          "MessageId": 12349105,
          "ParentMessageId": 0,
          "OrgId": 3,
          "FirstName": "Chandresh",
          "LastName": "Patel",
          "OrgName": "Asite Solutions",
          "Originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1161363_thumbnail.jpg?v=1673263342000#Chandresh",
          "OriginatorDisplayName": "Chandresh Patel, Asite Solutions",
          "NoOfActions": 0,
          "ObservationId": 112857,
          "LocationId": 185571,
          "PfLocFolderId": 116251424,
          "Updated": "07-Aug-2023#23:52 CST",
          "AttachmentImageName": "icons/assocform.png",
          "MsgCode": "ORI001",
          "TypeImage": "icons/form.png",
          "DocType": "Apps",
          "HasAttachments": 0,
          "HasDocAssocations": 0,
          "HasBimViewAssociations": 0,
          "HasFormAssocations": 0,
          "HasCommentAssocations": 0,
          "FormHasAssocAttach": 1,
          "FormCreationDate": "07-Aug-2023#23:52 CST",
          "FolderId": 0,
          "MsgTypeId": 1,
          "MsgStatusId": 20,
          "FormNumber": 409,
          "MsgOriginatorId": 1161363,
          "TemplateType": 2,
          "IsDraft": 0,
          "StatusId": 1001,
          "OriginatorId": 1161363,
          "IsStatusChangeRestricted": 0,
          "AllowReopenForm": 0,
          "CanOrigChangeStatus": 0,
          "MsgTypeCode": "ORI",
          "Id": "",
          "StatusChangeUserId": 0,
          "StatusUpdateDate": "07-Aug-2023#23:52 CST",
          "StatusChangeUserName": "Chandresh Patel",
          "StatusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1161363_thumbnail.jpg?v=1673263342000#Chandresh",
          "StatusChangeUserEmail": "chandreshpatel@asite.com",
          "StatusChangeUserOrg": "Asite Solutions",
          "OriginatorEmail": "chandreshpatel@asite.com",
          "ControllerUserId": 0,
          "UpdatedDateInMS": 1691470379000,
          "FormCreationDateInMS": 1691470379000,
          "ResponseRequestByInMS": 1692943199000,
          "FlagType": 0,
          "LatestDraftId": 0,
          "FlagTypeImageName": "flag_type/flag_0.png",
          "MessageTypeImageName": "icons/form.png",
          "CanAccessHistory": 1,
          "FormJsonData": "",
          "Status": "Open",
          "AttachedDocs": "",
          "IsUploadAttachmentInTemp": 0,
          "IsSync": 0,
          "UserRefCode": "",
          "HasActions": 1,
          "CanRemoveOffline": 0,
          "IsMarkOffline": 0,
          "IsOfflineCreated": 0,
          "SyncStatus": 1,
          "IsForDefect": 0,
          "IsForApps": 0,
          "ObservationDefectTypeId": "310497",
          "StartDate": "2023-08-08",
          "ExpectedFinishDate": "2023-08-24",
          "IsActive": 1,
          "ObservationCoordinates": "{\"x1\":536.33,\"y1\":934.37,\"x2\":584.33,\"y2\":886.37}",
          "AnnotationId": "b27a8610-0d01-9d6b-1ee8-0cf1fcad84cf",
          "IsCloseOut": 0,
          "AssignedToUserId": 2017529,
          "AssignedToUserName": "Mayur Raval m.",
          "AssignedToUserOrgName": "Asite Solutions Ltd",
          "MsgNum": "",
          "RevisionId": "",
          "RequestJsonForOffline": "",
          "FormDueDays": "12",
          "FormSyncDate": "2023-08-08 05:52:59.0",
          "LastResponderForAssignedTo": "2017529",
          "LastResponderForOriginator": "1161363",
          "PageNumber": "1",
          "ObservationDefectType": "",
          "StatusName": "Open",
          "AppBuilderId": "ASI-SITE",
          "TaskTypeName": "",
          "AssignedToRoleName": ""
        }
      ]);
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMsgQuery)).thenReturn([]);
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, captureAny(that: startsWith("SELECT count(*) AS MsgCount FROM FormMessageListTbl")))).thenReturn([]);
      Map saveResponse = await createFormLocalDataSource.saveFormOffline(saveFormParam);
      expect(saveResponse.isNotEmpty, true);
      expect(saveResponse.containsKey('formId'), true);
      expect(saveResponse.containsKey('msgId'), true);
      expect(saveResponse.containsKey('locationId'), true);
    });
    test("Test Edit Form which is created in offline and Save it", () async {
      Map<String, dynamic> saveFormParam = {
        "projectId": "2130192",
        "locationId": 185572,
        "formId": "1691478052496",
        "formTypeId": "11103151",
        "templateType": 2,
        "appBuilderId": "ASI-SITE",
        "appTypeId": 2,
        "formSelectRadiobutton": "1_2130192_11103151",
        "isUploadAttachmentInTemp": true,
        "offlineFormDataJson":
            "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"ORI_FORMTITLE\":\"Edit Form Test\",\"ORI_USERREF\":\"\",\"DefectTyoe\":\"Architectural\",\"TaskType\":\"Damages\",\"DefectDescription\":\"\",\"Location\":\"185572|Salon|01 Vijay_Test>Plan-4>Salon\",\"LocationName\":\"01 Vijay_Test>Plan-4>Salon\",\"StartDate\":\"2023-08-08\",\"StartDateDisplay\":\"08-Aug-2023\",\"ExpectedFinishDate\":\"2023-08-20\",\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"ActualFinishDate\":\"\",\"Recent_Defects\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"1161363#Chandresh Patel, Asite Solutions\"}},\"CurrStage\":\"2\",\"PF_Location_Detail\":\"185572|27187964|{\\\"x1\\\":460.47,\\\"y1\\\":814.3,\\\"x2\\\":639.16,\\\"y2\\\":669.41}|1\",\"Defect_Description\":\"T\",\"Username\":\"\",\"Organization\":\"\",\"ExpectedFinishDays\":\"12\",\"DistributionDays\":\"0\",\"LastResponder_For_AssignedTo\":\"1161363\",\"LastResponder_For_Originator\":\"2017529\",\"FormCreationDate\":\"\",\"Assigned\":\"Chandresh Patel, Asite Solutions\",\"attachements\":[{\"attachedDocs\":\"\"}],\"DS_Logo\":\"images/asite.gif\",\"isCalibrated\":true},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"ShowHideFlag\":\"Yes\",\"SHResponse\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_FORMAUTONO_CREATE\":\"\",\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_ADD\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_Get_All_Responses\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"Asite_System_Data_Read_Only\":{\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_2_Printing_Data\":{\"DS_PRINTEDBY\":\"\",\"DS_PRINTEDON\":\"\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMNAME\":\"Site Tasks\",\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\"},\"_5_Form_Data\":{\"DS_FORMID\":\"SITE\",\"DS_ORIGINATOR\":\"\",\"DS_DATEOFISSUE\":\"\",\"DS_DISTRIBUTION\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_ISDRAFT_RES\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ISDRAFT_RES_MSG\":\"NO\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"Status_Data\":{\"DS_FORMSTATUS\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_APPROVEDBY\":\"\",\"DS_APPROVEDON\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\"}},\"_6_Form_MSG_Data\":{\"DS_MSGID\":\"\",\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_PROJDISTUSERS\":\"1161363\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_ACTIONDUEDATE\":\"12\"}]}},\"attachments\":[],\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"assocDocSelection\":\"[{\\\"projectId\\\":\\\"2130192\\\",\\\"folderId\\\":\\\"0\\\",\\\"revision_id\\\":\\\"123\\\"}]\",\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"parent_msg_id\":\"0\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"assocLocationSelection\":\"{\\\"locationId\\\":185572}\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11103151\",\"editORI\":\"false\",\"requestType\":\"2\",\"msgId\":\"1691478133747\",\"formAction\":\"create\",\"editDraft\":\"false\",\"attachedDocs0\":\"1691478133808128\",\"appTypeId\":\"2\"},\"attachment_fields\":\"\"}}",
        "isDraft": true
      };
      String formQuery =
          "WITH OfflineSyncData AS (SELECT  CASE frmMsgTbl.OfflineRequestData WHEN 2 THEN 5 ELSE 1 END AS Type, frmTypeTbl.AppTypeId, frmMsgTbl.ProjectId, frmMsgTbl.FormTypeId, frmTypeTbl.InstanceGroupId, frmTypeTbl.TemplateTypeId, frmMsgTbl.FormId, frmMsgTbl.MsgId, frmMsgTbl.MsgTypeId, frmMsgTbl.OfflineRequestData, frmMsgTbl.UpdatedDateInMS, frmMsgTbl.IsDraft, frmMsgTbl.DelFormIds FROM FormMessageListTbl frmMsgTbl INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId INNER JOIN FormGroupAndFormTypeListTbl frmTypeTbl ON frmTypeTbl.ProjectId=frmMsgTbl.ProjectId AND frmTypeTbl.FormTypeId=frmMsgTbl.FormTypeId WHERE frmMsgTbl.OfflineRequestData<>'' AND ((frmTypeTbl.TemplateTypeId=1 AND frmMsgTbl.IsDraft<>1) OR frmTypeTbl.TemplateTypeId<>1)) SELECT IFNULL(fldSycDataView.OfflineRequestData,'') AS NewOfflineRequestData,frmTbl.* FROM FormListTbl frmTbl LEFT JOIN OfflineSyncData  fldSycDataView ON frmTbl.ProjectId=fldSycDataView.ProjectId AND frmTbl.FormId=fldSycDataView.FormId AND fldSycDataView.Type IN (1,2,5) WHERE frmTbl.ProjectId=2130192  AND frmTbl.FormId=1691478052496";
      String formMsgQuery = "SELECT * FROM FormMessageListTbl\nWHERE ProjectId=2130192 AND FormId=1691478052496 AND MsgId=1691478133747";
      String formAttachmentQuery = "SELECT * FROM FormMsgAttachAndAssocListTbl WHERE ProjectId=2130192 AND FormId=1691478052496 AND MsgId<>1691478133747";
      String formMsgTypeQuery = "SELECT * FROM FormMessageListTbl WHERE ProjectId=2130192 AND FormId=1691478052496 AND MsgTypeId=1";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, formQuery)).thenReturn([
        {
          "NewOfflineRequestData": "1",
          "ProjectId": 2130192,
          "FormId": "1691478052496",
          "AppTypeId": 2,
          "FormTypeId": 11103151,
          "InstanceGroupId": 10940318,
          "FormTitle": "Edit Form Test",
          "Code": "SITE",
          "CommentId": 1691478052496,
          "MessageId": 1691478133747,
          "ParentMessageId": 0,
          "OrgId": 0,
          "FirstName": "Mayur",
          "LastName": "Raval m.",
          "OrgName": "Asite Solutions Ltd",
          "Originator": "",
          "OriginatorDisplayName": " Mayur Raval m., Asite Solutions Ltd ",
          "NoOfActions": 0,
          "ObservationId": 1691478052496,
          "LocationId": 185572,
          "PfLocFolderId": "",
          "Updated": "2023-08-08 12:32:13.013",
          "AttachmentImageName": "icons/assocform.png",
          "MsgCode": "ORI001",
          "TypeImage": "icons/form.png",
          "DocType": "",
          "HasAttachments": 1,
          "HasDocAssocations": 0,
          "HasBimViewAssociations": 0,
          "HasFormAssocations": 0,
          "HasCommentAssocations": 0,
          "FormHasAssocAttach": 1,
          "FormCreationDate": "2023-08-08 12:32:13.013",
          "FolderId": "",
          "MsgTypeId": 1,
          "MsgStatusId": "",
          "FormNumber": "",
          "MsgOriginatorId": 2017529,
          "TemplateType": 2,
          "IsDraft": 0,
          "StatusId": 1001,
          "OriginatorId": 2017529,
          "IsStatusChangeRestricted": 0,
          "AllowReopenForm": 0,
          "CanOrigChangeStatus": 0,
          "MsgTypeCode": "ORI",
          "Id": "",
          "StatusChangeUserId": "",
          "StatusUpdateDate": "",
          "StatusChangeUserName": "",
          "StatusChangeUserPic": "",
          "StatusChangeUserEmail": "",
          "StatusChangeUserOrg": "",
          "OriginatorEmail": "",
          "ControllerUserId": "",
          "UpdatedDateInMS": 1691478133747,
          "FormCreationDateInMS": 1691478133747,
          "ResponseRequestByInMS": "",
          "FlagType": "",
          "LatestDraftId": "",
          "FlagTypeImageName": "",
          "MessageTypeImageName": "",
          "CanAccessHistory": 0,
          "FormJsonData": "",
          "Status": "Open",
          "AttachedDocs": "",
          "IsUploadAttachmentInTemp": 1,
          "IsSync": 0,
          "UserRefCode": "",
          "HasActions": 0,
          "CanRemoveOffline": 0,
          "IsMarkOffline": 1,
          "IsOfflineCreated": 1,
          "SyncStatus": 1,
          "IsForDefect": 1,
          "IsForApps": 0,
          "ObservationDefectTypeId": "310497",
          "StartDate": "2023-08-08",
          "ExpectedFinishDate": "2023-08-20",
          "IsActive": 1,
          "ObservationCoordinates": "{\"x1\":527.0890387016723,\"y1\":703.3783692873515,\"x2\":537.0890387016723,\"y2\":713.3783692873515}",
          "AnnotationId": "24aa2d64-1cda-42ff-93a3-0eacd381ea64-1691478052484",
          "IsCloseOut": 0,
          "AssignedToUserId": 1161363,
          "AssignedToUserName": "Chandresh Patel",
          "AssignedToUserOrgName": " Asite Solutions",
          "MsgNum": 0,
          "RevisionId": 27187964,
          "RequestJsonForOffline": "",
          "FormDueDays": "12",
          "FormSyncDate": "",
          "LastResponderForAssignedTo": "1161363",
          "LastResponderForOriginator": "2017529",
          "PageNumber": "1",
          "ObservationDefectType": "Architectural",
          "StatusName": "Open",
          "AppBuilderId": "ASI-SITE",
          "TaskTypeName": "",
          "AssignedToRoleName": ""
        }
      ]);
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMsgQuery)).thenReturn([
        {
          "ProjectId": "2130192",
          "FormTypeId": "11103151",
          "FormId": "1691478052496",
          "MsgId": "1691478133747",
          "Originator": "",
          "OriginatorDisplayName": " Mayur Raval m., Asite Solutions Ltd ",
          "MsgCode": "ORI001",
          "MsgCreatedDate": "2023-08-08 12:32:13.013",
          "ParentMsgId": "0",
          "MsgOriginatorId": "2017529",
          "MsgHasAssocAttach": 1,
          "JsonData":
              "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"ORI_FORMTITLE\":\"Edit Form Test\",\"ORI_USERREF\":\"\",\"DefectTyoe\":\"Architectural\",\"TaskType\":\"Damages\",\"DefectDescription\":\"\",\"Location\":\"185572|Salon|01 Vijay_Test>Plan-4>Salon\",\"LocationName\":\"01 Vijay_Test>Plan-4>Salon\",\"StartDate\":\"2023-08-08\",\"StartDateDisplay\":\"08-Aug-2023\",\"ExpectedFinishDate\":\"2023-08-20\",\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"ActualFinishDate\":\"\",\"Recent_Defects\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"1161363#Chandresh Patel, Asite Solutions\"}},\"CurrStage\":\"1\",\"PF_Location_Detail\":\"185572|27187964|{\\\"x1\\\":460.47,\\\"y1\\\":814.3,\\\"x2\\\":639.16,\\\"y2\\\":669.41}|1\",\"Defect_Description\":\"T\",\"Username\":\"\",\"Organization\":\"\",\"ExpectedFinishDays\":\"12\",\"DistributionDays\":\"0\",\"LastResponder_For_AssignedTo\":\"1161363\",\"LastResponder_For_Originator\":\"2017529\",\"FormCreationDate\":\"\",\"Assigned\":\"Chandresh Patel, Asite Solutions\",\"attachements\":[{\"attachedDocs\":\"\"}],\"DS_Logo\":\"images/asite.gif\",\"isCalibrated\":true},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"ShowHideFlag\":\"Yes\",\"SHResponse\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_FORMAUTONO_CREATE\":\"\",\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_ADD\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_Get_All_Responses\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"Asite_System_Data_Read_Only\":{\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_2_Printing_Data\":{\"DS_PRINTEDBY\":\"\",\"DS_PRINTEDON\":\"\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMNAME\":\"Site Tasks\",\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\"},\"_5_Form_Data\":{\"DS_FORMID\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_DATEOFISSUE\":\"\",\"DS_DISTRIBUTION\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_ISDRAFT_RES\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ISDRAFT_RES_MSG\":\"NO\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"Status_Data\":{\"DS_FORMSTATUS\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_APPROVEDBY\":\"\",\"DS_APPROVEDON\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\"}},\"_6_Form_MSG_Data\":{\"DS_MSGID\":\"\",\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_PROJDISTUSERS\":\"1161363\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_ACTIONDUEDATE\":\"12\"}]}},\"attachments\":[],\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"formAction\":\"create\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11103151\",\"assocLocationSelection\":\"{\\\"locationId\\\":185572}\",\"requestType\":\"0\",\"annotationId\":\"24aa2d64-1cda-42ff-93a3-0eacd381ea64-1691478052484\",\"coordinates\":\"{\\\"x1\\\":527.0890387016723,\\\"y1\\\":703.3783692873515,\\\"x2\\\":537.0890387016723,\\\"y2\\\":713.3783692873515}\",\"attachedDocs_0\":\"CAP6805135748225538611.jpg_2017529\",\"upFile0\":\"/data/user/0/com.asite.field/app_flutter/database/1_2017529/2130192/tempAttachments/CAP6805135748225538611.jpg\",\"appTypeId\":\"2\"},\"attachment_fields\":\"\"}}",
          "UserRefCode": "",
          "UpdatedDateInMS": "1691478133747",
          "FormCreationDateInMS": "1691478133747",
          "MsgCreatedDateInMS": "1691478133747",
          "MsgTypeId": "1",
          "MsgTypeCode": "ORI",
          "MsgStatusId": "20",
          "SentNames": "",
          "SentActions": "",
          "DraftSentActions": "",
          "FixFieldData": "",
          "FolderId": "",
          "LatestDraftId": "",
          "IsDraft": 0,
          "AssocRevIds": "",
          "ResponseRequestBy": "08-Aug-2023",
          "DelFormIds": "",
          "AssocFormIds": "",
          "AssocCommIds": "",
          "FormUserSet": "",
          "FormPermissionsMap": "",
          "CanOrigChangeStatus": 0,
          "CanControllerChangeStatus": 0,
          "IsStatusChangeRestricted": 0,
          "HasOverallStatus": 0,
          "IsCloseOut": 0,
          "AllowReopenForm": 0,
          "OfflineRequestData": "1",
          "IsOfflineCreated": 1,
          "LocationId": 185572,
          "ObservationId": 1691478052496,
          "MsgNum": 1,
          "MsgContent": "T",
          "ActionComplete": 0,
          "ActionCleared": 0,
          "HasAttach": 1,
          "TotalActions": 0,
          "InstanceGroupId": 10940318,
          "AttachFiles": "",
          "HasViewAccess": 0,
          "MsgOriginImage": "",
          "IsForInfoIncomplete": 0,
          "MsgCreatedDateOffline": "",
          "LastModifiedTime": "",
          "LastModifiedTimeInMS": "",
          "CanViewDraftMsg": 0,
          "CanViewOwnorgPrivateForms": 0,
          "IsAutoSavedDraft": 0,
          "MsgStatusName": "",
          "ProjectAPDFolderId": "",
          "ProjectStatusId": "",
          "HasFormAccess": 0,
          "CanAccessHistory": 0,
          "HasDocAssocations": 0,
          "HasBimViewAssociations": 0,
          "HasBimListAssociations": 0,
          "HasFormAssocations": 0,
          "HasCommentAssocations": 0
        }
      ]);
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, formAttachmentQuery)).thenReturn([]);
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMsgTypeQuery)).thenReturn([
        {
          "ProjectId": "2130192",
          "FormTypeId": "11103151",
          "FormId": "1691478052496",
          "MsgId": "1691478133747",
          "Originator": "",
          "OriginatorDisplayName": " Mayur Raval m., Asite Solutions Ltd ",
          "MsgCode": "ORI001",
          "MsgCreatedDate": "2023-08-08 12:32:13.013",
          "ParentMsgId": "0",
          "MsgOriginatorId": "2017529",
          "MsgHasAssocAttach": 1,
          "JsonData":
              "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"ORI_FORMTITLE\":\"Edit Form Test\",\"ORI_USERREF\":\"\",\"DefectTyoe\":\"Architectural\",\"TaskType\":\"Damages\",\"DefectDescription\":\"\",\"Location\":\"185572|Salon|01 Vijay_Test>Plan-4>Salon\",\"LocationName\":\"01 Vijay_Test>Plan-4>Salon\",\"StartDate\":\"2023-08-08\",\"StartDateDisplay\":\"08-Aug-2023\",\"ExpectedFinishDate\":\"2023-08-20\",\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"ActualFinishDate\":\"\",\"Recent_Defects\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"1161363#Chandresh Patel, Asite Solutions\"}},\"CurrStage\":\"1\",\"PF_Location_Detail\":\"185572|27187964|{\\\"x1\\\":460.47,\\\"y1\\\":814.3,\\\"x2\\\":639.16,\\\"y2\\\":669.41}|1\",\"Defect_Description\":\"T\",\"Username\":\"\",\"Organization\":\"\",\"ExpectedFinishDays\":\"12\",\"DistributionDays\":\"0\",\"LastResponder_For_AssignedTo\":\"1161363\",\"LastResponder_For_Originator\":\"2017529\",\"FormCreationDate\":\"\",\"Assigned\":\"Chandresh Patel, Asite Solutions\",\"attachements\":[{\"attachedDocs\":\"\"}],\"DS_Logo\":\"images/asite.gif\",\"isCalibrated\":true},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"ShowHideFlag\":\"Yes\",\"SHResponse\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_FORMAUTONO_CREATE\":\"\",\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_ADD\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_Get_All_Responses\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"Asite_System_Data_Read_Only\":{\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_2_Printing_Data\":{\"DS_PRINTEDBY\":\"\",\"DS_PRINTEDON\":\"\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMNAME\":\"Site Tasks\",\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\"},\"_5_Form_Data\":{\"DS_FORMID\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_DATEOFISSUE\":\"\",\"DS_DISTRIBUTION\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_ISDRAFT_RES\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ISDRAFT_RES_MSG\":\"NO\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"Status_Data\":{\"DS_FORMSTATUS\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_APPROVEDBY\":\"\",\"DS_APPROVEDON\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\"}},\"_6_Form_MSG_Data\":{\"DS_MSGID\":\"\",\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_PROJDISTUSERS\":\"1161363\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_ACTIONDUEDATE\":\"12\"}]}},\"attachments\":[],\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"formAction\":\"create\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11103151\",\"assocLocationSelection\":\"{\\\"locationId\\\":185572}\",\"requestType\":\"0\",\"annotationId\":\"24aa2d64-1cda-42ff-93a3-0eacd381ea64-1691478052484\",\"coordinates\":\"{\\\"x1\\\":527.0890387016723,\\\"y1\\\":703.3783692873515,\\\"x2\\\":537.0890387016723,\\\"y2\\\":713.3783692873515}\",\"attachedDocs_0\":\"CAP6805135748225538611.jpg_2017529\",\"upFile0\":\"/data/user/0/com.asite.field/app_flutter/database/1_2017529/2130192/tempAttachments/CAP6805135748225538611.jpg\",\"appTypeId\":\"2\"},\"attachment_fields\":\"\"}}",
          "UserRefCode": "",
          "UpdatedDateInMS": "1691478133747",
          "FormCreationDateInMS": "1691478133747",
          "MsgCreatedDateInMS": "1691478133747",
          "MsgTypeId": "1",
          "MsgTypeCode": "ORI",
          "MsgStatusId": "20",
          "SentNames": "",
          "SentActions": "",
          "DraftSentActions": "",
          "FixFieldData": "",
          "FolderId": "",
          "LatestDraftId": "",
          "IsDraft": 0,
          "AssocRevIds": "",
          "ResponseRequestBy": "08-Aug-2023",
          "DelFormIds": "",
          "AssocFormIds": "",
          "AssocCommIds": "",
          "FormUserSet": "",
          "FormPermissionsMap": "",
          "CanOrigChangeStatus": 0,
          "CanControllerChangeStatus": 0,
          "IsStatusChangeRestricted": 0,
          "HasOverallStatus": 0,
          "IsCloseOut": 0,
          "AllowReopenForm": 0,
          "OfflineRequestData": "1",
          "IsOfflineCreated": 1,
          "LocationId": 185572,
          "ObservationId": 1691478052496,
          "MsgNum": 1,
          "MsgContent": "T",
          "ActionComplete": 0,
          "ActionCleared": 0,
          "HasAttach": 1,
          "TotalActions": 0,
          "InstanceGroupId": 10940318,
          "AttachFiles": "",
          "HasViewAccess": 0,
          "MsgOriginImage": "",
          "IsForInfoIncomplete": 0,
          "MsgCreatedDateOffline": "",
          "LastModifiedTime": "",
          "LastModifiedTimeInMS": "",
          "CanViewDraftMsg": 0,
          "CanViewOwnorgPrivateForms": 0,
          "IsAutoSavedDraft": 0,
          "MsgStatusName": "",
          "ProjectAPDFolderId": "",
          "ProjectStatusId": "",
          "HasFormAccess": 0,
          "CanAccessHistory": 0,
          "HasDocAssocations": 0,
          "HasBimViewAssociations": 0,
          "HasBimListAssociations": 0,
          "HasFormAssocations": 0,
          "HasCommentAssocations": 0
        }
      ]);
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, captureAny(that: startsWith("SELECT count(*) AS MsgCount FROM FormMessageListTbl")))).thenReturn([]);
      removeFormMsgAttachAndAssocDataMock();
      Map saveResponse = await createFormLocalDataSource.saveFormOffline(saveFormParam);
      expect(saveResponse.isNotEmpty, true);
      expect(saveResponse.containsKey('formId'), true);
      expect(saveResponse.containsKey('msgId'), true);
      expect(saveResponse.containsKey('locationId'), true);
    });
    test("Test Create With Distribution Actions and Save it", () async {
      Map<String, dynamic> saveFormParam = {
        "projectId": "2130192",
        "locationId": 183682,
        "coordinates": "{\"x1\":300.1035336864152,\"y1\":582.9163221378506,\"x2\":310.1035336864152,\"y2\":592.9163221378506}",
        "annotationId": "45d8490e-542b-49ee-84ed-15e322eabd77-1691483588520",
        "isFromMapView": true,
        "isCalibrated": true,
        "page_number": 1,
        "appTypeId": 2,
        "formSelectRadiobutton": "1_2130192_11104955",
        "formTypeId": "11104955",
        "instanceGroupId": "11018088",
        "templateType": 2,
        "appBuilderId": "STD-DIS",
        "revisionId": "27187964",
        "offlineFormId": 1691483588552,
        "isUploadAttachmentInTemp": true,
        "formCreationDate": "2023-08-08 14:03:08",
        "url": "file:///data/user/0/com.asite.field/app_flutter/database/HTML5Form/createFormHTML.html",
        "offlineFormDataJson":
            "{\"myFields\":{\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_WORKINGUSER\",\"SP_RES_VIEW\":\"DS_WORKINGUSER\",\"SP_RES_PRINT_VIEW\":\"DS_WORKINGUSER\",\"SP_ORI_PRINT_VIEW\":\"DS_WORKINGUSER\"}},\"ORI_CREATEDATE\":\"25-Aug-2023\",\"ORI_ORIGINATOR\":\"Mayur Raval m., Asite Solutions Ltd\",\"ORI_FORMTITLE\":\"Distribution Actions Test\",\"ORI_DETAILS\":\"Test\",\"RES_RESPONSE\":\"\",\"RES_FINALSUMMARY\":\"\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[{\\\"email\\\":true,\\\"hUserID\\\":\\\"1161363\\\",\\\"fname\\\":\\\"Chandresh\\\",\\\"lname\\\":\\\"Patel\\\",\\\"user_type\\\":1,\\\"hActionID\\\":\\\"7\\\",\\\"actionDueDate\\\":\\\"\\\",\\\"orgID\\\":3,\\\"orgName\\\":\\\"Asite Solutions\\\"},{\\\"email\\\":true,\\\"hUserID\\\":\\\"1161363\\\",\\\"fname\\\":\\\"Chandresh\\\",\\\"lname\\\":\\\"Patel\\\",\\\"user_type\\\":1,\\\"hActionID\\\":\\\"2\\\",\\\"actionDueDate\\\":\\\"16-Aug-2023 14:3:34\\\",\\\"orgID\\\":3,\\\"orgName\\\":\\\"Asite Solutions\\\"},{\\\"email\\\":false,\\\"hUserID\\\":\\\"514806\\\",\\\"fname\\\":\\\"Dhaval\\\",\\\"lname\\\":\\\"Vekaria (5226)\\\",\\\"user_type\\\":1,\\\"hActionID\\\":\\\"6\\\",\\\"actionDueDate\\\":\\\"17-Aug-2023 14:3:25\\\",\\\"orgID\\\":3,\\\"orgName\\\":\\\"Asite Solutions\\\"}],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"25-Aug-2023\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[{\\\"email\\\":true,\\\"hUserID\\\":\\\"1161363\\\",\\\"fname\\\":\\\"Chandresh\\\",\\\"lname\\\":\\\"Patel\\\",\\\"user_type\\\":1,\\\"hActionID\\\":\\\"7\\\",\\\"actionDueDate\\\":\\\"\\\",\\\"orgID\\\":3,\\\"orgName\\\":\\\"Asite Solutions\\\"},{\\\"email\\\":true,\\\"hUserID\\\":\\\"1161363\\\",\\\"fname\\\":\\\"Chandresh\\\",\\\"lname\\\":\\\"Patel\\\",\\\"user_type\\\":1,\\\"hActionID\\\":\\\"2\\\",\\\"actionDueDate\\\":\\\"16-Aug-2023 14:3:34\\\",\\\"orgID\\\":3,\\\"orgName\\\":\\\"Asite Solutions\\\"},{\\\"email\\\":false,\\\"hUserID\\\":\\\"514806\\\",\\\"fname\\\":\\\"Dhaval\\\",\\\"lname\\\":\\\"Vekaria (5226)\\\",\\\"user_type\\\":1,\\\"hActionID\\\":\\\"6\\\",\\\"actionDueDate\\\":\\\"17-Aug-2023 14:3:25\\\",\\\"orgID\\\":3,\\\"orgName\\\":\\\"Asite Solutions\\\"}],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"formAction\":\"create\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11104955\",\"assocLocationSelection\":\"{\\\"locationId\\\":185573}\",\"requestType\":\"0\",\"annotationId\":\"45d8490e-542b-49ee-84ed-15e322eabd77-1691483588520\",\"coordinates\":\"{\\\"x1\\\":300.1035336864152,\\\"y1\\\":582.9163221378506,\\\"x2\\\":310.1035336864152,\\\"y2\\\":592.9163221378506}\",\"respondBy\":\"25-Aug-2023\",\"appTypeId\":\"2\"}}}",
        "isDraft": false
      };
      String formTypeQuery = "SELECT * FROM FormGroupAndFormTypeListTbl\nWHERE ProjectId=2130192 AND FormTypeId=11104955";
      when(() => mockDatabaseManager.executeSelectFromTable(FormTypeDao.tableName, formTypeQuery)).thenReturn([
        {
          "ProjectId": 2130192,
          "FormTypeId": 11103151,
          "FormTypeGroupId": 402,
          "FormTypeGroupName": "Correspondence",
          "FormTypeGroupCode": "DISC",
          "FormTypeName": "Discussion",
          "AppBuilderId": "STD-DIS",
          "InstanceGroupId": 11018088,
          "TemplateTypeId": 2,
          "FormTypeDetailJson":
              "{\"allow_associate_location\":true,\"allow_attachments\":true,\"appBuilderID\":\"STD-DIS\",\"appId\":2,\"canAccessPrivilegedForms\":true,\"canCreateForm\":true,\"canViewDraftMsg\":false,\"createFormsLimit\":0,\"createdFormsCount\":0,\"crossWorkspaceID\":-1,\"draftFormsCount\":0,\"formGroupCode\":\"DISC\",\"formTypeGroupName\":\"Correspondence\",\"formTypeID\":\"11104955\",\"formTypeName\":\"Discussion\",\"formTypesDetail\":{\"actionList\":[{\"actionID\":\"2\",\"actionName\":\"AssignStatus\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":true,\"is_default\":false,\"num_days\":6,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0},{\"actionID\":\"5\",\"actionName\":\"AttachDocs\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":false,\"is_default\":false,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0},{\"actionID\":\"6\",\"actionName\":\"Distribute\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":true,\"is_default\":false,\"num_days\":7,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0},{\"actionID\":\"37\",\"actionName\":\"ForAcknowledgement\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":true,\"is_default\":false,\"num_days\":5,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0},{\"actionID\":\"36\",\"actionName\":\"ForAction\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":true,\"is_default\":false,\"num_days\":5,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0},{\"actionID\":\"7\",\"actionName\":\"ForInformation\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":true,\"is_default\":false,\"num_days\":1,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0},{\"actionID\":\"3\",\"actionName\":\"Respond\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":false,\"is_default\":false,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0},{\"actionID\":\"34\",\"actionName\":\"ReviewDraft\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":true,\"is_default\":false,\"num_days\":6,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0}],\"formTypeGroupVO\":{\"formTypeGroupID\":402,\"formTypeGroupName\":\"AppBuilderForms(HTML)\",\"generateURI\":true},\"formTypeVO\":{\"allowDistributionByAll\":true,\"allowDistributionByRoles\":false,\"allowDistributionRoleIds\":\"\",\"allowEditingORI\":false,\"allowExternalAccess\":0,\"allowImportExcelInEditORI\":false,\"allowImportForm\":false,\"allowLocationAssociation\":true,\"allowViewAssociation\":1,\"allowWorkspaceLink\":false,\"allow_attachments\":true,\"allow_attributes\":false,\"allow_comment_associations\":false,\"allow_distribution_after_creation\":true,\"allow_distribution_originator\":true,\"allow_distribution_recipients\":true,\"allow_doc_associates\":true,\"allow_form_associations\":true,\"allow_forward_originator\":true,\"allow_forward_recipients\":true,\"allow_forwarding\":true,\"allow_reopening_form\":true,\"appBuilderFormIDCode\":\"STD-DIS\",\"appTypeId\":2,\"associations_extend_doc_issue\":false,\"auto_publish_to_folder\":false,\"bfpc\":\"0\",\"browsable_attachment_folder\":false,\"canEditWithAppbuilder\":true,\"canReplyViaEmail\":0,\"clonedFormTypeId\":0,\"code\":\"DISC\",\"continue_discussion\":false,\"createFormsLimit\":0,\"createFormsLimitLevel\":0,\"createdMsgCount\":0,\"ctrl_change_status\":false,\"dataCenterId\":0,\"default_action\":\"-1\",\"default_folder_id\":\"\",\"default_folder_path\":\"\",\"displayFileName\":\"Discussion.zip\",\"docAssociationType\":1,\"draftMsgId\":0,\"draft_count\":0,\"embedFormContentInEmail\":0,\"enableDraftResponses\":0,\"enableECatalague\":false,\"externalUsersOnly\":0,\"fixedFieldIds\":\"20,22,\",\"formGroupName\":\"Correspondence\",\"formTypeID\":\"11104955\",\"formTypeName\":\"Discussion\",\"form_type_group_id\":402,\"had\":\"0\",\"hasAppbuilderTemplateDraft\":false,\"has_hyperlink\":false,\"has_overall_status\":true,\"hide_orgs_and_users\":false,\"infojetServerVersion\":0,\"instance_group_id\":\"11018088\",\"integrateExchange\":false,\"isAsycnProcess\":false,\"isAutoCreateOnStatusChange\":false,\"isDistributionFromGroupOnly\":false,\"isFormAvailableOffline\":0,\"isFromMarketplace\":false,\"isLocationAssocMandatory\":true,\"isMarkDefault\":false,\"isMobile\":false,\"isNewlyCreated\":false,\"isOverwriteExcelInEditORI\":true,\"isRecent\":false,\"isTemplateChanged\":false,\"is_active\":true,\"is_default\":false,\"is_instance\":true,\"is_public\":false,\"linkedWorkspaceProjectId\":\"-1\",\"loginUserId\":2017529,\"mandatoryDistribution\":0,\"orig_can_close\":false,\"orig_change_status\":true,\"parent_formtype_id\":\"10052172\",\"projectId\":\"2130192\",\"public_message\":false,\"responders_collaborate\":true,\"responseFromAll\":false,\"responsePattern\":0,\"response_allowed\":true,\"restrictChangeFormStatus\":0,\"show_responses\":true,\"signatureBox\":\"000\",\"spellCheckPrefs\":\"11\",\"subTemplateType\":0,\"templateType\":2,\"upload_logo\":false,\"use_controller\":false,\"user_ref\":false,\"viewFieldIdsData\":\"<root><views><viewid>2</viewid><view_name>ORI_PRINT_VIEW</view_name><fieldids>20,22</fieldids></views><views><viewid>4</viewid><view_name>RES_PRINT_VIEW</view_name><fieldids>20,22</fieldids></views><views><viewid>3</viewid><view_name>RES_VIEW</view_name><fieldids>20,22</fieldids></views><views><viewid>1</viewid><view_name>ORI_VIEW</view_name><fieldids>20,22</fieldids></views></root>\",\"viewIds\":\"3,1,2,4,\",\"view_always_doc_association\":false,\"view_always_form_association\":false,\"viewsList\":[{\"appBuilderEnabled\":false,\"fieldsIds\":\"20,22\",\"formTypeId\":\"0\",\"generateURI\":true,\"viewId\":1,\"viewName\":\"ORI_VIEW\"},{\"appBuilderEnabled\":false,\"fieldsIds\":\"20,22\",\"formTypeId\":\"0\",\"generateURI\":true,\"viewId\":2,\"viewName\":\"ORI_PRINT_VIEW\"},{\"appBuilderEnabled\":false,\"fieldsIds\":\"20,22\",\"formTypeId\":\"0\",\"generateURI\":true,\"viewId\":3,\"viewName\":\"RES_VIEW\"},{\"appBuilderEnabled\":false,\"fieldsIds\":\"20,22\",\"formTypeId\":\"0\",\"generateURI\":true,\"viewId\":4,\"viewName\":\"RES_PRINT_VIEW\"}],\"xmlData\":\"<my:myFieldsxmlns:my=\\\"http://schemas.microsoft.com/office/infopath/2003/myXSD/2015-08-11T07:43:54\\\"><my:ORI_ORIGINATOR/><my:RES_FINALSUMMARY/><my:ORI_DETAILS/><my:ORI_FORMTITLE/><my:RES_RESPONSE/><my:Asite_System_Data_Read_Write><my:ORI_MSG_Fields><my:SP_RES_PRINT_VIEW>DS_WORKINGUSER</my:SP_RES_PRINT_VIEW><my:SP_RES_VIEW>DS_WORKINGUSER</my:SP_RES_VIEW><my:SP_ORI_PRINT_VIEW>DS_WORKINGUSER</my:SP_ORI_PRINT_VIEW><my:SP_ORI_VIEW>DS_WORKINGUSER</my:SP_ORI_VIEW></my:ORI_MSG_Fields></my:Asite_System_Data_Read_Write><my:ORI_CREATEDATE/></my:myFields>\",\"xslFileName\":\"\",\"xsnFile\":\"2327196.zip\"},\"generateURI\":true,\"isFormInherited\":false,\"statusList\":[{\"always_active\":false,\"closesOutForm\":true,\"defaultPermissionId\":0,\"generateURI\":true,\"hasAccess\":true,\"isDeactive\":false,\"isEnableForReviewComment\":false,\"is_associated\":true,\"orgId\":\"0\",\"proxyUserId\":0,\"statusID\":3,\"statusName\":\"Closed\",\"userId\":0},{\"always_active\":false,\"closesOutForm\":false,\"defaultPermissionId\":0,\"generateURI\":true,\"hasAccess\":true,\"isDeactive\":false,\"isEnableForReviewComment\":false,\"is_associated\":false,\"orgId\":\"0\",\"proxyUserId\":0,\"statusID\":4,\"statusName\":\"Closed-Approved\",\"userId\":0},{\"always_active\":false,\"closesOutForm\":false,\"defaultPermissionId\":0,\"generateURI\":true,\"hasAccess\":true,\"isDeactive\":false,\"isEnableForReviewComment\":false,\"is_associated\":false,\"orgId\":\"0\",\"proxyUserId\":0,\"statusID\":5,\"statusName\":\"Closed-ApprovedwithComments\",\"userId\":0},{\"always_active\":false,\"closesOutForm\":false,\"defaultPermissionId\":0,\"generateURI\":true,\"hasAccess\":true,\"isDeactive\":false,\"isEnableForReviewComment\":false,\"is_associated\":false,\"orgId\":\"0\",\"proxyUserId\":0,\"statusID\":6,\"statusName\":\"Closed-Rejected\",\"userId\":0},{\"always_active\":false,\"closesOutForm\":false,\"defaultPermissionId\":0,\"generateURI\":true,\"hasAccess\":true,\"isDeactive\":false,\"isEnableForReviewComment\":false,\"is_associated\":true,\"orgId\":\"0\",\"proxyUserId\":0,\"statusID\":1001,\"statusName\":\"Open\",\"userId\":0},{\"always_active\":false,\"closesOutForm\":false,\"defaultPermissionId\":0,\"generateURI\":true,\"hasAccess\":true,\"isDeactive\":false,\"isEnableForReviewComment\":false,\"is_associated\":true,\"orgId\":\"0\",\"proxyUserId\":0,\"statusID\":1002,\"statusName\":\"Resolved\",\"userId\":0},{\"always_active\":false,\"closesOutForm\":false,\"defaultPermissionId\":0,\"generateURI\":true,\"hasAccess\":true,\"isDeactive\":false,\"isEnableForReviewComment\":false,\"is_associated\":true,\"orgId\":\"0\",\"proxyUserId\":0,\"statusID\":1003,\"statusName\":\"Verified\",\"userId\":0}]},\"formtypeGroupid\":402,\"instanceGroupId\":11018088,\"isFavourite\":false,\"is_location_assoc_mandatory\":true,\"numActions\":4,\"numOverdueActions\":0,\"templatetype\":2,\"totalForms\":0,\"workspaceid\":2130192}",
          "AllowLocationAssociation": 1,
          "CanCreateForms": 1,
          "AppTypeId": "2"
        }
      ]);
      Map saveResponse = await createFormLocalDataSource.saveFormOffline(saveFormParam);
      expect(saveResponse.isNotEmpty, true);
      expect(saveResponse.containsKey('formId'), true);
      expect(saveResponse.containsKey('msgId'), true);
      expect(saveResponse.containsKey('locationId'), true);
    });
    test("Test Create Draft Form with Attachment From the Plan and Save it", () async {
      Map<String, dynamic> saveFormParam = {
        "projectId": "2130192",
        "locationId": 183682,
        "coordinates": "{\"x1\":646.694607498723,\"y1\":633.3538860379657,\"x2\":656.694607498723,\"y2\":643.3538860379657}",
        "annotationId": "4a31a24d-2c87-4d8a-aa26-a7c71a600580-1691147798919",
        "isFromMapView": true,
        "isCalibrated": true,
        "page_number": 1,
        "appTypeId": 2,
        "formSelectRadiobutton": "1_2130192_11103151",
        "formTypeId": "11103151",
        "instanceGroupId": "10940318",
        "templateType": 2,
        "appBuilderId": "ASI-SITE",
        "revisionId": "26773045",
        "offlineFormId": 1691147798938,
        "isUploadAttachmentInTemp": true,
        "formCreationDate": "2023-08-04 16:46:38",
        "url": "file:///data/user/0/com.asite.field/app_flutter/database/HTML5Form/createFormHTML.html",
        "offlineFormDataJson":
            "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"ORI_FORMTITLE\":\"Test offline\",\"ORI_USERREF\":\"\",\"DefectTyoe\":\"Computer\",\"TaskType\":\"Defect\",\"DefectDescription\":\"\",\"Location\":\"183682|Basement|01 Vijay_Test>Plan-1>Basement\",\"LocationName\":\"01 Vijay_Test>Plan-1>Basement\",\"StartDate\":\"2023-08-04\",\"StartDateDisplay\":\"04-Aug-2023\",\"ExpectedFinishDate\":\"\",\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"ActualFinishDate\":\"\",\"Recent_Defects\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"707447#Vijay Mavadiya (5336), Asite Solutions\"}},\"CurrStage\":\"1\",\"PF_Location_Detail\":\"183682|26773045|{\\\"x1\\\":593.98,\\\"y1\\\":669.61,\\\"x2\\\":803.92,\\\"y2\\\":522.8199999999999}|1\",\"Defect_Description\":\"edittred\",\"Username\":\"\",\"Organization\":\"\",\"ExpectedFinishDays\":\"5\",\"DistributionDays\":\"0\",\"LastResponder_For_AssignedTo\":\"707447\",\"LastResponder_For_Originator\":\"2017529\",\"FormCreationDate\":\"\",\"Assigned\":\"Vijay Mavadiya (5336), Asite Solutions\",\"attachements\":[{\"attachedDocs\":\"\"}],\"DS_Logo\":\"images/asite.gif\",\"isCalibrated\":true},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"ShowHideFlag\":\"Yes\",\"SHResponse\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_FORMAUTONO_CREATE\":\"\",\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_ADD\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_Get_All_Responses\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"Asite_System_Data_Read_Only\":{\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_2_Printing_Data\":{\"DS_PRINTEDBY\":\"\",\"DS_PRINTEDON\":\"\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMNAME\":\"Site Tasks\",\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\"},\"_5_Form_Data\":{\"DS_FORMID\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_DATEOFISSUE\":\"\",\"DS_DISTRIBUTION\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_ISDRAFT_RES\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ISDRAFT_RES_MSG\":\"NO\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"Status_Data\":{\"DS_FORMSTATUS\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_APPROVEDBY\":\"\",\"DS_APPROVEDON\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\"}},\"_6_Form_MSG_Data\":{\"DS_MSGID\":\"\",\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_PROJDISTUSERS\":\"707447\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_ACTIONDUEDATE\":\"5\"}]}},\"attachments\":[],\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"formAction\":\"create\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11103151\",\"assocLocationSelection\":\"{\\\"locationId\\\":183682}\",\"requestType\":\"0\",\"annotationId\":\"4a31a24d-2c87-4d8a-aa26-a7c71a600580-1691147798919\",\"coordinates\":\"{\\\"x1\\\":646.694607498723,\\\"y1\\\":633.3538860379657,\\\"x2\\\":656.694607498723,\\\"y2\\\":643.3538860379657}\",\"attachedDocs_0\":\"temp_img_annotation.png_2017529\",\"upFile0\":\"./test/fixtures/files/temp_img_annotation.png\",\"attachedDocs_1\":\"test.pdf_2017529\",\"upFile1\":\"./test/fixtures/files/test.pdf\",\"appTypeId\":\"2\"}}}",
        "isDraft": true
      };
      Map saveResponse = await createFormLocalDataSource.saveFormOffline(saveFormParam);
      expect(saveResponse.isNotEmpty, true);
      expect(saveResponse.containsKey('formId'), true);
      expect(saveResponse.containsKey('msgId'), true);
      expect(saveResponse.containsKey('locationId'), true);
    });
    test("Test Respond/Reply action with Attachment and Save it", () async {
      Map<String, dynamic> saveFormParam = {
        "projectId": "2130192",
        "locationId": "185571",
        "formId": "11637822",
        "formTypeId": "11103151",
        "templateType": 2,
        "appBuilderId": "ASI-SITE",
        "appTypeId": 2,
        "formSelectRadiobutton": "1_2130192_11103151",
        "isUploadAttachmentInTemp": true,
        "offlineFormDataJson":
            "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"DistributionDays\":\"12\",\"Organization\":\"\",\"DefectTyoe\":\"Architectural\",\"ExpectedFinishDate\":\"2023-08-24\",\"DefectDescription\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"2017529#Mayur Raval m., Asite Solutions Ltd\"}},\"Defect_Description\":\"Test Cases\",\"LocationName\":\"01 Vijay_Test>Plan-4>Family Room\",\"StartDate\":\"2023-08-08\",\"ActualFinishDate\":\"\",\"ExpectedFinishDays\":\"12\",\"DS_Logo\":\"images/asite.gif\",\"LastResponder_For_AssignedTo\":\"2017529\",\"TaskType\":\"Damages\",\"isCalibrated\":true,\"ORI_FORMTITLE\":\"Respond Test Case\",\"attachements\":[{\"attachedDocs\":\"\"}],\"OriginatorId\":\"1161363 | Chandresh Patel, Asite Solutions # Chandresh Patel, Asite Solutions\",\"Assigned\":\"Mayur Raval m., Asite Solutions Ltd\",\"Todays_Date\":\"2023-08-08T05:51:48\",\"CurrStage\":\"1\",\"Recent_Defects\":\"\",\"FormCreationDate\":\"\",\"StartDateDisplay\":\"08-Aug-2023\",\"LastResponder_For_Originator\":\"1161363\",\"PF_Location_Detail\":\"185571|27187964|{\\\"x1\\\":465.3,\\\"y1\\\":1021.97,\\\"x2\\\":594.08,\\\"y2\\\":822.3399999999999}|1\",\"Username\":\"\",\"ORI_USERREF\":\"\",\"Location\":\"185571|Family Room|01 Vijay_Test>Plan-4>Family Room\"},\"RES_MSG_Custom_Fields\":{\"Comments\":\"Responded\",\"SHResponse\":\"Yes\",\"ShowHideFlag\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_CREATE\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\",\"DS_FORMAUTONO_ADD\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_Get_All_Responses\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"attachments\":[],\"Asite_System_Data_Read_Only\":{\"_2_Printing_Data\":{\"DS_PRINTEDON\":\"\",\"DS_PRINTEDBY\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMGROUPCODE\":\"\",\"DS_FORMAUTONO\":\"\",\"DS_FORMNAME\":\"Site Tasks\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_5_Form_Data\":{\"DS_DATEOFISSUE\":\"\",\"DS_ISDRAFT_RES_MSG\":\"\",\"Status_Data\":{\"DS_APPROVEDON\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\",\"DS_ALL_FORMSTATUS\":\"1002 # Resolved\",\"DS_APPROVEDBY\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_FORMSTATUS\":\"Open\"},\"DS_DISTRIBUTION\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT_RES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_CLOSE_DUE_DATE\":\"2023-08-24\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_FORMID\":\"\"},\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_6_Form_MSG_Data\":{\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGID\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"411\",\"DS_PROJUSERS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_ACTIONDUEDATE\":\"7\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_PROJDISTUSERS\":\"1161363\"}]}},\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"2\",\"msg_type_code\":\"RES\",\"parent_msg_id\":\"12349105\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"assocLocationSelection\":\"\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11103151\",\"requestType\":\"4\",\"formAction\":\"create\",\"attachedDocs_0\":\"test.pdf_2017529\",\"upFile0\":\"./test/fixtures/files/test.pdf\",\"appTypeId\":\"2\"}}}",
        "isDraft": false
      };
      String formQuery =
          "WITH OfflineSyncData AS (SELECT  CASE frmMsgTbl.OfflineRequestData WHEN 2 THEN 5 ELSE 1 END AS Type, frmTypeTbl.AppTypeId, frmMsgTbl.ProjectId, frmMsgTbl.FormTypeId, frmTypeTbl.InstanceGroupId, frmTypeTbl.TemplateTypeId, frmMsgTbl.FormId, frmMsgTbl.MsgId, frmMsgTbl.MsgTypeId, frmMsgTbl.OfflineRequestData, frmMsgTbl.UpdatedDateInMS, frmMsgTbl.IsDraft, frmMsgTbl.DelFormIds FROM FormMessageListTbl frmMsgTbl INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId INNER JOIN FormGroupAndFormTypeListTbl frmTypeTbl ON frmTypeTbl.ProjectId=frmMsgTbl.ProjectId AND frmTypeTbl.FormTypeId=frmMsgTbl.FormTypeId WHERE frmMsgTbl.OfflineRequestData<>'' AND ((frmTypeTbl.TemplateTypeId=1 AND frmMsgTbl.IsDraft<>1) OR frmTypeTbl.TemplateTypeId<>1)) SELECT IFNULL(fldSycDataView.OfflineRequestData,'') AS NewOfflineRequestData,frmTbl.* FROM FormListTbl frmTbl LEFT JOIN OfflineSyncData  fldSycDataView ON frmTbl.ProjectId=fldSycDataView.ProjectId AND frmTbl.FormId=fldSycDataView.FormId AND fldSycDataView.Type IN (1,2,5) WHERE frmTbl.ProjectId=2130192  AND frmTbl.FormId=11637822";
      String formMsgQuery = "SELECT * FROM FormMessageListTbl WHERE ProjectId=2130192 AND FormId=11637822 AND MsgTypeId=2";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, formQuery)).thenReturn([
        {
          "NewOfflineRequestData": "",
          "ProjectId": 2130192,
          "FormId": "11637822",
          "AppTypeId": 2,
          "FormTypeId": 11103151,
          "InstanceGroupId": 10940318,
          "FormTitle": "Respond Test Case",
          "Code": "SITE409",
          "CommentId": 11637822,
          "MessageId": 12349105,
          "ParentMessageId": 0,
          "OrgId": 3,
          "FirstName": "Chandresh",
          "LastName": "Patel",
          "OrgName": "Asite Solutions",
          "Originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1161363_thumbnail.jpg?v=1673263342000#Chandresh",
          "OriginatorDisplayName": "Chandresh Patel, Asite Solutions",
          "NoOfActions": 0,
          "ObservationId": 112857,
          "LocationId": 185571,
          "PfLocFolderId": 116251424,
          "Updated": "07-Aug-2023#23:52 CST",
          "AttachmentImageName": "icons/assocform.png",
          "MsgCode": "ORI001",
          "TypeImage": "icons/form.png",
          "DocType": "Apps",
          "HasAttachments": 0,
          "HasDocAssocations": 0,
          "HasBimViewAssociations": 0,
          "HasFormAssocations": 0,
          "HasCommentAssocations": 0,
          "FormHasAssocAttach": 1,
          "FormCreationDate": "07-Aug-2023#23:52 CST",
          "FolderId": 0,
          "MsgTypeId": 1,
          "MsgStatusId": 20,
          "FormNumber": 409,
          "MsgOriginatorId": 1161363,
          "TemplateType": 2,
          "IsDraft": 0,
          "StatusId": 1001,
          "OriginatorId": 1161363,
          "IsStatusChangeRestricted": 0,
          "AllowReopenForm": 0,
          "CanOrigChangeStatus": 0,
          "MsgTypeCode": "ORI",
          "Id": "",
          "StatusChangeUserId": 0,
          "StatusUpdateDate": "07-Aug-2023#23:52 CST",
          "StatusChangeUserName": "Chandresh Patel",
          "StatusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_1161363_thumbnail.jpg?v=1673263342000#Chandresh",
          "StatusChangeUserEmail": "chandreshpatel@asite.com",
          "StatusChangeUserOrg": "Asite Solutions",
          "OriginatorEmail": "chandreshpatel@asite.com",
          "ControllerUserId": 0,
          "UpdatedDateInMS": 1691470379000,
          "FormCreationDateInMS": 1691470379000,
          "ResponseRequestByInMS": 1692943199000,
          "FlagType": 0,
          "LatestDraftId": 0,
          "FlagTypeImageName": "flag_type/flag_0.png",
          "MessageTypeImageName": "icons/form.png",
          "CanAccessHistory": 1,
          "FormJsonData": "",
          "Status": "Open",
          "AttachedDocs": "",
          "IsUploadAttachmentInTemp": 0,
          "IsSync": 0,
          "UserRefCode": "",
          "HasActions": 1,
          "CanRemoveOffline": 0,
          "IsMarkOffline": 0,
          "IsOfflineCreated": 0,
          "SyncStatus": 1,
          "IsForDefect": 0,
          "IsForApps": 0,
          "ObservationDefectTypeId": "310497",
          "StartDate": "2023-08-08",
          "ExpectedFinishDate": "2023-08-24",
          "IsActive": 1,
          "ObservationCoordinates": "{\"x1\":536.33,\"y1\":934.37,\"x2\":584.33,\"y2\":886.37}",
          "AnnotationId": "b27a8610-0d01-9d6b-1ee8-0cf1fcad84cf",
          "IsCloseOut": 0,
          "AssignedToUserId": 2017529,
          "AssignedToUserName": "Mayur Raval m.",
          "AssignedToUserOrgName": "Asite Solutions Ltd",
          "MsgNum": "",
          "RevisionId": "",
          "RequestJsonForOffline": "",
          "FormDueDays": "12",
          "FormSyncDate": "2023-08-08 05:52:59.0",
          "LastResponderForAssignedTo": "2017529",
          "LastResponderForOriginator": "1161363",
          "PageNumber": "1",
          "ObservationDefectType": "",
          "StatusName": "Open",
          "AppBuilderId": "ASI-SITE",
          "TaskTypeName": "",
          "AssignedToRoleName": ""
        }
      ]);
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMsgQuery)).thenReturn([]);
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, captureAny(that: startsWith("SELECT count(*) AS MsgCount FROM FormMessageListTbl")))).thenReturn([]);
      Map saveResponse = await createFormLocalDataSource.saveFormOffline(saveFormParam);
      expect(saveResponse.isNotEmpty, true);
      expect(saveResponse.containsKey('formId'), true);
      expect(saveResponse.containsKey('msgId'), true);
      expect(saveResponse.containsKey('locationId'), true);
    });
    test("Test Edit Form which is created in offline and Save it", () async {
      Map<String, dynamic> saveFormParam = {
        "projectId": "2130192",
        "locationId": 185572,
        "formId": "1691478052496",
        "formTypeId": "11103151",
        "templateType": 2,
        "appBuilderId": "ASI-SITE",
        "appTypeId": 2,
        "formSelectRadiobutton": "1_2130192_11103151",
        "isUploadAttachmentInTemp": true,
        "offlineFormDataJson":
            "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"ORI_FORMTITLE\":\"Edit Form Test\",\"ORI_USERREF\":\"\",\"DefectTyoe\":\"Architectural\",\"TaskType\":\"Damages\",\"DefectDescription\":\"\",\"Location\":\"185572|Salon|01 Vijay_Test>Plan-4>Salon\",\"LocationName\":\"01 Vijay_Test>Plan-4>Salon\",\"StartDate\":\"2023-08-08\",\"StartDateDisplay\":\"08-Aug-2023\",\"ExpectedFinishDate\":\"2023-08-20\",\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"ActualFinishDate\":\"\",\"Recent_Defects\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"1161363#Chandresh Patel, Asite Solutions\"}},\"CurrStage\":\"2\",\"PF_Location_Detail\":\"185572|27187964|{\\\"x1\\\":460.47,\\\"y1\\\":814.3,\\\"x2\\\":639.16,\\\"y2\\\":669.41}|1\",\"Defect_Description\":\"T\",\"Username\":\"\",\"Organization\":\"\",\"ExpectedFinishDays\":\"12\",\"DistributionDays\":\"0\",\"LastResponder_For_AssignedTo\":\"1161363\",\"LastResponder_For_Originator\":\"2017529\",\"FormCreationDate\":\"\",\"Assigned\":\"Chandresh Patel, Asite Solutions\",\"attachements\":[{\"attachedDocs\":\"\"}],\"DS_Logo\":\"images/asite.gif\",\"isCalibrated\":true},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"ShowHideFlag\":\"Yes\",\"SHResponse\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_FORMAUTONO_CREATE\":\"\",\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_ADD\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_Get_All_Responses\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"Asite_System_Data_Read_Only\":{\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_2_Printing_Data\":{\"DS_PRINTEDBY\":\"\",\"DS_PRINTEDON\":\"\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMNAME\":\"Site Tasks\",\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\"},\"_5_Form_Data\":{\"DS_FORMID\":\"SITE\",\"DS_ORIGINATOR\":\"\",\"DS_DATEOFISSUE\":\"\",\"DS_DISTRIBUTION\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_ISDRAFT_RES\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ISDRAFT_RES_MSG\":\"NO\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"Status_Data\":{\"DS_FORMSTATUS\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_APPROVEDBY\":\"\",\"DS_APPROVEDON\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\"}},\"_6_Form_MSG_Data\":{\"DS_MSGID\":\"\",\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_PROJDISTUSERS\":\"1161363\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_ACTIONDUEDATE\":\"12\"}]}},\"attachments\":[],\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"parent_msg_id\":\"0\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"assocLocationSelection\":\"{\\\"locationId\\\":185572}\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11103151\",\"editORI\":\"false\",\"requestType\":\"2\",\"msgId\":\"1691478133747\",\"formAction\":\"create\",\"editDraft\":\"false\",\"attachedDocs0\":\"1691478133808128\",\"appTypeId\":\"2\"},\"attachment_fields\":\"\"}}",
        "isDraft": true
      };
      String formQuery =
          "WITH OfflineSyncData AS (SELECT  CASE frmMsgTbl.OfflineRequestData WHEN 2 THEN 5 ELSE 1 END AS Type, frmTypeTbl.AppTypeId, frmMsgTbl.ProjectId, frmMsgTbl.FormTypeId, frmTypeTbl.InstanceGroupId, frmTypeTbl.TemplateTypeId, frmMsgTbl.FormId, frmMsgTbl.MsgId, frmMsgTbl.MsgTypeId, frmMsgTbl.OfflineRequestData, frmMsgTbl.UpdatedDateInMS, frmMsgTbl.IsDraft, frmMsgTbl.DelFormIds FROM FormMessageListTbl frmMsgTbl INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId INNER JOIN FormGroupAndFormTypeListTbl frmTypeTbl ON frmTypeTbl.ProjectId=frmMsgTbl.ProjectId AND frmTypeTbl.FormTypeId=frmMsgTbl.FormTypeId WHERE frmMsgTbl.OfflineRequestData<>'' AND ((frmTypeTbl.TemplateTypeId=1 AND frmMsgTbl.IsDraft<>1) OR frmTypeTbl.TemplateTypeId<>1)) SELECT IFNULL(fldSycDataView.OfflineRequestData,'') AS NewOfflineRequestData,frmTbl.* FROM FormListTbl frmTbl LEFT JOIN OfflineSyncData  fldSycDataView ON frmTbl.ProjectId=fldSycDataView.ProjectId AND frmTbl.FormId=fldSycDataView.FormId AND fldSycDataView.Type IN (1,2,5) WHERE frmTbl.ProjectId=2130192  AND frmTbl.FormId=1691478052496";
      String formMsgQuery = "SELECT * FROM FormMessageListTbl\nWHERE ProjectId=2130192 AND FormId=1691478052496 AND MsgId=1691478133747";
      String formAttachmentQuery = "SELECT * FROM FormMsgAttachAndAssocListTbl WHERE ProjectId=2130192 AND FormId=1691478052496 AND MsgId<>1691478133747";
      String formMsgTypeQuery = "SELECT * FROM FormMessageListTbl WHERE ProjectId=2130192 AND FormId=1691478052496 AND MsgTypeId=1";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, formQuery)).thenReturn([
        {
          "NewOfflineRequestData": "1",
          "ProjectId": 2130192,
          "FormId": "1691478052496",
          "AppTypeId": 2,
          "FormTypeId": 11103151,
          "InstanceGroupId": 10940318,
          "FormTitle": "Edit Form Test",
          "Code": "SITE",
          "CommentId": 1691478052496,
          "MessageId": 1691478133747,
          "ParentMessageId": 0,
          "OrgId": 0,
          "FirstName": "Mayur",
          "LastName": "Raval m.",
          "OrgName": "Asite Solutions Ltd",
          "Originator": "",
          "OriginatorDisplayName": " Mayur Raval m., Asite Solutions Ltd ",
          "NoOfActions": 0,
          "ObservationId": 1691478052496,
          "LocationId": 185572,
          "PfLocFolderId": "",
          "Updated": "2023-08-08 12:32:13.013",
          "AttachmentImageName": "icons/assocform.png",
          "MsgCode": "ORI001",
          "TypeImage": "icons/form.png",
          "DocType": "",
          "HasAttachments": 1,
          "HasDocAssocations": 0,
          "HasBimViewAssociations": 0,
          "HasFormAssocations": 0,
          "HasCommentAssocations": 0,
          "FormHasAssocAttach": 1,
          "FormCreationDate": "2023-08-08 12:32:13.013",
          "FolderId": "",
          "MsgTypeId": 1,
          "MsgStatusId": "",
          "FormNumber": "",
          "MsgOriginatorId": 2017529,
          "TemplateType": 2,
          "IsDraft": 0,
          "StatusId": 1001,
          "OriginatorId": 2017529,
          "IsStatusChangeRestricted": 0,
          "AllowReopenForm": 0,
          "CanOrigChangeStatus": 0,
          "MsgTypeCode": "ORI",
          "Id": "",
          "StatusChangeUserId": "",
          "StatusUpdateDate": "",
          "StatusChangeUserName": "",
          "StatusChangeUserPic": "",
          "StatusChangeUserEmail": "",
          "StatusChangeUserOrg": "",
          "OriginatorEmail": "",
          "ControllerUserId": "",
          "UpdatedDateInMS": 1691478133747,
          "FormCreationDateInMS": 1691478133747,
          "ResponseRequestByInMS": "",
          "FlagType": "",
          "LatestDraftId": "",
          "FlagTypeImageName": "",
          "MessageTypeImageName": "",
          "CanAccessHistory": 0,
          "FormJsonData": "",
          "Status": "Open",
          "AttachedDocs": "",
          "IsUploadAttachmentInTemp": 1,
          "IsSync": 0,
          "UserRefCode": "",
          "HasActions": 0,
          "CanRemoveOffline": 0,
          "IsMarkOffline": 1,
          "IsOfflineCreated": 1,
          "SyncStatus": 1,
          "IsForDefect": 1,
          "IsForApps": 0,
          "ObservationDefectTypeId": "310497",
          "StartDate": "2023-08-08",
          "ExpectedFinishDate": "2023-08-20",
          "IsActive": 1,
          "ObservationCoordinates": "{\"x1\":527.0890387016723,\"y1\":703.3783692873515,\"x2\":537.0890387016723,\"y2\":713.3783692873515}",
          "AnnotationId": "24aa2d64-1cda-42ff-93a3-0eacd381ea64-1691478052484",
          "IsCloseOut": 0,
          "AssignedToUserId": 1161363,
          "AssignedToUserName": "Chandresh Patel",
          "AssignedToUserOrgName": " Asite Solutions",
          "MsgNum": 0,
          "RevisionId": 27187964,
          "RequestJsonForOffline": "",
          "FormDueDays": "12",
          "FormSyncDate": "",
          "LastResponderForAssignedTo": "1161363",
          "LastResponderForOriginator": "2017529",
          "PageNumber": "1",
          "ObservationDefectType": "Architectural",
          "StatusName": "Open",
          "AppBuilderId": "ASI-SITE",
          "TaskTypeName": "",
          "AssignedToRoleName": ""
        }
      ]);
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMsgQuery)).thenReturn([
        {
          "ProjectId": "2130192",
          "FormTypeId": "11103151",
          "FormId": "1691478052496",
          "MsgId": "1691478133747",
          "Originator": "",
          "OriginatorDisplayName": " Mayur Raval m., Asite Solutions Ltd ",
          "MsgCode": "ORI001",
          "MsgCreatedDate": "2023-08-08 12:32:13.013",
          "ParentMsgId": "0",
          "MsgOriginatorId": "2017529",
          "MsgHasAssocAttach": 1,
          "JsonData":
              "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"ORI_FORMTITLE\":\"Edit Form Test\",\"ORI_USERREF\":\"\",\"DefectTyoe\":\"Architectural\",\"TaskType\":\"Damages\",\"DefectDescription\":\"\",\"Location\":\"185572|Salon|01 Vijay_Test>Plan-4>Salon\",\"LocationName\":\"01 Vijay_Test>Plan-4>Salon\",\"StartDate\":\"2023-08-08\",\"StartDateDisplay\":\"08-Aug-2023\",\"ExpectedFinishDate\":\"2023-08-20\",\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"ActualFinishDate\":\"\",\"Recent_Defects\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"1161363#Chandresh Patel, Asite Solutions\"}},\"CurrStage\":\"1\",\"PF_Location_Detail\":\"185572|27187964|{\\\"x1\\\":460.47,\\\"y1\\\":814.3,\\\"x2\\\":639.16,\\\"y2\\\":669.41}|1\",\"Defect_Description\":\"T\",\"Username\":\"\",\"Organization\":\"\",\"ExpectedFinishDays\":\"12\",\"DistributionDays\":\"0\",\"LastResponder_For_AssignedTo\":\"1161363\",\"LastResponder_For_Originator\":\"2017529\",\"FormCreationDate\":\"\",\"Assigned\":\"Chandresh Patel, Asite Solutions\",\"attachements\":[{\"attachedDocs\":\"\"}],\"DS_Logo\":\"images/asite.gif\",\"isCalibrated\":true},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"ShowHideFlag\":\"Yes\",\"SHResponse\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_FORMAUTONO_CREATE\":\"\",\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_ADD\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_Get_All_Responses\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"Asite_System_Data_Read_Only\":{\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_2_Printing_Data\":{\"DS_PRINTEDBY\":\"\",\"DS_PRINTEDON\":\"\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMNAME\":\"Site Tasks\",\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\"},\"_5_Form_Data\":{\"DS_FORMID\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_DATEOFISSUE\":\"\",\"DS_DISTRIBUTION\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_ISDRAFT_RES\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ISDRAFT_RES_MSG\":\"NO\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"Status_Data\":{\"DS_FORMSTATUS\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_APPROVEDBY\":\"\",\"DS_APPROVEDON\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\"}},\"_6_Form_MSG_Data\":{\"DS_MSGID\":\"\",\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_PROJDISTUSERS\":\"1161363\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_ACTIONDUEDATE\":\"12\"}]}},\"attachments\":[],\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"formAction\":\"create\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11103151\",\"assocLocationSelection\":\"{\\\"locationId\\\":185572}\",\"requestType\":\"0\",\"annotationId\":\"24aa2d64-1cda-42ff-93a3-0eacd381ea64-1691478052484\",\"coordinates\":\"{\\\"x1\\\":527.0890387016723,\\\"y1\\\":703.3783692873515,\\\"x2\\\":537.0890387016723,\\\"y2\\\":713.3783692873515}\",\"attachedDocs_0\":\"CAP6805135748225538611.jpg_2017529\",\"upFile0\":\"/data/user/0/com.asite.field/app_flutter/database/1_2017529/2130192/tempAttachments/CAP6805135748225538611.jpg\",\"appTypeId\":\"2\"},\"attachment_fields\":\"\"}}",
          "UserRefCode": "",
          "UpdatedDateInMS": "1691478133747",
          "FormCreationDateInMS": "1691478133747",
          "MsgCreatedDateInMS": "1691478133747",
          "MsgTypeId": "1",
          "MsgTypeCode": "ORI",
          "MsgStatusId": "20",
          "SentNames": "",
          "SentActions": "",
          "DraftSentActions": "",
          "FixFieldData": "",
          "FolderId": "",
          "LatestDraftId": "",
          "IsDraft": 0,
          "AssocRevIds": "",
          "ResponseRequestBy": "08-Aug-2023",
          "DelFormIds": "",
          "AssocFormIds": "",
          "AssocCommIds": "",
          "FormUserSet": "",
          "FormPermissionsMap": "",
          "CanOrigChangeStatus": 0,
          "CanControllerChangeStatus": 0,
          "IsStatusChangeRestricted": 0,
          "HasOverallStatus": 0,
          "IsCloseOut": 0,
          "AllowReopenForm": 0,
          "OfflineRequestData": "1",
          "IsOfflineCreated": 1,
          "LocationId": 185572,
          "ObservationId": 1691478052496,
          "MsgNum": 1,
          "MsgContent": "T",
          "ActionComplete": 0,
          "ActionCleared": 0,
          "HasAttach": 1,
          "TotalActions": 0,
          "InstanceGroupId": 10940318,
          "AttachFiles": "",
          "HasViewAccess": 0,
          "MsgOriginImage": "",
          "IsForInfoIncomplete": 0,
          "MsgCreatedDateOffline": "",
          "LastModifiedTime": "",
          "LastModifiedTimeInMS": "",
          "CanViewDraftMsg": 0,
          "CanViewOwnorgPrivateForms": 0,
          "IsAutoSavedDraft": 0,
          "MsgStatusName": "",
          "ProjectAPDFolderId": "",
          "ProjectStatusId": "",
          "HasFormAccess": 0,
          "CanAccessHistory": 0,
          "HasDocAssocations": 0,
          "HasBimViewAssociations": 0,
          "HasBimListAssociations": 0,
          "HasFormAssocations": 0,
          "HasCommentAssocations": 0
        }
      ]);
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, formAttachmentQuery)).thenReturn([]);
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMsgTypeQuery)).thenReturn([
        {
          "ProjectId": "2130192",
          "FormTypeId": "11103151",
          "FormId": "1691478052496",
          "MsgId": "1691478133747",
          "Originator": "",
          "OriginatorDisplayName": " Mayur Raval m., Asite Solutions Ltd ",
          "MsgCode": "ORI001",
          "MsgCreatedDate": "2023-08-08 12:32:13.013",
          "ParentMsgId": "0",
          "MsgOriginatorId": "2017529",
          "MsgHasAssocAttach": 1,
          "JsonData":
              "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"ORI_FORMTITLE\":\"Edit Form Test\",\"ORI_USERREF\":\"\",\"DefectTyoe\":\"Architectural\",\"TaskType\":\"Damages\",\"DefectDescription\":\"\",\"Location\":\"185572|Salon|01 Vijay_Test>Plan-4>Salon\",\"LocationName\":\"01 Vijay_Test>Plan-4>Salon\",\"StartDate\":\"2023-08-08\",\"StartDateDisplay\":\"08-Aug-2023\",\"ExpectedFinishDate\":\"2023-08-20\",\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"ActualFinishDate\":\"\",\"Recent_Defects\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"1161363#Chandresh Patel, Asite Solutions\"}},\"CurrStage\":\"1\",\"PF_Location_Detail\":\"185572|27187964|{\\\"x1\\\":460.47,\\\"y1\\\":814.3,\\\"x2\\\":639.16,\\\"y2\\\":669.41}|1\",\"Defect_Description\":\"T\",\"Username\":\"\",\"Organization\":\"\",\"ExpectedFinishDays\":\"12\",\"DistributionDays\":\"0\",\"LastResponder_For_AssignedTo\":\"1161363\",\"LastResponder_For_Originator\":\"2017529\",\"FormCreationDate\":\"\",\"Assigned\":\"Chandresh Patel, Asite Solutions\",\"attachements\":[{\"attachedDocs\":\"\"}],\"DS_Logo\":\"images/asite.gif\",\"isCalibrated\":true},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"ShowHideFlag\":\"Yes\",\"SHResponse\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_FORMAUTONO_CREATE\":\"\",\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_ADD\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_Get_All_Responses\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"Asite_System_Data_Read_Only\":{\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_2_Printing_Data\":{\"DS_PRINTEDBY\":\"\",\"DS_PRINTEDON\":\"\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"Site Quality Demo\",\"DS_CLIENT\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMNAME\":\"Site Tasks\",\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\"},\"_5_Form_Data\":{\"DS_FORMID\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_DATEOFISSUE\":\"\",\"DS_DISTRIBUTION\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_ISDRAFT_RES\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ISDRAFT_RES_MSG\":\"NO\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"Status_Data\":{\"DS_FORMSTATUS\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_APPROVEDBY\":\"\",\"DS_APPROVEDON\":\"\",\"DS_CLOSE_DUE_DATE\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\"}},\"_6_Form_MSG_Data\":{\"DS_MSGID\":\"\",\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_PROJDISTUSERS\":\"1161363\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_ACTIONDUEDATE\":\"12\"}]}},\"attachments\":[],\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"formAction\":\"create\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11103151\",\"assocLocationSelection\":\"{\\\"locationId\\\":185572}\",\"requestType\":\"0\",\"annotationId\":\"24aa2d64-1cda-42ff-93a3-0eacd381ea64-1691478052484\",\"coordinates\":\"{\\\"x1\\\":527.0890387016723,\\\"y1\\\":703.3783692873515,\\\"x2\\\":537.0890387016723,\\\"y2\\\":713.3783692873515}\",\"attachedDocs_0\":\"CAP6805135748225538611.jpg_2017529\",\"upFile0\":\"/data/user/0/com.asite.field/app_flutter/database/1_2017529/2130192/tempAttachments/CAP6805135748225538611.jpg\",\"appTypeId\":\"2\"},\"attachment_fields\":\"\"}}",
          "UserRefCode": "",
          "UpdatedDateInMS": "1691478133747",
          "FormCreationDateInMS": "1691478133747",
          "MsgCreatedDateInMS": "1691478133747",
          "MsgTypeId": "1",
          "MsgTypeCode": "ORI",
          "MsgStatusId": "20",
          "SentNames": "",
          "SentActions": "",
          "DraftSentActions": "",
          "FixFieldData": "",
          "FolderId": "",
          "LatestDraftId": "",
          "IsDraft": 0,
          "AssocRevIds": "",
          "ResponseRequestBy": "08-Aug-2023",
          "DelFormIds": "",
          "AssocFormIds": "",
          "AssocCommIds": "",
          "FormUserSet": "",
          "FormPermissionsMap": "",
          "CanOrigChangeStatus": 0,
          "CanControllerChangeStatus": 0,
          "IsStatusChangeRestricted": 0,
          "HasOverallStatus": 0,
          "IsCloseOut": 0,
          "AllowReopenForm": 0,
          "OfflineRequestData": "1",
          "IsOfflineCreated": 1,
          "LocationId": 185572,
          "ObservationId": 1691478052496,
          "MsgNum": 1,
          "MsgContent": "T",
          "ActionComplete": 0,
          "ActionCleared": 0,
          "HasAttach": 1,
          "TotalActions": 0,
          "InstanceGroupId": 10940318,
          "AttachFiles": "",
          "HasViewAccess": 0,
          "MsgOriginImage": "",
          "IsForInfoIncomplete": 0,
          "MsgCreatedDateOffline": "",
          "LastModifiedTime": "",
          "LastModifiedTimeInMS": "",
          "CanViewDraftMsg": 0,
          "CanViewOwnorgPrivateForms": 0,
          "IsAutoSavedDraft": 0,
          "MsgStatusName": "",
          "ProjectAPDFolderId": "",
          "ProjectStatusId": "",
          "HasFormAccess": 0,
          "CanAccessHistory": 0,
          "HasDocAssocations": 0,
          "HasBimViewAssociations": 0,
          "HasBimListAssociations": 0,
          "HasFormAssocations": 0,
          "HasCommentAssocations": 0
        }
      ]);
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, captureAny(that: startsWith("SELECT count(*) AS MsgCount FROM FormMessageListTbl")))).thenReturn([]);
      removeFormMsgAttachAndAssocDataMock();
      Map saveResponse = await createFormLocalDataSource.saveFormOffline(saveFormParam);
      expect(saveResponse.isNotEmpty, true);
      expect(saveResponse.containsKey('formId'), true);
      expect(saveResponse.containsKey('msgId'), true);
      expect(saveResponse.containsKey('locationId'), true);
    });
    test("Test Create With Distribution Actions and Save it", () async {
      Map<String, dynamic> saveFormParam = {
        "projectId": "2130192",
        "locationId": 183682,
        "coordinates": "{\"x1\":300.1035336864152,\"y1\":582.9163221378506,\"x2\":310.1035336864152,\"y2\":592.9163221378506}",
        "annotationId": "45d8490e-542b-49ee-84ed-15e322eabd77-1691483588520",
        "isFromMapView": true,
        "isCalibrated": true,
        "page_number": 1,
        "appTypeId": 2,
        "formSelectRadiobutton": "1_2130192_11104955",
        "formTypeId": "11104955",
        "instanceGroupId": "11018088",
        "templateType": 2,
        "appBuilderId": "STD-DIS",
        "revisionId": "27187964",
        "offlineFormId": 1691483588552,
        "isUploadAttachmentInTemp": true,
        "formCreationDate": "2023-08-08 14:03:08",
        "url": "file:///data/user/0/com.asite.field/app_flutter/database/HTML5Form/createFormHTML.html",
        "offlineFormDataJson":
        "{\"myFields\":{\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_WORKINGUSER\",\"SP_RES_VIEW\":\"DS_WORKINGUSER\",\"SP_RES_PRINT_VIEW\":\"DS_WORKINGUSER\",\"SP_ORI_PRINT_VIEW\":\"DS_WORKINGUSER\"}},\"ORI_CREATEDATE\":\"25-Aug-2023\",\"ORI_ORIGINATOR\":\"Mayur Raval m., Asite Solutions Ltd\",\"ORI_FORMTITLE\":\"Distribution Actions Test\",\"ORI_DETAILS\":\"Test\",\"RES_RESPONSE\":\"\",\"RES_FINALSUMMARY\":\"\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"10283813,\\\",\\\"selectedDistUsers\\\":[{\\\"email\\\":true,\\\"hUserID\\\":\\\"1161363\\\",\\\"fname\\\":\\\"Chandresh\\\",\\\"lname\\\":\\\"Patel\\\",\\\"user_type\\\":1,\\\"hActionID\\\":\\\"7\\\",\\\"actionDueDate\\\":\\\"\\\",\\\"orgID\\\":3,\\\"orgName\\\":\\\"Asite Solutions\\\"},{\\\"email\\\":true,\\\"hUserID\\\":\\\"1161363\\\",\\\"fname\\\":\\\"Chandresh\\\",\\\"lname\\\":\\\"Patel\\\",\\\"user_type\\\":1,\\\"hActionID\\\":\\\"2\\\",\\\"actionDueDate\\\":\\\"16-Aug-2023 14:3:34\\\",\\\"orgID\\\":3,\\\"orgName\\\":\\\"Asite Solutions\\\"},{\\\"email\\\":false,\\\"hUserID\\\":\\\"514806\\\",\\\"fname\\\":\\\"Dhaval\\\",\\\"lname\\\":\\\"Vekaria (5226)\\\",\\\"user_type\\\":1,\\\"hActionID\\\":\\\"6\\\",\\\"actionDueDate\\\":\\\"17-Aug-2023 14:3:25\\\",\\\"orgID\\\":3,\\\"orgName\\\":\\\"Asite Solutions\\\"}],\\\"selectedDistOrgs\\\":[{\\\"hActionID\\\":\\\"7\\\",\\\"actionDueDate\\\":\\\"28-Jul-2023 17:0:18\\\",\\\"hOrgID\\\":3,\\\"orgName\\\":\\\"Asite Solutions\\\"}],\\\"selectedDistRoles\\\":[{\\\"hActionID\\\":\\\"7\\\",\\\"actionDueDate\\\":\\\"28-Jul-2023 17:0:18\\\",\\\"hRoleID\\\":3389434,\\\"roleName\\\":\\\"Field Administrator\\\"}],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"25-Aug-2023\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"10283813,\\\",\\\"selectedDistUsers\\\":[{\\\"email\\\":true,\\\"hUserID\\\":\\\"1161363\\\",\\\"fname\\\":\\\"Chandresh\\\",\\\"lname\\\":\\\"Patel\\\",\\\"user_type\\\":1,\\\"hActionID\\\":\\\"7\\\",\\\"actionDueDate\\\":\\\"\\\",\\\"orgID\\\":3,\\\"orgName\\\":\\\"Asite Solutions\\\"},{\\\"email\\\":true,\\\"hUserID\\\":\\\"1161363\\\",\\\"fname\\\":\\\"Chandresh\\\",\\\"lname\\\":\\\"Patel\\\",\\\"user_type\\\":1,\\\"hActionID\\\":\\\"2\\\",\\\"actionDueDate\\\":\\\"16-Aug-2023 14:3:34\\\",\\\"orgID\\\":3,\\\"orgName\\\":\\\"Asite Solutions\\\"},{\\\"email\\\":false,\\\"hUserID\\\":\\\"514806\\\",\\\"fname\\\":\\\"Dhaval\\\",\\\"lname\\\":\\\"Vekaria (5226)\\\",\\\"user_type\\\":1,\\\"hActionID\\\":\\\"6\\\",\\\"actionDueDate\\\":\\\"17-Aug-2023 14:3:25\\\",\\\"orgID\\\":3,\\\"orgName\\\":\\\"Asite Solutions\\\"}],\\\"selectedDistOrgs\\\":[{\\\"hActionID\\\":\\\"7\\\",\\\"actionDueDate\\\":\\\"28-Jul-2023 17:0:18\\\",\\\"hOrgID\\\":3,\\\"orgName\\\":\\\"Asite Solutions\\\"}],\\\"selectedDistRoles\\\":[{\\\"hActionID\\\":\\\"7\\\",\\\"actionDueDate\\\":\\\"28-Jul-2023 17:0:18\\\",\\\"hRoleID\\\":3389434,\\\"roleName\\\":\\\"Field Administrator\\\"}],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"formAction\":\"create\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11104955\",\"assocLocationSelection\":\"{\\\"locationId\\\":185573}\",\"requestType\":\"0\",\"annotationId\":\"45d8490e-542b-49ee-84ed-15e322eabd77-1691483588520\",\"coordinates\":\"{\\\"x1\\\":300.1035336864152,\\\"y1\\\":582.9163221378506,\\\"x2\\\":310.1035336864152,\\\"y2\\\":592.9163221378506}\",\"respondBy\":\"25-Aug-2023\",\"appTypeId\":\"2\"}}}",
        "isDraft": false
      };
      String formTypeQuery = "SELECT * FROM FormGroupAndFormTypeListTbl\nWHERE ProjectId=2130192 AND FormTypeId=11104955";
      when(() => mockDatabaseManager.executeSelectFromTable(FormTypeDao.tableName, formTypeQuery)).thenReturn([
        {
          "ProjectId": 2130192,
          "FormTypeId": 11103151,
          "FormTypeGroupId": 402,
          "FormTypeGroupName": "Correspondence",
          "FormTypeGroupCode": "DISC",
          "FormTypeName": "Discussion",
          "AppBuilderId": "STD-DIS",
          "InstanceGroupId": 11018088,
          "TemplateTypeId": 2,
          "FormTypeDetailJson":
              "{\"allow_associate_location\":true,\"allow_attachments\":true,\"appBuilderID\":\"STD-DIS\",\"appId\":2,\"canAccessPrivilegedForms\":true,\"canCreateForm\":true,\"canViewDraftMsg\":false,\"createFormsLimit\":0,\"createdFormsCount\":0,\"crossWorkspaceID\":-1,\"draftFormsCount\":0,\"formGroupCode\":\"DISC\",\"formTypeGroupName\":\"Correspondence\",\"formTypeID\":\"11104955\",\"formTypeName\":\"Discussion\",\"formTypesDetail\":{\"actionList\":[{\"actionID\":\"2\",\"actionName\":\"AssignStatus\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":true,\"is_default\":false,\"num_days\":6,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0},{\"actionID\":\"5\",\"actionName\":\"AttachDocs\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":false,\"is_default\":false,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0},{\"actionID\":\"6\",\"actionName\":\"Distribute\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":true,\"is_default\":false,\"num_days\":7,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0},{\"actionID\":\"37\",\"actionName\":\"ForAcknowledgement\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":true,\"is_default\":false,\"num_days\":5,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0},{\"actionID\":\"36\",\"actionName\":\"ForAction\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":true,\"is_default\":false,\"num_days\":5,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0},{\"actionID\":\"7\",\"actionName\":\"ForInformation\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":true,\"is_default\":false,\"num_days\":1,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0},{\"actionID\":\"3\",\"actionName\":\"Respond\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":false,\"is_default\":false,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0},{\"actionID\":\"34\",\"actionName\":\"ReviewDraft\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"formId\":\"0\",\"generateURI\":true,\"is_associated\":true,\"is_default\":false,\"num_days\":6,\"projectId\":\"0\",\"revisionId\":\"0\",\"userId\":0}],\"formTypeGroupVO\":{\"formTypeGroupID\":402,\"formTypeGroupName\":\"AppBuilderForms(HTML)\",\"generateURI\":true},\"formTypeVO\":{\"allowDistributionByAll\":true,\"allowDistributionByRoles\":false,\"allowDistributionRoleIds\":\"\",\"allowEditingORI\":false,\"allowExternalAccess\":0,\"allowImportExcelInEditORI\":false,\"allowImportForm\":false,\"allowLocationAssociation\":true,\"allowViewAssociation\":1,\"allowWorkspaceLink\":false,\"allow_attachments\":true,\"allow_attributes\":false,\"allow_comment_associations\":false,\"allow_distribution_after_creation\":true,\"allow_distribution_originator\":true,\"allow_distribution_recipients\":true,\"allow_doc_associates\":true,\"allow_form_associations\":true,\"allow_forward_originator\":true,\"allow_forward_recipients\":true,\"allow_forwarding\":true,\"allow_reopening_form\":true,\"appBuilderFormIDCode\":\"STD-DIS\",\"appTypeId\":2,\"associations_extend_doc_issue\":false,\"auto_publish_to_folder\":false,\"bfpc\":\"0\",\"browsable_attachment_folder\":false,\"canEditWithAppbuilder\":true,\"canReplyViaEmail\":0,\"clonedFormTypeId\":0,\"code\":\"DISC\",\"continue_discussion\":false,\"createFormsLimit\":0,\"createFormsLimitLevel\":0,\"createdMsgCount\":0,\"ctrl_change_status\":false,\"dataCenterId\":0,\"default_action\":\"-1\",\"default_folder_id\":\"\",\"default_folder_path\":\"\",\"displayFileName\":\"Discussion.zip\",\"docAssociationType\":1,\"draftMsgId\":0,\"draft_count\":0,\"embedFormContentInEmail\":0,\"enableDraftResponses\":0,\"enableECatalague\":false,\"externalUsersOnly\":0,\"fixedFieldIds\":\"20,22,\",\"formGroupName\":\"Correspondence\",\"formTypeID\":\"11104955\",\"formTypeName\":\"Discussion\",\"form_type_group_id\":402,\"had\":\"0\",\"hasAppbuilderTemplateDraft\":false,\"has_hyperlink\":false,\"has_overall_status\":true,\"hide_orgs_and_users\":false,\"infojetServerVersion\":0,\"instance_group_id\":\"11018088\",\"integrateExchange\":false,\"isAsycnProcess\":false,\"isAutoCreateOnStatusChange\":false,\"isDistributionFromGroupOnly\":false,\"isFormAvailableOffline\":0,\"isFromMarketplace\":false,\"isLocationAssocMandatory\":true,\"isMarkDefault\":false,\"isMobile\":false,\"isNewlyCreated\":false,\"isOverwriteExcelInEditORI\":true,\"isRecent\":false,\"isTemplateChanged\":false,\"is_active\":true,\"is_default\":false,\"is_instance\":true,\"is_public\":false,\"linkedWorkspaceProjectId\":\"-1\",\"loginUserId\":2017529,\"mandatoryDistribution\":0,\"orig_can_close\":false,\"orig_change_status\":true,\"parent_formtype_id\":\"10052172\",\"projectId\":\"2130192\",\"public_message\":false,\"responders_collaborate\":true,\"responseFromAll\":false,\"responsePattern\":0,\"response_allowed\":true,\"restrictChangeFormStatus\":0,\"show_responses\":true,\"signatureBox\":\"000\",\"spellCheckPrefs\":\"11\",\"subTemplateType\":0,\"templateType\":2,\"upload_logo\":false,\"use_controller\":false,\"user_ref\":false,\"viewFieldIdsData\":\"<root><views><viewid>2</viewid><view_name>ORI_PRINT_VIEW</view_name><fieldids>20,22</fieldids></views><views><viewid>4</viewid><view_name>RES_PRINT_VIEW</view_name><fieldids>20,22</fieldids></views><views><viewid>3</viewid><view_name>RES_VIEW</view_name><fieldids>20,22</fieldids></views><views><viewid>1</viewid><view_name>ORI_VIEW</view_name><fieldids>20,22</fieldids></views></root>\",\"viewIds\":\"3,1,2,4,\",\"view_always_doc_association\":false,\"view_always_form_association\":false,\"viewsList\":[{\"appBuilderEnabled\":false,\"fieldsIds\":\"20,22\",\"formTypeId\":\"0\",\"generateURI\":true,\"viewId\":1,\"viewName\":\"ORI_VIEW\"},{\"appBuilderEnabled\":false,\"fieldsIds\":\"20,22\",\"formTypeId\":\"0\",\"generateURI\":true,\"viewId\":2,\"viewName\":\"ORI_PRINT_VIEW\"},{\"appBuilderEnabled\":false,\"fieldsIds\":\"20,22\",\"formTypeId\":\"0\",\"generateURI\":true,\"viewId\":3,\"viewName\":\"RES_VIEW\"},{\"appBuilderEnabled\":false,\"fieldsIds\":\"20,22\",\"formTypeId\":\"0\",\"generateURI\":true,\"viewId\":4,\"viewName\":\"RES_PRINT_VIEW\"}],\"xmlData\":\"<my:myFieldsxmlns:my=\\\"http://schemas.microsoft.com/office/infopath/2003/myXSD/2015-08-11T07:43:54\\\"><my:ORI_ORIGINATOR/><my:RES_FINALSUMMARY/><my:ORI_DETAILS/><my:ORI_FORMTITLE/><my:RES_RESPONSE/><my:Asite_System_Data_Read_Write><my:ORI_MSG_Fields><my:SP_RES_PRINT_VIEW>DS_WORKINGUSER</my:SP_RES_PRINT_VIEW><my:SP_RES_VIEW>DS_WORKINGUSER</my:SP_RES_VIEW><my:SP_ORI_PRINT_VIEW>DS_WORKINGUSER</my:SP_ORI_PRINT_VIEW><my:SP_ORI_VIEW>DS_WORKINGUSER</my:SP_ORI_VIEW></my:ORI_MSG_Fields></my:Asite_System_Data_Read_Write><my:ORI_CREATEDATE/></my:myFields>\",\"xslFileName\":\"\",\"xsnFile\":\"2327196.zip\"},\"generateURI\":true,\"isFormInherited\":false,\"statusList\":[{\"always_active\":false,\"closesOutForm\":true,\"defaultPermissionId\":0,\"generateURI\":true,\"hasAccess\":true,\"isDeactive\":false,\"isEnableForReviewComment\":false,\"is_associated\":true,\"orgId\":\"0\",\"proxyUserId\":0,\"statusID\":3,\"statusName\":\"Closed\",\"userId\":0},{\"always_active\":false,\"closesOutForm\":false,\"defaultPermissionId\":0,\"generateURI\":true,\"hasAccess\":true,\"isDeactive\":false,\"isEnableForReviewComment\":false,\"is_associated\":false,\"orgId\":\"0\",\"proxyUserId\":0,\"statusID\":4,\"statusName\":\"Closed-Approved\",\"userId\":0},{\"always_active\":false,\"closesOutForm\":false,\"defaultPermissionId\":0,\"generateURI\":true,\"hasAccess\":true,\"isDeactive\":false,\"isEnableForReviewComment\":false,\"is_associated\":false,\"orgId\":\"0\",\"proxyUserId\":0,\"statusID\":5,\"statusName\":\"Closed-ApprovedwithComments\",\"userId\":0},{\"always_active\":false,\"closesOutForm\":false,\"defaultPermissionId\":0,\"generateURI\":true,\"hasAccess\":true,\"isDeactive\":false,\"isEnableForReviewComment\":false,\"is_associated\":false,\"orgId\":\"0\",\"proxyUserId\":0,\"statusID\":6,\"statusName\":\"Closed-Rejected\",\"userId\":0},{\"always_active\":false,\"closesOutForm\":false,\"defaultPermissionId\":0,\"generateURI\":true,\"hasAccess\":true,\"isDeactive\":false,\"isEnableForReviewComment\":false,\"is_associated\":true,\"orgId\":\"0\",\"proxyUserId\":0,\"statusID\":1001,\"statusName\":\"Open\",\"userId\":0},{\"always_active\":false,\"closesOutForm\":false,\"defaultPermissionId\":0,\"generateURI\":true,\"hasAccess\":true,\"isDeactive\":false,\"isEnableForReviewComment\":false,\"is_associated\":true,\"orgId\":\"0\",\"proxyUserId\":0,\"statusID\":1002,\"statusName\":\"Resolved\",\"userId\":0},{\"always_active\":false,\"closesOutForm\":false,\"defaultPermissionId\":0,\"generateURI\":true,\"hasAccess\":true,\"isDeactive\":false,\"isEnableForReviewComment\":false,\"is_associated\":true,\"orgId\":\"0\",\"proxyUserId\":0,\"statusID\":1003,\"statusName\":\"Verified\",\"userId\":0}]},\"formtypeGroupid\":402,\"instanceGroupId\":11018088,\"isFavourite\":false,\"is_location_assoc_mandatory\":true,\"numActions\":4,\"numOverdueActions\":0,\"templatetype\":2,\"totalForms\":0,\"workspaceid\":2130192}",
          "AllowLocationAssociation": 1,
          "CanCreateForms": 1,
          "AppTypeId": "2"
        }
      ]);
      Map saveResponse = await createFormLocalDataSource.saveFormOffline(saveFormParam);
      expect(saveResponse.isNotEmpty, true);
      expect(saveResponse.containsKey('formId'), true);
      expect(saveResponse.containsKey('msgId'), true);
      expect(saveResponse.containsKey('locationId'), true);
    });
    test("Test Create Form with Inline Attachment From the Plan and Save it", () async {
      Map<String, dynamic> saveFormParam ={"projectId":"2116416","msgId":"1691478133747","locationId":183895,"coordinates":"{\"x1\":317.409977351698,\"y1\":578.1311923255256,\"x2\":327.409977351698,\"y2\":588.1311923255256}","annotationId":"bc2f9956-c777-479c-9402-8f96e3fe1190-1691572633624","isFromMapView":true,"isCalibrated":true,"page_number":1,"appTypeId":1,"formSelectRadiobutton":"1_2116416_10616643","formTypeId":"10616643","instanceGroupId":"10583899","templateType":2,"appBuilderId":"INL","revisionId":"26852532","offlineFormId":1691572633656,"isUploadAttachmentInTemp":true,"formCreationDate":"2023-08-09 14:47:13","url":"file:///data/user/0/com.asite.field/app_flutter/database/HTML5Form/createFormHTML.html","offlineFormDataJson":"{\"myFields\":{\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_ALL_FORMSTATUS\",\"SP_ORI_VIEW_HTML\":\"DS_ALL_FORMSTATUS\",\"SP_ORI_PRINT_VIEW\":\"DS_ALL_FORMSTATUS\",\"SP_ORI_PRINT_VIEW_HTML\":\"DS_ALL_FORMSTATUS\"}},\"TB_Title\":\"Test\",\"Repeating_Table\":{\"value\":[{\"Attachment_2\":{\"@inline\":\"xdoc_0_9_0_0_my:Attachment_2\",\"content\":\"\",\"OfflineContent\":{\"fileType\":6,\"isThumbnailSupports\":false,\"upFilePath\":\"./test/fixtures/files/test.pdf\"}}},{\"Attachment_3\":{\"@inline\":\"xdoc_0_9_0_0_my:Attachment_3\",\"content\":\"2089700#11105686#1690365017226#1690365017226_xdoc_0_4_6_1_my#1690365017226_xdoc_0_4_6_1_my_1690365038319370#1690365038319370\"}}],\"table_header\":[{}],\"table_footer\":[{}],\"defuaultRowData\":{\"Attachment_2\":\"\"}},\"ORI_FORMTITLE\":\"InLine attachments\",\"DS_ALL_FORMSTATUS\":\"5 # Closed-Approved with Comments\",\"CloseDueDate\":\"\",\"Datepicker_1\":\"2023-08-08T18:30:00.000Z\",\"Repeating_Table_2\":{\"value\":[{}],\"table_header\":[{}],\"table_footer\":[{}],\"defuaultRowData\":{}},\"Textbox_1\":\"\",\"MultiDropdown\":\"\",\"Attachment_5\":\"\",\"reply\":\"\",\"ORI_FORMTITLE_Copy\":\"InLine attachments\",\"TB_Title_Copy\":\"Test\",\"Repeating_Table_Copy\":{\"value\":[{}],\"table_header\":[{}],\"table_footer\":[{}],\"defuaultRowData\":{}},\"Dropdown_4_Copy\":\"Closed-Approved with Comments\",\"CloseDueDate_Copy\":\"\",\"attachments\":[],\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"respondBy\":\"25-Aug-2023\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msgId\":\"1691478133747\",\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"dist_list\":\"{\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"prePopulatedDistGroups\\\":\\\"\\\"}\",\"formAction\":\"create\",\"project_id\":\"2116416\",\"offlineProjectId\":\"2116416\",\"offlineFormTypeId\":\"10616643\",\"assocLocationSelection\":\"{\\\"locationId\\\":183895}\",\"requestType\":\"0\",\"annotationId\":\"bc2f9956-c777-479c-9402-8f96e3fe1190-1691572633624\",\"coordinates\":\"{\\\"x1\\\":317.409977351698,\\\"y1\\\":578.1311923255256,\\\"x2\\\":327.409977351698,\\\"y2\\\":588.1311923255256}\",\"respondBy\":\"25-Aug-2023\",\"appTypeId\":\"1\"}}}","isDraft":false};
      String formTypeQuery = "SELECT * FROM FormGroupAndFormTypeListTbl\nWHERE ProjectId=2116416 AND FormTypeId=10616643";
      when(() => mockDatabaseManager.executeSelectFromTable(FormTypeDao.tableName, formTypeQuery)).thenReturn([{"ProjectId":2116416,"FormTypeId":10616643,"FormTypeGroupId":399,"FormTypeGroupName":"INL","FormTypeGroupCode":"INL","FormTypeName":"Inline attachment","AppBuilderId":"INL","InstanceGroupId":10583899,"TemplateTypeId":2,"FormTypeDetailJson":"{\"createFormsLimit\":0,\"canAccessPrivilegedForms\":true,\"formTypeID\":\"10616643\",\"allow_attachments\":true,\"formTypesDetail\":{\"formTypeVO\":{\"formTypeID\":\"10616643\",\"formTypeName\":\"Inline attachment\",\"code\":\"INL\",\"use_controller\":false,\"response_allowed\":false,\"show_responses\":true,\"allow_reopening_form\":true,\"default_action\":\"7\",\"is_default\":true,\"allow_forwarding\":false,\"allow_distribution_after_creation\":true,\"allow_distribution_originator\":true,\"allow_distribution_recipients\":false,\"allow_forward_originator\":false,\"allow_forward_recipients\":false,\"responders_collaborate\":false,\"continue_discussion\":false,\"hide_orgs_and_users\":false,\"has_hyperlink\":false,\"allow_attachments\":true,\"allow_doc_associates\":true,\"allow_form_associations\":true,\"allow_attributes\":true,\"associations_extend_doc_issue\":true,\"public_message\":false,\"browsable_attachment_folder\":false,\"has_overall_status\":true,\"is_instance\":true,\"form_type_group_id\":399,\"instance_group_id\":\"10583899\",\"ctrl_change_status\":false,\"parent_formtype_id\":\"10033011\",\"orig_change_status\":false,\"orig_can_close\":false,\"upload_logo\":false,\"user_ref\":false,\"allow_comment_associations\":true,\"is_public\":true,\"is_active\":true,\"signatureBox\":\"000\",\"xsnFile\":\"2467572.zip\",\"xmlData\":\"<my:myFields xmlns:my=\\\"http://schemas.microsoft.com/office/infopath/2003/myXSD/2015-08-11T07:43:54\\\"><my:CloseDueDate_Copy/><my:Repeating_Table><my:table_header my:ASITE_JSON_ARRAY=\\\"true\\\"/><my:table_footer my:ASITE_JSON_ARRAY=\\\"true\\\"/><my:value my:ASITE_JSON_ARRAY=\\\"true\\\"><my:Attachment_2/></my:value></my:Repeating_Table><my:Attachment_5/><my:TB_Title/><my:MultiDropdown/><my:Asite_System_Data_Read_Write><my:ORI_MSG_Fields><my:SP_ORI_VIEW_HTML>DS_ALL_FORMSTATUS</my:SP_ORI_VIEW_HTML><my:SP_ORI_PRINT_VIEW_HTML>DS_ALL_FORMSTATUS</my:SP_ORI_PRINT_VIEW_HTML><my:SP_ORI_PRINT_VIEW>DS_ALL_FORMSTATUS</my:SP_ORI_PRINT_VIEW><my:SP_ORI_VIEW>DS_ALL_FORMSTATUS</my:SP_ORI_VIEW></my:ORI_MSG_Fields></my:Asite_System_Data_Read_Write><my:CloseDueDate/><my:ORI_FORMTITLE_Copy/><my:Textbox_1/><my:Dropdown_4_Copy/><my:DS_ALL_FORMSTATUS/><my:Repeating_Table_Copy><my:table_header my:ASITE_JSON_ARRAY=\\\"true\\\"/><my:table_footer my:ASITE_JSON_ARRAY=\\\"true\\\"/><my:value my:ASITE_JSON_ARRAY=\\\"true\\\"/></my:Repeating_Table_Copy><my:ORI_FORMTITLE/><my:reply/><my:TB_Title_Copy/><my:Datepicker_1>CURRENT_DATE_0d</my:Datepicker_1><my:Repeating_Table_2><my:table_header my:ASITE_JSON_ARRAY=\\\"true\\\"/><my:table_footer my:ASITE_JSON_ARRAY=\\\"true\\\"/><my:value my:ASITE_JSON_ARRAY=\\\"true\\\"/></my:Repeating_Table_2></my:myFields>\",\"templateType\":2,\"responsePattern\":0,\"fixedFieldIds\":\"20,563,\",\"displayFileName\":\"Inline Attachment.zip\",\"viewIds\":\"3,1,2,5,4,\",\"mandatoryDistribution\":0,\"responseFromAll\":false,\"subTemplateType\":0,\"integrateExchange\":false,\"allowEditingORI\":true,\"allowImportExcelInEditORI\":false,\"isOverwriteExcelInEditORI\":true,\"enableECatalague\":false,\"formGroupName\":\"INL\",\"projectId\":\"2116416\",\"clonedFormTypeId\":0,\"appBuilderFormIDCode\":\"INL\",\"loginUserId\":2017529,\"xslFileName\":\"\",\"allowImportForm\":false,\"allowWorkspaceLink\":false,\"linkedWorkspaceProjectId\":\"-1\",\"createFormsLimit\":0,\"spellCheckPrefs\":\"10\",\"isMobile\":false,\"createFormsLimitLevel\":0,\"restrictChangeFormStatus\":0,\"enableDraftResponses\":0,\"isDistributionFromGroupOnly\":true,\"isAutoCreateOnStatusChange\":true,\"docAssociationType\":1,\"viewFieldIdsData\":\"<root><views><viewid>2</viewid><view_name>ORI_PRINT_VIEW</view_name><fieldids>20,563</fieldids></views><views><viewid>4</viewid><view_name>RES_PRINT_VIEW</view_name><fieldids>20</fieldids></views><views><viewid>5</viewid><view_name>FORM_PRINT_VIEW</view_name><fieldids>20</fieldids></views><views><viewid>103863</viewid><view_name>RES_VIEW_HTML</view_name><fieldids>20</fieldids></views><views><viewid>119498</viewid><view_name>ORI_VIEW_HTML</view_name><fieldids>20,563</fieldids></views><views><viewid>3</viewid><view_name>RES_VIEW</view_name><fieldids>20</fieldids></views><views><viewid>103864</viewid><view_name>ORI_VIEW_HTML</view_name><fieldids>20,563</fieldids></views><views><viewid>1</viewid><view_name>ORI_VIEW</view_name><fieldids>20,563</fieldids></views><views><viewid>119497</viewid><view_name>RES_VIEW_HTML</view_name><fieldids>20</fieldids></views></root>\",\"createdMsgCount\":0,\"draft_count\":0,\"draftMsgId\":0,\"view_always_form_association\":true,\"view_always_doc_association\":false,\"auto_publish_to_folder\":true,\"default_folder_path\":\"\",\"default_folder_id\":\"\",\"allowExternalAccess\":0,\"embedFormContentInEmail\":0,\"canReplyViaEmail\":0,\"externalUsersOnly\":1,\"appTypeId\":1,\"dataCenterId\":0,\"allowViewAssociation\":1,\"infojetServerVersion\":0,\"isFormAvailableOffline\":1,\"allowDistributionByAll\":true,\"allowDistributionByRoles\":false,\"allowDistributionRoleIds\":\"\",\"canEditWithAppbuilder\":true,\"hasAppbuilderTemplateDraft\":false,\"isTemplateChanged\":false,\"viewsList\":[{\"viewId\":1,\"viewName\":\"ORI_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"20,563\",\"generateURI\":true},{\"viewId\":2,\"viewName\":\"ORI_PRINT_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"20,563\",\"generateURI\":true},{\"viewId\":3,\"viewName\":\"RES_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"20\",\"generateURI\":true},{\"viewId\":4,\"viewName\":\"RES_PRINT_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"20\",\"generateURI\":true},{\"viewId\":5,\"viewName\":\"FORM_PRINT_VIEW\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"20\",\"generateURI\":true},{\"viewId\":103863,\"viewName\":\"RES_VIEW_HTML\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"20\",\"generateURI\":true},{\"viewId\":103864,\"viewName\":\"ORI_VIEW_HTML\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"20,563\",\"generateURI\":true},{\"viewId\":119497,\"viewName\":\"RES_VIEW_HTML\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"20\",\"generateURI\":true},{\"viewId\":119498,\"viewName\":\"ORI_VIEW_HTML\",\"formTypeId\":\"0\",\"appBuilderEnabled\":false,\"fieldsIds\":\"20,563\",\"generateURI\":true}],\"isRecent\":false,\"allowLocationAssociation\":true,\"isLocationAssocMandatory\":false,\"templateJsonData\":\"{'fieldMap':[],'fxValueMap':{'ORI_FORMTITLE':['ORI_FORMTITLE_Copy'],'TB_Title':['TB_Title_Copy'],'DS_ALL_FORMSTATUS':['Dropdown_4_Copy'],'CloseDueDate':['CloseDueDate_Copy']},'TB_Title':{'name':'TB_Title','id':'TB_Title','label':{'Default':'Test'},'DSName':'','searchable':true,'reportable':true,'customizable-column':true,'type':'Textbox','uid':'720de02e-8fc7-407b-98ee-75e7eafdf267','autoGenerated':false,'hidden':false,'events':{'load':{'name':'onLoad','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'change':{'name':'onChange','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'focus':{'name':'onFocus','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'blur':{'name':'onBlur','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'enter':{'name':'onEnter','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'}},'style':{'labelStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'controlStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'group':{'background-color':'#ffffff','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000;','thymeleafControlStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000; white-space: pre-wrap;','thymeleafGroup':'background-color: #ffffff !important; background-color: #ffffff; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'ORI_VIEW','required':false,'readOnly':false,'placeHolder':'','charLimit':20,'tooltip':'','validate':'','digitSeparatorEnabled':false,'decimalPlaces':'0','decimalThousandSeparators':{'Default':{'displayCountry':'Default','displayLanguage':'Default','languageId':'Default','decimal':'.','thousand':','}},'wrapText':false,'value':''},'Repeating_Table':{'name':'Repeating_Table','id':'Repeating_Table','label':{'Default':'Repeating Table'},'DSName':'','searchable':false,'reportable':false,'customizable-column':false,'type':'RepeatingTable','uid':'998909f9-11ca-445c-9a17-22a2cb5a5b03','autoGenerated':false,'hidden':false,'events':{'load':{'name':'onLoad','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'}},'style':{'labelStyle':'','controlStyle':'','group':{'font-family':'initial','font-size':'16px','background-color':'#ffffff','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'black','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'','thymeleafControlStyle':' white-space: pre-wrap;','thymeleafGroup':'font-family: initial; font-size: 16px; background-color: #ffffff !important; background-color: #ffffff; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: black !important; color: black; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'ORI_VIEW','border':{'border-width':'1px','border-color':'#cccccc'},'thymeleafBorder':'border-width: 1px; border-color: #cccccc !important; border-color: #cccccc;','value':[{'Attachment_2':{'name':'Attachment_2','id':'Attachment_2','label':{'Default':'ORI Attachment'},'DSName':'','searchable':false,'reportable':false,'customizable-column':false,'type':'Attachment','uid':'a503ad04-c4f4-4899-8673-aa84c529344a','autoGenerated':false,'hidden':false,'events':{'load':{'name':'onLoad','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'change':{'name':'onChange','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'}},'style':{'labelStyle':'','controlStyle':'','group':{'font-family':'Helvetica','font-size':'18px','background-color':'#ffffff','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'','thymeleafControlStyle':' white-space: pre-wrap;','thymeleafGroup':'font-family: Helvetica; font-size: 18px; background-color: #ffffff !important; background-color: #ffffff; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'ORI_VIEW','value':'','required':false,'readOnly':false}}],'table_header':[{}],'table_footer':[{}]},'ORI_FORMTITLE':{'name':'ORI_FORMTITLE','id':'ORI_FORMTITLE','label':{'Default':'Title'},'DSName':'','searchable':true,'reportable':true,'customizable-column':true,'type':'Textbox','uid':'1adc4a5a-ab26-4fde-9529-049d14149d70','autoGenerated':false,'hidden':false,'events':{'load':{'name':'onLoad','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'change':{'name':'onChange','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'focus':{'name':'onFocus','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'blur':{'name':'onBlur','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'enter':{'name':'onEnter','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'}},'style':{'labelStyle':'','controlStyle':'','group':{'font-family':'Helvetica','font-size':'16px','background-color':'#ffffff','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'','thymeleafControlStyle':' white-space: pre-wrap;','thymeleafGroup':'font-family: Helvetica; font-size: 16px; background-color: #ffffff !important; background-color: #ffffff; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'ORI_VIEW','required':true,'readOnly':false,'placeHolder':'','charLimit':100,'tooltip':'','validate':'','digitSeparatorEnabled':false,'decimalPlaces':'0','decimalThousandSeparators':{'Default':{'displayCountry':'Default','displayLanguage':'Default','languageId':'Default','decimal':'.','thousand':','}},'wrapText':false,'value':''},'DS_ALL_FORMSTATUS':{'name':'DS_ALL_FORMSTATUS','id':'DS_ALL_FORMSTATUS','label':{'Default':'Form Status'},'DSName':'','searchable':true,'reportable':true,'customizable-column':true,'type':'Dropdown','uid':'dd70f9fb-6100-4406-8277-afa3305aa732','autoGenerated':false,'hidden':false,'events':{'load':{'name':'onLoad','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'change':{'name':'onChange','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'}},'style':{'labelStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'controlStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'group':{'background-color':'#ffffff','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000;','thymeleafControlStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000; white-space: pre-wrap;','thymeleafGroup':'background-color: #ffffff !important; background-color: #ffffff; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'ORI_VIEW','multiSelect':false,'required':false,'readOnly':false,'tooltip':'','DS':'DS_ALL_FORMSTATUS','options':[],'value':''},'CloseDueDate':{'name':'CloseDueDate','id':'CloseDueDate','label':{'Default':'Close Due Date'},'DSName':'','searchable':true,'reportable':true,'customizable-column':true,'type':'Datepicker','uid':'a5726261-64f8-4c9a-be7d-a4ed6f7a6c82','autoGenerated':false,'hidden':false,'events':{'load':{'name':'onLoad','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'change':{'name':'onChange','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'}},'style':{'labelStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'controlStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'group':{'background-color':'#ffffff','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000;','thymeleafControlStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000; white-space: pre-wrap;','thymeleafGroup':'background-color: #ffffff !important; background-color: #ffffff; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'ORI_VIEW','value':'','displayFormat':'default','time':false,'hourFormat':'false','required':false,'readOnly':false,'tooltip':''},'Datepicker_1':{'name':'Datepicker_1','id':'Datepicker_1','label':{'Default':'Datepicker'},'DSName':'','searchable':true,'reportable':true,'customizable-column':true,'type':'Datepicker','uid':'ec37dea6-b00d-4625-9dfd-bbeaf49da327','autoGenerated':false,'hidden':false,'events':{'load':{'name':'onLoad','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'change':{'name':'onChange','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'}},'style':{'labelStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'controlStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'group':{'background-color':'#ffffff','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000;','thymeleafControlStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000; white-space: pre-wrap;','thymeleafGroup':'background-color: #ffffff !important; background-color: #ffffff; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'ORI_VIEW','value':'CURRENT_DATE_0d','displayFormat':'default','time':false,'hourFormat':'false','required':false,'readOnly':false,'tooltip':''},'Repeating_Table_2':{'name':'Repeating_Table_2','id':'Repeating_Table_2','label':{'Default':'Repeating Table'},'DSName':'','searchable':false,'reportable':false,'customizable-column':false,'type':'RepeatingTable','uid':'b4326f33-d710-4327-b770-7e7b4b970b7b','autoGenerated':false,'hidden':false,'events':{'load':{'name':'onLoad','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'}},'style':{'labelStyle':'','controlStyle':'','group':{'font-family':'initial','font-size':'16px','background-color':'#ffffff','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'black','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'','thymeleafControlStyle':' white-space: pre-wrap;','thymeleafGroup':'font-family: initial; font-size: 16px; background-color: #ffffff !important; background-color: #ffffff; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: black !important; color: black; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'ORI_VIEW','border':{'border-width':'1px','border-color':'#cccccc'},'thymeleafBorder':'border-width: 1px; border-color: #cccccc !important; border-color: #cccccc;','value':[{}],'table_header':[{}],'table_footer':[{}]},'Textbox_1':{'name':'Textbox_1','id':'Textbox_1','label':{'Default':'Textbox'},'DSName':'','searchable':true,'reportable':true,'customizable-column':true,'type':'Textbox','uid':'21d157a1-26d6-4789-8767-d0689b0b30e9','autoGenerated':false,'hidden':false,'events':{'load':{'name':'onLoad','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'change':{'name':'onChange','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'focus':{'name':'onFocus','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'blur':{'name':'onBlur','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'enter':{'name':'onEnter','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'}},'style':{'labelStyle':{'font-family':'Helvetica','font-size':'14px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'controlStyle':{'font-family':'Helvetica','font-size':'14px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'group':{'background-color':'#ffffff','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'font-family: Helvetica; font-size: 14px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000;','thymeleafControlStyle':'font-family: Helvetica; font-size: 14px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000; white-space: pre-wrap;','thymeleafGroup':'background-color: #ffffff !important; background-color: #ffffff; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'ORI_VIEW','required':false,'readOnly':false,'placeHolder':'','charLimit':20,'tooltip':'','validate':'','digitSeparatorEnabled':false,'decimalPlaces':'0','decimalThousandSeparators':{'Default':{'displayCountry':'Default','displayLanguage':'Default','languageId':'Default','decimal':'.','thousand':','}},'wrapText':false,'value':''},'MultiDropdown':{'name':'MultiDropdown','id':'MultiDropdown','label':{'Default':'Multiselect Dropdown'},'DSName':'','searchable':true,'reportable':true,'customizable-column':true,'type':'MultiDropdown','uid':'8458b451-a27c-41bc-ae09-58ce5e1c88e1','autoGenerated':false,'hidden':false,'events':{'load':{'name':'onLoad','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'change':{'name':'onChange','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'}},'style':{'labelStyle':{'font-family':'Helvetica','font-size':'14px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'controlStyle':{'font-family':'Helvetica','font-size':'14px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'group':{'background-color':'#ffffff','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'font-family: Helvetica; font-size: 14px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000;','thymeleafControlStyle':'font-family: Helvetica; font-size: 14px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000; white-space: pre-wrap;','thymeleafGroup':'background-color: #ffffff !important; background-color: #ffffff; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'ORI_VIEW','required':false,'readOnly':false,'tooltip':'','options':[{'name':'Option 1','value':'option1','id':1},{'name':'Option 2','value':'option2','id':2}],'filter':[],'resetControls':[],'value':''},'Attachment_5':{'name':'Attachment_5','id':'Attachment_5','label':{'Default':'Attachment'},'DSName':'','searchable':false,'reportable':false,'customizable-column':false,'type':'Attachment','uid':'fddcdeeb-adc2-49e8-affe-a8e2d4eede4f','autoGenerated':false,'hidden':false,'events':{'load':{'name':'onLoad','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'change':{'name':'onChange','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'}},'style':{'labelStyle':'','controlStyle':'','group':{'font-family':'Helvetica','font-size':'18px','background-color':'#ffffff','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'','thymeleafControlStyle':' white-space: pre-wrap;','thymeleafGroup':'font-family: Helvetica; font-size: 18px; background-color: #ffffff !important; background-color: #ffffff; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'RES_VIEW','value':'','required':false,'readOnly':false},'reply':{'name':'reply','id':'reply','label':{'Default':'Reply'},'DSName':'','searchable':true,'reportable':true,'customizable-column':true,'type':'Text-Area','uid':'07ca8fb8-eff5-4b65-998d-3957f7757de2','autoGenerated':false,'hidden':false,'events':{'load':{'name':'onLoad','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'change':{'name':'onChange','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'focus':{'name':'onFocus','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'blur':{'name':'onBlur','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'},'enter':{'name':'onEnter','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog'}},'style':{'labelStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'controlStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'group':{'background-color':'#ffffff','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000;','thymeleafControlStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000; white-space: pre-wrap;','thymeleafGroup':'background-color: #ffffff !important; background-color: #ffffff; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'RES_VIEW','required':false,'readOnly':false,'placeHolder':'','tooltip':'','validate':'','digitSeparatorEnabled':false,'decimalPlaces':'0','decimalThousandSeparators':{'Default':{'displayCountry':'Default','displayLanguage':'Default','languageId':'Default','decimal':'.','thousand':','}},'size':3,'value':''},'ORI_FORMTITLE_Copy':{'name':'ORI_FORMTITLE_Copy','id':'ORI_FORMTITLE_Copy','label':{'Default':'Title'},'DSName':'ORI_FORMTITLE','searchable':false,'reportable':false,'customizable-column':false,'type':'Display field','uid':'3df8acfc-b9e6-413e-87bb-676d2eb6c891','autoGenerated':true,'hidden':false,'events':{},'style':{'labelStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'controlStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'group':{'background-color':'#ffffff','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000;','thymeleafControlStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000; white-space: pre-wrap;','thymeleafGroup':'background-color: #ffffff !important; background-color: #ffffff; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'ORI_PRINT_VIEW','value':'','isCalculation':'ORI_FORMTITLE','calculatedValue':'','conditions':''},'TB_Title_Copy':{'name':'TB_Title_Copy','id':'TB_Title_Copy','label':{'Default':'Test'},'DSName':'TB_Title','searchable':false,'reportable':false,'customizable-column':false,'type':'Display field','uid':'ad5da897-4bac-48e0-9506-5bb5a8b1517d','autoGenerated':true,'hidden':false,'events':{},'style':{'labelStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'controlStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'group':{'background-color':'#ffffff','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000;','thymeleafControlStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000; white-space: pre-wrap;','thymeleafGroup':'background-color: #ffffff !important; background-color: #ffffff; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'ORI_PRINT_VIEW','value':'','isCalculation':'TB_Title','calculatedValue':'','conditions':''},'Repeating_Table_Copy':{'name':'Repeating_Table_Copy','id':'Repeating_Table_Copy','label':{'Default':'Repeating Table'},'DSName':'Repeating_Table','searchable':false,'reportable':false,'customizable-column':false,'type':'RepeatingTable','uid':'998909f9-11ca-445c-9a17-22a2cb5a5b03','autoGenerated':false,'hidden':false,'events':{'load':{'name':'onLoad','type':'event','selectedValue':'','xmlValue':'','systemFields':[],'onClickFunction':'openCodeEditorDialog','disable':true}},'style':{'labelStyle':'','controlStyle':'','group':{'font-family':'initial','font-size':'16px','background-color':'#ffffff','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'black','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'','thymeleafControlStyle':' white-space: pre-wrap;','thymeleafGroup':'font-family: initial; font-size: 16px; background-color: #ffffff !important; background-color: #ffffff; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: black !important; color: black; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'ORI_PRINT_VIEW','border':{'border-width':'1px','border-color':'#cccccc'},'thymeleafBorder':'border-width: 1px; border-color: #cccccc !important; border-color: #cccccc;','value':[{}],'table_header':[{}],'table_footer':[{}]},'Dropdown_4_Copy':{'name':'Dropdown_4_Copy','id':'Dropdown_4_Copy','label':{'Default':'Form Status'},'DSName':'DS_ALL_FORMSTATUS','searchable':false,'reportable':false,'customizable-column':false,'type':'Display field','uid':'fb4348c7-1efc-4d20-8f4d-0b6692e432fb','autoGenerated':true,'hidden':false,'events':{},'style':{'labelStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'controlStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'group':{'background-color':'#ffffff','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000;','thymeleafControlStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000; white-space: pre-wrap;','thymeleafGroup':'background-color: #ffffff !important; background-color: #ffffff; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'ORI_PRINT_VIEW','DS':'DS_ALL_FORMSTATUS','value':'','isCalculation':'DS_ALL_FORMSTATUS','calculatedValue':'','conditions':''},'CloseDueDate_Copy':{'name':'CloseDueDate_Copy','id':'CloseDueDate_Copy','label':{'Default':'Close Due Date'},'DSName':'CloseDueDate','searchable':false,'reportable':false,'customizable-column':false,'type':'Display field','uid':'d73fda3a-8a0c-4a3a-9967-25c5d1fe113a','autoGenerated':true,'hidden':false,'events':{},'style':{'labelStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'controlStyle':{'font-family':'Helvetica','font-size':'16px','font-weight':'normal','font-style':'normal','text-decoration':'none','text-align-last':'left','text-align':'left','color':'#000000'},'group':{'background-color':'#ffffff','padding-top':'5px','padding-bottom':'5px','padding-left':'5px','padding-right':'5px'},'thymeleafLabelStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000;','thymeleafControlStyle':'font-family: Helvetica; font-size: 16px; font-weight: normal; font-style: normal; text-decoration: none; text-align-last: left; text-align: left; color: #000000 !important; color: #000000; white-space: pre-wrap;','thymeleafGroup':'background-color: #ffffff !important; background-color: #ffffff; padding-top: 5px; padding-bottom: 5px; padding-left: 5px; padding-right: 5px;'},'viewName':'ORI_PRINT_VIEW','value':'','isCalculation':'CloseDueDate','calculatedValue':'','conditions':''}}\",\"bfpc\":\"0\",\"had\":\"0\",\"isFromMarketplace\":false,\"isMarkDefault\":false,\"isNewlyCreated\":false,\"isAsycnProcess\":false},\"actionList\":[{\"is_default\":false,\"is_associated\":false,\"actionName\":\"Assign Status\",\"actionID\":\"2\",\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":false,\"actionName\":\"Attach Docs\",\"actionID\":\"5\",\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Distribute\",\"actionID\":\"6\",\"num_days\":4,\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Acknowledgement\",\"actionID\":\"37\",\"num_days\":4,\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Action\",\"actionID\":\"36\",\"num_days\":3,\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":true,\"is_associated\":true,\"actionName\":\"For Information\",\"actionID\":\"7\",\"num_days\":3,\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":false,\"actionName\":\"Respond\",\"actionID\":\"3\",\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Review Draft\",\"actionID\":\"34\",\"num_days\":4,\"projectId\":\"0\",\"userId\":0,\"revisionId\":\"0\",\"formId\":\"0\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\",\"docId\":\"0\",\"generateURI\":true}],\"formTypeGroupVO\":{\"formTypeGroupID\":399,\"formTypeGroupName\":\"Asite_Standard_Appbuilder_Template_Group\",\"generateURI\":true},\"statusList\":[{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Approve\",\"statusID\":1004,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed\",\"statusID\":3,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":true,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved\",\"statusID\":4,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved with Comments\",\"statusID\":5,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Rejected\",\"statusID\":6,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Open\",\"statusID\":1001,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Resolved\",\"statusID\":1002,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Verified\",\"statusID\":1003,\"orgId\":\"0\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true}],\"isFormInherited\":false,\"generateURI\":true},\"createdFormsCount\":31,\"draftFormsCount\":20,\"templatetype\":2,\"appId\":1,\"formTypeName\":\"Inline attachment\",\"totalForms\":31,\"formtypeGroupid\":399,\"isFavourite\":false,\"appBuilderID\":\"INL\",\"canViewDraftMsg\":false,\"formTypeGroupName\":\"INL\",\"formGroupCode\":\"INL\",\"canCreateForm\":true,\"numActions\":2,\"crossWorkspaceID\":-1,\"instanceGroupId\":10583899,\"allow_associate_location\":true,\"numOverdueActions\":2,\"is_location_assoc_mandatory\":false,\"workspaceid\":2116416}","AllowLocationAssociation":1,"CanCreateForms":1,"AppTypeId":"1"}]);
      String locationQuery = "SELECT * FROM LocationDetailTbl\nWHERE ProjectId=2116416 AND LocationId=183895";
      when(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, locationQuery)).thenReturn([{"ProjectId":"2116416","FolderId":"115335290","LocationId":183895,"LocationTitle":"Kitchen","ParentFolderId":115335289,"ParentLocationId":183894,"PermissionValue":0,"LocationPath":"!!PIN_ANY_APP_TYPE_20_9\\00-Zone-0\\Floor-1\\Kitchen","SiteId":0,"DocumentId":"13403720","RevisionId":"26852532","AnnotationId":"f40518dc-f13c-fc3e-3811-86a0b0c9de6a","LocationCoordinate":"{\"x1\":259.42,\"y1\":635.48,\"x2\":393.12,\"y2\":551.11}","PageNumber":1,"IsPublic":0,"IsFavorite":0,"IsSite":0,"IsCalibrated":1,"IsFileUploaded":0,"IsActive":1,"HasSubFolder":0,"CanRemoveOffline":0,"IsMarkOffline":1,"SyncStatus":1,"LastSyncTimeStamp":""}]);
      when(() => mockFileUtility.getFileNameWithoutExtention(any())).thenReturn("test");

      String formVOFromDBQuery = "WITH OfflineSyncData AS (SELECT ";
      formVOFromDBQuery = "$formVOFromDBQuery CASE frmMsgTbl.OfflineRequestData WHEN 2 THEN 5 ELSE 1 END AS Type, frmTypeTbl.AppTypeId, frmMsgTbl.ProjectId, frmMsgTbl.FormTypeId, frmTypeTbl.InstanceGroupId, frmTypeTbl.TemplateTypeId, frmMsgTbl.FormId, frmMsgTbl.MsgId, frmMsgTbl.MsgTypeId, frmMsgTbl.OfflineRequestData, frmMsgTbl.UpdatedDateInMS, frmMsgTbl.IsDraft, frmMsgTbl.DelFormIds";
      formVOFromDBQuery = "$formVOFromDBQuery FROM FormMessageListTbl frmMsgTbl";
      formVOFromDBQuery = "$formVOFromDBQuery INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId";
      formVOFromDBQuery = "$formVOFromDBQuery INNER JOIN FormGroupAndFormTypeListTbl frmTypeTbl ON frmTypeTbl.ProjectId=frmMsgTbl.ProjectId AND frmTypeTbl.FormTypeId=frmMsgTbl.FormTypeId";
      formVOFromDBQuery = "$formVOFromDBQuery WHERE frmMsgTbl.OfflineRequestData<>''";
      formVOFromDBQuery = "$formVOFromDBQuery AND ((frmTypeTbl.TemplateTypeId=1 AND frmMsgTbl.IsDraft<>1) OR frmTypeTbl.TemplateTypeId<>1))";
      formVOFromDBQuery = "$formVOFromDBQuery SELECT IFNULL(fldSycDataView.OfflineRequestData,'') AS NewOfflineRequestData,frmTbl.* FROM FormListTbl frmTbl";
      formVOFromDBQuery = "$formVOFromDBQuery LEFT JOIN OfflineSyncData  fldSycDataView ON frmTbl.ProjectId=fldSycDataView.ProjectId AND frmTbl.FormId=fldSycDataView.FormId";
      formVOFromDBQuery = "$formVOFromDBQuery AND fldSycDataView.Type IN (1,2,5)";
      formVOFromDBQuery = "$formVOFromDBQuery WHERE frmTbl.ProjectId=2116416 ";
      formVOFromDBQuery = "$formVOFromDBQuery AND frmTbl.FormId=1691572633656";
      var data1 = [{"NewOfflineRequestData":[],"ProjectId":"2116416","FormId":"1691572633656","msgId":"1691478133747","AppTypeId":2,"FormTypeId":"10641209","InstanceGroupId":"10381138","FormTitle":"TA-0407-Attachment","Code":"DEF2278","CommentId":"11608838","MessageId":"12311326","ParentMessageId":0,"OrgId":"5763307","FirstName":"Mayur","LastName":"Raval m.","OrgName":"Asite Solutions Ltd","Originator":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur","OriginatorDisplayName":" Mayur Raval m., Asite Solutions Ltd","NoOfActions":0,"ObservationId":107285,"LocationId":183904,"PfLocFolderId":115335312,"Updated":"19-Jul-2023#23:56 CST","AttachmentImageName":"","MsgCode":"ORI001","TypeImage":"icons/form.png","DocType":"Apps","HasAttachments":0,"HasDocAssocations":0,"HasBimViewAssociations":0,"HasFormAssocations":0,"HasCommentAssocations":0,"FormHasAssocAttach":0,"FormCreationDate":"19-Jul-2023#23:56 CST","FolderId":0,"MsgTypeId":1,"MsgStatusId":20,"FormNumber":2278,"MsgOriginatorId":2017529,"TemplateType":2,"IsDraft":0,"StatusId":1001,"OriginatorId":2017529,"IsStatusChangeRestricted":0,"AllowReopenForm":0,"CanOrigChangeStatus":0,"MsgTypeCode":"ORI","Id":"","StatusChangeUserId":0,"StatusUpdateDate":"19-Jul-2023#23:56 CST","StatusChangeUserName":" Mayur Raval m.","StatusChangeUserPic":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur","StatusChangeUserEmail":"m.raval@asite.com","StatusChangeUserOrg":"Asite Solutions Ltd","OriginatorEmail":"m.raval@asite.com","ControllerUserId":0,"UpdatedDateInMS":1689828977000,"FormCreationDateInMS":1689828977000,"ResponseRequestByInMS":1690952399000,"FlagType":0,"LatestDraftId":0,"FlagTypeImageName":"flag_type/flag_0.png","MessageTypeImageName":"icons/form.png","CanAccessHistory":1,"FormJsonData":"","Status":"Open","AttachedDocs":"0","IsUploadAttachmentInTemp":0,"IsSync":0,"UserRefCode":"","HasActions":0,"CanRemoveOffline":0,"IsMarkOffline":0,"IsOfflineCreated":0,"SyncStatus":1,"IsForDefect":0,"IsForApps":0,"ObservationDefectTypeId":"218898","StartDate":"2023-07-20","ExpectedFinishDate":"2023-08-01","IsActive":1,"ObservationCoordinates":'{"x1":360.001440304004,"y1":134.31719617472731,"x2":370.001440304004,"y2":144.31719617472731}',"AnnotationId":"08C66C6A-1478-4A97-BB40-E938BCB6F81B-1689828968","IsCloseOut":0,"AssignedToUserId":1079650,"AssignedToUserName":"","AssignedToUserOrgName":"Asite Solutions","MsgNum":0,"RevisionId":"","RequestJsonForOffline":"","FormDueDays":12,"FormSyncDate":"2023-07-20 05:56:17.27","LastResponderForAssignedTo":"1079650","LastResponderForOriginator":"2017529","PageNumber":1,"ObservationDefectType":"0","StatusName":"Open","AppBuilderId":"SNG-DEF","TaskTypeName":"","AssignedToRoleName":""}];
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, formVOFromDBQuery)).thenReturn(data1);
      String formMsgQuery = "SELECT * FROM FormMessageListTbl WHERE ProjectId=2116416 AND FormId=1691572633656 AND MsgTypeId=1";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMsgQuery)).thenReturn([]);
      String formMessageVOFromDBQuery = "SELECT * FROM FormMessageListTbl\n"
          "WHERE ProjectId=2116416 AND FormId=1691572633656 AND MsgId=1691478133747";
      var formMessageJson = fixture('form_message_db.json');
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMessageVOFromDBQuery)).thenReturn([jsonDecode(formMessageJson)]);
      String formAttachmentQuery = "SELECT * FROM FormMsgAttachAndAssocListTbl WHERE ProjectId=2116416 AND FormId=1691572633656 AND MsgId<>12309970";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, formAttachmentQuery)).thenReturn([]);
      String updateFormMsgAttachAndAssocQuery = "SELECT * FROM FormMsgAttachAndAssocListTbl WHERE ProjectId=2116416 AND FormId=1691572633656 AND AttachmentType=3 AND AttachRevId IN (1690365038319370)";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, updateFormMsgAttachAndAssocQuery)).thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":1691478133747,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);
      removeFormMsgAttachAndAssocDataMock();
      Map saveResponse = await createFormLocalDataSource.saveFormOffline(saveFormParam);
      expect(saveResponse.isNotEmpty, true);
      expect(saveResponse.containsKey('formId'), true);
      expect(saveResponse.containsKey('msgId'), true);
      expect(saveResponse.containsKey('locationId'), true);
    });

  });

  group("Testing Offline -Create Form", () {
    test("Testing Offline - Create Html Response is not Empty", () async {
      var htmlFile = fixtureFileContent('files/2130192/FormTypes/11103151/ORI_VIEW.html');
      when(() => mockFileUtility.readFromFile("./test/fixtures/files/2130192/FormTypes/11103151/ORI_VIEW.html")).thenReturn(htmlFile);

      var jsonData = fixtureFileContent('files/2130192/FormTypes/11103151/data.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/files/2130192/FormTypes/11103151/data.json")).thenReturn(jsonData);


      var customAttributeData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/CustomAttributeData.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/CustomAttributeData.json")).thenReturn(customAttributeData);

      var fieldJsonData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/Fix-FieldData.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/Fix-FieldData.json")).thenReturn(fieldJsonData);

      var offlineCreateFormContent = fixtureFileContent('database/HTML5Form/offlineCreateForm.html');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/HTML5Form/offlineCreateForm.html")).thenReturn(offlineCreateFormContent);

      String isDraftQuery = "SELECT MsgStatusId FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652\n"
          "AND MsgTypeId=1 AND (MsgStatusId=19 OR OfflineRequestData<>'')";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, isDraftQuery)).thenReturn([]);

      String isDraftResMsgQuery = "SELECT MsgStatusId FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652 AND MsgId=123\n"
          "AND MsgTypeId=2 AND (MsgStatusId=19 OR OfflineRequestData<>'')";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, isDraftResMsgQuery)).thenReturn([]);

      String dsFormNameQuery = "SELECT FormTypeName FROM FormGroupAndFormTypeListTbl\n"
          "WHERE ProjectId=2130192 AND FormTypeId=11103151";
      when(() => mockDatabaseManager.executeSelectFromTable(FormTypeDao.tableName, dsFormNameQuery)).thenReturn([
        {"FormTypeName": "demo"}
      ]);

      String dsFormGroupCodeQuery = "SELECT FormTypeGroupCode FROM FormGroupAndFormTypeListTbl\n"
          "WHERE ProjectId=2130192 AND FormTypeId=11103151";
      when(() => mockDatabaseManager.executeSelectFromTable(FormTypeDao.tableName, dsFormGroupCodeQuery)).thenReturn([
        {"FormTypeGroupCode": "code"}
      ]);

      String dsFormGroupCODQuery = "SELECT CASE WHEN INSTR(frmTbl.Code,'(')>0 THEN SUBSTR(frmTbl.Code,0,INSTR(frmTbl.Code,'(')) WHEN LOWER(frmTbl.Code)='draft' OR frmTbl.IsDraft=1 THEN frmTpView.FormTypeGroupCode || '000' ELSE frmTbl.Code END AS DS_FORMID FROM FormListTbl frmTbl\n"
          "INNER JOIN FormGroupAndFormTypeListTbl frmTpView ON frmTpView.ProjectId=frmTbl.ProjectId AND frmTpView.FormTypeId=frmTbl.FormTypeId\n"
          "WHERE frmTbl.ProjectId=2130192 AND frmTbl.FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, dsFormGroupCODQuery)).thenReturn([]);

      String dsCloseDueDateQuery = "SELECT JsonData FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652\n"
          "AND MsgId=123";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, dsCloseDueDateQuery)).thenReturn([]);

      String oriFormTitleQuery = "SELECT FormTitle FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, oriFormTitleQuery)).thenReturn([
        {"FormTitle": "Test Form"}
      ]);

      String oriUserREFQuery = "SELECT UserRefCode FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, oriUserREFQuery)).thenReturn([
        {"UserRefCode": "ORI001"}
      ]);

      String allLocationByProjectPFQuery = "SELECT prjTbl.ProjectName, locTbl.* FROM LocationDetailTbl locTbl\n"
          "INNER JOIN ProjectDetailTbl prjTbl ON prjTbl.ProjectId=locTbl.ProjectId\n"
          "WHERE locTbl.IsActive=1 AND locTbl.IsMarkOffline=1 AND locTbl.ProjectId=2130192\n"
          "ORDER BY locTbl.LocationPath COLLATE NOCASE";
      when(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, allLocationByProjectPFQuery)).thenReturn([
        {"ProjectName": "demo"}
      ]);

      String dsFormStatusQuery = "SELECT Status FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, dsFormStatusQuery)).thenReturn([]);

      String dsIncompleteActionsQuery = "SELECT * FROM FormMsgActionListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652\n"
          "AND ActionStatus=0 AND RecipientUserId=808581";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageActionDao.tableName, dsIncompleteActionsQuery)).thenReturn([]);

      String recentDefectQuery = "SELECT frmTbl.ProjectId,frmTbl.FormId,frmTbl.Code,frmTpTbl.FormTypeGroupCode,frmTbl.FormTitle,frmTbl.ObservationDefectType,frmTbl.LocationId,locTbl.LocationTitle,locTbl.LocationPath,frmMsgTbl.JsonData FROM FormListTbl frmTbl\n"
          "INNER JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=frmTbl.ProjectId AND frmTpTbl.FormTypeId=frmTbl.FormTypeId\n"
          "INNER JOIN LocationDetailTbl locTbl ON locTbl.ProjectId=frmTbl.ProjectId AND locTbl.LocationId=frmTbl.LocationId\n"
          "INNER JOIN FormMessageListTbl frmMsgTbl ON frmMsgTbl.ProjectId=frmTbl.ProjectId AND frmMsgTbl.FormId=frmTbl.FormId AND frmMsgTbl.MsgTypeId=1 AND frmMsgTbl.IsDraft=0\n"
          "WHERE frmTbl.ProjectId=2130192 AND frmTbl.OriginatorId=808581 AND frmTpTbl.InstanceGroupId=\n"
          "(SELECT InstanceGroupId FROM FormGroupAndFormTypeListTbl WHERE ProjectId=2130192 AND FormTypeId=11103151)\n"
          "ORDER BY frmTbl.FormCreationDateInMS DESC\n"
          "LIMIT 5 OFFSET 0";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, recentDefectQuery)).thenReturn([
        {
          "ProjectId": "2116416",
          "ProjectName": "!!PIN_ANY_APP_TYPE_20_9",
          "DcId": 1,
          "FormTypeId": "10616643",
          "JsonData":
              "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"DistributionDays\":\"0\",\"Organization\":\"\",\"DefectTyoe\":\"Computer\",\"ExpectedFinishDate\":\"2023-08-08\",\"DefectDescription\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"707447#Vijay Mavadiya (5336), Asite Solutions\"}},\"Defect_Description\":\"test description\",\"LocationName\":\"01 Vijay_Test\",\"StartDate\":\"2023-08-01\",\"ActualFinishDate\":\"\",\"ExpectedFinishDays\":\"5\",\"DS_Logo\":\"images/asite.gif\",\"LastResponder_For_AssignedTo\":\"707447\",\"TaskType\":\"Defect\",\"isCalibrated\":false,\"ORI_FORMTITLE\":\"Test Offlinr VJ Attachment\",\"attachements\":[{\"attachedDocs\":\"\"}],\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"Assigned\":\"Vijay Mavadiya (5336), Asite Solutions\",\"CurrStage\":\"1\",\"Recent_Defects\":\"\",\"FormCreationDate\":\"\",\"StartDateDisplay\":\"01-Aug-2023\",\"LastResponder_For_Originator\":\"2017529\",\"PF_Location_Detail\":\"183678|0|null|0\",\"Username\":\"\",\"ORI_USERREF\":\"\",\"Location\":\"183678|01 Vijay_Test|01 Vijay_Test\"},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"SHResponse\":\"Yes\",\"ShowHideFlag\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_CREATE\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\",\"DS_FORMAUTONO_ADD\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_Get_All_Responses\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"attachments\":[],\"Asite_System_Data_Read_Only\":{\"_2_Printing_Data\":{\"DS_PRINTEDON\":\"\",\"DS_PRINTEDBY\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\",\"DS_FORMNAME\":\"Site Tasks\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"\",\"DS_CLIENT\":\"\"},\"_5_Form_Data\":{\"DS_DATEOFISSUE\":\"\",\"DS_ISDRAFT_RES_MSG\":\"\",\"Status_Data\":{\"DS_APPROVEDON\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_APPROVEDBY\":\"\",\"DS_CLOSE_DUE_DATE\":\"2023-08-08\",\"DS_FORMSTATUS\":\"\"},\"DS_DISTRIBUTION\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT_RES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_FORMID\":\"\"},\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_6_Form_MSG_Data\":{\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGID\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_PROJUSERS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_ACTIONDUEDATE\":\"5\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_PROJDISTUSERS\":\"707447\"}]}},\"selectedControllerUserId\":\"\"}}",
          "FormTypeName": "Inline attachment",
          "FormGroupCode": "INL",
          "AppBuilderId": "INL",
          "TemplateTypeId": 2,
          "AppTypeId": 1
        }
      ]);

      String mapOfConfigListQuery = "SELECT prjTbl.ProjectId,prjTbl.ProjectName,prjTbl.DcId AS DcId,frmTpTbl.FormTypeId,frmTpTbl.FormTypeDetailJson,frmTpTbl.FormTypeName,frmTpTbl.FormTypeGroupCode AS FormGroupCode,frmTpTbl.AppBuilderId,frmTpTbl.TemplateTypeId,frmTpTbl.AppTypeId FROM ProjectDetailTbl prjTbl";
      mapOfConfigListQuery = "$mapOfConfigListQuery INNER JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=prjTbl.ProjectId";
      mapOfConfigListQuery = "$mapOfConfigListQuery WHERE frmTpTbl.ProjectId=2130192 AND frmTpTbl.FormTypeId=11103151";
      when(() => mockDatabaseManager.executeSelectFromTable(ProjectDao.tableName, mapOfConfigListQuery)).thenReturn([
        {
          "ProjectId": "2116416",
          "ProjectName": "!!PIN_ANY_APP_TYPE_20_9",
          "DcId": 1,
          "FormTypeId": "10616643",
          "FormTypeDetailJson":
              "{\"createFormsLimit\":0,\"canAccessPrivilegedForms\":true,\"formTypeID\":\"10381414\$\$9IBwDZ\",\"allow_attachments\":true,\"formTypesDetail\":{\"formTypeVO\":{\"formTypeID\":\"10381414\$\$9IBwDZ\",\"formTypeName\":\"Fields\",\"code\":\"FID\",\"use_controller\":false,\"response_allowed\":true,\"show_responses\":true,\"allow_reopening_form\":true,\"default_action\":\"3\$\$CPl6Fg\",\"is_default\":true,\"allow_forwarding\":false,\"allow_distribution_after_creation\":true,\"allow_distribution_originator\":true,\"allow_distribution_recipients\":false,\"allow_forward_originator\":false,\"allow_forward_recipients\":false,\"responders_collaborate\":false,\"continue_discussion\":false,\"hide_orgs_and_users\":false,\"has_hyperlink\":false,\"allow_attachments\":true,\"allow_doc_associates\":true,\"allow_form_associations\":true,\"allow_attributes\":false,\"associations_extend_doc_issue\":false,\"public_message\":false,\"browsable_attachment_folder\":false,\"has_overall_status\":true,\"is_instance\":true,\"form_type_group_id\":341,\"instance_group_id\":\"10381414\$\$9IBwDZ\",\"ctrl_change_status\":false,\"parent_formtype_id\":\"2171706\$\$6zD4x9\",\"orig_change_status\":true,\"orig_can_close\":false,\"upload_logo\":false,\"user_ref\":false,\"allow_comment_associations\":false,\"is_public\":true,\"is_active\":true,\"signatureBox\":\"000\",\"xsnFile\":\"2181422.xsn\$\$guzLhn\",\"xmlData\":\"<?mso-infoPathSolution name=\\\"urn:schemas-microsoft-com:office:infopath:ASI-Request-For-Information-Mobile-View:-myXSD-2008-07-03T04-59-35\\\" href=\\\"ASI_Request_For_Information_Mobile_View_tImEsTaMp516083820727589_516447\\\" solutionVersion=\\\"1.0.0.196\\\" productVersion=\\\"12.0.0\\\" PIVersion=\\\"1.0.0.0\\\" ?><?mso-application progid=\\\"InfoPath.Document\\\"?><my:myFields xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\" xmlns:xhtml=\\\"http://www.w3.org/1999/xhtml\\\" xmlns:my=\\\"http://schemas.microsoft.com/office/infopath/2003/myXSD/2008-07-03T04:59:35\\\" xmlns:xd=\\\"http://schemas.microsoft.com/office/infopath/2003\\\"><my:ORI_FORMTITLE/><my:FORM_CUSTOM_FIELDS><my:ORI_MSG_Custom_Fields><my:Description/></my:ORI_MSG_Custom_Fields><my:RES_MSG_Custom_Fields><my:Response/></my:RES_MSG_Custom_Fields></my:FORM_CUSTOM_FIELDS><my:Asite_System_Data_Read_Only><my:_1_User_Data><my:DS_WORKINGUSER/><my:DS_WORKINGUSERROLE/></my:_1_User_Data><my:_2_Printing_Data><my:DS_PRINTEDBY/><my:DS_PRINTEDON/></my:_2_Printing_Data><my:_3_Project_Data><my:DS_PROJECTNAME/><my:DS_CLIENTDS_CLIENT/></my:_3_Project_Data><my:_4_Form_Type_Data><my:DS_FORMNAME/><my:DS_FORMGROUPCODE/></my:_4_Form_Type_Data><my:_5_Form_Data><my:DS_FORMID/><my:DS_ORIGINATOR/><my:DS_DATEOFISSUE/><my:DS_DISTRIBUTION/><my:DS_CONTROLLERNAME/><my:DS_ATTRIBUTES/><my:Status_Data><my:DS_FORMSTATUS/><my:DS_CLOSEDUEDATE/><my:DS_APPROVEDBY/><my:DS_APPROVEDON/><my:DS_ALL_FORMSTATUS>Open</my:DS_ALL_FORMSTATUS></my:Status_Data><my:DS_CLOSE_DUE_DATE/></my:_5_Form_Data><my:_6_Form_MSG_Data><my:DS_MSGID/><my:DS_MSGCREATOR/><my:DS_MSGDATE/><my:DS_MSGSTATUS/><my:DS_MSGRELEASEDATE/><my:ORI_MSG_Data><my:DS_DOC_ASSOCIATIONS_ORI/><my:DS_FORM_ASSOCIATIONS_ORI/><my:DS_ATTACHMENTS_ORI/></my:ORI_MSG_Data></my:_6_Form_MSG_Data></my:Asite_System_Data_Read_Only><my:Asite_System_Data_Read_Write><my:ORI_MSG_Fields><my:ORI_USERREF/><my:DS_AUTODISTRIBUTE>2</my:DS_AUTODISTRIBUTE><my:DS_ACTIONDUEDATE>3</my:DS_ACTIONDUEDATE><my:DS_FORMACTIONS>3 # Respond</my:DS_FORMACTIONS><my:DS_PROJDISTUSERS/></my:ORI_MSG_Fields></my:Asite_System_Data_Read_Write><my:Assign_To/></my:myFields>\",\"templateType\":1,\"responsePattern\":0,\"fixedFieldIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"displayFileName\":\"ASI_Request_For_Information_Mobile_View.xsn\$\$z08kl4\",\"viewIds\":\"2,6,4,3,8,10,7,9,5,1,\",\"mandatoryDistribution\":0,\"responseFromAll\":false,\"subTemplateType\":0,\"integrateExchange\":false,\"allowEditingORI\":false,\"allowImportExcelInEditORI\":false,\"isOverwriteExcelInEditORI\":true,\"enableECatalague\":false,\"formGroupName\":\"Fields\",\"projectId\":\"2116416\$\$s2Ieys\",\"clonedFormTypeId\":0,\"appBuilderFormIDCode\":\"\",\"loginUserId\":2017529,\"xslFileName\":\"\",\"allowImportForm\":false,\"allowWorkspaceLink\":false,\"linkedWorkspaceProjectId\":\"-1\$\$BUrsqP\",\"createFormsLimit\":0,\"spellCheckPrefs\":\"10\",\"isMobile\":false,\"createFormsLimitLevel\":0,\"restrictChangeFormStatus\":0,\"enableDraftResponses\":0,\"isDistributionFromGroupOnly\":true,\"isAutoCreateOnStatusChange\":false,\"docAssociationType\":1,\"viewFieldIdsData\":\"<root><views><viewid>2</viewid><view_name>ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>6</viewid><view_name>MB_ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>4</viewid><view_name>RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>5</viewid><view_name>FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>3</viewid><view_name>RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>8</viewid><view_name>MB_RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>1</viewid><view_name>ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>7</viewid><view_name>MB_ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>9</viewid><view_name>MB_RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>10</viewid><view_name>MB_FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views></root>\",\"createdMsgCount\":0,\"draft_count\":0,\"draftMsgId\":0,\"view_always_form_association\":false,\"view_always_doc_association\":false,\"auto_publish_to_folder\":false,\"default_folder_path\":\"\",\"default_folder_id\":\"\$\$YDWWpv\",\"allowExternalAccess\":0,\"embedFormContentInEmail\":0,\"canReplyViaEmail\":0,\"externalUsersOnly\":0,\"appTypeId\":2,\"dataCenterId\":0,\"allowViewAssociation\":0,\"infojetServerVersion\":1,\"isFormAvailableOffline\":0,\"allowDistributionByAll\":false,\"allowDistributionByRoles\":false,\"allowDistributionRoleIds\":\"\",\"canEditWithAppbuilder\":false,\"hasAppbuilderTemplateDraft\":false,\"isTemplateChanged\":false,\"viewsList\":[{\"viewId\":1,\"viewName\":\"ORI_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":2,\"viewName\":\"ORI_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":3,\"viewName\":\"RES_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":4,\"viewName\":\"RES_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":5,\"viewName\":\"FORM_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":6,\"viewName\":\"MB_ORI_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":7,\"viewName\":\"MB_ORI_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":8,\"viewName\":\"MB_RES_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":9,\"viewName\":\"MB_RES_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":10,\"viewName\":\"MB_FORM_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true}],\"isRecent\":false,\"allowLocationAssociation\":false,\"isLocationAssocMandatory\":false,\"bfpc\":\"0\$\$kFpU9W\",\"had\":\"0\$\$lVfG3Y\",\"isFromMarketplace\":false,\"isMarkDefault\":false,\"isNewlyCreated\":false,\"isAsycnProcess\":false},\"actionList\":[{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Assign Status\",\"actionID\":\"2\$\$r5ZUtw\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Attach Docs\",\"actionID\":\"5\$\$RvyG5d\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Distribute\",\"actionID\":\"6\$\$pwccPZ\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Acknowledgement\",\"actionID\":\"37\$\$vhxsnH\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Action\",\"actionID\":\"36\$\$bzONin\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Information\",\"actionID\":\"7\$\$X2RF5y\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":true,\"is_associated\":true,\"actionName\":\"Respond\",\"actionID\":\"3\$\$CPl6Fg\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Review Draft\",\"actionID\":\"34\$\$vhA0uD\",\"num_days\":2,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true}],\"formTypeGroupVO\":{\"formTypeGroupID\":341,\"formTypeGroupName\":\"Adoddle-All Apps\",\"generateURI\":true},\"statusList\":[{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Approve\",\"statusID\":1004,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":true,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed\",\"statusID\":3,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved\",\"statusID\":4,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved with Comments\",\"statusID\":5,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Rejected\",\"statusID\":6,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Open\",\"statusID\":1001,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Resolved\",\"statusID\":1002,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Verified\",\"statusID\":1003,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true}],\"isFormInherited\":false,\"generateURI\":true},\"createdFormsCount\":0,\"draftFormsCount\":0,\"templatetype\":1,\"appId\":2,\"formTypeName\":\"Fields\",\"totalForms\":0,\"formtypeGroupid\":341,\"isFavourite\":true,\"appBuilderID\":\"\",\"canViewDraftMsg\":false,\"formTypeGroupName\":\"Fields\",\"formGroupCode\":\"FID\",\"canCreateForm\":true,\"numActions\":0,\"crossWorkspaceID\":-1,\"instanceGroupId\":10381414,\"allow_associate_location\":false,\"numOverdueActions\":0,\"is_location_assoc_mandatory\":false,\"workspaceid\":2116416}",
          "FormTypeName": "Inline attachment",
          "FormGroupCode": "INL",
          "AppBuilderId": "INL",
          "TemplateTypeId": 2,
          "AppTypeId": 1
        }
      ]);

      String formVOFromDBQuery = "WITH OfflineSyncData AS (SELECT ";
      formVOFromDBQuery = "$formVOFromDBQuery CASE frmMsgTbl.OfflineRequestData WHEN 2 THEN 5 ELSE 1 END AS Type, frmTypeTbl.AppTypeId, frmMsgTbl.ProjectId, frmMsgTbl.FormTypeId, frmTypeTbl.InstanceGroupId, frmTypeTbl.TemplateTypeId, frmMsgTbl.FormId, frmMsgTbl.MsgId, frmMsgTbl.MsgTypeId, frmMsgTbl.OfflineRequestData, frmMsgTbl.UpdatedDateInMS, frmMsgTbl.IsDraft, frmMsgTbl.DelFormIds";
      formVOFromDBQuery = "$formVOFromDBQuery FROM FormMessageListTbl frmMsgTbl";
      formVOFromDBQuery = "$formVOFromDBQuery INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId";
      formVOFromDBQuery = "$formVOFromDBQuery INNER JOIN FormGroupAndFormTypeListTbl frmTypeTbl ON frmTypeTbl.ProjectId=frmMsgTbl.ProjectId AND frmTypeTbl.FormTypeId=frmMsgTbl.FormTypeId";
      formVOFromDBQuery = "$formVOFromDBQuery WHERE frmMsgTbl.OfflineRequestData<>''";
      formVOFromDBQuery = "$formVOFromDBQuery AND ((frmTypeTbl.TemplateTypeId=1 AND frmMsgTbl.IsDraft<>1) OR frmTypeTbl.TemplateTypeId<>1))";
      formVOFromDBQuery = "$formVOFromDBQuery SELECT IFNULL(fldSycDataView.OfflineRequestData,'') AS NewOfflineRequestData,frmTbl.* FROM FormListTbl frmTbl";
      formVOFromDBQuery = "$formVOFromDBQuery LEFT JOIN OfflineSyncData  fldSycDataView ON frmTbl.ProjectId=fldSycDataView.ProjectId AND frmTbl.FormId=fldSycDataView.FormId";
      formVOFromDBQuery = "$formVOFromDBQuery AND fldSycDataView.Type IN (1,2,5)";
      formVOFromDBQuery = "$formVOFromDBQuery WHERE frmTbl.ProjectId=2130192 ";
      formVOFromDBQuery = "$formVOFromDBQuery AND frmTbl.FormId=11607652";
      var data1 = [
        {
          "NewOfflineRequestData": [],
          "ProjectId": "2116416",
          "FormId": "11608838",
          "AppTypeId": 2,
          "FormTypeId": "10641209",
          "InstanceGroupId": "10381138",
          "FormTitle": "TA-0407-Attachment",
          "Code": "DEF2278",
          "CommentId": "11608838",
          "MessageId": "12311326",
          "ParentMessageId": 0,
          "OrgId": "5763307",
          "FirstName": "Mayur",
          "LastName": "Raval m.",
          "OrgName": "Asite Solutions Ltd",
          "Originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "OriginatorDisplayName": " Mayur Raval m., Asite Solutions Ltd",
          "NoOfActions": 0,
          "ObservationId": 107285,
          "LocationId": 183904,
          "PfLocFolderId": 115335312,
          "Updated": "19-Jul-2023#23:56 CST",
          "AttachmentImageName": "",
          "MsgCode": "ORI001",
          "TypeImage": "icons/form.png",
          "DocType": "Apps",
          "HasAttachments": 0,
          "HasDocAssocations": 0,
          "HasBimViewAssociations": 0,
          "HasFormAssocations": 0,
          "HasCommentAssocations": 0,
          "FormHasAssocAttach": 0,
          "FormCreationDate": "19-Jul-2023#23:56 CST",
          "FolderId": 0,
          "MsgTypeId": 1,
          "MsgStatusId": 20,
          "FormNumber": 2278,
          "MsgOriginatorId": 2017529,
          "TemplateType": 2,
          "IsDraft": 0,
          "StatusId": 1001,
          "OriginatorId": 2017529,
          "IsStatusChangeRestricted": 0,
          "AllowReopenForm": 0,
          "CanOrigChangeStatus": 0,
          "MsgTypeCode": "ORI",
          "Id": "",
          "StatusChangeUserId": 0,
          "StatusUpdateDate": "19-Jul-2023#23:56 CST",
          "StatusChangeUserName": " Mayur Raval m.",
          "StatusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "StatusChangeUserEmail": "m.raval@asite.com",
          "StatusChangeUserOrg": "Asite Solutions Ltd",
          "OriginatorEmail": "m.raval@asite.com",
          "ControllerUserId": 0,
          "UpdatedDateInMS": 1689828977000,
          "FormCreationDateInMS": 1689828977000,
          "ResponseRequestByInMS": 1690952399000,
          "FlagType": 0,
          "LatestDraftId": 0,
          "FlagTypeImageName": "flag_type/flag_0.png",
          "MessageTypeImageName": "icons/form.png",
          "CanAccessHistory": 1,
          "FormJsonData": "",
          "Status": "Open",
          "AttachedDocs": "0",
          "IsUploadAttachmentInTemp": 0,
          "IsSync": 0,
          "UserRefCode": "",
          "HasActions": 0,
          "CanRemoveOffline": 0,
          "IsMarkOffline": 0,
          "IsOfflineCreated": 0,
          "SyncStatus": 1,
          "IsForDefect": 0,
          "IsForApps": 0,
          "ObservationDefectTypeId": "218898",
          "StartDate": "2023-07-20",
          "ExpectedFinishDate": "2023-08-01",
          "IsActive": 1,
          "ObservationCoordinates": '{"x1":360.001440304004,"y1":134.31719617472731,"x2":370.001440304004,"y2":144.31719617472731}',
          "AnnotationId": "08C66C6A-1478-4A97-BB40-E938BCB6F81B-1689828968",
          "IsCloseOut": 0,
          "AssignedToUserId": 1079650,
          "AssignedToUserName": "",
          "AssignedToUserOrgName": "Asite Solutions",
          "MsgNum": 0,
          "RevisionId": "",
          "RequestJsonForOffline": "",
          "FormDueDays": 12,
          "FormSyncDate": "2023-07-20 05:56:17.27",
          "LastResponderForAssignedTo": "1079650",
          "LastResponderForOriginator": "2017529",
          "PageNumber": 1,
          "ObservationDefectType": "0",
          "StatusName": "Open",
          "AppBuilderId": "SNG-DEF",
          "TaskTypeName": "",
          "AssignedToRoleName": ""
        }
      ];
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, formVOFromDBQuery)).thenReturn(data1);

      String formMessageVOFromDBQuery = "SELECT * FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652 AND MsgId=123";
      var formMessageJson = fixture('form_message_db.json');
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMessageVOFromDBQuery)).thenReturn([jsonDecode(formMessageJson)]);

      String mapOfMessagesAttachmentListQuery = "SELECT frmMsgAttachTbl.*, prjTbl.DcId, IFNULL(frmView.LocationId,0) AS LocationId,"
          " IFNULL(frmView.ObservationId,0) AS ObservationId, IFNULL(frmView.AppBuilderId,'') AS AppBuilderId, "
          "IFNULL(frmView.TemplateType,0) AS TemplateType FROM FormMsgAttachAndAssocListTbl frmMsgAttachTbl "
          "INNER JOIN ProjectDetailTbl prjTbl ON prjTbl.ProjectId=frmMsgAttachTbl.ProjectId "
          "LEFT JOIN FormListTbl frmView ON frmView.ProjectId=frmMsgAttachTbl.AssocProjectId AND frmView.FormId=frmMsgAttachTbl.AssocFormCommId AND frmMsgAttachTbl.AttachmentType IN (2,6)";
      mapOfMessagesAttachmentListQuery = "$mapOfMessagesAttachmentListQuery WHERE frmMsgAttachTbl.ProjectId=2130192";
      mapOfMessagesAttachmentListQuery = "$mapOfMessagesAttachmentListQuery AND frmMsgAttachTbl.FormId=11608838";
      mapOfMessagesAttachmentListQuery = "$mapOfMessagesAttachmentListQuery AND frmMsgAttachTbl.MsgId=12309970";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, mapOfMessagesAttachmentListQuery)).thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":123,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      String mapOfLocationListQuery = "SELECT * FROM LocationDetailTbl";
      mapOfLocationListQuery = "$mapOfLocationListQuery WHERE ProjectId=2130192 AND LocationId=0;";
      when(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, mapOfLocationListQuery)).thenReturn([
        {"ProjectId": "2130192", "FolderId": "115096357", "LocationId": 183682, "LocationTitle": "Basement", "ParentFolderId": 115096349, "ParentLocationId": 183679, "PermissionValue": 0, "LocationPath": "Site Quality Demo\01 Vijay_Test\Plan-1\Basement", "SiteId": 0, "DocumentId": "13351081", "RevisionId": "26773045", "AnnotationId": "1fc95526-3610-5163-e2c8-c915a692c3d4", "LocationCoordinate": "{\"x1\":593.98,\"y1\":669.61,\"x2\":803.92,\"y2\":522.8199999999999}", "PageNumber": 1, "IsPublic": 0, "IsFavorite": 0, "IsSite": 0, "IsCalibrated": 1, "IsFileUploaded": 0, "IsActive": 1, "HasSubFolder": 0, "CanRemoveOffline": 0, "IsMarkOffline": 1, "SyncStatus": 0, "LastSyncTimeStamp": ""}
      ]);

      when(() => mockFileUtility.isFileExists(any())).thenAnswer((_) => Future.value(true));

      String strAttachQuery = "SELECT frmMsgTbl.MsgTypeCode,frmMsgAttacTbl.AttachAssocDetailJson FROM FormMsgAttachAndAssocListTbl frmMsgAttacTbl\n"
      "INNER JOIN FormMessageListTbl frmMsgTbl ON frmMsgTbl.ProjectId=frmMsgAttacTbl.ProjectId\n"
      "AND frmMsgTbl.FormId=frmMsgAttacTbl.FormId AND frmMsgTbl.MsgId=frmMsgAttacTbl.MsgId\n"
      "WHERE frmMsgAttacTbl.AttachmentType=0 AND frmMsgAttacTbl.ProjectId=2130192 AND frmMsgAttacTbl.FormId=11607652";

      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strAttachQuery))
          .thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":123,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      String dsDocAttachmentsAllQuery = "SELECT ProjectId,AttachAssocDetailJson FROM FormMsgAttachAndAssocListTbl\n"
          "WHERE AttachmentType=3 AND ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, dsDocAttachmentsAllQuery)).thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":123,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      String dsGetMSGDistributionListQuery = "SELECT frmMsgTbl.ProjectId,frmMsgTbl.FormId,frmMsgTbl.MsgId,frmTpCTE.AppBuilderId || CASE LENGTH(CAST(frmTbl.FormNumber AS TEXT)) WHEN 0 THEN '000' WHEN 1 THEN '00' WHEN 2 THEN '0' ELSE '' END\n"
      " || CAST(frmTbl.FormNumber AS TEXT) AS AppBuilderIdCode,frmMsgTbl.SentActions FROM FormMessageListTbl frmMsgTbl\n"
      "INNER JOIN FormGroupAndFormTypeListTbl frmTpCTE ON frmTpCTE.ProjectId=frmMsgTbl.ProjectId AND frmTpCTE.FormTypeId=frmMsgTbl.FormTypeId\n"
      "INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId\n"
      "WHERE frmMsgTbl.ProjectId=2130192 AND frmMsgTbl.FormId=11607652 AND frmMsgTbl.MsgId=123";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, dsGetMSGDistributionListQuery)).thenReturn([jsonDecode(formMessageJson)]);

      var formTypeStatusListJson = fixture('formType_status_list.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/StatusListData.json")).thenReturn(formTypeStatusListJson);

      String dsGetAllResponsesQuery = "SELECT MsgCode,OriginatorDisplayName,MsgCreatedDate,JsonData,MsgCreatedDateInMS FROM FormMessageListTbl\n"
      "WHERE MsgStatusId<>19 AND MsgTypeId=2\n"
      "AND ProjectId=2130192 AND FormId=11607652\n"
      "ORDER BY MsgCreatedDateInMS ASC";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, dsGetAllResponsesQuery)).thenReturn([jsonDecode(formMessageJson)]);

      String? createHtmlResponse = await createFormLocalDataSource.getCreateOrRespondHtmlJson(EHtmlRequestType.create, {"projectId": projectId, "formTypeId": formTypeId, "formId": formId, "msgId": "123"});
      expect(!createHtmlResponse.isNullOrEmpty(), true);
      verify(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, isDraftQuery)).called(2);
      verify(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, isDraftResMsgQuery)).called(2);
      // verify(() => mockDatabaseManager.executeSelectFromTable(FormTypeDao.tableName, dsFormNameQuery)).called(1);
      verify(() => mockDatabaseManager.executeSelectFromTable(FormTypeDao.tableName, dsFormGroupCodeQuery)).called(1);
      //verify(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, dsFormGroupCODQuery)).called(1);
      verify(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, dsCloseDueDateQuery)).called(1);
      verify(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, oriFormTitleQuery)).called(1);
      verify(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, oriUserREFQuery)).called(1);
      verify(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, allLocationByProjectPFQuery)).called(3);
      verify(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, dsFormStatusQuery)).called(1);
      verify(() => mockDatabaseManager.executeSelectFromTable(FormMessageActionDao.tableName, dsIncompleteActionsQuery)).called(1);
      verify(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, recentDefectQuery)).called(4);
      verify(() => mockDatabaseManager.executeSelectFromTable(ProjectDao.tableName, mapOfConfigListQuery)).called(1);
      verify(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, formVOFromDBQuery)).called(1);
      verify(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMessageVOFromDBQuery)).called(1);
      // verify(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, mapOfMessagesAttachmentListQuery)).called(1);
      verify(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, mapOfLocationListQuery)).called(1);
      // verify(() => mockFileUtility.isFileExists(any())).called(1);
    });
  });

  group("Testing Offline -Reply Form", () {
    test("Testing Offline - Reply Html Response is not Empty", () async {
      var htmlFile = fixtureFileContent('files/2130192/FormTypes/11103151/RES_VIEW.html');
      when(() => mockFileUtility.readFromFile("./test/fixtures/files/2130192/FormTypes/11103151/RES_VIEW.html")).thenReturn(htmlFile);
      when(() => mockFileUtility.isFileExist("./test/fixtures/files/2130192/FormTypes/11103151/RES_VIEW.html")).thenReturn(true);
      var jsonData = fixtureFileContent('files/2130192/FormTypes/11103151/data.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/files/2130192/FormTypes/11103151/data.json")).thenReturn(jsonData);

      var fieldJsonData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/Fix-FieldData.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/Fix-FieldData.json")).thenReturn(fieldJsonData);

      var offlineCreateFormContent = fixtureFileContent('database/HTML5Form/offlineCreateForm.html');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/HTML5Form/offlineCreateForm.html")).thenReturn(offlineCreateFormContent);

      var distributionData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/DistributionData.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/DistributionData.json")).thenReturn(distributionData);

      String dsFormGroupCODQuery = "SELECT CASE WHEN INSTR(frmTbl.Code,'(')>0 THEN SUBSTR(frmTbl.Code,0,INSTR(frmTbl.Code,'(')) WHEN LOWER(frmTbl.Code)='draft' OR frmTbl.IsDraft=1 THEN frmTpView.FormTypeGroupCode || '000' ELSE frmTbl.Code END AS DS_FORMID FROM FormListTbl frmTbl\n"
          "INNER JOIN FormGroupAndFormTypeListTbl frmTpView ON frmTpView.ProjectId=frmTbl.ProjectId AND frmTpView.FormTypeId=frmTbl.FormTypeId\n"
          "WHERE frmTbl.ProjectId=2130192 AND frmTbl.FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, dsFormGroupCODQuery)).thenReturn([]);

      String formMessageVOFromDBQuery = "SELECT * FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652 AND MsgId=123";
      var formMessageJson = fixture('form_message_db.json');
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMessageVOFromDBQuery)).thenReturn([jsonDecode(formMessageJson)]);

      String strAttachQuery = "SELECT ProjectId,FormTypeId,MsgId,AttachRevId,AssocDocRevisionId,AttachmentType,AttachAssocDetailJson FROM FormMsgAttachAndAssocListTbl";
      strAttachQuery = "$strAttachQuery WHERE ProjectId=2130192";
      strAttachQuery = "$strAttachQuery AND MsgId=123";
      strAttachQuery = "$strAttachQuery AND (AttachRevId=1690365038319370 OR AssocDocRevisionId=1690365038319370)";

      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strAttachQuery))
          .thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":123,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      String isDraftQuery = "SELECT MsgStatusId FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652\n"
          "AND MsgTypeId=1 AND (MsgStatusId=19 OR OfflineRequestData<>'')";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, isDraftQuery)).thenReturn([]);

      String dsCloseDueDateQuery = "SELECT JsonData FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652\n"
          "AND MsgId=123";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, dsCloseDueDateQuery)).thenReturn([]);

      String oriFormTitleQuery = "SELECT FormTitle FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, oriFormTitleQuery)).thenReturn([{"FormTitle": "Test Form"}]);

      String oriUserREFQuery = "SELECT UserRefCode FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, oriUserREFQuery)).thenReturn([{"UserRefCode": "ORI001"}]);

      String allLocationByProjectPFQuery = "SELECT prjTbl.ProjectName, locTbl.* FROM LocationDetailTbl locTbl\n"
          "INNER JOIN ProjectDetailTbl prjTbl ON prjTbl.ProjectId=locTbl.ProjectId\n"
          "WHERE locTbl.IsActive=1 AND locTbl.IsMarkOffline=1 AND locTbl.ProjectId=2130192\n"
          "ORDER BY locTbl.LocationPath COLLATE NOCASE";
      when(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, allLocationByProjectPFQuery)).thenReturn([{"ProjectName": "demo"}]);

      String dsFormStatusQuery = "SELECT Status FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, dsFormStatusQuery)).thenReturn([]);

      String dsIncompleteActionsQuery = "SELECT * FROM FormMsgActionListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652\n"
          "AND ActionStatus=0 AND RecipientUserId=808581";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageActionDao.tableName, dsIncompleteActionsQuery)).thenReturn([]);

      String recentDefectQuery = "SELECT frmTbl.ProjectId,frmTbl.FormId,frmTbl.Code,frmTpTbl.FormTypeGroupCode,frmTbl.FormTitle,frmTbl.ObservationDefectType,frmTbl.LocationId,locTbl.LocationTitle,locTbl.LocationPath,frmMsgTbl.JsonData FROM FormListTbl frmTbl\n"
          "INNER JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=frmTbl.ProjectId AND frmTpTbl.FormTypeId=frmTbl.FormTypeId\n"
          "INNER JOIN LocationDetailTbl locTbl ON locTbl.ProjectId=frmTbl.ProjectId AND locTbl.LocationId=frmTbl.LocationId\n"
          "INNER JOIN FormMessageListTbl frmMsgTbl ON frmMsgTbl.ProjectId=frmTbl.ProjectId AND frmMsgTbl.FormId=frmTbl.FormId AND frmMsgTbl.MsgTypeId=1 AND frmMsgTbl.IsDraft=0\n"
          "WHERE frmTbl.ProjectId=2130192 AND frmTbl.OriginatorId=808581 AND frmTpTbl.InstanceGroupId=\n"
          "(SELECT InstanceGroupId FROM FormGroupAndFormTypeListTbl WHERE ProjectId=2130192 AND FormTypeId=11103151)\n"
          "ORDER BY frmTbl.FormCreationDateInMS DESC\n"
          "LIMIT 5 OFFSET 0";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, recentDefectQuery))
          .thenReturn([{"ProjectId": "2116416","ProjectName": "!!PIN_ANY_APP_TYPE_20_9","DcId": 1,"FormTypeId": "10616643","JsonData": "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"DistributionDays\":\"0\",\"Organization\":\"\",\"DefectTyoe\":\"Computer\",\"ExpectedFinishDate\":\"2023-08-08\",\"DefectDescription\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"707447#Vijay Mavadiya (5336), Asite Solutions\"}},\"Defect_Description\":\"test description\",\"LocationName\":\"01 Vijay_Test\",\"StartDate\":\"2023-08-01\",\"ActualFinishDate\":\"\",\"ExpectedFinishDays\":\"5\",\"DS_Logo\":\"images/asite.gif\",\"LastResponder_For_AssignedTo\":\"707447\",\"TaskType\":\"Defect\",\"isCalibrated\":false,\"ORI_FORMTITLE\":\"Test Offlinr VJ Attachment\",\"attachements\":[{\"attachedDocs\":\"\"}],\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"Assigned\":\"Vijay Mavadiya (5336), Asite Solutions\",\"CurrStage\":\"1\",\"Recent_Defects\":\"\",\"FormCreationDate\":\"\",\"StartDateDisplay\":\"01-Aug-2023\",\"LastResponder_For_Originator\":\"2017529\",\"PF_Location_Detail\":\"183678|0|null|0\",\"Username\":\"\",\"ORI_USERREF\":\"\",\"Location\":\"183678|01 Vijay_Test|01 Vijay_Test\"},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"SHResponse\":\"Yes\",\"ShowHideFlag\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_CREATE\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\",\"DS_FORMAUTONO_ADD\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_Get_All_Responses\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"attachments\":[],\"Asite_System_Data_Read_Only\":{\"_2_Printing_Data\":{\"DS_PRINTEDON\":\"\",\"DS_PRINTEDBY\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\",\"DS_FORMNAME\":\"Site Tasks\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"\",\"DS_CLIENT\":\"\"},\"_5_Form_Data\":{\"DS_DATEOFISSUE\":\"\",\"DS_ISDRAFT_RES_MSG\":\"\",\"Status_Data\":{\"DS_APPROVEDON\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_APPROVEDBY\":\"\",\"DS_CLOSE_DUE_DATE\":\"2023-08-08\",\"DS_FORMSTATUS\":\"\"},\"DS_DISTRIBUTION\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT_RES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_FORMID\":\"\"},\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_6_Form_MSG_Data\":{\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGID\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_PROJUSERS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_ACTIONDUEDATE\":\"5\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_PROJDISTUSERS\":\"707447\"}]}},\"selectedControllerUserId\":\"\"}}","FormTypeName": "Inline attachment","FormGroupCode": "INL","AppBuilderId": "INL","TemplateTypeId": 2,"AppTypeId": 1}]);

      String mapOfConfigListQuery = "SELECT prjTbl.ProjectId,prjTbl.ProjectName,prjTbl.DcId AS DcId,frmTpTbl.FormTypeId,frmTpTbl.FormTypeDetailJson,frmTpTbl.FormTypeName,frmTpTbl.FormTypeGroupCode AS FormGroupCode,frmTpTbl.AppBuilderId,frmTpTbl.TemplateTypeId,frmTpTbl.AppTypeId FROM ProjectDetailTbl prjTbl";
      mapOfConfigListQuery = "$mapOfConfigListQuery INNER JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=prjTbl.ProjectId";
      mapOfConfigListQuery = "$mapOfConfigListQuery WHERE frmTpTbl.ProjectId=2130192 AND frmTpTbl.FormTypeId=11103151";
      when(() => mockDatabaseManager.executeSelectFromTable(ProjectDao.tableName, mapOfConfigListQuery))
          .thenReturn([{"ProjectId": "2116416","ProjectName": "!!PIN_ANY_APP_TYPE_20_9","DcId": 1,"FormTypeId": "10616643","FormTypeDetailJson": "{\"createFormsLimit\":0,\"canAccessPrivilegedForms\":true,\"formTypeID\":\"10381414\$\$9IBwDZ\",\"allow_attachments\":true,\"formTypesDetail\":{\"formTypeVO\":{\"formTypeID\":\"10381414\$\$9IBwDZ\",\"formTypeName\":\"Fields\",\"code\":\"FID\",\"use_controller\":false,\"response_allowed\":true,\"show_responses\":true,\"allow_reopening_form\":true,\"default_action\":\"3\$\$CPl6Fg\",\"is_default\":true,\"allow_forwarding\":false,\"allow_distribution_after_creation\":true,\"allow_distribution_originator\":true,\"allow_distribution_recipients\":false,\"allow_forward_originator\":false,\"allow_forward_recipients\":false,\"responders_collaborate\":false,\"continue_discussion\":false,\"hide_orgs_and_users\":false,\"has_hyperlink\":false,\"allow_attachments\":true,\"allow_doc_associates\":true,\"allow_form_associations\":true,\"allow_attributes\":false,\"associations_extend_doc_issue\":false,\"public_message\":false,\"browsable_attachment_folder\":false,\"has_overall_status\":true,\"is_instance\":true,\"form_type_group_id\":341,\"instance_group_id\":\"10381414\$\$9IBwDZ\",\"ctrl_change_status\":false,\"parent_formtype_id\":\"2171706\$\$6zD4x9\",\"orig_change_status\":true,\"orig_can_close\":false,\"upload_logo\":false,\"user_ref\":false,\"allow_comment_associations\":false,\"is_public\":true,\"is_active\":true,\"signatureBox\":\"000\",\"xsnFile\":\"2181422.xsn\$\$guzLhn\",\"xmlData\":\"<?mso-infoPathSolution name=\\\"urn:schemas-microsoft-com:office:infopath:ASI-Request-For-Information-Mobile-View:-myXSD-2008-07-03T04-59-35\\\" href=\\\"ASI_Request_For_Information_Mobile_View_tImEsTaMp516083820727589_516447\\\" solutionVersion=\\\"1.0.0.196\\\" productVersion=\\\"12.0.0\\\" PIVersion=\\\"1.0.0.0\\\" ?><?mso-application progid=\\\"InfoPath.Document\\\"?><my:myFields xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\" xmlns:xhtml=\\\"http://www.w3.org/1999/xhtml\\\" xmlns:my=\\\"http://schemas.microsoft.com/office/infopath/2003/myXSD/2008-07-03T04:59:35\\\" xmlns:xd=\\\"http://schemas.microsoft.com/office/infopath/2003\\\"><my:ORI_FORMTITLE/><my:FORM_CUSTOM_FIELDS><my:ORI_MSG_Custom_Fields><my:Description/></my:ORI_MSG_Custom_Fields><my:RES_MSG_Custom_Fields><my:Response/></my:RES_MSG_Custom_Fields></my:FORM_CUSTOM_FIELDS><my:Asite_System_Data_Read_Only><my:_1_User_Data><my:DS_WORKINGUSER/><my:DS_WORKINGUSERROLE/></my:_1_User_Data><my:_2_Printing_Data><my:DS_PRINTEDBY/><my:DS_PRINTEDON/></my:_2_Printing_Data><my:_3_Project_Data><my:DS_PROJECTNAME/><my:DS_CLIENTDS_CLIENT/></my:_3_Project_Data><my:_4_Form_Type_Data><my:DS_FORMNAME/><my:DS_FORMGROUPCODE/></my:_4_Form_Type_Data><my:_5_Form_Data><my:DS_FORMID/><my:DS_ORIGINATOR/><my:DS_DATEOFISSUE/><my:DS_DISTRIBUTION/><my:DS_CONTROLLERNAME/><my:DS_ATTRIBUTES/><my:Status_Data><my:DS_FORMSTATUS/><my:DS_CLOSEDUEDATE/><my:DS_APPROVEDBY/><my:DS_APPROVEDON/><my:DS_ALL_FORMSTATUS>Open</my:DS_ALL_FORMSTATUS></my:Status_Data><my:DS_CLOSE_DUE_DATE/></my:_5_Form_Data><my:_6_Form_MSG_Data><my:DS_MSGID/><my:DS_MSGCREATOR/><my:DS_MSGDATE/><my:DS_MSGSTATUS/><my:DS_MSGRELEASEDATE/><my:ORI_MSG_Data><my:DS_DOC_ASSOCIATIONS_ORI/><my:DS_FORM_ASSOCIATIONS_ORI/><my:DS_ATTACHMENTS_ORI/></my:ORI_MSG_Data></my:_6_Form_MSG_Data></my:Asite_System_Data_Read_Only><my:Asite_System_Data_Read_Write><my:ORI_MSG_Fields><my:ORI_USERREF/><my:DS_AUTODISTRIBUTE>2</my:DS_AUTODISTRIBUTE><my:DS_ACTIONDUEDATE>3</my:DS_ACTIONDUEDATE><my:DS_FORMACTIONS>3 # Respond</my:DS_FORMACTIONS><my:DS_PROJDISTUSERS/></my:ORI_MSG_Fields></my:Asite_System_Data_Read_Write><my:Assign_To/></my:myFields>\",\"templateType\":1,\"responsePattern\":0,\"fixedFieldIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"displayFileName\":\"ASI_Request_For_Information_Mobile_View.xsn\$\$z08kl4\",\"viewIds\":\"2,6,4,3,8,10,7,9,5,1,\",\"mandatoryDistribution\":0,\"responseFromAll\":false,\"subTemplateType\":0,\"integrateExchange\":false,\"allowEditingORI\":false,\"allowImportExcelInEditORI\":false,\"isOverwriteExcelInEditORI\":true,\"enableECatalague\":false,\"formGroupName\":\"Fields\",\"projectId\":\"2116416\$\$s2Ieys\",\"clonedFormTypeId\":0,\"appBuilderFormIDCode\":\"\",\"loginUserId\":2017529,\"xslFileName\":\"\",\"allowImportForm\":false,\"allowWorkspaceLink\":false,\"linkedWorkspaceProjectId\":\"-1\$\$BUrsqP\",\"createFormsLimit\":0,\"spellCheckPrefs\":\"10\",\"isMobile\":false,\"createFormsLimitLevel\":0,\"restrictChangeFormStatus\":0,\"enableDraftResponses\":0,\"isDistributionFromGroupOnly\":true,\"isAutoCreateOnStatusChange\":false,\"docAssociationType\":1,\"viewFieldIdsData\":\"<root><views><viewid>2</viewid><view_name>ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>6</viewid><view_name>MB_ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>4</viewid><view_name>RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>5</viewid><view_name>FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>3</viewid><view_name>RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>8</viewid><view_name>MB_RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>1</viewid><view_name>ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>7</viewid><view_name>MB_ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>9</viewid><view_name>MB_RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>10</viewid><view_name>MB_FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views></root>\",\"createdMsgCount\":0,\"draft_count\":0,\"draftMsgId\":0,\"view_always_form_association\":false,\"view_always_doc_association\":false,\"auto_publish_to_folder\":false,\"default_folder_path\":\"\",\"default_folder_id\":\"\$\$YDWWpv\",\"allowExternalAccess\":0,\"embedFormContentInEmail\":0,\"canReplyViaEmail\":0,\"externalUsersOnly\":0,\"appTypeId\":2,\"dataCenterId\":0,\"allowViewAssociation\":0,\"infojetServerVersion\":1,\"isFormAvailableOffline\":0,\"allowDistributionByAll\":false,\"allowDistributionByRoles\":false,\"allowDistributionRoleIds\":\"\",\"canEditWithAppbuilder\":false,\"hasAppbuilderTemplateDraft\":false,\"isTemplateChanged\":false,\"viewsList\":[{\"viewId\":1,\"viewName\":\"ORI_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":2,\"viewName\":\"ORI_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":3,\"viewName\":\"RES_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":4,\"viewName\":\"RES_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":5,\"viewName\":\"FORM_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":6,\"viewName\":\"MB_ORI_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":7,\"viewName\":\"MB_ORI_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":8,\"viewName\":\"MB_RES_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":9,\"viewName\":\"MB_RES_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":10,\"viewName\":\"MB_FORM_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true}],\"isRecent\":false,\"allowLocationAssociation\":false,\"isLocationAssocMandatory\":false,\"bfpc\":\"0\$\$kFpU9W\",\"had\":\"0\$\$lVfG3Y\",\"isFromMarketplace\":false,\"isMarkDefault\":false,\"isNewlyCreated\":false,\"isAsycnProcess\":false},\"actionList\":[{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Assign Status\",\"actionID\":\"2\$\$r5ZUtw\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Attach Docs\",\"actionID\":\"5\$\$RvyG5d\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Distribute\",\"actionID\":\"6\$\$pwccPZ\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Acknowledgement\",\"actionID\":\"37\$\$vhxsnH\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Action\",\"actionID\":\"36\$\$bzONin\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Information\",\"actionID\":\"7\$\$X2RF5y\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":true,\"is_associated\":true,\"actionName\":\"Respond\",\"actionID\":\"3\$\$CPl6Fg\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Review Draft\",\"actionID\":\"34\$\$vhA0uD\",\"num_days\":2,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true}],\"formTypeGroupVO\":{\"formTypeGroupID\":341,\"formTypeGroupName\":\"Adoddle-All Apps\",\"generateURI\":true},\"statusList\":[{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Approve\",\"statusID\":1004,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":true,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed\",\"statusID\":3,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved\",\"statusID\":4,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved with Comments\",\"statusID\":5,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Rejected\",\"statusID\":6,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Open\",\"statusID\":1001,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Resolved\",\"statusID\":1002,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Verified\",\"statusID\":1003,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true}],\"isFormInherited\":false,\"generateURI\":true},\"createdFormsCount\":0,\"draftFormsCount\":0,\"templatetype\":1,\"appId\":2,\"formTypeName\":\"Fields\",\"totalForms\":0,\"formtypeGroupid\":341,\"isFavourite\":true,\"appBuilderID\":\"\",\"canViewDraftMsg\":false,\"formTypeGroupName\":\"Fields\",\"formGroupCode\":\"FID\",\"canCreateForm\":true,\"numActions\":0,\"crossWorkspaceID\":-1,\"instanceGroupId\":10381414,\"allow_associate_location\":false,\"numOverdueActions\":0,\"is_location_assoc_mandatory\":false,\"workspaceid\":2116416}","FormTypeName": "Inline attachment","FormGroupCode": "INL","AppBuilderId": "INL","TemplateTypeId": 2,"AppTypeId": 1}]);

      String formVOFromDBQuery = "WITH OfflineSyncData AS (SELECT ";
      formVOFromDBQuery = "$formVOFromDBQuery CASE frmMsgTbl.OfflineRequestData WHEN 2 THEN 5 ELSE 1 END AS Type, frmTypeTbl.AppTypeId, frmMsgTbl.ProjectId, frmMsgTbl.FormTypeId, frmTypeTbl.InstanceGroupId, frmTypeTbl.TemplateTypeId, frmMsgTbl.FormId, frmMsgTbl.MsgId, frmMsgTbl.MsgTypeId, frmMsgTbl.OfflineRequestData, frmMsgTbl.UpdatedDateInMS, frmMsgTbl.IsDraft, frmMsgTbl.DelFormIds";
      formVOFromDBQuery = "$formVOFromDBQuery FROM FormMessageListTbl frmMsgTbl";
      formVOFromDBQuery = "$formVOFromDBQuery INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId";
      formVOFromDBQuery = "$formVOFromDBQuery INNER JOIN FormGroupAndFormTypeListTbl frmTypeTbl ON frmTypeTbl.ProjectId=frmMsgTbl.ProjectId AND frmTypeTbl.FormTypeId=frmMsgTbl.FormTypeId";
      formVOFromDBQuery = "$formVOFromDBQuery WHERE frmMsgTbl.OfflineRequestData<>''";
      formVOFromDBQuery = "$formVOFromDBQuery AND ((frmTypeTbl.TemplateTypeId=1 AND frmMsgTbl.IsDraft<>1) OR frmTypeTbl.TemplateTypeId<>1))";
      formVOFromDBQuery = "$formVOFromDBQuery SELECT IFNULL(fldSycDataView.OfflineRequestData,'') AS NewOfflineRequestData,frmTbl.* FROM FormListTbl frmTbl";
      formVOFromDBQuery = "$formVOFromDBQuery LEFT JOIN OfflineSyncData  fldSycDataView ON frmTbl.ProjectId=fldSycDataView.ProjectId AND frmTbl.FormId=fldSycDataView.FormId";
      formVOFromDBQuery = "$formVOFromDBQuery AND fldSycDataView.Type IN (1,2,5)";
      formVOFromDBQuery = "$formVOFromDBQuery WHERE frmTbl.ProjectId=2130192 ";
      formVOFromDBQuery = "$formVOFromDBQuery AND frmTbl.FormId=11607652";
      var data1 = [{"NewOfflineRequestData":[],"ProjectId":"2116416","FormId":"11608838","AppTypeId":2,"FormTypeId":"10641209","InstanceGroupId":"10381138","FormTitle":"TA-0407-Attachment","Code":"DEF2278","CommentId":"11608838","MessageId":"12311326","ParentMessageId":0,"OrgId":"5763307","FirstName":"Mayur","LastName":"Raval m.","OrgName":"Asite Solutions Ltd","Originator":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur","OriginatorDisplayName":" Mayur Raval m., Asite Solutions Ltd","NoOfActions":0,"ObservationId":107285,"LocationId":183904,"PfLocFolderId":115335312,"Updated":"19-Jul-2023#23:56 CST","AttachmentImageName":"","MsgCode":"ORI001","TypeImage":"icons/form.png","DocType":"Apps","HasAttachments":0,"HasDocAssocations":0,"HasBimViewAssociations":0,"HasFormAssocations":0,"HasCommentAssocations":0,"FormHasAssocAttach":0,"FormCreationDate":"19-Jul-2023#23:56 CST","FolderId":0,"MsgTypeId":1,"MsgStatusId":20,"FormNumber":2278,"MsgOriginatorId":2017529,"TemplateType":2,"IsDraft":0,"StatusId":1001,"OriginatorId":2017529,"IsStatusChangeRestricted":0,"AllowReopenForm":0,"CanOrigChangeStatus":0,"MsgTypeCode":"ORI","Id":"","StatusChangeUserId":0,"StatusUpdateDate":"19-Jul-2023#23:56 CST","StatusChangeUserName":" Mayur Raval m.","StatusChangeUserPic":"https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur","StatusChangeUserEmail":"m.raval@asite.com","StatusChangeUserOrg":"Asite Solutions Ltd","OriginatorEmail":"m.raval@asite.com","ControllerUserId":0,"UpdatedDateInMS":1689828977000,"FormCreationDateInMS":1689828977000,"ResponseRequestByInMS":1690952399000,"FlagType":0,"LatestDraftId":0,"FlagTypeImageName":"flag_type/flag_0.png","MessageTypeImageName":"icons/form.png","CanAccessHistory":1,"FormJsonData":"","Status":"Open","AttachedDocs":"0","IsUploadAttachmentInTemp":0,"IsSync":0,"UserRefCode":"","HasActions":0,"CanRemoveOffline":0,"IsMarkOffline":0,"IsOfflineCreated":0,"SyncStatus":1,"IsForDefect":0,"IsForApps":0,"ObservationDefectTypeId":"218898","StartDate":"2023-07-20","ExpectedFinishDate":"2023-08-01","IsActive":1,"ObservationCoordinates":'{"x1":360.001440304004,"y1":134.31719617472731,"x2":370.001440304004,"y2":144.31719617472731}',"AnnotationId":"08C66C6A-1478-4A97-BB40-E938BCB6F81B-1689828968","IsCloseOut":0,"AssignedToUserId":1079650,"AssignedToUserName":"","AssignedToUserOrgName":"Asite Solutions","MsgNum":0,"RevisionId":"","RequestJsonForOffline":"","FormDueDays":12,"FormSyncDate":"2023-07-20 05:56:17.27","LastResponderForAssignedTo":"1079650","LastResponderForOriginator":"2017529","PageNumber":1,"ObservationDefectType":"0","StatusName":"Open","AppBuilderId":"SNG-DEF","TaskTypeName":"","AssignedToRoleName":""}];
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, formVOFromDBQuery)).thenReturn(data1);

      String mapOfMessagesAttachmentListQuery = "SELECT frmMsgAttachTbl.*, prjTbl.DcId, IFNULL(frmView.LocationId,0) AS LocationId,"
          " IFNULL(frmView.ObservationId,0) AS ObservationId, IFNULL(frmView.AppBuilderId,'') AS AppBuilderId, "
          "IFNULL(frmView.TemplateType,0) AS TemplateType FROM FormMsgAttachAndAssocListTbl frmMsgAttachTbl "
          "INNER JOIN ProjectDetailTbl prjTbl ON prjTbl.ProjectId=frmMsgAttachTbl.ProjectId "
          "LEFT JOIN FormListTbl frmView ON frmView.ProjectId=frmMsgAttachTbl.AssocProjectId AND frmView.FormId=frmMsgAttachTbl.AssocFormCommId AND frmMsgAttachTbl.AttachmentType IN (2,6)";
      mapOfMessagesAttachmentListQuery = "$mapOfMessagesAttachmentListQuery WHERE frmMsgAttachTbl.ProjectId=2130192";
      mapOfMessagesAttachmentListQuery = "$mapOfMessagesAttachmentListQuery AND frmMsgAttachTbl.FormId=11608838";
      mapOfMessagesAttachmentListQuery = "$mapOfMessagesAttachmentListQuery AND frmMsgAttachTbl.MsgId=12309970";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, mapOfMessagesAttachmentListQuery))
          .thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "2", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"2\",\"msgId\":123,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      String mapOfLocationListQuery = "SELECT * FROM LocationDetailTbl";
      mapOfLocationListQuery = "$mapOfLocationListQuery WHERE ProjectId=2130192 AND LocationId=183904;";
      when(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, mapOfLocationListQuery))
          .thenReturn([{"ProjectId": "2130192", "FolderId": "115096357", "LocationId": 183682, "LocationTitle": "Basement", "ParentFolderId": 115096349, "ParentLocationId": 183679, "PermissionValue": 0, "LocationPath": "Site Quality Demo\01 Vijay_Test\Plan-1\Basement", "SiteId": 0, "DocumentId": "13351081", "RevisionId": "26773045", "AnnotationId": "1fc95526-3610-5163-e2c8-c915a692c3d4", "LocationCoordinate": "{\"x1\":593.98,\"y1\":669.61,\"x2\":803.92,\"y2\":522.8199999999999}", "PageNumber": 1, "IsPublic": 0, "IsFavorite": 0, "IsSite": 0, "IsCalibrated": 1, "IsFileUploaded": 0, "IsActive": 1, "HasSubFolder": 0, "CanRemoveOffline": 0, "IsMarkOffline": 1, "SyncStatus": 0, "LastSyncTimeStamp": ""}]);

      when(() => mockFileUtility.isFileExists(any())).thenAnswer((_) => Future.value(true));

      String? replyHtmlResponse = await createFormLocalDataSource.getCreateOrRespondHtmlJson(EHtmlRequestType.reply, {"projectId": projectId, "formTypeId": formTypeId, "formId": formId, "msgId": "123"});
      expect(!replyHtmlResponse.isNullOrEmpty(), true);
      String? respondHtmlResponse = await createFormLocalDataSource.getCreateOrRespondHtmlJson(EHtmlRequestType.respond, {"projectId": projectId, "formTypeId": formTypeId, "formId": formId, "msgId": "123"});
      expect(!respondHtmlResponse.isNullOrEmpty(), true);
      String? replyAllHtmlResponse = await createFormLocalDataSource.getCreateOrRespondHtmlJson(EHtmlRequestType.replyAll, {"projectId": projectId, "formTypeId": formTypeId, "formId": formId, "msgId": "123"});
      expect(!replyAllHtmlResponse.isNullOrEmpty(), true);

      String formMessageVOFromDBQuery1 = "SELECT * FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652 AND MsgId=123";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMessageVOFromDBQuery1)).thenReturn([]);

      String formMessageVOFromDBQuery2 = "SELECT * FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652 AND MsgId=12349105";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMessageVOFromDBQuery2)).thenReturn([jsonDecode(formMessageJson)]);

      String? respondHtmlResponse1= await createFormLocalDataSource.getCreateOrRespondHtmlJson(EHtmlRequestType.respond, {"projectId": projectId, "formTypeId": formTypeId, "formId": formId, "msgId": "123", "parent_msg_id":"12349105"});
      expect(!respondHtmlResponse1.isNullOrEmpty(), true);
    });
  });

  group("Testing Offline - Edit Draft Form", () {
    test("Testing Offline - Edit Draft Html Response is not Empty", () async {
      var htmlFile = fixtureFileContent('files/2130192/FormTypes/11103151/ORI_VIEW.html');
      when(() => mockFileUtility.readFromFile("./test/fixtures/files/2130192/FormTypes/11103151/ORI_VIEW.html")).thenReturn(htmlFile);

      var jsonData = fixtureFileContent('files/2130192/FormTypes/11103151/data.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/files/2130192/FormTypes/11103151/data.json")).thenReturn(jsonData);

      var customAttributeData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/CustomAttributeData.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/CustomAttributeData.json")).thenReturn(customAttributeData);

      var fieldJsonData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/Fix-FieldData.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/Fix-FieldData.json")).thenReturn(fieldJsonData);

      var offlineCreateFormContent = fixtureFileContent('database/HTML5Form/offlineCreateForm.html');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/HTML5Form/offlineCreateForm.html")).thenReturn(offlineCreateFormContent);

      String formMessageVOFromDBQuery = "SELECT * FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652 AND MsgId=123";
      var formMessageJson = fixture('form_message_db.json');
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMessageVOFromDBQuery)).thenReturn([jsonDecode(formMessageJson)]);

      String mapOfConfigListQuery = "SELECT prjTbl.ProjectId,prjTbl.ProjectName,prjTbl.DcId AS DcId,frmTpTbl.FormTypeId,frmTpTbl.FormTypeDetailJson,frmTpTbl.FormTypeName,frmTpTbl.FormTypeGroupCode AS FormGroupCode,frmTpTbl.AppBuilderId,frmTpTbl.TemplateTypeId,frmTpTbl.AppTypeId FROM ProjectDetailTbl prjTbl";
      mapOfConfigListQuery = "$mapOfConfigListQuery INNER JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=prjTbl.ProjectId";
      mapOfConfigListQuery = "$mapOfConfigListQuery WHERE frmTpTbl.ProjectId=2130192 AND frmTpTbl.FormTypeId=11103151";
      when(() => mockDatabaseManager.executeSelectFromTable(ProjectDao.tableName, mapOfConfigListQuery)).thenReturn([
        {
          "ProjectId": "2116416",
          "ProjectName": "!!PIN_ANY_APP_TYPE_20_9",
          "DcId": 1,
          "FormTypeId": "10616643",
          "FormTypeDetailJson":
              "{\"createFormsLimit\":0,\"canAccessPrivilegedForms\":true,\"formTypeID\":\"10381414\$\$9IBwDZ\",\"allow_attachments\":true,\"formTypesDetail\":{\"formTypeVO\":{\"formTypeID\":\"10381414\$\$9IBwDZ\",\"formTypeName\":\"Fields\",\"code\":\"FID\",\"use_controller\":false,\"response_allowed\":true,\"show_responses\":true,\"allow_reopening_form\":true,\"default_action\":\"3\$\$CPl6Fg\",\"is_default\":true,\"allow_forwarding\":false,\"allow_distribution_after_creation\":true,\"allow_distribution_originator\":true,\"allow_distribution_recipients\":false,\"allow_forward_originator\":false,\"allow_forward_recipients\":false,\"responders_collaborate\":false,\"continue_discussion\":false,\"hide_orgs_and_users\":false,\"has_hyperlink\":false,\"allow_attachments\":true,\"allow_doc_associates\":true,\"allow_form_associations\":true,\"allow_attributes\":false,\"associations_extend_doc_issue\":false,\"public_message\":false,\"browsable_attachment_folder\":false,\"has_overall_status\":true,\"is_instance\":true,\"form_type_group_id\":341,\"instance_group_id\":\"10381414\$\$9IBwDZ\",\"ctrl_change_status\":false,\"parent_formtype_id\":\"2171706\$\$6zD4x9\",\"orig_change_status\":true,\"orig_can_close\":false,\"upload_logo\":false,\"user_ref\":false,\"allow_comment_associations\":false,\"is_public\":true,\"is_active\":true,\"signatureBox\":\"000\",\"xsnFile\":\"2181422.xsn\$\$guzLhn\",\"xmlData\":\"<?mso-infoPathSolution name=\\\"urn:schemas-microsoft-com:office:infopath:ASI-Request-For-Information-Mobile-View:-myXSD-2008-07-03T04-59-35\\\" href=\\\"ASI_Request_For_Information_Mobile_View_tImEsTaMp516083820727589_516447\\\" solutionVersion=\\\"1.0.0.196\\\" productVersion=\\\"12.0.0\\\" PIVersion=\\\"1.0.0.0\\\" ?><?mso-application progid=\\\"InfoPath.Document\\\"?><my:myFields xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\" xmlns:xhtml=\\\"http://www.w3.org/1999/xhtml\\\" xmlns:my=\\\"http://schemas.microsoft.com/office/infopath/2003/myXSD/2008-07-03T04:59:35\\\" xmlns:xd=\\\"http://schemas.microsoft.com/office/infopath/2003\\\"><my:ORI_FORMTITLE/><my:FORM_CUSTOM_FIELDS><my:ORI_MSG_Custom_Fields><my:Description/></my:ORI_MSG_Custom_Fields><my:RES_MSG_Custom_Fields><my:Response/></my:RES_MSG_Custom_Fields></my:FORM_CUSTOM_FIELDS><my:Asite_System_Data_Read_Only><my:_1_User_Data><my:DS_WORKINGUSER/><my:DS_WORKINGUSERROLE/></my:_1_User_Data><my:_2_Printing_Data><my:DS_PRINTEDBY/><my:DS_PRINTEDON/></my:_2_Printing_Data><my:_3_Project_Data><my:DS_PROJECTNAME/><my:DS_CLIENTDS_CLIENT/></my:_3_Project_Data><my:_4_Form_Type_Data><my:DS_FORMNAME/><my:DS_FORMGROUPCODE/></my:_4_Form_Type_Data><my:_5_Form_Data><my:DS_FORMID/><my:DS_ORIGINATOR/><my:DS_DATEOFISSUE/><my:DS_DISTRIBUTION/><my:DS_CONTROLLERNAME/><my:DS_ATTRIBUTES/><my:Status_Data><my:DS_FORMSTATUS/><my:DS_CLOSEDUEDATE/><my:DS_APPROVEDBY/><my:DS_APPROVEDON/><my:DS_ALL_FORMSTATUS>Open</my:DS_ALL_FORMSTATUS></my:Status_Data><my:DS_CLOSE_DUE_DATE/></my:_5_Form_Data><my:_6_Form_MSG_Data><my:DS_MSGID/><my:DS_MSGCREATOR/><my:DS_MSGDATE/><my:DS_MSGSTATUS/><my:DS_MSGRELEASEDATE/><my:ORI_MSG_Data><my:DS_DOC_ASSOCIATIONS_ORI/><my:DS_FORM_ASSOCIATIONS_ORI/><my:DS_ATTACHMENTS_ORI/></my:ORI_MSG_Data></my:_6_Form_MSG_Data></my:Asite_System_Data_Read_Only><my:Asite_System_Data_Read_Write><my:ORI_MSG_Fields><my:ORI_USERREF/><my:DS_AUTODISTRIBUTE>2</my:DS_AUTODISTRIBUTE><my:DS_ACTIONDUEDATE>3</my:DS_ACTIONDUEDATE><my:DS_FORMACTIONS>3 # Respond</my:DS_FORMACTIONS><my:DS_PROJDISTUSERS/></my:ORI_MSG_Fields></my:Asite_System_Data_Read_Write><my:Assign_To/></my:myFields>\",\"templateType\":1,\"responsePattern\":0,\"fixedFieldIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"displayFileName\":\"ASI_Request_For_Information_Mobile_View.xsn\$\$z08kl4\",\"viewIds\":\"2,6,4,3,8,10,7,9,5,1,\",\"mandatoryDistribution\":0,\"responseFromAll\":false,\"subTemplateType\":0,\"integrateExchange\":false,\"allowEditingORI\":false,\"allowImportExcelInEditORI\":false,\"isOverwriteExcelInEditORI\":true,\"enableECatalague\":false,\"formGroupName\":\"Fields\",\"projectId\":\"2116416\$\$s2Ieys\",\"clonedFormTypeId\":0,\"appBuilderFormIDCode\":\"\",\"loginUserId\":2017529,\"xslFileName\":\"\",\"allowImportForm\":false,\"allowWorkspaceLink\":false,\"linkedWorkspaceProjectId\":\"-1\$\$BUrsqP\",\"createFormsLimit\":0,\"spellCheckPrefs\":\"10\",\"isMobile\":false,\"createFormsLimitLevel\":0,\"restrictChangeFormStatus\":0,\"enableDraftResponses\":0,\"isDistributionFromGroupOnly\":true,\"isAutoCreateOnStatusChange\":false,\"docAssociationType\":1,\"viewFieldIdsData\":\"<root><views><viewid>2</viewid><view_name>ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>6</viewid><view_name>MB_ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>4</viewid><view_name>RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>5</viewid><view_name>FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>3</viewid><view_name>RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>8</viewid><view_name>MB_RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>1</viewid><view_name>ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>7</viewid><view_name>MB_ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>9</viewid><view_name>MB_RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>10</viewid><view_name>MB_FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views></root>\",\"createdMsgCount\":0,\"draft_count\":0,\"draftMsgId\":0,\"view_always_form_association\":false,\"view_always_doc_association\":false,\"auto_publish_to_folder\":false,\"default_folder_path\":\"\",\"default_folder_id\":\"\$\$YDWWpv\",\"allowExternalAccess\":0,\"embedFormContentInEmail\":0,\"canReplyViaEmail\":0,\"externalUsersOnly\":0,\"appTypeId\":2,\"dataCenterId\":0,\"allowViewAssociation\":0,\"infojetServerVersion\":1,\"isFormAvailableOffline\":0,\"allowDistributionByAll\":false,\"allowDistributionByRoles\":false,\"allowDistributionRoleIds\":\"\",\"canEditWithAppbuilder\":false,\"hasAppbuilderTemplateDraft\":false,\"isTemplateChanged\":false,\"viewsList\":[{\"viewId\":1,\"viewName\":\"ORI_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":2,\"viewName\":\"ORI_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":3,\"viewName\":\"RES_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":4,\"viewName\":\"RES_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":5,\"viewName\":\"FORM_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":6,\"viewName\":\"MB_ORI_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":7,\"viewName\":\"MB_ORI_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":8,\"viewName\":\"MB_RES_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":9,\"viewName\":\"MB_RES_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":10,\"viewName\":\"MB_FORM_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true}],\"isRecent\":false,\"allowLocationAssociation\":false,\"isLocationAssocMandatory\":false,\"bfpc\":\"0\$\$kFpU9W\",\"had\":\"0\$\$lVfG3Y\",\"isFromMarketplace\":false,\"isMarkDefault\":false,\"isNewlyCreated\":false,\"isAsycnProcess\":false},\"actionList\":[{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Assign Status\",\"actionID\":\"2\$\$r5ZUtw\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Attach Docs\",\"actionID\":\"5\$\$RvyG5d\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Distribute\",\"actionID\":\"6\$\$pwccPZ\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Acknowledgement\",\"actionID\":\"37\$\$vhxsnH\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Action\",\"actionID\":\"36\$\$bzONin\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Information\",\"actionID\":\"7\$\$X2RF5y\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":true,\"is_associated\":true,\"actionName\":\"Respond\",\"actionID\":\"3\$\$CPl6Fg\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Review Draft\",\"actionID\":\"34\$\$vhA0uD\",\"num_days\":2,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true}],\"formTypeGroupVO\":{\"formTypeGroupID\":341,\"formTypeGroupName\":\"Adoddle-All Apps\",\"generateURI\":true},\"statusList\":[{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Approve\",\"statusID\":1004,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":true,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed\",\"statusID\":3,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved\",\"statusID\":4,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved with Comments\",\"statusID\":5,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Rejected\",\"statusID\":6,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Open\",\"statusID\":1001,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Resolved\",\"statusID\":1002,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Verified\",\"statusID\":1003,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true}],\"isFormInherited\":false,\"generateURI\":true},\"createdFormsCount\":0,\"draftFormsCount\":0,\"templatetype\":1,\"appId\":2,\"formTypeName\":\"Fields\",\"totalForms\":0,\"formtypeGroupid\":341,\"isFavourite\":true,\"appBuilderID\":\"\",\"canViewDraftMsg\":false,\"formTypeGroupName\":\"Fields\",\"formGroupCode\":\"FID\",\"canCreateForm\":true,\"numActions\":0,\"crossWorkspaceID\":-1,\"instanceGroupId\":10381414,\"allow_associate_location\":false,\"numOverdueActions\":0,\"is_location_assoc_mandatory\":false,\"workspaceid\":2116416}",
          "FormTypeName": "Inline attachment",
          "FormGroupCode": "INL",
          "AppBuilderId": "INL",
          "TemplateTypeId": 2,
          "AppTypeId": 1
        }
      ]);

      String strAttachQuery = "SELECT ProjectId,FormTypeId,MsgId,AttachRevId,AssocDocRevisionId,AttachmentType,AttachAssocDetailJson FROM FormMsgAttachAndAssocListTbl";
      strAttachQuery = "$strAttachQuery WHERE ProjectId=2130192";
      strAttachQuery = "$strAttachQuery AND MsgId=123";
      strAttachQuery = "$strAttachQuery AND (AttachRevId=1690365038319370 OR AssocDocRevisionId=1690365038319370)";

      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strAttachQuery))
          .thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":123,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      String mapOfLocationListQuery = "SELECT * FROM LocationDetailTbl";
      mapOfLocationListQuery = "$mapOfLocationListQuery WHERE ProjectId=2130192 AND LocationId=183904;";
      when(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, mapOfLocationListQuery))
          .thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":123,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      var formTypeStatusListJson = fixture('formType_status_list.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/StatusListData.json")).thenReturn(formTypeStatusListJson);

      String? editHtmlResponse = await createFormLocalDataSource.getCreateOrRespondHtmlJson(EHtmlRequestType.editDraft, {"projectId": projectId, "formTypeId": formTypeId, "formId": formId, "msgId": "123"});
      expect(!editHtmlResponse.isNullOrEmpty(), true);
    });
  });

  group("Testing Offline - Edit & Distribute Html Form", () {
    test("Testing Offline - Edit & Distribute Html Response is not Empty", () async {
      var htmlFile = fixtureFileContent('files/2130192/FormTypes/11103151/ORI_VIEW.html');
      when(() => mockFileUtility.readFromFile("./test/fixtures/files/2130192/FormTypes/11103151/ORI_VIEW.html")).thenReturn(htmlFile);

      var jsonData = fixtureFileContent('files/2130192/FormTypes/11103151/data.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/files/2130192/FormTypes/11103151/data.json")).thenReturn(jsonData);

      var customAttributeData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/CustomAttributeData.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/CustomAttributeData.json")).thenReturn(customAttributeData);

      var fieldJsonData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/Fix-FieldData.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/Fix-FieldData.json")).thenReturn(fieldJsonData);

      var offlineCreateFormContent = fixtureFileContent('database/HTML5Form/offlineCreateForm.html');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/HTML5Form/offlineCreateForm.html")).thenReturn(offlineCreateFormContent);

      String dsFormGroupCODQuery = "SELECT CASE WHEN INSTR(frmTbl.Code,'(')>0 THEN SUBSTR(frmTbl.Code,0,INSTR(frmTbl.Code,'(')) WHEN LOWER(frmTbl.Code)='draft' OR frmTbl.IsDraft=1 THEN frmTpView.FormTypeGroupCode || '000' ELSE frmTbl.Code END AS DS_FORMID FROM FormListTbl frmTbl\n"
          "INNER JOIN FormGroupAndFormTypeListTbl frmTpView ON frmTpView.ProjectId=frmTbl.ProjectId AND frmTpView.FormTypeId=frmTbl.FormTypeId\n"
          "WHERE frmTbl.ProjectId=2130192 AND frmTbl.FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, dsFormGroupCODQuery)).thenReturn([]);

      String mapOfConfigListQuery = "SELECT prjTbl.ProjectId,prjTbl.ProjectName,prjTbl.DcId AS DcId,frmTpTbl.FormTypeId,frmTpTbl.FormTypeDetailJson,frmTpTbl.FormTypeName,frmTpTbl.FormTypeGroupCode AS FormGroupCode,frmTpTbl.AppBuilderId,frmTpTbl.TemplateTypeId,frmTpTbl.AppTypeId FROM ProjectDetailTbl prjTbl";
      mapOfConfigListQuery = "$mapOfConfigListQuery INNER JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=prjTbl.ProjectId";
      mapOfConfigListQuery = "$mapOfConfigListQuery WHERE frmTpTbl.ProjectId=2130192 AND frmTpTbl.FormTypeId=11103151";
      when(() => mockDatabaseManager.executeSelectFromTable(ProjectDao.tableName, mapOfConfigListQuery)).thenReturn([
        {
          "ProjectId": "2116416",
          "ProjectName": "!!PIN_ANY_APP_TYPE_20_9",
          "DcId": 1,
          "FormTypeId": "10616643",
          "FormTypeDetailJson":
              "{\"createFormsLimit\":0,\"canAccessPrivilegedForms\":true,\"formTypeID\":\"10381414\$\$9IBwDZ\",\"allow_attachments\":true,\"formTypesDetail\":{\"formTypeVO\":{\"formTypeID\":\"10381414\$\$9IBwDZ\",\"formTypeName\":\"Fields\",\"code\":\"FID\",\"use_controller\":false,\"response_allowed\":true,\"show_responses\":true,\"allow_reopening_form\":true,\"default_action\":\"3\$\$CPl6Fg\",\"is_default\":true,\"allow_forwarding\":false,\"allow_distribution_after_creation\":true,\"allow_distribution_originator\":true,\"allow_distribution_recipients\":false,\"allow_forward_originator\":false,\"allow_forward_recipients\":false,\"responders_collaborate\":false,\"continue_discussion\":false,\"hide_orgs_and_users\":false,\"has_hyperlink\":false,\"allow_attachments\":true,\"allow_doc_associates\":true,\"allow_form_associations\":true,\"allow_attributes\":false,\"associations_extend_doc_issue\":false,\"public_message\":false,\"browsable_attachment_folder\":false,\"has_overall_status\":true,\"is_instance\":true,\"form_type_group_id\":341,\"instance_group_id\":\"10381414\$\$9IBwDZ\",\"ctrl_change_status\":false,\"parent_formtype_id\":\"2171706\$\$6zD4x9\",\"orig_change_status\":true,\"orig_can_close\":false,\"upload_logo\":false,\"user_ref\":false,\"allow_comment_associations\":false,\"is_public\":true,\"is_active\":true,\"signatureBox\":\"000\",\"xsnFile\":\"2181422.xsn\$\$guzLhn\",\"xmlData\":\"<?mso-infoPathSolution name=\\\"urn:schemas-microsoft-com:office:infopath:ASI-Request-For-Information-Mobile-View:-myXSD-2008-07-03T04-59-35\\\" href=\\\"ASI_Request_For_Information_Mobile_View_tImEsTaMp516083820727589_516447\\\" solutionVersion=\\\"1.0.0.196\\\" productVersion=\\\"12.0.0\\\" PIVersion=\\\"1.0.0.0\\\" ?><?mso-application progid=\\\"InfoPath.Document\\\"?><my:myFields xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\" xmlns:xhtml=\\\"http://www.w3.org/1999/xhtml\\\" xmlns:my=\\\"http://schemas.microsoft.com/office/infopath/2003/myXSD/2008-07-03T04:59:35\\\" xmlns:xd=\\\"http://schemas.microsoft.com/office/infopath/2003\\\"><my:ORI_FORMTITLE/><my:FORM_CUSTOM_FIELDS><my:ORI_MSG_Custom_Fields><my:Description/></my:ORI_MSG_Custom_Fields><my:RES_MSG_Custom_Fields><my:Response/></my:RES_MSG_Custom_Fields></my:FORM_CUSTOM_FIELDS><my:Asite_System_Data_Read_Only><my:_1_User_Data><my:DS_WORKINGUSER/><my:DS_WORKINGUSERROLE/></my:_1_User_Data><my:_2_Printing_Data><my:DS_PRINTEDBY/><my:DS_PRINTEDON/></my:_2_Printing_Data><my:_3_Project_Data><my:DS_PROJECTNAME/><my:DS_CLIENTDS_CLIENT/></my:_3_Project_Data><my:_4_Form_Type_Data><my:DS_FORMNAME/><my:DS_FORMGROUPCODE/></my:_4_Form_Type_Data><my:_5_Form_Data><my:DS_FORMID/><my:DS_ORIGINATOR/><my:DS_DATEOFISSUE/><my:DS_DISTRIBUTION/><my:DS_CONTROLLERNAME/><my:DS_ATTRIBUTES/><my:Status_Data><my:DS_FORMSTATUS/><my:DS_CLOSEDUEDATE/><my:DS_APPROVEDBY/><my:DS_APPROVEDON/><my:DS_ALL_FORMSTATUS>Open</my:DS_ALL_FORMSTATUS></my:Status_Data><my:DS_CLOSE_DUE_DATE/></my:_5_Form_Data><my:_6_Form_MSG_Data><my:DS_MSGID/><my:DS_MSGCREATOR/><my:DS_MSGDATE/><my:DS_MSGSTATUS/><my:DS_MSGRELEASEDATE/><my:ORI_MSG_Data><my:DS_DOC_ASSOCIATIONS_ORI/><my:DS_FORM_ASSOCIATIONS_ORI/><my:DS_ATTACHMENTS_ORI/></my:ORI_MSG_Data></my:_6_Form_MSG_Data></my:Asite_System_Data_Read_Only><my:Asite_System_Data_Read_Write><my:ORI_MSG_Fields><my:ORI_USERREF/><my:DS_AUTODISTRIBUTE>2</my:DS_AUTODISTRIBUTE><my:DS_ACTIONDUEDATE>3</my:DS_ACTIONDUEDATE><my:DS_FORMACTIONS>3 # Respond</my:DS_FORMACTIONS><my:DS_PROJDISTUSERS/></my:ORI_MSG_Fields></my:Asite_System_Data_Read_Write><my:Assign_To/></my:myFields>\",\"templateType\":1,\"responsePattern\":0,\"fixedFieldIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"displayFileName\":\"ASI_Request_For_Information_Mobile_View.xsn\$\$z08kl4\",\"viewIds\":\"2,6,4,3,8,10,7,9,5,1,\",\"mandatoryDistribution\":0,\"responseFromAll\":false,\"subTemplateType\":0,\"integrateExchange\":false,\"allowEditingORI\":false,\"allowImportExcelInEditORI\":false,\"isOverwriteExcelInEditORI\":true,\"enableECatalague\":false,\"formGroupName\":\"Fields\",\"projectId\":\"2116416\$\$s2Ieys\",\"clonedFormTypeId\":0,\"appBuilderFormIDCode\":\"\",\"loginUserId\":2017529,\"xslFileName\":\"\",\"allowImportForm\":false,\"allowWorkspaceLink\":false,\"linkedWorkspaceProjectId\":\"-1\$\$BUrsqP\",\"createFormsLimit\":0,\"spellCheckPrefs\":\"10\",\"isMobile\":false,\"createFormsLimitLevel\":0,\"restrictChangeFormStatus\":0,\"enableDraftResponses\":0,\"isDistributionFromGroupOnly\":true,\"isAutoCreateOnStatusChange\":false,\"docAssociationType\":1,\"viewFieldIdsData\":\"<root><views><viewid>2</viewid><view_name>ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>6</viewid><view_name>MB_ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>4</viewid><view_name>RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>5</viewid><view_name>FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>3</viewid><view_name>RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>8</viewid><view_name>MB_RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>1</viewid><view_name>ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>7</viewid><view_name>MB_ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>9</viewid><view_name>MB_RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>10</viewid><view_name>MB_FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views></root>\",\"createdMsgCount\":0,\"draft_count\":0,\"draftMsgId\":0,\"view_always_form_association\":false,\"view_always_doc_association\":false,\"auto_publish_to_folder\":false,\"default_folder_path\":\"\",\"default_folder_id\":\"\$\$YDWWpv\",\"allowExternalAccess\":0,\"embedFormContentInEmail\":0,\"canReplyViaEmail\":0,\"externalUsersOnly\":0,\"appTypeId\":2,\"dataCenterId\":0,\"allowViewAssociation\":0,\"infojetServerVersion\":1,\"isFormAvailableOffline\":0,\"allowDistributionByAll\":false,\"allowDistributionByRoles\":false,\"allowDistributionRoleIds\":\"\",\"canEditWithAppbuilder\":false,\"hasAppbuilderTemplateDraft\":false,\"isTemplateChanged\":false,\"viewsList\":[{\"viewId\":1,\"viewName\":\"ORI_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":2,\"viewName\":\"ORI_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":3,\"viewName\":\"RES_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":4,\"viewName\":\"RES_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":5,\"viewName\":\"FORM_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":6,\"viewName\":\"MB_ORI_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":7,\"viewName\":\"MB_ORI_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":8,\"viewName\":\"MB_RES_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":9,\"viewName\":\"MB_RES_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":10,\"viewName\":\"MB_FORM_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true}],\"isRecent\":false,\"allowLocationAssociation\":false,\"isLocationAssocMandatory\":false,\"bfpc\":\"0\$\$kFpU9W\",\"had\":\"0\$\$lVfG3Y\",\"isFromMarketplace\":false,\"isMarkDefault\":false,\"isNewlyCreated\":false,\"isAsycnProcess\":false},\"actionList\":[{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Assign Status\",\"actionID\":\"2\$\$r5ZUtw\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Attach Docs\",\"actionID\":\"5\$\$RvyG5d\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Distribute\",\"actionID\":\"6\$\$pwccPZ\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Acknowledgement\",\"actionID\":\"37\$\$vhxsnH\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Action\",\"actionID\":\"36\$\$bzONin\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Information\",\"actionID\":\"7\$\$X2RF5y\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":true,\"is_associated\":true,\"actionName\":\"Respond\",\"actionID\":\"3\$\$CPl6Fg\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Review Draft\",\"actionID\":\"34\$\$vhA0uD\",\"num_days\":2,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true}],\"formTypeGroupVO\":{\"formTypeGroupID\":341,\"formTypeGroupName\":\"Adoddle-All Apps\",\"generateURI\":true},\"statusList\":[{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Approve\",\"statusID\":1004,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":true,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed\",\"statusID\":3,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved\",\"statusID\":4,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved with Comments\",\"statusID\":5,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Rejected\",\"statusID\":6,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Open\",\"statusID\":1001,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Resolved\",\"statusID\":1002,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Verified\",\"statusID\":1003,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true}],\"isFormInherited\":false,\"generateURI\":true},\"createdFormsCount\":0,\"draftFormsCount\":0,\"templatetype\":1,\"appId\":2,\"formTypeName\":\"Fields\",\"totalForms\":0,\"formtypeGroupid\":341,\"isFavourite\":true,\"appBuilderID\":\"\",\"canViewDraftMsg\":false,\"formTypeGroupName\":\"Fields\",\"formGroupCode\":\"FID\",\"canCreateForm\":true,\"numActions\":0,\"crossWorkspaceID\":-1,\"instanceGroupId\":10381414,\"allow_associate_location\":false,\"numOverdueActions\":0,\"is_location_assoc_mandatory\":false,\"workspaceid\":2116416}",
          "FormTypeName": "Inline attachment",
          "FormGroupCode": "INL",
          "AppBuilderId": "INL",
          "TemplateTypeId": 2,
          "AppTypeId": 1
        }
      ]);

      var formMessageVOFromDBQuery = "SELECT * FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652 AND MsgId=(SELECT MAX(CAST(MsgId AS INTEGER)) FROM FormMessageListTbl WHERE ProjectId=2130192 AND FormId=11607652 AND MsgTypeId IN (1,3) AND IsDraft=0)";
      var formMessageJson = fixture('form_message_db.json');
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMessageVOFromDBQuery)).thenReturn([jsonDecode(formMessageJson)]);

      String dsCloseDueDateQuery = "SELECT JsonData FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652\n"
          "AND MsgId=12309970";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, dsCloseDueDateQuery)).thenReturn([]);

      String isDraftResMsgQuery = "SELECT MsgStatusId FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652 AND MsgId=12309970\n"
          "AND MsgTypeId=2 AND (MsgStatusId=19 OR OfflineRequestData<>'')";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, isDraftResMsgQuery)).thenReturn([]);

      String formMessageVOFromDB1Query = "SELECT * FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652 AND MsgId=12309970";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMessageVOFromDB1Query)).thenReturn([jsonDecode(formMessageJson)]);


      String strAttachQuery = "SELECT ProjectId,FormTypeId,MsgId,AttachRevId,AssocDocRevisionId,AttachmentType,AttachAssocDetailJson FROM FormMsgActionListTbl";
      strAttachQuery = "$strAttachQuery WHERE ProjectId=2130192";
      strAttachQuery = "$strAttachQuery AND MsgId=123";
      strAttachQuery = "$strAttachQuery AND (AttachRevId=1690365038319370 OR AssocDocRevisionId=1690365038319370)";

      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strAttachQuery))
          .thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":123,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      String mapOfLocationListQuery = "SELECT * FROM LocationDetailTbl";
      mapOfLocationListQuery = "$mapOfLocationListQuery WHERE ProjectId=2130192 AND LocationId=183904;";
      when(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, mapOfLocationListQuery)).thenReturn([
        {"ProjectId": "2130192", "FolderId": "115096357", "LocationId": 183682, "LocationTitle": "Basement", "ParentFolderId": 115096349, "ParentLocationId": 183679, "PermissionValue": 0, "LocationPath": "Site Quality Demo\01 Vijay_Test\Plan-1\Basement", "SiteId": 0, "DocumentId": "13351081", "RevisionId": "26773045", "AnnotationId": "1fc95526-3610-5163-e2c8-c915a692c3d4", "LocationCoordinate": "{\"x1\":593.98,\"y1\":669.61,\"x2\":803.92,\"y2\":522.8199999999999}", "PageNumber": 1, "IsPublic": 0, "IsFavorite": 0, "IsSite": 0, "IsCalibrated": 1, "IsFileUploaded": 0, "IsActive": 1, "HasSubFolder": 0, "CanRemoveOffline": 0, "IsMarkOffline": 1, "SyncStatus": 0, "LastSyncTimeStamp": ""}
      ]);

      var distributionData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/DistributionData.json');
      //distributionData?["distData"]?["groupuserList"] = [{"distGroupId":"3","actionID":"6","userID":"1161363","orgID":3,"actionName":"Assign Status","orgName":"Asite Solutions","userName":"Chandresh Patel","userSubscriptionTypeId":0,"userStatus":0,"user_type":1,"emailId":"chandreshpatel@asite.com","fname":"Chandresh","lname":"Patel","userImageName":"https://portalqa.asite.com/profilefiles/member_photos/photo_1161363_thumbnail.jpg?v=1673263342000","defaultDays":2}];

      when(() => mockFileUtility.readFromFile("../test/fixtures/database/1_808581/2130192/FormTypes/11103151/DistributionData.json")).thenReturn(distributionData);

      when(() => mockFileUtility.readDataFromFile(any())).thenAnswer((_) => Future.value(htmlFile));

      String strAttachQuery1 = "SELECT frmMsgTbl.MsgTypeCode,frmMsgAttacTbl.AttachAssocDetailJson FROM FormMsgAttachAndAssocListTbl frmMsgAttacTbl\n"
          "INNER JOIN FormMessageListTbl frmMsgTbl ON frmMsgTbl.ProjectId=frmMsgAttacTbl.ProjectId\n"
          "AND frmMsgTbl.FormId=frmMsgAttacTbl.FormId AND frmMsgTbl.MsgId=frmMsgAttacTbl.MsgId\n"
          "WHERE frmMsgAttacTbl.AttachmentType=0 AND frmMsgAttacTbl.ProjectId=2130192 AND frmMsgAttacTbl.FormId=11607652";

      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strAttachQuery1))
          .thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":123,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      String dsDocAttachmentsAllQuery = "SELECT ProjectId,AttachAssocDetailJson FROM FormMsgAttachAndAssocListTbl\n"
          "WHERE AttachmentType=3 AND ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, dsDocAttachmentsAllQuery)).thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":123,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      String dsGetMSGDistributionListQuery = "SELECT frmMsgTbl.ProjectId,frmMsgTbl.FormId,frmMsgTbl.MsgId,frmTpCTE.AppBuilderId || CASE LENGTH(CAST(frmTbl.FormNumber AS TEXT)) WHEN 0 THEN '000' WHEN 1 THEN '00' WHEN 2 THEN '0' ELSE '' END\n"
          " || CAST(frmTbl.FormNumber AS TEXT) AS AppBuilderIdCode,frmMsgTbl.SentActions FROM FormMessageListTbl frmMsgTbl\n"
          "INNER JOIN FormGroupAndFormTypeListTbl frmTpCTE ON frmTpCTE.ProjectId=frmMsgTbl.ProjectId AND frmTpCTE.FormTypeId=frmMsgTbl.FormTypeId\n"
          "INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId\n"
          "WHERE frmMsgTbl.ProjectId=2130192 AND frmMsgTbl.FormId=11607652 AND frmMsgTbl.MsgId=12309970";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, dsGetMSGDistributionListQuery)).thenReturn([jsonDecode(formMessageJson)]);


      String getSPDataGETRECENTDEFECTS = "SELECT frmTbl.ProjectId,frmTbl.FormId,frmTbl.Code,frmTpTbl.FormTypeGroupCode,frmTbl.FormTitle,frmTbl.ObservationDefectType,frmTbl.LocationId,locTbl.LocationTitle,locTbl.LocationPath,frmMsgTbl.JsonData FROM FormListTbl frmTbl\n"
      "INNER JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=frmTbl.ProjectId AND frmTpTbl.FormTypeId=frmTbl.FormTypeId\n"
      "INNER JOIN LocationDetailTbl locTbl ON locTbl.ProjectId=frmTbl.ProjectId AND locTbl.LocationId=frmTbl.LocationId\n"
      "INNER JOIN FormMessageListTbl frmMsgTbl ON frmMsgTbl.ProjectId=frmTbl.ProjectId AND frmMsgTbl.FormId=frmTbl.FormId AND frmMsgTbl.MsgTypeId=1 AND frmMsgTbl.IsDraft=0\n"
      "WHERE frmTbl.ProjectId=2130192 AND frmTbl.OriginatorId=808581 AND frmTpTbl.InstanceGroupId=\n"
      "(SELECT InstanceGroupId FROM FormGroupAndFormTypeListTbl WHERE ProjectId=2130192 AND FormTypeId=11103151)\n"
      "ORDER BY frmTbl.FormCreationDateInMS DESC\n"
      "LIMIT 5 OFFSET 0";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, getSPDataGETRECENTDEFECTS)).thenReturn([]);

      var formTypeStatusListJson = fixture('formType_status_list.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/StatusListData.json")).thenReturn(formTypeStatusListJson);

      String? editHtmlResponse = await createFormLocalDataSource.getCreateOrRespondHtmlJson(EHtmlRequestType.editAndDistribute, {"projectId": projectId, "formTypeId": formTypeId, "formId": formId, "msgId": "123"});
      expect(!editHtmlResponse.isNullOrEmpty(), true);
    });
  });

  group("Testing Offline - Edit Ori  Html Form", () {
    test("Testing Offline - Edit Ori Html Response is not Empty", () async {
      var htmlFile = fixtureFileContent('files/2130192/FormTypes/11103151/ORI_VIEW.html');
      when(() => mockFileUtility.readFromFile("./test/fixtures/files/2130192/FormTypes/11103151/ORI_VIEW.html")).thenReturn(htmlFile);

      var jsonData = fixtureFileContent('files/2130192/FormTypes/11103151/data.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/files/2130192/FormTypes/11103151/data.json")).thenReturn(jsonData);

      var customAttributeData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/CustomAttributeData.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/CustomAttributeData.json")).thenReturn(customAttributeData);

      var fieldJsonData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/Fix-FieldData.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/Fix-FieldData.json")).thenReturn(fieldJsonData);

      var offlineCreateFormContent = fixtureFileContent('database/HTML5Form/offlineCreateForm.html');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/HTML5Form/offlineCreateForm.html")).thenReturn(offlineCreateFormContent);

      String strAttachQuery = "SELECT ProjectId,FormTypeId,MsgId,AttachRevId,AssocDocRevisionId,AttachmentType,AttachAssocDetailJson FROM FormMsgAttachAndAssocListTbl";
      strAttachQuery = "$strAttachQuery WHERE ProjectId=2130192";
      strAttachQuery = "$strAttachQuery AND MsgId=123";
      strAttachQuery = "$strAttachQuery AND (AttachRevId=1690365038319370 OR AssocDocRevisionId=1690365038319370)";

      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strAttachQuery))
          .thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":123,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      var formTypeStatusListJson = fixture('formType_status_list.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/StatusListData.json")).thenReturn(formTypeStatusListJson);

      String? editHtmlResponse = await createFormLocalDataSource.getCreateOrRespondHtmlJson(EHtmlRequestType.editOri, {"projectId": projectId, "formTypeId": formTypeId, "formId": formId, "msgId": "123"});
      expect(!editHtmlResponse.isNullOrEmpty(), true);
    });
  });

  group("Testing Offline - Edit Draft Html FormData", () {
    test("Testing Offline - editDraftHtmlFormData", () async {
      var htmlFile = fixtureFileContent('files/2130192/FormTypes/11103151/ORI_VIEW.html');
      when(() => mockFileUtility.readFromFile("./test/fixtures/files/2130192/FormTypes/11103151/ORI_VIEW.html")).thenReturn(htmlFile);

      var jsonData = fixtureFileContent('files/2130192/FormTypes/11103151/data.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/files/2130192/FormTypes/11103151/data.json")).thenReturn(jsonData);

      var customAttributeData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/CustomAttributeData.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/CustomAttributeData.json")).thenReturn(customAttributeData);

      var fieldJsonData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/Fix-FieldData.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/Fix-FieldData.json")).thenReturn(fieldJsonData);

      var offlineCreateFormContent = fixtureFileContent('database/HTML5Form/offlineCreateForm.html');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/HTML5Form/offlineCreateForm.html")).thenReturn(offlineCreateFormContent);

      String dsFormGroupCODQuery = "SELECT CASE WHEN INSTR(frmTbl.Code,'(')>0 THEN SUBSTR(frmTbl.Code,0,INSTR(frmTbl.Code,'(')) WHEN LOWER(frmTbl.Code)='draft' OR frmTbl.IsDraft=1 THEN frmTpView.FormTypeGroupCode || '000' ELSE frmTbl.Code END AS DS_FORMID FROM FormListTbl frmTbl\n"
          "INNER JOIN FormGroupAndFormTypeListTbl frmTpView ON frmTpView.ProjectId=frmTbl.ProjectId AND frmTpView.FormTypeId=frmTbl.FormTypeId\n"
          "WHERE frmTbl.ProjectId=2130192 AND frmTbl.FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, dsFormGroupCODQuery)).thenReturn([]);

      String formMessageVOFromDBQuery = "SELECT * FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652 AND MsgId=123";
      var formMessageJson = fixture('form_message_db.json');
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMessageVOFromDBQuery)).thenReturn([jsonDecode(formMessageJson)]);

      String strAttachQuery = "SELECT ProjectId,FormTypeId,MsgId,AttachRevId,AssocDocRevisionId,AttachmentType,AttachAssocDetailJson FROM FormMsgAttachAndAssocListTbl";
      strAttachQuery = "$strAttachQuery WHERE ProjectId=2130192";
      strAttachQuery = "$strAttachQuery AND MsgId=123";
      strAttachQuery = "$strAttachQuery AND (AttachRevId=1690365038319370 OR AssocDocRevisionId=1690365038319370)";

      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strAttachQuery))
          .thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":123,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      String isDraftQuery = "SELECT MsgStatusId FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652\n"
          "AND MsgTypeId=1 AND (MsgStatusId=19 OR OfflineRequestData<>'')";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, isDraftQuery)).thenReturn([]);

      String dsCloseDueDateQuery = "SELECT JsonData FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652\n"
          "AND MsgId=123";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, dsCloseDueDateQuery)).thenReturn([]);

      String oriFormTitleQuery = "SELECT FormTitle FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, oriFormTitleQuery)).thenReturn([
        {"FormTitle": "Test Form"}
      ]);

      String oriUserREFQuery = "SELECT UserRefCode FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, oriUserREFQuery)).thenReturn([
        {"UserRefCode": "ORI001"}
      ]);

      String allLocationByProjectPFQuery = "SELECT prjTbl.ProjectName, locTbl.* FROM LocationDetailTbl locTbl\n"
          "INNER JOIN ProjectDetailTbl prjTbl ON prjTbl.ProjectId=locTbl.ProjectId\n"
          "WHERE locTbl.IsActive=1 AND locTbl.IsMarkOffline=1 AND locTbl.ProjectId=2130192\n"
          "ORDER BY locTbl.LocationPath COLLATE NOCASE";
      when(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, allLocationByProjectPFQuery)).thenReturn([
        {"ProjectName": "demo"}
      ]);

      String dsFormStatusQuery = "SELECT Status FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, dsFormStatusQuery)).thenReturn([]);

      String dsIncompleteActionsQuery = "SELECT * FROM FormMsgActionListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652\n"
          "AND ActionStatus=0 AND RecipientUserId=808581";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageActionDao.tableName, dsIncompleteActionsQuery)).thenReturn([]);

      String recentDefectQuery = "SELECT frmTbl.ProjectId,frmTbl.FormId,frmTbl.Code,frmTpTbl.FormTypeGroupCode,frmTbl.FormTitle,frmTbl.ObservationDefectType,frmTbl.LocationId,locTbl.LocationTitle,locTbl.LocationPath,frmMsgTbl.JsonData FROM FormListTbl frmTbl\n"
          "INNER JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=frmTbl.ProjectId AND frmTpTbl.FormTypeId=frmTbl.FormTypeId\n"
          "INNER JOIN LocationDetailTbl locTbl ON locTbl.ProjectId=frmTbl.ProjectId AND locTbl.LocationId=frmTbl.LocationId\n"
          "INNER JOIN FormMessageListTbl frmMsgTbl ON frmMsgTbl.ProjectId=frmTbl.ProjectId AND frmMsgTbl.FormId=frmTbl.FormId AND frmMsgTbl.MsgTypeId=1 AND frmMsgTbl.IsDraft=0\n"
          "WHERE frmTbl.ProjectId=2130192 AND frmTbl.OriginatorId=808581 AND frmTpTbl.InstanceGroupId=\n"
          "(SELECT InstanceGroupId FROM FormGroupAndFormTypeListTbl WHERE ProjectId=2130192 AND FormTypeId=11103151)\n"
          "ORDER BY frmTbl.FormCreationDateInMS DESC\n"
          "LIMIT 5 OFFSET 0";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, recentDefectQuery)).thenReturn([
        {
          "ProjectId": "2116416",
          "ProjectName": "!!PIN_ANY_APP_TYPE_20_9",
          "DcId": 1,
          "FormTypeId": "10616643",
          "JsonData":
              "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"DistributionDays\":\"0\",\"Organization\":\"\",\"DefectTyoe\":\"Computer\",\"ExpectedFinishDate\":\"2023-08-08\",\"DefectDescription\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"707447#Vijay Mavadiya (5336), Asite Solutions\"}},\"Defect_Description\":\"test description\",\"LocationName\":\"01 Vijay_Test\",\"StartDate\":\"2023-08-01\",\"ActualFinishDate\":\"\",\"ExpectedFinishDays\":\"5\",\"DS_Logo\":\"images/asite.gif\",\"LastResponder_For_AssignedTo\":\"707447\",\"TaskType\":\"Defect\",\"isCalibrated\":false,\"ORI_FORMTITLE\":\"Test Offlinr VJ Attachment\",\"attachements\":[{\"attachedDocs\":\"\"}],\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"Assigned\":\"Vijay Mavadiya (5336), Asite Solutions\",\"CurrStage\":\"1\",\"Recent_Defects\":\"\",\"FormCreationDate\":\"\",\"StartDateDisplay\":\"01-Aug-2023\",\"LastResponder_For_Originator\":\"2017529\",\"PF_Location_Detail\":\"183678|0|null|0\",\"Username\":\"\",\"ORI_USERREF\":\"\",\"Location\":\"183678|01 Vijay_Test|01 Vijay_Test\"},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"SHResponse\":\"Yes\",\"ShowHideFlag\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_CREATE\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\",\"DS_FORMAUTONO_ADD\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_Get_All_Responses\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"attachments\":[],\"Asite_System_Data_Read_Only\":{\"_2_Printing_Data\":{\"DS_PRINTEDON\":\"\",\"DS_PRINTEDBY\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\",\"DS_FORMNAME\":\"Site Tasks\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"\",\"DS_CLIENT\":\"\"},\"_5_Form_Data\":{\"DS_DATEOFISSUE\":\"\",\"DS_ISDRAFT_RES_MSG\":\"\",\"Status_Data\":{\"DS_APPROVEDON\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_APPROVEDBY\":\"\",\"DS_CLOSE_DUE_DATE\":\"2023-08-08\",\"DS_FORMSTATUS\":\"\"},\"DS_DISTRIBUTION\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT_RES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_FORMID\":\"\"},\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_6_Form_MSG_Data\":{\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGID\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_PROJUSERS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_ACTIONDUEDATE\":\"5\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_PROJDISTUSERS\":\"707447\"}]}},\"selectedControllerUserId\":\"\"}}",
          "FormTypeName": "Inline attachment",
          "FormGroupCode": "INL",
          "AppBuilderId": "INL",
          "TemplateTypeId": 2,
          "AppTypeId": 1
        }
      ]);

      String mapOfConfigListQuery = "SELECT prjTbl.ProjectId,prjTbl.ProjectName,prjTbl.DcId AS DcId,frmTpTbl.FormTypeId,frmTpTbl.FormTypeDetailJson,frmTpTbl.FormTypeName,frmTpTbl.FormTypeGroupCode AS FormGroupCode,frmTpTbl.AppBuilderId,frmTpTbl.TemplateTypeId,frmTpTbl.AppTypeId FROM ProjectDetailTbl prjTbl";
      mapOfConfigListQuery = "$mapOfConfigListQuery INNER JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=prjTbl.ProjectId";
      mapOfConfigListQuery = "$mapOfConfigListQuery WHERE frmTpTbl.ProjectId=2130192 AND frmTpTbl.FormTypeId=11103151";
      when(() => mockDatabaseManager.executeSelectFromTable(ProjectDao.tableName, mapOfConfigListQuery)).thenReturn([
        {
          "ProjectId": "2116416",
          "ProjectName": "!!PIN_ANY_APP_TYPE_20_9",
          "DcId": 1,
          "FormTypeId": "10616643",
          "FormTypeDetailJson":
              "{\"createFormsLimit\":0,\"canAccessPrivilegedForms\":true,\"formTypeID\":\"10381414\$\$9IBwDZ\",\"allow_attachments\":true,\"formTypesDetail\":{\"formTypeVO\":{\"formTypeID\":\"10381414\$\$9IBwDZ\",\"formTypeName\":\"Fields\",\"code\":\"FID\",\"use_controller\":false,\"response_allowed\":true,\"show_responses\":true,\"allow_reopening_form\":true,\"default_action\":\"3\$\$CPl6Fg\",\"is_default\":true,\"allow_forwarding\":false,\"allow_distribution_after_creation\":true,\"allow_distribution_originator\":true,\"allow_distribution_recipients\":false,\"allow_forward_originator\":false,\"allow_forward_recipients\":false,\"responders_collaborate\":false,\"continue_discussion\":false,\"hide_orgs_and_users\":false,\"has_hyperlink\":false,\"allow_attachments\":true,\"allow_doc_associates\":true,\"allow_form_associations\":true,\"allow_attributes\":false,\"associations_extend_doc_issue\":false,\"public_message\":false,\"browsable_attachment_folder\":false,\"has_overall_status\":true,\"is_instance\":true,\"form_type_group_id\":341,\"instance_group_id\":\"10381414\$\$9IBwDZ\",\"ctrl_change_status\":false,\"parent_formtype_id\":\"2171706\$\$6zD4x9\",\"orig_change_status\":true,\"orig_can_close\":false,\"upload_logo\":false,\"user_ref\":false,\"allow_comment_associations\":false,\"is_public\":true,\"is_active\":true,\"signatureBox\":\"000\",\"xsnFile\":\"2181422.xsn\$\$guzLhn\",\"xmlData\":\"<?mso-infoPathSolution name=\\\"urn:schemas-microsoft-com:office:infopath:ASI-Request-For-Information-Mobile-View:-myXSD-2008-07-03T04-59-35\\\" href=\\\"ASI_Request_For_Information_Mobile_View_tImEsTaMp516083820727589_516447\\\" solutionVersion=\\\"1.0.0.196\\\" productVersion=\\\"12.0.0\\\" PIVersion=\\\"1.0.0.0\\\" ?><?mso-application progid=\\\"InfoPath.Document\\\"?><my:myFields xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\" xmlns:xhtml=\\\"http://www.w3.org/1999/xhtml\\\" xmlns:my=\\\"http://schemas.microsoft.com/office/infopath/2003/myXSD/2008-07-03T04:59:35\\\" xmlns:xd=\\\"http://schemas.microsoft.com/office/infopath/2003\\\"><my:ORI_FORMTITLE/><my:FORM_CUSTOM_FIELDS><my:ORI_MSG_Custom_Fields><my:Description/></my:ORI_MSG_Custom_Fields><my:RES_MSG_Custom_Fields><my:Response/></my:RES_MSG_Custom_Fields></my:FORM_CUSTOM_FIELDS><my:Asite_System_Data_Read_Only><my:_1_User_Data><my:DS_WORKINGUSER/><my:DS_WORKINGUSERROLE/></my:_1_User_Data><my:_2_Printing_Data><my:DS_PRINTEDBY/><my:DS_PRINTEDON/></my:_2_Printing_Data><my:_3_Project_Data><my:DS_PROJECTNAME/><my:DS_CLIENTDS_CLIENT/></my:_3_Project_Data><my:_4_Form_Type_Data><my:DS_FORMNAME/><my:DS_FORMGROUPCODE/></my:_4_Form_Type_Data><my:_5_Form_Data><my:DS_FORMID/><my:DS_ORIGINATOR/><my:DS_DATEOFISSUE/><my:DS_DISTRIBUTION/><my:DS_CONTROLLERNAME/><my:DS_ATTRIBUTES/><my:Status_Data><my:DS_FORMSTATUS/><my:DS_CLOSEDUEDATE/><my:DS_APPROVEDBY/><my:DS_APPROVEDON/><my:DS_ALL_FORMSTATUS>Open</my:DS_ALL_FORMSTATUS></my:Status_Data><my:DS_CLOSE_DUE_DATE/></my:_5_Form_Data><my:_6_Form_MSG_Data><my:DS_MSGID/><my:DS_MSGCREATOR/><my:DS_MSGDATE/><my:DS_MSGSTATUS/><my:DS_MSGRELEASEDATE/><my:ORI_MSG_Data><my:DS_DOC_ASSOCIATIONS_ORI/><my:DS_FORM_ASSOCIATIONS_ORI/><my:DS_ATTACHMENTS_ORI/></my:ORI_MSG_Data></my:_6_Form_MSG_Data></my:Asite_System_Data_Read_Only><my:Asite_System_Data_Read_Write><my:ORI_MSG_Fields><my:ORI_USERREF/><my:DS_AUTODISTRIBUTE>2</my:DS_AUTODISTRIBUTE><my:DS_ACTIONDUEDATE>3</my:DS_ACTIONDUEDATE><my:DS_FORMACTIONS>3 # Respond</my:DS_FORMACTIONS><my:DS_PROJDISTUSERS/></my:ORI_MSG_Fields></my:Asite_System_Data_Read_Write><my:Assign_To/></my:myFields>\",\"templateType\":1,\"responsePattern\":0,\"fixedFieldIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"displayFileName\":\"ASI_Request_For_Information_Mobile_View.xsn\$\$z08kl4\",\"viewIds\":\"2,6,4,3,8,10,7,9,5,1,\",\"mandatoryDistribution\":0,\"responseFromAll\":false,\"subTemplateType\":0,\"integrateExchange\":false,\"allowEditingORI\":false,\"allowImportExcelInEditORI\":false,\"isOverwriteExcelInEditORI\":true,\"enableECatalague\":false,\"formGroupName\":\"Fields\",\"projectId\":\"2116416\$\$s2Ieys\",\"clonedFormTypeId\":0,\"appBuilderFormIDCode\":\"\",\"loginUserId\":2017529,\"xslFileName\":\"\",\"allowImportForm\":false,\"allowWorkspaceLink\":false,\"linkedWorkspaceProjectId\":\"-1\$\$BUrsqP\",\"createFormsLimit\":0,\"spellCheckPrefs\":\"10\",\"isMobile\":false,\"createFormsLimitLevel\":0,\"restrictChangeFormStatus\":0,\"enableDraftResponses\":0,\"isDistributionFromGroupOnly\":true,\"isAutoCreateOnStatusChange\":false,\"docAssociationType\":1,\"viewFieldIdsData\":\"<root><views><viewid>2</viewid><view_name>ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>6</viewid><view_name>MB_ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>4</viewid><view_name>RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>5</viewid><view_name>FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>3</viewid><view_name>RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>8</viewid><view_name>MB_RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>1</viewid><view_name>ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>7</viewid><view_name>MB_ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>9</viewid><view_name>MB_RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>10</viewid><view_name>MB_FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views></root>\",\"createdMsgCount\":0,\"draft_count\":0,\"draftMsgId\":0,\"view_always_form_association\":false,\"view_always_doc_association\":false,\"auto_publish_to_folder\":false,\"default_folder_path\":\"\",\"default_folder_id\":\"\$\$YDWWpv\",\"allowExternalAccess\":0,\"embedFormContentInEmail\":0,\"canReplyViaEmail\":0,\"externalUsersOnly\":0,\"appTypeId\":2,\"dataCenterId\":0,\"allowViewAssociation\":0,\"infojetServerVersion\":1,\"isFormAvailableOffline\":0,\"allowDistributionByAll\":false,\"allowDistributionByRoles\":false,\"allowDistributionRoleIds\":\"\",\"canEditWithAppbuilder\":false,\"hasAppbuilderTemplateDraft\":false,\"isTemplateChanged\":false,\"viewsList\":[{\"viewId\":1,\"viewName\":\"ORI_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":2,\"viewName\":\"ORI_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":3,\"viewName\":\"RES_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":4,\"viewName\":\"RES_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":5,\"viewName\":\"FORM_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":6,\"viewName\":\"MB_ORI_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":7,\"viewName\":\"MB_ORI_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":8,\"viewName\":\"MB_RES_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":9,\"viewName\":\"MB_RES_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":10,\"viewName\":\"MB_FORM_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true}],\"isRecent\":false,\"allowLocationAssociation\":false,\"isLocationAssocMandatory\":false,\"bfpc\":\"0\$\$kFpU9W\",\"had\":\"0\$\$lVfG3Y\",\"isFromMarketplace\":false,\"isMarkDefault\":false,\"isNewlyCreated\":false,\"isAsycnProcess\":false},\"actionList\":[{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Assign Status\",\"actionID\":\"2\$\$r5ZUtw\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Attach Docs\",\"actionID\":\"5\$\$RvyG5d\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Distribute\",\"actionID\":\"6\$\$pwccPZ\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Acknowledgement\",\"actionID\":\"37\$\$vhxsnH\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Action\",\"actionID\":\"36\$\$bzONin\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Information\",\"actionID\":\"7\$\$X2RF5y\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":true,\"is_associated\":true,\"actionName\":\"Respond\",\"actionID\":\"3\$\$CPl6Fg\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Review Draft\",\"actionID\":\"34\$\$vhA0uD\",\"num_days\":2,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true}],\"formTypeGroupVO\":{\"formTypeGroupID\":341,\"formTypeGroupName\":\"Adoddle-All Apps\",\"generateURI\":true},\"statusList\":[{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Approve\",\"statusID\":1004,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":true,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed\",\"statusID\":3,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved\",\"statusID\":4,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved with Comments\",\"statusID\":5,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Rejected\",\"statusID\":6,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Open\",\"statusID\":1001,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Resolved\",\"statusID\":1002,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Verified\",\"statusID\":1003,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true}],\"isFormInherited\":false,\"generateURI\":true},\"createdFormsCount\":0,\"draftFormsCount\":0,\"templatetype\":1,\"appId\":2,\"formTypeName\":\"Fields\",\"totalForms\":0,\"formtypeGroupid\":341,\"isFavourite\":true,\"appBuilderID\":\"\",\"canViewDraftMsg\":false,\"formTypeGroupName\":\"Fields\",\"formGroupCode\":\"FID\",\"canCreateForm\":true,\"numActions\":0,\"crossWorkspaceID\":-1,\"instanceGroupId\":10381414,\"allow_associate_location\":false,\"numOverdueActions\":0,\"is_location_assoc_mandatory\":false,\"workspaceid\":2116416}",
          "FormTypeName": "Inline attachment",
          "FormGroupCode": "INL",
          "AppBuilderId": "INL",
          "TemplateTypeId": 2,
          "AppTypeId": 1
        }
      ]);

      String formVOFromDBQuery = "WITH OfflineSyncData AS (SELECT ";
      formVOFromDBQuery = "$formVOFromDBQuery CASE frmMsgTbl.OfflineRequestData WHEN 2 THEN 5 ELSE 1 END AS Type, frmTypeTbl.AppTypeId, frmMsgTbl.ProjectId, frmMsgTbl.FormTypeId, frmTypeTbl.InstanceGroupId, frmTypeTbl.TemplateTypeId, frmMsgTbl.FormId, frmMsgTbl.MsgId, frmMsgTbl.MsgTypeId, frmMsgTbl.OfflineRequestData, frmMsgTbl.UpdatedDateInMS, frmMsgTbl.IsDraft, frmMsgTbl.DelFormIds";
      formVOFromDBQuery = "$formVOFromDBQuery FROM FormMessageListTbl frmMsgTbl";
      formVOFromDBQuery = "$formVOFromDBQuery INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId";
      formVOFromDBQuery = "$formVOFromDBQuery INNER JOIN FormGroupAndFormTypeListTbl frmTypeTbl ON frmTypeTbl.ProjectId=frmMsgTbl.ProjectId AND frmTypeTbl.FormTypeId=frmMsgTbl.FormTypeId";
      formVOFromDBQuery = "$formVOFromDBQuery WHERE frmMsgTbl.OfflineRequestData<>''";
      formVOFromDBQuery = "$formVOFromDBQuery AND ((frmTypeTbl.TemplateTypeId=1 AND frmMsgTbl.IsDraft<>1) OR frmTypeTbl.TemplateTypeId<>1))";
      formVOFromDBQuery = "$formVOFromDBQuery SELECT IFNULL(fldSycDataView.OfflineRequestData,'') AS NewOfflineRequestData,frmTbl.* FROM FormListTbl frmTbl";
      formVOFromDBQuery = "$formVOFromDBQuery LEFT JOIN OfflineSyncData  fldSycDataView ON frmTbl.ProjectId=fldSycDataView.ProjectId AND frmTbl.FormId=fldSycDataView.FormId";
      formVOFromDBQuery = "$formVOFromDBQuery AND fldSycDataView.Type IN (1,2,5)";
      formVOFromDBQuery = "$formVOFromDBQuery WHERE frmTbl.ProjectId=2130192 ";
      formVOFromDBQuery = "$formVOFromDBQuery AND frmTbl.FormId=11607652";
      var data1 = [
        {
          "NewOfflineRequestData": [],
          "ProjectId": "2116416",
          "FormId": "11608838",
          "AppTypeId": 2,
          "FormTypeId": "10641209",
          "InstanceGroupId": "10381138",
          "FormTitle": "TA-0407-Attachment",
          "Code": "DEF2278",
          "CommentId": "11608838",
          "MessageId": "12311326",
          "ParentMessageId": 0,
          "OrgId": "5763307",
          "FirstName": "Mayur",
          "LastName": "Raval m.",
          "OrgName": "Asite Solutions Ltd",
          "Originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "OriginatorDisplayName": " Mayur Raval m., Asite Solutions Ltd",
          "NoOfActions": 0,
          "ObservationId": 107285,
          "LocationId": 183904,
          "PfLocFolderId": 115335312,
          "Updated": "19-Jul-2023#23:56 CST",
          "AttachmentImageName": "",
          "MsgCode": "ORI001",
          "TypeImage": "icons/form.png",
          "DocType": "Apps",
          "HasAttachments": 0,
          "HasDocAssocations": 0,
          "HasBimViewAssociations": 0,
          "HasFormAssocations": 0,
          "HasCommentAssocations": 0,
          "FormHasAssocAttach": 0,
          "FormCreationDate": "19-Jul-2023#23:56 CST",
          "FolderId": 0,
          "MsgTypeId": 1,
          "MsgStatusId": 20,
          "FormNumber": 2278,
          "MsgOriginatorId": 2017529,
          "TemplateType": 2,
          "IsDraft": 0,
          "StatusId": 1001,
          "OriginatorId": 2017529,
          "IsStatusChangeRestricted": 0,
          "AllowReopenForm": 0,
          "CanOrigChangeStatus": 0,
          "MsgTypeCode": "ORI",
          "Id": "",
          "StatusChangeUserId": 0,
          "StatusUpdateDate": "19-Jul-2023#23:56 CST",
          "StatusChangeUserName": " Mayur Raval m.",
          "StatusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "StatusChangeUserEmail": "m.raval@asite.com",
          "StatusChangeUserOrg": "Asite Solutions Ltd",
          "OriginatorEmail": "m.raval@asite.com",
          "ControllerUserId": 0,
          "UpdatedDateInMS": 1689828977000,
          "FormCreationDateInMS": 1689828977000,
          "ResponseRequestByInMS": 1690952399000,
          "FlagType": 0,
          "LatestDraftId": 0,
          "FlagTypeImageName": "flag_type/flag_0.png",
          "MessageTypeImageName": "icons/form.png",
          "CanAccessHistory": 1,
          "FormJsonData": "",
          "Status": "Open",
          "AttachedDocs": "0",
          "IsUploadAttachmentInTemp": 0,
          "IsSync": 0,
          "UserRefCode": "",
          "HasActions": 0,
          "CanRemoveOffline": 0,
          "IsMarkOffline": 0,
          "IsOfflineCreated": 0,
          "SyncStatus": 1,
          "IsForDefect": 0,
          "IsForApps": 0,
          "ObservationDefectTypeId": "218898",
          "StartDate": "2023-07-20",
          "ExpectedFinishDate": "2023-08-01",
          "IsActive": 1,
          "ObservationCoordinates": '{"x1":360.001440304004,"y1":134.31719617472731,"x2":370.001440304004,"y2":144.31719617472731}',
          "AnnotationId": "08C66C6A-1478-4A97-BB40-E938BCB6F81B-1689828968",
          "IsCloseOut": 0,
          "AssignedToUserId": 1079650,
          "AssignedToUserName": "",
          "AssignedToUserOrgName": "Asite Solutions",
          "MsgNum": 0,
          "RevisionId": "",
          "RequestJsonForOffline": "",
          "FormDueDays": 12,
          "FormSyncDate": "2023-07-20 05:56:17.27",
          "LastResponderForAssignedTo": "1079650",
          "LastResponderForOriginator": "2017529",
          "PageNumber": 1,
          "ObservationDefectType": "0",
          "StatusName": "Open",
          "AppBuilderId": "SNG-DEF",
          "TaskTypeName": "",
          "AssignedToRoleName": ""
        }
      ];
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, formVOFromDBQuery)).thenReturn(data1);

      String mapOfMessagesAttachmentListQuery = "SELECT frmMsgAttachTbl.*, prjTbl.DcId, IFNULL(frmView.LocationId,0) AS LocationId,"
          " IFNULL(frmView.ObservationId,0) AS ObservationId, IFNULL(frmView.AppBuilderId,'') AS AppBuilderId, "
          "IFNULL(frmView.TemplateType,0) AS TemplateType FROM FormMsgAttachAndAssocListTbl frmMsgAttachTbl "
          "INNER JOIN ProjectDetailTbl prjTbl ON prjTbl.ProjectId=frmMsgAttachTbl.ProjectId "
          "LEFT JOIN FormListTbl frmView ON frmView.ProjectId=frmMsgAttachTbl.AssocProjectId AND frmView.FormId=frmMsgAttachTbl.AssocFormCommId AND frmMsgAttachTbl.AttachmentType IN (2,6)";
      mapOfMessagesAttachmentListQuery = "$mapOfMessagesAttachmentListQuery WHERE frmMsgAttachTbl.ProjectId=2130192";
      mapOfMessagesAttachmentListQuery = "$mapOfMessagesAttachmentListQuery AND frmMsgAttachTbl.FormId=11608838";
      mapOfMessagesAttachmentListQuery = "$mapOfMessagesAttachmentListQuery AND frmMsgAttachTbl.MsgId=12309970";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, mapOfMessagesAttachmentListQuery)).thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "0", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"0\",\"msgId\":123,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      String mapOfLocationListQuery = "SELECT * FROM LocationDetailTbl";
      mapOfLocationListQuery = "$mapOfLocationListQuery WHERE ProjectId=2130192 AND LocationId=183904;";
      when(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, mapOfLocationListQuery)).thenReturn([
        {"ProjectId": "2130192", "FolderId": "115096357", "LocationId": 183682, "LocationTitle": "Basement", "ParentFolderId": 115096349, "ParentLocationId": 183679, "PermissionValue": 0, "LocationPath": "Site Quality Demo\01 Vijay_Test\Plan-1\Basement", "SiteId": 0, "DocumentId": "13351081", "RevisionId": "26773045", "AnnotationId": "1fc95526-3610-5163-e2c8-c915a692c3d4", "LocationCoordinate": "{\"x1\":593.98,\"y1\":669.61,\"x2\":803.92,\"y2\":522.8199999999999}", "PageNumber": 1, "IsPublic": 0, "IsFavorite": 0, "IsSite": 0, "IsCalibrated": 1, "IsFileUploaded": 0, "IsActive": 1, "HasSubFolder": 0, "CanRemoveOffline": 0, "IsMarkOffline": 1, "SyncStatus": 0, "LastSyncTimeStamp": ""}
      ]);

      when(() => mockFileUtility.isFileExists(any())).thenAnswer((_) => Future.value(true));

      String strAttachQuery1 = "SELECT frmMsgTbl.MsgTypeCode,frmMsgAttacTbl.AttachAssocDetailJson FROM FormMsgAttachAndAssocListTbl frmMsgAttacTbl\n"
          "INNER JOIN FormMessageListTbl frmMsgTbl ON frmMsgTbl.ProjectId=frmMsgAttacTbl.ProjectId\n"
          "AND frmMsgTbl.FormId=frmMsgAttacTbl.FormId AND frmMsgTbl.MsgId=frmMsgAttacTbl.MsgId\n"
          "WHERE frmMsgAttacTbl.AttachmentType=0 AND frmMsgAttacTbl.ProjectId=2130192 AND frmMsgAttacTbl.FormId=11607652";

      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, strAttachQuery1))
          .thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":123,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      String dsDocAttachmentsAllQuery = "SELECT ProjectId,AttachAssocDetailJson FROM FormMsgAttachAndAssocListTbl\n"
          "WHERE AttachmentType=3 AND ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, dsDocAttachmentsAllQuery)).thenReturn([{'ProjectId': "2130192", 'FormTypeId': "11105686", 'MsgId': "123", 'AttachRevId': "1690365038319370", 'AssocDocRevisionId': "1690365038319370", 'AttachmentType': "3", 'AttachAssocDetailJson':"{\"fileType\":\"filetype/.jpg.gif\",\"fileName\":\"edison1.jpg\",\"revisionId\":\"1690365038319370\",\"fileSize\":\"260 KB\",\"hasAccess\":false,\"canDownload\":false,\"publisherUserId\":0,\"hasBravaSupport\":false,\"docId\":\"1690365038319370\",\"attachedBy\":\"\",\"attachedDateInTimeStamp\":\"2023-07-26 15:20:17.017\",\"attachedDate\":\"2023-07-26 15:20:17.017\",\"attachedById\":\"1906453\",\"attachedByName\":\"hardik111 Asite\",\"isLink\":false,\"linkType\":\"Static\",\"isHasXref\":false,\"documentTypeId\":0,\"isRevPrivate\":false,\"isAccess\":true,\"isDocActive\":true,\"folderPermissionValue\":0,\"isRevInDistList\":false,\"isPasswordProtected\":false,\"attachmentId\":\"0\",\"type\":\"3\",\"msgId\":123,\"msgCreationDate\":\"2023-07-26 15:20:17.017\",\"projectId\":\"2130192\",\"folderId\":\"0\",\"dcId\":1,\"childProjectId\":0,\"userId\":0,\"resourceId\":0,\"parentMsgId\":123,\"parentMsgCode\":\"ORI001\",\"assocsParentId\":\"0\",\"generateURI\":true,\"hasOnlineViewerSupport\":false,\"downloadImageName\":\"\"}"}]);

      String dsGetMSGDistributionListQuery = "SELECT frmMsgTbl.ProjectId,frmMsgTbl.FormId,frmMsgTbl.MsgId,frmTpCTE.AppBuilderId || CASE LENGTH(CAST(frmTbl.FormNumber AS TEXT)) WHEN 0 THEN '000' WHEN 1 THEN '00' WHEN 2 THEN '0' ELSE '' END\n"
          " || CAST(frmTbl.FormNumber AS TEXT) AS AppBuilderIdCode,frmMsgTbl.SentActions FROM FormMessageListTbl frmMsgTbl\n"
          "INNER JOIN FormGroupAndFormTypeListTbl frmTpCTE ON frmTpCTE.ProjectId=frmMsgTbl.ProjectId AND frmTpCTE.FormTypeId=frmMsgTbl.FormTypeId\n"
          "INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId\n"
          "WHERE frmMsgTbl.ProjectId=2130192 AND frmMsgTbl.FormId=11607652 AND frmMsgTbl.MsgId=123";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, dsGetMSGDistributionListQuery)).thenReturn([jsonDecode(formMessageJson)]);

      var formTypeStatusListJson = fixture('formType_status_list.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/StatusListData.json")).thenReturn(formTypeStatusListJson);

      String? editHtmlResponse = await createFormLocalDataSource.editDraftHtmlFormData({"projectId": projectId, "formTypeId": formTypeId, "formId": formId, "msgId": "123"}, EHtmlRequestType.editDraft);
      expect(!editHtmlResponse.isNullOrEmpty(), true);

      var formMessageRESJson = jsonDecode(formMessageJson);
      formMessageRESJson["MsgTypeId"]= "2";
      formMessageRESJson["MsgTypeCode"]= "RES";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMessageVOFromDBQuery)).thenReturn([formMessageRESJson]);
      var htmlRESFile = fixtureFileContent('files/2130192/FormTypes/11103151/RES_VIEW.html');
      when(() => mockFileUtility.readFromFile("./test/fixtures/files/2130192/FormTypes/11103151/RES_VIEW.html")).thenReturn(htmlRESFile);

      String? editHtmlRESResponse = await createFormLocalDataSource.editDraftHtmlFormData({"projectId": projectId, "formTypeId": formTypeId, "formId": formId, "msgId": "123"}, EHtmlRequestType.editDraft);
      expect(!editHtmlRESResponse.isNullOrEmpty(), true);
    });
  });

  group("Testing Offline - Execute Bulk", () {
    test("Testing Offline - discardDraft", () async {
      var formMessageJson = fixture('form_message_db.json');
      when(() => mockDatabaseManager.executeSelectFromTable(any(), any())).thenReturn([jsonDecode(formMessageJson)]);

      var createQuery = "CREATE TABLE IF NOT EXISTS OfflineActivityTbl(ProjectId TEXT NOT NULL,FormTypeId TEXT NOT NULL,FormId TEXT NOT NULL,MsgId TEXT NOT NULL,actionId TEXT NOT NULL,DistListId TEXT NOT NULL,OfflineRequestData TEXT NOT NULL,CreatedDateInMs TEXT NOT NULL,PRIMARY KEY(ProjectId,FormId,MsgId,actionId,DistListId))";
      var tableName = OfflineActivityDao.tableName;
      List<String> primaryKeysList = ["ProjectId", "FormId", "MsgId", "actionId", "DistListId"];
      List<String> columnNames = ["ProjectId"];
      List<List<Object?>> rows = [];
      rows = [
        ["2130192"]
      ];
      ResultSet resultSet = ResultSet(columnNames, null, rows);
      var selectQuery = "SELECT ProjectId FROM OfflineActivityTbl WHERE ProjectId='2130192' AND FormId='11607652' AND MsgId='123' AND actionId='0' AND DistListId='0'";
      var sqlQuery = "UPDATE OfflineActivityTbl SET FormTypeId=?2,OfflineRequestData=?7,CreatedDateInMs=?8 WHERE ProjectId=?1 AND FormId=?3 AND MsgId=?4 AND actionId=?5 AND DistListId=?6";
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, any())).thenAnswer((_) => Future.value(null));

      String strUpdateAction = "UPDATE ${FormMessageActionDao.tableName} SET ${FormMessageActionDao.actionStatusField}=1,${FormMessageActionDao.isActionCompleteField}=1"
          "\nWHERE ${FormMessageActionDao.projectIdField}=$projectId AND ${FormMessageActionDao.formIdField}=$formId"
          "\nAND ${FormMessageActionDao.actionStatusField}=0 AND ${FormMessageActionDao.actionIdField} IN (0)";
      strUpdateAction = "$strUpdateAction AND ${FormMessageActionDao.msgIdField}=123";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageActionDao.tableName, strUpdateAction)).thenReturn([]);

      String? editHtmlResponse = await createFormLocalDataSource.discardDraft({"projectId": projectId, "formTypeId": formTypeId, "formId": formId, "msgId": "123"});
      expect(!editHtmlResponse.isNullOrEmpty(), true);

      var formMessageRESJson = jsonDecode(formMessageJson);
      formMessageRESJson["MsgTypeId"]= "2";
      formMessageRESJson["MsgTypeCode"]= "RES";
      when(() => mockDatabaseManager.executeSelectFromTable(any(), any())).thenReturn([formMessageRESJson]);

      String strUpdateQuery = "UPDATE FormListTbl SET MsgId=\n"
          "(SELECT MAX(CAST(MsgId AS INTEGER)) FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652 AND MsgId<>123)\n"
          "WHERE ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeTableRequest(strUpdateQuery)).thenReturn([]);

      String? editHtmlRes = await createFormLocalDataSource.discardDraft({"projectId": projectId, "formTypeId": formTypeId, "formId": formId, "msgId": "123"});
      expect(!editHtmlRes.isNullOrEmpty(), true);

      var formMessageFWDJson = jsonDecode(formMessageJson);
      formMessageFWDJson["MsgTypeId"]= "3";
      formMessageFWDJson["MsgTypeCode"]= "FWD";
      when(() => mockDatabaseManager.executeSelectFromTable(any(), any())).thenReturn([formMessageRESJson]);
      String? editHtmlFWD = await createFormLocalDataSource.discardDraft({"projectId": projectId, "formTypeId": formTypeId, "formId": formId, "msgId": "123"});
      expect(!editHtmlFWD.isNullOrEmpty(), true);

      verify(() => mockDb!.executeQuery(createQuery)).called(3);
      verify(() => mockDb!.getPrimaryKeys(tableName)).called(3);
      verify(() => mockDb!.selectFromTable(tableName, selectQuery)).called(3);
      verify(() => mockDb!.executeBulk(tableName, sqlQuery, any())).called(3);
    });

    test("Testing Offline - changeFieldFormHistoryStatus", () async {
      var formMessageJson = fixture('form_message_db.json');
      when(() => mockDatabaseManager.executeSelectFromTable(any(), any())).thenReturn([jsonDecode(formMessageJson)]);

      String formVOFromDBQuery = "WITH OfflineSyncData AS (SELECT ";
      formVOFromDBQuery = "$formVOFromDBQuery CASE frmMsgTbl.OfflineRequestData WHEN 2 THEN 5 ELSE 1 END AS Type, frmTypeTbl.AppTypeId, frmMsgTbl.ProjectId, frmMsgTbl.FormTypeId, frmTypeTbl.InstanceGroupId, frmTypeTbl.TemplateTypeId, frmMsgTbl.FormId, frmMsgTbl.MsgId, frmMsgTbl.MsgTypeId, frmMsgTbl.OfflineRequestData, frmMsgTbl.UpdatedDateInMS, frmMsgTbl.IsDraft, frmMsgTbl.DelFormIds";
      formVOFromDBQuery = "$formVOFromDBQuery FROM FormMessageListTbl frmMsgTbl";
      formVOFromDBQuery = "$formVOFromDBQuery INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId";
      formVOFromDBQuery = "$formVOFromDBQuery INNER JOIN FormGroupAndFormTypeListTbl frmTypeTbl ON frmTypeTbl.ProjectId=frmMsgTbl.ProjectId AND frmTypeTbl.FormTypeId=frmMsgTbl.FormTypeId";
      formVOFromDBQuery = "$formVOFromDBQuery WHERE frmMsgTbl.OfflineRequestData<>''";
      formVOFromDBQuery = "$formVOFromDBQuery AND ((frmTypeTbl.TemplateTypeId=1 AND frmMsgTbl.IsDraft<>1) OR frmTypeTbl.TemplateTypeId<>1))";
      formVOFromDBQuery = "$formVOFromDBQuery SELECT IFNULL(fldSycDataView.OfflineRequestData,'') AS NewOfflineRequestData,frmTbl.* FROM FormListTbl frmTbl";
      formVOFromDBQuery = "$formVOFromDBQuery LEFT JOIN OfflineSyncData  fldSycDataView ON frmTbl.ProjectId=fldSycDataView.ProjectId AND frmTbl.FormId=fldSycDataView.FormId";
      formVOFromDBQuery = "$formVOFromDBQuery AND fldSycDataView.Type IN (1,2,5)";
      formVOFromDBQuery = "$formVOFromDBQuery WHERE frmTbl.ProjectId=2130192 ";
      formVOFromDBQuery = "$formVOFromDBQuery AND frmTbl.FormId=11607652";
      var data1 = [
        {
          "NewOfflineRequestData": [],
          "ProjectId": "2116416",
          "FormId": "11608838",
          "AppTypeId": 2,
          "FormTypeId": "10641209",
          "InstanceGroupId": "10381138",
          "FormTitle": "TA-0407-Attachment",
          "Code": "DEF2278",
          "CommentId": "11608838",
          "MessageId": "12311326",
          "ParentMessageId": 0,
          "OrgId": "5763307",
          "FirstName": "Mayur",
          "LastName": "Raval m.",
          "OrgName": "Asite Solutions Ltd",
          "Originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "OriginatorDisplayName": " Mayur Raval m., Asite Solutions Ltd",
          "NoOfActions": 0,
          "ObservationId": 107285,
          "LocationId": 183904,
          "PfLocFolderId": 115335312,
          "Updated": "19-Jul-2023#23:56 CST",
          "AttachmentImageName": "",
          "MsgCode": "ORI001",
          "TypeImage": "icons/form.png",
          "DocType": "Apps",
          "HasAttachments": 0,
          "HasDocAssocations": 0,
          "HasBimViewAssociations": 0,
          "HasFormAssocations": 0,
          "HasCommentAssocations": 0,
          "FormHasAssocAttach": 0,
          "FormCreationDate": "19-Jul-2023#23:56 CST",
          "FolderId": 0,
          "MsgTypeId": 1,
          "MsgStatusId": 20,
          "FormNumber": 2278,
          "MsgOriginatorId": 2017529,
          "TemplateType": 2,
          "IsDraft": 0,
          "StatusId": 1001,
          "OriginatorId": 2017529,
          "IsStatusChangeRestricted": 0,
          "AllowReopenForm": 0,
          "CanOrigChangeStatus": 0,
          "MsgTypeCode": "ORI",
          "Id": "",
          "StatusChangeUserId": 0,
          "StatusUpdateDate": "19-Jul-2023#23:56 CST",
          "StatusChangeUserName": " Mayur Raval m.",
          "StatusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "StatusChangeUserEmail": "m.raval@asite.com",
          "StatusChangeUserOrg": "Asite Solutions Ltd",
          "OriginatorEmail": "m.raval@asite.com",
          "ControllerUserId": 0,
          "UpdatedDateInMS": 1689828977000,
          "FormCreationDateInMS": 1689828977000,
          "ResponseRequestByInMS": 1690952399000,
          "FlagType": 0,
          "LatestDraftId": 0,
          "FlagTypeImageName": "flag_type/flag_0.png",
          "MessageTypeImageName": "icons/form.png",
          "CanAccessHistory": 1,
          "FormJsonData": "",
          "Status": "Open",
          "AttachedDocs": "0",
          "IsUploadAttachmentInTemp": 0,
          "IsSync": 0,
          "UserRefCode": "",
          "HasActions": 0,
          "CanRemoveOffline": 0,
          "IsMarkOffline": 0,
          "IsOfflineCreated": 0,
          "SyncStatus": 1,
          "IsForDefect": 0,
          "IsForApps": 0,
          "ObservationDefectTypeId": "218898",
          "StartDate": "2023-07-20",
          "ExpectedFinishDate": "2023-08-01",
          "IsActive": 1,
          "ObservationCoordinates": '{"x1":360.001440304004,"y1":134.31719617472731,"x2":370.001440304004,"y2":144.31719617472731}',
          "AnnotationId": "08C66C6A-1478-4A97-BB40-E938BCB6F81B-1689828968",
          "IsCloseOut": 0,
          "AssignedToUserId": 1079650,
          "AssignedToUserName": "",
          "AssignedToUserOrgName": "Asite Solutions",
          "MsgNum": 0,
          "RevisionId": "",
          "RequestJsonForOffline": "",
          "FormDueDays": 12,
          "FormSyncDate": "2023-07-20 05:56:17.27",
          "LastResponderForAssignedTo": "1079650",
          "LastResponderForOriginator": "2017529",
          "PageNumber": 1,
          "ObservationDefectType": "0",
          "StatusName": "Open",
          "AppBuilderId": "SNG-DEF",
          "TaskTypeName": "",
          "AssignedToRoleName": ""
        }
      ];
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, formVOFromDBQuery)).thenReturn(data1);

      var tableName = FormStatusHistoryDao.tableName;
      var createQuery = "CREATE TABLE IF NOT EXISTS FormStatusHistoryTbl(ProjectId TEXT NOT NULL,FormTypeId TEXT,FormId TEXT NOT NULL,MessageId TEXT,ActionUserId TEXT NOT NULL,ActionUserName TEXT,ActionUserOrgName TEXT,ActionProxyUserId TEXT NOT NULL,ActionProxyUserName TEXT,ActionProxyUserOrgName TEXT,ActionUserTypeId INTEGER NOT NULL,ActionId TEXT NOT NULL,ActionDate TEXT NOT NULL,Description TEXT DEFAULT " ",Remarks TEXT DEFAULT " ",CreateDateInMS TEXT NOT NULL,JsonData TEXT DEFAULT " ",PRIMARY KEY(ProjectId,FormId,CreateDateInMS))";
      String tmpSelectQuery = "SELECT ProjectId FROM $tableName WHERE ";
      tmpSelectQuery = tmpSelectQuery + "ProjectId='2130192' AND FormId='11607652' AND CreateDateInMS='1691484992961'";
      var sqlInsertQuery = "INSERT INTO FormStatusHistoryTbl (ProjectId,FormTypeId,FormId,MessageId,ActionUserId,ActionUserName,ActionUserOrgName,ActionProxyUserId,ActionProxyUserName,ActionProxyUserOrgName,ActionUserTypeId,ActionId,ActionDate,Description,Remarks,CreateDateInMS,JsonData) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      var sqlUpdateQuery = "UPDATE OfflineActivityTbl SET FormTypeId=?2,OfflineRequestData=?7,CreatedDateInMs=?8 WHERE ProjectId=?1 AND FormId=?3 AND MsgId=?4 AND actionId=?5 AND DistListId=?6";
      when(() => mockDb!.executeQuery(createQuery)).thenReturn({});
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn([]);
      when(() => mockDb!.executeBulk(tableName, sqlInsertQuery, any())).thenAnswer((_) => Future.value(null));
      when(() => mockDb!.executeBulk(tableName, sqlUpdateQuery, any())).thenAnswer((_) => Future.value(null));

      var formDaoTableName = FormDao.tableName;
      var formDaoCreateQuery = "CREATE TABLE IF NOT EXISTS FormListTbl(ProjectId TEXT NOT NULL,FormTypeId TEXT,FormId TEXT NOT NULL,MessageId TEXT,ActionUserId TEXT NOT NULL,ActionUserName TEXT,ActionUserOrgName TEXT,ActionProxyUserId TEXT NOT NULL,ActionProxyUserName TEXT,ActionProxyUserOrgName TEXT,ActionUserTypeId INTEGER NOT NULL,ActionId TEXT NOT NULL,ActionDate TEXT NOT NULL,Description TEXT DEFAULT " ",Remarks TEXT DEFAULT " ",CreateDateInMS TEXT NOT NULL,JsonData TEXT DEFAULT " ",PRIMARY KEY(ProjectId,FormId,CreateDateInMS))";
      when(() => mockDb!.executeQuery(formDaoCreateQuery)).thenReturn({});
      when(() => mockDb!.getPrimaryKeys(formDaoTableName)).thenReturn([]);
      when(() => mockDb!.executeBulk(formDaoTableName, any(), any())).thenAnswer((_) => Future.value(null));
      String? editHtmlResponse = await createFormLocalDataSource.changeFieldFormHistoryStatus({"projectId": projectId, "formTypeId": formTypeId, "selectedFormId": formId, "msgId": "123"});
      expect(!editHtmlResponse.isNullOrEmpty(), true);
    });
  });

  group("Testing Offline - Attachments", () {
    test("getInlineAttachmentListFromJsonData", () async {
      String strMsgJsonData =
          "{\"myFields\":{\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_CLOSE_DUE_DATE,DS_WORKPACKAGE_PROJECT_DEFECTS,DS_PROJUSERS\",\"SP_ORI_VIEW_HTML\":\"DS_CLOSE_DUE_DATE,DS_WORKPACKAGE_PROJECT_DEFECTS,DS_PROJUSERS\",\"SP_ORI_PRINT_VIEW\":\"DS_CLOSE_DUE_DATE,DS_WORKPACKAGE_PROJECT_DEFECTS,DS_PROJUSERS\",\"SP_ORI_PRINT_VIEW_HTML\":\"DS_CLOSE_DUE_DATE,DS_WORKPACKAGE_PROJECT_DEFECTS,DS_PROJUSERS\"}},\"extraParams\":null,\"ORI_FORMTITLE\":\"3666\",\"Textbox\":\"666\",\"Datepicker\":\"2023-07-27T11:41:28.000Z\",\"DS_CLOSE_DUE_DATE\":\"2023-07-27\",\"Datepicker_3\":\"2023-07-29T11:41:28.000Z\",\"Timepicker_1\":\"\",\"Description\":\"\",\"Text_Area_2\":\"\",\"Dropdown_3\":\"\",\"cities\":\"Ahmedabad\",\"Dropdown_2\":\"\",\"Accepted\":\"\",\"Attachment\":[{\"@inline\":\"xdoc_0_5_4_3_my:Attachment\",\"content\":\"\",\"@caption\":\"abcd.jpg\",\"OfflineContent\":{\"fileType\":6,\"isThumbnailSupports\":true,\"upFilePath\":\"/data/user/0/com.asite.field/app_flutter/database/1_1906453/2130192/tempAttachments/abcd.jpg\"}}],\"Attachment_1\":[],\"Hyperlink\":\"https://www.google.com\",\"RichText_Area\":\"\",\"Dropdown_1\":\"\",\"MultiDropdown\":\"\",\"Checkbox\":\"\",\"Radio_1\":\"\",\"Timepicker\":\"\",\"Map\":\"\",\"Button\":\"Button\",\"ToggleButton\":\"false\",\"Rating\":0,\"Section\":{},\"Repeating_Table\":{\"value\":[{}],\"table_header\":[{}],\"table_footer\":[{}],\"defuaultRowData\":{}},\"Repeating_Table_1\":{\"value\":[{\"Dropdown_4\":\"\",\"Checkbox_1\":\"\",\"Attachment_2\":[]}],\"table_header\":[{}],\"table_footer\":[{}],\"defuaultRowData\":{\"Dropdown_4\":\"\",\"Checkbox_1\":\"\",\"Attachment_2\":[]}},\"Signature\":\"\",\"attachments\":[],\"dist_list\":{\"selectedDistGroups\":\"\",\"selectedDistUsers\":[],\"selectedDistOrgs\":[],\"selectedDistRoles\":[],\"prePopulatedDistGroups\":\"\"},\"respondBy\":\"\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"dist_list\":{\"selectedDistGroups\":\"\",\"selectedDistUsers\":[],\"selectedDistOrgs\":[],\"selectedDistRoles\":[],\"prePopulatedDistGroups\":\"\"},\"formAction\":\"create\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11105686\",\"assocLocationSelection\":{\"locationId\":185265},\"requestType\":\"0\",\"annotationId\":\"b0d6af67-f2e8-4d05-aa75-117627ca0f70-1690454433582\",\"coordinates\":{\"x1\":402.1324722380758,\"y1\":242.59780784087627,\"x2\":412.1324722380758,\"y2\":252.59780784087627},\"appTypeId\":\"2\",\"isThumbnailSupports\":\"true\"}}}";
      SiteForm pFormItem = SiteForm(
          projectId: "2130192",
          projectName: null,
          code: "HBHT",
          commId: "1690",
          formId: "11607652",
          title: "3666",
          userID: null,
          orgId: "0",
          originator: null,
          originatorDisplayName: "hardik111 Asite, Asite Solutions Ltd",
          noOfActions: 0,
          observationId: 1690454433616,
          locationId: 185265,
          pfLocFolderId: null,
          locationName: null,
          locationPath: null,
          updated: "2023-07-27 16:11:38.038",
          hasAttachments: false,
          msgCode: "ORI001",
          docType: null,
          formTypeName: "HB HTML 123",
          statusText: null,
          responseRequestBy: "27-Jul-2023",
          hasDocAssocations: null,
          hasBimViewAssociations: null,
          hasBimListAssociations: null,
          hasFormAssocations: null,
          hasCommentAssocations: null,
          formHasAssocAttach: false,
          msgHasAssocAttach: null,
          formCreationDate: "2023-07-27 16:11:38.038",
          msgCreatedDate: null,
          msgId: "1690454498373",
          parentMsgId: "0",
          msgTypeId: "1",
          msgStatusId: null,
          formTypeId: "11105686",
          templateType: 2,
          instanceGroupId: "10796407",
          noOfMessages: null,
          isDraft: false,
          dcId: null,
          statusid: "",
          originatorId: "1906453",
          isCloseOut: null,
          isStatusChangeRestricted: null,
          allowReopenForm: null,
          hasOverallStatus: null,
          canOrigChangeStatus: null,
          canControllerChangeStatus: null,
          appType: "2",
          msgTypeCode: "ORI",
          formGroupName: null,
          id: null,
          appTypeId: 2,
          lastmodified: null,
          appBuilderId: "HB-HTML",
          CFID_TaskType: null,
          CFID_DefectTyoe: null,
          CFID_Assigned: null,
          statusRecordStyle: null,
          isSiteFormSelected: null,
          statusUpdateDate: null,
          attachmentImageName: null,
          firstName: "hardik111",
          lastName: "Asite",
          folderId: null,
          formCreationDateInMS: "1690454498373",
          responseRequestByInMS: null,
          updatedDateInMS: "1690454498373",
          typeImage: "icons/form.png",
          status: "",
          statusName: "",
          statusChangeUserId: null,
          statusChangeUserPic: null,
          statusChangeUserOrg: null,
          statusChangeUserName: null,
          statusChangeUserEmail: null,
          orgName: "Asite Solutions Ltd",
          originatorEmail: null,
          msgOriginatorId: 1906453,
          formNum: null,
          controllerUserId: null,
          userRefCode: null,
          flagTypeImageName: null,
          formTypeCode: "HBHT",
          latestDraftId: null,
          canAccessHistory: null,
          observationCoordinates: "{\"x1\":402.1324722380758,\"y1\":242.59780784087627,\"x2\":412.1324722380758,\"y2\":252.59780784087627}",
          annotationId: "b0d6af67-f2e8-4d05-aa75-117627ca0f70-1690454433582",
          pageNumber: 1,
          isActive: true,
          formDueDays: null,
          formSyncDate: null,
          startDate: null,
          expectedFinishDate: null,
          assignedToUserId: null,
          assignedToUserName: null,
          assignedToUserOrgName: null,
          assignedToRoleName: null,
          lastResponderForAssignedTo: null,
          lastResponderForOriginator: null,
          manageTypeId: null,
          manageTypeName: null,
          hasActions: null,
          flagType: null,
          messageTypeImageName: null,
          formJsonData:
              "{\"myFields\":{\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_ORI_VIEW\":\"DS_CLOSE_DUE_DATE,DS_WORKPACKAGE_PROJECT_DEFECTS,DS_PROJUSERS\",\"SP_ORI_VIEW_HTML\":\"DS_CLOSE_DUE_DATE,DS_WORKPACKAGE_PROJECT_DEFECTS,DS_PROJUSERS\",\"SP_ORI_PRINT_VIEW\":\"DS_CLOSE_DUE_DATE,DS_WORKPACKAGE_PROJECT_DEFECTS,DS_PROJUSERS\",\"SP_ORI_PRINT_VIEW_HTML\":\"DS_CLOSE_DUE_DATE,DS_WORKPACKAGE_PROJECT_DEFECTS,DS_PROJUSERS\"}},\"extraParams\":null,\"ORI_FORMTITLE\":\"3666\",\"Textbox\":\"666\",\"Datepicker\":\"2023-07-27T11:41:28.000Z\",\"DS_CLOSE_DUE_DATE\":\"2023-07-27\",\"Datepicker_3\":\"2023-07-29T11:41:28.000Z\",\"Timepicker_1\":\"\",\"Description\":\"\",\"Text_Area_2\":\"\",\"Dropdown_3\":\"\",\"cities\":\"Ahmedabad\",\"Dropdown_2\":\"\",\"Accepted\":\"\",\"Attachment\":[{\"@inline\":\"xdoc_0_5_4_3_my:Attachment\",\"content\":\"\",\"@caption\":\"abcd.jpg\",\"OfflineContent\":{\"fileType\":6,\"isThumbnailSupports\":true,\"upFilePath\":\"/data/user/0/com.asite.field/app_flutter/database/1_1906453/2130192/tempAttachments/abcd.jpg\"}}],\"Attachment_1\":[],\"Hyperlink\":\"https://www.google.com\",\"RichText_Area\":\"\",\"Dropdown_1\":\"\",\"MultiDropdown\":\"\",\"Checkbox\":\"\",\"Radio_1\":\"\",\"Timepicker\":\"\",\"Map\":\"\",\"Button\":\"Button\",\"ToggleButton\":\"false\",\"Rating\":0,\"Section\":{},\"Repeating_Table\":{\"value\":[{}],\"table_header\":[{}],\"table_footer\":[{}],\"defuaultRowData\":{}},\"Repeating_Table_1\":{\"value\":[{\"Dropdown_4\":\"\",\"Checkbox_1\":\"\",\"Attachment_2\":[]}],\"table_header\":[{}],\"table_footer\":[{}],\"defuaultRowData\":{\"Dropdown_4\":\"\",\"Checkbox_1\":\"\",\"Attachment_2\":[]}},\"Signature\":\"\",\"attachments\":[],\"dist_list\":{\"selectedDistGroups\":\"\",\"selectedDistUsers\":[],\"selectedDistOrgs\":[],\"selectedDistRoles\":[],\"prePopulatedDistGroups\":\"\"},\"respondBy\":\"\",\"selectedControllerUserId\":\"\",\"create_hidden_list\":{\"msg_type_id\":\"1\",\"msg_type_code\":\"ORI\",\"dist_list\":{\"selectedDistGroups\":\"\",\"selectedDistUsers\":[],\"selectedDistOrgs\":[],\"selectedDistRoles\":[],\"prePopulatedDistGroups\":\"\"},\"formAction\":\"create\",\"project_id\":\"2130192\",\"offlineProjectId\":\"2130192\",\"offlineFormTypeId\":\"11105686\",\"assocLocationSelection\":{\"locationId\":185265},\"requestType\":\"0\",\"annotationId\":\"b0d6af67-f2e8-4d05-aa75-117627ca0f70-1690454433582\",\"coordinates\":{\"x1\":402.1324722380758,\"y1\":242.59780784087627,\"x2\":412.1324722380758,\"y2\":252.59780784087627},\"appTypeId\":\"2\",\"isThumbnailSupports\":\"true\"}}}",
          attachedDocs: null,
          isUploadAttachmentInTemp: false,
          isSync: null,
          canRemoveOffline: false,
          isMarkOffline: true,
          isOfflineCreated: null,
          isForDefect: null,
          isForApps: null,
          observationDefectTypeId: null,
          msgNum: 0,
          revisionId: "26987868",
          requestJsonForOffline: null,
          observationDefectType: null,
          taskTypeName: null,
          workPackage: "");
      when(() => mockFileUtility.getFileSize(any())).thenAnswer((_) => Future.value(12020));
      when(() => mockFileUtility.getFileNameFromPath(any())).thenReturn("abcd.jpg");
      when(() => mockFileUtility.copySyncFile(any(), any())).thenReturn(null);
      var jsonEncodeData = await createFormLocalDataSource.getInlineAttachmentListFromJsonData(strMsgJsonData, "HB-HTML", "", pFormItem, false, (List<FormMessageAttachAndAssocVO> inlineAttachList, List<String> inlineAttachRevIdList) {});
      expect(jsonEncodeData, isA<String>());

      when(() => mockFileUtility.getFileNameWithoutExtention(any())).thenReturn("abcd");
      var jsonEncodeAutoPublishData = await createFormLocalDataSource.getInlineAttachmentListFromJsonData(strMsgJsonData, "HB-HTML", "", pFormItem, true, (List<FormMessageAttachAndAssocVO> inlineAttachList, List<String> inlineAttachRevIdList) {});
      expect(jsonEncodeAutoPublishData, isA<String>());
    });
  });

  group("Field Copy Form Html5Json", () {
    test("GetFieldCopyFormHtml5Json", () async {
      var formMessageJson = fixture('form_message_db.json');
      String query = "SELECT frmMsgTbl.LocationId,locTbl.IsCalibrated,frmTpTbl.AppBuilderId,frmTpTbl.TemplateTypeId,frmTpTbl.InstanceGroupId,frmTpTbl.AppTypeId,frmTpTbl.FormTypeId,frmTpTbl.FormTypeGroupCode,frmTpTbl.FormTypeName,frmMsgTbl.JsonData FROM ${FormMessageDao.tableName} frmMsgTbl\n"
          "INNER JOIN ${LocationDao.tableName} locTbl ON locTbl.ProjectId=frmMsgTbl.ProjectId AND locTbl.LocationId=frmMsgTbl.LocationId\n"
          "INNER JOIN ${FormTypeDao.tableName} frmTpTbl ON frmTpTbl.ProjectId=frmMsgTbl.ProjectId AND frmTpTbl.FormTypeId=(\n"
          "SELECT MAX(FormTypeId) FROM ${FormTypeDao.tableName} WHERE ProjectId=frmMsgTbl.ProjectId AND InstanceGroupId=(\n"
          "SELECT InstanceGroupId FROM ${FormTypeDao.tableName} WHERE ProjectId=frmMsgTbl.ProjectId AND FormTypeId=frmMsgTbl.FormTypeId\n)\n)\n"
          "WHERE frmMsgTbl.ProjectId=$projectId AND frmMsgTbl.FormId=$formId AND frmMsgTbl.MsgTypeId=${EFormMessageType.ori.value.toString()}";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, query))
          .thenReturn([jsonDecode(formMessageJson)]);

      var htmlFile = fixtureFileContent('files/2130192/FormTypes/11103151/ORI_VIEW.html');
      when(() => mockFileUtility.readFromFile("./test/fixtures/files/2130192/FormTypes/11103151/ORI_VIEW.html")).thenReturn(htmlFile);

      var jsonData = fixtureFileContent('files/2130192/FormTypes/11103151/data.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/files/2130192/FormTypes/11103151/data.json")).thenReturn(jsonData);

      var customAttributeData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/CustomAttributeData.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/CustomAttributeData.json")).thenReturn(customAttributeData);

      var fieldJsonData = fixtureFileContent('database/1_808581/2130192/FormTypes/11103151/Fix-FieldData.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/Fix-FieldData.json")).thenReturn(fieldJsonData);

      var offlineCreateFormContent = fixtureFileContent('database/HTML5Form/offlineCreateForm.html');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/HTML5Form/offlineCreateForm.html")).thenReturn(offlineCreateFormContent);

      String isDraftQuery = "SELECT MsgStatusId FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652\n"
          "AND MsgTypeId=1 AND (MsgStatusId=19 OR OfflineRequestData<>'')";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, isDraftQuery)).thenReturn([]);

      String isDraftResMsgQuery = "SELECT MsgStatusId FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652 AND MsgId=123\n"
          "AND MsgTypeId=2 AND (MsgStatusId=19 OR OfflineRequestData<>'')";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, isDraftResMsgQuery)).thenReturn([]);

      String dsFormNameQuery = "SELECT FormTypeName FROM FormGroupAndFormTypeListTbl\n"
          "WHERE ProjectId=2130192 AND FormTypeId=11103151";
      when(() => mockDatabaseManager.executeSelectFromTable(FormTypeDao.tableName, dsFormNameQuery)).thenReturn([
        {"FormTypeName": "demo"}
      ]);

      String dsFormGroupCodeQuery = "SELECT FormTypeGroupCode FROM FormGroupAndFormTypeListTbl\n"
          "WHERE ProjectId=2130192 AND FormTypeId=11103151";
      when(() => mockDatabaseManager.executeSelectFromTable(FormTypeDao.tableName, dsFormGroupCodeQuery)).thenReturn([
        {"FormTypeGroupCode": "code"}
      ]);

      String dsFormGroupCODQuery = "SELECT CASE WHEN INSTR(frmTbl.Code,'(')>0 THEN SUBSTR(frmTbl.Code,0,INSTR(frmTbl.Code,'(')) WHEN LOWER(frmTbl.Code)='draft' OR frmTbl.IsDraft=1 THEN frmTpView.FormTypeGroupCode || '000' ELSE frmTbl.Code END AS DS_FORMID FROM FormListTbl frmTbl\n"
          "INNER JOIN FormGroupAndFormTypeListTbl frmTpView ON frmTpView.ProjectId=frmTbl.ProjectId AND frmTpView.FormTypeId=frmTbl.FormTypeId\n"
          "WHERE frmTbl.ProjectId=2130192 AND frmTbl.FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, dsFormGroupCODQuery)).thenReturn([]);

      String dsCloseDueDateQuery = "SELECT JsonData FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652\n"
          "AND MsgId=123";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, dsCloseDueDateQuery)).thenReturn([]);

      String oriFormTitleQuery = "SELECT FormTitle FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, oriFormTitleQuery)).thenReturn([
        {"FormTitle": "Test Form"}
      ]);

      String oriUserREFQuery = "SELECT UserRefCode FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, oriUserREFQuery)).thenReturn([
        {"UserRefCode": "ORI001"}
      ]);

      String allLocationByProjectPFQuery = "SELECT prjTbl.ProjectName, locTbl.* FROM LocationDetailTbl locTbl\n"
          "INNER JOIN ProjectDetailTbl prjTbl ON prjTbl.ProjectId=locTbl.ProjectId\n"
          "WHERE locTbl.IsActive=1 AND locTbl.IsMarkOffline=1 AND locTbl.ProjectId=2130192\n"
          "ORDER BY locTbl.LocationPath COLLATE NOCASE";
      when(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, allLocationByProjectPFQuery)).thenReturn([
        {"ProjectName": "demo"}
      ]);

      String dsFormStatusQuery = "SELECT Status FROM FormListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652";
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, dsFormStatusQuery)).thenReturn([]);

      String dsIncompleteActionsQuery = "SELECT * FROM FormMsgActionListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652\n"
          "AND ActionStatus=0 AND RecipientUserId=808581";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageActionDao.tableName, dsIncompleteActionsQuery)).thenReturn([]);

      String recentDefectQuery = "SELECT frmTbl.ProjectId,frmTbl.FormId,frmTbl.Code,frmTpTbl.FormTypeGroupCode,frmTbl.FormTitle,frmTbl.ObservationDefectType,frmTbl.LocationId,locTbl.LocationTitle,locTbl.LocationPath,frmMsgTbl.JsonData FROM FormListTbl frmTbl\n"
          "INNER JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=frmTbl.ProjectId AND frmTpTbl.FormTypeId=frmTbl.FormTypeId\n"
          "INNER JOIN LocationDetailTbl locTbl ON locTbl.ProjectId=frmTbl.ProjectId AND locTbl.LocationId=frmTbl.LocationId\n"
          "INNER JOIN FormMessageListTbl frmMsgTbl ON frmMsgTbl.ProjectId=frmTbl.ProjectId AND frmMsgTbl.FormId=frmTbl.FormId AND frmMsgTbl.MsgTypeId=1 AND frmMsgTbl.IsDraft=0\n"
          "WHERE frmTbl.ProjectId=2130192 AND frmTbl.OriginatorId=808581 AND frmTpTbl.InstanceGroupId=\n"
          "(SELECT InstanceGroupId FROM FormGroupAndFormTypeListTbl WHERE ProjectId=2130192 AND FormTypeId=11103151)\n"
          "ORDER BY frmTbl.FormCreationDateInMS DESC\n"
          "LIMIT 5 OFFSET 0";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, recentDefectQuery)).thenReturn([
        {
          "ProjectId": "2116416",
          "ProjectName": "!!PIN_ANY_APP_TYPE_20_9",
          "DcId": 1,
          "FormTypeId": "10616643",
          "JsonData":
          "{\"myFields\":{\"FORM_CUSTOM_FIELDS\":{\"ORI_MSG_Custom_Fields\":{\"DistributionDays\":\"0\",\"Organization\":\"\",\"DefectTyoe\":\"Computer\",\"ExpectedFinishDate\":\"2023-08-08\",\"DefectDescription\":\"\",\"AssignedToUsersGroup\":{\"AssignedToUsers\":{\"AssignedToUser\":\"707447#Vijay Mavadiya (5336), Asite Solutions\"}},\"Defect_Description\":\"test description\",\"LocationName\":\"01 Vijay_Test\",\"StartDate\":\"2023-08-01\",\"ActualFinishDate\":\"\",\"ExpectedFinishDays\":\"5\",\"DS_Logo\":\"images/asite.gif\",\"LastResponder_For_AssignedTo\":\"707447\",\"TaskType\":\"Defect\",\"isCalibrated\":false,\"ORI_FORMTITLE\":\"Test Offlinr VJ Attachment\",\"attachements\":[{\"attachedDocs\":\"\"}],\"OriginatorId\":\"2017529 | Mayur Raval m., Asite Solutions Ltd # Mayur Raval m., Asite Solutions Ltd\",\"Assigned\":\"Vijay Mavadiya (5336), Asite Solutions\",\"CurrStage\":\"1\",\"Recent_Defects\":\"\",\"FormCreationDate\":\"\",\"StartDateDisplay\":\"01-Aug-2023\",\"LastResponder_For_Originator\":\"2017529\",\"PF_Location_Detail\":\"183678|0|null|0\",\"Username\":\"\",\"ORI_USERREF\":\"\",\"Location\":\"183678|01 Vijay_Test|01 Vijay_Test\"},\"RES_MSG_Custom_Fields\":{\"Comments\":\"\",\"SHResponse\":\"Yes\",\"ShowHideFlag\":\"Yes\"},\"CREATE_FWD_RES\":{\"Can_Reply\":\"\"},\"DS_AUTONUMBER\":{\"DS_SEQ_LENGTH\":\"\",\"DS_FORMAUTONO_CREATE\":\"\",\"DS_GET_APP_ACTION_DETAILS\":\"\",\"DS_FORMAUTONO_ADD\":\"\"},\"DS_DATASOURCE\":{\"DS_ASI_SITE_GET_RECENT_DEFECTS\":\"\",\"DS_ASI_SITE_getDefectTypesForProjects_pf\":\"\",\"DS_Response_PARAM\":\"#Comments#DS_ALL_FORMSTATUS\",\"DS_ASI_SITE_getAllLocationByProject_PF\":\"\",\"DS_CALL_METHOD\":\"1\",\"DS_CHECK_FORM_PERMISSION_USER\":\"\",\"DS_Get_All_Responses\":\"\",\"DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY\":\"\",\"DS_Holiday_Calender_Param\":\"\",\"DS_ASI_Configurable_Attributes\":\"\"}},\"attachments\":[],\"Asite_System_Data_Read_Only\":{\"_2_Printing_Data\":{\"DS_PRINTEDON\":\"\",\"DS_PRINTEDBY\":\"\"},\"_4_Form_Type_Data\":{\"DS_FORMGROUPCODE\":\"SITE\",\"DS_FORMAUTONO\":\"\",\"DS_FORMNAME\":\"Site Tasks\"},\"_3_Project_Data\":{\"DS_PROJECTNAME\":\"\",\"DS_CLIENT\":\"\"},\"_5_Form_Data\":{\"DS_DATEOFISSUE\":\"\",\"DS_ISDRAFT_RES_MSG\":\"\",\"Status_Data\":{\"DS_APPROVEDON\":\"\",\"DS_CLOSEDUEDATE\":\"\",\"DS_ALL_ACTIVE_FORM_STATUS\":\"\",\"DS_ALL_FORMSTATUS\":\"1001 # Open\",\"DS_APPROVEDBY\":\"\",\"DS_CLOSE_DUE_DATE\":\"2023-08-08\",\"DS_FORMSTATUS\":\"\"},\"DS_DISTRIBUTION\":\"\",\"DS_ISDRAFT\":\"NO\",\"DS_FORMCONTENT\":\"\",\"DS_FORMCONTENT3\":\"\",\"DS_ORIGINATOR\":\"\",\"DS_FORMCONTENT2\":\"\",\"DS_FORMCONTENT1\":\"\",\"DS_CONTROLLERNAME\":\"\",\"DS_MAXORGFORMNO\":\"\",\"DS_ISDRAFT_RES\":\"\",\"DS_MAXFORMNO\":\"\",\"DS_FORMAUTONO_PREFIX\":\"\",\"DS_ATTRIBUTES\":\"\",\"DS_ISDRAFT_FWD_MSG\":\"NO\",\"DS_FORMID\":\"\"},\"_1_User_Data\":{\"DS_WORKINGUSER\":\"Mayur Raval m., Asite Solutions Ltd\",\"DS_WORKINGUSERROLE\":\"\",\"DS_WORKINGUSER_ID\":\"\",\"DS_WORKINGUSER_ALL_ROLES\":\"\"},\"_6_Form_MSG_Data\":{\"DS_MSGCREATOR\":\"\",\"DS_MSGDATE\":\"\",\"DS_MSGID\":\"\",\"DS_MSGRELEASEDATE\":\"\",\"DS_MSGSTATUS\":\"\",\"ORI_MSG_Data\":{\"DS_DOC_ASSOCIATIONS_ORI\":\"\",\"DS_FORM_ASSOCIATIONS_ORI\":\"\",\"DS_ATTACHMENTS_ORI\":\"\"}}},\"Asite_System_Data_Read_Write\":{\"ORI_MSG_Fields\":{\"SP_RES_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_MSGDATE,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER,DS_Get_All_Responses\",\"SP_RES_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_GET_APP_ACTION_DETAILS\",\"SP_ORI_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_FORM_PRINT_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses,DS_DATEOFISSUE,DS_CHECK_FORM_PERMISSION_USER\",\"SP_ORI_VIEW\":\"DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_ASI_SITE_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_ASI_SITE_getDefectTypesForProjects_pf, DS_FETCH_HOLIIDAY_CALENDAR_SUMMARY,DS_ASI_SITE_GET_RECENT_DEFECTS,DS_ASI_Configurable_Attributes\"},\"DS_PROJORGANISATIONS\":\"\",\"DS_PROJUSERS_ALL_ROLES\":\"\",\"DS_PROJDISTGROUPS\":\"\",\"DS_AUTODISTRIBUTE\":\"401\",\"DS_PROJUSERS\":\"\",\"DS_PROJORGANISATIONS_ID\":\"\",\"DS_INCOMPLETE_ACTIONS\":\"\",\"Auto_Distribute_Group\":{\"Auto_Distribute_Users\":[{\"DS_ACTIONDUEDATE\":\"5\",\"DS_FORMACTIONS\":\"3#Respond\",\"DS_PROJDISTUSERS\":\"707447\"}]}},\"selectedControllerUserId\":\"\"}}",
          "FormTypeName": "Inline attachment",
          "FormGroupCode": "INL",
          "AppBuilderId": "INL",
          "TemplateTypeId": 2,
          "AppTypeId": 1
        }
      ]);

      String mapOfConfigListQuery = "SELECT prjTbl.ProjectId,prjTbl.ProjectName,prjTbl.DcId AS DcId,frmTpTbl.FormTypeId,frmTpTbl.FormTypeDetailJson,frmTpTbl.FormTypeName,frmTpTbl.FormTypeGroupCode AS FormGroupCode,frmTpTbl.AppBuilderId,frmTpTbl.TemplateTypeId,frmTpTbl.AppTypeId FROM ProjectDetailTbl prjTbl";
      mapOfConfigListQuery = "$mapOfConfigListQuery INNER JOIN FormGroupAndFormTypeListTbl frmTpTbl ON frmTpTbl.ProjectId=prjTbl.ProjectId";
      mapOfConfigListQuery = "$mapOfConfigListQuery WHERE frmTpTbl.ProjectId=2130192 AND frmTpTbl.FormTypeId=11103151";
      when(() => mockDatabaseManager.executeSelectFromTable(ProjectDao.tableName, mapOfConfigListQuery)).thenReturn([
        {
          "ProjectId": "2116416",
          "ProjectName": "!!PIN_ANY_APP_TYPE_20_9",
          "DcId": 1,
          "FormTypeId": "10616643",
          "FormTypeDetailJson":
          "{\"createFormsLimit\":0,\"canAccessPrivilegedForms\":true,\"formTypeID\":\"10381414\$\$9IBwDZ\",\"allow_attachments\":true,\"formTypesDetail\":{\"formTypeVO\":{\"formTypeID\":\"10381414\$\$9IBwDZ\",\"formTypeName\":\"Fields\",\"code\":\"FID\",\"use_controller\":false,\"response_allowed\":true,\"show_responses\":true,\"allow_reopening_form\":true,\"default_action\":\"3\$\$CPl6Fg\",\"is_default\":true,\"allow_forwarding\":false,\"allow_distribution_after_creation\":true,\"allow_distribution_originator\":true,\"allow_distribution_recipients\":false,\"allow_forward_originator\":false,\"allow_forward_recipients\":false,\"responders_collaborate\":false,\"continue_discussion\":false,\"hide_orgs_and_users\":false,\"has_hyperlink\":false,\"allow_attachments\":true,\"allow_doc_associates\":true,\"allow_form_associations\":true,\"allow_attributes\":false,\"associations_extend_doc_issue\":false,\"public_message\":false,\"browsable_attachment_folder\":false,\"has_overall_status\":true,\"is_instance\":true,\"form_type_group_id\":341,\"instance_group_id\":\"10381414\$\$9IBwDZ\",\"ctrl_change_status\":false,\"parent_formtype_id\":\"2171706\$\$6zD4x9\",\"orig_change_status\":true,\"orig_can_close\":false,\"upload_logo\":false,\"user_ref\":false,\"allow_comment_associations\":false,\"is_public\":true,\"is_active\":true,\"signatureBox\":\"000\",\"xsnFile\":\"2181422.xsn\$\$guzLhn\",\"xmlData\":\"<?mso-infoPathSolution name=\\\"urn:schemas-microsoft-com:office:infopath:ASI-Request-For-Information-Mobile-View:-myXSD-2008-07-03T04-59-35\\\" href=\\\"ASI_Request_For_Information_Mobile_View_tImEsTaMp516083820727589_516447\\\" solutionVersion=\\\"1.0.0.196\\\" productVersion=\\\"12.0.0\\\" PIVersion=\\\"1.0.0.0\\\" ?><?mso-application progid=\\\"InfoPath.Document\\\"?><my:myFields xmlns:xsi=\\\"http://www.w3.org/2001/XMLSchema-instance\\\" xmlns:xhtml=\\\"http://www.w3.org/1999/xhtml\\\" xmlns:my=\\\"http://schemas.microsoft.com/office/infopath/2003/myXSD/2008-07-03T04:59:35\\\" xmlns:xd=\\\"http://schemas.microsoft.com/office/infopath/2003\\\"><my:ORI_FORMTITLE/><my:FORM_CUSTOM_FIELDS><my:ORI_MSG_Custom_Fields><my:Description/></my:ORI_MSG_Custom_Fields><my:RES_MSG_Custom_Fields><my:Response/></my:RES_MSG_Custom_Fields></my:FORM_CUSTOM_FIELDS><my:Asite_System_Data_Read_Only><my:_1_User_Data><my:DS_WORKINGUSER/><my:DS_WORKINGUSERROLE/></my:_1_User_Data><my:_2_Printing_Data><my:DS_PRINTEDBY/><my:DS_PRINTEDON/></my:_2_Printing_Data><my:_3_Project_Data><my:DS_PROJECTNAME/><my:DS_CLIENTDS_CLIENT/></my:_3_Project_Data><my:_4_Form_Type_Data><my:DS_FORMNAME/><my:DS_FORMGROUPCODE/></my:_4_Form_Type_Data><my:_5_Form_Data><my:DS_FORMID/><my:DS_ORIGINATOR/><my:DS_DATEOFISSUE/><my:DS_DISTRIBUTION/><my:DS_CONTROLLERNAME/><my:DS_ATTRIBUTES/><my:Status_Data><my:DS_FORMSTATUS/><my:DS_CLOSEDUEDATE/><my:DS_APPROVEDBY/><my:DS_APPROVEDON/><my:DS_ALL_FORMSTATUS>Open</my:DS_ALL_FORMSTATUS></my:Status_Data><my:DS_CLOSE_DUE_DATE/></my:_5_Form_Data><my:_6_Form_MSG_Data><my:DS_MSGID/><my:DS_MSGCREATOR/><my:DS_MSGDATE/><my:DS_MSGSTATUS/><my:DS_MSGRELEASEDATE/><my:ORI_MSG_Data><my:DS_DOC_ASSOCIATIONS_ORI/><my:DS_FORM_ASSOCIATIONS_ORI/><my:DS_ATTACHMENTS_ORI/></my:ORI_MSG_Data></my:_6_Form_MSG_Data></my:Asite_System_Data_Read_Only><my:Asite_System_Data_Read_Write><my:ORI_MSG_Fields><my:ORI_USERREF/><my:DS_AUTODISTRIBUTE>2</my:DS_AUTODISTRIBUTE><my:DS_ACTIONDUEDATE>3</my:DS_ACTIONDUEDATE><my:DS_FORMACTIONS>3 # Respond</my:DS_FORMACTIONS><my:DS_PROJDISTUSERS/></my:ORI_MSG_Fields></my:Asite_System_Data_Read_Write><my:Assign_To/></my:myFields>\",\"templateType\":1,\"responsePattern\":0,\"fixedFieldIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"displayFileName\":\"ASI_Request_For_Information_Mobile_View.xsn\$\$z08kl4\",\"viewIds\":\"2,6,4,3,8,10,7,9,5,1,\",\"mandatoryDistribution\":0,\"responseFromAll\":false,\"subTemplateType\":0,\"integrateExchange\":false,\"allowEditingORI\":false,\"allowImportExcelInEditORI\":false,\"isOverwriteExcelInEditORI\":true,\"enableECatalague\":false,\"formGroupName\":\"Fields\",\"projectId\":\"2116416\$\$s2Ieys\",\"clonedFormTypeId\":0,\"appBuilderFormIDCode\":\"\",\"loginUserId\":2017529,\"xslFileName\":\"\",\"allowImportForm\":false,\"allowWorkspaceLink\":false,\"linkedWorkspaceProjectId\":\"-1\$\$BUrsqP\",\"createFormsLimit\":0,\"spellCheckPrefs\":\"10\",\"isMobile\":false,\"createFormsLimitLevel\":0,\"restrictChangeFormStatus\":0,\"enableDraftResponses\":0,\"isDistributionFromGroupOnly\":true,\"isAutoCreateOnStatusChange\":false,\"docAssociationType\":1,\"viewFieldIdsData\":\"<root><views><viewid>2</viewid><view_name>ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>6</viewid><view_name>MB_ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>4</viewid><view_name>RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>5</viewid><view_name>FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>3</viewid><view_name>RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>8</viewid><view_name>MB_RES_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>1</viewid><view_name>ORI_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>7</viewid><view_name>MB_ORI_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>9</viewid><view_name>MB_RES_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views><views><viewid>10</viewid><view_name>MB_FORM_PRINT_VIEW</view_name><fieldids>2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,</fieldids></views></root>\",\"createdMsgCount\":0,\"draft_count\":0,\"draftMsgId\":0,\"view_always_form_association\":false,\"view_always_doc_association\":false,\"auto_publish_to_folder\":false,\"default_folder_path\":\"\",\"default_folder_id\":\"\$\$YDWWpv\",\"allowExternalAccess\":0,\"embedFormContentInEmail\":0,\"canReplyViaEmail\":0,\"externalUsersOnly\":0,\"appTypeId\":2,\"dataCenterId\":0,\"allowViewAssociation\":0,\"infojetServerVersion\":1,\"isFormAvailableOffline\":0,\"allowDistributionByAll\":false,\"allowDistributionByRoles\":false,\"allowDistributionRoleIds\":\"\",\"canEditWithAppbuilder\":false,\"hasAppbuilderTemplateDraft\":false,\"isTemplateChanged\":false,\"viewsList\":[{\"viewId\":1,\"viewName\":\"ORI_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":2,\"viewName\":\"ORI_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":3,\"viewName\":\"RES_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":4,\"viewName\":\"RES_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":5,\"viewName\":\"FORM_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":6,\"viewName\":\"MB_ORI_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":7,\"viewName\":\"MB_ORI_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":8,\"viewName\":\"MB_RES_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":9,\"viewName\":\"MB_RES_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true},{\"viewId\":10,\"viewName\":\"MB_FORM_PRINT_VIEW\",\"formTypeId\":\"0\$\$gyAzEZ\",\"appBuilderEnabled\":false,\"fieldsIds\":\"2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,25,26,27,29,30,36,43,563,\",\"generateURI\":true}],\"isRecent\":false,\"allowLocationAssociation\":false,\"isLocationAssocMandatory\":false,\"bfpc\":\"0\$\$kFpU9W\",\"had\":\"0\$\$lVfG3Y\",\"isFromMarketplace\":false,\"isMarkDefault\":false,\"isNewlyCreated\":false,\"isAsycnProcess\":false},\"actionList\":[{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Assign Status\",\"actionID\":\"2\$\$r5ZUtw\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Attach Docs\",\"actionID\":\"5\$\$RvyG5d\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Distribute\",\"actionID\":\"6\$\$pwccPZ\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Acknowledgement\",\"actionID\":\"37\$\$vhxsnH\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Action\",\"actionID\":\"36\$\$bzONin\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"For Information\",\"actionID\":\"7\$\$X2RF5y\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":true,\"is_associated\":true,\"actionName\":\"Respond\",\"actionID\":\"3\$\$CPl6Fg\",\"num_days\":1,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true},{\"is_default\":false,\"is_associated\":true,\"actionName\":\"Review Draft\",\"actionID\":\"34\$\$vhA0uD\",\"num_days\":2,\"projectId\":\"0\$\$PZfIIv\",\"userId\":0,\"revisionId\":\"0\$\$cJarHV\",\"formId\":\"0\$\$gyAzEZ\",\"adoddleContextId\":0,\"customObjectInstanceId\":\"0\$\$Tky0yC\",\"docId\":\"0\$\$b3Bja2\",\"generateURI\":true}],\"formTypeGroupVO\":{\"formTypeGroupID\":341,\"formTypeGroupName\":\"Adoddle-All Apps\",\"generateURI\":true},\"statusList\":[{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Approve\",\"statusID\":1004,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":true,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed\",\"statusID\":3,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved\",\"statusID\":4,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Approved with Comments\",\"statusID\":5,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":true,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Closed-Rejected\",\"statusID\":6,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Open\",\"statusID\":1001,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Resolved\",\"statusID\":1002,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true},{\"is_associated\":false,\"closesOutForm\":false,\"hasAccess\":true,\"always_active\":false,\"userId\":0,\"isDeactive\":false,\"defaultPermissionId\":0,\"statusName\":\"Verified\",\"statusID\":1003,\"orgId\":\"0\$\$Jpae2Y\",\"proxyUserId\":0,\"isEnableForReviewComment\":false,\"generateURI\":true}],\"isFormInherited\":false,\"generateURI\":true},\"createdFormsCount\":0,\"draftFormsCount\":0,\"templatetype\":1,\"appId\":2,\"formTypeName\":\"Fields\",\"totalForms\":0,\"formtypeGroupid\":341,\"isFavourite\":true,\"appBuilderID\":\"\",\"canViewDraftMsg\":false,\"formTypeGroupName\":\"Fields\",\"formGroupCode\":\"FID\",\"canCreateForm\":true,\"numActions\":0,\"crossWorkspaceID\":-1,\"instanceGroupId\":10381414,\"allow_associate_location\":false,\"numOverdueActions\":0,\"is_location_assoc_mandatory\":false,\"workspaceid\":2116416}",
          "FormTypeName": "Inline attachment",
          "FormGroupCode": "INL",
          "AppBuilderId": "INL",
          "TemplateTypeId": 2,
          "AppTypeId": 1
        }
      ]);

      String formVOFromDBQuery = "WITH OfflineSyncData AS (SELECT ";
      formVOFromDBQuery = "$formVOFromDBQuery CASE frmMsgTbl.OfflineRequestData WHEN 2 THEN 5 ELSE 1 END AS Type, frmTypeTbl.AppTypeId, frmMsgTbl.ProjectId, frmMsgTbl.FormTypeId, frmTypeTbl.InstanceGroupId, frmTypeTbl.TemplateTypeId, frmMsgTbl.FormId, frmMsgTbl.MsgId, frmMsgTbl.MsgTypeId, frmMsgTbl.OfflineRequestData, frmMsgTbl.UpdatedDateInMS, frmMsgTbl.IsDraft, frmMsgTbl.DelFormIds";
      formVOFromDBQuery = "$formVOFromDBQuery FROM FormMessageListTbl frmMsgTbl";
      formVOFromDBQuery = "$formVOFromDBQuery INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=frmMsgTbl.ProjectId AND frmTbl.FormId=frmMsgTbl.FormId";
      formVOFromDBQuery = "$formVOFromDBQuery INNER JOIN FormGroupAndFormTypeListTbl frmTypeTbl ON frmTypeTbl.ProjectId=frmMsgTbl.ProjectId AND frmTypeTbl.FormTypeId=frmMsgTbl.FormTypeId";
      formVOFromDBQuery = "$formVOFromDBQuery WHERE frmMsgTbl.OfflineRequestData<>''";
      formVOFromDBQuery = "$formVOFromDBQuery AND ((frmTypeTbl.TemplateTypeId=1 AND frmMsgTbl.IsDraft<>1) OR frmTypeTbl.TemplateTypeId<>1))";
      formVOFromDBQuery = "$formVOFromDBQuery SELECT IFNULL(fldSycDataView.OfflineRequestData,'') AS NewOfflineRequestData,frmTbl.* FROM FormListTbl frmTbl";
      formVOFromDBQuery = "$formVOFromDBQuery LEFT JOIN OfflineSyncData  fldSycDataView ON frmTbl.ProjectId=fldSycDataView.ProjectId AND frmTbl.FormId=fldSycDataView.FormId";
      formVOFromDBQuery = "$formVOFromDBQuery AND fldSycDataView.Type IN (1,2,5)";
      formVOFromDBQuery = "$formVOFromDBQuery WHERE frmTbl.ProjectId=2130192 ";
      formVOFromDBQuery = "$formVOFromDBQuery AND frmTbl.FormId=11607652";
      var data1 = [
        {
          "NewOfflineRequestData": [],
          "ProjectId": "2116416",
          "FormId": "11608838",
          "AppTypeId": 2,
          "FormTypeId": "10641209",
          "InstanceGroupId": "10381138",
          "FormTitle": "TA-0407-Attachment",
          "Code": "DEF2278",
          "CommentId": "11608838",
          "MessageId": "12311326",
          "ParentMessageId": 0,
          "OrgId": "5763307",
          "FirstName": "Mayur",
          "LastName": "Raval m.",
          "OrgName": "Asite Solutions Ltd",
          "Originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "OriginatorDisplayName": " Mayur Raval m., Asite Solutions Ltd",
          "NoOfActions": 0,
          "ObservationId": 107285,
          "LocationId": 183904,
          "PfLocFolderId": 115335312,
          "Updated": "19-Jul-2023#23:56 CST",
          "AttachmentImageName": "",
          "MsgCode": "ORI001",
          "TypeImage": "icons/form.png",
          "DocType": "Apps",
          "HasAttachments": 0,
          "HasDocAssocations": 0,
          "HasBimViewAssociations": 0,
          "HasFormAssocations": 0,
          "HasCommentAssocations": 0,
          "FormHasAssocAttach": 0,
          "FormCreationDate": "19-Jul-2023#23:56 CST",
          "FolderId": 0,
          "MsgTypeId": 1,
          "MsgStatusId": 20,
          "FormNumber": 2278,
          "MsgOriginatorId": 2017529,
          "TemplateType": 2,
          "IsDraft": 0,
          "StatusId": 1001,
          "OriginatorId": 2017529,
          "IsStatusChangeRestricted": 0,
          "AllowReopenForm": 0,
          "CanOrigChangeStatus": 0,
          "MsgTypeCode": "ORI",
          "Id": "",
          "StatusChangeUserId": 0,
          "StatusUpdateDate": "19-Jul-2023#23:56 CST",
          "StatusChangeUserName": " Mayur Raval m.",
          "StatusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "StatusChangeUserEmail": "m.raval@asite.com",
          "StatusChangeUserOrg": "Asite Solutions Ltd",
          "OriginatorEmail": "m.raval@asite.com",
          "ControllerUserId": 0,
          "UpdatedDateInMS": 1689828977000,
          "FormCreationDateInMS": 1689828977000,
          "ResponseRequestByInMS": 1690952399000,
          "FlagType": 0,
          "LatestDraftId": 0,
          "FlagTypeImageName": "flag_type/flag_0.png",
          "MessageTypeImageName": "icons/form.png",
          "CanAccessHistory": 1,
          "FormJsonData": "",
          "Status": "Open",
          "AttachedDocs": "0",
          "IsUploadAttachmentInTemp": 0,
          "IsSync": 0,
          "UserRefCode": "",
          "HasActions": 0,
          "CanRemoveOffline": 0,
          "IsMarkOffline": 0,
          "IsOfflineCreated": 0,
          "SyncStatus": 1,
          "IsForDefect": 0,
          "IsForApps": 0,
          "ObservationDefectTypeId": "218898",
          "StartDate": "2023-07-20",
          "ExpectedFinishDate": "2023-08-01",
          "IsActive": 1,
          "ObservationCoordinates": '{"x1":360.001440304004,"y1":134.31719617472731,"x2":370.001440304004,"y2":144.31719617472731}',
          "AnnotationId": "08C66C6A-1478-4A97-BB40-E938BCB6F81B-1689828968",
          "IsCloseOut": 0,
          "AssignedToUserId": 1079650,
          "AssignedToUserName": "",
          "AssignedToUserOrgName": "Asite Solutions",
          "MsgNum": 0,
          "RevisionId": "",
          "RequestJsonForOffline": "",
          "FormDueDays": 12,
          "FormSyncDate": "2023-07-20 05:56:17.27",
          "LastResponderForAssignedTo": "1079650",
          "LastResponderForOriginator": "2017529",
          "PageNumber": 1,
          "ObservationDefectType": "0",
          "StatusName": "Open",
          "AppBuilderId": "SNG-DEF",
          "TaskTypeName": "",
          "AssignedToRoleName": ""
        }
      ];
      when(() => mockDatabaseManager.executeSelectFromTable(FormDao.tableName, formVOFromDBQuery)).thenReturn(data1);

      String formMessageVOFromDBQuery = "SELECT * FROM FormMessageListTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607652 AND MsgId=123";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageDao.tableName, formMessageVOFromDBQuery)).thenReturn([jsonDecode(formMessageJson)]);

      String mapOfMessagesAttachmentListQuery = "SELECT frmMsgAttachTbl.*, prjTbl.DcId, IFNULL(frmView.LocationId,0) AS LocationId,"
          " IFNULL(frmView.ObservationId,0) AS ObservationId, IFNULL(frmView.AppBuilderId,'') AS AppBuilderId, "
          "IFNULL(frmView.TemplateType,0) AS TemplateType FROM FormMsgAttachAndAssocListTbl frmMsgAttachTbl "
          "INNER JOIN ProjectDetailTbl prjTbl ON prjTbl.ProjectId=frmMsgAttachTbl.ProjectId "
          "LEFT JOIN FormListTbl frmView ON frmView.ProjectId=frmMsgAttachTbl.AssocProjectId AND frmView.FormId=frmMsgAttachTbl.AssocFormCommId AND frmMsgAttachTbl.AttachmentType IN (2,6)";
      mapOfMessagesAttachmentListQuery = "$mapOfMessagesAttachmentListQuery WHERE frmMsgAttachTbl.ProjectId=2130192";
      mapOfMessagesAttachmentListQuery = "$mapOfMessagesAttachmentListQuery AND frmMsgAttachTbl.FormId=11608838";
      mapOfMessagesAttachmentListQuery = "$mapOfMessagesAttachmentListQuery AND frmMsgAttachTbl.MsgId=12309970";
      when(() => mockDatabaseManager.executeSelectFromTable(FormMessageAttachAndAssocDao.tableName, mapOfMessagesAttachmentListQuery)).thenReturn([]);

      String mapOfLocationListQuery = "SELECT * FROM LocationDetailTbl";
      mapOfLocationListQuery = "$mapOfLocationListQuery WHERE ProjectId=2130192 AND LocationId=0;";
      when(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, mapOfLocationListQuery)).thenReturn([
        {"ProjectId": "2130192", "FolderId": "115096357", "LocationId": 183682, "LocationTitle": "Basement", "ParentFolderId": 115096349, "ParentLocationId": 183679, "PermissionValue": 0, "LocationPath": "Site Quality Demo\01 Vijay_Test\Plan-1\Basement", "SiteId": 0, "DocumentId": "13351081", "RevisionId": "26773045", "AnnotationId": "1fc95526-3610-5163-e2c8-c915a692c3d4", "LocationCoordinate": "{\"x1\":593.98,\"y1\":669.61,\"x2\":803.92,\"y2\":522.8199999999999}", "PageNumber": 1, "IsPublic": 0, "IsFavorite": 0, "IsSite": 0, "IsCalibrated": 1, "IsFileUploaded": 0, "IsActive": 1, "HasSubFolder": 0, "CanRemoveOffline": 0, "IsMarkOffline": 1, "SyncStatus": 0, "LastSyncTimeStamp": ""}
      ]);

      var formTypeStatusListJson = fixture('formType_status_list.json');
      when(() => mockFileUtility.readFromFile("./test/fixtures/database/1_808581/2130192/FormTypes/11103151/StatusListData.json")).thenReturn(formTypeStatusListJson);

      var createLocalDataJson = fixture('create_form_local_data_source.json');
      String? getFieldCopyFormHtml5JsonResponse = await createFormLocalDataSource.getFieldCopyFormHtml5Json(jsonDecode(createLocalDataJson));
      expect(!getFieldCopyFormHtml5JsonResponse.isNullOrEmpty(), true);
    });
  });

  group("Custom Attribute SetData By AttributeSetId", () {
    test("getCustomAttributeSetDataByAttributeSetId", () {
      String selectQuery = "SELECT * FROM AttributeSetDetailTbl";
      selectQuery = "$selectQuery WHERE ProjectId=2130192 AND AttributeSetId=556361";
      when(() => mockDatabaseManager.executeSelectFromTable(LocationDao.tableName, selectQuery)).thenReturn([{"ProjectId": "2130192", "FolderId": "115096357", "LocationId": 183682, "LocationTitle": "Basement", "ParentFolderId": 115096349, "ParentLocationId": 183679, "PermissionValue": 0, "LocationPath": "Site Quality Demo\\01 Vijay_Test\\Plan-1\\Basement", "SiteId": 0, "DocumentId": "13351081", "RevisionId": "26773045", "AnnotationId": "1fc95526-3610-5163-e2c8-c915a692c3d4", "jsonResponse": "{\"x1\":593.98,\"y1\":669.61,\"x2\":803.92,\"y2\":522.8199999999999}"}]);

      String? getAttributeData =  createFormLocalDataSource.getCustomAttributeSetDataByAttributeSetId("2130192","556361");
      expect(!getAttributeData.isNullOrEmpty(), true);
    });
  });
}
