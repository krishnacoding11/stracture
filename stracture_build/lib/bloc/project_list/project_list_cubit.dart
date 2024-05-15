import 'dart:convert';

import 'package:field/bloc/Filter/filter_cubit.dart';
import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/recent_location/recent_location_cubit.dart';
import 'package:field/bloc/task_action_count/task_action_count_cubit.dart';
import 'package:field/data/local/project_list/project_list_local_repository.dart';
import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/exception/app_exception.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/injection_container.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/toolbar_mixin.dart';

import '../../utils/field_enums.dart';
import '../../utils/utils.dart';

part 'project_list_state.dart';

enum SearchMode { recent, suggested, other }

class ProjectListCubit extends BaseCubit with ToolbarTitle {
  final ProjectListUseCase _projectListUseCase;

  ProjectListCubit({ProjectListUseCase? projectListUseCase})
      : _projectListUseCase = projectListUseCase ?? di.getIt<ProjectListUseCase>(),
        super(PaginationListInitial());
  List<Popupdata> allItems = [];
  List<Popupdata> favItems = [];

  List<Popupdata> recentList = [];
  final FilterCubit _filterCubit = getIt<FilterCubit>();
  bool isAscending = true;
  bool isFavAscending = true;
  SearchMode _mSearchMode = SearchMode.other;
  final int projectPageLimit = 50;
  var isLastItem = false;
  var isFavLastItem = false;
  String? syncProjectId;
  Project? selectedProject;
  String? projectDownloadSize;

  set setSearchMode(SearchMode mode) {
    if (_mSearchMode != mode) {
      _mSearchMode = mode;
      emitState(SearchModeState(_mSearchMode));
    }
  }

  get getSearchMode => _mSearchMode;

  Future<Project?> getProjectDetailQr(String projectId) async {
    List<Project> items = await _projectListUseCase.getProjectList(0, 2, projectId);
    if (items.isNotEmpty) {
      var projectVO = items.first;
      return projectVO;
    } else {
      return null;
    }
  }

  Future<void> getProjectDetail(Popupdata project, bool isFavourites, {FromScreen? fromScreen}) async {
    if (fromScreen == FromScreen.listing) {
      emitState(RefreshingState(isFavourites));
    }
    if (fromScreen == FromScreen.dashboard) {
      emitState(LoadedState(true));
    }
    List<Project> items = await _projectListUseCase.getProjectList(0, 2, project.id ?? "0");
    if (fromScreen == FromScreen.dashboard) {
      emitState(LoadedState(false));
    }
    if (items.isNotEmpty) {
      var projectVO = items.first;
      await StorePreference.setSelectedProjectData(projectVO);
      _filterCubit.getFilterAttributeList("2");
      // await StorePreference.setSelectedProjectsTab(isFavourites ? 1 : 0);
      selectedProject = projectVO;
      await setNavigationTitleHeader(projectVO);
      _setProjectDependentSetting();
      emitState(ProjectDetailSuccessState(items: [projectVO]));
      Log.d("Selected Project is =========>${await StorePreference.getSelectedProjectData()}");
    } else {
      emitState(ProjectErrorState(exception: AppException(message: '')));
    }
  }

  //Workspace setting data for geo tagging
  Future<void> getWorkspaceSettingData(String projectId) async {
    Map<String, dynamic> request = {};
    request["projectsDetail"] = json.encode({"projectIds": "$projectId", "settingFields": "enableGeoTagging,projectid"});
    var result = await _projectListUseCase.getWorkspaceSettings(request);
    try {
      if (result is SUCCESS) {
        Map<String, dynamic> data = result.data;
        if (data.isNotEmpty && data.containsKey("documents")) {
          if (data["documents"] is List && data["documents"].length > 0) {
            List<dynamic> list = data["documents"];
            for (var i = 0; i < list.length; i++) {
              String geoTagEnabled = list[i]["enableGeoTagging"];
              //in case of multiple projects need to re-factor this accordingly current implementation is supports single project only
              await StorePreference.setProjectGeoTagSettings(geoTagEnabled);
            }
          }
        }
      }
    } catch (e) {}
  }

  _setProjectDependentSetting() {
    getIt<RecentLocationCubit>().initData();
    getIt<TaskActionCountCubit>().getTaskActionCount();
    //getIt<HomePageCubit>().getWeatherDetails();
  }

  showSyncProgress(int progress, String projectId, ESyncStatus status) {
    syncProjectId = projectId;
    emitState(ProjectSyncProgressState(progress, projectId, status));
  }

  Future<bool> isProjectMarkedOffline() async {
    return await _projectListUseCase.isProjectMarkedOffline();
  }

