import 'package:dio/dio.dart';
import 'package:field/data/repository/sitetask_repository.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/networking/network_service.dart';
import 'package:field/networking/request_body.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';

class SiteTaskRemoteRepository extends SiteTaskRepository<Map,Result> {

  SiteTaskRemoteRepository();

  @override
  Future<Result?> getSiteTaskList(Map<String, dynamic> request) async {
    var result = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        mNetworkRequest: NetworkRequest(
          type: NetworkRequestType.POST,
          path: AConstants.siteTasksUrl,
          data: NetworkRequestBody.json(request),
        ),
    ).execute((response){
      return response;
    });
    return result;
  }

  @override
  Future<Result?> getExternalAttachmentList(Map<String, dynamic> request) async {
    String endPointUrl = AConstants.formExternalAttachUrl;
    String temUrl = "";
    request.forEach((key, value) {
      if(temUrl.isNotEmpty){
        temUrl = '$temUrl&';
      }
      temUrl = '$temUrl$key=$value';
    });
    endPointUrl = '$endPointUrl?$temUrl';
    var result = await NetworkService(
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

  @override
  Future<Result?>? getFilterSiteTaskList(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getFilterSiteTaskListUrl,
        data: NetworkRequestBody.json(request),
      ),
    ).execute((response){
      return response;
    });
    return result;
  }

  @override
  Future<Result?> getUpdatedSiteTaskItem(String projectId, String formId) async {
    Map<String, dynamic> request = {
      "projectId": projectId,
      "recordBatchSize": 5,
      "listingType": 31,
      "recordStartFrom": 0,
      "selectedFormId":formId.plainValue(),
      "application_Id": 3,
      "isFromAndroidApp": true,
      "isFromSyncCall": true,
      "isRequiredTemplateData": true,
      "action_id": 100
    };
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      //headerType: HeaderType.APPLICATION_JSON,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.adoddleSiteListing,
        data: NetworkRequestBody.json(request),
      ),
    ).execute((response){
      return response;
    });
    return result;
  }
}