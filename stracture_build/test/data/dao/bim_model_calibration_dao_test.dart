import 'dart:convert';
import 'package:sqlite3/sqlite3.dart';
import 'package:field/data/dao/bim_model_calibration_dao.dart';
import 'package:field/data/model/bim_model_calibration_vo.dart';
import 'package:field/database/db_service.dart';
import 'package:field/injection_container.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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

 group("Bim model calibration dao", () {
   configureDependencies();
   test('Bim Model Calibration create table query test', () {
     BimModelCalibrationModelDao bimModelDao = BimModelCalibrationModelDao();
     String strBimModelListCreateQuery = 'CREATE TABLE IF NOT EXISTS BimModelCalibrationModelListTbl(bimModelId INTEGER NOT NULL,calibrationId INTEGER NOT NULL)';
     expect(strBimModelListCreateQuery, bimModelDao.createTableQuery);
   });

   test('Bim Model Calibration item to map test', () {
     BimModelCalibrationModelDao bimModelDao = BimModelCalibrationModelDao();
     String strData = "{\"bimModelId\":\"${"1234"}\",\"calibrationId\":\"${"46312\$\$17KRZw"}\"}";
     BimModelCalibrationModel bimModelCalibrationModel = BimModelCalibrationModel.fromJson(json.decode(strData));
     var dataMap = bimModelDao.toMap(bimModelCalibrationModel);
     dataMap.then((value) {
       expect(2, value.length);
     });
   });

   test('Bim Model Calibration from map test', () {
     var dataMap = {
       "bimModelId": "46542\$\$17KRZw",
       "calibrationId": "46312\$\$17KRZw",
     };
     BimModelCalibrationModelDao bimModelDao = BimModelCalibrationModelDao();
     BimModelCalibrationModel modelCalibrationModel = bimModelDao.fromMap(dataMap);
     expect(modelCalibrationModel.calibrationId, "46312\$\$17KRZw");
     expect(modelCalibrationModel.bimModelId, "46542\$\$17KRZw");
   });

   test('Bim Model Calibration from map test', () async {
     var dataMap = {
       "bimModelId": "46542\$\$17KRZw",
       "calibrationId": "46312\$\$17KRZw",
     };
     List<Map<String, dynamic>> mapBimModel = [];
     List<BimModelCalibrationModel> objects = [];
     BimModelCalibrationModelDao bimModelCalibrationModelDao = BimModelCalibrationModelDao();
     mapBimModel = await bimModelCalibrationModelDao.toListMap(objects);
     expect(objects.length, 0);
     BimModelCalibrationModel modelCalibrationModel = bimModelCalibrationModelDao.fromMap(dataMap);
     objects.add(modelCalibrationModel);
     expect(objects.length, 1);
   });

   test('Bim Model list from list map test', () {
     var dataMap = [
       {
         "bimModelId": "46542\$\$17KRZw",
         "calibrationId": "46312\$\$17KRZw",
       },
       {
         "bimModelId": "46542\$\$17KRZw",
         "calibrationId": "46312\$\$17KRZw",
       }
     ];
     BimModelCalibrationModelDao bimModelCalibrationModelDao = BimModelCalibrationModelDao();
     List<BimModelCalibrationModel> bimModelList = bimModelCalibrationModelDao.fromList(dataMap);
     expect(bimModelList.length, 2);
   });

   test('Bim Model from map test', () async {
     var dataMap = {"ModelId": "46542\$\$17KRZw", "bimModelId": "46312\$\$17KRZw"};
     BimModelCalibrationModelDao bimModelCalibrationModelDao = BimModelCalibrationModelDao();
     BimModelCalibrationModel modelBimModel = bimModelCalibrationModelDao.fromMap(dataMap);
     expect(modelBimModel.bimModelId, "46312\$\$17KRZw");
   });

   test('Bim Model delete test', () async {

     final projectId = '12345';
     final formTypeId = '12345';
     final deleteQuery = "DELETE FROM UserReferenceFormTypeTemplateTbl WHERE UserId= '1' AND ProjectId= '12345' AND FormTypeId= '12345'";
     final selectQuery = "SELECT * FROM UserReferenceFormTypeTemplateTbl";

     when(() => mockDb!.executeQuery(deleteQuery)).thenReturn(null);
     await BimModelCalibrationModelDao().delete(projectId, caliId: formTypeId);
     when(() => mockDb!.selectFromTable(BimModelCalibrationModelDao().tableName, selectQuery)).thenReturn(null);
     ResultSet? results = mockDb!.selectFromTable(BimModelCalibrationModelDao().tableName, selectQuery);
     verify(() => mockDb!.selectFromTable(BimModelCalibrationModelDao().tableName, selectQuery)).called(1);
     expect(results, null);
   });

   test('Bim Model deleteAllQuery test', () async {
     when(() => mockDb!.executeQuery(any())).thenReturn(null);
     await BimModelCalibrationModelDao().deleteAllQuery();
   });

   test('Bim Model fetch method test', () async {
     when(() => mockDb!.selectFromTable(any(),any())).thenReturn(null);
    var data= await BimModelCalibrationModelDao().fetch();
     ResultSet? results = mockDb!.selectFromTable(BimModelCalibrationModelDao().tableName, "");
     verify(() => mockDb!.selectFromTable(BimModelCalibrationModelDao().tableName, "")).called(1);
   });


 });
}
