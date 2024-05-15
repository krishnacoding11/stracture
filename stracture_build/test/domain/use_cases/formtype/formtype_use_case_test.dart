import 'dart:convert';

import 'package:field/data/local/formtype/formtype_local_repository_impl.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/data/remote/formtype/formtype_repository_impl.dart';
import 'package:field/data/repository/formtype/formtype_repository.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/formtype/formtype_use_case.dart';
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/networking/network_service.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/offline_injection_container.dart' as di;
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appconfig_test_data.dart';
import '../../../fixtures/fixture_reader.dart';
import '../../../utils/load_url.dart';

class MockFormTypeRepository extends Mock implements FormTypeRepository {}

class MockDBService extends Mock implements DBService {}

Future<void> main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setConnectivity();
    await di.init(test: true);

  AppConfig appConfig = di.getIt<AppConfig>();
  User user = User.fromJson(jsonDecode(fixture("user_data.json")));
  appConfig.currentUser = user;
  appConfig.appConfigData = {
    "cloud_type_data": "11",
    "languageData": {
      "jsonLocales": [
        {"displayCountry": "United Kingdom", "languageId": "en_GB", "displayLanguage": "English"}
      ]
    }
  };
  appConfig.currentSelectedProject = jsonDecode(fixture("project.json"));

  AppConfigTestData().setupAppConfigTestData();
  MockMethodChannelUrl().setupBuildFlavorMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AConstants.loadProperty();

  late FormTypeUseCase formTypeUseCase;
  late MockDBService mockDBService;

  setUp(() {
    formTypeUseCase = FormTypeUseCase();
    mockDBService = MockDBService();
    di.getIt.unregister<InternetCubit>();
    di.getIt.registerLazySingleton<InternetCubit>(() => InternetCubit());
  });

  test('getInstance should return FormTypeRemoteRepository when network is connected', () async {
    final result = await formTypeUseCase.getInstance();
    expect(result, isA<FormTypeRemoteRepository>());
  });

  test('getInstance should return FormTypeLocalRepository when network is not connected', () async {
    di.getIt<InternetCubit>().isNetworkConnected = false;
    var result = await formTypeUseCase.getInstance();
    expect(result, isA<FormTypeLocalRepository>());
  });

  group('getProjectFormTypeListFromSync', () {
    test('returns data from getProjectFormTypeListFromSync', () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";

      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);

      final result = await formTypeUseCase.getProjectFormTypeListFromSync(
        projectId: 'projectId',
        networkExecutionType: NetworkExecutionType.SYNC,
        taskNumber: 1,
      );
      expect(result, isA<FAIL>());

      final result1 = await formTypeUseCase.getProjectFormTypeListFromSync(projectId: 'projectId', networkExecutionType: NetworkExecutionType.SYNC, taskNumber: 1, formTypeIds: '1,2');
      expect(result1, isA<FAIL>());
    });

    test('returns data from getFormTypeHTMLTemplateZipDownload', () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";

      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);

      final result = await formTypeUseCase.getFormTypeHTMLTemplateZipDownload(projectId: "1", networkExecutionType: NetworkExecutionType.SYNC, formTypeId: "1", taskNumber: 1);
      expect(result, isA<FAIL>());
    });

    test('returns data from getFormTypeXSNTemplateZipDownload', () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";

      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);

      final result = await formTypeUseCase.getFormTypeXSNTemplateZipDownload(projectId: "1", taskNumber: 1, formTypeId: "1", networkExecutionType: NetworkExecutionType.SYNC, userId: "1", jSFolderPath: "", isMobileView: false);
      expect(result, isA<FAIL>());
    });

    test('returns data from getFormTypeCustomAttributeList', () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";

      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);

      final result = await formTypeUseCase.getFormTypeCustomAttributeList(
        projectId: "1",
        taskNumber: 1,
        formTypeId: "1",
        networkExecutionType: NetworkExecutionType.SYNC,
      );
      expect(result, isA<FAIL>());
    });

    test('returns data from getFormTypeDistributionList', () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);

      final result = await formTypeUseCase.getFormTypeDistributionList(networkExecutionType: NetworkExecutionType.SYNC, formTypeId: "1", taskNumber: 1, projectId: "1");
      expect(result, isA<FAIL>());
    });

    test('returns data from getFormTypeControllerUserList', () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";

      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);

      final result = await formTypeUseCase.getFormTypeControllerUserList(networkExecutionType: NetworkExecutionType.SYNC, formTypeId: "1", taskNumber: 1, projectId: "1");
      expect(result, isA<FAIL>());
    });

    test('returns data from getFormTypeStatusList', () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";

      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);

      final result = await formTypeUseCase.getFormTypeStatusList(networkExecutionType: NetworkExecutionType.SYNC, formTypeId: "1", taskNumber: 1, projectId: "1");
      expect(result, isA<FAIL>());
    });

    test('returns data from getFormTypeFixFieldList', () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";

      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);

      final result = await formTypeUseCase.getFormTypeFixFieldList(projectId: "1", taskNumber: 1, formTypeId: "", networkExecutionType: NetworkExecutionType.SYNC, userId: "1");
      expect(result, isA<FAIL>());
    });

    test('returns data from getFormTypeCustomAttributeList', () async {
      AConstants.adoddleUrl = "https://asdf.asite.com";

      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      NetworkService.csrfTokenKey = {'CSRF_SECURITY_TOKEN': 'asdf'};
      final result = await formTypeUseCase.getFormTypeAttributeSetDetail(projectId: "1", taskNumber: 1, networkExecutionType: NetworkExecutionType.SYNC, attributeSetId: "", callingArea: "");
      expect(result, isA<FAIL>());
    });

    test('returns data from getAppTypeList', () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";

      final projectId = 'projectID';
      final isFromMap = false;
      final appTypeId = 'appId';
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      await formTypeUseCase.getAppTypeList(projectId, isFromMap, appTypeId);
      di.getIt<InternetCubit>().isNetworkConnected = false;
      var result = await formTypeUseCase.getInstance();
      expect(result, isA<FormTypeLocalRepository>());
    });
  });
}
