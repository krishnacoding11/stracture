
import 'dart:async';
import 'dart:isolate';

import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/database/db_service.dart';
import 'package:field/sync/executors/auto_sync_executor.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/push_to_server_form_distribution_action_task.dart';
import 'package:field/sync/task/push_to_server_form_other_action_task.dart';
import 'package:field/sync/task/push_to_server_form_status_change_task.dart';
import 'package:field/sync/task/push_to_server_form_sync_task.dart';
import 'package:field/sync/sync_task_factory.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/offline_injection_container.dart' as di;
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/common.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';

class SyncTaskFactoryMock extends Mock implements SyncTaskFactory {}
class DBServiceMock extends Mock implements DBService {}
class PushToServerFormSyncTaskMock extends Mock implements PushToServerFormSyncTask {}
class PushToServerFormStatusChangeTaskMock extends Mock implements PushToServerFormStatusChangeTask {}
class PushToServerFormDistributionActionTaskMock extends Mock implements PushToServerFormDistributionActionTask {}
class PushToServerFormOherActionTaskMock extends Mock implements PushToServerFormOherActionTask {}


void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  DBServiceMock mockDb = DBServiceMock();
  SyncTaskFactoryMock mockFactory = SyncTaskFactoryMock();
  PushToServerFormSyncTaskMock mockFormSyncTask = PushToServerFormSyncTaskMock();
  PushToServerFormStatusChangeTaskMock mockFormStatusChangeSyncTask = PushToServerFormStatusChangeTaskMock();
  PushToServerFormDistributionActionTaskMock mockFormDistributionSyncTask = PushToServerFormDistributionActionTaskMock();
  PushToServerFormOherActionTaskMock mockFormOherActionSyncTask = PushToServerFormOherActionTaskMock();
  configureDependencies() {
    di.getIt.unregister<SyncTaskFactory>();
    di.getIt.unregister<DBService>();
    di.getIt.registerLazySingleton<SyncTaskFactory>(() => mockFactory);
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb);
  }
  tearDown(() {
    reset(mockFactory);
    reset(mockDb);
  });

  setUpAll(() {
    configureDependencies();
  });

  tearDownAll(() {

  });

  group("AutoSyncExecutor Test", () {
    test('execute test', () async {
      final taskPool = di.getIt<TaskPool>();
      final c = new Completer();
      final receivePort = ReceivePort();
      AutoSyncRequestTask siteSyncRequestTask = AutoSyncRequestTask();
      siteSyncRequestTask.eSyncType = ESyncType.pushToServer;
      final executor = AutoSyncExecutor(siteSyncRequestTask);

      String tableName = "FormMessageListTbl";
      String autoSyncQuery = "SELECT * FROM (\n"
          "SELECT 1 AS RequestType,ProjectId,FormId,MsgId,UpdatedDateInMS FROM FormMessageListTbl\n"
          "WHERE OfflineRequestData<>''\n"
          "UNION\n"
          "SELECT 2 AS RequestType,ProjectId,FormId,MessageId AS MsgId,CreateDateInMS AS UpdatedDateInMS FROM FormStatusHistoryTbl\n"
          "WHERE JsonData<>''\n"
          "UNION\n"
          "SELECT IIF(actionId=6,4,3) AS RequestType,ProjectId,FormId,MsgId,CreatedDateInMs AS UpdatedDateInMS FROM OfflineActivityTbl\n"
          "WHERE OfflineRequestData<>''\n"
          ")\n"
          "ORDER BY CAST(UpdatedDateInMS AS INTEGER) ASC";
      when(() => mockDb.selectFromTable(tableName, autoSyncQuery))
          .thenReturn(ResultSet(
          ["RequestType","ProjectId","FormId","MsgId","UpdatedDateInMS"],
          null,
          [
            ["1","1111","2222","3333","4444"],
            ["2","1111","2222","3333","4444"],
            ["3","1111","2222","3333","4444"],
            ["4","1111","2222","3333","4444"]
          ]
      ));

      when(() => mockFactory.getFormSyncTask(siteSyncRequestTask, executor.syncCallback))
          .thenReturn(mockFormSyncTask);
      when(() => mockFactory.getForStatusChangeSyncTask(siteSyncRequestTask, executor.syncCallback))
          .thenReturn(mockFormStatusChangeSyncTask);
      when(() => mockFactory.getFormDistributeActionSyncTask(siteSyncRequestTask, executor.syncCallback))
          .thenReturn(mockFormDistributionSyncTask);
      when(() => mockFactory.getFormOtherActionSyncTask(siteSyncRequestTask, executor.syncCallback))
          .thenReturn(mockFormOherActionSyncTask);

      when(() => mockFormSyncTask.syncFormDataToServer(any(), any()))
          .thenAnswer((_) => Future.delayed(Duration(milliseconds: 400)));
      when(() => mockFormStatusChangeSyncTask.formStatusChangeTask(any()))
          .thenAnswer((_) => Future.delayed(Duration(milliseconds: 100)));
      when(() => mockFormDistributionSyncTask.formDistributionActionTask(any()))
          .thenAnswer((_) => Future.delayed(Duration(milliseconds: 200)));
      when(() => mockFormOherActionSyncTask.formOtherActionTask(any()))
          .thenAnswer((_) => Future.delayed(Duration(milliseconds: 100)));
      await executor.execute((eSyncType, eSyncStatus, data) {
        if (eSyncStatus!=ESyncStatus.inProgress) {
          c.complete(null);
        }
      }, receivePort.sendPort);
      receivePort.listen((message) {
        print(message);
      });
      await c.future;
      expect(taskPool.pendingTaskSize, 0);
      verify (()=> mockDb.selectFromTable(tableName, autoSyncQuery)).called(1);
      verify (()=> mockFactory.getFormSyncTask(siteSyncRequestTask, executor.syncCallback)).called(1);
      verify (()=> mockFactory.getForStatusChangeSyncTask(siteSyncRequestTask, executor.syncCallback)).called(1);
      verify (()=> mockFactory.getFormDistributeActionSyncTask(siteSyncRequestTask, executor.syncCallback)).called(1);
      verify (()=> mockFactory.getFormOtherActionSyncTask(siteSyncRequestTask, executor.syncCallback)).called(1);
      verify (()=> mockFormSyncTask.syncFormDataToServer(any(), any())).called(1);
      verify (()=> mockFormStatusChangeSyncTask.formStatusChangeTask(any())).called(1);
      verify (()=> mockFormDistributionSyncTask.formDistributionActionTask(any())).called(1);
      verify (()=> mockFormOherActionSyncTask.formOtherActionTask(any())).called(1);
    });
  });
}