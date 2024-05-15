import 'dart:async';

import 'package:field/data/model/custom_attribute_set_vo.dart';
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/domain/use_cases/formtype/formtype_use_case.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/formtype_attribute_set_details_sync_task.dart';
import 'package:field/database/db_service.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/injection_container.dart' as di;
import 'package:sqlite3/common.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';

class MockFormTypeUseCase extends Mock implements FormTypeUseCase {}

class DBServiceMock extends Mock implements DBService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  AConstants.adoddleUrl = 'https://adoddleqaak.asite.com/';
  di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  MockFormTypeUseCase? mockFormTypeUseCase;
  DBServiceMock? mockDb;

  configureDependencies() async {
    MockMethodChannel().setConnectivity();
    mockFormTypeUseCase = MockFormTypeUseCase();
    mockDb = DBServiceMock();
    di.getIt.unregister<FormTypeUseCase>();
    di.getIt.unregister<DBService>();
    di.getIt.registerLazySingleton<FormTypeUseCase>(() => mockFormTypeUseCase!);
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
  }

  setUp(() {
    configureDependencies();
  });

  tearDown(() {
    mockFormTypeUseCase = null;
  });



  group("FormTypeAttributeSetDetailSyncTask Test", () {
    test("FormTypeAttributeSetDetailSyncTask  Sync Success", () async {
      var taskNumber = -9007199254740991;
      var createQuery = "CREATE TABLE IF NOT EXISTS AttributeSetDetailTbl(ProjectId TEXT NOT NULL,AttributeSetId TEXT NOT NULL,jsonResponse TEXT NOT NULL,PRIMARY KEY(ProjectId))";
      var tableName = "AttributeSetDetailTbl";
      List<String> primaryKeysList = ["ProjectId"];
      var selectQuery = "SELECT ProjectId FROM AttributeSetDetailTbl WHERE ProjectId='2130192'";
      List<String> columnNames = ["ProjectId", "AttributeSetId", "jsonResponse"];
      List<List<Object?>> rows = [];
      var sqlQuery = "INSERT INTO AttributeSetDetailTbl (ProjectId,AttributeSetId,jsonResponse) VALUES (?,?,?)";
      List<List<dynamic>> insertValues = [
        [2130192, 118281,'[{"childAttributeName":"City","parentAttributeName":"State","parentChildRelation":{"Gujarat":"Ahmadabad#Bhuj#Rajkot","Ladakh":"Kargil#Leh","Maharashtra":"Mumbai#Nagpur"}}]']];
      ResultSet resultSet = ResultSet(columnNames, null, rows);
      Completer comp = Completer();
      SyncRequestTask siteSyncTask = SyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2130192\$\$5L4WMm"
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.project
        ..projectSizeInByte = "105758801";

      TaskPool taskPool = TaskPool(3);
      when(() => mockFormTypeUseCase!.getFormTypeAttributeSetDetail(projectId: "2130192\$\$5L4WMm",  networkExecutionType: NetworkExecutionType.SYNC, taskNumber: taskNumber, attributeSetId: '118281', callingArea: "form"))
          .thenAnswer((_) async {
        return SUCCESS(CustomAttributeSetVo.getCustomAttributeVOList(fixture("formType_attributeSet.json")), null, 200);
      });

      when(() => mockDb!.executeQuery(createQuery)).thenReturn(null);
      when(() => mockDb!.getPrimaryKeys(tableName)).thenReturn(primaryKeysList);
      when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(resultSet);
      when(() => mockDb!.executeBulk(tableName, sqlQuery, insertValues)).thenAnswer((_) async=> null);

      taskPool.execute((task) async {
        await FormTypeAttributeSetDetailSyncTask(
          siteSyncTask,
              (eSyncTaskType, eSyncStatus, data) async {},
        ).getFormTypeAttributeSetDetail(projectId: "2130192\$\$5L4WMm", task: task, attributeSetId: '118281', callingArea: "form");
        comp.complete();
      });

      await comp.future;
      verify(() => mockFormTypeUseCase!.getFormTypeAttributeSetDetail(projectId: "2130192\$\$5L4WMm",  networkExecutionType: NetworkExecutionType.SYNC, taskNumber: taskNumber, attributeSetId: '118281', callingArea: "form")).called(1);

    });


    test("FormTypeAttributeSetDetailSyncTask Sync Fail", () async {
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
      when(() => mockFormTypeUseCase!.getFormTypeAttributeSetDetail(projectId: "2130192\$\$6euyPl", networkExecutionType: NetworkExecutionType.SYNC, taskNumber: taskNumber,attributeSetId: '117881', callingArea: "abc")).thenAnswer((_) async {
        return FAIL("", 404);
      });
      taskPool.execute((task) async {
        await FormTypeAttributeSetDetailSyncTask(
          siteSyncTask,
              (eSyncTaskType, eSyncStatus, data) async {},
        ).getFormTypeAttributeSetDetail(projectId: "2130192\$\$6euyPl",  task: task,attributeSetId: '117881', callingArea: "abc");
        comp.complete();
      });
      await comp.future;
      verify(() => mockFormTypeUseCase!.getFormTypeAttributeSetDetail(projectId: "2130192\$\$6euyPl", networkExecutionType: NetworkExecutionType.SYNC, taskNumber: taskNumber,attributeSetId: '117881', callingArea: "abc")).called(1);
    });


  });
}
