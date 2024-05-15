import 'dart:convert';

import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/sitetask/sitetask_state.dart';
import 'package:field/data/model/tasklisting_vo.dart';
import 'package:field/data/model/tasklistingsearch_vo.dart';
import 'package:field/data/model/taskstatussist_vo.dart';
import 'package:field/domain/use_cases/tasklisting/task_listing_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/toolbar_mixin.dart';

import '../../data/model/form_vo.dart';
import '../../data/model/project_vo.dart';
import '../../domain/use_cases/Filter/filter_usecase.dart';
import '../../domain/use_cases/sitetask/sitetask_usecase.dart';
import '../../enums.dart';
import '../../exception/app_exception.dart';
import '../../logger/logger.dart';
import '../../networking/request_body.dart';
import '../../utils/constants.dart';
import '../../utils/store_preference.dart';
import '../../utils/user_activity_preference.dart';
import '../task_action_count/task_action_count_cubit.dart';

enum InternalState { loading, success, failure }

class TaskListingCubit extends BaseCubit with ToolbarTitle {
  final TaskListingUseCase _taskListingUseCase;

  TaskListingCubit({TaskListingUseCase? useCase})
      : _taskListingUseCase = useCase ?? di.getIt<TaskListingUseCase>(),
        super(InitialState(stateRendererType: StateRendererType.DEFAULT));
  bool? isOverdueEnable;
  bool? isCompletedEnable;
  final SiteTaskUseCase _siteTaskUseCase = di.getIt<SiteTaskUseCase>();
  final _filterUseCase = di.getIt<FilterUseCase>();
  late TaskListingVO taskListingVO = TaskListingVO(elementVOList: []);
  late List<TaskStatusListVo> taskStatusListVO = [];

  List<SiteForm> taskListVO = [];
  int recordBatchSize = 25;
  int currentPage = 1;
  int startFrom = 0;
  int totalCount = 0;
  ListSortField _sortValue = ListSortField.creationDate;
  bool _sortOrder = true;
  double scrollPosition = 0;

  get sortOrder => _sortOrder;

  set setSortOrder(bool bSetOrder) {
    if (_sortOrder != bSetOrder) {
      _sortOrder = bSetOrder;
      emitState(SortChangeState());
    }
  }

  get sortValue => _sortValue;

  set setSortValue(ListSortField newSortValue) {
    if (_sortValue != newSortValue) {
      _sortValue = newSortValue;
      (_sortValue == ListSortField.siteTitle)
          ? _sortOrder = false
          : _sortOrder = true;
      emitState(SortChangeState());
    }
  }
  String _searchSummaryValue = "";
  /// searching by summary field

  setFilterApply(bool filterApply){
    emitState(ApplyFilterState(filterApply));
  }

  onChangeOverdueEnable() {
    isOverdueEnable = !isOverdueEnable!;
    //await StorePreference.setPushNotificationEnable(isPushNotificationEnable);
    //emit(EnablePushNotification(isPushNotificationEnable!, DateTime.now().millisecondsSinceEpoch.toString()));
  }

  onChangeCompletedEnable() {
    isCompletedEnable = !isCompletedEnable!;
    //await StorePreference.setPushNotificationEnable(isPushNotificationEnable);
    //emit(EnablePushNotification(isPushNotificationEnable!, DateTime.now().millisecondsSinceEpoch.toString()));
  }

  Future<Result?> getTaskListing(String strUserId) async {
    Map<String, dynamic> request = {};
    request["isOnline"] = isNetWorkConnected();
    request["isFromMyTask"] = "true";
    List<Criteria> listOfCriteria = [];
    //listOfCriteria.add(Criteria(field: "StatusId", operator: 1, values: [1]));
    listOfCriteria.add(Criteria(field: "EntityType", operator: 1, values: [1]));
    listOfCriteria.add(Criteria(field: "AssigneeId", operator: 1, values: [strUserId]));
    Tasklistingsearchvo taskListingSearchObj = Tasklistingsearchvo(recordStart: 0,
        recordLimit: 50,
        groupRecordLimit: 50,
        groupField: 1,
        criteria: listOfCriteria);
    request["searchCriteria"] = taskListingSearchObj.toJson().toString();

    return await _taskListingUseCase.getTaskListing(request);
  }

