import 'dart:convert';

import 'package:field/data/local/qr/qr_local_repository_impl.dart';
import 'package:field/database/db_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/offline_injection_container.dart' as di;
import 'package:sqlite3/common.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appconfig_test_data.dart';

class DBServiceMock extends Mock implements DBService {}

void main() {

  DBServiceMock? mockDb;
  TestWidgetsFlutterBinding.ensureInitialized();
  di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();

  configureDependencies() async {
    mockDb = DBServiceMock();
    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
  }

  setUpAll(() {
    configureDependencies();
  });

  tearDownAll(() {
    mockDb = null;
  });

  test("test check qr code permission for form", () async {
    Map<String, dynamic> map = {};
    map["projectId"] = "2089700";
    map["dcId"] = 1;
    map["instanceGroupId"] = "10676979";
    map["generateQRCodeFor"] = "3";

    final columnList = [
      "ProjectId",
    ];
    final rows = [[
      "2089700"]
    ];

    final columnListForm = [
      "CanCreateForms",
    ];

    final rowsForm = [[1]];
    String getFormQuery = "SELECT *, MAX(FormTypeId) FROM FormGroupAndFormTypeListTbl WHERE ProjectId =2089700 AND InstanceGroupId =10676979;";
    String getProjectQuery = "SELECT ProjectId FROM ProjectDetailTbl WHERE ProjectId =2089700;";

    ResultSet resultSet = ResultSet(columnList, null, rows);
    ResultSet resultSetForm = ResultSet(columnListForm, null, rowsForm);

    String projectTableName = "ProjectDetailTbl";
    String tableName = "FormGroupAndFormTypeListTbl";
    when(() => mockDb!.selectFromTable(projectTableName, getProjectQuery))
        .thenReturn(resultSet);
    when(() => mockDb!.selectFromTable(tableName, getFormQuery))
        .thenReturn(resultSetForm);

    final result = await QRLocalRepository().checkQRCodePermission(map);
    expect(result, isA<SUCCESS>());
    final rowsFormFail = [[0]];
    ResultSet resultSetFormFail = ResultSet(columnListForm, null, rowsFormFail);

    when(() => mockDb!.selectFromTable(tableName, getFormQuery))
        .thenReturn(resultSetFormFail);

    final failureForm = await QRLocalRepository().checkQRCodePermission(map);
    expect(failureForm, isA<FAIL>());

    final List<String> columnListFail = [];
    ResultSet resultSetFail = ResultSet(columnListFail, null, []);
    when(() => mockDb!.selectFromTable(projectTableName, getProjectQuery))
        .thenReturn(resultSetFail);
    final failure = await QRLocalRepository().checkQRCodePermission(map);
    expect(failure, isA<FAIL>());

    when(() => mockDb!.selectFromTable(projectTableName, getProjectQuery))
        .thenReturn(null);
    final failureNull = await QRLocalRepository().checkQRCodePermission(map);
    expect(failureNull, isA<FAIL>());
  });

  test("test check qr code permission for Location", () async {
    Map<String, dynamic> map = {};
    map["projectId"] = "2089700";
    map["dcId"] = 1;
    map["folderIds"] = "115054072";
    map["generateQRCodeFor"] = "1";

    final columnList = ["ProjectId","FolderId","LocationId","LocationTitle","ParentFolderId","ParentLocationId","PermissionValue","LocationPath","SiteId","DocumentId","RevisionId","AnnotationId","LocationCoordinate","PageNumber","IsPublic","IsFavorite","IsSite","IsCalibrated","IsFileUploaded","IsActive","HasSubFolder","CanRemoveOffline","IsMarkOffline","SyncStatus","LastSyncTimeStamp"];
    final rows = [["2089700", "115054072", 183441, "1", 15697133, 0, 0, "KrupalField19.8UK\1", 25367, "0", "0","", "", 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, "2023-08-09 12:00:03.25"]];

    String locationTreeQuery = "SELECT locTbl.* FROM LocationDetailTbl locTbl\n"
        "INNER JOIN LocationDetailTbl cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.ParentLocationId=locTbl.ParentLocationId AND locTbl.IsActive=1 \n"
        "AND cteLoc.ProjectId=2089700 AND cteLoc.FolderId=115054072\n"
        "ORDER BY LocationTitle COLLATE NOCASE ASC";

    ResultSet resultSetLocation = ResultSet(columnList, null, rows);
    when(() => mockDb!.selectFromTable("ProjectDetailTbl", locationTreeQuery))
        .thenReturn(resultSetLocation);
    final result = await QRLocalRepository().checkQRCodePermission(map);
    expect(result, isA<SUCCESS>());

    final rowsFail = [["2089700", "115054072", 183441, "1", 15697133, 0, 0, "KrupalField19.8UK\1", 25367, "0", "0","", "", 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 1, "2023-08-09 12:00:03.25"]];
    ResultSet resultSetFail = ResultSet(columnList, null, rowsFail);
    when(() => mockDb!.selectFromTable("ProjectDetailTbl", locationTreeQuery))
        .thenReturn(resultSetFail);
    final failure = await QRLocalRepository().checkQRCodePermission(map);
    expect(failure, isA<FAIL>());

    ResultSet resultSetEmpty = ResultSet([], null, []);
    when(() => mockDb!.selectFromTable("ProjectDetailTbl", locationTreeQuery))
        .thenReturn(resultSetEmpty);
    final failureEmpty = await QRLocalRepository().checkQRCodePermission(map);
    expect(failureEmpty, isA<FAIL>());

  });

  test("test get form privilege", () async {
    Map<String, dynamic> map = {};
    map["projectId"] = "2089700";
    map["dcId"] = 1;
    map["instanceGroupId"] = "10676979";

    final columnList = ["ProjectId","FormTypeId","FormTypeGroupId","FormTypeGroupName","FormTypeGroupCode","FormTypeName","AppBuilderId","InstanceGroupId","TemplateTypeId","FormTypeDetailJson","AllowLocationAssociation","CanCreateForms","AppTypeId"];
    final rows = [[2089700, 11104817, 379, "Defects", "DEF", "Defect", "SNG - DEF1", 10676979, 1,jsonEncode({
      "createFormsLimit": 0,
      "canAccessPrivilegedForms": true,
      "formTypeID": "11104817",
      "allow_attachments": true,
      "formTypesDetail": {
        "formTypeVO": {
          "formTypeID": "11104817",
          "formTypeName": "Defect",
          "code": "DEF",
          "use_controller": false,
          "response_allowed": true,
          "show_responses": true,
          "allow_reopening_form": true,
          "default_action": "7",
          "is_default": true,
          "allow_forwarding": false,
          "allow_distribution_after_creation": false,
          "allow_distribution_originator": false,
          "allow_distribution_recipients": false,
          "allow_forward_originator": false,
          "allow_forward_recipients": false,
          "responders_collaborate": true,
          "continue_discussion": true,
          "hide_orgs_and_users": false,
          "has_hyperlink": false,
          "allow_attachments": true,
          "allow_doc_associates": true,
          "allow_form_associations": true,
          "allow_attributes": false,
          "associations_extend_doc_issue": false,
          "public_message": false,
          "browsable_attachment_folder": false,
          "has_overall_status": true,
          "is_instance": true,
          "form_type_group_id": 379,
          "instance_group_id": "10676979",
          "ctrl_change_status": false,
          "parent_formtype_id": "2271684",
          "orig_change_status": false,
          "orig_can_close": false,
          "upload_logo": false,
          "user_ref": false,
          "allow_comment_associations": false,
          "is_public": false,
          "is_active": true,
          "signatureBox": "000",
          "xsnFile": "2283389.xsn",
          "xmlData": "<?mso-infoPathSolution name='urn:schemas-microsoft-com:office:infopath:DefectManager:-myXSD-2015-01-27T06-22-02' href='DefectManager_tImEsTaMp3980509418471061_15916' solutionVersion='1.0.0.699' productVersion='15.0.0' PIVersion='1.0.0.0' ?><?mso-application progid='InfoPath.Document' versionProgid='InfoPath.Document.4'?><my:myFields xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xhtml=\"http://www.w3.org/1999/xhtml\" xmlns:dfs=\"http://schemas.microsoft.com/office/infopath/2003/dataFormSolution\" xmlns:impl=\"http://soap.service.api.asite.com\" xmlns:my=\"http://schemas.microsoft.com/office/infopath/2003/myXSD/2015-01-27T06:22:02\" xmlns:xd=\"http://schemas.microsoft.com/office/infopath/2003\"><my:FORM_CUSTOM_FIELDS><my:ORI_MSG_Custom_Fields><my:ORI_FORMTITLE/><my:ORI_USERREF/><my:Todays_Date/><my:DefectTyoe/><my:DefectDescription/><my:Location/><my:StartDate>2017-02-03</my:StartDate><my:ExpectedFinishDate>2017-02-04</my:ExpectedFinishDate><my:OriginatorId/><my:ActualFinishDate xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:nil=\"true\"/><my:AssignedToUsersGroup><my:AssignedToUsers><my:AssignedToUser/></my:AssignedToUsers></my:AssignedToUsersGroup><my:CurrStage xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:nil=\"true\"/><my:PF_Location_Detail/><my:Defect_Description/><my:Username/><my:Organization/></my:ORI_MSG_Custom_Fields><my:RES_MSG_Custom_Fields><my:Comments/><my:ShowHideFlag>Yes</my:ShowHideFlag><my:SHResponse>Yes</my:SHResponse></my:RES_MSG_Custom_Fields><my:CREATE_FWD_RES><my:Can_Reply/></my:CREATE_FWD_RES><my:DS_AUTONUMBER><my:DS_FORMAUTONO_CREATE/><my:DS_SEQ_LENGTH/><my:DS_FORMAUTONO_ADD/></my:DS_AUTONUMBER><my:DS_DATASOURCE><my:DS_getAllLocationByProject_PF my:DS_getAllLocationByProject_PF_PARAM=\"1\"/><my:DS_Response_PARAM>#Comments#DS_ALL_FORMSTATUS</my:DS_Response_PARAM><my:DS_Get_All_Responses my:DS_Get_All_Responses_PARAM=\"DS_Response_PARAM\"/><my:DS_getDefectTypesForProjects_pf/></my:DS_DATASOURCE></my:FORM_CUSTOM_FIELDS><my:Asite_System_Data_Read_Only><my:_1_User_Data><my:DS_WORKINGUSER/><my:DS_WORKINGUSERROLE/><my:DS_WORKINGUSER_ID/><my:DS_WORKINGUSER_ALL_ROLES/></my:_1_User_Data><my:_2_Printing_Data><my:DS_PRINTEDBY/><my:DS_PRINTEDON/></my:_2_Printing_Data><my:_3_Project_Data><my:DS_PROJECTNAME/><my:DS_CLIENT/></my:_3_Project_Data><my:_4_Form_Type_Data><my:DS_FORMNAME/><my:DS_FORMGROUPCODE/><my:DS_FORMAUTONO/></my:_4_Form_Type_Data><my:_5_Form_Data><my:DS_FORMID/><my:DS_ORIGINATOR/><my:DS_DATEOFISSUE/><my:DS_DISTRIBUTION/><my:DS_CONTROLLERNAME/><my:DS_ATTRIBUTES/><my:DS_MAXFORMNO/><my:DS_MAXORGFORMNO/><my:DS_ISDRAFT/><my:DS_ISDRAFT_RES/><my:DS_FORMAUTONO_PREFIX/><my:DS_FORMCONTENT/><my:DS_FORMCONTENT1/><my:DS_FORMCONTENT2/><my:DS_FORMCONTENT3/><my:DS_ISDRAFT_RES_MSG/><my:DS_ISDRAFT_FWD_MSG/><my:Status_Data><my:DS_FORMSTATUS/><my:DS_CLOSEDUEDATE/><my:DS_APPROVEDBY/><my:DS_APPROVEDON/><my:DS_CLOSE_DUE_DATE xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:nil=\"true\"/><my:DS_ALL_FORMSTATUS/><my:DS_ALL_ACTIVE_FORM_STATUS/></my:Status_Data></my:_5_Form_Data><my:_6_Form_MSG_Data><my:DS_MSGID/><my:DS_MSGCREATOR/><my:DS_MSGDATE/><my:DS_MSGSTATUS/><my:DS_MSGRELEASEDATE/><my:ORI_MSG_Data><my:DS_DOC_ASSOCIATIONS_ORI/><my:DS_FORM_ASSOCIATIONS_ORI/><my:DS_ATTACHMENTS_ORI/></my:ORI_MSG_Data></my:_6_Form_MSG_Data></my:Asite_System_Data_Read_Only><my:Asite_System_Data_Read_Write><my:ORI_MSG_Fields><my:SP_ORI_VIEW>DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_getDefectTypesForProjects_pf</my:SP_ORI_VIEW><my:SP_ORI_PRINT_VIEW>DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses</my:SP_ORI_PRINT_VIEW><my:SP_FORM_PRINT_VIEW>DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses</my:SP_FORM_PRINT_VIEW><my:SP_RES_VIEW>DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES</my:SP_RES_VIEW><my:SP_RES_PRINT_VIEW>DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES</my:SP_RES_PRINT_VIEW></my:ORI_MSG_Fields><my:DS_PROJORGANISATIONS/><my:DS_PROJUSERS/><my:DS_PROJDISTGROUPS/><my:DS_AUTODISTRIBUTE xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:nil=\"true\"/><my:DS_INCOMPLETE_ACTIONS/><my:DS_PROJORGANISATIONS_ID/><my:DS_PROJUSERS_ALL_ROLES/><my:Auto_Distribute_Group><my:Auto_Distribute_Users><my:DS_PROJDISTUSERS/><my:DS_FORMACTIONS/><my:DS_ACTIONDUEDATE xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:nil=\"true\">2017-02-04</my:DS_ACTIONDUEDATE></my:Auto_Distribute_Users></my:Auto_Distribute_Group></my:Asite_System_Data_Read_Write><my:group1/><my:group2/><my:group3/><my:group4/><my:group5/><my:group6/></my:myFields>",
          "templateType": 1,
          "responsePattern": 0,
          "fixedFieldIds": "2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,32,33,34,35,36,43,51,159,308,528,562,563,628,639,657,671,798,1663,1664,3638,3732,3871,",
          "displayFileName": "DefectManager.xsn",
          "viewIds": "3,1,2,5,4,",
          "mandatoryDistribution": 2,
          "responseFromAll": true,
          "subTemplateType": 0,
          "integrateExchange": false,
          "allowEditingORI": false,
          "allowImportExcelInEditORI": false,
          "isOverwriteExcelInEditORI": true,
          "enableECatalague": false,
          "formGroupName": "Defects",
          "projectId": "2089700",
          "clonedFormTypeId": 0,
          "appBuilderFormIDCode": "SNG-DEF1",
          "loginUserId": 1906453,
          "xslFileName": "",
          "allowImportForm": false,
          "allowWorkspaceLink": false,
          "linkedWorkspaceProjectId": "-1",
          "createFormsLimit": 0,
          "spellCheckPrefs": "00",
          "isMobile": false,
          "createFormsLimitLevel": 0,
          "restrictChangeFormStatus": 1,
          "enableDraftResponses": 0,
          "isDistributionFromGroupOnly": false,
          "isAutoCreateOnStatusChange": false,
          "docAssociationType": 1,
          "viewFieldIdsData": "<root><views><viewid>2</viewid><view_name>ORI_PRINT_VIEW</view_name><fieldids>2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528,3732</fieldids></views><views><viewid>4</viewid><view_name>RES_PRINT_VIEW</view_name><fieldids>2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528</fieldids></views><views><viewid>5</viewid><view_name>FORM_PRINT_VIEW</view_name><fieldids>2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528,3732</fieldids></views><views><viewid>3</viewid><view_name>RES_VIEW</view_name><fieldids>2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528</fieldids></views><views><viewid>1</viewid><view_name>ORI_VIEW</view_name><fieldids>2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528,3871</fieldids></views></root>",
          "createdMsgCount": 0,
          "draft_count": 0,
          "draftMsgId": 0,
          "view_always_form_association": false,
          "view_always_doc_association": false,
          "auto_publish_to_folder": false,
          "default_folder_path": "",
          "default_folder_id": "",
          "allowExternalAccess": 0,
          "embedFormContentInEmail": 0,
          "canReplyViaEmail": 0,
          "externalUsersOnly": 0,
          "appTypeId": 2,
          "dataCenterId": 0,
          "allowViewAssociation": 0,
          "infojetServerVersion": 0,
          "isFormAvailableOffline": 1,
          "allowDistributionByAll": false,
          "allowDistributionByRoles": false,
          "allowDistributionRoleIds": "",
          "canEditWithAppbuilder": false,
          "hasAppbuilderTemplateDraft": false,
          "isTemplateChanged": false,
          "viewsList": [{
            "viewId": 1,
            "viewName": "ORI_VIEW",
            "formTypeId": "0",
            "appBuilderEnabled": false,
            "fieldsIds": "2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528,3871",
            "generateURI": true
          }, {
            "viewId": 2,
            "viewName": "ORI_PRINT_VIEW",
            "formTypeId": "0",
            "appBuilderEnabled": false,
            "fieldsIds": "2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528,3732",
            "generateURI": true
          }, {
            "viewId": 3,
            "viewName": "RES_VIEW",
            "formTypeId": "0",
            "appBuilderEnabled": false,
            "fieldsIds": "2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528",
            "generateURI": true
          }, {
            "viewId": 4,
            "viewName": "RES_PRINT_VIEW",
            "formTypeId": "0",
            "appBuilderEnabled": false,
            "fieldsIds": "2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528",
            "generateURI": true
          }, {
            "viewId": 5,
            "viewName": "FORM_PRINT_VIEW",
            "formTypeId": "0",
            "appBuilderEnabled": false,
            "fieldsIds": "2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528,3732",
            "generateURI": true
          }],
          "isRecent": false,
          "allowLocationAssociation": false,
          "isLocationAssocMandatory": false,
          "bfpc": "0",
          "had": "0",
          "isFromMarketplace": false,
          "isMarkDefault": false,
          "isNewlyCreated": false,
          "isAsycnProcess": false
        },
        "actionList": [{
          "is_default": false,
          "is_associated": false,
          "actionName": "Assign Status",
          "actionID": "2",
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }, {
          "is_default": false,
          "is_associated": false,
          "actionName": "Attach Docs",
          "actionID": "5",
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }, {
          "is_default": false,
          "is_associated": false,
          "actionName": "Distribute",
          "actionID": "6",
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }, {
          "is_default": false,
          "is_associated": false,
          "actionName": "For Acknowledgement",
          "actionID": "37",
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }, {
          "is_default": false,
          "is_associated": false,
          "actionName": "For Action",
          "actionID": "36",
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }, {
          "is_default": true,
          "is_associated": true,
          "actionName": "For Information",
          "actionID": "7",
          "num_days": -1,
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }, {
          "is_default": false,
          "is_associated": true,
          "actionName": "Respond",
          "actionID": "3",
          "num_days": 7,
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }, {
          "is_default": false,
          "is_associated": false,
          "actionName": "Review Draft",
          "actionID": "34",
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }],
        "formTypeGroupVO": {
          "formTypeGroupID": 379,
          "formTypeGroupName": "Field Manager",
          "generateURI": true
        },
        "statusList": [{
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Accepted",
          "statusID": 1016,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": true,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Approved",
          "statusID": 1017,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": true,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Closed",
          "statusID": 3,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Closed - RLT",
          "statusID": 1020,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Closed-Approved",
          "statusID": 4,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Closed-Approved with Comments",
          "statusID": 5,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": true,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Closed-Rejected",
          "statusID": 6,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Hb1 `test1 !@& abc",
          "statusID": 1025,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "HB2 Close status",
          "statusID": 1027,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "HB3 Open Status",
          "statusID": 1026,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "In Progress",
          "statusID": 1009,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "In Progress -RLT",
          "statusID": 1021,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "In Review",
          "statusID": 1010,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "More Info Required - RLT",
          "statusID": 1018,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Omitted",
          "statusID": 1019,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Open",
          "statusID": 1001,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Permission Given",
          "statusID": 1013,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Permission Given (Closed)",
          "statusID": 1015,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Re-inspection Required",
          "statusID": 1012,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Rejected",
          "statusID": 1005,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Rejected (Closed)",
          "statusID": 1014,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": true,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Resolved",
          "statusID": 1002,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Reviewed",
          "statusID": 1011,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Submitted",
          "statusID": 1008,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Submitted to Commercial Rep",
          "statusID": 1006,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Submitted to Delegated Authority",
          "statusID": 1007,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Submitted to Resource Team",
          "statusID": 1004,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Tasks Pending",
          "statusID": 1024,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Verified",
          "statusID": 1003,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "With Lab",
          "statusID": 1022,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "With QA",
          "statusID": 1023,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }],
        "isFormInherited": false,
        "generateURI": true
      },
      "createdFormsCount": 5,
      "draftFormsCount": 0,
      "templatetype": 1,
      "appId": 2,
      "formTypeName": "Defect",
      "totalForms": 5,
      "formtypeGroupid": 379,
      "isFavourite": true,
      "appBuilderID": "SNG-DEF1",
      "canViewDraftMsg": false,
      "formTypeGroupName": "Defects",
      "formGroupCode": "DEF",
      "canCreateForm": true,
      "numActions": 1,
      "crossWorkspaceID": -1,
      "instanceGroupId": 10676979,
      "allow_associate_location": false,
      "numOverdueActions": 1,
      "is_location_assoc_mandatory": false,
      "workspaceid": 2089700
    }) , 0, 1, "2"]];
    String selectQuery = "SELECT * FROM FormGroupAndFormTypeListTbl WHERE ProjectId=2089700 AND InstanceGroupId=10676979 ORDER BY FormTypeId DESC";

    ResultSet resultSet = ResultSet(columnList, null, rows);
    when(() => mockDb!.selectFromTable("FormGroupAndFormTypeListTbl", selectQuery))
        .thenReturn(resultSet);
    final result = await QRLocalRepository().getFormPrivilege(map);
    expect(result, isA<SUCCESS>());

    final rowsFail = [[2089700, 11104817, 379, "Defects", "DEF", "Defect", "SNG - DEF1", 10676979, 1, {
      "createFormsLimit": 0,
      "canAccessPrivilegedForms": true,
      "formTypeID": "11104817",
      "allow_attachments": true,
      "formTypesDetail": {
        "formTypeVO": {
          "formTypeID": "11104817",
          "formTypeName": "Defect",
          "code": "DEF",
          "use_controller": false,
          "response_allowed": true,
          "show_responses": true,
          "allow_reopening_form": true,
          "default_action": "7",
          "is_default": true,
          "allow_forwarding": false,
          "allow_distribution_after_creation": false,
          "allow_distribution_originator": false,
          "allow_distribution_recipients": false,
          "allow_forward_originator": false,
          "allow_forward_recipients": false,
          "responders_collaborate": true,
          "continue_discussion": true,
          "hide_orgs_and_users": false,
          "has_hyperlink": false,
          "allow_attachments": true,
          "allow_doc_associates": true,
          "allow_form_associations": true,
          "allow_attributes": false,
          "associations_extend_doc_issue": false,
          "public_message": false,
          "browsable_attachment_folder": false,
          "has_overall_status": true,
          "is_instance": true,
          "form_type_group_id": 379,
          "instance_group_id": "10676979",
          "ctrl_change_status": false,
          "parent_formtype_id": "2271684",
          "orig_change_status": false,
          "orig_can_close": false,
          "upload_logo": false,
          "user_ref": false,
          "allow_comment_associations": false,
          "is_public": false,
          "is_active": true,
          "signatureBox": "000",
          "xsnFile": "2283389.xsn",
          "xmlData": "<?mso-infoPathSolution name='urn:schemas-microsoft-com:office:infopath:DefectManager:-myXSD-2015-01-27T06-22-02' href='DefectManager_tImEsTaMp3980509418471061_15916' solutionVersion='1.0.0.699' productVersion='15.0.0' PIVersion='1.0.0.0' ?><?mso-application progid='InfoPath.Document' versionProgid='InfoPath.Document.4'?><my:myFields xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xhtml=\"http://www.w3.org/1999/xhtml\" xmlns:dfs=\"http://schemas.microsoft.com/office/infopath/2003/dataFormSolution\" xmlns:impl=\"http://soap.service.api.asite.com\" xmlns:my=\"http://schemas.microsoft.com/office/infopath/2003/myXSD/2015-01-27T06:22:02\" xmlns:xd=\"http://schemas.microsoft.com/office/infopath/2003\"><my:FORM_CUSTOM_FIELDS><my:ORI_MSG_Custom_Fields><my:ORI_FORMTITLE/><my:ORI_USERREF/><my:Todays_Date/><my:DefectTyoe/><my:DefectDescription/><my:Location/><my:StartDate>2017-02-03</my:StartDate><my:ExpectedFinishDate>2017-02-04</my:ExpectedFinishDate><my:OriginatorId/><my:ActualFinishDate xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:nil=\"true\"/><my:AssignedToUsersGroup><my:AssignedToUsers><my:AssignedToUser/></my:AssignedToUsers></my:AssignedToUsersGroup><my:CurrStage xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:nil=\"true\"/><my:PF_Location_Detail/><my:Defect_Description/><my:Username/><my:Organization/></my:ORI_MSG_Custom_Fields><my:RES_MSG_Custom_Fields><my:Comments/><my:ShowHideFlag>Yes</my:ShowHideFlag><my:SHResponse>Yes</my:SHResponse></my:RES_MSG_Custom_Fields><my:CREATE_FWD_RES><my:Can_Reply/></my:CREATE_FWD_RES><my:DS_AUTONUMBER><my:DS_FORMAUTONO_CREATE/><my:DS_SEQ_LENGTH/><my:DS_FORMAUTONO_ADD/></my:DS_AUTONUMBER><my:DS_DATASOURCE><my:DS_getAllLocationByProject_PF my:DS_getAllLocationByProject_PF_PARAM=\"1\"/><my:DS_Response_PARAM>#Comments#DS_ALL_FORMSTATUS</my:DS_Response_PARAM><my:DS_Get_All_Responses my:DS_Get_All_Responses_PARAM=\"DS_Response_PARAM\"/><my:DS_getDefectTypesForProjects_pf/></my:DS_DATASOURCE></my:FORM_CUSTOM_FIELDS><my:Asite_System_Data_Read_Only><my:_1_User_Data><my:DS_WORKINGUSER/><my:DS_WORKINGUSERROLE/><my:DS_WORKINGUSER_ID/><my:DS_WORKINGUSER_ALL_ROLES/></my:_1_User_Data><my:_2_Printing_Data><my:DS_PRINTEDBY/><my:DS_PRINTEDON/></my:_2_Printing_Data><my:_3_Project_Data><my:DS_PROJECTNAME/><my:DS_CLIENT/></my:_3_Project_Data><my:_4_Form_Type_Data><my:DS_FORMNAME/><my:DS_FORMGROUPCODE/><my:DS_FORMAUTONO/></my:_4_Form_Type_Data><my:_5_Form_Data><my:DS_FORMID/><my:DS_ORIGINATOR/><my:DS_DATEOFISSUE/><my:DS_DISTRIBUTION/><my:DS_CONTROLLERNAME/><my:DS_ATTRIBUTES/><my:DS_MAXFORMNO/><my:DS_MAXORGFORMNO/><my:DS_ISDRAFT/><my:DS_ISDRAFT_RES/><my:DS_FORMAUTONO_PREFIX/><my:DS_FORMCONTENT/><my:DS_FORMCONTENT1/><my:DS_FORMCONTENT2/><my:DS_FORMCONTENT3/><my:DS_ISDRAFT_RES_MSG/><my:DS_ISDRAFT_FWD_MSG/><my:Status_Data><my:DS_FORMSTATUS/><my:DS_CLOSEDUEDATE/><my:DS_APPROVEDBY/><my:DS_APPROVEDON/><my:DS_CLOSE_DUE_DATE xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:nil=\"true\"/><my:DS_ALL_FORMSTATUS/><my:DS_ALL_ACTIVE_FORM_STATUS/></my:Status_Data></my:_5_Form_Data><my:_6_Form_MSG_Data><my:DS_MSGID/><my:DS_MSGCREATOR/><my:DS_MSGDATE/><my:DS_MSGSTATUS/><my:DS_MSGRELEASEDATE/><my:ORI_MSG_Data><my:DS_DOC_ASSOCIATIONS_ORI/><my:DS_FORM_ASSOCIATIONS_ORI/><my:DS_ATTACHMENTS_ORI/></my:ORI_MSG_Data></my:_6_Form_MSG_Data></my:Asite_System_Data_Read_Only><my:Asite_System_Data_Read_Write><my:ORI_MSG_Fields><my:SP_ORI_VIEW>DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_getDefectTypesForProjects_pf</my:SP_ORI_VIEW><my:SP_ORI_PRINT_VIEW>DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses</my:SP_ORI_PRINT_VIEW><my:SP_FORM_PRINT_VIEW>DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES,DS_Response_PARAM,DS_Get_All_Responses</my:SP_FORM_PRINT_VIEW><my:SP_RES_VIEW>DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES</my:SP_RES_VIEW><my:SP_RES_PRINT_VIEW>DS_PRINTEDBY,DS_FORMID,DS_ISDRAFT,DS_CLOSE_DUE_DATE,DS_PRINTEDON,ORI_FORMTITLE,ORI_USERREF,DS_ALL_FORMSTATUS,DS_FORMNAME,DS_getAllLocationByProject_PF,DS_ALL_ACTIVE_FORM_STATUS,DS_WORKINGUSER_ID,DS_AUTODISTRIBUTE,DS_FORMSTATUS,DS_PROJDISTUSERS,DS_FORMACTIONS,DS_ACTIONDUEDATE,DS_INCOMPLETE_ACTIONS,DS_PROJUSERS_ALL_ROLES</my:SP_RES_PRINT_VIEW></my:ORI_MSG_Fields><my:DS_PROJORGANISATIONS/><my:DS_PROJUSERS/><my:DS_PROJDISTGROUPS/><my:DS_AUTODISTRIBUTE xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:nil=\"true\"/><my:DS_INCOMPLETE_ACTIONS/><my:DS_PROJORGANISATIONS_ID/><my:DS_PROJUSERS_ALL_ROLES/><my:Auto_Distribute_Group><my:Auto_Distribute_Users><my:DS_PROJDISTUSERS/><my:DS_FORMACTIONS/><my:DS_ACTIONDUEDATE xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:nil=\"true\">2017-02-04</my:DS_ACTIONDUEDATE></my:Auto_Distribute_Users></my:Auto_Distribute_Group></my:Asite_System_Data_Read_Write><my:group1/><my:group2/><my:group3/><my:group4/><my:group5/><my:group6/></my:myFields>",
          "templateType": 1,
          "responsePattern": 0,
          "fixedFieldIds": "2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,32,33,34,35,36,43,51,159,308,528,562,563,628,639,657,671,798,1663,1664,3638,3732,3871,",
          "displayFileName": "DefectManager.xsn",
          "viewIds": "3,1,2,5,4,",
          "mandatoryDistribution": 2,
          "responseFromAll": true,
          "subTemplateType": 0,
          "integrateExchange": false,
          "allowEditingORI": false,
          "allowImportExcelInEditORI": false,
          "isOverwriteExcelInEditORI": true,
          "enableECatalague": false,
          "formGroupName": "Defects",
          "projectId": "2089700",
          "clonedFormTypeId": 0,
          "appBuilderFormIDCode": "SNG-DEF1",
          "loginUserId": 1906453,
          "xslFileName": "",
          "allowImportForm": false,
          "allowWorkspaceLink": false,
          "linkedWorkspaceProjectId": "-1",
          "createFormsLimit": 0,
          "spellCheckPrefs": "00",
          "isMobile": false,
          "createFormsLimitLevel": 0,
          "restrictChangeFormStatus": 1,
          "enableDraftResponses": 0,
          "isDistributionFromGroupOnly": false,
          "isAutoCreateOnStatusChange": false,
          "docAssociationType": 1,
          "viewFieldIdsData": "<root><views><viewid>2</viewid><view_name>ORI_PRINT_VIEW</view_name><fieldids>2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528,3732</fieldids></views><views><viewid>4</viewid><view_name>RES_PRINT_VIEW</view_name><fieldids>2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528</fieldids></views><views><viewid>5</viewid><view_name>FORM_PRINT_VIEW</view_name><fieldids>2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528,3732</fieldids></views><views><viewid>3</viewid><view_name>RES_VIEW</view_name><fieldids>2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528</fieldids></views><views><viewid>1</viewid><view_name>ORI_VIEW</view_name><fieldids>2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528,3871</fieldids></views></root>",
          "createdMsgCount": 0,
          "draft_count": 0,
          "draftMsgId": 0,
          "view_always_form_association": false,
          "view_always_doc_association": false,
          "auto_publish_to_folder": false,
          "default_folder_path": "",
          "default_folder_id": "",
          "allowExternalAccess": 0,
          "embedFormContentInEmail": 0,
          "canReplyViaEmail": 0,
          "externalUsersOnly": 0,
          "appTypeId": 2,
          "dataCenterId": 0,
          "allowViewAssociation": 0,
          "infojetServerVersion": 0,
          "isFormAvailableOffline": 1,
          "allowDistributionByAll": false,
          "allowDistributionByRoles": false,
          "allowDistributionRoleIds": "",
          "canEditWithAppbuilder": false,
          "hasAppbuilderTemplateDraft": false,
          "isTemplateChanged": false,
          "viewsList": [{
            "viewId": 1,
            "viewName": "ORI_VIEW",
            "formTypeId": "0",
            "appBuilderEnabled": false,
            "fieldsIds": "2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528,3871",
            "generateURI": true
          }, {
            "viewId": 2,
            "viewName": "ORI_PRINT_VIEW",
            "formTypeId": "0",
            "appBuilderEnabled": false,
            "fieldsIds": "2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528,3732",
            "generateURI": true
          }, {
            "viewId": 3,
            "viewName": "RES_VIEW",
            "formTypeId": "0",
            "appBuilderEnabled": false,
            "fieldsIds": "2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528",
            "generateURI": true
          }, {
            "viewId": 4,
            "viewName": "RES_PRINT_VIEW",
            "formTypeId": "0",
            "appBuilderEnabled": false,
            "fieldsIds": "2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528",
            "generateURI": true
          }, {
            "viewId": 5,
            "viewName": "FORM_PRINT_VIEW",
            "formTypeId": "0",
            "appBuilderEnabled": false,
            "fieldsIds": "2,7,308,3,20,21,563,25,3638,639,628,8,43,36,671,528,3732",
            "generateURI": true
          }],
          "isRecent": false,
          "allowLocationAssociation": false,
          "isLocationAssocMandatory": false,
          "bfpc": "0",
          "had": "0",
          "isFromMarketplace": false,
          "isMarkDefault": false,
          "isNewlyCreated": false,
          "isAsycnProcess": false
        },
        "actionList": [{
          "is_default": false,
          "is_associated": false,
          "actionName": "Assign Status",
          "actionID": "2",
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }, {
          "is_default": false,
          "is_associated": false,
          "actionName": "Attach Docs",
          "actionID": "5",
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }, {
          "is_default": false,
          "is_associated": false,
          "actionName": "Distribute",
          "actionID": "6",
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }, {
          "is_default": false,
          "is_associated": false,
          "actionName": "For Acknowledgement",
          "actionID": "37",
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }, {
          "is_default": false,
          "is_associated": false,
          "actionName": "For Action",
          "actionID": "36",
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }, {
          "is_default": true,
          "is_associated": true,
          "actionName": "For Information",
          "actionID": "7",
          "num_days": -1,
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }, {
          "is_default": false,
          "is_associated": true,
          "actionName": "Respond",
          "actionID": "3",
          "num_days": 7,
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }, {
          "is_default": false,
          "is_associated": false,
          "actionName": "Review Draft",
          "actionID": "34",
          "projectId": "0",
          "userId": 0,
          "revisionId": "0",
          "formId": "0",
          "adoddleContextId": 0,
          "customObjectInstanceId": "0",
          "docId": "0",
          "generateURI": true
        }],
        "formTypeGroupVO": {
          "formTypeGroupID": 379,
          "formTypeGroupName": "Field Manager",
          "generateURI": true
        },
        "statusList": [{
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Accepted",
          "statusID": 1016,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": true,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Approved",
          "statusID": 1017,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": true,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Closed",
          "statusID": 3,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Closed - RLT",
          "statusID": 1020,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Closed-Approved",
          "statusID": 4,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Closed-Approved with Comments",
          "statusID": 5,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": true,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Closed-Rejected",
          "statusID": 6,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Hb1 `test1 !@& abc",
          "statusID": 1025,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "HB2 Close status",
          "statusID": 1027,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "HB3 Open Status",
          "statusID": 1026,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "In Progress",
          "statusID": 1009,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "In Progress -RLT",
          "statusID": 1021,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "In Review",
          "statusID": 1010,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "More Info Required - RLT",
          "statusID": 1018,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Omitted",
          "statusID": 1019,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Open",
          "statusID": 1001,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Permission Given",
          "statusID": 1013,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Permission Given (Closed)",
          "statusID": 1015,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Re-inspection Required",
          "statusID": 1012,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Rejected",
          "statusID": 1005,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Rejected (Closed)",
          "statusID": 1014,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": true,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Resolved",
          "statusID": 1002,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Reviewed",
          "statusID": 1011,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Submitted",
          "statusID": 1008,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Submitted to Commercial Rep",
          "statusID": 1006,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Submitted to Delegated Authority",
          "statusID": 1007,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Submitted to Resource Team",
          "statusID": 1004,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Tasks Pending",
          "statusID": 1024,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": true,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "Verified",
          "statusID": 1003,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "With Lab",
          "statusID": 1022,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }, {
          "is_associated": false,
          "closesOutForm": false,
          "hasAccess": true,
          "always_active": false,
          "userId": 0,
          "isDeactive": false,
          "defaultPermissionId": 0,
          "statusName": "With QA",
          "statusID": 1023,
          "orgId": "0",
          "proxyUserId": 0,
          "isEnableForReviewComment": false,
          "generateURI": true
        }],
        "isFormInherited": false,
        "generateURI": true
      },
      "createdFormsCount": 5,
      "draftFormsCount": 0,
      "templatetype": 1,
      "appId": 2,
      "formTypeName": "Defect",
      "totalForms": 5,
      "formtypeGroupid": 379,
      "isFavourite": true,
      "appBuilderID": "SNG-DEF1",
      "canViewDraftMsg": false,
      "formTypeGroupName": "Defects",
      "formGroupCode": "DEF",
      "canCreateForm": true,
      "numActions": 1,
      "crossWorkspaceID": -1,
      "instanceGroupId": 10676979,
      "allow_associate_location": false,
      "numOverdueActions": 1,
      "is_location_assoc_mandatory": false,
      "workspaceid": 2089700
    }, 0, 1, "2"]];
    ResultSet resultSetFail = ResultSet(columnList, null, rowsFail);
    when(() => mockDb!.selectFromTable("FormGroupAndFormTypeListTbl", selectQuery))
        .thenReturn(resultSetFail);
    final resultFail = await QRLocalRepository().getFormPrivilege(map);
    expect(resultFail, isA<FAIL>());

  });

  test("test get location details", () async {
    Map<String, dynamic> map = {};
    map["projectId"] = "2089700";
    map["locationIds"] = "183688";
    map["isObservationCountRequired"] = false;

    final columnList = ["ProjectId","FolderId","LocationId","LocationTitle","ParentFolderId","ParentLocationId","PermissionValue","LocationPath","SiteId","DocumentId","RevisionId","AnnotationId","LocationCoordinate","PageNumber","IsPublic","IsFavorite","IsSite","IsCalibrated","IsFileUploaded","IsActive","HasSubFolder","CanRemoveOffline","IsMarkOffline","SyncStatus","LastSyncTimeStamp"];
    final rows = [["2089700", "115097253", 183688, "test", 115059748, 183610, 0, "KrupalField19.8UK\1\2\2.1\test", 0, "13490921", "26992147","", null, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1,""]];
    String selectQuery = "SELECT * FROM LocationDetailTbl WHERE ProjectId=2089700 AND LocationId=183688";

    ResultSet resultSetLocation = ResultSet(columnList, null, rows);
    when(() => mockDb!.selectFromTable("FormGroupAndFormTypeListTbl", selectQuery))
        .thenReturn(resultSetLocation);
    final result = await QRLocalRepository().getLocationDetails(map);
    expect(result, isA<SUCCESS>());

    ResultSet resultSetEmpty = ResultSet(columnList, null, []);
    when(() => mockDb!.selectFromTable("FormGroupAndFormTypeListTbl", selectQuery))
        .thenReturn(resultSetEmpty);
    final resultEmpty = await QRLocalRepository().getLocationDetails(map);
    expect(resultEmpty, isA<FAIL>());
  });

  test("test get field enable selected projects and locations", () async {
    Map<String, dynamic> map = {};
    map["projectId"] = "2089700";
    map["folder_id"] = "115054072";
    map["folderTypeId"] = "1";
    map["projectIds"] = "2089700";
    map["checkHashing"] = "false";
    map["isfromfieldfolder"] = "true";
    map["dcId"] = 1;

    String selectQuery = "SELECT * FROM ProjectDetailTbl WHERE ProjectId=2089700  ORDER BY ProjectName COLLATE NOCASE ASC";

    String locationQuery = "SELECT locTbl.* FROM LocationDetailTbl locTbl INNER JOIN LocationDetailTbl cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.ParentLocationId=locTbl.ParentLocationId AND locTbl.IsActive=1 AND cteLoc.ProjectId=2089700 AND cteLoc.FolderId=115054072 ORDER BY LocationTitle COLLATE NOCASE ASC";

    final columnList = ["ProjectId","FolderId","LocationId","LocationTitle","ParentFolderId","ParentLocationId","PermissionValue","LocationPath","SiteId","DocumentId","RevisionId","AnnotationId","LocationCoordinate","PageNumber","IsPublic","IsFavorite","IsSite","IsCalibrated","IsFileUploaded","IsActive","HasSubFolder","CanRemoveOffline","IsMarkOffline","SyncStatus","LastSyncTimeStamp"];
    final rows = [["2089700", "115097253", 183688, "test", 115059748, 183610, 0, "KrupalField19.8UK\1\2\2.1\test", 0, "13490921", "26992147","", null, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 1,""]];


    ResultSet resultSetLocation = ResultSet(columnList, null, rows);
    when(() => mockDb!.selectFromTable("FormGroupAndFormTypeListTbl", selectQuery))
        .thenReturn(resultSetLocation);
    final result = await QRLocalRepository().getLocationDetails(map);
    expect(result, isA<SUCCESS>());

    ResultSet resultSetEmpty = ResultSet(columnList, null, []);
    when(() => mockDb!.selectFromTable("FormGroupAndFormTypeListTbl", selectQuery))
        .thenReturn(resultSetEmpty);
    final resultEmpty = await QRLocalRepository().getLocationDetails(map);
    expect(resultEmpty, isA<FAIL>());
  });

}