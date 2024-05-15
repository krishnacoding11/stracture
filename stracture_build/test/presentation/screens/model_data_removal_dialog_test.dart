import 'package:bloc_test/bloc_test.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/requestParamsConstants.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/model_dialogs/model_data_removal.dart';
import 'package:field/widgets/model_dialogs/model_request.dart';
import 'package:field/widgets/model_dialogs/model_request_set_offline_dialog.dart';
import 'package:field/widgets/model_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../bloc/mock_method_channel.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  Map<String, dynamic> arguments = {};
  MockBuildContext context = MockBuildContext();
  List<FloorDetail> selectedFloors = [];
  List<CalibrationDetails> selectedCalibrate = [];

  configureLoginCubitDependencies() {
    init(test: true);
  }

  setUp(() async {
    List<FloorDetail> floorDetailsList = [];
    arguments = {
      RequestConstants.projectId: '2134298\$\$4Dizau',
      RequestConstants.floorList: floorDetailsList,
      RequestConstants.modelId: '41568\$\$mWexLq',
      RequestConstants.calibrateList: [],
      "bimModelsName": '0109 D',
    };
    FloorDetail floorDetail = FloorDetail(fileName: "fileName", revisionId: 23, bimModelId: "bimModelId", fileSize: "34", floorNumber: "floorNumber", levelName: "levelName", projectId: "projectId", revName: '');
    selectedFloors.add(floorDetail);
    CalibrationDetails calibrationDetails = CalibrationDetails(modelId: "modelId", revisionId: "revisionId", calibrationId: "calibrationId", sizeOf2DFile: 45, createdByUserid: "createdByUserid",
        calibratedBy: "calibratedBy", createdDate: "createdDate", modifiedDate: "modifiedDate", point3D1: "point3D1", point3D2: "point3D2",
        point2D1: "point2D1", point2D2: "point2D2", depth: 3, fileName: "fileName", fileType: "fileType", isChecked: false, documentId: "documentId", docRef: "docRef", folderPath: "folderPath",
        calibrationImageId: "calibrationImageId", pageWidth: "pageWidth", pageHeight: "pageHeight", pageRotation: "pageRotation", folderId: "folderId",
        calibrationName: "calibrationName", generateUri: false, isDownloaded: false, projectId: "projectId");
    selectedCalibrate.add(calibrationDetails);
  });

  void onIconClicked() async {}

  Widget getModelDataRemovalDialogWidget() {
    return MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en')
        ],
        home: ModelDataRemovalDialog(
          onTapSelect: () async {},
          floorList: [],
          calibList: [],
          modelFileSize: '34',
          calibrate: [],
          calibrateFileSize: "56",
          removeList: [],
          caliRemoveList: [],
          removeFileSize: '',
          caliRemoveFileSize: '',
        ));
  }

  group('Model Tree Test', () {
    configureLoginCubitDependencies();
    testWidgets('should show model set request dialog', (WidgetTester tester) async {
      await tester.pumpWidget(getModelDataRemovalDialogWidget());
      expect(find.byKey(Key('key_model_data_removal_dialog_test_center')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_column')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_remove_text')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_are_sure_move')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_file_container_floor')), findsNothing);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_file_container_calib')), findsNothing);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_please_note_remove')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_row')), findsOneWidget);
      expect(find.byKey(Key('key_model_remove_dialog_file_container_gesture_detector')), findsNothing);
      expect(find.byKey(Key('key_model_remove_dialog_file_container_row')), findsNothing);
      expect(find.byKey(Key('key_model_remove_dialog_file_container_sized_box')), findsNothing);
    });

    Widget getModelDataRemovalDialogWidgetWithFloors() {
      return MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en')
          ],
          home: ModelDataRemovalDialog(
            onTapSelect: () async {},
            floorList: selectedFloors,
            calibList: [],
            modelFileSize: '34 MB',
            calibrate: selectedCalibrate,
            calibrateFileSize: "56",
            removeList: [],
            caliRemoveList: [],
            removeFileSize: '',
            caliRemoveFileSize: '',
          ));
    }

    testWidgets('should show model set request dialog', (WidgetTester tester) async {
      await tester.pumpWidget(getModelDataRemovalDialogWidgetWithFloors());
      expect(find.byKey(Key('key_model_data_removal_dialog_test_center')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_column')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_remove_text')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_are_sure_move')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_file_container_floor')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_file_container_calib')), findsNothing);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_please_note_remove')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_row')), findsOneWidget);
      expect(find.byKey(Key('key_model_remove_dialog_file_container_gesture_detector')), findsNWidgets(1));
      expect(find.byKey(Key('key_model_remove_dialog_file_container_row')), findsNWidgets(1));
      expect(find.byKey(Key('key_model_remove_dialog_file_container_sized_box')), findsNWidgets(1));
    });

    Widget getModelDataRemovalDialogWidgetWithCalibList() {
      return MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en')
          ],
          home: ModelDataRemovalDialog(
            onTapSelect: () async {},
            floorList: [],
            calibList: selectedCalibrate,
            modelFileSize: '34 MB',
            calibrate: [],
            calibrateFileSize: "56",
            removeList: [],
            caliRemoveList: [],
            removeFileSize: '',
            caliRemoveFileSize: '',
          ));
    }

    testWidgets('should show model set request dialog', (WidgetTester tester) async {
      await tester.pumpWidget(getModelDataRemovalDialogWidgetWithCalibList());
      expect(find.byKey(Key('key_model_data_removal_dialog_test_center')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_column')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_remove_text')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_are_sure_move')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_file_container_floor')), findsNothing);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_file_container_calib')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_please_note_remove')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_row')), findsOneWidget);
      expect(find.byKey(Key('key_model_remove_dialog_file_container_gesture_detector')), findsNWidgets(1));
      expect(find.byKey(Key('key_model_remove_dialog_file_container_row')), findsNWidgets(1));
      expect(find.byKey(Key('key_model_remove_dialog_file_container_sized_box')), findsNWidgets(1));
    });


    Widget getModelDataRemovalDialogWidgetWithCalibListAndFloors() {
      return MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en')
          ],
          home: ModelDataRemovalDialog(
            onTapSelect: () async {},
            floorList: selectedFloors,
            calibList: selectedCalibrate,
            modelFileSize: '34 MB',
            calibrate: [],
            calibrateFileSize: "56",
            removeList: [],
            caliRemoveList: [],
            removeFileSize: '',
            caliRemoveFileSize: '',
          ));
    }

    testWidgets('should show model set request dialog', (WidgetTester tester) async {
      await tester.pumpWidget(getModelDataRemovalDialogWidgetWithCalibListAndFloors());
      expect(find.byKey(Key('key_model_data_removal_dialog_test_center')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_column')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_remove_text')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_are_sure_move')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_file_container_floor')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_file_container_calib')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_please_note_remove')), findsOneWidget);
      expect(find.byKey(Key('key_model_data_removal_dialog_test_row')), findsOneWidget);
      expect(find.byKey(Key('key_model_remove_dialog_file_container_gesture_detector')), findsNWidgets(2));
      expect(find.byKey(Key('key_model_remove_dialog_file_container_row')), findsNWidgets(2));
      expect(find.byKey(Key('key_model_remove_dialog_file_container_sized_box')), findsNWidgets(2));
    });
  });
}
