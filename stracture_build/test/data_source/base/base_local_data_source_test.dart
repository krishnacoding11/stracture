import 'package:field/data/dao/sync/site/site_sync_status_project_dao.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/sync/calculation/site_sync_status_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';
import '../../sync/calculation/site_sync_status_local_data_source_test.dart';


void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppConfigTestData().setupAppConfigTestData();
  SharedPreferences.setMockInitialValues({
    "userData": fixture("user_data.json"),
  });

  MockDatabaseManager mockDatabaseManager = MockDatabaseManager();
  SiteSyncStatusLocalDataSource siteSyncStatusLocalDataSource = SiteSyncStatusLocalDataSource();
  siteSyncStatusLocalDataSource.databaseManager = mockDatabaseManager;

  group("BaseLocalDataSource Test", () {

    test("Create Table Test", () async {
      siteSyncStatusLocalDataSource.createTables([SiteSyncStatusProjectDao()]);
    });

    test("Remove Table Test", () async {
      siteSyncStatusLocalDataSource.removeTables([SiteSyncStatusProjectDao()]);
    });

    test("Get user data from storage Test", () async {
      var userId = await siteSyncStatusLocalDataSource.currentUserId;
      expect(userId, '808581');

      var user = await siteSyncStatusLocalDataSource.user;
      expect(user, isA<User>());
    });

  });
}