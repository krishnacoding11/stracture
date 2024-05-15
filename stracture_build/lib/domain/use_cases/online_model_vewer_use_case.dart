

import 'package:field/domain/repository/online_model_viewer_repository_impl.dart';

class OnlineModelViewerUseCase {
  final OnlineModelViewerRepositoryImpl _onlineModelViewerRepositoryImpl = OnlineModelViewerRepositoryImpl();

  Future<dynamic> getCalibrationList(String projectId, String modelId) async {
    return await _onlineModelViewerRepositoryImpl.getCalibrationList(projectId,modelId);
  }

 Future<dynamic> getLocalCalibrationList( String modelId) async {
    return await _onlineModelViewerRepositoryImpl.getLocalCalibrationList(modelId);
  }

  Future<dynamic> getColor(String projectId, String modelId) async {
    return await _onlineModelViewerRepositoryImpl.getColor(projectId,modelId);
  }

  Future<dynamic> saveColor(Map<String, dynamic> request,String projectId) async {
    return await _onlineModelViewerRepositoryImpl.saveColor(request,projectId);
  }

  Future<dynamic> setParallelViewAuditTrail(
      Map<String, dynamic> request, String projectId) async {
    return await _onlineModelViewerRepositoryImpl.parallelViewAuditTrail(request, projectId);
  }

  Future<dynamic> getLocationCalibrationList( String modelId) async {
    return await _onlineModelViewerRepositoryImpl.getLocalCalibrationList(modelId);
  }

  Future<dynamic> getFileAssociationList(Map<String, dynamic> request) async {
    return await _onlineModelViewerRepositoryImpl.getFileAssociation(request);
  }

  Future<dynamic> getThreeDAppTypeList(Map<String, dynamic> request) async {
    return await _onlineModelViewerRepositoryImpl.getThreeDAppTypeList(request);
  }
}
