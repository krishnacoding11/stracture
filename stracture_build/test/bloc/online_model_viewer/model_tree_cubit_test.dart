import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/online_model_viewer/model_tree_cubit.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/requestParamsConstants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/injection_container.dart' as container;
import '../../fixtures/appconfig_test_data.dart';
import '../../utils/load_url.dart';
import '../mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ModelTreeCubit modelTreeCubit;
  List<FloorDetail> floorList = [];
  List<List<List<FloorDetail>>> listOfFloors = [];
  List<List<List<bool>>> listOfIsCheckedFloors = [];
  List<List<bool>> revisionsCheckedTrue = [];
  List<List<bool>> revisionsCheckedFalse = [];
  List<bool> listOfCheckedCalibration = [true];
  List<CalibrationDetails> calibrationDetails = [];

  setUpAll(() {
    AppConfigTestData().setupAppConfigTestData();
    modelTreeCubit = ModelTreeCubit();
    FloorDetail floorDetail = FloorDetail(fileName: "fileName", revisionId: 23, bimModelId: "bimModelId", fileSize: "34", floorNumber: "floorNumber", levelName: "levelName", projectId: "projectId", revName: '');
    floorList.add(floorDetail);
    listOfFloors.add([]);
    listOfFloors[0].add([]);
    listOfFloors[0][0].add(floorDetail);
    listOfIsCheckedFloors.add([]);
    listOfIsCheckedFloors[0].add([]);
    listOfIsCheckedFloors[0][0].add(true);
    revisionsCheckedTrue.add([]);
    revisionsCheckedFalse.add([]);
    revisionsCheckedTrue[0].add(true);
    revisionsCheckedFalse[0].add(false);
    CalibrationDetails calibrationDetail = CalibrationDetails(modelId: "modelId", revisionId: "revisionId", calibrationId: "calibrationId", sizeOf2DFile: 45, createdByUserid: "createdByUserid", calibratedBy: "calibratedBy", createdDate: "createdDate", modifiedDate: "modifiedDate", point3D1: "point3D1", point3D2: "point3D2", point2D1: "point2D1", point2D2: "point2D2", depth: 3, fileName: "fileName", fileType: "fileType", isChecked: false, documentId: "documentId", docRef: "docRef", folderPath: "folderPath", calibrationImageId: "calibrationImageId", pageWidth: "pageWidth", pageHeight: "pageHeight", pageRotation: "pageRotation", folderId: "folderId", calibrationName: "calibrationName", generateUri: false, isDownloaded: false, projectId: "projectId");
    calibrationDetails.add(calibrationDetail);
  });
  configureCubitDependencies() {
    MockMethodChannel().setNotificationMethodChannel();
    container.init(test: true);
    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AConstants.loadProperty();
  }

  group("Model tree listing cubit:", () {
    configureCubitDependencies();
    test("Initial state", () {
      isA<PaginationListInitial>();
    });

    blocTest<ModelTreeCubit, ModelTreeState>("set offline params",
        build: () {
          return modelTreeCubit;
        },
        act: (cubit) async {
          cubit.setOfflineParamsData(offlineParams(floorList));
        },
        expect: () => [isA<LoadingState>()]);

    blocTest<ModelTreeCubit, ModelTreeState>("getSelected floors",
        build: () {
          modelTreeCubit.offlineParams = offlineParams(floorList);
          modelTreeCubit.lastLoadedModels = floorList;
          modelTreeCubit.selectedFloorList = [];
          modelTreeCubit.listOfFloors = listOfFloors;
          modelTreeCubit.listOfIsCheckedFloors = listOfIsCheckedFloors;
          modelTreeCubit.revisionsChecked = revisionsCheckedTrue;

          return modelTreeCubit;
        },
        act: (cubit) async {
          cubit.getSelectedFloor();
        },
        expect: () => []);

    blocTest<ModelTreeCubit, ModelTreeState>("update floors",
        build: () {
          modelTreeCubit.offlineParams = offlineParams(floorList);
          modelTreeCubit.lastLoadedModels = floorList;
          modelTreeCubit.selectedFloorList = [];
          modelTreeCubit.listOfFloors = listOfFloors;
          modelTreeCubit.listOfIsCheckedFloors = listOfIsCheckedFloors;
          modelTreeCubit.revisionsChecked = revisionsCheckedTrue;

          return modelTreeCubit;
        },
        act: (cubit) async {
          cubit.updatedFloor(0, 0, 0);
        },
        expect: () => []);

    blocTest<ModelTreeCubit, ModelTreeState>("update Calibration List",
        build: () {
          modelTreeCubit.listOfCheckedCalibration = listOfCheckedCalibration;
          modelTreeCubit.selectedCalibList = [];
          modelTreeCubit.calibrationList = calibrationDetails;
          modelTreeCubit.lastListOfCheckedCalibration = listOfCheckedCalibration;

          return modelTreeCubit;
        },
        act: (cubit) async {
          cubit.updateCalibrationList(0);
        },
        expect: () => []);
    blocTest<ModelTreeCubit, ModelTreeState>("update Model",
        build: () {
          modelTreeCubit.lastLoadedModels = floorList;
          modelTreeCubit.selectedFloorList = [];

          return modelTreeCubit;
        },
        act: (cubit) async {
          cubit.updateModel(floorList, floorList);
        },
        expect: () => []);

    blocTest<ModelTreeCubit, ModelTreeState>("update calib list",
        build: () {
          modelTreeCubit.listOfCheckedCalibration = listOfCheckedCalibration;
          modelTreeCubit.selectedCalibList = [];
          modelTreeCubit.calibrationList = calibrationDetails;

          return modelTreeCubit;
        },
        act: (cubit) async {
          cubit.updateCalibList(Orientation.landscape);
        },
        expect: () => []);

    blocTest<ModelTreeCubit, ModelTreeState>("Load floors",
        build: () {
          modelTreeCubit.listOfCheckedCalibration = listOfCheckedCalibration;
          modelTreeCubit.selectedCalibList = [];
          modelTreeCubit.calibrationList = calibrationDetails;

          return modelTreeCubit;
        },
        act: (cubit) async {
          cubit.loadFloors([], "floor name");
        },
        expect: () => []);
    blocTest<ModelTreeCubit, ModelTreeState>("get calibration list",
        build: () {
          return modelTreeCubit;
        },
        act: (cubit) async {
          cubit.getCalibrationList();
        },
        expect: () => []);

    blocTest<ModelTreeCubit, ModelTreeState>("remove Floor Details FromList",
        build: () {
          return modelTreeCubit;
        },
        act: (cubit) async {
          cubit.removeFloorDetailsFromList(floorList, []);
        },
        expect: () => []);

    blocTest<ModelTreeCubit, ModelTreeState>("select All true",
        build: () {
          modelTreeCubit.offlineParams = offlineParams(floorList);
          modelTreeCubit.lastLoadedModels = floorList;
          modelTreeCubit.selectedFloorList = [];
          modelTreeCubit.listOfFloors = listOfFloors;
          modelTreeCubit.listOfIsCheckedFloors = listOfIsCheckedFloors;
          modelTreeCubit.revisionsChecked = revisionsCheckedTrue;
          return modelTreeCubit;
        },
        act: (cubit) async {
          cubit.selectAll(0, 0);
        },
        expect: () => []);

    blocTest<ModelTreeCubit, ModelTreeState>("select All false",
        build: () {
          modelTreeCubit.offlineParams = offlineParams(floorList);
          modelTreeCubit.lastLoadedModels = floorList;
          modelTreeCubit.selectedFloorList = [];
          modelTreeCubit.listOfFloors = listOfFloors;
          modelTreeCubit.listOfIsCheckedFloors = listOfIsCheckedFloors;
          modelTreeCubit.revisionsChecked = revisionsCheckedFalse;
          return modelTreeCubit;
        },
        act: (cubit) async {
          cubit.selectAll(0, 0);
        },
        expect: () => []);
  });
}

Map<String, dynamic> offlineParams(List<FloorDetail> floorList) {
  Map<String, dynamic> map = {};
  map[RequestConstants.projectId] = "projectId";
  map[RequestConstants.floorList] = floorList;
  map[RequestConstants.modelId] = "modelId";
  map[RequestConstants.calibrateList] = [];
  map["bimModelsName"] = "userModelName";
  return map;
}
