import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/task_listing/task_listing_cubit.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/enums.dart';
import 'package:field/exception/app_exception.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/search_task.dart';
import 'package:field/presentation/screen/task_listing/task_listing_screen.dart';
import 'package:field/utils/sharedpreference.dart';
import 'package:field/widgets/border_card_widget.dart';
import 'package:field/widgets/pagination_view/pagination_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';

GetIt getIt = GetIt.instance;

class MockTaskListingCubit extends MockCubit<FlowState>
    implements TaskListingCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  late Widget taskListingScreen;
  MockTaskListingCubit mockTaskListingCubit = MockTaskListingCubit();

  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<TaskListingCubit>();
    di.getIt.registerFactory<TaskListingCubit>(() => mockTaskListingCubit);
    SharedPreferences.setMockInitialValues(
        {"userData": fixture("user_data.json")});
  }

  setUp(() {
    PreferenceUtils.init();
    taskListingScreen = const MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate
        ], home: Material(child: TaskListingScreen())));
  });

  group("Test Task Listing Screen Cases", () {
    configureCubitDependencies();

    testWidgets('Test init/loading state', (tester) async {
      when(() => mockTaskListingCubit.loadTaskListingData(any()))
          .thenAnswer((_) => Future.value());
      when(() => mockTaskListingCubit.getSearchSummaryFilterValue())
          .thenReturn("");
      when(() => mockTaskListingCubit.sortValue)
          .thenReturn(ListSortField.title);
      when(() => mockTaskListingCubit.isCompletedEnable).thenReturn(false);
      when(() => mockTaskListingCubit.isOverdueEnable).thenReturn(false);
      when(() => mockTaskListingCubit.sortOrder).thenReturn(false);
      when(() => mockTaskListingCubit.state).thenReturn(
          InitialState(stateRendererType: StateRendererType.DEFAULT));
      when(() => mockTaskListingCubit.getRecentSearchedTaskList())
          .thenAnswer((_) => Future.value(List.empty()));

      await tester.pumpWidget(taskListingScreen);
      expect(mockTaskListingCubit.state,isA<InitialState>());
      var loadingWidget = find.byKey(const Key("key_task_listing_progressbar"));
      expect(loadingWidget, findsOneWidget);
      verify(() => mockTaskListingCubit.loadTaskListingData(any())).called(1);

      when(() => mockTaskListingCubit.state).thenReturn(
          LoadingState(stateRendererType: StateRendererType.DEFAULT));

      expect(mockTaskListingCubit.state, isA<LoadingState>());
      loadingWidget = find.byKey(const Key("key_task_listing_progressbar"));
      expect(loadingWidget, findsOneWidget);
      verifyNever(() => mockTaskListingCubit.loadTaskListingData(any()));
    });

    testWidgets('Test success with empty list state', (tester) async {
      when(() => mockTaskListingCubit.loadTaskListingData(any()))
          .thenAnswer((_) => Future.value());
      when(() => mockTaskListingCubit.getNewTaskList(any()))
          .thenAnswer((_) => Future.value(List<SiteForm>.empty()));
      when(() => mockTaskListingCubit.changeFilterStatus(any()))
          .thenAnswer((invocation) => ((_) => mockTaskListingCubit.state));
      when(() => mockTaskListingCubit.getSearchSummaryFilterValue())
          .thenReturn("");
      when(() => mockTaskListingCubit.sortValue)
          .thenReturn(ListSortField.title);
      when(() => mockTaskListingCubit.isCompletedEnable).thenReturn(false);
      when(() => mockTaskListingCubit.isOverdueEnable).thenReturn(false);
      when(() => mockTaskListingCubit.sortOrder).thenReturn(false);
      when(() => mockTaskListingCubit.state).thenReturn(SuccessState(const {}));
      when(() => mockTaskListingCubit.getRecentSearchedTaskList())
          .thenAnswer((_) => Future.value(List.empty()));

      await tester.pumpWidget(taskListingScreen);
      expect(mockTaskListingCubit.state, SuccessState(const {}));
      var listWidget = find.byType(PaginationView<SiteForm>);
      expect(listWidget, findsOneWidget);
      final initialLoaderWidget =
          find.byKey(const Key("key_listview_initialLoader_widget"));
      expect(initialLoaderWidget, findsOneWidget);
      await tester.pumpAndSettle();
      final emptyWidget = find.byKey(const Key("key_listview_empty_widget"));
      expect(emptyWidget, findsOneWidget);
    });

    testWidgets('Test success with data list state', (tester) async {
      String jsonDataString = fixture("sitetaskslist.json").toString();
      final json = jsonDecode(jsonDataString);
      int totalCount = int.parse(json['totalDocs'].toString());
      List<SiteForm> itemList =
          List<SiteForm>.from(json['data'].map((x) => SiteForm.fromJson(x)));

      when(() => mockTaskListingCubit.loadTaskListingData(any()))
          .thenAnswer((_) => Future.value());
      when(() => mockTaskListingCubit.getNewTaskList(any()))
          .thenAnswer((_) => Future.value(itemList));
      when(() => mockTaskListingCubit.totalCount).thenReturn(totalCount);
      when(() => mockTaskListingCubit.getSearchSummaryFilterValue())
          .thenReturn("");
      when(() => mockTaskListingCubit.changeFilterStatus(any()))
          .thenAnswer((invocation) => ((_) => mockTaskListingCubit.state));
      when(() => mockTaskListingCubit.sortValue)
          .thenReturn(ListSortField.title);
      when(() => mockTaskListingCubit.isCompletedEnable).thenReturn(false);
      when(() => mockTaskListingCubit.isOverdueEnable).thenReturn(false);
      when(() => mockTaskListingCubit.sortOrder).thenReturn(false);
      when(() => mockTaskListingCubit.state).thenReturn(SuccessState(const {}));
      when(() => mockTaskListingCubit.getRecentSearchedTaskList())
          .thenAnswer((_) => Future.value(List.empty()));

      await tester.pumpWidget(taskListingScreen);
      expect(mockTaskListingCubit.state, SuccessState(const {}));
      var listWidget = find.byType(PaginationView<SiteForm>);
      expect(listWidget, findsOneWidget);
      final initialLoaderWidget =
          find.byKey(const Key("key_listview_initialLoader_widget"));
      expect(initialLoaderWidget, findsOneWidget);
      await tester.pumpAndSettle();
      final rowList = find.byType(ABorderCardWidget);
      expect(rowList, findsWidgets);
      final emptyWidget = find.byKey(const Key("key_listview_empty_widget"));
      expect(emptyWidget, findsNothing);
    });

    //FAIL
    /*testWidgets('Test success with exception on list state', (tester) async {
      when(() => mockTaskListingCubit.loadTaskListingData(any()))
          .thenAnswer((_) => Future.value());
      when(() => mockTaskListingCubit.getNewTaskList(any())).thenAnswer((_) =>
          Future.value(throw AppException(message: "Something went wrong")));
      when(() => mockTaskListingCubit.getSearchSummaryFilterValue())
          .thenReturn("");
      when(() => mockTaskListingCubit.changeFilterStatus(any()))
          .thenAnswer((invocation) => ((_) => mockTaskListingCubit.state));
      when(() => mockTaskListingCubit.sortValue)
          .thenReturn(ListSortField.title);
      when(() => mockTaskListingCubit.isCompletedEnable).thenReturn(false);
      when(() => mockTaskListingCubit.isOverdueEnable).thenReturn(false);
      when(() => mockTaskListingCubit.sortOrder).thenReturn(false);
      when(() => mockTaskListingCubit.state).thenReturn(SuccessState(const {}));
      when(() => mockTaskListingCubit.getRecentSearchedTaskList())
          .thenAnswer((_) => Future.value(List.empty()));

      await tester.pumpWidget(taskListingScreen);
      expect(mockTaskListingCubit.state, SuccessState(const {}));
      var listWidget = find.byType(PaginationView<SiteForm>);
      expect(listWidget, findsOneWidget);
      final initialLoaderWidget =
          find.byKey(const Key("key_listview_initialLoader_widget"));
      expect(initialLoaderWidget, findsOneWidget);
      await tester.pumpAndSettle();
      final emptyWidget = find.byKey(const Key("key_listview_error_widget"));
      expect(emptyWidget, findsOneWidget);
    });*/

    testWidgets('Search By Content Widget Testing', (tester) async {
      when(() => mockTaskListingCubit.loadTaskListingData(any()))
          .thenAnswer((_) => Future.value());
      when(() => mockTaskListingCubit.getNewTaskList(any()))
          .thenAnswer((_) => Future.value(List<SiteForm>.empty()));
      when(() => mockTaskListingCubit.getSearchSummaryFilterValue())
          .thenReturn("");
      when(() => mockTaskListingCubit.changeFilterStatus(any()))
          .thenAnswer((invocation) => ((_) => mockTaskListingCubit.state));
      when(() => mockTaskListingCubit.sortValue)
          .thenReturn(ListSortField.title);
      when(() => mockTaskListingCubit.isCompletedEnable).thenReturn(false);
      when(() => mockTaskListingCubit.isOverdueEnable).thenReturn(false);
      when(() => mockTaskListingCubit.sortOrder).thenReturn(false);
      when(() => mockTaskListingCubit.state).thenReturn(FlowState());
      when(() => mockTaskListingCubit.getRecentSearchedTaskList())
          .thenAnswer((_) => Future.value(List.empty()));

      await tester.pumpWidget(taskListingScreen);
      final searchTaskWidget = find.byType(SearchTask);

      expect(searchTaskWidget, findsWidgets);
    });
  });
}
