import 'package:equatable/equatable.dart';

import 'bim_project_model_vo.dart';

class OnlineViewerModelRequestModel extends Equatable {
  List<IfcObjects>? bimModelList;
  String? modelName;
  String? modelId;
  bool isSelectedModel = false;

  OnlineViewerModelRequestModel({
    this.bimModelList,
    this.modelName,
    this.modelId,
    required this.isSelectedModel,
  });

  OnlineViewerModelRequestModel.fromJson(Map<String, dynamic> json) {
    bimModelList = json['bimModelList'];
    modelName = json['model_name'];
    modelId = json['modelId'];
    isSelectedModel = json['isSelectedModel'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['bimModelList'] = bimModelList;
    data['model_name'] = modelName;
    data['modelId'] = modelId;
    data['isSelectedModel'] = isSelectedModel;

    return data;
  }

  @override
  List<Object?> get props => [];
}
