import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart';
import 'package:field/bloc/pdf_tron/pdf_tron_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/utils/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/dao/bim_model_list_dao.dart';
import '../../data/dao/floor_list_dao.dart';
import '../../data/model/bim_project_model_vo.dart';
import '../../data/model/calibrated.dart';
import '../../data/model/floor_details.dart';
import '../../domain/repository/online_model_viewer_repository_impl.dart';
import '../../injection_container.dart';
import '../../utils/app_path_helper.dart';
import '../../utils/requestParamsConstants.dart';
import '../../utils/utils.dart';

part 'model_tree_state.dart';

class ModelTreeCubit extends Cubit<ModelTreeState> {
  ModelTreeCubit() : super(PaginationListInitial());
  final OnlineModelViewerCubit _onlineModelViewerCubit = di.getIt<OnlineModelViewerCubit>();
  List<FloorDetail> floorList = [];
  List<FloorDetail> selectedFloorList = [];
  List<FloorDetail> lastLoadedModels = [];
  List<Uint8List> stringToBase64ModelList = [];
  List<String> listOfRevisionId = [];
  List<List<List<FloorDetail>>> listOfFloors = [];
  List<List<List<bool>>> listOfIsCheckedFloors = [];
  List<String> offlineFilePath = [];
  List<String> bimModelsNames = [];
  List<List<String>> revisionNames = [];
  List<CalibrationDetails> calibrationList = [];
  List<CalibrationDetails> newCalibList = [];
  String projectId = "";
  String modelId = "";
  bool isFloorListExpanded = false;
  List<FloorDetail> offlineParamsFloorList = [];
  late Map<String, dynamic> offlineParams;
  List<FloorDetail> globalRemovedFloorList = [];
  List<FloorDetail> globalAddedFloorList = [];
  List<List<bool>> revisionsChecked = [];
  List<int> numberOfFloorsOfRevisions = [];
  bool okButtonActive = false;

  setOfflineParamsData(offlineParamsData) {
    emit(LoadingState());
    listOfFloors.clear();
    listOfRevisionId.clear();
    calibrationList.clear();
    newCalibList.clear();
    selectedFloorList.clear();
    listOfIsCheckedFloors.clear();
    revisionsChecked.clear();
    numberOfFloorsOfRevisions.clear();
    bimModelsNames.clear();
    revisionNames.clear();
    this.offlineParams = offlineParamsData;
    projectId = offlineParamsData[RequestConstants.projectId];
    offlineParamsFloorList = offlineParamsData[RequestConstants.floorList];
    modelId = offlineParamsData[RequestConstants.modelId];
    fetchAllRevisionId();
    getCalibrationList();
  }

  Map<dynamic, List<BimModel>> mapGroupBimList = {};
  List<List<BimModel>> bimModelsDB = [];

  fetchAllRevisionId() async {
    okButtonActive = false;
    BimModelListDao bimModelListDao = BimModelListDao();
    List<BimModel> modelDB = await bimModelListDao.fetch(modelId);
    mapGroupBimList = modelDB.groupBy((BimModel obj) => obj.ifcName!);
    bimModelsDB = mapGroupBimList.keys.toList().map((e) => mapGroupBimList[e]!).toList();
    var temp = mapGroupBimList.keys.toList().map((e) => bimModelsNames.add(e)).toList();

    for (int i = 0; i < bimModelsDB.length; i++) {
      listOfFloors.add([]);
      listOfIsCheckedFloors.add([]);
      revisionNames.add([]);
      revisionsChecked.add([]);
      for (int j = 0; j < bimModelsDB[i].length; j++) {
        revisionsChecked[i].add(false);
        revisionNames[i].add(bimModelsDB[i][j].name!.split("-").first + "- " + bimModelsDB[i][j].docTitle.toString());
        listOfRevisionId.add(bimModelsDB[i][j].revId.toString());
        listOfFloors[i].add(await fetchFloor(bimModelsDB[i][j].revId.toString(), i));
      }
    }
    bimModelsNames.toSet().toList();

    getSelectedFloor();
    emit(LoadedState());
  }

