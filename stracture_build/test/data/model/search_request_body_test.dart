import 'package:field/data/model/search_request_body.dart';
import 'package:test/test.dart';

void main() {
  group('SearchModelRequestBody tests', () {
    test('fromJson() should initialize object from JSON', () {
      // Given
      Map<String, dynamic> json = {
        "id": 1,
        "userId": 123,
        "filterName": "Test Filter",
        "listingTypeId": 456,
        "subListingTypeId": 789,
        "isUnsavedFilter": true,
        "isFavorite": "Yes",
        "filterQueryVOs": [
          {
            "fieldName": "field1",
            "indexField": "index1",
            "v": "value1",
            "dataType": "type1",
            "solrCollections": "collection1",
            "returnIndexFields": "returnFields1",
            "popupTo": {
              "data": [
                {"id": "1", "value": "val1"}
              ]
            },
            "labelName": "Label 1",
          },
          // Add more FilterQueryVo objects here if needed
        ],
        "userAccesibleDCIds": [10, 20, 30],
      };

      // When
      var requestBody = SearchModelRequestBody.fromJson(json);

      // Then
      expect(requestBody.id, equals(1));
      expect(requestBody.userId, equals(123));
      expect(requestBody.filterName, equals("Test Filter"));
      expect(requestBody.listingTypeId, equals(456));
      expect(requestBody.subListingTypeId, equals(789));
      expect(requestBody.isUnsavedFilter, equals(true));
      expect(requestBody.isFavorite, equals("Yes"));
      expect(requestBody.filterQueryVOs!.length, equals(1));
      // You can add more detailed assertions for FilterQueryVo and other objects
      // if needed.
      expect(requestBody.userAccesibleDcIds, equals([10, 20, 30]));
    });

    test('toJson() should convert object to JSON', () {
      // Given
      var requestBody = SearchModelRequestBody(
        id: 1,
        userId: 123,
        filterName: "Test Filter",
        listingTypeId: 456,
        subListingTypeId: 789,
        isUnsavedFilter: true,
        isFavorite: "Yes",
        filterQueryVOs: [
          FilterQueryVo(
            fieldName: "field1",
            indexField: "index1",
            v: "value1",
            dataType: "type1",
            solrCollections: "collection1",
            returnIndexFields: "returnFields1",
            popupTo: PopupTo(data: [Datum(id: "1", value: "val1")]),
            labelName: "Label 1",
          ),
          // Add more FilterQueryVo objects here if needed
        ],
        userAccesibleDcIds: [10, 20, 30],
      );

      // When
      var json = requestBody.toJson();

      // Then
      expect(json["id"], equals(1));
      expect(json["userId"], equals(123));
      expect(json["filterName"], equals("Test Filter"));
      expect(json["listingTypeId"], equals(456));
      expect(json["subListingTypeId"], equals(789));
      expect(json["isUnsavedFilter"], equals(true));
      expect(json["isFavorite"], equals("Yes"));
      expect(json["filterQueryVOs"], isA<List>());
      expect(json["userAccesibleDCIds"], isA<List>());
    });
  });
}
