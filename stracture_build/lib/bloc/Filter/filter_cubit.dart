import 'dart:convert';

import 'package:field/bloc/Filter/filter_state.dart';
import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/user_activity_preference.dart';

class FilterCubit extends BaseCubit {
  final _filterUseCase = di.getIt<FilterUseCase>();
  List<String> removeFiltersTaskList = <String>[
    'status_id',
    'CFID_AssignedToUser',
    'form_title',
    'form_type_name',
    'CFID_LocationName',
    'CFID_TaskType',
    'CFID_DefectTyoe',
    'distribution_list',
    'action_date',
    'summary'
  ];
  List<String> removeFiltersSiteList = <String>[
    'status_id',
    'CFID_AssignedToUser',
    'CFID_LocationName',
    'CFID_TaskType',
    'CFID_DefectTyoe',
    'form_title',
    'action_date',
    'summary'
  ];

  Result? result;
  bool _overdue = false;

  get isOverdueEnabled => _overdue;
  bool _completed = false;

  get isCompletedEnabled => _completed;

  List filterAttributeList = [];
  var widgetList = [];
  var currentSelectedDropdown = [];

  var selectedFilterData = {};

  FilterCubit() : super(InitialState(stateRendererType: StateRendererType.DEFAULT));


  Future<void> getFilterAttributeList(String appType) async {
    try {
      Map<String, dynamic> map = <String, dynamic>{};
      map["projectIds"] = await getCurrentProjectId();
      map["appType"] = appType;
      final filterColumnAttributeList =
      await _filterUseCase.getFilterDataForDefect(map);
      if (filterColumnAttributeList is SUCCESS) {} else {
        emitState(ErrorState(StateRendererType.isValid,
            filterColumnAttributeList?.failureMessage ?? "Something went wrong",
            time: DateTime
                .now()
                .millisecondsSinceEpoch
                .toString()));
      }
    } on Exception catch (e) {
      emitState(ErrorState(StateRendererType.DEFAULT, e.toString()));
    }
  }

  Future<void> getFilterColumnData(String appType, {FilterScreen curScreen = FilterScreen.screenUndefined}) async {
    emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
    if (filterAttributeList.isEmpty) {
      filterAttributeList = await _filterUseCase.readSiteFilterList();
      if (filterAttributeList.isEmpty) {
        await getFilterAttributeList(appType);
        filterAttributeList = await _filterUseCase.readSiteFilterList();
      } else {
        getFilterAttributeList(appType);
      }
      widgetList = [...filterAttributeList];
      if (curScreen == FilterScreen.screenTask) {
        widgetList.removeWhere((element) {
          return removeFiltersTaskList.contains(element["indexField"]);
        });
      }
      else {
        widgetList.removeWhere((element) {
          return removeFiltersSiteList.contains(element["indexField"]);
        });
      }
      selectedFilterData = await _filterUseCase.readSiteFilterData(
            curScreen: curScreen);
      if (selectedFilterData.isNotEmpty) {
        fillSelectedData();
      }
    }
    if (widgetList.isNotEmpty) {
      emitState(FilterListState(widgetList, FilterScreen.screenSite));
    }
  }

  void fillSelectedData() {
    String strID = "";
    for (var obj in widgetList) {
      int index = widgetList.indexOf(obj);
      strID = obj["id"].toString();
      if (selectedFilterData[strID] != null) {
        if (obj["dataType"] == "text" || obj["dataType"] == "Text") {
          if (obj["returnIndexFields"] != "-1") {} else {
            dynamic data = selectedFilterData[strID];
            var popUpTo = obj["popupTo"];
            popUpTo["data"] = data;
            obj["popupTo"] = popUpTo;
            widgetList[index] = obj;
          }
        } else if (obj["dataType"] == "Dropdown") {
          if (selectedFilterData[strID] is List) {
            var popUpTo = obj["popupTo"];
            if (popUpTo["data"] is List) {
              List arrSelected = selectedFilterData[strID];
              List arr = popUpTo["data"];
              for (var obj in arr) {
                for (var temp in arrSelected) {
                  if (obj["id"] == temp["id"]) {
                    obj["isSelected"] = true;
                    arr[arr.indexOf(obj)] = obj;
                    break;
                  }
                }
              }
              popUpTo["data"] = arr;
              obj["popupTo"] = popUpTo;
              widgetList[index] = obj;
            }
          }
        } else if (obj["dataType"] == "Date") {}
      }
    }
    updateToggle();
  }

