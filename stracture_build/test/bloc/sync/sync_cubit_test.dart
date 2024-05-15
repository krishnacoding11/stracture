import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/download_size/download_size_cubit.dart';
import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/bloc/site/plan_cubit.dart';
import 'package:field/bloc/site/plan_loading_state.dart';
import 'package:field/bloc/sync/sync_cubit.dart';
import 'package:field/bloc/sync/sync_state.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/data_source/forms/form_local_data_source.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/sync/sync_manager.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data_source/filter/filter_local_data_source_test.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';
import '../../utils/load_url.dart';
import '../mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  // late SyncCubit syncCubit;
  late MockFormLocalDataSource mockFormLocalDataSource;
  late MockDatabaseManager mockDatabaseManager;
  late MockSyncManager mockSyncManager;
  late MockBuildContext mockContext;

  Project? project;
  List<SiteLocation>? siteLocationList = [];
  Map<String, dynamic> arguments = {};
  SyncCubit syncCubit = SyncCubit();
  MockDownloadSizeCubit mockDownloadSizeCubit = MockDownloadSizeCubit();


  List<AppType>? apptypeList = [];

  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<SyncCubit>();
    di.getIt.registerFactory<SyncCubit>(() => syncCubit);
    di.getIt.unregister<DownloadSizeCubit>();
    di.getIt.registerFactory<DownloadSizeCubit>(() => mockDownloadSizeCubit);

    SharedPreferences.setMockInitialValues({
      "userData":fixture("user_data.json"),
      "cloud_type_data":"1",
      "1_u1_project_":fixture("project.json")
    });
    final appTypeListData = jsonDecode(fixture("app_type_list.json"));
    for (var item in appTypeListData["data"]) {
      apptypeList.add(AppType.fromJson(item));
    }

    AppConfigTestData().setupAppConfigTestData();
    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AConstants.loadProperty();
  }

  setUp(() {
    siteLocationList = SiteLocation.jsonToList(fixture("site_location.json"));
    project = Project.fromJson(jsonDecode(fixture("project.json")));
    arguments['projectDetail'] = project;
    arguments['locationList'] = siteLocationList;
    MockMethodChannel().setAsitePluginsMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    mockFormLocalDataSource = MockFormLocalDataSource();
    mockDatabaseManager = MockDatabaseManager();
    mockSyncManager = MockSyncManager();
    syncCubit = SyncCubit();
    mockContext = MockBuildContext();
  });

  group('PlanCubit Tests -', () {
    configureCubitDependencies();

    test("Initial State", () {
      expect(syncCubit.state, SyncInitial());
    });

//FAIL
 /*   blocTest<SyncCubit, FlowState>(
      'Auto sync offline to online',
      build: () => syncCubit,
      act: (cubit) async {
        cubit.formLocalDataSource=mockFormLocalDataSource;
        when(() => mockFormLocalDataSource.isPushToServerData()).thenAnswer((_) async => true);
        await cubit.autoSyncOfflineToOnline();
      },
      expect: () => [isA<SyncStartState>(), isA<SyncCompleteState>()],
    );*/


    blocTest<SyncCubit,FlowState>("getUpdatedDownloadedProjectSize success", build: () => syncCubit, act: (cubit) async {
      when(() => mockDownloadSizeCubit.getProjectOfflineSyncDataSize("12346", ["-1"])).thenAnswer((invocation) => Future.value(859875));
      final result = await cubit.getUpdatedDownloadedProjectSize("12346");
      expect(result, 859875);
    });


    blocTest<SyncCubit,FlowState>("getUpdatedDownloadedProjectSize fail", build: () => syncCubit, act: (cubit) async {
      when(() => mockDownloadSizeCubit.getProjectOfflineSyncDataSize("12346", ["-1"])).thenAnswer((invocation) => Future.value(null));
      final result = await cubit.getUpdatedDownloadedProjectSize("12346");
      expect(result, null);
    });

    blocTest<SyncCubit,FlowState>("getRequestedLocationSyncSize success", build: () => syncCubit, act: (cubit) async {
      when(() => mockDownloadSizeCubit.getProjectOfflineSyncDataSize("12346",  ["86455"])).thenAnswer((invocation) => Future.value(859875));
      final result = await cubit.getUpdatedDownloadedLocationSize("12346",["86455"]);
      expect(result, 859875);
    });


    blocTest<SyncCubit,FlowState>("getRequestedLocationSyncSize fail", build: () => syncCubit, act: (cubit) async {
      when(() => mockDownloadSizeCubit.getProjectOfflineSyncDataSize("12346", ["86455"])).thenAnswer((invocation) => Future.value(null));
      final result = await cubit.getUpdatedDownloadedLocationSize("12346",["86455"]);
      expect(result, null);
    });

  });
}

class MockFormLocalDataSource extends Mock implements FormLocalDataSource {}

class mockDatabaseManager extends Mock implements DatabaseManager {}

class MockSyncManager extends Mock implements SyncManager {}

class MockBuildContext extends Mock implements BuildContext {}

class MockDownloadSizeCubit extends Mock implements DownloadSizeCubit{}