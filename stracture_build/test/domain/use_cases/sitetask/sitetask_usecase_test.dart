import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:field/data/local/sitetask/sitetask_local_repository_impl.dart';
import 'package:field/data/remote/sitetask/sitetask_remote_repository_impl.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/sitetask/sitetask_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appconfig_test_data.dart';
import '../../../fixtures/fixture_reader.dart';

class MockSiteUseCase extends Mock implements SiteTaskUseCase {}
class MockDBService extends Mock implements DBService {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  //late MockDioAdapter mockDioAdapter;
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setBuildFlavorMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setConnectivity();
  AConstants.loadProperty();
  late SiteTaskUseCase siteTaskUseCase;
  late MockDBService mockDBService;
  dynamic response;
  Map<String, dynamic> getDataMap(){
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

  setUpAll(()async{
    await di.init(test: true);
    siteTaskUseCase = SiteTaskUseCase();
    //mockDioAdapter = MockDioAdapter();
    mockDBService = MockDBService();
    AppConfigTestData().setupAppConfigTestData();
    di.getIt.unregister<InternetCubit>();
    di.getIt.registerLazySingleton<InternetCubit>(() => InternetCubit());
    response = fixture("sitetaskslist.json");
  });

  test('getInstance should return FormTypeRemoteRepository when network is connected', () async {
    final result = await siteTaskUseCase.getInstance();
    expect(result, isA<SiteTaskRemoteRepository>());
  });

  test('getInstance should return FormTypeLocalRepository when network is not connected', () async {
    di.getIt<InternetCubit>().isNetworkConnected = false;
    var result = await siteTaskUseCase.getInstance();
    expect(result, isA<SiteTaskLocalRepository>());
  });

  group("SiteTask use case:", () {


    test("get site task list", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> map = getDataMap();
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      final result = await siteTaskUseCase.getSiteTaskList(map);
      expect(result, isA<Result<dynamic>>());
    });

    test("get site task list by Filter API", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> map = getDataMap();
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      final result = await siteTaskUseCase.getFilterSiteTaskList(map);
      expect(result, isA<Result<dynamic>>());
    });

    test("get ExternalAttachmentList", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> requestMap = {'projectId': '2116416', 'formIds': '10955881\$\$XTWMOk,10913808\$\$aeEDkG,10852579\$\$bLk80Z'};
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      final result = await siteTaskUseCase.getExternalAttachmentList(requestMap);
      expect(result, isA<Result<dynamic>>());
    });

    test("get UpdatedSiteTaskItem", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> map = {};
      String projectId='2116416';
      String formId='10955881\$\$XTWMOk';
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      final result = await siteTaskUseCase.getUpdatedSiteTaskItem(projectId,formId);
      expect(result, isA<Result<dynamic>>());
    });
  });

}
