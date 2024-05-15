import 'dart:convert';
import 'dart:developer';

import 'package:field/data/model/floor_details.dart';
import 'package:field/data/model/offline_folder_list.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/network_info.dart';

import '../../../bloc/model_list/model_list_cubit.dart';
import '../../../data/model/bim_project_model_vo.dart';
import '../../../data/model/calibrated.dart';
import '../../../data/model/model_vo.dart';
import '../../../data_source/model_list_data_source/model_list_data_source.dart';
import '../../../data_source/model_list_data_source/model_list_local_data_source_impl.dart';
import '../../../data_source/model_list_data_source/model_list_remote_data_source_impl.dart';
import '../../../logger/logger.dart';
import '../../../networking/internet_cubit.dart';
import '../../../networking/network_request.dart';
import '../../../networking/network_response.dart';
import '../../../networking/network_service.dart';
import '../../../networking/request_body.dart';
import '../../../utils/constants.dart';

class ModelListRepositoryImpl {
  ModelListDataSource? _modelListDataSource;

  Future<ModelListDataSource?> getInstance() async {
    if (isNetWorkConnected()) {
      _modelListDataSource = getIt<ModelListRemoteDataSourceImpl>();
      return _modelListDataSource;
    } else {
      _modelListDataSource = getIt<ModelListLocalDataSourceImpl>();
      return _modelListDataSource;
    }
  }

  Future<dynamic> fetchModelList(Map<String, dynamic> request, String projectId) async {
    await getInstance();
    return await _modelListDataSource!.fetchModeList(request, projectId);
  }

  Future<dynamic> getProjectFromProjectDetailsTable(String projectId, bool isSetOffline) async {
    await getInstance();
    return await _modelListDataSource!.getProjectFromProjectDetailsTable(projectId, isSetOffline);
  }
  Future<dynamic> updateProject(Project project) async {
    await getInstance();
    return await _modelListDataSource!.updateProject(project);
  }

  Future<dynamic> getProjectNameFromProjectDetailsTable(String projectId, bool isSetOffline) async {
    await getInstance();
    return await _modelListDataSource!.getProjectNameProjectDetailsTable(projectId, isSetOffline);
  }

  Future<dynamic> insertAuditTrail(Map<String, dynamic> request, String projectId) async {
    await getInstance();
    return await _modelListDataSource!.setParallelViewAuditTrail(request, projectId);
  }

  Future<dynamic> getChoppedFilesStatus(Map<String, dynamic> request) async {
    //Instantiate a service and keep it in your DI container:
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      headerType: HeaderType.APPLICATION_JSON,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getChoppedFileStatus,
        data: NetworkRequestBody.json(request),
        // headers: csrfHeader
      ),
    ).execute(choppedStatus);

    return result;
  }

  List<dynamic> choppedStatus(dynamic response) {

    return response;
  }

  Future<dynamic> addModelFav(Map<String, dynamic> request, String projectId) async {
    //Instantiate a service and keep it in your DI container:
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getModels,
        data: NetworkRequestBody.json(request),
        // headers: csrfHeader
      ),
    ).execute(parseFavProjectJson);
    if (result is SUCCESS) {
      return result;
    } else {}
    return result;
  }

  Future<List<Model>> getFilteredList(Map<String, dynamic> request, String projectId, String searchValue) async {
    await getInstance();
    return await _modelListDataSource!.getFilteredModelList(request, projectId, searchValue);
  }

  //For New API
  List<Model> modelListFromJson(dynamic response) {
    var projectList = List<Model>.from(response.map((x) => Model.fromJson(x)));
    List<Model> outputList = projectList.toList();
    return outputList;
  }

  String parseFavProjectJson(dynamic data) {
    String success = data.toString();
    return success;
  }

  Future<dynamic> processChoppedFile(Map<String, dynamic> request) async {
    //Instantiate a service and keep it in your DI container:
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      headerType: HeaderType.APPLICATION_JSON,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.processChoppedFiles,
        data: NetworkRequestBody.json(request),
        // headers: csrfHeader
      ),
    ).execute(choppedFile);

    return result;
  }

  Future<dynamic> sendModelRequestForOffline(Map<String, dynamic> request) async {
    bool isSuccess = false;
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.sendModelRequestForOffline,
        data: NetworkRequestBody.json(request),
      ),
    ).execute(processResponse);
    if (result.responseCode == 200) {
      isSuccess = true;
    }
    return isSuccess;
  }

  Future<List<FloorData>> getFloorList(Map<String, dynamic> request) async {
    await getInstance();
    return await _modelListDataSource!.getFloorList(request);
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
    await getInstance();
    return await _modelListDataSource!.syncWithDB(
      floodDBList,
      calibrationList,
      modelListCubit,
      downloadedScsFiles,
      downloadedFiles,
      groupBimList,
      selectedBimModelData,
      floorSize,
    );
  }

  Future<List<String>> getDownloadedModelsPath(String projectId, String modelId, String revisionId, List<String> downloadedScsFiles) async {
    await getInstance();
    return await _modelListDataSource!.getDownloadedModelsPath(projectId, modelId, revisionId, downloadedScsFiles);
  }

  Future<List<String>> getDownloadedPdfFile(String projectId, List<String> downloadedScsFiles) async {
    await getInstance();
    return await _modelListDataSource!.getDownloadedPdfFile(projectId, downloadedScsFiles);
  }

  choppedFile(dynamic response) async {
    return response;
  }

  Future<List<WorkspaceList>> checkNManage(dynamic response) async {
    OfflineFolderList offlineFolderList = OfflineFolderList.fromJson(
      json.decode(
        response,
      ),
    );
    return offlineFolderList.responseData.first.workspaceList ?? [];
  }

  Future<List<FloorDetail>> fetchRevisionId(String revId) async {
    await getInstance();
    return await _modelListDataSource!.fetchRevisionId(revId);
  }

  Future<List<FloorDetail>> fetchAllFloors(String projectId) async {
    await getInstance();
    return await _modelListDataSource!.fetchAllFloors(projectId);
  }


  Future<List<FloorDetail>> fetchFloorsByModelId(String modelId) async {
    await getInstance();
    return await _modelListDataSource!.fetchFloorsByModelId(modelId);
  }

  Future<double> floorSizeByModelId(String plainModelId) async {
    await getInstance();
    return await _modelListDataSource!.floorSizeByModelId(plainModelId);
  }

  Future<List<CalibrationDetails>> fetchCalibrateByModel(String modelId) async {
    await getInstance();
    return await _modelListDataSource!.fetchCalibrateByModel(modelId);
  }

  Future<List<CalibrationDetails>> fetchAllCalibrates(String projectId) async {
    await getInstance();
    return await _modelListDataSource!.fetchAllCalibrates(projectId);
  }



  String processResponse(dynamic response) {
    return response?.toString() ?? "";
  }
}
