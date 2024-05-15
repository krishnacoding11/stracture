import 'dart:convert';
import 'package:field/data/model/offline_activity_vo.dart';
import 'package:test/test.dart';

  void main() {
    test('fromJson should convert JSON map to OfflineActivityVo object', () {
      final jsonString = '{"projectId": "12345", "formTypeId": "form_123", "formId": "form_567", "msgId": "msg_789", "actionId": "action_123", "distListId": "dist_456", "offlineRequestData": "data_here", "createdDateInMs": "1630444800000"}';
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      final offlineActivity = OfflineActivityVo.fromJson(jsonMap);

      expect(offlineActivity.projectId, equals("12345"));
      expect(offlineActivity.formTypeId, equals("form_123"));
      expect(offlineActivity.formId, equals("form_567"));
      expect(offlineActivity.msgId, equals("msg_789"));
      expect(offlineActivity.actionId, equals("action_123"));
      expect(offlineActivity.distListId, equals("dist_456"));
      expect(offlineActivity.offlineRequestData, equals("data_here"));
      expect(offlineActivity.createdDateInMs, equals("1630444800000"));
    });

    test('toJson should convert OfflineActivityVo object to JSON map', () {
      final offlineActivity = OfflineActivityVo(
        projectId: "12345",
        formTypeId: "form_123",
        formId: "form_567",
        msgId: "msg_789",
        actionId: "action_123",
        distListId: "dist_456",
        offlineRequestData: "data_here",
        createdDateInMs: "1630444800000",
      );

      final jsonMap = offlineActivity.toJson();

      expect(jsonMap['projectId'], equals("12345"));
      expect(jsonMap['formTypeId'], equals("form_123"));
      expect(jsonMap['formId'], equals("form_567"));
      expect(jsonMap['msgId'], equals("msg_789"));
      expect(jsonMap['actionId'], equals("action_123"));
      expect(jsonMap['distListId'], equals("dist_456"));
      expect(jsonMap['offlineRequestData'], equals("data_here"));
      expect(jsonMap['createdDateInMs'], equals("1630444800000"));
    });
  }