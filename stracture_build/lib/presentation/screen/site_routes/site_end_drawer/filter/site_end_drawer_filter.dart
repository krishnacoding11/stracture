import 'dart:convert';

import 'package:field/bloc/Filter/filter_cubit.dart';
import 'package:field/bloc/Filter/filter_state.dart';
import 'package:field/bloc/site/plan_cubit.dart';
import 'package:field/bloc/site/plan_loading_state.dart';
import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/filter/custom_datepicker.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/filter/custom_drop_down.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/filter/toggle_switch.dart';
import 'package:field/presentation/screen/site_routes/site_plan_viewer_screen.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/a_chip_widget.dart';
import 'package:field/widgets/backtologin_textbutton.dart';
import 'package:field/widgets/custom_material_button_widget.dart';
import 'package:field/widgets/elevatedbutton.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
import 'package:field/widgets/textformfieldwithchipsinputwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../enums.dart';
import '../../../../../utils/constants.dart';
import '../../../../../analytics/event_analytics.dart';
import 'date_picker.dart';

class SiteEndDrawerFilter extends StatefulWidget {
  final FilterScreen curScreen;
  final Function onClose;
  final Function onApply;
  ScrollController? animationScrollController = ScrollController();
  Map? data;

  SiteEndDrawerFilter({super.key, this.curScreen = FilterScreen.screenUndefined, required this.onClose, required this.onApply, this.animationScrollController, this.data});

  @override
  State<SiteEndDrawerFilter> createState() => _SiteEndDrawerFilterState();
}

class _SiteEndDrawerFilterState extends State<SiteEndDrawerFilter> {
  final _filterCubit = FilterCubit();
  late PlanCubit _planCubit;

  final TextEditingController? creationDate = TextEditingController();

  List<Widget> screenList = [];
  String? strDateFormat;

  final TextEditingController _filterNameController = TextEditingController();
  late bool isTablet;

