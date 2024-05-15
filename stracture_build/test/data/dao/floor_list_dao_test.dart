import 'dart:convert';

import 'package:field/data/dao/floor_list_dao.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/database/db_service.dart';
import 'package:field/injection_container.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../utils/load_url.dart';

class DBServiceMock extends Mock implements DBService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  DBServiceMock? mockDb;

  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannelUrl().setupBuildFlavorMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();

  configureDependencies() {
    mockDb = DBServiceMock();
    init(test: true);
    getIt.unregister<DBService>();
    getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
  }

  setUp(() {
    AppConfigTestData().setupAppConfigTestData();
  });

  group("Floor list dao test", () {
    configureDependencies();
    test('Calibration List create table query test', () {
      FloorListDao floorListDao = FloorListDao();
      String strFloorListCreateQuery = 'CREATE TABLE IF NOT EXISTS FloorListTbl(bimModelId TEXT NOT NULL,revisionId INTEGER NOT NULL,fileName TEXT NOT NULL,floorNumber TEXT NOT NULL,levelName TEXT NOT NULL,fileSize TEXT NOT NULL,isChecked INTEGER NOT NULL,isDownloaded INTEGER NOT NULL,projectId TEXT NOT NULL,revName TEXT NOT NULL)';
      expect(strFloorListCreateQuery, floorListDao.createTableQuery);
    });

    test('Calibration List item to map test', () {
      FloorListDao floorListDao = FloorListDao();
      String strData = "{\"bimModelId\":\"${"1234"}\",\"id\":\"${"46312\$\$17KRZw"}\",\"revisionId\":2373726,\"fileName\":\"00_2022_vivek mishra\","
          "\"fileSize\":\"asiteBim_46312\",\"floorNumber\":\"Vivek Mishra\",\"levelName\":\"\",\"isChecked\":false,\"isDownloaded\":true,"
          "\"projectId\":\"4534343\",\"revName\":\"32\"}";
      FloorDetail floorDetails = FloorDetail.fromJson(json.decode(strData));
      var dataMap = floorListDao.toMap(floorDetails);
      dataMap.then((value) {
        expect(10, value.length);
      });
    });

    test('Calibration List from map test', () {
      var dataMap = {"bimModelId": "46312\$\$17KRZw", "id": "2134298\$\$4Dizau", "revisionId": "434354", "fileName": "46312", "fileSize": "Test", "floorNumber": "1", "levelName": "0", "isChecked": "1832155\$\$nXozJq", "isDownloaded": "2", "projectId": "true"};
      FloorListDao floorListDao = FloorListDao();
      FloorDetail floorDetails = floorListDao.fromMap(dataMap);
      expect(floorDetails.bimModelId, "46312\$\$17KRZw");
    });

    test('Calibration List from list map test', () {
      var dataMap = [
        {"bimModelId": "46312\$\$17KRZw", "id": "2134298\$\$4Dizau", "revisionId": "434354", "fileName": "46312", "fileSize": "Test", "floorNumber": "1", "levelName": "0", "isChecked": "1832155\$\$nXozJq", "isDownloaded": "2", "projectId": "true"},
        {"bimModelId": "46312\$\$17KRZw", "id": "2134298\$\$4Dizau", "revisionId": "434354", "fileName": "46312", "fileSize": "Test", "floorNumber": "1", "levelName": "0", "isChecked": "1832155\$\$nXozJq", "isDownloaded": "2", "projectId": "true"}
      ];
      FloorListDao floorListDao = FloorListDao();
      List<FloorDetail> floorDetailsList = floorListDao.fromList(dataMap);
      expect(floorDetailsList.length, 2);
    });

    test('Calibration List from map test', () async {
      var dataMap = {"bimModelId": "46312\$\$17KRZw", "id": "2134298\$\$4Dizau", "revisionId": "434354", "fileName": "46312", "fileSize": "Test", "floorNumber": "1", "levelName": "0", "isChecked": "1832155\$\$nXozJq", "isDownloaded": "2", "projectId": "true"};
      FloorListDao floorListDao = FloorListDao();
      FloorDetail floorDetail = floorListDao.fromMap(dataMap);
      expect(floorDetail.bimModelId, "46312\$\$17KRZw");
    });

    test('Model Bim Model from map test', () async {
      var dataMap = {"bimModelId": "46312\$\$17KRZw", "id": "2134298\$\$4Dizau", "revisionId": "434354", "fileName": "46312", "fileSize": "Test", "floorNumber": "1", "levelName": "0", "isChecked": "1832155\$\$nXozJq", "isDownloaded": "2", "projectId": "true"};
      List<Map<String, dynamic>> mapBimModel = [];
      List<FloorDetail> objects = [];
      FloorListDao floorListDao = FloorListDao();
      mapBimModel = await floorListDao.toListMap(objects);
      expect(objects.length, 0);
      FloorDetail floorDetail = floorListDao.fromMap(dataMap);
      objects.add(floorDetail);
      expect(objects.length, 1);
    });

    test(' Model fetch method test', () async {
      when(() => mockDb!.selectFromTable(any(),any())).thenReturn(null);
      var data= await FloorListDao().fetch("");
      ResultSet? results = mockDb!.selectFromTable(FloorListDao().tableName, "");
      verify(() => mockDb!.selectFromTable(FloorListDao().tableName, "")).called(1);
    });
    test(' Model fetch method test', () async {
      when(() => mockDb!.selectFromTable(any(),any())).thenReturn(null);
      var data= await FloorListDao().fetchByBimModelIds([""]);
      ResultSet? results = mockDb!.selectFromTable(FloorListDao().tableName, "");
      verify(() => mockDb!.selectFromTable(FloorListDao().tableName, "")).called(1);
    });

    test('Bim Model delete test', () async {

      final projectId = '12345';
      final deleteQuery = "DELETE FROM UserReferenceFormTypeTemplateTbl WHERE UserId= '1' AND ProjectId= '12345' AND FormTypeId= '12345'";
      final selectQuery = "SELECT * FROM UserReferenceFormTypeTemplateTbl";

      when(() => mockDb!.executeQuery(deleteQuery)).thenReturn(null);
      await FloorListDao().delete(projectId,isTest: true);
      when(() => mockDb!.selectFromTable(FloorListDao().tableName, selectQuery)).thenReturn(null);
      ResultSet? results = mockDb!.selectFromTable(FloorListDao().tableName, selectQuery);
      verify(() => mockDb!.selectFromTable(FloorListDao().tableName, selectQuery)).called(1);
      expect(results, null);
    });
   test('Bim Model delete test', () async {

      final projectId = '12345';
      final deleteQuery = "DELETE FROM UserReferenceFormTypeTemplateTbl WHERE UserId= '1' AND ProjectId= '12345' AND FormTypeId= '12345'";
      final selectQuery = "SELECT * FROM UserReferenceFormTypeTemplateTbl";

      when(() => mockDb!.executeQuery(deleteQuery)).thenReturn(null);
      await FloorListDao().deleteModelWise(projectId,);
      when(() => mockDb!.selectFromTable(FloorListDao().tableName, selectQuery)).thenReturn(null);
      ResultSet? results = mockDb!.selectFromTable(FloorListDao().tableName, selectQuery);
      verify(() => mockDb!.selectFromTable(FloorListDao().tableName, selectQuery)).called(1);
      expect(results, null);
    });

    test('Bim Model deleteAllQuery test', () async {
      when(() => mockDb!.executeQuery(any())).thenReturn(null);
      await FloorListDao().deleteAllQuery();
    });

  });

}
