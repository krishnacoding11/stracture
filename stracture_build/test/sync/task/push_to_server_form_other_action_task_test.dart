
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/site/create_form_use_case.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/task/push_to_server_form_other_action_task.dart';
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

  group("PushToServerFormOherActionTask Test", () {
    test('formOtherActionTask test', () async {
      SyncRequestTask syncTask = SyncRequestTask();
      var paramData = {
        "RequestType": EOfflineSyncRequestType.OtherAction.value.toString(),
        "ProjectId": "2130192",
        "FormId": "11607175",
        "MsgId": "12309325",
        "UpdatedDateInMS": "1689857194900",
      };
      final columnList = [
        "AppTypeId",
        "LocationId",
        "ObservationId",
        "TemplateType",
        "ProjectId",
        "FormTypeId",
        "FormId",
        "MsgId",
        "actionId",
        "DistListId",
        "OfflineRequestData",
        "CreatedDateInMs",
      ];
      final rows = [[
        2,
        183764,
        107239,
        2,
        2130192,
        11104955,
        11607175,
        12309325,
        36,
        0,
        "{\"action_id\":21,\"orig_user_id\":2017529,\"msg_type\":\"ORI\",\"msg_num\":\"001\",\"projectId\":\"2130192\",\"formId\":\"11607175\",\"ori_msg_id\":\"12309325\",\"form_template_type\":2,\"form_type_id\":\"11104955\",\"isUser\":true,\"isFormDetailRequired\":true,\"isStatusChanged\":true,\"comingFrom\":\"FORM\",\"msgId\":\"12309325\",\"actionId\":36,\"form_remarks\":\"Test action\"}",
        1689857194900,
      ]
      ];

      ResultSet resultSet = ResultSet(columnList, null, rows);
      String query = "SELECT IFNULL(frmTbl.AppTypeId,'') AS AppTypeId, IFNULL(frmTbl.LocationId,'') AS LocationId, IFNULL(frmTbl.ObservationId,'') AS ObservationId,IFNULL(frmTbl.TemplateType,'') AS TemplateType,offlineActivityTbl.* FROM OfflineActivityTbl offlineActivityTbl\n"
        "LEFT JOIN FormListTbl frmTbl ON OfflineActivityTbl.FormId=frmTbl.FormId\n"
        "WHERE offlineActivityTbl.ProjectId=2130192 AND offlineActivityTbl.FormId=11607175  AND offlineActivityTbl.MsgId=12309325 AND offlineActivityTbl.CreatedDateInMs=1689857194900";
      String tableName = "FormMessageListTbl";
      when(() => mockDb!.selectFromTable(tableName, query))
          .thenReturn(resultSet);
      when(() => mockUseCase!.formOtherActionTaskToServer(any()))
          .thenAnswer((_) => Future.value(SUCCESS("", null, 200)));
      String removeQuery = "DELETE FROM OfflineActivityTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607175\n"
          "AND MsgId=12309325 AND actionId=36";
      when(() => mockDb!.executeQuery(removeQuery))
          .thenReturn(null);
      await PushToServerFormOherActionTask(syncTask, (eSyncTaskType, eSyncStatus, data) async {},).formOtherActionTask(paramData);
      verify(() => mockDb!.selectFromTable(tableName, query)).called(1);
      verify(() => mockUseCase!.formOtherActionTaskToServer(any())).called(1);
      verify(() => mockDb!.executeQuery(removeQuery)).called(1);
    });
  });
}