  Future<List<FloorDetail>> fetchFloor(String revisionId, int i) async {
    selectedFloorList.clear();
    offlineFilePath.clear();
    floorList = await FloorListDao().fetch(revisionId);
    List<bool> temp = List<bool>.filled(floorList.length, false);

    listOfIsCheckedFloors[i].add(temp);
    numberOfFloorsOfRevisions.add(temp.length);
    return floorList;
  }

  getSelectedFloor() {
    if (lastLoadedModels.isEmpty) {
      selectedFloorList = offlineParams['floorList'];
      if (lastLoadedModels.isEmpty) {
        lastLoadedModels.addAll(selectedFloorList);
      }
    } else {
      selectedFloorList.addAll(lastLoadedModels);
    }

    for (int i = 0; i < listOfFloors.length; i++) {
      for (int l = 0; l < listOfFloors[i].length; l++) {
        for (int k = 0; k < listOfFloors[i][l].length; k++) {
          for (int j = 0; j < selectedFloorList.length; j++) {
            if (listOfFloors[i][l][k].fileName == selectedFloorList[j].fileName) {
              listOfIsCheckedFloors[i][l][k] = true;
            }
          }
        }
        if (listOfIsCheckedFloors[i][l].where((element) => element == true).length == 0) {
          revisionsChecked[i][l] = false;
        } else {
          revisionsChecked[i][l] = true;
        }
      }
    }
  }

  updatedFloor(index, i, j) {
    listOfIsCheckedFloors[index][i][j] = !listOfIsCheckedFloors[index][i][j];
    if (selectedFloorList.contains(listOfFloors[index][i][j])) {
      selectedFloorList.remove(listOfFloors[index][i][j]);
      if (listOfIsCheckedFloors[index][i].where((element) => element == true).length == 0) {
        revisionsChecked[index][i] = false;
      }
    } else {
      selectedFloorList.add(listOfFloors[index][i][j]);
      if (listOfIsCheckedFloors[index][i].where((element) => element = true).length == 0) {
        revisionsChecked[index][i] = false;
      } else {
        revisionsChecked[index][i] = true;
      }
    }
    Set<FloorDetail> selectedFloorsSet = Set.from(selectedFloorList);
    Set<FloorDetail> lastLoadedModelsSet = Set.from(lastLoadedModels);
    List<FloorDetail> removedFloorList = lastLoadedModelsSet.difference(selectedFloorsSet).toList();
    List<FloorDetail> addedFloorList = selectedFloorsSet.difference(lastLoadedModelsSet).toList();

    if (((addedFloorList.isEmpty && removedFloorList.isEmpty))) {
      if (isListUpdated) okButtonActive = false;
    } else {
      okButtonActive = true;
    }
  }

  updateModel(List<FloorDetail> selectedFloorList, List<FloorDetail> lastLoadedModels) async {
    stringToBase64ModelList.clear();
    offlineFilePath.clear();
    Set<FloorDetail> selectedFloorsSet = Set.from(selectedFloorList);
    Set<FloorDetail> lastLoadedModelsSet = Set.from(lastLoadedModels);
    List<FloorDetail> removedFloorList = lastLoadedModelsSet.difference(selectedFloorsSet).toList();
    List<FloorDetail> addedFloorList = selectedFloorsSet.difference(lastLoadedModelsSet).toList();
    globalRemovedFloorList = removedFloorList;
    globalAddedFloorList = addedFloorList;
    _onlineModelViewerCubit.totalNumbersOfModels = "1";
    _onlineModelViewerCubit.totalNumbersOfModels = selectedFloorList.length.toString();
    if (removedFloorList.isNotEmpty) {
      for (var floor in removedFloorList) {
        await _onlineModelViewerCubit.webviewController.evaluateJavascript(source: 'nCircle.Model.deleteFile("${floor.fileName + floor.levelName}");');
      }
      _onlineModelViewerCubit.emit(LoadedSuccessfulAllModelState());
    }
    for (var floor in addedFloorList) {
      String outputFilePath = await AppPathHelper().getModelScsFilePath(
        projectId: offlineParams['projectId'],
        revisionId: floor.revisionId.toString(),
        filename: floor.fileName,
        modelId: offlineParams['modelId'],
      );
      Uint8List fileHtmlContents = await File(outputFilePath).readAsBytes();
      stringToBase64ModelList.add(fileHtmlContents);
      await loadFloors(stringToBase64ModelList, floor.fileName + floor.levelName);
    }

    lastLoadedModels.clear();
    lastLoadedModels.addAll(selectedFloorList);
  }

