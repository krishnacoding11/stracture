import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:field/data/local/homepage/homepage_local_repository_impl.dart';
import 'package:field/data/model/home_page_model.dart';
import 'package:field/data/remote/dashboard/homepage_remote_repository_impl.dart';
import 'package:field/domain/use_cases/dashboard/homepage_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appconfig_test_data.dart';
import '../../../fixtures/fixture_reader.dart';

class MockHomePageRepository extends Mock implements HomePageRemoteRepository {}

class MockHomePageLocalRepository extends Mock implements HomePageLocalRepository {}

class MockInternetCubit extends Mock implements InternetCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  late MockHomePageRepository mockHomePageRepository;
  late MockInternetCubit mockInternetCubit;
  late MockHomePageLocalRepository mockHomePageLocalRepository;
  HomePageUseCase homePageUseCase = HomePageUseCase();

  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<HomePageRemoteRepository>();
    di.getIt.registerFactory<HomePageRemoteRepository>(() => mockHomePageRepository);
    di.getIt.unregister<HomePageLocalRepository>();
    di.getIt.registerFactory<HomePageLocalRepository>(() => mockHomePageLocalRepository);
    di.getIt.unregister<InternetCubit>();
    di.getIt.registerFactory<InternetCubit>(() => mockInternetCubit);
  }

  setUp(() {
    mockHomePageRepository = MockHomePageRepository();
    mockInternetCubit = MockInternetCubit();
    mockHomePageLocalRepository = MockHomePageLocalRepository();
    when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
  });

  group("Test Homepage", () {
    configureCubitDependencies();
    AppConfigTestData().setupAppConfigTestData();

    test("Homepage getShortcutConfigList [Success] response", () async {
      Result? result = SUCCESS(HomePageModel.fromJson(jsonDecode(fixture('homepage_item_config_data.json'))), Headers(), 200);
      when(() => mockHomePageRepository.getShortcutConfigList(any())).thenAnswer((_) => Future.value(result));
      var response = await homePageUseCase.getShortcutConfigList({});
      expect(response!.data != null, true);
    });

    test("Homepage getShortcutConfigList [Offline Success] response", () async {
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(false);
      Result? result = SUCCESS(HomePageModel.fromJson(jsonDecode(fixture('homepage_item_config_data.json'))), Headers(), 200);
      when(() => mockHomePageLocalRepository.getShortcutConfigList(any())).thenAnswer((_) => Future.value(result));
      var response = await homePageUseCase.getShortcutConfigList({});
      expect(response!.data != null, true);
    });

    test("Homepage getShortcutConfigList [FAIL] response", () async {
      Result? result = FAIL('Internal server error', 500);
      when(() => mockHomePageRepository.getShortcutConfigList(any())).thenAnswer((_) => Future.value(result));
      var response = await homePageUseCase.getShortcutConfigList({});
      expect(response!.responseCode, 500);
    });

    test("Homepage updateShortcutConfigList [Success] response", () async {
      Result? result = SUCCESS(HomePageModel.fromJson(jsonDecode(fixture('homepage_item_config_data.json'))), Headers(), 200);
      when(() => mockHomePageRepository.updateShortcutConfigList(any())).thenAnswer((_) => Future.value(result));
      var response = await homePageUseCase.updateShortcutConfigList({});
      expect(response!.data != null, true);
    });

    test("Homepage updateShortcutConfigList [FAIL] response", () async {
      Result? result = FAIL('Internal server error', 500);
      when(() => mockHomePageRepository.updateShortcutConfigList(any())).thenAnswer((_) => Future.value(result));
      var response = await homePageUseCase.updateShortcutConfigList({});
      expect(response!.responseCode, 500);
    });

    test("Homepage getPendingShortcutConfigList [Success] response", () async {
      Result? result = SUCCESS(HomePageModel.fromJson(jsonDecode(fixture('homepage_item_config_data.json'))), Headers(), 200);
      when(() => mockHomePageRepository.getPendingShortcutConfigList(any())).thenAnswer((_) => Future.value(result));
      var response = await homePageUseCase.getPendingShortcutConfigList({});
      expect(response!.data != null, true);
    });

    test("Homepage getPendingShortcutConfigList [FAIL] response", () async {
      Result? result = FAIL('Internal server error', 500);
      when(() => mockHomePageRepository.getPendingShortcutConfigList(any())).thenAnswer((_) => Future.value(result));
      var response = await homePageUseCase.getPendingShortcutConfigList({});
      expect(response!.responseCode, 500);
    });
  });
}
