import 'package:field/data/dao/calibration_list_dao.dart';
import 'package:field/data/dao/model_bim_models_dao.dart';
import 'package:field/data/model/bim_model_calibration_vo.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/data/model/model_bim_model_vo.dart';

import '../../utils/extensions.dart';
import '../model/bim_project_model_vo.dart';
import '../model/floor_bim_model_vo.dart';
import '../model/model_vo.dart';
import 'bim_model_calibration_dao.dart';
import 'bim_model_list_dao.dart';
import 'floor_bim_model_dao.dart';
import 'floor_list_dao.dart';
import 'model_list_dao.dart';

class ModelDBInsert {
  List<BimModel> ifcObject;
  List<CalibrationDetails> calibrate;
  List<FloorDetail> selectedFloors;
  Model model;

  ModelDBInsert({
    required this.ifcObject,
    required this.calibrate,
    required this.selectedFloors,
    required this.model,
  });

  Future<void> execute() async {
    await _executeModelListDao([model]);
    await _executeBimModelListDao(ifcObject);
    await _modelBimModelListDao(model, ifcObject);
    if (selectedFloors.isNotEmpty) await _executeFloorListDao(selectedFloors);
    if (calibrate.isNotEmpty) await _executeCalibrateListDao(calibrate);
  }

  final FloorListDao _floorListDao = FloorListDao();
  final ModelListDao _modelListDao = ModelListDao();
  final BimModelListDao _bimModelListDao = BimModelListDao();
  final CalibrationListDao _calibrationListDao = CalibrationListDao();
  final FloorBimModelDao _floorBimModelDao = FloorBimModelDao();

  Future<void> _executeModelListDao(List<Model> modelList) async {
    List<Model> localModelList = await _modelListDao.fetch();
    for (int i = 0; i < localModelList.length; i++) {
      for (int ii = 0; ii < modelList.length; ii++) {
        if (localModelList[i].bimModelId.plainValue() == modelList[ii].bimModelId.plainValue()) {
          modelList.removeAt(ii);
        }
      }
    }
    await _modelListDao.insert(modelList);
  }

  Future<void> _executeBimModelListDao(List<BimModel> bimModelList) async {
    await _bimModelListDao.insert(bimModelList);
  }

  Future<void> _modelBimModelListDao(Model model, List<BimModel> bimModelList) async {
    List<ModelBimModel> modelBimModelList = [];
    ModelBimModelDao dao = ModelBimModelDao();

    List<ModelBimModel> localModelBimModelList = await dao.fetch();

    for (var bimModelModel in bimModelList) {
      var index = localModelBimModelList.indexWhere((element) => element.modelId == model.bimModelId.plainValue() && element.bimModelId == bimModelModel.revId.plainValue());
      if (index == -1) {
        modelBimModelList.add(ModelBimModel(modelId: model.bimModelId.plainValue(), bimModelId: bimModelModel.revId.plainValue()));
      }
    }

    await dao.insert(modelBimModelList);
  }

  Future<void> _executeFloorListDao(List<FloorDetail> floors) async {
    List<FloorDetail> localFloorList = await _floorListDao.fetchAll(model.projectId.plainValue());

    for (int i = 0; i < localFloorList.length; i++) {
      for (int ii = 0; ii < floors.length; ii++) {
        if (floors[ii].fileName == localFloorList[i].fileName) {
          floors.removeAt(ii);
        }
      }
    }

    await _floorListDao.insert(floors);
    await _executeFloorBimModelDao(floors);
  }

  Future<void> _executeCalibrateListDao(List<CalibrationDetails> calibrate) async {
    List<CalibrationDetails> localCalibratedList = await _calibrationListDao.fetchAll(model.projectId.plainValue());

    for (int i = 0; i < localCalibratedList.length; i++) {
      for (int ii = 0; ii < calibrate.length; ii++) {
        if (localCalibratedList[i].calibrationId.plainValue() == calibrate[ii].calibrationId.plainValue()) {
          calibrate.removeAt(ii);
        }
      }
    }
    await _calibrationListDao.insert(calibrate);
    await _calibrateBimModelDao(calibrate);
  }

