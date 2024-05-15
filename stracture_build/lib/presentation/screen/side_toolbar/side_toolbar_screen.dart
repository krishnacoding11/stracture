import 'package:field/bloc/model_list/model_list_cubit.dart' as model_list;
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart' as online_model_viewer;
import 'package:field/bloc/pdf_tron/pdf_tron_cubit.dart' as pdf_tron_cubit;
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart';
import 'package:field/data/model/measurement_units.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/presentation/screen/side_toolbar/unit_calibration.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/navigation/navigation_cubit.dart';
import '../../../injection_container.dart';
import '../../../utils/actionIdConstants.dart';
import '../../../utils/toolbar_mixin.dart';
import '../bottom_navigation/models/models_list_screen.dart';

class SideToolbarScreen extends StatefulWidget {
  bool isWhite;
  bool isModelSelected;
  bool isPdfViewISFull;
  dynamic onlineModelViewerCubit;
  bool isOnlineModelViewerScreen;
  Orientation orientation;
  String modelId;
  String modelName;

  SideToolbarScreen({Key? key, required this.isWhite, required this.onlineModelViewerCubit, required this.isPdfViewISFull, required this.isModelSelected, required this.isOnlineModelViewerScreen, required this.orientation, required this.modelId, required this.modelName}) : super(key: key);

  @override
  State<SideToolbarScreen> createState() => SideToolbarScreenState();
}

class SideToolbarScreenState extends State<SideToolbarScreen> with ToolbarTitle {
  final SideToolBarCubit sideToolBarCubit = getIt<SideToolBarCubit>();

  @override
  void didUpdateWidget(covariant SideToolbarScreen oldWidget) {
    if (widget.orientation != oldWidget.orientation && sideToolBarCubit.isPopUpShowing) {
      Navigator.of(sideToolBarCubit.mContext!, rootNavigator: true).pop();
    }
    super.didUpdateWidget(oldWidget);
  }

  late double height = MediaQuery.of(context).size.height;
  late double width = MediaQuery.of(context).size.width;
  GlobalKey markerKey = GlobalKey();
  GlobalKey rulerKey = GlobalKey();
  GlobalKey cuttingPlaneKey = GlobalKey();

