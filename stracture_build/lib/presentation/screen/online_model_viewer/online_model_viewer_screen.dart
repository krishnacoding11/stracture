import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart';
import 'package:field/bloc/online_model_viewer/task_form_list_cubit.dart' as snagging_cubit;
import 'package:field/bloc/pdf_tron/pdf_tron_cubit.dart' as pdf_tron;
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart' as side_tool_bar;
import 'package:field/bloc/site/plan_cubit.dart';
import 'package:field/bloc/toolbar/model_tree_title_click_event_cubit.dart';
import 'package:field/data/model/get_threed_type_list.dart';
import 'package:field/data/model/online_model_viewer_arguments.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/actionIdConstants.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/show_dialog_box.dart';
import 'package:field/widgets/model_tree.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';

import '../../../bloc/navigation/navigation_cubit.dart';
import '../../../bloc/online_model_viewer/model_tree_cubit.dart' as model_tree;
import '../../../bloc/site/create_form_selection_cubit.dart';
import '../../../bloc/sitetask/sitetask_cubit.dart';
import '../../../data/model/floor_details.dart';
import '../../../injection_container.dart';
import '../../../utils/constants.dart';
import '../../../utils/file_utils.dart';
import '../../../utils/in_app_webview_options.dart';
import '../../../utils/navigation_utils.dart';
import '../../../utils/requestParamsConstants.dart';
import '../../../utils/sharedpreference.dart';
import '../../../utils/site_utils.dart';
import '../../../utils/toolbar_mixin.dart';
import '../../../utils/utils.dart';
import '../../../widgets/circular_progress/circular_menu_item.dart';
import '../../../widgets/circular_progress/circuler_menu.dart';
import '../../../widgets/custom_material_button_widget.dart';
import '../../../widgets/snagging_widget/snagging_filter_widget.dart';
import '../../../widgets/task_form_listing_widget/task_form_listing_widget.dart';
import '../../base/state_renderer/state_render_impl.dart' as state_render;
import '../../managers/font_manager.dart';
import '../../pdf_tron_widget/pdf_tron_widget.dart';
import '../side_toolbar/side_toolbar_screen.dart';
import '../sidebar_menu_screen.dart';
import '../site_routes/create_form_dialog/task_type_dialog_threed.dart';
import '../site_routes/site_plan_viewer_screen.dart';
import '../view_object_details.dart';
import '../webview/asite_webview.dart';
import 'custom_color_picker.dart';

class OnlineModelViewerScreen extends StatefulWidget {
  final OnlineModelViewerArguments onlineModelViewerArguments;

  OnlineModelViewerScreen({
    Key? key,
    required this.onlineModelViewerArguments,
  }) : super(key: key);

  @override
  State<OnlineModelViewerScreen> createState() => OnlineModelViewerStates();
}

class OnlineModelViewerStates extends State<OnlineModelViewerScreen> with SingleTickerProviderStateMixin, ToolbarTitle {
  final side_tool_bar.SideToolBarCubit _sideToolBarCubit = di.getIt<side_tool_bar.SideToolBarCubit>();
  final OnlineModelViewerCubit _onlineModelViewerCubit = di.getIt<OnlineModelViewerCubit>();
  final pdf_tron.PdfTronCubit _pdfTronCubit = di.getIt<pdf_tron.PdfTronCubit>();
  Offset? touchPosition;
  final ScrollController _scrollController = ScrollController();
  String deviceType = "";

  @override
  void initState() {
    super.initState();
    PreferenceUtils.setBool('reloadOffline', false);
    _onlineModelViewerCubit.isSnaggingFilterOpen = false;
    _onlineModelViewerCubit.isSnaggingOpen = false;
    _sideToolBarCubit.emitPagination();
    _sideToolBarCubit.isSteps = false;
    _sideToolBarCubit.isWhite = false;
    _sideToolBarCubit.isColorPickerMenuActive = false;
    _sideToolBarCubit.isRulerMenuActive = false;
    _sideToolBarCubit.isRulerFirstSubMenuActive = false;
    _sideToolBarCubit.isRulerSecondSubMenuActive = false;
    _sideToolBarCubit.isRulerThirdSubMenuActive = false;
    _sideToolBarCubit.isMarkerMenuActive = false;
    _sideToolBarCubit.isCuttingPlaneMenuActive = false;
    _sideToolBarCubit.isCuttingPlaneFirstSubMenuActive = false;
    _sideToolBarCubit.isCuttingPlaneSecondSubMenuActive = false;
    _sideToolBarCubit.isCuttingPlaneThirdSubMenuActive = false;
    _sideToolBarCubit.isCuttingPlaneFourthSubMenuActive = false;
    _sideToolBarCubit.isCuttingPlaneFifthSubMenuActive = false;
    _sideToolBarCubit.selectedModel = widget.onlineModelViewerArguments.model;
    _pdfTronCubit.selectedCalibration = null;
    _onlineModelViewerCubit.calibrationList.clear();
    setOfflineParams(widget.onlineModelViewerArguments.offlineParams!);
    _onlineModelViewerCubit.isShowSideToolBar = widget.onlineModelViewerArguments.isShowSideToolBar;
    _onlineModelViewerCubit.isCalibListPressed = false;
    _onlineModelViewerCubit.isFullPdf = false;
    _onlineModelViewerCubit.isShowPdfView = false;
    _onlineModelViewerCubit.isFirstTime = true;
    _onlineModelViewerCubit.isModelTreeOpen = true;
    _onlineModelViewerCubit.getModelFileData(widget.onlineModelViewerArguments.onlineViewerModelRequestModel.bimModelList, widget.onlineModelViewerArguments.onlineViewerModelRequestModel.modelName!);
    updateTitle(widget.onlineModelViewerArguments.onlineViewerModelRequestModel.modelName, NavigationMenuItemType.models);
    deviceType = Utility.isTablet ? "Tablet" : "Mobile";
    getIt<model_tree.ModelTreeCubit>().emitPaginationListInitial();
    getIt<snagging_cubit.TaskFormListingCubit>().emitPaginationListInitial();
  }

