import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:field/bloc/formsetting/form_settings_change_event_cubit.dart';
import 'package:field/bloc/site/plan_cubit.dart';
import 'package:field/bloc/site/plan_loading_state.dart';
import 'package:field/bloc/sitetask/sitetask_cubit.dart';
import 'package:field/bloc/sync/sync_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_title_click_event_cubit.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/injection_container.dart';
import 'package:field/logger/logger.dart';
import 'package:field/pdftron/pdftron_document_view.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/filter/site_end_drawer_filter.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/observation_data_dialog.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/site_end_drawer.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/site_utils.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:field/widgets/custom_material_button_widget.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';

import '../../../analytics/event_analytics.dart';
import '../../../bloc/navigation/navigation_cubit.dart';
import '../../../bloc/recent_location/recent_location_cubit.dart';
import '../../../bloc/site/create_form_selection_cubit.dart';
import '../../../bloc/sitetask/sitetask_state.dart';
import '../../../bloc/sync/sync_state.dart';
import '../../../bloc/toolbar/toolbar_cubit.dart';
import '../../../domain/common/create_form_helper.dart';
import '../../../networking/network_info.dart';
import '../../../utils/constants.dart';
import '../../../utils/file_form_utility.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/store_preference.dart';
import '../../../widgets/location_tree.dart';
import '../../../widgets/task_pin.dart';
import '../../../widgets/tooltip_dialog/tooltip_dialog.dart';
import '../../managers/color_manager.dart';
import '../../managers/font_manager.dart';
import '../../managers/image_constant.dart';
import '../webview/asite_webview.dart';
import 'create_form_dialog/task_type_dialog.dart';

enum Pins { all, my, hide }

class SitePlanViewerScreen extends StatefulWidget {
  final Object? arguments;

  const SitePlanViewerScreen({
    this.arguments,
    Key? key,
  }) : super(key: key);

  @override
  State<SitePlanViewerScreen> createState() => SitePlanViewerScreenState();
}

class SitePlanViewerScreenState extends State<SitePlanViewerScreen> with TickerProviderStateMixin {
  final SiteTaskCubit _siteTaskCubit = getIt<SiteTaskCubit>();
  final PlanCubit _planCubit = getIt<PlanCubit>();
  ScrollController scrollController = getIt<ScrollController>();

  AProgressDialog? aProgressDialog;

  final TooltipController _tooltipController = TooltipController();
  final JustTheController justTheController = JustTheController();
  final double tempCreatePinIconSize = 40;
  final devicePixelRatio = Platform.isAndroid ? WidgetsBinding.instance.window.devicePixelRatio : 1;
  double x = -1, y = -1;
  late AnimationController controller;
  late AnimationController paddingController;
  late Animation<Offset> offset;
  Animation<EdgeInsetsGeometry>? animatedPadding;
  bool isDrawerOpen = false;
  bool isFilterOpen = false;

