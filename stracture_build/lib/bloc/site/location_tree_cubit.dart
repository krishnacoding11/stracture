import 'dart:collection';
import 'dart:convert';

import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/download_size/download_size_cubit.dart';
import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_cubit.dart';
import 'package:field/data/model/search_location_list_vo.dart';
import 'package:field/data/model/sync/sync_status_data_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/sync/task/mark_offline_project_and_location.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../analytics/event_analytics.dart';
import '../../data/model/download_size_vo.dart';
import '../../data/model/location_suggestion_search_vo.dart';
import '../../data/model/project_vo.dart';
import '../../data/model/site_location.dart';
import '../../data/model/sync_size_vo.dart';
import '../../domain/use_cases/qr/qr_usecase.dart';
import '../../domain/use_cases/site/site_use_case.dart';
import '../../injection_container.dart';
import '../../logger/logger.dart';
import '../../networking/network_response.dart';
import '../../networking/request_body.dart';
import '../../presentation/base/state_renderer/state_render_impl.dart';
import '../../presentation/base/state_renderer/state_renderer.dart';
import '../../utils/constants.dart';
import '../../utils/field_enums.dart';
import '../../utils/site_utils.dart';
import '../../utils/store_preference.dart';
import 'location_tree_state.dart';

enum LocationSearchMode { recentSearches, suggestedSearches, other }

class LocationTreeCubit extends BaseCubit {
  LocationTreeCubit({SiteUseCase? siteUseCase, QrUseCase? qrUseCase})
      : _siteUseCase = siteUseCase ?? di.getIt<SiteUseCase>(),
        _qrUseCase = qrUseCase ?? di.getIt<QrUseCase>(),
        super(InitialState(stateRendererType: StateRendererType.DEFAULT));

  final SiteUseCase _siteUseCase;
  final QrUseCase _qrUseCase;

  Project? project;

  SiteLocation? _selectedLocation, traversedLocation;
  FlowState? locationTreeState;
  List<dynamic> _listBreadCrumb = [];

  // LinkedHashMap<String, List<SiteLocation>?> _mapLocations = LinkedHashMap();
  List<SiteLocation> _listSiteLocation = [];
  final List<SearchLocationData> _searchLocationList = [];

  List<SearchDropdownList> recentList = [];
  LocationSearchMode _searchMode = LocationSearchMode.recentSearches;
  bool isSearchAlreadyLoading = false;
  Map<String, dynamic>? searchResult;
  List<SearchDropdownList> suggestedSearchList = [];

  List<SearchLocationData> get searchLocationList => _searchLocationList;

  SiteLocation? get selectedLocation => _selectedLocation;

  List<dynamic> get listBreadCrumb => _listBreadCrumb;

  LocationSearchMode get searchMode => _searchMode;
  // bool canRemoveOffline = false;

  Future<void> setCurrentSiteLocation(SiteLocation? location) async {
    di.getIt<ToolbarCubit>().updateTitleFromItemType(currentSelectedItem: NavigationMenuItemType.sites, title: location?.folderTitle ?? "Site Location 1");
    _selectedLocation = location;
  }

  Future<void> setCurrentSiteProject(Project? project) async {
    _selectedLocation = null;
    di.getIt<ToolbarCubit>().updateTitleFromItemType(currentSelectedItem: NavigationMenuItemType.sites, title: project?.projectName);
  }

  Future<void> getLocationTree({SiteLocation? location, isLoading = true}) async {
    if (location != null && !_listBreadCrumb.contains(location)) {
      _listBreadCrumb.add(location);
      traversedLocation = location;
    }
    if (!await checkIfProjectSelected()) {
      return;
    }
    setLocationTreeState(LoadingState(stateRendererType: StateRendererType.POPUP_LOADING_STATE));
    Map<String, dynamic> map = {};
    map["action_id"] = "2";
    map["appType"] = "2";
    map["folderId"] = location != null ? location.folderId : "0";
    map["isRequiredTemplateData"] = "true";
    map["isWorkspace"] = location == null ? '1' : '0';
    map["projectId"] = project?.projectID;
    map["projectIds"] = "-2";
    map["checkHashing"] = "false";
    var result = await _siteUseCase.getLocationTree(map);

    if (result is SUCCESS) {
      await addLocationList(result, location);
      // canRemoveOffline = await canRemoveOfflineLocation();
      setLocationTreeState();
    } else {
      setLocationTreeState(ErrorState(StateRendererType.POPUP_ERROR_STATE, "No Data Available"));
    }
  }

