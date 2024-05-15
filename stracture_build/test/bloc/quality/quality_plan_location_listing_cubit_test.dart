import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/quality/quality_plan_location_listing_cubit.dart';
import 'package:field/bloc/quality/quality_plan_location_listing_state.dart';
import 'package:field/data/model/quality_activity_list_vo.dart';
import 'package:field/data/model/quality_location_breadcrumb.dart';
import 'package:field/data/model/updated_activity_list_vo.dart';
import 'package:field/domain/use_cases/quality/quality_plan_listing_usecase.dart';
import 'package:field/injection_container.dart' as container;
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';
import '../../utils/load_url.dart';
import '../mock_method_channel.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  final mockUseCase = MockQualityLocationListingUseCase();
  late QualityPlanLocationListingCubit qualityPlanLocationListingCubit;

  configureCubitDependencies() {
    container.init(test: true);
    SharedPreferences.setMockInitialValues({
     // "userData":fixture("user_data.json"),
      "cloud_type_data":"1",
      "1_u1_project_":fixture("project.json")
    });
    AppConfigTestData().setupAppConfigTestData();
    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AConstants.loadProperty();
  }

  setUp(() {
    qualityPlanLocationListingCubit = QualityPlanLocationListingCubit(useCase: mockUseCase);
    qualityPlanLocationListingCubit.projectId = "2116416";
    qualityPlanLocationListingCubit.planId= "5251";
    qualityPlanLocationListingCubit.sitelocationId = "35690";
  });

  group("Quality location listing cubit:", ()
   {
    configureCubitDependencies();

    blocTest<QualityPlanLocationListingCubit, FlowState>(
        "Quality Plan Location Listing Success State on server response",
        build: () {
          return qualityPlanLocationListingCubit;
        },
        act: (c) async {
          when(() => mockUseCase.getQualityPlanLocationListingFromServer(any()))
              .thenAnswer((_) async =>
              Future(() =>
                  SUCCESS<dynamic>(
                      jsonDecode(fixture("quality_plan_location_listing.json")), null,
                      200)));

          await qualityPlanLocationListingCubit.getLocationListFromServer(isLoading: true,currentLocationId: "");
        },
        expect: () => [isA<LocationListState>(), isA<LocationListState>()]
    );


    blocTest<QualityPlanLocationListingCubit, FlowState>(
        "Quality Plan Location Listing emits [Error] state",
        build: () {
          return qualityPlanLocationListingCubit;
        },
        act: (cubit) async {
          when(() => mockUseCase.getQualityPlanLocationListingFromServer(any()))
              .thenAnswer((_) async =>
              Future(() {
                return FAIL("Failed", 204);
              }));
          await qualityPlanLocationListingCubit.getLocationListFromServer(isLoading: true,currentLocationId: "");
        },
        expect: () => [isA<LocationListState>(), isA<LocationListState>()]
    );


    blocTest<QualityPlanLocationListingCubit, FlowState>(
        "Quality Plan Breadcrumb Success State on server response",
        build: () {
          return qualityPlanLocationListingCubit;
        },
        act: (c) async {
          when(() => mockUseCase.getQualityPlanBreadcrumbFromServer(any()))
              .thenAnswer((_) async =>
              Future(() =>
                  SUCCESS(QualityLocationBreadcrumb.fromJson(fixture("quality_plan_breadcrumb.json")), null,
                      200)));

          await qualityPlanLocationListingCubit.getLocationBreadCrumbFromServer();
        },
        expect: () => [isA<LocationListState>()]
    );

    blocTest<QualityPlanLocationListingCubit, FlowState>(
        "Quality Plan Breadcrumb emits [Error] state",
        build: () {
          return qualityPlanLocationListingCubit;
        },
        act: (cubit) async {
          when(() => mockUseCase.getQualityPlanBreadcrumbFromServer(any()))
              .thenAnswer((_) async =>
              Future(() {
                return FAIL("Failed", 204);
              }));
          await qualityPlanLocationListingCubit.getLocationBreadCrumbFromServer();
        },
        expect: () => [isA<ErrorState>()]
    );

    blocTest<QualityPlanLocationListingCubit, FlowState>(
        "Quality Activity Listing Success State on server response",
        build: () {
          return qualityPlanLocationListingCubit;
        },
        act: (c) async {
          when(() => mockUseCase.getActivityListingFromServer(any()))
              .thenAnswer((_) async =>
              Future(() {
                return SUCCESS(jsonDecode(
                    fixture("quality_activity_listing_response.json")), null, null);
              }));
          await qualityPlanLocationListingCubit.getActivityList(true);
        },
        expect: () => [isA<ActivityListState>(), isA<ActivityListState>()],
    );

    blocTest<QualityPlanLocationListingCubit, FlowState>(
      "Quality Activity Listing Success State, but get uneven response ",
      build: () {
        return qualityPlanLocationListingCubit;
      },
      act: (c) async {
        when(() => mockUseCase.getActivityListingFromServer(any()))
            .thenAnswer((_) async =>
            Future(() {
              return SUCCESS(const {
              "msg": "Success",
              "response": {}}, null, null);
            }));
        await qualityPlanLocationListingCubit.getActivityList(true);
      },
      expect: () => [isA<ActivityListState>(), isA<ActivityListState>()],
    );

    blocTest<QualityPlanLocationListingCubit, FlowState>("Quality Activity Listing emits [Error] state",
        build: () {
          return qualityPlanLocationListingCubit;
        },
        act: (cubit) async {
          when(() => mockUseCase.getActivityListingFromServer(any()))
              .thenAnswer((_) async =>
              Future(() {
                return FAIL("Failed", 204);
              }));
          await qualityPlanLocationListingCubit.getActivityList(true);
        },
        expect: () => [isA<ActivityListState>(), isA<ActivityListState>()]
    );



    blocTest<QualityPlanLocationListingCubit, FlowState>("Quality Remove Activity Listing emits [Error] state",
        build: () {
          return qualityPlanLocationListingCubit;
        },
        act: (cubit) async {
          var data = QualityActivityList.fromJson(jsonDecode(
              fixture("quality_activity_listing_response.json")));
          when(() => mockUseCase.clearActivityData(any()))
              .thenAnswer((_) async =>
              Future(() {
                return FAIL("Failed", 204);
              }));
          await qualityPlanLocationListingCubit.clearActivityData(data.response!.root!.activitiesList![0].deliverableActivities![0]);
        },
        expect: () => [isA<ActivityListState>()]
    );


    blocTest<QualityPlanLocationListingCubit, FlowState>(
      "Update And Refresh Breadcrumb and Activity Listing Success State on server response",
      build: () {
        return qualityPlanLocationListingCubit;
      },
      act: (c) async {
        when(() => mockUseCase.getQualityPlanBreadcrumbFromServer(any()))
            .thenAnswer((_) async =>
            Future(() =>
                SUCCESS(QualityLocationBreadcrumb.fromJson(fixture("quality_plan_breadcrumb.json")), null,
                    200)));


        when(() => mockUseCase.getActivityListingFromServer(any()))
            .thenAnswer((_) async =>
            Future(() {return SUCCESS(jsonDecode(fixture("quality_activity_listing_response.json")), null, null);})
        );
        qualityPlanLocationListingCubit.setPlanPercentage = 25;
        qualityPlanLocationListingCubit.getLocationBreadCrumbFromServer();
        qualityPlanLocationListingCubit.getActivityList(true);
      },
      expect: () => [isA<ActivityListState>(), isA<ActivityListState>(), isA<ActivityListState>()],
    );

    blocTest<QualityPlanLocationListingCubit, FlowState>(
      "Update And Refresh Breadcrumb and Location Listing Success State on server response",
      build: () {
        return qualityPlanLocationListingCubit;
      },
      act: (c) async {
        when(() => mockUseCase.getQualityPlanBreadcrumbFromServer(any()))
            .thenAnswer((_) async =>
            Future(() =>
                SUCCESS(QualityLocationBreadcrumb.fromJson(fixture("quality_plan_breadcrumb.json")), null,
                    200)));

        when(() => mockUseCase.getQualityPlanLocationListingFromServer(any()))
            .thenAnswer((_) async =>
            Future(() =>
                SUCCESS<dynamic>(
                    jsonDecode(fixture("quality_plan_location_listing.json")), null,
                    200)));

        qualityPlanLocationListingCubit.getLocationBreadCrumbFromServer();
        qualityPlanLocationListingCubit.getLocationListFromServer(isLoading: true,currentLocationId: "");
      },
      expect: () => [isA<LocationListState>(), isA<LocationListState>(), isA<LocationListState>()],
    );

    blocTest<QualityPlanLocationListingCubit, FlowState>(
      "Quality Remove Activity Listing Success State on server response",
      build: () {
        return qualityPlanLocationListingCubit;
      },
      act: (c) async {
        QualityActivityList data = QualityActivityList.fromJson(jsonDecode(
            fixture("quality_activity_listing_response.json")));
        when(() => mockUseCase.clearActivityData(any()))
            .thenAnswer((_) async =>
            Future(() {
              return SUCCESS(UpdatedActivityListVo.fromJson(jsonDecode(
                  fixture("quality_plan_remove_activity_response.json"))), null, 200);
            })
        );
        await qualityPlanLocationListingCubit.clearActivityData(data.response!.root!.activitiesList![3].deliverableActivities![0]);
      },
      expect: () => [isA<ActivityListState>()],
    );


  });
}

class MockQualityLocationListingUseCase extends Mock implements QualityPlanListingUseCase {}