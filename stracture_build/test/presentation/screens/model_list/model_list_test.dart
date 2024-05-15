import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/bloc/model_list/model_list_item_cubit.dart' as model_list_item;
import 'package:field/bloc/model_list/model_list_item_cubit.dart';
import 'package:field/bloc/model_list/model_list_item_state.dart';
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart' as side_tool_bar;
import 'package:field/bloc/storage_details/storage_details_cubit.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/bim_request_data.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/data/model/model_vo.dart';
import 'package:field/data/model/online_model_viewer_request_model.dart';
import 'package:field/domain/use_cases/bim_model_list_use_cases/bim_project_model_use_case.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/bottom_navigation/models/models_list_screen.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../domain/use_cases/site/create_form_use_case_test.dart';
import '../../../fixtures/fixture_reader.dart';

class MockModelListCubit extends MockCubit<ModelListState> implements ModelListCubit {}

class MockModelListItemCubit extends MockCubit<ModelListItemState> implements model_list_item.ModelListItemCubit {}

class MockSideToolBarCubit extends MockCubit<FlowState> implements side_tool_bar.SideToolBarCubit {}

class MockStorageDetailsCubit extends MockCubit<StorageDetailsState> implements StorageDetailsCubit {}
class MockBimProjectModelListUseCase extends Mock implements BimProjectModelListUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockModelListCubit mockModelListCubit = MockModelListCubit();
  MockBimProjectModelListUseCase modelListUseCase = MockBimProjectModelListUseCase();
  MockSideToolBarCubit mockSideToolBarCubit = MockSideToolBarCubit();
  MockStorageDetailsCubit mockStorageDetailsCubit = MockStorageDetailsCubit();
  MockModelListItemCubit mockModelListItemCubit = MockModelListItemCubit();
  List<Model> allItems = [];


  configureLoginCubitDependencies() {
    init(test: true);
    getIt.unregister<ModelListCubit>();
    getIt.unregister<StorageDetailsCubit>();
    getIt.unregister<BimProjectModelListUseCase>();
    getIt.unregister<side_tool_bar.SideToolBarCubit>();
    getIt.registerLazySingleton<ModelListCubit>(() => mockModelListCubit);
    getIt.registerLazySingleton<BimProjectModelListUseCase>(() => modelListUseCase);
    getIt.registerLazySingleton<model_list_item.ModelListItemCubit>(() => mockModelListItemCubit);
    getIt.registerLazySingleton<side_tool_bar.SideToolBarCubit>(() => mockSideToolBarCubit);
    getIt.registerLazySingleton<StorageDetailsCubit>(() => mockStorageDetailsCubit);
  }

  setUp(() async {
    when(() => mockModelListCubit.isFavorite).thenReturn(false);
    when(() => mockModelListCubit.progress).thenReturn(0);
    when(() => mockModelListCubit.allItems).thenReturn([]);
    when(() => mockModelListCubit.totalProgress).thenReturn(-1);
    when(() => mockStorageDetailsCubit.getCurrentDate()).thenReturn("23-12-1995");
    when(() => mockStorageDetailsCubit.state).thenReturn(ShowHideDetailsState(false));
    when(() => mockStorageDetailsCubit.modelsFileSize).thenReturn("0");
    when(() => mockStorageDetailsCubit.calibFileSize).thenReturn("0");
    when(() => mockStorageDetailsCubit.isDataLoading).thenReturn(true);
    when(() => mockSideToolBarCubit.isWhite).thenReturn(false);
    when(() => mockStorageDetailsCubit.maxDataValue).thenReturn(0.0);
    when(() => mockStorageDetailsCubit.data).thenReturn([]);
    when(() => mockModelListCubit.allItems).thenReturn([]);
    when(() => mockStorageDetailsCubit.initStorageSpace()).thenAnswer((invocation) => Future.value());
    when(() => mockModelListCubit.getProjectName(any(), any())).thenAnswer((invocation) => Future.value("projectName"));
    when(() => mockSideToolBarCubit.isRulerMenuActive).thenReturn(false);
    when(() => mockSideToolBarCubit.isCuttingPlaneMenuActive).thenReturn(false);
    when(() => mockSideToolBarCubit.isMarkerMenuActive).thenReturn(false);
    final popUpData = json.decode(fixture('model_list.json'));
    for (var item in popUpData) {
      allItems.add(Model.fromJson(item));
    }
  });
  final FocusNode focusNode = FocusNode();
  Model mockModel = Model(
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
  List<FloorDetail> floorList = [
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
  List<BimModel> bimModel = [
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
  List<CalibrationDetails> calibList = [
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

  group('Model List Test', () {
    Map<String, BimModel> selectedFloorList = {};
    configureLoginCubitDependencies();
    Widget makeTestableWidget(bool isShowSideToolBar) {
      return MultiBlocProvider(
        providers: [
          BlocProvider<ModelListCubit>(
            create: (BuildContext context) => mockModelListCubit,
          ),
          BlocProvider<StorageDetailsCubit>(
            create: (BuildContext context) => mockStorageDetailsCubit,
          ),
          BlocProvider<side_tool_bar.SideToolBarCubit>(
            create: (BuildContext context) => mockSideToolBarCubit,
          ),
          BlocProvider<model_list_item.ModelListItemCubit>(
            create: (BuildContext context) => mockModelListItemCubit,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: ModelsListPage(
            isFavourites: false,
            isShowSideToolBar: isShowSideToolBar,
            isFromHome: false,
          ),
        ),
      );
    }

    testWidgets('key_tab_view_sized_box Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      await tester.pumpWidget(makeTestableWidget(false));
      expect(find.byType(OrientationBuilder), findsOneWidget);
      expect(find.byKey(Key('key_tab_view_sized_box')), findsOneWidget);
    });

    testWidgets('key_icon_star Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.isFavorite).thenReturn(true);
      await tester.pumpWidget(
        makeTestableWidget(false),
      );
      expect(find.byKey(Key('key_icon_star')), findsOneWidget);
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.isFavorite).thenReturn(false);
      await tester.pumpWidget(
        makeTestableWidget(false),
      );
      expect(find.byKey(Key('key_icon_star_border')), findsOneWidget);
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockSideToolBarCubit.state).thenReturn(side_tool_bar.LoadingState());
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byType(Visibility), findsNWidgets(5));
      expect(find.byKey(Key('key_visibility_side_tool_bar')), findsOneWidget);
      expect(find.byKey(Key('key_expanded_view')), findsOneWidget);
      expect(find.byKey(Key('key_visibility_listview_builder')), findsOneWidget);
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(LoadingModelState());
      when(() => mockModelListCubit.isShowDetails).thenReturn(false);
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byType(Visibility), findsNWidgets(5));
      expect(find.byKey(Key('key_visibility_listview_builder')), findsOneWidget);
      expect(find.byKey(Key('key_container_listview_landscape')), findsOneWidget);
      expect(find.byKey(Key('key_landscape_container_listview')), findsOneWidget);
      expect(find.byKey(Key('key_search_model_list')), findsOneWidget);
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(LoadingModelState());
      when(() => mockModelListCubit.isShowDetails).thenReturn(true);
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byType(Visibility), findsNWidgets(5));
      expect(find.byKey(Key('key_visibility_listview_builder')), findsOneWidget);
      expect(find.byKey(Key('key_container_listview_landscape')), findsOneWidget);
      expect(find.byKey(Key('key_landscape_container_listview')), findsOneWidget);
      expect(find.byKey(Key('key_search_model_list')), findsOneWidget);
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(ShowProgressBar(false));
      when(() => mockModelListCubit.isShowDetails).thenReturn(false);
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byType(Visibility), findsNWidgets(2));
      expect(find.byKey(Key('key_container_listview_landscape')), findsNothing);
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: [], isShowCloseButton: false));
      when(() => mockModelListCubit.isShowDetails).thenReturn(false);
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_refresh_indicator')), findsOneWidget);
      expect(find.byKey(Key('key_ignore_pointer')), findsNothing);
    });

    testWidgets(' key_acircular_progress Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(ProjectLoadingState());
      when(() => mockModelListCubit.isAnyItemChecked).thenReturn(true);
      when(() => mockModelListCubit.isProjectLoading).thenReturn(true);
      when(() => mockSideToolBarCubit.state).thenReturn(FlowState());
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_ignore_pointer')), findsNothing);
    });

    testWidgets('floors Test', (WidgetTester tester) async {
      Map<String, BimModel> selectedFloorList = {};
      List<FloorDetail> selectedFloors = [];
      FloorDetail floorDetail = FloorDetail(fileName: "fileName", revisionId: 23, bimModelId: "bimModelId", fileSize: "fileSize", floorNumber: "floorNumber", levelName: "levelName", projectId: "projectId", revName: '');
      selectedFloors.add(floorDetail);
      selectedFloorList.values.forEach((bimModel) {
        selectedFloors.addAll(bimModel.floorList.where((floorData) => floorData.isChecked && !floorData.isDownloaded));
      });
      List<CalibrationDetails> selectedCalibrate = [];
      CalibrationDetails calibrationDetails = CalibrationDetails(modelId: "modelId", revisionId: "revisionId", calibrationId: "calibrationId", sizeOf2DFile: 45, createdByUserid: "createdByUserid", calibratedBy: "calibratedBy", createdDate: "createdDate", modifiedDate: "modifiedDate", point3D1: "point3D1", point3D2: "point3D2", point2D1: "point2D1", point2D2: "point2D2", depth: 3, fileName: "fileName", fileType: "fileType", isChecked: false, documentId: "documentId", docRef: "docRef", folderPath: "folderPath", calibrationImageId: "calibrationImageId", pageWidth: "pageWidth", pageHeight: "pageHeight", pageRotation: "pageRotation", folderId: "folderId", calibrationName: "calibrationName", generateUri: false, isDownloaded: false, projectId: "projectId");
      selectedCalibrate.add(calibrationDetails);
      List<FloorDetail> removeList = [];
      List<CalibrationDetails> caliRemoveList = [];
      when(() => mockModelListCubit.state).thenReturn(ItemCheckedState(items: []));
      when(() => mockModelListCubit.isShowDetails).thenReturn(false);
      when(() => mockModelListCubit.selectedFloorList).thenReturn(selectedFloorList);
      when(() => mockModelListCubit.selectedCalibrate).thenReturn(selectedCalibrate);
      when(() => mockModelListCubit.removeList).thenReturn(removeList);
      when(() => mockModelListCubit.caliRemoveList).thenReturn(caliRemoveList);
      when(() => mockModelListCubit.isItemForUpdate).thenReturn(false);
      when(() => mockModelListCubit.isAnyItemChecked).thenReturn(true);
      when(() => mockSideToolBarCubit.state).thenReturn(FlowState());

      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_cancel_button_container')), findsOneWidget);
      expect(find.byKey(Key('key_sized_box_cancel')), findsOneWidget);
      expect(find.byKey(Key('key_cancel_text_widget')), findsOneWidget);
      expect(find.byKey(Key('key_sized_box_download')), findsOneWidget);
    });

    testWidgets('Should format size in bytes correctly', (WidgetTester tester) async {
      double sizeInBytes = 123.45;
      String result = formatPdfFileSize(sizeInBytes);
      expect(result, equals("123.45 B"));
    });

    testWidgets('Should format size in kilobytes correctly', (WidgetTester tester) async {
      double sizeInBytes = 1024.0;
      String result = formatPdfFileSize(sizeInBytes);
      expect(result, equals("1.00 KB"));
    });

    testWidgets('Should format size in megabytes correctly', (WidgetTester tester) async {
      double sizeInBytes = 2 * 1024 * 1024.0;
      String result = formatPdfFileSize(sizeInBytes);
      expect(result, equals("2.00 MB"));
    });

    testWidgets('Should handle edge case: zero bytes', (WidgetTester tester) async {
      double sizeInBytes = 0;
      String result = formatPdfFileSize(sizeInBytes);
      expect(result, equals("0.00 B"));
    });

    testWidgets('Should handle edge case: very large size', (WidgetTester tester) async {
      double sizeInBytes = 1024 * 1024 * 1024;
      String result = formatPdfFileSize(sizeInBytes);
      expect(result, equals("1024.00 MB"));
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockModelListItemCubit.isExpanded).thenReturn(true);
      when(() => mockModelListItemCubit.isModelSelected).thenReturn(false);
      when(() => mockModelListCubit.state).thenReturn(DownloadModelState(items: [], isItemForUpdate: false, downloadStart: false));

      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_download_state_sized_box_model_list_tile')), findsNothing);
      expect(find.byKey(Key('key_downloaded_value_text_widget')), findsNothing);
      expect(find.byKey(Key('key_model_state_row')), findsNothing);
    });

    testWidgets('Test', (WidgetTester tester) async {
      Map<String, BimModel> selectedFloorList = {};
      List<FloorDetail> selectedFloors = [];
      List<CalibrationDetails> selectedCalibrate = [];
      List<FloorDetail> removeList = [];
      List<CalibrationDetails> caliRemoveList = [];
      when(() => mockModelListCubit.state).thenReturn(ItemCheckedState(items: []));
      when(() => mockModelListCubit.isShowDetails).thenReturn(false);
      when(() => mockModelListCubit.selectedFloorList).thenReturn(selectedFloorList);
      when(() => mockModelListCubit.selectedCalibrate).thenReturn(selectedCalibrate);
      when(() => mockModelListCubit.removeList).thenReturn(removeList);
      when(() => mockModelListCubit.caliRemoveList).thenReturn(caliRemoveList);
      when(() => mockModelListCubit.isItemForUpdate).thenReturn(false);
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_cancel_button_container')), findsNothing);
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(DownloadModelState(items: [], isItemForUpdate: true));
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_sized_box_shrink')), findsOneWidget);
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(DropdownOpenState(items: [], isUpdate: false, isOpen: false));
      when(() => mockModelListCubit.isOpened).thenReturn(true);
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_container_dropdown')), findsOneWidget);
      expect(find.byKey(Key('key_container_sized_box_dropdown')), findsOneWidget);
      expect(find.byKey(Key('key_container_sized_box_download_update_dropdown')), findsOneWidget);
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockModelListCubit.isOpened).thenReturn(true);
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_open')), findsOneWidget);
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockModelListCubit.isOpened).thenReturn(true);
      when(() => mockStorageDetailsCubit.showDetails).thenReturn(false);

      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_model_storage_landscape_widget')), findsOneWidget);
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));

      await tester.pumpWidget(
        makeTestableWidget(true),
      );
     // expect(find.byKey(Key('key_model_list_tile_tablet')), findsNWidgets(6));
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockModelListItemCubit.isExpanded).thenReturn(true);
      when(() => mockModelListItemCubit.isModelSelected).thenReturn(false);
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
    //  expect(find.byKey(Key('key_ignore_pointer_model_list_state')), findsNWidgets(6));
    // expect(find.byKey(Key('key_model_list_tile_container')), findsNWidgets(6));
    // expect(find.byKey(Key('key_size_transition_animation')), findsNWidgets(6));
    // expect(find.byKey(Key('key_models_tab')), findsNWidgets(6));
    // expect(find.byKey(Key('key_calibration_tab')), findsNWidgets(6));
      expect(find.byKey(Key('key_model_widget_key')), findsNothing);
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockModelListItemCubit.isExpanded).thenReturn(true);
      when(() => mockModelListItemCubit.isModelSelected).thenReturn(true);
      when(() => mockModelListItemCubit.state).thenReturn(ModelLoadingState(ModelStatus.loaded));
      when(() => mockModelListItemCubit.mapGroupBimList).thenReturn({});
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_center_model_widget')), findsNWidgets(0));
      expect(find.byKey(Key('key_column_model_widget')), findsNWidgets(0));
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockModelListItemCubit.isExpanded).thenReturn(true);
      when(() => mockModelListItemCubit.isModelSelected).thenReturn(true);
      when(() => mockModelListCubit.state).thenReturn(DownloadModelState(items: allItems, isItemForUpdate: true, downloadStart: true));
      when(() => mockModelListCubit.selectedModelIndex).thenReturn(0);
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_linear_progress_bar_padding')), findsOneWidget);
      expect(find.byKey(Key('key_linear_progress_bar_indicator')), findsOneWidget);
