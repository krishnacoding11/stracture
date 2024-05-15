import 'package:field/data_source/sync_size/sync_size_data_source.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/utils/sharedpreference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';

class MockDatabaseManager extends Mock implements DatabaseManager {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  await di.init(test: true);
  SyncSizeDataSource dbManager = SyncSizeDataSource();
  dbManager.databaseManager = MockDatabaseManager();

  setUp(() {
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json")});
    PreferenceUtils.init();
  });

  group("SyncSizeDataSource Test", () {
    AppConfigTestData().setupAppConfigTestData();


    test("getProjectSyncSizeList fail test", () async {
      when(() => dbManager.databaseManager.executeSelectFromTable(any(), any())).thenThrow(Exception('Fail'));
      var result = await dbManager.getProjectSyncSize({"projectId":"2130192"});
      expect(result.isEmpty, true);
    });

    test("getProjectSyncSizeListList success test", () async {
      String query = "SELECT * FROM SyncSizeTbl WHERE ProjectId=2130192  ORDER BY ProjectId COLLATE NOCASE ASC";
      when(() => dbManager.databaseManager.executeSelectFromTable("SyncSizeTbl", query))
          .thenReturn([{
        "projectId": "2130192",
        "locationId": -1,
        "downloadSizeVo": {
          "pdfAndXfdfSize": 1651716,
          "formTemplateSize": 789029,
          "totalSize": 104762212,
          "countOfLocations": 47,
          "totalFormXmlSize": 4256765,
          "attachmentsSize": 67896652,
          "associationsSize": 30957079,
          "countOfForms": 790
        }
      }]);
      final result = await dbManager.getProjectSyncSize({"projectId":"2130192"});
      expect(result.isNotEmpty, true);
    });

    test("getRequestedLocationSyncSize fail test", () async {
      when(() => dbManager.databaseManager.executeSelectFromTable(any(), any())).thenThrow(Exception('Fail'));
      var result = await dbManager.getRequestedLocationSyncSize({"projectId":"23568", "locationId":["7869","5757"]});
      expect(result.isEmpty,true);
    });

    test("getRequestedLocationSyncSize success test", () async {
      String query = "SELECT * FROM SyncSizeTbl WHERE ProjectId=2116416  AND LocationId IN (12345)";
      when(() => dbManager.databaseManager.executeSelectFromTable("SyncSizeTbl", query))
          .thenReturn([{
        "projectId": "2116416",
        "locationId": 12345,
        "downloadSizeVo": {
          "pdfAndXfdfSize": 293857629,
          "formTemplateSize": 2534298,
          "totalSize": 1585824,
          "countOfLocations": 1004,
          "totalFormXmlSize": 28249291,
          "attachmentsSize": 5871163796,
          "associationsSize": 9664972802,
          "countOfForms": 12
        }
      }]);
      final result = await dbManager.getRequestedLocationSyncSize({"projectId":"2116416", "locationId":["12345"]});
      expect(result.isNotEmpty, true);
    });

    test("deleteProjectSync fail test", () async {
      when(() => dbManager.databaseManager.executeSelectFromTable(any(), any())).thenThrow(Exception('Fail'));
      var result = await dbManager.deleteProjectSync({"projectId":"23568", "locationId":["7869"]});
      expect(result.isEmpty,true);
    });

    test("getRequestedLocationSyncSize success test", () async {
      String query = "DELETE FROM SyncSizeTbl WHERE ProjectId=2116416 AND LocationId=[12345]";
      when(() => dbManager.databaseManager.executeSelectFromTable("SyncSizeTbl", query))
          .thenReturn([{
        "projectId": "2116416",
        "locationId": 12345,
        "downloadSizeVo": {
          "pdfAndXfdfSize": 293857629,
          "formTemplateSize": 2534298,
          "totalSize": 1585824,
          "countOfLocations": 1004,
          "totalFormXmlSize": 28249291,
          "attachmentsSize": 5871163796,
          "associationsSize": 9664972802,
          "countOfForms": 12
        }
      }]);
      final result = await dbManager.deleteProjectSync({"projectId":"2116416", "locationId":["12345"]});
      expect(result.isNotEmpty, true);
    });

    test("update updateSyncSize",() async {
      final result = dbManager.updateSyncSize([]);
      expect(result,isA<Future<void>>());
    });
  });
}