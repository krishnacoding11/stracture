import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/online_model_viewer/model_tree_cubit.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/presentation/screen/side_toolbar/side_toolbar_screen.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/requestParamsConstants.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/model_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../bloc/mock_method_channel.dart';

class MockModelTreeCubit extends MockCubit<ModelTreeState> implements ModelTreeCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockModelTreeCubit mockModelTreeCubit = MockModelTreeCubit();
  Map<String, dynamic> arguments = {};

  configureLoginCubitDependencies() {
    init(test: true);
    getIt.unregister<ModelTreeCubit>();
    getIt.registerLazySingleton<ModelTreeCubit>(() => mockModelTreeCubit);
  }
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
  setUp(() async {
    when(() => mockModelTreeCubit.state).thenReturn(PaginationListInitial());

    arguments = {
      RequestConstants.projectId: '2134298\$\$4Dizau',
      RequestConstants.floorList: floorList,
      RequestConstants.modelId: '41568\$\$mWexLq',
      RequestConstants.calibrateList: [],
      "bimModelsName": '0109 D',
    };
    when(()=> mockModelTreeCubit.bimModelsDB).thenReturn([bimModel]);
    when(()=> mockModelTreeCubit.listOfFloors).thenReturn([[floorList]]);
    when(()=> mockModelTreeCubit.revisionsChecked).thenReturn([[true]]);
    when(()=> mockModelTreeCubit.listOfIsCheckedFloors).thenReturn([[[true,false],[false,false]],[[true],[false]]]);
    when(()=> mockModelTreeCubit.okButtonActive).thenReturn(true);
    when(()=> mockModelTreeCubit.isFloorListExpanded).thenReturn(true);
    when(()=> mockModelTreeCubit.bimModelsNames).thenReturn(["0109 D"]);
    when(()=> mockModelTreeCubit.floorList).thenReturn(floorList);
    when(()=> mockModelTreeCubit.revisionNames).thenReturn([["0109 D"]]);
    when(()=> mockModelTreeCubit.calibrationList).thenReturn(calibList);
    when(() => mockModelTreeCubit.projectId).thenReturn(arguments[RequestConstants.projectId]);
    when(() => mockModelTreeCubit.offlineParamsFloorList).thenReturn(arguments[RequestConstants.floorList]);
    when(() => mockModelTreeCubit.modelId).thenReturn(arguments[RequestConstants.modelId]);
  });

  Widget getTestWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ModelTreeCubit>(
          create: (BuildContext context) => mockModelTreeCubit,
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: ModelTreeWidget(arguments),
      ),
    );
  }

  group('Model Tree Test', () {
    configureLoginCubitDependencies();
    //FAIL
    testWidgets('should show model tree dialog', (WidgetTester tester) async {
      await tester.pumpWidget(getTestWidget());
      expect(find.byKey(Key('key_model_tree_dialog')), findsOneWidget);
    });

    testWidgets('should show model tree dialog', (WidgetTester tester) async {
      when(() => mockModelTreeCubit.state).thenReturn(LoadingState());
      await tester.pumpWidget(getTestWidget());
      expect(find.byKey(Key('key_model_tree_a_circular_progress')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_column')), findsNothing);
    });

    testWidgets('should show model tree dialog', (WidgetTester tester) async {
      await tester.pumpWidget(getTestWidget());
      expect(find.byKey(Key('key_model_tree_a_circular_progress')), findsNothing);
      expect(find.byKey(Key('key_model_tree_column')), findsOneWidget);
    });

    testWidgets('should show model tree dialog', (WidgetTester tester) async {
      await tester.pumpWidget(getTestWidget());
      expect(find.byKey(Key('key_model_tree_a_circular_progress')), findsNothing);
      expect(find.byKey(Key('key_model_tree_column')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_tab_bar')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_model_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_calibrated_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_expanded_tab_bar_view')), findsOneWidget);

    });


    testWidgets('should show model tree dialog', (WidgetTester tester) async {
      when(()=> mockModelTreeCubit.bimModelsDB).thenReturn([bimModel]);
      await tester.pumpWidget(getTestWidget());
      expect(find.byKey(Key('key_model_tree_a_circular_progress')), findsNothing);
      expect(find.byKey(Key('key_model_tree_column')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_tab_bar')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_model_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_calibrated_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_expanded_tab_bar_view')), findsOneWidget);
    });

    testWidgets('should show model tree dialog', (WidgetTester tester) async {
      await tester.pumpWidget(getTestWidget());
      expect(find.byKey(Key('key_model_tree_select_location_controller')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_row_icon_close')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_model_name_text')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_close_icon')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_ok_elevated_button')), findsNothing);
    });

    testWidgets('should show model tree dialog', (WidgetTester tester) async {
      await tester.pumpWidget(getTestWidget());
      expect(find.byKey(Key('key_model_tree_expanded_tab_bar_view')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_expansion_tile')), findsNothing);
    });
  });

 

  testWidgets('CustomFlushBar should show and disappear', (WidgetTester tester) async {
    final overlayKey = GlobalKey<ScaffoldState>();

    await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ModelTreeCubit>(
              create: (BuildContext context) => mockModelTreeCubit,
            ),
          ],
          child: MaterialApp(
          home: Scaffold(
            key: overlayKey,
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    CustomFlushBar(
                      subMessage: "Message",
                      key: Key('customFlushBar'),
                      message: 'Hello, World!',
                      duration: Duration(milliseconds: 200),
                    ).show(context);
                  },
                  child: Text('Show CustomFlushBar'),
                );
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Hello, World!'), findsNothing); // Ensure CustomFlushBar is not initially displayed.

    // Trigger the CustomFlushBar to show.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Hello, World!'), findsOneWidget); // Ensure CustomFlushBar is displayed.

    // Wait for the CustomFlushBar to disappear.
    await tester.pumpAndSettle();

    expect(find.text('Hello, World!'), findsNothing); // Ensure CustomFlushBar is no longer displayed.
  });
}
