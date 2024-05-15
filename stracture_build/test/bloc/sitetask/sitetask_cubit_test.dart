import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/sitetask/sitetask_cubit.dart';
import 'package:field/bloc/sitetask/sitetask_state.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/pinsdata_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/domain/use_cases/sitetask/sitetask_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/site_item/site_item.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';
import '../../utils/load_url.dart';
import '../mock_method_channel.dart';

class MockSiteTaskUseCase extends Mock implements SiteTaskUseCase {}

class MockFilterUseCase extends Mock implements FilterUseCase {}

class DBServiceMock extends Mock implements DBService {}

class MockInternetCubit extends Mock implements InternetCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  final mockSiteUseCase = MockSiteTaskUseCase();
  final MockFilterUseCase mockFilterUseCase = MockFilterUseCase();
  DBServiceMock? mockDb;
  final mockInternetCubit = MockInternetCubit();
  late SiteTaskCubit siteTaskCubit;
  List<SiteLocation>? siteLocationList = [];
  String formId = "10941718";
  String projectId = "2116416\$\$NMiycJ";

  configureCubitDependencies(){
    //get register error due to in sitetask cubit FilterUseCase not use from registerLazySingleton
    //sitetaskcubit line no :54
    di.init(test: true);
    di.getIt.unregister<FilterUseCase>();
    di.getIt.registerLazySingleton<FilterUseCase>(() => mockFilterUseCase);
    di.getIt.unregister<InternetCubit>();
    di.getIt.registerFactory<InternetCubit>(() => mockInternetCubit);
    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);

    AppConfigTestData().setupAppConfigTestData();
    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AConstants.loadProperty();
  }

  setUp(() async {
    siteLocationList = SiteLocation.jsonToList(fixture("site_location.json"));
    siteTaskCubit = SiteTaskCubit(useCase: mockSiteUseCase);
    siteTaskCubit.setCurrentLocation(siteLocationList![0]);
    mockDb = DBServiceMock();
  });

  tearDown(() {
    mockDb = null;
  });

  group("Location listing cubit:", () {
    configureCubitDependencies();

    test("Initial state", () {
      expect(siteTaskCubit.state, isA<FlowState>());
    });

    blocTest<SiteTaskCubit, FlowState>("Error State in case of server api fail",
        build: () {
          return siteTaskCubit;
        },
        act: (c) async {
          when(()=> mockFilterUseCase.readSiteFilterData(curScreen: FilterScreen.screenSite)).thenAnswer((_) => Future.value({}));
          when(() => mockSiteUseCase.getSiteTaskList(any()))
              .thenAnswer((_) async => Future(() => FAIL("Error", 401)));

          await c.getSiteTaskList(<String, dynamic>{});
        },
        expect: () => [isA<LoadingState>(), isA<ErrorState>()]);

    blocTest<SiteTaskCubit, FlowState>("Success State on server response",
        build: () {
          return siteTaskCubit;
        },
        act: (c) async {
          when(()=>mockFilterUseCase.readSiteFilterData(curScreen: FilterScreen.screenSite)).thenAnswer((_) => Future.value({}));
          //thenReturn(Future.value({}));
          when(() => mockSiteUseCase.getSiteTaskList(any())).thenAnswer((_) async => Future(() => SUCCESS<dynamic>(fixture("sitetaskslist.json"), null, 200)));
          await c.getSiteTaskList(<String, dynamic>{});
        },
        expect: () => [isA<LoadingState>(), isA<SuccessState>()]);

    blocTest<SiteTaskCubit, FlowState>(
        "FormItemViewState State onFormItemClicked",
        build: () {
          return siteTaskCubit;
        },
        act: (c) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
          await c.onFormItemClicked(SiteForm());
        },
        expect: () =>
        [isA<FormItemViewState>(), isA<RefreshPaginationItemState>()]);
    blocTest<SiteTaskCubit, FlowState>(
        "Form status changed or not when it comes from UI",
        build: () {
          return siteTaskCubit;
        },
        act: (c) async {
          when(() => mockSiteUseCase.getUpdatedSiteTaskItem(any(), any())).thenAnswer((_) async => Future(() {
            return SUCCESS(fixture("form_detail_vo.json"), null, 200);
          }));
          await c.getUpdatedSiteTaskItem(projectId, formId);
        },
        expect: () => []);

    blocTest<SiteTaskCubit, FlowState>("FormItemViewState State onFormItemClicked for Offline",
        build: () {
          return siteTaskCubit;
        },
        act: (c) async {
          when(() => mockInternetCubit.isNetworkConnected).thenReturn(false);
          await c.onFormItemClicked(SiteForm());
        },
        expect: () => [isA<FormItemViewState>(), isA<RefreshPaginationItemState>()]
    );

    blocTest<SiteTaskCubit, FlowState>(
        "Success State on server response For Filter API",
        build: () {
          siteTaskCubit.setSummaryFilterValue("test");
          return siteTaskCubit;
        },
        act: (c) async {
          when(() => mockSiteUseCase.getFilterSiteTaskList(any())).thenAnswer(
              (_) async => Future(() =>
                  SUCCESS<dynamic>(fixture("sitetaskslist.json"), null, 200)));
          await c.getSiteTaskList(<String, dynamic>{});
        },
        expect: () => [isA<LoadingState>(), isA<SuccessState>()]);

    blocTest<SiteTaskCubit, FlowState>(
        "Error State in case of server api fail If Filter Applied",
        build: () {
          siteTaskCubit.setSummaryFilterValue("test");
          return siteTaskCubit;
        },
        act: (c) async {
          when(() => mockSiteUseCase.getFilterSiteTaskList(any()))
              .thenAnswer((_) async => Future(() => FAIL("Error", 401)));
          await c.getSiteTaskList(<String, dynamic>{});
        },
        expect: () => [isA<LoadingState>(), isA<ErrorState>()]);

    blocTest<SiteTaskCubit, FlowState>(
      "Form code filter applied then call getUpdatedSiteTaskItem",
      build: () {
        siteTaskCubit.applyStaticFilter = true;
        siteTaskCubit.setSelectedFormId("10941718\$\$TZQgUz");
        siteTaskCubit.setSelectedFormCode("SIIE1052");
        return siteTaskCubit;
      },
      act: (c) async {
        when(() => mockSiteUseCase.getUpdatedSiteTaskItem(any(), any())).thenAnswer((_) async => Future(() {
              return SUCCESS(fixture("form_detail_vo.json"), null, 200);
            }));
        when(() => mockSiteUseCase.getExternalAttachmentList(any())).thenAnswer((_) async => Future(() {
              return SUCCESS([], null, 200);
            }));
        await c.pageFetch(0);
      },
      seed: () => ScrollState(isScrollRequired: true),
    );

    blocTest<SiteTaskCubit, FlowState>(
      "Data is available in the listing then select pin data",
      build: () {
        siteTaskCubit.applyStaticFilter = true;
        siteTaskCubit.setSelectedFormId("10955881\$\$XTWMOk");
        siteTaskCubit.setSelectedFormCode("SIIE1052");
        return siteTaskCubit;
      },
      act: (c) async {
        when(() => mockSiteUseCase.getUpdatedSiteTaskItem(any(), any())).thenAnswer((_) async => Future(() {
              return SUCCESS(fixture("form_detail_vo.json"), null, 200);
            }));
        when(() => mockSiteUseCase.getExternalAttachmentList(any())).thenAnswer((_) async => Future(() {
              return SUCCESS([], null, 200);
            }));
        await c.pageFetch(0);
      },
      seed: () => ScrollState(isScrollRequired: true),
    );

    blocTest<SiteTaskCubit, FlowState>(
      "Highlight selected form data in existing listing data ",
      build: () {
        siteTaskCubit.applyStaticFilter = false;
        siteTaskCubit.setSelectedFormId("10955881\$\$XTWMOk");
        siteTaskCubit.setSelectedFormCode("SIIE1052");
        String jsonDataString = fixture("sitetaskslist.json").toString();
        final json = jsonDecode(jsonDataString);
        siteTaskCubit.loadedItems = List<SiteForm>.from(json['data'].map((x) => SiteForm.fromJson(x))).map((v) => SiteItem(v)).toList();
        return siteTaskCubit;
      },
      act: (c) async {
        await c.highLightSelectedFormData(ObservationData(formId: "10955881\$\$XTWMOk"));
      },
      expect: () => [isA<RefreshPaginationItemState>()],
      seed: () => ScrollState(isScrollRequired: true),
    );

    blocTest<SiteTaskCubit, FlowState>(
      "Highlight selected form data in existing listing data ",
      build: () {
        siteTaskCubit.applyStaticFilter = true;
        siteTaskCubit.setSelectedFormId("1095581\$\$XTWMOk");
        siteTaskCubit.setSelectedFormCode("SIIE1052");
        String jsonDataString = fixture("sitetaskslist.json").toString();
        final json = jsonDecode(jsonDataString);
        siteTaskCubit.loadedItems = List<SiteForm>.from(json['data'].map((x) => SiteForm.fromJson(x))).map((v) => SiteItem(v)).toList();
        return siteTaskCubit;
      },
      act: (c) async {
        await c.highLightSelectedFormData(ObservationData(formId: "1095581\$\$XTWMOk", formCode: "SIIE1052"));
      },
      seed: () => DefaultFormCodeFilterState(formCode: "SIIE1052", isFormCodeFilterApply: true),
    );

    blocTest<SiteTaskCubit, FlowState>(
      "Clear default form code filter",
      build: () {
        siteTaskCubit.setSelectedFormId("");
        siteTaskCubit.setSelectedFormCode("");
        return siteTaskCubit;
      },
      act: (c) async {
        await c.clearDefaultFormCodeFilter();
      },
      seed: () => DefaultFormCodeFilterState(isFormCodeFilterApply: false),
    );
  });
}