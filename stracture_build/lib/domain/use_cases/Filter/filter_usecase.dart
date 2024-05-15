import 'dart:convert';
import 'dart:io';

import 'package:field/data/local/Filter/filter_local_repository_impl.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/remote/Filter/filter_repositroy_impl.dart';
import 'package:field/data/repository/filter_repository.dart';
import 'package:field/domain/common/base_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/file_utils.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/user_activity_preference.dart';
import 'package:intl/intl.dart';

import '../../../data/model/user_vo.dart';
import '../../../networking/network_response.dart';
import '../../../utils/utils.dart';

enum FilterScreen { screenSite, screenTask, screenUndefined, screenHome, screenModel}

class FilterUseCase extends BaseUseCase<FilterRepository> {
  // static const String strDateFormat = 'dd-MMM-yyyy';

  FilterRepository? _filterRepository;

  Future<Result?>? getFilterDataForDefect(Map<String, dynamic> request) async {
    final result = await getFilterDataForDefectSync(request);
    if (result is SUCCESS) {
      String jsonString = result.data ?? "";
      var object = jsonDecode(jsonString);
      List attributeList = List.from(object["fieldsColumns"] as List);
      await saveSiteFilterList(attributeList);
      return result;
    }
    return result;
  }

  Future<Result?>? getFilterDataForDefectSync(Map<String, dynamic> request) async {
    request["checkHashing"] = "false";
    request["collectionType"] = "125";
    request["isFromDeviceFilter"] = "true";
    request["selectedFolderIds"] = "-1";
    request["selectedProjectIds"] = "-1";
    await getInstance();
    final result = await _filterRepository?.getFilterDataForDefect(request);
    return result;
  }

  Future<Result?>? getFilterSearchData(Map<String, dynamic> request) async {
    await getInstance();
    final result = await _filterRepository?.getFilterSearchData(request);
    if (result is SUCCESS) {
      return result;
    }
    return result;
  }

  String getFilterFileName(FilterScreen curScreen) {
    switch (curScreen) {
      case FilterScreen.screenTask:
        return "taskList";
      case FilterScreen.screenSite:
        return "siteList";
      default:
        return "unknownList";
    }
  }

  Future<String> getFilterJsonByIndexField(Map filterIndexFieldMap, {FilterScreen curScreen = FilterScreen.screenUndefined, bool isNeedToSave = true}) async {
    Map dict = await readSiteFilterData(curScreen: curScreen);
    List arr = await readSiteFilterList();
    filterIndexFieldMap.forEach((key, value) {
      var filterAttObj = arr.firstWhere((element) => element['indexField'] == key, orElse: () => null);
      if (filterAttObj != null) {
        if (value == null) {
          dict.removeWhere((key, value) => key == filterAttObj['id'].toString());
        } else {
          dict[filterAttObj['id'].toString()] = value;
        }
      }
    });
    return await getSiteFilterJson(dict, arr, curScreen: curScreen, isNeedToSave: isNeedToSave);
  }

  Future<String> getSiteFilterJson(Map dict, List arr, {FilterScreen curScreen = FilterScreen.screenUndefined, bool isNeedToSave = true}) async {
    if (isNeedToSave) {
      await saveSiteFilterData(dict, curScreen: curScreen);
    }
    if (curScreen == FilterScreen.screenTask) {
      var defaultFilter = await getTaskDefaultFilterList(arr);
      if (defaultFilter != null || defaultFilter!.isNotEmpty) {
        dict.addAll(defaultFilter);
      }
    }
    if (dict.isNotEmpty) {
      var filterJson = {};
      Project? temp = await StorePreference.getSelectedProjectData();
      String pid = temp?.projectID ?? "";
      int dcId = temp?.dcId ?? 0;
      Map appliedFilter = applyFilter(dict, arr, dcId);
      filterJson["creationDate"] = "";
      filterJson["filterName"] = "Unsaved Filter";
      filterJson["filterQueryVOs"] = appliedFilter.values.toList();
      filterJson["id"] = "-1";
      filterJson["isUnsavedFilter"] = true;
      filterJson["listingTypeId"] = "31";
      filterJson["selectedFolderIds"] = "-1";
      filterJson["selectedProjectIds"] = pid;
      filterJson["subListingTypeId"] = "1";
      filterJson["userId"] = "-1";
      return jsonEncode(filterJson);
    } else {
      return "";
    }
  }