  void updateToggle() {
    var statusObject = widgetList.singleWhere(
            (x) => x["indexField"] == "action_status",
        orElse: () => null);
    if (statusObject != null) {
      var popUpTo = statusObject["popupTo"];
      if (popUpTo["data"] is List) {
        List arr = popUpTo["data"];
        var overDueObject =
        arr.singleWhere((x) => x["id"] == "6", orElse: () => null);
        if (overDueObject != null) {
          bool value = overDueObject["isSelected"];
          if (value != _overdue) {
            _overdue = value;
          }
        }
        var completeObject =
        arr.singleWhere((x) => x["id"] == "2", orElse: () => null);
        if (completeObject != null) {
          bool value = completeObject["isSelected"];
          if (value != _completed) {
            _completed = value;
          }
        }
      }
    }
    emitState(UpdateToggleState(isOverdueEnabled, isCompletedEnabled));
  }

  void dataSelectionCallBack(Map date, int index) {
    Log.d("Date >>>> $date");
    if (widgetList[index] != null) {
      if (date.isEmpty) {
        selectedFilterData.removeWhere((key, value) => key == widgetList[index]["id"].toString());
      }
      else {
        selectedFilterData[widgetList[index]["id"].toString()] = date;
      }
    }
    emitState(UpdateFilterData(selectedFilterData, index, DateTime
        .now()
        .millisecondsSinceEpoch
        .toString()));
  }

  Future<void> getFilterSearchData(String searchText, String jsonData) async {
    try {
      emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
      Project? temp = await StorePreference.getSelectedProjectData();
      String projectID = temp?.projectID ?? "";
      Map<String, dynamic> map = <String, dynamic>{};
      map["appType"] = '2';
      map["checkHashing"] = "false";
      map["action_id"] = "707";
      map["isFromDeviceFilter"] = "true";
      map["isBlankSearchAllowed"] = "false";
      map["jsonData"] = jsonData;
      map["recordBatchSize"] = "10";
      if (searchText != "") {
        map["searchValue"] = searchText;
      }
      map["projectIds"] = projectID;
      map["selectedFolderIds"] = "-1";
      map["selectedProjectIds"] = "-1";
      map["isFromSyncCall"] = "true";
      final result = await _filterUseCase.getFilterSearchData(map);
      if (result is SUCCESS) {
        String jsonDataString = result.data.toString();
        final json = jsonDecode(jsonDataString);
        if (json['data'] != null) {
          emitState(FilterAttributeValueState(getFilterSearchBySearchText(searchText, json['data'])));
        } else {
          emitState(FilterAttributeValueState(const []));
        }
      } else {
        emitState(FilterAttributeValueErrorState(
            result?.failureMessage ?? "Something went wrong"));
      }
    } on Exception catch (e) {
      emitState(FilterAttributeValueErrorState(e.toString()));
    }
  }

  Future<void> getFilterSearchDataLocally(String searchText, List<dynamic> data) async {
    emitState(FilterAttributeValueState(getFilterSearchBySearchText(searchText, data)));
  }

