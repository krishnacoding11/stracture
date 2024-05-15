
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/task/filter_sync_task.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/offline_injection_container.dart' as di;
import 'package:mocktail/mocktail.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';

class FilterUseCaseMock extends Mock implements FilterUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  FilterUseCaseMock? mockUseCase;
  di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  configureDependencies() {
    mockUseCase = FilterUseCaseMock();
    di.getIt.unregister<FilterUseCase>();
    di.getIt.registerLazySingleton<FilterUseCase>(() => mockUseCase!);
  }
  setUp(() {
    configureDependencies();
  });

  tearDown(() {
    mockUseCase = null;
  });

  group("FilterSyncTask Test", () {
    test('getAttributeList test', () async {
      SyncRequestTask syncTask = SyncRequestTask();

      //final postData = {"action_id":19,"projectId":"2130192","dist_list":"{\"nonReviewDraftDistGroupUsers\":[],\"reviewDraftDistGroupUsers\":[],\"selectedDistGroups\":\"\",\"selectedDistUsers\":[{\"email\":false,\"hUserID\":\"707447\",\"fname\":\"Vijay\",\"lname\":\"Mavadiya (5336)\",\"user_type\":1,\"hActionID\":\"6\",\"actionDueDate\":\"28-Jul-2023 17:0:18\"}],\"selectedDistOrgs\":[],\"selectedDistRoles\":[],\"subject\":\"test\"}","save_draft":false,"folderId":"0","msg_num":"001","msg_type":"ORI","rmft":"11104955","msg_type_code":"ORI","msgId":"12309325","formId":"11607175","commitType":2,"originatorId":2017529,"parent_msg_id":"0","statusId":2,"noAccessUsers":"","actionId":"6","appTypeId":2,"formTypeId":11104955,"form_type_id":11104955,"form_template_type":2,"locationId":183764,"observationId":107239,"projectIds":"1111","checkHashing":"false","CreateDateInMS":"1234567890123","offlineMessageId":"3333","isFromAndroidApp":true,"offlineFormCreatedDateInMS":"1234567890123"};
      when(() => mockUseCase!.getFilterDataForDefectSync(any()))
          .thenAnswer((_) => Future.value(SUCCESS("{\"testData\":\"filterData\"}", null, 200)));
      FilterSyncTask filterTask = FilterSyncTask(syncTask, (eSyncTaskTypeTmp, eSyncStatusTmp, data) async {
        // outputData = data;
        // eSyncTaskType = eSyncTaskTypeTmp;
        // eSyncStatus = eSyncStatusTmp;
      },);
      filterTask.getAttributeList(projectId: "2130192", appTypeId: "2");
      verify(() => mockUseCase!.getFilterDataForDefectSync(any())).called(1);
      //expect(ESyncStatus.success, eSyncStatus);
    });
  });
}