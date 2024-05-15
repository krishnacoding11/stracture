import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/quality/quality_plan_listing_cubit.dart';
import 'package:field/data/model/quality_search_vo.dart';
import 'package:field/domain/use_cases/quality/quality_plan_listing_usecase.dart';
import 'package:field/injection_container.dart' as container;
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fixtures/fixture_reader.dart';
import '../mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  container.init(test: true);
  final mockUseCase = MockQualityPlanListingUseCase();
  late QualityPlanListingCubit qualityPlanListingCubit;
  late FilterQueryVOs suggessionList;
  setUp(() {
    qualityPlanListingCubit = QualityPlanListingCubit(useCase: mockUseCase);
    Map<String, dynamic> data = jsonDecode(fixture("quality_search.json"));
    suggessionList = FilterQueryVOs.fromJson(data);
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json"), "1_808581_project": fixture("project.json")});
    MockMethodChannel().setAsitePluginsMethodChannel();
  });

  group("Quality plan listing cubit:", () {
    blocTest<QualityPlanListingCubit, FlowState>("Fail on server response",
        build: () {
          return qualityPlanListingCubit;
        },
        act: (c) async {
          await c.getQualityPlanList(0);
        },
        expect: () => []);

    blocTest<QualityPlanListingCubit, FlowState>("Success on server response",
        build: () {
          return qualityPlanListingCubit;
        },
        act: (c) async {
          when(() => mockUseCase.getQualityPlanListingFromServer(any())).thenAnswer((_) async => Future(() => SUCCESS<dynamic>(fixture("quality_plan_listing.json"), null, 200)));
          await c.getQualityPlanList(0);
        },
        expect: () => []);

    blocTest<QualityPlanListingCubit, FlowState>(
        "emits [Success] state",
        build: () {
          return qualityPlanListingCubit;
        },
        act: (cubit) async {
          when(() => mockUseCase.getQualityPlanListingFromServer(any())).thenAnswer((_) async => Future(() => SUCCESS<dynamic>(fixture("quality_plan_listing.json"), null, 200)));
        cubit.getSuggestedSearchList("tes",isFromSuggestion: false,offset: 0);
          },
        expect: () => []
    );
    blocTest<QualityPlanListingCubit, FlowState>(
        "Add Recent Quality PlanList Search",
        build: () {
          return qualityPlanListingCubit;
        },
        act: (cubit) async {
          cubit.addRecentQualityPlanList(qualityPlanTitle:"abed");
        },
        expect: () => []
    );
  });
}

class MockQualityPlanListingUseCase extends Mock implements QualityPlanListingUseCase {}
