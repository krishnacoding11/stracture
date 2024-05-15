import 'dart:async';

import '../../../networking/network_response.dart';

abstract class OnlineModelViewerRepository {
  Future<Result> getCalibrationList(String projectId,String modelId);
  Future<dynamic> getLocalCalibrationList(String modelId);
  Future<Result> parallelViewAuditTrail(Map<String, dynamic> request, String projectId);
  Future<Result> saveColor(Map<String, dynamic> request, String projectId);
  Future<Result> getColor(String projectId,String modelId);
  Future<Result> getFileAssociation(Map<String, dynamic> request);
  Future<Result> getThreeDAppTypeList(Map<String, dynamic> request);
}
