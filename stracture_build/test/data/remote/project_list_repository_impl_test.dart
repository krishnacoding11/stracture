import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/sync_size_vo.dart';
import 'package:field/data/remote/project_list/project_list_repository_impl.dart';
import 'package:field/data_source/sync_size/sync_size_data_source.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/fixture_reader.dart';
import 'mock_dio_adpater.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockDioAdapter mockDioAdapter;

  ProjectListRemoteRepository projectListRemoteRepository = ProjectListRemoteRepository();
  MockMethodChannel().setBuildFlavorMethodChannel();
  MockMethodChannel().setNotificationMethodChannel();
  AConstants.loadProperty();

  configureCubitDependencies() {
    di.init(test: true);
  }

  setUpAll(() {
    mockDioAdapter = MockDioAdapter();
  });

  group("Project list remote repository", () {
    configureCubitDependencies();

    test("getProjectList [Success]", () async {
      Map<String, dynamic> requestData = {};
      requestData["isPrivilegesRequired"] = "true";
      requestData["projectIds"] = "2089700\$\$jpmd7h";
      requestData["checkHashing"] = "false";
      requestData["searchProjectIds"] = "";

      final responseData = [jsonDecode(fixture('project.json'))];

      mockDioAdapter.dioAdapter.onPost(AConstants.projectListUrl, (server) => server.reply(200, responseData),data: requestData);

      final result = await projectListRemoteRepository.getProjectList(0, 50, requestData,mockDioAdapter.dio);
      expect(result.runtimeType, List<Project>);
    });

    test("getProjectList [Fail]", () async {
      Map<String, dynamic> requestData = {};
      requestData["isPrivilegesRequired"] = "true";
      requestData["projectIds"] = "2089700\$\$jpmd7h";
      requestData["checkHashing"] = "false";
      requestData["searchProjectIds"] = "";

      mockDioAdapter.dioAdapter.onPost(
        AConstants.projectListUrl,
            (server) =>
            server.throws(
              502,
              DioException(
                requestOptions: RequestOptions(
                  path: AConstants.projectListUrl,
                ),
              ),
            ),
        data: requestData
      );
      final result = await projectListRemoteRepository.getProjectList(0, 50, {},mockDioAdapter.dio);
      expect(result.length, 0);
    });

    test("getPopupDataList [Success]", () async {
      Map<String, dynamic> map = {};
      map["recordBatchSize"] = "50";
      map["recordStartFrom"] = "0";
      map["applicationId"] = 3;
      map["object_type"] = "PROJECT";
      map["object_attribute"] = "project_id";
      map["searchValue"] = "";
      map["dataFor"] = 2;
      map["sortOrder"] = "asc";
      map["sortField"] = "name";


      final responseData = jsonDecode(fixture('popupdata_list.json'));

      mockDioAdapter.dioAdapter.onPost(AConstants.getPopupData, (server) => server.reply(200, responseData),data: map);

      final result = await projectListRemoteRepository.getPopupDataList(0, 50, map,mockDioAdapter.dio);
      expect(result.runtimeType, List<Popupdata>);
    });

    test("getPopupDataList [Fail]", () async {
      Map<String, dynamic> map = {};
      map["isPrivilegesRequired"] = "true";
      map["projectIds"] = "2089700\$\$jpmd7h";
      map["checkHashing"] = "false";
      map["searchProjectIds"] = "";
      map["searchValue"] = "";
      map["dataFor"] = 2;
      map["sortOrder"] = "asc";
      map["sortField"] = "name";

      mockDioAdapter.dioAdapter.onPost(
          AConstants.projectListUrl,
              (server) =>
              server.throws(
                502,
                DioException(
                  requestOptions: RequestOptions(
                    path: AConstants.projectListUrl,
                  ),
                ),
              ),
          data: map
      );
      final result = await projectListRemoteRepository.getProjectList(0, 50, {},mockDioAdapter.dio);
      expect(result.length, 0);
    });

    test("setFavProject [Success]", () async {
      Map<String, dynamic> map = {};
      map["action_id"] = "809";
      map["dcWiseProjectIds"] = {"1":"2115768\$\$8ksens"};
      map["setFavorite"] = "1";

      mockDioAdapter.dioAdapter.onPost(AConstants.favoriteProjectUrl, (server) => server.reply(200, "Success"),data: map);

      final result = await projectListRemoteRepository.setFavProject(map,mockDioAdapter.dio);
      expect(result.data, "Success");
    });

    test("setFavProject [FAIL]", () async {
      Map<String, dynamic> map = {};
      map["dcWiseProjectIds"] = {"1":"2115768\$\$8ksens"};
      map["setFavorite"] = "1";

      mockDioAdapter.dioAdapter.onPost(AConstants.favoriteProjectUrl, (server) => server.reply(200, ""),data: map);

      final result = await projectListRemoteRepository.setFavProject(map,mockDioAdapter.dio);
      expect(result.data, "");
    });

    test("deleteItemFromSyncTable [Success]",() async {
      projectListRemoteRepository.syncSizeDataSource = MockSyncSizeDataSource();
      List<dynamic> response = jsonDecode(fixture('sync_size_vo.json'));
      SyncSizeVo answer = SyncSizeVo.downloadSizeVoJson(response.first);
      when(() => projectListRemoteRepository.syncSizeDataSource.deleteProjectSync(any())).thenAnswer((invocation) => Future.value([answer]));

      final result = await projectListRemoteRepository.deleteItemFromSyncTable({
        "projectId" : "2115768\$\$8ksens",
        "locationId" : -1
      });

      expect(result.length, 1);
    });

    test("deleteItemFromSyncTable [Success]",() async {
      projectListRemoteRepository.syncSizeDataSource = MockSyncSizeDataSource();
      when(() => projectListRemoteRepository.syncSizeDataSource.deleteProjectSync(any())).thenAnswer((invocation) => Future.value([]));

      final result = await projectListRemoteRepository.deleteItemFromSyncTable({
        "projectId" : "2115768\$\$8ksens",
        "locationId" : -1
      });

      expect(result.length, 0);
    });

    test("getWorkspacesettings [Success]", () async {
      Map<String, dynamic> request = {};
      request["projectsDetail"] = json.encode({"projectIds": "2089700\$\$jpmd7h",
        "settingFields":"enableGeoTagging,projectid"});

      final responseData = [jsonDecode(fixture('workspace_settings.json'))];

      mockDioAdapter.dioAdapter.onPost(AConstants.getWorkspaceSetting, (server) => server.reply(200, responseData),data: request);

      final result = await projectListRemoteRepository.getWorkspaceSettings(request,mockDioAdapter.dio);
      expect(result, isA<Result>());
    });
  });
}

class MockSyncSizeDataSource extends Mock implements SyncSizeDataSource {}