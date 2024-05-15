
import 'dart:async';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/site/site_use_case.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/task/location_plan_sync_task.dart';
import 'package:field/utils/download_service.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:field/injection_container.dart' as di;

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';

class MockSiteUseCase extends Mock implements SiteUseCase {}

class DBServiceMock extends Mock implements DBService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  MockSiteUseCase? mockSiteUseCase;
  DBServiceMock? mockDb;

  configureDependencies() async {
    mockSiteUseCase = MockSiteUseCase();
    mockDb = DBServiceMock();
    di.getIt.unregister<SiteUseCase>();
    di.getIt.unregister<DBService>();
    di.getIt.registerLazySingleton<SiteUseCase>(() => mockSiteUseCase!);
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
  }

  setUp(() {
    configureDependencies();
  });

  tearDown(() {
    mockDb = null;
    mockSiteUseCase = null;
  });

  group("locationPlanSyncTask Test", () {
    test("Download PDF and XFDF Success", () async {
      Completer comp = Completer();
      Map<String, dynamic> projectjson;
      projectjson = {
        "iProjectId" : 0,
        "dcId" : 1,
        "projectName" : "Site Quality Demo",
        "privilege" : ",4,5,54,55,56,58,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,145,146,1",
        "projectID" : "2130192\$\$jQtD1z",
        "parentId" : -1,
        "isWorkspace" : 1,
        "projectBaseUrl" : "",
        "projectBaseUrlForCollab" : "",
        "isUserAdminforProj" : true,
        "bimEnabled" : false,
        "isFavorite" : false,
        "canManageWorkspaceRoles" : true,
        "canManageWorkspaceFormStatus" : true,
        "isFromExchange" : false,
        "spaceTypeId" : "1\$\$8G2JJ4",
        "isTemplate" : false,
        "isCloned" : false,
        "activeFilesCount" : 0,
        "formsCount" : 0,
        "statusId" : 5,
        "users" : 0,
        "fetchRuleId" : 0,
        "canManageWorkspaceDocStatus" : true,
        "canCreateAutoFetchRule" : true,
        "ownerOrgId" : 3,
        "canManagePurposeOfIssue" : true,
        "canManageMailBox" : true,
        "editWorkspaceFormSettings" : true,
        "canAssignApps" : true,
        "canManageDistributionGroup" : true,
        "defaultpermissiontypeid" : 0,
        "checkoutPref" : false,
        "restrictDownloadOnCheckout" : false,
        "canManageAppSetting" : true,
        "projectsubscriptiontypeid" : 0,
        "canManageCustomAttribute" : true,
        "isAdminAccess" : false,
        "isUseAccess" : false,
        "canManageWorkflowRules" : true,
        "canAccessAuditInformation" : true,
        "countryId" : 0,
        "projectSpaceTypeId" : 0,
        "isWatching" : false,
        "canManageRolePrivileges" : true,
        "canManageFormPermissions" : true,
        "canManageProjectInvitations" : true,
        "enableCommentReview" : false,
        "projectViewerId" : 7,
        "isShared" : false,
        "insertInStorageSpace" : false,
        "colorid" : 0,
        "iconid" : 0,
        "businessid" : 0,
        "childfolderTreeVOList" : null,
        "generateURI" : true,
        "postalCode" : "W1J 5JA",
        "canRemoveOffline" : false,
        "isMarkOffline" : false,
        "syncStatus" :  ESyncStatus.failed,
        "lastSyncTimeStamp" : "",
        "newSyncTimeStamp" : "",
        "projectSizeInByte" : "17946406",
        "progress" : null
      };
      List<Project> projectList = [Project.fromJson(projectjson)];

      Map<String, dynamic> Locationjson = {
        "folderTitle" : "Basement",
        "permissionValue" : 0,
        "isActive" : 1,
        "folderPath" : "Site Quality Demo\01 Vijay_Test\Plan-1\Basement",
        "folderId" : "115096357\$\$ZwL7xd",
        "folderPublishPrivateRevPref" : 0,
        "clonedFolderId" : 0,
        "isPublic" : false,
        "projectId" : "2130192\$\$jQtD1z",
        "hasSubFolder" : false,
        "isFavourite" : false,
        "fetchRuleId" : 0,
        "includePublicSubFolder" : false,
        "parentFolderId" : 115096349,
        "pfLocationTreeDetail" : {
          "locationId" : 183682,
          "siteId" : 0,
          "isSite" : false,
          "parentLocationId" : 183679,
          "docId" : "13351081\$\$EDsu8M",
          "revisionId" : "26773045\$\$SmUk4J",
          "annotationId" : "1fc95526-3610-5163-e2c8-c915a692c3d4",
          "locationCoordinates" : "{\"x1\":593.98,\"y1\":669.61,\"x2\":803.92,\"y2\":522.8199999999999}",
          "isFileUploaded" : false,
          "pageNumber" : 1,
          "isCalibrated" : true,
          "generateURI" : true,
        },
        "isPFLocationTree" : true,
        "isWatching" : false,
        "instanceGroupIds" : "",
        "ownerName" : null,
        "isPlanSelected" : false,
        "isMandatoryAttribute" : false,
        "isShared" : false,
        "publisherId" : null,
        "imgModifiedDate" : null,
        "userImageName" : null,
        "orgName" : null,
        "isSharedByOther" : false,
        "permissionTypeId" : 0,
        "generateURI" : true,
        "childLocation" : [],
        "childTree" : [],
        "isLocationFetching" : false,
        "treeIndexPos" : null,
        "treeFolderIdPath" : null,
        "hasPermissionError" : null,
        "canRemoveOffline" : false,
        "isMarkOffline" : true,
        "syncStatus" : ESyncStatus.failed,
        "lastSyncTimeStamp" : null,
        "newSyncTimeStamp" : null,
        "isCheckForMarkOffline" : null,
        "progress" : null,
        "locationSizeInByte" : "0"
      };
      var location = SiteLocation.fromJson(Locationjson);
      location.isMarkOffline = true;
      location.pfLocationTreeDetail?.isFileUploaded = true;
      List<SiteLocation> formList = [location];

      var createQuery = "CREATE TABLE IF NOT EXISTS UserReferenceLocationPlanTbl(UserId TEXT,ProjectId TEXT,RevisionId TEXT,UserCloudId TEXT)";
      var tableName = "UserReferenceLocationPlanTbl";
      List<String> primaryKeysList = ["ProjectId"];
      var selectQuery = "SELECT ProjectId FROM UserReferenceLocationPlanTbl WHERE ProjectId='2130192'";
      List<String> columnNames = ["UserId", "ProjectId", "RevisionId", "UserCloudId"];
      List<List<Object?>> rows = [];
      var sqlQuery = "INSERT INTO UserReferenceLocationPlanTbl (UserId, ProjectId, RevisionId, UserCloudId) VALUES (?,?,?,?)";
      List<List<dynamic>> insertValues = [
        [2017529,2130192,26773045,1]
      ];

      ResultSet resultSet = ResultSet(columnNames, null, rows);

      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2130192\$\$PunjQZ"
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.siteLocation
        ..projectSizeInByte = "17946406";

      Map<String, dynamic> request = {
        "projectId": "2130192\$\$jQtD1z",
        "folderId":  "115096357\$\$ZwL7xd",
        "revisionId": "26773045\$\$SmUk4J",
        "networkExecutionType": NetworkExecutionType.SYNC,
      };

      ///downloadPDF
      DownloadResponse downloadResponse = DownloadResponse(true, "", Result({2130192,115096357,26773045}),requestParam: request);
      when(() => mockSiteUseCase!.downloadPdf(request, checkFileExist: true)).thenAnswer((_) async => Future.value(downloadResponse));
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);

      ///downloadXFDF
      when(() => mockSiteUseCase!.downloadXfdf(request, checkFileExist: true)).thenAnswer((_) async => Future.value(downloadResponse));
      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);

      LocationPlanSyncTask(
        siteSyncTask,
            (eSyncTaskType, eSyncStatus, data) async {
              comp.complete();
            },
      ).downloadPlanFile(projectList,formList);
      await comp.future;

      verify(() => mockSiteUseCase!.downloadXfdf(request,onReceiveProgress: null,checkFileExist: true)).called(1);
      verify(() => mockSiteUseCase!.downloadPdf(request,onReceiveProgress: null,checkFileExist: true)).called(1);
    });

  });
}