  Future<List<Popupdata>> pageFetch(int offset, bool isFavourite, bool isRefreshing, String searchValue, bool isAsc) async {
    emitState(DisableSorting());
    isRefreshing
        ? emitState(RefreshingState(isFavourite))
        : isFavourite
            ? emitState(FavProjectLoadingState())
            : emitState(AllProjectLoadingState());
    if (offset == 0) {
      isFavourite ? isFavLastItem = false : isLastItem = false;
      isLastItem = false;
    }
    int limit = projectPageLimit;
    int page = offset;
    Log.d("page_number", page);
    Map<String, dynamic> map = getRequestMapDataForPopupPagination(page, limit, isFavourite, searchValue);
    map["sortOrder"] = isAsc ? "asc" : "desc";
    map["sortField"] = "name";
    try {
      List<Popupdata> items = await _projectListUseCase.getPopupDataList(page, limit, map);

      if (items.length < limit) {
        isFavourite ? isFavLastItem = true : isLastItem = true;
      }

      if (items.isEmpty && page == 0) {
        if (searchValue.trim().isEmpty) {
          if (isFavourite) {
            emitState(FavProjectNotAllocatedState());
          } else {
            emitState(AllProjectNotAllocatedState());
          }
        } else {
          if (isFavourite) {
            emitState(FavProjectNotFoundState());
          } else {
            emitState(AllProjectNotFoundState());
          }
        }
        return [];
      }
      if (offset == 0) {
        if (isFavourite) {
          favItems.clear();
        } else {
          allItems.clear();
        }
      }
      if (isFavourite) {
        /// ASITEFLD-1344 Project list is replaced with new one after load more
        favItems.addAll(List.from(items));
        emitState(FavProjectSuccessState(items: favItems));
      } else {
        /// ASITEFLD-1344 Project list is replaced with new one after load more
        allItems.addAll(List.from(items));
        checkSelectedProjectName();
        emitState(AllProjectSuccessState(items: allItems));
      }
    } on AppException catch (e) {
      emitState(ProjectErrorState(exception: e));
    }
    emitState(EnableSorting());

    return isFavourite ? favItems.toList() : allItems.toList();
  }

  Future<List<Popupdata>> getSuggestedSearchList(int offset, bool isFavourite, bool isRefreshing, String searchValue) async {
    int limit = 10; //projectPageLimit;
    int page = 0;
    Map<String, dynamic> map = getRequestMapDataForPopupPagination(page, limit, isFavourite, searchValue);
    List<Popupdata> items = [];
    try {
      items = await _projectListUseCase.getPopupDataList(page, limit, map);
    } on AppException catch (e) {
      emitState(ProjectErrorState(exception: e));
    }
    return items.toList();
  }

  setNavigationTitleHeader(Project projectVO) async {
    updateTitle(projectVO.projectName, NavigationMenuItemType.home);
  }

  // Future<void> favProject(Popupdata project, int isFav) async {
  //   emitState(FavProjectLoadingState());
  //   project.imgId = isFav;
  //   emitState(FavouriteState(project: project));
  //
  //   dynamic result;
  //   Map<String, dynamic> map = getFavouriteProjectMapData(project, isFav);
  //   try {
  //     var instance = _projectListUseCase;
  //     result = await instance.setFavProject(map);
  //     if (result is FAIL) {
  //       emitState(FavProjectLoadingState());
  //       project.imgId = isFav == 1 ? 1 : -1;
  //       emitState(FavouriteState(project: project));
  //     }
  //   } on AppException {
  //     emitState(FavProjectLoadingState());
  //     project.imgId = isFav == 1 ? 1 : -1;
  //     emitState(FavouriteState(project: project));
  //   }
  // }

  Future<void> favouriteProject(Popupdata project, int imgId, bool isFav) async {
    addUpdateFavouriteDataList(project, imgId, isFav);
    dynamic result;
    Map<String, dynamic> map = getFavouriteProjectMapData(project, imgId);
    try {
      var instance = _projectListUseCase;
      result = await instance.setFavProject(map);
      if (result is FAIL) {
        project.imgId = imgId == 1 ? 1 : -1;
        addUpdateFavouriteDataList(project, project.imgId!, isFav);
      }
    } on AppException {
      project.imgId = imgId == 1 ? 1 : -1;
      addUpdateFavouriteDataList(project, project.imgId!, isFav);
    }
  }

  void addUpdateFavouriteDataList(Popupdata project, int imgId, bool isFav) {
    emitState(AllProjectLoadingState());
    project.imgId = imgId;
    if (allItems.isNotEmpty) {
      List<Popupdata> item = allItems.where((element) => element.id == project.id).toList();
      if (item.isNotEmpty) {
        item.first.imgId = project.imgId;
      }
    }
    emitState(AllProjectSuccessState(items: allItems));
    emitState(FavProjectLoadingState());
    if (imgId == 1) {
      if (favItems.isNotEmpty) {
        var indexOfItem = favItems.indexWhere((element) => element.id == project.id);
        if (indexOfItem == -1) {
          favItems.insert(0, project);
        }
      } else {
        favItems.insert(0, project);
      }
    } else {
      // favItems.remove(project);
      favItems.removeWhere((element) => element.id == project.id);
    }
    favItems.sort((a, b) {
      return (a.value ?? "").toLowerCase().compareTo((b.value ?? "").toLowerCase());
    });
    emitState(FavProjectSuccessState(items: favItems));
  }

  // Map<String, dynamic> getRequestMapDataForProject(projectID) {
  //   Map<String, dynamic> map = {};
  //   map["isPrivilegesRequired"] = "true";
  //   map["projectIds"] = projectID;
  //   map["checkHashing"] = "false";
  //   map["searchProjectIds"] = "";
  //   // map["appType"] = "2";
  //   return map;
  // }

