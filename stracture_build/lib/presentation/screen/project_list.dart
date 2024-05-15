import 'dart:convert';

import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/bloc/sync/sync_cubit.dart';
import 'package:field/bloc/sync/sync_state.dart';
import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/data/model/sync/sync_request_task.dart';
import 'package:field/domain/use_cases/formtype/formtype_use_case.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:field/widgets/project_download_size_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../analytics/event_analytics.dart';
import '../../bloc/project_list_item/project_item_cubit.dart';
import '../../injection_container.dart';
import '../../logger/logger.dart';
import '../../utils/global.dart';
import '../../widgets/custom_search_view/custom_search_view.dart';
import '../../widgets/normaltext.dart';
import '../managers/color_manager.dart';
import '../managers/image_constant.dart';

class ProjectList extends StatefulWidget {
  const ProjectList({Key? key, required this.isFavourites, required this.onBack, required this.screenName, required this.searchFocusNode, this.stream, required this.scrollController, required this.searchProjectController, required this.tabController}) : super(key: key);
  final bool isFavourites;
  final String screenName;
  final Stream<int>? stream;
  final Function onBack;
  final ScrollController scrollController;
  final FocusNode searchFocusNode;
  final TextEditingController searchProjectController;
  final TabController tabController;

  @override
  State<ProjectList> createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> with AutomaticKeepAliveClientMixin<ProjectList> {
  @override
  bool get wantKeepAlive => true;
  var searchString = '';
  List<Popupdata> allItems = <Popupdata>[];
  List<Popupdata> favItems = <Popupdata>[];
  var page = 0;
  var favPage = 0;
  final ProjectListCubit _cubit = di.getIt<ProjectListCubit>();
  final ProjectItemCubit _projectItemCubit = di.getIt<ProjectItemCubit>();
  final SyncCubit _syncCubit = di.getIt<SyncCubit>();
  GlobalKey<RefreshIndicatorState> refreshAllKey = GlobalKey();
  GlobalKey<RefreshIndicatorState> refreshFavKey = GlobalKey();
  var tempFlag = false;
  var isFavAscending = true;
  var isAllAscending = true;
  late double scrollPosition = 0;
  late double favScrollPosition = 0;
  var isLoading = false;
  var isFavLoading = false;

  var isFirstTimeLoading = true;

  late final ScrollController paginationScrollController;
  late final ScrollController animatedScrollController;
  int tabBarIndex = 0;
  String highlightSearch = "";

  bool isProjectMarkOfflineEnable = false;

  @override
  void initState() {
    _cubit.isLastItem = false;
    _cubit.isFavLastItem = false;
    getProjectList(false);
    super.initState();
    animatedScrollController = widget.scrollController;
    paginationScrollController = ScrollController();
    _cubit.getRecentProject();
    paginationScrollController.addListener(pagination);
    widget.stream?.listen((id) {
      if (id == 0) {
        //BackPress event from Parent
        _cubit.setSearchMode = SearchMode.recent;
      }
    });
    widget.searchProjectController.addListener(_callProjectOnEmptySearch);
    widget.tabController.addListener(_setSelectedProjectTab);
    tabBarIndex = widget.tabController.index;
    _projectItemCubit.itemDeleteRequestCancel(projectId: "");
    if (_cubit.selectedProject == null) {
      getSelectedProject();
    }
    tempFlag = widget.isFavourites;
    _cubit.checkSelectedProjectName();
  }

  getSelectedProject() async {
    _cubit.selectedProject = await StorePreference.getSelectedProjectData();
  }

  Future<void> _setSelectedProjectTab() async {
    final index = widget.tabController.index;
    if (tabBarIndex != index) {
      tabBarIndex = index;
      if (index == 1 && widget.isFavourites && favItems.isEmpty) {
        getProjectList(false);
      } else if (index == 0 && !widget.isFavourites && allItems.isEmpty) {
        getProjectList(false);
      }
      _cubit.setSearchMode = SearchMode.other;
    }
  }

  void _callProjectOnEmptySearch() {
    if (widget.searchProjectController.text.isEmpty && !isFirstTimeLoading) {
      getProjectList(false);
    } else {
      isFirstTimeLoading = false;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    paginationScrollController.dispose();
    widget.searchProjectController.removeListener(_callProjectOnEmptySearch);
    super.dispose();
  }

  void pagination() async {
    if (widget.isFavourites) {
      Log.d("fav scrollPosition", paginationScrollController.position.extentAfter);
      if (paginationScrollController.offset.toInt() >= paginationScrollController.position.maxScrollExtent.toInt()) {
        if (!isFavLoading && !_cubit.isFavLastItem) {
          isFavLoading = !isFavLoading;
          favPage++;
          favScrollPosition = paginationScrollController.offset;
          await _cubit.pageFetch(favPage, true, false, searchString, isFavAscending);
          isFavLoading = false;
        }
      }
    } else {
      Log.d("scrollPosition", paginationScrollController.position.extentAfter);
      if (paginationScrollController.offset.toInt() >= paginationScrollController.position.maxScrollExtent.toInt()) {
        if (!isLoading && !_cubit.isLastItem) {
          isLoading = !isLoading;
          page++;
          scrollPosition = paginationScrollController.offset;
          await _cubit.pageFetch(page, false, false, searchString, isAllAscending);
          isLoading = false;
        }
      }
    }
    if (!Utility.isTablet) {
      if (paginationScrollController.position.userScrollDirection == ScrollDirection.reverse) {
        animatedScrollController.animateTo(
          animatedScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 10),
          curve: Curves.linear,
        );
      }
      if (paginationScrollController.position.userScrollDirection == ScrollDirection.forward) {
        animatedScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 10),
          curve: Curves.linear,
        );
      }
    }
  }

  Widget getOrientation() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const SizedBox(height: 22.5),
        BlocBuilder<ProjectListCubit, FlowState>(builder: (context, state) {
          return OrientationBuilder(builder: (_, orientation) {
            return searchOnProjectList(orientation, state);
          });
        }),
        const SizedBox(height: 24),
        BlocBuilder<ProjectListCubit, FlowState>(
          buildWhen: (prev, current) {
            if (current is SearchModeState || current is EnableSorting || current is DisableSorting) {
              return false;
            }
            if (current is RefreshingState && !(current.isFavourite == tempFlag)) {
              return false;
            }
            if (current is AllProjectLoadingState || current is AllProjectSuccessState || current is AllProjectNotFoundState || current is AllProjectNotAllocatedState) {
              if (!tempFlag) {
                return true;
              }
              return false;
            }
            if (current is FavProjectLoadingState || current is FavProjectSuccessState || current is FavProjectNotFoundState || current is FavProjectNotAllocatedState) {
              if (tempFlag) {
                return true;
              }
              return false;
            }
            return (current is! OnChangeSorting || current is! OnChangeFavSorting);
          },
          builder: (_, state) {
            if (state is RefreshingState || state is ProjectDetailSuccessState) {
              return Expanded(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: const ACircularProgress()),
              ));
            } else if (state is AllProjectLoadingState) {
              if ((!widget.isFavourites && page == 0) && widget.searchProjectController.text.isEmpty) {
                return Expanded(child: Center(child: const ACircularProgress()));
              }
              return getProjectListWidget(state);
            } else if (state is FavProjectLoadingState) {
              if ((widget.isFavourites && favPage == 0) && widget.searchProjectController.text.isEmpty) {
                return Expanded(child: Center(child: const ACircularProgress()));
              }
              return getProjectListWidget(state);
            } else if (state is AllProjectSuccessState) {
              allItems = [...state.items];
              isFirstTimeLoading = false;
              return getProjectListWidget(state);
            } else if (state is AllProjectNotAllocatedState || state is AllProjectNotFoundState) {
              allItems.clear();
              isFirstTimeLoading = false;
              return getProjectListWidget(state);
            } else if (state is FavProjectSuccessState) {
              favItems = [...state.items];
              isFirstTimeLoading = false;
              return getProjectListWidget(state);
            } else if (state is FavProjectNotAllocatedState || state is FavProjectNotFoundState) {
              favItems.clear();
              isFirstTimeLoading = false;
              return getProjectListWidget(state);
            } else if (state is ProjectSyncProgressState) {
              return getProjectListWidget(state);
            } else {
              return getProjectListWidget(state);
            }
          },
        )
      ],
    );
  }

  Future<void> getProjectList(bool isRefreshing) async {
    // widget.isFavourites ? favItems.clear() : allItems.clear();
    await _cubit.pageFetch(0, widget.isFavourites, isRefreshing, widget.searchProjectController.text, widget.isFavourites ? isFavAscending : isAllAscending);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiBlocListener(listeners: [
      BlocListener<ProjectListCubit, FlowState>(
        listener: (_, state) async {
          Log.d("Current state $state");
          Log.d("Favourite ------> ${widget.isFavourites}---->$state");
          Log.d("Screen ------> ${widget.screenName}---->$state");
          if (state is ProjectErrorState) {
            context.showSnack(state.exception.message);
          }
        },
      ),
      BlocListener<SyncCubit, FlowState>(listener: (_, state) async {
        if (state is SyncProgressState) {
          _cubit.showSyncProgress(state.progress, state.projectId, state.syncStatus!);
        }
      })
    ], child: Scaffold(backgroundColor: AColors.white, body: getOrientation()));
  }

  Widget projectListBuilder(List<Popupdata> items, FlowState state) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return OrientationBuilder(
      key: const Key("projectList"),
      builder: (_, orientation) {
        if (items.isEmpty) {
          return Center(
            child: _onEmpty(widget.isFavourites),
          );
        }
        return RefreshIndicator(
          key: (widget.isFavourites ? refreshFavKey : refreshAllKey),
          onRefresh: () async {
            widget.isFavourites ? favPage = 0 : page = 0;
            getProjectList(true);
          },
          child: IgnorePointer(
            ignoring: widget.searchFocusNode.hasFocus,
            child: Container(
              color: !widget.searchFocusNode.hasFocus ? AColors.white : AColors.iconGreyColor.withOpacity(0.4),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        separatorBuilder: (BuildContext _, int index) {
                          if ((items[index].isMarkOffline! && items[index].syncStatus == ESyncStatus.inProgress) || (_cubit.selectedProject?.projectID == items[index].id) || (_cubit.selectedProject?.projectID == items[index + 1].id)) {
                            return Container();
                          }
                          return Column(
                            children: [
                              !isProjectMarkOfflineEnable
                                  ? Container(
                                      margin: (orientation == Orientation.landscape && Utility.isTablet)?EdgeInsets.only(left: 60, right: 60):EdgeInsets.only(left: 30, right: 30),
                                      height: 1,
                                      color: AColors.lightGreyColor,
                                    )
                                  : Container(
                                      margin: ((orientation == Orientation.portrait && Utility.isTablet) || (!Utility.isTablet)) ? EdgeInsets.only(left: 70, right: 38) : const EdgeInsets.only(left: 98, right: 98),
                                      height: 1,
                                      color: AColors.lightGreyColor,
                                    ),
                            ],
                          );
                        },
                        controller: paginationScrollController,
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          Popupdata project = items[index];
                          int progress = 0;
                          if (state is ProjectSyncProgressState) {
                            if (state.projectId.compareTo(project.id.plainValue() ?? "") == 0) {
                              project.syncStatus = state.syncStatus;
                              progress = state.progress;
                              if (progress == 100) {
                                project.isMarkOffline = true;
                                _cubit.showSyncProgress(0, project.id.plainValue(), state.syncStatus);
                              }
                            }
                          } else if (project.syncStatus != null && project.syncStatus == ESyncStatus.inProgress) {
                            progress = project.progress != null ? project.progress!.floor() : 0;
                            _cubit.showSyncProgress(progress, project.id.plainValue(), ESyncStatus.inProgress);
                          }
                          return BlocBuilder<ProjectItemCubit, FlowState>(
                            builder: (context, state) {
                              bool isOpen = state is ItemDeleteRequestState
                                  ? state.projectId == project.id
                                      ? true
                                      : false
                                  : false;

                              if (state is ItemDeleteRequestSuccessState) {
                                if (state.projectId == project.id) {
                                  project.isMarkOffline = false;
                                  project.hasLocationMarkOffline = false;
                                }
                              }
                              return Padding(
                                  padding: ((orientation == Orientation.portrait && Utility.isTablet) || (!Utility.isTablet)) ? const EdgeInsets.only(left: 25, right: 25, top: 3) : const EdgeInsets.symmetric(horizontal: 50, vertical: 0),
                                  child: Container(
                                    color: _cubit.selectedProject?.projectID == project.id ? AColors.listItemSelected : Colors.transparent,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Stack(
                                          children: [
                                            Row(
                                              children: [
                                                Visibility(
                                                  visible: isProjectMarkOfflineEnable,
                                                  child: IconButton(
                                                    padding: const EdgeInsets.only(left: 10, right: 5, bottom: 5, top: 5),
                                                    constraints: const BoxConstraints(),
                                                    // Added for remove IconButton widget extra spacing
                                                    icon: !isNetWorkConnected()
                                                        ? Icon(
                                                            project.syncStatus == ESyncStatus.success
                                                                ? Icons.offline_pin
                                                                : (project.hasLocationMarkOffline ?? false)
                                                                    ? (project.hasLocationSyncedSuccessfully ?? false)
                                                                        ? Icons.offline_pin_outlined
                                                                        : Icons.cancel_outlined
                                                                    : Icons.cancel,
                                                            color: project.syncStatus == ESyncStatus.success
                                                                ? AColors.offlineSyncDoneColor
                                                                : (project.hasLocationMarkOffline ?? false)
                                                                    ? (project.hasLocationSyncedSuccessfully ?? false)
                                                                        ? AColors.offlineSyncDoneColor
                                                                        : Colors.red
                                                                    : Colors.red,
                                                          )
                                                        : Icon(
                                                            project.isMarkOffline! && (project.syncStatus != ESyncStatus.inProgress)
                                                                ? project.syncStatus == ESyncStatus.success
                                                                    ? Icons.offline_pin
                                                                    : Icons.cancel
                                                                : (project.hasLocationMarkOffline ?? false) && (project.locationSyncStatus != ESyncStatus.inProgress)
                                                                    ? (project.hasLocationSyncedSuccessfully ?? false)
                                                                        ? Icons.offline_pin_outlined
                                                                        : Icons.cancel_outlined
                                                                    : Icons.cloud_download_outlined,
                                                            color: project.isMarkOffline! && (project.syncStatus != ESyncStatus.inProgress)
                                                                ? project.syncStatus == ESyncStatus.success
                                                                    ? AColors.offlineSyncDoneColor
                                                                    : Colors.red
                                                                : (project.hasLocationMarkOffline ?? false) && (project.locationSyncStatus != ESyncStatus.inProgress)
                                                                    ? (project.hasLocationSyncedSuccessfully ?? false)
                                                                        ? AColors.offlineSyncDoneColor
                                                                        : Colors.red
                                                                    : AColors.iconGreyColor,
                                                          ),
                                                    onPressed: () async {
                                                      _cubit.syncProjectId = project.id;
                                                      await _showDialog(context, project);
                                                    },
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: ListTile(
                                                      key: ValueKey("List Item ${index + 1}"),
                                                      contentPadding: EdgeInsets.only(left: 10, right: 0),
                                                      title: Utility.isTablet
                                                          ? Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              children: [
                                                                Flexible(
                                                                  child: Column(
                                                                    children: [
                                                                      Text(project.value ?? "", maxLines: 1, overflow: TextOverflow.ellipsis),
                                                                    ],
                                                                  ),
                                                                ),
                                                                project.projectSizeInByte!.isNotEmpty ? Visibility(
                                                                  visible: isProjectMarkOfflineEnable,
                                                                    child: showProjectSizeWithProgress(progress, project)) : Container()
                                                              ],
                                                            )
                                                          : Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(project.value ?? "", maxLines: 3, overflow: TextOverflow.ellipsis),
                                                                project.projectSizeInByte!.isNotEmpty ? Visibility(
                                                                  visible: isProjectMarkOfflineEnable,
                                                                    child: showProjectSizeWithProgress(progress, project)) : Container(),
                                                              ],
                                                            ),
                                                      trailing: Wrap(
                                                        spacing: 1,
                                                        children: <Widget>[
                                                          IconButton(
                                                            icon: (project.imgId == 1)
                                                                ? Icon(
                                                                    semanticLabel: "Favorite project",
                                                                    Icons.star,
                                                                    color: Color(0xFFF79120),
                                                                  )
                                                                : Icon(
                                                                    semanticLabel: "Non-favorite project",
                                                                    Icons.star_border,
                                                                    color: Color(0xFFBDBDBD),
                                                                  ),
                                                            onPressed: () async {
                                                              if (isNetWorkConnected()) {
                                                                _cubit.favouriteProject(project, project.imgId == 1 ? -1 : 1, widget.isFavourites);
                                                                FireBaseEventAnalytics.setEvent(FireBaseEventType.favoriteProject, FireBaseFromScreen.projectListing,bIncludeProjectName: true);
                                                              }
                                                            },
                                                          ),
                                                          Visibility(
                                                            visible: isProjectMarkOfflineEnable,
                                                            child: IconButton(
                                                              icon: Icon(color: ((project.isMarkOffline! || (project.hasLocationMarkOffline ?? false)) && project.syncStatus != ESyncStatus.inProgress && project.locationSyncStatus != ESyncStatus.inProgress) ? AColors.iconGreyColor : AColors.btnDisableClr, Icons.delete_outline_sharp),
                                                              onPressed: ((project.isMarkOffline! || (project.hasLocationMarkOffline ?? false)) && project.syncStatus != ESyncStatus.inProgress && project.locationSyncStatus != ESyncStatus.inProgress)
                                                                  ? () {
                                                                      _projectItemCubit.itemDeleteRequest(projectId: project.id!);
                                                                    }
                                                                  : () {},
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      onTap: () async {
                                                        // List<Project> items =
                                                        if (searchString.trim().isNotEmpty) {
                                                          highlightSearch = searchString;
                                                          await _cubit.addRecentProject(newSearch: searchString);
                                                        }
                                                        isOnlineButtonSyncClicked = false;

                                                        ///Passing appTypeId 2 in getAppTypeList for Sites
                                                        getIt<FormTypeUseCase>().getAppTypeList(project.id ?? "", false, "2");
                                                        await _cubit.getProjectDetail(project, widget.isFavourites, fromScreen: FromScreen.listing);
                                                        await _cubit.getWorkspaceSettingData(project.id ?? "0");
                                                        FireBaseEventAnalytics.setEvent(FireBaseEventType.changeProject, FireBaseFromScreen.projectListing, bIncludeProjectName: true);
                                                        StorePreference.removeSelectedPinFilter();
                                                        widget.onBack();
                                                      }),
                                                ),
                                              ],
                                            ),
                                            Positioned(
                                              right: 15,
                                              child: AnimatedOpacity(
                                                opacity: isOpen ? 1.0 : 0.0,
                                                curve: Curves.linear,
                                                duration: const Duration(milliseconds: 500),
                                                child: AnimatedContainer(
                                                  duration: const Duration(milliseconds: 500),
                                                  decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(5), color: AColors.deleteBannerBgGrey),
                                                  alignment: Alignment.centerRight,
                                                  height: 60,
                                                  width: (Utility.isTablet && isOpen) ? (orientation == Orientation.landscape ? deviceWidth / 3 : deviceWidth / 2.2) : ((!Utility.isTablet && isOpen) ? deviceWidth - 60 : 0.0),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.max,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Flexible(
                                                        flex: 5,
                                                        fit: FlexFit.tight,
                                                        child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          mainAxisSize: MainAxisSize.max,
                                                          children: [
                                                            Flexible(
                                                              flex: 1,
                                                              child: Container(
                                                                width: 5.0,
                                                                height: 50.0,
                                                                decoration: BoxDecoration(
                                                                  shape: BoxShape.rectangle,
                                                                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(0), bottomLeft: Radius.circular(0)),
                                                                  color: AColors.userOnlineColor,
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 5,
                                                              child: Container(
                                                                padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Flexible(
                                                                      child: BlocBuilder<ProjectItemCubit, FlowState>(builder: (context, state) {
                                                                        if (state is ItemDeleteRequestState) {
                                                                          if (state.isProcessing == true) {
                                                                            return Text(context.toLocale!.lbl_removing_records, style: TextStyle(color: AColors.textColor, fontSize: 16, fontWeight: AFontWight.semiBold), textAlign: TextAlign.left);
                                                                          }
                                                                        }
                                                                        return Text(context.toLocale!.lbl_remove_records, style: TextStyle(color: AColors.textColor, fontSize: 16, fontWeight: AFontWight.semiBold), textAlign: TextAlign.left);
                                                                      }),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Flexible(
                                                        flex: 1,
                                                        child: Visibility(
                                                          visible: isOpen,
                                                          child: IconButton(
                                                            onPressed: () {
                                                              _projectItemCubit.itemDeleteRequestCancel(projectId: project.id!);
                                                            },
                                                            icon: const Icon(
                                                              Icons.close,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Flexible(
                                                        flex: 0,
                                                        child: Visibility(
                                                          visible: isOpen,
                                                          child: IconButton(
                                                            onPressed: () {
                                                              project.isMarkOffline = false;
                                                              progress = 0;
                                                              project.projectSizeInByte = "";
                                                              _projectItemCubit.itemDeleteRequestSuccess(projectId: project.id!);
                                                            },
                                                            color: AColors.userOnlineColor,
                                                            icon: const Icon(
                                                              Icons.delete_outline_sharp,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        (project.syncStatus == ESyncStatus.inProgress) && (progress < 100) /*&& (progress != 100 && progress != 0 && !project.isMarkOffline!)*/
                                            ? Visibility(
                                                visible: isProjectMarkOfflineEnable,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 48, right: 32),
                                                  child: Column(
                                                    children: [
                                                      LinearProgressIndicator(value: progress / 100, backgroundColor: _cubit.selectedProject?.projectID == project.id ? AColors.white : AColors.offlineSyncProgressBarColor, color: AColors.offlineSyncProgressColor),
                                                      const SizedBox(height: 8),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                      ],
                                    ),
                                  ));
                            },
                          );
                        }),
                  ),
                  Visibility(
                    visible: (widget.isFavourites) ? isFavLoading == true : isLoading == true,
                    child: const ACircularProgress(),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _emptyProject(bool isFav) {
    return SizedBox(
      height: 450,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Image.asset(AImageConstants.emptyProject),
          ),
          const SizedBox(
            height: 16,
          ),
          Flexible(
            child: NormalTextWidget(
              (isFav && favItems.isEmpty) ? context.toLocale?.lbl_empty_fav_project ?? "" : context.toLocale?.all_no_project_allocated ?? "",
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontSize: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _onEmpty(bool isFav) {
    if (searchString.isEmpty || _cubit.getSearchMode == SearchMode.other) {
      return Center(child: _emptyProject(isFav));
    } else {
      return Center(
        child: isFav ? Text(NavigationUtils.mainNavigationKey.currentContext?.toLocale?.no_matches_found ?? "") : Text(NavigationUtils.mainNavigationKey.currentContext?.toLocale?.no_matches_found ?? ""),
      );
    }
  }

  Widget searchOnProjectList(Orientation orientation, FlowState state) {
    return Padding(
      padding: ((orientation == Orientation.portrait && Utility.isTablet) || (!Utility.isTablet)) ? const EdgeInsets.symmetric(horizontal: 20.0) : const EdgeInsets.symmetric(horizontal: 50.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: CustomSearchSuggestionView<Popupdata>(
              key: const Key("searchBoxProjectList"),
              placeholder: context.toLocale!.search_projects,
              hideSuggestionsOnKeyboardHide: true,
              textFieldConfiguration: SearchTextFormFieldConfiguration(
                controller: widget.searchProjectController,
                focusNode: widget.searchFocusNode,
                textInputAction: TextInputAction.search,
                suffixIconOnClick: () {
                  _clearButtonOnTap();
                },
                onSubmitted: (value) async {
                  if (value.trim().isNotEmpty) {
                    (widget.isFavourites) ? favPage = 0 : page = 0;
                    highlightSearch = searchString;
                    await _cubit.addRecentProject(newSearch: searchString);
                    _cubit.pageFetch((widget.isFavourites) ? favPage : page, widget.isFavourites, false, value, widget.isFavourites ? isFavAscending : isAllAscending);
                  } else {
                    searchString = '';
                    widget.searchProjectController.text = searchString;
                    context.closeKeyboard();
                    getProjectList(false);
                  }
                },
                onTap: () {
                  FireBaseEventAnalytics.setEvent(FireBaseEventType.searchText, FireBaseFromScreen.projectListing, bIncludeProjectName: true);
                },
              ),
              suggestionsCallback: (value) async {
                searchString = value.trim();
                if (!widget.searchFocusNode.hasFocus) {
                  return [];
                } else {
                  if (value.isEmpty && !widget.searchFocusNode.hasFocus) {
                    return await _cubit.getRecentProject();
                  } else {
                    highlightSearch = searchString;
                    if (value.trim().length >= 3) {
                      _cubit.setSearchMode = SearchMode.suggested;
                      // return await _cubit.pageFetch(0, widget.isFavourites, false, searchString);
                      return await _cubit.getSuggestedSearchList(0, widget.isFavourites, false, searchString);
                    } else if (value.trim().length <= 2) {
                      _cubit.setSearchMode = SearchMode.recent;
                      return _cubit.getRecentProject();
                    } else {
                      return [];
                    }
                  }
                }
              },
              currentSearchHeader: BlocBuilder<ProjectListCubit, FlowState>(builder: (context, state) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: NormalTextWidget(
                    _cubit.getSearchMode == SearchMode.recent ? context.toLocale!.text_recent_searches : context.toLocale!.text_suggested_searches,
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
                        child: _cubit.getSearchMode == SearchMode.suggested
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: DefaultTextStyle.of(context).style,
                                        children: Utility.getTextSpans(suggestion.value!, highlightSearch),
                                      ),
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
                                          child: RichText(
                                            text: TextSpan(
                                              style: DefaultTextStyle.of(context).style,
                                              children: Utility.getTextSpans(suggestion.value!, highlightSearch),
                                            ),
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
                searchString = suggestion.value!.trim();
                widget.searchProjectController.text = searchString;
                if (searchString.isNotEmpty) {
                  highlightSearch = searchString;
                  await _cubit.addRecentProject(newSearch: searchString);
                }
                widget.isFavourites ? favPage = 0 : page = 0;
                await _cubit.pageFetch((widget.isFavourites) ? favPage : page, widget.isFavourites, false, suggestion.value!, widget.isFavourites ? isFavAscending : isAllAscending);
              },
            ),
          ),
          Column(
            children: [
              const SizedBox(
                height: 0,
                width: 20,
              ),
              TextButton.icon(
                onPressed: (state is! EnableSorting)
                    ? null
                    : () async {
                  FireBaseEventAnalytics.setEvent(
                      FireBaseEventType.sort,
                      FireBaseFromScreen.projectListing,
                      bIncludeProjectName: true);
                        if (widget.isFavourites) {
                          isFavAscending = !isFavAscending;
                          favPage = 0;
                        } else {
                          isAllAscending = !isAllAscending;
                          page = 0;
                        }
                        await getProjectList(false);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (paginationScrollController.hasClients) {
                            paginationScrollController.jumpTo(
                              paginationScrollController.position.minScrollExtent,
                            );
                          }
                        });
                      },
                icon: Row(
                  children: [
                     Text(
                      context.toLocale!.name,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    Icon(
                      (widget.isFavourites ? isFavAscending : isAllAscending) ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                      size: 20,
                      key: ValueKey("Sorting Icon"),
                    ),
                  ],
                ),
                label: const Text(
                  '', //'Label',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget showProjectSizeWithProgress(int progress, Popupdata project) {
    return project.syncStatus == ESyncStatus.inProgress
        ? NormalTextWidget(
            "$progress% of  ${Utility.getFileSizeWithMetaData(bytes: int.parse(project.projectSizeInByte!))}",
            fontSize: 13,
            fontWeight: AFontWight.regular,
            color: AColors.grColorDark,
          )
        : NormalTextWidget(
            Utility.getFileSizeWithMetaData(bytes: int.parse(project.projectSizeInByte!)),
            fontSize: 13,
            fontWeight: AFontWight.regular,
            color: AColors.grColorDark,
          );
  }

  _showDialog(BuildContext context, Popupdata project) async {
    bool isProjectMarkedOffline = await _cubit.isProjectMarkedOffline();
    if (_syncCubit.syncRequestList.isEmpty && !isProjectMarkedOffline) {
      await showDialog(
          context: this.context,
          builder: (context) {
            return Dialog(
              insetPadding: EdgeInsets.zero,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: ProjectDownloadSizeWidget(strProjectId: project.id ?? "", locationId: ["-1"]),
            );
          }).then((value) async {
        if (value != null && value is int) {
          project.projectSizeInByte = value!.toString();
          bool includeAttachments = await StorePreference.isIncludeAttachmentsSyncEnabled();
          SiteSyncRequestTask syncRequestTask = SiteSyncRequestTask()
            ..syncRequestId = DateTime.now().millisecondsSinceEpoch
            ..projectId = project.id
            ..projectName = project.value
            ..isMarkOffline = true
            ..isMediaSyncEnable = includeAttachments
            ..eSyncType = ESyncType.project
            ..projectSizeInByte = project.projectSizeInByte;

          _syncCubit.syncProjectData({"buildFlavor": AConstants.buildFlavor!, "tab": AConstants.siteTab, "syncRequest": jsonEncode(syncRequestTask)});
          project.isMarkOffline = true;
          // projectDownloadSize = await _cubit.getSyncProjectSize(projectId: project.id!);
        } else {
          _cubit.deleteProjectSyncSize(project.id!);
        }
      });
    } else if (!project.isMarkOffline!) {
      showDialog(
          context: this.context,
          builder: (context) {
            return const Dialog(
              insetPadding: EdgeInsets.zero,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: ProjectAlreadyMarkOffline(),
            );
          });
    }
  }

  void _clearButtonOnTap() {
    searchString = searchString.trim();
    if (searchString.isEmpty) {
      widget.searchFocusNode.unfocus();
      getProjectList(false);
    } else {
      widget.searchProjectController.clear();
      searchString = '';
      highlightSearch = '';
      widget.searchFocusNode.unfocus();
      FocusScopeNode currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.focusedChild?.unfocus();
      }
    }
  }

  Widget getProjectListWidget(FlowState state) {
    bool isFav = widget.isFavourites ? true : false;
    if (state is FavProjectLoadingState || state is AllProjectLoadingState) {
      return Expanded(
        child: ((isFav ? favItems : allItems).isNotEmpty)
            ? projectListBuilder((isFav ? favItems : allItems), state)
            : !isFirstTimeLoading || widget.searchProjectController.text.isNotEmpty
                ? _onEmpty(isFav ? true : false)
                : Container(),
      );
    } else if (state is AllProjectSuccessState || state is FavProjectSuccessState || state is ProjectSyncProgressState) {
      return Expanded(
        child: projectListBuilder((isFav ? favItems : allItems), state),
      );
    } else if (state is AllProjectNotAllocatedState || state is FavProjectNotAllocatedState) {
      return Expanded(child: Center(child: _emptyProject(isFav)));
    } else {
      return Expanded(
        child: Center(
          child: isFav ? Text(context.toLocale?.no_matches_found ?? "") : Text(context.toLocale?.no_matches_found ?? ""),
        ),
      );
    }
  }
}
