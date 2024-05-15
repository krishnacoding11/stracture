import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:field/data/model/simple_file_upload.dart';
import 'package:field/data/repository/upload/upload_repository.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/networking/network_service.dart';
import 'package:field/networking/request_body.dart';
import 'package:field/utils/constants.dart';

class UploadRemoteRepository extends UploadRepository<Map,Result>{
  UploadRemoteRepository();

  @override
  Future<Result> getLockValidation(Map<String, dynamic> request,[dioInstance]) async {
    var result = await NetworkService(
      dioClient: dioInstance,
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.uploadAttachmentUrl,
        data: NetworkRequestBody.json(request),
      ),
    ).execute((response){
      return jsonDecode(response);
    });
    return result;
  }

  @override
  Future<Result> checkUploadEventValidation(Map<String, dynamic> request,[dioInstance]) async {
    Map<String, dynamic> requestData = {};
    requestData["uploadEventData"] = jsonEncode(request);

    var result = await NetworkService(
      dioClient: dioInstance,
      baseUrl: AConstants.adoddleUrl,
      headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.uploadEventValidation,
        data: NetworkRequestBody.json(requestData),
      ),
    ).execute((response) {
      return response;
    });
    return result;
  }

  @override
  Future<Result> simpleFileUploadToServer(Map<String, dynamic> request,[dioInstance]) async {
    FormData formData = FormData();
    formData = FormData.fromMap(request);

    var result = await NetworkService(
      dioClient: dioInstance,
      baseUrl: AConstants.adoddleUrl,
      headerType: HeaderType.MULTIPART_REQUEST,
      mNetworkRequest: NetworkRequest(
        callType: CallType.MultiPart,
        type: NetworkRequestType.POST,
        path: AConstants.simpleFileUpload,
        data: NetworkRequestBody.formData(formData),
      ),
    ).execute(simpleUploadListFromJson);
    return result;
  }

  List<SimpleFileUpload>? simpleUploadListFromJson(dynamic value) {
    dynamic response = jsonDecode(value);
    var simpleUploadList = List<SimpleFileUpload>.from(response.map((x) => SimpleFileUpload.fromJson(x)));
    return simpleUploadList;
  }
}