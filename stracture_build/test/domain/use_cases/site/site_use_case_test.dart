// import 'package:field/data/model/site_location.dart';
// import 'package:field/database/db_service.dart';
// import 'package:field/domain/use_cases/site/site_use_case.dart';
// import 'package:field/networking/network_response.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:field/injection_container.dart' as di;
// import '../../../fixtures/fixture_reader.dart';
//
// class MockSiteUseCase extends Mock implements SiteUseCase {}
// class MockDBService extends Mock implements DBService {}

// void main() {
//   late MockSiteUseCase mockSiteUseCase;
//   List<SiteLocation>? siteLocationList = [];
//   late MockDBService mockDBService;
//
//   setUp(() {
//     mockSiteUseCase = MockSiteUseCase();
//     mockDBService = MockDBService();
//     siteLocationList = SiteLocation.jsonToList(fixture("site_location.json"));
//   });
//
//
//   group("Test LocationDetailsByLocationIds", () {
//     test("get ExternalAttachmentList", () async {
//       Map<String, dynamic> requestMap = {'projectId': '2116416', 'formIds': '10955881\$\$XTWMOk,10913808\$\$aeEDkG,10852579\$\$bLk80Z'};
//       // di.getIt.unregister<DBService>();
//       // di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
//       final result = await  mockSiteUseCase.getLocationTree(requestMap);
//       expect(result, isA<Result>());
//     });
//
//     // test("Fail response", () async {
//     //   when(() => mockSiteUseCase.getLocationDetailsByLocationIds(any()))
//     //       .thenAnswer((_) {
//     //     return Future.value([]);
//     //   });
//     //   var result = await mockSiteUseCase.getLocationDetailsByLocationIds({});
//     //   expect(result?.isEmpty, true);
//     // });
//   });
//
//   // group("Test Get Location Details By AnnotationId", () {
//   //   test("Success response", () async {
//   //     when(() => mockSiteUseCase.getLocationTreeByAnnotationId(any()))
//   //         .thenAnswer((_) {
//   //       return Future.value(siteLocationList![3]);
//   //     });
//   //     var result = await mockSiteUseCase.getLocationTreeByAnnotationId({});
//   //     expect(result != null, true);
//   //   });
//   //   test("Fail response", () async {
//   //     when(() => mockSiteUseCase.getLocationTreeByAnnotationId(any()))
//   //         .thenAnswer((_) {
//   //       return Future.value(null);
//   //     });
//   //     var result = await mockSiteUseCase.getLocationTreeByAnnotationId({});
//   //     expect(result, null);
//   //   });
//   // });
//   //
//   // group("Test Get Location List", () {
//   //   test("Success response", () async {
//   //     when(() => mockSiteUseCase.getLocationTree(any())).thenAnswer((_) {
//   //       return Future.value(SUCCESS(siteLocationList, null, null));
//   //     });
//   //     var result = await mockSiteUseCase.getLocationTree({});
//   //     expect(result, isA<SUCCESS>());
//   //   });
//   //   test("Fail response", () async {
//   //     when(() => mockSiteUseCase.getLocationTree(any())).thenAnswer((_) {
//   //       return Future.value(FAIL("", 204));
//   //     });
//   //     var result = await mockSiteUseCase.getLocationTree({});
//   //     expect(result, isA<FAIL>());
//   //   });
//   // });
//   //
//   // group("Get Search List", () {
//   //   test("Success response", () async {
//   //     when(() => mockSiteUseCase.getSearchList(any())).thenAnswer((_) {
//   //       return Future.value(SUCCESS(fixture("location_search_list.json"), null, null));
//   //     });
//   //     var result = await mockSiteUseCase.getSearchList({});
//   //     expect(result, isA<SUCCESS>());
//   //   });
//   //   test("Fail response", () async {
//   //     when(() => mockSiteUseCase.getSearchList(any())).thenAnswer((_) {
//   //       return Future.value(FAIL("", 204));
//   //     });
//   //     var result = await mockSiteUseCase.getSearchList({});
//   //     expect(result, isA<FAIL>());
//   //   });
//   // });
//   //
//   // group("Get suggestion Search List", () {
//   //   test("Success response", () async {
//   //     when(() => mockSiteUseCase.getSuggestedSearchList(any())).thenAnswer((_) {
//   //       return Future.value(SUCCESS(fixture("location_suggestion_search_list.json"), null, null));
//   //     });
//   //     var result = await mockSiteUseCase.getSuggestedSearchList({});
//   //     expect(result, isA<SUCCESS>());
//   //   });
//   //   test("Fail response", () async {
//   //     when(() => mockSiteUseCase.getSuggestedSearchList(any())).thenAnswer((_) {
//   //       return Future.value(FAIL("", 204));
//   //     });
//   //     var result = await mockSiteUseCase.getSuggestedSearchList({});
//   //     expect(result, isA<FAIL>());
//   //   });
//   // });
// }
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:field/data/local/sitetask/sitetask_local_repository_impl.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/data/remote/sitetask/sitetask_remote_repository_impl.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/site/site_use_case.dart';
import 'package:field/domain/use_cases/sitetask/sitetask_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/download_service.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appconfig_test_data.dart';
import '../../../fixtures/fixture_reader.dart';

