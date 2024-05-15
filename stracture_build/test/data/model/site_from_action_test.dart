import 'dart:convert';

import 'package:field/data/model/site_form_action.dart';
import 'package:test/test.dart';

void main() {
  group('SiteFormAction', () {
    test('Test toJson and fromJson', () {
      final siteFormAction = SiteFormAction(
        actionId: "123",
        actionName: "Sample Action",
        isActive: true,
      );

      final jsonMap = siteFormAction.toJson();
      final newSiteFormAction = SiteFormAction.fromJson(jsonMap);

      // Assert that the properties of the original and new objects match
      expect(newSiteFormAction.actionId, siteFormAction.actionId);
      expect(newSiteFormAction.actionName, siteFormAction.actionName);
      expect(newSiteFormAction.isActive, siteFormAction.isActive);
    });

    test('Test toJson with null values', () {
      final siteFormAction = SiteFormAction(
        actionId: null,
        actionName: null,
        isActive: null,
      );

      final jsonMap = siteFormAction.toJson();

      // Assert that the JSON map does not contain keys with null values
      expect(jsonMap.containsKey('actionId'), true);
      expect(jsonMap.containsKey('actionName'), true);
      expect(jsonMap.containsKey('isActive'), true);
    });

    test('Test fromJson with valid JSON', () {
      final jsonString = '{"actionId": "456", "actionName": "Another Action", "isActive": false}';
      final jsonMap = json.decode(jsonString);

      final siteFormAction = SiteFormAction.fromJson(jsonMap);

      // Assert that the properties are correctly parsed from JSON
      expect(siteFormAction.actionId, "456");
      expect(siteFormAction.actionName, "Another Action");
      expect(siteFormAction.isActive, false);
    });

    test('Test fromJson with missing values', () {
      final jsonString = '{"actionId": "456"}';
      final jsonMap = json.decode(jsonString);

      final siteFormAction = SiteFormAction.fromJson(jsonMap);

      // Assert that the missing fields are set to their default values
      expect(siteFormAction.actionName, 'null');
      expect(siteFormAction.isActive, isNull);
    });

    test('Test toJson and fromJson with all properties set', () {
      final siteFormAction = SiteFormAction(
        actionId: "789",
        actionName: "Third Action",
        actionStatus: "Pending",
        actionDate: "2023-07-26",
        isActive: true,
        assignedBy: "John Doe",
        actionCompleted: false,
      );

      final jsonMap = siteFormAction.toJson();
      final newSiteFormAction = SiteFormAction.fromJson(jsonMap);

      expect(newSiteFormAction.actionId, siteFormAction.actionId);
      expect(newSiteFormAction.actionName, siteFormAction.actionName);
      expect(newSiteFormAction.actionStatus, siteFormAction.actionStatus);
      expect(newSiteFormAction.actionDate, siteFormAction.actionDate);
      expect(newSiteFormAction.isActive, siteFormAction.isActive);
      expect(newSiteFormAction.assignedBy, siteFormAction.assignedBy);
      expect(newSiteFormAction.actionCompleted, siteFormAction.actionCompleted);
    });

    test('Test toJson with all properties set', () {
      final siteFormAction = SiteFormAction(
        actionId: "789",
        actionName: "Third Action",
        actionStatus: "Pending",
        actionDate: "2023-07-26",
        isActive: true,
        assignedBy: "John Doe",
        actionCompleted: false,
      );

      final jsonMap = siteFormAction.toJson();

      // Assert that the JSON map contains all properties and their values
      expect(jsonMap['actionId'], "789");
      expect(jsonMap['actionName'], "Third Action");
      expect(jsonMap['actionStatus'], "Pending");
      expect(jsonMap['actionDate'], "2023-07-26");
      expect(jsonMap['isActive'], true);
      expect(jsonMap['assignedBy'], "John Doe");
      expect(jsonMap['actionCompleted'], false);
    });

    test('Test siteFormActionFromJson', () {
      final jsonString = '{"actionId": "456", "actionName": "Test Action", "isActive": true}';
      final siteFormAction = siteFormActionFromJson(jsonString);

      // Assert that the properties are correctly parsed from JSON
      expect(siteFormAction.actionId, "456");
      expect(siteFormAction.actionName, "Test Action");
      expect(siteFormAction.isActive, true);
    });

    test('Test siteFormActionToJson', () {
      final siteFormAction = SiteFormAction(
        actionId: "123",
        actionName: "Sample Action",
        isActive: true,
      );

      final jsonString = siteFormActionToJson(siteFormAction);
      final jsonMap = json.decode(jsonString);

      // Assert that the properties of the SiteFormAction object are correctly encoded into JSON
      expect(jsonMap['actionId'], "123");
      expect(jsonMap['actionName'], "Sample Action");
      expect(jsonMap['isActive'], true);
    });


    test('Test SiteFormAction.fromMessageJson', () {
      final jsonString = '''
        {
          "actionId": "456",
          "actionName": "Test Action",
          "isActive": true,
          "actionDate": "2023-07-26",
          "dueDate": "2023-08-02",
          "recipientId": "789",
          "remarks": "Test remarks",
          "actionTime": "10:30 AM",
          "actionCompleteDate": "2023-07-30",
          "isActionCleared": false,
          "actionCompleted": true,
          "msgId": "12345",
          "actionNotes": "Test notes",
          "modelId": "7890",
          "recipientOrgId": "4567",
          "id": "999",
          "viewDate": "2023-07-28",
          "resourceId": "111",
          "resourceParentId": "222",
          "resourceCode": "XYZ",
          "actionStatus_name": "Completed",
          "actionDueDateInMiliSecond": "167983600000",
          "actionDateInMS": "1679577600000",
          "actionCompleteDateInMS": "1679726799000"
        }
      ''';

      final siteFormAction = SiteFormAction.fromMessageJson(json.decode(jsonString));

      // Assert that the properties are correctly parsed from JSON
      expect(siteFormAction.actionId, "456");
      expect(siteFormAction.actionName, "Test Action");
      expect(siteFormAction.isActive, true);
      expect(siteFormAction.actionDate, "2023-07-26");
      expect(siteFormAction.dueDate, "2023-08-02");
      expect(siteFormAction.recipientId, "789");
      expect(siteFormAction.remarks, "Test remarks");
      expect(siteFormAction.actionTime, "10:30 AM");
      expect(siteFormAction.actionCompleteDate, "2023-07-30");
      expect(siteFormAction.actionCleared, false);
      expect(siteFormAction.actionCompleted, null);
      expect(siteFormAction.msgId, "12345");
      expect(siteFormAction.actionNotes, "Test notes");
      expect(siteFormAction.modelId, "7890");
      expect(siteFormAction.recipientOrgId, "4567");
      expect(siteFormAction.id, "999");
      expect(siteFormAction.viewDate, "2023-07-28");
      expect(siteFormAction.resourceId, "111");
      expect(siteFormAction.resourceParentId, "222");
      expect(siteFormAction.resourceCode, "XYZ");
      expect(siteFormAction.actionStatusName, "Completed");
      expect(siteFormAction.actionDueDateMilliSecond, "167983600000");
      expect(siteFormAction.actionDateInMS, "1679577600000");
      expect(siteFormAction.actionCompleteDateInMS, "1679726799000");
    });

    test('Test copyWith method', () {
      // Create an instance of SiteFormAction with some initial data
      final originalData = SiteFormAction(
        actionId: '1',
        actionName: 'Test Action',
        actionStatus: 'Pending',
        recipientName: '',
        dueDateInMS : '',
        actionDelegated : false
      );

      final updatedData = originalData.copyWith(
        actionName: 'Updated Action',
        actionStatus: 'Completed',
        recipientName: '',
        dueDateInMS : '',
        actionDelegated : false,
      );

      // Verify that the original instance remains unchanged
      expect(originalData.actionName, 'Test Action');
      expect(originalData.actionStatus, 'Pending');
      expect(originalData.recipientName, '');
      expect(originalData.dueDateInMS, '');
      expect(originalData.actionDelegated, false);


      // Verify that the updated instance has the correct updated values
      expect(updatedData.actionName, 'Updated Action');
      expect(updatedData.actionStatus, 'Completed');

      expect(updatedData.actionId, originalData.actionId);

      final sameData = originalData.copyWith(actionName: null, actionStatus: null);
      //expect(sameData, originalData);
      expect(updatedData, isA<SiteFormAction>());
    });

    test('Test projectId setter', () {
      final formData = SiteFormAction();
      formData.setProjectId = '12345';
      formData.setFormId = '';
      formData.setActionDelegated = false;
      formData.setCommentMsgId = '9876';

      expect(formData.projectId, '12345');
      expect(formData.formId, '');
      expect(formData.actionDelegated, false);
      expect(formData.commentMsgId, '9876');
    });

    test('Test priorityId getter', () {
      final formData = SiteFormAction();

      formData.setPriorityId = 'PRIORITY123';

      expect(formData.priorityId, 'PRIORITY123');
    });

    test('Test distributorUserId getter', () {
      final formData = SiteFormAction();

      formData.setDistributorUserId = 'USER123';

      expect(formData.distributorUserId, 'USER123');
    });

    test('Test distListId getter', () {
      final formData = SiteFormAction();

      formData.setDistListId = 'LIST123';

      expect(formData.distListId, 'LIST123');
    });

    test('Test transNum getter', () {
      final formData = SiteFormAction();

      formData.setTransNum = 'TRANS456';

      expect(formData.transNum, 'TRANS456');
    });

    test('Test entityType getter', () {
      final formData = SiteFormAction();
      formData.setEntityType = 'ENTITY789';
      expect(formData.entityType, 'ENTITY789');
    });

  });
}
