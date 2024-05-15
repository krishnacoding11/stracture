
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/repository/qr_repository.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';

import '../../../networking/network_request.dart';
import '../../../networking/network_response.dart';
import '../../../networking/network_service.dart';
import '../../../networking/request_body.dart';
import '../../../utils/constants.dart';

class QRRemoteRepository extends QrRepository<Map,Result> {

  QRRemoteRepository();

  @override
  Future<Result?> checkQRCodePermission(Map<String, dynamic> request) async{
    String endPointUrl = "${AConstants.checkQRCodeUrl}?";
    String tmpData = "";
    int? dcId = request["dcId"];
    //request.remove("dcId");
    request.forEach((key, value) {
      if (tmpData != "") {
        tmpData = "$tmpData&";
      }
      tmpData = "$tmpData$key=$value";
    });
    endPointUrl = "$endPointUrl$tmpData";

    var result = await NetworkService(
            baseUrl: AConstants.adoddleUrl,
            dcId: dcId,
            //headerType: HeaderType.APPLICATION_JSON,
            mNetworkRequest: NetworkRequest(
              type: NetworkRequestType.GET,
              path: endPointUrl,
              data: const NetworkRequestBody.empty(),
            ),
            responseType: ResponseType.plain,
            isCsrfRequired: true)
        .execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result?>? getFormPrivilege(Map<String, dynamic> request) async
  {
    bool isCsrfRequired = !(request["projectId"].toString().isHashValue() && request["instanceGroupId"].toString().isHashValue());
    int? dcId = request["dcId"];
    //request.remove("dcId");
    var result = await NetworkService(
            baseUrl: AConstants.adoddleUrl,
            dcId: dcId,
            mNetworkRequest: NetworkRequest(
              type: NetworkRequestType.POST,
              path: AConstants.formPermissionUrl,
              data: NetworkRequestBody.json(request),
            ),
            responseType: ResponseType.plain,
            isCsrfRequired: isCsrfRequired)
        .execute((response){
      return response;
    });
    return result;
  }

  @override
  Future<Result?>? getLocationDetails(Map<String, dynamic> request) async
  {
    int? dcId = request["dcId"];
    //request.remove("dcId");
    var result = await NetworkService(
            baseUrl: AConstants.adoddleUrl,
            dcId: dcId,
            mNetworkRequest: NetworkRequest(
              type: NetworkRequestType.POST,
              path: AConstants.getLocationDetails,
              data: NetworkRequestBody.json(request),
            ),
            responseType: ResponseType.plain,
            isCsrfRequired: true)
        .execute((response){
      return response;
    });
    return result;
  }



  @override
  Future<Result?> getFieldEnableSelectedProjectsAndLocations(Map<String, dynamic> request) async {
    bool isCsrfRequired = false;
    if (!request['projectId'].toString().contains(Utility.keyDollar) ||
        !request['folder_id'].toString().contains(Utility.keyDollar)) {
      isCsrfRequired = true;
    }
    int? dcId = request["dcId"];
    //request.remove("dcId");
    //Instantiate a service and keep it in your DI container:
    var result = await NetworkService(
            baseUrl: AConstants.adoddleUrl,
            dcId: dcId,
            mNetworkRequest: NetworkRequest(
                type: NetworkRequestType.POST,
                path: AConstants.projectListUrl,
                data: NetworkRequestBody.json(request)),
            responseType: ResponseType.plain,
            isCsrfRequired: isCsrfRequired)
        .execute(getVOFromResponse);
    return result;
  }

  dynamic getVOFromResponse(dynamic response) {
    try {
      dynamic json = jsonDecode(response);
      var projectList = List<Project>.from(json.map((x) => Project.fromJson(x)));
      List<Project> outputList = projectList.where((o) => o.iProjectId == 0).toList();
      return outputList;

    }
    catch (error) {
      return null;
    }
    // return response;
  }
}