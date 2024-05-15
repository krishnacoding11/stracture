import 'dart:convert';

import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/data/model/sync_status.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/task/project_and_location_sync_task.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:field/injection_container.dart' as di;

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';

class MockProjectListUseCase extends Mock implements ProjectListUseCase {}

class DBServiceMock extends Mock implements DBService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  MockProjectListUseCase? mockProjectListUseCase;
  DBServiceMock? mockDb;

  configureDependencies() async {
    mockProjectListUseCase = MockProjectListUseCase();
    mockDb = DBServiceMock();
    di.getIt.unregister<ProjectListUseCase>();
    di.getIt.unregister<DBService>();
    di.getIt.registerLazySingleton<ProjectListUseCase>(() => mockProjectListUseCase!);
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
  }

  setUp(() {
    configureDependencies();
  });

  tearDown(() {
    mockDb = null;
    mockProjectListUseCase = null;
  });

  group("ProjectAndLocationSyncTask Test", () {
    test("Project Sync Success", () async {
      var taskNumber = -9007199254740991;
      var createQuery = "CREATE TABLE IF NOT EXISTS ProjectDetailTbl(ProjectId TEXT NOT NULL,ProjectName TEXT NOT NULL,DcId INTEGER NOT NULL,Privilege TEXT,ProjectAdmins TEXT,OwnerOrgId INTEGER,StatusId INTEGER,ProjectSubscriptionTypeId INTEGER,IsFavorite INTEGER NOT NULL DEFAULT 0,BimEnabled INTEGER NOT NULL DEFAULT 0,IsUserAdminForProject INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,LastSyncTimeStamp TEXT,projectSizeInByte INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId))";
      var tableName = "ProjectDetailTbl";
      List<String> primaryKeysList = ["ProjectId"];
      List<Map<String, dynamic>> rowList = [
        {"ProjectId": "2130192", "ProjectName": "Site Quality Demo", "DcId": 1, "Privilege": ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,147,148,149,150,151,154,160,162,170,181,,9,10,13,14,15,16,17,18,20,21,22,25,28,30,32,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,60,61,62,67,69,70,74,75,77,78,79,80,81,82,83,84,99,100,102,109,110,111,112,114,115,116,117,118,119,120,121,122,124,125,126,129,130,135,137,143,144,145,155,156,157,159,161,163,166,167,168,172,173,175,179,", "ProjectAdmins": "", "OwnerOrgId": 3, "StatusId": 5, "ProjectSubscriptionTypeId": 0, "IsFavorite": 1, "BimEnabled": 0, "IsUserAdminForProject": 1, "CanRemoveOffline": 1, "IsMarkOffline": 1, "SyncStatus": 0, "LastSyncTimeStamp": "", "projectSizeInByte": "138641898"}
      ];
      var selectQuery = "SELECT ProjectId FROM ProjectDetailTbl WHERE ProjectId='2130192'";
      List<String> columnNames = ["ProjectId", "ProjectName", "DcId", "Privilege", "ProjectAdmins", "OwnerOrgId", "StatusId", "ProjectSubscriptionTypeId", "IsFavorite", "BimEnabled", "IsUserAdminForProject", "CanRemoveOffline", "IsMarkOffline", "SyncStatus", "LastSyncTimeStamp", "projectSizeInByte"];
      List<List<Object?>> rows = [];
      var sqlQuery = "INSERT INTO ProjectDetailTbl (ProjectId,ProjectName,DcId,Privilege,ProjectAdmins,OwnerOrgId,StatusId,ProjectSubscriptionTypeId,IsFavorite,BimEnabled,IsUserAdminForProject,CanRemoveOffline,IsMarkOffline,SyncStatus,LastSyncTimeStamp,projectSizeInByte) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      List<List<dynamic>> insertValues = [
        ["2130192", "Site Quality Demo", 1, ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,147,148,149,150,151,154,160,162,170,181,,9,10,13,14,15,16,17,18,20,21,22,25,28,30,32,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,60,61,62,67,69,70,74,75,77,78,79,80,81,82,83,84,99,100,102,109,110,111,112,114,115,116,117,118,119,120,121,122,124,125,126,129,130,135,137,143,144,145,155,156,157,159,161,163,166,167,168,172,173,175,179,", "", 3, 5, 0, 1, 0, 1, 1, 1, 0, "", "138641898"]
      ];
      ResultSet resultSet = ResultSet(columnNames, null, rows);
      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2130192\$\$fIdR2g"
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.project
        ..projectSizeInByte = "105758801";

      Map<String, dynamic> serverTimeMap = {};
      //Map<String, dynamic> projectAndLocationMap = {"offlineProjectId": "2130192\$\$fIdR2g", "offlineFolderIds": -1, "isDeactiveLocationRequired": true, "applicationId": 3, "folderTypeId": 1, "includeSubFolders": true, "networkExecutionType": NetworkExecutionType.SYNC};

      when(() => mockProjectListUseCase!.getDeviceConfigurationFromServer()).thenAnswer((_) async {
        return SUCCESS(jsonDecode(fixture("device_configuration.json")), null, 200);
      });
      when(() => mockProjectListUseCase!.getServerTime(serverTimeMap)).thenAnswer((_) => Future.value(SUCCESS("2023-07-19 10:59:10.113", null, 200)));
      when(() => mockProjectListUseCase!.getProjectAndLocationList(any())).thenAnswer((_) async {
        return SUCCESS(fixture("project_and_location_list.json"), null, 200);
      });
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);

      rowList.clear();
      rowList = [
        {"ProjectId": "2130192", "FolderId": "115096357", "LocationId": 183682, "LocationTitle": "Basement", "ParentFolderId": 115096349, "ParentLocationId": 183679, "PermissionValue": 0, "LocationPath": "Site Quality Demo\01 Vijay_Test\Plan-1\Basement", "SiteId": 0, "DocumentId": "13351081", "RevisionId": "26773045", "AnnotationId": "1fc95526-3610-5163-e2c8-c915a692c3d4", "LocationCoordinate": "{\"x1\":593.98,\"y1\":669.61,\"x2\":803.92,\"y2\":522.8199999999999}", "PageNumber": 1, "IsPublic": 0, "IsFavorite": 0, "IsSite": 0, "IsCalibrated": 1, "IsFileUploaded": 0, "IsActive": 1, "HasSubFolder": 0, "CanRemoveOffline": 0, "IsMarkOffline": 1, "SyncStatus": 0, "LastSyncTimeStamp": ""}
      ];
      createQuery = "CREATE TABLE IF NOT EXISTS LocationDetailTbl(ProjectId TEXT NOT NULL,FolderId TEXT NOT NULL,LocationId INTEGER NOT NULL,LocationTitle TEXT NOT NULL,ParentFolderId INTEGER NOT NULL,ParentLocationId INTEGER NOT NULL,PermissionValue INTEGER,LocationPath TEXT NOT NULL,SiteId INTEGER,DocumentId TEXT,RevisionId TEXT,AnnotationId TEXT,LocationCoordinate TEXT,PageNumber INTEGER NOT NULL DEFAULT 0,IsPublic INTEGER NOT NULL DEFAULT 0,IsFavorite INTEGER NOT NULL DEFAULT 0,IsSite INTEGER NOT NULL DEFAULT 0,IsCalibrated INTEGER NOT NULL DEFAULT 0,IsFileUploaded INTEGER NOT NULL DEFAULT 0,IsActive INTEGER NOT NULL DEFAULT 0,HasSubFolder INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,LastSyncTimeStamp TEXT,PRIMARY KEY(ProjectId,FolderId,LocationId))";
      tableName = "LocationDetailTbl";
      primaryKeysList = ["ProjectId", "FolderId", "LocationId"];
      selectQuery = "SELECT ProjectId FROM LocationDetailTbl WHERE ProjectId='2130192' AND FolderId='115096357' AND LocationId='183682'";
      columnNames = ["ProjectId", "FolderId", "LocationId", "LocationTitle", "ParentFolderId", "ParentLocationId", "PermissionValue", "LocationPath", "SiteId", "DocumentId", "RevisionId", "AnnotationId", "LocationCoordinate", "PageNumber", "IsPublic", "IsFavorite", "IsSite", "IsCalibrated", "IsFileUploaded", "IsActive", "HasSubFolder", "CanRemoveOffline", "IsMarkOffline", "SyncStatus", "LastSyncTimeStamp"];
      sqlQuery = "INSERT INTO LocationDetailTbl (ProjectId,FolderId,LocationId,LocationTitle,ParentFolderId,ParentLocationId,PermissionValue,LocationPath,SiteId,DocumentId,RevisionId,AnnotationId,LocationCoordinate,PageNumber,IsPublic,IsFavorite,IsSite,IsCalibrated,IsFileUploaded,IsActive,HasSubFolder,CanRemoveOffline,IsMarkOffline,SyncStatus,LastSyncTimeStamp) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      insertValues = [
        ["2130192", "Site Quality Demo", 1, ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,147,148,149,150,151,154,160,162,170,181,,9,10,13,14,15,16,17,18,20,21,22,25,28,30,32,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,60,61,62,67,69,70,74,75,77,78,79,80,81,82,83,84,99,100,102,109,110,111,112,114,115,116,117,118,119,120,121,122,124,125,126,129,130,135,137,143,144,145,155,156,157,159,161,163,166,167,168,172,173,175,179,", "", 3, 5, 0, 1, 0, 1, 1, 1, 0, "", "138641898"]
      ];
      resultSet = ResultSet(columnNames, null, rows);
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, any())).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);

      SyncStatus syncStatus = await ProjectAndLocationSyncTask(
        siteSyncTask,
        (eSyncTaskType, eSyncStatus, data) async {},
      ).syncProjectAndLocationData(taskNumber);
      expect(syncStatus, isInstanceOf<SyncSuccessProjectLocationState>());
    });

    test("Location Sync Success", () async {
      var taskNumber = -9007199254740991;
      var createQuery = "CREATE TABLE IF NOT EXISTS ProjectDetailTbl(ProjectId TEXT NOT NULL,ProjectName TEXT NOT NULL,DcId INTEGER NOT NULL,Privilege TEXT,ProjectAdmins TEXT,OwnerOrgId INTEGER,StatusId INTEGER,ProjectSubscriptionTypeId INTEGER,IsFavorite INTEGER NOT NULL DEFAULT 0,BimEnabled INTEGER NOT NULL DEFAULT 0,IsUserAdminForProject INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,LastSyncTimeStamp TEXT,projectSizeInByte INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId))";
      var tableName = "ProjectDetailTbl";
      List<String> primaryKeysList = ["ProjectId"];
      List<Map<String, dynamic>> rowList = [
        {"ProjectId": "2130192", "ProjectName": "Site Quality Demo", "DcId": 1, "Privilege": ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,147,148,149,150,151,154,160,162,170,181,,9,10,13,14,15,16,17,18,20,21,22,25,28,30,32,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,60,61,62,67,69,70,74,75,77,78,79,80,81,82,83,84,99,100,102,109,110,111,112,114,115,116,117,118,119,120,121,122,124,125,126,129,130,135,137,143,144,145,155,156,157,159,161,163,166,167,168,172,173,175,179,", "ProjectAdmins": "", "OwnerOrgId": 3, "StatusId": 5, "ProjectSubscriptionTypeId": 0, "IsFavorite": 1, "BimEnabled": 0, "IsUserAdminForProject": 1, "CanRemoveOffline": 1, "IsMarkOffline": 1, "SyncStatus": 0, "LastSyncTimeStamp": "", "projectSizeInByte": "138641898"}
      ];
      var selectQuery = "SELECT ProjectId FROM ProjectDetailTbl WHERE ProjectId='2130192'";
      List<String> columnNames = ["ProjectId", "ProjectName", "DcId", "Privilege", "ProjectAdmins", "OwnerOrgId", "StatusId", "ProjectSubscriptionTypeId", "IsFavorite", "BimEnabled", "IsUserAdminForProject", "CanRemoveOffline", "IsMarkOffline", "SyncStatus", "LastSyncTimeStamp", "projectSizeInByte"];
      List<List<Object?>> rows = [];
      var sqlQuery = "INSERT INTO ProjectDetailTbl (ProjectId,ProjectName,DcId,Privilege,ProjectAdmins,OwnerOrgId,StatusId,ProjectSubscriptionTypeId,IsFavorite,BimEnabled,IsUserAdminForProject,CanRemoveOffline,IsMarkOffline,SyncStatus,LastSyncTimeStamp,projectSizeInByte) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      List<List<dynamic>> insertValues = [
        ["2130192", "Site Quality Demo", 1, ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,147,148,149,150,151,154,160,162,170,181,,9,10,13,14,15,16,17,18,20,21,22,25,28,30,32,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,60,61,62,67,69,70,74,75,77,78,79,80,81,82,83,84,99,100,102,109,110,111,112,114,115,116,117,118,119,120,121,122,124,125,126,129,130,135,137,143,144,145,155,156,157,159,161,163,166,167,168,172,173,175,179,", "", 3, 5, 0, 1, 0, 1, 1, 1, 0, "", "138641898"]
      ];
      ResultSet resultSet = ResultSet(columnNames, null, rows);
      List<SyncRequestLocationVo> syncLocationList = [];
      SyncRequestLocationVo siteRequestLocationvo = SyncRequestLocationVo()
        ..folderId = "115096348"
        ..folderTitle = "01 Vijay_Test"
        ..locationId = "183678"
        ..lastSyncTime = null
        ..isPlanOnly = true;
      syncLocationList.add(siteRequestLocationvo);

      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2130192"
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.siteLocation
        ..projectSizeInByte = "105758801"
        ..isReSync = false
        ..syncRequestLocationList = syncLocationList;

      Map<String, dynamic> serverTimeMap = {};
      //Map<String, dynamic> projectAndLocationMap = {"offlineProjectId": "2130192\$\$fIdR2g", "offlineFolderIds": -1, "isDeactiveLocationRequired": true, "applicationId": 3, "folderTypeId": 1, "includeSubFolders": true, "networkExecutionType": NetworkExecutionType.SYNC};

      when(() => mockProjectListUseCase!.getDeviceConfigurationFromServer()).thenAnswer((_) async {
        return SUCCESS(jsonDecode(fixture("device_configuration.json")), null, 200);
      });
      when(() => mockProjectListUseCase!.getServerTime(serverTimeMap)).thenAnswer((_) => Future.value(SUCCESS("2023-07-19 10:59:10.113", null, 200)));
      when(() => mockProjectListUseCase!.getProjectAndLocationList(any())).thenAnswer((_) async {
        return SUCCESS(fixture("project_and_location_list.json"), null, 200);
      });
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);

      rowList.clear();
      rowList = [
        {"ProjectId": "2130192", "FolderId": "115096357", "LocationId": 183682, "LocationTitle": "Basement", "ParentFolderId": 115096349, "ParentLocationId": 183679, "PermissionValue": 0, "LocationPath": "Site Quality Demo\01 Vijay_Test\Plan-1\Basement", "SiteId": 0, "DocumentId": "13351081", "RevisionId": "26773045", "AnnotationId": "1fc95526-3610-5163-e2c8-c915a692c3d4", "LocationCoordinate": "{\"x1\":593.98,\"y1\":669.61,\"x2\":803.92,\"y2\":522.8199999999999}", "PageNumber": 1, "IsPublic": 0, "IsFavorite": 0, "IsSite": 0, "IsCalibrated": 1, "IsFileUploaded": 0, "IsActive": 1, "HasSubFolder": 0, "CanRemoveOffline": 0, "IsMarkOffline": 1, "SyncStatus": 0, "LastSyncTimeStamp": ""}
      ];
      createQuery = "CREATE TABLE IF NOT EXISTS LocationDetailTbl(ProjectId TEXT NOT NULL,FolderId TEXT NOT NULL,LocationId INTEGER NOT NULL,LocationTitle TEXT NOT NULL,ParentFolderId INTEGER NOT NULL,ParentLocationId INTEGER NOT NULL,PermissionValue INTEGER,LocationPath TEXT NOT NULL,SiteId INTEGER,DocumentId TEXT,RevisionId TEXT,AnnotationId TEXT,LocationCoordinate TEXT,PageNumber INTEGER NOT NULL DEFAULT 0,IsPublic INTEGER NOT NULL DEFAULT 0,IsFavorite INTEGER NOT NULL DEFAULT 0,IsSite INTEGER NOT NULL DEFAULT 0,IsCalibrated INTEGER NOT NULL DEFAULT 0,IsFileUploaded INTEGER NOT NULL DEFAULT 0,IsActive INTEGER NOT NULL DEFAULT 0,HasSubFolder INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,LastSyncTimeStamp TEXT,PRIMARY KEY(ProjectId,FolderId,LocationId))";
      tableName = "LocationDetailTbl";
      primaryKeysList = ["ProjectId", "FolderId", "LocationId"];
      selectQuery = "SELECT ProjectId FROM LocationDetailTbl WHERE ProjectId='2130192' AND FolderId='115096357' AND LocationId='183682'";
      columnNames = ["ProjectId", "FolderId", "LocationId", "LocationTitle", "ParentFolderId", "ParentLocationId", "PermissionValue", "LocationPath", "SiteId", "DocumentId", "RevisionId", "AnnotationId", "LocationCoordinate", "PageNumber", "IsPublic", "IsFavorite", "IsSite", "IsCalibrated", "IsFileUploaded", "IsActive", "HasSubFolder", "CanRemoveOffline", "IsMarkOffline", "SyncStatus", "LastSyncTimeStamp"];
      sqlQuery = "INSERT INTO LocationDetailTbl (ProjectId,FolderId,LocationId,LocationTitle,ParentFolderId,ParentLocationId,PermissionValue,LocationPath,SiteId,DocumentId,RevisionId,AnnotationId,LocationCoordinate,PageNumber,IsPublic,IsFavorite,IsSite,IsCalibrated,IsFileUploaded,IsActive,HasSubFolder,CanRemoveOffline,IsMarkOffline,SyncStatus,LastSyncTimeStamp) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      insertValues = [
        ["2130192", "Site Quality Demo", 1, ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,147,148,149,150,151,154,160,162,170,181,,9,10,13,14,15,16,17,18,20,21,22,25,28,30,32,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,60,61,62,67,69,70,74,75,77,78,79,80,81,82,83,84,99,100,102,109,110,111,112,114,115,116,117,118,119,120,121,122,124,125,126,129,130,135,137,143,144,145,155,156,157,159,161,163,166,167,168,172,173,175,179,", "", 3, 5, 0, 1, 0, 1, 1, 1, 0, "", "138641898"]
      ];
      resultSet = ResultSet(columnNames, null, rows);
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, any())).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);

      SyncStatus syncStatus = await ProjectAndLocationSyncTask(
        siteSyncTask,
        (eSyncTaskType, eSyncStatus, data) async {},
      ).syncProjectAndLocationData(taskNumber);
      expect(syncStatus, isInstanceOf<SyncSuccessProjectLocationState>());
    });

    test("Location Sync Success with Rsync true", () async {
      var taskNumber = -9007199254740991;
      var createQuery = "CREATE TABLE IF NOT EXISTS ProjectDetailTbl(ProjectId TEXT NOT NULL,ProjectName TEXT NOT NULL,DcId INTEGER NOT NULL,Privilege TEXT,ProjectAdmins TEXT,OwnerOrgId INTEGER,StatusId INTEGER,ProjectSubscriptionTypeId INTEGER,IsFavorite INTEGER NOT NULL DEFAULT 0,BimEnabled INTEGER NOT NULL DEFAULT 0,IsUserAdminForProject INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,LastSyncTimeStamp TEXT,projectSizeInByte INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId))";
      var tableName = "ProjectDetailTbl";
      List<String> primaryKeysList = ["ProjectId"];
      List<Map<String, dynamic>> rowList = [
        {"ProjectId": "2130192", "ProjectName": "Site Quality Demo", "DcId": 1, "Privilege": ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,147,148,149,150,151,154,160,162,170,181,,9,10,13,14,15,16,17,18,20,21,22,25,28,30,32,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,60,61,62,67,69,70,74,75,77,78,79,80,81,82,83,84,99,100,102,109,110,111,112,114,115,116,117,118,119,120,121,122,124,125,126,129,130,135,137,143,144,145,155,156,157,159,161,163,166,167,168,172,173,175,179,", "ProjectAdmins": "", "OwnerOrgId": 3, "StatusId": 5, "ProjectSubscriptionTypeId": 0, "IsFavorite": 1, "BimEnabled": 0, "IsUserAdminForProject": 1, "CanRemoveOffline": 1, "IsMarkOffline": 1, "SyncStatus": 0, "LastSyncTimeStamp": "", "projectSizeInByte": "138641898"}
      ];
      var selectQuery = "SELECT ProjectId FROM ProjectDetailTbl WHERE ProjectId='2130192'";
      List<String> columnNames = ["ProjectId", "ProjectName", "DcId", "Privilege", "ProjectAdmins", "OwnerOrgId", "StatusId", "ProjectSubscriptionTypeId", "IsFavorite", "BimEnabled", "IsUserAdminForProject", "CanRemoveOffline", "IsMarkOffline", "SyncStatus", "LastSyncTimeStamp", "projectSizeInByte"];
      List<List<Object?>> rows = [];
      var sqlQuery = "INSERT INTO ProjectDetailTbl (ProjectId,ProjectName,DcId,Privilege,ProjectAdmins,OwnerOrgId,StatusId,ProjectSubscriptionTypeId,IsFavorite,BimEnabled,IsUserAdminForProject,CanRemoveOffline,IsMarkOffline,SyncStatus,LastSyncTimeStamp,projectSizeInByte) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      List<List<dynamic>> insertValues = [
        ["2130192", "Site Quality Demo", 1, ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,147,148,149,150,151,154,160,162,170,181,,9,10,13,14,15,16,17,18,20,21,22,25,28,30,32,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,60,61,62,67,69,70,74,75,77,78,79,80,81,82,83,84,99,100,102,109,110,111,112,114,115,116,117,118,119,120,121,122,124,125,126,129,130,135,137,143,144,145,155,156,157,159,161,163,166,167,168,172,173,175,179,", "", 3, 5, 0, 1, 0, 1, 1, 1, 0, "", "138641898"]
      ];
      var query = "SELECT * FROM LocationDetailTbl WHERE IsActive=1 AND ProjectId=2130192 AND FolderId=115096348 AND CanRemoveOffline=1";
      ResultSet resultSet = ResultSet(columnNames, null, rows);
      List<SyncRequestLocationVo> syncLocationList = [];
      SyncRequestLocationVo siteRequestLocationvo = SyncRequestLocationVo()
        ..folderId = "115096348"
        ..folderTitle = "01 Vijay_Test"
        ..locationId = "183678"
        ..lastSyncTime = null
        ..isPlanOnly = true;
      syncLocationList.add(siteRequestLocationvo);

      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2130192"
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.siteLocation
        ..projectSizeInByte = "105758801"
        ..isReSync = true
        ..syncRequestLocationList = syncLocationList;

      Map<String, dynamic> serverTimeMap = {};
      //Map<String, dynamic> projectAndLocationMap = {"offlineProjectId": "2130192\$\$fIdR2g", "offlineFolderIds": -1, "isDeactiveLocationRequired": true, "applicationId": 3, "folderTypeId": 1, "includeSubFolders": true, "networkExecutionType": NetworkExecutionType.SYNC};

      when(() => mockProjectListUseCase!.getDeviceConfigurationFromServer()).thenAnswer((_) async {
        return SUCCESS(jsonDecode(fixture("device_configuration.json")), null, 200);
      });
      when(() => mockProjectListUseCase!.getServerTime(serverTimeMap)).thenAnswer((_) => Future.value(SUCCESS("2023-07-19 10:59:10.113", null, 200)));
      when(() => mockProjectListUseCase!.getProjectAndLocationList(any())).thenAnswer((_) async {
        return SUCCESS(fixture("project_and_location_list.json"), null, 200);
      });
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);

      rowList.clear();
      rowList = [
        {"ProjectId": "2130192", "FolderId": "115096357", "LocationId": 183682, "LocationTitle": "Basement", "ParentFolderId": 115096349, "ParentLocationId": 183679, "PermissionValue": 0, "LocationPath": "Site Quality Demo\01 Vijay_Test\Plan-1\Basement", "SiteId": 0, "DocumentId": "13351081", "RevisionId": "26773045", "AnnotationId": "1fc95526-3610-5163-e2c8-c915a692c3d4", "LocationCoordinate": "{\"x1\":593.98,\"y1\":669.61,\"x2\":803.92,\"y2\":522.8199999999999}", "PageNumber": 1, "IsPublic": 0, "IsFavorite": 0, "IsSite": 0, "IsCalibrated": 1, "IsFileUploaded": 0, "IsActive": 1, "HasSubFolder": 0, "CanRemoveOffline": 0, "IsMarkOffline": 1, "SyncStatus": 0, "LastSyncTimeStamp": ""}
      ];
      createQuery = "CREATE TABLE IF NOT EXISTS LocationDetailTbl(ProjectId TEXT NOT NULL,FolderId TEXT NOT NULL,LocationId INTEGER NOT NULL,LocationTitle TEXT NOT NULL,ParentFolderId INTEGER NOT NULL,ParentLocationId INTEGER NOT NULL,PermissionValue INTEGER,LocationPath TEXT NOT NULL,SiteId INTEGER,DocumentId TEXT,RevisionId TEXT,AnnotationId TEXT,LocationCoordinate TEXT,PageNumber INTEGER NOT NULL DEFAULT 0,IsPublic INTEGER NOT NULL DEFAULT 0,IsFavorite INTEGER NOT NULL DEFAULT 0,IsSite INTEGER NOT NULL DEFAULT 0,IsCalibrated INTEGER NOT NULL DEFAULT 0,IsFileUploaded INTEGER NOT NULL DEFAULT 0,IsActive INTEGER NOT NULL DEFAULT 0,HasSubFolder INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,LastSyncTimeStamp TEXT,PRIMARY KEY(ProjectId,FolderId,LocationId))";
      tableName = "LocationDetailTbl";
      primaryKeysList = ["ProjectId", "FolderId", "LocationId"];
      selectQuery = "SELECT ProjectId FROM LocationDetailTbl WHERE ProjectId='2130192' AND FolderId='115096357' AND LocationId='183682'";
      columnNames = ["ProjectId", "FolderId", "LocationId", "LocationTitle", "ParentFolderId", "ParentLocationId", "PermissionValue", "LocationPath", "SiteId", "DocumentId", "RevisionId", "AnnotationId", "LocationCoordinate", "PageNumber", "IsPublic", "IsFavorite", "IsSite", "IsCalibrated", "IsFileUploaded", "IsActive", "HasSubFolder", "CanRemoveOffline", "IsMarkOffline", "SyncStatus", "LastSyncTimeStamp"];
      sqlQuery = "INSERT INTO LocationDetailTbl (ProjectId,FolderId,LocationId,LocationTitle,ParentFolderId,ParentLocationId,PermissionValue,LocationPath,SiteId,DocumentId,RevisionId,AnnotationId,LocationCoordinate,PageNumber,IsPublic,IsFavorite,IsSite,IsCalibrated,IsFileUploaded,IsActive,HasSubFolder,CanRemoveOffline,IsMarkOffline,SyncStatus,LastSyncTimeStamp) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      insertValues = [
        ["2130192", "Site Quality Demo", 1, ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,147,148,149,150,151,154,160,162,170,181,,9,10,13,14,15,16,17,18,20,21,22,25,28,30,32,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,60,61,62,67,69,70,74,75,77,78,79,80,81,82,83,84,99,100,102,109,110,111,112,114,115,116,117,118,119,120,121,122,124,125,126,129,130,135,137,143,144,145,155,156,157,159,161,163,166,167,168,172,173,175,179,", "", 3, 5, 0, 1, 0, 1, 1, 1, 0, "", "138641898"]
      ];

      resultSet = ResultSet(columnNames, null, rows);
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, any())).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);
      columnNames = ["ProjectId", "FolderId", "LocationId", "LocationTitle", "ParentFolderId", "ParentLocationId", "PermissionValue", "LocationPath", "SiteId", "DocumentId", "RevisionId", "AnnotationId", "LocationCoordinate", "PageNumber", "IsPublic", "IsFavorite", "IsSite", "IsCalibrated", "IsFileUploaded", "IsActive", "HasSubFolder", "CanRemoveOffline", "IsMarkOffline", "SyncStatus", "LastSyncTimeStamp"];
      rows = [
        ["2130192", "115096348", 183678, "01 Vijay_Test", 110997340, 0, 0, "Site Quality Demo\01 Vijay_Test", 25384, "0", "0", "", null, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, "2023-07-28 08:40:08.27"]
      ];
      resultSet = ResultSet(columnNames, null, rows);
      when(() => mockDb!.selectFromTable(tableName, query)).thenReturn(resultSet);
      SyncStatus syncStatus = await ProjectAndLocationSyncTask(
        siteSyncTask,
        (eSyncTaskType, eSyncStatus, data) async {},
      ).syncProjectAndLocationData(taskNumber);
      expect(syncStatus, isInstanceOf<SyncSuccessProjectLocationState>());
    });

    test("Location Sync Success with Rsync true with 204", () async {
      var taskNumber = -9007199254740991;
      var createQuery = "CREATE TABLE IF NOT EXISTS ProjectDetailTbl(ProjectId TEXT NOT NULL,ProjectName TEXT NOT NULL,DcId INTEGER NOT NULL,Privilege TEXT,ProjectAdmins TEXT,OwnerOrgId INTEGER,StatusId INTEGER,ProjectSubscriptionTypeId INTEGER,IsFavorite INTEGER NOT NULL DEFAULT 0,BimEnabled INTEGER NOT NULL DEFAULT 0,IsUserAdminForProject INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,LastSyncTimeStamp TEXT,projectSizeInByte INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId))";
      var tableName = "ProjectDetailTbl";
      List<String> primaryKeysList = ["ProjectId"];
      List<Map<String, dynamic>> rowList = [
        {"ProjectId": "2130192", "ProjectName": "Site Quality Demo", "DcId": 1, "Privilege": ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,147,148,149,150,151,154,160,162,170,181,,9,10,13,14,15,16,17,18,20,21,22,25,28,30,32,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,60,61,62,67,69,70,74,75,77,78,79,80,81,82,83,84,99,100,102,109,110,111,112,114,115,116,117,118,119,120,121,122,124,125,126,129,130,135,137,143,144,145,155,156,157,159,161,163,166,167,168,172,173,175,179,", "ProjectAdmins": "", "OwnerOrgId": 3, "StatusId": 5, "ProjectSubscriptionTypeId": 0, "IsFavorite": 1, "BimEnabled": 0, "IsUserAdminForProject": 1, "CanRemoveOffline": 1, "IsMarkOffline": 1, "SyncStatus": 0, "LastSyncTimeStamp": "", "projectSizeInByte": "138641898"}
      ];
      var selectQuery = "SELECT ProjectId FROM ProjectDetailTbl WHERE ProjectId='2130192'";
      List<String> columnNames = ["ProjectId", "ProjectName", "DcId", "Privilege", "ProjectAdmins", "OwnerOrgId", "StatusId", "ProjectSubscriptionTypeId", "IsFavorite", "BimEnabled", "IsUserAdminForProject", "CanRemoveOffline", "IsMarkOffline", "SyncStatus", "LastSyncTimeStamp", "projectSizeInByte"];
      List<List<Object?>> rows = [];
      var sqlQuery = "INSERT INTO ProjectDetailTbl (ProjectId,ProjectName,DcId,Privilege,ProjectAdmins,OwnerOrgId,StatusId,ProjectSubscriptionTypeId,IsFavorite,BimEnabled,IsUserAdminForProject,CanRemoveOffline,IsMarkOffline,SyncStatus,LastSyncTimeStamp,projectSizeInByte) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      List<List<dynamic>> insertValues = [
        ["2130192", "Site Quality Demo", 1, ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,147,148,149,150,151,154,160,162,170,181,,9,10,13,14,15,16,17,18,20,21,22,25,28,30,32,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,60,61,62,67,69,70,74,75,77,78,79,80,81,82,83,84,99,100,102,109,110,111,112,114,115,116,117,118,119,120,121,122,124,125,126,129,130,135,137,143,144,145,155,156,157,159,161,163,166,167,168,172,173,175,179,", "", 3, 5, 0, 1, 0, 1, 1, 1, 0, "", "138641898"]
      ];
      var query = "SELECT * FROM LocationDetailTbl WHERE IsActive=1 AND ProjectId=2130192 AND FolderId=115096348 AND CanRemoveOffline=1";
      ResultSet resultSet = ResultSet(columnNames, null, rows);
      List<SyncRequestLocationVo> syncLocationList = [];
      SyncRequestLocationVo siteRequestLocationvo = SyncRequestLocationVo()
        ..folderId = "115096348"
        ..folderTitle = "01 Vijay_Test"
        ..locationId = "183678"
        ..lastSyncTime = null
        ..isPlanOnly = true;
      syncLocationList.add(siteRequestLocationvo);

      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2130192"
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.siteLocation
        ..projectSizeInByte = "105758801"
        ..isReSync = true
        ..syncRequestLocationList = syncLocationList;

      Map<String, dynamic> serverTimeMap = {};
      //Map<String, dynamic> projectAndLocationMap = {"offlineProjectId": "2130192\$\$fIdR2g", "offlineFolderIds": -1, "isDeactiveLocationRequired": true, "applicationId": 3, "folderTypeId": 1, "includeSubFolders": true, "networkExecutionType": NetworkExecutionType.SYNC};

      when(() => mockProjectListUseCase!.getDeviceConfigurationFromServer()).thenAnswer((_) async {
        return SUCCESS(jsonDecode(fixture("device_configuration.json")), null, 200);
      });
      when(() => mockProjectListUseCase!.getServerTime(serverTimeMap)).thenAnswer((_) => Future.value(SUCCESS("2023-07-19 10:59:10.113", null, 200)));
      when(() => mockProjectListUseCase!.getProjectAndLocationList(any())).thenAnswer((_) async {
        return SUCCESS(null, null, 204);
      });
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);

      rowList.clear();
      rowList = [
        {"ProjectId": "2130192", "FolderId": "115096357", "LocationId": 183682, "LocationTitle": "Basement", "ParentFolderId": 115096349, "ParentLocationId": 183679, "PermissionValue": 0, "LocationPath": "Site Quality Demo\01 Vijay_Test\Plan-1\Basement", "SiteId": 0, "DocumentId": "13351081", "RevisionId": "26773045", "AnnotationId": "1fc95526-3610-5163-e2c8-c915a692c3d4", "LocationCoordinate": "{\"x1\":593.98,\"y1\":669.61,\"x2\":803.92,\"y2\":522.8199999999999}", "PageNumber": 1, "IsPublic": 0, "IsFavorite": 0, "IsSite": 0, "IsCalibrated": 1, "IsFileUploaded": 0, "IsActive": 1, "HasSubFolder": 0, "CanRemoveOffline": 0, "IsMarkOffline": 1, "SyncStatus": 0, "LastSyncTimeStamp": ""}
      ];
      createQuery = "CREATE TABLE IF NOT EXISTS LocationDetailTbl(ProjectId TEXT NOT NULL,FolderId TEXT NOT NULL,LocationId INTEGER NOT NULL,LocationTitle TEXT NOT NULL,ParentFolderId INTEGER NOT NULL,ParentLocationId INTEGER NOT NULL,PermissionValue INTEGER,LocationPath TEXT NOT NULL,SiteId INTEGER,DocumentId TEXT,RevisionId TEXT,AnnotationId TEXT,LocationCoordinate TEXT,PageNumber INTEGER NOT NULL DEFAULT 0,IsPublic INTEGER NOT NULL DEFAULT 0,IsFavorite INTEGER NOT NULL DEFAULT 0,IsSite INTEGER NOT NULL DEFAULT 0,IsCalibrated INTEGER NOT NULL DEFAULT 0,IsFileUploaded INTEGER NOT NULL DEFAULT 0,IsActive INTEGER NOT NULL DEFAULT 0,HasSubFolder INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,LastSyncTimeStamp TEXT,PRIMARY KEY(ProjectId,FolderId,LocationId))";
      tableName = "LocationDetailTbl";
      primaryKeysList = ["ProjectId", "FolderId", "LocationId"];
      selectQuery = "SELECT ProjectId FROM LocationDetailTbl WHERE ProjectId='2130192' AND FolderId='115096357' AND LocationId='183682'";
      columnNames = ["ProjectId", "FolderId", "LocationId", "LocationTitle", "ParentFolderId", "ParentLocationId", "PermissionValue", "LocationPath", "SiteId", "DocumentId", "RevisionId", "AnnotationId", "LocationCoordinate", "PageNumber", "IsPublic", "IsFavorite", "IsSite", "IsCalibrated", "IsFileUploaded", "IsActive", "HasSubFolder", "CanRemoveOffline", "IsMarkOffline", "SyncStatus", "LastSyncTimeStamp"];
      sqlQuery = "INSERT INTO LocationDetailTbl (ProjectId,FolderId,LocationId,LocationTitle,ParentFolderId,ParentLocationId,PermissionValue,LocationPath,SiteId,DocumentId,RevisionId,AnnotationId,LocationCoordinate,PageNumber,IsPublic,IsFavorite,IsSite,IsCalibrated,IsFileUploaded,IsActive,HasSubFolder,CanRemoveOffline,IsMarkOffline,SyncStatus,LastSyncTimeStamp) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
      insertValues = [
        ["2130192", "Site Quality Demo", 1, ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,147,148,149,150,151,154,160,162,170,181,,9,10,13,14,15,16,17,18,20,21,22,25,28,30,32,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,60,61,62,67,69,70,74,75,77,78,79,80,81,82,83,84,99,100,102,109,110,111,112,114,115,116,117,118,119,120,121,122,124,125,126,129,130,135,137,143,144,145,155,156,157,159,161,163,166,167,168,172,173,175,179,", "", 3, 5, 0, 1, 0, 1, 1, 1, 0, "", "138641898"]
      ];

      resultSet = ResultSet(columnNames, null, rows);
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, any())).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);
      columnNames = ["ProjectId", "FolderId", "LocationId", "LocationTitle", "ParentFolderId", "ParentLocationId", "PermissionValue", "LocationPath", "SiteId", "DocumentId", "RevisionId", "AnnotationId", "LocationCoordinate", "PageNumber", "IsPublic", "IsFavorite", "IsSite", "IsCalibrated", "IsFileUploaded", "IsActive", "HasSubFolder", "CanRemoveOffline", "IsMarkOffline", "SyncStatus", "LastSyncTimeStamp"];
      rows = [
        ["2130192", "115096348", 183678, "01 Vijay_Test", 110997340, 0, 0, "Site Quality Demo\01 Vijay_Test", 25384, "0", "0", "", null, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 1, "2023-07-28 08:40:08.27"]
      ];
      resultSet = ResultSet(columnNames, null, rows);
      when(() => mockDb!.selectFromTable(tableName, query)).thenReturn(resultSet);
      SyncStatus syncStatus = await ProjectAndLocationSyncTask(
        siteSyncTask,
        (eSyncTaskType, eSyncStatus, data) async {},
      ).syncProjectAndLocationData(taskNumber);
      expect(syncStatus, isInstanceOf<SyncErrorState>());
    });

    test("Project and Location Fail", () async {
      var taskNumber = -9007199254740991;
      Map<String, dynamic> serverTimeMap = {};
      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2130192\$\$fIdR2g"
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.project
        ..projectSizeInByte = "105758801";

      when(() => mockProjectListUseCase!.getDeviceConfigurationFromServer()).thenAnswer((_) async {
        return SUCCESS(jsonDecode(fixture("device_configuration.json")), null, 200);
      });
      when(() => mockProjectListUseCase!.getServerTime(serverTimeMap)).thenAnswer((_) => Future.value(SUCCESS("2023-07-19 10:59:10.113", null, 200)));
      when(() => mockProjectListUseCase!.getProjectAndLocationList(any())).thenAnswer((_) async {
        return FAIL("", 200);
      });

      SyncStatus syncStatus = await ProjectAndLocationSyncTask(
        siteSyncTask,
        (eSyncTaskType, eSyncStatus, data) async {},
      ).syncProjectAndLocationData(taskNumber);
      expect(syncStatus, isInstanceOf<SyncErrorState>());
    });
  });
}
