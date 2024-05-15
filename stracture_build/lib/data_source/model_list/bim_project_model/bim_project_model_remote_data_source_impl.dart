import 'dart:convert';

import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data_source/model_list/bim_project_model/bim_project_model_data_source.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';

import '../../../networking/network_request.dart';
import '../../../networking/network_service.dart';
import '../../../networking/request_body.dart';

class BimProjectModelListRemoteDataSourceImpl
    extends BimProjectModelDataSource {
  @override
  Future<List<BimProjectModel>> getBimProjectModel(
      Map<String, dynamic> request) async {
    List<BimProjectModel> list = [];

    var result = await NetworkService(
      baseUrl: AConstants.adoddleUrl,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.bimProjectModelUrl,
        data: NetworkRequestBody.json(request),
      ),
    ).execute(modelListFromJson);
    if (result is SUCCESS) {
      for (var item in result.data!) {
        list.add(item);
      }
      return list;
    }
    return list;
  }

  List<BimProjectModel>? modelListFromJson(dynamic response) {
    var dataJson = json.decode(response);

    dynamic data = dataJson[0];

    var modelList = BimProjectModel.fromJson(dataJson);

    List<BimProjectModel> outputList = [];
    outputList.add(modelList);
    return outputList;
  }
}
