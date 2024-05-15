import 'dart:async';

import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/domain/use_cases/formtype/formtype_use_case.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/pool/task_pool.dart';
import 'package:field/sync/task/formtype_controller_user_list_sync_task.dart';
import 'package:field/utils/field_enums.dart';
import 'package:field/utils/file_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/injection_container.dart' as di;

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';

class MockFormTypeUseCase extends Mock implements FormTypeUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  MockFormTypeUseCase? mockFormTypeUseCase;

  configureDependencies() async {
    mockFormTypeUseCase = MockFormTypeUseCase();
    di.getIt.unregister<FormTypeUseCase>();
    di.getIt.unregister<FileUtility>();
    di.getIt.registerLazySingleton<FormTypeUseCase>(() => mockFormTypeUseCase!);
  }

  setUpAll(() {
    configureDependencies();
  });

  tearDown(() {
    reset(mockFormTypeUseCase);
  });

  tearDownAll(() {
    mockFormTypeUseCase = null;
  });

  group("FormTypeControllerUserListSyncTask Test", () {
    test("FormTypeControllerUserListSyncTask Success", () async {
      var taskNumber = -9007199254740991;
      Completer comp = Completer();
      SiteSyncRequestTask siteSyncTask = SiteSyncRequestTask()
        ..syncRequestId = DateTime.now().millisecondsSinceEpoch
        ..projectId = "2130192\$\$MqjZY3"
        ..projectName = "Site Quality Demo"
        ..isMarkOffline = true
        ..isMediaSyncEnable = true
        ..eSyncType = ESyncType.project
        ..projectSizeInByte = "105758801";

      TaskPool taskPool = TaskPool(3);
      when(() => mockFormTypeUseCase!.getFormTypeControllerUserList(projectId: "2130192\$\$MqjZY3", formTypeId: "11076066\$\$8TW5W0", networkExecutionType: NetworkExecutionType.SYNC, taskNumber: taskNumber)).thenAnswer((_) async {
        return SUCCESS(fixture("formType_userController.json"), null, 200);
      });

      taskPool.execute((task) async {
        await FormTypeControllerUserListSyncTask(
          siteSyncTask,
              (eSyncTaskType, eSyncStatus, data) async {},
        ).getFormTypeControllerUserList(projectId: "2130192\$\$MqjZY3", formTypeId: "11076066\$\$8TW5W0", task: task);
        comp.complete();
      });
      await comp.future;
      verify(() => mockFormTypeUseCase!.getFormTypeControllerUserList(projectId: "2130192\$\$MqjZY3", formTypeId: "11076066\$\$8TW5W0", networkExecutionType: NetworkExecutionType.SYNC, taskNumber: taskNumber)).called(1);

    });


    test("FormTypeControllerUserListSyncTask Sync Fail", () async {
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
      when(() => mockFormTypeUseCase!.getFormTypeControllerUserList(projectId: "2130192\$\$6euyPl", formTypeId: "11070450\$\$qQ6uNw", networkExecutionType: NetworkExecutionType.SYNC, taskNumber: taskNumber)).thenAnswer((_) async {
        return FAIL("", 404);
      });
      taskPool.execute((task) async {
        await FormTypeControllerUserListSyncTask(
          siteSyncTask,
              (eSyncTaskType, eSyncStatus, data) async {},
        ).getFormTypeControllerUserList(projectId: "2130192\$\$6euyPl", formTypeId: "11070450\$\$qQ6uNw", task: task);
        comp.complete();
      });
      await comp.future;
      verify(() => mockFormTypeUseCase!.getFormTypeControllerUserList(projectId: "2130192\$\$6euyPl", formTypeId: "11070450\$\$qQ6uNw", networkExecutionType: NetworkExecutionType.SYNC, taskNumber: taskNumber)).called(1);
    });
  });
}
