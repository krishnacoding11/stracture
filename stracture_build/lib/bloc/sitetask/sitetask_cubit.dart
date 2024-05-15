import 'dart:convert';

import 'package:field/analytics/event_analytics.dart';
import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/sitetask/sitetask_state.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/pinsdata_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/domain/use_cases/sitetask/sitetask_usecase.dart';
import 'package:field/injection_container.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/networking/request_body.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/site_item/site_item.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/file_form_utility.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/user_activity_preference.dart';
import 'package:field/utils/utils.dart';

import '../../data/local/sitetask/sitetask_local_repository_impl.dart';
import '../../enums.dart';
import '../../utils/constants.dart';
import '../../utils/url_helper.dart';

enum StackDrawerOptions { drawerBody, filter, datePicker }

enum SearchMode { recent, suggested, other }

class SiteTaskCubit extends BaseCubit {
  final SiteTaskUseCase _siteTaskUseCase;
  late SiteLocation? location;
  late Project? project;

  int recordBatchSize = 25;
  int currentPage = 1;
  int startFrom = 0;
  int totalCount = 0;
  SiteForm? selectedItem;
  String selectedFormId = "";
  SearchMode _searchMode = SearchMode.other;
  String selectedFormCode = "";
  int selectedPinLocationId = 0;
  StackDrawerOptions drawerOptions = StackDrawerOptions.drawerBody;
  List<SiteItem> loadedItems = [];
  List<SiteForm> recentList = [];
  static ListSortField sortValue = ListSortField.creation_date;
  static bool sortOrder = true; //sort order default descending and icon is 'v' if date in sort
  String? _searchSummaryTitleValue;
  bool filterApplied = false;
  bool applyStaticFilter = false;

  //Map filterJson = {};
  int lastApiCallTimeStamp = 0;
  final _filterUseCase = FilterUseCase();

  SiteTaskCubit({SiteTaskUseCase? useCase})
      : _siteTaskUseCase = useCase ?? getIt<SiteTaskUseCase>(),
        super(FlowState());

  setCurrentLocation(SiteLocation? obj) {
    location = obj;
  }

  setCurrentPinSelectLocation(int locationId){
    selectedPinLocationId = locationId;
  }

  setCurrentProject(Project? proj) {
    project = proj;
  }

  setSelectedFormId(String? formId) {
    selectedFormId = formId ?? "";
  }

  setSelectedFormCode(String? formCode){
    selectedFormCode = formCode ?? "";
  }

  setSelectedItem(SiteForm? siteForm) {
    selectedItem = siteForm;
  }

  setFilterApply(bool filterApply) {
    filterApplied = filterApply;
  }

  set setSearchMode(SearchMode mode) {
    if (_searchMode != mode) {
      _searchMode = mode;
      emitState(SearchModeState(_searchMode));
    }
  }

  get getSearchMode => _searchMode;

  void setDrawerValue(StackDrawerOptions drawerOption) {
    drawerOptions = drawerOption;
    Log.d("drawerOptions >>> $drawerOptions");
    emitState(StackDrawerState(drawerOptions));
  }

  StackDrawerOptions getDrawerValue() {
    return drawerOptions;
  }

  Future<SiteForm?> getUpdatedSiteTaskItem(String projectId, String formId) async {
    try {
      final result = await _siteTaskUseCase.getUpdatedSiteTaskItem(projectId, formId);
      if (result is SUCCESS) {
        String jsonDataString = result.data.toString();
        final jsonObj = jsonDecode(jsonDataString);
        List<dynamic>? siteFormList = jsonObj["data"];
        SiteForm siteForm = SiteForm.fromJson(siteFormList?.first);
        for (var taskItem in loadedItems) {
          if (taskItem.item.formId == siteForm.formId) {
            //need to add data in siteform;
            //Taking locationPath from old taskItem as updated response does not contains locationpath
            final locationPath = taskItem.item.locationPath;
            taskItem.item = siteForm;
            if (taskItem.item.locationPath.isNullOrEmpty()) {
              taskItem.item.locationPath = locationPath;
            }
            taskItem.item.locationPath = siteForm.locationPath ?? taskItem.item.locationPath;
            emitState(RefreshWebViewGlobalKeyState());
            await onFormItemClicked(taskItem.item);
            return taskItem.item;
          }
        }
      } else {
        emitState(ErrorState(StateRendererType.isValid, result?.failureMessage ?? "Something went wrong", time: DateTime.now().millisecondsSinceEpoch.toString()));
      }
    } on Exception catch (e) {
      emitState(ErrorState(StateRendererType.DEFAULT, e.toString()));
    }
    return null;
  }

