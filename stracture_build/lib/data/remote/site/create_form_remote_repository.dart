import 'package:dio/dio.dart';
import 'package:field/data/repository/site/create_form_repository.dart';
import 'package:field/networking/network_response.dart';
import 'package:flutter/foundation.dart';

import '../../../networking/network_request.dart';
import '../../../networking/network_service.dart';
import '../../../networking/request_body.dart';
import '../../../utils/constants.dart';

class CreateFormRemoteRepository with CreateFormRepository {
  CreateFormRemoteRepository();

  @override
  Future<Result> downloadInLineAttachment(Map<String, dynamic> request, [dioInstance]) async {
    var result = await NetworkService(
      dioClient: dioInstance,
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(type: NetworkRequestType.POST, path: AConstants.formPermissionUrl, data: NetworkRequestBody.json(request)),
      responseType: ResponseType.plain,
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result> uploadAttachment(Map<String, dynamic> request, [dioInstance]) async {
    String projectID = request['projectid'];
    request.remove('projectid');
    String appType = request['appType'];
    FormData formData = FormData.fromMap(request);
    String url = "${AConstants.uploadAttachmentUrl}?action_id=1125&isUploadAttachmentInTemp=true&project_id=$projectID&appType=$appType";

    var result = await NetworkService(
      dioClient: dioInstance,
      baseUrl: AConstants.adoddleUrl,
      headerType: HeaderType.MULTIPART_REQUEST,
      mNetworkRequest: NetworkRequest(type: NetworkRequestType.POST, path: url, data: NetworkRequestBody.formData(formData), callType: CallType.MultiPart),
    ).execute((response) {
      if (kDebugMode) {
        print("Upload attachment response:$response");
      }
      return response;
    });
    return result;
  }

  @override
  Future<Result> uploadInlineAttachment(Map<String, dynamic> request, [dioInstance]) async {
    String url;
    if (request.containsKey('isXsn')) {
      request['project_id'] = request['projectid'];
      url = AConstants.uploadInlineAttachmentUrlXSN;
    } else {
      url = "${AConstants.uploadInlineAttachmentUrl}?action_id=1203";
    }

    FormData formData = FormData.fromMap(request);
    var result = await NetworkService(
      dioClient: dioInstance,
      baseUrl: AConstants.adoddleUrl,
      headerType: HeaderType.MULTIPART_REQUEST,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: url,
        data: NetworkRequestBody.formData(formData),
        callType: CallType.MultiPart,
      ),
    ).execute((response) {
      if (kDebugMode) {
        print("Upload attachment response:$response");
      }
      return response;
    });
    return result;
  }

  @override
  Future<Result> saveFormToServer(Map<String, dynamic> request, [dioInstance]) async {
    String url = AConstants.saveForm;
    FormData formData = FormData.fromMap(request);
    var result = await NetworkService(
      dioClient: dioInstance,
      baseUrl: AConstants.adoddleUrl,
      headerType: HeaderType.MULTIPART_REQUEST,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: url,
        data: NetworkRequestBody.formData(formData),
        callType: CallType.MultiPart,
        networkExecutionType: request["networkExecutionType"],
        taskNumber: request["taskNumber"],
      ),
    ).execute((response) {
      if (kDebugMode) {
        print("saveFormToServer response:$response");
      }
      return response;
    });
    return result;
  }

  @override
  Future<Result> formDistActionTaskToServer(Map<String, dynamic> request, [dioInstance]) async {
    String url = AConstants.formDistAction;
    var result = await NetworkService(
      dioClient: dioInstance,
      isCsrfRequired: true,
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(type: NetworkRequestType.POST, path: url, data: NetworkRequestBody.json(request)),
      responseType: ResponseType.plain,
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result> formOtherActionTaskToServer(Map<String, dynamic> request, [dioInstance]) async {
    String url = AConstants.clearFormForAckOrForActionUri;
    String actionId = request["actionId"]?.toString() ?? "";
    if (actionId.isEmpty) {
      url = AConstants.discardDraftUri;
    } else if (actionId == "4") {
      url = AConstants.appsReleaseRespondsUri;
    }
    var result = await NetworkService(
      dioClient: dioInstance,
      baseUrl: AConstants.adoddleUrl,
      isCsrfRequired: true,
      mNetworkRequest: NetworkRequest(type: NetworkRequestType.POST, path: url, data: NetworkRequestBody.json(request)),
      responseType: ResponseType.plain,
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result> formStatusChangeTaskToServer(Map<String, dynamic> request, [dioInstance]) async {
    String url = AConstants.formStatusChange;
    var result = await NetworkService(
      dioClient: dioInstance,
      isCsrfRequired: true,
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(type: NetworkRequestType.POST, path: url, data: NetworkRequestBody.json(request)),
      responseType: ResponseType.plain,
    ).execute((response) {
      return response;
    });
    return result;
  }
}