  Future<void> saveSiteFilterData(Map data, {FilterScreen curScreen = FilterScreen.screenUndefined}) async {
    String strFileName = getFilterFileName(curScreen);
    await saveFilterData(data, strFileName);
  }

  Future<void> saveFilterData(Map data, String fileName) async {
    String path = await getFilterFilePath(fileName: "${fileName}_filter.json");
    File file = File(path);
    String jsonString = json.encode(data);
    file.createSync(recursive: true);
    await file.writeAsString(jsonString);
  }

  Future<Map> readSiteFilterData({FilterScreen curScreen = FilterScreen.screenUndefined}) async {
    return await readFilterData(getFilterFileName(curScreen));
  }

  Future<void> saveSiteFilterList(List data) async {
    await saveFilterList(data, "2");
  }

  Future<Map> readFilterData(String fileName) async {
    String path = await getFilterFilePath(fileName: "${fileName}_filter.json");
    File file = File(path);
    String? dataString = await readDataFromFile(file);
    if (dataString != null) {
      var obj = json.decode(dataString);
      if (obj != null) {
        return obj;
      }
    }
    return {};
  }

  Future<void> saveFilterList(List data, String appType) async {
    String path = await getFilterFilePath(fileName: "${appType}_filter_list.json");
    File file = File(path);
    String jsonString = json.encode(data);
    file.createSync(recursive: true);
    await file.writeAsString(jsonString);
  }

  Future<List> readSiteFilterList() async {
    return await readFilterList("2");
  }

  Future<List> readFilterList(String appType) async {
    String path = await getFilterFilePath(fileName: "${appType}_filter_list.json");
    File file = File(path);
    String? dataString = await readDataFromFile(file);
    if (dataString != null) {
      var obj = json.decode(dataString);
      if (obj != null) {
        return obj;
      }
    }
    Map<String, dynamic> map = <String, dynamic>{};
    map["projectIds"] = await getCurrentProjectId();
    map["appType"] = appType;
    final result = await getFilterDataForDefect(map);
    if (result is SUCCESS) {
      String jsonString = result.data ?? "";
      var object = jsonDecode(jsonString);
      List attributeList = List.from(object["fieldsColumns"] as List);
      return attributeList;
    }
    return [];
  }

