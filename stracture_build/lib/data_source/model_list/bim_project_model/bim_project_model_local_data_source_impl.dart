import 'dart:convert';

import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data_source/model_list/bim_project_model/bim_project_model_data_source.dart';
import 'package:flutter/services.dart';

class BimProjectModelLocalDataSourceImpl extends BimProjectModelDataSource {
  @override
  Future<List<BimProjectModel>> getBimProjectModel(
      Map<String, dynamic> request) async {
    List<BimProjectModel> projectList = <BimProjectModel>[];

    final String response =
        await rootBundle.loadString('assets/json/project_list.json');
    final data = await jsonDecode(response);

    for (var item in data["data"]) {
      projectList.add(BimProjectModel.fromJson(item));
    }

    return projectList;
  }

  @override
  Future<List<BimProjectModel>> getWorkspaceList(Map<String, dynamic> request) {
    // TODO: implement getWorkspaceList
    throw UnimplementedError();
  }

  @override
  Future setFavBimProjectModel(Map<String, dynamic> request) {
    // TODO: implement setFavBimProjectModel
    throw UnimplementedError();
  }

  @override
  Future<List<BimProjectModel>> getPopupDataList(
      Map<String, dynamic> request) async {
    List<BimProjectModel> projectList = <BimProjectModel>[];

    final String response =
        await rootBundle.loadString('assets/json/project_list.json');
    final data = await jsonDecode(response);

    for (var item in data["data"]) {
      projectList.add(BimProjectModel.fromJson(item));
    }

    return projectList;
  }
}
