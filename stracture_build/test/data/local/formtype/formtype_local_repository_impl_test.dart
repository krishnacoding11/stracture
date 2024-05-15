import 'package:field/data/dao/formtype_dao.dart';
import 'package:field/data/local/formtype/formtype_local_repository_impl.dart';
import 'package:field/data/repository/formtype/formtype_repository.dart';
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/sync/calculation/site_form_listing_local_data_soruce.dart';
import 'package:field/injection_container.dart' as di;

class MockSiteFormListingLocalDataSource extends Mock implements SiteFormListingLocalDataSource {}

class MockFormTypeDao extends Mock implements FormTypeDao {}

class MockFormTypeRepository extends Mock implements FormTypeRepository<Map<String, dynamic>, Result> {}

Future<void> main() async {
  di.getIt.registerLazySingleton<SiteFormListingLocalDataSource>(() => MockSiteFormListingLocalDataSource());
  final mockSiteFormListingLocalDataSource = MockSiteFormListingLocalDataSource();
  final formTypeLocalRepository = FormTypeLocalRepository();
  late MockFormTypeDao mockFormTypeDao;

  formTypeLocalRepository.siteFormListingLocalDataSource = mockSiteFormListingLocalDataSource;
  configureLoginCubitDependencies() {
    mockFormTypeDao = MockFormTypeDao();
    formTypeLocalRepository.formTypeDao = mockFormTypeDao;
    //di.getIt.unregister<SiteFormListingLocalDataSource>();
  }

  group('form_type_local_repo', () {
    configureLoginCubitDependencies();

    test('getAppTypeList should populate appTypeList when data is available', () async {
      final mockAppTypeData = [
        {"CanCreateForms": 1, "FormCreationDateInMS": 123},
        {"CanCreateForms": 0}
      ];

      when(() => mockSiteFormListingLocalDataSource.fetchAppTypeList(any())).thenAnswer((_) async => mockAppTypeData);
      when(() => mockFormTypeDao.fromMap(any())).thenReturn(AppType());

      await formTypeLocalRepository.getAppTypeList('projectId', true, 'appTypeId');

      verify(() => mockSiteFormListingLocalDataSource.fetchAppTypeList('projectId')).called(1);
      verify(() => formTypeLocalRepository.formTypeDao.fromMap(any())).called(1);
    });

    test('getAppTypeList should clear appTypeList when no data is available', () async {
      when(() => mockSiteFormListingLocalDataSource.fetchAppTypeList(any())).thenAnswer((_) async => []);

      await formTypeLocalRepository.getAppTypeList('projectId', true, 'appTypeId');

      verify(() => mockSiteFormListingLocalDataSource.fetchAppTypeList('projectId')).called(1);
    });

    /////

    test('getFormTypeControllerUserList returns null', () async {
      final result = await formTypeLocalRepository.getFormTypeControllerUserList({'key': 'value'});
      expect(result, null);
    });

    test('getFormTypeCustomAttributeList returns null', () async {
      final result = await formTypeLocalRepository.getFormTypeCustomAttributeList({'key': 'value'});
      expect(result, null);
    });

    test('getFormTypeAttributeSetDetail returns null', () async {
      final result = await formTypeLocalRepository.getFormTypeAttributeSetDetail({'key': 'value'});
      expect(result, null);
    });

    test('getFormTypeDistributionList returns null', () async {
      final result = await formTypeLocalRepository.getFormTypeDistributionList({'key': 'value'});
      expect(result, null);
    });

    test('getFormTypeFixFieldData returns null', () async {
      final result = await formTypeLocalRepository.getFormTypeFixFieldData({'key': 'value'});
      expect(result, null);
    });

    test('getFormTypeHTMLTemplateZipDownload returns null', () async {
      final result = await formTypeLocalRepository.getFormTypeHTMLTemplateZipDownload({'key': 'value'});
      expect(result, null);
    });

    test('getFormTypeStatusList returns null', () async {
      final result = await formTypeLocalRepository.getFormTypeStatusList({'key': 'value'});
      expect(result, null);
    });

    test('getFormTypeXSNTemplateZipDownload returns null', () async {
      final result = await formTypeLocalRepository.getFormTypeXSNTemplateZipDownload({'key': 'value'});
      expect(result, null);
    });

    test('getLatestProjectDefectFormTypeIdList returns null', () async {
      final result = await formTypeLocalRepository.getLatestProjectDefectFormTypeIdList({'key': 'value'});
      expect(result, null);
    });
  });
}
