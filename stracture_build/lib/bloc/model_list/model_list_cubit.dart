import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:field/bloc/project_list_item/project_item_cubit.dart';
import 'package:field/data/dao/bim_model_list_dao.dart';
import 'package:field/data/dao/calibration_list_dao.dart';
import 'package:field/data/dao/floor_list_dao.dart';
import 'package:field/data/dao/model_db_fetch.dart';
import 'package:field/data/dao/model_db_insert.dart';
import 'package:field/data/dao/model_list_dao.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/data/model/offline_folder_list.dart';
import 'package:field/data/model/online_model_viewer_request_model.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/revision_data.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/exception/app_exception.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';
import 'package:field/utils/actionIdConstants.dart';
import 'package:field/utils/download_service.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/model/bim_request_data.dart';
import '../../data/model/model_vo.dart';
import '../../domain/use_cases/model_list_use_case/model_list_use_case.dart';
import '../../injection_container.dart';
import '../../logger/logger.dart';
import '../../networking/network_response.dart';
import '../../utils/app_path_helper.dart';
import '../../utils/constants.dart';
import '../../utils/file_utils.dart';
import '../../utils/requestParamsConstants.dart';
import '../../utils/store_preference.dart';
import '../storage_details/storage_details_cubit.dart';

part 'model_list_state.dart';

enum SearchMode { recent, suggested, other }

class ModelListCubit extends Cubit<ModelListState> {
  final ModelListUseCase _modelListUseCase;
  final ProjectListUseCase _projectListUseCase;

  ModelListCubit({ModelListUseCase? modelListUseCase, ProjectListUseCase? projectListUseCase})
      : _modelListUseCase = modelListUseCase ?? di.getIt<ModelListUseCase>(),
        _projectListUseCase = projectListUseCase ?? di.getIt<ProjectListUseCase>(),
        super(PaginationListInitial());

  List<Model> allItems = [];
  List<Model> favItems = [];
  var isLastItem = false;
  final int projectPageLimit = 50;
  bool isFavorite = false;
  String projectName = '';
  bool isIconClicked = false;
  String projectId = '';
  bool isLoading = false;
  bool isShowPdf = true;
  bool showDetails = false;
  bool isShowDetails = false;
  String searchString = '';
  bool isAnyItemChecked = false;
  int selectedModelIndex = -1;
  int lastSelectedIndex = -1;
  OnlineViewerModelRequestModel? selectedModelData;
  bool isAscending = true;
  List<Model> recentList = [];
  List<CalibrationDetails> selectedCalibrate = [];
  Model? selectedModel;
  bool isItemDeleted = false;
  SearchMode _mSearchMode = SearchMode.recent;
  bool isItemForUpdate = false;
  String fileRevision = "";
  String floorNumbers = "";
  int totalNumberOfDBEntries = 0;
  bool isOpened = false;
  bool isUpdated = false;
  OnlineViewerModelRequestModel? lastModelRequest;
  Map<String, dynamic> offlineParams = {};
  Map<String, BimModel> selectedFloorList = {};
  String selectedOption = "latest";
  List<Model> localStoredModel = [];
  List<FloorDetail> removeList = [];
  List<FloorDetail> floorListDB = [];
  List<CalibrationDetails> caliRemoveList = [];
  List<CalibrationDetails> calibListDB = [];
  bool isProjectLoading = false;
  bool isOfflineDialogShowing = false;

  get getSearchMode => _mSearchMode;
  int progress = 0;
  int totalProgress = 1;
  List<Model> oldData = [];
  List<String> bimModelsName = [];
  var selectedProject;

  bool toggleIsLoading() {
    isLoading = !isLoading;
    emit(ShowProgressBar(isLoading));
    return isLoading;
  }

  Future<List<RevisionId>> fetchChoppedFileStatus(Map<String, dynamic> request) async {
    List<RevisionId> listData = [];
    Result result = await _modelListUseCase.getChoppedStatus(request);
    var data = await result.data;

    if (result.responseCode != 200) {
      var processedFile = await processChoppedFile(request);
      if (processedFile.responseCode == 200) {
        result = await _modelListUseCase.getChoppedStatus(request);
        if (result.responseCode == 200) {
          var data = await result.data;
          data.forEach((e) {
            listData.add(RevisionId.fromJson(e));
          });
        }
      }
    } else {
      data = await result.data;
      data.forEach((e) {
        listData.add(RevisionId.fromJson(e));
      });

      List<RevisionId> newFailed = [];
      List<String> revIds = [];

      listData.forEach((element) async {
        if (!element.status.toLowerCase().contains(AConstants.failed.toLowerCase()) && !element.status.toLowerCase().contains(AConstants.inProcess.toLowerCase()) && !element.status.toLowerCase().contains(AConstants.inQueue.toLowerCase()) && !element.status.toLowerCase().contains(AConstants.completed.toLowerCase())) {
          revIds.add(element.revisionId.toString());
        }
      });

      if (revIds.isNotEmpty) {
        newFailed = await _processFailedRevisions(request);
      }

      listData.addAll(newFailed);
    }

    return listData;
  }

