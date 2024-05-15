import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:field/data/model/quality_activity_list_vo.dart';
import 'package:field/data/remote/upload/upload_repository_impl.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/fixture_reader.dart';
import 'mock_dio_adpater.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setBuildFlavorMethodChannel();
  AConstants.loadProperty();
  late UploadRemoteRepository uploadRemoteRepository;
  late MockDioAdapter mockDioAdapter;

  setUpAll(() {
    uploadRemoteRepository = UploadRemoteRepository();
    mockDioAdapter = MockDioAdapter();
  });

  configureCubitDependencies() {
    di.init(test: true);
  }

  group("Test Upload File", () {
    configureCubitDependencies();
    QualityActivityList activityResponse = QualityActivityList.fromJson(jsonDecode(fixture("quality_activity_listing_response.json")));
    List<ActivitiesList>? activitiesList = activityResponse.response!.root!.activitiesList;
    ActivitiesList activity = activitiesList!.first;

    test("Test Upload File Lock Validation [Success]", () async {
      Map<String, dynamic> fileLockValidationMap = {};
      fileLockValidationMap["action_id"] = 138;
      fileLockValidationMap["project_id"] = activityResponse.response!.root!.projectID!;
      fileLockValidationMap["folder_id"] = activity.folderId;
      fileLockValidationMap["validationType"] = 1;
      fileLockValidationMap["forPublishing"] = false;
      fileLockValidationMap["rowNumbers"] = 1;
      fileLockValidationMap["caller"] = 2;
      fileLockValidationMap["filename1"] = "IMG_0143.jpeg";

      mockDioAdapter.dioAdapter.onPost(AConstants.uploadAttachmentUrl, (server) => server.reply(200, jsonEncode([])), data: fileLockValidationMap);

      final result = await uploadRemoteRepository.getLockValidation(fileLockValidationMap, mockDioAdapter.dio);
      expect(result, isA<SUCCESS>());
      expect(result.data.runtimeType, List);
    });

    test("Test Upload File Lock Validation [Failed]", () async {
      Map<String, dynamic> fileLockValidationMap = {};
      mockDioAdapter.dioAdapter.onPost(
          AConstants.uploadAttachmentUrl,
          (server) => server.throws(
              502,
              DioException(
                requestOptions: RequestOptions(
                  path: AConstants.uploadAttachmentUrl,
                ),
              )),
          data: fileLockValidationMap);
      final result = await uploadRemoteRepository.getLockValidation(fileLockValidationMap, mockDioAdapter.dio);
      expect(result, isA<FAIL>());
    });

    test("Test Upload File Event Validation [Success]", () async {
      Map<String, dynamic> fileUploadValidationMap = {};
      fileUploadValidationMap["projectId"] = activityResponse.response!.root!.projectID!;
      fileUploadValidationMap["folderId"] = activity.folderId;
      fileUploadValidationMap["uploadType"] = 2;
      fileUploadValidationMap["userId"] = "1234";
      fileUploadValidationMap["thinUploadDocs"] = [
        {"filename": "IMG_0143.jpeg"}
      ];
      Map<String, dynamic> requestData = {};
      requestData["uploadEventData"] = jsonEncode(fileUploadValidationMap);

      mockDioAdapter.dioAdapter.onPost(AConstants.uploadEventValidation, (server) => server.reply(200, jsonEncode([])), data: requestData);


      final result = await uploadRemoteRepository.checkUploadEventValidation(fileUploadValidationMap,mockDioAdapter.dio);
      expect(result, isA<SUCCESS>());
      expect(jsonDecode(result.data).runtimeType, List);
    });


    test("Test Upload File Event Validation [FAIL]", () async {
      Map<String, dynamic> fileUploadValidationMap = {};
      fileUploadValidationMap["projectId"] = activityResponse.response!.root!.projectID!;
      fileUploadValidationMap["folderId"] = activity.folderId;
      fileUploadValidationMap["uploadType"] = 2;
      fileUploadValidationMap["userId"] = "";
      fileUploadValidationMap["thinUploadDocs"] = [
        {"filename": "IMG_0143.jpeg"}
      ];
      Map<String, dynamic> requestData = {};
      requestData["uploadEventData"] = jsonEncode(fileUploadValidationMap);

      mockDioAdapter.dioAdapter.onPost(AConstants.uploadEventValidation, (server) => server.throws(1502, DioException(requestOptions:  RequestOptions(
        path: AConstants.uploadAttachmentUrl,
      ),)), data: requestData);


      final result = await uploadRemoteRepository.checkUploadEventValidation(fileUploadValidationMap,mockDioAdapter.dio);
      expect(result, isA<FAIL>());
    });

    test("Test Simple File Upload [Success]", () async {
      Map<String, dynamic> simpleFileUploadMap = {};
      simpleFileUploadMap["projId"] = activityResponse.response!.root!.projectID!;
      simpleFileUploadMap["folderId"] = activity.folderId;
      simpleFileUploadMap["deliverableActivityId"] = activity.deliverableActivities!.first.qiActivityId;
      simpleFileUploadMap["planId"] = activityResponse.response!.root!.planID!;
      simpleFileUploadMap["isMac"] = 1;
      simpleFileUploadMap["totalFiles"] = 1;
      simpleFileUploadMap["upFile0"] = File('');
      FormData formData = FormData();
      formData = FormData.fromMap(simpleFileUploadMap);


      final responseData = [jsonDecode(fixture('simple_file_upload.json'))];

      mockDioAdapter.dioAdapter.onPost(AConstants.simpleFileUpload, (server) => server.reply(200, jsonEncode(responseData)), data: formData);

      final result = await uploadRemoteRepository.simpleFileUploadToServer(simpleFileUploadMap,mockDioAdapter.dio);
      expect(result, isA<SUCCESS>());
    });

    test("Test Simple File Upload [FAIL]", () async {
      Map<String, dynamic> simpleFileUploadMap = {};
      simpleFileUploadMap["projId"] = activityResponse.response!.root!.projectID!;
      simpleFileUploadMap["folderId"] = activity.folderId;
      simpleFileUploadMap["deliverableActivityId"] = activity.deliverableActivities!.first.qiActivityId;
      simpleFileUploadMap["planId"] = activityResponse.response!.root!.planID!;
      simpleFileUploadMap["isMac"] = 1;
      simpleFileUploadMap["totalFiles"] = 1;
      simpleFileUploadMap["upFile0"] = File('');

      mockDioAdapter.dioAdapter.onPost(AConstants.simpleFileUpload, (server) => server.throws(1502, DioException(requestOptions:  RequestOptions(
        path: AConstants.uploadAttachmentUrl,
      ),)));

      final result = await uploadRemoteRepository.simpleFileUploadToServer({},mockDioAdapter.dio);
      expect(result, isA<FAIL>());
    });

    /* Map<String, dynamic> fileUploadValidationMap = {};
    fileUploadValidationMap["projectId"] = activityResponse.response!.root!.projectID!;
    fileUploadValidationMap["folderId"] = activity.folderId;
    fileUploadValidationMap["uploadType"] = 2;
    fileUploadValidationMap["userId"] = "";
    fileUploadValidationMap["thinUploadDocs"] = [
      {"filename": "IMG_0143.jpeg"}
    ];

    test("Test Upload File Event Validation Success", () async {
      when(() => mockUploadRemoteRepository.checkUploadEventValidation(fileUploadValidationMap)).thenAnswer((_) async => Future(() => SUCCESS(const [], null, null)));
      final result = await mockUploadRemoteRepository.checkUploadEventValidation(fileUploadValidationMap);
      expect(result, isA<SUCCESS>());
    });

    test("Test Upload File Event Validation Failed", () async {
      when(() => mockUploadRemoteRepository.checkUploadEventValidation(fileUploadValidationMap)).thenAnswer((_) async => Future(() => FAIL("", 204)));
      final result = await mockUploadRemoteRepository.checkUploadEventValidation(fileUploadValidationMap);
      expect(result, isA<FAIL>());
    });


    Map<String, dynamic> simpleFileUploadMap = {};
    simpleFileUploadMap["projId"] = activityResponse.response!.root!.projectID!;
    simpleFileUploadMap["folderId"] = activity.folderId;
    simpleFileUploadMap["deliverableActivityId"] = activity.deliverableActivities!.first.qiActivityId;
    simpleFileUploadMap["planId"] = activityResponse.response!.root!.planID!;
    simpleFileUploadMap["isMac"] = 1;
    simpleFileUploadMap["totalFiles"] = 1;
    simpleFileUploadMap["upFile0"] = File('');


    test("Test Simple File Upload Success", () async {
      when(() => mockUploadRemoteRepository.simpleFileUploadToServer(simpleFileUploadMap)).thenAnswer((_) async => Future(() => SUCCESS(const [], null, null)));
      final result = await mockUploadRemoteRepository.simpleFileUploadToServer(simpleFileUploadMap);
      expect(result, isA<SUCCESS>());
    });

    test("Test Simple File Upload Failed", () async {
      when(() => mockUploadRemoteRepository.simpleFileUploadToServer(simpleFileUploadMap)).thenAnswer((_) async => Future(() => FAIL("", 204)));
      final result = await mockUploadRemoteRepository.simpleFileUploadToServer(simpleFileUploadMap);
      expect(result, isA<FAIL>());
    });*/
  });
}
