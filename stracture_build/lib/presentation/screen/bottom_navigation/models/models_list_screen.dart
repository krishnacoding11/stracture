import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:field/bloc/cBim_settings/cBim_settings_cubit.dart';
import 'package:field/bloc/project_list/project_list_cubit.dart' as project_cubit;
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart';
import 'package:field/bloc/storage_details/storage_details_cubit.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/data/model/online_model_viewer_arguments.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/logger/logger.dart';
import 'package:field/presentation/screen/bottom_navigation/models/model_list_tile.dart';
import 'package:field/presentation/screen/bottom_navigation/models/storageDetails/model_storage_widget_landscape.dart';
import 'package:field/presentation/screen/online_model_viewer/online_model_viewer_screen.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/requestParamsConstants.dart';
import 'package:field/utils/toolbar_mixin.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/model_dialogs/model_download.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../../bloc/bim_model_list/bim_project_model_cubit.dart' as bim_cubit;
import '../../../../bloc/model_list/model_list_cubit.dart' as model_cubit;
import '../../../../bloc/model_list/model_list_cubit.dart';
import '../../../../bloc/navigation/navigation_cubit.dart';
import '../../../../bloc/online_model_viewer/model_tree_cubit.dart';
import '../../../../bloc/online_model_viewer/online_model_viewer_cubit.dart';
import '../../../../bloc/sync/sync_cubit.dart';
import '../../../../data/model/bim_project_model_vo.dart';
import '../../../../data/model/bim_request_data.dart';
import '../../../../data/model/model_vo.dart';
import '../../../../data/model/online_model_viewer_request_model.dart';
import '../../../../data/model/sync/sync_request_task.dart';
import '../../../../injection_container.dart';
import '../../../../networking/internet_cubit.dart';
import '../../../../networking/network_info.dart';
import '../../../../utils/field_enums.dart';
import '../../../../utils/store_preference.dart';
import '../../../../widgets/custom_search_view/custom_search_view.dart';
import '../../../../widgets/normaltext.dart';
import '../../../managers/color_manager.dart';
import '../../../managers/font_manager.dart';
import '../../side_toolbar/side_toolbar_screen.dart';
import '../../sidebar_menu_screen.dart';
import 'storageDetails/model_storage_widget.dart';

class ModelsListPage extends StatefulWidget {
  final bool isFavourites;
  final bool isShowSideToolBar;
  final bool isFromHome;
  late final ScrollController scrollController = getIt<ScrollController>();
  final SideToolBarCubit sideToolBarCubit = getIt<SideToolBarCubit>();
  final StorageDetailsCubit storageDetailsCubit = getIt<StorageDetailsCubit>();
  final Model? selectedModel;

  ModelsListPage({Key? key, required this.isFavourites, required this.isShowSideToolBar, required this.isFromHome, this.selectedModel}) : super(key: key);

  @override
  State<ModelsListPage> createState() => ModelsListPageState();
}

