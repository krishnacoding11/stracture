import 'package:field/data/dao/model_bim_models_dao.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/data/model/model_bim_model_vo.dart';
import 'package:field/utils/extensions.dart';

import '../../domain/use_cases/model_list_use_case/model_list_use_case.dart';
import '../../injection_container.dart';
import 'calibration_list_dao.dart';
import 'floor_list_dao.dart';

class ModelDbFetch {
  static final FloorListDao _floorListDao = FloorListDao();
  static final CalibrationListDao _calibrationListDao = CalibrationListDao();
  static final ModelBimModelDao _modelBimModelDao = ModelBimModelDao();

  static Future<List<FloorDetail>> fetchFloors(String plainModelId) async {
    List<String> bimModelIds = [];
    List<ModelBimModel> mBmList = await _modelBimModelDao.fetch(modelId: plainModelId);
    for (var modelBimModel in mBmList) {
      bimModelIds.add(modelBimModel.bimModelId.plainValue());
    }
    List<FloorDetail> tempList = await _floorListDao.fetchByBimModelIds(bimModelIds);
    return tempList;
  }

  static Future<List<FloorDetail>> fetchFloorsByRevId(String plainRevId) async {
    List<FloorDetail> tempList = await getIt<ModelListUseCase>().fetchRevisionId(plainRevId);
    return tempList;
  }

  static Future<List<CalibrationDetails>> fetchCalibratedFiles(String plainModelId) async {
    List<CalibrationDetails> tempList = await _calibrationListDao.fetchModelWise(plainModelId);
    return tempList;
  }
}
