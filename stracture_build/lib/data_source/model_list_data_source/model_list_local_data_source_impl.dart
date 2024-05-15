import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/data/dao/calibration_list_dao.dart';
import 'package:field/data/dao/floor_list_dao.dart';
import 'package:field/data/dao/model_list_dao.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/utils/extensions.dart';

import '../../data/dao/model_bim_models_dao.dart';
import '../../data/dao/model_db_fetch.dart';
import '../../data/dao/project_dao.dart';
import '../../data/model/model_bim_model_vo.dart';
import '../../data/model/model_vo.dart';
import '../../data/model/project_vo.dart';
import '../../logger/logger.dart';
import '../../utils/app_path_helper.dart';
import 'model_list_data_source.dart';

class ModelListLocalDataSourceImpl extends ModelListDataSource {
  @override
  Future<List<Model>> getFilteredModelList(Map<String, dynamic> request, String projectId, String searchValue) async {
    List<Model> result = [];
    ModelListDao modelListDao = ModelListDao();
    String query = "SELECT * FROM ${ModelListDao.tableName} WHERE `${ModelListDao.setAsOffline}` = true AND `${ModelListDao.projectId}` = $projectId AND `${ModelListDao.userModelName}` LIKE '%${searchValue.trim()}%' ORDER BY `${ModelListDao.userModelName}` COLLATE NOCASE ASC";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(ModelListDao.tableName, query);
      result = modelListDao.fromList(qurResult);
      return result;
    } on Exception catch (e) {
      Log.d(e);
    }

    return result;
  }

  @override
  Future<List<Model>> fetchModeList(Map<String, dynamic> request, String projectId) async {
    List<Model> result = [];
    ModelListDao modelListDao = ModelListDao();
    String query = "SELECT * FROM ${ModelListDao.tableName} WHERE ${ModelListDao.setAsOffline}=${"true"} AND ${ModelListDao.projectId}=${projectId.plainValue()} ORDER BY ${ModelListDao.userModelName} COLLATE NOCASE ASC";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(ModelListDao.tableName, query);
      result = modelListDao.fromList(qurResult);
      return result;
    } on Exception catch (e) {
      Log.d(e);
    }

    return result;
  }

  @override
  Future<List<FloorData>> getFloorList(Map<String, dynamic> request) async {
    List<FloorData> list = [];
    FloorListDao dao = FloorListDao();
    var floorDetail = await dao.fetch(request["revisionIds"]);

    floorDetail = floorDetail.where((e) => e.isDownloaded == true).toList();
    list = [FloorData(revisionId: 0, floorDetails: floorDetail)];

    return list;
  }

  @override
  Future setParallelViewAuditTrail(Map<String, dynamic> request, String projectId) {
    throw UnimplementedError();
  }

  @override
  Future syncWithDB(
    List<FloorDetail> floodDBList,
    List<CalibrationDetails> calibrationList,
    ModelListCubit modelListCubit,
    List<String> downloadedScsFiles,
    List<FloorDetail> downloadedFiles,
    List<BimModel> groupBimList,
    BimModel selectedBimModelData,
    double floorSize,
  ) async {
    return;
  }

  @override
  Future getDownloadedModelsPath(String projectId, String modelId, String revisionId, List<String> downloadedScsFiles)async {
   return <String>[];
  }

  @override
  Future getDownloadedPdfFile(String projectId, List<String> downloadedScsFiles) {
    // TODO: implement getDownloadedModelsPath
    throw UnimplementedError();
  }

  @override
  Future<String> getProjectFromProjectDetailsTable(String projectId, bool isSetOffline) async {
    ProjectDao projectDao = ProjectDao();
    Project project = await projectDao.fetchProjectId(projectId.plainValue().toString(), isSetOffline);
    String offlineSelectedProjectId = project.projectID != null ? project.projectID! : '';
    return offlineSelectedProjectId;
  }

  @override
  Future<List<FloorDetail>> fetchRevisionId(String revId) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    List<FloorDetail> list = [];
    String fetchRevisionIdQuery = "SELECT * FROM ${FloorListDao().tableName} WHERE ${FloorListDao.revisionId} = $revId";
    try {
      var qurResult = db.executeSelectFromTable(FloorListDao().tableName, fetchRevisionIdQuery);
      list = FloorListDao().fromList(qurResult);
      return list;
    } on Exception catch (e) {
      return list;
    }
  }

  @override
  Future<double> floorSizeByModelId(String plainModelId) async {
    List<FloorDetail> floorsByModelId = await ModelDbFetch.fetchFloors(plainModelId);
    List<CalibrationDetails> calibrationByModelId = await ModelDbFetch.fetchCalibratedFiles(plainModelId);
    double size = floorsByModelId.map((floor) => double.parse(floor.fileSize.toString())).fold(0.0, (sum, floorSize) => sum + floorSize);
    double calibrateSize = calibrationByModelId.map((calib) => double.parse(calib.sizeOf2DFile.toString())).fold(0.0, (sum, calib) => sum + calib);
    return (size + (calibrateSize / 1024));
  }

  @override
  Future<List<FloorDetail>> fetchAllFloors(String projectId) async {
    List<FloorDetail> list = [];
    try {
      list = await FloorListDao().fetchAll(projectId);
      return list;
    } catch (e) {
      return list;
    }
  }

  @override
  Future<List<FloorDetail>> fetchFloorsByModelId(String modelId) async {
    List<String> bimModelIds = [];
    try {
      List<ModelBimModel> mBmList = await ModelBimModelDao().fetch(modelId: modelId.plainValue());
      for (var modelBimModel in mBmList) {
        bimModelIds.add(modelBimModel.bimModelId.plainValue());
      }
      List<FloorDetail> list = await FloorListDao().fetchByBimModelIds(bimModelIds);

      return list;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<CalibrationDetails>> fetchAllCalibrates(String projectId) async {
    List<CalibrationDetails> list = [];
    try {
      list = await CalibrationListDao().fetchAll(projectId);
      return list;
    } catch (e) {
      return list;
    }
  }

  @override
  Future<List<CalibrationDetails>> fetchCalibrateByModel(String modelId) async {
    try {
      List<CalibrationDetails> list = await CalibrationListDao().fetchModelWise(modelId);
      return list;
    } catch (e) {
      return [];
    }
  }

  @override
  Future<String> getProjectNameProjectDetailsTable(String projectId, bool isSetOffline) async{
    ProjectDao projectDao = ProjectDao();
    Project project = await projectDao.fetchProjectId(projectId.plainValue().toString(), isSetOffline);
    String offlineSelectedProjectName = project.projectName ?? '';
    return offlineSelectedProjectName;
  }

  @override
  Future updateProject(Project project) async{
    ProjectDao projectDao = ProjectDao();
    await projectDao.insert([project]);
  }
}
