import 'dart:convert';

import 'package:field/data/model/quality_activity_list_vo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  dynamic activityResponse;
  QualityActivityList? activityResponseData;
  dynamic activityListData;

  setUp(() {
    activityResponse = jsonDecode(fixture("quality_activity_listing_response.json"));
    activityResponseData = QualityActivityList.fromJson(activityResponse);
    activityListData = activityResponseData!.response!.root!.activitiesList!;
  });

  test(
    "Test activity list response parsing",
        () {
      expect(activityListData?.isNotEmpty, true);
    },
  );

  group("Activity Listing Model:", () {
    test("fromJson() method unit testing", () {
      ActivitiesList firstActivitiesList = activityListData![0];
      Map<String, dynamic> jsonMap = firstActivitiesList.toJson();
      final result = ActivitiesList.fromJson(jsonMap);
      expect(jsonEncode(result), jsonEncode(firstActivitiesList));
    });

    test("toJson() method unit testing", () {
      ActivitiesList firstActivitiesList = activityListData!.first;
      final result = firstActivitiesList.toJson();
      Map<String, dynamic> jsonMap = firstActivitiesList.toJson();
      expect(result, jsonMap);
    });
  });
}
