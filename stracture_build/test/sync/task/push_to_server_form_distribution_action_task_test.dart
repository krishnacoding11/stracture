
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/site/create_form_use_case.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/task/push_to_server_form_distribution_action_task.dart';
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

  group("PushToServerFormDistributionActionTask Test", () {
    test('formDistributionActionTask test', () async {
      SyncRequestTask syncTask = SyncRequestTask();
      var paramData = {
        "RequestType": EOfflineSyncRequestType.DistributeAction.value.toString(),
        "ProjectId": "2130192",
        "FormId": "11607175",
        "MsgId": "12309325",
        "UpdatedDateInMS": "1689766227351",
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
        6,
        0,
        "{\"action_id\":19,\"projectId\":\"2130192\",\"dist_list\":\"{\\\"nonReviewDraftDistGroupUsers\\\":[],\\\"reviewDraftDistGroupUsers\\\":[],\\\"selectedDistGroups\\\":\\\"\\\",\\\"selectedDistUsers\\\":[{\\\"email\\\":false,\\\"hUserID\\\":\\\"707447\\\",\\\"fname\\\":\\\"Vijay\\\",\\\"lname\\\":\\\"Mavadiya (5336)\\\",\\\"user_type\\\":1,\\\"hActionID\\\":\\\"6\\\",\\\"actionDueDate\\\":\\\"28-Jul-2023 17:0:18\\\"}],\\\"selectedDistOrgs\\\":[],\\\"selectedDistRoles\\\":[],\\\"subject\\\":\\\"test\\\"}\",\"save_draft\":false,\"folderId\":\"0\",\"msg_num\":\"001\",\"msg_type\":\"ORI\",\"rmft\":\"11104955\",\"msg_type_code\":\"ORI\",\"msgId\":\"12309325\",\"formId\":\"11607175\",\"commitType\":2,\"originatorId\":2017529,\"parent_msg_id\":\"0\",\"statusId\":2,\"noAccessUsers\":\"\",\"actionId\":\"6\"}",
        1689766227351,
      ]
      ];

      ResultSet resultSet = ResultSet(columnList, null, rows);
      String query = "SELECT IFNULL(frmTbl.AppTypeId,'') AS AppTypeId, IFNULL(frmTbl.LocationId,'') AS LocationId, IFNULL(frmTbl.ObservationId,'') AS ObservationId,IFNULL(frmTbl.TemplateType,'') AS TemplateType,offlineActivityTbl.* FROM OfflineActivityTbl offlineActivityTbl\n"
          "LEFT JOIN FormListTbl frmTbl ON OfflineActivityTbl.FormId=frmTbl.FormId\n"
          "WHERE offlineActivityTbl.ProjectId=2130192 AND offlineActivityTbl.FormId=11607175  AND offlineActivityTbl.MsgId=12309325 AND offlineActivityTbl.CreatedDateInMs=1689766227351";
      String tableName = "FormMessageListTbl";
      when(() => mockDb!.selectFromTable(tableName, query))
          .thenReturn(resultSet);
      //final postData = {"action_id":19,"projectId":"2130192","dist_list":"{\"nonReviewDraftDistGroupUsers\":[],\"reviewDraftDistGroupUsers\":[],\"selectedDistGroups\":\"\",\"selectedDistUsers\":[{\"email\":false,\"hUserID\":\"707447\",\"fname\":\"Vijay\",\"lname\":\"Mavadiya (5336)\",\"user_type\":1,\"hActionID\":\"6\",\"actionDueDate\":\"28-Jul-2023 17:0:18\"}],\"selectedDistOrgs\":[],\"selectedDistRoles\":[],\"subject\":\"test\"}","save_draft":false,"folderId":"0","msg_num":"001","msg_type":"ORI","rmft":"11104955","msg_type_code":"ORI","msgId":"12309325","formId":"11607175","commitType":2,"originatorId":2017529,"parent_msg_id":"0","statusId":2,"noAccessUsers":"","actionId":"6","appTypeId":2,"formTypeId":11104955,"form_type_id":11104955,"form_template_type":2,"locationId":183764,"observationId":107239,"projectIds":"1111","checkHashing":"false","CreateDateInMS":"1234567890123","offlineMessageId":"3333","isFromAndroidApp":true,"offlineFormCreatedDateInMS":"1234567890123"};
      when(() => mockUseCase!.formDistActionTaskToServer(any()))
          .thenAnswer((_) => Future.value(SUCCESS("", null, 200)));
      String removeQuery = "DELETE FROM OfflineActivityTbl\n"
          "WHERE ProjectId=2130192 AND FormId=11607175\n"
          "AND MsgId=12309325 AND actionId=6 AND CreatedDateInMs=1689766227351";
      when(() => mockDb!.executeQuery(removeQuery))
          .thenReturn(null);
      await PushToServerFormDistributionActionTask(syncTask, (eSyncTaskType, eSyncStatus, data) async {},).formDistributionActionTask(paramData);
      verify(() => mockDb!.selectFromTable(tableName, query)).called(1);
      verify(() => mockUseCase!.formDistActionTaskToServer(any())).called(1);
      verify(() => mockDb!.executeQuery(removeQuery)).called(1);
    });
  });
}