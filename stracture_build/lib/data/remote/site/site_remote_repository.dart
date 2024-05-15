import 'package:dio/dio.dart';
import 'package:field/data/model/pinsdata_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/data/repository/site/site_repository.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/download_service.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';
import 'package:field/utils/utils.dart';

import '../../../networking/network_request.dart';
import '../../../networking/network_service.dart';
import '../../../networking/request_body.dart';
import '../../../utils/constants.dart';
import '../../model/search_location_list_vo.dart';
import '../../repository/site/location_tree_repository.dart';

class SiteRemoteRepository extends SiteRepository with LocationTreeRepository {

  @override
  Future<DownloadResponse> downloadPdf(Map<String, dynamic> request,
      {DownloadProgressCallback? onReceiveProgress,
        bool checkFileExist = true, Dio? dio}) async {
    return DownloadPdfFile().downloadPdf(request,
        onReceiveProgress: onReceiveProgress, checkFileExist: checkFileExist,dio:dio);
  }

  @override
  Future<DownloadResponse> downloadXfdf(Map<String, dynamic> request,
      {DownloadProgressCallback? onReceiveProgress,
        bool checkFileExist = false, Dio? dio}) async {
    return DownloadXfdfFile().downloadXfdf(request,
        onReceiveProgress: onReceiveProgress, checkFileExist: checkFileExist, dio:dio);
  }

  @override
  Future<Result> getLocationTree(Map<String, dynamic> request,[dioInstance]) async {
    var result = await NetworkService(
        dioClient: dioInstance,
        baseUrl: AConstants.adoddleUrl,
        mNetworkRequest: NetworkRequest(
            type: NetworkRequestType.POST,
            path: AConstants.locationTreeUrl,
            data: NetworkRequestBody.json(request)))
        .execute(SiteLocation.jsonToList);
    if(result.data != null) {
      result.data = await addLocalSyncDataToSiteLocations(request,result.data as List<SiteLocation>);
    }
    return result;
  }
  Future<List<SiteLocation>>? addLocalSyncDataToSiteLocations(Map<String, dynamic> request,List<SiteLocation> locationList)async {
    List<Map<String,dynamic>> syncStatusDataList = await getSyncStatusDataByLocationId(request);
    if(syncStatusDataList.isNotEmpty) {
      for (SiteLocation location in locationList) {
        var syncStatusData = syncStatusDataList.firstWhere((element) => element['ProjectId'] == location.projectId?.toString().plainValue() && element['LocationId'].toString() == location.pfLocationTreeDetail?.locationId?.toString(),
        orElse: () => {});
        if (syncStatusData.isNotEmpty) {
          location.lastSyncTimeStamp = syncStatusData["LastSyncTimeStamp"].toString();
          location.syncStatus = ESyncStatus.fromString((syncStatusData["SyncStatus"] ?? ESyncStatus.failed.value).toString());
          location.canRemoveOffline = syncStatusData["CanRemoveOffline"] == 1 ? true : false;
          location.isMarkOffline = syncStatusData["IsMarkOffline"] == 1 ? true : false;
          if (location.syncStatus == ESyncStatus.inProgress) {
            location.progress = double.tryParse(syncStatusData["SyncProgress"]?.toString() ?? "0.0");
          }
        }
      }
    }
    return locationList;
  }
  Future<List<Map<String,dynamic>>> getSyncStatusDataByLocationId(Map<String, dynamic> request) async {
    return await siteLocationLocalDatasource.getSyncStatusDataByLocationId(request);
  }
  @override
  Future<SiteLocation?> getLocationTreeByAnnotationId(Map<String, dynamic> request,[dioInstance]) async {
    var result = await NetworkService(
        dioClient: dioInstance,
        baseUrl: AConstants.adoddleUrl,
        mNetworkRequest: NetworkRequest(
            type: NetworkRequestType.POST,
            path: AConstants.locationTreeByAnnotationIdUrl,
            data: NetworkRequestBody.json(request)))
        .execute(SiteLocation.fromJson);
    if (result is SUCCESS) {
      return result.data;
    }
    return null;
  }

  @override
  Future<List<SiteLocation>?> getLocationDetailsByLocationIds(
      Map<String, dynamic> request) async {
    var result = await NetworkService(
            baseUrl: AConstants.adoddleUrl,
            mNetworkRequest: NetworkRequest(
                type: NetworkRequestType.POST,
                path: AConstants.locationDetailsByLocationIds,
                data: NetworkRequestBody.json(request)))
        .execute(SiteLocation.jsonListToLocationList);
    List<SiteLocation>? locationList = [];
    if (result is SUCCESS) {
      locationList = result.data;
    }
    return locationList;
  }

  @override
  Future<List<ObservationData>?> getObservationListByPlan(
      Map<String, dynamic> request, [dioInstance]) async {
    bool isCsrfTokenRequired = !(request["revisionId"].toString().isHashValue() && request["projectId"].toString().isHashValue());
    var result = await NetworkService(
            dioClient: dioInstance,
            baseUrl: AConstants.adoddleUrl,
            isCsrfRequired:isCsrfTokenRequired,
            mNetworkRequest: NetworkRequest(
                type: NetworkRequestType.POST,
                path: AConstants.planObservationList,
                data: NetworkRequestBody.json(request)))
        .execute(ObservationData.jsonToObservationList);
    List<ObservationData>? observationList = [];
    if (result is SUCCESS) {
      observationList = result.data;
    }
    return observationList;
  }

  @override
  Future<Result> getSearchList(Map<String, dynamic> request,[dioInstance]) async {
    var result = await NetworkService(
        dioClient: dioInstance,
        baseUrl: AConstants.adoddleUrl,
        mNetworkRequest: NetworkRequest(
            type: NetworkRequestType.POST,
            path: AConstants.getSearchLocationList,
            data: NetworkRequestBody.json(request)))
        .execute(SearchLocationListVo.fromJson);
    return result;
  }

  @override
  Future<Result?> getSuggestedSearchList(Map<String, dynamic> request,[dioInstance]) async {
    String endPointUrl = AConstants.getSuggestedSearchLocationList;
    String temUrl = "";
    request.forEach((key, value) {
      if(temUrl.isNotEmpty){
        temUrl = '$temUrl&';
      }
      temUrl = '$temUrl$key=$value';
    });
    endPointUrl = '$endPointUrl?$temUrl';
    var result = await NetworkService(
      dioClient: dioInstance,
      baseUrl: AConstants.adoddleUrl,
      //headerType: HeaderType.APPLICATION_JSON,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.GET,
        path: endPointUrl,
        data: const NetworkRequestBody.empty(),
      ),
      responseType: ResponseType.plain,
    ).execute((response){
      return response;
    });
    return result;
  }

}
