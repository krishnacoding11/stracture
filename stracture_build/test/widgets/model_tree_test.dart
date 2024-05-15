import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/online_model_viewer/model_tree_cubit.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart' as online_model_viewer;
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/injection_container.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/requestParamsConstants.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/model_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../bloc/mock_method_channel.dart';

class MockModelTreeCubit extends MockCubit<ModelTreeState> implements ModelTreeCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockModelTreeCubit mockModelTreeCubit = MockModelTreeCubit();
  late ModelTreeCubit modelTreeCubit;
  online_model_viewer.OnlineModelViewerCubit onlineModelViewerCubit;
  Map<String, dynamic> arguments = {};
  final GlobalKey<ScaffoldState> modelScaffoldKey = GlobalKey<ScaffoldState>();
  List<FloorDetail> floorDetailsList = [];
  List<List<List<FloorDetail>>> listOfFloorsMock = [];
  const buttonOneKey = Key("buttonOne");
  configureLoginCubitDependencies() {
    init(test: true);
    getIt.registerLazySingleton<MockModelTreeCubit>(() => mockModelTreeCubit);
  }

  setUp(() async {
    onlineModelViewerCubit=online_model_viewer.OnlineModelViewerCubit();
    modelTreeCubit = ModelTreeCubit();
    when(() => mockModelTreeCubit.state).thenReturn(PaginationListInitial());
    final jsonCalibrationDetailsString = '{"calibrateData":[{"modelId": "12345", "revisionId": "form_123", "calibrationId": "calibration_567", "sizeOf2dFile": 0, "createdByUserid": "createdBy_123", "calibratedBy": "dist_456", "createdDate": "createdDate_here", "modifiedDate": "1630444800000", "point3d1": "1630444800000", "point3d2": "1630444800000", "point2d1": "1630845800000", "point2d2": "16304445252", "depth": 0.0, "fileName": "fileName_123", "fileType": "pdf", "documentId": "1630444500", "docRef": "1630444500", "folderPath": "folderPath", "calibrationImageId": "1630444500", "pageWidth": "1630444500", "pageHeight": "1630444500", "pageRotation": "16304", "calibrationName": "16364640","folderId" : "554158", "projectId": "8785411", "isChecked": false, "isDownloaded": false,"generateURI":false}]}';
    final Map<String, dynamic> jsonMap = jsonDecode(jsonCalibrationDetailsString);
    List<CalibrationDetails> calibrationList = List<CalibrationDetails>.from(jsonMap["calibrateData"].map((e) => CalibrationDetails.fromJson(e)));


    final jsonfloorDetailsString = '{"floorDetails": [{"fileName": "floor_plan_1","fileSize": 1024,"floorNumber": 1,"levelName": "Level 1","isChecked": true,"isDownloaded": false,"revisionId": 1,"bimModelId": "bim_123","projectId": "proj_456"}]}';
    final Map<String, dynamic> jsonMapFloor = jsonDecode(jsonfloorDetailsString);
    floorDetailsList = List<FloorDetail>.from(jsonMapFloor["floorDetails"].map((e) => FloorDetail.fromJson(e)));
    listOfFloorsMock.add([floorDetailsList]);
    listOfFloorsMock.add([floorDetailsList]);
    listOfFloorsMock.add([floorDetailsList]);
    modelTreeCubit.listOfFloors=listOfFloorsMock;
    arguments = {
      RequestConstants.projectId: '2134298\$\$4Dizau',
      RequestConstants.floorList: floorDetailsList,
      RequestConstants.modelId: '41568\$\$mWexLq',
      RequestConstants.calibrateList: calibrationList,
      "bimModelsName": '0109 D',
    };
    when(() => mockModelTreeCubit.projectId).thenReturn(arguments[RequestConstants.projectId]);
    when(() => mockModelTreeCubit.offlineParamsFloorList).thenReturn(arguments[RequestConstants.floorList]);
    when(() => mockModelTreeCubit.modelId).thenReturn(arguments[RequestConstants.modelId]);
    when(() => mockModelTreeCubit.listOfFloors).thenReturn(listOfFloorsMock);
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
        home: Scaffold(key: modelScaffoldKey,
            backgroundColor: Colors.transparent,
            body: ModelTreeWidget(arguments)
        )
      ),
    );
  }

  Widget getTest2Widget() {
    return MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: Scaffold(body: Builder(builder: (context) {
      return TextButton(
        key: buttonOneKey,
        child: const Text("Show dialog"),
        onPressed: () {
          CustomFlushBar(
            message: context.toLocale!.warning,
            subMessage: context.toLocale!.please_select_at_least_one_floor,
            duration: Duration(seconds: 3),
            backgroundColor: Colors.yellow,
            messageColor: Colors.black,
            icon: Icon(
              Icons.warning,
              color: Colors.yellow,
            ),
          ).show(context);
        },
      );
    })));
  }

  group('Model Tree Test', () {
    configureLoginCubitDependencies();
     testWidgets('should show model tree dialog', (WidgetTester tester) async {
      await tester.pumpWidget(getTestWidget());
      expect(find.byKey(modelScaffoldKey), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_a_circular_progress')), findsNothing);
      expect(find.byKey(Key('key_model_tree_column')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_tab_bar')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_model_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_calibrated_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_tree_expanded_tab_bar_view')), findsOneWidget);
      //expect(find.byKey(Key('key_model_tree_list_view')), findsOneWidget);
    });

    testWidgets('Test CustomFlushbar', (WidgetTester tester) async {
      //configureLoginCubitDependencies();
      await tester.pumpWidget(getTest2Widget());

      final buttonOne = find.byKey(buttonOneKey);
      expect(buttonOne, findsOneWidget);

      await tester.runAsync(() async {
        await tester.tap(buttonOne);
      });
      await tester.pump(Duration(milliseconds: 200));
    });

  });
}
