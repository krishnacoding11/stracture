import 'package:field/data/model/model_bim_model_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:test/test.dart';

void main() {

  group('Model Bim Model', () {
    test('fromJson should parse valid JSON correctly', () {
      final jsonData = {
        'modelId': "46312\$\$17KRZw",
        'bimModelId': "46642\$\$17GDFw",
      };
      final modelBimModel = ModelBimModel.fromJson(jsonData);

      expect(modelBimModel.modelId, equals("46312\$\$17KRZw"));
      expect(modelBimModel.bimModelId, equals("46642\$\$17GDFw"));
      // Add other expectations for the rest of the properties
    });

    test('toJson should encode valid object correctly', () {
      final modelBimModel = ModelBimModel(
        modelId: "46312\$\$17KRZw",
        bimModelId: '46642\$\$17GDFw',
        // Add other properties here with sample values
      );

      final json = modelBimModel.toJson();

      expect(json['modelId'], equals("46312\$\$17KRZw"));
      expect(json['bimModelId'], equals("46642\$\$17GDFw"));
      // Add other expectations for the rest of the properties
    });

    test('props should return an empty list', () {
      final modelBimModel = ModelBimModel(
        modelId: "46312\$\$17KRZw",
        bimModelId: '46642\$\$17GDFw',
        // Add other properties here with sample values
      );


      final props = modelBimModel.props;

      expect(props, isEmpty);
    });
  });
}