  @override
  void initState() {
    super.initState();
    setStartDateForm();
    if (widget.curScreen == FilterScreen.screenHome) {
      if (widget.data?.containsKey("initialFilterName") ?? false) {
        _filterNameController.text = widget.data?["initialFilterName"];
      }
    } else {
      _planCubit = context.read<PlanCubit>();
    }
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getFilterData();
      FireBaseEventAnalytics.setCurrentScreen(FireBaseFromScreen.siteFormListingSearch.value);
    });
  }

  getSelectedPinFilterType() async {
    _planCubit.currentPinsType = Pins.values[await StorePreference.getSelectedPinFilterType()];
  }

  setStartDateForm() async {
    strDateFormat = await Utility.getUserDateFormat();
  }

  Future<void> getFilterData() async {
    _filterCubit.getFilterColumnData("2", curScreen: widget.curScreen);
  }

  @override
  Widget build(BuildContext context) {
    isTablet = context.width() > context.height();
    return BlocProvider(
        create: (_) => _filterCubit,
        child: BlocConsumer<FilterCubit, FlowState>(
            builder: (context, state) {
              if (state is LoadingState || state is InitialState) {
                return const Center(child: ACircularProgress());
              } else {
                return Stack(
                  children: [
                    _filterCubit.widgetList.isNotEmpty ? _showScrollView(state) : Container(),
                    for (Widget screen in screenList) screen,
                  ],
                );
              }
            },
            listener: (_, state) async {
              if (state is ShowDropDownState) {
                screenList.add(_dropDown(state));
              } else if (state is ShowDatePickerState) {
                screenList.add(_datePicker(state.index, state.labelText));
              }
            },
            buildWhen: (previous, current) => current is! FilterAttributeValueState));
  }

  Widget _dropDown(ShowDropDownState state) {
    var arr = state.props;
    int index = int.tryParse(arr.first.toString()) ?? 0;
    var temp = _filterCubit.widgetList[index];
    String jsonString = "";
    if (temp["dataType"] != "Dropdown") {
      jsonString = json.encode(temp);
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(0, widget.curScreen == FilterScreen.screenHome ? 0 : 28, 0, 8),
      child: BlocProvider.value(
        value: _filterCubit,
        child: CustomDropDown(
          onClose: (emitState) {
            screenList.removeLast();
            if (emitState) {
              _filterCubit.dismissDropDown();
            }
          },
          dropDownList: _filterCubit.currentSelectedDropdown,
          title: arr[1].toString(),
          titleFilter:  arr[2].toString(),
          index: index,
          jsonString: jsonString,
          backgroundColor: widget.curScreen == FilterScreen.screenHome ? AColors.white : AColors.filterBgColor,
          curScreen: widget.curScreen,
        ),
      ),
    );
  }

  Widget _showScrollView(FlowState state) {
    return Padding(
      padding: (widget.curScreen == FilterScreen.screenHome) ? const EdgeInsets.fromLTRB(8, 2, 8, 2) : const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          if (widget.curScreen != FilterScreen.screenHome)
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 2, 26, 2),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          context.toLocale!.lbl_task_filter,
                          style: TextStyle(
                            color: AColors.iconGreyColor,
                            fontFamily: AFonts.fontFamily,
                            fontSize: 16,
                            fontWeight: AFontWight.regular,
                          ),
                        ),
                        SizedBox(height: 12),
                        ADividerWidget(
                          thickness: 1,
                          color: AColors.lightGreyColor,
                          height: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                CustomMaterialButtonWidget(
                  child: Icon(color: AColors.iconGreyColor, Icons.close, size: 20),
                  onPressed: () {
                    widget.onClose();
                  },
                ),
              ],
            ),
          ),
          if (widget.curScreen != FilterScreen.screenHome)
          BlocBuilder<FilterCubit, FlowState>(
            buildWhen: (previous, current) => current is UpdateToggleState,
            builder: (context, state) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                children: [
                  AToggleSwitch(
                    width: 50.0,
                    height: 30.0,
                    toggleSize: 24.0,
                    value: (state is UpdateToggleState) ? state.isOverDueEnabled : _filterCubit.isOverdueEnabled,
                    borderRadius: 40.0,
                    padding: 2.5,
                    activeToggleColor: AColors.white,
                    inactiveToggleColor: AColors.white,
                    activeIcon: Icon(
                      Icons.check,
                      color: AColors.themeBlueColor,
                      size: 30,
                    ),
                    inactiveIcon: Image.asset(
                      AImageConstants.closeIcon,
                      height: 30,
                    ),
                    toggleColor: const Color.fromRGBO(225, 225, 225, 1),
                    activeColor: AColors.themeBlueColor,
                    inactiveColor: AColors.hintColor,
                    onToggle: (val) {
                      _filterCubit.toggleOverDue(val);
                    },
                  ),
                  ATextbuttonWidget(
                    onPressed: () {
                      _filterCubit.toggleOverDue(!_filterCubit.isOverdueEnabled);
                      FireBaseEventAnalytics.setEvent(FireBaseEventType.filterTaskOverdue, FireBaseFromScreen.siteFormListingSearch, bIncludeProjectName: true);
                    },
                    label: context.toLocale!.lbl_task_overdue,
                    fontWeight: AFontWight.regular,
                    fontSize: 15,
                    color: AColors.textColor,
                  ),
                  const Spacer(),
                  AToggleSwitch(
                    width: 50.0,
                    height: 30.0,
                    toggleSize: 24.0,
                    value: (state is UpdateToggleState) ? state.isCompletedEnabled : _filterCubit.isCompletedEnabled,
                    borderRadius: 40.0,
                    padding: 2.5,
                    activeToggleColor: AColors.white,
                    inactiveToggleColor: AColors.white,
                    activeIcon: Icon(
                      Icons.check,
                      color: AColors.themeBlueColor,
                      size: 30,
                    ),
                    inactiveIcon: Image.asset(
                      AImageConstants.closeIcon,
                      height: 30,
                    ),
                    toggleColor: const Color.fromRGBO(225, 225, 225, 1),
                    activeColor: AColors.themeBlueColor,
                    inactiveColor: AColors.hintColor,
                    onToggle: (val) {
                      _filterCubit.toggleComplete(val);
                    },
                  ),
                  ATextbuttonWidget(
                    onPressed: () {
                      _filterCubit.toggleComplete(!_filterCubit.isCompletedEnabled);
                      FireBaseEventAnalytics.setEvent(FireBaseEventType.filterComplete, FireBaseFromScreen.siteFormListingSearch, bIncludeProjectName: true);
                    },
                    label: context.toLocale!.lbl_task_completed,
                    fontWeight: AFontWight.regular,
                    fontSize: 15,
                    color: AColors.textColor,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: (widget.curScreen == FilterScreen.screenHome) ? const EdgeInsets.all(0): const EdgeInsets.fromLTRB(26, 0, 26, 0),
              controller: widget.animationScrollController,
              child: Column(
                children: [
                  if (widget.curScreen != FilterScreen.screenHome)
                  BlocBuilder<PlanCubit, FlowState>(
                      buildWhen: (previous, current) => current is PinsLoadedState,
                      builder: (context, state) {
                        return Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _getPinsTile("All Pins", Pins.all),
                            ),
                            Expanded(
                              flex: 3,
                              child: _getPinsTile("My Pins", Pins.my),
                            ),
                            Expanded(
                              flex: 4,
                              child: _getPinsTile("Hide all Pins", Pins.hide),
                            ),
                          ],
                        );
                      }),
                  if (widget.curScreen == FilterScreen.screenHome) ..._homeFilterShortcutNameWidget(),
                  ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _filterCubit.widgetList.length,
                    itemBuilder: (context, index) {
                      return Padding(padding: (widget.curScreen == FilterScreen.screenHome) ? const EdgeInsets.symmetric(horizontal: 0, vertical: 8) : const EdgeInsets.fromLTRB(0, 8, 0, 8), child: _getListings(index, state));
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          _filterBottomBar(),
        ],
      ),
    );
  }

  Widget _filterBottomBar() {
    return Container(
      color: (widget.curScreen != FilterScreen.screenHome) ? AColors.filterBgColor.withOpacity(0.5): AColors.white,
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Column(
        children: [
          if (widget.curScreen != FilterScreen.screenHome)
          ADividerWidget(
            thickness: 1,
            color: AColors.lightGreyColor,
            height: 1,
          ),
          SizedBox(height: 10),
          Padding(
            padding: (widget.curScreen == FilterScreen.screenHome) ? const EdgeInsets.all(0): const EdgeInsets.fromLTRB(26, 0, 26, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.curScreen == FilterScreen.screenHome) ..._homeFilterActionButtons(),
                if (widget.curScreen != FilterScreen.screenHome) ..._filterActionButtons(),
              ],
            ),
          )
        ],
      ),
    );
  }
  List<Widget> _filterActionButtons() {
    return [
      AElevatedButtonWidget(
        btnLabel: context.toLocale!.lbl_btn_clear,
        fontFamily: AFonts.fontFamily,
        fontWeight: FontWeight.normal,
        btnBorderClr: AColors.themeBlueColor,
        btnBackgroundClr: AColors.white,
        btnLabelClr: AColors.themeBlueColor,
        borderRadius: 5,
        fontSize: 14,
        onPressed: () async {
          await _filterCubit.clearFilterData(curScreen: widget.curScreen);
          widget.onApply(false);
        },
      ),
      const SizedBox(width: 10),
      AElevatedButtonWidget(
        btnLabel: context.toLocale!.lbl_btn_apply,
        fontFamily: AFonts.fontFamily,
        fontWeight: FontWeight.normal,
        fontSize: 14,
        onPressed: () async {
          await _filterCubit.saveSiteFilterData(curScreen: widget.curScreen);
          FireBaseEventAnalytics.setEvent(FireBaseEventType.filterApply, FireBaseFromScreen.siteFormListingSearch, bIncludeProjectName: true);
                    widget.onApply(true);
                  },
                )
              ];
  }

  void callback(String text, int index) {
    var temp = _filterCubit.widgetList[index];
    if (text.isEmpty) {
      if (_filterCubit.selectedFilterData[temp["id"]] != null) {
        _filterCubit.selectedFilterData[temp["id"].toString()] = text;
      }
    } else {
      _filterCubit.selectedFilterData[temp["id"].toString()] = text;
    }
  }

  _getListings(int index, FlowState state) {
    var currentWidget = _filterCubit.widgetList[index];
    var arr = currentWidget["popupTo"]["data"] ?? [];
    if (currentWidget["dataType"] == "text" || currentWidget["dataType"] == "Text") {
      if (currentWidget["returnIndexFields"] != "-1") {
        arr = _filterCubit.selectedFilterData[currentWidget["id"].toString()] ?? [];
      }
    }
    var chipArr = <ChipData>[];
    if (arr is List) {
      for (var obj in arr) {
        if (currentWidget["dataType"] == "text" || currentWidget["dataType"] == "Text") {
          if (currentWidget["returnIndexFields"] != "-1") {
            chipArr.add(ChipData(obj["value"] ?? "", {"data": obj, "index": index}));
          }
        } else {
          if (obj["isSelected"]) {
            chipArr.add(ChipData(obj["value"] ?? "", {"data": obj, "index": index}));
          }
        }
      }
    }

    if (currentWidget["dataType"] == "text" || currentWidget["dataType"] == "Text") {
      if (currentWidget["returnIndexFields"] != "-1") {
        return InkWell(
          onTap: () {
            _filterCubit.currentSelectedDropdown = _filterCubit.selectedFilterData[currentWidget["id"].toString()] ?? [];
            _filterCubit.showDropDown(currentWidget["fieldName"] ?? "", index, currentWidget["indexField"] ?? "" );
          },
          child: AChipWidget(
              lblText: currentWidget["fieldName"] ?? "",
              selectedChipList: chipArr,
              onChipDeleted: (ChipData chipData) {
                if (chipData.object is Map) {
                  Map data = chipData.object as Map;
                  if (int.tryParse(data["index"].toString()) != null) {
                    int index = int.tryParse(data["index"].toString()) ?? 0;
                    var temp = _filterCubit.widgetList[index];
                    List arr = _filterCubit.selectedFilterData[temp["id"].toString()] ?? [];
                    if (data["data"] is Map) {
                      Map ele = data["data"];
                      arr.removeWhere((element) => element["id"] == ele["id"]);
                      if (arr.isEmpty) {
                        _filterCubit.selectedFilterData.remove(temp["id"].toString());
                      } else {
                        _filterCubit.selectedFilterData[temp["id"].toString()] = arr;
                      }
                    }
                  }
                }
              }),
        );
      } else {
        return ATextFormFieldWithChipInputWidget(
          index: index,
          lblText: currentWidget["fieldName"] ?? "",
          chipList: const [],
          editingFinished: callback,
        );
      }
    } else if (currentWidget["dataType"] == "date" || currentWidget["dataType"] == "Date") {
      var dateValue = _filterCubit.selectedFilterData[_filterCubit.widgetList[index]["id"].toString()]?.values.join("-") ?? "";

      return InkWell(
        onTap: () {
          _filterCubit.showDatePicker(index, currentWidget["fieldName"] ?? "");
        },
        child: CustomDateField(
          key: ValueKey(dateValue),
          index: index,
          date: dateValue,
          textLabel: currentWidget["fieldName"] ?? "",
        ),
      );
    } else if (currentWidget["dataType"] == "Dropdown") {
      return InkWell(
        onTap: () {
          if (currentWidget["popupTo"]["data"] != null) {
            _filterCubit.currentSelectedDropdown = currentWidget["popupTo"]["data"] ?? [];
          } else {}

          _filterCubit.showDropDown(currentWidget["fieldName"] ?? "", index, currentWidget["indexField"] ?? "" );
        },
        child: AChipWidget(
            lblText: currentWidget["fieldName"] ?? "",
            selectedChipList: chipArr,
            onChipDeleted: (ChipData chipData) {
              if (chipData.object is Map) {
                Map data = chipData.object as Map;
                if (int.tryParse(data["index"].toString()) != null) {
                  int index = int.tryParse(data["index"].toString()) ?? 0;
                  var temp = _filterCubit.widgetList[index];
                  String strID = "";
                  strID = temp["id"].toString();
                  if (data["data"] is Map) {
                    Map ele = data["data"];
                    for (var dataObj in arr) {
                      if (dataObj["id"] == ele["id"]) {
                        dataObj["isSelected"] = false;
                        break;
                      }
                    }
                    var popUpTo = temp["popupTo"];
                    popUpTo["data"] = arr;
                    temp["popupTo"] = popUpTo;
                    _filterCubit.widgetList[index] = temp;
                    if (temp["indexField"] == "action_status") {
                      _filterCubit.updateToggle();
                      if (_filterCubit.selectedFilterData[strID] is List) {
                        List arrDrop = _filterCubit.selectedFilterData[strID];
                        arrDrop.removeWhere((element) => element["id"] == ele["id"]);
                        if (arrDrop.isEmpty) {
                          _filterCubit.selectedFilterData.remove(strID);
                        } else {
                          _filterCubit.selectedFilterData[strID] = arrDrop;
                        }
                      }
                    }
                  }
                }
              }
            }),
      );
    }
    return const SizedBox(width: 0, height: 0);
  }

  Widget _datePicker(int index, String label) {
    return Container(
      child: CustomDatePicker(
        index: index,
        onDateChanged: (value, index) {
          _filterCubit.dataSelectionCallBack(value, index);
        },
        onClose: () {
          screenList.removeLast();
          _filterCubit.dismissDropDown();
        },
        title: label,
        jsonDateField: _filterCubit.widgetList[index],
        previousSelectedDate: _filterCubit.selectedFilterData[_filterCubit.widgetList[index]["id"].toString()]?.values.join("-") ?? null,
        strDateFormat: strDateFormat,
        backgroundColor: widget.curScreen == FilterScreen.screenHome ? AColors.white : AColors.filterBgColor,
      ),
    );
  }

  List<Widget> _homeFilterShortcutNameWidget() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: Align(
            alignment: Alignment.centerLeft,
            child: NormalTextWidget(
              context.toLocale!.lbl_shortcut_name,
              fontSize: 16,
              textAlign: TextAlign.start,
              fontWeight: AFontWight.semiBold,
            )),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        child: TextFormField(
          textAlignVertical: TextAlignVertical.center,
          maxLines: 1,
          maxLength: 25,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(RegExp(AConstants.key_valid_name_regex)),
          ],
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          onSaved: (val) {
            _filterNameController.text = val!;
            _filterCubit.emitState(UpdateHomeShortcutNameState(val));
          },
          onChanged: (val) {
            _filterCubit.emitState(UpdateHomeShortcutNameState(val));
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            counterText: '',
            isDense: true,
            suffixIcon: InkWell(
                onTap: _filterNameController.text.isNotEmpty
                    ? () {
                        FocusScope.of(context).unfocus();
                        _filterNameController.clear();
                        context.closeKeyboard();
                        _filterCubit.emitState(UpdateHomeShortcutNameState(""));
                      }
                    : null,
                child: Visibility(visible: _filterNameController.text.isNotEmpty, child: Icon(Icons.close, color: AColors.iconGreyColor))),
            fillColor: AColors.white,
            filled: true,
            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black38, width: 1.0)),
            disabledBorder: InputBorder.none,
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black38, width: 1.0)),
          ),
          keyboardType: TextInputType.text,
          autofocus: false,
          obscureText: false,
          controller: _filterNameController,
          onTapOutside: (e) {
            context.closeKeyboard();
          },
        ),
      ),
    ];
  }

  List<Widget> _homeFilterActionButtons() {
    return [
      AElevatedButtonWidget(
          key: Key("filter_form_exit_button"),
          fontSize: isTablet ? 18 : 14,
          height: isTablet ? 40 : 35,
          width: isTablet ? 70 : 55,
          btnLabel: context.toLocale!.lbl_exit,
          letterSpacing: -1,
          fontWeight: AFontWight.semiBold,
          btnLabelClr: AColors.themeBlueColor,
          btnBackgroundClr: AColors.white,
          btnBorderClr: AColors.themeBlueColor,
          onPressed: () {
            widget.onClose();
          }),
      const SizedBox(width: 10),
      BlocBuilder<FilterCubit, FlowState>(buildWhen: (prev, current) {
        return current is UpdateFilterData || current is UpdateHomeShortcutNameState;
      }, builder: (context, state) {
        bool isConfirmEnable = (state is UpdateFilterData)
            ? state.filledFilterData.isNotEmpty && _filterNameController.text.toString().trim().isNotEmpty
            : (state is UpdateHomeShortcutNameState)
                ? state.shortcutName.isNotEmpty && _filterCubit.selectedFilterData.isNotEmpty
                : false;
        return AElevatedButtonWidget(key: Key("filter_form_confirm_button"), fontSize: isTablet ? 18 : 14, height: isTablet ? 40 : 35, width: 110, letterSpacing: -1, btnLabel: context.toLocale!.lbl_confirm_shortcut, fontWeight: AFontWight.semiBold, btnLabelClr: isConfirmEnable ? AColors.white : AColors.lightGreyColor, btnBackgroundClr: isConfirmEnable ? AColors.themeBlueColor : AColors.btnDisableClr, onPressed: isConfirmEnable ? _createNewShortCutFilter : null);
      })
    ];
  }

  // use when click confirm on filter form dialog to create new shortcut Filter for Homepage
  _createNewShortCutFilter() {
    Map<String, dynamic> data = {};
    data["id"] = HomePageIconCategory.filter.value;
    data["name"] = _filterNameController.text.toString().trim();
    data["config"] = _filterCubit.selectedFilterData;
    widget.onApply(data);
  }

  Widget _getPinsTile(String title, Pins pinValue) {
    return InkWell(
      onTap: () {
        StorePreference.setSelectedPinFilterType(pinValue.index);
        _planCubit.currentPinsType = pinValue;
        _planCubit.clearSiteTaskFilter();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Radio(
              visualDensity: const VisualDensity(horizontal: VisualDensity.minimumDensity, vertical: VisualDensity.minimumDensity),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              activeColor: AColors.themeBlueColor,
              value: pinValue,
              groupValue: _planCubit.currentPinsType,
              onChanged: (Pins? value) {
                StorePreference.setSelectedPinFilterType(value?.index);
                _planCubit.currentPinsType = value;
                _planCubit.clearSiteTaskFilter();
              },
            ),
            SizedBox(width: 8),
            NormalTextWidget(
              title,
              fontWeight: AFontWight.regular,
              fontSize: 16.0,
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    ); /*RadioListTile(
      title: NormalTextWidget(
        title,
        fontWeight: AFontWight.regular,
        fontSize: 16.0,
        textAlign: TextAlign.left,
      ),
      contentPadding: EdgeInsets.zero,
      activeColor: AColors.themeBlueColor,
      value: pinValue,
      groupValue: _planCubit.currentPinsType,
      onChanged: (Pins? value) {
        StorePreference.setSelectedPinFilterType(value?.index);
        _planCubit.currentPinsType = value;
        _planCubit.clearSiteTaskFilter();
      },
      dense: true,
      controlAffinity: ListTileControlAffinity.leading,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );*/
  }
}
