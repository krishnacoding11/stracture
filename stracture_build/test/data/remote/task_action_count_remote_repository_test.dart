import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:field/data/remote/task_action_count/taskactioncount_repository_impl.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprintf/sprintf.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';
import 'mock_dio_adpater.dart';

class MockTaskActionCountRemoteRepository extends Mock implements TaskActionCountRemoteRepository {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  AppConfigTestData().setupAppConfigTestData();
  TaskActionCountRemoteRepository taskActionCountRemoteRepository = TaskActionCountRemoteRepository();
  late MockDioAdapter mockDioAdapter;
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setBuildFlavorMethodChannel();

  AConstants.loadProperty();

  setUpAll(() {
    mockDioAdapter = MockDioAdapter();
  });

  group("TaskActionCount Remote repository Implementation: ", () {
    dynamic response = json.decode((fixture("task_action_count_list.json")));
    Map<String, dynamic> mapRequest = {};
    mapRequest["appType"] = "2";
    mapRequest["entityTypeId"] = "1";
    mapRequest["projectIds"] = "2116416";

    String endPointUrl = sprintf(AConstants.getTaskActionCountUrl, ["1","2","2116416","-1"]);
    test("test get task action count", () async{
      mockDioAdapter.dioAdapter.onGet(endPointUrl, (server) => server.reply(200, response));
      final result = await taskActionCountRemoteRepository.getTaskActionCount(mapRequest,mockDioAdapter.dio);
      expect(result, isA<SUCCESS>());
    });
    test("test get task action count fail", () async {
      mockDioAdapter.dioAdapter.onPost(AConstants.getTaskFileFormData, (server) => server.throws(400,
        DioException(requestOptions: RequestOptions(path: AConstants.getTaskFileFormData),),
      ),
      );
      final resultFail = await taskActionCountRemoteRepository.getTaskActionCount({},mockDioAdapter.dio);
      expect(resultFail!, isA<FAIL>());
    });
  });
}
