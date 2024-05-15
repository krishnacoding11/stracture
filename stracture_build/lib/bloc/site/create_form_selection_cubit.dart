import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/data/model/apptype_group_vo.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/domain/use_cases/formtype/formtype_use_case.dart';
import 'package:field/logger/logger.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';

import '../../../utils/global.dart' as globals;
import '../../injection_container.dart';
import 'create_form_selection_state.dart';

class CreateFormSelectionCubit extends BaseCubit {
  CreateFormSelectionCubit({FormTypeUseCase? formTypeUseCase}) : _formTypeUseCase = formTypeUseCase??getIt<FormTypeUseCase>(), super(FlowState());

  final FormTypeUseCase _formTypeUseCase;

  List<AppTypeGroup>? appGroups = [];
  List<AppTypeGroup>? searchAppGroup = [];
  List<AppType> appList = [];
  bool isLoading = false;//This flag is taken for resolve https://asitehelpdesk.atlassian.net/browse/ASITEFLD-3327


  getAppList(String projectId, bool isFromMap, String appTypeId) async {
    if (!await checkIfProjectSelected()) {
      return;
    }
    isLoading = true;
    emitState(
        LoadingState(stateRendererType: StateRendererType.POPUP_LOADING_STATE));
    await _formTypeUseCase
        .getAppTypeList(projectId, isFromMap,appTypeId).then((value) {
      appList = [...globals.appTypeList];
      isLoading = false;
      if (appList.isNotEmpty) {
        appList.removeWhere((element) {
          if ((element.isRecent != null && !element.isRecent!) && (element.isMarkDefault != null && element.isMarkDefault!)) {
            return element.isMarkDefault!;
          } else {
            return false;
          }
        });
      }
      initData();
    });
  }

  Future<void> getDefaultSiteApp(String projectId) async {
    AppType? defaultSiteTask;

    ///Passing appTypeId 2 in postApiCall for Sites
    emitState(LoadingState(
      stateRendererType: StateRendererType.POPUP_LOADING_STATE,
    ));
    await _formTypeUseCase.getAppTypeList(projectId, false, "2");
    for (AppType app in globals.appTypeList) {
      if (app.isMarkDefault != null && app.isMarkDefault!) {
        defaultSiteTask = app;
        break;
      }
    }
    emitState(SuccessState(defaultSiteTask));
  }

  void initData() {
    List<AppType>? appRecentTypes = [];
    List<AppType>? appOthersTypes = [];

    for (var listElement in appList) {
      if ((listElement.isRecent != null && listElement.isRecent!) && appRecentTypes.length < 5) {
        appRecentTypes.add(listElement);
      } else {
        appOthersTypes.add(listElement);
      }
    }

    if (appRecentTypes.isNotEmpty) {
      appGroups!.insert(0, AppTypeGroup(formTypeName: AConstants.recentForm, formAppType: [...appRecentTypes], isExpanded: false));
      searchAppGroup!.insert(0, AppTypeGroup(formTypeName: AConstants.recentForm, formAppType: [...appRecentTypes], isExpanded: false));
    }

    var newMap = appOthersTypes.groupBy((m) => m.formTypeGroupName);
    newMap.forEach((key, value) {
      appGroups!.add(AppTypeGroup(formTypeName: key, formAppType: value, isExpanded: false));
      searchAppGroup!.add(AppTypeGroup(formTypeName: key, formAppType: value, isExpanded: false));
    });
    if (appGroups!.isNotEmpty && searchAppGroup!.isNotEmpty) {
      appGroups!.first.isExpanded = true;
      searchAppGroup!.first.isExpanded = true;
    }
    emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  onChangeExpansion(int index) {
    if(isLoading == true) return;
    searchAppGroup![index].isExpanded = !searchAppGroup![index].isExpanded!;
    emitState(FormTypeExpandedState(searchAppGroup![index].isExpanded!));
  }

  void onSearchForm(String value) {
    if(isLoading == true) return;
    List<AppTypeGroup> currentlySearchResult = [];

    for (var groupElement in appGroups!) {
      List<AppType> tempFormTypes = [];
      for (var formAppElement in groupElement.formAppType!) {
        if (formAppElement.formTypeName!.toLowerCase().toString().contains(value.toLowerCase()) || formAppElement.code!.toLowerCase().toString().contains(value.toLowerCase()) || formAppElement.appBuilderCode!.toLowerCase().contains(value.toLowerCase()) || formAppElement.formTypeGroupName!.toLowerCase().toString().contains(value.toLowerCase().toString())) {
          tempFormTypes.add(formAppElement);
        } else {
          searchAppGroup!.clear();
        }
      }

      if (tempFormTypes.isNotEmpty) {
        currentlySearchResult.add(groupElement.copy(formAppType: tempFormTypes));
      }
    }

    Log.d(appGroups);
    if (currentlySearchResult.isNotEmpty) {
      searchAppGroup!.clear();
      searchAppGroup = [...currentlySearchResult];
    }

    if (searchAppGroup!.isNotEmpty && value.isNotEmpty) {
      for (var element in searchAppGroup!) {
        element.isExpanded = true;
        emitState(FormTypeExpandedState(element.isExpanded!));
      }
    } else {
      emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
    }
  }

  void onClearSearch() {
    searchAppGroup!.clear();
    searchAppGroup = [...appGroups!];
    for (var element in searchAppGroup!) {
      if (element.formTypeName == AConstants.recentForm) {
        element.isExpanded = true;
      } else {
        element.isExpanded = false;
      }
      if(isLoading == true) return;
      emitState(FormTypeExpandedState(element.isExpanded!));
    }
  }

  void onFocusChange(bool hasFocus){
    if(isLoading == true) return;
    emitState(FormTypeExpandedState(hasFocus));
  }

  void onSearchClear(){
    emitState(FormTypeSearchClearState());
  }

  bool checkSiteTaskEnabled() {
    bool isEnabled = false;
    for (AppType app in globals.appTypeList) {
      isEnabled = app.isMarkDefault!;
      if (isEnabled) {
        break;
      }
    }
    return isEnabled;
  }
}
