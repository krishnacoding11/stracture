import 'package:field/data/dao/form_dao.dart';
import 'package:field/data/dao/location_dao.dart';
import 'package:field/data/model/pinsdata_vo.dart';
import 'package:field/data_source/site_location/site_location_local_data_source.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/database/db_service.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';

class MockDatabaseManager extends Mock implements DatabaseManager {}

class DBServiceMock extends Mock implements DBService {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SiteLocationLocalDatasource siteLocationLocalDatasource = SiteLocationLocalDatasource();
  DBServiceMock? mockDb;
  MockDatabaseManager mockDatabaseManager = MockDatabaseManager();

  setUpAll(() async {
    MockMethodChannel().setNotificationMethodChannel();
    await di.init(test: true);
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AppConfigTestData().setupAppConfigTestData();
    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
    mockDb = DBServiceMock();
  });

  tearDown(() {
    reset(mockDb);
  });

  tearDownAll(() {
    mockDb = null;
  });

  group("Site Location local data source", () {
    test("getSyncStatusDataByLocationId", () async {
      Map<String, dynamic> paramMap = {};
      paramMap['projectId'] = "2130192";
      paramMap['folderId'] = "115096357";

      String query = "SELECT locTbl.ProjectId,locTbl.LocationId, IFNULL(syncLocTbl.SyncProgress,100) AS SyncProgress,IFNULL(syncLocTbl.SyncStatus,locTbl.SyncStatus) AS SyncStatus,locTbl.CanRemoveOffline,locTbl.IsMarkOffline,locTbl.LastSyncTimeStamp FROM LocationDetailTbl locTbl";
      query = "$query LEFT JOIN SyncLocationTbl syncLocTbl ON syncLocTbl.ProjectId=locTbl.ProjectId AND syncLocTbl.LocationId=locTbl.LocationId";
      query = "$query WHERE locTbl.ProjectId=2130192 AND locTbl.ParentLocationId=0";

      final response = [
        {"ProjectId": "2130192", "LocationId": "183678", "SyncProgress": 0, "SyncStatus": 2, "CanRemoveOffline": 0, "IsMarkOffline": 0, "LastSyncTimeStamp": ""}
      ];
      ResultSet resultSet = ResultSet(paramMap.keys.toList(),null,response.cast<List<Object?>>());

      when(() => mockDb?.selectFromTable(LocationDao.tableName, query)).thenReturn(resultSet);
      final result = await siteLocationLocalDatasource.getSyncStatusDataByLocationId(paramMap);
      expect(result, isA<List<Map<String, dynamic>>>());

    });

    test("getSyncStatusDataByLocationId Exception",() async {
      Map<String, dynamic> paramMap = {};
      paramMap['projectId'] = "2130192";
      paramMap['folderId'] = "115096357";

      when(() => mockDb?.selectFromTable(LocationDao.tableName, any())).thenThrow(Exception());
      final result = await siteLocationLocalDatasource.getSyncStatusDataByLocationId(paramMap);
      expect(result, isA<List<Map<String, dynamic>>>());
    });

    test("getLocationTreeByAnnotationId", () async {
      Map<String, dynamic> paramMap = {};
      paramMap["projectId"] = "2130192";
      paramMap["annotationId"] = "b27a8610-0d01-9d6b-1ee8-0cf1fcad84cf";

      final response = [
        {
          "ProjectId": "2130192",
          "FolderId": "115096357",
          "LocationId": "183682",
          "LocationTitle": "Basement",
          "ParentFolderId": "115096349",
          "ParentLocationId": "183679",
          "PermissionValue": 0,
          "LocationPath": "Site Quality Demo\01 Vijay_Test\Plan-1\Basement",
          "SiteId": 0,
          "DocumentId": "13351081",
          "RevisionId": "26773045",
          "AnnotationId": "1fc95526-3610-5163-e2c8-c915a692c3d4",
          "LocationCoordinate": {"x1": "593.98", "y1": "669.61", "x2": "803.92", "y2": "522.8199999999999"},
          "PageNumber": 1,
          "IsPublic": 0,
          "IsFavorite": 0,
          "IsSite": 0,
          "IsCalibrated": 1,
          "IsFileUploaded": 0,
          "IsActive": 1,
          "HasSubFolder": 0,
          "CanRemoveOffline": 1,
          "IsMarkOffline": 1,
          "SyncStatus": 1,
          "LastSyncTimeStamp": "2023-08-11 13:28:08.733",
          "Level": "1"
        },
        {
          "ProjectId": "2130192",
          "FolderId": "115096357",
          "LocationId": "183682",
          "LocationTitle": "Basement",
          "ParentFolderId": "115096349",
          "ParentLocationId": "183679",
          "PermissionValue": 0,
          "LocationPath": "Site Quality Demo\01 Vijay_Test\Plan-1\Basement",
          "SiteId": 0,
          "DocumentId": "13351081",
          "RevisionId": "26773045",
          "AnnotationId": "1fc95526-3610-5163-e2c8-c915a692c3d4",
          "LocationCoordinate": {"x1": "593.98", "y1": "669.61", "x2": "803.92", "y2": "522.8199999999999"},
          "PageNumber": 1,
          "IsPublic": 0,
          "IsFavorite": 0,
          "IsSite": 0,
          "IsCalibrated": 1,
          "IsFileUploaded": 0,
          "IsActive": 1,
          "HasSubFolder": 0,
          "CanRemoveOffline": 1,
          "IsMarkOffline": 1,
          "SyncStatus": 1,
          "LastSyncTimeStamp": "2023-08-11 13:28:08.733",
          "Level": "1"
        }
      ];

      String query = "WITH CTE_ParentLocationList AS ( SELECT *,1 AS Level FROM LocationDetailTbl WHERE ProjectId=2130192 AND AnnotationId='1fc95526-3610-5163-e2c8-c915a692c3d4' UNION SELECT locTbl.*,locCte.Level+1 AS Level FROM LocationDetailTbl locTbl INNER JOIN CTE_ParentLocationList locCte ON locCte.ProjectId=locTbl.ProjectId AND locCte.ParentLocationId=locTbl.LocationId) SELECT * FROM CTE_ParentLocationList ORDER BY Level ASC";

      ResultSet resultSet = ResultSet(paramMap.keys.toList(),null,response.cast<List<Object?>>());

      when(() => mockDb?.selectFromTable(LocationDao.tableName, query)).thenReturn(resultSet);
      final result = await siteLocationLocalDatasource.getLocationTreeByAnnotationId(paramMap);
      // expect(result, isA<SiteLocation>());
      expect(result, isNull);
    });

    test("getLocationTreeByAnnotationId Exception",() async {
      Map<String, dynamic> paramMap = {};
      paramMap["projectId"] = "2130192";
      paramMap["annotationId"] = "b27a8610-0d01-9d6b-1ee8-0cf1fcad84cf";

      when(() => mockDb?.selectFromTable(LocationDao.tableName, any())).thenThrow(Exception());
      final result = await siteLocationLocalDatasource.getLocationTreeByAnnotationId(paramMap);
      expect(result, isNull);
    });

    test("getObservationListByPlan", () async {
      Map<String, dynamic> paramMap = {};
      paramMap["projectId"] = "2130192";
      paramMap["revisionId"] = "26773045";
      paramMap["observationIds"] = "112857";
      paramMap["onlyOfflineCreatedDataReq"] = true;

      final response = [
        {
          "ProjectId": "2130192",
          "FormId": "11602661",
          "AppTypeId": "2",
          "FormTypeId": "11076066",
          "InstanceGroupId": "11018088",
          "FormTitle": "Fhjh",
          "Code": "DRAFT",
          "CommentId": "11602661",
          "MessageId": "12303828",
          "ParentMessageId": 0,
          "OrgId": "5763307",
          "FirstName": "Mayur",
          "LastName": "Raval m.",
          "OrgName": "Asite Solutions Ltd",
          "Originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "OriginatorDisplayName": "Mayur Raval m., Asite Solutions Ltd",
          "NoOfActions": "0",
          "ObservationId": "106989",
          "LocationId": "183680",
          "PfLocFolderId": "115096353",
          "Updated": "13/07/2023#05:52 CST",
          "AttachmentImageName": "",
          "MsgCode": "ORI001",
          "TypeImage": "icons/form.png",
          "DocType": "Apps",
          "HasAttachments": "0",
          "HasDocAssocations": "0",
          "HasBimViewAssociations": "0",
          "HasFormAssocations": "0",
          "HasCommentAssocations": "0",
          "FormHasAssocAttach": "0",
          "FormCreationDate": "13/07/2023#05:52 CST",
          "FolderId": "115096353",
          "MsgTypeId": "1",
          "MsgStatusId": "19",
          "FormNumber": "0",
          "MsgOriginatorId": "2017529",
          "TemplateType": "2",
          "IsDraft": "1",
          "StatusId": "2",
          "OriginatorId": "2017529",
          "IsStatusChangeRestricted": "0",
          "AllowReopenForm": "0",
          "CanOrigChangeStatus": "0",
          "MsgTypeCode": "ORI, Id:",
          "StatusChangeUserId": "0",
          "StatusUpdateDate": "13/07/2023#05:52 CST",
          "StatusChangeUserName": "Mayur Raval m.",
          "StatusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "StatusChangeUserEmail": "m.raval@asite.com",
          "StatusChangeUserOrg": "Asite Solutions Ltd",
          "OriginatorEmail": "m.raval@asite.com",
          "ControllerUserId": "0",
          "UpdatedDateInMS": "1689245542000",
          "FormCreationDateInMS": "1689245542000",
          "ResponseRequestByInMS": "1689397199000",
          "FlagType": "0",
          "LatestDraftId": "0",
          "FlagTypeImageName": "flag_type/flag_0.png",
          "MessageTypeImageName": "icons/form.png",
          "CanAccessHistory": 1,
          "FormJsonData": "",
          "Status": "Open",
          "AttachedDocs": "",
          "IsUploadAttachmentInTemp": 0,
          "IsSync": 0,
          "UserRefCode": "",
          "HasActions": 0,
          "CanRemoveOffline": 1,
          "IsMarkOffline": 1,
          "IsOfflineCreated": 0,
          "SyncStatus": 1,
          "IsForDefect": 0,
          "IsForApps": 0,
          "ObservationDefectTypeId": 0,
          "StartDate": "",
          "ExpectedFinishDate": "",
          "IsActive": 1,
          "ObservationCoordinates": {"x1": "528.5730003866549", "y1": "308.90149999999994", "x2": "538.5730003866549", "y2": "318.90149999999994"},
          "AnnotationId": "bf5cd4e7-f128-2442-e711-683b83c35e91",
          "IsCloseOut": 0,
          "AssignedToUserId": 0,
          "AssignedToUserName": "",
          "AssignedToUserOrgName": "",
          "MsgNum": "",
          "RevisionId": "26773045",
          "RequestJsonForOffline": "",
          "FormDueDays": 0,
          "FormSyncDate": "2023-07-13 11:52:22.617",
          "LastResponderForAssignedTo": "",
          "LastResponderForOriginator": "",
          "PageNumber": 1,
          "ObservationDefectType": "",
          "StatusName": "Open",
          "AppBuilderId": "STD-DIS",
          "TaskTypeName": "",
          "AssignedToRoleName": "",
          "ProjectId": "2130192",
          "FolderId": "115096353",
          "LocationId": "183680",
          "LocationTitle": "First-Flour",
          "ParentFolderId": "115096349",
          "ParentLocationId": "183679",
          "PermissionValue": 0,
          "LocationPath": "Site Quality Demo\01 Vijay_Test\Plan-1\First-Flour",
          "SiteId": "0",
          "DocumentId": "13351081",
          "RevisionId": "",
          "AnnotationId": "bf5cd4e7-f128-2442-e711-683b83c35e91",
          "LocationCoordinate": {"x1": "425", "y1": "398.22", "x2": "614.46", "y2": "154.14999999999998"},
          "PageNumber": 1,
          "IsPublic": 0,
          "IsFavorite": 0,
          "IsSite": 0,
          "IsCalibrated": 1,
          "IsFileUploaded": 0,
          "IsActive": 1,
          "HasSubFolder": 0,
          "CanRemoveOffline": 1,
          "IsMarkOffline": 1,
          "SyncStatus": 1,
          "LastSyncTimeStamp": "2023-08-11 12:36:28.45",
          "page_number": 1,
          "responseRequestBy": "14/07/2023#23:59 CST",
          "bgColor": "#848484",
          "fontColor": "#ffffff"
        },
        {
          "ProjectId": "2130192",
          "FormId": "11602661",
          "AppTypeId": "2",
          "FormTypeId": "11076066",
          "InstanceGroupId": "11018088",
          "FormTitle": "Fhjh",
          "Code": "DRAFT",
          "CommentId": "11602661",
          "MessageId": "12303828",
          "ParentMessageId": 0,
          "OrgId": "5763307",
          "FirstName": "Mayur",
          "LastName": "Raval m.",
          "OrgName": "Asite Solutions Ltd",
          "Originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "OriginatorDisplayName": "Mayur Raval m., Asite Solutions Ltd",
          "NoOfActions": "0",
          "ObservationId": "106989",
          "LocationId": "183680",
          "PfLocFolderId": "115096353",
          "Updated": "13/07/2023#05:52 CST",
          "AttachmentImageName": "",
          "MsgCode": "ORI001",
          "TypeImage": "icons/form.png",
          "DocType": "Apps",
          "HasAttachments": "0",
          "HasDocAssocations": "0",
          "HasBimViewAssociations": "0",
          "HasFormAssocations": "0",
          "HasCommentAssocations": "0",
          "FormHasAssocAttach": "0",
          "FormCreationDate": "13/07/2023#05:52 CST",
          "FolderId": "115096353",
          "MsgTypeId": "1",
          "MsgStatusId": "19",
          "FormNumber": "0",
          "MsgOriginatorId": "2017529",
          "TemplateType": "2",
          "IsDraft": "1",
          "StatusId": "2",
          "OriginatorId": "2017529",
          "IsStatusChangeRestricted": "0",
          "AllowReopenForm": "0",
          "CanOrigChangeStatus": "0",
          "MsgTypeCode": "ORI, Id:",
          "StatusChangeUserId": "0",
          "StatusUpdateDate": "13/07/2023#05:52 CST",
          "StatusChangeUserName": "Mayur Raval m.",
          "StatusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "StatusChangeUserEmail": "m.raval@asite.com",
          "StatusChangeUserOrg": "Asite Solutions Ltd",
          "OriginatorEmail": "m.raval@asite.com",
          "ControllerUserId": "0",
          "UpdatedDateInMS": "1689245542000",
          "FormCreationDateInMS": "1689245542000",
          "ResponseRequestByInMS": "1689397199000",
          "FlagType": "0",
          "LatestDraftId": "0",
          "FlagTypeImageName": "flag_type/flag_0.png",
          "MessageTypeImageName": "icons/form.png",
          "CanAccessHistory": 1,
          "FormJsonData": "",
          "Status": "Open",
          "AttachedDocs": "",
          "IsUploadAttachmentInTemp": 0,
          "IsSync": 0,
          "UserRefCode": "",
          "HasActions": 0,
          "CanRemoveOffline": 1,
          "IsMarkOffline": 1,
          "IsOfflineCreated": 0,
          "SyncStatus": 1,
          "IsForDefect": 0,
          "IsForApps": 0,
          "ObservationDefectTypeId": 0,
          "StartDate": "",
          "ExpectedFinishDate": "",
          "IsActive": 1,
          "ObservationCoordinates": {"x1": "528.5730003866549", "y1": "308.90149999999994", "x2": "538.5730003866549", "y2": "318.90149999999994"},
          "AnnotationId": "bf5cd4e7-f128-2442-e711-683b83c35e91",
          "IsCloseOut": 0,
          "AssignedToUserId": 0,
          "AssignedToUserName": "",
          "AssignedToUserOrgName": "",
          "MsgNum": "",
          "RevisionId": "26773045",
          "RequestJsonForOffline": "",
          "FormDueDays": 0,
          "FormSyncDate": "2023-07-13 11:52:22.617",
          "LastResponderForAssignedTo": "",
          "LastResponderForOriginator": "",
          "PageNumber": 1,
          "ObservationDefectType": "",
          "StatusName": "Open",
          "AppBuilderId": "STD-DIS",
          "TaskTypeName": "",
          "AssignedToRoleName": "",
          "ProjectId": "2130192",
          "FolderId": "115096353",
          "LocationId": "183680",
          "LocationTitle": "First-Flour",
          "ParentFolderId": "115096349",
          "ParentLocationId": "183679",
          "PermissionValue": 0,
          "LocationPath": "Site Quality Demo\01 Vijay_Test\Plan-1\First-Flour",
          "SiteId": "0",
          "DocumentId": "13351081",
          "RevisionId": "",
          "AnnotationId": "bf5cd4e7-f128-2442-e711-683b83c35e91",
          "LocationCoordinate": {"x1": "425", "y1": "398.22", "x2": "614.46", "y2": "154.14999999999998"},
          "PageNumber": 1,
          "IsPublic": 0,
          "IsFavorite": 0,
          "IsSite": 0,
          "IsCalibrated": 1,
          "IsFileUploaded": 0,
          "IsActive": 1,
          "HasSubFolder": 0,
          "CanRemoveOffline": 1,
          "IsMarkOffline": 1,
          "SyncStatus": 1,
          "LastSyncTimeStamp": "2023-08-11 12:36:28.45",
          "page_number": 1,
          "responseRequestBy": "14/07/2023#23:59 CST",
          "bgColor": "#848484",
          "fontColor": "#ffffff"
        }
      ];

      String query = "SELECT frmTbl.*,locTbl.*,frmTbl.PageNumber AS page_number,frmMsgTbl.ResponseRequestBy AS responseRequestBy,statStyTbl.BackgroundColor AS bgColor,statStyTbl.FontColor AS fontColor FROM FormListTbl frmTbl INNER JOIN LocationDetailTbl locTbl ON locTbl.ProjectId=frmTbl.ProjectId AND locTbl.LocationId=frmTbl.LocationId INNER JOIN FormMessageListTbl frmMsgTbl ON frmMsgTbl.ProjectId = frmTbl.ProjectId AND frmMsgTbl.FormId = frmTbl.FormId AND frmMsgTbl.MsgId = frmTbl.MessageId LEFT JOIN StatusStyleListTbl statStyTbl ON statStyTbl.ProjectId=frmTbl.ProjectId AND statStyTbl.StatusId=frmTbl.StatusId WHERE locTbl.ProjectId=2130192 AND locTbl.RevisionId=26773045";
      query = "$query AND frmTbl.FormId IN (";
      query = "$query SELECT DISTINCT frmTbl.FormId FROM FormListTbl frmTbl WHERE (frmTbl.IsActive=1))";

      ResultSet resultSet = ResultSet(paramMap.keys.toList(),null,response.cast<List<Object?>>());

      when(() => mockDb?.selectFromTable(FormDao.tableName, query)).thenReturn(resultSet);

      final result = await siteLocationLocalDatasource.getObservationListByPlan(paramMap);
      expect(result, isA<List<ObservationData>>());
    });

    test("getObservationListByPlan", () async {
      Map<String, dynamic> paramMap = {};
      paramMap["projectId"] = "2130192";
    //  paramMap["revisionId"] = "26773045";
      paramMap["observationIds"] = "112857";
      paramMap["onlyOfflineCreatedDataReq"] = true;

      final response = [
        {
          "ProjectId": "2130192",
          "FormId": "11602661",
          "AppTypeId": "2",
          "FormTypeId": "11076066",
          "InstanceGroupId": "11018088",
          "FormTitle": "Fhjh",
          "Code": "DRAFT",
          "CommentId": "11602661",
          "MessageId": "12303828",
          "ParentMessageId": 0,
          "OrgId": "5763307",
          "FirstName": "Mayur",
          "LastName": "Raval m.",
          "OrgName": "Asite Solutions Ltd",
          "Originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "OriginatorDisplayName": "Mayur Raval m., Asite Solutions Ltd",
          "NoOfActions": "0",
          "ObservationId": "106989",
          "LocationId": "183680",
          "PfLocFolderId": "115096353",
          "Updated": "13/07/2023#05:52 CST",
          "AttachmentImageName": "",
          "MsgCode": "ORI001",
          "TypeImage": "icons/form.png",
          "DocType": "Apps",
          "HasAttachments": "0",
          "HasDocAssocations": "0",
          "HasBimViewAssociations": "0",
          "HasFormAssocations": "0",
          "HasCommentAssocations": "0",
          "FormHasAssocAttach": "0",
          "FormCreationDate": "13/07/2023#05:52 CST",
          "FolderId": "115096353",
          "MsgTypeId": "1",
          "MsgStatusId": "19",
          "FormNumber": "0",
          "MsgOriginatorId": "2017529",
          "TemplateType": "2",
          "IsDraft": "1",
          "StatusId": "2",
          "OriginatorId": "2017529",
          "IsStatusChangeRestricted": "0",
          "AllowReopenForm": "0",
          "CanOrigChangeStatus": "0",
          "MsgTypeCode": "ORI, Id:",
          "StatusChangeUserId": "0",
          "StatusUpdateDate": "13/07/2023#05:52 CST",
          "StatusChangeUserName": "Mayur Raval m.",
          "StatusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "StatusChangeUserEmail": "m.raval@asite.com",
          "StatusChangeUserOrg": "Asite Solutions Ltd",
          "OriginatorEmail": "m.raval@asite.com",
          "ControllerUserId": "0",
          "UpdatedDateInMS": "1689245542000",
          "FormCreationDateInMS": "1689245542000",
          "ResponseRequestByInMS": "1689397199000",
          "FlagType": "0",
          "LatestDraftId": "0",
          "FlagTypeImageName": "flag_type/flag_0.png",
          "MessageTypeImageName": "icons/form.png",
          "CanAccessHistory": 1,
          "FormJsonData": "",
          "Status": "Open",
          "AttachedDocs": "",
          "IsUploadAttachmentInTemp": 0,
          "IsSync": 0,
          "UserRefCode": "",
          "HasActions": 0,
          "CanRemoveOffline": 1,
          "IsMarkOffline": 1,
          "IsOfflineCreated": 0,
          "SyncStatus": 1,
          "IsForDefect": 0,
          "IsForApps": 0,
          "ObservationDefectTypeId": 0,
          "StartDate": "",
          "ExpectedFinishDate": "",
          "IsActive": 1,
          "ObservationCoordinates": {"x1": "528.5730003866549", "y1": "308.90149999999994", "x2": "538.5730003866549", "y2": "318.90149999999994"},
          "AnnotationId": "bf5cd4e7-f128-2442-e711-683b83c35e91",
          "IsCloseOut": 0,
          "AssignedToUserId": 0,
          "AssignedToUserName": "",
          "AssignedToUserOrgName": "",
          "MsgNum": "",
          "RevisionId": "26773045",
          "RequestJsonForOffline": "",
          "FormDueDays": 0,
          "FormSyncDate": "2023-07-13 11:52:22.617",
          "LastResponderForAssignedTo": "",
          "LastResponderForOriginator": "",
          "PageNumber": 1,
          "ObservationDefectType": "",
          "StatusName": "Open",
          "AppBuilderId": "STD-DIS",
          "TaskTypeName": "",
          "AssignedToRoleName": "",
          "ProjectId": "2130192",
          "FolderId": "115096353",
          "LocationId": "183680",
          "LocationTitle": "First-Flour",
          "ParentFolderId": "115096349",
          "ParentLocationId": "183679",
          "PermissionValue": 0,
          "LocationPath": "Site Quality Demo\01 Vijay_Test\Plan-1\First-Flour",
          "SiteId": "0",
          "DocumentId": "13351081",
          "RevisionId": "",
          "AnnotationId": "bf5cd4e7-f128-2442-e711-683b83c35e91",
          "LocationCoordinate": {"x1": "425", "y1": "398.22", "x2": "614.46", "y2": "154.14999999999998"},
          "PageNumber": 1,
          "IsPublic": 0,
          "IsFavorite": 0,
          "IsSite": 0,
          "IsCalibrated": 1,
          "IsFileUploaded": 0,
          "IsActive": 1,
          "HasSubFolder": 0,
          "CanRemoveOffline": 1,
          "IsMarkOffline": 1,
          "SyncStatus": 1,
          "LastSyncTimeStamp": "2023-08-11 12:36:28.45",
          "page_number": 1,
          "responseRequestBy": "14/07/2023#23:59 CST",
          "bgColor": "#848484",
          "fontColor": "#ffffff"
        },
        {
          "ProjectId": "2130192",
          "FormId": "11602661",
          "AppTypeId": "2",
          "FormTypeId": "11076066",
          "InstanceGroupId": "11018088",
          "FormTitle": "Fhjh",
          "Code": "DRAFT",
          "CommentId": "11602661",
          "MessageId": "12303828",
          "ParentMessageId": 0,
          "OrgId": "5763307",
          "FirstName": "Mayur",
          "LastName": "Raval m.",
          "OrgName": "Asite Solutions Ltd",
          "Originator": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "OriginatorDisplayName": "Mayur Raval m., Asite Solutions Ltd",
          "NoOfActions": "0",
          "ObservationId": "106989",
          "LocationId": "183680",
          "PfLocFolderId": "115096353",
          "Updated": "13/07/2023#05:52 CST",
          "AttachmentImageName": "",
          "MsgCode": "ORI001",
          "TypeImage": "icons/form.png",
          "DocType": "Apps",
          "HasAttachments": "0",
          "HasDocAssocations": "0",
          "HasBimViewAssociations": "0",
          "HasFormAssocations": "0",
          "HasCommentAssocations": "0",
          "FormHasAssocAttach": "0",
          "FormCreationDate": "13/07/2023#05:52 CST",
          "FolderId": "115096353",
          "MsgTypeId": "1",
          "MsgStatusId": "19",
          "FormNumber": "0",
          "MsgOriginatorId": "2017529",
          "TemplateType": "2",
          "IsDraft": "1",
          "StatusId": "2",
          "OriginatorId": "2017529",
          "IsStatusChangeRestricted": "0",
          "AllowReopenForm": "0",
          "CanOrigChangeStatus": "0",
          "MsgTypeCode": "ORI, Id:",
          "StatusChangeUserId": "0",
          "StatusUpdateDate": "13/07/2023#05:52 CST",
          "StatusChangeUserName": "Mayur Raval m.",
          "StatusChangeUserPic": "https://portalqa.asite.com/adoddleprofilefiles/member_photos/photo_2017529_thumbnail.jpg?v=1688541715000#Mayur",
          "StatusChangeUserEmail": "m.raval@asite.com",
          "StatusChangeUserOrg": "Asite Solutions Ltd",
          "OriginatorEmail": "m.raval@asite.com",
          "ControllerUserId": "0",
          "UpdatedDateInMS": "1689245542000",
          "FormCreationDateInMS": "1689245542000",
          "ResponseRequestByInMS": "1689397199000",
          "FlagType": "0",
          "LatestDraftId": "0",
          "FlagTypeImageName": "flag_type/flag_0.png",
          "MessageTypeImageName": "icons/form.png",
          "CanAccessHistory": 1,
          "FormJsonData": "",
          "Status": "Open",
          "AttachedDocs": "",
          "IsUploadAttachmentInTemp": 0,
          "IsSync": 0,
          "UserRefCode": "",
          "HasActions": 0,
          "CanRemoveOffline": 1,
          "IsMarkOffline": 1,
          "IsOfflineCreated": 0,
          "SyncStatus": 1,
          "IsForDefect": 0,
          "IsForApps": 0,
          "ObservationDefectTypeId": 0,
          "StartDate": "",
          "ExpectedFinishDate": "",
          "IsActive": 1,
          "ObservationCoordinates": {"x1": "528.5730003866549", "y1": "308.90149999999994", "x2": "538.5730003866549", "y2": "318.90149999999994"},
          "AnnotationId": "bf5cd4e7-f128-2442-e711-683b83c35e91",
          "IsCloseOut": 0,
          "AssignedToUserId": 0,
          "AssignedToUserName": "",
          "AssignedToUserOrgName": "",
          "MsgNum": "",
          "RevisionId": "26773045",
          "RequestJsonForOffline": "",
          "FormDueDays": 0,
          "FormSyncDate": "2023-07-13 11:52:22.617",
          "LastResponderForAssignedTo": "",
          "LastResponderForOriginator": "",
          "PageNumber": 1,
          "ObservationDefectType": "",
          "StatusName": "Open",
          "AppBuilderId": "STD-DIS",
          "TaskTypeName": "",
          "AssignedToRoleName": "",
          "ProjectId": "2130192",
          "FolderId": "115096353",
          "LocationId": "183680",
          "LocationTitle": "First-Flour",
          "ParentFolderId": "115096349",
          "ParentLocationId": "183679",
          "PermissionValue": 0,
          "LocationPath": "Site Quality Demo\01 Vijay_Test\Plan-1\First-Flour",
          "SiteId": "0",
          "DocumentId": "13351081",
          "RevisionId": "",
          "AnnotationId": "bf5cd4e7-f128-2442-e711-683b83c35e91",
          "LocationCoordinate": {"x1": "425", "y1": "398.22", "x2": "614.46", "y2": "154.14999999999998"},
          "PageNumber": 1,
          "IsPublic": 0,
          "IsFavorite": 0,
          "IsSite": 0,
          "IsCalibrated": 1,
          "IsFileUploaded": 0,
          "IsActive": 1,
          "HasSubFolder": 0,
          "CanRemoveOffline": 1,
          "IsMarkOffline": 1,
          "SyncStatus": 1,
          "LastSyncTimeStamp": "2023-08-11 12:36:28.45",
          "page_number": 1,
          "responseRequestBy": "14/07/2023#23:59 CST",
          "bgColor": "#848484",
          "fontColor": "#ffffff"
        }
      ];

      String query = "SELECT frmTbl.*,locTbl.*,frmTbl.PageNumber AS page_number,frmMsgTbl.ResponseRequestBy AS responseRequestBy,statStyTbl.BackgroundColor AS bgColor,statStyTbl.FontColor AS fontColor FROM FormListTbl frmTbl INNER JOIN LocationDetailTbl locTbl ON locTbl.ProjectId=frmTbl.ProjectId AND locTbl.LocationId=frmTbl.LocationId INNER JOIN FormMessageListTbl frmMsgTbl ON frmMsgTbl.ProjectId = frmTbl.ProjectId AND frmMsgTbl.FormId = frmTbl.FormId AND frmMsgTbl.MsgId = frmTbl.MessageId LEFT JOIN StatusStyleListTbl statStyTbl ON statStyTbl.ProjectId=frmTbl.ProjectId AND statStyTbl.StatusId=frmTbl.StatusId WHERE locTbl.ProjectId=2130192 AND locTbl.RevisionId=26773045";
      query = "$query AND frmTbl.FormId IN (";
      query = "$query SELECT DISTINCT frmTbl.FormId FROM FormListTbl frmTbl WHERE (frmTbl.IsActive=1))";

      ResultSet resultSet = ResultSet(paramMap.keys.toList(),null,response.cast<List<Object?>>());

      when(() => mockDb?.selectFromTable(FormDao.tableName, query)).thenReturn(resultSet);

      final result = await siteLocationLocalDatasource.getObservationListByPlan(paramMap);
      expect(result, isA<List<ObservationData>>());
    });

    test("getObservationListByPlan Exception",() async {
      Map<String, dynamic> paramMap = {};
      paramMap["projectId"] = "2130192";
      paramMap["revisionId"] = "26773045";
      paramMap["observationIds"] = "112857";
      paramMap["onlyOfflineCreatedDataReq"] = true;

      when(() => mockDb?.selectFromTable(FormDao.tableName, any())).thenThrow(Exception());
      final result = await siteLocationLocalDatasource.getObservationListByPlan(paramMap);
      expect(result, isEmpty);
    });
  });
}
