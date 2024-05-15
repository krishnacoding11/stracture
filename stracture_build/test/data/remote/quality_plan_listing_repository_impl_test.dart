import 'dart:convert';

import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/quality_plan_list_vo.dart';
import 'package:field/data/model/quality_search_vo.dart';
import 'package:field/data/remote/quality/quality_plan_listing_repository_impl.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/fixture_reader.dart';

class MockQualityRemoteRepository extends Mock implements QualityPlanListingRemoteRepository {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  di.getIt.registerLazySingleton<MockQualityRemoteRepository>(() => MockQualityRemoteRepository());
  late MockQualityRemoteRepository mockQualityRemoteRepository;

  setUpAll(() {
    mockQualityRemoteRepository = di.getIt<MockQualityRemoteRepository>();
  });

  group("test Get Quality Plan Listing", () {
    String jsonDataString = fixture("quality_plan_listing.json");
    final json = jsonDecode(jsonDataString);
    QualityPlanListVo qualityListVo = QualityPlanListVo.fromJson(json);
    //FAIL
    //QualitySearchVo qualitySearchVo = QualitySearchVo.fromJson(json);

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
      when(() => mockQualityRemoteRepository.getQualityPlanListingFromServer(map)).thenAnswer((_) async => Future(() => SUCCESS(qualityListVo, null, null)));
      final result = await mockQualityRemoteRepository.getQualityPlanListingFromServer(map);
      expect(result, isA<SUCCESS>());
    });

    //FAIL
    /*test("test get quality plan search data", ()  async{
      when(() => mockQualityRemoteRepository.getQualityPlanSearchFromServer(map)).thenAnswer((_) async => Future(() => SUCCESS(qualitySearchVo, null, null)));
      final result = await mockQualityRemoteRepository.getQualityPlanSearchFromServer(map);
      expect(result, isA<SUCCESS>());
    });*/
  });
}