  @override
  void initState() {
    checkFromQuality();
    initPlatformState();
    getSelectedPinFilterType();
    super.initState();
    FireBaseEventAnalytics.setCurrentScreen(FireBaseScreenName.twoDPlan.value);
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AConstants.siteEndDrawerDuration),
    );
    paddingController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (AConstants.siteEndDrawerDuration + 60)),
    );

    setDataAndLoadPlan();
    _resetAnimation();
    animationManager();
  }

  animationManager() {
    controller.addListener(() {
      switch (controller.status) {
        case AnimationStatus.completed:
          paddingController.duration = Duration.zero;
          controller.duration = Duration(milliseconds: AConstants.siteEndDrawerDuration);
          break;
        case AnimationStatus.dismissed:
          paddingController.duration = Duration(milliseconds: (AConstants.siteEndDrawerDuration + 60));
          controller.duration = Duration(milliseconds: (AConstants.siteEndDrawerDuration - 60));
          break;
        default:
      }
    });
  }

  checkFromQuality() {
    if (widget.arguments != null) {
      final arguments = widget.arguments as Map<String, dynamic>;
      if (arguments.containsKey("isFromQuality")) {
        _planCubit.isFromQuality = arguments["isFromQuality"];
      }
    }
  }

  getSelectedPinFilterType() async {
    _planCubit.currentPinsType = Pins.values[await StorePreference.getSelectedPinFilterType()];
  }

  @override
  Widget build(BuildContext context) {
    TextDirection currentTextDirection = Directionality.of(context);
    if (currentTextDirection == TextDirection.ltr) {
      offset = Tween(begin: const Offset(1.0, 0.0), end: const Offset(-0.01, 0.0)).animate(controller);
    } else {
      offset = Tween(end: const Offset(0.01, 0.0), begin: const Offset(-1.0, 0.0)).animate(controller);
    }
    animatedPadding = EdgeInsetsGeometryTween(
      begin: const EdgeInsetsDirectional.only(end: 0),
      end: EdgeInsetsDirectional.only(end: calculateResponsiveWidth(context)),
    ).animate(paddingController);
    return BlocProvider(
      create: (_) => _planCubit,
      child: MultiBlocListener(
        listeners: [
          BlocListener<ToolbarTitleClickEventCubit, FlowState>(listener: (_, state) {
            dismissToolTipDialog();
            showLocationTreeDialog();
          }),
          BlocListener<SyncCubit, FlowState>(listener: (_, state) {
            if (state is SyncCompleteState && state.isNeedToRefreshData == true) {
              if (SiteUtility.isLocationHasPlan(_planCubit.selectedLocation)) {
                _planCubit.refreshPins();
              }
              if (controller.status != AnimationStatus.dismissed) {
                _planCubit.refreshSiteTaskList();
              }
            }
          }),
          BlocListener<FormSettingsChangeEventCubit, FlowState>(listener: (_, state) {
            if (SiteUtility.isLocationHasPlan(_planCubit.selectedLocation) == true) {
              _planCubit.refreshPins();
            }
            if (controller.status != AnimationStatus.dismissed) {
              _planCubit.refreshSiteTaskList();
            }
          }),
        ],
        child: WillPopScope(
          onWillPop: _canPop,
          child: Scaffold(
            backgroundColor: Colors.white,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                BlocConsumer<PlanCubit, FlowState>(listenWhen: (previous, current) {
                  return current is ProgressDialogState || current is LastLocationChangeState || current is LongPressCreateTaskState || current is FormItemViewState || current is CloseKeyBoardState || current is CreateTaskNavigationState || current is SelectedFormDataState;
                }, listener: (_, state) async {
                  if (state is SelectedFormDataState) {
                    _planCubit.isFromScreen = FromScreen.listing;
                    if (!isDrawerOpen) openOrCloseListingDrawer(false);
                  } else if (state is CloseKeyBoardState) {
                    context.closeKeyboard();
                  } else if (state is ProgressDialogState) {
                    if (!isDrawerOpen || Utility.isTablet) {
                      if (state.isShowDialog) {
                        aProgressDialog ??= AProgressDialog(context);
                        aProgressDialog?.show();
                      } else {
                        aProgressDialog?.dismiss();
                      }
                    }
                  } else if (state is LastLocationChangeState) {
                    getIt<RecentLocationCubit>().initData();
                  } else if (state is LongPressCreateTaskState) {
                    ///Passing appTypeId 2 in postApiCall for Sites
                    if (state.isShowingPin) {
                      _showCreateFormDialog(createFormSelectionCubit: await CreateFormHelper().onPostApiCall(true, "2"));
                    }
                  } else if (state is CreateTaskNavigationState) {
                    if (!isNetWorkConnected() && state.appType.templateType.isXSN) {
                      Utility.showAlertDialog(context, context.toLocale!.lbl_xsn_form_type_msg_offline_title, context.toLocale!.lbl_xsn_form_type_msg_offline);
                    } else {
                      createSiteTaskOrForm(state);
                    }
                  } else if (state is FormItemViewState) {
                    Color? headerIconColor = (state.headerIconColor != "") ? state.headerIconColor.toColor() : null;
                    await FileFormUtility.showFileFormViewDialog(context, frmViewUrl: state.frmViewUrl, data: state.webviewData, color: headerIconColor, callback: (value) {
                      try {
                        if (value != null && value is Map && value.isNotEmpty) {
                          Map<String, dynamic> dict = json.decode(json.encode(value)) as Map<String, dynamic>;
                          //String projectId = dict['projectId'] as String;
                          String formId = dict['formId'] as String;
                          //bool isCopySiteTask = dict['isCopySiteTask'] ?? false;String formId = dict['formId'] as String;

                          Future.delayed(const Duration(milliseconds: 500)).then((value) async {
                            if (!_planCubit.isClosed) {
                              if (dict.containsKey('isFromDiscardDraft')) {
                                bool isFromDiscardDraft = dict['isFromDiscardDraft'];
                                if (isFromDiscardDraft == true) {
                                  _planCubit.refreshPins();
                                }
                              } else {
                                await _planCubit.refreshPinsAndHighLight({"formId": formId});
                                // await _planCubit.getUpdatedSiteTaskItem(projectId, formId.plainValue());
                              }
                            }
                          });
                        }
                      } catch (_) {}
                    });
                  }
                }, buildWhen: (previous, current) {
                  return (current is PlanLoadingState || current is ErrorState || current is LoadingState);
                }, builder: (_, state) {
                  return Utility.isTablet
                      ? AnimatedBuilder(
                      animation: paddingController,
                      builder: (context, child) {
                        return Padding(padding: animatedPadding!.value, child: _bindPdftronWidget(context, state));
                      })
                      : _bindPdftronWidget(context, state);
                }),
                _bindFormToggleBtnWidget(),
                // _bindHistoryLocationBtnWidget(),
                _backToQualityScreen(),
                Visibility(
                  // TODO FR-732 visibility off due to this case, will remove after first release
                    visible: false,
                    child: _bindCreateFormsWidget()),
                _bindTempCreateTaskPin(),
                // showObservationDialog(context),
                BlocBuilder<PlanCubit, FlowState>(
                  buildWhen: (previous, current) {
                    return current is RefreshSiteTaskListState;
                  },
                  builder: (context, state) {
                    return PositionedDirectional(
                      end: Utility.isTablet ? -15 : -4,
                      bottom: 0,
                      top: 0,
                      child: SlideTransition(
                        position: offset,
                        child: (controller.status != AnimationStatus.dismissed)
                            ? MultiBlocProvider(
                            providers: [
                              BlocProvider.value(
                                value: _planCubit,
                              ),
                              BlocProvider.value(
                                value: _siteTaskCubit,
                              ),
                            ],
                            child: SiteEndDrawerWidget(
                              selectedFormId: _planCubit.highLightFormId,
                              selectedFormCode: _planCubit.getFormCodeFilterValue(),
                              isFromFormCreate: _planCubit.isFromScreen,
                              animationStatus: controller.status,
                              key: ValueKey(state),
                              fromFilter: isFilterOpen,
                              obj: _planCubit.selectedLocation,
                              onClose: () {
                                openOrCloseListingDrawer(false);
                              },
                            ))
                            : Container(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> initPlatformState() async {
    try {
      // Initializes the PDFTron SDK, it must be called before you can use
      // any functionality.

      String? pdftronLicenceKey = await Utility.getPDFTronLicenseKey();
      PdftronFlutter.initialize(pdftronLicenceKey!);
      // await _planCubit.intializePDFTron();
    } on PlatformException {
      Log.d('Failed to get platform version.');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, you want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
  }

  openOrCloseListingDrawer(bool fromFilter) {
    setState(() {
      switch (controller.status) {
        case AnimationStatus.completed:
          isDrawerOpen = false;
          isFilterOpen = false;
          paddingController.reverse();
          controller.reverse();
          break;
        case AnimationStatus.dismissed:
          isDrawerOpen = true;
          if (fromFilter) {
            isFilterOpen = true;
          } else {
            isFilterOpen = false;
          }
          paddingController.forward();
          controller.forward();
          break;
        default:
      }
    });
  }

  Widget _bindPdftronWidget(BuildContext context, FlowState flowState) {
    if (flowState is LoadingState) {
      return _bindCircularProgressWidget();
    } else if (flowState is PlanLoadingState) {
      return Stack(fit: StackFit.expand, children: <Widget>[
        PdftronDocumentView(key: const Key("Key_PdftronDocumentView"), onCreated: _planCubit.onDocumentViewCreated),
        //For Black screen Issue
        if (flowState.planStatus != PlanStatus.loadedPlan) Container(color: Colors.white, child: _bindCircularProgressWidget())
      ]);
    } else if (flowState is ErrorState) {
      return _bindPlanLoadErrorWidget(flowState.message.isNullOrEmpty() ? context.toLocale!.no_plan_available : flowState.message);
    }
    return Container();
  }

  Widget _backToQualityScreen() {
    return Visibility(
      visible: _planCubit.isFromQuality,
      child: PositionedDirectional(
        top: 16,
        start: Utility.isTablet ? 16 : 10,
        child: CustomMaterialButtonWidget(
          elevation: 4,
          onPressed: () {
            context.closeKeyboard();
            backToQuality();
          },
          height: 46,
          width: 46,
          child: Image.asset(AImageConstants.backToQuality),
        ),
      ),
    );
  }

  Widget _bindHistoryLocationBtnWidget() {
    return BlocBuilder<PlanCubit, FlowState>(
        buildWhen: (prev, current) => current is HistoryLocationBtnState || current is LoadingState || current is PlanLoadingState || current is ProgressDialogState,
        builder: (context, state) {
          bool isHistoryLocationBtnVisible = (state is HistoryLocationBtnState && (state.isHistoryLocationBtnVisible)) /*|| (state is PlanLoadingState && state.planStatus != PlanStatus.loadedPlan)*/;

          return Visibility(
            visible: isHistoryLocationBtnVisible && !_planCubit.isFromQuality,
            child: PositionedDirectional(
              top: 16,
              start: Utility.isTablet ? 16 : 10,
              child: CustomMaterialButtonWidget(
                color: AColors.white,
                elevation: 4,
                onPressed: () {
                  context.closeKeyboard();
                  _planCubit.removeItemFromBreadCrumb();
                },
                height: 46,
                width: 46,
                shape: CircleBorder(side: BorderSide(color: AColors.themeBlueColor, strokeAlign: BorderSide.strokeAlignInside)),
                child: Icon(
                  semanticLabel: "BackBtnIcon",
                  Icons.arrow_back,
                  color: AColors.themeBlueColor,
                  size: 24,
                ),
              ),
            ),
          );
        });
  }

  Widget _bindCreateFormsWidget() {
    return PositionedDirectional(
      bottom: 16,
      end: Utility.isTablet ? 16 : 10,
      child: CustomMaterialButtonWidget(
        color: AColors.themeBlueColor,
        elevation: 4,
        onPressed: () {},
        height: 50,
        width: 50,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.add_task,
          color: AColors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _bindFormToggleBtnWidget() {
    return PositionedDirectional(
      top: 16,
      end: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CustomMaterialButtonWidget(
            color: AColors.themeBlueColor,
            elevation: 0,
            onPressed: () {
              _planCubit.isFromScreen = FromScreen.listing;
              _siteTaskCubit.setDrawerValue(StackDrawerOptions.drawerBody);
              openOrCloseListingDrawer(false);
              FireBaseEventAnalytics.setEvent(FireBaseEventType.siteListingDrawerToggle, FireBaseFromScreen.twoDPlan, bIncludeProjectName: true);
              FireBaseEventAnalytics.setEvent(FireBaseEventType.siteListingDrawerToggle, FireBaseFromScreen.twoDPlan, bIncludeProjectName: true);
            },
            height: 55,
            width: 48,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(5),
              ),
            ),
            child: ImageIcon(
              semanticLabel: "TaskFormsIcon",
              AssetImage(Utility.isTablet ? AImageConstants.tabletSidebarIcon : AImageConstants.openSidebarIcon),
              color: AColors.white,
              size: 35,
            ),
          ),
          const SizedBox(height: 16),
          BlocBuilder<PlanCubit, FlowState>(
            buildWhen: (previous, current) => current is PinsLoadedState || current is AppliedStaticFilter,
            builder: (_, state) {
              if (state is AppliedStaticFilter && state.appliedStaticFilter) {
                return Container();
              } else {
                return _showPinButton();
              }
            },
          ),
        ],
      ),
    ); //32447684
  }

  // Widget showObservationDialog(BuildContext context) {
  //   return BlocBuilder<PlanCubit, FlowState>(
  //       buildWhen: (previous, current) => current is ShowObservationDialogState,
  //       builder: (_, state) {
  //         if (state is ShowObservationDialogState) {
  //           var x = state.x;
  //           var y = state.y;
  //           var w = state.pinWidth / devicePixelRatio;
  //           var h = state.pinHeight / devicePixelRatio;
  //           var start = (x / devicePixelRatio) - w / 2;
  //           var top = (y / devicePixelRatio) - h;
  //           if (state.isShowDialog) {
  //             Future.delayed(const Duration(milliseconds: 200))
  //                 .whenComplete(() {
  //               justTheController.showTooltip();
  //             });
  //           }
  //           return PositionedDirectional(
  //               top: top,
  //               start: start,
  //               child: JustTheTooltip(
  //                 preferredDirection: AxisDirection.down,
  //                 onShow: () {
  //                   // print('onShow');
  //                 },
  //                 onDismiss: () {
  //                   _planCubit.onDismissPinDialog(state.observationData);
  //                   //_planCubit.onFormItemClicked(state.observationData);
  //                 },
  //                 controller: justTheController,
  //                 isModal: true,
  //                 borderRadius: BorderRadius.circular(18.0),
  //                 content: ConstrainedBox(
  //                   constraints: const BoxConstraints(maxWidth: 320),
  //                   child: BlocProvider.value(
  //                     value: _planCubit,
  //                     child: ObservationDataDialog(
  //                       observationData: state.observationData,
  //                       onTooltipClick: (frmData) async {
  //                         if (!isNetWorkConnected() &&
  //                             frmData.templateType.isXSN) {
  //                           Utility.showAlertDialog(
  //                               context,
  //                               context.toLocale!
  //                                   .lbl_xsn_form_type_msg_offline_title,
  //                               context
  //                                   .toLocale!.lbl_xsn_form_type_msg_offline);
  //                         } else {
  //                           if (isNetWorkConnected() &&
  //                               frmData.isSyncPending == true) {
  //                             Utility.showAlertDialog(
  //                                 context,
  //                                 context.toLocale!.lbl_cant_open_form,
  //                                 context.toLocale!
  //                                     .lbl_open_unsynced_form_in_online);
  //                           } else {
  //                             await _planCubit.onFormItemClicked(frmData);
  //                           }
  //                         }
  //                         justTheController.hideTooltip();
  //                       },
  //                     ),
  //                   ),
  //                 ),
  //                 child: state.isShowDialog
  //                     ? SizedBox(width: w, height: h)
  //                     : const SizedBox.shrink(),
  //               ));
  //         } else {
  //           return Container();
  //         }
  //       });
  // }

  Future<bool> _canPop() async {
    if (_planCubit.isFromQuality) {
      if (isDrawerOpen) {
        openOrCloseListingDrawer(false);
        return false;
      } else {
        backToQuality();
        return !_planCubit.isFromQuality;
      }
    } else {
      if (isDrawerOpen) {
        openOrCloseListingDrawer(false);
        return false;
      } else {
        return !_planCubit.isFromQuality;
      }
    }
  }

  backToQuality() {
    getIt<NavigationCubit>().updateSelectedItemByType(NavigationMenuItemType.quality);
    getIt<ToolbarCubit>().updateSelectedItemByPosition(NavigationMenuItemType.quality);
  }

  dismissToolTipDialog() {
    _tooltipController.hideTooltipDialog();
    if (justTheController.value == TooltipStatus.isShowing) {
      justTheController.hideTooltip();
    }
  }

  // Widget _pinContainsVisibility(bool isVisible){
  //   return Visibility(visible: isVisible,child: container,);
  // }
  Widget _showPinButton() {
    return CustomMaterialButtonWidget(
      color: AColors.greyColor,
      elevation: 4,
      onPressed: () {
        context.closeKeyboard();
        _siteTaskCubit.setDrawerValue(StackDrawerOptions.filter);
        openOrCloseListingDrawer(true);
        // _tooltipController.showTooltipDialog();
      },
      height: 55,
      width: 48,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(5),
        ),
      ),
      child: ImageIcon(
        AssetImage(
          _siteTaskCubit.filterApplied ? AImageConstants.openAppliedFilterIcon : AImageConstants.openFilterIcon,
        ),
        size: 30,
        color: AColors.themeBlueColor,
      ),
    );
  }

  Widget _showPinsPopupMenu() => Column(
    children: <Widget>[
      _getPinsTile(Icons.pin_drop, context.toLocale!.lbl_show_all_pin, Pins.all),
      const Divider(height: 1.0),
      _getPinsTile(Icons.person_pin, context.toLocale!.lbl_assigned_pin_only, Pins.my),
      const Divider(height: 1.0),
      _getPinsTile(Icons.location_off, context.toLocale!.lbl_hide_all_pin, Pins.hide),
    ],
  );

  Widget _getPinsTile(IconData icon, String title, Pins pinValue) {
    return RadioListTile(
      title: Row(
        children: [
          Icon(icon, size: 24.0),
          const SizedBox(
            width: 8.0,
          ),
          Flexible(
            child: NormalTextWidget(
              title,
              fontWeight: AFontWight.regular,
              fontSize: 16.0,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
      activeColor: AColors.themeBlueColor,
      value: pinValue,
      groupValue: _planCubit.currentPinsType,
      onChanged: (Pins? value) {
        _tooltipController.hideTooltipDialog();
        StorePreference.setSelectedPinFilterType(value?.index);
        _planCubit.currentPinsType = value;
        _planCubit.clearSiteTaskFilter();
      },
      controlAffinity: ListTileControlAffinity.trailing,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _bindCircularProgressWidget() {
    return const Center(child: ACircularProgress());
  }

  Widget _bindPlanLoadErrorWidget(String msg) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              width: 120,
              height: 120,
              image: AssetImage(AImageConstants.plan),
            ),
            const SizedBox(height: 20),
            NormalTextWidget(
              msg,
              fontWeight: FontWeight.normal,
              color: AColors.grColor,
            ),
          ],
        ));
  }

  /// rendering temp animated pin while a long press on plan
  Widget _bindTempCreateTaskPin() {
    return BlocBuilder<PlanCubit, FlowState>(
        buildWhen: (previous, current) => current is LongPressCreateTaskState,
        builder: (context, state) {
          if (state is LongPressCreateTaskState) {
            x = state.x;
            y = state.y;
            var start = (x / devicePixelRatio) - tempCreatePinIconSize / 2;
            var top = (y / devicePixelRatio) - tempCreatePinIconSize;
            return state.isShowingPin ? PositionedDirectional(start: start, top: top, child: TaskPin(key: const Key('Key_TempCreateTaskPin'), isShowAnimation: true, iconSize: tempCreatePinIconSize)) : const SizedBox.shrink();
          }
          return Container();
        });
  }

  void showLocationTreeDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return ScaffoldMessenger(child: Builder(builder: (context) {
            return Scaffold(backgroundColor: Colors.transparent, body: LocationTreeWidget(_planCubit.getArgumentData()));
          }));
        }).then((value) async {
      if (value != null) {
        _planCubit.currentPinsType = Pins.values[await StorePreference.getSelectedPinFilterType()];
        _planCubit.highLightFormId = "";
        await _planCubit.refreshPinsAndHighLight({"formId": ""}, refreshTaskList: true, isShowProgressDialog: true);
        await _planCubit.setArgumentData(value);
        _planCubit.loadPlan();
        if (_planCubit.isNeedtoOpenListingDrawer()) {
          if (!isDrawerOpen) {
            openOrCloseListingDrawer(false);
          }
        }
      }
    });
  }

  void setDataAndLoadPlan() async {
    await _planCubit.setArgumentData(widget.arguments);
    _planCubit.loadPlan();
    if ((_planCubit.isFromScreen == FromScreen.dashboard || _planCubit.isFromScreen == FromScreen.qrCode) && !_planCubit.highLightFormId.isNullOrEmpty()) {
      _showFormCreatedMessage();
    }

    if (_planCubit.isNeedtoOpenListingDrawer()) {
      if (!Utility.isTablet) {
        aProgressDialog?.dismiss();
      }
      openOrCloseListingDrawer(false);
    }
  }

  Future<void> _showCreateFormDialog({CreateFormSelectionCubit? createFormSelectionCubit}) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return TaskTypeDialog(
            key: const Key('Key_ShowPinDialog'),
            createFormSelectionCubit: createFormSelectionCubit!,
          );
        }).then((value) {
      _planCubit.removeTempCreatePin();
      if (value != null && value is AppType) {
        if (!isNetWorkConnected() && value.templateType.isXSN) {
          Utility.showAlertDialog(context, context.toLocale!.lbl_xsn_form_type_msg_offline_title, context.toLocale!.lbl_xsn_form_type_msg_offline);
        } else {
          _planCubit.navigateToCreateTask(x: x, y: y, appType: value, from: "site_plan_view");
        }
      }
    });
    /* else if (globals.appTypeList.length == 1) {
      AppType appType = globals.appTypeList.first;
      String formType = appType.appBuilderCode ?? "";
      if (formType.toLowerCase() == AConstants.siteTaskType) {
        _planCubit.navigateToCreateTask(x, y, appType);
      } else {
        //Open another forms
      }
    }*/
  }

  Future<void> createSiteTaskOrForm(CreateTaskNavigationState state) async {
    if (Utility.isTablet) {
      await showDialog(
          context: context,
          builder: (context) {
            var height = MediaQuery.of(context).size.height * 0.85;
            var width = MediaQuery.of(context).size.width * 0.87;
            return Dialog(
              insetPadding: EdgeInsets.zero,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: SizedBox(
                width: width,
                height: height,
                child: AsiteWebView(
                  url: Uri.decodeFull(state.url),
                  title: "${context.toLocale!.lbl_create} ${state.appType.formTypeName!}",
                  data: state.data,
                ),
              ),
            );
          }).then((value) {
        _onFormOrTaskCreated(value);
      });
    } else {
      await NavigationUtils.mainPushWithResult(
        context,
        MaterialPageRoute(
          builder: (context) => AsiteWebView(
            url: Uri.decodeFull(state.url),
            title: "${context.toLocale!.lbl_create} ${state.appType.formTypeName!}",
            data: state.data,
          ),
        ),
      )?.then((value) {
        _onFormOrTaskCreated(value);
      });
    }
  }

  void _onFormOrTaskCreated(value) {
    if (value != null && SiteUtility.isLocationHasPlan(_planCubit.selectedLocation) && value["formId"] != null) {
      if (_planCubit.currentPinsType != Pins.all) {
        _showFormCreatedMessage();
      }
      _planCubit.refreshPinsAndHighLight(value);
    } else {
      _planCubit.refreshSiteTaskList();
    }
  }

  void _showFormCreatedMessage() {
    if (_planCubit.currentPinsType != Pins.all) {
      context.showSnack(context.toLocale!.form_created_with_pin_message);
    }
  }

  _resetAnimation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Utility.isTablet) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.minScrollExtent,
            duration: const Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
          );
        }
      }
    });
  }

  double calculateResponsiveWidth(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    double fullWidth = 0.0;
    double width = mediaQueryData.size.width;
    if (mediaQueryData.orientation == Orientation.landscape) {
      fullWidth = width * 0.325;
    } else if (mediaQueryData.orientation == Orientation.portrait) {
      fullWidth = width * 0.485;
    }
    // Calculate the width for the specific resolution (2800 x 1752)
    double customResolutionWidth = (width * fullWidth) / width;

    return customResolutionWidth;
  }
}
