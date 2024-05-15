import 'package:field/data/local/task_listing/tasklisting_local_repository_impl.dart';
import 'package:field/data/model/taskstatussist_vo.dart';
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late TaskListingLocalRepository taskListingLocalRepository;
  setUp(() {
    taskListingLocalRepository = TaskListingLocalRepository();
  });

  group("Task listing local repository test", () {
    test("getTaskListing test success", () async {
      Map<String, dynamic> request = {};
      var result = await taskListingLocalRepository.getTaskListing(request);
      expect(result, FAIL("", -1));
    });

    test("getTaskStatusList test success", () async {
      Map<String, dynamic> request = {};
      var result = await taskListingLocalRepository.getTaskStatusList(request);
      expect(result, FAIL("", -1));
    });

    test("getTaskDetail test success", () async {
      Map<String, dynamic> request = {};
      var result = await taskListingLocalRepository.getTaskDetail(request);
      expect(result, FAIL("", -1));
    });

    test("getTaskStatusObjList test success", () async {
      Map<String, dynamic> map = {
        'statusId': 0,
        'statusName': "",
        'statusDesc': "",
      };
      List<TaskStatusListVo> result = await taskListingLocalRepository.getTaskStatusObjList([map]);
      expect(result, isA<List<TaskStatusListVo>>());
    });
  });
}
