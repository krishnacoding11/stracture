import 'dart:convert';
import 'package:field/bloc/site/plan_cubit.dart';
import 'package:field/bloc/task_listing/task_listing_cubit.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/file_form_utility.dart';
import 'package:field/utils/task_utils.dart';
import 'package:field/utils/url_helper.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/border_card_widget.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/event_analytics.dart';
import '../../../bloc/sitetask/sitetask_state.dart';
import '../../../bloc/sitetask/unique_value_cubit.dart';
import '../../../enums.dart';
import '../../../injection_container.dart';
import '../../../logger/logger.dart';
import '../../../widgets/pagination_view/pagination_view.dart';
import '../../../widgets/progressbar.dart';
import '../../../widgets/tooltip_dialog/tooltip_dialog.dart';
import '../site_routes/site_end_drawer/filter/site_end_drawer_filter.dart';
import '../site_routes/site_end_drawer/search_task.dart';

class TaskListingScreen extends StatefulWidget {
  final Object? arguments;

  const TaskListingScreen({this.arguments, Key? key}) : super(key: key);

  @override
  State<TaskListingScreen> createState() => _TaskListingScreenState();
}

class _TaskListingScreenState extends State<TaskListingScreen> {
  final GlobalKey<ScaffoldState> _taskListingScaffoldKey = GlobalKey<ScaffoldState>();
  late TaskListingCubit taskListingCubit;
  late UniqueValueCubit _uniqueValueCubit;
  late final ScrollController paginationScrollController;
  late final ScrollController animatedScrollController;
  late ScrollController scrollController;
  final TooltipController _tooltipController = TooltipController();

  @override
  void initState() {
    scrollController = ScrollController();
    taskListingCubit = getIt<TaskListingCubit>();
    _uniqueValueCubit = getIt<UniqueValueCubit>();
    animatedScrollController = getIt<ScrollController>();
    paginationScrollController = ScrollController();
    _scrollingAnimation();
    super.initState();
    taskListingCubit.loadTaskListingData(widget.arguments);
    FireBaseEventAnalytics.setCurrentScreen(FireBaseFromScreen.taskList.value);
  }

  _scrollingAnimation() {
    paginationScrollController.addListener(() {
      _animationController();
    });
    scrollController.addListener(() {
      _filterAnimationController();
    });
  }

  _animationController() {
    if (!Utility.isTablet) {
      if (paginationScrollController.position.userScrollDirection == ScrollDirection.reverse) {
        _reverseAnimation();
      }
    }
    if (paginationScrollController.position.userScrollDirection == ScrollDirection.forward) {
      _forwardAnimation();
    }
  }

