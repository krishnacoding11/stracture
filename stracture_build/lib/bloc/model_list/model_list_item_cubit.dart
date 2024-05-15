import 'dart:developer';
import 'dart:io';

import 'package:field/data/dao/calibration_list_dao.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/dao/model_list_dao.dart';
import '../../data/model/model_vo.dart';
import '../../domain/use_cases/model_list_use_case/model_list_use_case.dart';
import '../../domain/use_cases/online_model_vewer_use_case.dart';
import '../../injection_container.dart';
import '../../utils/app_path_helper.dart';
import '../storage_details/storage_details_cubit.dart';
import 'model_list_cubit.dart';
import 'model_list_item_state.dart';

enum ModelStatus { loaded, loading, failed }

class ModelListItemCubit extends Cubit<ModelListItemState> {
  ModelListItemCubit() : super(ExpandedState(false));
  final ModelListUseCase _modelListUseCase = getIt<ModelListUseCase>();
  final ModelListCubit _modelListCubit = getIt<ModelListCubit>();
  final OnlineModelViewerUseCase _onlineModelViewerUseCase = getIt<OnlineModelViewerUseCase>();
  bool isExpanded = false;
  bool isFloorExpanded = false;
  bool isTesting = false;
  bool isModelSelected = true;
  bool isCalibrateLoading = true;
  bool isFloorLoading = true;
  bool isFloorDeleted = false;
  bool isChopped = true;
  bool isChopping = false;
  bool isModelLoaded = false;
  bool isModelLoading = false;
  bool isBimModelExpanded = false;
  bool isModelEmpty = false;
  String downloadedValue = '';
  List<FloorDetail> loadedFloorList = [];
  late ModelListCubit modelListCubit;
  late List<Model> selectedProjectModelsList;
  Map<String, List<FloorDetail>> selectedFloorList = {};
  late Model model;
  late Function(String) onTap;
  List<CalibrationDetails> calibrationList = [];
  Map<String, List<String>> tempFloorList = Map();
  List<String> downloadedScsFiles = [];
  List<BimModel> groupBimList = [];
  late BimModel selectedBimModelData;
  List<FloorDetail> downloadedFiles = [];
  List<CalibrationDetails> downloadedPdfFilesList = [];
  Map<String, List<BimModel>> mapGroupBimList = {};

  void initializeVars(ModelListCubit modelListCubit, List<Model> selectedProjectModelsList, Model model, Function(String) onTap) {
    this.modelListCubit = modelListCubit;
    this.selectedProjectModelsList = selectedProjectModelsList;
    this.model = model;
    this.onTap = onTap;
  }

  downloadProgressState(progress) {
    emit(DownloadedProgressState(progress));
  }

  fetchCalibratedFile(String projectId, {bool isTest = false}) async {
    String projectId = model.projectId ?? "";
    String modelId = model.bimModelId ?? "";
    try {
      loadingCalibrate(true);
      if (isNetWorkConnected()) {
        var result = await _onlineModelViewerUseCase.getCalibrationList(
          projectId,
          modelId,
        );
        log(result.data.toString());
        calibrationList = List<CalibrationDetails>.from(result.data.map(
          (e) => CalibrationDetails.fromJson(e),
        ));
      } else {
        calibrationList = await _onlineModelViewerUseCase.getLocalCalibrationList(modelId);
      }
      List<String> downloadedPDFFiles = [];

      downloadedPDFFiles = await getDownloadedPdfFile(model.projectId.toString(), []);

      for (int j = 0; j < calibrationList.length; j++) {
        if (downloadedPDFFiles.toString().contains(calibrationList[j].revisionId.plainValue())) {
          calibrationList[j].isChecked = isNetWorkConnected() ? true : false;
          calibrationList[j].isDownloaded = true;
        } else {
          calibrationList[j].isChecked = false;
        }
      }
      if (!isTest) {
        syncCalibListWithDB(calibrationList.where((element) => element.isChecked == true).toList());
      }
      calibrationList.forEach((element) {
        element.projectId = projectId.plainValue();
      });
      double floorSize = await _modelListUseCase.floorSizeByModelId(model.modelId.plainValue());
      if (floorSize > 0) {
        model.fileSize = floorSize.toString();
        model.isDownload = true;
        if (!isTest) {
          ModelListDao().insert([model]);
        }
      } else {
        model.fileSize = "";
        model.isDownload = false;
        if (!isTest) {
          ModelListDao().insert([model]);
        }
      }
      loadingCalibrate(false);
    } catch (e) {
      loadingCalibrate(false);
      rethrow;
    }
  }