  Future<List<RevisionId>> _processFailedRevisions(Map<String, dynamic> request) async {
    List<RevisionId> newFailed = [];
    var processedFile = await processChoppedFile(request);
    if (processedFile.responseCode == 200) {
      Result result = await _modelListUseCase.getChoppedStatus(request);
      if (result.responseCode == 200) {
        var data = await result.data;
        data.forEach((e) {
          newFailed.add(RevisionId.fromJson(e));
        });
      }
    }
    return newFailed;
  }

  Future<List<RevisionId>> fetchChoppedFileStatusOnDrop(Map<String, dynamic> request) async {
    List<RevisionId> listData = [];
    Result result = await _modelListUseCase.getChoppedStatus(request);
    if (result.responseCode == 200) {
      var data = await result.data;

      data.forEach((e) {
        listData.add(RevisionId.fromJson(e));
      });
    }
    return listData;
  }

  Future<bool> canManageModel(String projectId) async {
    Map<String, dynamic> request = {
      "offlineProjectId": projectId.plainValue(),
      "offlineFolderIds": -1,
      "isDeactiveLocationRequired": true,
      "applicationId": 3,
      "folderTypeId": 1,
      "includeSubFolders": true,
    };
    List<WorkspaceList> tempWorkList = [];
    Result result = (await _projectListUseCase.getProjectAndLocationList(request));
    if (result is SUCCESS) {
      if (result.data != null) {
        String response = result.data.toString();
        tempWorkList = getWorkSpaceListFromResponse(response);
        var canManageModelList = tempWorkList.where((data) => projectId == data.projectId && data.privilege.trim().contains(AConstants.numberHundredTen));
        return canManageModelList.isNotEmpty;
      }
    }
    return false;
  }

  List<WorkspaceList> getWorkSpaceListFromResponse(response) {
    List<WorkspaceList> itemList = [];
    if (response.toString().isNotEmpty) {
      String jsonDataString = response.toString();
      final json = jsonDecode(jsonDataString);
      final workSpaceListObj = json['ResponseData'][0]['workspaceList'];
      if (workSpaceListObj != null) {
        itemList = List<WorkspaceList>.from(workSpaceListObj.map((x) => WorkspaceList.fromJson(x))).toList();
      }
    }
    return itemList;
  }

  Future<dynamic> processChoppedFile(Map<String, dynamic> request) async {
    Result result = await _modelListUseCase.processChoppedFile(request);
    return result;
  }

  Future<List<Model>> pageFetch(int offset, bool isFavourite, bool isRefreshing, String searchValue, String projectId, int isFavoriteValue, bool isSorting, String sortOrder, String modelName, {bool isTest = false}) async {
    isProjectLoading = true;
    if (offset == 0) {
      isLastItem = false;
      allItems = [];
    }
    isRefreshing
        ? emit(RefreshingState())
        : offset == 0
            ? emit(ProjectLoadingState())
            : emit(LoadingModelState());
    int limit = projectPageLimit;
    int page = offset;
    var startedFrom = (page == 0) ? 0 : (page * limit);
    try {
      selectedFloorList.clear();
      selectedModel = null;
      selectedModelData = null;
      List<Model> result = await _modelListUseCase.getModelListFromServer(getRequestSortedMapDataForModel(projectId, sortOrder, startedFrom, modelName), projectId);
      if (isNetWorkConnected()) {
        List<Model> modelList = result;
        if (modelList.length < limit) {
          isLastItem = true;
        }
        if ((allItems.isEmpty && page == 0) || (allItems.isNotEmpty && page > 0)) {
          allItems.addAll(modelList);
        }
        for (var item in allItems) {
          item = await checkFromLocalModel(item);
        }
        emit(allItems.isNotEmpty ? AllModelSuccessState(true, items: allItems, isShowCloseButton: true) : AllModelSuccessState(true, items: const [], isShowCloseButton: true));
      } else {
        List<Model> modelList = result;
        allItems.clear();
        allItems.addAll(modelList);
        List<Model> itemsToRemove = [];
        if (!isTest) {
          for (var item in allItems) {
            List<FloorDetail> floor = await ModelDbFetch.fetchFloors(item.modelId.plainValue());
            if (floor.isEmpty) {
              itemsToRemove.add(item);
            } else {
              item = await checkFromLocalModel(item);
            }
          }
        }
        allItems.removeWhere((element) => itemsToRemove.contains(element));
        oldData = allItems;
        if (isFavorite) {
          getFavouriteModelsLocal();
        } else {
          emit(allItems.isNotEmpty ? AllModelSuccessState(true, items: allItems, isShowCloseButton: true) : AllModelSuccessState(true, items: const [], isShowCloseButton: true));
        }
      }
    } on AppException catch (e) {
      emit(ErrorState(exception: e));
    }

    return allItems.toList();
  }

  Future<Model> checkFromLocalModel(Model model) async {
    double floorSize = await _modelListUseCase.floorSizeByModelId(model.modelId.plainValue());
    if (floorSize > 0) {
      model.isDownload = true;
      model.fileSize = floorSize.toString();
    } else {
      model.isDownload = false;
      model.fileSize = "";
    }

    return model;
  }