  checkCalibrationListStatus() {
    LoadedState();
    List<CalibrationDetails> offlineList = offlineParams['calibrateList'];

    calibrationList.forEach((calib) {
      if (offlineList.contains(calib) || _onlineModelViewerCubit.calibrationList.contains(calib)) {
        calib.isChecked = true;
      } else {
        calib.isChecked = false;
      }
    });
    newCalibList = List<CalibrationDetails>.from(calibrationList
        .map((e) => CalibrationDetails(
              modelId: e.modelId,
              revisionId: e.revisionId,
              calibrationId: e.calibrationId,
              sizeOf2DFile: e.sizeOf2DFile ?? 0,
              createdByUserid: e.createdByUserid,
              calibratedBy: e.calibratedBy,
              createdDate: e.createdDate,
              modifiedDate: e.modifiedDate,
              point3D1: e.point3D1,
              point3D2: e.point3D2,
              point2D1: e.point2D1,
              point2D2: e.point2D2,
              depth: e.depth,
              fileName: e.fileName,
              fileType: e.fileType,
              documentId: e.documentId,
              docRef: e.docRef,
              folderPath: e.folderPath,
              calibrationImageId: e.calibrationImageId,
              pageWidth: e.pageWidth,
              pageHeight: e.pageHeight,
              pageRotation: e.pageRotation,
              folderId: e.folderId,
              calibrationName: e.calibrationName,
              generateUri: e.generateUri,
              projectId: e.projectId,
              isChecked: e.isChecked,
              isDownloaded: e.isDownloaded,
            ))
        .toList());
    UpdatedState();
  }

  void updateCalibrationList(int index, bool isChecked) {
    calibrationList[index].isChecked = !calibrationList[index].isChecked;

    Set<FloorDetail> selectedFloorsSet = Set.from(selectedFloorList);
    Set<FloorDetail> lastLoadedModelsSet = Set.from(lastLoadedModels);
    List<FloorDetail> removedFloorList = lastLoadedModelsSet.difference(selectedFloorsSet).toList();
    List<FloorDetail> addedFloorList = selectedFloorsSet.difference(lastLoadedModelsSet).toList();

    if (isListUpdated) {
      if (((addedFloorList.isEmpty && removedFloorList.isEmpty))) okButtonActive = false;
    } else {
      okButtonActive = true;
    }
  }

  bool get isListUpdated => listEquals(calibrationList, newCalibList);

  updateCalibList(Orientation orientation) {
    _onlineModelViewerCubit.calibrationList.clear();
    calibrationList.forEach((element) {
      if (element.isChecked) {
        _onlineModelViewerCubit.calibrationList.add(element);
      } else {
        _onlineModelViewerCubit.calibrationList.remove(element);
      }
    });
    newCalibList.clear();
    if (_onlineModelViewerCubit.calibrationList.isEmpty) {
      String deviceType = Utility.isTablet ? "Tablet" : "Mobile";
      _onlineModelViewerCubit.is3DVisible = true;
      if (_onlineModelViewerCubit.isCalibListPressed) {
        getIt<PdfTronCubit>().selectedCalibrationHandle = null;
        _onlineModelViewerCubit.togglePdfTronVisibility(_onlineModelViewerCubit.isShowPdf ? true : false, _onlineModelViewerCubit.selectedPdfFileName, false, false);
        getIt<PdfTronCubit>().lastSavedXPoint = -99999;
        getIt<PdfTronCubit>().lastSavedYPoint = -99999;
        getIt<PdfTronCubit>().selectedCalibration = null;
        _onlineModelViewerCubit.calibList.clear();
        _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '$orientation', view : '3D',device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
        _onlineModelViewerCubit.emitNormalWebState();
      }
    }
  }

