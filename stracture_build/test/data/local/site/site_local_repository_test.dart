import 'dart:convert';
import 'package:field/data/local/site/create_form_local_repository.dart';
import 'package:field/data/local/site/site_local_repository.dart';
import 'package:field/data/local/sitetask/sitetask_local_repository_impl.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/pinsdata_vo.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/database/db_service.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/download_service.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../utils/load_url.dart';

class MockSiteSiteLocalRepository extends Mock implements SiteLocalRepository {}
class MockDatabaseManager extends Mock implements DatabaseManager {}
class DBServiceMock extends Mock implements DBService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannelUrl().setupBuildFlavorMethodChannel();
  late MockSiteSiteLocalRepository mockSiteSiteLocalRepository;
  late SiteLocalRepository siteLocalRepository;
  late MockDatabaseManager mockDBService;
  setUpAll(() {
    di.init(test: true);
    di.getIt.registerLazySingleton<MockSiteSiteLocalRepository>(() => MockSiteSiteLocalRepository());
    mockSiteSiteLocalRepository = di.getIt<MockSiteSiteLocalRepository>();
    siteLocalRepository = di.getIt<SiteLocalRepository>();
    mockDBService = MockDatabaseManager();
    di.getIt.unregister<InternetCubit>();
    di.getIt.registerLazySingleton<InternetCubit>(() => InternetCubit());
  });

  test('createFormLocalRepository downloadInLineAttachment : ', () async {
    Map<String, dynamic> requestMap = <String, dynamic>{"projectId": "6444521", "revisionId": "545645"};
    final result = await siteLocalRepository.downloadPdf(requestMap);
    expect(result, isA<DownloadResponse>());
  });

  test('createFormLocalRepository downloadInLineAttachment : ', () async {
    Map<String, dynamic> requestMap = <String, dynamic>{"projectId": "6444521", "revisionId": "545645"};
    final result = await siteLocalRepository.downloadXfdf(requestMap);
    expect(result, isA<DownloadResponse>());
  });
  test('createFormLocalRepository downloadInLineAttachment : ', () async {
    Map<String, dynamic> requestMap = <String, dynamic>{"projectId": "", "folderId": ""};
    final result = await siteLocalRepository.getLocationTree(requestMap);
    expect(result, isA<Result<dynamic>>());
  });

  test('createFormLocalRepository getVOFromResponse : ', () async {
    final result = await siteLocalRepository.getVOFromResponse('[{"projectId" : "","folderId" : ""}]');
    expect(result, []);
  });
  test('createFormLocalRepository getVOFromResponse : ', () async {
    Map<String, dynamic> requestMap = <String, dynamic>{"projectId": "", "folderId": ""};
    di.getIt.unregister<DatabaseManager>();
    di.getIt.registerFactoryParam<DatabaseManager, String, void>((filePath, _) => mockDBService);
    final result = await siteLocalRepository.getLocationTree(requestMap);
    expect(result, []);
  });
  // test('createFormLocalRepository downloadInLineAttachment : ', () async {
  //
  //   Map<String, dynamic> requestMap = <String, dynamic>{"projectId": "6444521", "revisionId": "545645", "observationIds": "s56451", "onlyOfflineCreatedDataReq": true};
  //   final result = await siteLocalRepository.getObservationListByPlan(requestMap);
  //   expect(result, isA<List<ObservationData>>());
  // });
}
