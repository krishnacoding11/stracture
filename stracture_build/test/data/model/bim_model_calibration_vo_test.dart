import 'package:field/data/model/bim_model_calibration_vo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BimModelCalibrationModel bimModelCalibrationModel;

  setUp(() async {
    bimModelCalibrationModel = BimModelCalibrationModel(bimModelId: "123456", calibrationId: "abcd1234");
  });

  group("test BimModelCalibrationModel", () {
    test("test with toJson expected map with exact key and data", () async {
      Map<String, dynamic> map = bimModelCalibrationModel.toJson();
      expect(bimModelCalibrationModel.bimModelId, map["bimModelId"]);
    });

    test("test with fromJson expected bimModelCalibrationModel with valid data", () async {
      Map<String, dynamic> map = bimModelCalibrationModel.toJson();
      BimModelCalibrationModel.fromJson(map);
      expect(BimModelCalibrationModel.fromJson(map).calibrationId, map["CalibrationId"]);
    });
  });
}
