import 'dart:convert';
import 'package:field/injection_container.dart';
import 'package:field/data/dao/floor_bim_model_dao.dart';
import 'package:field/data/model/floor_bim_model_vo.dart';
import 'package:field/database/db_service.dart';
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
  group("Floor bim model test", () {
    configureDependencies();
    test('Floor Bim Model create table query test', () {
      FloorBimModelDao floorBimModelDao = FloorBimModelDao();
      String strBimModelListCreateQuery = 'CREATE TABLE IF NOT EXISTS FloorBimModelListTbl(bimModelId INTEGER NOT NULL,FloorId TEXT NOT NULL)';
      expect(strBimModelListCreateQuery, floorBimModelDao.createTableQuery);
    });

    test('Floor Bim Model item to map test', () {
      FloorBimModelDao floorBimModelDao = FloorBimModelDao();
      String strData = "{\"bimModelId\":\"${"43812\$\$17KRZw"}\",\"FloorId\":\"${"46312\$\$17KRZw"}\"}";
      FloorBimModel floorBimModel = FloorBimModel.fromJson(json.decode(strData));
      var dataMap = floorBimModelDao.toMap(floorBimModel);
      dataMap.then((value) {
        expect(2, value.length);
      });
    });

    test('Floor Bim Model insertion test', () {
      List<FloorBimModel> floorBimModelList = [];
      FloorBimModelDao floorBimModelDao = FloorBimModelDao();
      String strData = "{\"bimModelId\":\"${"43812\$\$17KRZw"}\",\"FloorId\":\"${"46312\$\$17KRZw"}\"}";
      FloorBimModel floorBimModel = FloorBimModel.fromJson(json.decode(strData));
      floorBimModelList.add(floorBimModel);
      var dataMap = floorBimModelDao.toMap(floorBimModel);
      dataMap.then((value) {
        expect(2, value.length);
      });
    });

    test('Floor Bim Model from map test', () {
      var dataMap = {
        "bimModelId": "46542\$\$17KRZw",
        "FloorId": "46312\$\$17KRZw",
      };
      FloorBimModelDao floorBimModelDao = FloorBimModelDao();
      FloorBimModel floorBimModel = floorBimModelDao.fromMap(dataMap);
      expect(floorBimModel.floorId, "46312\$\$17KRZw");
      expect(floorBimModel.bimModelId, "46542\$\$17KRZw");
    });

    test('Floor Bim Model from map test', () async {
      var dataMap = {
        "bimModelId": "46542\$\$17KRZw",
        "FloorId": "46312\$\$17KRZw",
      };
      List<Map<String, dynamic>> mapBimModel = [];
      List<FloorBimModel> objects = [];
      FloorBimModelDao floorBimModelDao = FloorBimModelDao();
      mapBimModel = await floorBimModelDao.toListMap(objects);
      expect(objects.length, 0);
      FloorBimModel floorBimModel = floorBimModelDao.fromMap(dataMap);
      objects.add(floorBimModel);
      expect(objects.length, 1);
    });

    test('Floor Bim Model list from list map test', () {
      var dataMap = [
        {
          "bimModelId": "46542\$\$17KRZw",
          "FloorId": "46312\$\$17KRZw",
        },
        {
          "bimModelId": "46542\$\$17KRZw",
          "FloorId": "46312\$\$17KRZw",
        }
      ];
      FloorBimModelDao floorBimModelDao = FloorBimModelDao();
      List<FloorBimModel> floorBimModelList = floorBimModelDao.fromList(dataMap);
      expect(floorBimModelList.length, 2);
    });

    test('Floor Bim Model from map test', () async {
      var dataMap = {
        "bimModelId": "46542\$\$17KRZw",
        "FloorId": "46312\$\$17KRZw",
      };
      FloorBimModelDao floorBimModelDao = FloorBimModelDao();
      FloorBimModel floorBimModel = floorBimModelDao.fromMap(dataMap);
      expect(floorBimModel.bimModelId, "46542\$\$17KRZw");
    });


    test('Bim Model delete test', () async {

      final projectId = '12345';
      final formTypeId = '12345';
      final deleteQuery = "";
      final selectQuery = "";
      when(() => mockDb!.executeQuery(deleteQuery)).thenReturn(null);
      await FloorBimModelDao().delete(projectId, floorNum: formTypeId);
      when(() => mockDb!.selectFromTable(FloorBimModelDao().tableName, selectQuery)).thenReturn(null);
      ResultSet? results = mockDb!.selectFromTable(FloorBimModelDao().tableName, selectQuery);
      verify(() => mockDb!.selectFromTable(FloorBimModelDao().tableName, selectQuery)).called(1);
      expect(results, null);
    });

    test('Bim Model deleteAllQuery test', () async {
      when(() => mockDb!.executeQuery(any())).thenReturn(null);
      await FloorBimModelDao().deleteAllQuery();
    });

    test('Bim Model fetch method test', () async {
      when(() => mockDb!.selectFromTable(any(),any())).thenReturn(null);
      var data= await FloorBimModelDao().fetch();
      ResultSet? results = mockDb!.selectFromTable(FloorBimModelDao().tableName, "");
      verify(() => mockDb!.selectFromTable(FloorBimModelDao().tableName, "")).called(1);
    });


  });

}