//      expect(find.byKey(Key('key_linear_progress_bar_divider')), findsNWidgets(6));
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockModelListItemCubit.isExpanded).thenReturn(true);
      when(() => mockModelListItemCubit.isModelSelected).thenReturn(false);
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_inkwell_column')), findsNWidgets(0));
      expect(find.byKey(Key('key_container_model_list_tile')), findsNWidgets(0));
      expect(find.byKey(Key('key_row_model_list_tile')), findsNWidgets(0));
      expect(find.byKey(Key('key_sized_box_model_list_tile')), findsNWidgets(0));
      expect(find.byKey(Key('key_sized_box_tile_model_list_tile')), findsNWidgets(0));
      expect(find.byKey(Key('key_expanded_model_list_tile')), findsNWidgets(0));
      expect(find.byKey(Key('key_row_model_list_tile')), findsNWidgets(0));
      expect(find.byKey(Key('key_user_model_name_text_model_list_tile')), findsNWidgets(0));
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockModelListItemCubit.isExpanded).thenReturn(true);
      when(() => mockModelListItemCubit.isModelSelected).thenReturn(false);
      when(() => mockModelListCubit.state).thenReturn(DownloadModelState(items: [], isItemForUpdate: false, downloadStart: false));

      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_download_state_sized_box_model_list_tile')), findsNothing);
      expect(find.byKey(Key('key_downloaded_value_text_widget')), findsNothing);
      expect(find.byKey(Key('key_model_state_row')), findsNothing);
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockModelListItemCubit.isExpanded).thenReturn(true);
      when(() => mockModelListItemCubit.isModelSelected).thenReturn(false);
      when(() => mockModelListItemCubit.selectedFloorList).thenReturn({});
      when(() => mockModelListItemCubit.isFloorLoading).thenReturn(true);
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_sized_box_network_connected')), findsNothing);
      expect(find.byKey(Key('key_center_isFloor_loading_floor_list_empty')), findsNothing);
      expect(find.byKey(Key('key_icon_delete_single_floor')), findsNothing);
      expect(find.byKey(Key('key_text_file_size_list_tile')), findsNothing);
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockModelListItemCubit.isExpanded).thenReturn(true);
      when(() => mockModelListItemCubit.isModelSelected).thenReturn(true);
      when(() => mockModelListItemCubit.isCalibrateLoading).thenReturn(true);
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_model_widget_key')), findsNothing);
      expect(find.byKey(Key('key_center_calib')), findsNothing);
      expect(find.byKey(Key('key_refresh_button')), findsOneWidget);
      expect(find.byKey(Key('key_storage_details_container')), findsOneWidget);
      expect(find.byKey(Key('key_storage_details_calibrate')), findsOneWidget);
      expect(find.byKey(Key('key_storage_details_model')), findsOneWidget);
      expect(find.byKey(Key('key_center_clear_project_button')), findsOneWidget);
      expect(find.byKey(Key('key_text_clear_project')), findsOneWidget);
    });

    testWidgets('Test With All Model Success State', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockModelListItemCubit.isExpanded).thenReturn(true);
      when(() => mockModelListItemCubit.isModelSelected).thenReturn(false);
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      // //expect(find.byKey(Key('key_ignore_pointer_model_list_state')), findsNWidgets(6));
      // expect(find.byKey(Key('key_model_list_tile_container')), findsNWidgets(6));
      // expect(find.byKey(Key('key_size_transition_animation')), findsNWidgets(6));
      // expect(find.byKey(Key('key_models_tab')), findsNWidgets(6));
      // expect(find.byKey(Key('key_calibration_tab')), findsNWidgets(6));
       expect(find.byKey(Key('key_model_widget_key')), findsNothing);
    });

    testWidgets('Test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(DownloadModelState(items: mockModelListCubit.allItems, isItemForUpdate: false,downloadStart: true));
      when(() => mockModelListCubit.selectedModelIndex).thenReturn(0);
      expect(find.byKey(Key('key_padding')), findsNothing);
    });

    testWidgets('Test', (WidgetTester tester) async {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      expect(find.byKey(Key('key_portrait_visibility_storage_widget')), findsOneWidget);
      expect(find.byKey(Key('key_model_storage_landscape_widget')), findsOneWidget);
    });

    testWidgets('Should format size in bytes correctly', (WidgetTester tester) async {
      double sizeInBytes = 123.45;

      String result = formatPdfFileSizeInMB(sizeInBytes);

      expect(result, equals("0.12 MB"));
    });

    testWidgets('Should format size in kilobytes correctly', (WidgetTester tester) async {
      double sizeInBytes = 1024.0;

      String result = formatPdfFileSizeInMB(sizeInBytes);

      expect(result, equals("1.00 MB"));
    });

    testWidgets('Should format size in megabytes correctly', (WidgetTester tester) async {
      double sizeInBytes = 2 * 1024 * 1024.0;

      String result = formatPdfFileSizeInMB(sizeInBytes);

      expect(result, equals("2048.00 MB"));
    });

    testWidgets('Should handle edge case: zero bytes', (WidgetTester tester) async {
      double sizeInBytes = 0;

      String result = formatPdfFileSizeInMB(sizeInBytes);

      expect(result, equals("0.00 MB"));
    });

    testWidgets('Should handle edge case: very large size', (WidgetTester tester) async {
      double sizeInBytes = 1024 * 1024 * 1024;

      String result = formatPdfFileSizeInMB(sizeInBytes);

      expect(result, equals("1048576.00 MB"));
    });

    testWidgets('FileSizeOutOfStorage widget displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ModelListCubit>(
              create: (BuildContext context) => mockModelListCubit,
            ),
            BlocProvider<StorageDetailsCubit>(
              create: (BuildContext context) => mockStorageDetailsCubit,
            ),
            BlocProvider<side_tool_bar.SideToolBarCubit>(
              create: (BuildContext context) => mockSideToolBarCubit,
            ),
            BlocProvider<model_list_item.ModelListItemCubit>(
              create: (BuildContext context) => mockModelListItemCubit,
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Builder(builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return Dialog(
                          insetPadding: EdgeInsets.zero,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: FileSizeOutOfStorage(),
                        );
                      },
                    );
                  },
                  child: Text('Show Dialog'),
                ),
              );
            }),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Warning'), findsOneWidget);

      expect(find.text('Please free up some space to download files'), findsOneWidget);

      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.byType(FileSizeOutOfStorage), findsNothing);
    });

    testWidgets('Displays suggestions and handles suggestion tap', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockSideToolBarCubit.state).thenReturn(FlowState());
      await tester.pumpWidget(makeTestableWidget(true));

      // Enter some text into the search field
      await tester.enterText(find.byType(TextField), 'example');

      when(() => mockModelListCubit.getSuggestedSearchModelList(any(), any(), any(), any(), any(), any(), any(), any(), any())).thenAnswer((_) => Future.value([
            Model(userModelName: "Suggested Search 1"),
            Model(userModelName: "Suggested Search 2"),
          ]));

      // Wait for suggestions to be displayed
      await tester.pumpAndSettle();
    });

    testWidgets('fetchListOfModels method test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockSideToolBarCubit.state).thenReturn(FlowState());
      await tester.pumpWidget(makeTestableWidget(true));
      final finder = find.byType(ModelsListPage);
      final widget = tester.state<ModelsListPageState>(finder);
      widget.searchController = TextEditingController(text: "test1");
      when(() => mockModelListCubit.searchString).thenReturn(widget.searchController.text.trim());
      when(() => MockInternetCubit().isNetworkConnected).thenReturn(false);
      final fetchListOfModels = widget.fetchListOfModels();
    });

    testWidgets('modelListOnTap method test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockSideToolBarCubit.state).thenReturn(FlowState());
      await tester.pumpWidget(makeTestableWidget(true));
      final finder = find.byType(ModelsListPage);

      final widget = tester.state<ModelsListPageState>(finder);
      when(() => mockModelListCubit.lastSelectedIndex).thenReturn(-1);
      when(() => mockModelListCubit.selectedModelData).thenReturn(OnlineViewerModelRequestModel(isSelectedModel: false));

      final onOpenClicked = widget.modelListOnTap(1, "itemTile");
    });

    testWidgets('showDownloadPopup method test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockSideToolBarCubit.state).thenReturn(FlowState());
      await tester.pumpWidget(makeTestableWidget(true));
      final finder = find.byType(ModelsListPage);

      final widget = tester.state<ModelsListPageState>(finder);
      when(() => mockModelListCubit.selectedFloorList).thenReturn({
        bimModel[0].revId.toString(): bimModel[0],
        bimModel[1].revId.toString(): bimModel[1],
      });
      when(() => mockModelListCubit.selectedCalibrate).thenReturn(calibList);
      when(() => mockModelListCubit.caliRemoveList).thenReturn(calibList);
      when(() => mockModelListCubit.removeList).thenReturn(floorList);

      final onOpenClicked = widget.showDownloadPopup();
    });


    testWidgets('clearButtonOnTap method test', (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockSideToolBarCubit.state).thenReturn(FlowState());
      await tester.pumpWidget(makeTestableWidget(true));
      final finder = find.byType(ModelsListPage);

      final widget = tester.state<ModelsListPageState>(finder);
      when(() => mockModelListCubit.searchString).thenReturn("");
      when(() => mockModelListCubit.pageFetch(any(), any(), any(), any(), any(), any(), any(), any(), any())).thenAnswer((invocation) => Future.value([mockModel]));
   
      final onOpenClicked = widget.clearButtonOnTap();
    });

    testWidgets("CustomSearchSuggestionView Test", (tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockSideToolBarCubit.state).thenReturn(FlowState());
      when(() => mockModelListCubit.getSuggestedSearchModelList(any(), any(), any(), any(), any(), any(), any(), any(), any())).thenAnswer((invocation) => Future.value([allItems[0]]));
      await tester.pumpWidget(makeTestableWidget(true));
      final finder = find.byType(ModelsListPage);
      final widget = tester.state<ModelsListPageState>(finder);
      var searchContainer = find.byKey(Key("key_search_model_list"));
      await tester.tap(searchContainer);
      expect(widget.searchModelNode.hasFocus, true);
      widget.searchController.text = "site";
      await tester.pump();
    });

    testWidgets("callModelOnEmptySearch Test", (tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockSideToolBarCubit.state).thenReturn(FlowState());
      when(() => mockModelListCubit.getSuggestedSearchModelList(any(), any(), any(), any(), any(), any(), any(), any(), any())).thenAnswer((invocation) => Future.value([allItems[0]]));
      await tester.pumpWidget(makeTestableWidget(true));
      final finder = find.byType(ModelsListPage);
      final widget = tester.state<ModelsListPageState>(finder);
      widget.isFirstTimeLoading=false;
      when(() => mockModelListCubit.searchString).thenReturn("");
      when(() => mockModelListCubit.pageFetch(any(), any(), any(), any(), any(), any(), any(), any(), any())).thenAnswer((invocation) => Future.value([mockModel]));
      widget.callModelOnEmptySearch();
    });

    testWidgets("onOpenClicked() Test", (tester) async {
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockSideToolBarCubit.state).thenReturn(FlowState());
      when(() => mockModelListCubit.isLoading).thenReturn(false);
      when(() => mockModelListCubit.isLastItem).thenReturn(false);
      when(() => mockModelListCubit.isShowDetails).thenReturn(true);
      when(() => mockModelListCubit.toggleIsLoading()).thenReturn(false);
      when(() => mockModelListCubit.pageFetch(any(), any(), any(), any(), any(), any(), any(), any(), any())).thenAnswer((invocation) => Future.value([mockModel]));
      when(() => mockModelListCubit.buildBimRequestBody(any(),any(),any())).thenAnswer((invocation) => BimProjectModelRequestModel(modelId: "",projectId: "",actionId: "",fileName: "",modelName: "",modelVersionID: ""));
      when(() => modelListUseCase.getBimProjectModelList(any(),)).thenAnswer((invocation) =>Future.value([BimProjectModel(
        bIMProjectModelVO: BimProjectModelVO(
          ifcObject: IfcObject(
            name: 'Object 1',
            disciplineId: 1,
            fileLocation: '/path/to/object_1',
          ),
          userPrivilege: 'Privilege 1',
          hasViews: 'Views 1',
          hasDiscussions: 'Discussions 1',
          projectId: 'Project 1',
          modelId: 'Model 1',
          projectName: 'Project Name 1',
          modelCreationDate: '2023-09-07',
          publisherFullName: 'Publisher 1',
          modelTypeId: 1,
          lastAccessedDateTime: '2023-09-07 10:00:00',
          isFavourite: 1,
          lastUpdateDateTime: '2023-09-07 11:00:00',
          generateURI: true,
        ),
      ),
        BimProjectModel(
          bIMProjectModelVO: BimProjectModelVO(
            ifcObject: IfcObject(
              name: 'Object 2',
              disciplineId: 2,
              fileLocation: '/path/to/object_2',
            ),
            userPrivilege: 'Privilege 2',
            hasViews: 'Views 2',
            hasDiscussions: 'Discussions 2',
            projectId: 'Project 2',
            modelId: 'Model 2',
            projectName: 'Project Name 2',
            modelCreationDate: '2023-09-08',
            publisherFullName: 'Publisher 2',
            modelTypeId: 2,
            lastAccessedDateTime: '2023-09-08 10:00:00',
            isFavourite: 0,
            lastUpdateDateTime: '2023-09-08 11:00:00',
            generateURI: false,
          ),
        ),]));
      when(() => mockModelListCubit.state).thenReturn(ShowProgressBar(true));
      await tester.pumpWidget(makeTestableWidget(true));
      final finder = find.byType(ModelsListPage);
      final widget = tester.state<ModelsListPageState>(finder);

     widget.onOpenClicked();
    });

    testWidgets('ModelList mobile', (WidgetTester tester) async {
      Utility.isTablet=false;
      Utility.isPhone=true;
      when(() => mockModelListCubit.state).thenReturn(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
      when(() => mockSideToolBarCubit.state).thenReturn(FlowState());
      when(() => mockModelListItemCubit.isExpanded).thenReturn(true);
      when(() => mockModelListItemCubit.isModelSelected).thenReturn(false);
      await tester.pumpWidget(
        makeTestableWidget(true),
      );
      final finder = find.byType(ModelsListPage);
      final widget = tester.state<ModelsListPageState>(finder);
      expect(find.byKey(Key('key_model_list_mobile')), findsOneWidget);
      var searchContainer = find.byKey(Key("key_search_model_list_mobile"));
      await tester.tap(searchContainer);
      expect(widget.searchModelNode.hasFocus, true);
      widget.searchController.text = "site";
    });

  });
}