  Future addLocationList(dynamic responseData, SiteLocation? location) async {
    Result? result = responseData;
    dynamic locationList = result!.data;
    NetworkRequestBody? requestBody = result.requestData;
    Map<String, dynamic> reqData = {};
    if (requestBody is Json) {
      reqData = requestBody.data;
    }
    if ((locationList is List<SiteLocation>)) {
      if (reqData['folderId'] == '0' || reqData['folderId'] == getLastKeyForLocation()) {
        _listSiteLocation = locationList;
      }
    }
  }

  /// state Which state want to emit. Default is ContentState.
  void setLocationTreeState([FlowState? state]) {
    Future.delayed(Duration.zero).then((value) => emitState(state ?? ContentState(time: DateTime.now().millisecondsSinceEpoch.toString())));
    // emitState(state ?? ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  void addBreadCrumbItemToList(dynamic itemBreadCrumb) {
    traversedLocation = itemBreadCrumb is SiteLocation ? itemBreadCrumb : null;
    if (!_listBreadCrumb.contains(itemBreadCrumb)) {
      _listBreadCrumb.add(itemBreadCrumb);
    }
    if (_listBreadCrumb.length > 1) {
      setLocationTreeState();
    }
  }

  void removeItemFromBreadCrumb({int? index}) async {
    (index == null) ? _listBreadCrumb.removeLast() : _listBreadCrumb.removeRange(index + 1, _listBreadCrumb.length);
    if (listBreadCrumb.length > 1) traversedLocation = _listBreadCrumb.last;
    // if (isChildLocationOnCache()) {
    //   setLocationTreeState();
    // } else {
    getLocationTree(location: listBreadCrumb.last is Project ? null : listBreadCrumb.last, isLoading: true);
    // }
  }

  // void addLocationToMap(String key, List<SiteLocation>? listChildLocation) {
  //   _mapLocations.putIfAbsent(key, () => listChildLocation);
  // }

  String getLastKeyForLocation() {
    if (_listBreadCrumb.isNotEmpty) {
      if (_listBreadCrumb.last is Project) {
        return (_listBreadCrumb.last as Project).projectID!;
      } else if (_listBreadCrumb.last is SiteLocation) {
        return (_listBreadCrumb.last as SiteLocation).folderId!;
      }
    }
    return '';
  }

  // bool isChildLocationOnCache({String? folderId}) {
  //   if (folderId != null) {
  //     return _mapLocations.keys.contains(folderId);
  //   } else {
  //     return _mapLocations.keys.contains(getLastKeyForLocation());
  //   }
  // }

  // int? getCountFromMapLocation(String mapKey) {
  //   return _mapLocations[mapKey]?.length;
  // }
  //
  // SiteLocation getSiteLocationByIndex(String mapKey, int index) {
  //   return _mapLocations[mapKey]![index];
  // }
  //

  int getCountSiteLocationList() {
    return _listSiteLocation.length;
  }

  bool isOfflineLocationAvailableForDelete() {
    return offlineSiteLocationListCount() != 0;
  }

  bool _checkOfflineLocationsOnList(SiteLocation location) {
    return ((location.isMarkOffline ?? false) && (location.canRemoveOffline ?? false) && (location.syncStatus == ESyncStatus.success || location.syncStatus == ESyncStatus.failed));
  }

  int offlineSiteLocationListCount() {
    return _listSiteLocation.where((element) => _checkOfflineLocationsOnList(element)).length;
  }

  List<SiteLocation> offlineSiteLocationList() {
    return _listSiteLocation.where((element) => _checkOfflineLocationsOnList(element)).toList();
  }

  List<String?> offlineSiteLocationIdList() {
    List<String> offlineSiteLocationIdList = [];
    _listSiteLocation.forEach((element) {
      if ((element.isCheckForMarkOffline ?? false) && !(element.isMarkOffline ?? false)) {
        offlineSiteLocationIdList.add(element.pfLocationTreeDetail!.locationId.toString());
      }
    });
    return offlineSiteLocationIdList;
  }

  List<SiteLocation> get listSiteLocation => _listSiteLocation;

  GlobalKey getKeyForBreadCrumb(int index) {
    if (_listBreadCrumb[index] is SiteLocation) {
      return (_listBreadCrumb[index] as SiteLocation).globalKey!;
    }
    return GlobalKey();
  }

