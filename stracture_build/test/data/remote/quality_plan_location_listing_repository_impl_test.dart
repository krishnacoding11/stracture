import 'dart:convert';

import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/quality_plan_list_vo.dart';
import 'package:field/data/model/quality_plan_location_listing_vo.dart';
import 'package:field/data/model/quality_location_breadcrumb.dart';
import 'package:field/data/remote/quality/quality_plan_listing_repository_impl.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/fixture_reader.dart';

class MockQualityPlanLocationRemoteRepository extends Mock implements QualityPlanListingRemoteRepository {}

void main() async {

  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  di.init(test: true);
  di.getIt.registerLazySingleton<MockQualityPlanLocationRemoteRepository>(() => MockQualityPlanLocationRemoteRepository());
  late MockQualityPlanLocationRemoteRepository mockQualityPlanLocationRemoteRepository;

  setUpAll(() {
    mockQualityPlanLocationRemoteRepository = di.getIt<MockQualityPlanLocationRemoteRepository>();
  });


  group("test Get Quality Plan Listing", () {
    String jsonDataString = fixture("quality_plan_listing.json");
    final json = jsonDecode(jsonDataString);
    QualityPlanListVo qualityListVo = QualityPlanListVo.fromJson(json);
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

    test("test get quality listing data", () async {
      when(() => mockQualityPlanLocationRemoteRepository.getQualityPlanListingFromServer(map)).thenAnswer((_) async => Future(() => SUCCESS(qualityListVo, null, null)));
      final result = await mockQualityPlanLocationRemoteRepository.getQualityPlanListingFromServer(map);
      expect(result, isA<SUCCESS>());
    });

    test("test get quality plan search data", ()  async{
      when(() => mockQualityPlanLocationRemoteRepository.getQualityPlanSearchFromServer(map)).thenAnswer((_) async => Future(() => SUCCESS(qualityListVo, null, null)));
      final result = await mockQualityPlanLocationRemoteRepository.getQualityPlanSearchFromServer(map);
      expect(result, isA<SUCCESS>());
    });
  });

  group("test Get Location Listing", () {
    String jsonDataString = fixture("quality_plan_location_listing.json");
    final json = jsonDecode(jsonDataString);
    QualityPlanLocationListingVo qualityPlanLocationListingVo = QualityPlanLocationListingVo.fromJson(json);

    QualityPlanLocationListingVo qualityPlanListingVO = QualityPlanLocationListingVo.fromJson(jsonDecode(fixture("quality_plan_location_listing.json")));

    Map<String, dynamic> map = {};
    map["projectId"] = qualityPlanListingVO.response!.root!.projectID!;
    map["planId"] = qualityPlanListingVO.response!.root!.planID!;
    map["qiLocationId"] = 1;

    test("test get quality location listing data", () async {
      when(() => mockQualityPlanLocationRemoteRepository.getQualityPlanLocationListingFromServer(map)).thenAnswer((_) async => Future(() => SUCCESS(qualityPlanLocationListingVo, null, null)));
      final result = await mockQualityPlanLocationRemoteRepository.getQualityPlanLocationListingFromServer(map);
      expect(result, isA<SUCCESS>());
    });

    test("test get quality location breadcrumb data", () async {
      when(() => mockQualityPlanLocationRemoteRepository.getQualityPlanBreadcrumbFromServer(map)).thenAnswer((_) async => Future(() => SUCCESS(QualityLocationBreadcrumb, null, null)));
      final result = await mockQualityPlanLocationRemoteRepository.getQualityPlanBreadcrumbFromServer(map);
      expect(result, isA<SUCCESS>());
    });
  });

  group("test Get Activity Listing", () {
    test("test get activity listing data", () async {
      when(() => mockQualityPlanLocationRemoteRepository.getActivityListingFromServer(any()))
          .thenAnswer((_) async => Future(() => SUCCESS(jsonDecode(fixture("quality_activity_listing_response.json")), null, null)));
      final result = await mockQualityPlanLocationRemoteRepository.getActivityListingFromServer({});
      expect(result, isA<SUCCESS>());
    });

    test("test clear activity data", () async {
      when(() => mockQualityPlanLocationRemoteRepository.clearActivityData(any()))
          .thenAnswer((_) async => Future(() => SUCCESS(jsonDecode(fixture("quality_activity_listing_response.json")), null, null)));
      final result = await mockQualityPlanLocationRemoteRepository.clearActivityData({});
      expect(result, isA<SUCCESS>());
    });

    test("test get user Privilege", () async {
      when(() => mockQualityPlanLocationRemoteRepository.getUserPrivilegeByProjectId(any()))
          .thenAnswer((_) async => Future(() => SUCCESS({"privileges":",4,54,55,59,63,66,71,72,73,76,86,88,90,91,92,93,94,95,96,97,98,101,103,106,113,123,127,132,133,134,136,138,139,140,145,146,147,148,149,150,151,154,160,162,170,62,69,70,82,84,126,129,161,166,167,169,","isObjectPrivacyEnable":"true"}, null, null)));
      final result = await mockQualityPlanLocationRemoteRepository.getUserPrivilegeByProjectId({});
      expect(result, isA<SUCCESS>());
    });
  });

}
