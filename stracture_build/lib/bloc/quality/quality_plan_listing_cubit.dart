import 'dart:convert';

import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/quality/quality_plan_listing_state.dart';
import 'package:field/bloc/sitetask/sitetask_state.dart';
import 'package:field/domain/use_cases/quality/quality_plan_listing_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/utils/toolbar_mixin.dart';

import '../../data/model/project_vo.dart';
import '../../data/model/quality_plan_list_vo.dart';
import '../../data/model/quality_search_vo.dart';
import '../../enums.dart';
import '../../exception/app_exception.dart';
import '../../networking/request_body.dart';
import '../../utils/constants.dart';
import '../../utils/store_preference.dart';

enum InternalState { loading, success, failure }

enum QualityPlanSearchMode { recent, suggested, other }

enum QualityMode { listMode, searchMode }

class QualityPlanListingCubit extends BaseCubit with ToolbarTitle {
  final QualityPlanListingUseCase _qualityPlanListingUseCase;

  QualityPlanListingCubit({QualityPlanListingUseCase? useCase})
      : _qualityPlanListingUseCase = useCase ?? di.getIt<QualityPlanListingUseCase>(),
        super(FlowState());

  late QualityPlanListVo qualityPlanListingVO = QualityPlanListVo();
  List<Data> loadedItems = [];
  //List of Quality
  int recordBatchSize = 25;
  int currentPage = 1;
  int startFrom = 0;
  int totalCount = 0;

  //search quality Plan
  int recordBatchSizeSearch = 10;
  int currentPageSearchNo = 0;
  int startFromSearch = 0;
  int totalCountSearch = 0;

  ListSortField _sortValue = ListSortField.lastUpdatedDate;
  QualityMode qualityMode = QualityMode.listMode;

  bool _sortOrder = true;
  bool isSuggestionSelected = false;
  double scrollPosition = 0;

  set setSuggesion(bool isSuggestion) {
    isSuggestionSelected = isSuggestion;
  }

  bool get getSuggestion => isSuggestionSelected;
  // search data
  final List<Data> _searchQualityPlanList = [];

  List<Data> recentList = [];
  QualityPlanSearchMode _searchMode = QualityPlanSearchMode.recent;
  bool isSearchAlreadyLoading = false;
  Map<String, dynamic>? searchResult;
  var searchString = '';
  bool isSubmitted = false;

  List<Data> get searchLocationList => _searchQualityPlanList;

