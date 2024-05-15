import 'dart:async';

import 'package:field/analytics/event_analytics.dart';
import 'package:field/bloc/Filter/filter_cubit.dart';
import 'package:field/bloc/Filter/filter_state.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/elevatedbutton.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
import 'package:field/widgets/textformfieldwidget.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../domain/use_cases/Filter/filter_usecase.dart';

class LabeledCheckbox extends StatefulWidget {
  const LabeledCheckbox({
    super.key,
    required this.label,
    required this.padding,
    required this.value,
    required this.onChanged,
    required this.onTap,
  });

  final String label;
  final EdgeInsets padding;
  final bool value;
  final Function onTap;
  final ValueChanged<bool> onChanged;

  @override
  State<LabeledCheckbox> createState() => _LabeledCheckboxState();
}

class _LabeledCheckboxState extends State<LabeledCheckbox> {
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    isSelected = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: widget.padding,
        child: CheckboxListTile(
          activeColor: AColors.themeBlueColor,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          visualDensity: const VisualDensity(horizontal: -4.0, vertical: -4.0),
          value: isSelected,
          onChanged: (value) {
            setState(() {
              isSelected = value!;
              widget.onChanged(value);
            });
          },
          title: NormalTextWidget(
            textAlign: TextAlign.left,
            widget.label,
            fontWeight: FontWeight.normal,
            maxLines: 1,
          ),
        ));
  }
}

class CustomCheckbox extends StatefulWidget {
  final Function onChange;
  final bool isChecked;
  final double size;
  final double iconSize;
  final Color selectedColor;
  final Color selectedIconColor;
  final Color borderColor;
  final Icon checkIcon;

  CustomCheckbox({super.key, required this.isChecked, required this.onChange, required this.size, required this.iconSize, required this.selectedColor, required this.selectedIconColor, required this.borderColor, required this.checkIcon});

  @override
  CustomCheckboxState createState() => CustomCheckboxState();
}

class CustomCheckboxState extends State<CustomCheckbox> {
  bool _isSelected = false;

  @override
  void initState() {
    _isSelected = widget.isChecked;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isSelected = !_isSelected;
          widget.onChange(_isSelected);
        });
      },
      child: AnimatedContainer(
        margin: const EdgeInsets.all(4),
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastLinearToSlowEaseIn,
        decoration: BoxDecoration(
            color: _isSelected ? widget.selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(3.0),
            border: Border.all(
              color: widget.borderColor,
              width: 1.5,
            )),
        width: widget.size,
        height: widget.size,
        child: _isSelected
            ? Icon(
                Icons.check,
                color: widget.selectedIconColor,
                size: widget.iconSize,
              )
            : null,
      ),
    );
  }
}

class CustomDropDown extends StatefulWidget {
  final Function onClose;

  final List<dynamic> dropDownList;
  final String title;
  final String titleFilter;
  final int index;
  final String? jsonString;
  final Color? backgroundColor;
  final FilterScreen? curScreen;

