import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/QR/navigator_cubit.dart';
import 'package:field/bloc/dashboard/home_page_cubit.dart';
import 'package:field/bloc/dashboard/home_page_state.dart';
import 'package:field/bloc/recent_location/recent_location_cubit.dart';
import 'package:field/bloc/site/create_form_selection_cubit.dart';
import 'package:field/bloc/task_action_count/task_action_count_cubit.dart';
import 'package:field/bloc/task_action_count/task_action_count_state.dart';
import 'package:field/bloc/task_listing/task_listing_cubit.dart';
import 'package:field/data/model/home_page_model.dart';
import 'package:field/data/model/qrcodedata_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/data/model/taskactioncount_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/screen/homepage/home_page_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appConfig_test_data.dart';
import '../../../fixtures/fixture_reader.dart';
import '../../../sync/form_attachment_download_batch_sync_task_test.dart';
import '../site_routes/create_form_dialog/create_form_dialog_test.dart';

class MockHomePageCubit extends MockCubit<FlowState> implements HomePageCubit {}

class MockTaskActionCountCubit extends MockCubit<FlowState> implements TaskActionCountCubit {}

class MockRecentLocationCubit extends MockCubit<FlowState> implements RecentLocationCubit {}

class MockFieldNavigatorCubit extends MockCubit<FlowState> implements FieldNavigatorCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  AppConfigTestData().setupAppConfigTestData();

  MockHomePageCubit mockHomePageCubit = MockHomePageCubit();
  MockTaskActionCountCubit mockTaskActionCountCubit = MockTaskActionCountCubit();
  MockRecentLocationCubit mockRecentLocationCubit = MockRecentLocationCubit();
  MockFieldNavigatorCubit mockFieldNavigatorCubit = MockFieldNavigatorCubit();
  MockCreateFormSelectionCubit mockCreateFormSelectionCubit = MockCreateFormSelectionCubit();

  HomePageModel homePageModel = HomePageModel.fromJson(jsonDecode(fixture('homepage_item_config_data.json')));
  TaskActionCountVo? taskActionCountVo;
  var siteLocationList;

  MockAppConfig mockAppConfig = MockAppConfig();

  configureHomePageCubitDependencies() {
    di.getIt.unregister<HomePageCubit>();
    di.getIt.registerFactory<HomePageCubit>(() => mockHomePageCubit);

    di.getIt.unregister<TaskActionCountCubit>();
    di.getIt.registerFactory<TaskActionCountCubit>(() => mockTaskActionCountCubit);

    di.getIt.unregister<RecentLocationCubit>();
    di.getIt.registerFactory<RecentLocationCubit>(() => mockRecentLocationCubit);

    di.getIt.unregister<FieldNavigatorCubit>();
    di.getIt.registerFactory<FieldNavigatorCubit>(() => mockFieldNavigatorCubit);

    di.getIt.unregister<CreateFormSelectionCubit>();
    di.getIt.registerFactory<CreateFormSelectionCubit>(() => mockCreateFormSelectionCubit);
  }

  setUpAll(() async {
    await Firebase.initializeApp();
    taskActionCountVo = TaskActionCountVo.fromJson(jsonDecode(fixture("task_action_count_list.json")));
    siteLocationList = SiteLocation.jsonToList(fixture("site_location.json"));
    when(() => mockTaskActionCountCubit.getTaskActionCount()).thenAnswer((invocation) async => Future.value(jsonDecode(fixture("task_action_count_list.json"))));
    when(() => mockAppConfig.currentSelectedProject).thenAnswer((invocation) => jsonDecode(fixture("project.json")));
    registerFallbackValue(UserProjectConfigTabsDetails());
  });

  setUp(() {
    when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);
    registerFallbackValue(QRCodeDataVo());
  });

  group("Test Homepage widget", () {
    configureHomePageCubitDependencies();

    Widget testWidget = MediaQuery(
        data: const MediaQueryData(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => di.getIt<HomePageCubit>(),
            ),
            BlocProvider(create: (context) => di.getIt<TaskActionCountCubit>()),
            BlocProvider(create: (context) => di.getIt<RecentLocationCubit>()),
            BlocProvider(create: (context) => di.getIt<FieldNavigatorCubit>()),
            BlocProvider(create: (context) => di.getIt<CreateFormSelectionCubit>()),
          ],
          child: const MaterialApp(localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ], home: Material(child: Scaffold(body: HomePageView()))),
        ));

    testWidgets("Find HomePage widget", (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('Test Home Page No Project Select in Online Find', (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(HomePageNoProjectSelectState(true));
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));
      final homePageNoProjectView = find.byKey(const Key("HomePageNoProjectViewKey"));
      expect(homePageNoProjectView, findsOneWidget);
    });

    testWidgets('Test Home Page No Project Select in Offline Find', (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(HomePageNoProjectSelectState(false));
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));
      final homePageNoProjectView = find.byKey(const Key("HomePageNoProjectViewKey"));
      expect(homePageNoProjectView, findsOneWidget);
    });

    testWidgets('Test HomePage Loader Find', (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(HomePageItemLoadingState(stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE));
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));
      final homePageItemLoadingView = find.byKey(const Key("HomePageItemLoader"));
      expect(homePageItemLoadingView, findsOneWidget);
    });

    testWidgets('Test HomePage EmptyView Find', (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(HomePageEmptyState());
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));
      final homePageEmptyView = find.byKey(const Key("HomePageEmptyView"));
      expect(homePageEmptyView, findsOneWidget);
    });

    testWidgets('Test HomePage Error State View Find', (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE, ""));
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));
      final homePageErrorView = find.byKey(const Key("ErrorStateView"));
      expect(homePageErrorView, findsOneWidget);
    });

    testWidgets('Test HomePage Item View Find', (tester) async {
      when(() => mockHomePageCubit.userSelectedShortcutList).thenAnswer((invocation) => homePageModel.configJsonData!.userProjectConfigTabsDetails!);
      //get all sortcuts list
      when(() => mockHomePageCubit.state).thenReturn(HomePageItemState(mockHomePageCubit.userSelectedShortcutList, true));
      //taskcount
      when(() => mockTaskActionCountCubit.state).thenReturn(TaskActionCountState(InternalState.success, taskActionCount: taskActionCountVo!));
      //recent location
      when(() => mockRecentLocationCubit.state).thenReturn(SuccessState(siteLocationList));
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));
      final homePageItemView = find.byKey(const Key("HomePageItemView"));
      expect(homePageItemView, findsOneWidget);
    });

    testWidgets('Test HomePage Item View Edit Mode Find', (tester) async {
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => true);

      when(() => mockHomePageCubit.userSelectedShortcutList).thenAnswer((invocation) => homePageModel.configJsonData!.userProjectConfigTabsDetails!);
      //get all sortcuts list
      when(() => mockHomePageCubit.state).thenReturn(HomePageItemState(mockHomePageCubit.userSelectedShortcutList, true));
      //taskcount
      when(() => mockTaskActionCountCubit.state).thenReturn(TaskActionCountState(InternalState.success, taskActionCount: taskActionCountVo!));
      //recent location
      when(() => mockRecentLocationCubit.state).thenReturn(SuccessState(siteLocationList));
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));
      final homePageItemView = find.byKey(const Key("HomePageItemView"));
      expect(homePageItemView, findsOneWidget);
    });

    testWidgets('Test HomePage Item View Edit Mode delete Item Click Find', (tester) async {
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => true);

      when(() => mockHomePageCubit.userSelectedShortcutList).thenAnswer((invocation) => homePageModel.configJsonData!.userProjectConfigTabsDetails!);
      //get all sortcuts list
      when(() => mockHomePageCubit.state).thenReturn(HomePageItemState(mockHomePageCubit.userSelectedShortcutList, true));
      //taskcount
      when(() => mockTaskActionCountCubit.state).thenReturn(TaskActionCountState(InternalState.success, taskActionCount: taskActionCountVo!));
      //recent location
      when(() => mockRecentLocationCubit.state).thenReturn(SuccessState(siteLocationList));
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));
      final homePageItemView = find.byKey(const Key("HomePageItemView"));
      expect(homePageItemView, findsOneWidget);

      Finder deleteShortcutDialog0 = find.byKey(Key("DeleteShortcutItemDialog_0"));
      await tester.tap(deleteShortcutDialog0);
      await tester.pumpAndSettle();

      Finder deleteDialog = find.byKey(Key("Delete Dialog"));
      expect(deleteDialog, findsOneWidget);

      Finder deleteText = find.byKey(Key('remove_widget_from_home'));
      expect(deleteText, findsOneWidget);
      await tester.tap(deleteText);
      await tester.pumpAndSettle();

      verify(() => mockHomePageCubit.deleteShortcutItem(any())).called(1);
      expect(deleteDialog, findsNothing);
    });

    testWidgets('Test HomePage Item View Edit Mode delete Item Cancel Click', (tester) async {
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => true);

      when(() => mockHomePageCubit.userSelectedShortcutList).thenAnswer((invocation) => homePageModel.configJsonData!.userProjectConfigTabsDetails!);
      //get all sortcuts list
      when(() => mockHomePageCubit.state).thenReturn(HomePageItemState(mockHomePageCubit.userSelectedShortcutList, true));
      //taskcount
      when(() => mockTaskActionCountCubit.state).thenReturn(TaskActionCountState(InternalState.success, taskActionCount: taskActionCountVo!));
      //recent location
      when(() => mockRecentLocationCubit.state).thenReturn(SuccessState(siteLocationList));
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));
      final homePageItemView = find.byKey(const Key("HomePageItemView"));
      expect(homePageItemView, findsOneWidget);

      Finder deleteShortcutDialog0 = find.byKey(Key("DeleteShortcutItemDialog_0"));
      await tester.tap(deleteShortcutDialog0);
      await tester.pumpAndSettle();

      Finder deleteDialog = find.byKey(Key("Delete Dialog"));
      expect(deleteDialog, findsOneWidget);

      Finder cancelText = find.byKey(Key('cancel_delete_dialog'));
      expect(cancelText, findsOneWidget);
      await tester.tap(cancelText);
      await tester.pumpAndSettle();

      expect(deleteDialog, findsNothing);
    });

    testWidgets('Test HomePage Item View Item Click Find', (tester) async {
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);

      when(() => mockHomePageCubit.userSelectedShortcutList).thenAnswer((invocation) => homePageModel.configJsonData!.userProjectConfigTabsDetails!);
      //get all sortcuts list
      when(() => mockHomePageCubit.state).thenReturn(HomePageItemState(mockHomePageCubit.userSelectedShortcutList, true));
      //task Count
      when(() => mockTaskActionCountCubit.state).thenReturn(TaskActionCountState(InternalState.success, taskActionCount: taskActionCountVo!));
      //recent location
      when(() => mockRecentLocationCubit.state).thenReturn(SuccessState(siteLocationList));

      when(() => mockFieldNavigatorCubit.checkQRCodePermission(any())).thenAnswer((invocation) => Future.value());

      when(() => mockCreateFormSelectionCubit.getDefaultSiteApp(any())).thenAnswer((invocation) => Future.value());

      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));
      final homePageItemView = find.byKey(const Key("HomePageItemView"));
      expect(homePageItemView, findsOneWidget);

      Finder onShortcutTapListener0 = find.byKey(Key("onShortcutTapListener_0"));
      await tester.tap(onShortcutTapListener0);
      await tester.pumpAndSettle();

      Finder onShortcutTapListener1 = find.byKey(Key("onShortcutTapListener_1"));
      await tester.tap(onShortcutTapListener1);
      await tester.pumpAndSettle();

      Finder onShortcutTapListener2 = find.byKey(Key("onShortcutTapListener_2"));
      await tester.tap(onShortcutTapListener2);
      await tester.pumpAndSettle();

      Finder onShortcutTapListener3 = find.byKey(Key("onShortcutTapListener_3"));
      await tester.tap(onShortcutTapListener3);
      await tester.pumpAndSettle();

      Finder onShortcutTapListener4 = find.byKey(Key("onShortcutTapListener_4"));
      await tester.tap(onShortcutTapListener4);
      await tester.pumpAndSettle();

      Finder onShortcutTapListener5 = find.byKey(Key("onShortcutTapListener_5"));
      await tester.tap(onShortcutTapListener5);
      await tester.pumpAndSettle();

      Finder onShortcutTapListener6 = find.byKey(Key("onShortcutTapListener_6"));
      await tester.tap(onShortcutTapListener6);
      await tester.pumpAndSettle();

      Finder onShortcutTapListener7 = find.byKey(Key("onShortcutTapListener_7"));
      await tester.tap(onShortcutTapListener7);
      await tester.pumpAndSettle();

      Finder onShortcutTapListener8 = find.byKey(Key("onShortcutTapListener_8"));
      await tester.tap(onShortcutTapListener8);
      await tester.pumpAndSettle();
    });

    testWidgets('Test update shortcuts list progress dialog', (tester) async {
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => true);

      final expectedStates = [UpdateShortcutListProgressState(true)];
      whenListen(mockHomePageCubit, Stream.fromIterable(expectedStates));

      when(() => mockHomePageCubit.state).thenReturn(UpdateShortcutListProgressState(true));
      await tester.pumpWidget(testWidget);
      await tester.pump();
    });

    testWidgets('Test get pending shortcuts list', (tester) async {
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => true);
      when(() => mockHomePageCubit.pendingShortcutList).thenAnswer((invocation) => homePageModel.configJsonData!.userProjectConfigTabsDetails!);
      when(() => mockHomePageCubit.addedShortcutList).thenAnswer((invocation) => []);

      final expectedStates = [PendingShortcutItemState(mockHomePageCubit.pendingShortcutList)];
      whenListen(mockHomePageCubit, Stream.fromIterable(expectedStates));

      when(() => mockHomePageCubit.state).thenReturn(PendingShortcutItemState(mockHomePageCubit.pendingShortcutList));
      await tester.pumpWidget(testWidget);
      await tester.pump();
    });

    testWidgets('Test reach add shortcut limit reach ', (tester) async {
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => true);
      when(() => mockHomePageCubit.pendingShortcutList).thenAnswer((invocation) => homePageModel.configJsonData!.userProjectConfigTabsDetails!);

      final expectedStates = [ReachedConfigureLimitState()];
      whenListen(mockHomePageCubit, Stream.fromIterable(expectedStates));

      when(() => mockHomePageCubit.state).thenReturn(ReachedConfigureLimitState());
      await tester.pumpWidget(testWidget);
      await tester.pump();
    });

    testWidgets('Test add more shortcuts error state ', (tester) async {
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => true);

      final expectedStates = [AddMoreErrorState("")];
      whenListen(mockHomePageCubit, Stream.fromIterable(expectedStates));

      when(() => mockHomePageCubit.state).thenReturn(AddMoreErrorState(""));
      await tester.pumpWidget(testWidget);
      await tester.pump();
    });

    testWidgets('Test home page edit state error', (tester) async {
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => true);

      final expectedStates = [HomePageEditErrorState("")];
      whenListen(mockHomePageCubit, Stream.fromIterable(expectedStates));

      when(() => mockHomePageCubit.state).thenReturn(HomePageEditErrorState(""));
      await tester.pumpWidget(testWidget);
      await tester.pump();
    });

    testWidgets('Test edit mode done button click', (tester) async {
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => true);

      when(() => mockHomePageCubit.state).thenReturn(HomePageItemState(homePageModel.configJsonData!.userProjectConfigTabsDetails!, true));
      await tester.pumpWidget(testWidget);
      await tester.pump(Duration(seconds: 1));

      final editButtonClick = find.byKey(Key("OnPressDoneButton"));
      await tester.tap(editButtonClick);
      await tester.pumpAndSettle();
    });

    testWidgets('Test add pending progress view', (tester) async {
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => true);
      when(() => mockHomePageCubit.state).thenReturn(AddPendingProgressState(true));

      await tester.pumpWidget(testWidget);
      await tester.pump(Duration(seconds: 1));

      final addPendingProgressState = find.byKey(Key('AddPendingProgressStateKey'));
      expect(addPendingProgressState, findsOneWidget);
    });

    testWidgets('Test add pending item button', (tester) async {
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => true);

      when(() => mockHomePageCubit.state).thenReturn(HomePageItemState(homePageModel.configJsonData!.userProjectConfigTabsDetails!, true));
      await tester.pumpWidget(testWidget);
      await tester.pump(Duration(seconds: 1));

      when(() => mockHomePageCubit.state).thenReturn(AddPendingProgressState(false));
      when(() => mockHomePageCubit.canConfigureMoreShortcuts()).thenReturn(true);
      when(() => mockHomePageCubit.getPendingShortcutConfigList()).thenAnswer((invocation) => Future.value());

      final addButtonClick = find.byKey(Key('PendingItemAddButton'));
      await tester.tap(addButtonClick);
      await tester.pumpAndSettle();
    });

    testWidgets('Test edit button click', (tester) async {
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);

      when(() => mockHomePageCubit.state).thenReturn(HomePageItemState(homePageModel.configJsonData!.userProjectConfigTabsDetails!, true));
      await tester.pumpWidget(testWidget);
      await tester.pump(Duration(seconds: 1));

      final addButtonClick = find.byKey(Key('EditButtonClick'));
      await tester.tap(addButtonClick);
      await tester.pumpAndSettle();
    });

    testWidgets('Test did update widget method finds', (tester) async {
      when(() => mockHomePageCubit.isEditEnable).thenAnswer((invocation) => false);

      when(() => mockHomePageCubit.state).thenReturn(HomePageItemState(homePageModel.configJsonData!.userProjectConfigTabsDetails!, true));
      await tester.pumpWidget(testWidget);
      await tester.pump(Duration(seconds: 1));

      Widget homePageChange = MediaQuery(
          data: const MediaQueryData(),
          child: MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => di.getIt<HomePageCubit>(),
              ),
              BlocProvider(create: (context) => di.getIt<TaskActionCountCubit>()),
              BlocProvider(create: (context) => di.getIt<RecentLocationCubit>()),
              BlocProvider(create: (context) => di.getIt<FieldNavigatorCubit>()),
              BlocProvider(create: (context) => di.getIt<CreateFormSelectionCubit>()),
            ],
            child: const MaterialApp(localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ], home: Material(child: Scaffold(body: HomePageView()))),
          ));

      when(() => mockHomePageCubit.isNeedToRefresh()).thenAnswer((invocation) => Future.value(true));
      await tester.pumpWidget(homePageChange);
      await tester.pump(Duration(seconds: 1));
    });
  });
}