  Future<void> _executeFloorBimModelDao(List<FloorDetail> floorsList) async {
    List<FloorBimModel> floorBimModelList = [];

    List<FloorBimModel> localFloorBimModelList = await _floorBimModelDao.fetch();

    for (var floor in floorsList) {
      var index = localFloorBimModelList.indexWhere((element) => element.floorId == floor.floorNumber.toString() && element.bimModelId == floor.revisionId.toString());

      if (index == -1) {
        floorBimModelList.add(
          FloorBimModel(
            floorId: floor.floorNumber.toString(),
            bimModelId: floor.revisionId.toString(),
          ),
        );
      }
    }
    await _floorBimModelDao.insert(floorBimModelList);
  }

  Future<void> _calibrateBimModelDao(List<CalibrationDetails> calibrateFile) async {
    List<BimModelCalibrationModel> calibrateBimModeList = [];
    BimModelCalibrationModelDao dao = BimModelCalibrationModelDao();
    List<BimModelCalibrationModel> localCalibrateBimModeList = await dao.fetch();
    for (var calibrate in calibrateFile) {
      var index = localCalibrateBimModeList.indexWhere((element) => element.calibrationId == calibrate.calibrationId.plainValue() && element.bimModelId == calibrate.revisionId.plainValue());
      if (index == -1) {
        calibrateBimModeList.add(BimModelCalibrationModel(
          bimModelId: calibrate.revisionId.plainValue(),
          calibrationId: calibrate.calibrationId.plainValue(),
        ));
      }
    }
    await dao.insert(calibrateBimModeList);
  }

  updateFloor(FloorDetail floorList) async {
    await _floorListDao.updateIsDownloaded(floorList);
  }

  updateCalibrate(CalibrationDetails calibrate) async {
    await _calibrationListDao.updateIsDownloaded(calibrate);
  }

  static updateModel(Model modelList) async {
    await ModelListDao().updateFileSize(modelList);
  }

  static updateSize({
    required Model selectedModel,
    required List<FloorDetail> selectedFloors,
    required List<CalibrationDetails> selectedCalib,
    required List<FloorDetail> removedFloors,
    required List<CalibrationDetails> removedCali,
  }) async {
    var list = await ModelListDao().fetchSingleModel(modelId: selectedModel.modelId.plainValue());
    Model modelList = list.first;

    double removedFilesSize = 0.0;
    double addFilesSize = 0.0;

    if (removedFloors.isNotEmpty) {
      for (var value in removedFloors) {
        removedFilesSize += double.parse(value.fileSize?.toString() ?? "0.0");
      }
    }

    if (selectedFloors.isNotEmpty) {
      for (var value in selectedFloors) {
        addFilesSize += double.parse(value.fileSize?.toString() ?? "0.0");
      }
    }

    if (removedCali.isNotEmpty) {
      for (var value in removedCali) {
        double fileSize = double.parse(value.sizeOf2DFile.toString()) / 1024;
        removedFilesSize += fileSize;
      }
    }

    if (selectedCalib.isNotEmpty) {
      for (var value in selectedCalib) {
        double fileSize = double.parse(value.sizeOf2DFile.toString()) / 1024;
        addFilesSize += fileSize;
      }
    }
    double modelSize = double.parse(modelList.fileSize?.toString() ?? "0");

    modelSize = modelSize + addFilesSize;
    modelSize = modelSize - removedFilesSize;
    modelList.fileSize = modelSize.toString();

    await ModelListDao().updateFileSize(modelList);
  }

  static Future<Model?> checkModelIsDownloaded(Model model) async {
    final ModelListDao _modelListDao = ModelListDao();
    var list = await _modelListDao.fetchSingleModel(modelId: model.modelId.plainValue());
    if (list.isEmpty) {
      return null;
    } else {
      return list.first;
    }
  }
}
