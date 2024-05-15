import 'dart:convert';

import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/tasklisting_vo.dart';
import 'package:field/data/model/taskstatussist_vo.dart';
import 'package:field/data/remote/task_listing/tasklisting_repository_impl.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/injection_container.dart' as di;
import '../../bloc/mock_method_channel.dart';
import '../../fixtures/fixture_reader.dart';

class MockTaskListingRemoteRepository extends Mock implements TaskListingRemoteRepository {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  di.getIt.registerLazySingleton<MockTaskListingRemoteRepository>(() => MockTaskListingRemoteRepository());
  late MockTaskListingRemoteRepository mockTaskListingRemoteRepository;

  setUpAll(() {
    mockTaskListingRemoteRepository = di.getIt<MockTaskListingRemoteRepository>();
  });

  group("test get task listing", () {
    String jsonDataString = fixture("task_listing.json");
    final json = jsonDecode(jsonDataString);
    TaskListingVO taskListingVO = TaskListingVO.fromJson(json);
    TaskStatusListVo taskStatusListVo = TaskStatusListVo.fromJson(json);

    Project project = Project.fromJson(jsonDecode(fixture("project.json")));

    Map<String, dynamic> map = {};
    map["action_id"] = "100";
    map["projectId"] = project.projectID!;
    map["currentPageNo"] = "1";
    map["recordBatchSize"] = "25";
    map["recordStartFrom"] = "0";
    map["projectIds"] = "-2";
    map["listingType"] = "134";
    map["sortField"] = "lastupdatedate";
    map["sortFieldType"] = "timestamp";
    map["sortOrder"] = "desc";
    map["applicationId"] = "3";
    map["checkHashing"] = "false";
    map[AConstants.keyLastApiCallTimestamp] = DateTime.now().millisecondsSinceEpoch;

    test("test get task listing data", () async {
      when(() => mockTaskListingRemoteRepository.getTaskListing(map)).thenAnswer((_) async => Future(() => SUCCESS(taskListingVO, null, null)));
      final result = await mockTaskListingRemoteRepository.getTaskListing(map);
      expect(result, isA<SUCCESS>());
    });

    test("test get task status data", ()  async{
      when(() => mockTaskListingRemoteRepository.getTaskStatusList(map)).thenAnswer((_) async => Future(() => SUCCESS(taskStatusListVo, null, null)));
      final result = await mockTaskListingRemoteRepository.getTaskStatusList(map);
      expect(result, isA<SUCCESS>());
    });

  });
}