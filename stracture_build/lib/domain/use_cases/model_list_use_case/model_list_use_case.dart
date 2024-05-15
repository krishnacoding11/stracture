import 'package:field/data/model/model_vo.dart';
import 'package:field/data/model/project_vo.dart';

import '../../../bloc/model_list/model_list_cubit.dart';
import '../../../data/model/bim_project_model_vo.dart';
import '../../../data/model/calibrated.dart';
import '../../../data/model/floor_details.dart';
import '../../repository/model_list_repository/model_list_repository_impl.dart';

class ModelListUseCase {
  final ModelListRepositoryImpl _modelListRepositoryImpl = ModelListRepositoryImpl();

  Future<List<Model>> getModelListFromServer(Map<String, dynamic> request, String projectId) async {
    return await _modelListRepositoryImpl.fetchModelList(request, projectId);
  }

  Future<dynamic> getProjectFromProjectDetailsTable(String projectId, bool isSetOffline) async {
    return await _modelListRepositoryImpl.getProjectFromProjectDetailsTable(projectId, isSetOffline);
  }
  Future<dynamic> updateProject(Project project) async {
    return await _modelListRepositoryImpl.updateProject(project);
  }


  Future<dynamic> getProjectNameFromProjectDetailsTable(String projectId, bool isSetOffline) async {
    return await _modelListRepositoryImpl.getProjectNameFromProjectDetailsTable(projectId, isSetOffline);
  }

  Future<dynamic> getChoppedStatus(Map<String, dynamic> request) async {
    return await _modelListRepositoryImpl.getChoppedFilesStatus(request);
  }

  Future<dynamic> sendModelRequestForOffline(Map<String, dynamic> request) async {
    return await _modelListRepositoryImpl.sendModelRequestForOffline(request);
  }

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
    return await _modelListRepositoryImpl.syncWithDB(floodDBList, calibrationList, modelListCubit, downloadedScsFiles, downloadedFiles, groupBimList, selectedBimModelData, floorSize);
  }

  Future<dynamic> getDownloadedModelsPath(String projectId, String modelId, String revisionId, List<String> downloadedScsFiles) async {
    return await _modelListRepositoryImpl.getDownloadedModelsPath(projectId, modelId, revisionId, downloadedScsFiles);
  }

  Future<dynamic> getDownloadedPdfFile(String projectId, List<String> downloadedScsFiles) async {
    return await _modelListRepositoryImpl.getDownloadedPdfFile(projectId, downloadedScsFiles);
  }

  Future<dynamic> processChoppedFile(Map<String, dynamic> request) async {
    return await _modelListRepositoryImpl.processChoppedFile(request);
  }

  Future<dynamic> addModelAsFav(Map<String, dynamic> request, String projectId) async {
    return await _modelListRepositoryImpl.addModelFav(request, projectId);
  }

  Future<dynamic> setParallelViewAuditTrail(Map<String, dynamic> request, String projectId) async {
    return await _modelListRepositoryImpl.insertAuditTrail(request, projectId);
  }

  Future<List<Model>> getFilteredList(Map<String, dynamic> request, String projectId, String searchValue) async {
    return await _modelListRepositoryImpl.getFilteredList(request, projectId, searchValue);
  }

  Future<dynamic> getFloorList(Map<String, dynamic> request) async {
    return await _modelListRepositoryImpl.getFloorList(
      request,
    );
  }

  Future<List<FloorDetail>> fetchRevisionId(String revId) async {
    return await _modelListRepositoryImpl.fetchRevisionId(revId);
  }

  Future<List<FloorDetail>> fetchAllFloors(String project) async {
    return await _modelListRepositoryImpl.fetchAllFloors(project);
  }

  Future<List<FloorDetail>> fetchFloorsByModelId(String modelId) async {
    return await _modelListRepositoryImpl.fetchFloorsByModelId(modelId);
  }

  Future<List<CalibrationDetails>> fetchCalibrateByModel(String modelId) async {
    return await _modelListRepositoryImpl.fetchCalibrateByModel(modelId);
  }

  Future<List<CalibrationDetails>> fetchAllCalibrates(String projectId) async {
    return await _modelListRepositoryImpl.fetchAllCalibrates(projectId);
  }

  Future<double> floorSizeByModelId(String plainModelId) async {
    return await _modelListRepositoryImpl.floorSizeByModelId(plainModelId);
  }
}
