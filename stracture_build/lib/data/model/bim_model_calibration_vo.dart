class BimModelCalibrationModel {
  String? bimModelId;
  String? calibrationId;

  BimModelCalibrationModel({
    this.bimModelId,
    this.calibrationId,
  });

  BimModelCalibrationModel.fromJson(Map<String, dynamic> json) {
    bimModelId = json['bimModelId'];
    calibrationId = json['CalibrationId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bimModelId'] = bimModelId;
    data['CalibrationId'] = calibrationId;

    return data;
  }
}