  Map applyFilter(Map dict, List dataList, int dcId, {int seqID = 0}) {
    Map appliedFilter = {};
    String strID = "";
    for (var obj in dataList) {
      strID = obj["id"].toString();
      if (dict[strID] != null) {
        var newObj = {};
        String recordBatchSize = "0";
        if (obj["popupTo"] != null) {
          if (obj["popupTo"]["recordBatchSize"] != null) {
            recordBatchSize = obj["popupTo"]["recordBatchSize"].toString();
          }
        }
        newObj["dataType"] = obj["dataType"];
        newObj["fieldName"] = obj["indexField"];
        newObj["id"] = obj["id"];
        newObj["indexField"] = obj["indexField"];
        newObj["isBlankSearchAllowed"] = obj["isBlankSearchAllowed"];
        newObj["isCustomAttribute"] = obj["isCustomAttribute"];
        newObj["labelName"] = obj["labelName"];
        if (newObj['indexField'].toString().toLowerCase() == 'summary') {
          newObj["operatorId"] = 11;
        } else if (obj["dataType"] == "Date" || (obj["dataType"] == "Text" && obj["returnIndexFields"] != "-1")) {
          newObj["operatorId"] = 11;
        } else {
          newObj["operatorId"] = 1;
        }
        newObj["logicalOperator"] = "AND";
        if (obj["dataType"] == "Dropdown") {
          if (dict[strID] is List) {
            var dataArr = dict[strID];
            var popUpArr = [];
            for (var dataObj in dataArr) {
              dynamic data = {
                "dataCenterId": dcId,
                "id": dataObj["id"] ?? "",
                "imgId": -1,
                "isActive": true,
                "isSelected": true,
                "rangeFilterData": {},
                "value": dataObj["value"] ?? "",
              };
              popUpArr.add(data);
            }
            var newPopUpTo = {"data": popUpArr, "recordBatchSize": recordBatchSize};
            newObj["popupTo"] = newPopUpTo;
          }
        } else if (obj["dataType"] == "Text" || obj["dataType"] == "text") {
          if (obj["returnIndexFields"] != "-1") {
            if (dict[strID] is List) {
              var dataArr = dict[strID];
              var popUpArr = [];
              for (var dataObj in dataArr) {
                String value = obj["indexField"] == "CFID_AssignedToUser" ? (dataObj["id"] + "#") : dataObj["value"];
                dynamic data = {
                  "dataCenterId": dcId,
                  "id": dataObj["id"] ?? "",
                  "imgId": -1,
                  "isActive": true,
                  "isSelected": true,
                  "rangeFilterData": {},
                  "value": value,
                };
                popUpArr.add(data);
              }
              var newPopUpTo = {"data": popUpArr, "recordBatchSize": recordBatchSize};
              newObj["popupTo"] = newPopUpTo;
            }
          } else {
            dynamic textData = {"dataCenterId": dcId, "id": dict[strID] ?? "", "imgId": 0, "isActive": false, "isSelected": true, "rangeFilterData": {}, "value": dict[strID] ?? ""};
            var newPopUpTo = {
              "data": [textData],
              "recordBatchSize": recordBatchSize
            };
            newObj["popupTo"] = newPopUpTo;
          }
        } else if (obj["dataType"] == "Date") {
          if (dict[strID] is Map) {
            var dateObject = dict[strID];
            var popUpArr = [];
            if (dateObject["end_date"] != null) {
              String value = "rptbetween#from#${dateObject["start_date"]}|${dateObject["end_date"]}";
              dynamic data = {
                "dataCenterId": dcId,
                "id": value,
                "imgId": 0,
                "isActive": false,
                "isSelected": false,
                "rangeFilterData": {"dataType": "date", "fromVal": dateObject["start_date"], "targetId": "Between", "toVal": dateObject["end_date"]},
                "value": value,
              };
              popUpArr.add(data);
            } else if (dateObject["start_date"] != null) {
              String value = "rpton#on#${dateObject["start_date"]}";
              dynamic data = {
                "dataCenterId": dcId,
                "id": value,
                "imgId": 0,
                "isActive": false,
                "isSelected": false,
                "rangeFilterData": {"dataType": "date", "fromVal": dateObject["start_date"], "targetId": "On"},
                "value": value,
              };
              popUpArr.add(data);
            }

            var newPopUpTo = {"data": popUpArr, "recordBatchSize": recordBatchSize};
            newObj["popupTo"] = newPopUpTo;
          }
        }
        newObj["returnIndexFields"] = obj["returnIndexFields"];
        newObj["sequenceId"] = seqID + 1;
        newObj["solrCollections"] = obj["solrCollections"];
        appliedFilter[strID] = newObj;
      }
    }
    return appliedFilter;
  }

  Future<Map<String, dynamic>?> getTaskDefaultFilterList(List attributeList) async {
    Project? projectDetails = await StorePreference.getSelectedProjectData();
    User? userDetails = await StorePreference.getUserData();
    if (projectDetails != null && userDetails != null) {
      String userId = userDetails.usersessionprofile?.userID?.plainValue() ?? "";
      String userNameWithOrg = "${userDetails.usersessionprofile?.tpdUserName ?? ""}, ${userDetails.usersessionprofile?.tpdOrgName ?? ""}";
      int dcId = projectDetails.dcId ?? 0;
      Map<String, dynamic> filterAttributeValueMap = {};
      for (var element in attributeList) {
        if (element["indexField"] == "status_id") {
          List valueList = List.from(element["popupTo"]["data"]);
          valueList.removeWhere((element) => element["id"] != "-1");
          filterAttributeValueMap[element["id"].toString()] = valueList;
        } else if (element["indexField"] == "distribution_list") {
          dynamic valueData = {"dataCenterId": dcId, "id": userId, "imgId": -1, "isActive": true, "isSelected": true, "rangeFilterData": null, "value": userNameWithOrg};
          List valueList = [valueData];
          filterAttributeValueMap[element["id"].toString()] = valueList;
        }
      }
      return filterAttributeValueMap;
    }
    return null;
  }

