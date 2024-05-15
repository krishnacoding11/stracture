import 'dart:convert';

import 'package:field/data/dao/calibration_list_dao.dart';
import 'package:field/data/model/calibrated.dart';
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

  group("calibration list dao", () {
    configureDependencies();
    test('Calibration List create table query test', () {
      CalibrationListDao calibrationListDao = CalibrationListDao();
      String strCalibrationListCreateQuery = 'CREATE TABLE IF NOT EXISTS CalibrateTbl(ModelId INTEGER NOT NULL,revisionId\tINTEGER NOT NULL,calibrationId TEXT NOT NULL,sizeOf2dFile TEXT NOT NULL,createdByUserid TEXT NOT NULL,'
          'calibratedBy TEXT NOT NULL,createdDate TEXT NOT NULL,modifiedDate TEXT NOT NULL,point3d1 TEXT NOT NULL,point3d2 TEXT NOT NULL,'
          'point2d1 TEXT NOT NULL,point2d2 TEXT NOT NULL,depth TEXT NOT NULL,fileName TEXT NOT NULL,'
          'fileType TEXT NOT NULL,documentId TEXT NOT NULL,docRef TEXT NOT NULL,folderPath TEXT NOT NULL,'
          'calibrationImageId TEXT NOT NULL,pageWidth TEXT NOT NULL,pageHeight TEXT NOT NULL,pageRotation TEXT NOT NULL,folderId TEXT NOT NULL,'
          'calibrationName TEXT NOT NULL,isChecked INTEGER NOT NULL,isDownloaded INTEGER NOT NULL,generateURI TEXT NOT NULL,projectId TEXT NOT NULL,PRIMARY KEY(calibrationId))';
      expect(strCalibrationListCreateQuery, calibrationListDao.createTableQuery);
    });

    test('Calibration List item to map test', () {
      CalibrationListDao calibrationListDao = CalibrationListDao();
      String strData = "{\"modelId\":\"${"1234"}\",\"revisionId\":\"${"46312\$\$17KRZw"}\",\"calibrationId\":\"test\",\"sizeOf2DFile\":\"00_2022_vivek mishra\","
          "\"createdByUserid\":\"asiteBim_46312\",\"calibratedBy\":\"Vivek Mishra\",\"createdDate\":\"\",\"modifiedDate\":\"\",\"point3d1\":\"43\","
          "\"point3d2\":\"43\",\"point2d1\":\"32\",\"point2d2\":\"2\",\"depth\":54,\"fileName\":\"UK\",\"fileType\":\"pdf\","
          "\"documentId\":\"43\",\"docRef\":\"0\$\$tYgTOy\",\"folderPath\":\"documents/asite\",\"calibrationImageId\":\"3223\",\"pageWidth\":\"0\$\$Zh6QIW\","
          "\"pageHeight\":\"Vivek#Mishra#Asite Solutions\",\"pageRotation\":\"1832155\$\$nXozJq\",\"folderId\":\"1832155\$\$nXozJq\","
          "\"calibrationName\":\"1832155\$\$nXozJq\",\"projectId\":\"322342211\",\"generateURI\":true,\"isChecked\":false,"
          "\"isDownloaded\":true}";
      CalibrationDetails calibrationDetails = CalibrationDetails.fromJson(json.decode(strData));
      var dataMap = calibrationListDao.toMap(calibrationDetails);
      dataMap.then((value) {
        expect(28, value.length);
      });
    });

    test('Calibration List from map test', () {
      var dataMap = {"ModelId": "46312\$\$17KRZw", "revisionId": "2134298\$\$4Dizau", "calibrationId": "00_2022_vivek mishra", "sizeOf2dFile": "46312", "createdByUserid": "Test", "calibratedBy": "Test BW inaccurate 230623", "createdDate": "0", "modifiedDate": "1832155\$\$nXozJq", "point3d1": "2", "point3d2": "true", "point2d1": "123", "point2d2": "2", "depth": "0", "fileName": "UK", "fileType": "0", "documentId": "0", "docRef": "0", "folderPath": "0", "calibrationImageId": "true", "pageWidth": "", "pageHeight": "", "docTitle": "", "pageRotation": "3", "folderId": "5", "calibrationName": "test", "projectId": "213455", "generateURI": "dss", "isChecked": false, "isDownloaded": false};
      CalibrationListDao calibrationListDao = CalibrationListDao();
      CalibrationDetails calibrationDetails = calibrationListDao.fromMap(dataMap);
      expect(calibrationDetails.modelId, "46312\$\$17KRZw");
    });

    test('Calibration List from list map test', () {
      var dataMap = [
        {"ModelId": "46312\$\$17KRZw", "revisionId": "2134298\$\$4Dizau", "calibrationId": "00_2022_vivek mishra", "sizeOf2dFile": "46312", "createdByUserid": "Test", "calibratedBy": "Test BW inaccurate 230623", "createdDate": "0", "modifiedDate": "1832155\$\$nXozJq", "point3d1": "2", "point3d2": "true", "point2d1": "123", "point2d2": "2", "depth": "0", "fileName": "UK", "fileType": "0", "documentId": "0", "docRef": "0", "folderPath": "0", "calibrationImageId": "true", "pageWidth": "", "pageHeight": "", "docTitle": "", "pageRotation": "3", "folderId": "5", "calibrationName": "test", "projectId": "213455", "generateURI": "dss", "isChecked": false, "isDownloaded": false},
        {"ModelId": "46312\$\$17KRZw", "revisionId": "2134298\$\$4Dizau", "calibrationId": "00_2022_vivek mishra", "sizeOf2dFile": "46312", "createdByUserid": "Test", "calibratedBy": "Test BW inaccurate 230623", "createdDate": "0", "modifiedDate": "1832155\$\$nXozJq", "point3d1": "2", "point3d2": "true", "point2d1": "123", "point2d2": "2", "depth": "0", "fileName": "UK", "fileType": "0", "documentId": "0", "docRef": "0", "folderPath": "0", "calibrationImageId": "true", "pageWidth": "", "pageHeight": "", "docTitle": "", "pageRotation": "3", "folderId": "5", "calibrationName": "test", "projectId": "213455", "generateURI": "dss", "isChecked": false, "isDownloaded": false}
      ];
      CalibrationListDao calibrationListDao = CalibrationListDao();
      List<CalibrationDetails> calibrationsList = calibrationListDao.fromList(dataMap);
      expect(calibrationsList.length, 2);
    });

    test('Calibration List from map test', () async {
      var dataMap = {"ModelId": "46312\$\$17KRZw", "revisionId": "2134298\$\$4Dizau", "calibrationId": "00_2022_vivek mishra", "sizeOf2dFile": "46312", "createdByUserid": "Test", "calibratedBy": "Test BW inaccurate 230623", "createdDate": "0", "modifiedDate": "1832155\$\$nXozJq", "point3d1": "2", "point3d2": "true", "point2d1": "123", "point2d2": "2", "depth": "0", "fileName": "UK", "fileType": "0", "documentId": "0", "docRef": "0", "folderPath": "0", "calibrationImageId": "true", "pageWidth": "", "pageHeight": "", "docTitle": "", "pageRotation": "3", "folderId": "5", "calibrationName": "test", "projectId": "213455", "generateURI": "dss", "isChecked": false, "isDownloaded": false};
      CalibrationListDao calibrationListDao = CalibrationListDao();
      CalibrationDetails calibrationDetails = calibrationListDao.fromMap(dataMap);
      expect(calibrationDetails.modelId, "46312\$\$17KRZw");
    });
    test('Calibration delete test', () async {

      final projectId = '12345';
      final formTypeId = '12345';
      final deleteQuery = "DELETE FROM UserReferenceFormTypeTemplateTbl WHERE UserId= '1' AND ProjectId= '12345' AND FormTypeId= '12345'";
      final selectQuery = "SELECT * FROM UserReferenceFormTypeTemplateTbl";

      when(() => mockDb!.executeQuery(deleteQuery)).thenReturn(null);
      await CalibrationListDao().delete(projectId, caliId: formTypeId,isTest: true);
      when(() => mockDb!.selectFromTable(CalibrationListDao().tableName, selectQuery)).thenReturn(null);
      ResultSet? results = mockDb!.selectFromTable(CalibrationListDao().tableName, selectQuery);
      verify(() => mockDb!.selectFromTable(CalibrationListDao().tableName, selectQuery)).called(1);
      expect(results, null);
    });

    test('Calibration deleteAllQuery test', () async {
      when(() => mockDb!.executeQuery(any())).thenReturn(null);
      await CalibrationListDao().deleteAllQuery();
    });

    test('Calibration fetch method test', () async {
      when(() => mockDb!.selectFromTable(any(),any())).thenReturn(null);
      var data= await CalibrationListDao().fetch();
      ResultSet? results = mockDb!.selectFromTable(CalibrationListDao().tableName, "");
      verify(() => mockDb!.selectFromTable(CalibrationListDao().tableName, "")).called(1);
    });

    test('Calibration fetchAll method test', () async {
      when(() => mockDb!.selectFromTable(any(),any())).thenReturn(null);
      var data= await CalibrationListDao().fetchAll("");
      ResultSet? results = mockDb!.selectFromTable(CalibrationListDao().tableName, "");
      verify(() => mockDb!.selectFromTable(CalibrationListDao().tableName, "")).called(1);
    });

    test('Calibration fetchAll method test', () async {
      when(() => mockDb!.selectFromTable(any(),any())).thenReturn(null);
      var data= await CalibrationListDao().fetchModelWise("");
      ResultSet? results = mockDb!.selectFromTable(CalibrationListDao().tableName, "");
      verify(() => mockDb!.selectFromTable(CalibrationListDao().tableName, "")).called(1);
    });
  });
}
