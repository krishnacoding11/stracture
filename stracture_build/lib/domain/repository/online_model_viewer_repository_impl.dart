import 'package:field/data/dao/calibration_list_dao.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/domain/repository/online_model_viewer_repository.dart';
import 'package:field/utils/extensions.dart';

import '../../networking/network_request.dart';
import '../../networking/network_response.dart';
import '../../networking/network_service.dart';
import '../../networking/request_body.dart';
import '../../utils/constants.dart';

class OnlineModelViewerRepositoryImpl extends OnlineModelViewerRepository {
  @override
  Future<Result> getCalibrationList(String projectId, String modelId) async {
    var result = await NetworkService(baseUrl: AConstants.adoddleUrl, headerType: HeaderType.APPLICATION_JSON, mNetworkRequest: NetworkRequest(type: NetworkRequestType.GET, path: AConstants.getCalibrationList(projectId, modelId), data: const NetworkRequestBody.empty())).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<dynamic> getLocalCalibrationList(String modelId) async {
    List<CalibrationDetails> calibrationList = [];
    CalibrationListDao dao = CalibrationListDao();
    calibrationList = await dao.fetch(modelId: modelId.plainValue());
    return calibrationList;
  }

  @override
  Future<Result> parallelViewAuditTrail(Map<String, dynamic> request, String projectId) async {
    var result = await NetworkService(baseUrl: AConstants.adoddleUrl, headerType: HeaderType.APPLICATION_JSON, mNetworkRequest: NetworkRequest(type: NetworkRequestType.POST, path: AConstants.setAuditTrail, data: NetworkRequestBody.json(request))).execute((response) {
      return response;
    });
    return result;
  }

  String processResponse(dynamic response) {
    return response?.toString() ?? "";
  }

  @override
  Future<Result> saveColor(Map<String, dynamic> request, String projectId) async {
    var result = await NetworkService(baseUrl: AConstants.adoddleUrl, headerType: HeaderType.APPLICATION_FORM_URL_ENCODE, mNetworkRequest: NetworkRequest(type: NetworkRequestType.POST, path: AConstants.saveColor, data: NetworkRequestBody.json(request))).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result> getColor(String projectId, String modelId) async {
    var result = await NetworkService(baseUrl: AConstants.adoddleUrl, headerType: HeaderType.APPLICATION_JSON, mNetworkRequest: NetworkRequest(type: NetworkRequestType.GET, path: AConstants.getColor(projectId, modelId), data: const NetworkRequestBody.empty())).execute((response) {
      return response;
    });

    return result;
  }

  @override
  Future<Result> getFileAssociation(Map<String, dynamic> request) async {
    var result = await NetworkService(baseUrl: AConstants.adoddleUrl, headerType: HeaderType.APPLICATION_FORM_URL_ENCODE, mNetworkRequest: NetworkRequest(type: NetworkRequestType.POST, path: AConstants.getFileAssociationByObjectId, data: NetworkRequestBody.json(request))).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result> getThreeDAppTypeList(Map<String, dynamic> request) async {
    var result = await NetworkService(baseUrl: AConstants.adoddleUrl, headerType: HeaderType.APPLICATION_FORM_URL_ENCODE, mNetworkRequest: NetworkRequest(type: NetworkRequestType.POST, path: AConstants.getThreeDAppTypeList, data: NetworkRequestBody.json(request))).execute((response) {
      return response;
    });
    return result;
  }
}
