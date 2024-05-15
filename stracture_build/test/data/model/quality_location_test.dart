import 'dart:convert';

import 'package:field/data/model/quality_location_breadcrumb.dart';
import 'package:field/data/model/quality_plan_location_listing_vo.dart' as locationList;
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  dynamic qualityLocationResponse;
  locationList.QualityPlanLocationListingVo qualityLocations;
  List<locationList.Locations>? qualityLocationsData;

  dynamic qualityBreadcrumbResponse;
  QualityLocationBreadcrumb qualityBreadcrumb;
  ProjectPlanDetailsVo projectPlanDetail;


  setUp(() {
    qualityLocationResponse = jsonDecode(fixture("quality_plan_location_listing.json"));
    qualityLocations = locationList.QualityPlanLocationListingVo.fromJson(qualityLocationResponse);
    qualityLocationsData = qualityLocations!.response!.root!.locations!;
  });

  test(
    "Test quality plan location list response parsing",
    () {
      expect(qualityLocationsData?.isNotEmpty, true);
    },
  );

  test(
    "Test quality plan breadcrumb response parsing",
        () {
      expect(qualityBreadcrumbResponse?.isNotEmpty, true);
    },
  );

  group("Quality Location Listing Model:", () {
    test("fromJson() method unit testing", () {
      locationList.Locations qualityLocation = qualityLocationsData!.first;
      Map<String, dynamic> jsonMap = qualityLocation.toJson();
      final result = locationList.Locations.fromJson(jsonMap);
      expect(jsonEncode(result), jsonEncode(qualityLocation));
    });

    test("toJson() method unit testing", () {
      locationList.Locations qualityLocation = qualityLocationsData!.first;
      final result = qualityLocation.toJson();
      Map<String, dynamic> jsonMap = qualityLocation.toJson();
      expect(result, jsonMap);
    });

  });

  group("Quality Breadcrumb Model:", () {

    qualityBreadcrumbResponse = fixture("quality_plan_breadcrumb.json");
    qualityBreadcrumb = QualityLocationBreadcrumb.fromJson(qualityBreadcrumbResponse);
    projectPlanDetail = qualityBreadcrumb!.projectPlanDetailsVO!;

    test("fromJson() method unit testing", () {
      final jsonMap = projectPlanDetail.toJson();
      final result = ProjectPlanDetailsVo.fromJson(jsonMap);
      expect(jsonEncode(result), jsonEncode(projectPlanDetail));
    });

    test("toJson() method unit testing", () {
      final result = qualityBreadcrumb.toJson();
      Map<String, dynamic> jsonMap = qualityBreadcrumb.toJson();
      expect(result, jsonMap);
    });
  });
}