  const CustomDropDown({
    super.key,
    required this.onClose,
    required this.dropDownList,
    required this.title,
    required this.titleFilter,
    required this.index,
     this.curScreen,
    this.backgroundColor,
    this.jsonString,
  });

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  final TextEditingController _searchController = TextEditingController();
  var searchText = "";
  late FilterCubit filterCubit;
  List<dynamic> listItem = [];
  Set selectedDropDownList = {};
  late FilterCubit _filterAttributeCubit;
  Timer? _debounceTimer;
  Duration debounceDuration = const Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    filterCubit = context.read<FilterCubit>();
    _filterAttributeCubit = getIt<FilterCubit>();
    listItem = widget.dropDownList;
    if (widget.jsonString != null) {
      selectedDropDownList = {...widget.dropDownList};
    }
    getListItem();
    _searchController.addListener(_textFieldChange);
  }

  void _textFieldChange() {
    if (searchText != _searchController.text && (_searchController.text == "" || _searchController.text.length >= 3)) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(debounceDuration, () {
        if (_debounceTimer!.isActive) return;

        searchText = _searchController.text;
        getListItem();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor ?? AColors.filterBgColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 8),
        child: BlocProvider(
          create: (_) => _filterAttributeCubit,
          child: BlocBuilder<FilterCubit, FlowState>(
            buildWhen: (previous, current) => current is FilterAttributeValueState || current is LoadingState || current is FilterAttributeValueErrorState,
            builder: (context, state) {
              return Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        child: Icon(Icons.arrow_back, size: 25, color: AColors.iconGreyColor),
                        onTap: () {
                          widget.onClose(true);
                        },
                      ),
                      const Spacer(),
                      Text(widget.title,
                          style: TextStyle(
                            color: AColors.iconGreyColor,
                            fontFamily: AFonts.fontFamily,
                            fontSize: 16,
                            fontWeight: AFontWight.regular,
                          )),
                      const Spacer(),
                    ],
                  ),
                  ADividerWidget(thickness: 1, color: AColors.lightGreyColor),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: AColors.iconGreyColor)),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Icon(Icons.search, color: AColors.iconGreyColor),
                        Flexible(
                          child: ATextFormFieldWidget(
                            key: const Key('search'),
                            keyboardType: TextInputType.name,
                            isPassword: false,
                            obscureText: false,
                            controller: _searchController,
                            hintText: context.toLocale!.search_for,
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(child: _getListviewBuilder(state)),
                  _filterBottomBar(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_textFieldChange);
    _debounceTimer?.cancel();
    super.dispose();
  }

  Widget _circularProgressWidget() {
    return const Center(child: ACircularProgress());
  }

  _getListviewBuilder(FlowState state) {
    if (state is LoadingState || state is InitialState) {
      return _circularProgressWidget();
    } else if (state is FilterAttributeValueState) {
      listItem = [...state.data];
      if (listItem.isEmpty) {
        return Center(child: NormalTextWidget(fontWeight: FontWeight.normal, context.toLocale!.no_data_available));
      } else {
        return ListView.builder(
            shrinkWrap: true,
            itemCount: listItem.length,
            physics: const ScrollPhysics(),
            itemBuilder: (context, index) {
              return _getListings(index);
            });
      }
    } else if (state is FilterAttributeValueErrorState) {
      return Center(child: NormalTextWidget(fontWeight: FontWeight.normal, context.toLocale!.error_message_something_wrong));
    }
  }

  _getListings(int index) {
    var temp = listItem[index];
    String title = temp["value"] ?? "";
    bool isSelected;
    if (!isJsonStringNullOrEmpty()) {
      isSelected = selectedDropDownList.singleWhere((x) => x["id"] == temp["id"], orElse: () => null) != null;
    } else {
      isSelected = temp["isSelected"] ?? false;
    }
    return LabeledCheckbox(
      key: UniqueKey(),
      label: title,
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      value: isSelected,
      onChanged: (bool newValue) {
        temp["isSelected"] = newValue;
        if (!isJsonStringNullOrEmpty()) {
          if (newValue) {
            selectedDropDownList.add(temp);
          } else {
            selectedDropDownList.removeWhere((element) => element["id"] == temp["id"]);
          }
        }
      },
      onTap: () {},
    );
  }

  bool isJsonStringNullOrEmpty() {
    return widget.jsonString.isNullOrEmpty();
  }

  Widget _filterBottomBar() {
    return Column(
      children: [
        ADividerWidget(thickness: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AElevatedButtonWidget(
              btnLabel: context.toLocale!.lbl_btn_clear,
              fontFamily: AFonts.fontFamily,
              btnBorderClr: AColors.themeBlueColor,
              btnBackgroundClr: AColors.white,
              btnLabelClr: AColors.themeBlueColor,
              borderRadius: 5,
              fontSize: 14,
              onPressed: () {
                if (isJsonStringNullOrEmpty()) {
                  for (var obj in widget.dropDownList) {
                    obj["isSelected"] = false;
                  }
                }
                _filterAttributeCubit.clearFilterOptions(listItem);
                selectedDropDownList.clear();
                if (_searchController.text.isNotEmpty) {
                  _searchController.text = "";
                  _textFieldChange();
                }
              },
            ),
            const SizedBox(width: 10),
            AElevatedButtonWidget(
              btnLabel: context.toLocale!.button_text_select,
              fontFamily: AFonts.fontFamily,
              fontSize: 14,
              onPressed: () {
                if (!isJsonStringNullOrEmpty()) {
                  filterCubit.selectDropDown(selectedDropDownList.toList(), widget.index);
                } else {
                  filterCubit.selectDropDown(listItem, widget.index);
                }
                _getSelect();
                widget.onClose(false);
              },
            )
          ],
        )
      ],
    );
  }

  _getSelect() {
    FireBaseEventType event;
    switch (widget.titleFilter) {
      case "form_type_name":
        event = FireBaseEventType.filterFormTypeSelect;
        break;
      case "originator_user_id":
        event =  FireBaseEventType.filterOriginatorSelect;
        break;
      case "originator_organisation":
        event =  FireBaseEventType.filterOriginatorOrgSelect;
        break;
      case "distribution_list":
        event = FireBaseEventType.filterRecipientSelect;
        break;
      case "recipient_org":
        event = FireBaseEventType.filterRecipientOrgSelect;
        break;
      case "form_status":
        event = FireBaseEventType.filterStatusSelect;
        break;
      case "action_status":
        event = FireBaseEventType.filterTaskStatusSelect;
        break;
      default:
        return;
    }
  if (widget.curScreen == FilterScreen.screenSite) {
    FireBaseEventAnalytics.setEvent(
        event,
        FireBaseFromScreen.siteFormListingSearch,
        bIncludeProjectName: true);
    } else if (widget.curScreen == FilterScreen.screenTask) {
      FireBaseEventAnalytics.setEvent(
          event,
          FireBaseFromScreen.taskList,
          bIncludeProjectName: true);
    }
  }

  void getListItem() {
    if (!isJsonStringNullOrEmpty()) {
      _filterAttributeCubit.getFilterSearchData(searchText, widget.jsonString ?? "");
    } else {
      _filterAttributeCubit.getFilterSearchDataLocally(searchText, widget.dropDownList);
    }
  }
}
