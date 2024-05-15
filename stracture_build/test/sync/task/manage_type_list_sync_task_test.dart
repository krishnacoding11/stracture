import 'dart:async';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/task/manage_type_list_sync_task.dart';
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

  group("ManageTypeListSyncTask Test", () {
    test("Project Sync Success", () async {
      Completer comp = Completer();
      Map<String, dynamic> json = {
        "iProjectId": 0,
        "dcId": 1,
        "projectName": "Site Quality Demo",
        "privilege": ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,1",
        "projectID": "2130192\$\$Sri9Uu",
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
        "spaceTypeId": "1\$\$IAK9IT",
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
        "childfolderTreeVOList": [],
        "generateURI": true,
        "postalCode": "W1J 5JA",
        "canRemoveOffline": true,
        "isMarkOffline": true,
        "syncStatus": ESyncStatus.failed,
        "lastSyncTimeStamp": "",
        "newSyncTimeStamp": "2023-08-11 07:53:39.26",
        "projectSizeInByte": "16469496",
        "progress": ""
      };
      List<Project> projectList = [Project.fromJson(json)];
      var createQuery = "CREATE TABLE IF NOT EXISTS ManageTypeListTbl(ProjectId TEXT NOT NULL,ManageTypeId INTEGER,ManageTypeName TEXT NOT NULL,UserId TEXT,UserName TEXT,OrgId TEXT,OrgName TEXT,IsDeactive  INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId,ManageTypeId))";
      var tableName = "ManageTypeListTbl";
      List<String> primaryKeysList = ["ProjectId", "ManageTypeId"];
      List<String> columnNames = ["ProjectId", "ManageTypeId", "ManageTypeName", "UserId", "UserName", "OrgId", "OrgName", "IsDeactive"];
      List<List<Object?>> rows = [];
      var sqlQuery = "INSERT INTO ManageTypeListTbl (ProjectId,ManageTypeId,ManageTypeName,UserId,UserName,OrgId,OrgName,IsDeactive) VALUES (?,?,?,?,?,?,?,?)";
      List<List<dynamic>> insertValues = [
        [2130192, 310497, "Architectural", "", "", "", "", 0],
        [2130192, 310499, "Civil", "", "", "", "", 0],
        [2130192, 310493, "Computer", "", "", "", "", 0],
        [2130192, 310494, "EC", "", "", "", "", 0],
        [2130192, 310498, "Electrical", "", "", "", "", 0],
        [2130192, 310495, "Fire Safety", "", "", "", "", 0],
        [2130192, 310496, "Mechanical", "", "", "", "", 0]
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

      when(() => mockProjectListUseCase!.getManageTypeListFromServer(any())).thenAnswer((_) async {
        return Future.value(SUCCESS(fixture("managetype.json"), null, 200));
      });
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, any())).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);

      ManageTypeListSyncTask(
        siteSyncTask,
        (eSyncTaskType, eSyncStatus, data) async {
          comp.complete();
        },
      ).syncManageTypeListData(projectList);

      await comp.future;
      verify(() => mockProjectListUseCase!.getManageTypeListFromServer(any())).called(1);
      verify(() => mockDb!.executeQuery(any())).called(1);
      verify(() => mockDb!.getPrimaryKeys(tableName)).called(1);
      verify(() => mockDb!.selectFromTable(tableName, any())).called(7);
      verify(() => mockDb!.executeBulk(tableName, sqlQuery, any())).called(1);
    });

    test("Project Sync Fail", () async {
      Completer comp = Completer();
      Map<String, dynamic> json = {
        "iProjectId": 0,
        "dcId": 1,
        "projectName": "Site Quality Demo",
        "privilege": ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,1",
        "projectID": "2130192\$\$Sri9Uu",
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
        "spaceTypeId": "1\$\$IAK9IT",
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
        "childfolderTreeVOList": [],
        "generateURI": true,
        "postalCode": "W1J 5JA",
        "canRemoveOffline": true,
        "isMarkOffline": true,
        "syncStatus": ESyncStatus.failed,
        "lastSyncTimeStamp": "",
        "newSyncTimeStamp": "2023-08-11 07:53:39.26",
        "projectSizeInByte": "16469496",
        "progress": ""
      };
      List<Project> projectList = [Project.fromJson(json)];
      var createQuery = "CREATE TABLE IF NOT EXISTS ManageTypeListTbl(ProjectId TEXT NOT NULL,ManageTypeId INTEGER,ManageTypeName TEXT NOT NULL,UserId TEXT,UserName TEXT,OrgId TEXT,OrgName TEXT,IsDeactive  INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId,ManageTypeId))";
      var tableName = "ManageTypeListTbl";
      List<String> primaryKeysList = ["ProjectId", "ManageTypeId"];
      List<String> columnNames = ["ProjectId", "ManageTypeId", "ManageTypeName", "UserId", "UserName", "OrgId", "OrgName", "IsDeactive"];
      List<List<Object?>> rows = [];
      var sqlQuery = "INSERT INTO ManageTypeListTbl (ProjectId,ManageTypeId,ManageTypeName,UserId,UserName,OrgId,OrgName,IsDeactive) VALUES (?,?,?,?,?,?,?,?)";
      List<List<dynamic>> insertValues = [
        [2130192, 310497, "Architectural", "", "", "", "", 0],
        [2130192, 310499, "Civil", "", "", "", "", 0],
        [2130192, 310493, "Computer", "", "", "", "", 0],
        [2130192, 310494, "EC", "", "", "", "", 0],
        [2130192, 310498, "Electrical", "", "", "", "", 0],
        [2130192, 310495, "Fire Safety", "", "", "", "", 0],
        [2130192, 310496, "Mechanical", "", "", "", "", 0]
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

      when(() => mockProjectListUseCase!.getManageTypeListFromServer(any())).thenAnswer((_) async {
        return Future.value(FAIL("", 404));
      });
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, any())).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);

      ManageTypeListSyncTask(
        siteSyncTask,
        (eSyncTaskType, eSyncStatus, data) async {
          comp.complete();
        },
      ).syncManageTypeListData(projectList);

      await comp.future;
      verify(() => mockProjectListUseCase!.getManageTypeListFromServer(any())).called(1);
    });

    test("Project List is Null", () async {
      Completer comp = Completer();
      List<Project> projectList = [];
      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2130192\$\$fIdR2g"
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.project
        ..projectSizeInByte = "105758801";

      when(() => mockProjectListUseCase!.getManageTypeListFromServer(any())).thenAnswer((_) async {
        return Future.value(FAIL("", 404));
      });
      ManageTypeListSyncTask(
        siteSyncTask,
        (eSyncTaskType, eSyncStatus, data) async {
          comp.complete();
        },
      ).syncManageTypeListData(projectList);
      await comp.future;
    });
  });
}
