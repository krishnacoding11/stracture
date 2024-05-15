import 'package:field/data/model/site_location.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  dynamic siteLocationResponse;
  List<SiteLocation>? siteLocationList;
  setUp(() {
    siteLocationResponse = fixture("site_location.json");
    siteLocationList = SiteLocation.jsonToList(siteLocationResponse);
  });

  test(
    "test Site response parsing",
    () {
      expect(siteLocationList?.isNotEmpty, true);
    },
  );

  group("SiteLocation Model:", () {
    test("fromJson() method unit testing", () {
      SiteLocation siteLocation = siteLocationList![0];
      Map<String, dynamic> jsonMap = siteLocation.toJson();
      final result = SiteLocation.fromJson(jsonMap);
      expect(result, siteLocation);
    });

    test("toJson() method unit testing", () {
      SiteLocation siteLocation = siteLocationList![0];
      final result = siteLocation.toJson();
      Map<String, dynamic> jsonMap = siteLocation.toJson();
      expect(result, jsonMap);
    });
  });
}
