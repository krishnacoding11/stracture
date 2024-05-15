import 'package:field/data/remote/quality/quality_plan_listing_repository_impl.dart';
import 'package:field/injection_container.dart' as di;

import '../../../networking/network_response.dart';

class QualityPlanListingUseCase {
  final QualityPlanListingRemoteRepository _qualityPlanListingRemoteRepository = di.getIt<QualityPlanListingRemoteRepository>();

  Future<Result?> getQualityPlanListingFromServer(Map<String, dynamic> request) async {
    return await _qualityPlanListingRemoteRepository.getQualityPlanListingFromServer(request);
  }

  Future<Result?> getQualityPlanSearch(Map<String, dynamic> request) async {
    return await _qualityPlanListingRemoteRepository.getQualityPlanSearchFromServer(request);
  }

  Future<Result?> getQualityPlanLocationListingFromServer(Map<String, dynamic> request) async {
    return await _qualityPlanListingRemoteRepository.getQualityPlanLocationListingFromServer(request);
  }

  Future<Result?> getQualityPlanBreadcrumbFromServer(Map<String, dynamic> request) async {
    return await _qualityPlanListingRemoteRepository.getQualityPlanBreadcrumbFromServer(request);
  }

  Future<Result> getActivityListingFromServer(Map<String, dynamic> request) async {
    return await _qualityPlanListingRemoteRepository.getActivityListingFromServer(request);
  }

  Future<Result?> clearActivityData(Map<String, dynamic> request) async {
    return await _qualityPlanListingRemoteRepository.clearActivityData(request);
  }

  Future<Result> getUserPrivilegeByProjectId(Map<String, dynamic> request) async {
    return await _qualityPlanListingRemoteRepository.getUserPrivilegeByProjectId(request);
  }
}
