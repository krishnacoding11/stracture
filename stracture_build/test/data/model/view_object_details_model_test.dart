import 'package:field/data/model/view_object_details_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ViewObjectDetailsModel', () {
    test('fromJson should parse JSON correctly', () {
      final jsonString = '''
        {
          "details": [
            {
              "section-name": "Section 1",
              "isExpanded": true,
              "property": [
                {
                  "property-name": "Property 1",
                  "property-value": "Value 1"
                }
              ]
            }
          ]
        }
      ''';

      final model = viewObjectDetailsModelFromJson(jsonString);

      expect(model.details.length, 1);
      expect(model.details[0].sectionName, "Section 1");
      expect(model.details[0].isExpanded, false);
      expect(model.details[0].property.length, 1);
      expect(model.details[0].property[0].propertyName, "Property 1");
      expect(model.details[0].property[0].propertyValue, "Value 1");
    });

    test('toJson should convert model to JSON correctly', () {
      final model = ViewObjectDetailsModel(
        details: [
          Detail(
            sectionName: "Section 1",
            isExpanded: true,
            property: [
              Property(
                propertyName: "Property 1",
                propertyValue: "Value 1",
              )
            ],
          )
        ],
      );

      final json = viewObjectDetailsModelToJson(model);

      final expectedJson = '{"details":[{"section-name":"Section 1","isExpanded":false,"property":[{"property-name":"Property 1","property-value":"Value 1"}]}]}';

      expect(json, expectedJson.trim());
    });
  });
}
