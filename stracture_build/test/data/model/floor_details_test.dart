import 'package:field/data/model/floor_details.dart';
import 'package:test/test.dart';

void main() {
  group('FloorData Tests', () {

    test('FloorData.fromJson should create a FloorData object from JSON', () {
      final json = {
        "revisionId": 1,
        "bimModelId": "bim_123",
        "floorDetails": [
          {
            "fileName": "floor_plan_1",
            "fileSize": 1024,
            "floorNumber": 1,
            "levelName": "Level 1",
            "isChecked": true,
            "isDownloaded": false,
            "revisionId": 1,
            "bimModelId": "bim_123",
            "projectId": "proj_456",
          },
        ],
      };


      final floorData = FloorData.fromJson(json);

      expect(floorData.revisionId, 1);
      expect(floorData.bimModelId, "bim_123");
      expect(floorData.floorDetails, isNotNull);
      expect(floorData.floorDetails.length, 1);
      expect(floorData.floorDetails[0].fileName, "floor_plan_1");
      expect(floorData.floorDetails[0].fileSize, 1024);
      expect(floorData.floorDetails[0].floorNumber, 1);
      expect(floorData.floorDetails[0].levelName, "Level 1");
      expect(floorData.floorDetails[0].isChecked, true);
      expect(floorData.floorDetails[0].isDownloaded, false);
      expect(floorData.floorDetails[0].revisionId, 1);
      expect(floorData.floorDetails[0].bimModelId, "bim_123");
      expect(floorData.floorDetails[0].projectId, "proj_456");
    });

    test('FloorData.toJson should convert a FloorData object to JSON', () {

      final floorDetail1 = FloorDetail(
        fileName: "floor_plan_1",
        fileSize: 1024,
        floorNumber: 1,
        levelName: "Level 1",
        isChecked: true,
        isDownloaded: false,
        revisionId: 1,
        bimModelId: "bim_123",
        projectId: "proj_456",
        revName: '',
      );

      final floorData = FloorData(
        revisionId: 1,
        bimModelId: "bim_123",
        floorDetails: [floorDetail1],
      );

      final json = floorData.toJson();

      expect(json["revisionId"], 1);
      expect(json["bimModelId"], "bim_123");
      expect(json["floorDetails"], isNotNull);
      expect(json["floorDetails"], isList);
      expect(json["floorDetails"].length, 1);
      expect(json["floorDetails"][0]["fileName"], "floor_plan_1");
      expect(json["floorDetails"][0]["fileSize"], 1024);
      expect(json["floorDetails"][0]["floorNumber"], 1);
      expect(json["floorDetails"][0]["levelName"], "Level 1");
      expect(json["floorDetails"][0]["isChecked"], true);
      expect(json["floorDetails"][0]["isDownloaded"], false);
      expect(json["floorDetails"][0]["revisionId"], 1);
      expect(json["floorDetails"][0]["bimModelId"], "bim_123");
      expect(json["floorDetails"][0]["projectId"], "proj_456");
    });

    test('FloorDetail.fromJson should create a FloorDetail object from JSON', () {
      // Sample JSON data representing a FloorDetail object
      final json = {
        "fileName": "floor_plan_1",
        "fileSize": 1024,
        "floorNumber": 1,
        "levelName": "Level 1",
        "isChecked": true,
        "isDownloaded": false,
        "revisionId": 1,
        "bimModelId": "bim_123",
        "projectId": "proj_456",
      };

      // Create a FloorDetail object from the JSON data
      final floorDetail = FloorDetail.fromJson(json);

      // Check if the properties are correctly set
      expect(floorDetail.fileName, "floor_plan_1");
      expect(floorDetail.fileSize, 1024);
      expect(floorDetail.floorNumber, 1);
      expect(floorDetail.levelName, "Level 1");
      expect(floorDetail.isChecked, true);
      expect(floorDetail.isDownloaded, false);
      expect(floorDetail.revisionId, 1);
      expect(floorDetail.bimModelId, "bim_123");
      expect(floorDetail.projectId, "proj_456");
    });

    test('FloorDetail.toJson should convert a FloorDetail object to JSON', () {
      // Create a sample FloorDetail object
      final floorDetail = FloorDetail(
        fileName: "floor_plan_1",
        fileSize: 1024,
        floorNumber: 1,
        levelName: "Level 1",
        isChecked: true,
        isDownloaded: false,
        revisionId: 1,
        bimModelId: "bim_123",
        projectId: "proj_456",
        revName: '',
      );

      // Convert the FloorDetail object to JSON
      final json = floorDetail.toJson();

      // Check if the JSON object is correctly generated
      expect(json["fileName"], "floor_plan_1");
      expect(json["fileSize"], 1024);
      expect(json["floorNumber"], 1);
      expect(json["levelName"], "Level 1");
      expect(json["isChecked"], true);
      expect(json["isDownloaded"], false);
      expect(json["revisionId"], 1);
      expect(json["bimModelId"], "bim_123");
      expect(json["projectId"], "proj_456");
    });

    test('FloorDetail props should correctly determine object equality', () {
      final floorDetail1 = FloorDetail(
        fileName: "floor_plan_1",
        fileSize: 1024,
        floorNumber: 1,
        levelName: "Level 1",
        isChecked: true,
        isDownloaded: false,
        revisionId: 1,
        bimModelId: "bim_123",
        projectId: "proj_456", revName: '',
      );

      // Create an identical FloorDetail object
      final floorDetail2 = FloorDetail(
        fileName: "floor_plan_1",
        fileSize: 1024,
        floorNumber: 1,
        levelName: "Level 1",
        isChecked: true,
        isDownloaded: false,
        revisionId: 1,
        bimModelId: "bim_123",
        projectId: "proj_456",
        revName: '',
      );

      // Create a FloorDetail object with different floorNumber
      final floorDetail3 = FloorDetail(
        fileName: "floor_plan_1",
        fileSize: 1024,
        floorNumber: 2,
        levelName: "Level 1",
        isChecked: true,
        isDownloaded: false,
        revisionId: 1,
        bimModelId: "bim_123",
        projectId: "proj_456",
        revName: '',
      );

      // Test object equality
      expect(floorDetail1, floorDetail2);

      // Test object inequality
      expect(floorDetail1, isNot(floorDetail3));
    });

    test('floorDataToJson should serialize FloorData objects to JSON', () {
      final floorDetail1 = FloorDetail(
        fileName: "floor_plan_1",
        fileSize: 1024,
        floorNumber: 1,
        levelName: "Level 1",
        isChecked: true,
        isDownloaded: false,
        revisionId: 1,
        bimModelId: "bim_123",
        projectId: "proj_456",
        revName: '',
      );

      final floorDetail2 = FloorDetail(
        fileName: "floor_plan_2",
        fileSize: 2048,
        floorNumber: 2,
        levelName: "Level 2",
        isChecked: false,
        isDownloaded: true,
        revisionId: 2,
        bimModelId: "bim_456",
        projectId: "proj_789",
        revName: '',
      );

      final floorData = FloorData(
        revisionId: 1,
        floorDetails: [floorDetail1, floorDetail2],
      );

      final jsonString = floorDataToJson([floorData]);

      expect(jsonString, isA<String>());

      final decodedData = floorDataFromJson(jsonString);

      expect(decodedData, isA<List<FloorData>>());
      expect(decodedData.length, equals(1));

    });

    test('floorDataFromJson should deserialize JSON to FloorData objects', () {
      final jsonString = '''
        [{
          "revisionId": 1,
          "bimModelId": "bim_123",
          "floorDetails": [
            {
              "fileName": "floor_plan_1",
              "fileSize": 1024,
              "floorNumber": 1,
              "levelName": "Level 1",
              "isChecked": true,
              "isDownloaded": false,
              "revisionId": 1,
              "bimModelId": "bim_123",
              "projectId": "proj_456"
            },
            {
              "fileName": "floor_plan_2",
              "fileSize": 2048,
              "floorNumber": 2,
              "levelName": "Level 2",
              "isChecked": false,
              "isDownloaded": true,
              "revisionId": 1,
              "bimModelId": "bim_123",
              "projectId": "proj_789"
            }
          ]
        }]
      ''';

      // Deserialize the JSON string to FloorData objects
      final decodedData = floorDataFromJson(jsonString);

      // Verify that the deserialized object matches the expected object
      expect(decodedData, isA<List<FloorData>>());
      expect(decodedData.length, equals(1));
      //expect(decodedData[0], equals(expectedFloorData));
    });

  });
}