  Future<Result?> getTaskStatusList() async {
    Map<String, dynamic> request = {};
    request["isOnline"] = isNetWorkConnected();
    return await _taskListingUseCase.getTaskStatusList(request);
  }

  Future<void> loadTaskListingData(Object? arguments) async {
    if(!await checkIfProjectSelected()){
      return;
    }
    emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT, message: "Loading"));
    await _filterUseCase.saveSiteFilterData({}, curScreen: FilterScreen.screenTask);
    if (arguments != null) {
      arguments as Map<String, dynamic>;
      if (arguments.containsKey("isFrom")) {
        switch (arguments["isFrom"] as TaskActionType) {
          case TaskActionType.newTask:
            await _filterUseCase.applyDashboardNewTaskFilter();
            break;
          case TaskActionType.dueToday:
            await _filterUseCase.applyDashboardDueTodayFilter();
            break;
          case TaskActionType.dueThisWeek:
            await _filterUseCase.applyDashboardDueThisWeekFilter();
            break;
          case TaskActionType.overDue:
            await _filterUseCase.applyDashboardOverDueFilter();
            break;
        }
      }
    }
    emitState(SuccessState(const {}, time: DateTime
        .now()
        .millisecondsSinceEpoch
        .toString()));
  }

  getNewTaskList(int offset) async {
    List<SiteForm> itemList = [];
    if (!(totalCount > 0 && offset >= totalCount)) {
      if (scrollPosition == 0 && offset == 0) {
        startFrom = totalCount = 0;
        currentPage = 1;
      }
      Project? temp = await StorePreference.getSelectedProjectData();
      if (temp != null) {
        var lastApiCallTimeStamp = DateTime
            .now()
            .millisecondsSinceEpoch;
        String projectID = temp.projectID ?? "";
        Map searchMapData = {
          'summary': !_searchSummaryValue.isNullOrEmpty() ? _searchSummaryValue : null
        };
        var filterData = await _filterUseCase.getFilterJsonByIndexField(searchMapData, curScreen: FilterScreen.screenTask, isNeedToSave: false);
        changeFilterStatus(filterData);
        var request = await getDataMap(projectID, lastApiCallTimeStamp, filterData);
        if(scrollPosition > 0 && offset == 0){
          request["currentPageNo"] = (currentPage-1).toString();
          request["recordBatchSize"] = ((currentPage-1) * recordBatchSize).toString();
          request["recordStartFrom"] = '0';
        }
        final result = await _siteTaskUseCase.getFilterSiteTaskList(request);
        if (result is SUCCESS && (result.requestData as Json).data[AConstants.keyLastApiCallTimestamp] == lastApiCallTimeStamp) {
          try {
            String jsonDataString = result.data.toString();
            final json = jsonDecode(jsonDataString);
            if (json.containsKey("data")) {
              itemList = List<SiteForm>.from(json['data'].map((x) => SiteForm.fromJson(x)));
            }
            currentPage = int.parse(json['currentPageNo'].toString()) + 1;
            totalCount = int.parse(json['totalDocs'].toString());
            startFrom += recordBatchSize;
            if(scrollPosition > 0){
              startFrom = itemList.length;
              emitStateWithDuration(ScrollState(position: scrollPosition),const Duration(milliseconds: 50));
            }
          } catch (e) {
            throw AppException(message: e.toString());
          }
        } else {
          throw AppException(message: result?.failureMessage ?? "Something went wrong");
        }
      } else {
        throw AppException(message: "Project is not selected");
      }
    }
    return itemList;
  }

  getTaskDetail(SiteForm obj) async {
    Map<String, dynamic> request = {
      'recordBatchSize': '5',
      'listingType': '31',
      'recordStartFrom': '0',
      'application_Id': '3',
      'isFromAndroidApp': 'true',
      'isFromSyncCall': 'true',
      'isRequiredTemplateData': 'true',
      'action_id': '100',
      'projectId': obj.projectId,
      'selectedFormId': obj.commId.plainValue()
    };
    final result = await _taskListingUseCase.getTaskDetail(request);
    if (result is SUCCESS) {
      String jsonDataString = result.data.toString();
      final json = jsonDecode(jsonDataString);
      if (json.containsKey("data")) {
        obj.updateDisplayingContent(List<SiteForm>.from(json['data'].map((x) => SiteForm.fromJson(x))).first);
        emitState(RefreshPaginationItemState());
      }
    }
  }

  Future<Map<String, dynamic>> getDataMap(String projectId, dynamic lastApiCallTimeStamp, String jsonData) async {
    Map<String, dynamic> map = {};
    map["action_id"] = "706";
    map["filterId"] = "-1";
    map["filterName"] = "-1";
    map["collectionType"] = "31";
    map["isUnsavedFilter"] = "true";
    map["isScheduledReturn"] = "0";
    map["isForAssocComms"] = "false";
    map["appType"] = "2";
    map["isRequiredTemplateData"] = "true";
    map["currentPageNo"] = currentPage.toString();
    map["recordBatchSize"] = recordBatchSize.toString();
    map["recordStartFrom"] = startFrom.toString();
    map["selectedProjectIds"] = "-1";
    map["projectIds"] = projectId.plainValue();
    map["folderId"] = "-1";
    map["jsonData"] = jsonData;
    map["sortField"] = sortValue.fieldName;
    map["sortFieldType"] = sortValue.fieldName == "title" ? "text" : "timestamp";
    map["sortOrder"] = sortOrder ? "desc" : "asc";
    map["applicationId"] = "3";
    map["checkHashing"] = "false";
    map["requiredCustomAttributes"] = "CFID_Assigned,CFID_DefectTyoe,CFID_TaskType";
    map["customAttributeFieldPresent"] = "true";
    map["isFromDeviceFilter"] = "true";
    map["projectId"] = projectId;
    map["isFromSyncCall"] = "true";
    if (await StorePreference.getIncludeCloseOutFormFlag() == false) {
      map['isExcludeClosesOutForms'] = "true";
    }
    map[AConstants.keyLastApiCallTimestamp] = lastApiCallTimeStamp;
    return map;
  }

  String getStatusNameFromActionStatus(int? actionStatus) {
    String strStatusName = "Open";
    if (actionStatus != 0) {
      for (TaskStatusListVo taskStatusObj in taskStatusListVO) {
        if (actionStatus == taskStatusObj.statusId) {
          strStatusName = taskStatusObj.statusName ?? "";
        }
      }
    }
    return strStatusName;
  }

  String getDateInProperFormat(String? dateTime) {
    String date = "";
    List<String> lstDate = dateTime!.split("#");
    if (lstDate.isNotEmpty) {
      date = lstDate[0];
    }
    return date;
  }

  void updateSearchBarVisibleState(bool isExpand) {
    emitState(SearchBarVisibleState(isExpand));
  }

  void setSearchSummaryFilterValue(String value) {
    _searchSummaryValue = value;
  }

  String getSearchSummaryFilterValue() {
    return _searchSummaryValue;
  }

  Future<List<String>> getRecentSearchedTaskList() async {
    return await getRecentSearchTaskListData();
  }

  Future<void> saveRecentSearchTaskList(List<String> options) async {
    await setRecentSearchTaskListData(options);
  }

  changeFilterStatus(var jsonData){
    Map map = jsonDecode(jsonData);
    if(map.containsKey("filterQueryVOs")){
      List arr = map['filterQueryVOs'];
      Log.d("Arr length ${arr.length}");
      if(arr.length>2){
        setFilterApply(true);
      }else{
        setFilterApply(false);
      }
    }
  }
}
