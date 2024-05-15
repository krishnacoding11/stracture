import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:field/data/model/download_size_vo.dart';
import 'package:field/data/model/sync_size_vo.dart';
import 'package:field/data/remote/download_size/download_size_repositroy_impl.dart';
import 'package:field/domain/use_cases/download_size/download_size_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appconfig_test_data.dart';
import '../../../fixtures/fixture_reader.dart';

class MockDownloadSizeRepository extends Mock implements DownloadSizeRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  late MockDownloadSizeRepository mockDownloadSizeRepository;
  late DownloadSizeUseCase downloadSizeUseCase;

  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<DownloadSizeRepository>();
    di.getIt.registerLazySingleton<DownloadSizeRepository>(() => mockDownloadSizeRepository);
  }

  setUp(() {
    mockDownloadSizeRepository = MockDownloadSizeRepository();
    downloadSizeUseCase = DownloadSizeUseCase(downloadSizeRepository: mockDownloadSizeRepository);
  });

  group("Test DownloadSyncSize", () {
    configureCubitDependencies();
    AppConfigTestData().setupAppConfigTestData();
    List<dynamic> data = json.decode(fixture('download_size_data.json'));
    List<dynamic> expectedData = json.decode(fixture("sync_size_vo.json"));
    List<SyncSizeVo> expectedSyncVo1;



    test("DownloadSyncSize [Success] response", () async {
      Result? result = SUCCESS(DownloadSizeVo.getDownloadSize(data[0]), Headers(), 200);
      when(() => mockDownloadSizeRepository.getOfflineSyncDataSize(any())).thenAnswer((_) => Future.value(result));
      when(() => mockDownloadSizeRepository.addSyncSize(any())).thenAnswer((_) => Future.value());
      var response = await downloadSizeUseCase.getOfflineSyncDataSize({});
      expect(response!.data != null, true);
    });

    test("DownloadSyncSize [Fail] response", () async {
      Result? result = FAIL("failureMessage", 502);
      when(() => mockDownloadSizeRepository.getOfflineSyncDataSize(any()))
          .thenAnswer((_) {
        return Future.value(result);
      });
      var response = await downloadSizeUseCase.getOfflineSyncDataSize({});
      expect(response!.failureMessage!.isNotEmpty, true);
    });

    test("DownloadSyncSize [Empty] response", () async {
      Result? resultFail = SUCCESS(null, Headers(), 200);
      when(() => mockDownloadSizeRepository.getOfflineSyncDataSize(any()))
          .thenAnswer((_) {
        return Future.value(resultFail);
      });
      var result = await downloadSizeUseCase.getOfflineSyncDataSize({});
      expect(result!.data==null, true);
    });

    test("getProjectSyncSize [Success] response", () async {
      expectedSyncVo1 = [SyncSizeVo.downloadSizeVoJson(expectedData[0])];
      when(() => mockDownloadSizeRepository.getProjectSyncSize(any()))
          .thenAnswer((_) {
        return Future.value(expectedSyncVo1);
      });
      var response = await downloadSizeUseCase.getProjectSyncSize({});
      expect(response.length>0, true);
    });

    test("getProjectSyncSize [Empty] response", () async {
      expectedSyncVo1 = [];
      when(() => mockDownloadSizeRepository.getProjectSyncSize(any()))
          .thenAnswer((_) {
        return Future.value(expectedSyncVo1);
      });
      var response = await downloadSizeUseCase.getProjectSyncSize({});
      expect(response.length==0, true);
    });

    test("requestLocationSyncSize [Success] response", () async {
      expectedSyncVo1 = [SyncSizeVo.downloadSizeVoJson(expectedData[2])];
      when(() => mockDownloadSizeRepository.requestLocationSyncSize(any()))
          .thenAnswer((_) {
        return Future.value(expectedSyncVo1);
      });
      var response = await downloadSizeUseCase.requestedLocationSyncSize({});
      expect(response.length>0, true);
    });

    test("requestLocationSyncSize [Empty] response", () async {
      expectedSyncVo1 = [];
      when(() => mockDownloadSizeRepository.requestLocationSyncSize(any()))
          .thenAnswer((_) {
        return Future.value(expectedSyncVo1);
      });
      var response = await downloadSizeUseCase.requestedLocationSyncSize({});
      expect(response.length==0, true);
    });

  });
}
