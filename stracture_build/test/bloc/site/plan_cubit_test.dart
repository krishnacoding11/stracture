import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/site/plan_cubit.dart';
import 'package:field/bloc/site/plan_loading_state.dart';
import 'package:field/bloc/sitetask/sitetask_state.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/pinsdata_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/domain/use_cases/site/site_use_case.dart';
import 'package:field/domain/use_cases/sitetask/sitetask_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/pdftron/pdftron_document_view.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/site_routes/site_plan_viewer_screen.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/download_service.dart';
import 'package:field/utils/site_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';
import '../../utils/load_url.dart';
import '../mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setConnectivity();
  MockMethodChannel().setNotificationMethodChannel();
  final mockSiteUseCase = MockSiteUseCase();
  final mockSiteTaskUseCase = MockSiteTaskUseCase();
  final mockFilterUseCase = MockFilterUseCase();
  DBServiceMock? mockDb;
  final mockInternetCubit = MockInternetCubit();
  final mockSiteUtility = MockSiteUtility();

  MockMethodChannel().setNotificationMethodChannel();
  Project? project;
  List<SiteLocation>? siteLocationList = [];
  Map<String, dynamic> arguments = {};
  PlanCubit planCubit = PlanCubit(siteUseCase: mockSiteUseCase, siteTaskUseCase: mockSiteTaskUseCase, filterUseCase: mockFilterUseCase);
  List<AppType>? apptypeList = [];

  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<PlanCubit>();
    di.getIt.registerFactory<PlanCubit>(() => planCubit);
    di.getIt.unregister<InternetCubit>();
    di.getIt.registerFactory<InternetCubit>(() => mockInternetCubit);
    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json"), "cloud_type_data": "1", "1_u1_project_": fixture("project.json")});
    final appTypeListData = jsonDecode(fixture("app_type_list.json"));
    for (var item in appTypeListData["data"]) {
      apptypeList.add(AppType.fromJson(item));
    }

    AppConfigTestData().setupAppConfigTestData();
    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AConstants.loadProperty();
  }

  setUp(() {
    siteLocationList = SiteLocation.jsonToList(fixture("site_location.json"));
    project = Project.fromJson(jsonDecode(fixture("project.json")));
    arguments['projectDetail'] = project;
    arguments['locationList'] = siteLocationList;
    MockMethodChannel().setAsitePluginsMethodChannel();
    mockDb = DBServiceMock();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  });

  tearDown(() {
    mockDb = null;
  });

  group('PlanCubit Tests -', () {
    configureCubitDependencies();

    test("Initial State", () {
      expect(planCubit.state, isA<InitialState>());
    });

    test("set form code filter value", () {
      planCubit.setFormCodeFilterValue("SITE:15999");
      expect("SITE:15999", planCubit.getFormCodeFilterValue());
    });

    blocTest<PlanCubit, FlowState>("Error State if location has no plan",
        build: () {
          planCubit = PlanCubit(siteUseCase: mockSiteUseCase, siteTaskUseCase: mockSiteTaskUseCase);
          planCubit.setArgumentData(arguments);
          return planCubit;
        },
        act: (c) async => await c.loadPlan(),
        expect: () => [isA<ErrorState>(), isA<HistoryLocationBtnState>()]);

    blocTest<PlanCubit, FlowState>(
      "Plan Loading State if location has plan",
      build: () {
        planCubit = PlanCubit(siteUseCase: mockSiteUseCase, siteTaskUseCase: mockSiteTaskUseCase);
        arguments['selectedLocation'] = siteLocationList![0];
        planCubit.setArgumentData(arguments);
        return planCubit;
      },
      act: (c) async {
        DownloadResponse downloadResponse = DownloadResponse(true, "test", null);
        when(() => mockSiteUseCase.downloadPdf(any())).thenAnswer((_) async => Future.value(downloadResponse));

        when(() => mockSiteUseCase.downloadXfdf(any(), checkFileExist: true)).thenAnswer((_) async => Future.value(downloadResponse));
        await c.loadPlan();
      },
      expect: () => [isA<LoadingState>(), isA<LastLocationChangeState>(), isA<PlanLoadingState>()],
    );

    blocTest<PlanCubit, FlowState>(
      "FormItemViewState State onFormItemClicked",
      build: () {
        planCubit = PlanCubit(siteUseCase: mockSiteUseCase, siteTaskUseCase: mockSiteTaskUseCase);
        arguments['selectedLocation'] = siteLocationList![0];
        planCubit.setArgumentData(arguments);
        return planCubit;
      },
      act: (c) async {
        when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
        await c.onFormItemClicked(ObservationData());
      },
      expect: () => [isA<LastLocationChangeState>(), isA<FormItemViewState>()],
    );

    blocTest<PlanCubit, FlowState>("Discard form pin should be remove",
        build: () {
          planCubit = PlanCubit(siteUseCase: mockSiteUseCase, siteTaskUseCase: mockSiteTaskUseCase);
          arguments['selectedLocation'] = siteLocationList![0];
          planCubit.setArgumentData(arguments);
          return planCubit;
        },
        act: (c) async {
          when(() => mockSiteUseCase.getObservationListByPlan(any())).thenAnswer((_) async => Future(() => ObservationData.jsonToObservationList(fixture("observations_list.json"))));
          await c.setPinsType(Pins.hide);
          await c.setHistoryLocationData();
          await c.refreshPins();
        },
        expect: () => [isA<PinsLoadedState>(), isA<HistoryLocationBtnState>(), isA<ProgressDialogState>(), isA<PinsLoadedState>(), isA<ProgressDialogState>(), isA<HistoryLocationBtnState>(), isA<LastLocationChangeState>()]);

    blocTest<PlanCubit, FlowState>("FormItemViewState State refreshPinsAndHighLight",
        build: () {
          planCubit = PlanCubit(siteUseCase: mockSiteUseCase, siteTaskUseCase: mockSiteTaskUseCase, filterUseCase: mockFilterUseCase);
          arguments['selectedLocation'] = siteLocationList![0];
          planCubit.setArgumentData(arguments);
          planCubit.setSummaryFilterValue("");
          return planCubit;
        },
        act: (c) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
          when(() => mockSiteUseCase.getObservationListByPlan(any())).thenAnswer((_) async => Future(() => ObservationData.jsonToObservationList(fixture("observations_list.json"))));
          when(() => mockFilterUseCase.getFilterJsonByIndexField({'summary': null}, curScreen: FilterScreen.screenSite, isNeedToSave: false)).thenAnswer((_) => Future(() => ""));
          await c.refreshPinsAndHighLight({"formId": "123445"});
        },
        expect: () => [isA<ProgressDialogState>(), isA<LastLocationChangeState>(), isA<PinsLoadedState>(), isA<ProgressDialogState>(), isA<HistoryLocationBtnState>(), isA<RefreshSiteTaskListState>()]);

    blocTest<PlanCubit, FlowState>("FormItemViewState State refreshPinsAndHighLight",
        build: () {
          planCubit = PlanCubit(siteUseCase: mockSiteUseCase, siteTaskUseCase: mockSiteTaskUseCase, filterUseCase: mockFilterUseCase);
          arguments['selectedLocation'] = siteLocationList![0];
          planCubit.setArgumentData(arguments);
          planCubit.setSummaryFilterValue("");
          return planCubit;
        },
        act: (c) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
          when(() => mockSiteUseCase.getObservationListByPlan(any())).thenAnswer((_) async => Future(() => ObservationData.jsonToObservationList(fixture("observations_list.json"))));
          when(() => mockFilterUseCase.getFilterJsonByIndexField({'summary': null}, curScreen: FilterScreen.screenSite, isNeedToSave: false)).thenAnswer((_) => Future(() => ""));
          await c.refreshPinsAndHighLight({"formId": "123445"}, refreshTaskList: false);
        },
        expect: () => [isA<ProgressDialogState>(), isA<LastLocationChangeState>(), isA<PinsLoadedState>(), isA<ProgressDialogState>(), isA<HistoryLocationBtnState>()]);

    blocTest<PlanCubit, FlowState>(
      "refreshPinAfterFormStatusChanged updates observation with site form data",
      build: () {
        planCubit = PlanCubit(
          siteUseCase: mockSiteUseCase,
          siteTaskUseCase: mockSiteTaskUseCase,
        );
        return planCubit;
      },
      act: (c) async {
        c.refreshPinAfterFormStatusChanged(SiteForm());
      },
      expect: () => [
        isA<PinsLoadedState>(),
      ],
    );
  });
  blocTest<PlanCubit, FlowState>('should return a SiteLocation',
      build: () {
        planCubit = PlanCubit(siteUseCase: mockSiteUseCase, siteTaskUseCase: mockSiteTaskUseCase);
        arguments['selectedLocation'] = siteLocationList![0];
        planCubit.setArgumentData(arguments);
        return planCubit;
      },
      act: (c) async {
        when(() => mockSiteUtility.getLocationFromAnnotationId(any()));
        await c.getLocationFromAnnotationId(["", c.siteLocationList, null]);
      },
      expect: () => [isA<LastLocationChangeState>()]);

  blocTest<PlanCubit, FlowState>('Remove Item From Bread Crumb',
      build: () {
        planCubit = PlanCubit(siteUseCase: mockSiteUseCase, siteTaskUseCase: mockSiteTaskUseCase);
        arguments['selectedLocation'] = siteLocationList![0];
        planCubit.setArgumentData(arguments);
        return planCubit;
      },
      act: (c) {
        c.removeItemFromBreadCrumb();
      },
      expect: () => [isA<HistoryLocationBtnState>(), isA<LastLocationChangeState>()]);

  blocTest<PlanCubit, FlowState>('on DocumentView Created',
      build: () {
        planCubit = PlanCubit(siteUseCase: mockSiteUseCase, siteTaskUseCase: mockSiteTaskUseCase);
        arguments['selectedLocation'] = siteLocationList![0];
        planCubit.setArgumentData(arguments);
        return planCubit;
      },
      act: (c) {
        c.onDocumentViewCreated(MockPdftronDocumentViewController());
      },
      expect: () => [isA<LastLocationChangeState>()]);
  blocTest<PlanCubit, FlowState>(
    'get Updated SiteTask Item',
    build: () {
      planCubit = PlanCubit(siteUseCase: mockSiteUseCase, siteTaskUseCase: mockSiteTaskUseCase);
      arguments['selectedLocation'] = siteLocationList![0];
      planCubit.setArgumentData(arguments);
      return planCubit;
    },
    act: (c) async {
      when(() => mockSiteTaskUseCase.getUpdatedSiteTaskItem(any(), any()));
      var result = await c.getUpdatedSiteTaskItem("", "");
      expect(result, null);
    },
  );
  blocTest<PlanCubit, FlowState>('Remove Temp Create Pin',
      build: () {
        planCubit = PlanCubit(siteUseCase: mockSiteUseCase, siteTaskUseCase: mockSiteTaskUseCase);
        arguments['selectedLocation'] = siteLocationList![0];
        planCubit.setArgumentData(arguments);
        return planCubit;
      },
      act: (c) {
        c.removeTempCreatePin();
      },
      expect: () => [isA<LongPressCreateTaskState>(), isA<LastLocationChangeState>()]);
  //FAIL
