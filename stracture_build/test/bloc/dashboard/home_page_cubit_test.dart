import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/dashboard/home_page_cubit.dart';
import 'package:field/bloc/dashboard/home_page_state.dart';
import 'package:field/bloc/recent_location/recent_location_cubit.dart';
import 'package:field/bloc/task_action_count/task_action_count_cubit.dart';
import 'package:field/data/local/project_list/project_list_local_repository.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/home_page_model.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/dashboard/homepage_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/appConfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';
import '../../utils/load_url.dart';
import '../mock_method_channel.dart';

class MockHomePageUseCase extends Mock implements HomePageUseCase {}

class MockInternetCubit extends Mock implements InternetCubit {}

class MockTaskActionCountCubit extends Mock implements TaskActionCountCubit {}

class MockRecentLocationCubit extends Mock implements RecentLocationCubit {}

class MockProjectListLocalRepository extends Mock implements ProjectListLocalRepository {}

class DBServiceMock extends Mock implements DBService {}

class MockDatabaseManager extends Mock implements DatabaseManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();
  MockMethodChannel().setConnectivity();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  final MockHomePageUseCase mockHomePageUseCase = MockHomePageUseCase();
  final MockInternetCubit mockInternetCubit = MockInternetCubit();
  final MockTaskActionCountCubit mockTaskActionCountCubit = MockTaskActionCountCubit();
  final MockRecentLocationCubit mockRecentLocationCubit = MockRecentLocationCubit();
  final MockProjectListLocalRepository mockProjectListLocalRepository = MockProjectListLocalRepository();
  late HomePageCubit homePageCubit;
  late HomePageModel pendingHomePageData;
  late HomePageModel homePageData;
  DBServiceMock mockDb;

  configureCubitDependencies() {
    di.getIt.unregister<HomePageUseCase>();
    di.getIt.registerFactory<HomePageUseCase>(() => mockHomePageUseCase);
    di.getIt.unregister<InternetCubit>();
    di.getIt.registerFactory<InternetCubit>(() => mockInternetCubit);
    di.getIt.unregister<TaskActionCountCubit>();
    di.getIt.registerFactory<TaskActionCountCubit>(() => mockTaskActionCountCubit);
    di.getIt.unregister<RecentLocationCubit>();
    di.getIt.registerFactory<RecentLocationCubit>(() => mockRecentLocationCubit);
    di.getIt.unregister<ProjectListLocalRepository>();
    di.getIt.registerFactory<ProjectListLocalRepository>(() => mockProjectListLocalRepository);
    mockDb = DBServiceMock();
    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb);

    AppConfigTestData().setupAppConfigTestData();
    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AConstants.loadProperty();
  }

  setUpAll(() async {
    await Firebase.initializeApp();
    MockMethodChannel().setAsitePluginsMethodChannel();
    mockDb = DBServiceMock();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  });

  setUp(() {
    when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
    AppConfigTestData().setupAppConfigTestData();
    homePageCubit = HomePageCubit();
    homePageData = HomePageModel.fromJson(jsonDecode(fixture("homepage_item_config_data.json")));
    pendingHomePageData = HomePageModel.fromJson(jsonDecode(fixture("homepage_pending_list_config_data.json")));
  });

  // tearDown(() {
  //   mockDb = null;
  // });

  group("Home Page Cubit Test", () {
    configureCubitDependencies();

    blocTest<HomePageCubit, FlowState>("Init Data Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          when(() => mockRecentLocationCubit.initData()).thenReturn(null);
          when(() => mockTaskActionCountCubit.getTaskActionCount()).thenAnswer((invocation) async => null);
          when(() => mockHomePageUseCase.getShortcutConfigList(any())).thenAnswer((_) async => Future(() => SUCCESS<dynamic>(homePageData, null, 200)));
          await cubit.initData();
        },
        expect: () => [isA<HomePageItemLoadingState>(), isA<HomePageItemState>()]);

    blocTest<HomePageCubit, FlowState>("Init Data Project Selected in offline Mode Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          when(() => mockRecentLocationCubit.initData()).thenReturn(null);
          when(() => mockTaskActionCountCubit.getTaskActionCount()).thenAnswer((invocation) async => null);
          when(() => mockHomePageUseCase.getShortcutConfigList(any())).thenAnswer((_) async => Future(() => SUCCESS<dynamic>(homePageData, null, 200)));
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(false);
          when(() => mockProjectListLocalRepository.getMarkedOfflineProjects()).thenAnswer((_) async => [Project.fromJson(jsonDecode(fixture('project.json')))]);
          await cubit.initData();
        },
        expect: () => [isA<HomePageItemLoadingState>(), isA<HomePageItemState>()]);

    blocTest<HomePageCubit, FlowState>("Init Data No Project Selected in offline Mode Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(false);
          when(() => mockProjectListLocalRepository.getMarkedOfflineProjects()).thenAnswer((_) async => []);
          await cubit.initData();
        },
        expect: () => [isA<HomePageItemLoadingState>(), isA<HomePageNoProjectSelectState>()]);

    blocTest<HomePageCubit, FlowState>("Get Shortcut Config List Success Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          when(() => mockRecentLocationCubit.initData()).thenReturn(null);
          when(() => mockTaskActionCountCubit.getTaskActionCount()).thenAnswer((invocation) async => null);
          when(() => mockHomePageUseCase.getShortcutConfigList(any())).thenAnswer((_) async => Future(() => SUCCESS<dynamic>(homePageData, null, 200)));
          await cubit.getShortcutConfigList('2089700\$\$jpmd7h');
        },
        expect: () => [isA<HomePageItemState>()]);

    blocTest<HomePageCubit, FlowState>("Get Empty Shortcut Config List Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          when(() => mockRecentLocationCubit.initData()).thenReturn(null);
          when(() => mockTaskActionCountCubit.getTaskActionCount()).thenAnswer((invocation) async => null);
          homePageData.configJsonData!.userProjectConfigTabsDetails!.clear();
          when(() => mockHomePageUseCase.getShortcutConfigList(any())).thenAnswer((_) async => Future(() => SUCCESS<dynamic>(homePageData, null, 200)));
          await cubit.getShortcutConfigList('2089700\$\$jpmd7h');
        },
        expect: () => [isA<HomePageEmptyState>()]);

    blocTest<HomePageCubit, FlowState>("Get Shortcut Config List Fail Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          when(() => mockHomePageUseCase.getShortcutConfigList(any())).thenAnswer((_) async => Future(() => FAIL("Error", 401)));
          await cubit.getShortcutConfigList('2089700\$\$jpmd7h');
        },
        expect: () => [isA<ErrorState>()]);

    blocTest<HomePageCubit, FlowState>("On Change Edit Mode  (Editable to Non Editable)  Success Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          homePageCubit.isEditEnable = true;
          homePageCubit.editModeShortcutList = homePageData.configJsonData!.userProjectConfigTabsDetails!;
          homePageCubit.userSelectedShortcutList = [...homePageData.configJsonData!.userProjectConfigTabsDetails!];
          homePageCubit.userSelectedShortcutList[2] = UserProjectConfigTabsDetails(id: "4", name: "Task Due This Week", config: {});
          when(() => mockHomePageUseCase.updateShortcutConfigList(any())).thenAnswer((_) async => Future(() => SUCCESS<dynamic>(homePageData, null, 200)));
          await cubit.onChangeEditMode();
        },
        expect: () => [isA<UpdateShortcutListProgressState>(), isA<UpdateShortcutListProgressState>(), isA<HomePageItemState>()]);

    blocTest<HomePageCubit, FlowState>("On Change Edit Mode When Nothing Changed Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          homePageCubit.isEditEnable = true;
          await cubit.onChangeEditMode();
        },
        expect: () => [isA<HomePageEmptyState>()]);

    blocTest<HomePageCubit, FlowState>("On Change Edit Mode  (Editable to Non Editable)  Fail Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          homePageCubit.isEditEnable = true;
          homePageCubit.editModeShortcutList = homePageData.configJsonData!.userProjectConfigTabsDetails!;
          homePageCubit.userSelectedShortcutList = [...homePageData.configJsonData!.userProjectConfigTabsDetails!];
          homePageCubit.userSelectedShortcutList[2] = UserProjectConfigTabsDetails(id: "4", name: "Task Due This Week", config: {});
          when(() => mockHomePageUseCase.updateShortcutConfigList(any())).thenAnswer((_) async => Future(() => FAIL("Error", 401)));
          await cubit.onChangeEditMode();
        },
        expect: () => [isA<UpdateShortcutListProgressState>(), isA<UpdateShortcutListProgressState>(), isA<HomePageEditErrorState>()]);

    blocTest<HomePageCubit, FlowState>("On Change Edit Mode (Non Editable To Editable) Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          homePageCubit.isEditEnable = false;
          homePageCubit.editModeShortcutList = homePageData.configJsonData!.userProjectConfigTabsDetails!;
          homePageCubit.userSelectedShortcutList = [...homePageData.configJsonData!.userProjectConfigTabsDetails!];
          await cubit.onChangeEditMode();
        },
        expect: () => [isA<HomePageItemState>()]);

    blocTest<HomePageCubit, FlowState>("Delete Shortcut Item Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          cubit.editModeShortcutList = homePageData.configJsonData!.userProjectConfigTabsDetails!;
          cubit.deleteShortcutItem(homePageData.configJsonData!.userProjectConfigTabsDetails![1]);
        },
        expect: () => [isA<HomePageItemState>()]);

    blocTest<HomePageCubit, FlowState>("Get Pending ShortCutList Success Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          cubit.editModeShortcutList = pendingHomePageData.configJsonData!.userProjectConfigTabsDetails!;
          cubit.deletedShortcutList = pendingHomePageData.configJsonData!.userProjectConfigTabsDetails!;
          when(() => mockHomePageUseCase.getPendingShortcutConfigList(any())).thenAnswer((_) async => Future(() => SUCCESS<dynamic>(pendingHomePageData, null, 200)));
          await cubit.getPendingShortcutConfigList();
        },
        expect: () => [isA<AddPendingProgressState>(), isA<AddPendingProgressState>(), isA<PendingShortcutItemState>()]);

    blocTest<HomePageCubit, FlowState>("Get Pending ShortCutList Fail Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          when(() => mockHomePageUseCase.getPendingShortcutConfigList(any())).thenAnswer((_) async => Future(() => FAIL("Error", 401)));
          await cubit.getPendingShortcutConfigList();
        },
        expect: () => [isA<AddPendingProgressState>(), isA<AddPendingProgressState>(), isA<AddMoreErrorState>()]);

    blocTest("Update Edit Mode List From Drag",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          List<DraggableGridItem> list = [DraggableGridItem(isDraggable: false, dragData: homePageData.configJsonData!.userProjectConfigTabsDetails![0], child: Container())];
          cubit.updateEditModeListFromDrag(list);
        },
        expect: () => []);

    blocTest("Is Need To Refresh Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          cubit.isNeedToRefresh();
        },
        expect: () => []);

    blocTest("isBackFromEditMode",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          cubit.isEditEnable = true;
          await cubit.isBackFromEditMode();
        },
        expect: () => [isA<HomePageItemState>()]);

    blocTest<HomePageCubit, FlowState>("Emit Home State",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          cubit.emitState(HomePageItemState(cubit.editModeShortcutList, cubit.isEditEnable));
        },
        expect: () => [isA<HomePageItemState>()]);

    blocTest<HomePageCubit, FlowState>("Update HomePage After Dialog Dismiss Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          cubit.deletedShortcutList = [...homePageData.configJsonData!.userProjectConfigTabsDetails!];
          List<UserProjectConfigTabsDetails> data = [homePageData.configJsonData!.userProjectConfigTabsDetails![1]];
          cubit.updateHomePageAfterDialogDismiss(data);
        },
        expect: () => [isA<HomePageItemState>()]);

    blocTest<HomePageCubit, FlowState>("Handle On Tap Add More Shortcut Item (UnAdded to Added) Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          List<UserProjectConfigTabsDetails> shortCutList = pendingHomePageData.configJsonData!.userProjectConfigTabsDetails!;
          homePageCubit.editModeShortcutList = homePageData.configJsonData!.userProjectConfigTabsDetails!;
          cubit.handleOnTapAddMoreShortcutItem(shortCutList, shortCutList[2]);
        },
        expect: () => [isA<ItemToggleState>()]);

    blocTest<HomePageCubit, FlowState>("Handle On Tap Add More Shortcut Item (Added to UnAdded) Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          List<UserProjectConfigTabsDetails> shortCutList = pendingHomePageData.configJsonData!.userProjectConfigTabsDetails!;
          shortCutList[2].isAdded = true;
          cubit.editModeShortcutList = homePageData.configJsonData!.userProjectConfigTabsDetails!;
          cubit.handleOnTapAddMoreShortcutItem(shortCutList, shortCutList[2]);
        },
        expect: () => [isA<ItemToggleState>()]);

    blocTest<HomePageCubit, FlowState>("Emit Add More Search State Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) {
          cubit.emitAddMoreSearchState(pendingHomePageData.configJsonData!.userProjectConfigTabsDetails!);
        },
        expect: () => [isA<AddMoreSearchState>()]);

    blocTest<HomePageCubit, FlowState>("Check Max HomePage Shortcut Config Limit Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          cubit.editModeShortcutList = pendingHomePageData.configJsonData!.userProjectConfigTabsDetails!;
          when(() => mockHomePageUseCase.getPendingShortcutConfigList(any())).thenAnswer((_) async => Future(() => SUCCESS<dynamic>(pendingHomePageData, null, 200)));
          cubit.checkMaxHomePageShortcutConfigLimit();
        },
        expect: () => [isA<AddPendingProgressState>()]);

    blocTest<HomePageCubit, FlowState>("Check Max HomePage Shortcut Config Limit Test 2",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          List<UserProjectConfigTabsDetails> shortCutList = [];
          for (int i = 0; i <= 5; i++) {
            shortCutList.addAll(pendingHomePageData.configJsonData!.userProjectConfigTabsDetails!);
          }
          cubit.editModeShortcutList = [...shortCutList];
          cubit.checkMaxHomePageShortcutConfigLimit();
        },
        expect: () => [isA<ReachedConfigureLimitState>()]);

    blocTest<HomePageCubit, FlowState>("Show site task form dialog no site task configure Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          cubit.showSiteTaskFormDialog(null);
        },
        expect: () => [isA<NoFormsMessageState>()]);

    blocTest<HomePageCubit, FlowState>("Show site task form dialog (online) Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          final appTypeListData = jsonDecode(fixture("app_type_list.json"));
          List<AppType> appList = [];
          for (var item in appTypeListData["data"]) {
            appList.add(AppType.fromJson(item));
          }
          final appType = appList.where((element) => element.isMarkDefault == true).toList();
          await cubit.showSiteTaskFormDialog(appType.first);
        },
        expect: () => [isA<ShowFormCreateDialogState>()]);

    blocTest<HomePageCubit, FlowState>("Show site task form dialog (offline) Test",
        build: () {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(false);
          return homePageCubit;
        },
        act: (cubit) async {
          final appTypeListData = jsonDecode(fixture("app_type_list.json"));
          List<AppType> appList = [];
          for (var item in appTypeListData["data"]) {
            appList.add(AppType.fromJson(item));
          }
          final appType = appList.where((element) => element.isMarkDefault == true).toList();
          await cubit.showSiteTaskFormDialog(appType.first);
        },
        expect: () => [isA<ShowFormCreateDialogState>()]);

    blocTest<HomePageCubit, FlowState>("Navigate to site task listing screen Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          await cubit.navigateSiteListingScreen(homePageData.configJsonData!.userProjectConfigTabsDetails!.first);
        },
        expect: () => [isA<HomePageItemLoadingState>(), isA<NavigateSiteListingScreenState>()]);

    blocTest<HomePageCubit, FlowState>("Home page showFormCreationOptionsDialog Test",
        build: () {
          AppConfigTestData().setupAppConfigTestData();
          return homePageCubit;
        },
        act: (cubit) async {
          await cubit.showFormCreationOptionsDialog();
        },
        expect: () => [isA<ShowFormCreationOptionsDialogState>()]);

    blocTest<HomePageCubit, FlowState>("Home page navigateTaskListingScreen Test",
        build: () {
          return homePageCubit;
        },
        act: (cubit) async {
          await cubit.navigateTaskListingScreen(TaskActionType.newTask);
        },
        expect: () => [isA<NavigateTaskListingScreenState>()]);
  });
}
