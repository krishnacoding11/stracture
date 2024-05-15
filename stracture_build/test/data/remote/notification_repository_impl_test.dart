import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:field/data/model/notification_detail_vo.dart';
import 'package:field/data/remote/notification/notification_repository_impl.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/networking/network_service.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/injection_container.dart' as di;
import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';
import 'mock_dio_adpater.dart';

class MockNetworkService extends Mock implements NetworkService {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  NotificationRemoteRepository notificationRemoteRepository = NotificationRemoteRepository();
  late MockDioAdapter mockDioAdapter;

  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setBuildFlavorMethodChannel();

  AConstants.loadProperty();

  setUpAll(() {
    mockDioAdapter = MockDioAdapter();
  });


  group("test Notification Data", () {
    String jsonDataString = fixture("notification_detail.json");
    final json = jsonDecode(jsonDataString);
    NotificationDetailVo notificationVo = NotificationDetailVo.fromJson(json[0]);
    Map<String, dynamic> map = {};
    map["action_id"] = "174";
    map["appType"] = "2";
    map["entityTypeId"] = "1";
    map["updateData"] = "2130192#11580871";
    final responseOfCSRF = <String, String>{
      "CSRF_SECURITY_TOKEN": "NjAwMDAwOmJjN2I1YmU5YmQ3ZTU4Y2YxMzU1YzZhMzI3ZDQzYjMw",
    };
    test("Notification Data response Success", () async {
   //   mockDioAdapter.dioAdapter.onPost(AConstants.csrfTokenUrl, (server) => server.reply(200,responseOfCSRF), data: {});
      String jsonResponseDataString = fixture("notification_detail_response.json");
      final jsonResponse = jsonEncode(jsonResponseDataString);
      NetworkService.csrfTokenKey = responseOfCSRF;
      mockDioAdapter.dioAdapter.onPost(AConstants.getTaskFileFormData, (server) => server.reply(200, jsonResponse), data: map, headers: responseOfCSRF);
      final result = await notificationRemoteRepository.sendTaskDetailRequest(map,mockDioAdapter.dio);
      expect(result, isA<SUCCESS>());
    });

    test("Notification Data response fail", () async {
    //  mockDioAdapter.dioAdapter.onPost(AConstants.csrfTokenUrl, (server) => server.reply(200,responseOfCSRF), data: {});
      NetworkService.csrfTokenKey = responseOfCSRF;
      mockDioAdapter.dioAdapter.onPost(AConstants.getTaskFileFormData, (server) => server.throws(400,
          DioException(requestOptions: RequestOptions(path: AConstants.getTaskFileFormData,headers: responseOfCSRF),),
        ),
      );
      final resultFail = await notificationRemoteRepository.sendTaskDetailRequest({},mockDioAdapter.dio);
     expect(resultFail!, isA<FAIL>());
    });
  });
}