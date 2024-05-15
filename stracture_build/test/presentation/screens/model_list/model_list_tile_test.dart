import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/bim_model_list/bim_project_model_cubit.dart'as bimProCubit;
import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/bloc/model_list/model_list_item_cubit.dart';
import 'package:field/bloc/model_list/model_list_item_state.dart';
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart' as side_tool_bar;
import 'package:field/bloc/storage_details/storage_details_cubit.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/bim_request_data.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/data/model/model_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/revision_data.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/internet_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/bottom_navigation/models/model_list_tile.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';

class ModeModelListItemCubit extends MockCubit<ModelListItemState> implements ModelListItemCubit {}
class MockBimProjectCubit extends MockCubit<bimProCubit.BimProjectModelListState> implements bimProCubit.BimProjectModelListCubit {}
class MockInternetCubit extends Mock implements InternetCubit {}
class MockModel extends Mock implements Model {}

class MockModelListCubit extends MockCubit<ModelListState> implements ModelListCubit {}

class MockSideToolBarCubit extends MockCubit<FlowState> implements side_tool_bar.SideToolBarCubit {}

class MockStorageDetailsCubit extends MockCubit<StorageDetailsState> implements StorageDetailsCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockModelListCubit mockModelListCubit = MockModelListCubit();
  MockInternetCubit mockInternetCubit = MockInternetCubit();
  MockBimProjectCubit mockBimProjectCubit = MockBimProjectCubit();
  MockSideToolBarCubit mockSideToolBarCubit = MockSideToolBarCubit();
  MockStorageDetailsCubit mockStorageDetailsCubit = MockStorageDetailsCubit();
  ModeModelListItemCubit mockModelListItemCubit = ModeModelListItemCubit();

  configureLoginCubitDependencies() {
    init(test: true);
    getIt.unregister<ModelListCubit>();
    getIt.unregister<InternetCubit>();
    getIt.unregister<bimProCubit.BimProjectModelListCubit>();
    getIt.unregister<StorageDetailsCubit>();
    getIt.unregister<side_tool_bar.SideToolBarCubit>();
    getIt.registerLazySingleton<ModelListCubit>(() => mockModelListCubit);
    getIt.registerLazySingleton<InternetCubit>(() => mockInternetCubit);
    getIt.registerLazySingleton<bimProCubit.BimProjectModelListCubit>(() => mockBimProjectCubit);
    getIt.registerLazySingleton<ModeModelListItemCubit>(() => mockModelListItemCubit);
    getIt.registerLazySingleton<side_tool_bar.SideToolBarCubit>(() => mockSideToolBarCubit);
    getIt.registerLazySingleton<StorageDetailsCubit>(() => mockStorageDetailsCubit);
  }

  Model  mockModel = Model.fromJson({
    "modelId": "46782\$\$z6im76",
    "bimModelId": "46782\$\$z6im76",
    "projectId": "2155366\$\$Hf0srP",
    "projectName": "CBIM_Data_Kajal",
    "bimModelName": "asiteBim_46782",
    "modelDescription": "Test",
    "userModelName": "Apartment A",
    "workPackageId": 2575343,
    "modelCreatorUserId": "2054614\$\$mnV9l3",
    "modelStatus": true,
    "modelCreationDate": "2023-07-19T14:30:13Z",
    "lastUpdateDate": "2023-07-19T14:30:13Z",
    "mergeLevel": 2,
    "isFavoriteModel": 0,
    "dc": "UK",
    "modelViewId": 0,
    "revisionId": "0\$\$1oecqO",
    "folderId": "0\$\$2okRIV",
    "revisionNumber": 0,
    "worksetId": "0\$\$S9js5P",
    "docId": "0\$\$Tew95s",
    "publisher": "kajal#patil#My Asite Organisation",
    "lastUpdatedUserId": "2054614\$\$mnV9l3",
    "lastUpdatedBy": "kajal#patil#My Asite Organisation",
    "lastAccessUserId": "2054614\$\$mnV9l3",
    "lastAccessBy": "kajal#patil#My Asite Organisation",
    "lastAccessModelDate": "2023-08-24T06:10:57Z",
    "modelTypeId": 0,
    "worksetdetails": null,
    "workingFolders": null,
    "generateURI": true,
    "setAsOffline": true,
    "isDropOpen": true,
    "isDownload": true,
    "fileSize": "10000.00",
    "modelSupportedOffline": true
  });
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
    CalibrationDetails.fromJson({
      "modelId": "46288\$\$JYjB69",
      "revisionId": "26991926\$\$QWzoAp",
      "calibrationId": "859\$\$fKJbka",
      "sizeOf2dFile": 194,
      "createdByUserid": "2054614\$\$euhSdp",
      "calibratedBy": "kajal",
      "createdDate": "14-Jul-2023#17:43 WET",
      "modifiedDate": "14-Jul-2023#17:43 WET",
      "point3d1": "{\"x\":-13252.9026429976,\"y\":-12848.7658434939,\"z\":3800.000106018972}",
      "point3d2": "{\"x\":53582.0973576951,\"y\":-12848.7658434939,\"z\":3800}",
      "point2d1": "{\"x\":490.725,\"y\":851,\"z\":1}",
      "point2d2": "{\"x\":500.55,\"y\":2737.4,\"z\":1}",
      "depth": 1947.08592145,
      "fileName": "Hospital_00_Floor_1_Ver2_Ver1_Ver1.pdf",
      "fileType": "pdf",
      "documentId": "13490764\$\$gsEoUS",
      "docRef": "Hospital_00_Floor_1_Ver2_Ver1_Ver1",
      "folderPath": "CBIM_Data_Kajal\\cBIM Test Data A\\Hospital A",
      "calibrationImageId": 859,
      "pageWidth": 3370.0,
      "pageHeight": 2384.0,
      "pageRotation": 270.0,
      "folderId": "115421471\$\$mLTmOE",
      "calibrationName": "Ground floor 00",
      "generateURI": true,
      "isChecked": false,
      "isDownloaded": false,
      "projectId": ""
    }),
    CalibrationDetails.fromJson({
      "modelId": "46288\$\$JYjB69",
      "revisionId": "26991930\$\$RJHPB8",
      "calibrationId": "1025\$\$aQUU93",
      "sizeOf2dFile": 178,
      "createdByUserid": "2054614\$\$euhSdp",
      "calibratedBy": "kajal",
      "createdDate": "12-Aug-2023#10:34 WET",
      "modifiedDate": "12-Aug-2023#10:34 WET",
      "point3d1": "{\"x\":-13397.9026416122,\"y\":40715.2814181994,\"z\":45700}",
      "point3d2": "{\"x\":-12765.4026416122,\"y\":30513.599677946077,\"z\":45700}",
      "point2d1": "{\"x\":2040.4,\"y\":834.9249999999997,\"z\":1}",
      "point2d2": "{\"x\":1729.95,\"y\":839.7249999999999,\"z\":1}",
      "depth": 43950.0,
      "fileName": "Hospital_13th Floor_Ver1_Ver1_Ver1.pdf",
      "fileType": "pdf",
      "documentId": "13490768\$\$FjQMzx",
      "docRef": "Hospital_13th Floor_Ver1_Ver1_Ver1",
      "folderPath": "CBIM_Data_Kajal\\cBIM Test Data A\\Hospital A",
      "calibrationImageId": 1025,
      "pageWidth": 3370.0,
      "pageHeight": 2384.0,
      "pageRotation": 270.0,
      "folderId": "115421471\$\$mLTmOE",
      "calibrationName": "Login User A and open the Hospital A model from model tab and create calibration for the 13th floor. This is the 13 th floor 13",
      "generateURI": true,
      "isChecked": false,
      "isDownloaded": false,
      "projectId": ""
    }),
  ];

  setUp(() {
    when(() => mockModelListCubit.selectedFloorList).thenReturn({});
    when(() => mockModelListItemCubit.state).thenReturn(ModelLoadingState(ModelStatus.loaded));
    when(() => mockModelListItemCubit.isFloorLoading).thenReturn(false);
    when(() => mockModelListCubit.state).thenReturn(LoadingModelState());
    when(() => mockModelListItemCubit.isTesting).thenReturn(true);
    when(() => mockModelListCubit.progress).thenReturn(0);
    when(() => mockModelListCubit.totalProgress).thenReturn(30);
    when(() => mockModelListCubit.getProjectName(any(), any())).thenAnswer((invocation) => Future.value("testProjectName"));
    when(() => mockModelListItemCubit.model).thenReturn(mockModel);
    when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
  });

  group("Model list tile widget test", () {
    configureLoginCubitDependencies();
    final floorsExpansionTileKey = GlobalKey<FloorsExpansionTileState>();
    Widget testableWidget() {
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
          BlocProvider<ModelListItemCubit>(
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
            home: Scaffold(
              body: BlocBuilder<ModelListItemCubit, ModelListItemState>(builder: (con, state) {
                return FloorsExpansionTile(
                  key: floorsExpansionTileKey,
                  bimModel: bimModel[0],
                  itemCubit: mockModelListItemCubit,
                  globalIndex: 0,
                  model: mockModel,
                  title: "Title",
                  isShowSideToolBar: false,
                  bimList: [],
                );
              }),
            )),
      );
    }

    Widget makeTestableWidget() {
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
          BlocProvider<ModelListItemCubit>(
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
            home: Scaffold(
              body: BlocBuilder<ModelListItemCubit, ModelListItemState>(builder: (con, state) {
                return ModelListTile(
                  selectedProjectModelsList: [mockModel],
                  index: 0,
                  isTest: true,
                  selectedIndex: 0,
                  state: LoadedState(),
                  onTap: (String? from) {},
                  selectedProject: Project(projectName: "testProject",projectID: "2155366\$\$Hf0srP"),
                  model: mockModel,
                  isShowSideToolBar: false,
                );
              }),
            )),
      );
    }

    testWidgets('BimListWidget test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BimListWidget(
              bimList: [],
              title: 'Test Title',
              globalIndex: 0,
              itemCubit: mockModelListItemCubit,
              model: mockModel,
              isShowSideToolBar: true,
            ),
          ),
        ),
      );

      final columnFinder = find.byType(Column);
      final column = tester.widget<Column>(columnFinder);
      expect(column.crossAxisAlignment, CrossAxisAlignment.start);

      final paddingFinder1 = find.byKey(Key("bimlist_padding_1"));
      final padding = tester.widget<Padding>(paddingFinder1);
      expect(padding.padding, const EdgeInsets.only(left: 28));

      final paddingFinder2 = find.byKey(Key("bimlist_padding_2"));
      final padding2 = tester.widget<Padding>(paddingFinder2);
      expect(padding2.padding, const EdgeInsets.only(top: 14, bottom: 15));

      expect(find.byType(NormalTextWidget), findsOneWidget);
      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets("Floor 1 expansion Widgets are render", (WidgetTester tester) async {
      await tester.pumpWidget(testableWidget());
      expect(find.byKey(Key('floor_expansion_container')), findsOneWidget);
      expect(find.byKey(Key('floor_expansion_container_2')), findsOneWidget);
      expect(find.byKey(Key('floor_expansion_column')), findsOneWidget);
      expect(find.byKey(Key('floor_expansion_row')), findsOneWidget);
      expect(find.byKey(Key('floor_expansion_gesture')), findsOneWidget);
      expect(find.byKey(Key('floor_expansion_cube_icon')), findsOneWidget);
      expect(find.byKey(Key("floor_expansion_gesture_on_name")), findsOneWidget);
    });

    testWidgets("Floor 2 expansion Widgets are render", (WidgetTester tester) async {
      when(() => mockModelListCubit.state).thenReturn(LoadedState());
      Widget testableModelListTileWidget() {
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
            BlocProvider<ModelListItemCubit>(
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
              home: Scaffold(
                body: BlocBuilder<ModelListItemCubit, ModelListItemState>(builder: (con, state) {
                  return ModelListTile(
                    progress: mockModelListCubit.progress,
                    totalProgress: mockModelListCubit.totalProgress,
                    isDownload: false,
                    selectedIndex: 0,
                    selectedProjectModelsList: [mockModel],
                    index: 0,
                    selectedProject: Project(),
                    model: mockModel,
                    onTap: (String? callFrom) {},
                    state: LoadedState(),
                    isShowSideToolBar: true,
                  );
                }),
              )),
        );
      }

      await tester.pumpWidget(testableModelListTileWidget());
      expect(find.byKey(Key('key_ignore_pointer_model_list_state')), findsOneWidget);
      expect(find.byKey(Key('key_model_list_tile_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_list_tile_ink_well')), findsOneWidget);
      expect(find.byKey(Key('key_model_list_tile_downloaded_value')), findsNothing);
    });

    testWidgets("Floor 3 expansion Widgets are render", (WidgetTester tester) async {
      List<Model> modelList = [];
      modelList.add(Model());
      when(() => mockModelListCubit.state).thenReturn(DownloadModelState(items: modelList, isItemForUpdate: false, downloadStart: true));
      when(() => mockModelListItemCubit.downloadedValue).thenReturn("43");
      when(() => mockModelListCubit.selectedModelIndex).thenReturn(0);
      Widget testableModelListTileWidget() {
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
            BlocProvider<ModelListItemCubit>(
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
              home: Scaffold(
                body: BlocBuilder<ModelListItemCubit, ModelListItemState>(builder: (con, state) {
                  return ModelListTile(
                    progress: mockModelListCubit.progress,
                    totalProgress: mockModelListCubit.totalProgress,
                    isDownload: false,
                    selectedIndex: 0,
                    selectedProjectModelsList: [],
                    index: 0,
                    selectedProject: Project(),
                    model: Model(),
                    onTap: (String? callFrom) {},
                    state: DownloadModelState(items: modelList, isItemForUpdate: false, downloadStart: true),
                    isShowSideToolBar: true,
                  );
                }),
              )),
        );
      }

      await tester.pumpWidget(testableModelListTileWidget());
      expect(find.byKey(Key('key_ignore_pointer_model_list_state')), findsOneWidget);
      expect(find.byKey(Key('key_model_list_tile_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_list_tile_ink_well')), findsOneWidget);
      expect(find.byKey(Key('key_model_list_tile_downloaded_value')), findsNothing);
    });

    testWidgets("Floor 4 expansion Widgets are render", (WidgetTester tester) async {
      List<Model> modelList = [];
      modelList.add(Model());
      when(() => mockModelListCubit.state).thenReturn(DownloadModelState(items: modelList, isItemForUpdate: false, downloadStart: true));
      when(() => mockModelListItemCubit.downloadedValue).thenReturn("43");
      when(() => mockModelListCubit.selectedModelIndex).thenReturn(0);
      Widget testableModelListTileWidget() {
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
            BlocProvider<ModelListItemCubit>(
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
              home: Scaffold(
                body: BlocBuilder<ModelListItemCubit, ModelListItemState>(builder: (con, state) {
                  return ModelListTile(
                    progress: mockModelListCubit.progress,
                    totalProgress: mockModelListCubit.totalProgress,
                    isDownload: false,
                    selectedIndex: 0,
                    selectedProjectModelsList: [],
                    index: 0,
                    selectedProject: Project(),
                    model: Model(modelSupportedOffline: true, isFavoriteModel: 1),
                    onTap: (String? callFrom) {},
                    state: DownloadModelState(items: modelList, isItemForUpdate: false, downloadStart: true),
                    isShowSideToolBar: true,
                  );
                }),
              )),
        );
      }

      await tester.pumpWidget(testableModelListTileWidget());
      expect(find.byKey(Key('model_list_tile_icon_button')), findsOneWidget);
      expect(find.byKey(Key('key_star')), findsOneWidget);
      expect(find.byKey(Key('key_model_list_tile_animated_icon')), findsNothing);
      expect(find.byKey(Key('key_star_border')), findsNothing);
    });

    testWidgets("Floor 6 expansion Widgets are render", (WidgetTester tester) async {
      List<Model> modelList = [];
      modelList.add(Model());
      when(() => mockModelListCubit.state).thenReturn(DownloadModelState(items: modelList, isItemForUpdate: false, downloadStart: true));
      when(() => mockModelListItemCubit.downloadedValue).thenReturn("43");
      when(() => mockModelListCubit.selectedModelIndex).thenReturn(0);
      Widget testableModelListTileWidget() {
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
            BlocProvider<ModelListItemCubit>(
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
              home: Scaffold(
                body: BlocBuilder<ModelListItemCubit, ModelListItemState>(builder: (con, state) {
                  return ModelListTile(
                    progress: mockModelListCubit.progress,
                    totalProgress: mockModelListCubit.totalProgress,
                    isDownload: false,
                    selectedIndex: 0,
                    selectedProjectModelsList: [],
                    index: 0,
                    selectedProject: Project(),
                    model: Model(modelSupportedOffline: false),
                    onTap: (String? callFrom) {},
                    state: DownloadModelState(items: modelList, isItemForUpdate: false, downloadStart: true),
                    isShowSideToolBar: true,
                  );
                }),
              )),
        );
      }

      await tester.pumpWidget(testableModelListTileWidget());
      expect(find.byKey(Key('model_list_tile_icon_button')), findsNothing);
      expect(find.byKey(Key('key_model_list_tile_animated_icon')), findsOneWidget);
      expect(find.byKey(Key('key_star')), findsNothing);
      expect(find.byKey(Key('key_star_border')), findsOneWidget);
      expect(find.byKey(Key('key_model_list_tile_con')), findsOneWidget);
    });

    testWidgets("Floor 5 expansion Widgets are render", (WidgetTester tester) async {
      List<Model> modelList = [];
      modelList.add(Model());
      when(() => mockModelListCubit.state).thenReturn(DownloadModelState(items: modelList, isItemForUpdate: false, downloadStart: true));
      when(() => mockModelListItemCubit.downloadedValue).thenReturn("43");
      when(() => mockModelListItemCubit.isModelSelected).thenReturn(true);
      when(() => mockModelListItemCubit.state).thenReturn(ModelLoadingState(ModelStatus.loaded));
      when(() => mockModelListCubit.selectedModelIndex).thenReturn(0);
      Widget testableModelListTileWidget() {
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
            BlocProvider<ModelListItemCubit>(
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
              home: Scaffold(
                body: BlocBuilder<ModelListItemCubit, ModelListItemState>(builder: (con, state) {
                  return ModelListTile(
                    progress: mockModelListCubit.progress,
                    totalProgress: mockModelListCubit.totalProgress,
                    isDownload: false,
                    selectedIndex: 0,
                    selectedProjectModelsList: [],
                    index: 0,
                    selectedProject: Project(),
                    model: Model(modelSupportedOffline: false),
                    onTap: (String? callFrom) {},
                    state: mockModelListCubit.state,
                    isShowSideToolBar: true,
                  );
                }),
              )),
        );
      }

      await tester.pumpWidget(testableModelListTileWidget());
    });

    testWidgets("Model 7 List Tile are render", (WidgetTester tester) async {
      List<Model> modelList = [];
      modelList.add(Model());
      when(() => mockModelListCubit.state).thenReturn(DownloadModelState(items: modelList, isItemForUpdate: false, downloadStart: true));
      when(() => mockModelListItemCubit.downloadedValue).thenReturn("43");
      when(() => mockModelListItemCubit.isModelSelected).thenReturn(false);
      when(() => mockModelListItemCubit.state).thenReturn(ModelLoadingState(ModelStatus.loaded));
      when(() => mockModelListItemCubit.isCalibrateLoading).thenReturn(true);
      when(() => mockModelListCubit.selectedModelIndex).thenReturn(0);
      Widget testableModelListTileWidget() {
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
            BlocProvider<ModelListItemCubit>(
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
              home: Scaffold(
                body: BlocBuilder<ModelListItemCubit, ModelListItemState>(builder: (con, state) {
                  return ModelListTile(
                    progress: mockModelListCubit.progress,
                    totalProgress: mockModelListCubit.totalProgress,
                    isDownload: false,
                    selectedIndex: 0,
                    selectedProjectModelsList: [],
                    index: 0,
                    selectedProject: Project(),
                    model: Model(modelSupportedOffline: false),
                    onTap: (String? callFrom) {},
                    state: mockModelListCubit.state,
                    isShowSideToolBar: true,
                  );
                }),
              )),
        );
      }

      await tester.pumpWidget(testableModelListTileWidget());
      expect(find.byKey(Key('key_center_calib')), findsNothing);
    });

    testWidgets("Floor 1 expansion rotation", (WidgetTester tester) async {
      await tester.pumpWidget(testableWidget());
      final gestureDetectorFinder = find.byKey(Key("floor_expansion_gesture"));
      expect(gestureDetectorFinder, findsOneWidget);
      await tester.tap(gestureDetectorFinder);
      await tester.pumpAndSettle();
      final rotationTransitionFinder = find.byKey(Key("floor_expansion_rotation"));
      final RotationTransition rotationTransition = tester.widget(rotationTransitionFinder);
      expect(rotationTransition.turns.value, 0.5); // Assuming the turns value changes
      final iconFinder = find.byIcon(Icons.arrow_drop_down_outlined);
      final Icon icon = tester.widget(iconFinder);
      expect(icon.size, 18);
    });

    testWidgets("Floor 2 expansion revision checkbox", (WidgetTester tester) async {
      await tester.pumpWidget(testableWidget());
      final revisionInkWell = find.byKey(Key("floor_expansion_revision_check"));
      expect(revisionInkWell, findsOneWidget);
      expect(find.byKey(Key("check_remove_icon")), findsNothing);
      await tester.tap(revisionInkWell);
      await tester.pump();
      expect(find.byKey(Key("check_icon")), findsNothing);
    });

    testWidgets("Floor  3 expansion tap on name", (WidgetTester tester) async {
      await tester.pumpWidget(testableWidget());
      final gestureDetectorFinder = find.byKey(Key("floor_expansion_gesture_on_name"));
      expect(gestureDetectorFinder, findsOneWidget);
      await tester.tap(gestureDetectorFinder);
      await tester.pumpAndSettle();
      var name = bimModel[0].name!.split("-").first.replaceAll("\"", "") + "- ${bimModel[0].docTitle ?? "Test Title"}";
      expect(find.text(name), findsOneWidget);
    });

    testWidgets("Floor 5 expansion size transion", (WidgetTester tester) async {
      await tester.pumpWidget(testableWidget());

      final gestureDetectorFinder = find.byKey(Key("floor_expansion_gesture_on_name"));
      expect(gestureDetectorFinder, findsOneWidget);

      final sizeTransitionFinder = find.byType(SizeTransition);
      expect(sizeTransitionFinder, findsOneWidget);

      await tester.tap(gestureDetectorFinder);
      await tester.pumpAndSettle();
      when(() => mockModelListItemCubit.state).thenReturn(FloorFileLoadingState(true));
      when(() => mockModelListItemCubit.isFloorLoading).thenReturn(true);
      final circularProgressIndicator = find.byKey(Key("floor_expansion_circularProgressIndicator"));
      expect(circularProgressIndicator, isNotNull);
      await tester.pumpAndSettle();
      when(() => mockModelListItemCubit.state).thenReturn(FloorFileLoadingState(false));
      when(() => mockModelListItemCubit.isFloorLoading).thenReturn(false);

      var localList = floorsExpansionTileKey.currentState?.floorList = floorList;
      expect(floorList.length, localList?.length);

      for (int i = 0; i < floorList.length; i++) {
        expect(find.byKey(Key("floor_expansion_column_floors$i")), findsOneWidget);
      }
    });

    testWidgets('Test SelectedProjectNotSetForOffline widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: SelectedProjectNotSetForOffline(
              selectedProject: Project(
                projectID: 'your_project_id',
                projectName: 'Your Project',
              ),
              isShowValidation: true,
              projectName: '',
            ),
          ),
        ),
      );

      expect(find.text('Offline data already exists'), findsOneWidget);
      expect(find.text("Please make current selected project as offline to mark model as offline."), findsOneWidget);
    });

    testWidgets('ProcessIcon animation test', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ], home: Scaffold(body: ProcessIcon())));

      expect(find.byType(ProcessIcon), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500)); // Advance the time

      final rotationTransitionFinder = find.byKey(Key("progress_icon"));
      expect(rotationTransitionFinder, findsOneWidget);

      final animatedIconFinder = find.byIcon(Icons.cached_rounded);
      expect(animatedIconFinder, findsOneWidget);
    });

    testWidgets('dropdownDispose test', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);
      final result = widget.dropdownDispose();
    });

    testWidgets('didUpdateWidget test', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);
      final result = widget.didUpdateWidget(ModelListTile(
        selectedProjectModelsList: [mockModel],
        index: 0,
        selectedIndex: 0,
        state: LoadedState(),
        onTap: (String? from) {},
        selectedProject: Project(),
        model: mockModel,
        isShowSideToolBar: false,
      ));
    });

    testWidgets('toggleExpanded test false', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);
      when(()=> mockModelListItemCubit.isExpanded).thenReturn(false);
      when(()=> mockModelListCubit.selectedCalibrate).thenReturn(calibList);
      when(() => mockModelListCubit.buildBimRequestBody(any(), any(), any())).thenAnswer((invocation) => BimProjectModelRequestModel());
      when(() => mockBimProjectCubit.getBimProjectModel(project: any(named: "project"))).thenAnswer((invocation) => Future.value([]));
      when(() => mockModelListCubit.fetchChoppedFileStatusOnDrop(any(),)).thenAnswer((invocation) => Future.value([RevisionId(revisionId: 22222222, status: "Completed"),RevisionId(revisionId: 1111111, status: "Failed"),]));
      final result = widget.toggleExpanded();
      final result2 = widget.toggleExpanded();
    });


    testWidgets('modelWidget ModelLoadingState test false', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);
      when(()=> mockModelListItemCubit.isExpanded).thenReturn(false);
      when(()=> mockModelListCubit.selectedCalibrate).thenReturn(calibList);
      when(() => mockModelListCubit.buildBimRequestBody(any(), any(), any())).thenAnswer((invocation) => BimProjectModelRequestModel());
      when(() => mockBimProjectCubit.getBimProjectModel(project: any(named: "project"))).thenAnswer((invocation) => Future.value([]));
      when(() => mockModelListCubit.fetchChoppedFileStatusOnDrop(any(),)).thenAnswer((invocation) => Future.value([RevisionId(revisionId: 22222222, status: "Completed"),RevisionId(revisionId: 1111111, status: "Failed"),]));
      final result = widget.modelWidget(ModelLoadingState(ModelStatus.loaded));
    });

    testWidgets('modelWidget ModelLoadingState test false', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);
      when(()=> mockModelListItemCubit.isExpanded).thenReturn(false);
      when(()=> mockModelListCubit.selectedCalibrate).thenReturn(calibList);
      when(() => mockModelListCubit.buildBimRequestBody(any(), any(), any())).thenAnswer((invocation) => BimProjectModelRequestModel());
      when(() => mockBimProjectCubit.getBimProjectModel(project: any(named: "project"))).thenAnswer((invocation) => Future.value([]));
      when(() => mockModelListCubit.fetchChoppedFileStatusOnDrop(any(),)).thenAnswer((invocation) => Future.value([RevisionId(revisionId: 22222222, status: "Completed"),RevisionId(revisionId: 1111111, status: "Failed"),]));
      widget.itemCubit.mapGroupBimList={"123":bimModel};
      final result = widget.modelWidget(ModelLoadingState(ModelStatus.loaded));
    });


    testWidgets('modelWidget ModelLoadingState test false', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);
      when(()=> mockModelListItemCubit.isExpanded).thenReturn(false);
      when(()=> mockModelListCubit.selectedCalibrate).thenReturn(calibList);
      when(() => mockModelListCubit.buildBimRequestBody(any(), any(), any())).thenAnswer((invocation) => BimProjectModelRequestModel());
      when(() => mockBimProjectCubit.getBimProjectModel(project: any(named: "project"))).thenAnswer((invocation) => Future.value([]));
      when(() => mockModelListCubit.fetchChoppedFileStatusOnDrop(any(),)).thenAnswer((invocation) => Future.value([RevisionId(revisionId: 22222222, status: "Completed"),RevisionId(revisionId: 1111111, status: "Failed"),]));
      widget.itemCubit.mapGroupBimList={"123":bimModel};
      final result = widget.modelWidget(ModelLoadingState(ModelStatus.failed));
    });

    testWidgets('modelWidget ModelLoadingState test false', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);
      when(()=> mockModelListItemCubit.isExpanded).thenReturn(false);
      when(()=> mockModelListCubit.selectedCalibrate).thenReturn(calibList);
      when(() => mockModelListCubit.buildBimRequestBody(any(), any(), any())).thenAnswer((invocation) => BimProjectModelRequestModel());
      when(() => mockBimProjectCubit.getBimProjectModel(project: any(named: "project"))).thenAnswer((invocation) => Future.value([]));
      when(() => mockModelListCubit.fetchChoppedFileStatusOnDrop(any(),)).thenAnswer((invocation) => Future.value([RevisionId(revisionId: 22222222, status: "Completed"),RevisionId(revisionId: 1111111, status: "Failed"),]));
      widget.itemCubit.mapGroupBimList={"123":bimModel};
      final result = widget.modelWidget(ExpandedState(true));
    });

    testWidgets('modelWidget calibratedList test 0', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);

      widget.itemCubit.isModelEmpty=false;
      widget.itemCubit.isCalibrateLoading=true;

      final result = widget.calibratedList();
    });

    testWidgets('modelWidget calibratedList test 1', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);

      widget.itemCubit.isModelEmpty=false;
      widget.itemCubit.isCalibrateLoading=false;
      widget.itemCubit.calibrationList=calibList;

      final result = widget.calibratedList();
    });

    testWidgets('modelWidget calibratedList test 2', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);

      widget.itemCubit.isModelEmpty=false;
      widget.itemCubit.isCalibrateLoading=false;
      widget.itemCubit.calibrationList=[];

      final result = widget.calibratedList();
    });

    testWidgets('modelWidget onIconClicked test 0 ', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);
      when(() => mockModelListCubit.getProjectId(any(),any())).thenAnswer((invocation) => Future.value("2155366"));
      when(() => mockModelListCubit.canManageModel(any())).thenAnswer((invocation) => Future.value(true));
      widget.widget.selectedProject!.projectID="2155366";
      final result = widget.onIconClicked(0,isTest:true);
    });
    testWidgets('modelWidget onIconClicked test 0 ', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);
      when(() => mockModelListCubit.getProjectId(any(),any())).thenAnswer((invocation) => Future.value("2155361"));
      when(() => mockModelListCubit.canManageModel(any())).thenAnswer((invocation) => Future.value(true));
      widget.widget.selectedProject!.projectID="2155366";
      final result = widget.onIconClicked(0,isTest:true);
    });

    testWidgets('modelWidget onIconClicked test 0 ', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);
      when(() => mockModelListCubit.getProjectId(any(),any())).thenAnswer((invocation) => Future.value("2155361"));
      when(() => mockModelListCubit.canManageModel(any())).thenAnswer((invocation) => Future.value(false));
      widget.widget.selectedProject!.projectID="2155366";
      widget.widget.model.setAsOffline=false;
      final result = widget.onIconClicked(0,isTest:true);
    });

    testWidgets('modelWidget tileIcon test UnableChoppedState ', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);
      when(() => mockModelListCubit.getProjectId(any(),any())).thenAnswer((invocation) => Future.value("2155361"));
      when(() => mockModelListCubit.canManageModel(any())).thenAnswer((invocation) => Future.value(true));
      widget.itemCubit.emit(UnableChoppedState());
      widget.widget.selectedProject!.projectID="2155366";
      widget.widget.model.setAsOffline=false;
      final result = widget.tileIcon(UnableChoppedState());
    });
    testWidgets('modelWidget tileIcon test FileChoppedState ', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);
      when(() => mockModelListCubit.getProjectId(any(),any())).thenAnswer((invocation) => Future.value("2155361"));
      when(() => mockModelListCubit.canManageModel(any())).thenAnswer((invocation) => Future.value(true));
      widget.itemCubit.emit(FileChoppedState());
      widget.widget.selectedProject!.projectID="2155366";
      widget.widget.model.setAsOffline=false;
      final result = widget.tileIcon(FileChoppedState());
    });
    testWidgets('modelWidget tileIcon test FileChoppedState ', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);
      when(() => mockModelListCubit.getProjectId(any(),any())).thenAnswer((invocation) => Future.value("2155361"));
      when(() => mockModelListCubit.canManageModel(any())).thenAnswer((invocation) => Future.value(true));
      widget.itemCubit.emit(FileChoppedState());
      widget.widget.selectedProject!.projectID="2155366";
      widget.widget.model.setAsOffline=false;
      widget.widget.model.isDownload=true;
      final result = widget.tileIcon(FileChoppedState());
    });
    testWidgets('modelWidget tileIcon test FileChoppedState ', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);
      when(() => mockModelListCubit.getProjectId(any(),any())).thenAnswer((invocation) => Future.value("2155361"));
      when(() => mockModelListCubit.canManageModel(any())).thenAnswer((invocation) => Future.value(true));
      widget.itemCubit.emit(FileChoppedState());
      widget.widget.selectedProject!.projectID="2155366";
      widget.widget.model.setAsOffline=false;
      widget.widget.model.isDownload=false;
      final result = widget.tileIcon(FileChoppedState());
    });

    testWidgets('modelWidget tileIcon test ExpandedState ', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());
      final finder = find.byType(ModelListTile);
      final widget = tester.state<ModelListTileState>(finder);
      when(() => mockModelListCubit.getProjectId(any(),any())).thenAnswer((invocation) => Future.value("2155361"));
      when(() => mockModelListCubit.canManageModel(any())).thenAnswer((invocation) => Future.value(true));
      widget.itemCubit.emit(ExpandedState(false));
      widget.widget.selectedProject!.projectID="2155366";
      widget.widget.model.setAsOffline=true;
      widget.widget.model.isDownload=false;
      final result = widget.tileIcon(ExpandedState(false));
    });

    testWidgets('modelWidget fetchFloor test ', (WidgetTester tester) async {
      await tester.pumpWidget(testableWidget());
      final finder = find.byType(FloorsExpansionTile);
      final widget = tester.state<FloorsExpansionTileState>(finder);
      when(() => mockModelListItemCubit.getFloorData(any(), bimModel: bimModel[0])).thenAnswer((invocation) => Future.value(floorList));
        widget.floorList=[];
        widget.widget.bimModel.floorList=[];
      final result = widget.fetchFloor();
    });

    testWidgets('modelWidget fetchFloor test [] ', (WidgetTester tester) async {
      await tester.pumpWidget(testableWidget());
      final finder = find.byType(FloorsExpansionTile);
      final widget = tester.state<FloorsExpansionTileState>(finder);
      when(() => mockModelListItemCubit.getFloorData(any(), bimModel: bimModel[0])).thenAnswer((invocation) => Future.value([]));
        widget.floorList=[];
        widget.widget.bimModel.floorList=[];
      final result = widget.fetchFloor(isTest: true);
    }); 
    
    testWidgets('modelWidget fetchFloor test mockInternetCubit ', (WidgetTester tester) async {
      await tester.pumpWidget(testableWidget());
      final finder = find.byType(FloorsExpansionTile);
      final widget = tester.state<FloorsExpansionTileState>(finder);
      widget.floorList=[];
      widget.widget.bimModel.floorList=[];
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
      when(() => mockModelListItemCubit.getFloorData(any(), bimModel: bimModel[0])).thenAnswer((invocation) => Future.value(floorList));

      final result = widget.fetchFloor(isTest: true);
    });

    testWidgets('modelWidget test onTapHandle ', (WidgetTester tester) async {
      await tester.pumpWidget(testableWidget());
      final finder = find.byType(FloorsExpansionTile);
      final widget = tester.state<FloorsExpansionTileState>(finder);
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(false);
       when(() => mockModelListItemCubit.tempFloorList).thenReturn({"rev":['file']});
       when(() => mockModelListItemCubit.onTap).thenReturn((String? from){});

      final result = widget.onTapHandle("12313","file1");
    });

    testWidgets('modelWidget test onTapHandle ', (WidgetTester tester) async {
      await tester.pumpWidget(testableWidget());
      final finder = find.byType(FloorsExpansionTile);
      final widget = tester.state<FloorsExpansionTileState>(finder);
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(false);
       when(() => mockModelListItemCubit.tempFloorList).thenReturn({"12313":['file']});
       when(() => mockModelListItemCubit.onTap).thenReturn((String? from){});

      final result = widget.onTapHandle("12313","file");
    });

    testWidgets('modelWidget test onAllTapHandel ', (WidgetTester tester) async {
      await tester.pumpWidget(testableWidget());
      final finder = find.byType(FloorsExpansionTile);
      final widget = tester.state<FloorsExpansionTileState>(finder);
      when(() => mockInternetCubit.isNetworkConnected).thenReturn(false);
       when(() => mockModelListItemCubit.tempFloorList).thenReturn({"12313":['file']});
       when(() => mockModelListItemCubit.onTap).thenReturn((String? from){});

      final result = widget.onAllTapHandel("12313",["file"]);
    });


  });
}