  Future<void> addRecentModel({String? newSearch}) async {
    final bool matchNewSearch = recentList.any((element) => element.userModelName == newSearch);
    if (!matchNewSearch) {
      recentList.insert(0, Model(userModelName: newSearch!));
      if (recentList.isNotEmpty && recentList.length > 5) {
        recentList.removeLast();
      }
      for (var element in recentList) {
        element.toJson();
      }
      await StorePreference.setRecentModelPrefData(AConstants.recentModel, jsonEncode(recentList));
    }
  }

  Future<List<Model>> getRecentModel() async {
    final recentFromLocal = await StorePreference.getRecentModelPrefData(AConstants.recentModel);
    recentList = [];
    final getRecentList = recentFromLocal != null ? jsonDecode(recentFromLocal) as List<dynamic> : [];
    if (getRecentList.isNotEmpty) {
      for (var element in getRecentList) {
        recentList.add(Model.fromJson(element));
      }
    }
    recentList.removeWhere((element) => element.userModelName!.trim().isEmpty);
    return recentList;
  }

  set setSearchMode(SearchMode mode) {
    if (_mSearchMode != mode) {
      _mSearchMode = mode;
      emit(SearchModelState(_mSearchMode, allItems));
    }
  }

  int lastIndex = -1;

  changeDropdown(index) {
    if (lastIndex != index) {
      lastIndex = index;
      for (var element in allItems) {
        element.isDropOpen = false;
      }
      selectedCalibrate.clear();
      selectedFloorList.clear();
      removeList.clear();
      isAnyItemChecked = false;
      var model = allItems[index];
      emit(AllModelSuccessState(true, items: allItems, isShowCloseButton: true, openItem: model));
    }
  }

