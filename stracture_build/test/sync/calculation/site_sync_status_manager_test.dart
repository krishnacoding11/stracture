import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/database/db_service.dart';
import 'package:field/sync/calculation/site_sync_status_manager.dart';
import 'package:field/utils/field_enums.dart';
import 'package:field/utils/file_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';

class MockDatabaseManager extends Mock implements DatabaseManager {}

class MockFileUtility extends Mock implements FileUtility {}

class DBServiceMock extends Mock implements DBService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SiteSyncStatusManager? _siteSyncStatusManager;
  SiteSyncRequestTask siteSyncRequestTask;

  MockFileUtility mockFileUtility = MockFileUtility();
  FileUtility fileUtility = FileUtility();
  //DBServiceMock? mockDb;
  DBService? dbService;
  configMockResponse() async {}

  setUpAll(() async {
    MockMethodChannel().setNotificationMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    dbService = DBServiceMock();
    await di.init(test: true);
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AppConfigTestData().setupAppConfigTestData();
    MockMethodChannel().setAsitePluginsMethodChannel();
    di.getIt.unregister<DBService>();
    di.getIt.unregister<FileUtility>();
    di.getIt.registerLazySingleton<FileUtility>(() => fileUtility);
    di.getIt.registerFactoryParam<DBService, String, void>(
            (filePath, _) => dbService!);
    //di.getIt.registerFactoryParam<DBService,String,void>((filePath,_) => DBService(filePath));
    SharedPreferences.setMockInitialValues({
      "userData": fixture("user_data.json"),
      "cloud_type_data": "1",
      "1_u1_project_": fixture("project.json")
    });
    configMockResponse();
  });
  tearDown(() {
    reset(mockFileUtility);
    reset(dbService);
  });
  tearDownAll(() {
    dbService = null;
  });

  group("SiteSyncStatusManager test case", () {
    test("init", () async {
      Map<String, dynamic> resultMap = {};
      if (_siteSyncStatusManager == null) {
        _siteSyncStatusManager = await SiteSyncStatusManager.getInstance();
        await _siteSyncStatusManager!.init();
      }

      expect(resultMap, isEmpty);
    });

    test("syncStatusResultMap", () async {
      if (_siteSyncStatusManager == null) {
        _siteSyncStatusManager = await SiteSyncStatusManager.getInstance();
        await _siteSyncStatusManager!.init();
      }
      siteSyncRequestTask = SiteSyncRequestTask();
      Map? syncResultMap = _siteSyncStatusManager
          ?.syncStatusResultMap(siteSyncRequestTask);
      expect(syncResultMap!["syncRequest"], siteSyncRequestTask);
    });

    test("syncStatusResultMapDefault", () async {
      if (_siteSyncStatusManager == null) {
        _siteSyncStatusManager = await SiteSyncStatusManager.getInstance();
        await _siteSyncStatusManager!.init();
      }
      siteSyncRequestTask = SiteSyncRequestTask();
      Map? syncResultMap = _siteSyncStatusManager
          ?.syncStatusResultMapDefault(siteSyncRequestTask, [], []);
      expect(syncResultMap!["syncRequest"], siteSyncRequestTask);
    });

    test("removeSyncRequestData", () async {
      Map<String, dynamic> resultMap = {};
      if (_siteSyncStatusManager == null) {
        _siteSyncStatusManager = await SiteSyncStatusManager.getInstance();
        await _siteSyncStatusManager!.init();
      }
      siteSyncRequestTask = SiteSyncRequestTask();
      await _siteSyncStatusManager?.removeSyncRequestData(siteSyncRequestTask);
      expect(resultMap, isEmpty);
    });

    test("syncCallback", () async {
      Map<String, dynamic> resultMap = {};
      if (_siteSyncStatusManager == null) {
        _siteSyncStatusManager = await SiteSyncStatusManager.getInstance();
        await _siteSyncStatusManager!.init();
      }
      siteSyncRequestTask = SiteSyncRequestTask();
      await _siteSyncStatusManager?.syncCallback(ESyncTaskType.formListSyncTask,
          ESyncStatus.success, siteSyncRequestTask, {});
      expect(resultMap, isEmpty);
    });
  });
}