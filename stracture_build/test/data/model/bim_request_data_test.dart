import 'package:field/data/model/model_bim_model_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/utils/actionIdConstants.dart';
import 'package:test/test.dart';

import '../../../lib/data/model/bim_request_data.dart';

void main() {

  group('Bim Request Data', () {
    test('fromJson should parse valid JSON correctly', () {
      final jsonData = {
        'projectId': "2134298\$\$4Dizau",
        'action_id': "1013",
        'model_id': "46642\$\$17GDFw",
        'modelVersionID': "-1",
        'model_name': "Scenario 1",
        'file_name': "Vivek_Mishra",
      };
      final bimRequestData = BimProjectModelRequestModel.fromJson(jsonData);

      expect(bimRequestData.projectId, equals("2134298\$\$4Dizau"));
      expect(bimRequestData.actionId, equals("1013"));
      expect(bimRequestData.modelId, equals("46642\$\$17GDFw"));
      expect(bimRequestData.modelVersionID, equals("-1"));
      expect(bimRequestData.modelName, equals("Scenario 1"));
      expect(bimRequestData.fileName, equals("Vivek_Mishra"));
      // Add other expectations for the rest of the properties
    });

    test('toJson should encode valid object correctly', () {
      final modelRequestData = BimProjectModelRequestModel(
        projectId: "2134298\$\$4Dizau",
        actionId: "1013",
        modelId: '46642\$\$17GDFw',
        modelVersionID: '-1',
        modelName: 'Scenario 1',
        fileName: 'Vivek_Mishra',
        // Add other properties here with sample values
      );

      final json = modelRequestData.toJson();

      expect(json['projectId'], equals("2134298\$\$4Dizau"));
      expect(json['action_id'], equals("1013"));
      expect(json['model_id'], equals("46642\$\$17GDFw"));
      expect(json['modelVersionID'], equals("-1"));
      expect(json['model_name'], equals("Scenario 1"));
      expect(json['file_name'], equals("Vivek_Mishra"));
      // Add other expectations for the rest of the properties
    });

    test('props should return an empty list', () {
      final modelRequestData = BimProjectModelRequestModel(
        projectId: "2134298\$\$4Dizau",
        actionId: "1013",
        modelId: '46642\$\$17GDFw',
        modelVersionID: '-1',
        modelName: 'Scenario 1',
        fileName: 'Vivek_Mishra',
        // Add other properties here with sample values
      );


      final props = modelRequestData.props;

      expect(props, isEmpty);
    });
  });
}
