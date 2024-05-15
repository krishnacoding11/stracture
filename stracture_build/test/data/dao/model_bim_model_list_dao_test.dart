import 'dart:convert';

import 'package:field/data/dao/model_bim_models_dao.dart';
import 'package:field/data/model/model_bim_model_vo.dart';
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

  group("model Bim model dao", () {
    configureDependencies();

    test('Model Bim Model create table query test', () {
      ModelBimModelDao bimModelDao = ModelBimModelDao();
      String strBimModelListCreateQuery = 'CREATE TABLE IF NOT EXISTS ModelBimModelListTbl(ModelId INTEGER NOT NULL,BimModelId INTEGER NOT NULL)';
      expect(strBimModelListCreateQuery, bimModelDao.createTableQuery);
    });

    test('Model Bim Model item to map test', () {
      ModelBimModelDao bimModelDao = ModelBimModelDao();
      String strData = "{\"modelId\":\"${"1234"}\",\"bimModelId\":\"${"46312\$\$17KRZw"}\"}";
      ModelBimModel bimModel = ModelBimModel.fromJson(json.decode(strData));
      var dataMap = bimModelDao.toMap(bimModel);
      dataMap.then((value) {
        expect(2, value.length);
      });
    });

    test('Model Bim Model from map test', () {
      var dataMap = {
        "ModelId": "46542\$\$17KRZw",
        "BimModelId": "46312\$\$17KRZw",
      };
      ModelBimModelDao bimModelDao = ModelBimModelDao();
      ModelBimModel modelBimModel = bimModelDao.fromMap(dataMap);
      expect(modelBimModel.bimModelId, "46312\$\$17KRZw");
      expect(modelBimModel.modelId, "46542\$\$17KRZw");
    });

    test('Model Bim Model from map test', () async {
      var dataMap = {
        "ModelId": "46542\$\$17KRZw",
        "BimModelId": "46312\$\$17KRZw",
      };
      List<Map<String, dynamic>> mapBimModel = [];
      List<ModelBimModel> objects = [];
      ModelBimModelDao bimModelDao = ModelBimModelDao();
      mapBimModel = await bimModelDao.toListMap(objects);
      expect(objects.length, 0);
      ModelBimModel modelBimModel = bimModelDao.fromMap(dataMap);
      objects.add(modelBimModel);
      expect(objects.length, 1);
    });

    test('Bim Model list from list map test', () {
      var dataMap = [
        {"ModelId": "46542\$\$17KRZw", "BimModelId": "46312\$\$17KRZw"},
        {"ModelId": "46542\$\$17KRZw", "BimModelId": "46312\$\$17KRZw"}
      ];
      ModelBimModelDao bimModelDao = ModelBimModelDao();
      List<ModelBimModel> bimModelList = bimModelDao.fromList(dataMap);
      expect(bimModelList.length, 2);
    });

    test('Bim Model from map test', () async {
      var dataMap = {"ModelId": "46542\$\$17KRZw", "BimModelId": "46312\$\$17KRZw"};
      ModelBimModelDao bimModelDao = ModelBimModelDao();
      ModelBimModel modelBimModel = bimModelDao.fromMap(dataMap);
      expect(modelBimModel.bimModelId, "46312\$\$17KRZw");
    });

    test('Bim Model delete test', () async {

      final projectId = '12345';
      final deleteQuery = "DELETE FROM UserReferenceFormTypeTemplateTbl WHERE UserId= '1' AND ProjectId= '12345' AND FormTypeId= '12345'";
      final selectQuery = "SELECT * FROM UserReferenceFormTypeTemplateTbl";

      when(() => mockDb!.executeQuery(deleteQuery)).thenReturn(null);
      await ModelBimModelDao().delete(projectId,);
      when(() => mockDb!.selectFromTable(ModelBimModelDao().tableName, selectQuery)).thenReturn(null);
      ResultSet? results = mockDb!.selectFromTable(ModelBimModelDao().tableName, selectQuery);
      verify(() => mockDb!.selectFromTable(ModelBimModelDao().tableName, selectQuery)).called(1);
      expect(results, null);
    });

    test('Bim Model delete test', () async {

      final projectId = '12345';
      final deleteQuery = "DELETE FROM UserReferenceFormTypeTemplateTbl WHERE UserId= '1' AND ProjectId= '12345' AND FormTypeId= '12345'";
      final selectQuery = "SELECT * FROM UserReferenceFormTypeTemplateTbl";

      when(() => mockDb!.executeQuery(deleteQuery)).thenReturn(null);
      await ModelBimModelDao().deleteByRevId(projectId,);
      when(() => mockDb!.selectFromTable(ModelBimModelDao().tableName, selectQuery)).thenReturn(null);
      ResultSet? results = mockDb!.selectFromTable(ModelBimModelDao().tableName, selectQuery);
      verify(() => mockDb!.selectFromTable(ModelBimModelDao().tableName, selectQuery)).called(1);
      expect(results, null);
    });

    test('Bim Model deleteAllQuery test', () async {
      when(() => mockDb!.executeQuery(any())).thenReturn(null);
      await ModelBimModelDao().deleteAllQuery();
    });

    test('Bim Model fetch method test', () async {
      when(() => mockDb!.selectFromTable(any(),any())).thenReturn(null);
      var data= await ModelBimModelDao().fetch();
      ResultSet? results = mockDb!.selectFromTable(ModelBimModelDao().tableName, "");
      verify(() => mockDb!.selectFromTable(ModelBimModelDao().tableName, "")).called(1);
    });

  });
}
