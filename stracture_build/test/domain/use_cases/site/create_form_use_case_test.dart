import 'package:dio/dio.dart';
import 'package:field/data/remote/site/create_form_remote_repository.dart';
import 'package:field/domain/use_cases/site/create_form_use_case.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appconfig_test_data.dart';
import '../../../fixtures/fixture_reader.dart';
import '../../../utils/load_url.dart';

class MockCreateFormRemoteRepository extends Mock
    implements CreateFormRemoteRepository {}

class MockInternetCubit extends Mock implements InternetCubit {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  di.getIt.registerLazySingleton<MockCreateFormRemoteRepository>(
          () => MockCreateFormRemoteRepository());
  late CreateFormUseCase createFormUseCase;
  late MockCreateFormRemoteRepository repository;
  final mockInternetCubit = MockInternetCubit();

  setUpAll(() => () async {
    MockMethodChannel().setNotificationMethodChannel();
    MockMethodChannel().setConnectivityMethodChannel();
    MockMethodChannel().setAsitePluginsMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    await di.init(test: true);
    AppConfigTestData().setupAppConfigTestData();
  });

  setUp(() async {
    createFormUseCase = CreateFormUseCase();
    repository = di.getIt<MockCreateFormRemoteRepository>();
    di.getIt.registerFactory<CreateFormRemoteRepository>(() => repository);
    di.getIt.registerFactory<InternetCubit>(() => mockInternetCubit);
    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    SharedPreferences.setMockInitialValues(
        {"userData": fixture("user_data.json")});
    AConstants.loadProperty();
    when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
  });

  tearDown(() {
    di.getIt.unregister<CreateFormRemoteRepository>();
    di.getIt.unregister<InternetCubit>();
  });

  group("Test uploadAttachment", () {
    test("check permission IsNetworkConnected=true", () async {
      Map<String, dynamic> map = {};
      Map<String, dynamic> data = {
        "csrfToken": "shfuicheufhaj38972874837_aw9qr78="
      };
      when(
            () => repository.uploadAttachment(map),
      ).thenAnswer(
            (_) async => Result<dynamic>(SUCCESS(data, Headers(), 200)),
      );
      final result = await createFormUseCase.uploadAttachment(map);
      expect(result, isA<Result>());
    });
  });

  group("Test downloadInLineAttachment", () {
    test("check permission IsNetworkConnected=true", () async {
      Map<String, dynamic> map = {};
      Map<String, dynamic> data = {
        "csrfToken": "shfuicheufhaj38972874837_aw9qr78="
      };
      when(
            () => repository.downloadInLineAttachment(map),
      ).thenAnswer(
            (_) async => Result<dynamic>(SUCCESS(data, Headers(), 200)),
      );
      final result = await createFormUseCase.downloadInLineAttachment(map);
      expect(result, isA<Result>());
    });
  });

  group("Test uploadInlineAttachment", () {
    test("check permission IsNetworkConnected=true", () async {
      Map<String, dynamic> map = {};
      Map<String, dynamic> data = {
        "csrfToken": "shfuicheufhaj38972874837_aw9qr78="
      };
      when(
            () => repository.uploadInlineAttachment(map),
      ).thenAnswer(
            (_) async => Result<dynamic>(SUCCESS(data, Headers(), 200)),
      );
      final result = await createFormUseCase.uploadInlineAttachment(map);
      expect(result, isA<Result>());
    });
  });

  group("Test saveFormToServer", () {
    test("check permission IsNetworkConnected=true", () async {
      Map<String, dynamic> map = {};
      Map<String, dynamic> data = {
        "csrfToken": "shfuicheufhaj38972874837_aw9qr78="
      };
      when(
            () => repository.saveFormToServer(map),
      ).thenAnswer(
            (_) async => Result<dynamic>(SUCCESS(data, Headers(), 200)),
      );
      final result = await createFormUseCase.saveFormToServer(map);
      expect(result, isA<Result>());
    });
  });

  group("Test formDistActionTaskToServer", () {
    test("check permission IsNetworkConnected=true", () async {
      Map<String, dynamic> map = {};
      Map<String, dynamic> data = {
        "csrfToken": "shfuicheufhaj38972874837_aw9qr78="
      };
      when(
            () => repository.formDistActionTaskToServer(map),
      ).thenAnswer(
            (_) async => Result<dynamic>(SUCCESS(data, Headers(), 200)),
      );
      final result = await createFormUseCase.formDistActionTaskToServer(map);
      expect(result, isA<Result>());
    });
  });

  group("Test formOtherActionTaskToServer", () {
    test("check permission IsNetworkConnected=true", () async {
      Map<String, dynamic> map = {};
      Map<String, dynamic> data = {
        "csrfToken": "shfuicheufhaj38972874837_aw9qr78="
      };
      when(
            () => repository.formOtherActionTaskToServer(map),
      ).thenAnswer(
            (_) async => Result<dynamic>(SUCCESS(data, Headers(), 200)),
      );
      final result = await createFormUseCase.formOtherActionTaskToServer(map);
      expect(result, isA<Result>());
    });
  });

  group("Test formStatusChangeTaskToServer", () {
    test("check permission IsNetworkConnected=true", () async {
      Map<String, dynamic> map = {};
      Map<String, dynamic> data = {
        "csrfToken": "shfuicheufhaj38972874837_aw9qr78="
      };
      when(
            () => repository.formStatusChangeTaskToServer(map),
      ).thenAnswer(
            (_) async => Result<dynamic>(SUCCESS(data, Headers(), 200)),
      );
      final result = await createFormUseCase.formStatusChangeTaskToServer(map);
      expect(result, isA<Result>());
    });
  });
}