import 'dart:async';
import 'dart:convert';

import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/column_header_list_sync_task.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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

  group("ColumnHeaderListSyncTask Test", () {
    test("ColumnHeaderListSyncTask sync Success", () async {
      var taskNumber = -9007199254740991;
      Completer comp = Completer();
      SyncRequestTask siteSyncTask = SyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2130192\$\$MqjZY3"
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.project
        ..projectSizeInByte = "105758801";

      TaskPool taskPool = TaskPool(3);
      when(() => mockProjectListUseCase!.getColumnHeaderList(any())).thenAnswer((_) async {
        return SUCCESS(jsonDecode(fixture("column_header_list.json")), null, 200);
      });

      taskPool.execute((task) async {
        await ColumnHeaderListSyncTask(
          siteSyncTask,
              (eSyncTaskType, eSyncStatus, data) async {},
        ).syncColumnHeaderListData(task);
        comp.complete();
      });
      await comp.future;
      verify(() => mockProjectListUseCase!.getColumnHeaderList(any())).called(3);

    });


    test("ColumnHeaderListSyncTask Sync Fail", () async {
      var taskNumber = -9007199254740991;
      Completer comp = Completer();
      SyncRequestTask siteSyncTask = SyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2130192\$\$6euyPl"
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.project
        ..projectSizeInByte = "105758801";

      TaskPool taskPool = TaskPool(3);
      when(() => mockProjectListUseCase!.getColumnHeaderList(any())).thenAnswer((_) async {
        return FAIL("sync failed", 400);
      });
      taskPool.execute((task) async {
        await ColumnHeaderListSyncTask(
          siteSyncTask,
              (eSyncTaskType, eSyncStatus, data) async {},
        ).syncColumnHeaderListData(task);
        comp.complete();
      });
      await comp.future;
      verify(() => mockProjectListUseCase!.getColumnHeaderList(any())).called(3);
    });

  });
}
