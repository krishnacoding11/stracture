
import 'dart:convert';

import 'package:field/data/dao/form_dao.dart';
import 'package:field/data/dao/project_dao.dart';

import '../../data/dao/form_message_action_dao.dart';
import '../../data/dao/formtype_dao.dart';
import '../../networking/network_response.dart';
import '../../networking/request_body.dart';
import '../base/base_local_data_source.dart';

class FilterLocalDataSource extends BaseLocalDataSource {

  String _filterValueQuery(Map<String, dynamic> request) {
    String query = "";
    String searchValue = request["searchValue"]?.toString() ?? "";
    String conditionCause = "WHERE";
    String groupByField = "";
    String recordBatchSize = request["recordBatchSize"]?.toString() ?? "10";
    String selectedProjectIds = request["projectIds"]?.toString() ?? "";
    switch ((jsonDecode(request["jsonData"].toString()))["indexField"].toString().toLowerCase()) {
      case 'cfid_locationname':
        break;
      case 'form_status':
        query = "SELECT DISTINCT StatusName COLLATE NOCASE AS Id, StatusName COLLATE NOCASE AS Value FROM ${FormDao.tableName}";
        if (selectedProjectIds.isNotEmpty) {
          query = "$query\n$conditionCause ProjectId IN ("
              "${(selectedProjectIds == "-2") ? "\nSELECT ProjectId FROM ${ProjectDao.tableName} WHERE IsFavorite=1\n" : selectedProjectIds}"
              ")";
          conditionCause = "AND";
        }
        break;
      case 'cfid_defecttyoe':
        query = "SELECT DISTINCT ObservationDefectType COLLATE NOCASE AS Id, ObservationDefectType COLLATE NOCASE AS Value FROM ${FormDao.tableName}";
        if (selectedProjectIds.isNotEmpty) {
          query = "$query\n$conditionCause ProjectId IN ("
              "${(selectedProjectIds == "-2") ? "\nSELECT ProjectId FROM ${ProjectDao.tableName} WHERE IsFavorite=1\n" : selectedProjectIds}"
              ")";
          conditionCause = "AND";
        }
        break;
      case 'cfid_assignedtouser':
        break;
      case 'action_status':
        break;
      case 'status_id':
        break;
      case 'distribution_list':
        query = "SELECT DISTINCT RecipientUserId AS Id,RecipientName COLLATE NOCASE AS Value FROM ${FormMessageActionDao.tableName}";
        if (selectedProjectIds.isNotEmpty) {
          query = "$query\n$conditionCause ProjectId IN ("
              "${(selectedProjectIds == "-2") ? "\nSELECT ProjectId FROM ${ProjectDao.tableName} WHERE IsFavorite=1\n" : selectedProjectIds}"
              ")";
          conditionCause = "AND";
        }
        break;
      case 'recipient_org':
        query = "SELECT DISTINCT RecipientOrgId AS Id,TRIM(SUBSTR(RecipientName,INSTR(RecipientName,',')+1,LENGTH(RecipientName))) COLLATE NOCASE AS Value FROM ${FormMessageActionDao.tableName}";
        if (selectedProjectIds.isNotEmpty) {
          query = "$query\n$conditionCause ProjectId IN ("
              "${(selectedProjectIds == "-2") ? "\nSELECT ProjectId FROM ${ProjectDao.tableName} WHERE IsFavorite=1\n" : selectedProjectIds}"
              ")";
          conditionCause = "AND";
        }
        break;
      case 'originator_user_id':
        query = "SELECT DISTINCT OriginatorId AS Id,OriginatorDisplayName COLLATE NOCASE AS Value FROM ${FormDao.tableName}";
        if (selectedProjectIds.isNotEmpty) {
          query = "$query\n$conditionCause ProjectId IN ("
              "${(selectedProjectIds == "-2") ? "\nSELECT ProjectId FROM ${ProjectDao.tableName} WHERE IsFavorite=1\n" : selectedProjectIds}"
              ")";
          conditionCause = "AND";
        }
        break;
      case 'originator_organisation':
        query = "SELECT DISTINCT OrgId AS Id,OrgName COLLATE NOCASE AS Value FROM ${FormDao.tableName}";
        if (selectedProjectIds.isNotEmpty) {
          query = "$query\n$conditionCause ProjectId IN ("
              "${(selectedProjectIds == "-2") ? "\nSELECT ProjectId FROM ${ProjectDao.tableName} WHERE IsFavorite=1\n" : selectedProjectIds}"
              ")";
          conditionCause = "AND";
        }
        break;
      case 'form_creation_date':
        break;
      case 'due_date':
        break;
      case 'form_title':
        break;
      case 'form_type_name':
        query = "SELECT DISTINCT FormTypeName AS Id, FormTypeName AS Value FROM ${FormTypeDao.tableName}";
        String appTypeId = request["appType"]?.toString() ?? "";
        // if (appTypeId.isNotEmpty) {
        //   query = "$query\n$conditionCause AppTypeId=$appTypeId";
        //   conditionCause = "AND";
        // }
        if (selectedProjectIds.isNotEmpty) {
          query = "$query\n$conditionCause ProjectId IN ("
              "${(selectedProjectIds == "-2") ? "\nSELECT ProjectId FROM ${ProjectDao.tableName} WHERE IsFavorite=1\n" : selectedProjectIds}"
              ")";
          conditionCause = "AND";
        }
        break;
      case 'cfid_tasktype':
        query = "SELECT DISTINCT TaskTypeName COLLATE NOCASE AS Id,TaskTypeName COLLATE NOCASE AS Value FROM ${FormDao.tableName}";
        if (selectedProjectIds.isNotEmpty) {
          query = "$query\n$conditionCause ProjectId IN ("
              "${(selectedProjectIds == "-2") ? "\nSELECT ProjectId FROM ${ProjectDao.tableName} WHERE IsFavorite=1\n" : selectedProjectIds}"
              ")";
          conditionCause = "AND";
        }
        break;
      case 'summary':
        break;
    }
    if (query.isNotEmpty) {
      if (searchValue != "") {
        if (searchValue.contains("_")) {
          searchValue = searchValue.replaceAll("_", "^_");
          query = "$query\n$conditionCause Value LIKE ('%$searchValue%') ESCAPE '^'";
        } else {
          query = "$query\n$conditionCause Value LIKE ('%$searchValue%')";
        }
      }
      if (groupByField.isNotEmpty) {
        query = "$query\nGROUP BY $groupByField";
      }
      query = "$query\nORDER BY Value COLLATE NOCASE ASC";
      if (recordBatchSize != "") {
        query = "$query\nLIMIT 0,$recordBatchSize";
      }
    }
    return query;
  }

  Future<Result> getFilterAttributeValueList(Map<String, dynamic> request) async {
    Result result = FAIL("", 500);
    if (request.containsKey("jsonData") && (request["jsonData"]?.toString().isNotEmpty ?? false)) {
      String valueQuery = _filterValueQuery(request);
      if (valueQuery.isNotEmpty) {
        var dbResult = databaseManager.executeSelectFromTable(FormDao.tableName, valueQuery);
        List<Map<String, dynamic>> valueData = [];
        for (var valueRowItem in dbResult) {
          Map<String, dynamic> valueMapNode = {
            "id": valueRowItem["Id"],
            "value": valueRowItem["Value"].toString(),
            "dataCenterId": 0,
            "isSelected": false,
            "isActive": true,
          };
          valueData.add(valueMapNode);
        }
        var responseParentNode = {
          "totalDocs": dbResult.length,
          "recordBatchSize": int.tryParse(request["recordBatchSize"]?.toString() ?? "") ?? 0,
          "data": valueData,
          "isSortRequired": true,
          "generateURI": true,
        };
        result = SUCCESS(jsonEncode(responseParentNode), null, 200, requestData: NetworkRequestBody.json(request));
      }
    }
    return result;
  }
}