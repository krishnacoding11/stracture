import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/tasklistingsearch_vo.dart';
import 'package:field/domain/use_cases/tasklisting/task_listing_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';

class MockTaskListingUseCase extends Mock implements TaskListingUseCase {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  await di.init(test: true);
  late MockTaskListingUseCase mockTaskListingUseCase;

  group("Tasklisting use case test :", () {
    dynamic response;
    setUp(() {
      mockTaskListingUseCase = MockTaskListingUseCase();
      response = fixture("sitetaskslist.json");
    });

    test("get task list", () async {
      Map<String, dynamic> request = {};
      request["isOnline"] = true;
      request["isFromMyTask"] = "true";
      List<Criteria> listOfCriteria = [];
      //listOfCriteria.add(Criteria(field: "StatusId", operator: 1, values: [1]));
      listOfCriteria.add(Criteria(field: "EntityType", operator: 1, values: [1]));
      listOfCriteria.add(Criteria(field: "AssigneeId", operator: 1, values: ["223321"]));
      Tasklistingsearchvo taskListingSearchObj = Tasklistingsearchvo(recordStart: 0,
          recordLimit: 50,
          groupRecordLimit: 50,
          groupField: 1,
          criteria: listOfCriteria);
      request["searchCriteria"] = taskListingSearchObj.toJson().toString();
      when(() => mockTaskListingUseCase.getTaskListing(any()))
          .thenAnswer((_) async {
        return Result<dynamic>(SUCCESS(response, Headers(), 200));
      });
      final result = mockTaskListingUseCase.getTaskListing(request);
      expect(result, isA<Future<Result<dynamic>?>>());
    });

    test("get task status API", () async {
      Map<String, dynamic> map = {};
      map["isOnline"] = true;
      when(() => mockTaskListingUseCase.getTaskStatusList(any()))
          .thenAnswer((_) async {
        return SUCCESS<dynamic>(response, null,200);
      });
      final result = await mockTaskListingUseCase.getTaskStatusList(map);
      expect(result, isA<Result>());
    });

    test("get task details API", () async {
      String jsonDataString = fixture("sitetaskslist.json").toString();
      final json = jsonDecode(jsonDataString);
      final dataNode = json['data'];
      var form = SiteForm.fromJson(dataNode[0]);
      Map<String, dynamic> map = {
        'recordBatchSize': '5',
        'listingType': '31',
        'recordStartFrom': '0',
        'application_Id': '3',
        'isFromAndroidApp': 'true',
        'isFromSyncCall': 'true',
        'isRequiredTemplateData': 'true',
        'action_id': '100',
        'projectId': form.projectId,
        'selectedFormId': form.commId.plainValue()
      };
      when(() => mockTaskListingUseCase.getTaskDetail(any()))
          .thenAnswer((_) async {
        return SUCCESS<dynamic>(response, null,200);
      });
      final result = await mockTaskListingUseCase.getTaskDetail(map);
      expect(result, isA<Result>());
    });
  });

}
