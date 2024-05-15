import 'package:field/analytics/event_analytics.dart';
import 'package:field/bloc/dashboard/home_page_state.dart';
import 'package:field/data/model/home_page_model.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/screen/homepage/add_more_to_home_screen.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';

import '../../../bloc/QR/navigator_cubit.dart';
import '../../../bloc/dashboard/home_page_cubit.dart';
import '../../../bloc/navigation/navigation_cubit.dart';
import '../../../bloc/site/create_form_selection_cubit.dart';
import '../../../bloc/task_action_count/task_action_count_cubit.dart';
import '../../../bloc/toolbar/toolbar_cubit.dart';
import '../../../data/model/project_vo.dart';
import '../../../data/model/qrcodedata_vo.dart';
import '../../../enums.dart';
import '../../../injection_container.dart';
import '../../../logger/logger.dart';
import '../../../networking/network_info.dart';
import '../../../utils/store_preference.dart';
import '../../../utils/utils.dart';
import '../../../widgets/normaltext.dart';
import '../../managers/color_manager.dart';
import '../../managers/font_manager.dart';
import 'home_page_empty_view.dart';
import 'home_page_item_widget.dart';
import 'home_page_no_project_view.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  List<DraggableGridItem> _listOfDraggableGridItem = [];
  bool isOnline = true;
  late HomePageCubit homePageCubit;
  AProgressDialog? addProgressDialog;
  double cellItemHeight = 0.0;
  double cellItemWidth = 0.0;

  double draggableGridViewMaxWidth = 0;
  double draggableGridViewMaxHeight = 0;
  Orientation? currentOrientation;

  final ScrollController _scrollController = ScrollController(
    initialScrollOffset: 0.0,
    keepScrollOffset: true,
  );

  final PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    homePageCubit = context.read<HomePageCubit>();
    initHomePageData();
  }

  @override
  void didUpdateWidget(covariant HomePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    Future.delayed(Duration.zero, () async {
      if (await homePageCubit.isNeedToRefresh()) {
        initHomePageData();
      }
    });
  }

  initHomePageData() async {
    draggableGridViewMaxWidth = 0;
    draggableGridViewMaxHeight = 0;
    await homePageCubit.initData();
  }

  @override
  Widget build(BuildContext context) {
    isOnline = isNetWorkConnected();
    if (!Utility.isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    return WillPopScope(
        onWillPop: () async {
          return homePageCubit.isBackFromEditMode();
        },
        child: BlocConsumer<HomePageCubit, FlowState>(
            listenWhen: (prev, current) {
              return current is PendingShortcutItemState || current is HomePageEditErrorState || current is ReachedConfigureLimitState || current is AddMoreErrorState || current is UpdateShortcutListProgressState;
            },
            listener: (_, state) {
              dismissAddProgressDialog();
              if (state is UpdateShortcutListProgressState && state.isShow) {
                showAddProgressDialog();
              } else if (state is PendingShortcutItemState) {
                getAddMoreDialog(context, state);
              } else if (state is ReachedConfigureLimitState) {
                Utility.showAlertWithOk(context, context.toLocale!.lbl_maximum_shortcut_configuration_limit_reached);
              } else if (state is AddMoreErrorState) {
                context.showSnack(context.toLocale!.something_went_wrong);
              } else if (state is HomePageEditErrorState) {
                context.showSnack(context.toLocale!.lbl_homepage_update_error);
              }
            },
            buildWhen: (previous, current) => current is HomePageNoProjectSelectState || current is HomePageEmptyState || current is HomePageItemState || current is ErrorState || (current is HomePageItemLoadingState && current.stateRendererType == StateRendererType.FULL_SCREEN_LOADING_STATE),
            builder: (_, state) {
              return Container(
                child: Padding(
                  padding: Utility.isTablet
                      ? const EdgeInsetsDirectional.only(
                          start: 32,
                          end: 42,
                        )
                      : const EdgeInsetsDirectional.only(start: 8, end: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 5, bottom: 0, start: 5, end: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: NormalTextWidget(
                                key: Key('home_text_widget_key'),
                                context.toLocale!.home,
                                fontSize: (Utility.isTablet) ? 20 : 15,
                                fontWeight: AFontWight.medium,
                                color: Colors.black,
                              ),
                            ),
                            if (state is! HomePageNoProjectSelectState)
                              homePageCubit.isEditEnable
                                  ? Row(
                                      children: [
                                        BlocBuilder<HomePageCubit, FlowState>(
                                            buildWhen: (previous, current) => current is AddPendingProgressState,
                                            builder: (_, state) {
                                              if (state is AddPendingProgressState && state.isShow) {
                                                return Center(
                                                    key: const Key("AddPendingProgressStateKey"),
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                                      child: SizedBox(
                                                        height: 24,
                                                        width: 24,
                                                        child: ACircularProgress(),
                                                      ),
                                                    ));
                                              } else {
                                                return MaterialButton(
                                                  key: Key("PendingItemAddButton"),
                                                  color: AColors.themeBlueColor,
                                                  onPressed: () {
                                                    showAddProgressDialog();
                                                    homePageCubit.checkMaxHomePageShortcutConfigLimit();
                                                  },
                                                  height: 36,
                                                  minWidth: 36,
                                                  shape: const CircleBorder(),
                                                  child: Icon(
                                                    Icons.add,
                                                    size: 20,
                                                    color: Colors.white,
                                                  ),
                                                );
                                              }
                                            }),
                                        BlocBuilder<HomePageCubit, FlowState>(builder: (_, state) {
                                          if (state is UpdateShortcutListProgressState && state.isShow) {
                                            return Center(
                                                child: Padding(
                                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                                              child: SizedBox(
                                                height: 24,
                                                width: 24,
                                                child: ACircularProgress(),
                                              ),
                                            ));
                                          } else {
                                            return TextButton(
                                              key: Key("OnPressDoneButton"),
                                              onPressed: () {
                                                if (state is UpdateShortcutListProgressState && state.isShow) {
                                                  showAddProgressDialog();
                                                }
                                                homePageCubit.onChangeEditMode();
                                                FireBaseEventAnalytics.setEvent(FireBaseEventType.editShortcut, FireBaseFromScreen.homePage, bIncludeProjectName: true);
                                              },
                                              child: NormalTextWidget(
                                                key: Key('Edit_complete_text_widget_key'),
                                                context.toLocale!.lbl_done,
                                                fontSize: (Utility.isTablet) ? 20 : 16,
                                                fontWeight: AFontWight.medium,
                                                color: AColors.themeBlueColor,
                                              ),
                                            );
                                          }
                                        })
                                      ],
                                    )
                                  : TextButton(
                                      key: Key("EditButtonClick"),
                                      onPressed: () {
                                        if (isOnline) homePageCubit.onChangeEditMode();
                                      },
                                      child: NormalTextWidget(
                                        key: Key('Edit_mode_text_widget_key'),
                                        context.toLocale!.lbl_edit,
                                        fontSize: (Utility.isTablet) ? 20 : 16,
                                        fontWeight: AFontWight.medium,
                                        color: isOnline ? AColors.themeBlueColor : AColors.iconGreyColor,
                                      ),
                                    )
                          ],
                        ),
                      ),
                      Expanded(child: getHomePageView(context, state)),
                    ],
                  ),
                ),
              );
            }));
  }

  Widget getHomePageView(BuildContext context, FlowState state) {
    if (state is HomePageItemLoadingState && state.stateRendererType == StateRendererType.FULL_SCREEN_LOADING_STATE) {
      return ACircularProgress(
        key: Key("HomePageItemLoader"),
      );
    } else if (state is HomePageNoProjectSelectState) {
      return HomePageNoProjectView(
        key: const Key("HomePageNoProjectViewKey"),
        isOnline: state.isOnline,
      );
    } else if (state is HomePageEmptyState) {
      return HomePageEmptyView(
        key: const Key("HomePageEmptyView"),
      );
    } else if (state is ErrorState) {
      return Center(
        key: const Key("ErrorStateView"),
        child: NormalTextWidget(context.toLocale!.something_went_wrong),
      );
    } else if (state is HomePageItemState) {
      return OrientationBuilder(builder: (context, orientation) {
        if (currentOrientation != orientation) {
          currentOrientation = orientation;
          draggableGridViewMaxWidth = 0;
          draggableGridViewMaxHeight = 0;
        }
        return LayoutBuilder(
            key: const Key("HomePageItemView"),
            builder: (context, BoxConstraints constraints) {
              if (draggableGridViewMaxWidth == 0 || draggableGridViewMaxHeight == 0) {
                draggableGridViewMaxWidth = constraints.maxWidth;
                draggableGridViewMaxHeight = constraints.maxHeight;
              }

              int crossAxisCount = draggableGridViewMaxWidth ~/ (Utility.isTablet ? (draggableGridViewMaxWidth > draggableGridViewMaxHeight ? 190 : (draggableGridViewMaxWidth / 4 > 160 ? 160 : draggableGridViewMaxWidth / 4)) : 110); // minimum item width
              if (crossAxisCount <= 2) crossAxisCount = 3;
              double gridHeight = draggableGridViewMaxHeight - 40; // 40 for page indicator
              cellItemHeight = draggableGridViewMaxWidth / crossAxisCount;
              int rowAxisCount = (gridHeight ~/ cellItemHeight);
              if (rowAxisCount <= 2) {
                rowAxisCount = 3;
                cellItemHeight = gridHeight / rowAxisCount;
              }
              double remainHeight = gridHeight - (rowAxisCount * cellItemHeight);
              double mainAxisSpacing = remainHeight / rowAxisCount > 3 ? 3 : remainHeight / rowAxisCount;
              if (mainAxisSpacing < 0) mainAxisSpacing = 0;
              remainHeight = remainHeight - (mainAxisSpacing * rowAxisCount) - 50; // 50 ignorable space at bottom
              double topPadding = remainHeight > 0 ? remainHeight / 2 : 0;
              double bottomPadding = remainHeight > 0 ? remainHeight / 2 : 0;
              cellItemWidth = draggableGridViewMaxWidth / crossAxisCount;

              return Padding(
                padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
                child: DraggableGridViewBuilder(
                  pageController: pageController,
                  controller: _scrollController,
                  padding: EdgeInsets.zero,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent: cellItemHeight,
                    mainAxisSpacing: mainAxisSpacing,
                    crossAxisSpacing: Utility.isTablet ? 0 : 0,
                  ),
                  children: createListOfWidgets(context, true, state.homePageItemList!),
                  shrinkWrap: true,
                  dragCompletion: onDragAccept,
                  isOnlyLongPress: true,
                  dragFeedback: feedback,
                  dragPlaceHolder: placeHolder,
                  currentPageItemLength: crossAxisCount * rowAxisCount,
                  currentPageIndicatorColor: AColors.themeBlueColor,
                  otherPageIndicatorColor: AColors.iconGreyColor,
                ),
              );
            });
      });
    } else {
      return Container();
    }
  }

  List<DraggableGridItem> createListOfWidgets(BuildContext context, isProjectSelected, List<UserProjectConfigTabsDetails> userSelectedTabList) {
    _listOfDraggableGridItem = [];
    if (userSelectedTabList.isNotEmpty) {
      userSelectedTabList.asMap().forEach((index, element) {
        HomePageItemWidget homePageItemWidget = HomePageItemWidget(context, element, (shortcutAction, userProjectConfigTabsDetails) => onTapGridItem(shortcutAction, userProjectConfigTabsDetails), isDraggable: homePageCubit.isEditEnable, indexOfItem: index);
        _listOfDraggableGridItem.add(homePageItemWidget.getRenderItem());
      });
    }
    return _listOfDraggableGridItem;
  }

  Future<void> onTapGridItem(ShortcutAction shortcutAction, UserProjectConfigTabsDetails userProjectConfigTabsDetails) async {
    switch (shortcutAction) {
      case ShortcutAction.click:
        final homePageSortCutCategory = HomePageSortCutCategory.fromString(userProjectConfigTabsDetails.id!);
        Project? project = await StorePreference.getSelectedProjectData();
        FireBaseEventType? eventType;
        switch (homePageSortCutCategory) {
          case HomePageSortCutCategory.createNewTask:
            eventType = FireBaseEventType.createSiteTask;
            if (project == null) {
              context.showSnack(context.toLocale!.lbl_select_project);
            } else {
              BlocProvider.of<CreateFormSelectionCubit>(context).getDefaultSiteApp(project.projectID!);
            }
            break;
          case HomePageSortCutCategory.newTasks:
            eventType = FireBaseEventType.newTasks;
            _onTaskCountItemClicked(context, TaskActionType.newTask);
            break;
          case HomePageSortCutCategory.taskDueToday:
            eventType = FireBaseEventType.taskDueToday;
            _onTaskCountItemClicked(context, TaskActionType.dueToday);
            break;
          case HomePageSortCutCategory.taskDueThisWeek:
            eventType = FireBaseEventType.taskDueThisWeek;
            _onTaskCountItemClicked(context, TaskActionType.dueThisWeek);
            break;
          case HomePageSortCutCategory.overDueTasks:
            eventType = FireBaseEventType.overDueTasks;
            _onTaskCountItemClicked(context, TaskActionType.overDue);
            break;
          case HomePageSortCutCategory.jumpBackToSite:
            eventType = FireBaseEventType.jumpToLastLocation;
            break;
          case HomePageSortCutCategory.createSiteForm:
            eventType = FireBaseEventType.createSiteForm;
            if (project == null) {
              context.showSnack(context.toLocale!.lbl_select_project);
            } else {
              BlocProvider.of<HomePageCubit>(context).showFormCreationOptionsDialog();
            }
            break;
          case HomePageSortCutCategory.createForm:
            eventType = FireBaseEventType.createForm;
            if (project == null) {
              context.showSnack(context.toLocale!.lbl_select_project);
            } else {
              try {
                Map<String, dynamic> data = userProjectConfigTabsDetails.config;
                if (data.containsKey("instanceGroupId") && data.containsKey("templatetype")) {
                  if (!isNetWorkConnected() && (data["templatetype"] as int).isXSN) {
                    Utility.showAlertDialog(context, context.toLocale!.lbl_xsn_form_type_msg_offline_title, context.toLocale!.lbl_xsn_form_type_msg_offline);
                  } else {
                    QRCodeDataVo qrCodeDataVo = QRCodeDataVo(projectId: project.projectID, instanceGroupId: data["instanceGroupId"], dcId: project.dcId, qrCodeType: QRCodeType.qrFormType);
                    BlocProvider.of<FieldNavigatorCubit>(context).getFormPrivilege(qrCodeDataVo, isShowLoading: true, fromScreen: FromScreen.dashboard);
                  }
                } else {
                  context.showSnack(context.toLocale!.something_went_wrong);
                }
              } catch (e) {}
            }
            break;
          case HomePageSortCutCategory.filter:
            eventType = FireBaseEventType.filterFormsShortcut;
            homePageCubit.navigateSiteListingScreen(userProjectConfigTabsDetails);
            break;
          default:
            return null;
        }
        FireBaseEventAnalytics.setEvent(eventType, FireBaseFromScreen.homePage, bIncludeProjectName: true);
        break;
      case ShortcutAction.delete:
        await homePageCubit.deleteShortcutItem(userProjectConfigTabsDetails);
        break;
      default:
    }
  }

  _onTaskCountItemClicked(BuildContext context, TaskActionType taskItem) async {
    if (isOnline) {
      if (getIt<NavigationCubit>().currSelectedItem != NavigationMenuItemType.tasks) {
        getIt<NavigationCubit>().updateSelectedItemByType(NavigationMenuItemType.tasks);
        getIt<ToolbarCubit>().updateSelectedItemByPosition(NavigationMenuItemType.tasks);
      }
      BlocProvider.of<HomePageCubit>(context).navigateTaskListingScreen(taskItem);
    }
  }

  //Drag Widget
  void onDragAccept(List<DraggableGridItem> list, int beforeIndex, int afterIndex) {
    Log.d('onDragAccept: $beforeIndex -> $afterIndex');
    if (beforeIndex != afterIndex) {
      homePageCubit.updateEditModeListFromDrag(list);
    }
    FireBaseEventAnalytics.setEvent(FireBaseEventType.shortcutsDrag, FireBaseFromScreen.homePage, bIncludeProjectName: true);
  }

  Widget feedback(List<DraggableGridItem> list, int index) {
    return SizedBox(width: cellItemWidth, height: cellItemHeight, child: list[index].child);
  }

  PlaceHolderWidget placeHolder(List<DraggableGridItem> list, int index) {
    return PlaceHolderWidget(
      child: Padding(
        padding: const EdgeInsets.only(top: 10.0, left: 10.0),
        child: Container(
          width: cellItemWidth,
          height: cellItemHeight,
          child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
        ),
      ),
    );
  }

  void dismissAddProgressDialog() {
    addProgressDialog?.dismiss();
  }

  void showAddProgressDialog() {
    addProgressDialog = addProgressDialog ?? AProgressDialog(context, dismissable: false, isAnimationRequired: false, loadingWidget: Container(), backgroundColor: Colors.transparent);
    addProgressDialog?.show();
  }

  void getAddMoreDialog(BuildContext context, PendingShortcutItemState state) {
    homePageCubit.addedShortcutList.clear();
    showDialog(
        context: context,
        builder: (_) {
          return BlocProvider.value(
              value: homePageCubit,
              child: AddMoreToHomeScreen(
                  pendingShortCutList: state.pendingShortCutList,
                  onConfirm: (addedShortcutList) {
                    try {
                      if (addedShortcutList != null && addedShortcutList is List<UserProjectConfigTabsDetails> && addedShortcutList.isNotEmpty) {
                        homePageCubit.updateHomePageAfterDialogDismiss(addedShortcutList);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (homePageCubit.editModeShortcutList.length ~/ subListLength != pageController.page!.toInt()) {
                            pageController.jumpToPage(homePageCubit.editModeShortcutList.length ~/ subListLength);
                          }
                        });
                      }
                    } catch (_) {}
                  }));
        });
  }
}
