import 'dart:convert';

import 'package:field/data/model/model_vo.dart';
import 'package:field/data_source/model_list/model_list_data_source.dart';
import 'package:field/logger/logger.dart';
import 'package:flutter/services.dart';

class ModelListLocalDataSourceImpl extends ModelListDataSource {
  @override
  Future<List<Model>> getModelList(Map<String, dynamic> request) async {
    List<Model> projectList = <Model>[];

    final String response =
        await rootBundle.loadString('assets/json/project_list.json');
    final data = await jsonDecode(response);
    //Log.d(data);

    for (var item in data["data"]) {
      Log.d(item);
      projectList.add(Model.fromJson(item));
    }

    return projectList;
  }

  @override
  Future<List<Model>> getWorkspaceList(Map<String, dynamic> request) {
    throw UnimplementedError();
  }

  @override
  Future setFavModel(Map<String, dynamic> request) {
    throw UnimplementedError();
  }

  @override
  Future<List<Model>> getPopupDataList(Map<String, dynamic> request) async {
    List<Model> projectList = <Model>[];

    final String response =
        await rootBundle.loadString('assets/json/project_list.json');
    final data = await jsonDecode(response);
    //Log.d(data);

    for (var item in data["data"]) {
      Log.d(item);
      projectList.add(Model.fromJson(item));
    }

    return projectList;
  }
}