  @override
  void initState() {
    sideToolBarCubit.selectedAreaUnit = MeasurementUnits("sqmm", "mm2");
    sideToolBarCubit.selectedDistanceUnit = MeasurementUnits("mm", "MM");
    sideToolBarCubit.selectedPrecisionUnit = MeasurementUnits("zero", "0");
    sideToolBarCubit.selectedAngleUnit = MeasurementUnits("Degrees", "Degrees");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AConstants.modelName = widget.modelName;
    sideToolBarCubit.isWhite = widget.isWhite;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocListener<SideToolBarCubit, FlowState>(
        listener: (context, state) {
          if (state is AppErrorState) {
            context.showSnack(state.exception.message);
          } else if (state is SideToolBarEnableState) {
            sideToolBarCubit.isSideToolBarEnabled = true;
          }
        },
        child: BlocBuilder<SideToolBarCubit, FlowState>(
          builder: (context, state) {
            return OrientationBuilder(
                key: Key('key_orientation_builder'),
                builder: (_, orientation1) {
                  return SingleChildScrollView(
                    key: Key('key_single_child_scroll_view'),
                    physics: const NeverScrollableScrollPhysics(),
                    child: Container(
                      key: Key('key_container_widget'),
                      width: Utility.isTablet ? MediaQuery.of(context).size.width / 16 : MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.height,
                      padding: EdgeInsets.only(top: widget.isOnlineModelViewerScreen && widget.onlineModelViewerCubit.isShowPdf && widget.orientation == Orientation.portrait && Utility.isTablet ? 0 : 0),
                      color: sideToolBarCubit.isWhite && widget.onlineModelViewerCubit is online_model_viewer.OnlineModelViewerCubit
                          ? const Color.fromRGBO(189, 189, 189, 0.800)
                          : widget.isOnlineModelViewerScreen
                              ? const Color.fromARGB(228, 255, 255, 255)
                              : const Color.fromRGBO(189, 189, 189, 0.800),
                      child: Column(
                        key: const Key(AConstants.key_side_tool_bar_icons_column),
                        mainAxisAlignment: widget.isOnlineModelViewerScreen && widget.onlineModelViewerCubit.isShowPdf && widget.orientation == Orientation.portrait && Utility.isTablet
                            ? widget.isPdfViewISFull
                                ? MainAxisAlignment.start
                                : MainAxisAlignment.start
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            key: const Key(AConstants.key_home),
                            height: 37,
                            width: 47,
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            color: sideToolBarCubit.isWhite && widget.onlineModelViewerCubit is online_model_viewer.OnlineModelViewerCubit
                                ? Colors.transparent
                                : widget.isOnlineModelViewerScreen
                                    ? AColors.white
                                    : Colors.transparent,
                            child: IconButton(
                              key: const Key("key_icon_home"),
                              icon: Image.asset(AImageConstants.homeSideToolBar, color: AColors.grColorDark, height: 25, width: 25),
                              onPressed: () {
                                if (widget.isOnlineModelViewerScreen && !sideToolBarCubit.isWhite && sideToolBarCubit.isSideToolBarEnabled && !widget.isPdfViewISFull) {
                                  widget.onlineModelViewerCubit.isDialogShowing = false;
                                  widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.home()");
                                  getIt<pdf_tron_cubit.PdfTronCubit>().lastSavedYPoint = -99999;
                                  getIt<pdf_tron_cubit.PdfTronCubit>().lastSavedXPoint = -99999;
                                }
                              },
                              color: AColors.white,
                            ),
                          ),
                          setMarginToDivider(),
                          Container(
                            key: rulerKey,
                            height: 40,
                            width: 50,
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            color: sideToolBarCubit.isWhite && widget.onlineModelViewerCubit is online_model_viewer.OnlineModelViewerCubit
                                ? Colors.transparent
                                : widget.isOnlineModelViewerScreen
                                    ? AColors.white
                                    : Colors.transparent,
                            child: IconButton(
                              icon: Image.asset(
                                AImageConstants.rulerOutline,
                                color: ((state is RulerMenuVisibility && state.isRulerMenuVisible) || sideToolBarCubit.isRulerMenuActive) && (sideToolBarCubit.isRulerFirstSubMenuActive || sideToolBarCubit.isRulerSecondSubMenuActive || sideToolBarCubit.isRulerThirdSubMenuActive) ? AColors.enableColor : AColors.grColorDark,
                              ),
                              onPressed: () {
                                if (widget.isOnlineModelViewerScreen && !sideToolBarCubit.isWhite && sideToolBarCubit.isSideToolBarEnabled && !widget.isPdfViewISFull) {
                                  if (Utility.isIos) {
                                    widget.onlineModelViewerCubit.callViewObjectFileAssociationDetails();
                                  }
                                  showRulerMenu(context, widget.orientation);
                                  sideToolBarCubit.isRulerMenuVisible(true);
                                }
                              },
                              color: AColors.white,
                            ),
                          ),
                          setMarginToDivider(),
                          Container(
                            key: Key(state is StepsIconState && state.isSteps ? AConstants.key_joystick : AConstants.key_orbit),
                            height: 40,
                            width: 50,
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            color: sideToolBarCubit.isWhite && widget.onlineModelViewerCubit is online_model_viewer.OnlineModelViewerCubit
                                ? Colors.transparent
                                : widget.isOnlineModelViewerScreen
                                    ? AColors.white
                                    : Colors.transparent,
                            child: IconButton(
                              icon: Image.asset(
                                (state is StepsIconState && state.isSteps) || (state is CuttingPlaneMenuVisibility && state.isCameraIconVisible) || (state is SideToolBarEnableState && sideToolBarCubit.isSteps) || (state is ColorPickerState && sideToolBarCubit.isSteps) || (state is RulerMenuVisibility && state.isCameraIconVisible) || (state is MarkerMenuVisibility && state.isCameraIconVisible) ? AImageConstants.cameraControl : AImageConstants.rotateOrbit,
                                color: (state is StepsIconState && state.isSteps) || (state is CuttingPlaneMenuVisibility && state.isCameraIconVisible) || (state is RulerMenuVisibility && state.isCameraIconVisible) || (state is MarkerMenuVisibility && state.isCameraIconVisible) || (state is ColorPickerState && sideToolBarCubit.isSteps) || (state is SideToolBarEnableState && sideToolBarCubit.isSteps) ? AColors.enableColor : AColors.grColorDark,
                              ),
                              onPressed: () {
                                if (widget.isOnlineModelViewerScreen && !sideToolBarCubit.isWhite && sideToolBarCubit.isSideToolBarEnabled && !widget.isPdfViewISFull) {
                                  widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.joystick()");
                                  widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '$orientation1', view : ${widget.onlineModelViewerCubit.isShowPdfView?'2D/3D':'3D'},device : '${Utility.isTablet ? "Tablet" : "Mobile"}', isIOS : '${Utility.isIos ? 1 : 0}'})");
                                  sideToolBarCubit.showStepsIcon();
                                }
                              },
                              color: (state is StepsIconState && state.isSteps) || (state is CuttingPlaneMenuVisibility && state.isCameraIconVisible) || (state is RulerMenuVisibility && state.isCameraIconVisible) || (state is MarkerMenuVisibility && state.isCameraIconVisible) ? AColors.enableColor : AColors.white,
                            ),
                          ),
                          setMarginToDivider(),
                          Container(
                            key: cuttingPlaneKey,
                            height: 40,
                            width: 50,
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            color: sideToolBarCubit.isWhite && widget.onlineModelViewerCubit is online_model_viewer.OnlineModelViewerCubit
                                ? Colors.transparent
                                : widget.isOnlineModelViewerScreen
                                    ? AColors.white
                                    : Colors.transparent,
                            child: IconButton(
                              icon: Image.asset(
                                AImageConstants.cuttingPlane,
                                color: ((state is CuttingPlaneMenuVisibility && state.isCuttingPlaneMenuVisible) || sideToolBarCubit.isCuttingPlaneMenuActive) && (sideToolBarCubit.isCuttingPlaneFirstSubMenuActive || sideToolBarCubit.isCuttingPlaneSecondSubMenuActive || sideToolBarCubit.isCuttingPlaneThirdSubMenuActive || sideToolBarCubit.isCuttingPlaneFourthSubMenuActive || sideToolBarCubit.isCuttingPlaneFifthSubMenuActive) ? AColors.enableColor : AColors.grColorDark,
                              ),
                              key: Key('key_cutting_plane_widget'),
                              onPressed: () {
                                if (widget.isOnlineModelViewerScreen && !sideToolBarCubit.isWhite && sideToolBarCubit.isSideToolBarEnabled && !widget.isPdfViewISFull) {
                                  if (Utility.isIos) {
                                    widget.onlineModelViewerCubit.callViewObjectFileAssociationDetails();
                                  }
                                  showCuttingPlaneMenu(context, widget.orientation);
                                  sideToolBarCubit.isCuttingPlaneMenuVisible(true);
                                }
                              },
                              color: AColors.white,
                            ),
                          ),
                          setMarginToDivider(),
                          Container(
                            key: const Key(AConstants.key_pdf),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: sideToolBarCubit.isWhite ? const Color.fromRGBO(255, 255, 255, 1) : Colors.transparent,
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(5),
                                topLeft: Radius.circular(5),
                              ),
                              color: sideToolBarCubit.isWhite ? AColors.white : Colors.transparent,
                            ),
                            height: 40,
                            width: 50,
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            child: Transform.rotate(
                              angle: 252.9,
                              child: IconButton(
                                icon: Image.asset(AImageConstants.splitHorizontallyAlt, color: sideToolBarCubit.isWhite && widget.onlineModelViewerCubit is online_model_viewer.OnlineModelViewerCubit  ? AColors.enableColor : AColors.grColorDark),
                                onPressed: () {
                                  if (widget.onlineModelViewerCubit != null && sideToolBarCubit.isSideToolBarEnabled && widget.onlineModelViewerCubit.isCalibListPressed) {
                                    if ((widget.onlineModelViewerCubit.calibList.isEmpty || widget.onlineModelViewerCubit.isShowPdf) && !widget.onlineModelViewerCubit.isCalibListEmptyFromApi) {
                                      widget.onlineModelViewerCubit.isShowPdf = false;
                                      widget.onlineModelViewerCubit!.getCalibrationList(widget.onlineModelViewerCubit!.selectedProject.projectID, widget.onlineModelViewerCubit!.selectedModelId, false).then((value) {
                                        value.removeWhere((element) => element.calibrationName == null || element.calibrationName.toString().trim().isEmpty);
                                        sideToolBarCubit.isWhite = true;
                                        widget.onlineModelViewerCubit.calibList = value;
                                        widget.onlineModelViewerCubit.isPdfListingVisible = true;
                                      });
                                    } else if (getIt<pdf_tron_cubit.PdfTronCubit>().selectedCalibration != null && !widget.onlineModelViewerCubit.is3DVisible) {
                                      sideToolBarCubit.isWhite = false;
                                      widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '${widget.orientation}', view : '2D/3D',device : '${Utility.isTablet ? "Tablet" : "Mobile"}', isIOS : '${Utility.isIos ? 1 : 0}'})");
                                      widget.onlineModelViewerCubit.togglePdfTronVisibility(true, getIt<pdf_tron_cubit.PdfTronCubit>().selectedCalibration!.fileName, false, false);
                                      if (isNetWorkConnected()) widget.onlineModelViewerCubit.setParallelViewAuditTrail(widget.onlineModelViewerCubit.selectedProject.projectID!, "Field", "Coordinate View", ActionConstants.actionId98, widget.modelId, getIt<pdf_tron_cubit.PdfTronCubit>().selectedCalibration!.calibrationId);
                                      getIt<pdf_tron_cubit.PdfTronCubit>().selectedCalibrationHandle = getIt<pdf_tron_cubit.PdfTronCubit>().selectedCalibration;
                                      widget.onlineModelViewerCubit.isCalibListShow = false;
                                    } else {
                                      if (getIt<pdf_tron_cubit.PdfTronCubit>().selectedCalibration != null && widget.onlineModelViewerCubit.isShowPdfView) {
                                        widget.onlineModelViewerCubit.isShowPdf = true;
                                      }
                                      sideToolBarCubit.isWhite = false;
                                      widget.onlineModelViewerCubit.isShowPdfView = false;
                                      widget.onlineModelViewerCubit.calibListPresentState();
                                      widget.onlineModelViewerCubit.isCalibListShow = false;
                                      widget.onlineModelViewerCubit.isCalibListEmptyFromApi = false;
                                    }
                                  }
                                },
                                color: AColors.white,
                              ),
                            ),
                          ),
                          setMarginToDivider(),
                          Container(
                            key: const Key(AConstants.key_color_palette),
                            height: 38,
                            width: 38,
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            color: sideToolBarCubit.isWhite && widget.onlineModelViewerCubit is online_model_viewer.OnlineModelViewerCubit
                                ? Colors.transparent
                                : widget.isOnlineModelViewerScreen
                                    ? AColors.white
                                    : Colors.transparent,
                            child: IconButton(
                              icon: Image.asset(
                                AImageConstants.colorPalateIcon,
                                color: (state is ColorPickerState && state.isColorPicker) || ((state is StepsIconState || state is online_model_viewer.ShowBackGroundWebviewState || state is SideToolBarEnableState || state is  online_model_viewer.NormalWebState || state is online_model_viewer.NormalWebState) && sideToolBarCubit.isColorPickerMenuActive) ? AColors.enableColor : AColors.grColorDark,
                                height: 50,
                                width: 50,
                              ),
                              onPressed: () {
                                if (widget.isOnlineModelViewerScreen && !sideToolBarCubit.isWhite && !widget.isPdfViewISFull && sideToolBarCubit.isSideToolBarEnabled) {
                                  widget.onlineModelViewerCubit.getColor(widget.onlineModelViewerCubit.selectedProject.projectID!, widget.modelId);
                                  widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.color()");
                                  Log.d(sideToolBarCubit.isColorPickerMenuActive);
                                  sideToolBarCubit.isColorPickerMenuActive = !sideToolBarCubit.isColorPickerMenuActive;
                                  sideToolBarCubit.emitColorPickerState();
                                }
                              },
                              color: AColors.white,
                            ),
                          ),
                          setMarginToDivider(),
                          Container(
                            key: const Key(AConstants.key_model),
                            height: 40,
                            width: 50,
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            color: sideToolBarCubit.isWhite && widget.onlineModelViewerCubit is online_model_viewer.OnlineModelViewerCubit
                                ? Colors.transparent
                                : widget.isOnlineModelViewerScreen
                                    ? AColors.white
                                    : Colors.white,
                            child: IconButton(
                              key: Key("key_model_widget"),
                              icon: Image.asset(
                                widget.isOnlineModelViewerScreen ? AImageConstants.modelOffline : AImageConstants.modelOfflineSideToolBar,
                                color: !widget.isOnlineModelViewerScreen ? AColors.aPrimaryColor : AColors.grColorDark,
                              ),
                              onPressed: () {
                                sideToolBarCubit.isRulerMenuActive = false;
                                sideToolBarCubit.isRulerFirstSubMenuActive = false;
                                sideToolBarCubit.isRulerSecondSubMenuActive = false;
                                sideToolBarCubit.isRulerThirdSubMenuActive = false;
                                sideToolBarCubit.isMarkerMenuActive = false;
                                sideToolBarCubit.isCuttingPlaneMenuActive = false;
                                sideToolBarCubit.isCuttingPlaneFirstSubMenuActive = false;
                                sideToolBarCubit.isCuttingPlaneSecondSubMenuActive = false;
                                sideToolBarCubit.isCuttingPlaneThirdSubMenuActive = false;
                                sideToolBarCubit.isCuttingPlaneFourthSubMenuActive = false;
                                sideToolBarCubit.isCuttingPlaneFifthSubMenuActive = false;
                                sideToolBarCubit.isColorPickerMenuActive = false;
                                sideToolBarCubit.emitColorPickerState();
                                if (!sideToolBarCubit.isWhite && sideToolBarCubit.isSideToolBarEnabled) {
                                  widget.onlineModelViewerCubit.isModelTreeOpen = false;
                                  if (!widget.isOnlineModelViewerScreen) {
                                    sideToolBarCubit.isSideToolBarEnabled = true;
                                  }
                                  if (widget.isOnlineModelViewerScreen) {
                                    if (state is StepsIconState && state.isSteps) {
                                      sideToolBarCubit.showStepsIcon();
                                    }
                                    sideToolBarCubit.isSideToolBarEnabled = false;
                                    updateTitle(widget.onlineModelViewerCubit.selectedProject.projectName, NavigationMenuItemType.models);
                                    widget.onlineModelViewerCubit.isShowPdf = false;
                                    sideToolBarCubit.isWhite = false;
                                    sideToolBarCubit.isSteps = false;
                                    sideToolBarCubit.isSideToolBarEnabled = false;
                                    getIt<model_list.ModelListCubit>().selectedModelData = null;
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) => ModelsListPage(
                                                  isFavourites: false,
                                                  isShowSideToolBar: true,
                                                  isFromHome: false,
                                                  selectedModel: !isNetWorkConnected() ? sideToolBarCubit.selectedModel : null,
                                                )));
                                  } /*else {
                                Navigator.of(context).pop();
                                updateTitle(AConstants.modelName, NavigationMenuItemType.models);
                              }*/
                                }
                              },
                              color: AColors.white,
                            ),
                          ),
                          setMarginToDivider(),
                          Container(
                            key: const Key(AConstants.key_reset),
                            height: 40,
                            width: 50,
                            padding: EdgeInsets.zero,
                            margin: EdgeInsets.zero,
                            color: sideToolBarCubit.isWhite && widget.onlineModelViewerCubit is online_model_viewer.OnlineModelViewerCubit
                                ? Colors.transparent
                                : widget.isOnlineModelViewerScreen
                                    ? AColors.white
                                    : Colors.transparent,
                            child: IconButton(
                              icon: Image.asset(
                                AImageConstants.refresh,
                                color: AColors.grColorDark,
                              ),
                              onPressed: () {
                                if (widget.isOnlineModelViewerScreen && !sideToolBarCubit.isWhite && !widget.isPdfViewISFull && sideToolBarCubit.isSideToolBarEnabled) {
                                  sideToolBarCubit.isRulerMenuActive = false;
                                  sideToolBarCubit.isRulerFirstSubMenuActive = false;
                                  sideToolBarCubit.isRulerSecondSubMenuActive = false;
                                  sideToolBarCubit.isRulerThirdSubMenuActive = false;
                                  sideToolBarCubit.emitColorPickerState();
                                  widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.reset()");
                                }
                              },
                              color: AColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          },
        ),
      ),
    );
  }

  Widget openRulerMenu(BuildContext context, Orientation orientation, Offset position) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          left: position.dx + 10 + (Utility.isSmallTablet ? 12 : 0),
          top: widget.isOnlineModelViewerScreen && widget.onlineModelViewerCubit.isShowPdf && widget.orientation == Orientation.portrait && Utility.isTablet ? position.dy - (position.dy / 8) : position.dy - (position.dy / 2),
          child: Container(
            key: const Key('key_ruler_menu'),
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 8.0, color: Colors.grey.shade600),
              ],
            ),
            child: Column(
              children: [
                SizedBox(
                  key: const Key(AConstants.key_ruler_asset),
                  width: 25.0,
                  height: 25.0,
                  child: InkWell(
                    highlightColor: Colors.white24,
                    onTap: () {
                      widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.measurement('distance')");
                      if (Utility.isIos) {
                        widget.onlineModelViewerCubit.callViewObjectFileAssociationDetails();
                      }
                      sideToolBarCubit.isRulerMenuActive = true;
                      sideToolBarCubit.isRulerFirstSubMenuActive = !sideToolBarCubit.isRulerFirstSubMenuActive;
                      sideToolBarCubit.isRulerSecondSubMenuActive = false;
                      sideToolBarCubit.isRulerThirdSubMenuActive = false;
                      Navigator.of(context).pop();
                    },
                    child: SizedBox(
                      child: Image.asset(
                        AImageConstants.rulerOutline,
                        scale: 1.0,
                        height: 25,
                        width: 25,
                        color: sideToolBarCubit.isRulerFirstSubMenuActive ? AColors.enableColor : AColors.grColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  key: const Key(AConstants.key_angle_asset),
                  width: 25.0,
                  height: 25.0,
                  child: InkWell(
                    highlightColor: Colors.white24,
                    onTap: () {
                      widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.measurement('angle')");
                      if (Utility.isIos) {
                        widget.onlineModelViewerCubit.callViewObjectFileAssociationDetails();
                      }
                      sideToolBarCubit.isRulerMenuActive = true;
                      sideToolBarCubit.isRulerFirstSubMenuActive = false;
                      sideToolBarCubit.isRulerSecondSubMenuActive = !sideToolBarCubit.isRulerSecondSubMenuActive;
                      sideToolBarCubit.isRulerThirdSubMenuActive = false;
                      Navigator.of(context).pop();
                    },
                    child: SizedBox(
                      child: Image.asset(
                        AImageConstants.angelAcute,
                        scale: 1.0,
                        width: 25,
                        height: 25,
                        color: sideToolBarCubit.isRulerSecondSubMenuActive ? AColors.enableColor : AColors.grColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  width: 25.0,
                  height: 25.0,
                  child: InkWell(
                    highlightColor: Colors.white24,
                    onTap: () {
                      widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.measurement('area')");
                      if (Utility.isIos) {
                        widget.onlineModelViewerCubit.callViewObjectFileAssociationDetails();
                      }
                      sideToolBarCubit.isRulerMenuActive = true;
                      sideToolBarCubit.isRulerFirstSubMenuActive = false;
                      sideToolBarCubit.isRulerSecondSubMenuActive = false;
                      sideToolBarCubit.isRulerThirdSubMenuActive = !sideToolBarCubit.isRulerThirdSubMenuActive;
                      Navigator.of(context).pop();
                    },
                    child: SizedBox(
                      child: Image.asset(
                        AImageConstants.area,
                        scale: 1.0,
                        width: 25,
                        height: 25,
                        color: sideToolBarCubit.isRulerThirdSubMenuActive ? AColors.enableColor : AColors.grColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  key: const Key(AConstants.key_side_toolbar),
                  width: 25.0,
                  height: 25.0,
                  child: InkWell(
                    highlightColor: Colors.white24,
                    onTap: () {
                      widget.onlineModelViewerCubit.webviewController.evaluateJavascript(
                        source: "nCircle.Ui.Toolbar.setDistanceMeasurementUnit(`${sideToolBarCubit.selectedDistanceUnit.key}`)",
                      );
                      widget.onlineModelViewerCubit.webviewController.evaluateJavascript(
                        source: "nCircle.Ui.Toolbar.setAngleMeasurementUnit(`${sideToolBarCubit.selectedAngleUnit.key}`)",
                      );
                      widget.onlineModelViewerCubit.webviewController.evaluateJavascript(
                        source: "nCircle.Ui.Toolbar.setAreaMeasurmentUnit(`${sideToolBarCubit.selectedAreaUnit.key}`)",
                      );
                      widget.onlineModelViewerCubit.webviewController.evaluateJavascript(
                        source: "nCircle.Ui.Toolbar.setMeasurementPrecision(`${sideToolBarCubit.selectedPrecisionUnit.key}`)",
                      );
                      sideToolBarCubit.isRulerMenuActive = true;
                      Navigator.of(context).pop();
                      showDialog(
                          barrierColor: Colors.transparent,
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            if (Utility.isIos) {
                              widget.onlineModelViewerCubit.callViewObjectFileAssociationDetails();
                            }
                            return UnitCalibration(
                              left: position.dx - 12 + (Utility.isSmallTablet ? 12 : 0),
                              top: widget.isOnlineModelViewerScreen && widget.onlineModelViewerCubit.isShowPdf && widget.orientation == Orientation.portrait && Utility.isTablet ? position.dy - (position.dy / 16) : position.dy - (position.dy / 4),
                            );
                          });
                    },
                    child: SizedBox(
                      child: Image.asset(
                        AImageConstants.areaSideToolBar,
                        scale: 1.0,
                        height: 25,
                        width: 25,
                        color: AColors.grColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          ),
        ),
        Positioned(
            key: const Key(AConstants.key_arrow_left),
            left: position.dx - 12 + (Utility.isSmallTablet ? 12 : 0),
            top: widget.isOnlineModelViewerScreen && widget.onlineModelViewerCubit.isShowPdf && widget.orientation == Orientation.portrait && Utility.isTablet ? position.dy - (position.dy / 16) : position.dy - (position.dy / 4),
            child: Image.asset(
              AImageConstants.arrowLeft,
              height: 26,
              width: 26,
            )),
      ],
    );
  }

  Widget openCuttingPlaneMenu(BuildContext context, Orientation orientation, Offset position) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          left: position.dx + 10 + (Utility.isSmallTablet ? 12 : 0),
          top: widget.isOnlineModelViewerScreen && widget.onlineModelViewerCubit.isShowPdf && widget.orientation == Orientation.portrait && Utility.isTablet ? position.dy - (position.dy / 6) : position.dy - (position.dy / 3),
          child: Container(
            width: 50,
            height: 280,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 8.0, color: Colors.grey.shade600),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: SizedBox(
                    key: const Key(AConstants.key_slice_x),
                    width: 25.0,
                    height: 25.0,
                    child: InkWell(
                      highlightColor: Colors.white24,
                      onTap: () {
                        widget.onlineModelViewerCubit.emitNormalWebState();
                        widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.cuttingPlane('x')");
                        sideToolBarCubit.isCuttingPlaneMenuActive = true;
                        sideToolBarCubit.isCuttingPlaneFirstSubMenuActive = true;
                        sideToolBarCubit.isCuttingPlaneSecondSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneThirdSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneFourthSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneFifthSubMenuActive = false;
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        child: Image.asset(
                          AImageConstants.sliceX,
                          scale: 1.0,
                          height: 25,
                          width: 25,
                          color: sideToolBarCubit.isCuttingPlaneFirstSubMenuActive ? AColors.enableColor : AColors.grColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: SizedBox(
                    key: const Key(AConstants.key_slice_y), width: 25.0, height: 25.0, // ignore: unnecessary_new
                    child: InkWell(
                      highlightColor: Colors.white24,
                      onTap: () {
                        widget.onlineModelViewerCubit.emitNormalWebState();
                        widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.cuttingPlane('y')");
                        sideToolBarCubit.isCuttingPlaneMenuActive = true;
                        sideToolBarCubit.isCuttingPlaneFirstSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneSecondSubMenuActive = true;
                        sideToolBarCubit.isCuttingPlaneThirdSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneFourthSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneFifthSubMenuActive = false;
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        child: Image.asset(
                          AImageConstants.sliceY,
                          scale: 1.0,
                          height: 25,
                          width: 25,
                          color: sideToolBarCubit.isCuttingPlaneSecondSubMenuActive ? AColors.enableColor : AColors.grColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: SizedBox(
                    key: const Key(AConstants.key_slice_z), width: 25.0, height: 25.0, // ignore: unnecessary_new
                    child: InkWell(
                      highlightColor: Colors.white24,
                      onTap: () {
                        widget.onlineModelViewerCubit.emitNormalWebState();
                        widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.cuttingPlane('z')");
                        sideToolBarCubit.isCuttingPlaneMenuActive = true;
                        sideToolBarCubit.isCuttingPlaneFirstSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneSecondSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneThirdSubMenuActive = true;
                        sideToolBarCubit.isCuttingPlaneFourthSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneFifthSubMenuActive = false;
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        child: Image.asset(
                          AImageConstants.sliceZ,
                          scale: 1.0,
                          height: 25,
                          width: 25,
                          color: sideToolBarCubit.isCuttingPlaneThirdSubMenuActive ? AColors.enableColor : AColors.grColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: SizedBox(
                    key: const Key(AConstants.key_show_slice), width: 25.0, height: 25.0, // ignore: unnecessary_new
                    child: InkWell(
                      highlightColor: Colors.white24,
                      onTap: () {
                        widget.onlineModelViewerCubit.emitNormalWebState();
                        widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.cuttingPlane('section')");
                        sideToolBarCubit.isCuttingPlaneMenuActive = true;
                        sideToolBarCubit.isCuttingPlaneFirstSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneSecondSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneThirdSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneFourthSubMenuActive = true;
                        sideToolBarCubit.isCuttingPlaneFifthSubMenuActive = false;
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        child: Image.asset(
                          AImageConstants.showSlice,
                          scale: 1.0,
                          height: 25,
                          width: 25,
                          color: sideToolBarCubit.isCuttingPlaneFourthSubMenuActive ? AColors.enableColor : AColors.grColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: SizedBox(
                    key: const Key(AConstants.key_inverse_slice), width: 25.0, height: 25.0, // ignore: unnecessary_new
                    child: InkWell(
                      highlightColor: Colors.white24,
                      onTap: () {
                        widget.onlineModelViewerCubit.emitNormalWebState();
                        widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.cuttingPlane('toggle')");
                        sideToolBarCubit.isCuttingPlaneMenuActive = true;
                        sideToolBarCubit.isCuttingPlaneFirstSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneSecondSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneThirdSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneFourthSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneFifthSubMenuActive = true;
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        child: Image.asset(
                          AImageConstants.inverseSlice,
                          scale: 1.0,
                          height: 25,
                          width: 25,
                          color: sideToolBarCubit.isCuttingPlaneFifthSubMenuActive ? AColors.enableColor : AColors.grColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: SizedBox(
                    key: const Key(AConstants.key_hide_slice), width: 20.0, height: 20.0, // ignore: unnecessary_new
                    child: InkWell(
                      highlightColor: Colors.white24,
                      onTap: () {
                        widget.onlineModelViewerCubit.emitNormalWebState();
                        widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.cuttingPlane('reset')");
                        sideToolBarCubit.isCuttingPlaneMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneFirstSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneSecondSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneThirdSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneFourthSubMenuActive = false;
                        sideToolBarCubit.isCuttingPlaneFifthSubMenuActive = false;
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        child: Image.asset(
                          AImageConstants.hideSliceSideToolBar,
                          scale: 1.0,
                          height: 20,
                          width: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            key: const Key(AConstants.key_arrow_left_cutting_plane),
            left: position.dx - 12 + (Utility.isSmallTablet ? 12 : 0),
            top: widget.isOnlineModelViewerScreen && widget.onlineModelViewerCubit.isShowPdf && widget.orientation == Orientation.portrait && Utility.isTablet ? position.dy - (position.dy / 18) : position.dy - (position.dy / 6.8),
            child: Image.asset(
              AImageConstants.arrowLeft,
              height: 26,
              width: 26,
            )),
      ],
    );
  }

  Widget openMarkerMenu(BuildContext context, Orientation orientation, Offset position) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Positioned(
          left: position.dx + 10 + (Utility.isSmallTablet ? 12 : 0),
          top: widget.isOnlineModelViewerScreen && widget.onlineModelViewerCubit.isShowPdf && widget.orientation == Orientation.portrait && Utility.isTablet ? position.dy - (position.dy / 6.8) : position.dy - (position.dy / 1.5),
          child: Container(
            width: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
              ),
              borderRadius: const BorderRadius.all(
                Radius.circular(10),
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 8.0, color: Colors.grey.shade600),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: SizedBox(
                    key: const Key(AConstants.key_edit_font), width: 20.0, height: 20.0, // ignore: unnecessary_new
                    child: InkWell(
                      key: const Key("key_red_line_text"),
                      highlightColor: Colors.white24,
                      onTap: () {
                        widget.onlineModelViewerCubit.emitNormalWebState();
                        widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.markup('redlineText')");
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        child: Image.asset(
                          AImageConstants.editFont,
                          scale: 1.0,
                          color: AColors.grColor,
                          height: 20,
                          width: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: SizedBox(
                    key: const Key(AConstants.key_free_hand_marker), width: 20.0, height: 20.0, // ignore: unnecessary_new
                    child: InkWell(
                      key: const Key("key_red_line_free_hand"),
                      highlightColor: Colors.white24,
                      onTap: () {
                        widget.onlineModelViewerCubit.emitNormalWebState();
                        widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.markup('redlineFreehand')");
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        child: Image.asset(
                          AImageConstants.freeHandMarkerMenu,
                          scale: 1.0,
                          height: 20,
                          color: AColors.grColor,
                          width: 20,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3.0),
                  child: SizedBox(
                    key: const Key(AConstants.key_plan_reset), width: 30.0, height: 30.0, // ignore: unnecessary_new
                    child: InkWell(
                      key: const Key("key_clear"),
                      highlightColor: Colors.white24,
                      onTap: () {
                        widget.onlineModelViewerCubit.emitNormalWebState();
                        widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.markup('clear')");
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        child: Image.asset(
                          AImageConstants.planeReset,
                          scale: 1.0,
                          height: 30,
                          width: 30,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            key: Key(AConstants.key_arrow_left_marker),
            left: position.dx - 12 + (Utility.isSmallTablet ? 12 : 0),
            top: widget.isOnlineModelViewerScreen && widget.onlineModelViewerCubit.isShowPdf && widget.orientation == Orientation.portrait && Utility.isTablet ? position.dy - (position.dy / 15) : position.dy - (position.dy / 3),
            child: Image.asset(
              AImageConstants.arrowLeft,
              height: 26,
              width: 26,
            )),
      ],
    );
  }

  void showRulerMenu(BuildContext context, Orientation orientation) async {
    sideToolBarCubit.isPopUpShowing = true;
    sideToolBarCubit.mContext = context;
    RenderBox box = rulerKey.currentContext?.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    return showDialog(
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.only(right: 210.0, bottom: 180),
            child: Dialog(
              alignment: Alignment.centerLeft,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: openRulerMenu(context, orientation, position),
            ),
          );
        }).then((value) => {
          sideToolBarCubit.isRulerMenuVisible(false),
          sideToolBarCubit.isPopUpShowing = false,
          sideToolBarCubit.mContext = null,
          widget.onlineModelViewerCubit.emitNormalWebState(),
        });
  }

  void showCuttingPlaneMenu(BuildContext context, Orientation orientation) async {
    sideToolBarCubit.isPopUpShowing = true;
    sideToolBarCubit.mContext = context;
    RenderBox box = cuttingPlaneKey.currentContext?.findRenderObject() as RenderBox;
    Offset position = box.localToGlobal(Offset.zero);
    return showDialog(
        barrierColor: Colors.transparent,
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Padding(
            padding: const EdgeInsets.only(right: 210.0, bottom: 180),
            child: Dialog(
              alignment: Alignment.centerLeft,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              child: openCuttingPlaneMenu(context, orientation, position),
            ),
          );
        }).then((value) => {
          sideToolBarCubit.isCuttingPlaneMenuVisible(false),
          sideToolBarCubit.isPopUpShowing = false,
          sideToolBarCubit.mContext = null,
          widget.onlineModelViewerCubit.emitNormalWebState(),
        });
  }

  void showMarkerMenu(BuildContext context, Orientation orientation) async {
    sideToolBarCubit.isPopUpShowing = true;
    sideToolBarCubit.mContext = context;
    RenderBox? box = markerKey.currentContext != null ? markerKey.currentContext?.findRenderObject() as RenderBox : null;
    Offset position = box?.localToGlobal(Offset.zero) ?? Offset.zero;
    return showDialog(
        context: context,
        barrierColor: Colors.transparent,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return Dialog(
            alignment: Alignment.centerLeft,
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            child: openMarkerMenu(context, orientation, position),
          );
        }).then((value) => {
          sideToolBarCubit.isMarkerMenuVisible(false),
          sideToolBarCubit.isPopUpShowing = false,
          sideToolBarCubit.mContext = null,
          widget.onlineModelViewerCubit.emitNormalWebState(),
        });
  }

  Container setMarginToDivider() {
    return Container(
      height: 0.5,
      width: 30,
      margin: const EdgeInsets.symmetric(vertical: 5),
      color: AColors.sideToolBarColor,
    );
  }
}
