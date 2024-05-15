import 'dart:convert';

import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:test/test.dart';

void main() {
  group('Bim Project Model VO Data', () {
    test('fromJson should parse valid JSON correctly', () {
      final jsonData = {
        'ifcObject': null,
        'user_privilege': "110",
        'has_views': "true",
        'has_discussions': "true",
        'project_id': "2134298\$\$4Dizau",
        'model_id': "46642\$\$17GDFw",
        'project_name': "Vivek_Mishra",
        'model_creation_date': "",
        'publisher_full_name': "Vivek",
        'model_type_id': -1,
        'last_accessed_date_time': "",
        'is_favourite': 1,
        'last_update_date_time': "Vivek_Mishra",
        'generateURI': false,
      };
      final bimRequestData = BimProjectModelVO.fromJson(jsonData);
      expect(bimRequestData.ifcObject, equals(null));
      expect(bimRequestData.userPrivilege, equals("110"));
      expect(bimRequestData.hasViews, equals("true"));
      expect(bimRequestData.hasDiscussions, equals("true"));
      expect(bimRequestData.projectId, equals("2134298\$\$4Dizau"));
      expect(bimRequestData.modelId, equals("46642\$\$17GDFw"));
      expect(bimRequestData.projectName, equals("Vivek_Mishra"));
      expect(bimRequestData.modelCreationDate, equals(""));
      expect(bimRequestData.publisherFullName, equals("Vivek"));
      expect(bimRequestData.modelTypeId, equals(-1));
      expect(bimRequestData.lastAccessedDateTime, equals(""));
      expect(bimRequestData.isFavourite, equals(1));
      expect(bimRequestData.lastUpdateDateTime, equals("Vivek_Mishra"));
      expect(bimRequestData.generateURI, equals(false));
    });

    test('toJson should encode valid object correctly', () {
      final modelRequestData = BimProjectModelVO(
        ifcObject: null,
        userPrivilege: "110",
        hasViews: 'true',
        hasDiscussions: 'true',
        projectId: '2134298\$\$4Dizau',
        modelId: '46642\$\$17GDFw',
        projectName: 'Vivek_Mishra',
        modelCreationDate: '',
        publisherFullName: 'Vivek',
        modelTypeId: -1,
        lastAccessedDateTime: '',
        isFavourite: 1,
        lastUpdateDateTime: '',
        generateURI: false,
        // Add other properties here with sample values
      );

      final json = modelRequestData.toJson();
      expect(json['ifcObject'], equals(null));
      expect(json['user_privilege'], equals("110"));
      expect(json['has_views'], equals("true"));
      expect(json['has_discussions'], equals("true"));
      expect(json['project_id'], equals("2134298\$\$4Dizau"));
      expect(json['model_id'], equals("46642\$\$17GDFw"));
      expect(json['project_name'], equals("Vivek_Mishra"));
      expect(json['model_creation_date'], equals(""));
      expect(json['publisher_full_name'], equals("Vivek"));
      expect(json['model_type_id'], equals(-1));
      expect(json['last_accessed_date_time'], equals(""));
      expect(json['is_favourite'], equals(1));
      expect(json['last_update_date_time'], equals(""));
      expect(json['generateURI'], equals(false));
    });

    test('props should return an empty list', () {
      final modelRequestData = BimProjectModelVO(
        ifcObject: null,
        userPrivilege: "110",
        hasViews: 'true',
        hasDiscussions: 'true',
        projectId: '2134298\$\$4Dizau',
        modelId: '46642\$\$17GDFw',
        projectName: 'Vivek_Mishra',
        modelCreationDate: '',
        publisherFullName: 'Vivek',
        modelTypeId: -1,
        lastAccessedDateTime: '',
        isFavourite: 1,
        lastUpdateDateTime: '',
        generateURI: false,
      );
      final props = modelRequestData.props;
      expect(props, isEmpty);
    });
  });

  group('BimProjectModelVO', () {
    test('fromJson should parse JSON correctly', () {
      final jsonString = '''{
  "BIMProjectModelVO": {
    "ifcObject": {
      "name": "Apartment A",
      "ifcObjects": [
        {
          "name": "Apartment_A",
          "ifcObjects": [
            {
              "bimModelIdField": "1",
              "name": "v1 - 19-Jul-2023 18:59 IST",
              "fileName": "Apartment_A.ifc",
              "revId": "27092328\$\$DuNEqD",
              "isMerged": false,
              "disciplineId": 0,
              "is_link": false,
              "filesize": 33590019,
              "folderId": "115928911\$\$xQDFKp",
              "fileLocation": "project_2155366/collabspace/folders/115928911/27092328.ifc",
              "is_last_uploaded": true,
              "bimIssueNumber": 0,
              "hsf_checksum": null,
              "bimIssueNumberModel": 0,
              "isDocAssociated": false,
              "docTitle": "Apartment_A",
              "publisherName": "kajal patil",
              "orgName": "!!!Project Preference",
              "floorList": [],
              "isChecked": false,
              "ifcName": "Apartment_A",
              "isDownloaded": false
            }
          ],
          "docId": "13571117\$\$wypMB7",
          "disciplineId": 0,
          "isDownload": false,
          "isDownloadCompleted": false,
          "isDownloading": false,
          "isQueue": false,
          "isClicked": false,
          "size": "",
          "tReceived": 8191,
          "tTotal": 1371452
        }
      ],
      "disciplineId": 0,
      "fileLocation": "Apartment A"
    },
    "user_privilege": "81",
    "has_views": "false",
    "has_discussions": "false",
    "project_id": "2155366\$\$Hf0srP",
    "model_id": "46782\$\$z6im76",
    "project_name": "CBIM_Data_Kajal",
    "model_creation_date": "2023-07-19 14:30:13.413",
    "publisher_full_name": "kajal patil My Asite Organisation",
    "model_type_id": 0,
    "last_accessed_date_time": "2023-08-25 06:47:42.73",
    "is_favourite": 0,
    "last_update_date_time": "2023-07-19 14:30:13.417",
    "generateURI": true
  }
}
''';

      final json = jsonDecode(jsonString);
      final bimProjectModelVO = BimProjectModelVO.fromJson(json['BIMProjectModelVO']);
      final bimProjectModel = BimProjectModel.fromJson(json);
      final bimJson = bimProjectModelVO.ifcObject!.ifcObjects!.first.ifcObjects!.first.toJson();
      expect(bimJson, equals({
        "bimModelIdField": "1",
        "name": "v1 - 19-Jul-2023 18:59 IST",
        "fileName": "Apartment_A.ifc",
        "revId": "27092328\$\$DuNEqD",
        "isMerged": false,
        "disciplineId": 0,
        "is_link": false,
        "filesize": 33590019,
        "folderId": "115928911\$\$xQDFKp",
        "fileLocation": "project_2155366/collabspace/folders/115928911/27092328.ifc",
        "is_last_uploaded": true,
        "bimIssueNumber": 0,
        "hsf_checksum": null,
        "bimIssueNumberModel": 0,
        "isDocAssociated": false,
        "docTitle": "Apartment_A",
        "publisherName": "kajal patil",
        "orgName": "!!!Project Preference",
        "floorList": [],
        "isChecked": false,
        "ifcName": "Apartment_A",
        "isDownloaded": false
      }));
      expect(bimProjectModel.toJson(), equals(json));
      expect(bimProjectModelVO.userPrivilege, '81');
      expect(bimProjectModelVO.ifcObject?.name, 'Apartment A');
      // Add more assertions for other properties...
    });

    test('toJson should convert object to JSON correctly', () {
      final bimProjectModelVO = BimProjectModelVO(
        userPrivilege: '81',
        ifcObject: IfcObject(name: 'Apartment A'),
      );

      final json = bimProjectModelVO.toJson();
      print(json);


      expect(json['user_privilege'], '81');

      expect(json['ifcObject']['name'], 'Apartment A');
    });
  });

}