  /*Future<void> addRecentSiteTask({String? newSearch}) async {
    if(newSearch == null || newSearch.isEmpty){
      return;
    }
    final bool matchNewSearch =
    recentList.any((element) => element.title == newSearch);

    if(matchNewSearch){
      recentList.removeWhere((element) => element.title == newSearch);
    }
    recentList.insert(0, SiteForm(title: newSearch));
    if (recentList.isNotEmpty && recentList.length > 5) {
      recentList.removeLast();
    }
    for (var element in recentList) {
      element.toJson();
    }
    *//*await StorePreference.setRecentProjectPrefData(
        AConstants.recentSiteTask, jsonEncode(recentList));*//*
  }*/

  updateItemValues(SiteForm siteForm) {
    for (var taskItem in loadedItems) {
      if (taskItem.item.formId == siteForm.formId) {
        //need to add data in siteform;
        //Taking locationPath from old taskItem as updated response does not contains locationpath
        final locationPath = taskItem.item.locationPath;
        taskItem.item = siteForm;
        if (taskItem.item.locationPath.isNullOrEmpty()) {
          taskItem.item.locationPath = locationPath;
        }
        emitState(RefreshPaginationItemState());
        // emitState(RefreshWebViewGlobalKeyState());
        // onFormItemClicked(taskItem.item);
        break;
      }
    }
  }

  Future<Result?> getExternalAttachmentList(dynamic map) async {
    try {
      final result = await _siteTaskUseCase.getExternalAttachmentList(map);
      if (result is SUCCESS) {
        String jsonDataString = result.data.toString();
        final jsonObj = jsonDecode(jsonDataString);
        List<AttachmentItem> tempItems = [];
        for (var i in jsonObj) {
          tempItems.add(AttachmentItem(i['formId'], i['revisionId'], i['attachmentCount'], i['fileExtensionType'], realPath: i["realPath"] ?? ""));
        }
        if (tempItems.isNotEmpty) {
          for (var taskItem in loadedItems) {
            for (var attachItem in tempItems) {
              if (attachItem.formId.plainValue() == taskItem.item.formId.plainValue()) {
                await taskItem.addAttachment(attachItem);
              }
            }
          }
          emitState(RefreshPaginationItemState());
        }
      } else {
        emitState(ErrorState(StateRendererType.isValid, result?.failureMessage ?? "Something went wrong", time: DateTime.now().millisecondsSinceEpoch.toString()));
      }
    } on Exception catch (e) {
      emitState(ErrorState(StateRendererType.DEFAULT, e.toString()));
    }
    return null;
  }

  getSiteTaskList(dynamic map) async {
    emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
    try {
      bool filterApplied = await isFilterApplied();
      final result = filterApplied ? await _siteTaskUseCase.getFilterSiteTaskList(map) : await _siteTaskUseCase.getSiteTaskList(map);
      if (result is SUCCESS) {
        emitState(SuccessState(result));
      } else {
        emitState(ErrorState(StateRendererType.isValid, result?.failureMessage ?? "Something went wrong", time: DateTime.now().millisecondsSinceEpoch.toString()));
      }
    } on Exception catch (e) {
      emitState(ErrorState(StateRendererType.DEFAULT, e.toString()));
    }
  }