  List<dynamic> getFilterSearchBySearchText(String searchText, List<dynamic> data) {
    if (!searchText.isNullOrEmpty()) {
      return data
          .where((x) =>
          x['value'].toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    }
    return data;
  }

  Future<void> saveSiteFilterData({FilterScreen curScreen = FilterScreen.screenUndefined}) async {
    await _filterUseCase.saveSiteFilterData(selectedFilterData,
        curScreen: curScreen);
  }

  Future<void> clearFilterData({FilterScreen curScreen = FilterScreen.screenUndefined}) async {
    await _filterUseCase.saveSiteFilterData({},
        curScreen: curScreen);
  }

  Future<void> clearFilterOptions(List options) async {
    emitState(FilterAttributeValueState(options));
  }

  void toggleOverDue(bool val) {
    var statusObject = widgetList.singleWhere(
            (x) => x["indexField"] == "action_status",
        orElse: () => null);
    if (statusObject != null) {
      String strID = "";
      strID = statusObject["id"].toString();
      var popUpTo = statusObject["popupTo"];
      if (popUpTo["data"] is List) {
        List arr = popUpTo["data"];
        for (var obj in arr) {
          if (obj["id"] == "6") {
            obj["isSelected"] = val;
            arr[arr.indexOf(obj)] = obj;
            if (selectedFilterData[strID] is List) {
              List arrDrop = selectedFilterData[strID];
              if (val) {
                arrDrop.add(obj);
              } else {
                arrDrop.removeWhere((element) => element["id"] == "6");
              }
              if(arrDrop.isEmpty){
                selectedFilterData.remove(strID);
              }
              else{
                selectedFilterData[strID] = arrDrop;
              }
            } else {
              if (val) {
                selectedFilterData[strID] = [obj];
              }
            }
            break;
          }
        }
        popUpTo["data"] = arr;
        statusObject["popupTo"] = popUpTo;
        widgetList[widgetList.indexOf(statusObject)] = statusObject;
      }
    }
    _overdue = val;
    emitState(UpdateToggleState(isOverdueEnabled, isCompletedEnabled));
  }

  void toggleComplete(bool val) {
    var statusObject = widgetList.singleWhere(
            (x) => x["indexField"] == "action_status",
        orElse: () => null);
    if (statusObject != null) {
      String strID = "";
      strID = statusObject["id"].toString();
      var popUpTo = statusObject["popupTo"];
      if (popUpTo["data"] is List) {
        List arr = popUpTo["data"];
        for (var obj in arr) {
          if (obj["id"] == "2") {
            obj["isSelected"] = val;
            arr[arr.indexOf(obj)] = obj;
            if (selectedFilterData[strID] is List) {
              List arrDrop = selectedFilterData[strID];
              if (val) {
                arrDrop.add(obj);
              } else {
                arrDrop.removeWhere((element) => element["id"] == "2");
              }
              if(arrDrop.isEmpty){
                selectedFilterData.remove(strID);
              }
              else{
                selectedFilterData[strID] = arrDrop;
              }
              
            } else {
              if (val) {
                selectedFilterData[strID] = [obj];
              }
            }
            break;
          }
        }
        popUpTo["data"] = arr;
        statusObject["popupTo"] = popUpTo;
        widgetList[widgetList.indexOf(statusObject)] = statusObject;
      }
    }
    _completed = val;
    emitState(UpdateToggleState(isOverdueEnabled, isCompletedEnabled));
  }

  showDropDown(String title, int index,String titleFilter) {
    emitState(ShowDropDownState(index, titleFilter,message: title));
  }

  void showDatePicker(int index, String labelText) {
    emitState(ShowDatePickerState(index, labelText: labelText));
  }

  void selectDate(int index, String date) {
    emitState(ShowDatePickerState(index, date: date));
  }

  dismissDropDown() {
    emitState(DismissDropDownState(DateTime
        .now()
        .millisecondsSinceEpoch
        .toString()));
  }

  selectDropDown(List<dynamic> value, int index) {
    updateDropdownValues(index, value);
    emitState(UpdateFilterData(selectedFilterData, index, DateTime
        .now()
        .millisecondsSinceEpoch
        .toString()));
  }

  clearDropDown(int index) {
    updateDropdownValues(index, List.empty());
    emitState(UpdateFilterData(selectedFilterData, index, DateTime
        .now()
        .millisecondsSinceEpoch
        .toString()));
  }

  void updateDropdownValues(int index, List<dynamic> valueList) {
    var temp = widgetList[index];
    if (temp["dataType"] == "text" || temp["dataType"] == "Text") {
      if (temp["returnIndexFields"] != "-1") {
        if (valueList.isNotEmpty) {
          selectedFilterData[temp["id"].toString()] = valueList;
        } else {
          selectedFilterData
              .removeWhere((key, value) => key == temp["id"].toString());
        }
      }
    } else {
      List arrSelected = [];
      for (var obj in valueList) {
        if (obj["isSelected"]) {
          arrSelected.add(obj);
        }
      }
      if (temp["indexField"] == "action_status") {
        updateToggle();
      }
      if (arrSelected.isNotEmpty) {
        selectedFilterData[temp["id"].toString()] = arrSelected;
      } else {
        selectedFilterData
            .removeWhere((key, value) => key == temp["id"].toString());
      }
    }
  }
}
