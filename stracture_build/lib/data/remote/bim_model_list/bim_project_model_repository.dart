import 'dart:async';

import 'package:field/data/model/bim_project_model_vo.dart';

import '../../../logger/logger.dart';
import '../../../networking/network_request.dart';
import '../../../networking/network_response.dart';
import '../../../networking/network_service.dart';
import '../../../networking/request_body.dart';
import '../../../utils/constants.dart';

abstract class BimProjectModelListRepository {
  Future<List<BimProjectModel>> getBimProjectModelList(Map<String, dynamic> request);
}

class BimProjectModelListRemoteRepository extends BimProjectModelListRepository {
  BimProjectModelListRemoteRepository();

  @override
  Future<List<BimProjectModel>> getBimProjectModelList(
      Map<String, dynamic> request) async {
    List<BimProjectModel> list = [];
    //Instantiate a service and keep it in your DI container:
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
    } else {}
    return list;
  }

  List<BimProjectModel>? modelListFromJson(dynamic response) {
    var modelList = List<BimProjectModel>.from(
        response.map((x) => BimProjectModel.fromJson(x)));

    List<BimProjectModel> outputList = modelList.toList();
    return outputList;
  }

  Future<dynamic> setFavBimProjectModel(Map<String, dynamic> request) async {
    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.modelListURL,
        data: NetworkRequestBody.json(request),
        // headers: csrfHeader
      ),
    ).execute(parseFavModelJson);
    if (result is SUCCESS) {
      return result;
    } else {}
    return result;
  }

  String parseFavModelJson(dynamic data) {
    String success = data.toString();
    return success;
  }
}
