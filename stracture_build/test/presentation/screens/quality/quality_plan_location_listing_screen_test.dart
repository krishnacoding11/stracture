import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/quality/quality_plan_location_listing_cubit.dart';
import 'package:field/bloc/quality/quality_plan_location_listing_state.dart';
import 'package:field/data/model/quality_plan_list_vo.dart';
import 'package:field/data/model/quality_plan_location_listing_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/screen/quality/quality_plan_location_listing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';

GetIt getIt = GetIt.instance;

class MockQualityPlanLocationListingCubit extends MockCubit<FlowState>
    implements QualityPlanLocationListingCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  late Widget qualityLocationListingScreen;
  MockQualityPlanLocationListingCubit mockQualityPlanLocationListingCubit = MockQualityPlanLocationListingCubit();

  TestWidgetsFlutterBinding.ensureInitialized();

  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<QualityPlanLocationListingCubit>();
    di.getIt.registerFactory<QualityPlanLocationListingCubit>(
        () => mockQualityPlanLocationListingCubit);
  }

  setUp(() {

    String jsonDataString = fixture("quality_plan_listing.json").toString();
    final json = jsonDecode(jsonDataString);
    QualityPlanListVo planList = QualityPlanListVo.fromJson(json);
    Data planData = planList.data![0];
    when(()=>mockQualityPlanLocationListingCubit.locationBreadcrumbList).thenAnswer((invocation) => [{"projectName":planData.projectName},{"Quality plan"},{"planName":planData.planTitle}]);

    qualityLocationListingScreen = BlocProvider(
      create: (context) => mockQualityPlanLocationListingCubit,
      child: MaterialApp(localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ], home: LocationListingScreen(qualityPlanData: planData)),

    );
  });

  group("Test Quality Plan Location Listing Screen Cases", () {
    configureCubitDependencies();
    setUp(() {
      when(() => mockQualityPlanLocationListingCubit.state).thenReturn(FlowState());
    });

    testWidgets('Test quality plan location loading widget', (tester) async {
      when(() => mockQualityPlanLocationListingCubit.state).thenReturn(
          LocationListState(null, QualityListInternalState.locationList, InternalState.loading));
      await tester.pumpWidget(qualityLocationListingScreen);
      var loadingWidget = find.byKey(const Key("key_location_listing_progressbar"));
      expect(loadingWidget, findsOneWidget);
    });

    testWidgets('Test quality plan location listing success with empty list state', (tester) async {
      when(()=> mockQualityPlanLocationListingCubit.qualityLocationList).thenAnswer((_) => []);
      when(() => mockQualityPlanLocationListingCubit.state).thenReturn(
          LocationListState(const {}, QualityListInternalState.locationList, InternalState.success));
      await tester.pumpWidget(qualityLocationListingScreen);
      final emptyWidget = find.byKey(const Key("key_no_location_found"));
      expect(emptyWidget, findsOneWidget);
    });

    testWidgets('Test quality plan location listing success with data list state', (tester) async {
      String jsonDataString = fixture("quality_plan_location_listing.json").toString();
      final json = jsonDecode(jsonDataString);
      QualityPlanLocationListingVo itemList = QualityPlanLocationListingVo.fromJson(json);
      when(() => mockQualityPlanLocationListingCubit.getLocationListFromServer())
          .thenReturn((_) => Future.value(itemList.response!.root!.locations));

      await tester.pumpWidget(qualityLocationListingScreen);
      var listWidget = find.byType(LocationListingScreen);
      expect(listWidget, findsOneWidget);
    });

    testWidgets('Test quality plan location listing with error', (tester) async {
      String jsonDataString = fixture("quality_plan_location_listing.json").toString();
      final json = jsonDecode(jsonDataString);
      QualityPlanLocationListingVo itemList = QualityPlanLocationListingVo.fromJson(json);
      when(() => mockQualityPlanLocationListingCubit.getLocationListFromServer())
          .thenAnswer((_) => Future.value(itemList.response));
      when(() => mockQualityPlanLocationListingCubit.state).thenReturn(LocationListState("Something went wrong", QualityListInternalState.locationList, InternalState.failure));

      await tester.pumpWidget(qualityLocationListingScreen);
      await tester.pump();
      final emptyWidget = find.byKey(const Key("something_went_wrong"));
      expect(emptyWidget, findsOneWidget);
    });


    testWidgets('Test quality plan breadcrumb success state', (tester) async {
      when(() => mockQualityPlanLocationListingCubit.state).thenReturn(ContentState());
      await tester.pumpWidget(qualityLocationListingScreen);
      var listWidget = find.byType(LocationListingScreen);
      expect(listWidget, findsOneWidget);
    });

    testWidgets('Test quality plan breadcrumb with error', (tester) async {
      when(() => mockQualityPlanLocationListingCubit.state).thenReturn(ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE, 'Something went wrong...'));
      await tester.pumpWidget(qualityLocationListingScreen);
      await tester.pump();
      var listWidget = find.byType(LocationListingScreen);
      expect(listWidget, findsOneWidget);
    });

    testWidgets('Test icons widget', (tester) async {
      String jsonDataString = fixture("quality_plan_location_listing.json").toString();
      final json = jsonDecode(jsonDataString);
      QualityPlanLocationListingVo itemList = QualityPlanLocationListingVo.fromJson(json);
      when(() => mockQualityPlanLocationListingCubit.selectedQualityLocation).thenReturn(itemList.response!.root!.locations!.first);
      when(() => mockQualityPlanLocationListingCubit.qualityListInternalState).thenReturn(QualityListInternalState.locationList);
      await tester.pumpWidget(qualityLocationListingScreen);
      final iconButtonMobile = find.byKey(const Key("key_quality_site_plan_widget"));
      expect(iconButtonMobile, findsOneWidget);
      expect(tester.widget<IconButton>(iconButtonMobile).onPressed,
          isNotNull);
      final refreshButtonMobile = find.byKey(const Key("quality_plan_Listing_refresh_icon"));
      expect(refreshButtonMobile, findsOneWidget);
      expect(tester.widget<IconButton>(refreshButtonMobile).onPressed,
          isNotNull);
    });

    testWidgets('Test quality plan location listing scrolling', (tester) async {
      String jsonDataString = fixture("quality_plan_location_listing.json").toString();
      final json = jsonDecode(jsonDataString);
      QualityPlanLocationListingVo itemList = QualityPlanLocationListingVo.fromJson(json);
      when(() => mockQualityPlanLocationListingCubit.getLocationListFromServer())
          .thenReturn((_) => Future.value(itemList.response!.root!.locations));

      await tester.pumpWidget(qualityLocationListingScreen);
      var listWidget = find.byType(LocationListingScreen);

      final listView = tester.widget<ListView>(find.byType(ListView));
      final ctrl = listView.controller;
      ctrl?.jumpTo(-300);
      await tester.pumpAndSettle(Duration(microseconds: 100));

      expect(listWidget, findsOneWidget);
    });
  });
}
