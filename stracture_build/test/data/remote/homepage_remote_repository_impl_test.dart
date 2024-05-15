import 'dart:convert';

import 'package:field/data/remote/dashboard/homepage_remote_repository_impl.dart';
import 'package:field/data_source/sync_size/sync_size_data_source.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprintf/sprintf.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';

import 'mock_dio_adpater.dart';

class MockSyncSizeDataSource extends Mock implements SyncSizeDataSource {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  HomePageRemoteRepository homePageRemoteRepository = HomePageRemoteRepository();
  late MockDioAdapter mockDioAdapter;

  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setBuildFlavorMethodChannel();

  AConstants.loadProperty();

  setUp(() {
    mockDioAdapter = MockDioAdapter();
  });

  group("Home page remote repository  ", () {

    test("getShortcutConfigList response success", () async {
      final requestParams = <String, dynamic>{
        "projectId": '2119100\$\$CaLnQA',
      };

      final responseDownloadSize = jsonDecode(fixture('homepage_item_config_data.json'));

      mockDioAdapter.dioAdapter.onPost(AConstants.manageDeviceHomePage, (server) => server.reply(200, responseDownloadSize), data: requestParams);

      final result = await homePageRemoteRepository.getShortcutConfigList(requestParams, mockDioAdapter.dio);
      expect(result!.responseCode, 200);
    });

    test("getShortcutConfigList response fail", () async {
      final requestParams = <String, dynamic>{
        "projectId": '2119100\$\$CaLnQA',
      };


      mockDioAdapter.dioAdapter.onPost(AConstants.manageDeviceHomePage, (server) => server.reply(500, null), data: requestParams);

      final result = await homePageRemoteRepository.getShortcutConfigList(requestParams, mockDioAdapter.dio);
      expect(result!.responseCode, 500);
    });

    test("updateShortcutConfigList response success", () async {
      final requestParams = <String, dynamic>{
        "projectId": '2119100\$\$CaLnQA',
        "jsonData": {"defaultTabs":[{"id":"1","values":"Create New Task"},{"id":"2","values":"New Tasks"},{"id":"3","values":"Task Due Today"},{"id":"4","values":"Task Due This Week"},{"id":"5","values":"Overdue Tasks"},{"id":"6","values":"Jump Back to Site"},{"id":"7","values":"Create Site Form"},{"id":"8","values":"Filter"},{"id":"9","values":"CreateForm"}],"userProjectConfigTabsDetails":[{"id":"1","name":"Create New Task","config":{}},{"id":"2","name":"New Tasks","config":{}},{"id":"3","name":"Task Due Today","config":{}},{"id":"4","name":"Task Due This Week","config":{}},{"id":"5","name":"Overdue Tasks","config":{}},{"id":"6","name":"Jump Back to Site","config":{}},{"id":"7","name":"Create Site Form","config":{}},{"id":"9","name":"01. Contract Form","config":{"templatetype":2,"instanceGroupId":"10421108"}},{"id":"9","name":"02. Meeting Tasks","config":{"templatetype":2,"instanceGroupId":"10421097"}}]},
      };

      final responseDownloadSize = jsonDecode(fixture('homepage_item_config_data.json'));

      mockDioAdapter.dioAdapter.onPost(AConstants.manageDeviceHomePage, (server) => server.reply(200, responseDownloadSize), data: requestParams);

      final result = await homePageRemoteRepository.updateShortcutConfigList(requestParams, mockDioAdapter.dio);
      expect(result!.responseCode, 200);
    });

    test("updateShortcutConfigList response fail", () async {
      final requestParams = <String, dynamic>{
        "projectId": '2119100\$\$CaLnQA',
        "jsonData": {"defaultTabs":[{"id":"1","values":"Create New Task"},{"id":"2","values":"New Tasks"},{"id":"3","values":"Task Due Today"},{"id":"4","values":"Task Due This Week"},{"id":"5","values":"Overdue Tasks"},{"id":"6","values":"Jump Back to Site"},{"id":"7","values":"Create Site Form"},{"id":"8","values":"Filter"},{"id":"9","values":"CreateForm"}],"userProjectConfigTabsDetails":[{"id":"1","name":"Create New Task","config":{}},{"id":"2","name":"New Tasks","config":{}},{"id":"3","name":"Task Due Today","config":{}},{"id":"4","name":"Task Due This Week","config":{}},{"id":"5","name":"Overdue Tasks","config":{}},{"id":"6","name":"Jump Back to Site","config":{}},{"id":"7","name":"Create Site Form","config":{}},{"id":"9","name":"01. Contract Form","config":{"templatetype":2,"instanceGroupId":"10421108"}},{"id":"9","name":"02. Meeting Tasks","config":{"templatetype":2,"instanceGroupId":"10421097"}}]},
      };


      mockDioAdapter.dioAdapter.onPost(AConstants.manageDeviceHomePage, (server) => server.reply(500, null), data: requestParams);

      final result = await homePageRemoteRepository.updateShortcutConfigList(requestParams, mockDioAdapter.dio);
      expect(result!.responseCode, 500);
    });

    test("getPendingShortcutConfigList response success", () async {
      final requestParams = <String, dynamic>{
        "projectId": '2119100\$\$CaLnQA',
      };

      final responseDownloadSize = jsonDecode(fixture('homepage_item_config_data.json'));
      String endPointUrl = sprintf(AConstants.homePageDataForConfiguration, [requestParams['projectId'], 2, "true"]);
      mockDioAdapter.dioAdapter.onGet(endPointUrl, (server) => server.reply(200, responseDownloadSize),);

      final result = await homePageRemoteRepository.getPendingShortcutConfigList(requestParams, mockDioAdapter.dio);
      expect(result!.responseCode, 200);
    });

    test("getPendingShortcutConfigList response fail", () async {
      final requestParams = <String, dynamic>{
        "projectId": '2119100',
      };

      String endPointUrl = sprintf(AConstants.homePageDataForConfiguration, [requestParams['projectId'], 2, "true"]);
      mockDioAdapter.dioAdapter.onGet(endPointUrl, (server) => server.reply(500, null),);

      final result = await homePageRemoteRepository.getPendingShortcutConfigList(requestParams, mockDioAdapter.dio);
      expect(result!.responseCode, 500);
    });

  });
}