  Future<List<FloorDetail>> getFloorData(String revId, {required BimModel bimModel, bool isTest = false}) async {
    Map<String, dynamic> request = {"projectId": model.projectId, "revisionIds": revId};
    List<FloorDetail> floorList = [];
    downloadedFiles.clear();
    try {
      List<FloorData> result = await _modelListUseCase.getFloorList(request);
      if (result.isNotEmpty) {
        if (isNetWorkConnected()) {
          selectedFloorList[revId] = result.first.floorDetails;
          for (var element in result) {
            element.bimModelId = model.bimModelId;
            for (var e in element.floorDetails) {
              e.bimModelId = model.bimModelId.plainValue();
              e.revisionId = element.revisionId;
              e.revName = "${bimModel.ifcName} (${bimModel.name!.split("-").first + "- ${bimModel.docTitle}"})";
              e.projectId = model.projectId.plainValue();
            }
          }
        }
        floorList = result.first.floorDetails;

        List<FloorDetail> floorDBList = await _modelListUseCase.fetchRevisionId(revId.toString().plainValue());
        List<String> downloadedScsFiles = await _modelListUseCase.getDownloadedModelsPath(model.projectId.toString(), model.bimModelId.toString(), revId, []);

        Set<String> downloadedFilesSet = Set.from(downloadedScsFiles);
        for (var floor in floorList) {
          if (downloadedFilesSet.contains(floor.fileName)) {
            floor.isDownloaded = true;
            floor.isChecked = true;
            downloadedFiles.add(floor);
          }
        }
        var floorSize = 0.0;

        if (!isTest) {
          await _modelListUseCase.syncWithDB(floorDBList, [], modelListCubit, downloadedScsFiles, downloadedFiles, groupBimList, bimModel, floorSize).then((value) async {
            floorSize = await _modelListUseCase.floorSizeByModelId(model.modelId.plainValue());
            if (floorSize > 0) {
              model.fileSize = floorSize.toString();
              model.isDownload = true;
              ModelListDao().insert([model]);
            } else {
              model.fileSize = "";
              model.isDownload = false;
              ModelListDao().insert([model]);
            }
          });
        }

        if (!isNetWorkConnected()) {
          floorSize = await _modelListUseCase.floorSizeByModelId(model.modelId.plainValue());
          if (floorSize > 0) {
            model.fileSize = floorSize.toString();
            model.isDownload = true;
            ModelListDao().insert([model]);
          } else {
            model.fileSize = "";
            model.isDownload = false;
            ModelListDao().insert([model]);
          }
        }
      }
    } catch (e) {
      Log.d([e]);
    }

    return floorList;
  }

  loadingCalibrate(bool value) {
    isCalibrateLoading = value;
    emit(CalibrateFileLoadingState(isCalibrateLoading));
  }

  fileChoppingState() {
    isChopping = true;
    emit(FileChoppingState());
  }

  loadingFavCheckState() {
    emit(LoadingFavCheckState());
  }

  favCheckedState() {
    emit(FavCheckedState());
  }

  modelLoadingState(ModelStatus value) {
    isModelLoading = (value == ModelStatus.loading);
    isModelLoaded = (value == ModelStatus.loaded);
    emit(ModelLoadingState(value));
  }

  fileChoppedState() {
    isChopping = false;
    isChopped = true;
    emit(FileChoppedState());
  }

  unableChoppedState() {
    isChopping = false;
    emit(UnableChoppedState());
  }

  loadingFloor(bool value) {
    isFloorLoading = value;
    emit(FloorFileLoadingState(isFloorLoading));
  }

  deletedSingleFloorState(bool value) {
    getIt<StorageDetailsCubit>().modelSelectState(model);
    isFloorDeleted = value;
    emit(SingleFloorDeletedState(value));
  }

  checkedFloor(bool value, BimModel bimModel) {
    emit(FloorCheckedState(value, bimModel));
    value = !value;
    emit(FloorCheckedState(value, bimModel));
  }

  onCalibratedFileClick(List<CalibrationDetails> calibrationList) {
    emit(CalibrateFileCheckState(calibrationList));
  }

  onExpansionClick(bool value) {
    isExpanded = value;
    emit(ExpandedState(value));
  }

  onFloorExpansionClick(bool value) {
    isFloorExpanded = value;
    emit(FloorExpandedState(value));
  }

  onTabChange(bool value, String projectId) {
    isModelSelected = value;
    emit(TabChangeState(value));
    if (!isModelSelected) {
      if (calibrationList.isEmpty && isExpanded) {
        fetchCalibratedFile(projectId);
      }
    }
  }

  AProgressDialog? aProgressDialog;

  Future<void> sendModelOfflineRequest({
    required String bimModelId,
    required String projectId,
  }) async {
    Map<String, dynamic> request = {
      "projectId": projectId,
      "bimModelId": bimModelId,
      "modelVersionID": -1,
    };
    aProgressDialog?.show();
    var dataResponse = await _modelListUseCase.sendModelRequestForOffline(request);
    aProgressDialog?.dismiss();
    emit(SendAdministratorState(responseData: dataResponse));
  }

  clearWrongCheckFile() {
    calibrationList.forEach((element) {
      if (!element.isDownloaded) {
        element.isChecked = false;
      }
    });
  }

