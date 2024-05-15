import 'package:field/data/model/apptype_group_vo.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:test/test.dart';

void main() {
  group('AppTypeGroup Tests', () {
    test('AppTypeGroup.fromJson should create a AppTypeGroup object from JSON', () {
      // Sample JSON data representing a FloorData object
      final json = {
        "formTypeName": "dsdfdf",
        "isExpanded": true,
        "formAppType": [
          {"formTypeID": "floor_plan_1", "formTypeName": "dfdf", "code": "sdds", "appBuilderCode": "Level 1", "projectID": "sdd", "msgId": "dcdf", "formId": "54ddf", "dataCenterId": 1021, "createFormsLimit": 2, "createdMsgCount": 5, "draft_count": 5, "draftMsgId": 122585, "appTypeId": 15245, "isFromWhere": 5, "projectName": "ddffsa", "instanceGroupId": "proj_456", "templateType": 5454, "isRecent": false, "formTypeGroupName": "prosdsj_456", "generateURI": true, "isMarkDefault": false},
          // Add more floorDetail objects as needed...
        ],
      };

      // Create a FloorData object from the JSON data
      final appTypeGroupData = AppTypeGroup.fromJson(json);

      // Check if the properties are correctly set
      expect(appTypeGroupData.formTypeName, "dsdfdf");
      expect(appTypeGroupData.isExpanded, true);
      expect(appTypeGroupData.formAppType, isNotNull);
      expect(appTypeGroupData.formAppType?.length, 1);
      expect(appTypeGroupData.formAppType?[0].formTypeID, "floor_plan_1");
      expect(appTypeGroupData.formAppType?[0].formTypeName, "dfdf");
      expect(appTypeGroupData.formAppType?[0].code, "sdds");
      expect(appTypeGroupData.formAppType?[0].appBuilderCode, "Level 1");
      expect(appTypeGroupData.formAppType?[0].projectID, "sdd");
      expect(appTypeGroupData.formAppType?[0].msgId, "dcdf");
      expect(appTypeGroupData.formAppType?[0].formId, "54ddf");
      expect(appTypeGroupData.formAppType?[0].dataCenterId, 1021);
      expect(appTypeGroupData.formAppType?[0].createFormsLimit, 2);
      expect(appTypeGroupData.formAppType?[0].draftCount, 5);
      expect(appTypeGroupData.formAppType?[0].createdMsgCount, 5);
      expect(appTypeGroupData.formAppType?[0].draftMsgId, 122585);
      expect(appTypeGroupData.formAppType?[0].appTypeId, 15245);
      expect(appTypeGroupData.formAppType?[0].isFromWhere, 5);
      expect(appTypeGroupData.formAppType?[0].projectName, "ddffsa");
      expect(appTypeGroupData.formAppType?[0].instanceGroupId, "proj_456");
      expect(appTypeGroupData.formAppType?[0].templateType, 5454);
      expect(appTypeGroupData.formAppType?[0].isRecent, false);
      expect(appTypeGroupData.formAppType?[0].formTypeGroupName, "prosdsj_456");
      expect(appTypeGroupData.formAppType?[0].generateURI, true);
      expect(appTypeGroupData.formAppType?[0].isMarkDefault, false);
    });

    test('FloorData.toJson should convert a AppType object to JSON', () {
      // Create sample FloorDetail objects
      final appType = AppType(
        formTypeID: "floor_plan_1",
        formTypeName: "dfdf",
        code: "sdds",
        appBuilderCode: "Level 1",
        projectID: "sdd",
        msgId: "dcdf",
        formId: "54ddf",
        dataCenterId: 1021,
        createFormsLimit: 2,
        draftCount: 5,
        createdMsgCount: 5,
        draftMsgId: 122585,
        appTypeId: 15245,
        isFromWhere: 5,
        projectName: "ddffsa",
        instanceGroupId: "proj_456",
        templateType: 5454,
        isRecent: false,
        formTypeGroupName: "prosdsj_456",
        generateURI: true,
        isMarkDefault: false,
      );

      // Create a sample FloorData object
      final floorData = AppTypeGroup(
        formTypeName: "dsdfdf",
        isExpanded:true,
        formAppType: [appType],
      );

      // Convert the FloorData object to JSON
      final json = floorData.copy();

      expect(json.formTypeName, "dsdfdf");
      expect(json.isExpanded, true);
      expect(json.formAppType, isNotNull);
      expect(json.formAppType?.length, 1);
      expect(json.formAppType?[0].formTypeID, "floor_plan_1");
      expect(json.formAppType?[0].formTypeName, "dfdf");
      expect(json.formAppType?[0].code, "sdds");
      expect(json.formAppType?[0].appBuilderCode, "Level 1");
      expect(json.formAppType?[0].projectID, "sdd");
      expect(json.formAppType?[0].msgId, "dcdf");
      expect(json.formAppType?[0].formId, "54ddf");
      expect(json.formAppType?[0].dataCenterId, 1021);
      expect(json.formAppType?[0].createFormsLimit, 2);
      expect(json.formAppType?[0].draftCount, 5);
      expect(json.formAppType?[0].createdMsgCount, 5);
      expect(json.formAppType?[0].draftMsgId, 122585);
      expect(json.formAppType?[0].appTypeId, 15245);
      expect(json.formAppType?[0].isFromWhere, 5);
      expect(json.formAppType?[0].projectName, "ddffsa");
      expect(json.formAppType?[0].instanceGroupId, "proj_456");
      expect(json.formAppType?[0].templateType, 5454);
      expect(json.formAppType?[0].isRecent, false);
      expect(json.formAppType?[0].formTypeGroupName, "prosdsj_456");
      expect(json.formAppType?[0].generateURI, true);
      expect(json.formAppType?[0].isMarkDefault, false);
    });
  });


}
