import 'dart:convert';
import 'package:field/data/local/sitetask/sitetask_local_repository_impl.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/database/db_service.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';

class MockSiteTaskLocalRepository extends Mock implements SiteTaskLocalRepository {}

class MockDatabaseManager extends Mock implements DatabaseManager {}
class MockDBService extends Mock implements DBService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  late MockSiteTaskLocalRepository mockSiteTaskLocalRepository;
  late SiteTaskLocalRepository siteTaskLocalRepository;
  late MockDBService mockDBService;

  setUpAll(() {
    di.init(test: true);
    di.getIt.registerLazySingleton<MockSiteTaskLocalRepository>(() => MockSiteTaskLocalRepository());
    mockSiteTaskLocalRepository = di.getIt<MockSiteTaskLocalRepository>();
    siteTaskLocalRepository=di.getIt<SiteTaskLocalRepository>();
    mockDBService = MockDBService();
  });

  Future<Map<String, dynamic>> getDataMap() async {
    int lastApiCallTimeStamp = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> map = {};
    map["appType"] = "2";
    map["applicationId"] = "3";
    map["checkHashing"] = "false";
    map["isRequiredTemplateData"] = "true";
    map["requiredCustomAttributes"] =
    "CFID_Assigned,CFID_DefectTyoe,CFID_TaskType";
    map["customAttributeFieldPresent"] = "true";

    map["projectId"] = '2116416\$\$35785c';
    map["folderId"] = '0\$\$hYzbA7';
    map["locationId"] = '35687';
    map["projectIds"] = '2116416\$\$35785c'.toString().plainValue();
    map["currentPageNo"] = '2';
    map["recordBatchSize"] = '25';
    map["recordStartFrom"] = '0';
    map["sortField"] = 'updated';
    map["sortFieldType"] ='timestamp';
    map["sortOrder"] ="desc"; //FR-678 Sorting listing descending / ascending should display as per the order
    map[AConstants.keyLastApiCallTimestamp] = lastApiCallTimeStamp;
    map["isFromSyncCall"] = "true";
    map["action_id"] = "100";
    map["controller"] = "/commonapi/pfobservationservice/getObservationList";
    map["listingType"] = "31";
    return map;
  }

  test('SiteTaskLocalRepository getSiteTaskList : ', () async {
    Map<String, dynamic> requestMap = await getDataMap();
    final result = await siteTaskLocalRepository.getSiteTaskList(requestMap);
    expect(result, isA<Result<dynamic>>());
  });

  test('SiteTaskLocalRepository getFilterSiteTaskList : ', () async {
    Map<String, dynamic> requestMap = await getDataMap();
    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
    final result = await siteTaskLocalRepository.getFilterSiteTaskList(requestMap);
    expect(result, isA<Result<dynamic>>());
  });

  test('SiteTaskLocalRepository getExternalAttachmentList : ', () async {
    Map<String, dynamic> requestMap = {'projectId': '2116416', 'formIds': '10955881\$\$XTWMOk,10913808\$\$aeEDkG,10852579\$\$bLk80Z'};
    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
    final result = await siteTaskLocalRepository.getExternalAttachmentList(requestMap);
    expect(result, isA<Result<dynamic>>());
  });

  test('SiteTaskLocalRepository getUpdatedSiteTaskItem : ', () async {
    //Map<String, dynamic> requestMap = await getDataMap();
    String projectId='2116416';
    String formId='10955881\$\$XTWMOk';
    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
    final result = await siteTaskLocalRepository.getUpdatedSiteTaskItem(projectId,formId);
    expect(result, isA<Result<dynamic>>());
  });
}
