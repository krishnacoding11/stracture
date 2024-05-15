
import 'dart:convert';

import 'package:field/data/dao/sync/site/site_sync_status_form_dao.dart';
import 'package:field/data/dao/sync/site/site_sync_status_location_dao.dart';
import 'package:field/data/dao/sync/site/site_sync_status_project_dao.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/form_message_attach_assoc_vo.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/sync/calculation/site_sync_status_local_data_source.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/fixture_reader.dart';

class MockDatabaseManager extends Mock implements DatabaseManager {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MockDatabaseManager mockDatabaseManager = MockDatabaseManager();
  SiteSyncStatusLocalDataSource siteSyncStatusLocalDataSource = SiteSyncStatusLocalDataSource();
  siteSyncStatusLocalDataSource.databaseManager = mockDatabaseManager;

  final projectId = "2116416";
  final formId = "234123";
  final revisionId = "2345489";
  final formTypeId = "28315689";
  final locationId = "183899";
  final folderId = "115335301";

  SiteSyncRequestTask projectSyncRequestTask = SiteSyncRequestTask()
    ..syncRequestId = DateTime.now().millisecondsSinceEpoch
    ..projectId = projectId
    ..eSyncType = ESyncType.project;

  SiteSyncRequestTask locationSyncRequestTask = SiteSyncRequestTask()
    ..syncRequestId = DateTime.now().millisecondsSinceEpoch
    ..projectId = projectId
    ..eSyncType = ESyncType.siteLocation;