  // Map<String, dynamic> getRequestMapData(page, limit, isFavourite) {
  //   var startedFrom = (page == 0) ? 0 : (page * limit) - 1;
  //   Map<String, dynamic> map = {};
  //   map["isPrivilegesRequired"] = "true";
  //   map["recordBatchSize"] = "$limit";
  //   map["recordStartFrom"] = "$startedFrom";
  //   map["projectIds"] = isFavourite
  //       ? AConstants.favouriteProjectsItemId
  //       : AConstants.allProjectsItemId;
  //   map["checkHashing"] = "false";
  //   map["searchProjectIds"] = "";
  //   map["appType"] = "2";
  //   return map;
  // }

  // Map<String, dynamic> getRequestMapDataForPopup(page, limit, isFavourite) {
  //   Map<String, dynamic> map = {};
  //   map["recordBatchSize"] = -1;
  //   map["applicationId"] = 3;
  //   map["object_type"] = "PROJECT";
  //   map["object_attribute"] = "project_id";
  //   if (isFavourite) {
  //     map["dataFor"] = 2;
  //   }
  //   return map;
  // }

  Map<String, dynamic> getRequestMapDataForPopupPagination(page, limit, isFavourite, searchValue) {
    var startedFrom = (page == 0) ? 0 : (page * limit);
    Map<String, dynamic> map = {};
    map["recordBatchSize"] = "$limit";
    map["recordStartFrom"] = "$startedFrom";
    map["applicationId"] = 3;
    map["object_type"] = "PROJECT";
    map["object_attribute"] = "project_id";
    map["searchValue"] = searchValue;
    if (isFavourite) {
      map["dataFor"] = 2;
    }
    return map;
  }

  Map<String, dynamic> getFavouriteProjectMapData(Popupdata project, int isFav) {
    Map<String, dynamic> map = {};
    map["action_id"] = "809";
    Map<String, dynamic> subMap = {};
    subMap["${project.dataCenterId}"] = project.id;

    map["dcWiseProjectIds"] = json.encode(subMap);
    map["setFavorite"] = isFav == 1 ? 1 : 0;
    return map;
  }

  Future<void> addRecentProject({String? newSearch}) async {
    if (newSearch == null || newSearch.isEmpty) {
      return;
    }
    final bool matchNewSearch = recentList.any((element) => element.value == newSearch);

    if (matchNewSearch) {
      recentList.removeWhere((element) => element.value == newSearch);
    }
    recentList.insert(0, Popupdata(value: newSearch));
    if (recentList.isNotEmpty && recentList.length > 5) {
      recentList.removeLast();
    }
    for (var element in recentList) {
      element.toJson();
    }
    await StorePreference.setRecentProjectPrefData(AConstants.recentProject, jsonEncode(recentList));
  }

  Future<List<Popupdata>> getRecentProject() async {
    final recentFromLocal = await StorePreference.getRecentProjectPrefData(AConstants.recentProject);
    recentList = [];
    final getRecentList = recentFromLocal != null ? jsonDecode(recentFromLocal) as List<dynamic> : [];
    if (getRecentList.isNotEmpty) {
      for (var element in getRecentList) {
        recentList.add(Popupdata.fromJson(element));
      }
    }
    return recentList;
  }

  Future<bool> isProjectLocationMarkedOffline(bool isNetWorkConnected) async {
    if (!isNetWorkConnected) {
      bool isProjectMarkOffline = await ProjectListLocalRepository().isProjectMarkedOffline();
      return !isProjectMarkOffline;
    }
    return false;
  }

  deleteProjectSyncSize(String projectId) {
    final map = {"projectId": projectId, "locationId": -1};
    _projectListUseCase.deleteItemFromSyncTable(map);
  }

  Future<void> checkSelectedProjectName() async {
    if(selectedProject==null)return;
    var modelCubit = getIt<ModelListCubit>();
    String projectId = await modelCubit.getProjectId(selectedProject?.projectID!, false);
    String projectName = await modelCubit.getProjectName(selectedProject?.projectID!, false);

    for (var popUpData in allItems) {
      if (popUpData.id.plainValue() == projectId) {
        if (popUpData.value != projectName) {
          var newProject = await getProjectDetailQr(popUpData.id.plainValue());
          if (newProject != null) {
            modelCubit.updateProject(newProject);
          }
        }
      }
    }
  }

/* Future<void> getSyncProjectSize({required String projectId}) async {
    List<SyncSizeVo> syncSizeVoList = await _projectListUseCase.getProjectSyncSize({"projectId":projectId});

    if(syncSizeVoList.isNotEmpty){
      Map<String, int> syncSize = DownloadSizeVo.fromSyncVo(syncSizeVoList);
      String projectDownloadSize = Utility.getFileSizeString(bytes: double.parse(syncSize["totalSize"].toString()) + (double.parse(syncSize["totalLocationCount"].toString())*500));
      this.projectDownloadSize = projectDownloadSize;
    }
  }*/
}
