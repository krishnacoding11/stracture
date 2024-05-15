import 'dart:convert';

import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/data/remote/site/site_remote_repository.dart';
import 'package:field/data_source/site_location/site_location_local_data_source.dart';
import 'package:field/database/db_service.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/fixture_reader.dart';
import 'mock_dio_adpater.dart';

class MockSiteLocationLocalDatasource extends Mock implements SiteLocationLocalDatasource {}

class DBServiceMock extends Mock implements DBService {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  late SiteRemoteRepository siteRemoteRepository;
  late MockDioAdapter mockDioAdapter;
  final mockSiteLocationLocalDatasource = MockSiteLocationLocalDatasource();
  DBServiceMock mockDb = DBServiceMock();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setBuildFlavorMethodChannel();
  AConstants.loadProperty();

  di.init(test: true);
  di.getIt.unregister<SiteLocationLocalDatasource>();
  di.getIt.registerLazySingleton<SiteLocationLocalDatasource>(() => mockSiteLocationLocalDatasource);
  di.getIt.unregister<DBService>();
  di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb);

  setUp(() {
    mockDioAdapter = MockDioAdapter();
    siteRemoteRepository = SiteRemoteRepository();
  });

  group("Site Remote repository Implementation: ", () {
    List<SiteLocation>? siteLocationList = SiteLocation.jsonToList(fixture("site_location.json"));
    SiteLocation location = siteLocationList![0];
    Map<String, dynamic> downloadPdfRequest = {"projectId": location.projectId, "folderId": location.folderId, "revisionId": location.pfLocationTreeDetail!.revisionId};

    test("test get Location Tree", () async {
      Project project = Project.fromJson(jsonDecode(fixture("project.json")));
      Map<String, dynamic> mapRequest = {
        "projectId": project.projectID!,
        "action_id": "2",
        "appType": "2",
        "folderId": "0",
        "isRequiredTemplateData": "true",
        "isWorkspace": '1',
        "projectIds": "-2",
        "checkHashing": "false",
      };
      when(() => mockSiteLocationLocalDatasource.getSyncStatusDataByLocationId(any())).thenAnswer((invocation) async => [
            {"ProjectId": "2089700", "LocationId": "25506", "SyncProgress": 100, "SyncStatus": 1, "CanRemoveOffline": 1, "IsMarkOffline": 1, "LastSyncTimeStamp": "2023-08-08 10:44:27.76"}
          ]);
      mockDioAdapter.dioAdapter.onPost(AConstants.locationTreeUrl, (server) => server.reply(200, fixture("site_location.json")), data: mapRequest);
      final result = await siteRemoteRepository.getLocationTree(mapRequest, mockDioAdapter.dio);
      expect(result, isA<SUCCESS>());
    });

    test("Observation List By Plan Test", () async {
      Project project = Project.fromJson(jsonDecode(fixture("project.json")));
      Map<String, dynamic> mapRequest = {"projectId": project.projectID!, "revisionId": "26806140\$\$AL5UXO", "FromTab": 3, "checkHashing": "false", "includeDraft": "true", "isRequiredTemplateData": "true", "viewAlwaysFormAssociation": "false", "isExcludeClosesOutForms": "true", "onlyOfflineCreatedDataReq": true};
      mockDioAdapter.dioAdapter.onPost(AConstants.planObservationList, (server) => server.reply(200, fixture("observations_list.json")), data: mapRequest);
      final result = await siteRemoteRepository.getObservationListByPlan(mapRequest, mockDioAdapter.dio);
      expect(result!.isNotEmpty, true);
    });

    test("Search List Test", () async {
      Map<String, dynamic> mapRequest = {"action_id": "1002", "searchValue": "vijay", "folderTypeId": "1", "selectedProjectIds": "2130192"};
      Map<String, dynamic> responseMap = {
        "totalDocs": 1,
        "recordBatchSize": 0,
        "data": [
          {"id": "115096348\$\$qpT53q#2130192\$\$9Za1dH", "value": "Site Quality Demo\\01 Vijay_Test", "dataCenterId": 0, "isSelected": false, "imgId": -1, "isActive": true}
        ],
        "isSortRequired": true,
        "isReviewEnableProjectSelected": false,
        "isAmessageProjectSelected": false,
        "generateURI": true
      };
      String responseData = jsonEncode(responseMap);
      mockDioAdapter.dioAdapter.onPost(AConstants.getSearchLocationList, (server) => server.reply(200, responseData), data: mapRequest);
      final result = await siteRemoteRepository.getSearchList(mapRequest, mockDioAdapter.dio);
      expect(result, isA<SUCCESS>());
    });

    test("Suggested List Test", () async {
      Map<String, dynamic> mapRequest = {"recordBatchSize": 10, "searchValue": "vij", "folderTypeId": "1", "selectedProjectIds": "2130192"};
      String responseData = "{\"01 Vijay_Test\":1}";
      String endPointUrl = AConstants.getSuggestedSearchLocationList;
      String temUrl = "";
      mapRequest.forEach((key, value) {
        if (temUrl.isNotEmpty) {
          temUrl = '$temUrl&';
        }
        temUrl = '$temUrl$key=$value';
      });
      endPointUrl = '$endPointUrl?$temUrl';
      mockDioAdapter.dioAdapter.onGet(endPointUrl, (server) => server.reply(200, responseData));
      final result = await siteRemoteRepository.getSuggestedSearchList(mapRequest, mockDioAdapter.dio);
      expect(result, isA<SUCCESS>());
    });

    test("Location by Annotation Id Test", () async {
      Map<String, dynamic> mapRequest = {"projectId": "2130192", "annotationId": "adf40cc9-02dc-8349-05d5-ebf2cf472773"};
      mockDioAdapter.dioAdapter.onPost(AConstants.locationTreeByAnnotationIdUrl, (server) => server.reply(200, location.toJson()), data: mapRequest);

      final result = await siteRemoteRepository.getLocationTreeByAnnotationId(mapRequest, mockDioAdapter.dio);
      expect(result, isA<SiteLocation>());
    });
  });
}
