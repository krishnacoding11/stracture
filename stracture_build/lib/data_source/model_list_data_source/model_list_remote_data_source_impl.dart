import 'dart:io';

import 'package:field/data/dao/calibration_list_dao.dart';
import 'package:field/data/dao/model_bim_models_dao.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';

import '../../bloc/model_list/model_list_cubit.dart';
import '../../data/dao/floor_list_dao.dart';
import '../../data/dao/model_db_fetch.dart';
import '../../data/dao/model_db_insert.dart';
import '../../data/dao/project_dao.dart';
import '../../data/model/bim_project_model_vo.dart';
import '../../data/model/calibrated.dart';
import '../../data/model/model_bim_model_vo.dart';
import '../../data/model/model_vo.dart';
import '../../data/model/project_vo.dart';
import '../../database/db_manager.dart';
import '../../networking/network_request.dart';
import '../../networking/network_service.dart';
import '../../networking/request_body.dart';
import '../../utils/app_path_helper.dart';
import 'model_list_data_source.dart';

class ModelListRemoteDataSourceImpl extends ModelListDataSource {
  List<Model>? modelListFromJson(dynamic response) {
    var modelList = List<Model>.from(response.map((x) => Model.fromJson(x)));
    List<Model> outputList = modelList;
    return outputList;
  }

  String parseFavModelJson(dynamic data) {
    String success = data.toString();
    return success;
  }

  @override
  Future<List<Model>> getFilteredModelList(Map<String, dynamic> request, String projectId, String searchValue) async {
    List<Model> allItem = [];
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      headerType: HeaderType.APPLICATION_JSON,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getSearchModelUrl(projectId),
        data: NetworkRequestBody.json(request),
      ),
    ).execute(filteredModelListFromJson);
    allItem = result.data!;
    return allItem;
  }

  List<Model> filteredModelListFromJson(dynamic response) {
    var projectList = List<Model>.from(response.map((x) => Model.fromJson(x)));
    List<Model> outputList = projectList.toList();
    return outputList;
  }

  @override
  Future<List<Model>> fetchModeList(Map<String, dynamic> request, String projectId) async {
    List<Model> list = [];
    Log.d(request);
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      headerType: HeaderType.APPLICATION_JSON,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getSearchModelUrl(projectId),
        data: NetworkRequestBody.json(request),
        // headers: csrfHeader
      ),
    ).execute(modelListFromJson);
    if (result is SUCCESS) {
      for (var item in result.data!) {
        list.add(item);
      }
      return list;
    }

    return list;
  }

  @override
  Future<List<FloorData>> getFloorList(Map<String, dynamic> request) async {
    List<FloorData> _list = [];

    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      headerType: HeaderType.APPLICATION_JSON,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getFloorDetails,
        data: NetworkRequestBody.json(request),
        // headers: csrfHeader
      ),
    ).execute(processFloorData);
    if (result is SUCCESS) {
      _list = await result.data ?? [];
    }

    return _list;
  }

  List<FloorData> processFloorData(dynamic response) {
    if (response is List) {
      return List<FloorData>.from(response.map((x) => FloorData.fromJson(x)));
    }
    return [];
  }

  @override
  Future<dynamic> setParallelViewAuditTrail(Map<String, dynamic> request, String projectId) async {
    var result = await NetworkService(baseUrl: AConstants.adoddleUrl, headerType: HeaderType.APPLICATION_JSON, mNetworkRequest: NetworkRequest(type: NetworkRequestType.POST, path: AConstants.setAuditTrail, data: NetworkRequestBody.json(request))).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<dynamic> syncWithDB(
    List<FloorDetail> floodDBList,
    List<CalibrationDetails> calibrationList,
    ModelListCubit modelListCubit,
    List<String> downloadedScsFiles,
    List<FloorDetail> downloadedFiles,
    List<BimModel> groupBimList,
    BimModel selectedBimModelData,
    double floorSize,
  ) async {
    List<FloorDetail> removedFloors = [];
    List<BimModel> ifcList = [];
    if (downloadedScsFiles.isNotEmpty) {
      ifcList.add(selectedBimModelData);
      ModelDBInsert dbInsert = ModelDBInsert(
        calibrate: calibrationList,
        selectedFloors: downloadedFiles,
        model: modelListCubit.selectedModel!,
        ifcObject: ifcList,
      );
      await dbInsert.execute();
    }

    for (int i = 0; i < floodDBList.length; i++) {
      if (!downloadedScsFiles.toString().contains(floodDBList[i].fileName)) {
        removedFloors.add(floodDBList[i]);
        await FloorListDao().delete(
          floodDBList[i].revisionId.toString(),
          floorNum: floodDBList[i].floorNumber.toString(),
          modelId: modelListCubit.selectedModel!.modelId.plainValue(),
        );
      }
    }
  }

  @override
  Future<List<String>> getDownloadedModelsPath(String projectId, String modelId, String revisionId, List<String> downloadedScsFiles) async {
    String modelsPath = await AppPathHelper().getModelDirectory(
      projectId: projectId,
    );
    List<FileSystemEntity> modelFile = Directory("$modelsPath").listSync();
    String path = await AppPathHelper().getModelRevIdPath(projectId: projectId, modelId: modelId, revisionId: revisionId);

    if (await Directory("$path").exists()) {
      List<FileSystemEntity> file = Directory("$path").listSync();
      for (int i = 0; i < file.length; i++) {
        var actualFile = file[i].path.toString().split("/").last;
        downloadedScsFiles.add(actualFile);
      }
      return downloadedScsFiles;
    } else {
      return downloadedScsFiles;
    }
  }

  @override
  Future getDownloadedPdfFile(String projectId, List<String> downloadedScsFiles) {
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
    String fetchRevisionIdQuery = "SELECT * FROM ${FloorListDao().tableName} WHERE ${FloorListDao.revisionId} = $revId AND ${FloorListDao.isDownloaded} = 1";
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
