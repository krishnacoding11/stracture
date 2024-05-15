import 'dart:convert';

import 'package:field/data/local/task_action_count/taskactioncount_local_repository_impl.dart';
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/injection_container.dart' as di;

import '../../../fixtures/fixture_reader.dart';

class MockTaskActionCountLocalRepository extends Mock implements TaskActionCountLocalRepository {}

void main() {
  di.getIt.registerLazySingleton<MockTaskActionCountLocalRepository>(() => MockTaskActionCountLocalRepository());
  late MockTaskActionCountLocalRepository mockTaskActionCountLocalRepository;

  setUpAll(() {
    mockTaskActionCountLocalRepository = di.getIt<MockTaskActionCountLocalRepository>();
  });

  group("TaskActionCount local repository tests:", () {
    dynamic response = json.decode((fixture("task_action_count_list.json")));
    Map<String, dynamic> map = {};
    map["isOnline"] = true;
    map["appType"] = "2";
    map["entityTypeId"] = "1";
    map["projectIds"] = "2116416";
    test("test get task action count", () async {
      when(() => mockTaskActionCountLocalRepository.getTaskActionCount(map)).thenAnswer((_) async => Future(() => SUCCESS(response, null, null)));
      final result = await mockTaskActionCountLocalRepository.getTaskActionCount(map);
      expect(result, isA<SUCCESS>());
    });
  });
}
