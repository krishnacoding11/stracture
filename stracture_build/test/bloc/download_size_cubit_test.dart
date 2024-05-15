import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/src/headers.dart';
import 'package:field/bloc/download_size/download_size_cubit.dart';
import 'package:field/bloc/download_size/download_size_state.dart';
import 'package:field/data/model/download_size_vo.dart';
import 'package:field/data/model/sync_size_vo.dart';
import 'package:field/domain/use_cases/download_size/download_size_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/sharedpreference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fixtures/fixture_reader.dart';
import 'mock_method_channel.dart';

class MockDownloadSizeUseCase extends Mock implements DownloadSizeUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockDownloadSizeUseCase mockDownloadSizeUseCase = MockDownloadSizeUseCase();
  late DownloadSizeCubit downloadSizeCubit;
  AConstants.adoddleUrl = 'https://adoddleqaak.asite.com/';
  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<DownloadSizeUseCase>();
    di.getIt.registerLazySingleton<DownloadSizeUseCase>(() => mockDownloadSizeUseCase);
  }

  setUp(() async {
    downloadSizeCubit = DownloadSizeCubit(downloadSizeUseCase: mockDownloadSizeUseCase);
    MockMethodChannel().setGetFreeSpaceMethodChannel();
    MockMethodChannel().setAsitePluginsMethodChannel();
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json")});
    SharedPreferences.setMockInitialValues({"includeAttachments": "false"});
    PreferenceUtils.init();
  });

  group("Download Size Cubit:", () {
    configureCubitDependencies();
    List<dynamic> data = json.decode(fixture("download_size_data.json"));
    List<dynamic> expectedData = json.decode(fixture("sync_size_vo.json"));
    var pExpectedSuccess;
    var pExpectedLimit;
    var lExpectedSuccess;
    List<SyncSizeVo> expectedSyncVo1;
    List<SyncSizeVo> expectedSyncVo2;
    List<SyncSizeVo> expectedSyncVo3;

    pExpectedSuccess = SUCCESS(DownloadSizeVo.getDownloadSize(data[0]), Headers(), 200);
    pExpectedLimit = SUCCESS(DownloadSizeVo.getDownloadSize(data[1]), Headers(), 200);
    lExpectedSuccess = SUCCESS(DownloadSizeVo.getDownloadSize(data[2]), Headers(), 200);

    expectedSyncVo1 = [SyncSizeVo.downloadSizeVoJson(expectedData[0])];
    expectedSyncVo2 = [SyncSizeVo.downloadSizeVoJson(expectedData[1])];
    expectedSyncVo3 = [SyncSizeVo.downloadSizeVoJson(expectedData[2])];

    var expectedError = FAIL("failureMessage", 502);
    test("Initial state", () {
      expect(downloadSizeCubit.state, isA<InitialState>());
    });

    blocTest<DownloadSizeCubit, FlowState>("emits [Project SyncDownloadSizeState] state",
        build: () {
          return downloadSizeCubit;
        },
        act: (cubit) async {
          when(() => mockDownloadSizeUseCase.getOfflineSyncDataSize(any())).thenAnswer((_) => Future.value(pExpectedSuccess));
          when(() => mockDownloadSizeUseCase.getProjectSyncSize(any())).thenAnswer((_) => Future.value(expectedSyncVo1));
          await cubit.getProjectOfflineSyncDataSize("2130192\$\$QULADT", ["-1"]);
        },
        expect: () => [isA<SyncDownloadStartState>(), isA<SyncDownloadSizeState>()]);

    blocTest<DownloadSizeCubit, FlowState>("emits [Project SyncDownloadLimitState] state",
        build: () {
          return downloadSizeCubit;
        },
        act: (cubit) async {
          when(() => mockDownloadSizeUseCase.getOfflineSyncDataSize(any())).thenAnswer((_) => Future.value(pExpectedLimit));
          when(() => mockDownloadSizeUseCase.getProjectSyncSize(any())).thenAnswer((_) => Future.value(expectedSyncVo2));

          await cubit.getProjectOfflineSyncDataSize("2116416\$\$0l22fe", ["-1"]);
        },
        expect: () => [isA<SyncDownloadStartState>(), isA<SyncDownloadLimitState>()]);

    blocTest<DownloadSizeCubit, FlowState>("emits [SyncDownloadErrorState] state",
        build: () {
          return downloadSizeCubit;
        },
        act: (cubit) async {
          when(() => mockDownloadSizeUseCase.getOfflineSyncDataSize(any())).thenAnswer((_) => Future.value(expectedError));
          await cubit.getProjectOfflineSyncDataSize("2116416\$\$0l22fe", ["-1"]);
        },
        expect: () => [isA<SyncDownloadStartState>(), isA<SyncDownloadErrorState>()]);

    blocTest<DownloadSizeCubit, FlowState>("emits [Location SyncDownloadSizeState] state",
        build: () {
          return downloadSizeCubit;
        },
        act: (cubit) async {
          when(() => mockDownloadSizeUseCase.getOfflineSyncDataSize(any())).thenAnswer((_) => Future.value(lExpectedSuccess));
          when(() => mockDownloadSizeUseCase.getProjectSyncSize(any())).thenAnswer((_) => Future.value(expectedSyncVo1));
          when(() => mockDownloadSizeUseCase.requestedLocationSyncSize(any())).thenAnswer((_) => Future.value(expectedSyncVo3));
          await cubit.getProjectOfflineSyncDataSize("2130192\$\$QULADT", ["12345", "69870"]);
        },
        expect: () => [isA<SyncDownloadStartState>(), isA<SyncDownloadSizeState>()]);

    blocTest<DownloadSizeCubit, FlowState>("emits Location SyncDownloadSizeState with more than batchSize [Success] state",
        build: () {
          return downloadSizeCubit;
        },
        act: (cubit) async {
          when(() => mockDownloadSizeUseCase.getOfflineSyncDataSize(any())).thenAnswer((_) => Future.value(lExpectedSuccess));
          when(() => mockDownloadSizeUseCase.getProjectSyncSize(any())).thenAnswer((_) => Future.value(expectedSyncVo1));
          when(() => mockDownloadSizeUseCase.requestedLocationSyncSize(any())).thenAnswer((_) => Future.value(expectedSyncVo3));
          downloadSizeCubit.batchSize = 10;

          await cubit.getProjectOfflineSyncDataSize("2130192\$\$QULADT", [
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
          ]);
        },
        expect: () => [isA<SyncDownloadStartState>(), isA<SyncDownloadSizeState>()]);

    blocTest<DownloadSizeCubit, FlowState>("emits Location SyncDownloadSizeState with less than batchSize [Success] state",
        build: () {
          return downloadSizeCubit;
        },
        act: (cubit) async {
          when(() => mockDownloadSizeUseCase.getOfflineSyncDataSize(any())).thenAnswer((_) => Future.value(lExpectedSuccess));
          when(() => mockDownloadSizeUseCase.getProjectSyncSize(any())).thenAnswer((_) => Future.value(expectedSyncVo1));
          when(() => mockDownloadSizeUseCase.requestedLocationSyncSize(any())).thenAnswer((_) => Future.value(expectedSyncVo3));
          downloadSizeCubit.batchSize = 10;

          await cubit.getProjectOfflineSyncDataSize("2130192\$\$QULADT", [
            "12345",
            "69870",
            "12345",
            "69870",
            "12345"
          ]);
        },
        expect: () => [isA<SyncDownloadStartState>(), isA<SyncDownloadSizeState>()]);

    blocTest<DownloadSizeCubit, FlowState>("emits Location SyncDownloadSizeState with equal to batchSize [Success] state",
        build: () {
          return downloadSizeCubit;
        },
        act: (cubit) async {
          when(() => mockDownloadSizeUseCase.getOfflineSyncDataSize(any())).thenAnswer((_) => Future.value(lExpectedSuccess));
          when(() => mockDownloadSizeUseCase.getProjectSyncSize(any())).thenAnswer((_) => Future.value(expectedSyncVo1));
          when(() => mockDownloadSizeUseCase.requestedLocationSyncSize(any())).thenAnswer((_) => Future.value(expectedSyncVo3));
          downloadSizeCubit.batchSize = 10;

          await cubit.getProjectOfflineSyncDataSize("2130192\$\$QULADT", [
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870"
          ]);
        },
        expect: () => [isA<SyncDownloadStartState>(), isA<SyncDownloadSizeState>()]);

    blocTest<DownloadSizeCubit, FlowState>("emits Location SyncDownloadSizeState with more than batchSize [FAIL] state",
        build: () {
          return downloadSizeCubit;
        },
        act: (cubit) async {
          when(() => mockDownloadSizeUseCase.getOfflineSyncDataSize(any())).thenAnswer((_) => Future.value(FAIL('',502)));
          downloadSizeCubit.batchSize = 10;

          await cubit.getProjectOfflineSyncDataSize("2130192\$\$QULADT", [
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
            "12345",
            "69870",
          ]);
        },
        expect: () => [isA<SyncDownloadStartState>(), isA<SyncDownloadErrorState>()]);

    blocTest<DownloadSizeCubit, FlowState>("emits SyncDownloadSizeState result data empty",
        build: () {
          return downloadSizeCubit;
        },
        act: (cubit) async {
          when(() => mockDownloadSizeUseCase.getOfflineSyncDataSize(any())).thenAnswer((_) => Future.value(SUCCESS({}, Headers(), 200)));
          when(() => mockDownloadSizeUseCase.getProjectSyncSize(any())).thenAnswer((_) => Future.value([SyncSizeVo.downloadSizeVoJson({})]));
          await cubit.getProjectOfflineSyncDataSize("2130192\$\$QULADT", ["-1"]);
        },
        expect: () => [isA<SyncDownloadStartState>(), isA<SyncDownloadSizeState>()]);

    blocTest<DownloadSizeCubit, FlowState>("emits SyncDownloadSizeState result data empty",
        build: () {
          return downloadSizeCubit;
        },
        act: (cubit) async {
          when(() => mockDownloadSizeUseCase.getOfflineSyncDataSize(any())).thenAnswer((_) => Future.value(pExpectedSuccess));
          when(() => mockDownloadSizeUseCase.getProjectSyncSize(any())).thenThrow(Exception("Error"));
          await cubit.getProjectOfflineSyncDataSize("2130192\$\$QULADT", ["-1"]);
        },
        expect: () => [isA<SyncDownloadStartState>(),isA<SyncDownloadErrorState>()]);
  });
}
