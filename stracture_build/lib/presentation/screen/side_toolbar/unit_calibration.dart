import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart';
import 'package:field/data/model/measurement_units.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/side_tool_bar/side_tool_bar_cubit.dart';
import '../../../injection_container.dart';
import '../../managers/color_manager.dart';

class UnitCalibration extends StatefulWidget {
  final double top, left;

  UnitCalibration({required this.top, required this.left});

  @override
  State<UnitCalibration> createState() => _UnitCalibrationState();
}

class _UnitCalibrationState extends State<UnitCalibration> with WidgetsBindingObserver {
  final SideToolBarCubit _sideToolBarCubit = getIt<SideToolBarCubit>();
  final OnlineModelViewerCubit _onlineModelViewerCubit = getIt<OnlineModelViewerCubit>();
  Orientation mediaQueryOrientation = MediaQuery.of(NavigationUtils.mainNavigationKey.currentContext!).orientation;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _onlineModelViewerCubit.isUnitCalibrationDialogShowing = true;
    return BlocBuilder<OnlineModelViewerCubit, OnlineModelViewerState>(builder: (context, state) {
      return OrientationBuilder(
        key: Key('key_unit_calibration_orientation'),
        builder: (BuildContext context, Orientation orientation) {
          if (mediaQueryOrientation != orientation) {
            Navigator.of(context).pop();
            mediaQueryOrientation = orientation;
            _onlineModelViewerCubit.emitNormalWebState();
          }
          return Stack(
            key: Key('key_unit_calibration_stack'),
            children: [
              Positioned(
                key: Key('key_unit_calibration_positioned'),
                top: widget.top,
                left: Utility.isTablet ? widget.left + 36 : 0,
                child: Padding(
                  key: Key('key_unit_calibration_padding'),
                  padding: EdgeInsets.only(left: Utility.isTablet ? 0 : 16),
                  child: Dialog(
                    key: Key('key_unit_calibration_dialog'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    alignment: Alignment(-0.8, -0.70),
                    child: Container(
                      key: Key('key_unit_calibration_container'),
                      width: Utility.isTablet && orientation == Orientation.portrait
                          ? MediaQuery.of(context).size.width / 2
                          : Utility.isTablet && orientation == Orientation.landscape
                              ? MediaQuery.of(context).size.width / 3.0
                              : MediaQuery.of(context).size.width / 1.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: EdgeInsets.all(8),
                      child: Column(
                        key: Key('key_unit_calibration_column'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            key: Key('key_unit_calibration_row'),
                            children: <Widget>[
                              SizedBox(
                                key: Key('key_unit_calibration_sized_box_empty'),
                                width: (IconTheme.of(context).size! + 8),
                              ),
                              Expanded(
                                child: NormalTextWidget(
                                  "Unit Calibration",
                                  key: Key('key_unit_calibration_text_widget'),
                                  fontWeight: AFontWight.regular,
                                  fontSize: 18,
                                  color: AColors.black,
                                ),
                              ),
                              IconButton(
                                  key: Key('key_unit_calibration_icon_button'),
                                  onPressed: () {
                                    _onlineModelViewerCubit.emitNormalWebState();
                                    Navigator.of(context).pop(false);
                                  },
                                  icon: Icon(Icons.close))
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              key: Key('key_unit_calibration_row_drop_down_distance'),
                              children: <Widget>[
                                Expanded(
                                  key: Key('key_unit_calibration_expanded_custom_drop_down_distance'),
                                  child: CustomDropdown(
                                      label: 'Distance Units',
                                      items: _sideToolBarCubit.distanceMeasurementUnit,
                                      selectedUnit: _sideToolBarCubit.selectedDistanceUnit,
                                      labelFontSize: 20.0,
                                      orientation: orientation,
                                      state: state,
                                      onChanged: (MeasurementUnits? newValue) {
                                        _onlineModelViewerCubit.emitNormalWebState();
                                        _sideToolBarCubit.selectedDistanceUnit = newValue!;
                                        _onlineModelViewerCubit.webviewController.evaluateJavascript(
                                          source: "nCircle.Ui.Toolbar.setDistanceMeasurementUnit(`${_sideToolBarCubit.selectedDistanceUnit.key}`)",
                                        );
                                        _onlineModelViewerCubit.emitUnitCalibrationUpdateState();
                                      } // Custom font size
                                      ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  key: Key('key_unit_calibration_expanded_angle'),
                                  child: CustomDropdown(
                                      label: 'Angle Units',
                                      items: _sideToolBarCubit.angleMeasurementUnit,
                                      selectedUnit: _sideToolBarCubit.selectedAngleUnit,
                                      labelFontSize: 20.0,
                                      orientation: orientation,
                                      state: state,
                                      onChanged: (MeasurementUnits? newValue) {
                                        _onlineModelViewerCubit.emitNormalWebState();
                                        _sideToolBarCubit.selectedAngleUnit = newValue!;
                                        _onlineModelViewerCubit.webviewController.evaluateJavascript(
                                          source: "nCircle.Ui.Toolbar.setAngleMeasurementUnit(`${_sideToolBarCubit.selectedAngleUnit.key}`)",
                                        );
                                        _onlineModelViewerCubit.emitUnitCalibrationUpdateState();
                                      } // / Custom font size
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  key: Key('key_unit_calibration_expanded_area'),
                                  child: CustomDropdown(
                                    label: 'Area Units',
                                    items: _sideToolBarCubit.areaMeasurementUnit,
                                    selectedUnit: _sideToolBarCubit.selectedAreaUnit,
                                    labelFontSize: 20.0,
                                    orientation: orientation,
                                    state: state,
                                    onChanged: (MeasurementUnits? newValue) {
                                      _onlineModelViewerCubit.emitNormalWebState();
                                      _sideToolBarCubit.selectedAreaUnit = newValue!;
                                      _onlineModelViewerCubit.webviewController.evaluateJavascript(
                                        source: "nCircle.Ui.Toolbar.setAreaMeasurmentUnit(`${_sideToolBarCubit.selectedAreaUnit.key}`)",
                                      );
                                      _onlineModelViewerCubit.emitUnitCalibrationUpdateState();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  key: Key('key_unit_calibration_expanded_precision'),
                                  child: CustomDropdown(
                                    label: 'Precision',
                                    items: _sideToolBarCubit.precisionUnit,
                                    selectedUnit: _sideToolBarCubit.selectedPrecisionUnit,
                                    labelFontSize: 20.0,
                                    orientation: orientation,
                                    state: state,
                                    onChanged: (MeasurementUnits? newValue) {
                                      _onlineModelViewerCubit.emitNormalWebState();
                                      _sideToolBarCubit.selectedPrecisionUnit = newValue!;
                                      _onlineModelViewerCubit.webviewController.evaluateJavascript(
                                        source: "nCircle.Ui.Toolbar.setMeasurementPrecision(`${_sideToolBarCubit.selectedPrecisionUnit.key}`)",
                                      );
                                      _onlineModelViewerCubit.emitUnitCalibrationUpdateState();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });
  }
}

class CustomDropdown extends StatefulWidget {
  final List<MeasurementUnits> items;
  final String label;
  final MeasurementUnits selectedUnit;
  final double labelFontSize;
  final ValueChanged<MeasurementUnits?>? onChanged;
  final Orientation orientation;
  final OnlineModelViewerState state;

  const CustomDropdown({
    required this.items,
    required this.label,
    required this.onChanged,
    required this.selectedUnit,
    required this.orientation,
    required this.state,
    this.labelFontSize = 16.0,
  });

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  final GlobalKey<DropdownButton2State<String>> dropdownKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Stack(
      key: Key('key_custom_drop_down'),
      children: [
        TextField(
          key: Key('key_custom_drop_down_text_field'),
          enabled: false,
          controller: TextEditingController(text: widget.label),
          decoration: InputDecoration(
            labelText: widget.label,
            labelStyle: TextStyle(fontSize: widget.labelFontSize, color: AColors.black),
            border: OutlineInputBorder(), // Remove the underline
            disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AColors.black)), // Remove the underline
            focusedBorder: InputBorder.none, // Remove the underline when focused
          ),
        ),
        Padding(
          key: Key('key_custom_drop_down_padding'),
          padding: EdgeInsets.only(left: (Utility.isTablet && widget.orientation == Orientation.portrait) || !Utility.isTablet ? 8 : 8, top: 8.0, right: 8.0),
          child: Center(
            key: Key('key_custom_drop_down_center'),
            child: DropdownButtonHideUnderline(
              key: Key('key_custom_drop_down_drop_down_button_hide_underline'),
              child: DropdownButton2<MeasurementUnits>(
                key: dropdownKey,
                isExpanded: true,
                hint: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                items: widget.items.map<DropdownMenuItem<MeasurementUnits>>(
                  (MeasurementUnits value) {
                    return DropdownMenuItem<MeasurementUnits>(
                      key: Key('key_drop_down_item'),
                      value: value,
                      child: Text(
                        value.value,
                      ),
                    );
                  },
                ).toList(),
                value: widget.selectedUnit,
                selectedItemBuilder: (con) {
                  return widget.items.map(
                    (MeasurementUnits value) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            value.value,
                            maxLines: 1,
                          ),
                        ),
                      );
                    },
                  ).toList();
                },
                onChanged: widget.onChanged,
                barrierDismissible: true,
                buttonStyleData: ButtonStyleData(
                  height: 40,
                  width: (Utility.isTablet && widget.orientation == Orientation.portrait) || !Utility.isTablet ? 210 : 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: Colors.white,
                    ),
                    color: Colors.white,
                  ),
                ),
                iconStyleData: const IconStyleData(
                  icon: Icon(
                    Icons.arrow_drop_down,
                    key: Key('key_icon_arrow_drop_down'),
                  ),
                  iconSize: 18,
                  iconEnabledColor: Colors.black,
                  iconDisabledColor: Colors.grey,
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 200,
                  width: !Utility.isTablet ? 155 : 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                  ),
                  offset: const Offset(-8, 0),
                  scrollbarTheme: ScrollbarThemeData(
                    radius: const Radius.circular(10),
                    thickness: MaterialStateProperty.all<double>(6),
                    thumbVisibility: MaterialStateProperty.all<bool>(true),
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 54,
                  padding: EdgeInsets.only(left: 14, right: 14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
