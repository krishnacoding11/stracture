import 'dart:convert';

import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/data/dao/floor_list_dao.dart';
import 'package:field/data/dao/model_list_dao.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/data/model/model_vo.dart';
import 'package:field/data_source/model_list_data_source/model_list_local_data_source_impl.dart';
import 'package:field/database/db_service.dart';
import 'package:field/injection_container.dart' as di;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/common.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/fixture_reader.dart';

class DBServiceMock extends Mock implements DBService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setAsitePluginsMethodChannel();

  di.init(test: true);
  SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json")});

  final String projectId = "2130192";

  DBServiceMock mockDb = DBServiceMock();
  late ModelListLocalDataSourceImpl modelListLocalDataSourceImpl;

  Map<String, dynamic> modelDataOfflineJson = {"bimModelId": "4631217KRZw", "projectId": "21342984Dizau", "projectName": "00_2022_vivek mishra", "bimModelName": "asiteBim_46312", "modelDescription": "Test", "userModelName": "Test BW inaccurate 230623", "workPackageId": 0, "modelCreatorUserId": "1832155nXozJq", "modelStatus": true, "modelCreationDate": "2023-06-23T10:21:26Z", "lastUpdateDate": "2023-06-23T10:21:26Z", "mergeLevel": "2", "isFavoriteModel": "0", "dc": "UK", "modelViewId": "0", "revisionId": "0nJZ6gd", "folderId": "0tYgTOy", "revisionNumber": "0", "worksetId": "0HbtXr2", "docId": "0Zh6QIW", "publisher": "Vivek#Mishra#Asite Solutions", "lastUpdatedUserId": "1832155nXozJq", "lastUpdatedBy": "Vivek#Mishra#Asite Solutions", "lastAccessUserId": "1832155nXozJq", "lastAccessBy": "Vivek#Mishra#Asite Solutions", "lastAccessModelDate": "2023-06-23T10:24:46Z", "modelTypeId": "0", "worksetdetails": {}, "workingFolders": {}, "setAsOffline": false, "generateURI": true};

  setUp(() async {
    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb);

    modelListLocalDataSourceImpl = ModelListLocalDataSourceImpl();
  });

  group("getFilteredModelList", () {
    test("getFilteredModelList pass valid param expected bimModelName", () async {
      ResultSet resultSet = ResultSet(modelDataOfflineJson.keys.toList(), null, [modelDataOfflineJson.values.toList()]);

      when(() => mockDb.selectFromTable(ModelListDao.tableName, any())).thenReturn(resultSet);

      List<Model> result = await modelListLocalDataSourceImpl.getFilteredModelList({}, projectId, "asiteBim_46312");
      expect(result.first.bimModelName, "asiteBim_46312");
    });

    test("getFilteredModelList pass exception expected empty list", () async {
      when(() => mockDb.selectFromTable(ModelListDao.tableName, any())).thenThrow(Exception());

      List<Model> result = await modelListLocalDataSourceImpl.getFilteredModelList({}, projectId, "asiteBim_46312");
      expect(result.isEmpty, true);
    });
  });

  group("fetchModeList", () {
    test("fetchModeList pass valid param expected bimModelName", () async {
      ResultSet resultSet = ResultSet(modelDataOfflineJson.keys.toList(), null, [modelDataOfflineJson.values.toList()]);

      when(() => mockDb.selectFromTable(ModelListDao.tableName, any())).thenReturn(resultSet);

      List<Model> result = await modelListLocalDataSourceImpl.fetchModeList({}, projectId);
      expect(result.isNotEmpty, true);
    });

    test("fetchModeList pass exception expected empty list", () async {
      when(() => mockDb.selectFromTable(ModelListDao.tableName, any())).thenThrow(Exception());

      List<Model> result = await modelListLocalDataSourceImpl.fetchModeList({}, projectId);
      expect(result.isEmpty, true);
    });
  });

  group("Exception cases", () {
    test("setParallelViewAuditTrail expected UnimplementedError exception", () async {
      expect(() => modelListLocalDataSourceImpl.setParallelViewAuditTrail({}, projectId), throwsA(isA<UnimplementedError>()));
    });

    test("syncWithDB expected UnimplementedError exception", () async {
      expect(() => modelListLocalDataSourceImpl.syncWithDB([], [], ModelListCubit(), [], [], [], BimModel(), 0.0), throwsA(isA<UnimplementedError>()));
    });

    test("getDownloadedModelsPath expected UnimplementedError exception", () async {
      expect(() => modelListLocalDataSourceImpl.getDownloadedModelsPath(projectId, "", "", []), throwsA(isA<UnimplementedError>()));
    });

    test("getDownloadedPdfFile expected UnimplementedError exception", () async {
      expect(() => modelListLocalDataSourceImpl.getDownloadedPdfFile(projectId, []), throwsA(isA<UnimplementedError>()));
    });
  });

  group("fetchRevisionId", () {
    test("fetchRevisionId pass valid param expected list of FloorDetail", () async {
      String strData = "{\"bimModelId\":\"${"1234"}\",\"id\":\"${"46312\$\$17KRZw"}\",\"revisionId\":2373726,\"fileName\":\"00_2022_vivek mishra\","
          "\"fileSize\":\"asiteBim_46312\",\"floorNumber\":\"0\",\"levelName\":\"Vivek Mishra\",\"isChecked\":false,\"isDownloaded\":true,"
          "\"projectId\":\"4534343\",\"revName\":\"32\"}";

      FloorDetail floorDetails = FloorDetail.fromJson(jsonDecode(strData));
      Map<String, dynamic> floorDetailsMap = floorDetails.toJson();

      ResultSet resultSet = ResultSet(floorDetailsMap.keys.toList(), null, [floorDetailsMap.values.toList()]);

      when(() => mockDb.selectFromTable(FloorListDao().tableName, any())).thenReturn(resultSet);

      List<FloorDetail> result = await modelListLocalDataSourceImpl.fetchRevisionId(projectId);
      expect(result.isNotEmpty, true);
    });

    test("fetchRevisionId pass exception expected empty list", () async {
      when(() => mockDb.selectFromTable(FloorListDao().tableName, any())).thenThrow(Exception());

      List<FloorDetail> result = await modelListLocalDataSourceImpl.fetchRevisionId(projectId);
      expect(result.isNotEmpty, false);
    });
  });

  test("floorSizeByModelId pass plainModelId param expected calibrateSize", () async {
    double result = await modelListLocalDataSourceImpl.floorSizeByModelId(projectId);
    expect(result, 0.0);
  });

  test("getProjectFromProjectDetailsTable pass valid param expected empty string", () async {
    String result = await modelListLocalDataSourceImpl.getProjectFromProjectDetailsTable(projectId, true);
    expect(result.isEmpty, true);
  });

  test("getFloorList pass valid param expected list of FloorData", () async {
    List<FloorData> result = await modelListLocalDataSourceImpl.getFloorList({"revisionIds": "2373726"});
    expect(result.isNotEmpty, true);
  });
}