  @override
  Widget build(BuildContext context) {
    _onlineModelViewerCubit.selectedModelId = widget.onlineModelViewerArguments.onlineViewerModelRequestModel.modelId != null ? widget.onlineModelViewerArguments.onlineViewerModelRequestModel.modelId! : "";
    return SafeArea(
      child: WillPopScope(
        onWillPop: onWillPop,
        child: BlocBuilder<OnlineModelViewerCubit, OnlineModelViewerState>(
          builder: (context, state) {
            return Scaffold(
              key: _onlineModelViewerCubit.key,
              backgroundColor: Colors.grey[300],
              drawer: const SidebarMenuWidget(),
              endDrawer: !_onlineModelViewerCubit.isTaskFormListing && state is! NormalWebState ? ViewObjectDetails() : null,
              endDrawerEnableOpenDragGesture: false,
              drawerEnableOpenDragGesture: true,
              floatingActionButtonLocation: _buildFloatingActionButtonLocation(),
              body: MultiBlocListener(
                listeners: [
                  BlocListener<OnlineModelViewerCubit, OnlineModelViewerState>(
                    listener: (context, state) {
                      if (state is ErrorState) {
                        context.showSnack(state.exception.message);
                      } else if (state is MenuOptionLoadedState && state.isShowPdfView) {
                        _onlineModelViewerCubit.isShowPdf = true;
                        _onlineModelViewerCubit.is3DVisible = false;
                      } else if (state is MenuOptionLoadedState && !state.isShowPdfView) {
                        _onlineModelViewerCubit.isShowPdf = false;
                      } else if (state is WebGlContextLostState || state is TimeoutWarningState || state is TimeOutState || state is WebsocketConnectionClosedState || state is ModelLoadFailureState) {
                        ShowAlertDialogBox.modelLoadingFailed(context: context);
                      } else if (state is FailedModelState) {
                        ShowAlertDialogBox.issueWhileLoadingModels(context: context, totalNumbersOfModel: _onlineModelViewerCubit.bimModelListData.length.toString(), totalNumbersOfModelLoadFailed: _onlineModelViewerCubit.totalNumbersOfModelsLoadFailed);
                      } else if (state is InsufficientStorageState) {
                        ShowAlertDialogBox.inSufficientStorage(
                          context: context,
                        );
                      } else if (state is NormalWebState) {
                        if (_onlineModelViewerCubit.isShowPdf) {
                          _onlineModelViewerCubit.isShowPdfView = true;
                        }
                      } else if (state is CreateTaskNavigationState) {
                        if (!isNetWorkConnected() && state.appType.templateType.isXSN) {
                          Utility.showAlertDialog(context, context.toLocale!.lbl_xsn_form_type_msg_offline_title, context.toLocale!.lbl_xsn_form_type_msg_offline);
                        } else {
                          createSiteTaskOrForm(state);
                        }
                      } else if (state is LoadedSuccessfulAllModelState || state is CalibrationListPresentState) {
                        _onlineModelViewerCubit.is3DVisible = true;
                        _onlineModelViewerCubit.isCalibListPressed = true;
                        _onlineModelViewerCubit.isModelLoaded = true;
                        _sideToolBarCubit.isSideToolBarEnabled = true;
                        _sideToolBarCubit.isSideToolBarEnable();
                        _onlineModelViewerCubit.setNavigationSpeed();
                        if (isNetWorkConnected()) {
                          _onlineModelViewerCubit.getColor(widget.onlineModelViewerArguments.projectId, widget.onlineModelViewerArguments.onlineViewerModelRequestModel.modelId!);
                          _onlineModelViewerCubit.setParallelViewAuditTrail(_onlineModelViewerCubit.selectedProject.projectID!, "Field", "Viewed Model", ActionConstants.actionId45, widget.onlineModelViewerArguments.onlineViewerModelRequestModel.modelId!, "");
                        }
                      } else if (state is CalibrationListResponseSuccessState && state.items.isEmpty) {
                        _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '${Orientation.portrait}', view : ${_onlineModelViewerCubit.isShowPdf ? "'3D/2D'" : "'3D'"},device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
                        _sideToolBarCubit.isWhite = false;
                      } else if (state is! LoadingState && state is! PaginationListInitial) {
                        _onlineModelViewerCubit.isShowSideToolBar = true;
                      }
                    },
                  ),
                  BlocListener<ModelTreeTitleClickEventCubit, state_render.FlowState>(listener: (_, state) {
                    showLocationTreeDialog(context);
                  }),
                  BlocListener<snagging_cubit.TaskFormListingCubit, snagging_cubit.TaskFormListingState>(listener: (_, state) {
                    //showLocationTreeDialog(context);
                  }),
                ],
                child: BlocBuilder<OnlineModelViewerCubit, OnlineModelViewerState>(
                  builder: (context, state) {
                    return OrientationBuilder(
                      builder: (context, orientation) {
                        if (state is CalibrationListResponseSuccessState && state.items.isEmpty) {
                          _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '$orientation', view : ${_onlineModelViewerCubit.isShowPdf ? "'3D/2D'" : "'3D'"},device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
                        }
                        if (_onlineModelViewerCubit.isDialogShowing && state is GetJoystickCoordinatesState) {
                          onMenuClose();
                          _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.ContextMenu.clearLongpressSelection()");
                        }
                        if (state is MenuOptionLoadedState || state is CalibrationListPresentState || state is LoadedSuccessfulAllModelState || state is NormalWebState || state is UnitCalibrationUpdateState || (state is GetJoystickCoordinatesState && !_onlineModelViewerCubit.isShowPdf)) {
                          if (orientation == Orientation.portrait) {
                            _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '${Orientation.portrait}', view : ${(state is MenuOptionLoadedState && state.isShowPdfView) || ((state is NormalWebState || state is UnitCalibrationUpdateState || state is LoadedSuccessfulAllModelState) && _onlineModelViewerCubit.isShowPdf) ? "'3D/2D'" : "'3D'"},device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
                          } else {
                            _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '${Orientation.landscape}', view : ${(state is MenuOptionLoadedState && state.isShowPdfView) || ((state is NormalWebState || state is UnitCalibrationUpdateState || state is LoadedSuccessfulAllModelState) && _onlineModelViewerCubit.isShowPdf) ? "'3D/2D'" : "'3D'"},device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
                          }
                        }
                        return IgnorePointer(
                          ignoring: !_sideToolBarCubit.isSideToolBarEnabled,
                          child: Column(
                            children: [
                              Expanded(
                                child: Container(
                                  color: AColors.white,
                                  child: SingleChildScrollView(
                                    controller: _scrollController,
                                    physics: const NeverScrollableScrollPhysics(),
                                    child: Stack(
                                      children: [
                                        Row(
                                          children: [
                                            Utility.isTablet
                                                ? Container()
                                                : SizedBox(
                                                    height: MediaQuery.of(context).size.height - (AppBar().preferredSize.height),
                                                    child: Visibility(
                                                      visible: _onlineModelViewerCubit.isShowSideToolBar,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          border: Border(
                                                            right: BorderSide(
                                                              color: AColors.lightGreyColor, // Set the color of the right border
                                                              width: 1.0, // Set the width of the right border
                                                            ),
                                                          ),
                                                        ),
                                                        width: (Utility.isTablet && orientation == Orientation.landscape)
                                                            ? MediaQuery.of(context).size.width * 0.04
                                                            : Utility.isTablet && orientation == Orientation.portrait
                                                                ? MediaQuery.of(context).size.width * 0.08
                                                                : MediaQuery.of(context).size.width * 0.13,
                                                        child: SideToolbarScreen(
                                                          key: Key('key_side_tool_bar_widget'),
                                                          isWhite: state is CalibrationListResponseSuccessState ? true : false,
                                                          isOnlineModelViewerScreen: true,
                                                          isModelSelected: false,
                                                          onlineModelViewerCubit: _onlineModelViewerCubit,
                                                          orientation: orientation,
                                                          isPdfViewISFull: _pdfTronCubit.isFullViewPdfTron,
                                                          modelId: widget.onlineModelViewerArguments.onlineViewerModelRequestModel.modelId!,
                                                          modelName: widget.onlineModelViewerArguments.onlineViewerModelRequestModel.modelName!,
                                                        ),
                                                      ),
                                                    ),
                                                    key: Key("key_online_mobile_sizBox")),
                                            Expanded(
                                              child: SafeArea(
                                                bottom: false,
                                                child: SizedBox(
                                                  height: MediaQuery.of(context).size.height - (kBottomNavigationBarHeight - (MediaQuery.of(context).padding.bottom) + 80),
                                                  width: MediaQuery.of(context).size.width,
                                                  child: Stack(
                                                    children: [
                                                      Flex(
                                                        key: Key('key_web_view_flex'),
                                                        direction: orientation == Orientation.portrait ? Axis.vertical : Axis.horizontal,
                                                        verticalDirection: _onlineModelViewerCubit.isShowPdf ? VerticalDirection.up : VerticalDirection.down,
                                                        children: [
                                                          SingleChildScrollView(
                                                            physics: NeverScrollableScrollPhysics(),
                                                            child: SizedBox(
                                                              height: orientation == Orientation.portrait
                                                                  ? (state is MenuOptionLoadedState && state.isShowPdfView && !state.isShowPdfViewFullScreen) ||
                                                                          (state is LoadedSuccessfulAllModelState && _onlineModelViewerCubit.isShowPdf) ||
                                                                          (getIt<model_tree.ModelTreeCubit>().state is model_tree.UpdatedState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) ||
                                                                          (getIt<model_tree.ModelTreeCubit>().state is model_tree.LoadedState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) ||
                                                                          (state is LoadedSuccessfullyState && _onlineModelViewerCubit.isShowPdf) ||
                                                                          (state is LoadedModelState && _onlineModelViewerCubit.isShowPdf) ||
                                                                          (state is LoadedState && _onlineModelViewerCubit.isShowPdf) ||
                                                                          (state is LoadingState && _onlineModelViewerCubit.isShowPdf) ||
                                                                          (state is CalibrationListPresentState && _onlineModelViewerCubit.isShowPdf) ||
                                                                          (state is NormalWebState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) ||
                                                                          (state is GetJoystickCoordinatesState && state.longPress == 'true') ||
                                                                          (state is ShowPopUpState || state is HIdePopUpState && _onlineModelViewerCubit.isShowPdf || state is FileAssociationLoadingState && _onlineModelViewerCubit.isShowPdf || (state is ShowBackGroundWebviewState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) || (state is UnitCalibrationUpdateState && _onlineModelViewerCubit.isShowPdf))
                                                                      ? MediaQuery.of(context).size.height * 0.48
                                                                      : (state is MenuOptionLoadedState && state.isShowPdfViewFullScreen) || (state is GetJoystickCoordinatesState && state.longPress == 'true') || (state is NormalWebState && _onlineModelViewerCubit.isFullPdf) || (state is ShowBackGroundWebviewState && _onlineModelViewerCubit.isFullPdf)
                                                                          ? 0.0
                                                                          : MediaQuery.of(context).size.height - (kBottomNavigationBarHeight - MediaQuery.of(context).padding.bottom + 80)
                                                                  : MediaQuery.of(context).size.height - kBottomNavigationBarHeight - MediaQuery.of(context).padding.bottom - 80,
                                                              width: orientation == Orientation.portrait
                                                                  ? MediaQuery.of(context).size.width
                                                                  : (state is MenuOptionLoadedState && state.isShowPdfView && !state.isShowPdfViewFullScreen) ||
                                                                          (state is LoadedSuccessfulAllModelState && _onlineModelViewerCubit.isShowPdf) ||
                                                                          (getIt<model_tree.ModelTreeCubit>().state is model_tree.UpdatedState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) ||
                                                                          (getIt<model_tree.ModelTreeCubit>().state is model_tree.LoadedState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) ||
                                                                          (state is LoadedSuccessfullyState && _onlineModelViewerCubit.isShowPdf) ||
                                                                          (state is LoadedModelState && _onlineModelViewerCubit.isShowPdf) ||
                                                                          (state is LoadedState && _onlineModelViewerCubit.isShowPdf) ||
                                                                          (state is CalibrationListPresentState && _onlineModelViewerCubit.isShowPdf) ||
                                                                          (state is LoadingState && _onlineModelViewerCubit.isShowPdf) ||
                                                                          (state is NormalWebState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) ||
                                                                          (state is GetJoystickCoordinatesState && state.longPress == 'true') ||
                                                                          (state is ShowPopUpState || state is HIdePopUpState && _onlineModelViewerCubit.isShowPdf || state is FileAssociationLoadingState && _onlineModelViewerCubit.isShowPdf || (state is ShowBackGroundWebviewState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) || (state is UnitCalibrationUpdateState && _onlineModelViewerCubit.isShowPdf))
                                                                      ? MediaQuery.of(context).size.width * 0.5
                                                                      : (state is MenuOptionLoadedState && state.isShowPdfViewFullScreen) || (state is GetJoystickCoordinatesState && state.longPress == 'true') || (state is ShowBackGroundWebviewState && _onlineModelViewerCubit.isFullPdf) || (state is NormalWebState && _onlineModelViewerCubit.isFullPdf)
                                                                          ? 0.0
                                                                          : (state is MenuOptionLoadedState && state.isShowPdfView)
                                                                              ? MediaQuery.of(context).size.width * 0.495
                                                                              : MediaQuery.of(context).size.width * 0.995,
                                                              child: Stack(
                                                                key: Key('key_web_view_stack'),
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Utility.isTablet
                                                                          ? Visibility(
                                                                              key: Key('key_side_tool_bar_visibility'),
                                                                              visible: _onlineModelViewerCubit.isShowSideToolBar,
                                                                              child: Container(
                                                                                decoration: BoxDecoration(
                                                                                  border: Border(
                                                                                    right: BorderSide(
                                                                                      color: AColors.lightGreyColor, // Set the color of the right border
                                                                                      width: 1.0, // Set the width of the right border
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                width: (Utility.isTablet && orientation == Orientation.landscape)
                                                                                    ? MediaQuery.of(context).size.width * 0.038
                                                                                    : Utility.isTablet && orientation == Orientation.portrait
                                                                                        ? MediaQuery.of(context).size.width * 0.06
                                                                                        : MediaQuery.of(context).size.width * 0.16,
                                                                                child: SideToolbarScreen(
                                                                                  key: Key('key_side_tool_bar_widget'),
                                                                                  isWhite: state is CalibrationListResponseSuccessState ? true : false,
                                                                                  isOnlineModelViewerScreen: true,
                                                                                  isModelSelected: false,
                                                                                  onlineModelViewerCubit: _onlineModelViewerCubit,
                                                                                  orientation: orientation,
                                                                                  isPdfViewISFull: _pdfTronCubit.isFullViewPdfTron,
                                                                                  modelId: widget.onlineModelViewerArguments.onlineViewerModelRequestModel.modelId!,
                                                                                  modelName: widget.onlineModelViewerArguments.onlineViewerModelRequestModel.modelName!,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : Container(),
                                                                      Expanded(
                                                                        key: Key('key_web_view_expanded'),
                                                                        child: IgnorePointer(
                                                                          key: Key('key_web_view_ignore_pointer'),
                                                                          ignoring: (state is CalibrationListResponseSuccessState && state.items.isNotEmpty) || state is LoadedAllModelState || state is LoadedSuccessfullyState || state is LoadingModelsState || state is LoadedModelState || state is LoadingState,
                                                                          child: GestureDetector(
                                                                            onLongPressStart: (LongPressStartDetails details) {
                                                                              onTapUp(context, details, orientation, state);
                                                                              if (_pdfTronCubit.selectedCalibration != null && _pdfTronCubit.selectedCalibrationHandle != null) {
                                                                                _onlineModelViewerCubit.webviewController.evaluateJavascript(
                                                                                    source: "nCircle.Ui.Joystick.getJoystickOverlayState({x : ${_onlineModelViewerCubit.posX}, y : ${_onlineModelViewerCubit.posY},"
                                                                                        "width  : ${_onlineModelViewerCubit.width},height : ${_onlineModelViewerCubit.height},value : ${1}})");
                                                                              } else {
                                                                                _onlineModelViewerCubit.webviewController.evaluateJavascript(
                                                                                    source: "nCircle.Ui.Joystick.getJoystickOverlayState({x : ${_onlineModelViewerCubit.posX}, y : ${_onlineModelViewerCubit.posY},"
                                                                                        "width  : ${_onlineModelViewerCubit.width},height : ${_onlineModelViewerCubit.height},value : ${0}})");
                                                                              }
                                                                            },
                                                                            onLongPressMoveUpdate: (details) {
                                                                              onTapMove(context, details, orientation, state);
                                                                              _onlineModelViewerCubit.webviewController.evaluateJavascript(
                                                                                  source: "nCircle.Ui.Joystick.onLongpressMove({x : ${_onlineModelViewerCubit.posX}, y : ${_onlineModelViewerCubit.posY},"
                                                                                      "width  : ${_onlineModelViewerCubit.width},height : ${_onlineModelViewerCubit.height},value : ${0}})");
                                                                            },
                                                                            onLongPressEnd: (LongPressEndDetails details) {
                                                                              _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.onLongpressTouchEnd()");
                                                                              onTapDown(context, details, orientation, state);
                                                                              if ((state is GetJoystickCoordinatesState && state.bIsInside != "1") || state is LoadedSuccessfulAllModelState) {
                                                                                _onlineModelViewerCubit.isShowContextMenu = true;
                                                                                _showTooltipDialog(details, orientation);
                                                                                _onlineModelViewerCubit.isDialogShowing = true;
                                                                              }
                                                                            },
                                                                            onTapDown: (TapDownDetails details) {
                                                                              touchPosition = details.globalPosition;
                                                                            },
                                                                            child: InAppWebView(
                                                                                key: Key('key_in_app_web_view'),
                                                                                initialUrlRequest: URLRequest(url: Uri.parse("")),
                                                                                initialOptions: inAppWebViewGroupOptions(Uri.parse('file://${AppPathHelper().basePath}')),
                                                                                iosOnWebContentProcessDidTerminate: (controller) {
                                                                                  _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "hwv.closeConnection()");
                                                                                  _onlineModelViewerCubit.insufficientStorage();
                                                                                },
                                                                                onWebViewCreated: (controller) async {
                                                                                  _onlineModelViewerCubit.webviewController = controller;
                                                                                  _pdfTronCubit.webviewController = controller;
                                                                                  if (isNetWorkConnected()) {
                                                                                    _onlineModelViewerCubit.webviewController.loadUrl(urlRequest: URLRequest(url: Uri.file("${await AppPathHelper().getAssetOfflineZipPath()}/files/online.html")));
                                                                                  } else {
                                                                                    _onlineModelViewerCubit.webviewController.loadUrl(urlRequest: URLRequest(url: Uri.file("${await AppPathHelper().getAssetOfflineZipPath()}/files/offline.html")));
                                                                                  }
                                                                                  Future.delayed(Duration(seconds: 2));
                                                                                  _onlineModelViewerCubit.loadModelOnline(widget.onlineModelViewerArguments.projectId, widget.onlineModelViewerArguments.onlineViewerModelRequestModel.modelId!, widget.onlineModelViewerArguments.model.revisionId!, widget.onlineModelViewerArguments.onlineViewerModelRequestModel.bimModelList);
                                                                                }),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Positioned(
                                                                    key: Key('key_positioned_widget'),
                                                                    top: (AppBar().preferredSize.height + 12) * 0.4,
                                                                    left: 0,
                                                                    right: 0,
                                                                    child: Center(
                                                                      child: Opacity(
                                                                        opacity: 0.1,
                                                                        child: GestureDetector(
                                                                            onTap: () {},
                                                                            child: Container(
                                                                              clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                              width: 100,
                                                                              height: 36,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(3), topLeft: Radius.circular(3), topRight: Radius.circular(3), bottomRight: Radius.circular(3)),
                                                                                color: Colors.transparent,
                                                                              ),
                                                                              child: const InAppWebView(),
                                                                            )),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    top: (AppBar().preferredSize.height + 12) * 0.4,
                                                                    left: 0,
                                                                    right: 0,
                                                                    child: Visibility(
                                                                      key: Key('key_visibility_three_hybrid_button'),
                                                                      visible: _onlineModelViewerCubit.isShowSideToolBar,
                                                                      child: Center(
                                                                        child: Stack(
                                                                          children: [
                                                                            Row(
                                                                              key: Key('key_row_three_hybrid_button'),
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                GestureDetector(
                                                                                  onTap: () {
                                                                                    _onlineModelViewerCubit.is3DVisible = true;
                                                                                    if (_onlineModelViewerCubit.isCalibListPressed) {
                                                                                      _pdfTronCubit.selectedCalibrationHandle = null;
                                                                                      _onlineModelViewerCubit.togglePdfTronVisibility(false, _onlineModelViewerCubit.selectedPdfFileName, false, false);
                                                                                      _pdfTronCubit.lastSavedXPoint = -99999;
                                                                                      _pdfTronCubit.lastSavedYPoint = -99999;
                                                                                      _onlineModelViewerCubit.calibList.clear();
                                                                                      _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '$orientation', view : '3D',device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
                                                                                    }
                                                                                  },
                                                                                  child: Container(
                                                                                    key: Key('key_container_three_button'),
                                                                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                                                                    width: 50,
                                                                                    height: 36,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(3), topLeft: Radius.circular(3)),
                                                                                      color: (state is LoadedSuccessfulAllModelState || state is NormalWebState || state is LoadedSuccessfullyState || state is LoadingModelsState || getIt<model_tree.ModelTreeCubit>().state is model_tree.UpdatedState || getIt<model_tree.ModelTreeCubit>().state is model_tree.LoadedState || state is LoadedModelState || state is LoadingState || state is LoadedState || state is LoadedAllModelState || state is ShowBackGroundWebviewState || state is UnitCalibrationUpdateState || state is JoyStickPositionState || state is CalibrationListPresentState || (state is CalibrationListResponseSuccessState && state.items.isEmpty) || (state is GetJoystickCoordinatesState && !_onlineModelViewerCubit.isShowPdfView) || (state is MenuOptionLoadedState && !state.isShowPdfView) || (state is MenuOptionLoadedState && !state.isShowPdfView)) && !_onlineModelViewerCubit.isShowPdfView ? AColors.aPrimaryColor : AColors.themeBlueColor,
                                                                                    ),
                                                                                    child: Center(
                                                                                      child: Image.asset(
                                                                                        AImageConstants.threeDIcon,
                                                                                        color: Colors.white,
                                                                                        height: 18,
                                                                                        width: 18,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                const SizedBox(width: 2),
                                                                                GestureDetector(
                                                                                  onTap: () {
                                                                                    Utility.closeBanner();
                                                                                    _onlineModelViewerCubit.is3DVisible = false;
                                                                                    if (_onlineModelViewerCubit.isCalibListPressed) {
                                                                                      if (_onlineModelViewerCubit.isFirstTime || _onlineModelViewerCubit.calibrationList.isNotEmpty) {
                                                                                        if (_sideToolBarCubit.isSideToolBarEnabled) {
                                                                                          if (_pdfTronCubit.selectedCalibration == null) {
                                                                                            _onlineModelViewerCubit.getCalibrationList(_onlineModelViewerCubit.selectedProject.projectID!, widget.onlineModelViewerArguments.onlineViewerModelRequestModel.modelId!, false).then((value) => {
                                                                                                  value.removeWhere((element) => element.calibrationName.toString().trim().isEmpty),
                                                                                                  _sideToolBarCubit.isWhite = true,
                                                                                                  _onlineModelViewerCubit.calibList = value,
                                                                                                  _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '$orientation', view : '2D/3D',device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})"),
                                                                                                });
                                                                                          } else {
                                                                                            _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '$orientation', view : '2D/3D',device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
                                                                                            _onlineModelViewerCubit.togglePdfTronVisibility(true, _pdfTronCubit.selectedCalibration!.fileName, false, false);
                                                                                            if (isNetWorkConnected()) {
                                                                                              _onlineModelViewerCubit.setParallelViewAuditTrail(_onlineModelViewerCubit.selectedProject.projectID!, "Field", "Coordinate View", ActionConstants.actionId98, widget.onlineModelViewerArguments.onlineViewerModelRequestModel.modelId!, _pdfTronCubit.selectedCalibration!.calibrationId);
                                                                                            }
                                                                                            _pdfTronCubit.selectedCalibrationHandle = _pdfTronCubit.selectedCalibration;
                                                                                          }
                                                                                        }
                                                                                      } else if (!_onlineModelViewerCubit.isFirstTime && _onlineModelViewerCubit.calibrationList.isEmpty) {
                                                                                        _sideToolBarCubit.isWhite = false;
                                                                                        _onlineModelViewerCubit.isShowPdf = false;
                                                                                        _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '$orientation', view : '3D',device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
                                                                                        context.shownCircleSnackBarAsBanner(context.toLocale!.warning, AConstants.couldNotFindCalibData, Icons.warning, Colors.orange);
                                                                                      }
                                                                                    }
                                                                                  },
                                                                                  child: Container(
                                                                                    key: Key('key_row_hybrid_button'),
                                                                                    width: 50,
                                                                                    height: 36,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: const BorderRadius.only(
                                                                                        bottomRight: Radius.circular(3),
                                                                                        topRight: Radius.circular(3),
                                                                                      ),
                                                                                      color: ((state is MenuOptionLoadedState && state.isShowPdfView) || (getIt<model_tree.ModelTreeCubit>().state is model_tree.UpdatedState && _onlineModelViewerCubit.isShowPdfView) || (getIt<model_tree.ModelTreeCubit>().state is model_tree.LoadedState && _onlineModelViewerCubit.isShowPdfView) || (state is GetJoystickCoordinatesState && _onlineModelViewerCubit.isShowPdfView) || (state is ShowBackGroundWebviewState && _onlineModelViewerCubit.isShowPdfView) || (state is UnitCalibrationUpdateState && _onlineModelViewerCubit.isShowPdfView) || (state is NormalWebState && _onlineModelViewerCubit.isShowPdf) && _onlineModelViewerCubit.isShowPdfView) || (state is CalibrationListResponseSuccessState && state.items.isNotEmpty) ? AColors.aPrimaryColor : AColors.themeBlueColor,
                                                                                    ),
                                                                                    child: Center(
                                                                                        child: Transform.rotate(
                                                                                      key: Key('key_transform_rotate'),
                                                                                      angle: (Utility.isTablet && orientation == Orientation.portrait) || !Utility.isTablet ? 0 : 252.9,
                                                                                      child: Image.asset(
                                                                                        AImageConstants.splitHorizontallyAlt,
                                                                                        scale: Utility.isTablet ? 0.8 : 1.1,
                                                                                        height: 18,
                                                                                        width: 18,
                                                                                        color: AColors.white,
                                                                                      ),
                                                                                    )),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    key: Key('key_load_message_positioned_widget'),
                                                                    top: 8.0,
                                                                    left: 0.0,
                                                                    right: 0.0,
                                                                    child: Visibility(
                                                                      visible: _onlineModelViewerCubit.isShowSideToolBar && state is! MenuOptionLoadedState,
                                                                      child: Center(
                                                                        child: Text(
                                                                          state is LoadedSuccessfullyState
                                                                              ? AConstants.modelsLoadedSuccessfully
                                                                              : state is LoadedSuccessfulAllModelState
                                                                                  ? ""
                                                                                  : state is LoadedAllModelState && state is! LoadedSuccessfulAllModelState && state is! LoadedSuccessfullyState && state is! LoadingModelsState && state is! LoadedModelState
                                                                                      ? 'Loading model ${_onlineModelViewerCubit.totalNumbersOfModelsLoad} of ${_onlineModelViewerCubit.totalNumbersOfModels}'
                                                                                      : state is LoadingModelsState
                                                                                          ? 'Loading model ${_onlineModelViewerCubit.totalNumbersOfModelsLoad} of ${_onlineModelViewerCubit.totalNumbersOfModels}'
                                                                                          : state is LoadingModelsState && (_onlineModelViewerCubit.totalNumbersOfModelsLoad == _onlineModelViewerCubit.totalNumbersOfModels)
                                                                                              ? AConstants.modelsLoadedSuccessfully
                                                                                              : state is LoadedModelState
                                                                                                  ? 'Loading model ${_onlineModelViewerCubit.totalNumbersOfModelsLoad} of ${_onlineModelViewerCubit.totalNumbersOfModels}'
                                                                                                  : state is DeletedModelState
                                                                                                      ? 'Unloading models'
                                                                                                      : (state is LoadingState || state is LoadedState)
                                                                                                          ? 'Loading model ${_onlineModelViewerCubit.totalNumbersOfModelsLoad} of ${_onlineModelViewerCubit.totalNumbersOfModels}'
                                                                                                          : '',
                                                                          key: Key('key_load_message_text_widget'),
                                                                          style: TextStyle(color: AColors.lightGreyColor, fontFamily: "Sofia", fontWeight: AFontWight.bold, fontSize: 14),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  (state is CalibrationListResponseSuccessState && state.items.isNotEmpty) || ((state is ShowBackGroundWebviewState || state is NormalWebState) && _onlineModelViewerCubit.isCalibListShow)
                                                                      ? Stack(
                                                                          key: Key('key_widget_stack'),
                                                                          children: [
                                                                            Container(
                                                                                color: Colors.transparent,
                                                                                width: MediaQuery.of(context).size.width,
                                                                                height: MediaQuery.of(context).size.height,
                                                                                margin: EdgeInsets.only(
                                                                                    left: Utility.isTablet && orientation == Orientation.portrait
                                                                                        ? 60
                                                                                        : Utility.isTablet && orientation == Orientation.landscape
                                                                                            ? 50
                                                                                            : 0),
                                                                                child: Opacity(
                                                                                  opacity: 0.1,
                                                                                  child: InAppWebView(
                                                                                    onWebViewCreated: (controller) {},
                                                                                  ),
                                                                                )),
                                                                            Container(
                                                                              key: Key('key_container_widget'),
                                                                              width: Utility.isTablet
                                                                                  ? orientation == Orientation.portrait
                                                                                      ? MediaQuery.of(context).size.width / 1.6
                                                                                      : MediaQuery.of(context).size.width / 2.4
                                                                                  : MediaQuery.of(context).size.width,
                                                                              height: MediaQuery.of(context).size.height,
                                                                              margin: EdgeInsets.only(
                                                                                  left: Utility.isTablet && orientation == Orientation.portrait
                                                                                      ? MediaQuery.of(context).size.width * 0.06
                                                                                      : Utility.isTablet && orientation == Orientation.landscape
                                                                                          ? MediaQuery.of(context).size.width * 0.038
                                                                                          : 0),
                                                                              color: AColors.white,
                                                                              child: ListView.builder(
                                                                                key: Key('key_calibList_list_view_widget'),
                                                                                padding: EdgeInsets.only(bottom: Utility.isIos ? 160 : 140),
                                                                                itemCount: _onlineModelViewerCubit.calibList.length,
                                                                                physics: const BouncingScrollPhysics(),
                                                                                itemBuilder: (context, index) {
                                                                                  if (orientation == Orientation.portrait) {
                                                                                    _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '${Orientation.portrait}', view : ${"'3D'"},device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
                                                                                  } else {
                                                                                    _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '${Orientation.landscape}', view : ${"'3D'"},device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
                                                                                  }
                                                                                  return GestureDetector(
                                                                                    onTap: () {
                                                                                      _sideToolBarCubit.isWhite = false;
                                                                                      _onlineModelViewerCubit.selectedPdfFileName = _onlineModelViewerCubit.calibList[index].calibrationName;
                                                                                      Map<String, dynamic> map = {};
                                                                                      map[RequestConstants.projectId] = _onlineModelViewerCubit.selectedProject.projectID;
                                                                                      map[RequestConstants.folderId] = _onlineModelViewerCubit.calibList[index].folderId;
                                                                                      map[RequestConstants.revisionId] = _onlineModelViewerCubit.calibList[index].revisionId;
                                                                                      _pdfTronCubit.downloadPdf(map).then((value) {
                                                                                        _pdfTronCubit.selectedCalibration = _onlineModelViewerCubit.calibList[index];
                                                                                        _pdfTronCubit.selectedCalibrationHandle = _pdfTronCubit.selectedCalibration;
                                                                                        _pdfTronCubit.newCalibrationData();
                                                                                        _onlineModelViewerCubit.togglePdfTronVisibility(true, _onlineModelViewerCubit.calibList[index].fileName, false, false);
                                                                                        _onlineModelViewerCubit.selectedPdfFileName = _onlineModelViewerCubit.calibList[index].calibrationName;
                                                                                        if (isNetWorkConnected()) {
                                                                                          _onlineModelViewerCubit.setParallelViewAuditTrail(_onlineModelViewerCubit.selectedProject.projectID!, "Field", "Coordinate View", ActionConstants.actionId98, widget.onlineModelViewerArguments.onlineViewerModelRequestModel.modelId!, _pdfTronCubit.selectedCalibration!.calibrationId);
                                                                                        }
                                                                                      });
                                                                                      _onlineModelViewerCubit.isCalibListShow = false;
                                                                                    },
                                                                                    child: Container(
                                                                                      key: Key('key_container_widget_calib_list'),
                                                                                      color: _onlineModelViewerCubit.selectedCalibrationName.toLowerCase() == _onlineModelViewerCubit.calibList[index].calibrationName.toLowerCase() && (_pdfTronCubit.selectedCalibration != null && _pdfTronCubit.selectedCalibration!.calibrationId == _onlineModelViewerCubit.calibList[index].calibrationId)
                                                                                          ? AColors.themeLightColor
                                                                                          : index % 2 == 0
                                                                                              ? Colors.grey[200]
                                                                                              : AColors.white,
                                                                                      child: ListTile(
                                                                                        tileColor: AColors.white,
                                                                                        leading: Padding(
                                                                                          padding: const EdgeInsets.only(top: 8.0),
                                                                                          child: SizedBox(
                                                                                            width: Utility.isTablet ? 96 : 70,
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                              children: [
                                                                                                Container(
                                                                                                  decoration: BoxDecoration(
                                                                                                    border: Border.all(),
                                                                                                    borderRadius: const BorderRadius.all(
                                                                                                      Radius.circular(4),
                                                                                                    ),
                                                                                                    color: AColors.white,
                                                                                                  ),
                                                                                                  padding: const EdgeInsets.all(5),
                                                                                                  child: Image.asset(
                                                                                                    AImageConstants.splitVerticallyAlt,
                                                                                                    height: Utility.isTablet ? 20 : 20,
                                                                                                    width: Utility.isTablet ? 20 : 20,
                                                                                                    color: const Color.fromRGBO(117, 117, 117, 1),
                                                                                                  ),
                                                                                                ),
                                                                                                const SizedBox(
                                                                                                  width: 5,
                                                                                                ),
                                                                                                Image.asset(
                                                                                                  AImageConstants.pdfIcon,
                                                                                                  height: Utility.isTablet ? 30 : 30,
                                                                                                  width: Utility.isTablet ? 30 : 30,
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        title: Text(
                                                                                          _onlineModelViewerCubit.calibList[index].calibrationName,
                                                                                          textScaleFactor: 1,
                                                                                        ),
                                                                                        subtitle: Text(
                                                                                          _onlineModelViewerCubit.calibList[index].fileName,
                                                                                          textScaleFactor: 1,
                                                                                          maxLines: 1,
                                                                                          overflow: TextOverflow.ellipsis,
                                                                                        ),
                                                                                        trailing: SizedBox(
                                                                                          width: 110,
                                                                                          child: Row(
                                                                                            mainAxisSize: MainAxisSize.min,
                                                                                            children: [
                                                                                              Flexible(
                                                                                                child: Column(
                                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                                                                  children: [
                                                                                                    Text(
                                                                                                      getFormattedDate(_onlineModelViewerCubit.calibList[index].createdDate.toString().split('#')[0]),
                                                                                                      textScaleFactor: 1,
                                                                                                    ),
                                                                                                    const SizedBox(
                                                                                                      height: 5,
                                                                                                    ),
                                                                                                    Text(
                                                                                                      "${_onlineModelViewerCubit.calibList[index].sizeOf2DFile} KB",
                                                                                                      textScaleFactor: 1,
                                                                                                    )
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                              const SizedBox(
                                                                                                width: 8,
                                                                                              ),
                                                                                              const Icon(
                                                                                                Icons.restore,
                                                                                                size: 20,
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  );
                                                                                },
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : (state is CalibrationListResponseSuccessState && state.items.isEmpty) || ((state is ShowBackGroundWebviewState || state is NormalWebState) && _onlineModelViewerCubit.isCalibListShow)
                                                                          ? Stack(
                                                                              children: [
                                                                                Container(
                                                                                    color: Colors.transparent,
                                                                                    width: MediaQuery.of(context).size.width,
                                                                                    height: MediaQuery.of(context).size.height,
                                                                                    margin: EdgeInsets.only(
                                                                                        left: Utility.isTablet && orientation == Orientation.portrait
                                                                                            ? 60
                                                                                            : Utility.isTablet && orientation == Orientation.landscape
                                                                                                ? 50
                                                                                                : 0),
                                                                                    child: Opacity(
                                                                                      opacity: 0.1,
                                                                                      child: InAppWebView(
                                                                                        onWebViewCreated: (controller) {},
                                                                                      ),
                                                                                    )),
                                                                                Container(
                                                                                  width: Utility.isTablet
                                                                                      ? orientation == Orientation.portrait
                                                                                          ? MediaQuery.of(context).size.width / 1.6
                                                                                          : MediaQuery.of(context).size.width / 2.4
                                                                                      : MediaQuery.of(context).size.width,
                                                                                  height: MediaQuery.of(context).size.height,
                                                                                  margin: EdgeInsets.only(
                                                                                      left: Utility.isTablet && orientation == Orientation.portrait
                                                                                          ? MediaQuery.of(context).size.width * 0.06
                                                                                          : Utility.isTablet && orientation == Orientation.landscape
                                                                                              ? MediaQuery.of(context).size.width * 0.038
                                                                                              : 0),
                                                                                  color: AColors.white,
                                                                                  child: Center(
                                                                                    child: Text('No Records Available'),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : Container(),
                                                                  state is ShowBackGroundWebviewState && Utility.isIos
                                                                      ? Stack(
                                                                          key: Key('key_show_web_view_widget'),
                                                                          children: [
                                                                            Container(
                                                                              key: const Key('key_show_web_view_widget'),
                                                                              color: Colors.transparent,
                                                                              width: MediaQuery.of(context).size.width,
                                                                              height: MediaQuery.of(context).size.height,
                                                                              child: Opacity(
                                                                                opacity: 0.1,
                                                                                child: InAppWebView(
                                                                                  key: Key('key_in_web_view_widget'),
                                                                                  onWebViewCreated: (controller) {},
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : Container(
                                                                          key: Key('key_show_web_view_widget_empty_container'),
                                                                        ),
                                                                  Positioned(
                                                                    right: 0.0,
                                                                    top: (AppBar().preferredSize.height + 12) * 0.4,
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        _onlineModelViewerCubit.isSnaggingClick();

                                                                        _onlineModelViewerCubit.isTaskFormListing = true;
                                                                        _onlineModelViewerCubit.callViewObjectFileAssociationDetails();
                                                                        _onlineModelViewerCubit.key.currentState?.openEndDrawer();
                                                                        getIt<snagging_cubit.TaskFormListingCubit>().getTaskFormListingList(widget.onlineModelViewerArguments.model.modelId!);
                                                                      },
                                                                      child: AnimatedContainer(
                                                                        alignment: Alignment.centerLeft,
                                                                        duration: Duration(milliseconds: 400),
                                                                        curve: Curves.easeOut,
                                                                        height: 45,
                                                                        width: _onlineModelViewerCubit.isSnaggingOpen
                                                                            ? Orientation.portrait == orientation
                                                                                ? MediaQuery.of(context).size.width * 0.55 + 45
                                                                                : MediaQuery.of(context).size.width * 0.45 + 45
                                                                            : 45.0,
                                                                        padding: EdgeInsets.only(left: 8),
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: const BorderRadius.only(
                                                                            bottomLeft: Radius.circular(6),
                                                                            topLeft: Radius.circular(6),
                                                                          ),
                                                                          color: AColors.lightBlue,
                                                                        ),
                                                                        child: Image.asset(
                                                                          AImageConstants.viewTaskForms,
                                                                          height: 48,
                                                                          width: 48,
                                                                          color: AColors.white,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Positioned(
                                                                    right: 0.0,
                                                                    top: ((AppBar().preferredSize.height + 12) * 0.4) * 3.4,
                                                                    child: GestureDetector(
                                                                      onTap: () {
                                                                        _onlineModelViewerCubit.isSnaggingClick();

                                                                        _onlineModelViewerCubit.isSnaggingFilterClick();
                                                                      },
                                                                      child: AnimatedContainer(
                                                                        alignment: Alignment.centerLeft,
                                                                        duration: Duration(milliseconds: 400),
                                                                        curve: Curves.easeOut,
                                                                        height: 45,
                                                                        width: _onlineModelViewerCubit.isSnaggingOpen
                                                                            ? Orientation.portrait == orientation
                                                                                ? MediaQuery.of(context).size.width * 0.55 + 45
                                                                                : MediaQuery.of(context).size.width * 0.45 + 45
                                                                            : 45.0,
                                                                        padding: EdgeInsets.only(left: 16),
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: const BorderRadius.only(
                                                                            bottomLeft: Radius.circular(6),
                                                                            topLeft: Radius.circular(6),
                                                                          ),
                                                                          color: AColors.white,
                                                                        ),
                                                                        child: Icon(
                                                                          Icons.filter_alt_rounded,
                                                                          size: 24,
                                                                          color: AColors.lightBlue,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  MultiBlocListener(
                                                                    listeners: [
                                                                      BlocListener<snagging_cubit.TaskFormListingCubit, snagging_cubit.TaskFormListingState>(
                                                                        listener: (context, state) {},
                                                                      ),
                                                                    ],
                                                                    child: BlocBuilder<snagging_cubit.TaskFormListingCubit, snagging_cubit.TaskFormListingState>(builder: (context, state) {
                                                                      return Positioned(
                                                                        right: 0.0,
                                                                        //top: ((AppBar().preferredSize.height + 12) * 0.4),
                                                                        child: AnimatedContainer(
                                                                            alignment: Alignment.centerLeft,
                                                                            duration: Duration(milliseconds: 400),
                                                                            curve: Curves.easeOut,
                                                                            height: MediaQuery.of(context).size.height,
                                                                            width: _onlineModelViewerCubit.isSnaggingOpen
                                                                                ? Orientation.portrait == orientation
                                                                                    ? state is snagging_cubit.FullScreenFormViewState && state.isFullScreen
                                                                                        ? MediaQuery.of(context).size.width
                                                                                        : MediaQuery.of(context).size.width * 0.55
                                                                                    : state is snagging_cubit.FullScreenFormViewState && state.isFullScreen
                                                                                        ? MediaQuery.of(context).size.width
                                                                                        : MediaQuery.of(context).size.width * 0.55
                                                                                : 0.0,
                                                                            decoration: BoxDecoration(
                                                                              borderRadius: const BorderRadius.only(
                                                                                bottomLeft: Radius.circular(6),
                                                                                topLeft: Radius.circular(6),
                                                                              ),
                                                                              color: AColors.white,
                                                                            ),
                                                                            child: TaskFormListingWidget(modelId: widget.onlineModelViewerArguments.model.modelId!)),
                                                                      );
                                                                    }),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            key: Key('key_widget_expanded'),
                                                            child: Visibility(
                                                              key: Key('key_widget_visibility'),
                                                              visible: (state is MenuOptionLoadedState && state.isShowPdfView) ||
                                                                  (state is GetJoystickCoordinatesState && state.longPress == 'true') ||
                                                                  (getIt<model_tree.ModelTreeCubit>().state is model_tree.UpdatedState && _onlineModelViewerCubit.isShowPdf) ||
                                                                  (getIt<model_tree.ModelTreeCubit>().state is model_tree.LoadedState && _onlineModelViewerCubit.isShowPdf) ||
                                                                  (state is NormalWebState && _onlineModelViewerCubit.isShowPdf) ||
                                                                  (state is LoadedSuccessfulAllModelState && _onlineModelViewerCubit.isShowPdf) ||
                                                                  (state is LoadedSuccessfullyState && _onlineModelViewerCubit.isShowPdf) ||
                                                                  (state is LoadedModelState && _onlineModelViewerCubit.isShowPdf) ||
                                                                  (state is LoadedState && _onlineModelViewerCubit.isShowPdf) ||
                                                                  (state is LoadingState && _onlineModelViewerCubit.isShowPdf) ||
                                                                  (state is UnitCalibrationUpdateState && _onlineModelViewerCubit.isShowPdf) ||
                                                                  (state is FileAssociationLoadingState && _onlineModelViewerCubit.isShowPdf) ||
                                                                  (state is ShowBackGroundWebviewState && _onlineModelViewerCubit.isShowPdf),
                                                              child: SizedBox(
                                                                height: (state is MenuOptionLoadedState && state.isShowPdfViewFullScreen)
                                                                    ? MediaQuery.of(context).size.height
                                                                    : orientation == Orientation.portrait
                                                                        ? MediaQuery.of(context).size.height * 0.4
                                                                        : MediaQuery.of(context).size.height,
                                                                width: orientation == Orientation.landscape
                                                                    ? (state is MenuOptionLoadedState && state.isShowPdfViewFullScreen)
                                                                        ? MediaQuery.of(context).size.width / 1.005
                                                                        : MediaQuery.of(context).size.width * 0.50
                                                                    : MediaQuery.of(context).size.height * 0.7,
                                                                child: PdfTronWidget(
                                                                  pdfFileName: _onlineModelViewerCubit.selectedPdfFileName,
                                                                  onlineModelViewerCubit: _onlineModelViewerCubit,
                                                                  orientation: orientation,
                                                                  scrollController: _scrollController,
                                                                  modelId: widget.onlineModelViewerArguments.onlineViewerModelRequestModel.modelId!,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      ((state is MenuOptionLoadedState && state.isShowColorPopup) || state is LoadedAllModelState || state is LoadedSuccessfullyState || state is LoadingModelsState || state is LoadedModelState || state is LoadingState) && Utility.isIos
                                                          ? Container(
                                                              key: const Key('key_menu_options_loaded_state'),
                                                              color: Colors.transparent,
                                                              width: MediaQuery.of(context).size.width,
                                                              height: MediaQuery.of(context).size.height,
                                                              margin: EdgeInsets.only(
                                                                  left: Utility.isTablet && orientation == Orientation.portrait
                                                                      ? 45
                                                                      : Utility.isTablet && orientation == Orientation.landscape
                                                                          ? 35
                                                                          : 0),
                                                              child: Opacity(
                                                                key: const Key('key_opacity_options_loaded_state'),
                                                                opacity: 0.1,
                                                                child: InAppWebView(
                                                                  onWebViewCreated: (controller) {},
                                                                ),
                                                              ))
                                                          : Container()
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        state is LoadingState
                                            ? Positioned(
                                                left: 0,
                                                top: 0,
                                                right: 0,
                                                bottom: 60,
                                                child: IgnorePointer(
                                                  key: Key('key_ignore_pointer_animation'),
                                                  ignoring: true,
                                                  child: SizedBox(
                                                    key: Key('key_animation_sized_box'),
                                                    height: MediaQuery.of(context).size.height,
                                                    child: Center(
                                                      child: InAppWebView(
                                                          key: Key('key_in_app_view'),
                                                          initialUrlRequest: URLRequest(url: Uri.parse("")),
                                                          initialOptions: inAppWebViewGroupOptions(Uri.parse('file://${AppPathHelper().basePath}')),
                                                          onWebViewCreated: (controller) async {
                                                            _onlineModelViewerCubit.animationWebviewController = controller;
                                                            _onlineModelViewerCubit.animationWebviewController.loadUrl(urlRequest: URLRequest(url: Uri.file("${await AppPathHelper().getAssetOfflineZipPath()}/files/cBIM_Loader_Corrected/cBIM-Loader-alt.html")));
                                                          }),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : state is CalibrationListLoadingState || state is FileAssociationLoadingState
                                                ? const Positioned(
                                                    left: 0,
                                                    right: 0,
                                                    top: 0,
                                                    bottom: 0,
                                                    child: IgnorePointer(child: ACircularProgress()),
                                                  )
                                                : const SizedBox(
                                                    key: Key('key_empty_sized_box'),
                                                  ),
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              resizeToAvoidBottomInset: false,
            );
          },
        ),
      ),
    );
  }

  void _showTooltipDialog(LongPressEndDetails details, Orientation orientation) {
    final Offset target = details.globalPosition;

    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    final dialogWidth = 200.0;
    final dialogHeight = 250.0;

    double left = target.dx - 100;
    double top = target.dy - 100;
    if (left < 20) {
      left += 72;
      top += 16;
    }
    if (top < 20) {
      top += 50;
    }

    if (_onlineModelViewerCubit.isShowPdf) {
      if (orientation == Orientation.landscape) {
        if (top + dialogHeight > screenHeight) {
          top = screenHeight - dialogHeight - 48;
        }
        screenWidth = screenWidth / 2;
      } else {
        screenHeight = screenHeight / 2;
        top = top + 24;
      }
    }

    if (left + dialogWidth > screenWidth) {
      left = screenWidth - dialogWidth + 16;
    }

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) => Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubicEmphasized,
            left: left,
            top: top,
            child: isNetWorkConnected()
                ? CircularMenu(
                    toggleButtonOnPressed: () {
                      onMenuClose();
                    },
                    toggleButtonColor: Colors.transparent,
                    radius: 60,
                    toggleButtonSize: 35,
                    alignment: Alignment.center,
                    backgroundWidget: SizedBox(
                      height: dialogHeight,
                      width: dialogWidth,
                    ),
                    items: [
                      CircularMenuItem(
                          color: AColors.white,
                          iconSize: 18,
                          imageIcon: Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: Image.asset(
                              AImageConstants.focus,
                              width: 22,
                              height: 22,
                            ),
                          ),
                          onTap: () {
                            _onFocusClick();
                          }),
                      CircularMenuItem(
                          color: AColors.white,
                          iconSize: 18,
                          imageIcon: Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: Image.asset(
                              AImageConstants.calibrationFile,
                              width: 22,
                              height: 22,
                            ),
                          ),
                          onTap: () async {
                            onMenuClose();
                            Result result = await _onlineModelViewerCubit.getThreeDAppTypeList(widget.onlineModelViewerArguments.projectId);
                            showCreateFormDialog(getThreedAppTypeFromJson(result.data));
                          }),
                      CircularMenuItem(
                          color: AColors.white,
                          iconSize: 35,
                          imageIcon: Image.asset(
                            AImageConstants.palette,
                            width: 40,
                            height: 40,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            _onPaletteClick();
                          }),
                      CircularMenuItem(
                          color: AColors.white,
                          iconSize: 35,
                          imageIcon: Image.asset(
                            AImageConstants.viewObjectDetails,
                            width: 40,
                            height: 40,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            _onSelectViewObjectDetails();
                          }),
                      CircularMenuItem(
                          color: AColors.white,
                          iconSize: 40,
                          imageIcon: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Image.asset(
                              AImageConstants.fileAssociation,
                              width: 20,
                              height: 20,
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () {
                            _onSelectFileAssociation();
                          }),
                      CircularMenuItem(
                          color: AColors.white,
                          iconSize: 18,
                          imageIcon: Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: Image.asset(
                              AImageConstants.opacityCircle,
                              width: 22,
                              height: 22,
                            ),
                          ),
                          onTap: () {
                            _onOpacityClick();
                          }),
                      CircularMenuItem(
                          color: AColors.white,
                          iconSize: 18,
                          imageIcon: Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: Image.asset(
                              AImageConstants.isolate,
                              width: 22,
                              height: 22,
                            ),
                          ),
                          onTap: () {
                            _onIsolateClick();
                          }),
                    ],
                  )
                : CircularMenu(
                    toggleButtonOnPressed: () {
                      onMenuClose();
                    },
                    toggleButtonColor: Colors.transparent,
                    radius: 60,
                    toggleButtonSize: 35,
                    alignment: Alignment.center,
                    backgroundWidget: SizedBox(
                      height: dialogHeight,
                      width: dialogWidth,
                    ),
                    items: [
                      CircularMenuItem(
                          color: AColors.white,
                          iconSize: 18,
                          imageIcon: Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: Image.asset(
                              AImageConstants.focus,
                              width: 22,
                              height: 22,
                            ),
                          ),
                          onTap: () {
                            _onFocusClick();
                          }),
                      CircularMenuItem(
                          color: AColors.white,
                          iconSize: 35,
                          imageIcon: Image.asset(
                            AImageConstants.palette,
                            width: 40,
                            height: 40,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            _onPaletteClick();
                          }),
                      CircularMenuItem(
                          color: AColors.white,
                          iconSize: 35,
                          imageIcon: Image.asset(
                            AImageConstants.viewObjectDetails,
                            width: 40,
                            height: 40,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            _onSelectViewObjectDetails();
                          }),
                      CircularMenuItem(
                          color: AColors.white,
                          iconSize: 18,
                          imageIcon: Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: Image.asset(
                              AImageConstants.opacityCircle,
                              width: 22,
                              height: 22,
                            ),
                          ),
                          onTap: () {
                            _onOpacityClick();
                          }),
                      CircularMenuItem(
                          color: AColors.white,
                          iconSize: 18,
                          imageIcon: Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: Image.asset(
                              AImageConstants.isolate,
                              width: 22,
                              height: 22,
                            ),
                          ),
                          onTap: () {
                            _onIsolateClick();
                          }),
                    ],
                  ),
          ),
        ],
      ),
    ).then((value) {
      _onlineModelViewerCubit.isDialogShowing = false;
    });
  }

  double getNewTopPosition(Orientation orientation) {
    return MediaQuery.of(context).size.height - _onlineModelViewerCubit.tapXY.dy;
  }

  _onOpacityClick() {
    _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.ContextMenu.handle({ x : ${_onlineModelViewerCubit.posX} , y : ${_onlineModelViewerCubit.posY}, width : ${_onlineModelViewerCubit.width}, height : ${_onlineModelViewerCubit.height}},'transparent')");
    onMenuClose();
  }

  _onIsolateClick() {
    _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.ContextMenu.handle({ x : ${_onlineModelViewerCubit.posX} , y : ${_onlineModelViewerCubit.posY}, width : ${_onlineModelViewerCubit.width}, height : ${_onlineModelViewerCubit.height}},'focus')");
    onMenuClose();

    _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.ContextMenu.handle({ x : ${"anurag"}");
  }

  _onFocusClick() {
    _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.ContextMenu.handle({ x : ${_onlineModelViewerCubit.posX} , y : ${_onlineModelViewerCubit.posY}, width : ${_onlineModelViewerCubit.width}, height : ${_onlineModelViewerCubit.height}},'isolate')");
    onMenuClose();
  }

  Future<void> showCreateFormDialog(GetThreedAppType getThreeDAppType) async {
    _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.ContextMenu.handle({ x : ${_onlineModelViewerCubit.posX} , y : ${_onlineModelViewerCubit.posY}, width : ${_onlineModelViewerCubit.width}, height : ${_onlineModelViewerCubit.height}},'createForm')");
    await showDialog(
        context: context,
        barrierColor: Colors.transparent,
        builder: (BuildContext context) {
          return TaskTypeDialogThreeD(
            key: const Key('Key_ShowPinDialog'),
            createFormSelectionCubit: getIt<CreateFormSelectionCubit>(),
          );
        }).then((value) {
      getIt<PlanCubit>().removeTempCreatePin();
      if (value != null && value is Datum) {
        if (!isNetWorkConnected() && value.templateType.isXSN) {
          Utility.showAlertDialog(context, context.toLocale!.lbl_xsn_form_type_msg_offline_title, context.toLocale!.lbl_xsn_form_type_msg_offline);
        } else {
          _onlineModelViewerCubit.navigateToCreateTask(x: -1, y: -1, appType: value, from: "model_view", bimModelId: widget.onlineModelViewerArguments.model.modelId!, dcId: _onlineModelViewerCubit.selectedProject.dcId.toString());
        }
      }
    });
  }

  _onSelectViewObjectDetails() {
    _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.ContextMenu.handle({ x : ${_onlineModelViewerCubit.posX} , y : ${_onlineModelViewerCubit.posY}, width : ${_onlineModelViewerCubit.width}, height : ${_onlineModelViewerCubit.height}},'detail')");
    onMenuClose();
  }

  _onSelectFileAssociation() {
    _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.ContextMenu.handle({ x : ${_onlineModelViewerCubit.posX} , y : ${_onlineModelViewerCubit.posY}, width : ${_onlineModelViewerCubit.width}, height : ${_onlineModelViewerCubit.height}},'assocFile')");
    onMenuClose();
  }

  _onPaletteClick() {
    onMenuClose();
    _onlineModelViewerCubit.callViewObjectFileAssociationDetails();
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return CustomColorPicker();
        });
  }

  void onTapMove(BuildContext context, LongPressMoveUpdateDetails details, Orientation orientation, OnlineModelViewerState state) {
    _onlineModelViewerCubit.tapXY = details.globalPosition;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final topLeft = box.globalToLocal(Offset.zero);

    final y = (Utility.isTablet && orientation == Orientation.landscape)
        ? MediaQuery.of(context).size.width * 0.038
        : Utility.isTablet && orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width * 0.06
            : MediaQuery.of(context).size.width * 0.10;
    _onlineModelViewerCubit.posX = details.globalPosition.dx - y;
    _onlineModelViewerCubit.posY = details.globalPosition.dy + topLeft.dy;
    _onlineModelViewerCubit.height = (orientation == Orientation.portrait)
        ? (state is MenuOptionLoadedState && state.isShowPdfView && !state.isShowPdfViewFullScreen) ||
                (state is LoadedSuccessfulAllModelState && _onlineModelViewerCubit.isShowPdf) ||
                (getIt<model_tree.ModelTreeCubit>().state is model_tree.UpdatedState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) ||
                (getIt<model_tree.ModelTreeCubit>().state is model_tree.LoadedState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) ||
                (state is LoadedSuccessfullyState && _onlineModelViewerCubit.isShowPdf) ||
                (state is LoadedModelState && _onlineModelViewerCubit.isShowPdf) ||
                (state is LoadedState && _onlineModelViewerCubit.isShowPdf) ||
                (state is LoadingState && _onlineModelViewerCubit.isShowPdf) ||
                (state is CalibrationListPresentState && _onlineModelViewerCubit.isShowPdf) ||
                (state is NormalWebState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) ||
                (state is GetJoystickCoordinatesState && state.longPress == 'true') ||
                (state is ShowPopUpState || state is HIdePopUpState && _onlineModelViewerCubit.isShowPdf || state is FileAssociationLoadingState && _onlineModelViewerCubit.isShowPdf || (state is ShowBackGroundWebviewState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) || (state is UnitCalibrationUpdateState && _onlineModelViewerCubit.isShowPdf))
            ? MediaQuery.of(context).size.height * 0.48
            : (state is MenuOptionLoadedState && state.isShowPdfViewFullScreen) || (state is GetJoystickCoordinatesState && state.longPress == 'true') || (state is NormalWebState && _onlineModelViewerCubit.isFullPdf) || (state is ShowBackGroundWebviewState && _onlineModelViewerCubit.isFullPdf)
                ? 0.0
                : MediaQuery.of(context).size.height - (kBottomNavigationBarHeight - MediaQuery.of(context).padding.bottom + 20)
        : MediaQuery.of(context).size.height - kBottomNavigationBarHeight - MediaQuery.of(context).padding.bottom - 80;

    _onlineModelViewerCubit.width = (orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width
            : (state is MenuOptionLoadedState && state.isShowPdfView && !state.isShowPdfViewFullScreen) || (state is GetJoystickCoordinatesState && state.longPress == 'true')
                ? MediaQuery.of(context).size.width * 0.5
                : (state is MenuOptionLoadedState && state.isShowPdfViewFullScreen) || (state is GetJoystickCoordinatesState && state.longPress == 'true')
                    ? 0.0
                    : (state is MenuOptionLoadedState && state.isShowPdfView)
                        ? MediaQuery.of(context).size.width * 0.495
                        : MediaQuery.of(context).size.width * 0.995) -
        y;
    if (_onlineModelViewerCubit.height < box.size.height) {
      _onlineModelViewerCubit.posY = details.globalPosition.dy + 2 * topLeft.dy - box.size.height + _onlineModelViewerCubit.height;
    }
  }

  void onTapDown(BuildContext context, LongPressEndDetails details, Orientation orientation, OnlineModelViewerState state) {
    _onlineModelViewerCubit.tapXY = details.globalPosition;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final topLeft = box.globalToLocal(Offset.zero);

    final y = (Utility.isTablet && orientation == Orientation.landscape)
        ? MediaQuery.of(context).size.width * 0.038
        : Utility.isTablet && orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width * 0.06
            : MediaQuery.of(context).size.width * 0.10;
    _onlineModelViewerCubit.posX = details.globalPosition.dx - y;
    _onlineModelViewerCubit.posY = details.globalPosition.dy + topLeft.dy;
    _onlineModelViewerCubit.height = (orientation == Orientation.portrait)
        ? (state is MenuOptionLoadedState && state.isShowPdfView && !state.isShowPdfViewFullScreen) ||
                (state is LoadedSuccessfulAllModelState && _onlineModelViewerCubit.isShowPdf) ||
                (getIt<model_tree.ModelTreeCubit>().state is model_tree.UpdatedState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) ||
                (getIt<model_tree.ModelTreeCubit>().state is model_tree.LoadedState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) ||
                (state is LoadedSuccessfullyState && _onlineModelViewerCubit.isShowPdf) ||
                (state is LoadedModelState && _onlineModelViewerCubit.isShowPdf) ||
                (state is LoadedState && _onlineModelViewerCubit.isShowPdf) ||
                (state is LoadingState && _onlineModelViewerCubit.isShowPdf) ||
                (state is CalibrationListPresentState && _onlineModelViewerCubit.isShowPdf) ||
                (state is NormalWebState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) ||
                (state is GetJoystickCoordinatesState && state.longPress == 'true') ||
                (state is ShowPopUpState || state is HIdePopUpState && _onlineModelViewerCubit.isShowPdf || state is FileAssociationLoadingState && _onlineModelViewerCubit.isShowPdf || (state is ShowBackGroundWebviewState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) || (state is UnitCalibrationUpdateState && _onlineModelViewerCubit.isShowPdf))
            ? MediaQuery.of(context).size.height * 0.48
            : (state is MenuOptionLoadedState && state.isShowPdfViewFullScreen) || (state is GetJoystickCoordinatesState && state.longPress == 'true') || (state is NormalWebState && _onlineModelViewerCubit.isFullPdf) || (state is ShowBackGroundWebviewState && _onlineModelViewerCubit.isFullPdf)
                ? 0.0
                : MediaQuery.of(context).size.height - (kBottomNavigationBarHeight - MediaQuery.of(context).padding.bottom + 20)
        : MediaQuery.of(context).size.height - kBottomNavigationBarHeight - MediaQuery.of(context).padding.bottom - 80;

    _onlineModelViewerCubit.width = (orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width
            : (state is MenuOptionLoadedState && state.isShowPdfView && !state.isShowPdfViewFullScreen) || (state is GetJoystickCoordinatesState && state.longPress == 'true')
                ? MediaQuery.of(context).size.width * 0.5
                : (state is MenuOptionLoadedState && state.isShowPdfViewFullScreen) || (state is GetJoystickCoordinatesState && state.longPress == 'true')
                    ? 0.0
                    : (state is MenuOptionLoadedState && state.isShowPdfView)
                        ? MediaQuery.of(context).size.width * 0.495
                        : MediaQuery.of(context).size.width * 0.995) -
        y;
    if (_onlineModelViewerCubit.height < box.size.height) {
      _onlineModelViewerCubit.posY = details.globalPosition.dy + 2 * topLeft.dy - box.size.height + _onlineModelViewerCubit.height;
    }
  }

  void onTapUp(BuildContext context, LongPressStartDetails details, Orientation orientation, OnlineModelViewerState state) {
    _onlineModelViewerCubit.tapXY = details.globalPosition;
    final RenderBox box = context.findRenderObject() as RenderBox;
    final topLeft = box.globalToLocal(Offset.zero);

    final y = (Utility.isTablet && orientation == Orientation.landscape)
        ? MediaQuery.of(context).size.width * 0.038
        : Utility.isTablet && orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width * 0.06
            : MediaQuery.of(context).size.width * 0.10;
    _onlineModelViewerCubit.posX = details.globalPosition.dx - y;
    _onlineModelViewerCubit.posY = details.globalPosition.dy + topLeft.dy;
    _onlineModelViewerCubit.height = (orientation == Orientation.portrait)
        ? (state is MenuOptionLoadedState && state.isShowPdfView && !state.isShowPdfViewFullScreen) ||
                (state is LoadedSuccessfulAllModelState && _onlineModelViewerCubit.isShowPdf) ||
                (getIt<model_tree.ModelTreeCubit>().state is model_tree.UpdatedState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) ||
                (getIt<model_tree.ModelTreeCubit>().state is model_tree.LoadedState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) ||
                (state is LoadedSuccessfullyState && _onlineModelViewerCubit.isShowPdf) ||
                (state is LoadedModelState && _onlineModelViewerCubit.isShowPdf) ||
                (state is LoadedState && _onlineModelViewerCubit.isShowPdf) ||
                (state is LoadingState && _onlineModelViewerCubit.isShowPdf) ||
                (state is CalibrationListPresentState && _onlineModelViewerCubit.isShowPdf) ||
                (state is NormalWebState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) ||
                (state is GetJoystickCoordinatesState && state.longPress == 'true') ||
                (state is ShowPopUpState || state is HIdePopUpState && _onlineModelViewerCubit.isShowPdf || state is FileAssociationLoadingState && _onlineModelViewerCubit.isShowPdf || (state is ShowBackGroundWebviewState && _onlineModelViewerCubit.isShowPdf && !_onlineModelViewerCubit.isFullPdf) || (state is UnitCalibrationUpdateState && _onlineModelViewerCubit.isShowPdf))
            ? MediaQuery.of(context).size.height * 0.48
            : (state is MenuOptionLoadedState && state.isShowPdfViewFullScreen) || (state is GetJoystickCoordinatesState && state.longPress == 'true') || (state is NormalWebState && _onlineModelViewerCubit.isFullPdf) || (state is ShowBackGroundWebviewState && _onlineModelViewerCubit.isFullPdf)
                ? 0.0
                : MediaQuery.of(context).size.height - (kBottomNavigationBarHeight - MediaQuery.of(context).padding.bottom + 80)
        : MediaQuery.of(context).size.height - kBottomNavigationBarHeight - MediaQuery.of(context).padding.bottom - 80;
    _onlineModelViewerCubit.width = (orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width
            : (state is MenuOptionLoadedState && state.isShowPdfView && !state.isShowPdfViewFullScreen) || (state is GetJoystickCoordinatesState && state.longPress == 'true')
                ? MediaQuery.of(context).size.width * 0.5
                : (state is MenuOptionLoadedState && state.isShowPdfViewFullScreen) || (state is GetJoystickCoordinatesState && state.longPress == 'true')
                    ? 0.0
                    : (state is MenuOptionLoadedState && state.isShowPdfView)
                        ? MediaQuery.of(context).size.width * 0.495
                        : MediaQuery.of(context).size.width * 0.995) -
        y;
    if (_onlineModelViewerCubit.height < box.size.height) {
      _onlineModelViewerCubit.posY = details.globalPosition.dy + 2 * topLeft.dy - box.size.height + _onlineModelViewerCubit.height;
    }
  }

  Future<bool> onWillPop() async {
    _onlineModelViewerCubit.isModelTreeOpen = false;
    updateTitle(_onlineModelViewerCubit.selectedProject.projectName, NavigationMenuItemType.models);
    return true;
  }

  Future<void> createSiteTaskOrForm(CreateTaskNavigationState state) async {
    if (Utility.isTablet) {
      await showDialog(
          context: context,
          barrierDismissible: false,
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
                  title: "${context.toLocale!.lbl_create} ${state.appType.formTypeName}",
                  data: state.data,
                  snaggingGuid: _onlineModelViewerCubit.snaggingGuId,
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
            title: "${context.toLocale!.lbl_create} ${state.appType.formTypeName}",
            data: state.data,
            snaggingGuid: _onlineModelViewerCubit.snaggingGuId,
          ),
        ),
      )?.then((value) {
        _onFormOrTaskCreated(value);
      });
    }
  }

  void _onFormOrTaskCreated(value) {
    _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "PinManager.disablePinOperator()");
    if (value != null && SiteUtility.isLocationHasPlan(getIt<PlanCubit>().selectedLocation) && value["formId"] != null) {
      if (getIt<PlanCubit>().currentPinsType != Pins.all) {
        _showFormCreatedMessage();
      }
      getIt<PlanCubit>().refreshPinsAndHighLight(value);
    } else {
      getIt<PlanCubit>().refreshSiteTaskList();
    }
  }

  void _showFormCreatedMessage() {
    if (getIt<PlanCubit>().currentPinsType != Pins.all) {
      context.showSnack(context.toLocale!.form_created_with_pin_message);
    }
  }

  FloatingActionButtonLocation _buildFloatingActionButtonLocation() {
    if (Utility.isTablet) {
      return FloatingActionButtonLocation.startDocked;
    } else {
      return FloatingActionButtonLocation.startDocked;
    }
  }

  String getFormattedDate(String unformattedDate) {
    String formattedDate = "";
    DateTime date = DateFormat("dd-MMM-yyyy").parse(unformattedDate);
    formattedDate = DateFormat('dd/MM/yyyy').format(date);
    return formattedDate;
  }

  void onMenuClose() {
    _onlineModelViewerCubit.isDialogShowing = false;
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void deactivate() {
    _onlineModelViewerCubit.isModelTreeOpen = false;
    super.deactivate();
  }

  @override
  void dispose() {
    super.dispose();
    _onlineModelViewerCubit.totalNumbersOfModelsLoad = "1";
    _onlineModelViewerCubit.bimModelListData.clear();
    _pdfTronCubit.selectedCalibration = null;
    _onlineModelViewerCubit.isShowPdf = false;
    _onlineModelViewerCubit.isModelTreeOpen = false;
  }

  Widget? showLocationTreeDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          Map<String, dynamic> arguments = _onlineModelViewerCubit.offlineParams;
          return Scaffold(key: _onlineModelViewerCubit.modelScaffoldKey, backgroundColor: Colors.transparent, body: ModelTreeWidget(arguments));
        });
    return null;
  }

  Future<void> setOfflineParams(Map<String, dynamic> offlineParams) async {
    _onlineModelViewerCubit.offlineParams = offlineParams;
    _onlineModelViewerCubit.offlineFilePath.clear();
    _onlineModelViewerCubit.totalNumbersOfModelsLoad = "1";
    if (offlineParams.isNotEmpty) {
      List<FloorDetail> floorList = offlineParams['floorList'];
      _onlineModelViewerCubit.fileNameList.clear();
      for (var floor in floorList) {
        _onlineModelViewerCubit.fileNameList.add(floor.fileName + floor.levelName);
        String? outputFilePath = await AppPathHelper().getModelScsFilePath(
          projectId: offlineParams['projectId'],
          revisionId: floor.revisionId.toString(),
          filename: floor.fileName,
          modelId: offlineParams['modelId'],
        );

        if (!outputFilePath.isNullOrEmpty() && isFileExist(outputFilePath)) {
          _onlineModelViewerCubit.offlineFilePath.add(outputFilePath);
          if (!isNetWorkConnected()) {
            _onlineModelViewerCubit.totalNumbersOfModels = _onlineModelViewerCubit.offlineFilePath.length.toString();
          }
        }
      }
    }
  }
}
