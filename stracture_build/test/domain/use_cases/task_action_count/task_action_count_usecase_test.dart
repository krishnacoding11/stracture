import 'package:dio/dio.dart';
import 'package:field/domain/use_cases/task_action_count/task_action_count_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';

class MockTaskActionCountUseCase extends Mock implements TaskActionCountUseCase {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  await di.init(test: true);
  late MockTaskActionCountUseCase taskActionCountUseCase;

  Map<String, dynamic> getDataMap() {
    Map<String, dynamic> map = {};
    map["isOnline"] = isNetWorkConnected();
    map["appType"] = "2";
    map["entityTypeId"] = "1";
    map["projectIds"] = "2116416";
    return map;
  }

  group("TaskActionCount use case:", () {
    dynamic response;
    setUp(() {
      taskActionCountUseCase = MockTaskActionCountUseCase();
      response = fixture("task_action_count_list.json");
    });

    test("get task action count list", () async {
      Map<String, dynamic> map = getDataMap();
      when(() => taskActionCountUseCase.getTaskActionCount(any()))
          .thenAnswer((_) async {
        return Result<dynamic>(SUCCESS(response, Headers(), 200));
      });
      final result = taskActionCountUseCase.getTaskActionCount(map);
      expect(result, isA<Future<Result<dynamic>?>>());

    });
  });

}
