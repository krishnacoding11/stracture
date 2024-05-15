import 'dart:convert';
import 'package:field/database/db_service.dart';
import 'package:field/injection_container.dart' as di;

import 'package:field/data/model/simple_file_upload.dart';
import 'package:field/data/remote/upload/upload_repository_impl.dart';
import 'package:field/domain/use_cases/upload/upload_usecase.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appconfig_test_data.dart';
import '../../../fixtures/fixture_reader.dart';

dynamic duplicateFileNameResponse = [
  {
    "messageCode": 2022,
    "docRefs": [
      "IMG_20230719_165310.jpg"
    ],
    "validExistingFileList": [
      27092239
    ],
    "validExistingDocIdList": [
      13571050
    ],
    "latestFileNameDocrefDetails": {
      "13571050": [
        "IMG_20230719_165310",
        "IMG_20230719_165310.jpg"
      ]
    },
    "generateURI": true
  }
];

class MockUploadRemoteRepo extends Mock implements UploadRemoteRepository{}

class DBServiceMock extends Mock implements DBService {}

void main() {
  DBServiceMock? mockDb = DBServiceMock();
  TestWidgetsFlutterBinding.ensureInitialized();
  MockUploadRemoteRepo mockUploadRemoteRepo = MockUploadRemoteRepo();
  dynamic simpleFileUploadResponse;

  setUpAll(() async {
    MockMethodChannel().setNotificationMethodChannel();
    await di.init(test: true);
    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
    di.getIt.unregister<UploadRemoteRepository>();
    di.getIt.registerLazySingleton<UploadRemoteRepository>(() => mockUploadRemoteRepo);
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AppConfigTestData().setupAppConfigTestData();
    AConstants.adoddleUrl = "https://adoddleqaak.asite.com";
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json"), "cloud_type_data": "1", "1_u1_project_": fixture("project.json")});
    simpleFileUploadResponse = SimpleFileUpload.fromJson(jsonDecode(fixture("simple_file_upload.json")));
  });

  tearDown(() {
    mockDb = null;
  });

  group("Upload File to Server", () {
    test("Success Upload of File", () async {
      const fileName = 'temp_img_annotation.png';
      when(() => mockUploadRemoteRepo.getLockValidation(any())).thenAnswer((_) { return Future.value(SUCCESS([], null, 200));});
      when(() => mockUploadRemoteRepo.checkUploadEventValidation(any())).thenAnswer((_) { return Future.value(SUCCESS([], null, 200));});
      when(() => mockUploadRemoteRepo.simpleFileUploadToServer(any())).thenAnswer((_) { return Future.value(SUCCESS(simpleFileUploadResponse, null, 200));});
      var result = await UploadUseCase().uploadFileToServer(fixtureFile(fileName), fileName, "2100809\$\$coUdXe", "91839471\$\$3RNKz0");
      expect(result, isA<SUCCESS>());
    });

    test("Success Upload Duplicate File Name", () async {
      const fileName = 'temp_img_annotation.png';
      when(() => mockUploadRemoteRepo.getLockValidation(any())).thenAnswer((_) { return Future.value(SUCCESS(duplicateFileNameResponse, null, 200));});
      when(() => mockUploadRemoteRepo.checkUploadEventValidation(any())).thenAnswer((_) { return Future.value(SUCCESS([], null, 200));});
      when(() => mockUploadRemoteRepo.simpleFileUploadToServer(any())).thenAnswer((_) { return Future.value(SUCCESS(simpleFileUploadResponse, null, 200));});
      var result = await UploadUseCase().uploadFileToServer(fixtureFile(fileName), fileName, "2100809\$\$coUdXe", "91839471\$\$3RNKz0");
      expect(result, isA<SUCCESS>());
    });

    test("Fail when getLockValidation is Failed", () async {
      const fileName = 'temp_img_annotation.png';
      when(() => mockUploadRemoteRepo.getLockValidation(any())).thenAnswer((_) { return Future.value(FAIL(null, 400));});
      var result = await UploadUseCase().uploadFileToServer(fixtureFile(fileName), fileName, "2100809\$\$coUdXe", "91839471\$\$3RNKz0");
      expect(result, isA<FAIL>());
    });

    test("Success of getLockValidation but validation is Failed", () async {
      const fileName = 'temp_img_annotation.png';
      when(() => mockUploadRemoteRepo.getLockValidation(any())).thenAnswer((_) { return Future.value(SUCCESS([{'messageCode': 1504}], null, 200));});
      var result = await UploadUseCase().uploadFileToServer(fixtureFile(fileName), fileName, "2100809\$\$coUdXe", "91839471\$\$3RNKz0");
      expect(result, isA<FAIL>());
    });

    test("Fail when checkUploadEventValidation is Failed", () async {
      const fileName = 'temp_img_annotation.png';
      when(() => mockUploadRemoteRepo.getLockValidation(any())).thenAnswer((_) { return Future.value(SUCCESS(duplicateFileNameResponse, null, 200));});
      when(() => mockUploadRemoteRepo.checkUploadEventValidation(any())).thenAnswer((_) { return Future.value(FAIL(null, 404));});
      var result = await UploadUseCase().uploadFileToServer(fixtureFile(fileName), fileName, "2100809\$\$coUdXe", "91839471\$\$3RNKz0");
      expect(result, isA<FAIL>());
    });

    test("Success of checkUploadEventValidation but when response message is FAIL Failed", () async {
      const fileName = 'temp_img_annotation.png';
      when(() => mockUploadRemoteRepo.getLockValidation(any())).thenAnswer((_) { return Future.value(SUCCESS(duplicateFileNameResponse, null, 200));});
      when(() => mockUploadRemoteRepo.checkUploadEventValidation(any())).thenAnswer((_) { return Future.value(SUCCESS([FAIL], null, 200));});
      var result = await UploadUseCase().uploadFileToServer(fixtureFile(fileName), fileName, "2100809\$\$coUdXe", "91839471\$\$3RNKz0");
      expect(result, isA<FAIL>());
    });
  });
}