  loadFloors(stringToBase64ModelListTemp, floorName) async {
    for (int i = 0; i < stringToBase64ModelListTemp.length; ++i) {
      Future.delayed(Duration(seconds: 2));
      await _onlineModelViewerCubit.webviewController.evaluateJavascript(source: 'nCircle.Model.loadFile({fileName:`$floorName`,scsBuffer: "${base64Encode(stringToBase64ModelListTemp[i])}"});');
    }
    stringToBase64ModelListTemp.clear();
  }

  getCalibrationList() async {
    calibrationList = await OnlineModelViewerRepositoryImpl().getLocalCalibrationList(modelId);
    checkCalibrationListStatus();
    return calibrationList;
  }

  List<FloorDetail> finalList = [];

  selectAll(index, j) {
    finalList.clear();
    if (revisionsChecked[index][j]) {
      revisionsChecked[index][j] = false;
      finalList = removeFloorDetailsFromList(selectedFloorList, listOfFloors[index][j]);
      Set<FloorDetail> uniqueSet = Set<FloorDetail>.from(finalList);
      selectedFloorList.clear();
      selectedFloorList.addAll(uniqueSet.toList());
      Set<FloorDetail> selectedFloorsSet = Set.from(selectedFloorList);
      Set<FloorDetail> lastLoadedModelsSet = Set.from(lastLoadedModels);
      List<FloorDetail> removedFloorList = lastLoadedModelsSet.difference(selectedFloorsSet).toList();
      List<FloorDetail> addedFloorList = selectedFloorsSet.difference(lastLoadedModelsSet).toList();

      if (addedFloorList.isEmpty && removedFloorList.isEmpty) {
        if (isListUpdated) okButtonActive = false;
      } else {
        okButtonActive = true;
      }

      listOfIsCheckedFloors[index][j].fillRange(0, listOfIsCheckedFloors[index][j].length, false);
    } else {
      revisionsChecked[index][j] = true;
      selectedFloorList.addAll(listOfFloors[index][j]);
      finalList.addAll(selectedFloorList);
      Set<FloorDetail> uniqueSet = Set<FloorDetail>.from(finalList);
      selectedFloorList.clear();
      selectedFloorList.addAll(uniqueSet.toList());
      if (listOfIsCheckedFloors[index][j].where((element) => element = true).length == 0) {
        revisionsChecked[index][j] = false;
      } else {
        revisionsChecked[index][j] = true;
      }
      listOfIsCheckedFloors[index][j].fillRange(0, listOfIsCheckedFloors[index][j].length, true);

      Set<FloorDetail> selectedFloorsSet = Set.from(selectedFloorList);
      Set<FloorDetail> lastLoadedModelsSet = Set.from(lastLoadedModels);
      List<FloorDetail> removedFloorList = lastLoadedModelsSet.difference(selectedFloorsSet).toList();
      List<FloorDetail> addedFloorList = selectedFloorsSet.difference(lastLoadedModelsSet).toList();

      if (addedFloorList.isEmpty && removedFloorList.isEmpty) {
        if (isListUpdated) okButtonActive = false;
      } else {
        okButtonActive = true;
      }
      if (((addedFloorList.isEmpty && removedFloorList.isEmpty) || selectedFloorList.isEmpty)) {
        if (isListUpdated) okButtonActive = false;
      } else {
        okButtonActive = true;
      }
    }
  }

  List<FloorDetail> removeFloorDetailsFromList(List<FloorDetail> mainList, List<FloorDetail> floorsToRemove) {
    return mainList.where((item) => !floorsToRemove.contains(item)).toList();
  }

  void emitUpdatedState() {
    emit(UpdatedState());
  }

  void emitAfterLoadedState() {
    emit(AfterUpdatedState());
  }

  void emitNormalState() {
    emit(NormalState());
  }

  void emitLoadedState() {
    emit(LoadedState());
  }

  void emitPaginationListInitial() {
    emit(PaginationListInitial());
  }
}
