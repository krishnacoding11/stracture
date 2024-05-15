import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:field/bloc/site/location_tree_cubit.dart';
import 'package:field/bloc/site/location_tree_state.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/search_location_list_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/domain/use_cases/qr/qr_usecase.dart';
import 'package:field/domain/use_cases/site/site_use_case.dart';
import 'package:field/injection_container.dart' as container;
import 'package:field/networking/network_response.dart';
import 'package:field/networking/request_body.dart';
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

  final mockSiteUseCase = MockSiteUseCase();
  final mockQRUseCase = MockQRUseCase();
  late LocationTreeCubit locationTreeCubit;

  setUp(() {
    AppConfigTestData().setupAppConfigTestData();
    locationTreeCubit = LocationTreeCubit(siteUseCase: mockSiteUseCase, qrUseCase: mockQRUseCase);
    locationTreeCubit.project = Project.fromJson(jsonDecode(fixture("project.json")));
  });
  configureCubitDependencies() {
    MockMethodChannel().setNotificationMethodChannel();
    container.init(test: true);
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json"), "cloud_type_data": "1", "1_u1_project_": fixture("project.json")});

    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AConstants.loadProperty();
  }

  group("Location listing cubit:", () {
    configureCubitDependencies();
    test("Initial state", () {
      isA<InitialState>();
    });

    blocTest<LocationTreeCubit, FlowState>("emits [Success] state",
        build: () {
          return locationTreeCubit;
        },
        act: (cubit) async {
          when(() => mockSiteUseCase.getLocationTree(any())).thenAnswer((_) async => Future(() {
                return SUCCESS(fixture("site_location_list.json"), null, null);
              }));
          await cubit.getLocationTree(isLoading: true);
        },
        expect: () => [isA<LoadingState>(), isA<ContentState>()]);

    blocTest<LocationTreeCubit, FlowState>("emits [Error] state",
        build: () {
          return locationTreeCubit;
        },
        act: (cubit) async {
          when(() => mockSiteUseCase.getLocationTree(any())).thenAnswer((_) async => Future(() {
                return FAIL("No Data Available", 204);
              }));
          await cubit.getLocationTree(isLoading: true);
        },
        expect: () => [isA<LoadingState>(), isA<ErrorState>()]);

    blocTest<LocationTreeCubit, FlowState>("emits [Success] state suggested search List",
        build: () {
          return locationTreeCubit;
        },
        act: (cubit) async {
          when(() => mockSiteUseCase.getSuggestedSearchList(any())).thenAnswer((_) async => Future(() {
                return SUCCESS(fixture("location_suggestion_search_list.json"), null, null);
              }));
          await cubit.getSuggestedSearchList("flo");
        },
        expect: () => [isA<LoadingState>(), isA<LocationSearchSuggestion>(), isA<LocationSearchSuggestionMode>()]);

    blocTest<LocationTreeCubit, FlowState>("emits [Error] state suggested search List",
        build: () {
          return locationTreeCubit;
        },
        act: (cubit) async {
          when(() => mockSiteUseCase.getSuggestedSearchList(any())).thenAnswer((_) async => Future(() {
                return FAIL("No Data Available", 204);
              }));
          await cubit.getSuggestedSearchList("abc");
        },
        expect: () => [isA<LoadingState>(), isA<ErrorState>()]);

    blocTest<LocationTreeCubit, FlowState>("emits [Success] state search List",
        build: () {
          return locationTreeCubit;
        },
        act: (cubit) async {
          when(() => mockSiteUseCase.getSearchList(any())).thenAnswer((_) async => Future(() {
                return SUCCESS(SearchLocationListVo.fromJson(fixture("location_search_list.json")), null, null);
              }));
          await cubit.getSearchList("floor");
        },
        expect: () => [isA<LoadingState>(), isA<LocationSearchSate>()]);

    blocTest<LocationTreeCubit, FlowState>("emits [Error] state search List",
        build: () {
          return locationTreeCubit;
        },
        act: (cubit) async {
          when(() => mockSiteUseCase.getSearchList(any())).thenAnswer((_) async => Future(() {
                return SUCCESS(SearchLocationListVo.fromJson(fixture("location_search_empty_list.json")), null, null);
              }));
          await cubit.getSearchList("floor");
        },
        expect: () => [isA<LoadingState>(), isA<ErrorState>()]);
  });

  blocTest<LocationTreeCubit, FlowState>("emits [Success] navigate to plan",
      build: () {
        return locationTreeCubit;
      },
      act: (cubit) async {
        when(() => mockQRUseCase.getFieldEnableSelectedProjectsAndLocations(any())).thenAnswer((_) async => Future(() {
              return SUCCESS([locationTreeCubit.project], Headers(), 200);
            }));

        await cubit.getLocationDetailsAndNavigateFromSearch("107848989\$\$Q4pbHw#2116416\$\$yzxIbB");
      },
      expect: () => [
            isA<SuccessState>(),
          ]);
  blocTest<LocationTreeCubit, FlowState>("Add Recent Project Search",
      build: () {
        return locationTreeCubit;
      },
      act: (cubit) async {
        cubit.addRecentProject(newSearch: "abed");
      },
      expect: () => []);

  group("check canRemoveOffline", () {
    test("call canRemoveOfflineLocation if listSiteLocation empty expected false", () async {
      bool canRemoveOfflineLocation = await locationTreeCubit.canRemoveOfflineLocation();
      expect(false, canRemoveOfflineLocation);
    });

    test("call canRemoveOfflineLocation with listSiteLocation data", () async {
      var datajson = fixture('site_location_list.json');
      final jsonObj = jsonDecode(datajson);

      when(() => mockSiteUseCase.getLocationTree(any())).thenAnswer((_) async {
        return (SUCCESS(jsonObj, Headers(), 200));
      });

      when(() => mockSiteUseCase.canRemoveOfflineLocation(any(), any())).thenAnswer((_) async {
        return Future.value(true);
      });

      await locationTreeCubit.getLocationTree(location: null);
      expect(false, locationTreeCubit.isOfflineLocationAvailableForDelete());
    });
  });

  group("Offline LocationList", () {
    setUp(() {
      var datajson = fixture('site_location_list.json');
      List<SiteLocation> jsonObj = SiteLocation.jsonListToLocationList(jsonDecode(datajson));
      locationTreeCubit.addLocationList(SUCCESS(jsonObj, null, 200, requestData: NetworkRequestBody.json({'folderId': '0'})), null);
    });

    test("Offline available location count for unmark ", () {
      expect(2, locationTreeCubit.offlineSiteLocationListCount());
    });

    test("Offline available location list for unmark ", () {
      expect(2, locationTreeCubit.offlineSiteLocationList().length);
    });
  });
}

class MockSiteUseCase extends Mock implements SiteUseCase {}

class MockQRUseCase extends Mock implements QrUseCase {}
