
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/site/create_form_use_case.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/task/push_to_server_form_status_change_task.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/offline_injection_container.dart' as di;
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/common.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';

class DBServiceMock extends Mock implements DBService {}

class CreateFormUseCaseMock extends Mock implements CreateFormUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  DBServiceMock? mockDb;
  CreateFormUseCaseMock? mockUseCase;
  di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  configureDependencies() {
    mockDb = DBServiceMock();
    mockUseCase = CreateFormUseCaseMock();
    di.getIt.unregister<DBService>();
    di.getIt.unregister<CreateFormUseCase>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
    di.getIt.registerLazySingleton<CreateFormUseCase>(() => mockUseCase!);
  }
  setUp(() {
    configureDependencies();
  });

  tearDown(() {
    mockDb = null;
    mockUseCase = null;
  });

  group("PushToServerFormStatusChangeTask Test", () {
    test('formStatusChangeTask test', () async {
      SyncRequestTask syncTask = SyncRequestTask();
      var paramData = {
        "RequestType": EOfflineSyncRequestType.StatusChange.value.toString(),
        "ProjectId": "2130192",
        "FormId": "11607175",
        "MsgId": "",
        "UpdatedDateInMS": "1689915831090",
      };
      final columnList = [
        "AppTypeId",
        "LocationId",
        "ObservationId",
        "OfflineRequestData",
      ];
      final rows = [[
        2,
        183764,
        107239,
        "{\"action_id\":572,\"formNum\":\"121\",\"formTypeId\":\"11104955\",\"newStatusReason\":\"test status change\",\"projectId\":\"2130192\",\"selectedFormId\":11607175,\"statusName\":\"Resolved\",\"statusId\":1002,\"formId\":\"11607175\"}",
      ]
      ];

      ResultSet resultSet = ResultSet(columnList, null, rows);
      String query = "SELECT frmTbl.AppTypeId,frmTbl.LocationId,frmTbl.ObservationId,frmHstrTbl.JsonData AS OfflineRequestData FROM FormStatusHistoryTbl frmHstrTbl\n"
          "INNER JOIN FormListTbl frmTbl ON frmTbl.ProjectId=frmHstrTbl.ProjectId AND frmTbl.FormId=frmHstrTbl.FormId\n"
          "WHERE frmHstrTbl.ProjectId=2130192 AND frmHstrTbl.FormId=11607175 AND frmHstrTbl.CreateDateInMS=1689915831090";
      String tableName = "FormMessageListTbl";
      when(() => mockDb!.selectFromTable(tableName, query))
          .thenReturn(resultSet);
      when(() => mockUseCase!.formStatusChangeTaskToServer(any()))
          .thenAnswer((_) => Future.value(SUCCESS("", null, 200)));
      String removeQuery = "UPDATE FormStatusHistoryTbl SET JsonData=''\n"
          "WHERE ProjectId=2130192 AND FormId=11607175 AND CreateDateInMS=1689915831090";
      when(() => mockDb!.executeQuery(removeQuery))
          .thenReturn(null);
      await PushToServerFormStatusChangeTask(syncTask, (eSyncTaskType, eSyncStatus, data) async {},).formStatusChangeTask(paramData);
      verify(() => mockDb!.selectFromTable(tableName, query)).called(1);
      verify(() => mockUseCase!.formStatusChangeTaskToServer(any())).called(1);
      verify(() => mockDb!.executeQuery(removeQuery)).called(1);
    });
  });
}