  Future<List<SiteItem>> pageFetch(int offset) async {
    List<SiteItem> itemList = [];
    List<SiteItem> offlineItemList = [];
    if (totalCount > 0 && offset >= totalCount) {
      return itemList;
    }
    if (offset == 0) {
      startFrom = totalCount = 0;
      currentPage = 1;
      loadedItems = [];
    }
    Result? result;
    bool isLastApiCallTimeStamp = false;

    if(applyStaticFilter){
      var projId = (location != null) ? location!.projectId : project!.projectID;
      result = await _siteTaskUseCase.getUpdatedSiteTaskItem(projId.toString(), selectedFormId);
      isLastApiCallTimeStamp = true;
    } else {
      // bool filterApplied = await isFilterApplied();
      Map<String, dynamic> requestMap = await getDataMap();
      if (await StorePreference.getIncludeCloseOutFormFlag() == false) {
        requestMap['isExcludeClosesOutForms'] = "true";
      }
      if (isNetWorkConnected() && currentPage == 1) {
        requestMap["onlyOfflineCreatedDataReq"] = true;
        final offlineResult = await getIt<SiteTaskLocalRepository>().getSiteTaskList(requestMap);
        if (offlineResult != null) {
          final json = jsonDecode(offlineResult.data.toString());
          if (json['data'] != null) {
            offlineItemList = List<SiteForm>.from(json['data'].map((x) {
              SiteForm item = SiteForm.fromJson(x);
              item.isSyncPending = true;
              return item;
            })).map((v) => SiteItem(v)).toList();
          }
        }
      }
      result = filterApplied ? await _siteTaskUseCase.getFilterSiteTaskList(requestMap) : await _siteTaskUseCase.getSiteTaskList(requestMap);
      isLastApiCallTimeStamp = (result?.requestData as Json).data[AConstants.keyLastApiCallTimestamp] == lastApiCallTimeStamp;
    }

    if (result is SUCCESS && isLastApiCallTimeStamp) {
      String jsonDataString = result. data.toString();
      final json = jsonDecode(jsonDataString);
      if (json['data'] != null) {
        itemList = List<SiteForm>.from(json['data'].map((x) => SiteForm.fromJson(x))).map((v) => SiteItem(v)).toList();
        if (offlineItemList.isNotEmpty) {
          for (int i = 0; i < offlineItemList.length; i++) {
            itemList.insert(i, offlineItemList[i]);
          }
          totalCount = offlineItemList.length;
        }
        if (itemList.isNotEmpty) {
          loadedItems.addAll(itemList);
          currentPage = int.parse(json['currentPageNo'].toString()) + 1;
          totalCount = int.parse(json['totalDocs'].toString());
          startFrom += recordBatchSize;
          String formIds = "";
          for (var item in itemList) {
            if (formIds != '') {
              formIds = "$formIds,";
            }
            formIds = "$formIds${item.item.formId}";
          }

          //Todo: need to replace this isOnline when offline is implemented for external attachmentlist
          var projId = (location != null) ? location!.projectId : project?.projectID;
          getExternalAttachmentList({'projectId': projId, 'formIds': formIds});
        }
      }
    }
    if (itemList.isNotEmpty) {
      if (selectedFormId.isNotEmpty) {
        final item = itemList.where((element) => element.item.formId == selectedFormId).toList();
        if (item.isNotEmpty && item.first.item.isSiteFormSelected == false) {
          setSelectedItem(item.first.item);
          setSelectedFormId(selectedFormId);
          applyStaticFilter = false;
          item.first.item.isSiteFormSelected = true;
          emitState(ScrollState(isScrollRequired: true));
        } else if(!applyStaticFilter && selectedFormCode.isNotEmpty){
          final loadItem = loadedItems.where((element) => element.item.formId == selectedFormId).toList();
          setSelectedFormId(selectedFormId);
          if(loadItem.isNotEmpty){
            setSelectedItem(loadItem.first.item);
            loadItem.first.item.isSiteFormSelected = true;
            applyStaticFilter = false;
            emitState(ScrollState(isScrollRequired: true));
          } else {
            loadedItems = [];
            applyStaticFilter = true;
            emitState(DefaultFormCodeFilterState(formCode: selectedFormCode.toString(),isFormCodeFilterApply: true));
          }
        }
      }

      if (offset == 0 && selectedItem == null && Utility.isTablet) {
        setSelectedItem(itemList[0].item);
        selectedItem?.isSiteFormSelected = true;
      }
    } else if (itemList.isEmpty) {
      setSelectedItem(null);
    }
    return itemList;
  }