class ModelsListPageState extends State<ModelsListPage> with ToolbarTitle, SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List<Model> selectedProjectModelsList = <Model>[];
  int page = 0;
  final model_cubit.ModelListCubit _modelListCubit = getIt<model_cubit.ModelListCubit>();
  final StorageDetailsCubit _storageCubit = getIt<StorageDetailsCubit>();
  final bim_cubit.BimProjectModelListCubit _bimProjectModelCubit = getIt<bim_cubit.BimProjectModelListCubit>();
  var selectedProject;
  bool isAscending = false;
  late final ScrollController paginationScrollController;
  late final ScrollController animatedScrollController;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  late double scrollPosition = 0;
  int favPage = 0;
  late TabController _tabController;
  int index = 0;
  int selectedIndex = 0;
  List<Model> favItems = <Model>[];
  late double favScrollPosition = 0;
  List<BimProjectModel> tempList = [];
  List<IfcObjects> bimModelList = [];
  String projectName = '';
  TextEditingController searchController = TextEditingController();
  FocusNode searchModelNode = FocusNode();
  bool isFirstTimeLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _modelListCubit.emitPaginationListInitialState();
    setNavigationTitleHeader();
    _modelListCubit.isShowDetails = false;
    _modelListCubit.selectedModel = widget.selectedModel;
    _modelListCubit.isFavorite = false;
    _modelListCubit.isShowDetails = false;
    _modelListCubit.isAnyItemChecked = false;
    _modelListCubit.isAscending = true;
    _modelListCubit.searchString = "";
    animatedScrollController = widget.scrollController;
    _modelListCubit.lastSelectedIndex = -1;
    getIt<OnlineModelViewerCubit>().isModelTreeOpen = false;
    paginationScrollController = ScrollController();
    _storageCubit.initStorageSpace();
    _storageCubit.updateModelSize(_modelListCubit.selectedModel);
    if (isNetWorkConnected()) {
      searchController.addListener(callModelOnEmptySearch);
      paginationScrollController.addListener(pagination);
    }
    _tabController = TabController(length: 2, initialIndex: index, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        _modelListCubit.isAnyItemChecked = false;
        _modelListCubit.dropdownStateEmit(false, false);
      }
    });
    _tabController.animation?.addListener(_setSelectedProjectTab);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!(isNetWorkConnected())) {
        if (context.mounted) {
          Utility.showNetworkLostBanner(context);
        }
      }
    });
    getIt<CBIMSettingsCubit>().initCBIMSettings();
    getProjectName();
  }

  @override
  Widget build(BuildContext context) {
    Log.d(MediaQuery.of(context).size.height);
    return SafeArea(
      child: Scaffold(
        key: scaffoldKey,
        drawerEnableOpenDragGesture: true,
        resizeToAvoidBottomInset: false,
        drawer: const SidebarMenuWidget(),
        body: MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => widget.storageDetailsCubit),
          ],
          child: BlocListener<model_cubit.ModelListCubit, model_cubit.ModelListState>(
            listener: (context, state) {
              if (state is model_cubit.ErrorState) {
                context.showSnack(state.exception.message);
              }
              if (state is DownloadModelState) {
                if (!state.downloadStart) {
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
                    context.shownCircleSnackBarAsBanner(state.isItemForUpdate ? context.toLocale!.update_models : context.toLocale!.download_models, state.isItemForUpdate ? context.toLocale!.requested_model_updated : context.toLocale!.requested_model_downloaded, Icons.check_circle, Colors.green);
                  });
                }
              }
            },
            child: BlocBuilder<model_cubit.ModelListCubit, model_cubit.ModelListState>(
              builder: (context, state) {
                if ((state is model_cubit.ProjectLoadingState || state is model_cubit.LoadingModelState || state is ShowProgressBar)) {
                  return buildListView(state, false, context);
                } else if (state is model_cubit.AllModelSuccessState) {
                  if (!widget.isFavourites) {
                    selectedProjectModelsList = state.items;
                  }
                  return buildListView(state, false, context);
                } else if (state is model_cubit.ShowDetailsState) {
                  _modelListCubit.isProjectLoading = false;
                  if (!widget.isFavourites) {
                    selectedProjectModelsList = state.items;
                  }
                  return buildListView(state, false, context);
                } else if (state is model_cubit.OpenButtonLoadingState) {
                  if (!widget.isFavourites) {
                    selectedProjectModelsList = state.items;
                  }
                  return buildListView(state, false, context);
                } else if (state is model_cubit.LoadedState) {
                  return buildListView(state, false, context);
                } else if (state is ShowSnackBarState) {
                  selectedProjectModelsList = state.items;
                  return buildListView(state, true, context);
                } else if (state is ShowSnackBarInQueueState) {
                  selectedProjectModelsList = state.items;
                  WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
                    context.shownCircleSnackBarAsBanner(context.toLocale!.in_process, context.toLocale!.chopping_in_queue_check_after_sometime, Icons.warning_rounded, AColors.warningIconColor);
                  });
                  return buildListView(state, true, context);
                } else if (state is ItemCheckedState) {
                  selectedProjectModelsList = state.items;
                  return buildListView(state, true, context);
                } else if (state is DropdownOpenState) {
                  selectedProjectModelsList = state.items;
                  return buildListView(state, true, context);
                } else if (state is DownloadModelState) {
                  if (!state.downloadStart) {
                    _modelListCubit.itemDropdownClick(index, isCancel: true);
                  }
                  selectedProjectModelsList = state.items;
                  return buildListView(state, true, context);
                } else if (state is model_cubit.FavProjectSuccessState) {
                  if (widget.isFavourites) {
                    favItems = state.items;
                  }
                  return buildListView(state, false, context);
                } else if (state is SearchModelState) {
                  selectedProjectModelsList = state.items;
                  return buildListView(state, false, context);
                } else if (state is model_cubit.EmptyErrorState) {
                  return Center(
                    child: NormalTextWidget(context.toLocale!.no_record_available),
                  );
                } else {
                  return const ACircularProgress();
                }
              },
            ),
          ),
        ),
        floatingActionButtonLocation: _buildFloatingActionButtonLocation(),
      ),
    );
  }

  void callModelOnEmptySearch() async {
    if (searchController.text.isEmpty && !isFirstTimeLoading) {
      FocusManager.instance.primaryFocus?.unfocus();
      _modelListCubit.selectedModelData = null;
      searchController.text = '';
      _modelListCubit.searchString = searchController.text;
      _modelListCubit.setSearchMode = SearchMode.recent;
      _modelListCubit.selectedModelData = null;
      isAscending = true;
      _modelListCubit.isAscending = isAscending;
      String projectId = !isNetWorkConnected()
          ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
          : selectedProject != null
              ? selectedProject.projectID
              : "";
      selectedProjectModelsList = await _modelListCubit.pageFetch(0, false, false, "", projectId, _modelListCubit.isFavorite ? 0 : 1, true, "aesc", _modelListCubit.searchString);
      isFirstTimeLoading = true;
    } else {
      isFirstTimeLoading = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
  }

  Future<void> _setSelectedProjectTab() async {
    final aniValue = _tabController.animation?.value;
    if (aniValue! > 0.5 && index != 1) {
      await StorePreference.setSelectedProjectsTab(1);
    } else if (aniValue <= 0.5 && index != 0) {
      await StorePreference.setSelectedProjectsTab(0);
    }
  }

  void pagination() async {
    if (paginationScrollController.offset.toInt() >= paginationScrollController.position.maxScrollExtent.toInt()) {
      if (!_modelListCubit.isLoading && !_modelListCubit.isLastItem) {
        _modelListCubit.toggleIsLoading();
        page++;
        scrollPosition = paginationScrollController.offset;
        String projectId = !isNetWorkConnected()
            ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
            : selectedProject != null
                ? selectedProject.projectID
                : "";
        await _modelListCubit.pageFetch(page, false, false, "", projectId, _modelListCubit.isFavorite ? 1 : 0, true, isAscending ? "asc" : "desc", _modelListCubit.searchString);
        _modelListCubit.isLoading = false;
      }
    }
    if (!Utility.isTablet) {
      if (paginationScrollController.position.userScrollDirection == ScrollDirection.reverse) {
        animatedScrollController.animateTo(
          animatedScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.linear,
        );
      }
      if (paginationScrollController.position.userScrollDirection == ScrollDirection.forward) {
        animatedScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 400),
          curve: Curves.linear,
        );
      }
    }
  }

  setNavigationTitleHeader() async {
    _modelListCubit.projectName = '';
    await getIt<InternetCubit>().updateConnectionStatus();
    selectedProject = await StorePreference.getSelectedProjectData();
    if (selectedProject != null) {
      _modelListCubit.projectName = selectedProject.projectName;
      _modelListCubit.selectedProject = selectedProject;
    }
    updateTitle(_modelListCubit.projectName, NavigationMenuItemType.models);
    if (!widget.isFromHome) {
      fetchListOfModels();
    }
  }

  Future<void> _pullRefresh() async {
    isAscending = false;
    fetchListOfModels();
  }

  Widget buildListView(model_cubit.ModelListState state, bool isFiltered, BuildContext context) {
    if (Utility.isTablet) {
      return tabBuildListView(state, isFiltered, context);
    }
    return OrientationBuilder(
        key: const Key("key_model_list_mobile"),
        builder: (_, orientation) {
          return Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: state is OpenButtonLoadingState && state.isShow ? const ACircularProgress() : null,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: widget.isShowSideToolBar,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.12,
                        key: const Key('Side Tool Bar'),
                        child: SideToolbarScreen(
                          isWhite: false,
                          isModelSelected: true,
                          isOnlineModelViewerScreen: false,
                          onlineModelViewerCubit: _modelListCubit,
                          orientation: orientation,
                          isPdfViewISFull: true,
                          modelId: "",
                          modelName: AConstants.modelName,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          TabBar(
                            key: const Key('Tab Bar'),
                            indicatorColor: Colors.red,
                            padding: EdgeInsets.zero,
                            controller: _tabController,
                            tabs: [
                              Container(
                                height: 50.0,
                                alignment: Alignment.center,
                                child: Text(
                                  context.toLocale!.models,
                                  style: TextStyle(color: AColors.aPrimaryColor),
                                ),
                              ),
                              Container(
                                height: 50.0,
                                alignment: Alignment.center,
                                child: Text(
                                  context.toLocale!.lbl_storage,
                                  style: TextStyle(color: AColors.aPrimaryColor),
                                ),
                              ),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    // height: MediaQuery.of(context).size.height,
                                    child: Column(children: [
                                      IgnorePointer(
                                        ignoring: state is DownloadModelState,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                height: 46,
                                                child: CustomSearchSuggestionView<Model>(
                                                  key: const Key("key_search_model_list_mobile"),
                                                  placeholder: context.toLocale!.search_models,
                                                  hideSuggestionsOnKeyboardHide: true,
                                                  textFieldConfiguration: SearchTextFormFieldConfiguration(
                                                    controller: searchController,
                                                    focusNode: searchModelNode,
                                                    textInputAction: TextInputAction.search,
                                                    suffixIconOnClick: () {
                                                      clearButtonOnTap();
                                                    },
                                                    onSubmitted: (value) async {
                                                      isAscending = true;
                                                      String projectId = !isNetWorkConnected()
                                                          ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
                                                          : selectedProject != null
                                                              ? selectedProject.projectID
                                                              : "";
                                                      if (value.trim().isNotEmpty) {
                                                        await _modelListCubit.addRecentModel(newSearch: _modelListCubit.searchString.trim());
                                                        _modelListCubit.setSearchMode = SearchMode.recent;
                                                        _modelListCubit.getFilteredList(page, true, projectId, value.trim(), _modelListCubit.isFavorite ? 1 : 0);
                                                      } else {
                                                        _modelListCubit.searchString = value.trim();
                                                        searchController.text = _modelListCubit.searchString;
                                                        context.closeKeyboard();
                                                        _modelListCubit.getFilteredList(page, true, projectId, value.trim(), _modelListCubit.isFavorite ? 1 : 0);
                                                      }
                                                    },
                                                  ),
                                                  suggestionsCallback: (value) async {
                                                    _modelListCubit.searchString = value.trim();
                                                    if (!searchModelNode.hasFocus) {
                                                      return [];
                                                    } else {
                                                      if (value.isEmpty && searchModelNode.hasFocus) {
                                                        return await _modelListCubit.getRecentModel();
                                                      } else {
                                                        if (value.trim().length >= 3) {
                                                          _modelListCubit.setSearchMode = SearchMode.suggested;
                                                          _modelListCubit.searchString = value.trim();
                                                          if (!searchModelNode.hasFocus) {
                                                            return [];
                                                          } else {
                                                            if (value.isEmpty && !searchModelNode.hasFocus) {
                                                              return await _modelListCubit.getRecentModel();
                                                            } else {
                                                              if (value.trim().length >= 3) {
                                                                _modelListCubit.setSearchMode = SearchMode.suggested;
                                                                String projectId = !isNetWorkConnected()
                                                                    ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
                                                                    : selectedProject != null
                                                                        ? selectedProject.projectID
                                                                        : "";
                                                                return await _modelListCubit.getSuggestedSearchModelList(0, false, false, "", projectId, _modelListCubit.isFavorite ? 1 : 0, true, "aesc", value.trim());
                                                              } else if (value.trim().length <= 2) {
                                                                _modelListCubit.setSearchMode = SearchMode.recent;
                                                                return _modelListCubit.getRecentModel();
                                                              } else {
                                                                return [];
                                                              }
                                                            }
                                                          }
                                                        } else if (value.trim().length <= 2) {
                                                          _modelListCubit.setSearchMode = SearchMode.recent;
                                                          return _modelListCubit.getRecentModel();
                                                        } else {
                                                          return [];
                                                        }
                                                      }
                                                    }
                                                  },
                                                  currentSearchHeader: BlocBuilder<ModelListCubit, ModelListState>(builder: (context, state) {
                                                    return Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: NormalTextWidget(
                                                        _modelListCubit.getSearchMode == SearchMode.recent ? context.toLocale!.text_recent_searches : context.toLocale!.text_suggested_searches,
                                                        fontWeight: AFontWight.regular,
                                                        fontSize: 13,
                                                        color: AColors.iconGreyColor,
                                                      ),
                                                    );
                                                  }),
                                                  itemBuilder: (context, suggestion, suggestionsCallback) {
                                                    return Column(
                                                      children: [
                                                        SizedBox(
                                                          height: 40,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left: 18.0, right: 16.0, top: 0.0, bottom: 0.0),
                                                            child: _modelListCubit.getSearchMode == SearchMode.suggested
                                                                ? Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child: NormalTextWidget(
                                                                          suggestion.userModelName!.overflow ?? "",
                                                                          fontSize: 15,
                                                                          fontWeight: AFontWight.medium,
                                                                          overflow: TextOverflow.ellipsis,
                                                                          color: AColors.textColor,
                                                                          textAlign: TextAlign.start,
                                                                          maxLines: 1,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                : Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                    children: [
                                                                      Flexible(
                                                                        child: Row(
                                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                                          children: [
                                                                            Icon(
                                                                              Icons.access_time_outlined,
                                                                              color: AColors.lightGreyColor,
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 12,
                                                                            ),
                                                                            Expanded(
                                                                              child: NormalTextWidget(
                                                                                suggestion.userModelName!.overflow ?? "",
                                                                                fontWeight: AFontWight.light,
                                                                                fontSize: 15,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                color: AColors.textColor,
                                                                                textAlign: TextAlign.start,
                                                                                maxLines: 1,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                          ),
                                                        )
                                                      ],
                                                    );
                                                  },
                                                  onSuggestionSelected: (suggestion) async {
                                                    String projectId = !isNetWorkConnected()
                                                        ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
                                                        : selectedProject != null
                                                            ? selectedProject.projectID
                                                            : "";
                                                    _modelListCubit.searchString = suggestion.userModelName!;
                                                    searchController.text = _modelListCubit.searchString;
                                                    if (_modelListCubit.searchString.trim().isNotEmpty) {
                                                      await _modelListCubit.addRecentModel(newSearch: _modelListCubit.searchString);
                                                    }
                                                    if (_modelListCubit.searchString.trim().isNotEmpty) {
                                                      _modelListCubit.getFilteredList(page, true, projectId, _modelListCubit.searchString.trim().toString(), _modelListCubit.isFavorite ? 1 : 0);
                                                    } else {
                                                      String projectId = !isNetWorkConnected()
                                                          ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
                                                          : selectedProject != null
                                                              ? selectedProject.projectID
                                                              : "";
                                                      await _modelListCubit.pageFetch(0, false, false, "", projectId, _modelListCubit.isFavorite ? 1 : 0, true, "aes", _modelListCubit.searchString);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const SizedBox(
                                                  width: 12,
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    if (isNetWorkConnected()) {
                                                      if (state is! ProjectLoadingState || state is model_cubit.LoadingModelState) {
                                                        _modelListCubit.searchString = searchController.text;
                                                        _modelListCubit.selectedModelData = null;
                                                        isAscending = !isAscending;
                                                        String projectId = !isNetWorkConnected()
                                                            ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
                                                            : selectedProject != null
                                                                ? selectedProject.projectID
                                                                : "";
                                                        selectedProjectModelsList = await _modelListCubit.pageFetch(0, false, false, "", projectId, _modelListCubit.isFavorite ? 0 : 1, true, isAscending ? "aesc" : "desc", _modelListCubit.searchString.trim());
                                                      }
                                                    } else {
                                                      isAscending = !isAscending;
                                                      _modelListCubit.isAscending = isAscending;
                                                      _modelListCubit.localModelItemSort(isAscending);
                                                    }
                                                  },
                                                  child: Row(
                                                    children: [
                                                      NormalTextWidget(
                                                        context.toLocale!.name,
                                                        fontWeight: AFontWight.regular,
                                                        key: Key('key_mae_text_widget'),
                                                      ),
                                                      isAscending
                                                          ? const Icon(
                                                              Icons.keyboard_arrow_up,
                                                              key: Key('Arrow Up Icon'),
                                                            )
                                                          : const Icon(Icons.keyboard_arrow_down, key: Key('Arrow Down Icon')),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 8,
                                                ),
                                                GestureDetector(
                                                    onTap: () async {
                                                      isAscending = true;
                                                      if (isNetWorkConnected()) {
                                                        if (state is! ProjectLoadingState || state is model_cubit.LoadingModelState) {
                                                          _modelListCubit.searchString = searchController.text;
                                                          _modelListCubit.isFavorite = !_modelListCubit.isFavorite;
                                                          String projectId = !isNetWorkConnected()
                                                              ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
                                                              : selectedProject != null
                                                                  ? selectedProject.projectID
                                                                  : "";
                                                          selectedProjectModelsList = await _modelListCubit.pageFetch(0, false, false, "", projectId, _modelListCubit.isFavorite ? 1 : 0, true, "aesc", _modelListCubit.searchString.trim());
                                                        }
                                                      } else {
                                                        _modelListCubit.isFavorite = !_modelListCubit.isFavorite;
                                                        _modelListCubit.getFavouriteModelsLocal();
                                                      }
                                                    },
                                                    child: Icon(
                                                      _modelListCubit.isFavorite ? Icons.star : Icons.star_border,
                                                      key: const Key('Star Icon'),
                                                      color: _modelListCubit.isFavorite ? const Color(0xFFF79120) : AColors.grColor,
                                                    ))
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                child: (state is model_cubit.ProjectLoadingState)
                                                    ? const ACircularProgress()
                                                    : selectedProjectModelsList.isNotEmpty
                                                        ? RefreshIndicator(
                                                            onRefresh: _pullRefresh,
                                                            child: ListView.builder(
                                                              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                                                              itemCount: selectedProjectModelsList.length,
                                                              shrinkWrap: true,
                                                              key: const Key('ListviewFirst'),
                                                              controller: paginationScrollController,
                                                              physics: const AlwaysScrollableScrollPhysics(),
                                                              itemBuilder: (ctx, index) {
                                                                return Column(
                                                                  children: [
                                                                    ModelListTile(
                                                                      key: const Key("key_model_list_tile_phone"),
                                                                      progress: _modelListCubit.progress,
                                                                      totalProgress: _modelListCubit.totalProgress,
                                                                      isDownload: state is DownloadModelState && state.downloadStart && _modelListCubit.selectedModelIndex == index,
                                                                      selectedIndex: selectedIndex,
                                                                      selectedProjectModelsList: selectedProjectModelsList,
                                                                      index: index,
                                                                      selectedProject: selectedProject,
                                                                      model: selectedProjectModelsList[index],
                                                                      onTap: (String? callFrom) {
                                                                        modelListOnTap(
                                                                          index,
                                                                          callFrom,
                                                                        );
                                                                      },
                                                                      state: state,
                                                                      isShowSideToolBar: widget.isShowSideToolBar,
                                                                    ),
                                                                    if ((state is DownloadModelState && state.downloadStart && _modelListCubit.selectedModelIndex == index)) ...[
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(left: 28, top: 4),
                                                                        child: LinearProgressIndicator(
                                                                          backgroundColor: const Color.fromARGB(255, 134, 183, 208),
                                                                          color: Colors.blue,
                                                                          value: (state.progressValue / state.totalSize),
                                                                        ),
                                                                      ),
                                                                    ] else ...[
                                                                      const Divider(
                                                                        thickness: 1,
                                                                        indent: 0,
                                                                        height: 0,
                                                                      ),
                                                                    ]
                                                                  ],
                                                                );
                                                              },
                                                            ),
                                                          )
                                                        : RefreshIndicator(
                                                            onRefresh: _pullRefresh,
                                                            child: SingleChildScrollView(
                                                              physics: AlwaysScrollableScrollPhysics(),
                                                              child: SizedBox(
                                                                height: _modelListCubit.isShowDetails ? MediaQuery.of(context).size.height * 0.4 : MediaQuery.of(context).size.height * 0.3,
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Align(
                                                                      alignment: Alignment.center,
                                                                      child: Text(context.toLocale!.no_record_available),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: state is model_cubit.LoadingModelState,
                                              child: Padding(padding: EdgeInsets.only(bottom: 16), child: const ACircularProgress()),
                                            ),
                                            if (isNetWorkConnected() && (state is ItemCheckedState && _modelListCubit.isAnyItemChecked) && (_modelListCubit.selectedFloorList.isNotEmpty || _modelListCubit.selectedCalibrate.isNotEmpty) || (isNetWorkConnected() && state is ItemCheckedState && (_modelListCubit.removeList.isNotEmpty || _modelListCubit.caliRemoveList.isNotEmpty))) ...[
                                              Container(
                                                width: MediaQuery.of(context).size.width,
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                      color: Color.fromRGBO(
                                                        224,
                                                        224,
                                                        224,
                                                        1,
                                                      ),
                                                    ),
                                                  ),
                                                  color: Colors.transparent,
                                                ),
                                                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                child: Align(
                                                  alignment: Alignment.bottomRight,
                                                  child: Row(
                                                    children: <Widget>[
                                                      const Spacer(),
                                                      SizedBox(
                                                        height: 42,
                                                        width: 110,
                                                        child: OutlinedButton(
                                                          onPressed: () {
                                                            _modelListCubit.itemDropdownClick(index, isCancel: true);
                                                          },
                                                          style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey, width: .8)),
                                                          child: Text(
                                                            AConstants.cancel,
                                                            style: TextStyle(
                                                              color: AColors.themeBlueColor,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      SizedBox(
                                                        height: 42,
                                                        width: 110,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            showDownloadPopup();
                                                          },
                                                          style: ElevatedButton.styleFrom(backgroundColor: AColors.themeBlueColor, disabledForegroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                                                          child: Text(
                                                            _modelListCubit.isItemForUpdate ? context.toLocale!.update : context.toLocale!.lbl_download,
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ] else if (state is DownloadModelState) ...[
                                              SizedBox.shrink(
                                                key: const Key('key_download_model_state'),
                                              )
                                            ] else if (isNetWorkConnected() && state is DropdownOpenState && _modelListCubit.isOpened) ...[
                                              Container(
                                                width: MediaQuery.of(context).size.width,
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                      color: Color.fromRGBO(
                                                        224,
                                                        224,
                                                        224,
                                                        1,
                                                      ),
                                                    ),
                                                  ),
                                                  color: Colors.transparent,
                                                ),
                                                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                child: Align(
                                                  alignment: Alignment.bottomRight,
                                                  child: Row(
                                                    children: <Widget>[
                                                      const Spacer(),
                                                      SizedBox(
                                                        height: 42,
                                                        width: 110,
                                                        child: OutlinedButton(
                                                          onPressed: () {
                                                            _modelListCubit.itemDropdownClick(index, isCancel: true);
                                                          },
                                                          style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey, width: .8)),
                                                          child: Text(
                                                            AConstants.cancel,
                                                            style: TextStyle(
                                                              color: AColors.themeBlueColor,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      SizedBox(
                                                        height: 42,
                                                        width: 110,
                                                        child: ElevatedButton(
                                                          onPressed: null,
                                                          style: ElevatedButton.styleFrom(backgroundColor: AColors.themeBlueColor, disabledForegroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                                                          child: Text(
                                                            state.isUpdate ? context.toLocale!.update : context.toLocale!.lbl_download,
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ] else ...[
                                              Container(
                                                width: MediaQuery.of(context).size.width,
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                      color: Color.fromRGBO(224, 224, 224, 1),
                                                    ),
                                                  ),
                                                  color: Colors.transparent,
                                                ),
                                                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                                                child: Align(
                                                  alignment: Alignment.bottomRight,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      if ((_modelListCubit.selectedModel != null && isNetWorkConnected()) || (!isNetWorkConnected() && _modelListCubit.selectedFloorList.isNotEmpty)) {
                                                        onOpenClicked();
                                                      }
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: ((_modelListCubit.selectedModel != null && isNetWorkConnected()) || (!isNetWorkConnected() && _modelListCubit.selectedFloorList.isNotEmpty)) ? const Color.fromRGBO(8, 91, 144, 1) : AColors.lightGreyColor,
                                                        ),
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(6),
                                                        ),
                                                        color: ((_modelListCubit.selectedModel != null && isNetWorkConnected()) || (!isNetWorkConnected() && _modelListCubit.selectedFloorList.isNotEmpty)) ? const Color.fromRGBO(8, 91, 144, 1) : AColors.lightGreyColor,
                                                      ),
                                                      width: 100,
                                                      height: 42,
                                                      child: Center(
                                                          child: Text(
                                                        context.toLocale!.open,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      )),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ]
                                          ],
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                                IgnorePointer(
                                  ignoring: state is DownloadModelState,
                                  child: ModelStorageLandscapeWidget(
                                    selectedProject: selectedProject != null ? selectedProject : Project(),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  void clearButtonOnTap() async {
    FocusManager.instance.primaryFocus?.unfocus();
    _modelListCubit.selectedModelData = null;
    _modelListCubit.selectedModel = null;
    searchController.text = '';
    _modelListCubit.setSearchMode = SearchMode.recent;
    _modelListCubit.searchString = searchController.text;
    _modelListCubit.selectedModel = null;
    isAscending = true;
    String projectId = !isNetWorkConnected()
        ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
        : selectedProject != null
            ? selectedProject.projectID
            : "";
    selectedProjectModelsList = await _modelListCubit.pageFetch(0, false, false, "", projectId, _modelListCubit.isFavorite ? 0 : 1, true, "aesc", _modelListCubit.searchString);
    _storageCubit.updateModelSize(_modelListCubit.selectedModel);
    _storageCubit.emitSizeUpdateState();
  }

  /// Tablet portrait view
  Widget tabBuildListView(model_cubit.ModelListState state, bool isFiltered, BuildContext context) {
    return OrientationBuilder(
      builder: (_, orientation) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: SizedBox(
            key: Key('key_tab_view_sized_box'),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  key: Key('key_visibility_side_tool_bar'),
                  visible: widget.isShowSideToolBar,
                  child: SizedBox(
                    width: Utility.isTablet && orientation == Orientation.portrait
                        ? MediaQuery.of(context).size.width * 0.06
                        : Utility.isTablet && orientation == Orientation.landscape
                            ? MediaQuery.of(context).size.width * 0.04
                            : MediaQuery.of(context).size.width * 0.13,
                    child: SideToolbarScreen(
                      isWhite: false,
                      isModelSelected: true,
                      isOnlineModelViewerScreen: false,
                      onlineModelViewerCubit: _modelListCubit,
                      orientation: orientation,
                      isPdfViewISFull: true,
                      modelId: "",
                      modelName: AConstants.modelName,
                    ),
                  ),
                ),
                Expanded(
                    key: Key('key_expanded_view'),
                    child: Visibility(
                      key: Key('key_visibility_listview_builder'),
                      visible: state is model_cubit.LoadingModelState || state is model_cubit.AllModelSuccessState || state is ShowSnackBarState || state is ShowSnackBarInQueueState || state is model_cubit.SearchModelState || state is model_cubit.ProjectLoadingState || state is model_cubit.OpenButtonLoadingState || state is ShowDetailsState || state is DownloadModelState || state is ItemCheckedState || state is DropdownOpenState,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                              child: Stack(
                            children: [
                              Positioned(
                                left: 0,
                                right: 0,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: state is model_cubit.OpenButtonLoadingState && state.isShow ? const ACircularProgress() : null,
                                ),
                              ),
                              Container(
                                key: Key('key_container_listview_landscape'),
                                padding: const EdgeInsets.all(16),
                                width: _listWidth(orientation),
                                height: MediaQuery.of(context).size.height,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Visibility(
                                      key: Key('key_portrait_visibility_storage_widget'),
                                      visible: orientation == Orientation.portrait,
                                      child: IgnorePointer(
                                        ignoring: state is DownloadModelState,
                                        child: ModelStorageWidget(
                                          key: Key('key_portrait_storage_widget'),
                                          selectedProject: selectedProject != null ? selectedProject : Project(),
                                        ),
                                      ),
                                    ),
                                    IgnorePointer(
                                      key: Key('key_landscape_container_listview'),
                                      ignoring: (state is model_cubit.OpenButtonLoadingState && state.isShow) || state is DownloadModelState,
                                      child: Container(
                                        height: 50,
                                        width: Utility.isTablet && orientation == Orientation.landscape ? MediaQuery.of(context).size.width * .65 : MediaQuery.of(context).size.width,
                                        padding: EdgeInsets.only(left: Utility.isTablet && orientation == Orientation.landscape ? 15 : 0, right: 5),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: const EdgeInsets.only(left: 5, bottom: 5),
                                                width: Utility.isTablet && orientation == Orientation.portrait
                                                    ? MediaQuery.of(context).size.width * 0.7
                                                    : Utility.isTablet && orientation == Orientation.landscape
                                                        ? MediaQuery.of(context).size.width * 0.35
                                                        : MediaQuery.of(context).size.width * 0.87,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(top: 8.0),
                                                  child: CustomSearchSuggestionView<Model>(
                                                    key: const Key("key_search_model_list"),
                                                    placeholder: context.toLocale!.search_models,
                                                    hideSuggestionsOnKeyboardHide: true,
                                                    textFieldConfiguration: SearchTextFormFieldConfiguration(
                                                      controller: searchController,
                                                      focusNode: searchModelNode,
                                                      textInputAction: TextInputAction.search,
                                                      suffixIconOnClick: () {
                                                        clearButtonOnTap();
                                                      },
                                                      onSubmitted: (value) async {
                                                        isAscending = true;
                                                        String projectId = !isNetWorkConnected()
                                                            ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
                                                            : selectedProject != null
                                                                ? selectedProject.projectID
                                                                : "";
                                                        if (value.trim().isNotEmpty) {
                                                          await _modelListCubit.addRecentModel(newSearch: _modelListCubit.searchString.trim());
                                                          _modelListCubit.setSearchMode = SearchMode.recent;
                                                          _modelListCubit.getFilteredList(page, true, projectId, value.trim(), _modelListCubit.isFavorite ? 1 : 0);
                                                        } else {
                                                          _modelListCubit.searchString = value.trim();
                                                          searchController.text = _modelListCubit.searchString;
                                                          context.closeKeyboard();
                                                          _modelListCubit.getFilteredList(page, true, projectId, value.trim(), _modelListCubit.isFavorite ? 1 : 0);
                                                        }
                                                      },
                                                    ),
                                                    suggestionsCallback: (value) async {
                                                      _modelListCubit.searchString = value.trim();
                                                      if (!searchModelNode.hasFocus) {
                                                        return [];
                                                      } else {
                                                        if (value.isEmpty && searchModelNode.hasFocus) {
                                                          return await _modelListCubit.getRecentModel();
                                                        } else {
                                                          if (value.trim().length >= 3) {
                                                            _modelListCubit.setSearchMode = SearchMode.suggested;
                                                            _modelListCubit.searchString = value.trim();
                                                            if (!searchModelNode.hasFocus) {
                                                              return [];
                                                            } else {
                                                              if (value.isEmpty && !searchModelNode.hasFocus) {
                                                                return await _modelListCubit.getRecentModel();
                                                              } else {
                                                                if (value.trim().length >= 3) {
                                                                  _modelListCubit.setSearchMode = SearchMode.suggested;
                                                                  String projectId = !isNetWorkConnected()
                                                                      ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
                                                                      : selectedProject != null
                                                                          ? selectedProject.projectID
                                                                          : "";
                                                                  return await _modelListCubit.getSuggestedSearchModelList(0, false, false, "", projectId, _modelListCubit.isFavorite ? 1 : 0, true, "aesc", value.trim());
                                                                } else if (value.trim().length <= 2) {
                                                                  _modelListCubit.setSearchMode = SearchMode.recent;
                                                                  return _modelListCubit.getRecentModel();
                                                                } else {
                                                                  return [];
                                                                }
                                                              }
                                                            }
                                                          } else if (value.trim().length <= 2) {
                                                            _modelListCubit.setSearchMode = SearchMode.recent;
                                                            return _modelListCubit.getRecentModel();
                                                          } else {
                                                            return [];
                                                          }
                                                        }
                                                      }
                                                    },
                                                    currentSearchHeader: BlocBuilder<ModelListCubit, ModelListState>(builder: (context, state) {
                                                      return Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: NormalTextWidget(
                                                          _modelListCubit.getSearchMode == SearchMode.recent ? context.toLocale!.text_recent_searches : context.toLocale!.text_suggested_searches,
                                                          fontWeight: AFontWight.regular,
                                                          fontSize: 13,
                                                          color: AColors.iconGreyColor,
                                                        ),
                                                      );
                                                    }),
                                                    itemBuilder: (context, suggestion, suggestionsCallback) {
                                                      return Column(
                                                        children: [
                                                          SizedBox(
                                                            height: 40,
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(left: 18.0, right: 16.0, top: 0.0, bottom: 0.0),
                                                              child: _modelListCubit.getSearchMode == SearchMode.suggested
                                                                  ? Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Expanded(
                                                                          child: NormalTextWidget(
                                                                            suggestion.userModelName!.overflow ?? "",
                                                                            fontSize: 15,
                                                                            fontWeight: AFontWight.medium,
                                                                            overflow: TextOverflow.ellipsis,
                                                                            color: AColors.textColor,
                                                                            textAlign: TextAlign.start,
                                                                            maxLines: 1,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Row(
                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        Flexible(
                                                                          child: Row(
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            children: [
                                                                              Icon(
                                                                                Icons.access_time_outlined,
                                                                                color: AColors.lightGreyColor,
                                                                              ),
                                                                              const SizedBox(
                                                                                width: 12,
                                                                              ),
                                                                              Expanded(
                                                                                child: NormalTextWidget(
                                                                                  suggestion.userModelName!.overflow ?? "",
                                                                                  fontWeight: AFontWight.light,
                                                                                  fontSize: 15,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  color: AColors.textColor,
                                                                                  textAlign: TextAlign.start,
                                                                                  maxLines: 1,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                            ),
                                                          )
                                                        ],
                                                      );
                                                    },
                                                    onSuggestionSelected: (suggestion) async {
                                                      String projectId = !isNetWorkConnected()
                                                          ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
                                                          : selectedProject != null
                                                              ? selectedProject.projectID
                                                              : "";
                                                      _modelListCubit.searchString = suggestion.userModelName!;
                                                      searchController.text = _modelListCubit.searchString;
                                                      if (_modelListCubit.searchString.trim().isNotEmpty) {
                                                        await _modelListCubit.addRecentModel(newSearch: _modelListCubit.searchString);
                                                      }
                                                      if (_modelListCubit.searchString.trim().isNotEmpty) {
                                                        _modelListCubit.getFilteredList(page, true, projectId, _modelListCubit.searchString.trim().toString(), _modelListCubit.isFavorite ? 1 : 0);
                                                      } else {
                                                        String projectId = !isNetWorkConnected()
                                                            ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
                                                            : selectedProject != null
                                                                ? selectedProject.projectID
                                                                : "";
                                                        await _modelListCubit.pageFetch(0, false, false, "", projectId, _modelListCubit.isFavorite ? 1 : 0, true, "aes", _modelListCubit.searchString);
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                TextButton(
                                                  onPressed: () async {
                                                    if (isNetWorkConnected()) {
                                                      if (state is! ProjectLoadingState || state is model_cubit.LoadingModelState) {
                                                        _modelListCubit.searchString = searchController.text;
                                                        _modelListCubit.selectedModelData = null;
                                                        isAscending = !isAscending;
                                                        String projectId = !isNetWorkConnected()
                                                            ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
                                                            : selectedProject != null
                                                                ? selectedProject.projectID
                                                                : "";
                                                        selectedProjectModelsList = await _modelListCubit.pageFetch(0, false, false, "", projectId, _modelListCubit.isFavorite ? 0 : 1, true, isAscending ? "aesc" : "desc", _modelListCubit.searchString.trim());
                                                      }
                                                    } else {
                                                      isAscending = !isAscending;
                                                      _modelListCubit.isAscending = isAscending;
                                                      _modelListCubit.localModelItemSort(isAscending);
                                                    }
                                                  },
                                                  child: Row(
                                                    children: [
                                                      const NormalTextWidget(
                                                        "Name",
                                                        fontWeight: AFontWight.regular,
                                                      ),
                                                      isAscending ? const Icon(Icons.keyboard_arrow_up) : const Icon(Icons.keyboard_arrow_down),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                GestureDetector(
                                                    onTap: () async {
                                                      isAscending = true;
                                                      if (isNetWorkConnected()) {
                                                        if (state is! ProjectLoadingState || state is model_cubit.LoadingModelState) {
                                                          _modelListCubit.searchString = searchController.text;
                                                          _modelListCubit.isFavorite = !_modelListCubit.isFavorite;
                                                          String projectId = !isNetWorkConnected()
                                                              ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
                                                              : selectedProject != null
                                                                  ? selectedProject.projectID
                                                                  : "";
                                                          if (projectId.isEmpty) {
                                                            _modelListCubit.emitAllModelSuccessState();
                                                            return;
                                                          }
                                                          selectedProjectModelsList = await _modelListCubit.pageFetch(0, false, false, "", projectId, _modelListCubit.isFavorite ? 1 : 0, true, "aesc", _modelListCubit.searchString.trim());
                                                        }
                                                      } else {
                                                        _modelListCubit.isFavorite = !_modelListCubit.isFavorite;
                                                        _modelListCubit.getFavouriteModelsLocal();
                                                      }
                                                    },
                                                    child: Icon(
                                                      _modelListCubit.isFavorite ? Icons.star : Icons.star_border,
                                                      key: _modelListCubit.isFavorite ? Key("key_icon_star") : Key("key_icon_star_border"),
                                                      color: _modelListCubit.isFavorite ? const Color(0xFFF79120) : AColors.grColor,
                                                    )),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        width: orientation == Orientation.landscape ? MediaQuery.of(context).size.width * 0.62 : MediaQuery.of(context).size.width,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Flexible(
                                              child: SizedBox(
                                                height: orientation == Orientation.portrait
                                                    ? MediaQuery.of(context).size.height * 0.75 -
                                                        (kBottomNavigationBarHeight +
                                                            (MediaQuery.of(context).size.height == 1180 || MediaQuery.of(context).size.height == 1194
                                                                ? 60
                                                                : MediaQuery.of(context).size.height == 1133
                                                                    ? 70
                                                                    : 20))
                                                    : MediaQuery.of(context).size.height * 0.7 -
                                                        (kBottomNavigationBarHeight -
                                                            (MediaQuery.of(context).size.height == 744
                                                                ? (-5)
                                                                : MediaQuery.of(context).size.height == 820
                                                                    ? 20
                                                                    : (75))),
                                                child: (state is model_cubit.ProjectLoadingState || (selectedProjectModelsList.isEmpty && state is ShowDetailsState && state.items.isEmpty)) && _modelListCubit.isProjectLoading
                                                    ? const ACircularProgress(
                                                        key: Key('key_a_circular_progress'),
                                                      )
                                                    : selectedProjectModelsList.isNotEmpty
                                                        ? IgnorePointer(
                                                            key: Key('key_ignore_pointer'),
                                                            ignoring: state is model_cubit.OpenButtonLoadingState && state.isShow,
                                                            child: RefreshIndicator(
                                                              onRefresh: _pullRefresh,
                                                              child: ListView.builder(
                                                                itemCount: selectedProjectModelsList.length,
                                                                shrinkWrap: true,
                                                                key: const Key('ListviewFirst'),
                                                                controller: paginationScrollController,
                                                                physics: const AlwaysScrollableScrollPhysics(),
                                                                itemBuilder: (ctx, index) {
                                                                  return Column(
                                                                    children: [
                                                                      ModelListTile(
                                                                        state: state,
                                                                        key: const Key("key_model_list_tile_tablet"),
                                                                        progress: _modelListCubit.progress,
                                                                        totalProgress: _modelListCubit.totalProgress,
                                                                        selectedProject: selectedProject,
                                                                        selectedIndex: selectedIndex,
                                                                        isShowSideToolBar: widget.isShowSideToolBar,
                                                                        isDownload: state is DownloadModelState && state.downloadStart && _modelListCubit.selectedModelIndex == index,
                                                                        selectedProjectModelsList: selectedProjectModelsList,
                                                                        model: selectedProjectModelsList[index],
                                                                        index: index,
                                                                        onTap: (String? callFrom) {
                                                                          modelListOnTap(
                                                                            index,
                                                                            callFrom,
                                                                          );
                                                                        },
                                                                      ),
                                                                      if (state is DownloadModelState && state.downloadStart && _modelListCubit.selectedModelIndex == index) ...[
                                                                        Padding(
                                                                          key: const Key('key_linear_progress_bar_padding'),
                                                                          padding: const EdgeInsets.only(left: 28, top: 4),
                                                                          child: LinearProgressIndicator(
                                                                            key: const Key('key_linear_progress_bar_indicator'),
                                                                            backgroundColor: const Color.fromARGB(255, 134, 183, 208),
                                                                            color: Colors.blue,
                                                                            value: (state.progressValue / state.totalSize),
                                                                          ),
                                                                        ),
                                                                      ] else ...[
                                                                        const Divider(
                                                                          key: const Key('key_linear_progress_bar_divider'),
                                                                          thickness: 1,
                                                                          indent: 0,
                                                                          height: 0,
                                                                        ),
                                                                      ],
                                                                    ],
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          )
                                                        : RefreshIndicator(
                                                            key: Key('key_refresh_indicator'),
                                                            onRefresh: _pullRefresh,
                                                            child: SingleChildScrollView(
                                                              physics: AlwaysScrollableScrollPhysics(),
                                                              child: SizedBox(
                                                                height: _modelListCubit.isShowDetails ? MediaQuery.of(context).size.height * 0.4 : MediaQuery.of(context).size.height * 0.6,
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Align(
                                                                      alignment: Alignment.center,
                                                                      child: Text(context.toLocale!.no_record_available),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                              ),
                                              fit: FlexFit.tight,
                                            ),
                                            Visibility(
                                              visible: (state is ShowProgressBar && state.isLoading) || state is model_cubit.LoadingModelState,
                                              child: const ACircularProgress(),
                                            ),
                                            if (isNetWorkConnected() && (state is ItemCheckedState && _modelListCubit.isAnyItemChecked) && (_modelListCubit.selectedFloorList.isNotEmpty || _modelListCubit.selectedCalibrate.isNotEmpty) || (isNetWorkConnected() && state is ItemCheckedState && (_modelListCubit.removeList.isNotEmpty || _modelListCubit.caliRemoveList.isNotEmpty))) ...[
                                              Container(
                                                key: Key('key_cancel_button_container'),
                                                width: MediaQuery.of(context).size.width,
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                      color: Color.fromRGBO(224, 224, 224, 1),
                                                    ),
                                                  ),
                                                  color: Colors.transparent,
                                                ),
                                                padding: getPadding(orientation),
                                                child: Align(
                                                  alignment: Alignment.bottomRight,
                                                  child: Row(
                                                    children: <Widget>[
                                                      const Spacer(),
                                                      SizedBox(
                                                        key: Key('key_sized_box_cancel'),
                                                        height: 42,
                                                        width: 110,
                                                        child: OutlinedButton(
                                                          onPressed: () {
                                                            _modelListCubit.itemDropdownClick(index, isCancel: true);
                                                          },
                                                          style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey, width: .8)),
                                                          child: Text(
                                                            context.toLocale!.lbl_cancel,
                                                            key: Key('key_cancel_text_widget'),
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: AColors.themeBlueColor,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 12,
                                                      ),
                                                      SizedBox(
                                                        key: Key('key_sized_box_download'),
                                                        height: 42,
                                                        width: 110,
                                                        child: ElevatedButton(
                                                          onPressed: () {
                                                            showDownloadPopup();
                                                          },
                                                          style: ElevatedButton.styleFrom(backgroundColor: AColors.themeBlueColor, disabledForegroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                                                          child: Text(
                                                            _modelListCubit.isItemForUpdate ? context.toLocale!.update : context.toLocale!.lbl_download,
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ] else if (state is DownloadModelState) ...[
                                              SizedBox.shrink(
                                                key: Key('key_sized_box_shrink'),
                                              )
                                            ] else if (isNetWorkConnected() && state is DropdownOpenState && _modelListCubit.isOpened) ...[
                                              Container(
                                                key: Key('key_container_dropdown'),
                                                width: MediaQuery.of(context).size.width,
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                      color: Color.fromRGBO(224, 224, 224, 1),
                                                    ),
                                                  ),
                                                  color: Colors.transparent,
                                                ),
                                                padding: getPadding(orientation),
                                                child: Align(
                                                  alignment: Alignment.bottomRight,
                                                  child: Row(
                                                    children: <Widget>[
                                                      const Spacer(),
                                                      SizedBox(
                                                        key: Key('key_container_sized_box_dropdown'),
                                                        height: 42,
                                                        width: 110,
                                                        child: OutlinedButton(
                                                          onPressed: () {
                                                            _modelListCubit.itemDropdownClick(index, isCancel: true);
                                                          },
                                                          style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey, width: .8)),
                                                          child: Text(
                                                            context.toLocale!.lbl_cancel,
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: AColors.themeBlueColor,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 12,
                                                      ),
                                                      SizedBox(
                                                        key: Key('key_container_sized_box_download_update_dropdown'),
                                                        height: 42,
                                                        width: 110,
                                                        child: ElevatedButton(
                                                          onPressed: null,
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: AColors.themeBlueColor,
                                                            disabledForegroundColor: Colors.white,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(6),
                                                            ),
                                                          ),
                                                          child: Text(
                                                            state.isUpdate ? context.toLocale!.update : context.toLocale!.lbl_download,
                                                            style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 15,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ] else ...[
                                              Container(
                                                key: const Key("key_open"),
                                                width: MediaQuery.of(context).size.width,
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                      color: Color.fromRGBO(224, 224, 224, 1),
                                                    ),
                                                  ),
                                                  color: Colors.transparent,
                                                ),
                                                padding: getPadding(orientation),
                                                child: Align(
                                                  alignment: Alignment.bottomRight,
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      if ((_modelListCubit.selectedModel != null && isNetWorkConnected()) || (!isNetWorkConnected() && _modelListCubit.selectedFloorList.isNotEmpty)) {
                                                        onOpenClicked();
                                                      }
                                                    },
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          color: ((_modelListCubit.selectedModel != null && isNetWorkConnected()) || (!isNetWorkConnected() && _modelListCubit.selectedFloorList.isNotEmpty)) ? const Color.fromRGBO(8, 91, 144, 1) : AColors.lightGreyColor,
                                                        ),
                                                        borderRadius: const BorderRadius.all(
                                                          Radius.circular(6),
                                                        ),
                                                        color: (_modelListCubit.selectedModel != null && isNetWorkConnected()) || (!isNetWorkConnected() && _modelListCubit.selectedFloorList.isNotEmpty) ? const Color.fromRGBO(8, 91, 144, 1) : AColors.lightGreyColor,
                                                      ),
                                                      width: 100,
                                                      height: 42,
                                                      child: Center(
                                                          child: Text(
                                                        context.toLocale!.open,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      )),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                            const SizedBox(height: 10)
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                          Visibility(
                            key: Key('key_model_storage_landscape_widget'),
                            visible: orientation == Orientation.landscape,
                            child: SizedBox(width: MediaQuery.of(context).size.width * 0.35, height: MediaQuery.of(context).size.height, child: IgnorePointer(ignoring: state is DownloadModelState, child: ModelStorageLandscapeWidget(selectedProject: selectedProject != null ? selectedProject : Project()))),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> getProjectName() async {
    projectName = await _modelListCubit.getProjectName(selectedProject?.projectID ?? "", true);
  }


  getPadding(Orientation orientation) {
    Log.d(MediaQuery.of(context).size.height);
    if (Utility.isTablet && Platform.isAndroid) {
      return const EdgeInsets.only(bottom: 120, top: 12, left: 8, right: 8);
    }
    return EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height == 1366 || MediaQuery.of(context).size.height == 1180 || MediaQuery.of(context).size.height == 1194 || MediaQuery.of(context).size.height == 1133
            ? 145.0
            : MediaQuery.of(context).size.height == 1080
                ? 120.0
                : (orientation == Orientation.portrait
                    ? 135.0
                    : MediaQuery.of(context).size.height == 810
                        ? 125.0
                        : 145.0),
        top: 12,
        left: 8,
        right: 8);
  }

  Future<void> showDownloadPopup() async {
    List<BimModel> list = _modelListCubit.selectedFloorList.values.toList();
    var totalFloorSize = 0.0;
    int floorArraySize = 0;
    double removeFileSize = 0;
    double removeCalibration = 0;
    int calibratedArraySize = 0;
    List<FloorDetail> selectedFloors = [];
    for (var bimModel in list) {
      for (var floorData in bimModel.floorList) {
        if (floorData.isChecked && !floorData.isDownloaded) {
          totalFloorSize += (floorData.fileSize!);
          selectedFloors.add(floorData);
          floorArraySize++;
        }
      }
    }
    var totalCalibratedSize = 0;
    List<CalibrationDetails> calibratedList = _modelListCubit.selectedCalibrate
        .where(
          (element) => element.isChecked == true && element.isDownloaded == false,
        )
        .toList();
    for (var element in calibratedList) {
      totalCalibratedSize += element.sizeOf2DFile;
      calibratedArraySize++;
    }
    for (var remove in _modelListCubit.removeList) {
      if (remove.fileSize!.runtimeType == String) {
        removeFileSize += double.parse(remove.fileSize!.toString());
      } else {
        removeFileSize += remove.fileSize!;
      }
    }
    for (var remove in _modelListCubit.caliRemoveList) {
      if (remove.sizeOf2DFile.runtimeType == String) {
        removeFileSize += double.parse(remove.sizeOf2DFile.toString());
      } else {
        removeCalibration += remove.sizeOf2DFile;
      }
    }
    if (selectedFloors.where((e) => e.isChecked && !e.isDownloaded).isNotEmpty || calibratedList.where((e) => e.isChecked && !e.isDownloaded).isNotEmpty || _modelListCubit.removeList.isNotEmpty || _modelListCubit.caliRemoveList.isNotEmpty) {
      String projectId = await getIt<ModelListCubit>().getProjectId(selectedProject?.projectID!, false);
      if (projectId == selectedProject?.projectID.toString().plainValue()) {

      } else if (projectId != selectedProject?.projectID.toString().plainValue() && projectId.length > 0) {
        _modelListCubit.isOfflineDialogShowing = true;
        getProjectName();
        showDialog(
            context: this.context,
            barrierDismissible: false,
            builder: (context) {
              return Dialog(
                insetPadding: EdgeInsets.zero,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: SelectedProjectNotSetForOffline(
                  selectedProject: selectedProject!,
                  isShowValidation: false,
                  projectName: projectName,
                ),
              );
            }).then((value) {
          _modelListCubit.isOfflineDialogShowing = false;
        });
        return;
      } else if (isNetWorkConnected()) {
        bool includeAttachments = await StorePreference.isIncludeAttachmentsSyncEnabled();
        SiteSyncRequestTask syncRequestTask = SiteSyncRequestTask()
          ..syncRequestId = DateTime.now().millisecondsSinceEpoch
          ..projectId = selectedProject?.projectID
          ..projectName = selectedProject?.projectName
          ..isMarkOffline = true
          ..isMediaSyncEnable = includeAttachments
          ..eSyncType = ESyncType.project
          ..projectSizeInByte = '0';
        getIt<SyncCubit>().syncProjectData({"buildFlavor": AConstants.buildFlavor!, "tab": AConstants.siteTab, "syncRequest": jsonEncode(syncRequestTask)});
        return;
      }
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => ModelDownLoadDialog(
              isUpdate: _modelListCubit.isItemForUpdate,
              removeList: _modelListCubit.removeList,
              removeFileSize: formatFileSize(removeFileSize),
              caliRemoveList: _modelListCubit.caliRemoveList,
              caliRemoveFileSize: formatPdfFileSize(removeCalibration * 1024),
              calibrate: calibratedList,
              calibrateFileSize: formatPdfFileSize(totalCalibratedSize * 1024),
              modelFileSize: formatFileSize(totalFloorSize),
              floors: selectedFloors,
              onTapSelect: () async {
                var fileSize = (totalCalibratedSize / 1024) + totalFloorSize;
                var totalStorageSize = double.parse(_storageCubit.storageSpace?.totalSize.split(" ").first ?? "0") * 1024;

                if (fileSize > totalStorageSize) {
                  await showDialog(
                      context: this.context,
                      barrierDismissible: false,
                      builder: (context) {
                        return Dialog(
                          insetPadding: EdgeInsets.zero,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: FileSizeOutOfStorage(),
                        );
                      });
                  return;
                }
                _modelListCubit.downloadScsFile(
                  totalModelSize: (totalCalibratedSize / 1024) + totalFloorSize,
                  totalProgressValue: floorArraySize + calibratedArraySize,
                  calibrate: calibratedList,
                  ifcObject: list,
                  context: context,
                  selectedFloors: selectedFloors,
                );
              }));
    } else {
      context.shownCircleSnackBarAsBanner(context.toLocale!.warning, context.toLocale!.please_add_remove_to_update, Icons.warning, Colors.orange);
    }
  }

  double _listWidth(Orientation orientation) {
    if (Utility.isTablet && orientation == Orientation.portrait && widget.isShowSideToolBar) {
      return MediaQuery.of(context).size.width * 0.93;
    } else if (Utility.isTablet && orientation == Orientation.landscape && widget.isShowSideToolBar) {
      return MediaQuery.of(context).size.width * .95;
    } else if (Utility.isTablet && orientation == Orientation.landscape) {
      return MediaQuery.of(context).size.width * .99;
    } else {
      return MediaQuery.of(context).size.width;
    }
  }

  FloatingActionButtonLocation _buildFloatingActionButtonLocation() {
    if (Utility.isTablet) {
      return FloatingActionButtonLocation.startDocked;
    } else {
      return FloatingActionButtonLocation.startDocked;
    }
  }

  void fetchListOfModels() async {
    if (searchController.text.trim().isNotEmpty) {
      _modelListCubit.searchString = searchController.text.trim();
    }
    if (selectedProjectModelsList.isNotEmpty) {
      selectedProjectModelsList.clear();
    }
    isAscending = !isAscending;
    String projectId = !isNetWorkConnected()
        ? await _modelListCubit.getProjectId(selectedProject != null ? selectedProject.projectID : '', false)
        : selectedProject != null
            ? selectedProject.projectID
            : "";
    if (projectId.isEmpty) {
      _modelListCubit.emitAllModelSuccessState();
      return;
    }
    selectedProjectModelsList = await _modelListCubit.pageFetch(0, false, false, "", projectId.toString(), _modelListCubit.isFavorite ? 1 : 0, true, isAscending ? "aesc" : "desc", _modelListCubit.searchString);
  }

  void onOpenClicked() async {
    if (isNetWorkConnected()) {
      _modelListCubit.emitOpenButtonModelLoadingState(true);
      BimProjectModelRequestModel bimProjectModelRequestModel = _modelListCubit.buildBimRequestBody(selectedIndex, selectedProjectModelsList, selectedProject);
      _bimProjectModelCubit.getBimProjectModel(project: bimProjectModelRequestModel).then((value) async {
        tempList = value;
        bimModelList = tempList.isNotEmpty
            ? tempList[0].bIMProjectModelVO!.ifcObject!.ifcObjects != null
                ? tempList[0].bIMProjectModelVO!.ifcObject!.ifcObjects!
                : []
            : [];
        if (bimModelList.isNotEmpty) {
          _modelListCubit.selectedModelData = OnlineViewerModelRequestModel(modelId: selectedProjectModelsList[selectedIndex].bimModelId, bimModelList: bimModelList, modelName: selectedProjectModelsList[selectedIndex].userModelName, isSelectedModel: false);
          if (context.mounted) {
            _modelListCubit.emitOpenButtonModelLoadingState(false);
            _modelListCubit.lastModelRequest = OnlineViewerModelRequestModel(modelId: selectedProjectModelsList[selectedIndex].bimModelId, bimModelList: bimModelList, modelName: selectedProjectModelsList[selectedIndex].userModelName, isSelectedModel: false);
            if (widget.isShowSideToolBar) {
              getIt<OnlineModelViewerCubit>().webviewController.evaluateJavascript(source: 'nCircle.Model.clear()');
              getIt<OnlineModelViewerCubit>().animationWebviewController.loadUrl(urlRequest: URLRequest(url: Uri.parse('about:blank')));
              getIt<OnlineModelViewerCubit>().key = GlobalKey<ScaffoldState>();
            }
            String projectId = !isNetWorkConnected()
                ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
                : selectedProject != null
                    ? selectedProject.projectID
                    : "";

            OnlineModelViewerArguments onlineModelViewerArguments = OnlineModelViewerArguments(model: _modelListCubit.selectedModel!, projectId: projectId, isShowSideToolBar: false, onlineViewerModelRequestModel: _modelListCubit.lastModelRequest!, offlineParams: {});
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext context) => OnlineModelViewerScreen(
                          onlineModelViewerArguments: onlineModelViewerArguments,
                        )));
          }
        } else {
          context.shownCircleSnackBarAsBanner(context.toLocale!.lbl_cant_open_model, context.toLocale!.lbl_access_denied, Icons.warning, Colors.yellow);
          _modelListCubit.emitNoIfcObjectsFound();
        }
      });
    } else {
      var projectId = selectedProject?.projectID;
      var modelId = _modelListCubit.selectedModel?.modelId.plainValue();
      List<BimModel> list = _modelListCubit.selectedFloorList.values.toList();
      List<CalibrationDetails> calibrateList = _modelListCubit.selectedCalibrate.where((element) => element.isChecked == true).toList();
      List<FloorDetail> floorList = [];
      list.forEach((bim) {
        bim.floorList.forEach((floor) {
          if (floor.isChecked) {
            floorList.add(floor);
          }
        });
      });
      _modelListCubit.offlineParams = {};
      Map<String, dynamic> params = {
        RequestConstants.projectId: projectId,
        RequestConstants.floorList: floorList,
        RequestConstants.modelId: modelId,
        RequestConstants.calibrateList: calibrateList,
        "bimModelsName": _modelListCubit.bimModelsName,
      };
      _modelListCubit.lastModelRequest = OnlineViewerModelRequestModel(modelId: selectedProjectModelsList[selectedIndex].bimModelId, bimModelList: bimModelList, modelName: selectedProjectModelsList[selectedIndex].userModelName, isSelectedModel: false);
      _modelListCubit.offlineParams = params;
      if (context.mounted) {
        if (widget.isShowSideToolBar) {
          getIt<OnlineModelViewerCubit>().webviewController.loadUrl(urlRequest: URLRequest(url: Uri.parse('about:blank')));
          getIt<OnlineModelViewerCubit>().webviewController.evaluateJavascript(source: 'nCircle.Model.clear()');
          getIt<OnlineModelViewerCubit>().animationWebviewController.loadUrl(urlRequest: URLRequest(url: Uri.parse('about:blank')));
          getIt<SideToolBarCubit>().isSideToolBarEnabled = false;
          getIt<OnlineModelViewerCubit>().key = GlobalKey<ScaffoldState>();
        }
        String projectId = !isNetWorkConnected()
            ? await _modelListCubit.getProjectId(selectedProject.projectID, false)
            : selectedProject != null
                ? selectedProject.projectID
                : "";
        OnlineModelViewerArguments onlineModelViewerArguments = OnlineModelViewerArguments(model: _modelListCubit.selectedModel!, projectId: projectId, isShowSideToolBar: false, onlineViewerModelRequestModel: _modelListCubit.lastModelRequest!, offlineParams: params);
        getIt<ModelTreeCubit>().lastLoadedModels.clear();
        getIt<OnlineModelViewerCubit>().selectedCalibrationName = '';
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext context) => OnlineModelViewerScreen(
                      onlineModelViewerArguments: onlineModelViewerArguments,
                    )));
        _modelListCubit.selectedFloorList.clear();
      } else {
        context.showSnack(AConstants.noModelsFound);
      }
    }
  }

  @override
  void deactivate() {
    _modelListCubit.dispose("deactivate");
    super.deactivate();
  }

  void modelListOnTap(
    int index,
    String? callFrom,
  ) {
    if (_modelListCubit.lastSelectedIndex == -1 || index != _modelListCubit.lastSelectedIndex) {
      FocusScope.of(context).unfocus();
      _modelListCubit.selectedModelData = OnlineViewerModelRequestModel(modelId: selectedProjectModelsList.isNotEmpty ? selectedProjectModelsList[index].bimModelId : "", bimModelList: bimModelList, modelName: selectedProjectModelsList.isNotEmpty ? selectedProjectModelsList[index].userModelName : "", isSelectedModel: true);
      selectedIndex = index;
      _modelListCubit.lastSelectedIndex = index;
      _modelListCubit.selectedModel = selectedProjectModelsList[index];
      _modelListCubit.toggleColor(_modelListCubit.selectedModelData!);
      if (callFrom == AConstants.itemTile) {
        _modelListCubit.changeDropdown(index);
      }
    } else if (index == _modelListCubit.lastSelectedIndex) {
      _modelListCubit.selectedModelData = null;
      _modelListCubit.selectedModel = null;
      _modelListCubit.lastSelectedIndex = -1;
    }
    _modelListCubit.allProjectState();
    if (isNetWorkConnected()) {
      _storageCubit.modelSelectState(_modelListCubit.selectedModel);
    }
  }
}

double formatStorageSize(String size) {
  RegExp regex = RegExp(r'\d+(?:\.\d+)?');
  Iterable<Match> matches = regex.allMatches(size);

  if (matches.isNotEmpty) {
    String? number = matches.elementAt(0).group(0);
    return double.parse(number!) * 1024;
  }
  return 0.0;
}

String formatFileSize(double sizeInBytes) {
  return "${(sizeInBytes.toStringAsFixed(2).toString() != "0.00" || sizeInBytes.toString() == "0.0") ? sizeInBytes.toStringAsFixed(2) : sizeInBytes.toStringAsFixed(5)} MB";
}

String formatPdfFileSize(double sizeInBytes) {
  if (sizeInBytes < 1024) {
    return "${sizeInBytes.toStringAsFixed(5).toString().split(".")[1] == "00000" || sizeInBytes.toStringAsFixed(5).toString().split(".")[1].substring(0, 1) != "00" ? sizeInBytes.toStringAsFixed(2) : sizeInBytes.toStringAsFixed(5)} B";
  } else if (sizeInBytes < (1024 * 1024)) {
    double sizeInKB = sizeInBytes / 1024;
    return "${sizeInKB.toStringAsFixed(5).toString().split(".")[1] == "00000" || sizeInKB.toStringAsFixed(5).toString().split(".")[1].substring(0, 1) != "00" ? sizeInKB.toStringAsFixed(2) : sizeInKB.toStringAsFixed(5)} KB";
  } else {
    double sizeInMB = sizeInBytes / (1024 * 1024);
    return "${sizeInMB.toStringAsFixed(5).toString().split(".")[1] == "00000" || sizeInMB.toStringAsFixed(5).toString().split(".")[1].substring(0, 1) != "00" ? sizeInMB.toStringAsFixed(2) : sizeInMB.toStringAsFixed(5)} MB";
  }
}

String formatPdfFileSizeInMB(double sizeInBytes) {
  return "${(sizeInBytes / 1024).toString().split(".")[1] == "00000" || (sizeInBytes / 1024).toString().split(".")[1].substring(0, 1) == "00" ? (sizeInBytes / 1024).toStringAsFixed(5) : (sizeInBytes / 1024).toStringAsFixed(2)} MB";
}

class FileSizeOutOfStorage extends StatelessWidget {
  FileSizeOutOfStorage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = 200;
    if (Utility.isTablet) {
      if ((MediaQuery.of(context).orientation == Orientation.portrait)) {
        width = MediaQuery.of(context).size.width * 0.6;
      } else {
        width = MediaQuery.of(context).size.width * 0.5;
      }
    } else {
      width = MediaQuery.of(context).size.width * 0.8;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              NormalTextWidget(
                "Warning",
                fontWeight: AFontWight.bold,
                fontSize: 24,
                color: AColors.textColor,
              ),
              const SizedBox(height: 20),
              NormalTextWidget(
                "Please free up some space to download files",
                textAlign: TextAlign.center,
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: AColors.grColorDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(color: AColors.lightGreyColor, height: 2, width: width),
        InkWell(
          onTap: () async {
            Navigator.pop(context);
          },
          child: Container(
            height: 50,
            width: width,
            alignment: Alignment.center,
            child: NormalTextWidget(
              context.toLocale!.lbl_ok,
              textAlign: TextAlign.center,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AColors.userOnlineColor,
            ),
          ),
        ),
      ],
    );
  }
}
