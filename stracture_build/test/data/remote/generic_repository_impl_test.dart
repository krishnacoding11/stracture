import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:field/data/model/sync/sync_property_detail_vo.dart';
import 'package:field/data/remote/generic/generic_repository_impl.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../bloc/mock_method_channel.dart';
import 'mock_dio_adpater.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MockDioAdapter mockDioAdapter;

  GenericRemoteRepository genericRemoteRepository = GenericRemoteRepository();
  MockMethodChannel().setBuildFlavorMethodChannel();
  MockMethodChannel().setNotificationMethodChannel();
  AConstants.loadProperty();

  configureCubitDependencies() {
    di.init(test: true);
  }

  setUpAll(() {
    mockDioAdapter = MockDioAdapter();
  });

  test("getDeviceConfiguration [Success]", () async {
    configureCubitDependencies();
    final responseSize = {"fieldFormListCount": "75", "maxThreadForMobileDevice": "3", "fieldOfflineLocationSizeSyncLimit": "100", "akamaiDownloadLimit": "1073741824", "fieldBatchDownloadSize": "250", "fieldBatchDownloadFileLimit": "250", "fieldCustomAttributeSetIdLimit": "5", "fieldFormMessageListCount": "5"};

    mockDioAdapter.dioAdapter.onPost(AConstants.getDeviceConfigurationUrl, (server) => server.reply(200, jsonEncode(responseSize)));

    final result = await genericRemoteRepository.getDeviceConfiguration(mockDioAdapter.dio);
    expect(result.responseCode, 200);
    expect(result.data is SyncManagerPropertyDetails, true);
  });

  test("getDeviceConfiguration [Fail]", () async {
    mockDioAdapter.dioAdapter.onPost(
      AConstants.getDeviceConfigurationUrl,
      (server) => server.throws(
        502,
        DioException(
          requestOptions: RequestOptions(
            path: AConstants.getDeviceConfigurationUrl,
          ),
        ),
      ),
    );
    final result = await genericRemoteRepository.getDeviceConfiguration(mockDioAdapter.dio);
    expect(result is FAIL, true);
  });

  test("getHashValue [Success]", () async {
    final requestData = {
      "fieldValueJson": [
        {"projectId": 2116416}
      ]
    };
    final response = [
      {"hasOnlineViewerSupport": "false", "projectId": "2116416\$\$f3CQ1g"}
    ];

    mockDioAdapter.dioAdapter.onPost(AConstants.getHashUrl, (server) => server.reply(200, jsonEncode(response)), data: requestData);

    final result = await genericRemoteRepository.getHashValue(requestData, mockDioAdapter.dio);
    expect(result!.responseCode, 200);
    expect(result.data, response);
  });

  test("getHashValue [Fail]", () async {
    mockDioAdapter.dioAdapter.onPost(
      AConstants.getHashUrl,
      (server) => server.throws(
        502,
        DioException(
          requestOptions: RequestOptions(
            path: AConstants.getHashUrl,
          ),
        ),
      ),
    );
    final result = await genericRemoteRepository.getHashValue({}, mockDioAdapter.dio);
    expect(result is FAIL, true);
  });
}
