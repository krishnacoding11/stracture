class FloorBimModel {
  String? bimModelId;
  String? floorId;

  FloorBimModel({
    this.bimModelId,
    this.floorId,
  });

  FloorBimModel.fromJson(Map<String, dynamic> json) {
    bimModelId = json['bimModelId'] ?? "1";
    floorId = json['FloorId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bimModelId'] = bimModelId;
    data['FloorId'] = floorId;

    return data;
  }

  List<Object?> get props => [];
}