class MockSiteUseCase extends Mock implements SiteUseCase {}
class MockDBService extends Mock implements DBService {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  //late MockDioAdapter mockDioAdapter;
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setBuildFlavorMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setConnectivity();
  AConstants.loadProperty();
  late SiteUseCase siteUseCase;
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
    map["revisionId"] = '2661255';
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
    siteUseCase = SiteUseCase();
    //mockDioAdapter = MockDioAdapter();
    mockDBService = MockDBService();
    AppConfigTestData().setupAppConfigTestData();
    di.getIt.unregister<InternetCubit>();
    di.getIt.registerLazySingleton<InternetCubit>(() => InternetCubit());
    response = fixture("sitetaskslist.json");
  });

  group("SiteTask use case:", () {


    test("get site task list", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> map = getDataMap();
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      final result = await siteUseCase.getLocationTree(map);
      expect(result, isA<Result<dynamic>>());
    });

    test("get site task list by Filter API", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> map = getDataMap();
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      final result = await siteUseCase.getLocationTreeByAnnotationId(map);
      expect(result, null);
    });
    test("get site task list by Filter API", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> map = getDataMap();
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      final result = await siteUseCase.getLocationDetailsByLocationIds(map);
      expect(result, []);
    });
    test("get site task list by Filter API", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> map = getDataMap();
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      final result = await siteUseCase.getObservationListByPlan(map);
      expect(result, []);
    });
    test("get site task list by Filter API", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> map = getDataMap();
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      final result = await siteUseCase.getSearchList(map);
      expect(result, isA<Result<dynamic>>());
    });
    test("get site task list by Filter API", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> map = getDataMap();
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      final result = await siteUseCase.getSuggestedSearchList(map);
      expect(result, isA<Result<dynamic>>());
    });
    test("get site task list by Filter API", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> map = getDataMap();
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      final result = await siteUseCase.isProjectLocationMarkedOffline("2116416");
      expect(result, false);
    });
    test("get site task list by Filter API", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> map = getDataMap();
      final result = await siteUseCase.isProjectLocationMarkedOffline("");
      expect(result, false);
    });
    test("get site task list by Filter API", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> map = getDataMap();
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      final result = await siteUseCase.canRemoveOfflineLocation("2116416",[""],);
      expect(result, false);
    });
    test("get site task list by Filter API", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> map = getDataMap();
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      final result = await siteUseCase.deleteItemFromSyncTable(map);
      expect(result, []);
    });
    test("get site task list by Filter API", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> map = getDataMap();
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      final result = await siteUseCase.downloadPdf(map);
      expect(result, isA<DownloadResponse>());
    });
    test("get site task list by Filter API", () async {
      AConstants.adoddleUrl = "https://dmsqaak.asite.com";
      Map<String, dynamic> map = getDataMap();
      di.getIt.unregister<DBService>();
      di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
      final result = await siteUseCase.downloadXfdf(map);
      expect(result, isA<DownloadResponse>());
    });
    //
    // test("get ExternalAttachmentList", () async {
    //   AConstants.adoddleUrl = "https://dmsqaak.asite.com";
    //   Map<String, dynamic> requestMap = {'projectId': '2116416', 'formIds': '10955881\$\$XTWMOk,10913808\$\$aeEDkG,10852579\$\$bLk80Z'};
    //   di.getIt.unregister<DBService>();
    //   di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
    //   final result = await siteUseCase.getExternalAttachmentList(requestMap);
    //   expect(result, isA<Result<dynamic>>());
    // });
    //
    // test("get UpdatedSiteTaskItem", () async {
    //   AConstants.adoddleUrl = "https://dmsqaak.asite.com";
    //   Map<String, dynamic> map = {};
    //   String projectId='2116416';
    //   String formId='10955881\$\$XTWMOk';
    //   di.getIt.unregister<DBService>();
    //   di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDBService);
    //   final result = await siteUseCase.getUpdatedSiteTaskItem(projectId,formId);
    //   expect(result, isA<Result<dynamic>>());
    // });
  });
}