  int getTotalCount() {
    return totalCount;
  }

  int getTaskListCount() {
    if (startFrom > totalCount) {
      return totalCount;
    }
    return startFrom;
  }

  Future<Map<String, dynamic>> getDataMap() async {
    lastApiCallTimeStamp = DateTime.now().millisecondsSinceEpoch;

    Map<String, dynamic> map = {};
    map["appType"] = "2";
    map["applicationId"] = "3";
    map["checkHashing"] = "false";
    map["isRequiredTemplateData"] = "true";
    map["requiredCustomAttributes"] = "CFID_Assigned,CFID_DefectTyoe,CFID_TaskType";
    map["customAttributeFieldPresent"] = "true";


    if(location != null) {
      map["projectId"] = location!.projectId;
      map["projectIds"] = location!.projectId?.plainValue();
      map["folderId"] = location!.folderId.toString();
      map["locationId"] = location!.pfLocationTreeDetail?.locationId.toString();
    } else if(project != null){
      map["projectId"] = project!.projectID;
      map["projectIds"] = project!.projectID.plainValue();
    }

    map["currentPageNo"] = currentPage.toString();
    map["recordBatchSize"] = recordBatchSize.toString();
    map["recordStartFrom"] = startFrom.toString();
    map["sortField"] = sortValue.fieldName;
    map["sortFieldType"] = sortValue.fieldName == ListSortField.siteTitle.fieldName ? "text" : "timestamp";
    map["sortOrder"] = sortOrder ? "desc" : "asc"; //FR-678 Sorting listing descending / ascending should display as per the order
    map[AConstants.keyLastApiCallTimestamp] = lastApiCallTimeStamp;
    map["isFromSyncCall"] = "true";
    if (await isFilterApplied()) {
      map["action_id"] = "706";
      map["filterId"] = "-1";
      map["filterName"] = "-1";
      map["collectionType"] = "31";
      map["isUnsavedFilter"] = "true";
      map["isScheduledReturn"] = "0";
      map["isForAssocComms"] = "false";
      map["jsonData"] = await _filterUseCase.getFilterJsonByIndexField({'summary': !_searchSummaryTitleValue.isNullOrEmpty() ? _searchSummaryTitleValue : null}, curScreen: FilterScreen.screenSite, isNeedToSave: false);
    } else {
      map["action_id"] = "100";
      map["controller"] = "/commonapi/pfobservationservice/getObservationList";
      map["listingType"] = "31";
    }
    return map;
  }

