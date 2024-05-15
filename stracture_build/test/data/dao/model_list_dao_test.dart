import 'dart:convert';

import 'package:field/data/dao/model_list_dao.dart';
import 'package:field/data/model/model_vo.dart';
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

  group("Model list dao test", () {
    configureDependencies();
    test('Model create table query test', () {
      ModelListDao itemDao = ModelListDao();
      String strModelListCreateQuery = "CREATE TABLE IF NOT EXISTS ModelListTbl(ModelId TEXT NOT NULL,bimModelId INTEGER NOT NULL,projectId TEXT NOT NULL,projectName TEXT NOT NULL,bimModelName TEXT NOT NULL,modelDescription TEXT NOT NULL,userModelName TEXT NOT NULL,modelCreatorUserId TEXT NOT NULL,modelStatus TEXT NOT NULL,modelCreationDate TEXT NOT NULL,lastUpdateDate TEXT NOT NULL,mergeLevel TEXT NOT NULL,isFavoriteModel TEXT NOT NULL,dc TEXT NOT NULL,modelViewId TEXT NOT NULL,revisionId TEXT NOT NULL,folderId TEXT NOT NULL,revisionNumber TEXT NOT NULL,worksetId TEXT NOT NULL,docId TEXT NOT NULL,publisher TEXT NOT NULL,lastUpdatedUserId TEXT NOT NULL,lastUpdatedBy TEXT NOT NULL,lastAccessUserId TEXT NOT NULL,lastAccessBy TEXT NOT NULL,lastAccessModelDate TEXT NOT NULL,modelTypeId TEXT NOT NULL,setAsOffline TEXT NOT NULL,fileSize TEXT NOT NULL,modelSupportedOffline INTEGER NOT NULL,generateUri TEXT NOT NULL, PRIMARY KEY(ModelId))";

      expect(strModelListCreateQuery.trim(), equals(itemDao.createTableQuery.trim()));
    });

    test('Model item to map test', () {
      ModelListDao itemDao = ModelListDao();
      String strData =
          "{\"ModelId\":\"${"1234"}\",\"bimModelId\":\"${"46312\$\$17KRZw"}\",\"projectId\":\"2134298\$\$4Dizau\",\"projectName\":\"00_2022_vivek mishra\",\"bimModelName\":\"asiteBim_46312\",\"modelDescription\":\"Test\",\"userModelName\":\"Test BW inaccurate 230623\",\"modelCreatorUserId\":\"1832155\$\$nXozJq\",\"modelStatus\":true,\"modelCreationDate\":\"2023-06-23T10:21:26Z\",\"lastUpdateDate\":\"2023-06-23T10:21:26Z\",\"mergeLevel\":2,\"isFavoriteModel\":0,\"dc\":\"UK\",\"modelViewId\":0,\"revisionId\":\"0\$\$nJZ6gd\",\"folderId\":\"0\$\$tYgTOy\",\"revisionNumber\":0,\"worksetId\":\"0\$\$HbtXr2\",\"docId\":\"0\$\$Zh6QIW\",\"publisher\":\"Vivek#Mishra#Asite Solutions\",\"lastUpdatedUserId\":\"1832155\$\$nXozJq\",\"lastUpdatedBy\":\"Vivek#Mishra#Asite Solutions\",\"lastAccessUserId\":\"1832155\$\$nXozJq\",\"lastAccessBy\":\"Vivek#Mishra#Asite Solutions\",\"lastAccessModelDate\":\"2023-06-23T10:24:46Z\",\"modelTypeId\":0,\"generateURI\":true,\"setAsOffline\":true,\"fileSize\":\"123\"}";
      Model model = Model.fromJson(json.decode(strData));
      var dataMap = itemDao.toMap(model);
      dataMap.then((value) {
        expect(31, value.length);
      });
    });

    test('Model from map test', () {
      var dataMap = {"bimModelId": "46312\$\$17KRZw", "projectId": "2134298\$\$4Dizau", "projectName": "00_2022_vivek mishra", "bimModelName": "asiteBim_46312", "modelDescription": "Test", "userModelName": "Test BW inaccurate 230623", "workPackageId": "0", "modelCreatorUserId": "1832155\$\$nXozJq", "modelStatus": true, "modelCreationDate": "2023-06-23T10:21:26Z", "lastUpdateDate": "2023-06-23T10:21:26Z", "mergeLevel": "2", "isFavoriteModel": "0", "dc": "UK", "modelViewId": "0", "revisionId": "0\$\$nJZ6gd", "folderId": "0\$\$tYgTOy", "revisionNumber": "0", "worksetId": "0\$\$HbtXr2", "docId": "0\$\$Zh6QIW", "publisher": "Vivek#Mishra#Asite Solutions", "lastUpdatedUserId": "1832155\$\$nXozJq", "lastUpdatedBy": "Vivek#Mishra#Asite Solutions", "lastAccessUserId": "1832155\$\$nXozJq", "lastAccessBy": "Vivek#Mishra#Asite Solutions", "lastAccessModelDate": "2023-06-23T10:24:46Z", "modelTypeId": "0", "worksetdetails": {}, "workingFolders": {}, "setAsOffline": false, "generateURI": true};
      ModelListDao itemDao = ModelListDao();
      Model model = itemDao.fromMap(dataMap);
      expect(model.projectId, "2134298\$\$4Dizau");
    });

    test('Model from map test', () async {
      var dataMap = {"bimModelId": "46312\$\$17KRZw", "projectId": "2134298\$\$4Dizau", "projectName": "00_2022_vivek mishra", "bimModelName": "asiteBim_46312", "modelDescription": "Test", "userModelName": "Test BW inaccurate 230623", "workPackageId": "0", "modelCreatorUserId": "1832155\$\$nXozJq", "modelStatus": true, "modelCreationDate": "2023-06-23T10:21:26Z", "lastUpdateDate": "2023-06-23T10:21:26Z", "mergeLevel": "2", "isFavoriteModel": "0", "dc": "UK", "modelViewId": "0", "revisionId": "0\$\$nJZ6gd", "folderId": "0\$\$tYgTOy", "revisionNumber": "0", "worksetId": "0\$\$HbtXr2", "docId": "0\$\$Zh6QIW", "publisher": "Vivek#Mishra#Asite Solutions", "lastUpdatedUserId": "1832155\$\$nXozJq", "lastUpdatedBy": "Vivek#Mishra#Asite Solutions", "lastAccessUserId": "1832155\$\$nXozJq", "lastAccessBy": "Vivek#Mishra#Asite Solutions", "lastAccessModelDate": "2023-06-23T10:24:46Z", "modelTypeId": "0", "worksetdetails": {}, "workingFolders": {}, "setAsOffline": false, "generateURI": true};
      List<Map<String, dynamic>> modelListEmpty = [];
      List<Model> modelList1 = [];
      ModelListDao itemDao = ModelListDao();
      modelListEmpty = await itemDao.toListMap(modelList1);
      expect(modelListEmpty.length, 0);
      List<Model> modelListNotEmpty = [];
      Model model = itemDao.fromMap(dataMap);
      modelListNotEmpty.add(model);
      expect(modelListNotEmpty.length, 1);
    });

    test('Model list from list map test', () {
      var dataMap = [
        {"bimModelId": "46312\$\$17KRZw", "projectId": "2134298\$\$4Dizau", "projectName": "00_2022_vivek mishra", "bimModelName": "asiteBim_46312", "modelDescription": "Test", "userModelName": "Test BW inaccurate 230623", "workPackageId": "0", "modelCreatorUserId": "1832155\$\$nXozJq", "modelStatus": true, "modelCreationDate": "2023-06-23T10:21:26Z", "lastUpdateDate": "2023-06-23T10:21:26Z", "mergeLevel": "2", "isFavoriteModel": "0", "dc": "UK", "modelViewId": "0", "revisionId": "0\$\$nJZ6gd", "folderId": "0\$\$tYgTOy", "revisionNumber": "0", "worksetId": "0\$\$HbtXr2", "docId": "0\$\$Zh6QIW", "publisher": "Vivek#Mishra#Asite Solutions", "lastUpdatedUserId": "1832155\$\$nXozJq", "lastUpdatedBy": "Vivek#Mishra#Asite Solutions", "lastAccessUserId": "1832155\$\$nXozJq", "lastAccessBy": "Vivek#Mishra#Asite Solutions", "lastAccessModelDate": "2023-06-23T10:24:46Z", "modelTypeId": "0", "worksetdetails": {}, "workingFolders": {}, "setAsOffline": false, "generateURI": true},
        {"bimModelId": "46312\$\$17KRZw", "projectId": "2134298\$\$4Dizau", "projectName": "00_2022_vivek mishra", "bimModelName": "asiteBim_46312", "modelDescription": "Test", "userModelName": "Test BW inaccurate 230623", "workPackageId": "0", "modelCreatorUserId": "1832155\$\$nXozJq", "modelStatus": true, "modelCreationDate": "2023-06-23T10:21:26Z", "lastUpdateDate": "2023-06-23T10:21:26Z", "mergeLevel": "2", "isFavoriteModel": "0", "dc": "UK", "modelViewId": "0", "revisionId": "0\$\$nJZ6gd", "folderId": "0\$\$tYgTOy", "revisionNumber": "0", "worksetId": "0\$\$HbtXr2", "docId": "0\$\$Zh6QIW", "publisher": "Vivek#Mishra#Asite Solutions", "lastUpdatedUserId": "1832155\$\$nXozJq", "lastUpdatedBy": "Vivek#Mishra#Asite Solutions", "lastAccessUserId": "1832155\$\$nXozJq", "lastAccessBy": "Vivek#Mishra#Asite Solutions", "lastAccessModelDate": "2023-06-23T10:24:46Z", "modelTypeId": "0", "worksetdetails": {}, "workingFolders": {}, "setAsOffline": false, "generateURI": true}
      ];
      ModelListDao modelListDao = ModelListDao();
      List<Model> modelList = modelListDao.fromList(dataMap);
      expect(modelList.length, 2);
    });

    test('Model from map test', () async {
      var dataMap = {"bimModelId": "46312\$\$17KRZw", "projectId": "2134298\$\$4Dizau", "projectName": "00_2022_vivek mishra", "bimModelName": "asiteBim_46312", "modelDescription": "Test", "userModelName": "Test BW inaccurate 230623", "workPackageId": "0", "modelCreatorUserId": "1832155\$\$nXozJq", "modelStatus": true, "modelCreationDate": "2023-06-23T10:21:26Z", "lastUpdateDate": "2023-06-23T10:21:26Z", "mergeLevel": "2", "isFavoriteModel": "0", "dc": "UK", "modelViewId": "0", "revisionId": "0\$\$nJZ6gd", "folderId": "0\$\$tYgTOy", "revisionNumber": "0", "worksetId": "0\$\$HbtXr2", "docId": "0\$\$Zh6QIW", "publisher": "Vivek#Mishra#Asite Solutions", "lastUpdatedUserId": "1832155\$\$nXozJq", "lastUpdatedBy": "Vivek#Mishra#Asite Solutions", "lastAccessUserId": "1832155\$\$nXozJq", "lastAccessBy": "Vivek#Mishra#Asite Solutions", "lastAccessModelDate": "2023-06-23T10:24:46Z", "modelTypeId": "0", "worksetdetails": {}, "workingFolders": {}, "setAsOffline": false, "generateURI": true};
      ModelListDao itemDao = ModelListDao();
      Model model = itemDao.fromMap(dataMap);
      expect(model.projectId, "2134298\$\$4Dizau");
    });

    test(' Model fetch method test', () async {
      when(() => mockDb!.selectFromTable(any(),any())).thenReturn(null);
      var data= await ModelListDao().fetch();
      ResultSet? results = mockDb!.selectFromTable(ModelListDao.tableName, "");
      verify(() => mockDb!.selectFromTable(ModelListDao.tableName, "")).called(1);
    });

    test('Bim Model delete test', () async {

      final projectId = '12345';
      final deleteQuery = "DELETE FROM UserReferenceFormTypeTemplateTbl WHERE UserId= '1' AND ProjectId= '12345' AND FormTypeId= '12345'";
      final selectQuery = "SELECT * FROM UserReferenceFormTypeTemplateTbl";

      when(() => mockDb!.executeQuery(deleteQuery)).thenReturn(null);
      await ModelListDao().delete(projectId,);
      when(() => mockDb!.selectFromTable(ModelListDao.tableName, selectQuery)).thenReturn(null);
      ResultSet? results = mockDb!.selectFromTable(ModelListDao.tableName, selectQuery);
      verify(() => mockDb!.selectFromTable(ModelListDao.tableName, selectQuery)).called(1);
      expect(results, null);
    });

    test('Bim Model deleteAllQuery test', () async {
      when(() => mockDb!.executeQuery(any())).thenReturn(null);
      await ModelListDao().deleteAllQuery();
    });

  });
}
