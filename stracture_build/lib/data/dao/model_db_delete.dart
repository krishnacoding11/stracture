import 'package:field/data/dao/model_bim_models_dao.dart';
import 'package:field/utils/extensions.dart';

import '../model/bim_project_model_vo.dart';
import '../model/model_vo.dart';
import 'bim_model_list_dao.dart';
import 'calibration_list_dao.dart';
import 'floor_bim_model_dao.dart';
import 'floor_list_dao.dart';
import 'model_list_dao.dart';

class ModelDbDelete {
  static final FloorListDao _floorListDao = FloorListDao();
  static final ModelListDao _modelListDao = ModelListDao();
  static final BimModelListDao _bimModelListDao = BimModelListDao();
  static final ModelBimModelDao _modelBimModelDao = ModelBimModelDao();
  static final CalibrationListDao _calibrationListDao = CalibrationListDao();
  static final FloorBimModelDao _floorBimModelDao = FloorBimModelDao();

  static clearModel(Model model) async {
    List<BimModel> bimModel = await _bimModelListDao.fetch(model.modelId.plainValue());

    bimModel.forEach((element) async {
    await  _floorBimModelDao.delete(element.revId.plainValue());
    });

    await _floorListDao.deleteModelWise(model.modelId.plainValue());
   await _calibrationListDao.deleteModelWise(model.modelId.plainValue());
   await _modelBimModelDao.delete(model.modelId.plainValue());
   await _bimModelListDao.delete(model.modelId.plainValue());
   await _modelListDao.delete(model.modelId.toString());
  }

  static clearProject() async {
    await _floorListDao.deleteAllQuery();
    await _modelListDao.deleteAllQuery();
    await _bimModelListDao.deleteAllQuery();
    await _modelBimModelDao.deleteAllQuery();
    await _calibrationListDao.deleteAllQuery();
    await _floorBimModelDao.deleteAllQuery();
  }
}
