import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/site/create_form_selection_cubit.dart';
import 'package:field/bloc/site/create_form_selection_state.dart';
import 'package:field/data/model/apptype_group_vo.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/domain/use_cases/formtype/formtype_use_case.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/global.dart' as global;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';
import '../mock_method_channel.dart';



class MockFormTypeUseCase extends MockCubit<FlowState> implements FormTypeUseCase{}


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  late CreateFormSelectionCubit createFormSelectionCubit;
  MockFormTypeUseCase mockFormTypeUseCase = MockFormTypeUseCase();
  List<AppType>? appList = [];
  List<AppTypeGroup>? searchAppGroup = [];

  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<FormTypeUseCase>();
    di.getIt.registerFactory<FormTypeUseCase>(() => mockFormTypeUseCase);
    AppConfigTestData().setupAppConfigTestData();
  }

  setUp(() {
    appList.clear();
    searchAppGroup.clear();
    createFormSelectionCubit = CreateFormSelectionCubit(formTypeUseCase: mockFormTypeUseCase);


    final appTypeListData = jsonDecode(fixture("app_type_list.json"));
    for (var item in appTypeListData["data"]) {
      appList.add(AppType.fromJson(item));
    }
    global.appTypeList = appList;

    final searchGroup = jsonDecode(fixture("app_type_group_list.json"));
    for (var item in searchGroup) {
      searchAppGroup.add(AppTypeGroup.fromJson(item));
    }

    createFormSelectionCubit.searchAppGroup = searchAppGroup;
    createFormSelectionCubit.appGroups = [...searchAppGroup];
  });

  group('Create Form Selection Cubit Tests -', () {
    configureCubitDependencies();

    blocTest<CreateFormSelectionCubit, FlowState>(
        "getAppTypeList [Success] state.",
        build: () {
          return createFormSelectionCubit;
        },
        act: (c){
          when(() => mockFormTypeUseCase.getAppTypeList(any(), any(), any())).thenAnswer((invocation) => Future.value(appList));
          c.getAppList("24567\$\$SBFJE", false, "2");
        },
        expect: () => [isA<LoadingState>(), isA<ContentState>()]
    );

    blocTest<CreateFormSelectionCubit, FlowState>(
        "getAppTypeList [Empty] state.",
        build: () {
          return createFormSelectionCubit;
        },
        act: (c) {
          when(() => mockFormTypeUseCase.getAppTypeList(any(), any(), any())).thenAnswer((invocation) => Future.value([]));
          c.getAppList("24567\$\$SBFJE", false, "2");
          },
        expect: () => [isA<LoadingState>(), isA<ContentState>()]);

    //FAIL
    /*blocTest<CreateFormSelectionCubit, FlowState>(
        "Search [Success] state",
        build: () {
          return createFormSelectionCubit;
        },
        act: (c) {
          c.onSearchForm("Site");
        },
        expect: () => [isA<FormTypeExpandedState>()]);*/

    blocTest<CreateFormSelectionCubit, FlowState>(
        "Search [Empty] state",
        build: () {
          return createFormSelectionCubit;
        },
        act: (c) {
          c.onSearchForm("57768");
        },
        expect: () => [isA<ContentState>()]);


    //FAIL
    /*blocTest<CreateFormSelectionCubit, FlowState>(
        "App Type Form Current Search Clear [Success]",
        build: () {
          return createFormSelectionCubit;
        },
        act: (c) {
          c.onClearSearch();
          },
        expect: () => [isA<FormTypeExpandedState>()]);*/

    /*blocTest<CreateFormSelectionCubit, FlowState>(
        "App Type Form Current Search Clear [Fail]",
        build: () {
          return createFormSelectionCubit;
        },
        act: (c) {
          c.onClearSearch();
        },
        expect: () => [isA<FormTypeExpandedState>()]);*/

    blocTest<CreateFormSelectionCubit, FlowState>(
        "getDefaultSiteApp [Success]",
        build: () {
          return createFormSelectionCubit;
        },
        act: (c) {
          when(() => mockFormTypeUseCase.getAppTypeList(any(), any(), any())).thenAnswer((invocation) => Future.value(appList));
          c.getDefaultSiteApp("24567\$\$SBFJE");
        },
        expect: () => [isA<LoadingState>(), isA<SuccessState>()]);

    blocTest<CreateFormSelectionCubit, FlowState>(
        "getDefaultSiteApp [Empty]",
        build: () {
          return createFormSelectionCubit;
        },
        act: (c) {
          when(() => mockFormTypeUseCase.getAppTypeList(any(), any(), any())).thenAnswer((invocation) => Future.value([]));
          c.getDefaultSiteApp("24567\$\$SBFJE");
        },
        expect: () => [isA<LoadingState>(), isA<SuccessState>()]);

    blocTest<CreateFormSelectionCubit, FlowState>(
        "onChangeExpansion",
        build: () {
          return createFormSelectionCubit;
        },
        act: (c) {
          c.onChangeExpansion(0);
        },
        expect: () => [isA<FormTypeExpandedState>()]);

    blocTest<CreateFormSelectionCubit, FlowState>(
        "onFocusChange",
        build: () {
          return createFormSelectionCubit;
        },
        act: (c) {
          c.onFocusChange(true);
        },
        expect: () => [isA<FormTypeExpandedState>()]);


    blocTest<CreateFormSelectionCubit, FlowState>(
        "onSearchClear",
        build: () {
          return createFormSelectionCubit;
        },
        act: (c) {
          c.onSearchClear();
        },
        expect: () => [isA<FormTypeSearchClearState>()]);

    blocTest<CreateFormSelectionCubit, FlowState>(
        "checkSiteTaskEnabled",
        build: () {
          return createFormSelectionCubit;
        },
        act: (c) {
          c.checkSiteTaskEnabled();
        },
        expect: () => []);
  });
}