  Map<String, dynamic> setArgumentDataForLocation() {
    Map<String, dynamic> arguments = {};
    arguments['projectDetail'] = project;
    // arguments['mapLocations'] = _mapLocations;
    if(listBreadCrumb.last is SiteLocation) {
      arguments['selectedLocation'] = selectedLocation!;
    }
    arguments['listBreadCrumb'] = listBreadCrumb;
    return arguments;
  }

  void clearAllData() {
    _listBreadCrumb.clear();
    // _mapLocations.clear();
    _selectedLocation = null;
  }

  Future<void> getDataFromArgument(Map<String, dynamic> arguments) async {
    if (arguments.containsKey("projectDetail")) {
      project = arguments["projectDetail"];
    } else {
      project = await StorePreference.getSelectedProjectData();
    }
    // if (arguments.containsKey("mapLocations")) {
    //   _mapLocations = arguments["mapLocations"];
    // }
    if (arguments.containsKey("selectedLocation")) {
      _selectedLocation = arguments["selectedLocation"];
    }
    if (arguments.containsKey("listBreadCrumb")) {
      _listBreadCrumb = (arguments["listBreadCrumb"] as List<dynamic>).toList();
    }
  }

  void downloadLocationPdfXfdf(SiteLocation location) {
    if (SiteUtility.isLocationHasPlan(location)) {
      Map<String, dynamic> request = {"projectId": location.projectId, "folderId": location.folderId, "revisionId": location.pfLocationTreeDetail?.revisionId};
      _siteUseCase.downloadPdf(request, checkFileExist: true);
      _siteUseCase.downloadXfdf(request, checkFileExist: false);
    }
  }

  bool isParentLocationSelected() {
    if (listBreadCrumb.isNotEmpty) {
      if (selectedLocation == null) {
        return true;
      }
      if (listBreadCrumb.last is Project) {
        return true;
      }
      if (listBreadCrumb.last is SiteLocation) {
        if (listBreadCrumb.last == selectedLocation) {
          return true;
        } else if (selectedLocation == traversedLocation) {
          return true;
        } else if (listBreadCrumb.last == traversedLocation && !isChildSelected()) {
          return true;
        }
      }
      return false;
    }
    return false;
  }

  bool isChildSelected() {
    // List<SiteLocation>? listChild = _mapLocations[getLastKeyForLocation()];

    if (_listSiteLocation.contains(selectedLocation)) {
      return !(_listSiteLocation.firstWhere((element) => selectedLocation == element).hasSubFolder ?? false);
    }

    return false;
  }

