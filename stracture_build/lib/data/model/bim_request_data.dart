import 'package:equatable/equatable.dart';

class BimProjectModelRequestModel extends Equatable {
  String? projectId;
  String? actionId;
  String? modelId;
  String? modelVersionID;
  String? modelName;
  String? fileName;

  BimProjectModelRequestModel(
      {this.projectId,
      this.actionId,
      this.modelId,
      this.modelVersionID,
      this.modelName,
      this.fileName});

  BimProjectModelRequestModel.fromJson(Map<String, dynamic> json) {
    projectId = json['projectId'];
    actionId = json['action_id'];
    modelId = json['model_id'];
    modelVersionID = json['modelVersionID'];
    modelName = json['model_name'];
    fileName = json['file_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['projectId'] = projectId;
    data['action_id'] = actionId;
    data['model_id'] = modelId;
    data['modelVersionID'] = modelVersionID;
    data['model_name'] = modelName;
    data['file_name'] = fileName;

    return data;
  }

  @override
  List<Object?> get props => [];
}
