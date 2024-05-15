import 'dart:async';

import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/domain/use_cases/formtype/formtype_use_case.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/formtype_custom_attribute_list_sync_task.dart';
import 'package:field/utils/field_enums.dart';
import 'package:field/utils/file_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/injection_container.dart' as di;

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';

class MockFormTypeUseCase extends Mock implements FormTypeUseCase {}

class FileUtilityMock extends Mock implements FileUtility {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  MockFormTypeUseCase? mockFormTypeUseCase;
  FileUtilityMock? mockFileUtility;

  configureDependencies() async {
    mockFormTypeUseCase = MockFormTypeUseCase();
    mockFileUtility = FileUtilityMock();
    di.getIt.unregister<FormTypeUseCase>();
    di.getIt.unregister<FileUtility>();
    di.getIt.registerLazySingleton<FormTypeUseCase>(() => mockFormTypeUseCase!);
    di.getIt.registerLazySingleton<FileUtility>(() => mockFileUtility!);
  }

  setUpAll(() {
    configureDependencies();
  });

  tearDown(() {
    reset(mockFileUtility);
    reset(mockFormTypeUseCase);
  });

  tearDownAll(() {
    mockFileUtility = null;
    mockFormTypeUseCase = null;
  });

  group("FormTypeCustomAttributeListSyncTask Test", () {
    test("FormTypeCustomAttributeListSyncTask Project Sync Success", () async {
      var taskNumber = -9007199254740991;
      Completer comp = Completer();
      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2130192\$\$6euyPl"
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.project
        ..projectSizeInByte = "105758801";

      TaskPool taskPool = TaskPool(3);
      when(() => mockFormTypeUseCase!.getFormTypeCustomAttributeList(projectId: "2130192\$\$6euyPl", formTypeId: "11070450\$\$qQ6uNw", networkExecutionType: NetworkExecutionType.SYNC, taskNumber: taskNumber)).thenAnswer((_) async {
        return SUCCESS(fixture("form_custom_attribute_list.json"), null, 200);
      });
      when(() => mockFileUtility!.deleteFileAtPath(any())).thenAnswer((_) => Future.value(null));
      when(() => mockFileUtility!.writeDataToFile(any(), any())).thenAnswer((_) => Future.value(null));
      taskPool.execute((task) async {
        await FormTypeCustomAttributeListSyncTask(
          siteSyncTask,
          (eSyncTaskType, eSyncStatus, data) async {},
        ).getFormTypeCustomAttributeList(projectId: "2130192\$\$6euyPl", formTypeId: "11070450\$\$qQ6uNw", task: task);
        comp.complete();
      });
      await comp.future;
      verify(() => mockFormTypeUseCase!.getFormTypeCustomAttributeList(projectId: "2130192\$\$6euyPl", formTypeId: "11070450\$\$qQ6uNw", networkExecutionType: NetworkExecutionType.SYNC, taskNumber: taskNumber)).called(1);
      verify(() => mockFileUtility!.deleteFileAtPath(any())).called(1);
      verify(() => mockFileUtility!.writeDataToFile(any(), any())).called(1);
    });

    test("FormTypeCustomAttributeListSyncTask Location Sync Success", () async {
      var taskNumber = -9007199254740991;
      Completer comp = Completer();
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

      TaskPool taskPool = TaskPool(3);
      when(() => mockFormTypeUseCase!.getFormTypeCustomAttributeList(projectId: "2130192\$\$6euyPl", formTypeId: "11070450\$\$qQ6uNw", networkExecutionType: NetworkExecutionType.SYNC, taskNumber: taskNumber)).thenAnswer((_) async {
        return SUCCESS(fixture("form_custom_attribute_list.json"), null, 200);
      });
      when(() => mockFileUtility!.deleteFileAtPath(any())).thenAnswer((_) => Future.value(null));
      when(() => mockFileUtility!.writeDataToFile(any(), any())).thenAnswer((_) => Future.value(null));
      taskPool.execute((task) async {
        await FormTypeCustomAttributeListSyncTask(
          siteSyncTask,
          (eSyncTaskType, eSyncStatus, data) async {},
        ).getFormTypeCustomAttributeList(projectId: "2130192\$\$6euyPl", formTypeId: "11070450\$\$qQ6uNw", task: task);
        comp.complete();
      });
      await comp.future;
      verify(() => mockFormTypeUseCase!.getFormTypeCustomAttributeList(projectId: "2130192\$\$6euyPl", formTypeId: "11070450\$\$qQ6uNw", networkExecutionType: NetworkExecutionType.SYNC, taskNumber: taskNumber)).called(1);
      verify(() => mockFileUtility!.deleteFileAtPath(any())).called(1);
      verify(() => mockFileUtility!.writeDataToFile(any(), any())).called(1);
    });

    test("FormTypeCustomAttributeListSyncTask Project Sync Fail", () async {
      var taskNumber = -9007199254740991;
      Completer comp = Completer();
      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2130192\$\$6euyPl"
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.project
        ..projectSizeInByte = "105758801";

      TaskPool taskPool = TaskPool(3);
      when(() => mockFormTypeUseCase!.getFormTypeCustomAttributeList(projectId: "2130192\$\$6euyPl", formTypeId: "11070450\$\$qQ6uNw", networkExecutionType: NetworkExecutionType.SYNC, taskNumber: taskNumber)).thenAnswer((_) async {
        return FAIL("", 404);
      });
      taskPool.execute((task) async {
        await FormTypeCustomAttributeListSyncTask(
          siteSyncTask,
          (eSyncTaskType, eSyncStatus, data) async {},
        ).getFormTypeCustomAttributeList(projectId: "2130192\$\$6euyPl", formTypeId: "11070450\$\$qQ6uNw", task: task);
        comp.complete();
      });
      await comp.future;
      verify(() => mockFormTypeUseCase!.getFormTypeCustomAttributeList(projectId: "2130192\$\$6euyPl", formTypeId: "11070450\$\$qQ6uNw", networkExecutionType: NetworkExecutionType.SYNC, taskNumber: taskNumber)).called(1);
    });

    test("FormTypeCustomAttributeListSyncTask Project and FormTypeId is empty.", () async {
      var taskNumber = -9007199254740991;
      Completer comp = Completer();
      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2130192\$\$6euyPl"
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.project
        ..projectSizeInByte = "105758801";

      TaskPool taskPool = TaskPool(3);
      taskPool.execute((task) async {
        await FormTypeCustomAttributeListSyncTask(
          siteSyncTask,
          (eSyncTaskType, eSyncStatus, data) async {},
        ).getFormTypeCustomAttributeList(projectId: "2130192\$\$6euyPl", formTypeId: "11070450\$\$qQ6uNw", task: task);
        comp.complete();
      });
      await comp.future;
    });
  });
}