  Future<void> getSearchList(String? searchValue) async {
    _searchLocationList.clear();
    isSearchAlreadyLoading = true;
    setLocationTreeState(LoadingState(stateRendererType: StateRendererType.POPUP_LOADING_STATE));

    Map<String, dynamic> map = {};
    map["action_id"] = "1002";
    map["searchValue"] = searchValue!;
    map["folderTypeId"] = "1";
    map["selectedProjectIds"] = project?.projectID!.plainValue();
    var result = await _siteUseCase.getSearchList(map);
    final searchLocationListVo = result.data as SearchLocationListVo;
    if (searchLocationListVo != null) {
      if (searchLocationListVo.totalDocs! > 0 && searchLocationListVo.data!.isNotEmpty) {
        _searchLocationList.addAll(searchLocationListVo.data!);
        await _setSearchViewData(_searchLocationList);
      } else {
        setLocationTreeState(ErrorState(StateRendererType.EMPTY_SCREEN_STATE, ""));
      }
    } else {
      setLocationTreeState(ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE, ""));
    }
  }

  Future<void> _setSearchViewData(List<SearchLocationData> searchLocationList) async {
    for (var element in _searchLocationList) {
      List<String> locationNameList = element.value!.split(r"\");
      locationNameList.removeAt(0);
      element.searchTitle = locationNameList.last;
      locationNameList.removeLast();
      if (locationNameList.isEmpty) {
        locationNameList.add(element.searchTitle!);
      }
      element.value = locationNameList.join(">");
    }
    isSearchAlreadyLoading = false;
    setLocationTreeState(LocationSearchSate(searchList: _searchLocationList));
  }

  onClearSearch() async {
    _searchLocationList.clear();
    _searchMode = LocationSearchMode.recentSearches;
    // canRemoveOffline = await canRemoveOfflineLocation();
    setLocationTreeState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  getLocationDetailsAndNavigateFromSearch(String selectedId, {FireBaseFromScreen screenName = FireBaseFromScreen.locationTree}) async {
    List<String> selectedIdsList = selectedId.split("#");

    Map<String, dynamic> map = getWorkspaceMapData(selectedIdsList[1], selectedIdsList[0], project!.dcId);

    try {
      final result = await _qrUseCase.getFieldEnableSelectedProjectsAndLocations(map);

      var arguments = await navigateToPlan(selectedIdsList[0], result);

      if (result is SUCCESS) {
        setLocationTreeState(SuccessState(arguments));
      } else {
        emitState(ErrorState(StateRendererType.isValid, result?.failureMessage ?? "Something went wrong", time: DateTime.now().millisecondsSinceEpoch.toString()));
      }
    } on Exception catch (e) {
      setLocationTreeState(ErrorState(StateRendererType.DEFAULT, e.toString()));
    }
  }

  Future<Object?> navigateToPlan(String? folderId, dynamic response) async {
    List<Project> items = [];
    if (response != null && response.data != null) {
      for (var item in response.data!) {
        items.add(item);
      }
    }
    if (items.isNotEmpty) {
      Project objProj = items.first;
      List<SiteLocation>? siteLocationList = List<SiteLocation>.from(objProj.childfolderTreeVOList.map((x) => SiteLocation.fromJson(x))).toList();
      _listBreadCrumb = [objProj];
      _listBreadCrumb.addAll(await compute(addListCrumbData, siteLocationList));

      project = objProj;
      _selectedLocation = getSelectedLocationFromFolderId(folderId!, siteLocationList);

      Map<String, dynamic> arguments = {};
      arguments['projectDetail'] = project;
      // arguments['mapLocations'] = _mapLocations;
      arguments['selectedLocation'] = _selectedLocation;
      arguments['listBreadCrumb'] = _listBreadCrumb;
      return arguments;
    } else {
      Log.d("ProjectList empty or Not available");
      return null;
    }
  }

  static List<dynamic> addListCrumbData(List<SiteLocation>? listChild) {
    List<dynamic> returnList = [];
    for (var element in listChild!) {
      if (element.childTree.isNotEmpty) {
        returnList.add(element);
        //List<SiteLocation> childList = List<SiteLocation>.from(element.childTree.map((x) => SiteLocation.fromJson(x))).toList();
        List<dynamic> result = addListCrumbData(element.childTree);
        if (result.isNotEmpty) {
          returnList.addAll(result);
        }
      }
    }
    return returnList;
  }

  static LinkedHashMap<String, List<SiteLocation>?> getLocationMap(Project project) {
    LinkedHashMap<String, List<SiteLocation>?> mapLocations = LinkedHashMap();
    List<SiteLocation>? siteLocationList = List<SiteLocation>.from(project.childfolderTreeVOList.map((x) => SiteLocation.fromJson(x))).toList();
    mapLocations.putIfAbsent(project.projectID!, () => siteLocationList);
    for (var element in siteLocationList) {
      if (element.childTree.isNotEmpty) {
        //List<SiteLocation> childList = List<SiteLocation>.from(element.childTree.map((x) => SiteLocation.fromJson(x))).toList();
        LinkedHashMap<String, List<SiteLocation>?> result = getMap(element.childTree, element);
        if (result.isNotEmpty) {
          mapLocations.addAll(result);
        }
      }
    }
    return mapLocations;
  }

  static getMap(List<SiteLocation>? listChild, SiteLocation parent) {
    LinkedHashMap<String, List<SiteLocation>?> mapLocations = LinkedHashMap();
    mapLocations.putIfAbsent(parent.folderId!, () => listChild);
    for (var element in listChild!) {
      if (element.childTree.isNotEmpty) {
        //List<SiteLocation> childList = List<SiteLocation>.from(element.childTree.map((x) => SiteLocation.fromJson(x))).toList();
        LinkedHashMap<String, List<SiteLocation>?> result = getMap(element.childTree, element);
        if (result.isNotEmpty) {
          mapLocations.addAll(result);
        }
      }
    }
    return mapLocations;
  }

  SiteLocation? getSelectedLocationFromFolderId(String parentFolderId, List<SiteLocation>? listChild) {
    for (var element in listChild!) {
      if (element.folderId.plainValue() == parentFolderId.plainValue()) {
        return element;
      } else if (element.childTree.isNotEmpty) {
        SiteLocation? siteLocation = getSelectedLocationFromFolderId(parentFolderId, element.childTree);
        if (siteLocation != null) return siteLocation;
      }
    }
    return null;
  }

  Map<String, dynamic> getWorkspaceMapData(projectId, folderId, dcId) {
    Map<String, dynamic> map = {};
    map["isfromfieldfolder"] = "true";
    map["projectId"] = projectId;
    map["folder_id"] = folderId;
    map["folderTypeId"] = "1";
    map["projectIds"] = projectId;
    map["checkHashing"] = "false";
    map["dcId"] = dcId;
    return map;
  }

  Future<void> addRecentProject({String? newSearch}) async {
    final bool matchNewSearch = recentList.any((element) => element.searchKey == newSearch);
    if (matchNewSearch) {
      recentList.removeWhere((element) => element.searchKey == newSearch);
    }
    recentList.insert(0, SearchDropdownList(newSearch!, null));
    if (recentList.isNotEmpty && recentList.length > 5) {
      recentList.removeLast();
    }

    for (var element in recentList) {
      element.toJson();
    }

    await StorePreference.setRecentLocationSearchPrefData(AConstants.recentSearchLocation, jsonEncode(recentList));
  }

  Future<void> removeLocationFromRecentSearch({String? newSearch}) async {
    recentList.removeWhere((element) => element.searchKey == newSearch);
    for (var element in recentList) {
      element.toJson();
    }

    await StorePreference.setRecentLocationSearchPrefData(AConstants.recentSearchLocation, jsonEncode(recentList));

    setLocationTreeState(LocationSearchSuggestion(recentList));
  }

  Future<List?> getRecentProject(bool isFromInit) async {
    final recentFromLocal = await StorePreference.getRecentLocationSearchPrefData(AConstants.recentSearchLocation);

    recentList = [];
    final getRecentList = recentFromLocal != null && recentFromLocal.isNotEmpty ? jsonDecode(recentFromLocal) as List<dynamic> : [];

    if (getRecentList.isNotEmpty) {
      for (var element in getRecentList) {
        recentList.add(SearchDropdownList.fromJson(element));
      }
    }
    _searchMode = LocationSearchMode.recentSearches;
    if (!isFromInit) {
      setLocationTreeState(LocationSearchSuggestion(recentList));
    } else {
      setLocationTreeState();
    }
    return recentList;
  }

  Future<List<SearchDropdownList>> getSuggestedSearchList(String? searchValue) async {
    setLocationTreeState(LoadingState(stateRendererType: StateRendererType.POPUP_LOADING_STATE));

    Map<String, dynamic> map = {};
    map["selectedProjectIds"] = project?.projectID.plainValue();
    map["searchValue"] = searchValue!;
    map["folderTypeId"] = "1";
    map["recordBatchSize"] = 10;
    var result = await _siteUseCase.getSuggestedSearchList(map);

    if (result != null && result.data != null) {
      final decodedResponse = json.decode(result.data);
      searchResult = null;
      isSearchAlreadyLoading = true;
      suggestedSearchList.clear();
      searchResult = Map<String, dynamic>.from(decodedResponse);
      searchResult!.forEach((key, value) {
        suggestedSearchList.add(SearchDropdownList(key, value.toString()));
      });
      isSearchAlreadyLoading = false;
      if (suggestedSearchList.isNotEmpty) {
        setLocationTreeState(LocationSearchSuggestion(suggestedSearchList));
        changeSearchMode(LocationSearchMode.suggestedSearches);
      } else {
        changeSearchMode(LocationSearchMode.recentSearches);
        setLocationTreeState(ErrorState(StateRendererType.EMPTY_SCREEN_STATE, ""));
      }
      return suggestedSearchList;
    } else {
      setLocationTreeState(ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE, ""));
      return [];
    }
  }

  void hideSelectionOfLocation(bool? isSelectVisible) {
    setLocationTreeState(VisibleSelectBtn(isSelectVisible!));
  }

  void changeSearchMode(LocationSearchMode searchMode) {
    _searchMode = searchMode;
    setLocationTreeState(LocationSearchSuggestionMode(_searchMode));
  }

  void enableMarkOfflineSelection(bool isEnableOfflineSelection) {
    setLocationTreeState(MarkOfflineEnableState(isEnableOfflineSelection));
    _locationAllMarkUnMark(false);
  }

  void locationCheckForOffline(bool isCheck, {SiteLocation? location, FireBaseFromScreen screenName = FireBaseFromScreen.locationTree}) {
    if (location != null) {
      location.isCheckForMarkOffline = isCheck;
    } else {
      _locationAllMarkUnMark(isCheck);
    }
    setLocationTreeState(CheckboxClickState(isCheck));
  }

  bool isOnlyOneLocationSelectForOffline() {
    return listSiteLocation.any((element) => (element.isCheckForMarkOffline == true && element.syncStatus==null));
  }

  bool isAllLocationSelectForOffline() {
    return listSiteLocation.every((element) => element.isCheckForMarkOffline == true || element.isMarkOffline == true);
  }

  void _locationAllMarkUnMark(bool isMarkAll) {
    for (var element in listSiteLocation) {
      if (element.isMarkOffline == null || !element.isMarkOffline!) {
        element.isCheckForMarkOffline = isMarkAll;
      }
    }
  }

  void enableUnMarkOfflineSelection(bool isEnableUnmarkSelection) async {
    // canRemoveOffline = await canRemoveOfflineLocation();
    setLocationTreeState(LocationUnMarkEnableState(isEnableUnmarkSelection));
  }

  void showLocationUnMarkConfirmation(int locationId, bool isAnimate) {
    setLocationTreeState(LocationUnMarkDeleteApprovalState(locationId, isAnimate));
  }

  void refreshListAfterSync(List<SiteSyncStatusDataVo> locationSitesSyncDataVo) async {
    for (int i = 0; i < locationSitesSyncDataVo.length; i++) {
      int locationIdx = listSiteLocation.indexWhere((location) {
        return location.pfLocationTreeDetail?.locationId.toString() == locationSitesSyncDataVo[i].locationId;
      });
      if (locationIdx != -1) {
        SiteLocation siteLocation = listSiteLocation[locationIdx];
        siteLocation.syncStatus = locationSitesSyncDataVo[i].eSyncStatus;
        siteLocation.progress = locationSitesSyncDataVo[i].syncProgress;
        siteLocation.isMarkOffline = true;
        listSiteLocation[locationIdx] = siteLocation;
      }
    }
    // canRemoveOffline = await canRemoveOfflineLocation();
    setLocationTreeState();
  }
  void refreshListOnDeleteAction(SiteLocation location, int? wantToDeleteLocationId) async {
    //emitState(LocationUnMarkProgressDialogState(true));
    final markOfflineProjectAndLocation = MarkOfflineLocationProject();
    await markOfflineProjectAndLocation.deleteProjectLocationDetails(projectID: location.projectId?.plainValue(), locationID: "$wantToDeleteLocationId");
    updateProjectSyncSize(markOfflineProjectAndLocation, location.projectId!);
    location.canRemoveOffline = false;
    location.isMarkOffline = false;
    location.progress = 0;
    location.syncStatus = null;
    location.lastSyncTimeStamp = null;
    final index = listSiteLocation.indexOf(location);
    listSiteLocation[index] = location;
    emitState(LocationUnMarkProgressDialogState(false));
    emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
    // canRemoveOffline = await canRemoveOfflineLocation();
    if (!isOfflineLocationAvailableForDelete()) {
      enableUnMarkOfflineSelection(false);
    }
  }

  Future<bool> isProjectLocationMarkedOffline(String? projectId) async {
    return await _siteUseCase.isProjectLocationMarkedOffline(projectId);
  }

  Future<bool> canRemoveOfflineLocation() async {
    if (listSiteLocation.isNotEmpty) {
      String? projectId = listSiteLocation.first.projectId;
      List<String> locationIds = listSiteLocation.map((e) => e.pfLocationTreeDetail?.locationId.toString() ?? "").toList();
      return await _siteUseCase.canRemoveOfflineLocation(projectId, locationIds);
    }
    return Future.value(false);
  }

  updateProjectSyncSize(MarkOfflineLocationProject markOfflineProjectAndLocation, String projectId) async {
    List<SyncSizeVo> syncSizeVoList = await markOfflineProjectAndLocation.getUpdatedProjectSyncSize(projectId: projectId);
    if (syncSizeVoList.isNotEmpty) {
      Map<String, int> syncSize = DownloadSizeVo.fromSyncVo(syncSizeVoList);
      int projectDownloadSize = syncSize["totalSize"]! + (syncSize["totalLocationCount"]! * 500);
      markOfflineProjectAndLocation.setUpdatedProjectSyncSize(projectId: projectId, updatedProjectSize: projectDownloadSize.toString());
    }
  }

  deleteSyncSize(String? projectId, List<String?> locationId) {
    locationId.forEach((element) {
      final map = {"projectId": projectId, "locationId": element};
      _siteUseCase.deleteItemFromSyncTable(map);
    });
  }

  Future<int?> getSyncProjectSize({required String projectId}) async {
    return getIt<DownloadSizeCubit>().getSyncProjectSize(projectId: projectId);
  }
}