  void allProjectState() {
    emit(LoadingModelState());
    emit(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
  }

  void itemDropdownClick(
    int index, {
    bool isCancel = false,
  }) async {
    selectedModelIndex = index;

    for (var element in allItems) {
      element.isDropOpen = false;
    }
    if (isCancel) {
      selectedModel = null;
      selectedModelData = null;
      selectedCalibrate.clear();
      selectedFloorList.clear();
      caliRemoveList.clear();
      removeList.clear();
      selectedModelIndex = -1;
      getIt<StorageDetailsCubit>().modelSelectState(null);
    } else {
      allItems[index].isDropOpen = true;
    }
    selectedCalibrate.clear();
    selectedFloorList.clear();
    localStoredModel.clear();
    removeList.clear();
    caliRemoveList.clear();
    isItemForUpdate = false;
    isAnyItemChecked = false;
    var model = allItems[index];
    emit(AllModelSuccessState(true, items: allItems, isShowCloseButton: true, openItem: model));
  }

  void clearData() async {
    for (var element in allItems) {
      element.isDropOpen = false;
    }
    selectedCalibrate.clear();
    selectedFloorList.clear();
    removeList.clear();
    caliRemoveList.clear();
    localStoredModel.clear();
    isItemForUpdate = false;
    isAnyItemChecked = false;
    selectedModelData = null;
    selectedModel = null;
    emit(AllModelSuccessState(
      true,
      items: allItems,
      isShowCloseButton: true,
    ));
  }

  void itemCheckToggle(
    bool isAnyItemChecked,
    BimModel ifc,
    bool isItemClear,
    Model model,
  ) async {
    var modelId = model.modelId.plainValue();
    BimModelListDao bimModelListDao = BimModelListDao();
    List<BimModel> modelDB = await bimModelListDao.fetch(modelId);
    for (var bimModel in modelDB) {
      bimModelsName.add(bimModel.docTitle.toString());
      var list = await FloorListDao().fetch(bimModel.revId!);
      addFloorData(list);
    }

    Set<String> floorListDBFileNames = Set.from(floorListDB.map((item) => item.fileName));

    for (int j = 0; j < ifc.floorList.length; j++) {
      String fileName = ifc.floorList[j].fileName;
      if (floorListDBFileNames.contains(fileName)) {
        if (!ifc.floorList[j].isChecked && floorListDB.firstWhere((item) => item.fileName == fileName).isDownloaded) {
          addRemoveList(ifc.floorList[j]);
        } else if (ifc.floorList[j].isChecked && floorListDB.firstWhere((item) => item.fileName == fileName).isDownloaded) {
          removeList.removeWhere((element) => element.fileName == fileName);
        }
      }
    }
    setFloorData(ifc, isItemClear, model);
    isItemForUpdate = isUpdated = model.isDownload!;

    if (selectedFloors.isNotEmpty) {
      emit(AllModelSuccessState(
        true,
        items: allItems,
        isShowCloseButton: true,
      ));
      this.isAnyItemChecked = true;
      emit(ItemCheckedState(items: allItems));
    } else {
      this.isAnyItemChecked = removeList.isNotEmpty || caliRemoveList.isNotEmpty;
      if (isOpened && isNetWorkConnected()) {
        ifc.isDownloaded = false;
        dropdownStateEmit(isOpened, isUpdated);
      } else {
        selectedModel = model;
        emit(AllModelSuccessState(
          true,
          items: allItems,
          isShowCloseButton: true,
        ));
      }
      if (this.isAnyItemChecked) {
        emit(ItemCheckedState(items: allItems));
      }
    }
  }

  List<FloorDetail> get selectedFloors {
    List<FloorDetail> _selectedFloors = [];
    selectedFloorList.values.forEach((bimModel) {
      _selectedFloors.addAll(bimModel.floorList.where((floorData) => floorData.isChecked && !floorData.isDownloaded));
    });
    return _selectedFloors;
  }

  Future<void> calibratedItemSelect(List<CalibrationDetails> list, bool isAnyItemChecked, CalibrationDetails calibrateItem, Model model) async {
    var modelId = model.modelId.plainValue();
    calibListDB = await CalibrationListDao().fetch(modelId: modelId);
    Set<String> calibListDBFileNames = Set.from(calibListDB.map((item) => item.calibrationId.plainValue()));
    for (var calibrate in list) {
      String calibId = calibrate.calibrationId.plainValue();
      if (calibListDBFileNames.contains(calibId)) {
        bool isCalibrationDownloaded = calibListDB.firstWhere((item) => item.calibrationId.plainValue() == calibId).isDownloaded;
        if (isCalibrationDownloaded) {
          if (!calibrate.isChecked) {
            addRemoveCaliList(calibrate);
          } else {
            caliRemoveList.removeWhere((item) => item.calibrationId.plainValue() == calibId);
          }
        }
      }
    }

    isItemForUpdate = model.isDownload!;
    var tempList = list.where((element) => element.isChecked && !element.isDownloaded).toList();

    if (isNetWorkConnected()) {
      selectedCalibrate = tempList;
    } else {
      addCalibratedList(calibrateItem);
    }

    selectedModel = model;
    if (!isItemForUpdate) return;
    if (isAnyItemChecked && tempList.isNotEmpty) {
      this.isAnyItemChecked = true;
      if (state is ItemCheckedState) {
        emit(AllModelSuccessState(true, items: allItems, isShowCloseButton: true));
      }
      emit(ItemCheckedState(items: allItems));
    } else {
      this.isAnyItemChecked = selectedFloors.isNotEmpty || removeList.isNotEmpty || caliRemoveList.isNotEmpty;
      if (isOpened && isNetWorkConnected()) {
        dropdownStateEmit(isOpened, isUpdated);
      } else {
        emit(AllModelSuccessState(true, items: allItems, isShowCloseButton: true));
      }
      if (this.isAnyItemChecked) {
        emit(ItemCheckedState(items: allItems));
      }
    }
  }

  addCalibratedList(CalibrationDetails calibrateItem) {
    if (calibrateItem.isChecked) {
      selectedCalibrate.add(calibrateItem);
    } else {
      for (int i = 0; i < selectedCalibrate.length; i++) {
        if (selectedCalibrate[i].calibrationId.plainValue() == calibrateItem.calibrationId.plainValue()) {
          selectedCalibrate.removeAt(i);
        }
      }
    }
  }

  Future<List<Model>> getFilteredList(int offset, bool isSearchModel, String projectId, String modelName, int favValue, {bool isTest = false}) async {
    isProjectLoading = true;
    int limit = projectPageLimit;
    if (isSearchModel) {
      emit(ProjectLoadingState());
    }
    try {
      selectedModel = null;
      selectedModelData = null;
      selectedFloorList.clear();
      List<Model> result = await _modelListUseCase.getFilteredList(getFilteredListByModelName(modelName, favValue), projectId, modelName);
      if (isNetWorkConnected()) {
        List<Model> filteredModelList = result;
        if (filteredModelList.length < limit) {
          isLastItem = true;
        }
        allItems = filteredModelList;
        for (var item in allItems) {
          item = await checkFromLocalModel(item);
        }
        emit(AllModelSuccessState(true, items: filteredModelList, isShowCloseButton: true));
      } else {
        List<Model> modelList = result;
        allItems.clear();
        allItems.addAll(modelList);
        List<Model> itemsToRemove = [];
        if (!isTest) {
          for (var item in allItems) {
            List<FloorDetail> floor = await ModelDbFetch.fetchFloors(item.modelId.plainValue());
            if (floor.isEmpty) {
              itemsToRemove.add(item);
            } else {
              item = await checkFromLocalModel(item);
            }
          }
        }
        allItems.removeWhere((element) => itemsToRemove.contains(element));
        if (isFavorite) {
          getFavouriteModelsLocal();
        }
        if (!isAscending) {
          localModelItemSort(false);
        }
        if ((!isFavorite) && isAscending) {
          emit(allItems.isNotEmpty ? AllModelSuccessState(true, items: allItems, isShowCloseButton: true) : AllModelSuccessState(true, items: const [], isShowCloseButton: true));
        }
      }
    } on AppException catch (e) {
      Log.d("Exception Found");
      emit(ErrorState(exception: e));
    }
    return allItems.toList();
  }

  Future<void> favouriteModel(Model project, int isFavorite) async {
    if (isNetWorkConnected()) {
      addUpdateFavouriteDataList(project, isFavorite);
      dynamic result;
      Map<String, dynamic> map = getFavouriteModelMapData(project, isFavorite);
      try {
        var instance = _modelListUseCase;
        result = await instance.addModelAsFav(map, projectId);
        if (result is FAIL) {
          project.isFavoriteModel = isFavorite == 0 ? 1 : 0;
          addUpdateFavouriteDataList(project, project.isFavoriteModel!);
        }
      } on AppException {
        project.isFavoriteModel = isFavorite == 0 ? 1 : 0;
        addUpdateFavouriteDataList(project, project.isFavoriteModel!);
      }
    } else {
      addUpdateFavouriteDataList(project, isFavorite);
      ModelListDao dao = ModelListDao();
      await dao.insert([project]);
    }
  }

  Future<List<Model>> getSuggestedSearchModelList(
    int offset,
    bool isFavourite,
    bool isRefreshing,
    String searchValue,
    String projectId,
    int isFavoriteValue,
    bool isSorting,
    String sortOrder,
    String modelName,
  ) async {
    int limit = projectPageLimit;
    int page = offset;
    var startedFrom = (page == 0) ? 0 : (page * limit);
    List<Model> items = [];
    try {
      items = await _modelListUseCase.getModelListFromServer(getRequestSortedMapDataForModel(page, sortOrder, startedFrom, modelName), projectId);
    } on AppException {
      emit(EmptyErrorState());
    }
    items.removeWhere((element) => !element.userModelName!.trim().toLowerCase().contains(modelName.toLowerCase()));
    return items.toList();
  }

  void addUpdateFavouriteDataList(Model model, int isFavorite) {
    model.isFavoriteModel = isFavorite;
    if (allItems.isNotEmpty) {
      allItems.firstWhere((element) => element.bimModelId == model.bimModelId).isFavoriteModel = model.isFavoriteModel;
    }
    if (isFavorite == 0) {
      favItems.insert(0, model);
    } else {
      favItems.removeWhere((element) => element.bimModelId == model.bimModelId);
    }
    favItems.sort((a, b) {
      return (a.bimModelName)!.toLowerCase().compareTo((b.bimModelName)!.toLowerCase());
    });
  }

  Map<String, dynamic> getFavouriteModelMapData(Model project, int isFavorite) {
    Map<String, dynamic> map = {};
    map[RequestConstants.actionId] = ActionConstants.actionId612;
    map[RequestConstants.model_id] = project.bimModelId;
    map[RequestConstants.isFavorite] = isFavorite == 0 ? 1 : 0;
    return map;
  }

  Map<String, dynamic> getRequestMapDataForModel(projectID, pageNumber, startedFrom, int isFavoriteValue, String modelName) {
    Map<String, dynamic> map = {};
    map[RequestConstants.projectId] = projectID;
    map[RequestConstants.actionId] = ActionConstants.actionId601;
    map[RequestConstants.recordStartFrom] = startedFrom;
    map[RequestConstants.listingType] = "47";
    map[RequestConstants.xhr] = "false";
    map[RequestConstants.active] = true;
    map[RequestConstants.recordBatchSize] = '50';
    map[RequestConstants.isFavorite] = isFavoriteValue;
    map[RequestConstants.currentPageNo] = pageNumber;
    map[RequestConstants.modelName] = modelName;
    map[RequestConstants.favorite] = isFavoriteValue == 1 ? 'true' : 'false';
    return map;
  }

  Map<String, dynamic> getFilteredListByModelName(String modelName, int favValue) {
    selectedModel = null;
    Map<String, dynamic> map = {};
    map[RequestConstants.favorite] = favValue == 1 ? 'true' : 'false';
    map[RequestConstants.modelName] = modelName;
    map[RequestConstants.sortOrder] = "asc";
    map[RequestConstants.sortField] = "userModelName";
    return map;
  }

  Map<String, dynamic> getRequestSortedMapDataForModel(projectID, sortOrder, startedFrom, modelName) {
    Map<String, dynamic> map = {};
    map[RequestConstants.recordStartFrom] = startedFrom;
    map[RequestConstants.recordBatchSize] = '50';
    map[RequestConstants.sortOrder] = sortOrder;
    map[RequestConstants.sortField] = "userModelName";
    map[RequestConstants.sortFieldType] = "text";
    map[RequestConstants.favorite] = isFavorite ? "true" : "false";
    map[RequestConstants.modelName] = modelName;
    map[RequestConstants.isFavorite] = isFavorite ? "1" : "0";
    return map;
  }

  BimProjectModelRequestModel buildBimRequestBody(int index, List<Model> selectedProjectModelsList, var selectedProject) {
    BimProjectModelRequestModel bimProjectModelRequestModel = BimProjectModelRequestModel();
    bimProjectModelRequestModel.actionId = ActionConstants.actionId714;
    bimProjectModelRequestModel.modelId = selectedProjectModelsList[index].bimModelId;
    bimProjectModelRequestModel.projectId = selectedProject.projectID;
    bimProjectModelRequestModel.modelName = selectedProjectModelsList[index].bimModelName;
    bimProjectModelRequestModel.modelVersionID = ActionConstants.modelVersionId;
    bimProjectModelRequestModel.fileName = selectedProjectModelsList[index].userModelName.toString();
    return bimProjectModelRequestModel;
  }

  toggleColor(OnlineViewerModelRequestModel selectedModelData) {
    emit(LoadingModelState());
    selectedModelData.isSelectedModel = !selectedModelData.isSelectedModel;
    emit(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
  }

  dropdownStateEmit(bool isOpen, bool isUpdate) {
    isOpened = isOpen;
    isUpdated = isUpdate;
    emit(DropdownOpenState(isOpen: isOpen, isUpdate: isUpdate, items: allItems));
  }

  void setFloorData(BimModel ifc, bool isItemClear, Model model) {
    if (selectedFloorList.containsKey(ifc.revId.plainValue()) && isItemClear) {
      selectedFloorList.remove(ifc.revId.plainValue());
    } else {
      selectedFloorList[ifc.revId.plainValue()] = ifc;
      selectedModel = model;
    }
  }

  Future<void> downloadScsFile({
    required List<BimModel> ifcObject,
    required BuildContext context,
    required List<CalibrationDetails> calibrate,
    required int totalProgressValue,
    required List<FloorDetail> selectedFloors,
    required double totalModelSize,
  }) async {
    progress = 0;
    totalProgress = 1;
    totalProgress = totalProgressValue;
    isItemForUpdate = selectedModel?.isDownload ?? false;
    if (selectedFloors.isNotEmpty || calibrate.isNotEmpty) {
      emit(DownloadModelState(
        items: allItems,
        progressValue: progress.toDouble(),
        isItemForUpdate: isItemForUpdate,
        totalModelSize: totalModelSize,
        downloadStart: true,
        totalSize: totalProgressValue.toDouble(),
      ));

      ModelDBInsert dbInsert = ModelDBInsert(
        ifcObject: ifcObject,
        calibrate: calibrate,
        selectedFloors: selectedFloors,
        model: selectedModel!,
      );

      await Future.delayed(Duration(milliseconds: 200));

      await dbInsert.execute();
      await Future.delayed(Duration(milliseconds: 100));
      String fileName = "";
      String calibFileName = "";
      String revId = "";
      for (var ifc in selectedFloorList.values) {
        fileName += ifc.docTitle! + ";";
        for (var floor in ifc.floorList) {
          if (!isNetWorkConnected()) {
            return;
          }
          if (floor.isChecked && !floor.isDownloaded) {
            progress++;
            if (!isNetWorkConnected()) {
              return;
            }
            Map<String, dynamic> request = {
              "projectId": projectId,
              "folderId": ifc.folderId,
              "revisionId": ifc.revId,
              "modelId": selectedModel?.modelId,
              "floorName": floor.fileName,
              "floorNumber": floor.floorNumber,
            };
            await Future.wait<DownloadResponse>([DownloadScsFile().downloadScs(request)]).then((value) async {
              if (value[0].isSuccess) {
                emit(DownloadModelState(
                  items: allItems,
                  progressValue: progress.toDouble(),
                  totalModelSize: totalModelSize,
                  downloadStart: true,
                  isItemForUpdate: isItemForUpdate,
                  totalSize: totalProgressValue.toDouble(),
                ));
                floor.isDownloaded = true;
                revId = ifc.revId!;
                fileRevision = ifc.name!.split(" ")[0].replaceAll("v", "");
                floorNumbers += floor.levelName + ",";
                await dbInsert.updateFloor(floor);
              } else {
                Log.d(value[0].errorMsg);
              }
            });
          }
        }
      }
      String calibRevId="";

      for (var calibrationFile in calibrate) {
        progress++;
        if (!isNetWorkConnected()) {
          return;
        }
        Map<String, dynamic> request = {
          "projectId": projectId,
          "folderId": calibrationFile.folderId,
          "revisionId": calibrationFile.revisionId,
        };
        calibRevId = calibrationFile.revisionId;
        await Future.wait<DownloadResponse>([DownloadPdfFile().downloadPdf(request)]).then((value) async {
          if (value[0].isSuccess) {
            emit(DownloadModelState(
              items: allItems,
              progressValue: progress.toDouble(),
              totalModelSize: totalModelSize,
              downloadStart: true,
              totalSize: totalProgressValue.toDouble(),
              isItemForUpdate: isItemForUpdate,
            ));
            calibrationFile.isDownloaded = true;
            await dbInsert.updateCalibrate(calibrationFile);
          } else {
            Log.d(value[0].errorMsg);
          }
        });
        calibFileName = calibFileName + ";" + calibrationFile.fileName;
      }

      String remarks;
      String? modelId = selectedModel?.bimModelId;
      remarks = "File Name:$fileName,Download Type:Field,File Type:Model,Location:${floorNumbers.replaceAll(",", "#")}";
      if (selectedFloorList.isNotEmpty && isNetWorkConnected()) {
        insertDownloadModelFileAuditTrail(projectId, remarks, ActionConstants.actionId92, modelId!, "", revId, isItemForUpdate: isItemForUpdate);
      }
      if (calibrate.isNotEmpty && isNetWorkConnected()) {
        remarks = "File Name:${calibFileName.replaceFirst(";", "")},Download Type:Field,File Type:Calibrated Drawing";
        insertDownloadModelCalibrateFileAuditTrail(projectId, remarks, ActionConstants.actionId92, modelId!, "", calibRevId, isItemForUpdate: isItemForUpdate);
      }
    }

    if (removeList.isNotEmpty) {
      emit(DownloadModelState(
        items: allItems,
        isItemForUpdate: isItemForUpdate,
        progressValue: 0,
        totalModelSize: totalModelSize,
        downloadStart: true,
        totalSize: 1,
      ));
      await removeFloorsFromLocal(selectedModel!, removeList, projectId);
      await Future.delayed(Duration(milliseconds: 200));
    }

    if (caliRemoveList.isNotEmpty) {
      emit(DownloadModelState(
        items: allItems,
        isItemForUpdate: isItemForUpdate,
        progressValue: 0,
        totalModelSize: totalModelSize,
        downloadStart: true,
        totalSize: 1,
      ));
      await removeCalibrateFromLocal(caliRemoveList, projectId, selectedModel!);
      await Future.delayed(Duration(milliseconds: 200));
    }
    await Future.delayed(Duration(milliseconds: 200));
    selectedModel = await checkFromLocalModel(selectedModel!);
    await ModelListDao().insert([selectedModel!]);

    removeList.clear();
    floorListDB.clear();
    calibListDB.clear();
    caliRemoveList.clear();
    selectedFloorList.clear();
    selectedCalibrate.clear();
    progress = 0;
    totalProgress = 1;
    emit(
      DownloadModelState(
        items: caliRemoveList.isNotEmpty || removeList.isNotEmpty ? [] : allItems,
        progressValue: 0,
        isItemForUpdate: isItemForUpdate,
        totalModelSize: totalModelSize,
        downloadStart: false,
        totalSize: 1,
      ),
    );
    isItemForUpdate = false;
    isAnyItemChecked = false;
    selectedModel = null;
    selectedModelData = null;
    getIt<StorageDetailsCubit>().modelSelectState(null);
    emit(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
    if (selectedFloorList.isEmpty && selectedCalibrate.isEmpty) {
      emit(ShowSnackBarState(items: allItems, isItemForUpdate: true));
    }
    unmarkProject();
  }

  Future<void> insertDownloadModelFileAuditTrail(String projectId, String remarks, String actionId, String modelId, String objectId, String revisionId, {required bool isItemForUpdate}) async {
    await _modelListUseCase.setParallelViewAuditTrail(getRequestMapDataForAuditTrail(projectId, remarks, actionId, modelId, objectId, revisionId), projectId);
    emit(ShowSnackBarState(items: allItems, isItemForUpdate: isItemForUpdate));
  }

  Future<void> insertDownloadModelCalibrateFileAuditTrail(String projectId, String remarks, String actionId, String modelId, String objectId, String revisionId, {required bool isItemForUpdate}) async {
    await _modelListUseCase.setParallelViewAuditTrail(getRequestMapDataForAuditTrail(projectId, remarks, actionId, modelId, objectId, revisionId), projectId);
    if (selectedFloorList.isEmpty && selectedCalibrate.isNotEmpty) {
      emit(ShowSnackBarState(items: allItems, isItemForUpdate: isItemForUpdate));
    }
  }

  Map<String, dynamic> getRequestMapDataForAuditTrail(projectId, remarks, actionId, modelId, objectId, revisionId) {
    Map<String, dynamic> map = {};
    map[RequestConstants.project_id] = projectId;
    map[RequestConstants.model_id] = modelId;
    map[RequestConstants.actionId] = actionId;
    map[RequestConstants.objectId] = objectId;
    map[RequestConstants.revision_id] = revisionId;
    map[RequestConstants.remarks] = remarks;
    return map;
  }

  void localModelItemSort(bool isAscending) {
    emit(LoadingModelState());
    if (isAscending) {
      allItems.sort((a, b) => a.userModelName!.toLowerCase().compareTo(b.userModelName!.toLowerCase()));
    } else {
      allItems.sort((a, b) => b.userModelName!.toLowerCase().compareTo(a.userModelName!.toLowerCase()));
    }
    emit(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
  }

  void getFavouriteModelsLocal() {
    emit(LoadingModelState());
    if (isFavorite) {
      allItems = allItems.where((element) => element.isFavoriteModel == 1 && element.userModelName!.toLowerCase().contains(searchString.trim().toLowerCase())).toList();
    } else {
      allItems = oldData;
    }
    emit(AllModelSuccessState(
      false,
      items: allItems,
      isShowCloseButton: true,
    ));
  }

  void searchLocalModel(String value) {
    emit(LoadingModelState());
    allItems = allItems.where((element) => element.userModelName!.toLowerCase().contains(value.toLowerCase())).toList();
    emit(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
  }

  void emitDeleteModelListState() {
    emit(ProjectLoadingState());
    emit(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
  }

  Future deleteFiles(Map<String, dynamic> offlineParams) async {
    if (offlineParams['floorList'] == null) {
      String? outputFilePath = await AppPathHelper().getModelScsFilePath(
        projectId: offlineParams['projectId'],
        revisionId: offlineParams['revisionId'].toString(),
        filename: offlineParams['fileName'],
        modelId: offlineParams['modelId'],
      );

      if (!outputFilePath.isNullOrEmpty() && isFileExist(outputFilePath)) {
        Utility().deleteFile(File(outputFilePath));
        return true;
      }
      return false;
    }

    List<FloorDetail> floorList = offlineParams['floorList'];
    for (var floor in floorList) {
      String? outputFilePath = await AppPathHelper().getModelScsFilePath(
        projectId: offlineParams['projectId'],
        revisionId: offlineParams['revisionId'].toString(),
        filename: floor.fileName,
        modelId: offlineParams['modelId'],
      );

      if (!outputFilePath.isNullOrEmpty() && isFileExist(outputFilePath)) {
        Utility().deleteFile(File(outputFilePath));
      }
    }
    return false;
  }

  void emitOpenButtonModelLoadingState(bool isShow) {
    emit(OpenButtonLoadingState(items: allItems, isShow: isShow));
  }

  Future<void> removeFloorsFromLocal(
    Model? model,
    List<FloorDetail> removeList,
    String projectId,
  ) async {
    for (var floor in removeList) {
      String? outputFilePath = await AppPathHelper().getModelScsFilePath(
        projectId: projectId,
        revisionId: floor.revisionId.toString(),
        filename: floor.fileName,
        modelId: floor.bimModelId.plainValue(),
      );
      FloorListDao().delete(floor.revisionId.toString(), floorNum: floor.floorNumber.toString(), modelId: model?.modelId!.plainValue() ?? "");

      if (!outputFilePath.isNullOrEmpty() && isFileExist(outputFilePath)) {
        Utility().deleteFile(File(outputFilePath));
      }
      floor.isDownloaded = false;
    }
    if (model != null) await ModelListDao().fetch(modelId: model.modelId!.plainValue());
    removeList.clear();
  }

  void addRemoveList(FloorDetail floorList) {
    bool isAvailable = true;
    for (int i = 0; i < removeList.length; i++) {
      if (floorList.fileName == removeList[i].fileName) {
        isAvailable = false;
        break;
      }
    }
    if (isAvailable) {
      removeList.add(floorList);
    }
  }

  void addRemoveCaliList(CalibrationDetails list) {
    bool isAvailable = true;
    for (int i = 0; i < caliRemoveList.length; i++) {
      if (list.calibrationId == caliRemoveList[i].calibrationId) {
        isAvailable = false;
        break;
      }
    }
    if (isAvailable) {
      caliRemoveList.add(list);
    }
  }

  removeCalibrateFromLocal(List<CalibrationDetails> caliRemoveList, String projectId, Model? model) async {
    for (var cali in caliRemoveList) {
      CalibrationListDao().delete(cali.revisionId.plainValue(), caliId: cali.calibrationId.plainValue(), modelId: model?.modelId.plainValue() ?? "");
      String? outputFilePath = await AppPathHelper().getPlanPDFFilePath(projectId: projectId, revisionId: cali.revisionId);
      if (!outputFilePath.isNullOrEmpty() && isFileExist(outputFilePath)) {
        Utility().deleteFile(File(outputFilePath));
      }
      cali.isDownloaded = false;
    }
  }

  String getCurrentDate() {
    var date = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MMM-yyyy');
    return formatter.format(date).toString();
  }

  void dispose(String msg) {
    isAnyItemChecked = false;
  }

  void addFloorData(List<FloorDetail> list) {
    Set<String> existingFileNames = floorListDB.map((element) => element.fileName).toSet();
    for (var floorDetail in list) {
      if (!existingFileNames.contains(floorDetail.fileName)) {
        floorListDB.add(floorDetail);
        existingFileNames.add(floorDetail.fileName);
      }
    }
  }

  void emitAllModelSuccessState() {
    allItems.clear();
    emit(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
  }

  void emitNoIfcObjectsFound() {
    emit(AllModelSuccessState(false, items: allItems, isShowCloseButton: false));
  }

  Future<String> getProjectId(String? selectedProjectId, bool isSetOffline) async {
    String projectId = await _modelListUseCase.getProjectFromProjectDetailsTable(selectedProjectId??"", isSetOffline);
    return projectId;
  }

  Future<String> getProjectName(String? selectedProjectId, bool isSetOffline) async {
    String projectName = await _modelListUseCase.getProjectNameFromProjectDetailsTable(selectedProjectId!, isSetOffline);
    return projectName;
  }

  Future updateProject(Project project) async {
     await _modelListUseCase.updateProject(project);
  }

  void emitPaginationListInitialState() {
    emit(PaginationListInitial());
  }

  Future<void> unmarkProject() async {
    List<FloorDetail> floors = await _modelListUseCase.fetchAllFloors(
      selectedProject != null ? selectedProject.projectID.toString().plainValue() : '',
    );
    List<CalibrationDetails> calib = await _modelListUseCase.fetchAllCalibrates(selectedProject != null ? selectedProject.projectID.toString().plainValue() : '');
    if (floors.isEmpty && calib.isEmpty) {
      getIt<ProjectItemCubit>().itemDeleteRequestSuccess(projectId: selectedProject.projectID!);
    }
  }
}
