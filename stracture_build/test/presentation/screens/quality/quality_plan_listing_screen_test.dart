import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/quality/quality_plan_listing_cubit.dart';
import 'package:field/data/model/quality_plan_list_vo.dart';
import 'package:field/enums.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/screen/quality/quality_plan_listing_screen.dart';
import 'package:field/widgets/pagination_view/pagination_view.dart';
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

class MockQualityPlanListingCubit extends MockCubit<FlowState>
    implements QualityPlanListingCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  late Widget qualityListingScreen;
  MockQualityPlanListingCubit mockQualityPlanListingCubit =
      MockQualityPlanListingCubit();

  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<QualityPlanListingCubit>();
    di.getIt.registerFactory<QualityPlanListingCubit>(
        () => mockQualityPlanListingCubit);
    // SharedPreferences.setMockInitialValues(
    //     {"userData": fixture("user_data.json")});
  }

  setUp(() {
    // PreferenceUtils.init();

    qualityListingScreen = MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => di.getIt<QualityPlanListingCubit>(),
          child: const MaterialApp(localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ], home: QualityListingScreen()),
        ));
  });

  group("Test Quality Plan Listing Screen Cases", () {

    configureCubitDependencies();
    setUp(() {
      when(() => mockQualityPlanListingCubit.state).thenReturn(FlowState());
      when(() => mockQualityPlanListingCubit.sortValue)
          .thenReturn(ListSortField.title);
      when(() => mockQualityPlanListingCubit.sortOrder).thenReturn(false);
      when(() => mockQualityPlanListingCubit.state).thenReturn(
          LoadingState(stateRendererType: StateRendererType.DEFAULT));
      when(() => mockQualityPlanListingCubit.qualityMode).thenReturn(QualityMode.searchMode);
      when(() => mockQualityPlanListingCubit.isSubmitted).thenReturn(false);
      when(() => mockQualityPlanListingCubit.isSearchAlreadyLoading).thenReturn(false);
      when(() => mockQualityPlanListingCubit.getRecentQualityPlan(true)).thenAnswer((_) => Future.value());
    });

    testWidgets('Quality Widget Testing', (tester) async {
      when(() => mockQualityPlanListingCubit.state).thenReturn(
          LoadingState(stateRendererType: StateRendererType.DEFAULT));

      await tester.pumpWidget(qualityListingScreen);
      var loadingWidget = find.byKey(const Key("key_quality_plan_listing_progressbar"));
      expect(loadingWidget, findsOneWidget);
    });

    testWidgets('Test success with empty list state', (tester) async {
      when(() => mockQualityPlanListingCubit.getQualityPlanList(any()))
          .thenAnswer((_) => Future.value(List<Data>.empty()));
      when(() => mockQualityPlanListingCubit.state).thenReturn(SuccessState(const {}));
      await tester.pumpWidget(qualityListingScreen);
      expect(mockQualityPlanListingCubit.state, SuccessState(const {}));
      var listWidget = find.byType(PaginationView<Data>);
      expect(listWidget, findsOneWidget);
      final initialLoaderWidget =
      find.byKey(const Key("key_listview_initialLoader_widget"));
      expect(initialLoaderWidget, findsOneWidget);
      await tester.pumpAndSettle();
      final emptyWidget = find.byKey(const Key("key_listview_empty_widget"));
      expect(emptyWidget, findsOneWidget);
    });

    testWidgets('Test success with data list state', (tester) async {
      String jsonDataString = fixture("quality_plan_listing.json").toString();
      final json = jsonDecode(jsonDataString);
      int totalCount = int.parse(json['totalDocs'].toString());
      QualityPlanListVo itemList = QualityPlanListVo.fromJson(json);
      when(() => mockQualityPlanListingCubit.getQualityPlanList(any()))
          .thenAnswer((_) => Future.value(itemList.data));
      when(() => mockQualityPlanListingCubit.totalCount).thenReturn(totalCount);
      when(() => mockQualityPlanListingCubit.sortValue)
          .thenReturn(ListSortField.title);
      when(() => mockQualityPlanListingCubit.sortOrder).thenReturn(false);
      when(() => mockQualityPlanListingCubit.getDateInProperFormat(any())).thenReturn("15-08-22");
      when(() => mockQualityPlanListingCubit.state).thenReturn(SuccessState(const {}));

      await tester.pumpWidget(qualityListingScreen);
      expect(mockQualityPlanListingCubit.state, SuccessState(const {}));
      var listWidget = find.byType(PaginationView<Data>);
      expect(listWidget, findsOneWidget);
      final initialLoaderWidget =
      find.byKey(const Key("key_listview_initialLoader_widget"));
      expect(initialLoaderWidget, findsOneWidget);
      await tester.pumpAndSettle();
      final emptyWidget = find.byKey(const Key("key_listview_empty_widget"));
      expect(emptyWidget, findsNothing);
    });

    testWidgets('Test Sorting Widget', (tester) async {
      await tester.pumpWidget(qualityListingScreen);
      var iconButton = find.byKey(const Key("key_qualityPlanListing_sort_order_widget"));
      expect(iconButton, findsOneWidget);
      var textButton= find.byKey(const  Key('key_qualityPlanListing_sort_field_widget'));
      expect(textButton, findsOneWidget);
      when(() => mockQualityPlanListingCubit.sortValue)
          .thenReturn(ListSortField.title);
      await tester.tap((textButton));
      await tester.pump();
      expect(find.text('Name'), findsOneWidget);
    });
  });
}
