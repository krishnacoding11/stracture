import 'dart:convert';

import 'package:field/data/model/model_vo.dart';
import 'package:field/data_source/model_list/model_list_data_source.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/utils.dart';

import '../../../networking/network_request.dart';
import '../../../networking/network_service.dart';
import '../../../networking/request_body.dart';

class ModelListRemoteDataSourceImpl extends ModelListDataSource {
  @override
  Future<List<Model>> getModelList(Map<String, dynamic> request) async {
    List<Model> list = [];

    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.modelListURL,
        data: NetworkRequestBody.json(request),
      ),
    ).execute(modelListFromJson);
    if (result is SUCCESS) {
      for (var item in result.data!) {
        list.add(item);
      }
      Log.d("Get model listing in successfully");
      return list;
    }
    return list;
  }

  List<Model>? modelListFromJson(dynamic response) {
    var modelList = List<Model>.from(response.map((x) => Model.fromJson(x)));
    return modelList;
  }

  List<Model>? popupDataListFromJson(dynamic response) {
    var dataJson = json.decode(response);
    dynamic data = dataJson["data"];
    var modelList = List<Model>.from(data.map((x) => Model.fromJson(x)));
    return modelList;
  }

  @override
  Future<List<Model>> getWorkspaceList(Map<String, dynamic> request) async {
    List<Model> list = [];
    Map<String, String> csrfHeader = {};

    bool isCsrfRequired = false;
    if (!request['modelId'].toString().contains(Utility.keyDollar) ||
        !request['folder_id'].toString().contains(Utility.keyDollar)) {
      isCsrfRequired = true;
    }
    if (isCsrfRequired == true) {
      var csrf = await NetworkService(
        baseUrl: AConstants.adoddleUrl,
        mNetworkRequest: const NetworkRequest(
            type: NetworkRequestType.POST,
            path: AConstants.csrfTokenUrl,
            data: NetworkRequestBody.json({})),
      ).execute((response) {
        return response;
      });
      csrfHeader = Map<String, String>.from(csrf.data);
    }
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
          type: NetworkRequestType.POST,
          path: AConstants.modelListURL,
          data: NetworkRequestBody.json(request),
          headers: csrfHeader),
    ).execute(modelListFromJson);
    if (result is SUCCESS) {
      for (var item in result.data!) {
        list.add(item);
      }
      Log.d("Get model listing in successfully");
      return list;
    }
    return list;
  }

  @override
  Future<dynamic> setFavModel(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.modelListURL,
        data: NetworkRequestBody.json(request),
      ),
    ).execute(parseFavModelJson);
    if (result is SUCCESS) {
      return result;
    }
    return result;
  }

  String parseFavModelJson(dynamic data) {
    String success = data.toString();
    return success;
  }

  @override
  Future<List<Model>> getPopupDataList(Map<String, dynamic> request) async {
    List<Model> list = [];
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.modelListURL,
        data: NetworkRequestBody.json(request),
      ),
    ).execute(popupDataListFromJson);
    if (result is SUCCESS) {
      for (var item in result.data!) {
        list.add(item);
      }
      Log.d("Get model listing in successfully");
      return list;
    }
    return list;
  }
}
