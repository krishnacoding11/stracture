import 'dart:async';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/task/status_style_list_sync_task.dart';
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

  setUpAll(() {
    configureDependencies();
  });

  tearDown(() {
    reset(mockDb);
    reset(mockProjectListUseCase);
  });

  tearDownAll(() {
    mockDb = null;
    mockProjectListUseCase = null;
  });

  group("StatusStyleListSyncTask Test", () {
    test("Project Sync Success", () async {
      Completer comp = Completer();
      Map<String, dynamic> json = {
        "iProjectId": 0,
        "dcId": 1,
        "projectName": "Site Quality Demo",
        "projectID": "2130192\$\$RT58Aj",
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
        "space_type_id": "1\$\$DEZrfb",
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
        "generateURI": true,
        "postalCode": "W1J 5JA",
        "projectSizeInByte": "201739336"
      };
      List<Project> projectList = [Project.fromJson(json)];
      var createQuery = "CREATE TABLE IF NOT EXISTS StatusStyleListTbl(ProjectId TEXT NOT NULL,StatusId INTEGER NOT NULL,StatusName TEXT NOY NULL,FontColor TEXT,BackgroundColor TEXT NOT NULL,FontEffect TEXT,FontType TEXT,StatusTypeId INTEGER NOT NULL DEFAULT 0,IsActive  INTEGER NOT NULL DEFAULT  0,PRIMARY KEY(ProjectId,StatusId))";
      var tableName = "StatusStyleListTbl";
      List<String> primaryKeysList = ["ProjectId", "StatusId"];
      List<String> columnNames = ["ProjectId", "StatusId", "StatusName", "FontColor", "BackgroundColor", "FontEffect", "FontType", "StatusTypeId", "IsActive"];
      List<List<Object?>> rows = [];
      var sqlQuery = "INSERT INTO StatusStyleListTbl (ProjectId,StatusId,StatusName,FontColor,BackgroundColor,FontEffect,FontType,StatusTypeId,IsActive) VALUES (?,?,?,?,?,?,?,?,?)";
      List<List<dynamic>> insertValues = [
        [
          [2130192, 3, "Closed", "#ffffff", "#848484", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 4, "Closed-Approved", "#ffffff", "#848484", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 5, "Closed-Approved with Comments", "#ffffff", "#848484", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 6, "Closed-Rejected", "#ffffff", "#848484", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 1, "Draft", "#ffffff", "#848484", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 2, "Open", "#ffffff", "#848484", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 1001, "Open", "#000000", "#e03ae0", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 1002, "Resolved", "#070ff2", "#22e0da", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 1003, "Verified", "#d8f2c2", "#1ac20e", "0#0#0#0", "PT Sans", 1, 1]
        ]
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

      when(() => mockProjectListUseCase!.getStatusStyleFromServer(any())).thenAnswer((_) async {
        return Future.value(SUCCESS(fixture("status_style.json"), null, 200));
      });
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, any())).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);

      StatusStyleListSyncTask(
        siteSyncTask,
        (eSyncTaskType, eSyncStatus, data) async {
          comp.complete();
        },
      ).syncStatusStyleData(projectList);

      await comp.future;
      verify(() => mockProjectListUseCase!.getStatusStyleFromServer(any())).called(1);
      verify(() => mockDb!.executeQuery(any())).called(1);
      verify(() => mockDb!.getPrimaryKeys(tableName)).called(1);
      verify(() => mockDb!.selectFromTable(tableName, any())).called(9);
      verify(() => mockDb!.executeBulk(tableName, sqlQuery, any())).called(1);
    });

    test("Project Sync Fail", () async {
      Completer comp = Completer();
      Map<String, dynamic> json = {
        "iProjectId": 0,
        "dcId": 1,
        "projectName": "Site Quality Demo",
        "projectID": "2130192\$\$RT58Aj",
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
        "space_type_id": "1\$\$DEZrfb",
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
        "generateURI": true,
        "postalCode": "W1J 5JA",
        "projectSizeInByte": "201739336"
      };
      List<Project> projectList = [Project.fromJson(json)];
      var createQuery = "CREATE TABLE IF NOT EXISTS StatusStyleListTbl(ProjectId TEXT NOT NULL,StatusId INTEGER NOT NULL,StatusName TEXT NOY NULL,FontColor TEXT,BackgroundColor TEXT NOT NULL,FontEffect TEXT,FontType TEXT,StatusTypeId INTEGER NOT NULL DEFAULT 0,IsActive  INTEGER NOT NULL DEFAULT  0,PRIMARY KEY(ProjectId,StatusId))";
      var tableName = "StatusStyleListTbl";
      List<String> primaryKeysList = ["ProjectId", "StatusId"];
      List<String> columnNames = ["ProjectId", "StatusId", "StatusName", "FontColor", "BackgroundColor", "FontEffect", "FontType", "StatusTypeId", "IsActive"];
      List<List<Object?>> rows = [];
      var sqlQuery = "INSERT INTO StatusStyleListTbl (ProjectId,StatusId,StatusName,FontColor,BackgroundColor,FontEffect,FontType,StatusTypeId,IsActive) VALUES (?,?,?,?,?,?,?,?,?)";
      List<List<dynamic>> insertValues = [
        [
          [2130192, 3, "Closed", "#ffffff", "#848484", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 4, "Closed-Approved", "#ffffff", "#848484", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 5, "Closed-Approved with Comments", "#ffffff", "#848484", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 6, "Closed-Rejected", "#ffffff", "#848484", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 1, "Draft", "#ffffff", "#848484", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 2, "Open", "#ffffff", "#848484", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 1001, "Open", "#000000", "#e03ae0", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 1002, "Resolved", "#070ff2", "#22e0da", "0#0#0#0", "PT Sans", 1, 1],
          [2130192, 1003, "Verified", "#d8f2c2", "#1ac20e", "0#0#0#0", "PT Sans", 1, 1]
        ]
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

      when(() => mockProjectListUseCase!.getStatusStyleFromServer(any())).thenAnswer((_) async {
        return Future.value(FAIL("", 404));
      });
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, any())).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);

      StatusStyleListSyncTask(
        siteSyncTask,
        (eSyncTaskType, eSyncStatus, data) async {
          comp.complete();
        },
      ).syncStatusStyleData(projectList);

      await comp.future;
      verify(() => mockProjectListUseCase!.getStatusStyleFromServer(any())).called(1);
    });

    test("Project List in Null", () async {
      Completer comp = Completer();
      List<Project> projectList = [];
      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = ""
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.project
        ..projectSizeInByte = "105758801";

      when(() => mockProjectListUseCase!.getStatusStyleFromServer(any())).thenAnswer((_) async {
        return Future.value(FAIL("", 404));
      });

      StatusStyleListSyncTask(
        siteSyncTask,
        (eSyncTaskType, eSyncStatus, data) async {
          comp.complete();
        },
      ).syncStatusStyleData(projectList);

      await comp.future;
    });
  });
}