  onFormItemClicked(SiteForm frmData) async {
    setSelectedItem(frmData);
    for (var element in loadedItems) {
      element.item.isSiteFormSelected = false;
      if (element.item.formId.plainValue() == frmData.formId.plainValue()) {
        element.item.isSiteFormSelected = true;
        setSelectedFormId(frmData.formId);
      }
    }

    String formId = frmData.formId ?? "";
    String formTitle = "${frmData.code?.split('(')[0]}: ${frmData.title}";
    String appBuilderId = frmData.appBuilderId ?? "";
    String frmStatusColor = frmData.statusRecordStyle?['backgroundColor'] ?? "";
    Map<String, dynamic> param = {
      "projectId": frmData.projectId,
      "projectids": frmData.projectId?.plainValue(),
      "isDraft": frmData.isDraft,
      "checkHashing": false,
      "formID": frmData.formId,
      "formTypeId": frmData.formTypeId,
      //"folderId":frmData.,
      "dcId": "1",
      "statusId": frmData.statusid,
      "parentmsgId": frmData.parentMsgId,
      "msgTypeCode": frmData.msgTypeCode,
      "msgCode": frmData.msgCode,
      "originatorId": frmData.observationId,
      "msgId": frmData.msgId,
      "toOpen": "FromForms",
      "commId": frmData.commId,
      "numberOfRecentDefect": "5",
      "appTypeId": frmData.appTypeId,
    };
    final data = {
      "projectId": frmData.projectId,
      "locationId": frmData.locationId.toString(),
      "isFrom": FromScreen.siteTakListing,
      "commId": frmData.commId,
      "observationId": frmData.observationId.toString(),
      "formId": frmData.formId,
      "formTypeId": frmData.formTypeId,
      "templateType": frmData.templateType,
      "appTypeId": frmData.appTypeId,
      "appBuilderId": frmData.appBuilderId,
      "formSelectRadiobutton": "${frmData.dcId ?? "1"}_${frmData.projectId}_${frmData.formTypeId}",
      "isUploadAttachmentInTemp": frmData.isUploadAttachmentInTemp,
    };
    if (isNetWorkConnected()) {
      String formViewUrl = await UrlHelper.getViewFormURL(param,screenName: FireBaseFromScreen.siteFormListingSearch);
      emitState(FormItemViewState(formId, frmStatusColor, appBuilderId, formTitle, formViewUrl, data));
    } else {
      final offlineParams = {
        "projectId": frmData.projectId,
        "locationId": frmData.locationId.toString(),
        // "isFrom": FromScreen.siteTakListing,
        "commId": frmData.commId,
        "toOpen": "FromForms",
        "observationId": frmData.observationId.toString(),
        "formId": frmData.formId,
        "formTypeId": frmData.formTypeId,
        "msgId": frmData.msgId,
        "hideBackButton": Utility.isTablet
      };
      String filePath = await FileFormUtility.getOfflineViewFormPath(offlineParams);
      emitState(FormItemViewState(formId, frmStatusColor, appBuilderId, formTitle, filePath, data));
    }
    emitState(RefreshPaginationItemState());
  }

  Future<bool> isFilterApplied() async {
    Map data = await _filterUseCase.readSiteFilterData(curScreen: FilterScreen.screenSite);
    bool isFilterActive = data.isNotEmpty;
    bool filterApply = !_searchSummaryTitleValue.isNullOrEmpty() || isFilterActive;
    setFilterApply(filterApply);
    return filterApply;
  }

  void setSummaryFilterValue(String? value) {
    _searchSummaryTitleValue = value;
  }

  String? getSummaryFilterValue() {
    return _searchSummaryTitleValue;
  }

  Future<List<String>> getRecentSearchedSiteList() async {
    return await getRecentSearchSiteTaskListData();
  }

  Future<void> saveRecentSearchSiteList(List<String> options) async {
    await setRecentSearchSiteTaskListData(options);
  }

  bool isCurrentSelectedPinLocation(){
    return location?.pfLocationTreeDetail?.locationId == selectedPinLocationId;
  }

  highLightSelectedFormData(ObservationData observationData) async {
    if(observationData.formId != null){
      var isFormIdInList = false;
      for (var element in loadedItems) {
        element.item.isSiteFormSelected = false;
        if (element.item.formId.plainValue() == observationData.formId.plainValue()) {
          isFormIdInList = true;
          applyStaticFilter = false;
          element.item.isSiteFormSelected = true;
          setSelectedItem(element.item);
          setSelectedFormId(observationData.formId);
          emitState(ScrollState(isScrollRequired: true));
          emitState(RefreshPaginationItemState());
        }
      }
      if(!isFormIdInList){
        loadedItems = [];
        applyStaticFilter = true;
        setSelectedFormId(observationData.formId);
        emitState(DefaultFormCodeFilterState(formCode: observationData.formCode.toString(),isFormCodeFilterApply: true));
      }
    }
  }

  clearDefaultFormCodeFilter() {
    setSelectedFormId("");
    setSelectedFormCode("");
  }
}