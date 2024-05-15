import 'package:field/data/model/floor_bim_model_vo.dart';
import 'package:field/data/model/model_bim_model_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:test/test.dart';

void main() {

  group('Model Bim Model', () {
    test('fromJson should parse valid JSON correctly', () {
      final jsonData = {
        'bimModelId': "46312\$\$17KRZw",
        'FloorId': "46642\$\$17GDFw",
      };
      final modelBimModel = FloorBimModel.fromJson(jsonData);

      expect(modelBimModel.floorId, equals("46642\$\$17GDFw"));
      expect(modelBimModel.bimModelId, equals("46312\$\$17KRZw"));
      // Add other expectations for the rest of the properties
    });

    test('toJson should encode valid object correctly', () {
      final modelBimModel = FloorBimModel(
        floorId: "46312\$\$17KRZw",
        bimModelId: '46642\$\$17GDFw',
        // Add other properties here with sample values
      );

      final json = modelBimModel.toJson();

      expect(json['bimModelId'], equals("46642\$\$17GDFw"));
      expect(json['FloorId'], equals("46312\$\$17KRZw"));
      // Add other expectations for the rest of the properties
    });

    test('props should return an empty list', () {
      final modelBimModel = FloorBimModel(
        floorId: "46312\$\$17KRZw",
        bimModelId: '46642\$\$17GDFw',
        // Add other properties here with sample values
      );


      final props = modelBimModel.props;

      expect(props, isEmpty);
    });
  });
}