  QualityPlanSearchMode get searchMode => _searchMode;

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
      (_sortValue == ListSortField.title)
          ? _sortOrder = false
          : _sortOrder = true;
      emitState(SortChangeState());
    }
  }

  Future<String> getSelectedProjectFrom() async {
    Project? temp = await StorePreference.getSelectedProjectData();
    if(temp != null) {
      String projectID = temp!.projectID ?? "";
      return projectID;
    }return "";
  }

  getQualityPlanList(int offset) async {
    if (searchString.isEmpty) {
      if (!(totalCount > 0 && offset >= totalCount)) {
        if (scrollPosition == 0 && offset == 0) {
          startFrom = totalCount = 0;
          currentPage = 1;
          loadedItems = [];
        }
        String projectId = await getSelectedProjectFrom();
        if (projectId.isNotEmpty) {
          var lastApiCallTimeStamp = DateTime.now().millisecondsSinceEpoch;

          var request = getDataMap(projectId, lastApiCallTimeStamp);
          if (scrollPosition > 0 && offset == 0) {
            request["currentPageNo"] = (currentPage - 1).toString();
            request["recordBatchSize"] =
                ((currentPage - 1) * recordBatchSize).toString();
            request["recordStartFrom"] = '0';
          }
          final result = await _qualityPlanListingUseCase
              .getQualityPlanListingFromServer(request);
          if (result is SUCCESS &&
              (result.requestData as Json)
                  .data[AConstants.keyLastApiCallTimestamp] ==
                  lastApiCallTimeStamp) {
            try {
              qualityPlanListingVO = result.data;
              if(qualityPlanListingVO.data != null) {
                loadedItems.addAll(qualityPlanListingVO.data as List<Data>);
              }
              currentPage = int.parse(qualityPlanListingVO.currentPageNo.toString()) + 1;
              totalCount = int.parse(qualityPlanListingVO.totalDocs.toString());
              startFrom += recordBatchSize;
              if (scrollPosition > 0) {
                startFrom = qualityPlanListingVO.data!.length;
                Future.delayed(const Duration(milliseconds: 50)).then(
                        (value) => emitState(ScrollState(position: scrollPosition)));
              } else {
                emitState(SuccessState(const {},
                    time: DateTime.now().millisecondsSinceEpoch.toString()));
              }
              return qualityPlanListingVO.data;
            } catch (e) {
              emitState(ErrorState(StateRendererType.DEFAULT, e.toString()));
              throw AppException(message: e.toString());
            }
          } else {
            emitState(ErrorState(StateRendererType.DEFAULT, result?.failureMessage ?? "Something went wrong"));
            throw AppException(message: result?.failureMessage ?? "Something went wrong");
          }
        }
      }
    } else {
      if (!(totalCountSearch > 0 && offset >= totalCountSearch)) {
        return getSuggestedSearchList(searchString.trim(),isFromSuggestion: false,offset: offset);
      }
    }
  }

  Map<String, dynamic> getDataMap(
      String projectId, dynamic lastApiCallTimeStamp) {
    Map<String, dynamic> map = {};
    map["action_id"] = "100";
    map["projectId"] = projectId;
    map["currentPageNo"] = currentPage.toString();
    map["recordBatchSize"] = recordBatchSize.toString();
    map["recordStartFrom"] = startFrom.toString();
    map["projectIds"] = "-2";
    map["listingType"] = "134";
    map["sortField"] = sortValue.fieldName;
    map["sortFieldType"] =
        sortValue.fieldName == "title" ? "text" : "timestamp";
    map["sortOrder"] = sortOrder ? "desc" : "asc";
    map["applicationId"] = "3";
    map["checkHashing"] = "false";
    map[AConstants.keyLastApiCallTimestamp] = lastApiCallTimeStamp;
    return map;
  }

  String getDateInProperFormat(String? dateTime) {
    String date = "";
    List<String> lstDate = dateTime!.split("#");
    if (lstDate.isNotEmpty) {
      date = lstDate[0];
    }
    return date;
  }

  Future<void> addRecentQualityPlanList({String? qualityPlanTitle}) async {
    final bool matchNewSearch =
        recentList.any((element) => element.planTitle == qualityPlanTitle);
    if (matchNewSearch) {
      recentList.removeWhere((element) => element.planTitle == qualityPlanTitle);
    }
      recentList.insert(0, Data(planTitle: qualityPlanTitle!));
      if (recentList.isNotEmpty && recentList.length > 5) {
        recentList.removeLast();
      }

      for (var element in recentList) {
        element.toJson();
      }

      await StorePreference.setRecentQualitySearchPrefData(
          AConstants.recentSearchQualityPlan, jsonEncode(recentList));
  }

  Future<void> removeQualityFromRecentSearch({String? newSearch}) async {
    recentList.removeWhere((element) => element.planTitle == newSearch);
    for (var element in recentList) {
      element.toJson();
    }

    await StorePreference.setRecentQualitySearchPrefData(
        AConstants.recentSearchQualityPlan, jsonEncode(recentList));

    _searchQualityPlanList;
  }

  Future<List?> getRecentQualityPlan(bool isFromInit) async {
    final recentFromLocal = await StorePreference.getRecentQualityPrefData(
        AConstants.recentSearchQualityPlan);

    recentList = [];
    final getRecentList = recentFromLocal != null && recentFromLocal.isNotEmpty
        ? jsonDecode(recentFromLocal) as List<dynamic>
        : [];

    if (getRecentList.isNotEmpty) {
      for (var element in getRecentList) {
        recentList.add(Data.fromJson(element));
      }
    }
    _searchMode = QualityPlanSearchMode.recent;
    if (!isFromInit) {
      emitState(QualityPlanSearchSuggestionList(searchList: recentList));
    } else {
      _searchQualityPlanList;
    }
    return recentList;
  }

  Future<List<Data>> getSuggestedSearchList(
      String searchValue, {bool? isFromSuggestion = true, int offset=0}) async {
    String projectId = await getSelectedProjectFrom();
    if(projectId.isNotEmpty) {
      if (offset == 0) {
        startFromSearch = totalCountSearch = 0;
        currentPageSearchNo = 0;
      }
      Map<String, dynamic> map = getRequestMapDataForPopupPagination(projectId, searchValue, isFromSuggestion!);
      try {
        List<Data> suggestedSearchList = [];
        Result? result = await _qualityPlanListingUseCase.getQualityPlanSearch(map);
        if (result is SUCCESS) {
          QualitySearchVo qualitySearchVo = result.data;
          if (qualitySearchVo.filterData != null && qualitySearchVo.filterData!.totalDocs != 0 && qualitySearchVo.filterData!.data!.isNotEmpty) {
            suggestedSearchList.addAll(qualitySearchVo.filterData!.data!);
            emitState(QualityPlanSearchSuggestionList(searchList: suggestedSearchList));
            if(!isFromSuggestion) {
              totalCountSearch = int.parse(qualitySearchVo.filterData!.totalDocs.toString());
              currentPageSearchNo = int.parse(qualitySearchVo.filterData!.currentPageNo.toString()) + 1;
              startFromSearch += recordBatchSizeSearch;
            }
          } else {
            // emitState(ErrorState(StateRendererType.POPUP_ERROR_STATE, "No matches found"));
            updateErrorVisibility();
          }
        } else {
          emitState(ErrorState(StateRendererType.POPUP_ERROR_STATE, "Something went wrong"));
        }
        return suggestedSearchList;
      } on Exception catch (e) {
        Log.d(e);
      }
    }
    return [];
  }

  Map<String, dynamic> getRequestMapDataForPopupPagination(projectId, searchValue,bool isdFromSuggestion,) {
    Map<String, dynamic> map = {};
    Map<String, dynamic> jsonData = {};
    List filterQueryVos = [];
    filterQueryVos.add(<String, dynamic>{
      "popupTo": {
        "recordBatchSize": 10,
        "data": [
          <String, dynamic>{"id": "$searchValue", "value": "$searchValue"}
        ]
      },
      "fieldName": "title",
      "indexField": "title",
      "operatorId": "11",
      "dataType": "Text",
      "labelName": "Title",
      "solrCollections": "-1",
      "listingColumnFieldName": "planTitle"
    });

    jsonData["selectedProjectIds"] = projectId;
    jsonData["filterQueryVOs"] = filterQueryVos;
    map["currentPageNo"] = isdFromSuggestion?0:"$currentPageSearchNo";
    map["recordStartFrom"] = isdFromSuggestion?0:"$startFromSearch";
    map["recordBatchSize"] = "$recordBatchSizeSearch";
    map["action_id"] = "705";
    map["collectionType"] = "134";
    map["appType"] = "1";
    map["jsonData"] = jsonEncode(jsonData);
    return map;
  }

  onClearSearch() {
    _searchQualityPlanList.clear();
    _searchMode = QualityPlanSearchMode.recent;
    emitState(
        ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  set setSearchMode(QualityPlanSearchMode mode) {
    if (_searchMode != mode) {
      _searchMode = mode;
      emitState(QualityPlanSearchModeState(_searchMode));
    }
  }

  void updateSearchBarVisibleState(bool isExpand) {
    emitState(QualitySearchBarVisibleState(isExpand));
  }

  void changeSearchMode(QualityPlanSearchMode searchMode) {
    _searchMode = searchMode;
    emitState(QualityPlanSearchModeState(_searchMode));
  }

  get getSearchMode => _searchMode;

  updateErrorVisibility() async {
    emitState(UpdateNoMatchesFound(isSubmitted));
  }

  updateIndexData(value){
    if(value != null){
      for (var planData in loadedItems) {
        if(planData.planId == value['planId']){
          planData.percentageCompletion = value['percentageCompletion'];
          emitState(RefreshPaginationItemState());
          break;
        }
      }
    }
  }
}
