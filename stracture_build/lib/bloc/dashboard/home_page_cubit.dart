import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:field/analytics/event_analytics.dart';
import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';

import '../../data/local/project_list/project_list_local_repository.dart';
import '../../data/model/apptype_vo.dart';
import '../../data/model/home_page_model.dart';
import '../../data/model/project_vo.dart';
import '../../domain/use_cases/dashboard/homepage_usecase.dart';
import '../../enums.dart';
import '../../injection_container.dart';
import '../../networking/network_info.dart';
import '../../utils/file_form_utility.dart';
import '../../utils/store_preference.dart';
import '../../utils/url_helper.dart';
import '../../utils/utils.dart';
import '../recent_location/recent_location_cubit.dart';
import '../task_action_count/task_action_count_cubit.dart';
import 'home_page_state.dart';

class HomePageCubit extends BaseCubit {
  final _homePageUseCase = di.getIt<HomePageUseCase>();
  bool isEditEnable = false;
  bool isOnline = isNetWorkConnected();
  String? pId;

  //new home page
  List<UserProjectConfigTabsDetails> userSelectedShortcutList = [];
  List<UserProjectConfigTabsDetails> editModeShortcutList = [];
  List<UserProjectConfigTabsDetails> pendingShortcutList = [];
  List<UserProjectConfigTabsDetails> deletedShortcutList = [];
  List<UserProjectConfigTabsDetails> addedShortcutList = [];
  HomePageModel? homePageModel;

  Future<String> get userId async => await StorePreference.getUserId() ?? "";

  Future<Project?> get project async => await StorePreference.getSelectedProjectData();

  Future<String> get projectId async => (await project)?.projectID ?? "";

  HomePageCubit() : super(InitialState(stateRendererType: StateRendererType.CONTENT_SCREEN_STATE));

  initData() async {
    emitState(HomePageItemLoadingState(stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE));
    isEditEnable = false;
    isOnline = isNetWorkConnected();
    if (isOnline) {
      //online
      if (await project != null) {
        pId = (await projectId);
        await getShortcutConfigList(pId);
      } else {
        emitState(HomePageNoProjectSelectState(true));
      }
    } else {
      //offline
      List<Project> offlineProjectList = await getIt<ProjectListLocalRepository>().getMarkedOfflineProjects();
      if (offlineProjectList.isEmpty) {
        emitState(HomePageNoProjectSelectState(false));
      } else {
        pId = offlineProjectList.first.projectID;
        await getShortcutConfigList(pId);
      }
    }
  }