  applyDashboardNewTaskFilter() async {
    List filterAttributeList = await readSiteFilterList();
    if (filterAttributeList.isNotEmpty) {
      String strDateFormat = await Utility.getUserDateFormat();
      Map filterData = {};
      for (var element in filterAttributeList) {
        switch (element["indexField"].toString()) {
          case 'action_status':
            {
              List valueList = List.from(element["popupTo"]["data"]);
              valueList.removeWhere((elementValue) {
                return (elementValue["id"].toString() != "5");
              });
              filterData[element["id"].toString()] = valueList;
            }
            break;
          case 'action_date':
            {
              Map selectedDateMap = {"start_date": DateFormat(strDateFormat).format(DateTime.now())};
              filterData[element["id"].toString()] = selectedDateMap;
            }
            break;
        }
      }
      await saveSiteFilterData(filterData, curScreen: FilterScreen.screenTask);
    }
  }

  applyDashboardDueTodayFilter() async {
    List filterAttributeList = await readSiteFilterList();
    if (filterAttributeList.isNotEmpty) {
      Map filterData = {};
      String strDateFormat = await Utility.getUserDateFormat();
      for (var element in filterAttributeList) {
        switch (element["indexField"].toString()) {
          case 'action_status':
            {
              List valueList = List.from(element["popupTo"]["data"]);
              valueList.removeWhere((elementValue) {
                return (elementValue["id"].toString() != "5");
              });
              filterData[element["id"].toString()] = valueList;
            }
            break;
          case 'due_date':
            {
              Map selectedDateMap = {"start_date": DateFormat(strDateFormat).format(DateTime.now())};
              filterData[element["id"].toString()] = selectedDateMap;
            }
            break;
        }
      }
      await saveSiteFilterData(filterData, curScreen: FilterScreen.screenTask);
    }
  }

  applyDashboardDueThisWeekFilter() async {
    List filterAttributeList = await readSiteFilterList();
    if (filterAttributeList.isNotEmpty) {
      Map filterData = {};
      String strDateFormat = await Utility.getUserDateFormat();
      for (var element in filterAttributeList) {
        switch (element["indexField"].toString()) {
          case 'action_status':
            {
              List valueList = List.from(element["popupTo"]["data"]);
              valueList.removeWhere((elementValue) {
                return (elementValue["id"].toString() != "5");
              });
              filterData[element["id"].toString()] = valueList;
            }
            break;
          case 'due_date':
            {
              Map selectedDateMap = Utility.getWeekStartEndDate(DateTime.now(), dateFormat: strDateFormat);
              filterData[element["id"].toString()] = selectedDateMap;
            }
            break;
        }
      }
      await saveSiteFilterData(filterData, curScreen: FilterScreen.screenTask);
    }
  }

  applyDashboardOverDueFilter() async {
    List filterAttributeList = await readSiteFilterList();
    if (filterAttributeList.isNotEmpty) {
      Map filterData = {};
      for (var element in filterAttributeList) {
        if (element["indexField"] == "action_status") {
          List valueList = List.from(element["popupTo"]["data"]);
          valueList.removeWhere((elementValue) {
            return (elementValue["id"].toString() != "6");
          });
          filterData[element["id"].toString()] = valueList;
        }
      }
      await saveSiteFilterData(filterData, curScreen: FilterScreen.screenTask);
    }
  }

  @override
  Future<FilterRepository?> getInstance() async {
    if (isNetWorkConnected()) {
      _filterRepository = di.getIt<FilterRemoteRepository>();
      return _filterRepository;
    } else {
      _filterRepository = di.getIt<FilterLocalRepository>();
      return _filterRepository;
    }
  }
}
