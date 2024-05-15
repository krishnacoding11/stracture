import 'dart:convert';
import 'package:field/data/model/tasklistingsearch_vo.dart';
import 'package:test/test.dart';

void main() {
  // Test the fromJson method for Tasklistingsearchvo
  test('fromJson should convert JSON string to Tasklistingsearchvo object', () {
    final jsonString = '{"criteria": [{"field": "name", "operator": 1, "values": ["John"]}], "groupField": 1, "groupRecordLimit": 10, "recordLimit": 50, "recordStart": 0}';
    final tasklistingsearchvo = tasklistingsearchvoFromJson(jsonString);

    expect(tasklistingsearchvo.groupField, equals(1));
    expect(tasklistingsearchvo.groupRecordLimit, equals(10));
    expect(tasklistingsearchvo.recordLimit, equals(50));
    expect(tasklistingsearchvo.recordStart, equals(0));

    expect(tasklistingsearchvo.criteria?.length, equals(1));
    expect(tasklistingsearchvo.criteria?[0].field, equals("name"));
    expect(tasklistingsearchvo.criteria?[0].operator, equals(1));
    expect(tasklistingsearchvo.criteria?[0].values, equals(["John"]));
  });

  // Test the toJson method for Tasklistingsearchvo
  test('toJson should convert Tasklistingsearchvo object to JSON string', () {
    final criteria = Criteria(field: "name", operator: 1, values: ["John"]);
    final tasklistingsearchvo = Tasklistingsearchvo(
      criteria: [criteria],
      groupField: 1,
      groupRecordLimit: 10,
      recordLimit: 50,
      recordStart: 0,
    );

    final jsonStr = tasklistingsearchvoToJson(tasklistingsearchvo);

    expect(jsonStr, equals('{"criteria":[{"field":"name","operator":1,"values":["John"]}],"groupField":1,"groupRecordLimit":10,"recordLimit":50,"recordStart":0}'));
  });

  // Test the fromJson method for Criteria
  test('fromJson should convert JSON string to Criteria object', () {
    final jsonString = '{"field": "name", "operator": 1, "values": ["John"]}';
    final criteria = criteriaFromJson(jsonString);

    expect(criteria.field, equals("name"));
    expect(criteria.operator, equals(1));
    expect(criteria.values, equals(["John"]));
  });

  // Test the toJson method for Criteria
  test('toJson should convert Criteria object to JSON string', () {
    final criteria = Criteria(field: "name", operator: 1, values: ["John"]);
    final jsonStr = criteriaToJson(criteria);

    expect(jsonStr, equals('{"field":"name","operator":1,"values":["John"]}'));
  });

  test('Tasklistingsearchvo copyWith', () {
    // Original Tasklistingsearchvo object
    Tasklistingsearchvo originalObject = Tasklistingsearchvo(
      criteria: [Criteria(field: 'name', operator: 1, values: ['John', 'Doe'])],
      groupField: 2,
      groupRecordLimit: 10,
      recordLimit: 100,
      recordStart: 0,
    );

    // Create a new object based on the original object with some properties updated
    Tasklistingsearchvo updatedObject = originalObject.copyWith(
      criteria: [Criteria(field: 'age', operator: 2, values: [25, 30])],
      //groupRecordLimit: 5,
    );

    // Verify that the properties are updated correctly
    expect(updatedObject.criteria!.length, 1);
    expect(updatedObject.criteria![0].field, 'age');
    expect(updatedObject.criteria![0].operator, 2);
    expect(updatedObject.criteria![0].values, [25, 30]);

    expect(updatedObject.groupField, 2);
    expect(updatedObject.groupRecordLimit, 10);
    expect(updatedObject.recordLimit, 100);
    expect(updatedObject.recordStart, 0);
  });

  test('Criteria copyWith method should return a new instance with updated values', () {
    // Create an instance of Criteria with initial values
    Criteria initialCriteria = Criteria(
      field: "StatusId",
      operator: 1,
      values: [0],
    );

    // Use copyWith to create a new instance with updated values
    Criteria updatedCriteria = initialCriteria.copyWith(
      field: "NewField",
      operator: 2,
      values: [1, 2, 3],
    );

    // Verify that the new instance has the updated values
    expect(updatedCriteria.field, "NewField");
    expect(updatedCriteria.operator, 2);
    expect(updatedCriteria.values, [1, 2, 3]);

    // Verify that the initial instance remains unchanged
    expect(initialCriteria.field, "StatusId");
    expect(initialCriteria.operator, 1);
    expect(initialCriteria.values, [0]);

    updatedCriteria = initialCriteria.copyWith(
      field: null,
      operator: null,
      values: null,
    );

    // Verify that the new instance has the updated values
    expect(updatedCriteria.field, "StatusId");
    expect(updatedCriteria.operator, 1);
    expect(updatedCriteria.values, [0]);
  });


}
