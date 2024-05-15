import 'package:bloc_test/bloc_test.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/requestParamsConstants.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/model_dialogs/model_download.dart';
import 'package:field/widgets/model_dialogs/model_manage_request.dart';
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
    CalibrationDetails calibrationDetails = CalibrationDetails(modelId: "modelId", revisionId: "revisionId", calibrationId: "calibrationId", sizeOf2DFile: 45, createdByUserid: "createdByUserid", calibratedBy: "calibratedBy", createdDate: "createdDate", modifiedDate: "modifiedDate", point3D1: "point3D1", point3D2: "point3D2", point2D1: "point2D1", point2D2: "point2D2", depth: 3, fileName: "fileName", fileType: "fileType", isChecked: false, documentId: "documentId", docRef: "docRef", folderPath: "folderPath", calibrationImageId: "calibrationImageId", pageWidth: "pageWidth", pageHeight: "pageHeight", pageRotation: "pageRotation", folderId: "folderId", calibrationName: "calibrationName", generateUri: false, isDownloaded: false, projectId: "projectId");
    selectedCalibrate.add(calibrationDetails);
  });

  void onIconClicked() async {}

  Widget getModelDownloadDialogTestWidget() {
    return MaterialApp(localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ], supportedLocales: [
      Locale('en')
    ], home: ModelDownLoadDialog(isUpdate: true, removeList: [], removeFileSize: '56', caliRemoveList: [], caliRemoveFileSize: '45', calibrate: [], calibrateFileSize: '45', modelFileSize: '55', floors: [], onTapSelect: () {}));
  }

  group('Model Download Dialog Test', () {
    configureLoginCubitDependencies();
    testWidgets('should show model model download dialog', (WidgetTester tester) async {
      await tester.pumpWidget(getModelDownloadDialogTestWidget());
      expect(find.byKey(Key('key_model_download_dialog_orientation_builder')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_center')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_image_cloud_outlined')), findsNothing);
      expect(find.byKey(Key('key_model_download_dialog_update_text_widget')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_download_update_text')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_single_child_scroll_view')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_padding_floor_size')), findsNothing);
      expect(find.byKey(Key('key_model_download_dialog_padding_remove_file_size')), findsNothing);
      expect(find.byKey(Key('key_model_download_dialog_padding_calib_remove')), findsNothing);
      expect(find.byKey(Key('key_model_download_dialog_padding_calib_file')), findsNothing);
      expect(find.byKey(Key('key_model_download_dialog_download_widget')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_row')), findsOneWidget);
    });

    Widget getModelDownloadDialogTestWidgetWithFloors() {
      return MaterialApp(localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ], supportedLocales: [
        Locale('en')
      ], home: ModelDownLoadDialog(isUpdate: true, removeList: selectedFloors, removeFileSize: '56',
          caliRemoveList: selectedCalibrate, caliRemoveFileSize: '45', calibrate: selectedCalibrate, calibrateFileSize: '45', modelFileSize: '55', floors: selectedFloors, onTapSelect: () {}));
    }

    testWidgets('should show model model download dialog', (WidgetTester tester) async {
      FloorDetail floorDetail = FloorDetail(isChecked:true,isDownloaded:false,fileName: "fileName", revisionId: 23, bimModelId: "bimModelId", fileSize: "34", floorNumber: "floorNumber", levelName: "levelName", projectId: "projectId", revName: '');
      selectedFloors.add(floorDetail);
      CalibrationDetails calibrationDetails = CalibrationDetails(modelId: "modelId", revisionId: "revisionId", calibrationId: "calibrationId", sizeOf2DFile: 45, createdByUserid: "createdByUserid", calibratedBy: "calibratedBy",
          createdDate: "createdDate", modifiedDate: "modifiedDate", point3D1: "point3D1", point3D2: "point3D2", point2D1: "point2D1", point2D2: "point2D2",
          depth: 3, fileName: "fileName", fileType: "fileType", isChecked: true, documentId: "documentId", docRef: "docRef", folderPath: "folderPath",
          calibrationImageId: "calibrationImageId", pageWidth: "pageWidth", pageHeight: "pageHeight", pageRotation: "pageRotation", folderId: "folderId",
          calibrationName: "calibrationName", generateUri: false, isDownloaded: false, projectId: "projectId");
      selectedCalibrate.add(calibrationDetails);
      await tester.pumpWidget(getModelDownloadDialogTestWidgetWithFloors());
      expect(find.byKey(Key('key_model_download_dialog_orientation_builder')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_center')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_image_cloud_outlined')), findsNothing);
      expect(find.byKey(Key('key_model_download_dialog_update_text_widget')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_download_update_text')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_single_child_scroll_view')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_padding_floor_size')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_padding_remove_file_size')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_padding_calib_remove')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_padding_calib_file')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_download_widget')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_row')), findsOneWidget);
      expect(find.byKey(Key('key_file_container_column')), findsNWidgets(4));
      expect(find.byKey(Key('key_file_container_title')), findsNWidgets(4));
      expect(find.byKey(Key('key_file_container_container')), findsNWidgets(4));
    });


    Widget getModelDownloadDialogTestWidgetWithCalibEmpty() {
      FloorDetail floorDetail = FloorDetail(isChecked:true,isDownloaded:false,fileName: "fileName", revisionId: 23, bimModelId: "bimModelId", fileSize: "34", floorNumber: "floorNumber", levelName: "levelName", projectId: "projectId", revName: '');
      selectedFloors.add(floorDetail);
      CalibrationDetails calibrationDetails = CalibrationDetails(modelId: "modelId", revisionId: "revisionId", calibrationId: "calibrationId", sizeOf2DFile: 45, createdByUserid: "createdByUserid", calibratedBy: "calibratedBy",
          createdDate: "createdDate", modifiedDate: "modifiedDate", point3D1: "point3D1", point3D2: "point3D2", point2D1: "point2D1", point2D2: "point2D2",
          depth: 3, fileName: "fileName", fileType: "fileType", isChecked: true, documentId: "documentId", docRef: "docRef", folderPath: "folderPath",
          calibrationImageId: "calibrationImageId", pageWidth: "pageWidth", pageHeight: "pageHeight", pageRotation: "pageRotation", folderId: "folderId",
          calibrationName: "calibrationName", generateUri: false, isDownloaded: false, projectId: "projectId");
      selectedCalibrate.add(calibrationDetails);
      return MaterialApp(localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ], supportedLocales: [
        Locale('en')
      ], home: ModelDownLoadDialog(isUpdate: true, removeList: selectedFloors, removeFileSize: '56',
          caliRemoveList: [], caliRemoveFileSize: '45', calibrate: [], calibrateFileSize: '45', modelFileSize: '55', floors: selectedFloors, onTapSelect: () {}));
    }

    testWidgets('should show model model download dialog', (WidgetTester tester) async {
      await tester.pumpWidget(getModelDownloadDialogTestWidgetWithCalibEmpty());
      expect(find.byKey(Key('key_model_download_dialog_orientation_builder')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_center')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_image_cloud_outlined')), findsNothing);
      expect(find.byKey(Key('key_model_download_dialog_update_text_widget')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_download_update_text')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_single_child_scroll_view')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_padding_floor_size')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_padding_remove_file_size')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_padding_calib_remove')), findsNothing);
      expect(find.byKey(Key('key_model_download_dialog_padding_calib_file')), findsNothing);
      expect(find.byKey(Key('key_model_download_dialog_download_widget')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_row')), findsOneWidget);
      expect(find.byKey(Key('key_download_model_file_size')), findsOneWidget);
      expect(find.byKey(Key('key_file_container_column')), findsNWidgets(2));
      expect(find.byKey(Key('key_file_container_title')), findsNWidgets(2));
      expect(find.byKey(Key('key_file_container_container')), findsNWidgets(2));
    });


    Widget getModelDownloadDialogTestWidgetWithFloorEmpty() {
      FloorDetail floorDetail = FloorDetail(isChecked:true,isDownloaded:false,fileName: "fileName", revisionId: 23, bimModelId: "bimModelId", fileSize: "34", floorNumber: "floorNumber", levelName: "levelName", projectId: "projectId", revName: '');
      selectedFloors.add(floorDetail);
      CalibrationDetails calibrationDetails = CalibrationDetails(modelId: "modelId", revisionId: "revisionId", calibrationId: "calibrationId", sizeOf2DFile: 45, createdByUserid: "createdByUserid", calibratedBy: "calibratedBy",
          createdDate: "createdDate", modifiedDate: "modifiedDate", point3D1: "point3D1", point3D2: "point3D2", point2D1: "point2D1", point2D2: "point2D2",
          depth: 3, fileName: "fileName", fileType: "fileType", isChecked: true, documentId: "documentId", docRef: "docRef", folderPath: "folderPath",
          calibrationImageId: "calibrationImageId", pageWidth: "pageWidth", pageHeight: "pageHeight", pageRotation: "pageRotation", folderId: "folderId",
          calibrationName: "calibrationName", generateUri: false, isDownloaded: false, projectId: "projectId");
      selectedCalibrate.add(calibrationDetails);
      return MaterialApp(localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ], supportedLocales: [
        Locale('en')
      ], home: ModelDownLoadDialog(isUpdate: true, removeList: [], removeFileSize: '56',
          caliRemoveList: selectedCalibrate, caliRemoveFileSize: '45', calibrate: selectedCalibrate, calibrateFileSize: '45', modelFileSize: '55', floors: [], onTapSelect: () {}));
    }

    testWidgets('should show model model download dialog', (WidgetTester tester) async {
      await tester.pumpWidget(getModelDownloadDialogTestWidgetWithFloorEmpty());
      expect(find.byKey(Key('key_model_download_dialog_orientation_builder')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_center')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_container')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_image_cloud_outlined')), findsNothing);
      expect(find.byKey(Key('key_model_download_dialog_update_text_widget')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_download_update_text')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_single_child_scroll_view')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_padding_floor_size')), findsNothing);
      expect(find.byKey(Key('key_model_download_dialog_padding_remove_file_size')), findsNothing);
      expect(find.byKey(Key('key_model_download_dialog_padding_calib_remove')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_padding_calib_file')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_download_widget')), findsOneWidget);
      expect(find.byKey(Key('key_model_download_dialog_row')), findsOneWidget);
      expect(find.byKey(Key('key_file_container_column')), findsNWidgets(2));
      expect(find.byKey(Key('key_file_container_title')), findsNWidgets(2));
      expect(find.byKey(Key('key_file_container_container')), findsNWidgets(2));
    });
  });
}
