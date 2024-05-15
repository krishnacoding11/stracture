import 'dart:convert';

import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:flutter/services.dart';

import 'bim_project_model_data_source.dart';

class BimProjectModelListLocalDataSourceImpl extends BimProjectModelDataSource {
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

  Future<List<BimProjectModel>> getWorkspaceList(Map<String, dynamic> request) {
    throw UnimplementedError();
  }

  Future setFavBimProjectModel(Map<String, dynamic> request) {
    throw UnimplementedError();
  }

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
