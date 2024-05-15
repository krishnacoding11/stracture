import 'package:dio/dio.dart';
import 'package:field/data/model/quality_plan_location_listing_vo.dart';
import 'package:field/data/model/updated_activity_list_vo.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/networking/network_service.dart';
import 'package:field/networking/request_body.dart';
import 'package:field/utils/constants.dart';

import '../../model/quality_activity_list_vo.dart';
import '../../model/quality_location_breadcrumb.dart';
import '../../model/quality_plan_list_vo.dart';
import '../../model/quality_search_vo.dart';

class QualityPlanListingRemoteRepository {
  QualityPlanListingRemoteRepository();

  Future<Result> getQualityPlanListingFromServer(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.adoddleSiteListing,
        data: NetworkRequestBody.json(request),
      ),
    ).execute(QualityPlanListVo.parseJson);
    return result;
  }

  Future<Result?> getQualityPlanSearchFromServer(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getQualitySearchData,
        data: NetworkRequestBody.json(request),
      ),
    ).execute(QualitySearchVo.fromJson);
    return result;
  }

  List<QualitySearchVo>? popupDataListFromJson(dynamic response) {
    dynamic data = response["data"];
    var qualityList = List<QualitySearchVo>.from(data.map((x) => QualitySearchVo.fromJson(x)));
    return qualityList;
  }

  Future<Result> getQualityPlanLocationListingFromServer(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.qualityPlanLocationListing,
        data: NetworkRequestBody.json(request),
      ),
    ).execute(QualityPlanLocationListingVo.fromJson);
    return result;
  }

  Future<Result?>? getQualityPlanBreadcrumbFromServer(Map<String, dynamic> request) async {
    String finalURL = AConstants.getQualityPlanBreadCrumb;
    String tempUrl = "";
    request.forEach((key, value) {
      if (tempUrl.isNotEmpty) {
        tempUrl = '$tempUrl&';
      }
      tempUrl = '$tempUrl$key=$value';
    });
    finalURL = "$finalURL?$tempUrl";
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.GET,
        path: finalURL,
        data: const NetworkRequestBody.empty(),
      ),
      responseType: ResponseType.plain,
    ).execute(QualityLocationBreadcrumb.fromJson);
    return result;
  }

  Future<Result> getActivityListingFromServer(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getActivityByPlanIdURL,
        data: NetworkRequestBody.json(request),
      ),
    ).execute(QualityActivityList.fromJson);
    return result;
  }

  Future<Result> clearActivityData(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.manageQAEntityData,
        data: NetworkRequestBody.json(request),
      ),
    ).execute(UpdatedActivityListVo.fromJson);
    return result;
  }

  Future<Result> getUserPrivilegeByProjectId(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.dashboardUrl,
        data: NetworkRequestBody.json(request),
      ),
    ).execute((response) {
      return response;
    });
    return result;
  }
}
