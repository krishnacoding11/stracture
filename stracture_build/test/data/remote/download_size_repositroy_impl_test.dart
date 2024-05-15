import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:field/data/model/download_size_vo.dart';
import 'package:field/data/model/sync_size_vo.dart';
import 'package:field/data/remote/download_size/download_size_repositroy_impl.dart';
import 'package:field/data_source/sync_size/sync_size_data_source.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/networking/network_service.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';

import 'mock_dio_adpater.dart';

class MockSyncSizeDataSource extends Mock implements SyncSizeDataSource {}

// class MockNetworkService extends Mock implements NetworkService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  DownloadSizeRepository downloadSizeRepository = DownloadSizeRepository();
  late MockDioAdapter mockDioAdapter;

  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setBuildFlavorMethodChannel();

  AConstants.loadProperty();

  setUp(() {
    mockDioAdapter = MockDioAdapter();
    downloadSizeRepository.syncSizeDataSource = MockSyncSizeDataSource();
  });

  group("Download size repositroy  ", () {

    test("getDownloadSize response success", () async {
      final params = <String, dynamic>{
        "tabId": 1,
        "requestDetailsJSON": [
          {"projectId": "2096175\$\$SAgThN", "locationIds": "-1"}
        ],
        "settingJSON": {"includeAttachments": false, "includeAssociation": false, "includeClosedOutForms": false}
      };

      final responseDownloadSize = {
        "2096175": [
          {
            "-1": {"pdfAndXfdfSize": 1651716, "formTemplateSize": 789029, "totalSize": 104762212, "countOfLocations": 47, "totalFormXmlSize": 4256765, "attachmentsSize": 67896652, "associationsSize": 30957079, "countOfForms": 790}
          }
        ]
      };

      mockDioAdapter.dioAdapter.onPost(AConstants.getOfflineSyncDataSizeUrl, (server) => server.reply(200, responseDownloadSize), data: params);

      final result = await downloadSizeRepository.getOfflineSyncDataSize(params, mockDioAdapter.dio);
      expect(result!.responseCode, 200);
    });

    test("getDownloadSize response fail", () async {
      mockDioAdapter.dioAdapter.onPost(
        AConstants.getOfflineSyncDataSizeUrl,
            (server) => server.throws(
          401,
          DioException(
            requestOptions: RequestOptions(
              path: AConstants.getOfflineSyncDataSizeUrl,
            ),
          ),
        ),
      );

      final resultFail = await downloadSizeRepository.getOfflineSyncDataSize({}, mockDioAdapter.dio);
      expect(resultFail!, isA<FAIL>());
    });

    test("getProjectSyncSize", () async {
      List<dynamic> data = jsonDecode(fixture('sync_size_vo.json'));
      List<SyncSizeVo> response = [];

      data.forEach((element) {
        response.add(SyncSizeVo.downloadSizeVoJson(element));
      });

      when(() => downloadSizeRepository.syncSizeDataSource.getProjectSyncSize(any())).thenAnswer((invocation) => Future.value(response));
      final result = await downloadSizeRepository.getProjectSyncSize({"projectId": "456167", "locationId": "-1"});
      expect(result.length, 3);
    });

    test("requestLocationSyncSize", () async {
      List<dynamic> data = jsonDecode(fixture('sync_size_vo.json'));
      List<SyncSizeVo> response = [];

      data.forEach((element) {
        response.add(SyncSizeVo.downloadSizeVoJson(element));
      });

      when(() => downloadSizeRepository.syncSizeDataSource.getRequestedLocationSyncSize(any())).thenAnswer((invocation) => Future.value(response));
      final result = await downloadSizeRepository.requestLocationSyncSize({
        "projectId": "456167",
        "locationId": ["123456,589871"]
      });
      expect(result.length, 3);
    });

      test("addSyncSize", () async {
      List data = json.decode(fixture('download_size_data.json'));
      Map<String, List<Map<String, DownloadSizeVo>>> map = DownloadSizeVo.getDownloadSize(data[0]);
      when(() => downloadSizeRepository.syncSizeDataSource.updateSyncSize(any())).thenAnswer((invocation) => Future.value());
      final result = downloadSizeRepository.addSyncSize(map);
      expect(result, isA<Future<void>>());
    });
  });
}
