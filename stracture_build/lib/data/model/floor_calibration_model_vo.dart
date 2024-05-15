class FloorCalibrationModel {
  String? calibrationId;
  String? floorId;

  FloorCalibrationModel({
    this.calibrationId,
    this.floorId,
  });

  FloorCalibrationModel.fromJson(Map<String, dynamic> json) {
    calibrationId = json['calibrationId'] ?? "1";
    floorId = json['FloorId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['calibrationId'] = calibrationId;
    data['FloorId'] = floorId;

    return data;
  }
}
