class ModelBimModel {
  String? modelId;
  String? bimModelId;

  ModelBimModel({
    this.modelId,
    this.bimModelId,
  });

  ModelBimModel.fromJson(Map<String, dynamic> json) {
    modelId = json['modelId'] ?? "1";
    bimModelId = json['bimModelId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['modelId'] = modelId;
    data['bimModelId'] = bimModelId;

    return data;
  }

  List<Object?> get props => [];
}
