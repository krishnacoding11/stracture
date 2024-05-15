import 'dart:convert';

import 'package:field/data/model/quality_search_vo.dart';
import 'package:test/test.dart';

void main() {
  group('PopupToData', () {
    test('Constructor creates an instance with correct values', () {
      final filterQueryVOs1 = FilterQueryVOs(id: 1, fieldName: 'Field1');
      final filterQueryVOs2 = FilterQueryVOs(id: 2, fieldName: 'Field2');
      final filterQueryVOsList = [filterQueryVOs1, filterQueryVOs2];

      final filterVOs = FilterVOs(
        id: 100,
        userId: 200,
        filterName: 'Filter 1',
        listingTypeId: 300,
        subListingTypeId: 400,
        isUnsavedFilter: true,
        creationDate: '2023-08-01',
        filterQueryVOs: filterQueryVOsList,
        isFavorite: true,
        isRecent: false,
        isMyAction: true,
        docCount: 50,
        isEditable: false,
        isShared: true,
        originatorName: 'User1',
        originatorId: 500,
        userAccesibleDCIds: [600, 700],
        isAccessByDashboardShareOnly: false,
        dueDateId: 800,
        generateURI: true,
      );

      expect(filterVOs.id, 100);
      expect(filterVOs.userId, 200);
      expect(filterVOs.filterName, 'Filter 1');
      expect(filterVOs.listingTypeId, 300);
      expect(filterVOs.subListingTypeId, 400);
      expect(filterVOs.isUnsavedFilter, true);
      expect(filterVOs.creationDate, '2023-08-01');
      expect(filterVOs.filterQueryVOs, filterQueryVOsList);
      expect(filterVOs.isFavorite, true);
      expect(filterVOs.isRecent, false);
      expect(filterVOs.isMyAction, true);
      expect(filterVOs.docCount, 50);
      expect(filterVOs.isEditable, false);
      expect(filterVOs.isShared, true);
      expect(filterVOs.originatorName, 'User1');
      expect(filterVOs.originatorId, 500);
      expect(filterVOs.userAccesibleDCIds, [600, 700]);
      expect(filterVOs.isAccessByDashboardShareOnly, false);
      expect(filterVOs.dueDateId, 800);
      expect(filterVOs.generateURI, true);
    });

    test('fromJson creates an instance with correct values', () {
      final jsonData = {
        'id': 101,
        'userId': 201,
        'filterName': 'Filter 2',
        'listingTypeId': 301,
        'subListingTypeId': 401,
        'isUnsavedFilter': false,
        'creationDate': '2023-08-02',
        'filterQueryVOs': [
          {'id': 3, 'fieldName': 'Field3'},
          {'id': 4, 'fieldName': 'Field4'},
        ],
        'isFavorite': false,
        'isRecent': true,
        'isMyAction': false,
        'docCount': 75,
        'isEditable': true,
        'isShared': false,
        'originatorName': 'User2',
        'originatorId': 501,
        'userAccesibleDCIds': [601, 701],
        'isAccessByDashboardShareOnly': true,
        'dueDateId': 801,
        'generateURI': false,
      };

      final filterVOs = FilterVOs.fromJson(jsonData);

      expect(filterVOs.id, 101);
      expect(filterVOs.userId, 201);
      expect(filterVOs.filterName, 'Filter 2');
      expect(filterVOs.listingTypeId, 301);
      expect(filterVOs.subListingTypeId, 401);
      expect(filterVOs.isUnsavedFilter, false);
      expect(filterVOs.creationDate, '2023-08-02');
      expect(filterVOs.filterQueryVOs, hasLength(2));
      expect(filterVOs.isFavorite, false);
      expect(filterVOs.isRecent, true);
      expect(filterVOs.isMyAction, false);
      expect(filterVOs.docCount, 75);
      expect(filterVOs.isEditable, true);
      expect(filterVOs.isShared, false);
      expect(filterVOs.originatorName, 'User2');
      expect(filterVOs.originatorId, 501);
      expect(filterVOs.userAccesibleDCIds, [601, 701]);
      expect(filterVOs.isAccessByDashboardShareOnly, true);
      expect(filterVOs.dueDateId, 801);
      expect(filterVOs.generateURI, false);
    });

    test('copyWith creates a copy with updated values', () {
      final originalData = FilterVOs(
        id: 102,
        userId: 202,
        filterName: 'Filter 3',
        listingTypeId: 302,
        subListingTypeId: 402,
        isUnsavedFilter: false,
        creationDate: '2023-08-03',
        filterQueryVOs: [FilterQueryVOs(id: 5, fieldName: 'Field5')],
        isFavorite: true,
        isRecent: true,
        isMyAction: true,
        docCount: 100,
        isEditable: true,
        isShared: true,
        originatorName: 'User3',
        originatorId: 502,
        userAccesibleDCIds: [602, 702],
        isAccessByDashboardShareOnly: true,
        dueDateId: 802,
        generateURI: true,
      );

      final updatedData = originalData.copyWith(
        id: 103,
        userId: 203,
        filterName: 'Filter 4',
        listingTypeId: 303,
        subListingTypeId: 403,
        isUnsavedFilter: true,
        creationDate: '2023-08-04',
        filterQueryVOs: null,
        isFavorite: false,
        isRecent: false,
        isMyAction: false,
        docCount: 200,
        isEditable: false,
        isShared: false,
        originatorName: 'User4',
        originatorId: 503,
        userAccesibleDCIds: null,
        isAccessByDashboardShareOnly: false,
        dueDateId: 803,
        generateURI: false,
      );

      expect(updatedData.id, 103);
      expect(updatedData.userId, 203);
      expect(updatedData.filterName, 'Filter 4');
      expect(updatedData.listingTypeId, 303);
      expect(updatedData.subListingTypeId, 403);
      expect(updatedData.isUnsavedFilter, true);
      expect(updatedData.creationDate, '2023-08-04');
      // expect(updatedData.filterQueryVOs, isA<FilterQueryVOs>());
      expect(updatedData.isFavorite, false);
      expect(updatedData.isRecent, false);
      expect(updatedData.isMyAction, false);
      expect(updatedData.docCount, 200);
      expect(updatedData.isEditable, false);
      expect(updatedData.isShared, false);
      expect(updatedData.originatorName, 'User4');
      expect(updatedData.originatorId, 503);
      expect(updatedData.userAccesibleDCIds, [602, 702]);
      expect(updatedData.isAccessByDashboardShareOnly, false);
      expect(updatedData.dueDateId, 803);
      expect(updatedData.generateURI, false);
    });

    test('toJson returns the correct JSON map', () {
      final filterQueryVOs1 = FilterQueryVOs(id: 1, fieldName: 'Field1');
      final filterQueryVOs2 = FilterQueryVOs(id: 2, fieldName: 'Field2');
      final filterQueryVOsList = [filterQueryVOs1, filterQueryVOs2];

      final filterVOs = FilterVOs(
        id: 104,
        userId: 204,
        filterName: 'Filter 5',
        listingTypeId: 304,
        subListingTypeId: 404,
        isUnsavedFilter: true,
        creationDate: '2023-08-05',
        filterQueryVOs: filterQueryVOsList,
        isFavorite: true,
        isRecent: false,
        isMyAction: true,
        docCount: 50,
        isEditable: false,
        isShared: true,
        originatorName: 'User5',
        originatorId: 504,
        userAccesibleDCIds: [604, 704],
        isAccessByDashboardShareOnly: false,
        dueDateId: 804,
        generateURI: true,
      );

      final jsonMap = filterVOs.toJson();

      expect(jsonMap['id'], 104);
      expect(jsonMap['userId'], 204);
      expect(jsonMap['filterName'], 'Filter 5');
      expect(jsonMap['listingTypeId'], 304);
      expect(jsonMap['subListingTypeId'], 404);
      expect(jsonMap['isUnsavedFilter'], true);
      expect(jsonMap['creationDate'], '2023-08-05');
      expect(jsonMap['filterQueryVOs'], hasLength(2));
      expect(jsonMap['isFavorite'], true);
      expect(jsonMap['isRecent'], false);
      expect(jsonMap['isMyAction'], true);
      expect(jsonMap['docCount'], 50);
      expect(jsonMap['isEditable'], false);
      expect(jsonMap['isShared'], true);
      expect(jsonMap['originatorName'], 'User5');
      expect(jsonMap['originatorId'], 504);
      expect(jsonMap['userAccesibleDCIds'], [604, 704]);
      expect(jsonMap['isAccessByDashboardShareOnly'], false);
      expect(jsonMap['dueDateId'], 804);
      expect(jsonMap['generateURI'], true);
    });

    test('Constructor creates an instance with correct values', () {
      final popupToData1 = PopupToData(id: '1', value: 'Data 1');
      final popupToData2 = PopupToData(id: '2', value: 'Data 2');

      var popupTo = PopupTo(
        totalDocs: 100,
        recordBatchSize: 10,
        data: [popupToData1, popupToData2],
        isSortRequired: true,
        isReviewEnableProjectSelected: false,
        isAmessageProjectSelected: true,
        generateURI: false,
      );

      expect(popupTo.totalDocs, 100);
      expect(popupTo.recordBatchSize, 10);
      expect(popupTo.data, [popupToData1, popupToData2]);
      expect(popupTo.isSortRequired, true);
      expect(popupTo.isReviewEnableProjectSelected, false);
      expect(popupTo.isAmessageProjectSelected, true);
      expect(popupTo.generateURI, false);
    });

    test('fromJson creates an instance with correct values', () {
      final jsonData = {
        'totalDocs': 200,
        'recordBatchSize': 5,
        'data': [
          {'id': '3', 'value': 'Data 3'},
          {'id': '4', 'value': 'Data 4'},
        ],
        'isSortRequired': true,
        'isReviewEnableProjectSelected': true,
        'isAmessageProjectSelected': false,
        'generateURI': true,
      };

      final popupTo = PopupTo.fromJson(jsonData);

      expect(popupTo.totalDocs, 200);
      expect(popupTo.recordBatchSize, 5);
      expect(popupTo.data, hasLength(2));
      expect(popupTo.isSortRequired, true);
      expect(popupTo.isReviewEnableProjectSelected, true);
      expect(popupTo.isAmessageProjectSelected, false);
      expect(popupTo.generateURI, true);
    });

    test('copyWith creates a copy with updated values', () {
      final originalData = PopupTo(
        totalDocs: 300,
        recordBatchSize: 15,
        data: [
          PopupToData(id: '5', value: 'Data 5'),
          PopupToData(id: '6', value: 'Data 6'),
        ],
        isSortRequired: false,
        isReviewEnableProjectSelected: true,
        isAmessageProjectSelected: true,
        generateURI: false,
      );

      final updatedData = originalData.copyWith(
        totalDocs: 400,
        recordBatchSize: 20,
        data: [
          PopupToData(id: '7', value: 'Data 7'),
        ],
        isSortRequired: true,
        isReviewEnableProjectSelected: false,
        isAmessageProjectSelected: false,
        generateURI: true,
      );

      expect(updatedData.totalDocs, 400);
      expect(updatedData.recordBatchSize, 20);
      expect(updatedData.data, hasLength(1));
      expect(updatedData.isSortRequired, true);
      expect(updatedData.isReviewEnableProjectSelected, false);
      expect(updatedData.isAmessageProjectSelected, false);
      expect(updatedData.generateURI, true);
    });

    test('toJson returns the correct JSON map', () {
      final popupToData = PopupToData(id: '8', value: 'Data 8');
      final popupTo = PopupTo(
        totalDocs: 500,
        recordBatchSize: 25,
        data: [popupToData],
        isSortRequired: true,
        isReviewEnableProjectSelected: true,
        isAmessageProjectSelected: true,
        generateURI: true,
      );

      final jsonMap = popupTo.toJson();

      expect(jsonMap['totalDocs'], 500);
      expect(jsonMap['recordBatchSize'], 25);
      expect(jsonMap['data'], hasLength(1));
      expect(jsonMap['isSortRequired'], true);
      expect(jsonMap['isReviewEnableProjectSelected'], true);
      expect(jsonMap['isAmessageProjectSelected'], true);
      expect(jsonMap['generateURI'], true);
    });

    test('Constructor creates an instance with correct values', () {
      final popupData = PopupToData(
        id: '1',
        value: 'Sample Value',
        dataCenterId: 1001,
        isSelected: true,
        imgId: 12345,
        isActive: false,
      );

      expect(popupData.id, '1');
      expect(popupData.value, 'Sample Value');
      expect(popupData.dataCenterId, 1001);
      expect(popupData.isSelected, true);
      expect(popupData.imgId, 12345);
      expect(popupData.isActive, false);
    });

    test('fromJson creates an instance with correct values', () {
      final json = {
        'id': '2',
        'value': 'Another Value',
        'dataCenterId': 2001,
        'isSelected': false,
        'imgId': 67890,
        'isActive': true,
      };
      final popupData = PopupToData.fromJson(json);

      expect(popupData.id, '2');
      expect(popupData.value, 'Another Value');
      expect(popupData.dataCenterId, 2001);
      expect(popupData.isSelected, false);
      expect(popupData.imgId, 67890);
      expect(popupData.isActive, true);
    });

    test('copyWith creates a copy with updated values', () {
      final originalData = PopupToData(
        id: '3',
        value: 'Original Value',
        dataCenterId: 3001,
        isSelected: false,
        imgId: 11111,
        isActive: true,
      );

      final updatedData = originalData.copyWith(
        id: '4',
        value: 'Updated Value',
        dataCenterId: 4001,
        isSelected: true,
        imgId: 99999,
        isActive: false,
      );

      expect(updatedData.id, '4');
      expect(updatedData.value, 'Updated Value');
      expect(updatedData.dataCenterId, 4001);
      expect(updatedData.isSelected, true);
      expect(updatedData.imgId, 99999);
      expect(updatedData.isActive, false);
    });

    test('toJson returns the correct JSON map', () {
      var popupData = PopupToData(
        id: '5',
        value: 'JSON Value',
        dataCenterId: 5001,
        isSelected: true,
        imgId: 55555,
        isActive: true,
      );

      var jsonMap = popupData.toJson();

      expect(jsonMap['id'], '5');
      expect(jsonMap['value'], 'JSON Value');
      expect(jsonMap['dataCenterId'], 5001);
      expect(jsonMap['isSelected'], true);
      expect(jsonMap['imgId'], 55555);
      expect(jsonMap['isActive'], true);
      popupData = PopupToData(
        id: null,
        value: null,
        dataCenterId: null,
        isSelected: null,
        imgId: null,
        isActive: null,
      );

      jsonMap = popupData.toJson();

      expect(jsonMap['id'], null);
      expect(jsonMap['value'], null);
      expect(jsonMap['dataCenterId'], null);
      expect(jsonMap['isSelected'], null);
      expect(jsonMap['imgId'], null);
      expect(jsonMap['isActive'], null);
    });

    test('Constructor creates an instance with correct values', () {
      final popupToData1 = PopupToData(id: '1', value: 'Data 1');
      final popupToData2 = PopupToData(id: '2', value: 'Data 2');
      final popupTo = PopupTo(data: [popupToData1, popupToData2]);

      final filterQueryVOs = FilterQueryVOs(
        id: 100,
        filterId: 200,
        fieldName: 'Field',
        operatorId: 300,
        logicalOperator: 'AND',
        sequenceId: 1,
        returnIndexFields: 'Field1,Field2',
        dataType: 'String',
        solrCollections: 'collection1,collection2',
        labelName: 'Label',
        optionalValues: 'Value1,Value2',
        popupTo: popupTo,
        indexField: 'IndexField',
        isCustomAttribute: false,
        inputDataTypeId: 400,
        isBlankSearchAllowed: true,
        supportDashboardWidget: true,
        isMultipleAttributeWithSameName: true,
        digitSeparatorEnabled: false,
        generateURI: true,
      );

      expect(filterQueryVOs.id, 100);
      expect(filterQueryVOs.filterId, 200);
      expect(filterQueryVOs.fieldName, 'Field');
      expect(filterQueryVOs.operatorId, 300);
      expect(filterQueryVOs.logicalOperator, 'AND');
      expect(filterQueryVOs.sequenceId, 1);
      expect(filterQueryVOs.returnIndexFields, 'Field1,Field2');
      expect(filterQueryVOs.dataType, 'String');
      expect(filterQueryVOs.solrCollections, 'collection1,collection2');
      expect(filterQueryVOs.labelName, 'Label');
      expect(filterQueryVOs.optionalValues, 'Value1,Value2');
      expect(filterQueryVOs.popupTo, popupTo);
      expect(filterQueryVOs.indexField, 'IndexField');
      expect(filterQueryVOs.isCustomAttribute, false);
      expect(filterQueryVOs.inputDataTypeId, 400);
      expect(filterQueryVOs.isBlankSearchAllowed, true);
      expect(filterQueryVOs.supportDashboardWidget, true);
      expect(filterQueryVOs.isMultipleAttributeWithSameName, true);
      expect(filterQueryVOs.digitSeparatorEnabled, false);
      expect(filterQueryVOs.generateURI, true);
    });

    test('fromJson creates an instance with correct values', () {
      final jsonData = {
        'id': 101,
        'filterId': 201,
        'fieldName': 'Field2',
        'operatorId': 301,
        'logicalOperator': 'OR',
        'sequenceId': 2,
        'returnIndexFields': 'Field3,Field4',
        'dataType': 'Number',
        'solrCollections': 'collection3,collection4',
        'labelName': 'Label2',
        'optionalValues': 'Value3,Value4',
        'popupTo': {
          'data': [
            {'id': '3', 'value': 'Data 3'},
            {'id': '4', 'value': 'Data 4'},
          ],
        },
        'indexField': 'IndexField2',
        'isCustomAttribute': true,
        'inputDataTypeId': 401,
        'isBlankSearchAllowed': false,
        'supportDashboardWidget': false,
        'isMultipleAttributeWithSameName': false,
        'digitSeparatorEnabled': true,
        'generateURI': false,
      };

      final filterQueryVOs = FilterQueryVOs.fromJson(jsonData);

      expect(filterQueryVOs.id, 101);
      expect(filterQueryVOs.filterId, 201);
      expect(filterQueryVOs.fieldName, 'Field2');
      expect(filterQueryVOs.operatorId, 301);
      expect(filterQueryVOs.logicalOperator, 'OR');
      expect(filterQueryVOs.sequenceId, 2);
      expect(filterQueryVOs.returnIndexFields, 'Field3,Field4');
      expect(filterQueryVOs.dataType, 'Number');
      expect(filterQueryVOs.solrCollections, 'collection3,collection4');
      expect(filterQueryVOs.labelName, 'Label2');
      expect(filterQueryVOs.optionalValues, 'Value3,Value4');
      expect(filterQueryVOs.popupTo?.data, hasLength(2));
      expect(filterQueryVOs.indexField, 'IndexField2');
      expect(filterQueryVOs.isCustomAttribute, true);
      expect(filterQueryVOs.inputDataTypeId, 401);
      expect(filterQueryVOs.isBlankSearchAllowed, false);
      expect(filterQueryVOs.supportDashboardWidget, false);
      expect(filterQueryVOs.isMultipleAttributeWithSameName, false);
      expect(filterQueryVOs.digitSeparatorEnabled, true);
      expect(filterQueryVOs.generateURI, false);
    });

    test('copyWith creates a copy with updated values', () {
      final originalData = FilterQueryVOs(
        id: 102,
        filterId: 202,
        fieldName: 'Field3',
        operatorId: 302,
        logicalOperator: 'AND',
        sequenceId: 3,
        returnIndexFields: 'Field5,Field6',
        dataType: 'Date',
        solrCollections: 'collection5,collection6',
        labelName: 'Label3',
        optionalValues: 'Value5,Value6',
        popupTo: PopupTo(data: []),
        indexField: 'IndexField3',
        isCustomAttribute: false,
        inputDataTypeId: 402,
        isBlankSearchAllowed: true,
        supportDashboardWidget: true,
        isMultipleAttributeWithSameName: true,
        digitSeparatorEnabled: false,
        generateURI: true,
      );

      final updatedData = originalData.copyWith(
        id: 103,
        filterId: 203,
        fieldName: 'Field4',
        operatorId: 303,
        logicalOperator: 'OR',
        sequenceId: 4,
        returnIndexFields: 'Field7,Field8',
        dataType: 'Boolean',
        solrCollections: 'collection7,collection8',
        labelName: 'Label4',
        optionalValues: 'Value7,Value8',
        popupTo: null,
        indexField: 'IndexField4',
        isCustomAttribute: true,
        inputDataTypeId: 403,
        isBlankSearchAllowed: false,
        supportDashboardWidget: false,
        isMultipleAttributeWithSameName: false,
        digitSeparatorEnabled: true,
        generateURI: false,
      );

      expect(updatedData.id, 103);
      expect(updatedData.filterId, 203);
      expect(updatedData.fieldName, 'Field4');
      expect(updatedData.operatorId, 303);
      expect(updatedData.logicalOperator, 'OR');
      expect(updatedData.sequenceId, 4);
      expect(updatedData.returnIndexFields, 'Field7,Field8');
      expect(updatedData.dataType, 'Boolean');
      expect(updatedData.solrCollections, 'collection7,collection8');
      expect(updatedData.labelName, 'Label4');
      expect(updatedData.optionalValues, 'Value7,Value8');
      expect(updatedData.popupTo, isA<PopupTo>());
      expect(updatedData.indexField, 'IndexField4');
      expect(updatedData.isCustomAttribute, true);
      expect(updatedData.inputDataTypeId, 403);
      expect(updatedData.isBlankSearchAllowed, false);
      expect(updatedData.supportDashboardWidget, false);
      expect(updatedData.isMultipleAttributeWithSameName, false);
      expect(updatedData.digitSeparatorEnabled, true);
      expect(updatedData.generateURI, false);
    });

    test('toJson returns the correct JSON map', () {
      final popupToData = PopupToData(id: '5', value: 'Data 5');
      final popupTo = PopupTo(data: [popupToData]);
      final filterQueryVOs = FilterQueryVOs(
        id: 104,
        filterId: 204,
        fieldName: 'Field5',
        operatorId: 304,
        logicalOperator: 'AND',
        sequenceId: 5,
        returnIndexFields: 'Field9,Field10',
        dataType: 'List',
        solrCollections: 'collection9,collection10',
        labelName: 'Label5',
        optionalValues: 'Value9,Value10',
        popupTo: popupTo,
        indexField: 'IndexField5',
        isCustomAttribute: false,
        inputDataTypeId: 404,
        isBlankSearchAllowed: true,
        supportDashboardWidget: true,
        isMultipleAttributeWithSameName: true,
        digitSeparatorEnabled: false,
        generateURI: true,
      );

      final jsonMap = filterQueryVOs.toJson();

      expect(jsonMap['id'], 104);
      expect(jsonMap['filterId'], 204);
      expect(jsonMap['fieldName'], 'Field5');
      expect(jsonMap['operatorId'], 304);
      expect(jsonMap['logicalOperator'], 'AND');
      expect(jsonMap['sequenceId'], 5);
      expect(jsonMap['returnIndexFields'], 'Field9,Field10');
      expect(jsonMap['dataType'], 'List');
      expect(jsonMap['solrCollections'], 'collection9,collection10');
      expect(jsonMap['labelName'], 'Label5');
      expect(jsonMap['optionalValues'], 'Value9,Value10');
      expect(jsonMap['popupTo']['data'], hasLength(1));
      expect(jsonMap['indexField'], 'IndexField5');
      expect(jsonMap['isCustomAttribute'], false);
      expect(jsonMap['inputDataTypeId'], 404);
      expect(jsonMap['isBlankSearchAllowed'], true);
      expect(jsonMap['supportDashboardWidget'], true);
      expect(jsonMap['isMultipleAttributeWithSameName'], true);
      expect(jsonMap['digitSeparatorEnabled'], false);
      expect(jsonMap['generateURI'], true);
    });
    test('fromJson should correctly parse JSON', () {
      final jsonData = {
        'id': '1',
        'fieldName': 'field1',
        'colDisplayName': 'Column 1',
        'userIndex': 1,
        'imgName': '',
        'tooltipSrc' : '',
        'solrIndexfieldName' : '',
        'tooltipSrc' : '',
        'dataType' : '',
        'function' : '',
        'funParams' : '',
        'wrapData' : '',
        'isSortSupported' : false,
        'isCustomAttributeColumn' : false,
        'isActive' : false,
        'widthOfColumn' : 1
      };

      final columnHeader = ColumnHeader.fromJson(jsonData);

      expect(columnHeader.id, jsonData['id']);
      expect(columnHeader.fieldName, jsonData['fieldName']);
      expect(columnHeader.colDisplayName, jsonData['colDisplayName']);

      expect(columnHeader.userIndex, 1);
      expect(columnHeader.imgName, '');
      expect(columnHeader.tooltipSrc, '');
      expect(columnHeader.dataType, '');
      expect(columnHeader.function, '');
      expect(columnHeader.wrapData, '');
      expect(columnHeader.isSortSupported, false);
      expect(columnHeader.isActive, false);
      expect(columnHeader.widthOfColumn, 1);
      expect(columnHeader.isCustomAttributeColumn, false);
      expect(columnHeader.funParams, '');
      expect(columnHeader.colType, null);
      expect(columnHeader.solrIndexfieldName, '');
    });

    test('toJson should correctly convert to JSON', () {
      final columnHeader = ColumnHeader(
        id: '1',
        fieldName: 'field1',
        colDisplayName: 'Column 1',
        // Add other properties here
      );

      final json = columnHeader.toJson();

      // Add assertions to check if the JSON is correctly formatted
      expect(json['id'], columnHeader.id);
      expect(json['fieldName'], columnHeader.fieldName);
      expect(json['colDisplayName'], columnHeader.colDisplayName);
      // Add more assertions for other properties
    });

    test('copyWith should create a new ColumnHeader with updated values', () {
      final originalColumnHeader = ColumnHeader(
        id: '1',
        fieldName: 'field1',
        colDisplayName: 'Column 1',
        // Add other properties here
      );

      final updatedColumnHeader = originalColumnHeader.copyWith(
        colDisplayName: 'Updated Column 1',
        // Add other updated properties here
      );

      // Assert that the new ColumnHeader has the updated values
      expect(updatedColumnHeader.colDisplayName, 'Updated Column 1');
      // Add more assertions for other updated properties
    });

    test('copyWith should create a new ColumnHeader with original values when null', () {
      final originalColumnHeader = ColumnHeader(
        id: '1',
        fieldName: 'field1',
        colDisplayName: 'Column 1',
        // Add other properties here
      );

      final updatedColumnHeader = originalColumnHeader.copyWith(
        // Pass null to the copyWith method for all properties
      );

      // Assert that the new ColumnHeader has the original values
      expect(updatedColumnHeader.colDisplayName, originalColumnHeader.colDisplayName);
      // Add more assertions for other properties
    });

    test('getters should return correct values', () {
      final columnHeader = ColumnHeader(
        id: '1',
        fieldName: 'field1',
        colDisplayName: 'Column 1',
        // Add other properties here
      );

      // Assert that the getters return the correct values
      expect(columnHeader.id, '1');
      expect(columnHeader.fieldName, 'field1');
      expect(columnHeader.colDisplayName, 'Column 1');
      // Add more assertions for other properties
    });

    test('fromJson should correctly parse JSON', () {
      // Sample JSON data representing a FilterData object
      final jsonData = {
        'totalDocs': 100,
        'recordBatchSize': 10,
        'listingType': 1,
        'currentPageNo': 1,
        'recordStartFrom': 1,
        'columnHeader': [
          {},
          {},
        ],
        'data': [
          {},
          {},
        ],
        'sortField': 'fieldName',
        'sortFieldType': 'string',
        'sortOrder': 'asc',
        'editable': true,
        'isIncludeSubFolder': false,
        'totalListData': 1000,
      };

      final filterData = FilterData.fromJson(jsonData);

      expect(filterData.totalDocs, jsonData['totalDocs']);
      expect(filterData.recordBatchSize, jsonData['recordBatchSize']);
      expect(filterData.listingType, jsonData['listingType']);
      expect(filterData.currentPageNo, jsonData['currentPageNo']);
      expect(filterData.recordStartFrom, jsonData['recordStartFrom']);
    });

    test('toJson should correctly convert to JSON', () {
      final filterData = FilterData(
        totalDocs: 100,
        recordBatchSize: 10,
        listingType: 1,
        currentPageNo: 1,
        recordStartFrom: 1,
        columnHeader: [
          ColumnHeader(),
          ColumnHeader(),
        ],
        data: [],
        sortField: 'fieldName',
        sortFieldType: 'string',
        sortOrder: 'asc',
        editable: true,
        isIncludeSubFolder: false,
        totalListData: 1000,
      );

      final json = filterData.toJson();

      expect(json['totalDocs'], filterData.totalDocs);
      expect(json['recordBatchSize'], filterData.recordBatchSize);
      expect(json['listingType'], filterData.listingType);
      expect(json['currentPageNo'], filterData.currentPageNo);
      expect(json['recordStartFrom'], filterData.recordStartFrom);
    });

    test('copyWith should create a new FilterData with updated values', () {
      final originalFilterData = FilterData(
        totalDocs: 100,
        recordBatchSize: 10,
        listingType: 1,
        currentPageNo: 1,
        recordStartFrom: 1,
        columnHeader: [
          ColumnHeader(),
          ColumnHeader(),
        ],
        data: [],
        sortField: 'fieldName',
        sortFieldType: 'string',
        sortOrder: 'asc',
        editable: true,
        isIncludeSubFolder: false,
        totalListData: 1000,
      );

      final updatedFilterData = originalFilterData.copyWith(
        totalDocs: 200,
        recordBatchSize: 20,
        listingType: 2,
      );

      expect(updatedFilterData.totalDocs, 200);
      expect(updatedFilterData.recordBatchSize, 20);
      expect(updatedFilterData.listingType, 2);
    });

    test('copyWith should create a new FilterData with original values when null', () {
      final originalFilterData = FilterData(
        totalDocs: 100,
        recordBatchSize: 10,
        listingType: 1,
        currentPageNo: 1,
        recordStartFrom: 1,
        columnHeader: [
          ColumnHeader(),
          ColumnHeader(),
        ],
        data: [],
        sortField: 'fieldName',
        sortFieldType: 'string',
        sortOrder: 'asc',
        editable: true,
        isIncludeSubFolder: false,
        totalListData: 1000,
      );

      final updatedFilterData = originalFilterData.copyWith();

      expect(updatedFilterData.totalDocs, originalFilterData.totalDocs);
      expect(updatedFilterData.recordBatchSize, originalFilterData.recordBatchSize);
      expect(updatedFilterData.listingType, originalFilterData.listingType);
    });

    test('getters should return correct values', () {
      final filterData = FilterData(
        totalDocs: 100,
        recordBatchSize: 10,
        listingType: 1,
        currentPageNo: 1,
        recordStartFrom: 1,
        columnHeader: [
          ColumnHeader(),
          ColumnHeader(),
        ],
        data: [],
        sortField: 'fieldName',
        sortFieldType: 'string',
        sortOrder: 'asc',
        editable: true,
        isIncludeSubFolder: false,
        totalListData: 1000,
      );

      expect(filterData.totalDocs, 100);
      expect(filterData.recordBatchSize, 10);
      expect(filterData.listingType, 1);
      expect(filterData.currentPageNo, 1);
      expect(filterData.recordStartFrom, 1);
    });

    test('fromJson should correctly parse JSON', () {
      final jsonData = {
        'filterResponse': {
        },
        'filterData': {
        },
      };

      final qualitySearchVo = QualitySearchVo.fromJson(json.encode(jsonData));

      expect(qualitySearchVo.filterResponse, isNotNull);
    });

    test('toJson should correctly convert to JSON', () {
      final filterResponse = FilterResponse();

      final filterData = FilterData();

      final qualitySearchVo = QualitySearchVo(
        filterResponse: filterResponse,
        filterData: filterData,
      );

      final json = qualitySearchVo.toJson();

      expect(json['filterResponse'], isNotNull);
    });

    test('copyWith should create a new QualitySearchVo with updated values', () {
      final originalFilterResponse = FilterResponse();

      final originalFilterData = FilterData();

      final originalQualitySearchVo = QualitySearchVo(
        filterResponse: originalFilterResponse,
        filterData: originalFilterData,
      );

      final updatedFilterResponse = FilterResponse();

      final updatedFilterData = FilterData();

      final updatedQualitySearchVo = originalQualitySearchVo.copyWith(
        filterResponse: updatedFilterResponse,
        filterData: updatedFilterData,
      );

      expect(updatedQualitySearchVo.filterResponse, equals(updatedFilterResponse));
      expect(updatedQualitySearchVo.filterData, equals(updatedFilterData));
    });

    test('copyWith should create a new QualitySearchVo with original values when null', () {
      final originalFilterResponse = FilterResponse();

      final originalFilterData = FilterData();

      final originalQualitySearchVo = QualitySearchVo(
        filterResponse: originalFilterResponse,
        filterData: originalFilterData,
      );

      final updatedQualitySearchVo = originalQualitySearchVo.copyWith();

      expect(updatedQualitySearchVo.filterResponse, equals(originalFilterResponse));
      expect(updatedQualitySearchVo.filterData, equals(originalFilterData));
    });
  });

  test('fromJson should correctly parse JSON', () {
    // Sample JSON data representing a FilterResponse object
    final jsonData = {
      'filterVOs': [
        {
          // Add sample data for the FilterVOs here
        },
        {
          // Add sample data for the FilterVOs here
        },
      ],
    };

    final filterResponse = FilterResponse.fromJson(jsonData);

    // Assert that filterVOs is not null and has the correct length
    expect(filterResponse.filterVOs, isNotNull);
    expect(filterResponse.filterVOs!.length, 2); // Assuming 2 FilterVOs in the JSON
    // Add more assertions for the content of filterVOs if needed
  });

  test('copyWith should create a new FilterResponse with updated values', () {
    final originalFilterResponse = FilterResponse(
      filterVOs: [
        FilterVOs(),
        FilterVOs(),
      ],
    );

    final updatedFilterResponse = originalFilterResponse.copyWith(
      filterVOs: [
        FilterVOs(),
      ],
    );

    expect(updatedFilterResponse.filterVOs?.length, 1);
  });

  test('copyWith should create a new FilterResponse with original values when null', () {
    final originalFilterResponse = FilterResponse(
      filterVOs: [
        FilterVOs(),
        FilterVOs(),
      ],
    );

    final updatedFilterResponse = originalFilterResponse.copyWith(
    );

    expect(updatedFilterResponse.filterVOs?.length, 2);
  });

  test('toJson should correctly convert to JSON', () {
    final filterVOs = [
      FilterVOs(),
      FilterVOs(),
    ];

    final filterResponse = FilterResponse(filterVOs: filterVOs);

    final json = filterResponse.toJson();

    expect(json['filterVOs'], isNotNull);
    expect(json['filterVOs'], isList);
    expect(json['filterVOs'].length, 2);
  });

  test('copyWith should create a new FilterVOs with updated values', () {
    final originalFilterVOs = FilterVOs(
      id: 1,
      userId: 10,
      filterName: 'Original Filter',
    );

    final updatedFilterVOs = originalFilterVOs.copyWith(
      id: 2,
      userId: 20,
      filterName: 'Updated Filter',
    );

    expect(updatedFilterVOs.id, 2);
    expect(updatedFilterVOs.userId, 20);
    expect(updatedFilterVOs.filterName, 'Updated Filter');
  });


  ////
  test('copyWith should create a new PopupTo with updated values', () {
    final originalPopupTo = PopupTo(
      totalDocs: 100,
      recordBatchSize: 10,
      // Add other sample data for the properties here
    );

    final updatedPopupTo = originalPopupTo.copyWith(
      totalDocs: 200,
      recordBatchSize: 20,
      // Add other updated sample data for the properties here
    );

    // Assert that the new PopupTo has the updated values
    expect(updatedPopupTo.totalDocs, 200);
    expect(updatedPopupTo.recordBatchSize, 20);
    // Add more assertions for the other updated properties
  });

  test('copyWith should create a new PopupTo with original values when null', () {
    final originalPopupTo = PopupTo(
      totalDocs: 100,
      recordBatchSize: 10,
      // Add other sample data for the properties here
    );

    final updatedPopupTo = originalPopupTo.copyWith(
      // Pass null to the copyWith method for all properties
    );

    // Assert that the new PopupTo has the original values
    expect(updatedPopupTo.totalDocs, 100);
    expect(updatedPopupTo.recordBatchSize, 10);
    // Add more assertions for the other original properties
  });

  test('PopupTo instantiation should set correct values', () {
    final popupTo = PopupTo(
      totalDocs: 100,
      recordBatchSize: 10,
    );

    expect(popupTo.totalDocs, 100);
    expect(popupTo.recordBatchSize, 10);
  });

  ////

  test('copyWith should create a new PopupToData with updated values', () {
    final originalPopupToData = PopupToData(
      id: '1',
      value: 'Value1',
      dataCenterId: 100,
    );

    final updatedPopupToData = originalPopupToData.copyWith(
      id: '2',
      value: 'Updated Value',
      dataCenterId: 200,
    );

    expect(updatedPopupToData.id, '2');
    expect(updatedPopupToData.value, 'Updated Value');
    expect(updatedPopupToData.dataCenterId, 200);
  });

  test('copyWith should create a new PopupToData with original values when null', () {
    final originalPopupToData = PopupToData(
      id: '1',
      value: 'Value1',
      dataCenterId: 100,
    );

    final updatedPopupToData = originalPopupToData.copyWith(
    );

    expect(updatedPopupToData.id, '1');
    expect(updatedPopupToData.value, 'Value1');
    expect(updatedPopupToData.dataCenterId, 100);
  });

  test('PopupToData instantiation should set correct values', () {
    final popupToData = PopupToData(
      id: '1',
      value: 'Value1',
      dataCenterId: 100,
    );

    expect(popupToData.id, '1');
    expect(popupToData.value, 'Value1');
    expect(popupToData.dataCenterId, 100);
  });

  test('copyWith should create a new FilterQueryVOs with updated values', () {
    final originalFilterQueryVOs = FilterQueryVOs(
      id: 1,
      filterId: 100,
      fieldName: 'Field1',
    );

    final updatedFilterQueryVOs = originalFilterQueryVOs.copyWith(
      id: 2,
      filterId: 200,
      fieldName: 'Updated Field',
    );

    expect(updatedFilterQueryVOs.id, 2);
    expect(updatedFilterQueryVOs.filterId, 200);
    expect(updatedFilterQueryVOs.fieldName, 'Updated Field');
  });

  test('copyWith should create a new FilterQueryVOs with original values when null', () {
    final originalFilterQueryVOs = FilterQueryVOs(
      id: 1,
      filterId: 100,
      fieldName: 'Field1',
    );

    final updatedFilterQueryVOs = originalFilterQueryVOs.copyWith(
    );

    expect(updatedFilterQueryVOs.id, 1);
    expect(updatedFilterQueryVOs.filterId, 100);
    expect(updatedFilterQueryVOs.fieldName, 'Field1');
  });

  test('FilterQueryVOs instantiation should set correct values', () {
    final filterQueryVOs = FilterQueryVOs(
      id: 1,
      filterId: 100,
      fieldName: 'Field1',
    );

    expect(filterQueryVOs.id, 1);
    expect(filterQueryVOs.filterId, 100);
    expect(filterQueryVOs.fieldName, 'Field1');
  });

  test('columnHeader getter should return correct value', () {
    final columnHeader = [
      ColumnHeader(id: 1.toString(), colDisplayName: 'Column 1'),
      ColumnHeader(id: 2.toString(), colDisplayName: 'Column 2'),
    ];

    final filterData = FilterData(columnHeader: columnHeader);

    expect(filterData.columnHeader, equals(columnHeader));
  });

  test('data getter should return correct value', () {

    final filterData = FilterData(data: []);

    expect(filterData.data, equals([]));
  });

  test('sortField getter should return correct value', () {
    final sortField = 'fieldName';

    final filterData = FilterData(sortField: sortField);

    expect(filterData.sortField, equals(sortField));
  });

  test('sortFieldType getter should return correct value', () {
    final sortFieldType = 'type';

    final filterData = FilterData(sortFieldType: sortFieldType);

    expect(filterData.sortFieldType, equals(sortFieldType));
  });

  test('sortOrder getter should return correct value', () {
    final sortOrder = 'asc';

    final filterData = FilterData(sortOrder: sortOrder);

    expect(filterData.sortOrder, equals(sortOrder));
  });

  test('editable getter should return correct value', () {
    final editable = true;

    final filterData = FilterData(editable: editable);

    expect(filterData.editable, equals(editable));
  });

  test('isIncludeSubFolder getter should return correct value', () {
    final isIncludeSubFolder = false;

    final filterData = FilterData(isIncludeSubFolder: isIncludeSubFolder);

    expect(filterData.isIncludeSubFolder, equals(isIncludeSubFolder));
  });

  test('totalListData getter should return correct value', () {
    final totalListData = 100;

    final filterData = FilterData(totalListData: totalListData);

    expect(filterData.totalListData, equals(totalListData));
  });
}
