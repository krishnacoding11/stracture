import 'package:field/data/model/quality_plan_list_vo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QualityPlanListVo', () {
    test('toJson should convert QualityPlanListVo object to JSON map', () {
      final columnHeader1 = ColumnHeader(
        id: '1',
        fieldName: 'field1',
        colDisplayName: 'Column 1',
        colType: 'type1',
      );

      final columnHeader2 = ColumnHeader(
        id: '2',
        fieldName: 'field2',
        colDisplayName: 'Column 2',
        colType: 'type2',
      );

      final data1 = Data(
        id: 1,
        projectId: 'proj1',
        planTitle: 'Plan 1',
      );

      final data2 = Data(
        id: 2,
        projectId: 'proj2',
        planTitle: 'Plan 2',
      );

      final qualityPlanListVo = QualityPlanListVo(
        totalDocs: 100,
        recordBatchSize: 10,
        listingType: 1,
        currentPageNo: 1,
        recordStartFrom: 0,
        columnHeader: [columnHeader1, columnHeader2],
        data: [data1, data2],
        sortField: 'fieldName',
        sortFieldType: 'type',
        sortOrder: 'asc',
        editable: true,
        isIncludeSubFolder: false,
        totalListData: 200,
      );

      final expectedJsonMap = {
        'totalDocs': 100,
        'recordBatchSize': 10,
        'listingType': 1,
        'currentPageNo': 1,
        'recordStartFrom': 0,
        'columnHeader': [
          columnHeader1.toJson(),
          columnHeader2.toJson(),
        ],
        'data': [
          data1.toJson(),
          data2.toJson(),
        ],
        'sortField': 'fieldName',
        'sortFieldType': 'type',
        'sortOrder': 'asc',
        'editable': true,
        'isIncludeSubFolder': false,
        'totalListData': 200,
      };

      expect(qualityPlanListVo.toJson(), equals(expectedJsonMap));
    });

    test('fromJson should create QualityPlanListVo object from JSON map', () {
      final jsonMap = {
        'totalDocs': 100,
        'recordBatchSize': 10,
        'listingType': 1,
        'currentPageNo': 1,
        'recordStartFrom': 0,
        'columnHeader': [
          {
            'id': '1',
            'fieldName': 'field1',
            'colDisplayName': 'Column 1',
            'colType': 'type1',
          },
          {
            'id': '2',
            'fieldName': 'field2',
            'colDisplayName': 'Column 2',
            'colType': 'type2',
          },
        ],
        'data': [
          {
            'id': 1,
            'projectId': 'proj1',
            'planTitle': 'Plan 1',
          },
          {
            'id': 2,
            'projectId': 'proj2',
            'planTitle': 'Plan 2',
          },
        ],
        'sortField': 'fieldName',
        'sortFieldType': 'type',
        'sortOrder': 'asc',
        'editable': true,
        'isIncludeSubFolder': false,
        'totalListData': 200,
      };

      final qualityPlanListVo = QualityPlanListVo.fromJson(jsonMap);

      expect(qualityPlanListVo.totalDocs, equals(100));
      expect(qualityPlanListVo.recordBatchSize, equals(10));
      expect(qualityPlanListVo.listingType, equals(1));
      expect(qualityPlanListVo.currentPageNo, equals(1));
      expect(qualityPlanListVo.recordStartFrom, equals(0));

      // Test columnHeader list
      expect(qualityPlanListVo.columnHeader, hasLength(2));
      expect(qualityPlanListVo.columnHeader![0].id, equals('1'));
      expect(qualityPlanListVo.columnHeader![0].fieldName, equals('field1'));
      expect(qualityPlanListVo.columnHeader![0].colDisplayName, equals('Column 1'));
      expect(qualityPlanListVo.columnHeader![1].id, equals('2'));
      expect(qualityPlanListVo.columnHeader![1].fieldName, equals('field2'));
      expect(qualityPlanListVo.columnHeader![1].colDisplayName, equals('Column 2'));

      // Test data list
      expect(qualityPlanListVo.data, hasLength(2));
      expect(qualityPlanListVo.data![0].id, equals(1));
      expect(qualityPlanListVo.data![0].projectId, equals('proj1'));
      expect(qualityPlanListVo.data![0].planTitle, equals('Plan 1'));
      expect(qualityPlanListVo.data![1].id, equals(2));
      expect(qualityPlanListVo.data![1].projectId, equals('proj2'));
      expect(qualityPlanListVo.data![1].planTitle, equals('Plan 2'));

      expect(qualityPlanListVo.sortField, equals('fieldName'));
      expect(qualityPlanListVo.sortFieldType, equals('type'));
      expect(qualityPlanListVo.sortOrder, equals('asc'));
      expect(qualityPlanListVo.editable, isTrue);
      expect(qualityPlanListVo.isIncludeSubFolder, isFalse);
      expect(qualityPlanListVo.totalListData, equals(200));
    });

    test('parseJson should create QualityPlanListVo object from JSON response', () {
      final jsonResponse = '''
        {
          "totalDocs": 100,
          "recordBatchSize": 10,
          "listingType": 1,
          "currentPageNo": 1,
          "recordStartFrom": 0,
          "columnHeader": [
            {
              "id": "1",
              "fieldName": "field1",
              "colDisplayName": "Column 1",
              "colType": "type1"
            },
            {
              "id": "2",
              "fieldName": "field2",
              "colDisplayName": "Column 2",
              "colType": "type2"
            }
          ],
          "data": [
            {
              "id": 1,
              "projectId": "proj1",
              "planTitle": "Plan 1"
            },
            {
              "id": 2,
              "projectId": "proj2",
              "planTitle": "Plan 2"
            }
          ],
          "sortField": "fieldName",
          "sortFieldType": "type",
          "sortOrder": "asc",
          "editable": true,
          "isIncludeSubFolder": false,
          "totalListData": 200
        }
      ''';

      final qualityPlanListVo = QualityPlanListVo.parseJson(jsonResponse);

      expect(qualityPlanListVo.totalDocs, equals(100));
      expect(qualityPlanListVo.recordBatchSize, equals(10));
      expect(qualityPlanListVo.listingType, equals(1));
      expect(qualityPlanListVo.currentPageNo, equals(1));
      expect(qualityPlanListVo.recordStartFrom, equals(0));

      // Test columnHeader list
      expect(qualityPlanListVo.columnHeader, hasLength(2));
      expect(qualityPlanListVo.columnHeader![0].id, equals('1'));
      expect(qualityPlanListVo.columnHeader![0].fieldName, equals('field1'));
      expect(qualityPlanListVo.columnHeader![0].colDisplayName, equals('Column 1'));
      expect(qualityPlanListVo.columnHeader![1].id, equals('2'));
      expect(qualityPlanListVo.columnHeader![1].fieldName, equals('field2'));
      expect(qualityPlanListVo.columnHeader![1].colDisplayName, equals('Column 2'));

      // Test data list
      expect(qualityPlanListVo.data, hasLength(2));
      expect(qualityPlanListVo.data![0].id, equals(1));
      expect(qualityPlanListVo.data![0].projectId, equals('proj1'));
      expect(qualityPlanListVo.data![0].planTitle, equals('Plan 1'));
      expect(qualityPlanListVo.data![1].id, equals(2));
      expect(qualityPlanListVo.data![1].projectId, equals('proj2'));
      expect(qualityPlanListVo.data![1].planTitle, equals('Plan 2'));

      expect(qualityPlanListVo.sortField, equals('fieldName'));
      expect(qualityPlanListVo.sortFieldType, equals('type'));
      expect(qualityPlanListVo.sortOrder, equals('asc'));
      expect(qualityPlanListVo.editable, isTrue);
      expect(qualityPlanListVo.isIncludeSubFolder, isFalse);
      expect(qualityPlanListVo.totalListData, equals(200));
    });
  });
}
