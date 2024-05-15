import 'dart:convert';

import 'package:field/data/model/quality_plan_location_listing_vo.dart';
import 'package:field/domain/use_cases/quality/quality_plan_listing_usecase.dart';
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/fixture_reader.dart';

class MockQualityPlanListingUseCase extends Mock implements QualityPlanListingUseCase {}

void main() {
  late MockQualityPlanListingUseCase mockQualityPlanListingUseCase;
  List<Locations>? locationList = [];

  setUp(() {
    mockQualityPlanListingUseCase = MockQualityPlanListingUseCase();
    locationList = QualityPlanLocationListingVo.fromJson(jsonDecode(fixture("quality_plan_location_listing.json"))).response!.root!.locations;
  });


  group("Test Get Quality Plan Location Listing From Server", () {
    test("Success response", () async {
      when(() => mockQualityPlanListingUseCase.getQualityPlanLocationListingFromServer(any()))
          .thenAnswer((_) {
        return Future.value(SUCCESS(locationList, null, null));
      });
      var result = await mockQualityPlanListingUseCase.getQualityPlanLocationListingFromServer({});
      expect(result, isA<SUCCESS>());
    });
    test("Fail response", () async {
      when(() => mockQualityPlanListingUseCase.getQualityPlanLocationListingFromServer(any()))
          .thenAnswer((_) {
        return Future.value(FAIL("", 204));
      });
      var result = await mockQualityPlanListingUseCase.getQualityPlanLocationListingFromServer({});
      expect(result, isA<FAIL>());
    });
  });


  group("Test Get Quality Plan Breadcrumb Data From Server", () {
    test("Success response", () async {
      when(() => mockQualityPlanListingUseCase.getQualityPlanBreadcrumbFromServer(any()))
          .thenAnswer((_) {
        return Future.value(SUCCESS(jsonDecode(fixture("quality_plan_breadcrumb.json")), null, null));
      });
      var result = await mockQualityPlanListingUseCase.getQualityPlanBreadcrumbFromServer({});
      expect(result, isA<SUCCESS>());
    });
    test("Fail response", () async {
      when(() => mockQualityPlanListingUseCase.getQualityPlanBreadcrumbFromServer(any()))
          .thenAnswer((_) {
        return Future.value(FAIL("", 204));
      });
      var result = await mockQualityPlanListingUseCase.getQualityPlanBreadcrumbFromServer({});
      expect(result, isA<FAIL>());
    });
  });


  group("Test Get Quality Activity Data From Server", () {
    test("Success response", () async {
      when(() => mockQualityPlanListingUseCase.getActivityListingFromServer(any()))
          .thenAnswer((_) {
        return Future.value(SUCCESS(jsonDecode(fixture("quality_activity_listing_response.json")), null, null));
      });
      var result = await mockQualityPlanListingUseCase.getActivityListingFromServer({});
      expect(result, isA<SUCCESS>());
    });
    test("Fail response", () async {
      when(() => mockQualityPlanListingUseCase.getActivityListingFromServer(any()))
          .thenAnswer((_) {
        return Future.value(FAIL("", 204));
      });
      var result = await mockQualityPlanListingUseCase.getActivityListingFromServer({});
      expect(result, isA<FAIL>());
    });
  });

  group("Test Clear Activity Data From Server", () {
    test("Success response", () async {
      when(() => mockQualityPlanListingUseCase.clearActivityData(any()))
          .thenAnswer((_) {
        return Future.value(SUCCESS(jsonDecode(fixture("quality_activity_listing_response.json")), null, null));
      });
      var result = await mockQualityPlanListingUseCase.clearActivityData({});
      expect(result, isA<SUCCESS>());
    });
    test("Fail response", () async {
      when(() => mockQualityPlanListingUseCase.clearActivityData(any()))
          .thenAnswer((_) {
        return Future.value(FAIL("", 204));
      });
      var result = await mockQualityPlanListingUseCase.clearActivityData({});
      expect(result, isA<FAIL>());
    });
  });

  group("Test Clear Activity Data From Server", () {
    test("Success response", () async {
      when(() => mockQualityPlanListingUseCase.getUserPrivilegeByProjectId(any()))
          .thenAnswer((_) {
        return Future.value(SUCCESS({"privileges":",4,54,55,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,140,145,146,147,148,149,150,151,154,160,162,170,62,69,70,82,84,126,129,161,166,167,169,","isObjectPrivacyEnable":"true"}, null, null));
      });
      var result = await mockQualityPlanListingUseCase.getUserPrivilegeByProjectId({});
      expect(result, isA<SUCCESS>());
    });
    test("Fail response", () async {
      when(() => mockQualityPlanListingUseCase.getUserPrivilegeByProjectId(any()))
          .thenAnswer((_) {
        return Future.value(FAIL("", 204));
      });
      var result = await mockQualityPlanListingUseCase.getUserPrivilegeByProjectId({});
      expect(result, isA<FAIL>());
    });
  });

}