  _filterAnimationController() {
    if (!Utility.isTablet) {
      if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        _reverseAnimation();
      }
    }
    if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
      _forwardAnimation();
    }
  }

  _reverseAnimation() {
    if (animatedScrollController.hasClients) {
      animatedScrollController.animateTo(
        animatedScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.linear,
      );
    }
  }

  _forwardAnimation() {
    if (animatedScrollController.hasClients) {
      animatedScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.linear,
      );
    }
  }

  @override
  void dispose() {
    paginationScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Utility.isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    return BlocProvider(
      create: (_) => taskListingCubit,
      child: BlocListener<TaskListingCubit, FlowState>(
        listenWhen: (previous, current) => current is ScrollState || current is ApplyFilterState,
        listener: (context, state) {
          if (state is ScrollState && state.position != null && state.position! > 0) {
            if (paginationScrollController.hasClients) {
              paginationScrollController.jumpTo(state.position!);
            }
            taskListingCubit.scrollPosition = 0;
          }
        },
        child: Scaffold(
          key: _taskListingScaffoldKey,
          resizeToAvoidBottomInset: false,
          onEndDrawerChanged: (_) {
            _forwardAnimation();
          },
          body: Container(
              color: AColors.white,
              child: Padding(
                  padding: (Utility.isTablet && (MediaQuery.of(context).orientation) == Orientation.landscape)
                      ? const EdgeInsets.only(
                          left: 70.0,
                          right: 70.0,
                        )
                      : const EdgeInsets.all(18),
                  /*child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  searchAndFilterWidget(),
                  Expanded(child: _taskListWidget(context)),
                ],
              ),*/
                  child: _taskListWidget(context))),
          endDrawer: _taskFilterWidget(),
          endDrawerEnableOpenDragGesture: false,
        ),
      ),
    );
  }

  Widget searchBarWidget(bool isTablet) {
    return isTablet
        ? searchTaskWidget()
        : IconButton(
            padding: const EdgeInsetsDirectional.only(start: 16.0, top: 8.0, bottom: 8.0),
            constraints: const BoxConstraints(),
            color: AColors.iconGreyColor,
            onPressed: () => taskListingCubit.updateSearchBarVisibleState(true),
            icon: const Icon(Icons.search),
          );
  }

  Widget searchAndFilterWidget(key) {
    return BlocBuilder<TaskListingCubit, FlowState>(
        buildWhen: (previous, current) => current is SearchBarVisibleState,
        builder: (context, state) {
          return state is SearchBarVisibleState && state.isExpand
              ? Row(mainAxisAlignment: MainAxisAlignment.end, mainAxisSize: MainAxisSize.max, children: [searchTaskWidget()])
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: [(Utility.isTablet) ? searchBarWidget(Utility.isTablet) : const SizedBox.shrink(), sortFilterWidget(), (!Utility.isTablet) ? searchBarWidget(Utility.isTablet) : const SizedBox.shrink(), filterWidget(key)],
                );
        });
  }

  Widget filterWidget(key) {
    return BlocBuilder<TaskListingCubit, FlowState>(
        buildWhen: (prev, current) => current is ApplyFilterState,
        builder: (context, state) {
          bool currentApplyFilter = false;
          if (state is ApplyFilterState && state.isFilterApply) {
            currentApplyFilter = true;
          }
          return IconButton(
            padding: const EdgeInsetsDirectional.only(start: 16.0, top: 8.0, bottom: 8.0),
            constraints: const BoxConstraints(),
            color: currentApplyFilter ? AColors.themeBlueColor : AColors.iconGreyColor,
            onPressed: () {
              onFilterButtonClick();
              FireBaseEventAnalytics.setEvent(FireBaseEventType.taskListingFilterSave, FireBaseFromScreen.taskList, bIncludeProjectName: true);
            },
            icon: currentApplyFilter ? const Icon(Icons.filter_alt) : const Icon(Icons.filter_alt_outlined),
          );
        });
  }

  Widget sortFilterWidget() {
    return BlocBuilder<TaskListingCubit, FlowState>(
        buildWhen: (previous, current) => current is SortChangeState,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.only(start: 8.0, end: 8.0),
                child: TooltipDialog(
                  toolTipContent: Container(
                    constraints: const BoxConstraints(minWidth: 100, maxWidth: 140, minHeight: 150, maxHeight: 170),
                    child: Column(
                      children: <Widget>[
                        _getTile(ListSortField.creationDate),
                        const Divider(height: 1.0),
                        _getTile(ListSortField.due_date),
                        const Divider(height: 1.0),
                        _getTile(ListSortField.siteTitle),
                      ],
                    ),
                  ),
                  toolTipController: _tooltipController,
                  child: InkWell(
                    onTap: () {
                      _tooltipController.showTooltipDialog();
                    },
                    child: NormalTextWidget(
                      getSortFieldName(taskListingCubit.sortValue),
                      fontSize: 16,
                      fontWeight: AFontWight.medium,
                      color: AColors.iconGreyColor,
                      key: const Key("key_taskListing_sort_field_widget"),
                    ),
                  ),
                ),
              ),
              IconButton(
                key: const Key("key_taskListing_sort_order_widget"),
                icon: Icon(
                  (taskListingCubit.sortOrder) ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  color: AColors.iconGreyColor,
                ),
                onPressed: () {
                  taskListingCubit.setSortOrder = !taskListingCubit.sortOrder;
                  _uniqueValueCubit.updateValue();
                  FireBaseEventAnalytics.setEvent(FireBaseEventType.sort, FireBaseFromScreen.taskList, bIncludeProjectName: true);
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          );
        });
  }

  Widget searchTaskWidget() {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(3.0, 8.0, Utility.isTablet ? 8.0 : 3.0, 8.0),
          child: SearchTask(
              fromScreen: FireBaseFromScreen.taskList,
              borderWidth: Utility.isTablet ? 1.0 : 1.5,
              isShowClearButtonOnCleared: !Utility.isTablet ? true : null,
              initialValue: taskListingCubit.getSearchSummaryFilterValue(),
              setInitialOptionsValue: (List<String> options) async {
                options.addAll(await taskListingCubit.getRecentSearchedTaskList());
              },
              onRecentSearchListUpdated: (List<String> options) async {
                await taskListingCubit.saveRecentSearchTaskList(options);
              },
              onSearchChanged: (searchValue, isFromCloseButton) {
                if (!Utility.isTablet && searchValue.toString().isNullOrEmpty()) {
                  taskListingCubit.updateSearchBarVisibleState(!isFromCloseButton);
                }
                if (taskListingCubit.getSearchSummaryFilterValue() != searchValue) {
                  taskListingCubit.setSearchSummaryFilterValue(searchValue);
                  _uniqueValueCubit.updateValue();
                  FireBaseEventAnalytics.setEvent(FireBaseEventType.locationTreeSearch, FireBaseFromScreen.taskList, bIncludeProjectName: true);
                }
              }),
        ),
      ),
    );
  }

  Widget _getTile(ListSortField data) {
    return ListTile(
        title: NormalTextWidget(
          getSortFieldName(data),
          fontWeight: AFontWight.regular,
          fontSize: 16.0,
          textAlign: TextAlign.left,
        ),
        onTap: () {
          _tooltipController.hideTooltipDialog();
          taskListingCubit.setSortValue = data;
          _uniqueValueCubit.updateValue();
        });
  }

  String getSortFieldName(ListSortField item) {
    switch (item) {
      case ListSortField.due_date:
        return context.toLocale!.placeholder_task_due_date;
      case ListSortField.siteTitle:
        return context.toLocale!.placeholder_task_title;
      case ListSortField.creationDate:
        return context.toLocale!.placeholder_task_creation_date;
      default:
        return context.toLocale!.placeholder_task_creation_date;
    }
  }

  _taskListWidget(BuildContext context) {
    return BlocBuilder<TaskListingCubit, FlowState>(builder: (_, state) {
      if (state is LoadingState || state is InitialState) {
        return const Center(
          child: ACircularProgress(
            key: Key("key_task_listing_progressbar"),
          ),
        );
      } else if (state is NoProjectSelectedState) {
        return Center(
            child: NormalTextWidget(
          context.toLocale!.lbl_no_project_data,
          key: const Key("key_no_project_selected"),
        ));
      } else {
        return BlocProvider(
          create: (context) => _uniqueValueCubit,
          child: BlocBuilder<UniqueValueCubit, String>(builder: (context, state) {
            return Column(
              children: [
                if (Utility.isTablet)
                  const SizedBox(
                    height: 20,
                  ),
                searchAndFilterWidget(Key(state)),
                Expanded(
                  child: PaginationView<SiteForm>(
                    key: Key(state),
                    shrinkWrap: true,
                    scrollController: paginationScrollController,
                    itemBuilder: (_, item, index) => _taskListRowItemWidget(context, index, item),
                    pageFetch: _pageFetch,
                    pullToRefresh: true,
                    onError: (dynamic error) => Center(
                      child: NormalTextWidget(
                        context.toLocale!.error_message_something_wrong,
                        key: const Key("key_listview_error_widget"),
                      ),
                    ),
                    onEmpty: Center(
                      child: NormalTextWidget(
                        !taskListingCubit.getSearchSummaryFilterValue().isNullOrEmpty() ? context.toLocale!.no_results : context.toLocale!.no_data_available,
                        key: const Key("key_listview_empty_widget"),
                      ),
                    ),
                    bottomLoader: const Center(
                      child: ACircularProgress(
                        key: Key("key_listview_bottomLoader_widget"),
                      ),
                    ),
                    initialLoader: const Center(
                      child: ACircularProgress(
                        key: Key("key_listview_initialLoader_widget"),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      }
    });
  }

  Future<List<SiteForm>> _pageFetch(int offset) async {
    var items = await taskListingCubit.getNewTaskList(offset);
    return items;
  }

  _taskListRowItemWidget(BuildContext context, int index, SiteForm item) {
    Color iconColor = (item.statusRecordStyle != null) ?
    item.statusRecordStyle['backgroundColor'] != null ?
    (item.statusRecordStyle['backgroundColor'] as String).toColor() : AColors.iconGreyColor : AColors.iconGreyColor;
    return BlocBuilder<TaskListingCubit, FlowState>(
      buildWhen: (previous, current) => current is RefreshPaginationItemState,
      builder: (context, state) {
        Log.i("Scale: ${Utility.getFontScale(context)}");
        return Column(
          children: [
            SizedBox(
              height: (Utility.getFontScale(context) < 1.2)
                  ? (Utility.isTablet)
                      ? 65
                      : 130
                  : (Utility.isTablet)
                      ? 75
                      : 140,
              child: InkWell(
                onTap: () async {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                    FireBaseEventAnalytics.setEvent(FireBaseEventType.taskListingSelect, FireBaseFromScreen.taskList, bIncludeProjectName: true);
                  }
                  final data = {"projectId": item.projectId, "locationId": item.locationId.toString(), "isFrom": FromScreen.task};

                  String formViewUrl = await UrlHelper.getORIFormURLByAction(item);
                  dynamic result = await FileFormUtility.showFormActionViewDialog(context, frmViewUrl: formViewUrl, data: data, color: iconColor);

                  bool isFormUpdate = false;
                  if (result != null && result is Map) {
                    Map<String, dynamic> dict = json.decode(json.encode(result)) as Map<String, dynamic>;
                    if (dict.isNotEmpty) {
                      isFormUpdate = true;
                    }
                    if (TaskUtils.getMyTaskAction(item.actions)?.actionId.plainValue() == '7') {
                      isFormUpdate = true;
                    }
                  }
                  if (isFormUpdate == true) {
                    taskListingCubit.scrollPosition = paginationScrollController.position.pixels;
                    _uniqueValueCubit.updateValue();
                  }
                },
                child: ABorderCardWidget(
                  border: BorderDirectional(start: BorderSide(color: iconColor, width: 5)),
                  cardColor: (index % 2 != 0) ? Colors.white : AColors.taskListGreyColor,
                  child: _taskRowWidget(item),
                ),
              ),
            ),
            SizedBox(
              height: taskListingCubit.totalCount <= 6 && taskListingCubit.totalCount >= 2 && taskListingCubit.totalCount - 1 == index ? (5 - index) * 130 : 0,
            )
          ],
        );
      },
    );
  }

  _taskRowWidget(SiteForm item) {
    String frmCode = item.code ?? "---";
    String frmTitle = item.title ?? "---";
    String frmStatus = item.statusText ?? "---";
    String frmIconName = FileFormUtility.getFormIconName(item);
    Color frmStatusColor = FileFormUtility.getStatusColor(item);
    String frmCreatedDate = FileFormUtility.getCreatedDate(item);
    String frmDueDate = FileFormUtility.getDueDate(item);
    String frmStatusUpdateDate = FileFormUtility.getStatusUpdateDate(item);
    String locationPath = FileFormUtility.getLocationPath(item, pathSeparator: " > ");
    String strMyTasks = TaskUtils.getMyTaskName(TaskUtils.getMyTaskAction(item.actions));
    if (Utility.isTablet) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ImageIcon(
                    size: 28,
                    color: frmStatusColor,
                    AssetImage(
                      frmIconName,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 4.0),
                    child: NormalTextWidget(
                      frmCode,
                      fontWeight: AFontWight.semiBold,
                      fontSize: 16.0,
                      color: AColors.iconGreyColor,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _showTextWithDescription(context.toLocale!.lbl_tasks_title, frmTitle),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: _showTextWithDescription(context.toLocale!.lbl_tasks_myTask, strMyTasks),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 35,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: _showTextWithDescription(context.toLocale!.lbl_task_created_date, frmCreatedDate)),
                      Expanded(child: item.isCloseOut == true ? _showTextWithDescription("${context.toLocale!.lbl_task_completed}:", frmStatusUpdateDate, isTitleFlexible: true) : _showTextWithDescription(context.toLocale!.lbl_task_due_date, frmDueDate, isTitleFlexible: false)),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: _showTextWithDescription(context.toLocale!.lbl_tasks_location, locationPath),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 8.0,
            ),
            Container(
              child: _showTextWithDescription(context.toLocale!.lbl_task_status, frmStatus),
            ),
          ],
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsetsDirectional.only(start: 14.0, top: 5.0, end: 10.0, bottom: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ImageIcon(
                          size: 28,
                          color: frmStatusColor,
                          AssetImage(
                            frmIconName,
                          ),
                        ),
                        const SizedBox(
                          width: 10.0,
                        ),
                        Flexible(
                          child: NormalTextWidget(
                            frmCode,
                            fontWeight: AFontWight.semiBold,
                            fontSize: 16.0,
                            color: AColors.iconGreyColor,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.start,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: NormalTextWidget(
                      frmStatus,
                      fontWeight: AFontWight.regular,
                      fontSize: 13.0,
                      color: AColors.iconGreyColor,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: SizedBox(height: 17, child: _showTextWithDescription(context.toLocale!.lbl_tasks_title, frmTitle))),
                    const SizedBox(
                      height: 4.0,
                    ),
                    Expanded(
                      child: item.isCloseOut == true ? _showTextWithDescription("${context.toLocale!.lbl_task_completed}:", frmStatusUpdateDate) : _showTextWithDescription(context.toLocale!.lbl_task_due_date, frmDueDate),
                    ),
                    const SizedBox(
                      height: 4.0,
                    ),
                    Expanded(child: SizedBox(height: 17, child: _showTextWithDescription(context.toLocale!.lbl_tasks_location, locationPath))),
                    const SizedBox(
                      height: 4.0,
                    ),
                    Expanded(
                      child: _showTextWithDescription(context.toLocale!.lbl_tasks_myTask, strMyTasks),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  _showTextWithDescription(String txtTitle, String txtValue, {bool isTitleFlexible = false}) {
    bool isTablet = Utility.isTablet;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isTitleFlexible
            ? Flexible(
                child: NormalTextWidget(
                  txtTitle,
                  fontWeight: (isTablet) ? AFontWight.medium : AFontWight.regular,
                  fontSize: 15.0,
                  color: AColors.iconGreyColor,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              )
            : Flexible(
                child: NormalTextWidget(
                  txtTitle,
                  fontWeight: (isTablet) ? AFontWight.medium : AFontWight.regular,
                  fontSize: 15.0,
                  color: AColors.iconGreyColor,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
        Flexible(
          child: Padding(
            padding: const EdgeInsetsDirectional.only(start: 3.0),
            child: NormalTextWidget(
              txtValue,
              fontWeight: (isTablet) ? AFontWight.medium : AFontWight.regular,
              fontSize: 15.0,
              maxLines: 1,
              color: AColors.textColor,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  _taskFilterWidget() {
    double screenWidth = (MediaQuery.of(context).size.width);
    if (Utility.isTablet) {
      Orientation screenOrientation = (MediaQuery.of(context).orientation);
      screenWidth = screenWidth / ((screenOrientation == Orientation.landscape) ? 3 : 2);
    }
    return BlocProvider(
      create: (context) => PlanCubit(),
      child: Drawer(
        width: screenWidth,
        backgroundColor: AColors.filterBgColor,
        child: SiteEndDrawerFilter(
          animationScrollController: scrollController,
          curScreen: FilterScreen.screenTask,
          onClose: () {
            _forwardAnimation();
            _taskListingScaffoldKey.currentState?.closeEndDrawer();
          },
          onApply: (value) async {
            if (kDebugMode) {
              print(value);
            }
            _forwardAnimation();
            _taskListingScaffoldKey.currentState?.closeEndDrawer();
            _uniqueValueCubit.updateValue();
          },
        ),
      ),
    );
  }

  onFilterButtonClick() {
    //_getFilterWidget();
    _taskListingScaffoldKey.currentState?.openEndDrawer();
    _forwardAnimation();
  }
}