  group("FormLocalDataSource",() {

    test("Remove Project Sync Request Data",() async {
      await siteSyncStatusLocalDataSource.removeSyncRequestData(projectSyncRequestTask);
    });

    test("Remove Location Sync Request Data",() async {
      await siteSyncStatusLocalDataSource.removeSyncRequestData(locationSyncRequestTask);
    });

    test("Insert Project and Location Sync Data",() async {
      List<SiteLocation>? siteLocationList = SiteLocation.jsonToList(fixture("site_location.json"));

      List<Project> projectList = <Project>[];
      final expectedResult = jsonDecode(fixture("project_list_data.json"));
      for (var item in expectedResult["data"]) {
        projectList.add(Project.fromJson(item));
      }

      Map<String, dynamic> data = {
        "projectList" : projectList,
        "siteLocationList" : siteLocationList
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.projectAndLocationSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.projectAndLocationSyncTask, ESyncStatus.failed, projectSyncRequestTask, data);
    });

    test("Update Project Filter Sync Status",() async {
      Map<String, dynamic> data = {
        "projectId" : projectId
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.filterSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
    });

    test("Update Location XFDF Status",() async {
      Map<String, dynamic> data = {
        "projectId" : projectId,
        "revisionId": revisionId,
        "isXfdf" : true
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.locationPlanSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
    });

    test("Update Location PDF Status",() async {
      Map<String, dynamic> data = {
        "projectId" : projectId,
        "revisionId": revisionId,
        "isXfdf" : false
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.locationPlanSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
    });

    test("Form List Sync Status",() async {
      dynamic formResponse = jsonDecode(fixture("form_vo_list.json"));
      List<SiteForm> formList = List<SiteForm>.from(formResponse.map((x) => SiteForm.fromJson(x))).toList();

      Map<String, dynamic> data = {
        "projectId" : projectId,
        "locationId": revisionId,
        "formList" : formList
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.formListSyncTask, ESyncStatus.inProgress, projectSyncRequestTask, data);
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.formListSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.formListSyncTask, ESyncStatus.failed, projectSyncRequestTask, data);
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.formListSyncTask, ESyncStatus.success, locationSyncRequestTask, data);
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.formListSyncTask, ESyncStatus.failed, locationSyncRequestTask, data);
    });

    test("Update Batch Form MSG List Sync Data",() async {
      Map<String, dynamic> data = {
        "projectId" : projectId,
        "formIds" : formId
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.formMessageBatchListSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
    });

    test("Update Project Form Type List Sync Status Data",() async {
      List<AppType> appTypeList = [];
      final appTypeListData = jsonDecode(fixture("app_type_list.json"));
      for (var item in appTypeListData["data"]) {
        appTypeList.add(AppType.fromJson(item));
      }

      Map<String, dynamic> data = {
        "projectId" : projectId,
        "appTypeList" : appTypeList
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.formTypeListSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
    });

    test("Update Form Type Template Download Sync Status Data",() async {
      Map<String, dynamic> data = {
        "projectId" : projectId,
        "formTypeId" : formTypeId
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.formTypeTemplateDownloadSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
    });

    test("Update Form Type Distribution List Sync Status Data",() async {

      Map<String, dynamic> data = {
        "projectId" : projectId,
        "formTypeId" : formTypeId
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.formTypeDistributionListSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
    });

    test("Update Form Type Controller User List Sync Status Data",() async {
      Map<String, dynamic> data = {
        "projectId" : projectId,
        "formTypeId" : formTypeId
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.formTypeControllerUserListSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
    });

    test("Update Form Type Fix Field List Sync Status Data",() async {
      Map<String, dynamic> data = {
        "projectId" : projectId,
        "formTypeId" : formTypeId
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.formTypeFixFieldListSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
    });

    test("Update Form Type Status List Sync Status Data",() async {
      Map<String, dynamic> data = {
        "projectId" : projectId,
        "formTypeId" : formTypeId
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.formTypeStatusListSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
    });

    test("Update Form Type Custom Attribute List Sync Status Data",() async {
      Map<String, dynamic> data = {
        "projectId" : projectId,
        "formTypeId" : formTypeId
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.formTypeCustomAttributeListSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
    });

    test("Status Style List Sync Data",() async {
      Map<String, dynamic> data = {
        "projectId" : projectId
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.statusStyleListSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
    });

    test("Manage Type List Sync Data",() async {
      Map<String, dynamic> data = {
        "projectId" : projectId
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.manageTypeListSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
    });

    test("Column Header List Sync Data",() async {
      Map<String, dynamic> data = {
        "projectId" : projectId
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.columnHeaderListSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
    });

    test("Form Attachment Download Batch Sync Status Data",() async {
      Map<String, dynamic> revisionData = {
        "projectId" : projectId,
        "revisionIds": revisionId
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.formAttachmentDownloadBatchSyncTask, ESyncStatus.success, projectSyncRequestTask, revisionData);

      List<FormMessageAttachAndAssocVO> attachmentList = [];
      attachmentList.add(FormMessageAttachAndAssocVO.fromJson({
        'type': '3',
        "attachType" : "3",
        "projectId": projectId,
        "formId" : formId,
        "locationId" : locationId,
        "attachRevId" : revisionId,
        'fileName': 'file.txt',
        'fileSize': '2048 KB',
      }));

      Map<String, dynamic> data = {
        "projectId" : projectId,
        "attachmentList": attachmentList
      };
      await siteSyncStatusLocalDataSource.syncCallback(ESyncTaskType.formAttachmentDownloadBatchSyncTask, ESyncStatus.success, projectSyncRequestTask, data);
    });

    test("Update Form XSN HTML View Sync Data",() async {
      siteSyncStatusLocalDataSource.updateFormXSNHtmlViewSyncData(projectId: projectId, locationId: locationId, formId: formId, eSyncStatus: ESyncStatus.success);
    });

    test("Test Sync Status Result Data For Location",() async {

     String strChildLocationQuery = "WITH ChildLocation(ProjectId,ParentLocationId,LocationId) AS (\n"
          "SELECT ProjectId,ParentLocationId,LocationId FROM SyncLocationTbl \n"
          "WHERE ProjectId=2116416 AND LocationId IN (183899)\n"
          "UNION\n"
          "SELECT f.ProjectId,f.ParentLocationId,f.LocationId FROM SyncLocationTbl f\n"
          "INNER JOIN ChildLocation c ON f.ParentLocationId=c.LocationId AND f.ProjectId=C.ProjectId\n"
          ")";
      //Form Sync Status
      String strFormQuery = "$strChildLocationQuery SELECT ProjectId,LocationId,FormId,SyncStatus FROM ";
      strFormQuery = "$strFormQuery  SyncFormTbl  WHERE ProjectId=2116416  AND LocationId IN (SELECT DISTINCT LocationId FROM ChildLocation)";
      when(() => mockDatabaseManager.executeSelectFromTable(SiteSyncStatusFormDao.tableName, strFormQuery)).thenReturn([{"ProjectId":2116416,"LocationId":183899,"FormId":11638294,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183901,"FormId":11603804,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11579886,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11580288,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11581990,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11581993,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588343,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588359,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588361,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588367,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588565,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588572,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588599,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588603,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588632,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588634,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588638,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588646,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588648,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588654,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588657,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588660,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588662,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588676,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588761,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588763,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588764,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588838,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588917,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588929,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588948,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11589007,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11597501,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11597510,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11597679,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11599214,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11604883,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11605766,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11607103,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11607113,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11608834,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11608838,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11617209,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620366,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620484,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620532,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620546,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620586,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620594,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620606,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620624,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620650,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620668,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620683,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620713,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620761,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620766,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620768,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620770,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620934,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11621184,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11621301,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11621304,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11622407,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11622942,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623119,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623144,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623183,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623429,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623657,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623669,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623856,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623887,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11624487,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11624490,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11624513,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11624526,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11626043,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11626044,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183905,"FormId":11597167,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183905,"FormId":11628445,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183905,"FormId":11631645,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183907,"FormId":11597180,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183909,"FormId":11597601,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183909,"FormId":11597613,"SyncStatus":2}]);

      String strLocationQuery = "WITH ChildLocation(ProjectId,ParentLocationId,LocationId) AS (\n"
          "SELECT ProjectId,ParentLocationId,LocationId FROM SyncLocationTbl \n"
          "WHERE ProjectId=2116416 AND LocationId IN (183899)\n"
          "UNION\n"
          "SELECT f.ProjectId,f.ParentLocationId,f.LocationId FROM SyncLocationTbl f\n"
          "INNER JOIN ChildLocation c ON f.ParentLocationId=c.LocationId AND f.ProjectId=C.ProjectId\n"
          ") \n"
          "SELECT f.ProjectId,f.LocationId,f.SyncStatus,f.SyncProgress From SyncLocationTbl f\n"
          "INNER JOIN ChildLocation c ON f.LocationId=c.LocationId AND f.ProjectId=C.ProjectId";
     when(() => mockDatabaseManager.executeSelectFromTable(SiteSyncStatusLocationDao.tableName, strLocationQuery)).thenReturn([{"ProjectId":2116416,"LocationId":183899,"SyncStatus":2,"SyncProgress":14},{"ProjectId":2116416,"LocationId":183900,"SyncStatus":2,"SyncProgress":24},{"ProjectId":2116416,"LocationId":183901,"SyncStatus":2,"SyncProgress":14},{"ProjectId":2116416,"LocationId":183902,"SyncStatus":2,"SyncProgress":24},{"ProjectId":2116416,"LocationId":183903,"SyncStatus":2,"SyncProgress":14},{"ProjectId":2116416,"LocationId":183904,"SyncStatus":2,"SyncProgress":14},{"ProjectId":2116416,"LocationId":183905,"SyncStatus":2,"SyncProgress":14},{"ProjectId":2116416,"LocationId":183908,"SyncStatus":2,"SyncProgress":69},{"ProjectId":2116416,"LocationId":183909,"SyncStatus":2,"SyncProgress":24},{"ProjectId":2116416,"LocationId":183906,"SyncStatus":2,"SyncProgress":59},{"ProjectId":2116416,"LocationId":183907,"SyncStatus":2,"SyncProgress":14},{"ProjectId":2116416,"LocationId":183910,"SyncStatus":2,"SyncProgress":69},{"ProjectId":2116416,"LocationId":183911,"SyncStatus":2,"SyncProgress":69}]);


      List<SyncRequestLocationVo> syncLocationList = [];
      SyncRequestLocationVo syncRequestLocationVo = SyncRequestLocationVo()
        ..folderId = folderId
        ..folderTitle = "0-Vijay-Sites"
        ..locationId = locationId
        ..isPlanOnly = true;
      syncLocationList.add(syncRequestLocationVo);

      SiteSyncRequestTask syncRequestTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = projectId
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..projectName = "!!PIN_ANY_APP_TYPE_20_9"
        ..lastSyncTime = null
        ..projectSizeInByte = "1759314"
        ..thresholdCompletedTask = null
        ..isReSync = false
        ..eSyncType = ESyncType.siteLocation
        ..syncRequestLocationList = syncLocationList;


      Map result  = siteSyncStatusLocalDataSource.syncStatusResultMap(syncRequestTask);
      expect(result, isNotNull);

    });

    test("Test Sync Status Result Data For Project",() async {
      String strChildLocationQuery = "WITH ChildLocation(ProjectId,ParentLocationId,LocationId) AS (\n"
          "SELECT ProjectId,ParentLocationId,LocationId FROM SyncLocationTbl \n"
          "WHERE ProjectId=2116416 AND ParentLocationId=0\n"
          "UNION\n"
          "SELECT f.ProjectId,f.ParentLocationId,f.LocationId FROM SyncLocationTbl f\n"
          "INNER JOIN ChildLocation c ON f.ParentLocationId=c.LocationId AND f.ProjectId=C.ProjectId\n"
          ")";
      //Form Sync Status
      String strFormQuery = "$strChildLocationQuery SELECT ProjectId,LocationId,FormId,SyncStatus FROM ";
      strFormQuery = "$strFormQuery  SyncFormTbl  WHERE ProjectId=2116416  AND LocationId IN (SELECT DISTINCT LocationId FROM ChildLocation)";
      when(() => mockDatabaseManager.executeSelectFromTable(SiteSyncStatusFormDao.tableName, strFormQuery)).thenReturn([{"ProjectId":2116416,"LocationId":183899,"FormId":11638294,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183901,"FormId":11603804,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11579886,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11580288,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11581990,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11581993,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588343,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588359,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588361,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588367,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588565,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588572,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588599,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588603,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588632,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588634,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588638,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588646,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588648,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588654,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588657,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588660,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588662,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588676,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588761,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588763,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588764,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588838,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588917,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588929,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11588948,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11589007,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11597501,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11597510,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11597679,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11599214,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11604883,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11605766,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11607103,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11607113,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11608834,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11608838,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11617209,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620366,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620484,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620532,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620546,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620586,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620594,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620606,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620624,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620650,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620668,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620683,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620713,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620761,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620766,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620768,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620770,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11620934,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11621184,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11621301,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11621304,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11622407,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11622942,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623119,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623144,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623183,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623429,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623657,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623669,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623856,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11623887,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11624487,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11624490,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11624513,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11624526,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11626043,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183904,"FormId":11626044,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183905,"FormId":11597167,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183905,"FormId":11628445,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183905,"FormId":11631645,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183907,"FormId":11597180,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183909,"FormId":11597601,"SyncStatus":2},{"ProjectId":2116416,"LocationId":183909,"FormId":11597613,"SyncStatus":2}]);

      String strLocationQuery = "WITH ChildLocation(ProjectId,ParentLocationId,LocationId) AS (\n"
          "SELECT ProjectId,ParentLocationId,LocationId FROM SyncLocationTbl \n"
          "WHERE ProjectId=2116416 AND ParentLocationId=0\n"
          "UNION\n"
          "SELECT f.ProjectId,f.ParentLocationId,f.LocationId FROM SyncLocationTbl f\n"
          "INNER JOIN ChildLocation c ON f.ParentLocationId=c.LocationId AND f.ProjectId=C.ProjectId\n"
          ") \n"
          "SELECT f.ProjectId,f.LocationId,f.SyncStatus,f.SyncProgress From SyncLocationTbl f\n"
          "INNER JOIN ChildLocation c ON f.LocationId=c.LocationId AND f.ProjectId=C.ProjectId";
      when(() => mockDatabaseManager.executeSelectFromTable(SiteSyncStatusLocationDao.tableName, strLocationQuery)).thenReturn([{"ProjectId":2116416,"LocationId":183899,"SyncStatus":2,"SyncProgress":14},{"ProjectId":2116416,"LocationId":183900,"SyncStatus":2,"SyncProgress":24},{"ProjectId":2116416,"LocationId":183901,"SyncStatus":2,"SyncProgress":14},{"ProjectId":2116416,"LocationId":183902,"SyncStatus":2,"SyncProgress":24},{"ProjectId":2116416,"LocationId":183903,"SyncStatus":2,"SyncProgress":14},{"ProjectId":2116416,"LocationId":183904,"SyncStatus":2,"SyncProgress":14},{"ProjectId":2116416,"LocationId":183905,"SyncStatus":2,"SyncProgress":14},{"ProjectId":2116416,"LocationId":183908,"SyncStatus":2,"SyncProgress":69},{"ProjectId":2116416,"LocationId":183909,"SyncStatus":2,"SyncProgress":24},{"ProjectId":2116416,"LocationId":183906,"SyncStatus":2,"SyncProgress":59},{"ProjectId":2116416,"LocationId":183907,"SyncStatus":2,"SyncProgress":14},{"ProjectId":2116416,"LocationId":183910,"SyncStatus":2,"SyncProgress":69},{"ProjectId":2116416,"LocationId":183911,"SyncStatus":2,"SyncProgress":69}]);

      String strProjectProgressQuery = "SELECT ProjectId,SyncStatus,SyncProgress FROM SyncProjectTbl\n"
          "WHERE ProjectId=2116416";
      when(() => mockDatabaseManager.executeSelectFromTable(SiteSyncStatusProjectDao.tableName, strProjectProgressQuery)).thenReturn([{"ProjectId": 2116416, "SyncStatus": 1, "SyncProgress": 0}]);

      List<SyncRequestLocationVo> syncLocationList = [];
      SyncRequestLocationVo syncRequestLocationVo = SyncRequestLocationVo()
        ..folderId = folderId
        ..folderTitle = "0-Vijay-Sites"
        ..locationId = ""
        ..isPlanOnly = true;
      syncLocationList.add(syncRequestLocationVo);

      SiteSyncRequestTask syncRequestTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = projectId
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..projectName = "!!PIN_ANY_APP_TYPE_20_9"
        ..lastSyncTime = null
        ..projectSizeInByte = "1759314"
        ..thresholdCompletedTask = null
        ..isReSync = false
        ..eSyncType = ESyncType.project
        ..syncRequestLocationList = syncLocationList;

      Map result  = siteSyncStatusLocalDataSource.syncStatusResultMap(syncRequestTask);
      expect(result, isNotNull);

    });
  });
}