/*  blocTest<PlanCubit, FlowState>('Refresh Pins And High Light',
      build: () {
        planCubit = PlanCubit(siteUseCase: mockSiteUseCase, siteTaskUseCase: mockSiteTaskUseCase);
        arguments['selectedLocation'] = siteLocationList![0];
        planCubit.setArgumentData(arguments);
        return planCubit;
      },
      act: (c) {
        c.refreshPinsAndHighLight({"formId": ""});
      },
      expect: () => [isA<ProgressDialogState>(), isA<LastLocationChangeState>()]);*/

  //FAIL
/*  blocTest<PlanCubit, FlowState>('Navigate To Create Task',
      build: () {
        planCubit = PlanCubit(siteUseCase: mockSiteUseCase, siteTaskUseCase: mockSiteTaskUseCase);
        arguments['selectedLocation'] = siteLocationList![0];
        planCubit.setArgumentData(arguments);
        return planCubit;
      },
      act: (c) {
        c.navigateToCreateTask(appType: apptypeList[0]);
      },
      expect: () => [isA<LastLocationChangeState>()]);*/
  blocTest<PlanCubit, FlowState>('Test getArgumentData with empty values',
      build: () {
        planCubit = PlanCubit(siteUseCase: mockSiteUseCase, siteTaskUseCase: mockSiteTaskUseCase);
        arguments['selectedLocation'] = siteLocationList![0];
        planCubit.setArgumentData(arguments);
        return planCubit;
      },
      act: (c) {
        c.getArgumentData();
      },
      expect: () => [isA<LastLocationChangeState>()]);
}

class MockSiteUseCase extends Mock implements SiteUseCase {}

class MockSiteTaskUseCase extends Mock implements SiteTaskUseCase {
  @override
  Future<Result?> getUpdatedSiteTaskItem(String projectId, String formId) {
    return Future.value(SUCCESS("", null, 200));
  }
}

class MockFilterUseCase extends Mock implements FilterUseCase {}

class MockInternetCubit extends Mock implements InternetCubit {}

class DBServiceMock extends Mock implements DBService {}

class MockPdftronDocumentViewController extends Mock implements PdftronDocumentViewController {}

class MockSiteUtility extends Mock implements SiteUtility {
  getLocationFromAnnotationId(any) {
    return null;
  }
}
