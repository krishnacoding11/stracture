import 'package:field/data/model/save_color_request_body.dart';
import 'package:test/test.dart';

void main() {
  group('SaveColorRequestBody tests', () {
    test('fromJson() should initialize object from JSON', () {
      // Given
      Map<String, dynamic> json = {
        "guid": "12345",
        "color": "#FF0000",
      };

      // When
      var saveColorRequestBody = SaveColorRequestBody.fromJson(json);

      // Then
      expect(saveColorRequestBody.guid, equals("12345"));
      expect(saveColorRequestBody.color, equals("#FF0000"));
    });

    test('toJson() should convert object to JSON', () {
      // Given
      var saveColorRequestBody = SaveColorRequestBody(
        guid: "12345",
        color: "#FF0000",
      );

      // When
      var json = saveColorRequestBody.toJson();

      // Then
      expect(json["guid"], equals("12345"));
      expect(json["color"], equals("#FF0000"));
    });

    test('saveColorRequestBodyFromJson() should convert JSON list to List<SaveColorRequestBody>', () {
      // Given
      String jsonString = '[{"guid": "12345", "color": "#FF0000"}, {"guid": "67890", "color": "#00FF00"}]';

      // When
      var result = saveColorRequestBodyFromJson(jsonString);

      // Then
      expect(result, isA<List<SaveColorRequestBody>>());
      expect(result.length, equals(2));

      expect(result[0].guid, equals("12345"));
      expect(result[0].color, equals("#FF0000"));

      expect(result[1].guid, equals("67890"));
      expect(result[1].color, equals("#00FF00"));
    });

    test('saveColorRequestBodyToJson() should convert List<SaveColorRequestBody> to JSON list', () {
      // Given
      var saveColorRequestBodyList = [
        SaveColorRequestBody(guid: "12345", color: "#FF0000"),
        SaveColorRequestBody(guid: "67890", color: "#00FF00"),
      ];

      // When
      var json = saveColorRequestBodyToJson(saveColorRequestBodyList);

      // Then
      expect(json, equals('[{"guid":"12345","color":"#FF0000"},{"guid":"67890","color":"#00FF00"}]'));
    });
  });
}
