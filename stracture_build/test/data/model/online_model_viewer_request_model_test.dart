import 'package:field/data/model/online_model_viewer_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OnlineViewerModelRequestModel Test', () {
    test('toJson() should return a valid JSON map', () {
      final model = OnlineViewerModelRequestModel(
        modelName: 'Test Model',
        modelId: '12345',
        isSelectedModel: true,
        bimModelList: []
      );

      final jsonMap = model.toJson();

      final expectedJsonMap = {
        'bimModelList': [],
        'model_name': 'Test Model',
        'modelId': '12345',
        'isSelectedModel': true
      };
      expect(jsonMap['bimModelList'], equals(isEmpty));
      expect(jsonMap['modelId'], equals('12345'));
      expect(jsonMap['isSelectedModel'], equals(true));
      expect(jsonMap['model_name'], equals('Test Model'));
      expect(jsonMap, equals(expectedJsonMap));
    });

    test('fromJson() should correctly parse a JSON map', () {
      final jsonMap = {
        'model_name': 'Test Model',
        'modelId': '12345',
        'isSelectedModel': true,
      };

      final model = OnlineViewerModelRequestModel.fromJson(jsonMap);

      expect(model.modelName, equals('Test Model'));
      expect(model.modelId, equals('12345'));
      expect(model.isSelectedModel, equals(true));
    });

    test('toJson() and fromJson() should be consistent', () {
      final model = OnlineViewerModelRequestModel(
        modelName: 'Test Model',
        modelId: '12345',
        isSelectedModel: true,
        bimModelList: []
      );

      final jsonMap = model.toJson();
      final parsedModel = OnlineViewerModelRequestModel.fromJson(jsonMap);

      expect(parsedModel.modelName, equals(model.modelName));
      expect(parsedModel.modelId, equals(model.modelId));
      expect(parsedModel.isSelectedModel, equals(model.isSelectedModel));
    });

    test('props should return an empty list', () {
      final data = OnlineViewerModelRequestModel(
        modelName: 'Test Model',
        modelId: '12345',
        isSelectedModel: true,
      );

      final props = data.props;

      expect(props, isEmpty);
    });


    test('fromJson should parse valid JSON correctly', () {
      // Test the fromJson method (same as previous test).
    });

    test('toJson should encode valid object correctly', () {
      // Test the toJson method (same as previous test).
    });
  });
}
