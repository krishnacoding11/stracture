import 'dart:async';
import 'dart:convert';

import 'package:field/data/dao/user_reference_formtype_template_dao.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/formtype/formtype_use_case.dart';
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/formtype_template_dowload_sync_task.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:field/injection_container.dart' as di;

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';


class MockFormTypeUseCase extends Mock implements FormTypeUseCase {}

class DBServiceMock extends Mock implements DBService {}



Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  await di.init(test: true);
  AppConfigTestData().setupAppConfigTestData();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockFormTypeUseCase? mockFormTypeUseCase;
  UserReferenceFormTypeTemplateDao userReferenceFormTypeTemplateDao = UserReferenceFormTypeTemplateDao();
  List<AppType>? apptypeList = [];
  DBServiceMock? mockDb;
  AConstants.adoddleUrl = 'https://adoddleqaak.asite.com/';
  AConstants.collabUrl = 'https://dmsak.asite.com';


  configureDependencies() async {
    mockFormTypeUseCase = MockFormTypeUseCase();
    mockDb = DBServiceMock();

      di.getIt.unregister<FormTypeUseCase>();
      di.getIt.unregister<DBService>();

    di.getIt.unregister<InternetCubit>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
    di.getIt.registerLazySingleton<FormTypeUseCase>(() => mockFormTypeUseCase!);

     di.getIt.registerLazySingleton<InternetCubit>(() => InternetCubit());
  }

  setUp(() {
    configureDependencies();
    final appTypeListData = jsonDecode(fixture("form_type_download_app_list.json"));
    for (var item in appTypeListData["data"]) {
      apptypeList.add(AppType.fromJson(item));
    }
  });

  tearDown(() {
    mockFormTypeUseCase = null;
  });






  group("Form type template download test Test", () {

    test("FormTypeTemplateDownloadSyncTask html zip download", () async {
      var taskNumber = -9007199254740959;
      var projectID = "2130192\$\$Jwiccq";
      var formTypeId = '11104955\$\$Z4seZ3';
      var instanceGroupId = '11063842';

      TaskPool taskPool = TaskPool(3);

      List<SyncRequestLocationVo> syncLocationList = [];
      SyncRequestLocationVo siteRequestLocationvo = SyncRequestLocationVo()
        ..folderId = "114159237"
        ..folderTitle = "01 - Zone-1"
        ..locationId = "177287"
        ..lastSyncTime = null
        ..isPlanOnly = true;
      syncLocationList.add(siteRequestLocationvo);

      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..eSyncType = ESyncType.siteLocation
        ..projectId = '2130192'
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..projectSizeInByte = "182335131"
        ..syncRequestLocationList = syncLocationList;

      var success = fixtureZipFile("11104955.zip");

      String tableName = 'UserReferenceFormTypeTemplateTbl';
      final userId = '1';
      final userCloudId = '1';

      String insertQuery = "INSERT INTO $tableName (UserId, ProjectId, FormTypeId, UserCloudId) SELECT '$userId', '$projectID', '$formTypeId','$userCloudId' WHERE NOT EXISTS (SELECT 1 FROM $tableName WHERE UserId = '$userId' AND ProjectId = '$projectID' AND FormTypeId = '$formTypeId' AND UserCloudId = '$userCloudId');";
      final columnList = ["UserId", "ProjectId", "FormTypeId", "UserCloudId"];
      final rows = [
        ['1', '1234', '1234', '1']
      ];
      final createQuery = "CREATE TABLE IF NOT EXISTS UserReferenceFormTypeTemplateTbl(UserId TEXT,ProjectId TEXT,FormTypeId TEXT,UserCloudId TEXT)";
      final selectQuery = "SELECT * FROM UserReferenceFormTypeTemplateTbl";
      ResultSet resultSet = ResultSet(columnList, null, rows);



      when(() => mockFormTypeUseCase!.getFormTypeHTMLTemplateZipDownload(projectId: projectID, formTypeId: formTypeId, networkExecutionType: NetworkExecutionType.SYNC, taskNumber: any( named: "taskNumber"))).thenAnswer((_) async {
        return Future.value(SUCCESS(success, null, 200));
      });

      when(() => mockDb!.executeQuery(insertQuery)).thenReturn(null);
      await userReferenceFormTypeTemplateDao.insertFormTypeTemplateDetailsInUserReference(projectId: '', formTypeId: '');
      when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(resultSet);

      verify(() => mockDb!.executeQuery(createQuery)).called(1);



      taskPool.execute((task) async {
        await FormTypeTemplateDownloadSyncTask(
          siteSyncTask,
              (eSyncTaskType, eSyncStatus, data) async {},
        ).getFormTypeHTMLTemplateDownload(apptypeList,projectId: projectID, formTypeId: formTypeId, task: task, instanceGroupId: instanceGroupId);
      });


      when(() => mockFormTypeUseCase!.getFormTypeHTMLTemplateZipDownload(projectId: '', formTypeId: '', networkExecutionType: NetworkExecutionType.SYNC, taskNumber: 0)).thenAnswer((_) async {
        return FAIL('', null);
      });

    });

    test("FormTypeTemplateDownloadSyncTask html zip download catch", () async {
      var taskNumber = -9007199254740959;
      var projectID = "2130192\$\$Jwiccq";
      var formTypeId = '11104955\$\$Z4seZ3';
      var instanceGroupId = '11063842';

      TaskPool taskPool = TaskPool(3);

      List<SyncRequestLocationVo> syncLocationList = [];
      SyncRequestLocationVo siteRequestLocationvo = SyncRequestLocationVo()
        ..folderId = "114159237"
        ..folderTitle = "01 - Zone-1"
        ..locationId = "177287"
        ..lastSyncTime = null
        ..isPlanOnly = true;
      syncLocationList.add(siteRequestLocationvo);

      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..eSyncType = ESyncType.siteLocation
        ..projectId = '2130192'
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..projectSizeInByte = "182335131"
        ..syncRequestLocationList = syncLocationList;

      var success = fixtureZipFile("11104955.zip");



      when(() => mockFormTypeUseCase!.getFormTypeHTMLTemplateZipDownload(projectId: projectID, formTypeId: formTypeId, networkExecutionType: NetworkExecutionType.SYNC, taskNumber: taskNumber)).thenAnswer((_) async {
        return Future.value(SUCCESS(success, null, 200));
      });

      taskPool.execute((task) async {
        await FormTypeTemplateDownloadSyncTask(
          siteSyncTask,
              (eSyncTaskType, eSyncStatus, data) async {},
        ).getFormTypeHTMLTemplateDownload(apptypeList,projectId: projectID, formTypeId: formTypeId, task: task, instanceGroupId: instanceGroupId);
      });


    });

    test("FormTypeTemplateDownloadSyncTask html zip download fail", () async {
      var taskNumber = -9007199254740959;
      var projectID = "2130192\$\$Jwiccq";
      var formTypeId = '11104955\$\$Z4seZ3';
      var instanceGroupId = '11063842';

      TaskPool taskPool = TaskPool(3);

      List<SyncRequestLocationVo> syncLocationList = [];
      SyncRequestLocationVo siteRequestLocationvo = SyncRequestLocationVo()
        ..folderId = "114159237"
        ..folderTitle = "01 - Zone-1"
        ..locationId = "177287"
        ..lastSyncTime = null
        ..isPlanOnly = true;
      syncLocationList.add(siteRequestLocationvo);

      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..eSyncType = ESyncType.siteLocation
        ..projectId = '2130192'
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..projectSizeInByte = "182335131"
        ..syncRequestLocationList = syncLocationList;


      taskPool.execute((task) async {
        await FormTypeTemplateDownloadSyncTask(
          siteSyncTask,
              (eSyncTaskType, eSyncStatus, data) async {},
        ).getFormTypeHTMLTemplateDownload(apptypeList,projectId: projectID, formTypeId: formTypeId, task: task, instanceGroupId: instanceGroupId);
      });


      when(() => mockFormTypeUseCase!.getFormTypeHTMLTemplateZipDownload(projectId: '', formTypeId: '', networkExecutionType: NetworkExecutionType.SYNC, taskNumber: any(named: "taskNumber"))).thenAnswer((_) async {
        return FAIL('', null);
      });

    });




    test("_formTypeXSNTemplateDownload success", () async {
      var projectId1 = "2130192\$\$Jwiccq";
      var formTypeId1 = "10973573\$\$rbhrCz";
      var userId1 = "2017529\$\$uTqgBp";
      var jSFolderPath = "file:///offlineJsFolder/";
      var taskNumber = -9007199254740968;
      TaskPool taskPool = TaskPool(3);

      List<SyncRequestLocationVo> syncLocationList = [];
      SyncRequestLocationVo siteRequestLocationvo = SyncRequestLocationVo()
        ..folderId = "114159237"
        ..folderTitle = "01 - Zone-1"
        ..locationId = "177287"
        ..lastSyncTime = null
        ..isPlanOnly = true;
      syncLocationList.add(siteRequestLocationvo);

      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..eSyncType = ESyncType.siteLocation
        ..projectId = '2130192'
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..projectSizeInByte = "182335131"
        ..syncRequestLocationList = syncLocationList;


     when(() => mockFormTypeUseCase!.getFormTypeXSNTemplateZipDownload(projectId: projectId1, formTypeId: formTypeId1, networkExecutionType: NetworkExecutionType.SYNC,
         taskNumber: any( named: "taskNumber"),
         userId: userId1, jSFolderPath: jSFolderPath)).thenAnswer((_) async {
       return SUCCESS(fixtureZipFile("11072582.zip"), null, 200);
     });

      taskPool.execute((task) async {
        await FormTypeTemplateDownloadSyncTask(
          siteSyncTask,
              (eSyncTaskType, eSyncStatus, data) async {},
        ).getFormTypeXSNTemplateDownload(projectId: projectId1, formTypeId: formTypeId1, task: task, userId: userId1);
      });


    });

    test("_formTypeXSNTemplateDownload catch", () async {
      var projectId1 = "2130192\$\$Jwiccq";
      var formTypeId1 = "10973573\$\$rbhrCz";
      var userId1 = "2017529\$\$uTqgBp";
      var jSFolderPath = "file:///offlineJsFolder/";
      var taskNumber = -9007199254740968;
      TaskPool taskPool = TaskPool(3);

      List<SyncRequestLocationVo> syncLocationList = [];
      SyncRequestLocationVo siteRequestLocationvo = SyncRequestLocationVo()
        ..folderId = "114159237"
        ..folderTitle = "01 - Zone-1"
        ..locationId = "177287"
        ..lastSyncTime = null
        ..isPlanOnly = true;
      syncLocationList.add(siteRequestLocationvo);

      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..eSyncType = ESyncType.siteLocation
        ..projectId = '2130192'
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..projectSizeInByte = "182335131"
        ..syncRequestLocationList = syncLocationList;


      when(() => mockFormTypeUseCase!.getFormTypeXSNTemplateZipDownload(projectId: projectId1, formTypeId: formTypeId1, networkExecutionType: NetworkExecutionType.SYNC,
          taskNumber: taskNumber,
          userId: userId1, jSFolderPath: jSFolderPath)).thenAnswer((_) async {
        return SUCCESS(fixtureZipFile("11072582.zip"), null, 200);
      });

      taskPool.execute((task) async {
        await FormTypeTemplateDownloadSyncTask(
          siteSyncTask,
              (eSyncTaskType, eSyncStatus, data) async {},
        ).getFormTypeXSNTemplateDownload(projectId: projectId1, formTypeId: formTypeId1, task: task, userId: userId1);
      });


    });

    test("_formTypeXSNTemplateDownload fail case", () async {
      var projectId1 = "2130192\$\$Jwiccq";
      var formTypeId1 = "10973573\$\$rbhrCz";
      var userId1 = "2017529\$\$uTqgBp";
      var jSFolderPath = "file:///offlineJsFolder/";
      var taskNumber = -9007199254740968;
      TaskPool taskPool = TaskPool(3);

      List<SyncRequestLocationVo> syncLocationList = [];
      SyncRequestLocationVo siteRequestLocationvo = SyncRequestLocationVo()
        ..folderId = "114159237"
        ..folderTitle = "01 - Zone-1"
        ..locationId = "177287"
        ..lastSyncTime = null
        ..isPlanOnly = true;
      syncLocationList.add(siteRequestLocationvo);

      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..eSyncType = ESyncType.siteLocation
        ..projectId = '2130192'
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..projectSizeInByte = "182335131"
        ..syncRequestLocationList = syncLocationList;

      //
      // when(() => mockFormTypeUseCase!.getFormTypeXSNTemplateZipDownload(projectId: projectId1, formTypeId: formTypeId1, networkExecutionType: NetworkExecutionType.SYNC,
      //     taskNumber: any( named: "taskNumber"),
      //     userId: userId1, jSFolderPath: jSFolderPath)).thenAnswer((_) async {
      //   return SUCCESS(fixtureZipFile("11072582.zip"), null, 200);
      // });

      when(() =>
          mockFormTypeUseCase!.getFormTypeXSNTemplateZipDownload(projectId: '', formTypeId: '', networkExecutionType: NetworkExecutionType.SYNC, taskNumber: 0, userId: '', jSFolderPath: '')).thenAnswer((_) async {
        return FAIL('', null);
      });

      taskPool.execute((task) async {
        await FormTypeTemplateDownloadSyncTask(
          siteSyncTask,
              (eSyncTaskType, eSyncStatus, data) async {},
        ).getFormTypeXSNTemplateDownload(projectId: projectId1, formTypeId: formTypeId1, task: task, userId: userId1);
      });


    });

  });
}



