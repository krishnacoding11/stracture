import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/measurement_units.dart';
import 'package:field/data/model/model_vo.dart';
import 'package:field/exception/app_exception.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:flutter/cupertino.dart';

part 'side_tool_bar_state.dart';

class SideToolBarCubit extends BaseCubit {


  SideToolBarCubit() : super(PaginationListInitial());
  bool isRuler = false;
  bool isCuttingPlane = false;
  bool isMarker = false;
  bool isPictureInPictureMode = false;
  bool isSteps = false;
  bool isPopUpShowing = false;
  bool isJoystickShowing = false;
  bool isWhite = false;
  bool isSideToolBarEnabled = false;
  bool isRulerMenuActive = false;
  bool isRulerFirstSubMenuActive = false;
  bool isRulerSecondSubMenuActive = false;
  bool isRulerThirdSubMenuActive = false;
  bool isMarkerMenuActive = false;
  bool isCuttingPlaneMenuActive = false;
  bool isCuttingPlaneFirstSubMenuActive = false;
  bool isCuttingPlaneSecondSubMenuActive = false;
  bool isCuttingPlaneThirdSubMenuActive = false;
  bool isCuttingPlaneFourthSubMenuActive = false;
  bool isCuttingPlaneFifthSubMenuActive = false;
  bool isColorPickerMenuActive = false;
  String isColorAppliedToObject = "";
  Orientation? orientation;
  BuildContext? mContext;
  Model? selectedModel;
  MeasurementUnits selectedAreaUnit = MeasurementUnits("sqmm", "mm2");
  MeasurementUnits selectedDistanceUnit = MeasurementUnits("mm", "MM");
  MeasurementUnits selectedPrecisionUnit = MeasurementUnits("zero", "0");
  MeasurementUnits selectedAngleUnit = MeasurementUnits("Degrees", "Degrees");

  List<MeasurementUnits> areaMeasurementUnit = [
    MeasurementUnits("sqmm", "mm2"),
    MeasurementUnits("sqcm", "cm2"),
    MeasurementUnits("sqm", "m2"),
    MeasurementUnits("sqinch", "in2"),
    MeasurementUnits("sqfeet", "ft2"),
    MeasurementUnits("acre", "Acres"),
    MeasurementUnits("hectare", "Hectare"),
  ];

  List<MeasurementUnits> distanceMeasurementUnit = [
    MeasurementUnits("mm", "MM"),
    MeasurementUnits("cm", "CM"),
    MeasurementUnits("m", "Meter"),
    MeasurementUnits("inch", "Inch"),
    MeasurementUnits("feet", "Feet"),
    MeasurementUnits("fractional_inch", "Fractional Inch"),
    MeasurementUnits("fractional_foot", "Fractional feet & Inch"),
  ];

  List<MeasurementUnits> precisionUnit = [
    MeasurementUnits("zero", "0"),
    MeasurementUnits("one", "0.1"),
    MeasurementUnits("two", "0.01"),
    MeasurementUnits("three", "0.001"),
    MeasurementUnits("four", "0.0001"),
    MeasurementUnits("five", "0.00001"),
  ];

  List<MeasurementUnits> angleMeasurementUnit = [
    MeasurementUnits("Degrees", "Degrees"),
    MeasurementUnits("DegreesMinutesSeconds", "Degrees, Minutes and Seconds"),
    MeasurementUnits("Radians", "Radians"),
  ];

  void showPictureInPictureMode() {
    isPictureInPictureMode = !isPictureInPictureMode;
    emitState(PictureInPictureState(isPictureInPictureMode));
  }

  void isRulerMenuVisible(bool isVisible) {
    emitState(RulerMenuVisibility(isVisible, isJoystickShowing ? true : false));
  }

  void isCuttingPlaneMenuVisible(bool isVisible) {
    emitState(CuttingPlaneMenuVisibility(
        isVisible, isJoystickShowing ? true : false));
  }

  void showStepsIcon() {
    isSteps = !isSteps;
    isJoystickShowing = isSteps ? true : false;
    if (isClosed) {
      return;
    } else {
      emitState(StepsIconState(isSteps));
    }
  }

  void isMarkerMenuVisible(bool isVisible) {
    emitState(
        MarkerMenuVisibility(isVisible, isJoystickShowing ? true : false));
  }

  void isSideToolBarEnable() {
    emitState(SideToolBarEnableState());
  }

  void emitPagination() {
    emitState(PaginationListInitial());
  }

  void emitColorPickerState(){
    emit(ColorPickerState(isColorPickerMenuActive));
  }

  bool isThereCurrentDialogShowing(BuildContext context) =>
      ModalRoute.of(context)?.isCurrent != true;
}