  Future<void> getShortcutConfigList(String? pId) async {
    userSelectedShortcutList.clear();
    if (!pId.isNullOrEmpty()) {
      Map<String, dynamic> request = {"projectId": pId.toString()};
      final response = await _homePageUseCase.getShortcutConfigList(request);
      if (response is SUCCESS && response.data is HomePageModel) {
        homePageModel = response.data;
        userSelectedShortcutList.addAll(homePageModel?.configJsonData?.userProjectConfigTabsDetails ?? []);
        if (userSelectedShortcutList.isNotEmpty) {
          emitState(HomePageItemState(userSelectedShortcutList, isEditEnable));
          //Delayed added for rendering view time
          await Future.delayed(Duration(milliseconds: 200), () {
            getRenderItemConfigData(userSelectedShortcutList);
          });
        } else {
          emitState(HomePageEmptyState());
        }
      } else {
        emitState(ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE, response!.failureMessage ?? ""));
      }
    } else {
      emitState(ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE, ""));
    }
  }

  _generateParamToCreateForm(AppType value) async {
    Project? project = await StorePreference.getSelectedProjectData();

    Map<String, dynamic> obj = {};
    obj['projectId'] = value.projectID;
    obj['appBuilderCode'] = value.appBuilderCode;
    obj['projectName'] = value.projectName;
    obj['appTypeId'] = value.appTypeId;
    obj['msgId'] = value.msgId;
    obj['formId'] = value.formId;
    obj['formTypeID'] = value.formTypeID;
    obj['formTypeName'] = value.formTypeName;
    obj['instanceGroupId'] = value.instanceGroupId;
    obj['templateType'] = value.templateType;
    obj['isFromWhere'] = value.isFromWhere;
    obj['formSelectRadiobutton'] = "${project?.dcId ?? "1"}_${value.projectID}_${value.formTypeID}";

    String url = "";
    if (isNetWorkConnected()) {
      url = await UrlHelper.getCreateFormURL(obj, screenName: FireBaseFromScreen.homePage);
    } else {
      obj['formTypeId'] = value.formTypeID;
      obj['templateType'] = value.templateType;
      obj['appBuilderId'] = value.appBuilderCode;
      obj['offlineFormId'] = DateTime.now().millisecondsSinceEpoch;
      obj['isUploadAttachmentInTemp'] = true;
      url = await FileFormUtility.getOfflineCreateFormPath(obj);
    }
    obj['locationId'] = "0";
    obj['url'] = url;
    obj['isFrom'] = FromScreen.dashboard;

    return obj;
  }

  showSiteTaskFormDialog(AppType? siteTaskApp) async {
    if (siteTaskApp != null) {
      dynamic map = await _generateParamToCreateForm(siteTaskApp);
      String url = map['url'];
      emitShowFormCreateDialogState(url, map, siteTaskApp.formTypeName);
    } else {
      emitState(NoFormsMessageState());
    }
  }

  emitShowFormCreateDialogState(String url, Map<String, dynamic> data, String? title) {
    emitState(ShowFormCreateDialogState(url, data, title));
  }

  showFormCreationOptionsDialog() {
    emitState(ShowFormCreationOptionsDialogState());
  }

  navigateTaskListingScreen(TaskActionType taskType) {
    emitState(NavigateTaskListingScreenState(taskType));
  }

  navigateSiteListingScreen(UserProjectConfigTabsDetails userProjectConfigTabsDetails) async {
    emitState(HomePageItemLoadingState(stateRendererType: StateRendererType.POPUP_LOADING_STATE));
    Map<String, dynamic> arguments = {};
    List<dynamic> listBreadCrumb = [];
    listBreadCrumb.add(await project);
    arguments['projectDetail'] = await project;
    arguments['listBreadCrumb'] = listBreadCrumb;
    await di.getIt<FilterUseCase>().saveSiteFilterData(Map.from(userProjectConfigTabsDetails.config), curScreen: FilterScreen.screenSite);
    emitState(NavigateSiteListingScreenState(arguments));
  }

  onChangeEditMode() async {
    if (!isEditEnable) {
      editModeShortcutList = [...userSelectedShortcutList];
      isEditEnable = !isEditEnable;
      (editModeShortcutList.length == 0) ? emitState(HomePageEmptyState()) : emitState(HomePageItemState(editModeShortcutList, isEditEnable));
    } else {
      if (isSelectedSortCutsListChanged()) {
        emitState(UpdateShortcutListProgressState(true));
        final result = await updateShortcutConfigList(editModeShortcutList);
        emitState(UpdateShortcutListProgressState(false));
        if (result is SUCCESS && result.data is HomePageModel) {
          deletedShortcutList.clear();
          userSelectedShortcutList = [...(result.data as HomePageModel).configJsonData?.userProjectConfigTabsDetails ?? []];
          isEditEnable = !isEditEnable;
        } else {
          emitState(HomePageEditErrorState(result?.failureMessage));
        }
      } else {
        isEditEnable = !isEditEnable;
      }
      if (!isEditEnable) {
        (userSelectedShortcutList.length == 0) ? emitState(HomePageEmptyState()) : emitState(HomePageItemState(userSelectedShortcutList, isEditEnable));
      }
    }
  }

  bool isSelectedSortCutsListChanged() {
    if (userSelectedShortcutList.isNotEmpty || editModeShortcutList.isNotEmpty) {
      if (editModeShortcutList.length != userSelectedShortcutList.length) {
        return true;
      } else {
        for (var i = 0; i < editModeShortcutList.length; i++) {
          if (editModeShortcutList[i] != userSelectedShortcutList[i]) {
            return true;
          }
        }
      }
    }
    return false;
  }

  Future<Result?> updateShortcutConfigList(List<UserProjectConfigTabsDetails> editedItemList) async {
    Map<String, dynamic> data = {};
    Map<String, dynamic> jsonData = {};
    jsonData['defaultTabs'] = homePageModel?.configJsonData?.defaultTabs?.toList() ?? "";
    List<UserProjectConfigTabsDetails> updatedShortcutList = [...editModeShortcutList];
    // pass instanceGroupId in Plain value
    updatedShortcutList.forEach((element) {
      if (element.id == HomePageSortCutCategory.createForm.value) {
        if (element.config is Map && element.config.containsKey("instanceGroupId")) {
          element.config["instanceGroupId"] = element.config["instanceGroupId"].toString().plainValue();
        }
      }
    });
    jsonData['userProjectConfigTabsDetails'] = updatedShortcutList.toList();
    data['projectId'] = await projectId;
    data['jsonData'] = jsonEncode(jsonData);
    final response = await _homePageUseCase.updateShortcutConfigList(data);
    return response;
  }

  deleteShortcutItem(UserProjectConfigTabsDetails item) {
    if (editModeShortcutList.length > 0) {
      editModeShortcutList.remove(item);
      deletedShortcutList.add(item);
      final List<UserProjectConfigTabsDetails> list = List.from(editModeShortcutList);
      (editModeShortcutList.length == 0) ? emitState(HomePageEmptyState()) : emitState(HomePageItemState(list, isEditEnable));
    }
  }

  Future<void> getPendingShortcutConfigList() async {
    emitState(AddPendingProgressState(true));
    pendingShortcutList.clear();
    pId = (await projectId);
    Map<String, dynamic> request = {"projectId": pId.toString()};
    final response = await _homePageUseCase.getPendingShortcutConfigList(request);
    emitState(AddPendingProgressState(false));
    if (response is SUCCESS && response.data is HomePageModel) {
      HomePageModel homePageModel = response.data;
      pendingShortcutList.addAll(homePageModel.configJsonData!.userProjectConfigTabsDetails!);
      if (editModeShortcutList.isNotEmpty) {
        for (UserProjectConfigTabsDetails element in editModeShortcutList) {
          if (element.id != HomePageIconCategory.filter.value) {
            int index = isShortcutItemPresent(pendingShortcutList, element);
            if (index != -1) {
              pendingShortcutList.removeAt(index);
            }
          }
        }
      }

      if (deletedShortcutList.isNotEmpty) {
        for (UserProjectConfigTabsDetails deleted in deletedShortcutList) {
          if (deleted.id != HomePageIconCategory.filter.value) {
            int index = isShortcutItemPresent(pendingShortcutList, deleted);
            if (index == -1) {
              pendingShortcutList.add(deleted);
            }
          }
        }
      }
      List<UserProjectConfigTabsDetails> tempList = getOrderedPendingList(pendingShortcutList);
      pendingShortcutList = [...tempList];
      for (UserProjectConfigTabsDetails pendingItem in pendingShortcutList) {
        pendingItem.isAdded = false;
      }
      emitState(PendingShortcutItemState(pendingShortcutList));
    } else {
      emitState(AddMoreErrorState(response!.failureMessage ?? ""));
    }
  }

  void getRenderItemConfigData(List<UserProjectConfigTabsDetails> userSortCuts) async {
    getIt<RecentLocationCubit>().initData();
    if (checkTaskItemAvailable(userSortCuts)) {
      bool isProjectIdPlain = (await projectId).isHashValue();
      if (isProjectIdPlain) {
        getIt<TaskActionCountCubit>().getTaskActionCount();
      }
    }
  }

  bool checkTaskItemAvailable(List<UserProjectConfigTabsDetails> userSortCuts) {
    return userSelectedShortcutList.any((element) {
      if (HomePageSortCutCategory.fromString(element.id.toString()) == HomePageSortCutCategory.newTasks || HomePageSortCutCategory.fromString(element.id.toString()) == HomePageSortCutCategory.taskDueToday || HomePageSortCutCategory.fromString(element.id.toString()) == HomePageSortCutCategory.overDueTasks || HomePageSortCutCategory.fromString(element.id.toString()) == HomePageSortCutCategory.taskDueThisWeek) {
        return true;
      }
      return false;
    });
  }

  updateEditModeListFromDrag(List<DraggableGridItem> list) {
    editModeShortcutList.clear();
    list.forEach((element) {
      UserProjectConfigTabsDetails userSelectedTabs = element.dragData as UserProjectConfigTabsDetails;
      editModeShortcutList.add(userSelectedTabs);
    });
  }

  Future<bool> isNeedToRefresh() async {
    String currProjectId = await projectId;
    if (userSelectedShortcutList.isEmpty || isOnline != isNetWorkConnected() || (pId == null || pId.plainValue() != currProjectId.plainValue())) {
      return true;
    }
    return false;
  }

  Future<bool> isBackFromEditMode() async {
    if (isEditEnable) {
      isEditEnable = false;
      emitState(HomePageItemState(userSelectedShortcutList, isEditEnable));
      return false;
    }
    return true;
  }

  bool canConfigureMoreShortcuts() {
    int totalShortcuts = editModeShortcutList.length + addedShortcutList.length;
    return totalShortcuts < getIt<AppConfig>().syncPropertyDetails!.maxHomePageShortcutConfigField;
  }

  int isShortcutItemPresent(List<UserProjectConfigTabsDetails> shortcutList, UserProjectConfigTabsDetails userProjectConfigTabsDetails) {
    int index = -1;
    for (int i = 0; i < shortcutList.length; i++) {
      UserProjectConfigTabsDetails item = shortcutList[i];
      if (userProjectConfigTabsDetails.id == HomePageIconCategory.createForm.value) {
        if (item.id == HomePageIconCategory.createForm.value && item.config["instanceGroupId"].toString().plainValue() == userProjectConfigTabsDetails.config["instanceGroupId"].toString().plainValue()) {
          index = i;
        }
      } else {
        if (userProjectConfigTabsDetails.id == item.id) {
          index = i;
        }
      }
      if (index != -1) {
        break;
      }
    }
    return index;
  }

  List<UserProjectConfigTabsDetails> getOrderedPendingList(List<UserProjectConfigTabsDetails> pendingList) {
    List<UserProjectConfigTabsDetails> tempList = [];
    List<UserProjectConfigTabsDetails> formShortcutList = pendingList.where((element) => element.id == HomePageSortCutCategory.createForm.value).toList();
    formShortcutList.sort((a, b) => compareAsciiUpperCase(a.name ?? "", b.name ?? ""));
    List<String> orderedList = [HomePageSortCutCategory.newTasks.value, HomePageSortCutCategory.taskDueToday.value, HomePageSortCutCategory.taskDueThisWeek.value, HomePageSortCutCategory.overDueTasks.value, HomePageSortCutCategory.jumpBackToSite.value, HomePageSortCutCategory.filter.value, HomePageSortCutCategory.createNewTask.value, HomePageSortCutCategory.createSiteForm.value];
    orderedList.forEach((item) {
      UserProjectConfigTabsDetails? userProjectConfigTabsDetails = pendingList.firstWhereOrNull((element) => element.id == item);
      if (userProjectConfigTabsDetails != null) {
        tempList.add(userProjectConfigTabsDetails);
      }
    });
    tempList.addAll(formShortcutList);
    return tempList;
  }

  void updateHomePageAfterDialogDismiss(dynamic data) {
    for (UserProjectConfigTabsDetails element in data) {
      if (element.id != HomePageIconCategory.filter.value) {
        int index = isShortcutItemPresent(deletedShortcutList, element);
        if (index != -1) {
          deletedShortcutList.removeAt(index);
        }
      }
      editModeShortcutList.add(element);
    }
    emitState(HomePageItemState(editModeShortcutList, true));
  }

  void handleOnTapAddMoreShortcutItem(List<UserProjectConfigTabsDetails> shortCutList, UserProjectConfigTabsDetails item) {
    if (item is UserProjectConfigTabsDetails && item.id != HomePageIconCategory.filter.value) {
      if (item.isAdded) {
        item.isAdded = false;
        emitState(ItemToggleState(shortCutList));
      } else {
        if (canConfigureMoreShortcuts()) {
          item.isAdded = true;
          emitState(ItemToggleState(shortCutList));
        } else {
          emitState(ReachedConfigureLimitState());
        }
      }
    }
  }

  void emitAddMoreSearchState(List<UserProjectConfigTabsDetails>? shortCutList) {
    emitState(AddMoreSearchState(shortCutList));
  }

  void checkMaxHomePageShortcutConfigLimit() {
    if (canConfigureMoreShortcuts()) {
      getPendingShortcutConfigList();
    } else {
      emitState(ReachedConfigureLimitState());
    }
  }
}
