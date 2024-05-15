import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/model_list/model_list_cubit.dart'as modelListCubit;
import 'package:field/bloc/storage_details/storage_details_cubit.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/data/model/model_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/model_list_use_case/model_list_use_case.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/internet_cubit.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:field/widgets/model_dialogs/model_data_removal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:storage_space/storage_space.dart';

import '../../fixtures/appconfig_test_data.dart';
import '../../utils/load_url.dart';
import '../mock_method_channel.dart';

class MockModelListUseCase extends Mock implements ModelListUseCase {}
class MockModelListCubit extends Mock implements modelListCubit.ModelListCubit {}

class MockProjectListUseCase extends Mock implements ProjectListUseCase {}

class DBServiceMock extends Mock implements DBService {}

class MockInternetCubit extends Mock implements InternetCubit {}

class MockModel extends Mock implements Model {}

class MockStorageSpace extends Mock implements StorageSpace {}



main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late StorageDetailsCubit storageCubit;
  MockModelListUseCase mockModelListUseCase = MockModelListUseCase();
  MockModelListCubit mockModelListCubit = MockModelListCubit();
  MockMethodChannel().setNotificationMethodChannel();
  final mockInternetCubit = MockInternetCubit();

  MockMethodChannelUrl().setupBuildFlavorMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setAsitePluginsMethodChannel();
  MockMethodChannel().setGetFreeSpaceMethodChannel();
  late List<BimModel> bimModel;
  DBServiceMock? mockDb;

  late List<FloorDetail> floorList;
  late List<CalibrationDetails> calibList;
  late Model mockModel;

  setUp(() async {
    storageCubit = StorageDetailsCubit();
    mockModel = Model(
      modelId: '123123',
      bimModelId: '123132',
      projectId: '12313231',
      projectName: 'Sample Project',
      fileSize: '10 MB',
      downloadProgress: '50%',
      bimModelName: 'Sample BIM Model',
      modelDescription: 'This is a sample model.',
      userModelName: 'Sample User',
      workPackageId: 123,
      modelCreatorUserId: 'sampleCreatorUserId',
      modelStatus: true,
      modelCreationDate: '2023-08-11',
      lastUpdateDate: '2023-08-12',
      mergeLevel: 1,
      isFavoriteModel: 1,
      dc: 'sampleDC',
      modelViewId: 456,
      revisionId: 'sampleRevisionId',
      folderId: 'sampleFolderId',
      revisionNumber: 2,
      worksetId: 'sampleWorksetId',
      docId: 'sampleDocId',
      publisher: 'Sample Publisher',
      lastUpdatedUserId: 'sampleLastUpdatedUserId',
      lastUpdatedBy: 'Sample Last Updated By',
      lastAccessUserId: 'sampleLastAccessUserId',
      lastAccessBy: 'Sample Last Access By',
      lastAccessModelDate: '2023-08-13',
      modelTypeId: 789,
      generateUri: true,
      setAsOffline: true,
      isDropOpen: false,
      isDownload: true,
    );
    floorList = [
      FloorDetail(
        fileName: 'sample.ifc',
        fileSize: 1024,
        floorNumber: 1,
        levelName: 'Ground Floor',
        isChecked: true,
        isDownloaded: true,
        isDeleteExpanded: false,
        revisionId: 1,
        bimModelId: '123',
        revName: 'Revision 1',
        projectId: 'project_123',
      ),
      FloorDetail(
        fileName: 'samplesss.ifc',
        fileSize: 1024,
        floorNumber: 2,
        levelName: 'Ground Floor',
        isChecked: true,
        isDownloaded: true,
        isDeleteExpanded: false,
        revisionId: 2,
        bimModelId: '123',
        revName: 'Revision 2',
        projectId: 'project_12312',
      ),
    ];
    bimModel = [
      BimModel(
        bimModelIdField: '123',
        name: 'Sample Model',
        fileName: 'sample.ifc',
        ifcName: 'Sample_IFC',
        revId: '1.0',
        isMerged: true,
        disciplineId: 1,
        isLink: false,
        filesize: 1024,
        folderId: 'folder_123',
        fileLocation: '/path/to/sample.ifc',
        isLastUploaded: true,
        bimIssueNumber: 2,
        hsfChecksum: 'abcd1234',
        isChecked: false,
        floorList: floorList,
        bimIssueNumberModel: 3,
        isDocAssociated: true,
        docTitle: 'Sample Document',
        publisherName: 'John Doe',
        orgName: 'Sample Organization',
        isDownloaded: true,
      ),
      BimModel(
        bimModelIdField: '123',
        name: 'Sample Model',
        fileName: 'sample.ifc',
        ifcName: 'Sample_IFC',
        revId: '1.0',
        isMerged: true,
        disciplineId: 1,
        isLink: false,
        filesize: 1024,
        folderId: 'folder_123',
        fileLocation: '/path/to/sample.ifc',
        isLastUploaded: true,
        bimIssueNumber: 2,
        hsfChecksum: 'abcd1234',
        isChecked: false,
        floorList: floorList,
        bimIssueNumberModel: 3,
        isDocAssociated: true,
        docTitle: 'Sample Document',
        publisherName: 'John Doe',
        orgName: 'Sample Organization',
        isDownloaded: true,
      )
    ];
    calibList = [
      CalibrationDetails(
        modelId: "model123",
        revisionId: "revision456",
        calibrationId: "calibration789",
        sizeOf2DFile: 1024 * 1024,
        createdByUserid: "user123",
        calibratedBy: "calibrator456",
        createdDate: "2023-08-23",
        modifiedDate: "2023-08-24",
        point3D1: "3DPointA",
        point3D2: "3DPointB",
        point2D1: "2DPointA",
        point2D2: "2DPointB",
        depth: 10.5,
        fileName: "file123.txt",
        fileType: "txt",
        isChecked: true,
        documentId: "doc456",
        docRef: "ref789",
        folderPath: "/documents/files/",
        calibrationImageId: 123,
        pageWidth: 800,
        pageHeight: 600,
        pageRotation: 90,
        folderId: "folder789",
        calibrationName: "Calibration 1",
        generateUri: false,
        isDownloaded: true,
        projectId: "project456",
      ),
      CalibrationDetails(
        modelId: "model234",
        revisionId: "revision567",
        calibrationId: "calibration987",
        sizeOf2DFile: 1024 * 1024,
        createdByUserid: "user234",
        calibratedBy: "calibrator567",
        createdDate: "2023-08-22",
        modifiedDate: "2023-08-25",
        point3D1: "3DPointX",
        point3D2: "3DPointY",
        point2D1: "2DPointX",
        point2D2: "2DPointY",
        depth: 8.2,
        fileName: "data456.csv",
        fileType: "csv",
        isChecked: false,
        documentId: "doc567",
        docRef: "ref123",
        folderPath: "/documents/data/",
        calibrationImageId: 456,
        pageWidth: 1200,
        pageHeight: 900,
        pageRotation: 180,
        folderId: "folder567",
        calibrationName: "Calibration 2",
        generateUri: true,
        isDownloaded: false,
        projectId: "project789",
      ),
    ];

    storageCubit.storageSpace = await getStorageSpace(
      lowOnSpaceThreshold: 123454566788567, // 2GB
      fractionDigits: 1,
    );
  });

  configureCubitDependencies() {
    mockDb = DBServiceMock();
    init(test: true);
    getIt.unregister<ModelListUseCase>();
    getIt.unregister<modelListCubit.ModelListCubit>();
    getIt.registerFactory<ModelListUseCase>(() => mockModelListUseCase);
    getIt.registerFactory<modelListCubit.ModelListCubit>(() => mockModelListCubit);
    getIt.unregister<InternetCubit>();
    getIt.registerFactory<InternetCubit>(() => mockInternetCubit);
    AppConfigTestData().setupAppConfigTestData();
    AConstants.loadProperty();
  }

  group("Storage details list", () {
    configureCubitDependencies();

    test("Initial state", () {
      isA<PaginationListInitial>();
    });

    test("initStorageSpace method test", () async {
      when(() => mockModelListUseCase.fetchAllFloors(any())).thenAnswer((invocation) => Future.value(floorList));
      when(() => mockModelListUseCase.fetchAllCalibrates(any())).thenAnswer((invocation) => Future.value(calibList));

      await storageCubit.initStorageSpace();
      expect(storageCubit.isDataLoading, isTrue);
      expect(storageCubit.selectedModel, null);
      expect(storageCubit.data, []);
      expect(storageCubit.totalSpace, 0.0);
      expect(storageCubit.maxDataValue, 0.0);
      expect(storageCubit.modelsFileSize, "0.0");
      expect(storageCubit.calibFileSize, "0.0");
      expect(storageCubit.storageSpace, isNot(Null));
    });

    test("getCurrentDate method test", () async {
      var currentDate = storageCubit.getCurrentDate();
      var date = DateTime.now();
      final DateFormat formatter = DateFormat('dd MMMM yyyy');
      var testDate = formatter.format(date).toString();

      expect(currentDate, testDate);
    });

    test("initData method test", () async {
      storageCubit.initData(storageCubit.storageSpace);
      expect(storageCubit.totalSpace, greaterThanOrEqualTo(3000));
      expect(storageCubit.data.length, 3);
    });

    test("getStackedBarSeries method test", () async {
      var bars = storageCubit.getStackedBarSeries();
      expect(bars.length, 3);
    });

    blocTest<StorageDetailsCubit, StorageDetailsState>("showStorageDetails state",
        build: () {
          return storageCubit;
        },
        act: (cubit) async {
          cubit.showStorageDetails(true);
        },
        expect: () => [isA<ShowHideDetailsState>()]);

    blocTest<StorageDetailsCubit, StorageDetailsState>("loadingStorage state",
        build: () {
          return storageCubit;
        },
        act: (cubit) async {
          cubit.loadingStorage(true);
        },
        expect: () => [isA<ShowHideDetailsState>()]);

    blocTest<StorageDetailsCubit, StorageDetailsState>("refreshState state",
        build: () {
          return storageCubit;
        },
        act: (cubit) async {
          cubit.refreshState();
        },
        expect: () => [isA<RefreshState>(), isA<ModelSelectedState>()]);

    blocTest<StorageDetailsCubit, StorageDetailsState>("emitSizeUpdateState state",
        build: () {
          return storageCubit;
        },
        act: (cubit) async {
          cubit.emitSizeUpdateState();
        },
        expect: () => [isA<SizeUpdateState>()]);

    blocTest<StorageDetailsCubit, StorageDetailsState>("emitSizeUpdateState state",
        build: () {
          return storageCubit;
        },
        act: (cubit) async {
          cubit.emitSizeUpdateState();
        },
        expect: () => [isA<SizeUpdateState>()]);

    blocTest<StorageDetailsCubit, StorageDetailsState>("emitPaginationListInitial state",
        build: () {
          return storageCubit;
        },
        act: (cubit) async {
          cubit.emitPaginationListInitial();
        },
        expect: () => [isA<PaginationListInitial>()]);

    test("getProjectModelsSize method test isModelSelected true", () async {
      when(() => mockModelListUseCase.fetchFloorsByModelId(any())).thenAnswer((invocation) => Future.value(floorList));
      var size = await storageCubit.getProjectModelsSize(true, "123");
      expect(size, equals("2048.00 MB"));
    });

    test("getProjectModelsSize method test isModelSelected false", () async {
      when(() => mockModelListUseCase.fetchAllFloors(any())).thenAnswer((invocation) => Future.value(floorList));
      var size = await storageCubit.getProjectModelsSize(false, "123");
      expect(size, equals("2048.00 MB"));
    });

    test("getProjectCalibrationSize method test isModelSelected true", () async {
      when(() => mockModelListUseCase.fetchCalibrateByModel(any())).thenAnswer((invocation) => Future.value(calibList));
      var size = await storageCubit.getProjectCalibrationSize(true, "123");
      expect(size, equals("2048.00 MB"));
    });

    test("getProjectCalibrationSize method test isModelSelected false", () async {
      when(() => mockModelListUseCase.fetchAllCalibrates(any())).thenAnswer((invocation) => Future.value(calibList));
      var size = await storageCubit.getProjectCalibrationSize(false, "123");
      expect(size, equals("2048.00 MB"));
    });

    testWidgets('shows dialog and clears data', (WidgetTester tester) async {
      storageCubit.calibList=calibList;
      storageCubit.floorListSelected=floorList;
      storageCubit.selectedModel=mockModel;
      when(() => mockModelListCubit.removeFloorsFromLocal(any(),any(),any())).thenAnswer((invocation) => Future.value());
      when(() => mockModelListCubit.removeCalibrateFromLocal(any(),any(),any())).thenAnswer((invocation) => Future.value());
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<StorageDetailsCubit>(
              create: (BuildContext context) => getIt<StorageDetailsCubit>(),
            ),
           
          ],
          child:  MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: Scaffold(
              body:Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      storageCubit.onClearButton(context,storageCubit,Project());
                    },
                    child: Text('Clear Button'),
                  );
                }
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Clear Button'));
      await tester.pumpAndSettle();
      var widget = find.byKey(Key("ModelDataRemovalDialog_widget"));
      expect(widget, findsOneWidget);
      await tester.tap(find.byKey(Key("key_model_data_removal_dialog_test_expanded")));
      await tester.pumpAndSettle();
    });

    testWidgets('onClickToManage with calib', (WidgetTester tester) async {
      storageCubit.calibList=calibList;
      storageCubit.floorListSelected=floorList;
      storageCubit.selectedModel=mockModel;
      when(() => mockModelListCubit.removeFloorsFromLocal(any(),any(),any())).thenAnswer((invocation) => Future.value());
      when(() => mockModelListCubit.removeCalibrateFromLocal(any(),any(),any())).thenAnswer((invocation) => Future.value());
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
      when(() => mockModelListCubit.isFavorite).thenReturn(true);
      when(() => mockModelListCubit.searchString).thenReturn("");
      when(() => mockModelListCubit.pageFetch(any(),any(),any(),any(),any(),any(),any(),any(),any())).thenAnswer((invocation) => Future.value([]));
      when(() => mockModelListUseCase.fetchAllFloors(any())).thenAnswer((invocation) => Future.value(floorList));
      when(() => mockModelListUseCase.fetchAllCalibrates(any())).thenAnswer((invocation) => Future.value(calibList));

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<StorageDetailsCubit>(
              create: (BuildContext context) => getIt<StorageDetailsCubit>(),
            ),

          ],
          child:  MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: Scaffold(
              body:Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      storageCubit.onClickToManage(context,fileType: "calibrate",isTest: true);
                    },
                    child: Text('Clear Button'),
                  );
                }
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Clear Button'));
      await tester.pumpAndSettle();
      var widget = find.byKey(Key("ModelDataRemovalDialog_widget"));

      await tester.tap(find.byKey(Key("key_model_data_removal_dialog_test_expanded")));
      await tester.pumpAndSettle();
    });

    testWidgets('onClickToManage with with floors', (WidgetTester tester) async {
      storageCubit.calibList=calibList;
      storageCubit.floorListSelected=floorList;
      storageCubit.selectedModel=mockModel;
      when(() => mockModelListCubit.removeFloorsFromLocal(any(),any(),any())).thenAnswer((invocation) => Future.value());
      when(() => mockModelListCubit.removeCalibrateFromLocal(any(),any(),any())).thenAnswer((invocation) => Future.value());
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
      when(() => mockModelListCubit.isFavorite).thenReturn(true);
      when(() => mockModelListCubit.searchString).thenReturn("");
      when(() => mockModelListCubit.pageFetch(any(),any(),any(),any(),any(),any(),any(),any(),any())).thenAnswer((invocation) => Future.value([]));
      when(() => mockModelListUseCase.fetchAllFloors(any())).thenAnswer((invocation) => Future.value(floorList));
      when(() => mockModelListUseCase.fetchAllCalibrates(any())).thenAnswer((invocation) => Future.value(calibList));

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<StorageDetailsCubit>(
              create: (BuildContext context) => getIt<StorageDetailsCubit>(),
            ),

          ],
          child:  MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: Scaffold(
              body:Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      storageCubit.onClickToManage(context,fileType: "model",isTest: true);
                    },
                    child: Text('Clear Button'),
                  );
                }
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Clear Button'));
      await tester.pumpAndSettle();
      var widget = find.byKey(Key("ModelDataRemovalDialog_widget"));
      await tester.tap(find.byKey(Key("key_model_data_removal_dialog_test_expanded")));
      await tester.pumpAndSettle();
    });

    test('Constructor should create an instance with the correct values', () {
      final chartData = ChartData('Sample', 5, 10, 15);

      expect(chartData.x, 'Sample');
      expect(chartData.models, 5);
      expect(chartData.calibrations, 10);
      expect(chartData.free, 15);
    });

  });
}