  Future<List<String>> getDownloadedPdfFile(String projectId, List<String> downloadedPDFFiles) async {
    String path = await AppPathHelper().getPlanDirectory(projectId: projectId);
    if (await Directory("$path").exists()) {
      List<FileSystemEntity> file = Directory("$path").listSync();

      for (int i = 0; i < file.length; i++) {
        var actualFile = file[i].path.toString().split("/").last;
        actualFile = actualFile.replaceAll(".pdf", "");
        downloadedPDFFiles.add(actualFile);
      }
      return downloadedPDFFiles;
    } else {
      return downloadedPDFFiles;
    }
  }

  Future<void> syncCalibListWithDB(List<CalibrationDetails> calibrate) async {
    final CalibrationListDao _calibrationListDao = CalibrationListDao();
    // if (calibrate.isNotEmpty) {
    //   await _calibrationListDao.deleteAllQuery();
    // }
    await _calibrationListDao.insert(calibrate);
  }

  deleteSingleFloor(BimModel bimModel, i, List<BimModel> bimList, FloorDetail floor) async {
    deletedSingleFloorState(true);
    await _modelListCubit.removeFloorsFromLocal(model, [bimModel.floorList[i]], _modelListCubit.projectId);

    bimModel.floorList.removeWhere((element) => floor.fileName.trim() == element.fileName.trim());

    if (bimModel.floorList.isEmpty) {
      if (mapGroupBimList.containsKey(bimModel.ifcName)) {
        mapGroupBimList[bimModel.ifcName]!.removeWhere((element) => element.revId.plainValue() == bimModel.revId.toString().plainValue());
        if (mapGroupBimList[bimModel.ifcName]!.isEmpty) {
          mapGroupBimList.remove(bimModel.ifcName);
        }
      }
    }

    if (mapGroupBimList.isEmpty) {
      _modelListCubit.pageFetch(0, false, false, "", model.projectId!, _modelListCubit.isFavorite ? 0 : 1, true, "aesc", _modelListCubit.searchString);
    }

    mapGroupBimList.keys.forEach((titleKey) {
      mapGroupBimList[titleKey]!.forEach((bimModel) {
        bimModel.isChecked = false;
        bimModel.floorList.forEach((floor) {
          floor.isChecked = false;
        });
      });
    });

    double floorSize = await _modelListUseCase.floorSizeByModelId(model.modelId.plainValue());
    if (floorSize > 0) {
      model.fileSize = floorSize.toString();
      model.isDownload = true;
      ModelListDao().insert([model]);
    } else {
      model.fileSize = "";
      model.isDownload = false;
      ModelListDao().insert([model]);
    }

    _modelListCubit.selectedFloorList.clear();

    deletedSingleFloorState(false);
    _modelListCubit.emitDeleteModelListState();
  }

  Future<void> deleteByRevision(BimModel bimModel) async {
    deletedSingleFloorState(true);
    List<FloorDetail> revFloorsList = await _modelListUseCase.fetchRevisionId(bimModel.revId.toString().plainValue());
    await _modelListCubit.removeFloorsFromLocal(model, revFloorsList, _modelListCubit.projectId);
    if (mapGroupBimList.containsKey(bimModel.ifcName)) {
      mapGroupBimList[bimModel.ifcName]!.removeWhere((element) => element.revId.plainValue() == bimModel.revId.toString().plainValue());
      if (mapGroupBimList[bimModel.ifcName]!.isEmpty) {
        mapGroupBimList.remove(bimModel.ifcName);
      }
    }
    if (mapGroupBimList.isEmpty) {
      _modelListCubit.pageFetch(0, false, false, "", model.projectId!, _modelListCubit.isFavorite ? 0 : 1, true, "aesc", _modelListCubit.searchString);
    }

    double floorSize = await _modelListUseCase.floorSizeByModelId(model.modelId.plainValue());
    if (floorSize > 0) {
      model.fileSize = floorSize.toString();
      model.isDownload = true;
      ModelListDao().insert([model]);
    } else {
      model.fileSize = "";
      model.isDownload = false;
      ModelListDao().insert([model]);
    }

    mapGroupBimList.keys.forEach((titleKey) {
      mapGroupBimList[titleKey]!.forEach((bimModel) {
        bimModel.isChecked = false;
        bimModel.floorList.forEach((floor) {
          floor.isChecked = false;
        });
      });
    });

    _modelListCubit.selectedFloorList.clear();

    deletedSingleFloorState(false);
    _modelListCubit.emitDeleteModelListState();
  }

  Future<void> bimModelDownload(BimModel bimModel) async {
    List<FloorDetail> floors = await _modelListUseCase.fetchRevisionId(bimModel.revId.plainValue());
    if (floors.isNotEmpty) {
      bimModel.isDownloaded = true;
    }
  }

 Future<List<FloorDetail>> getFloorByRevId(plainValue) async {
    List<FloorDetail> floors = await _modelListUseCase.fetchRevisionId(plainValue);
    return floors;
  }
}
