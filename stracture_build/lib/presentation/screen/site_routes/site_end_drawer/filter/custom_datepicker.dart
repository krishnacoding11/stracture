import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/custom_material_button_widget.dart';
import 'package:field/widgets/elevatedbutton.dart';
import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../analytics/event_analytics.dart';

class CustomDatePicker extends StatefulWidget {
  final Function onClose;
  final Function? onDateChanged;
  final int index;
  final String title;
  final Map jsonDateField;
  final String? previousSelectedDate;
  final String? strDateFormat;
  final Color? backgroundColor;

  const CustomDatePicker({super.key, required this.onClose, this.onDateChanged, required this.index, required this.title, required this.jsonDateField, this.previousSelectedDate, this.strDateFormat, this.backgroundColor});

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  Map<String, String> selectedDateMap = {};
  String selectedDate = "";
  String? strDateFormat;
  DateFormat? format;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor ?? AColors.filterBgColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 28, 18, 8),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const ScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(widget.title,
                                    style: TextStyle(
                                      color: AColors.iconGreyColor,
                                      fontFamily: AFonts.fontFamily,
                                      fontSize: 16,
                                      fontWeight: AFontWight.regular,
                                    )),
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
                          color: AColors.white,
                          elevation: 0,
                          onPressed: () {
                            widget.onClose();
                          },
                          height: 50,
                          width: 50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(color: AColors.iconGreyColor),
                          ),
                          child: Icon(color: AColors.iconGreyColor, Icons.arrow_back, size: 20),
                        ),
                      ],
                    ),
                    ADividerWidget(thickness: 1),
                    const SizedBox(height: 10),
                    CalendarDatePicker(
                        initialDate: widget.previousSelectedDate != null && widget.strDateFormat != null ? DateFormat(widget.strDateFormat).parse(widget.previousSelectedDate!) : DateTime.now(),
                        firstDate: DateTime(DateTime.now().year - 100),
                        lastDate: (widget.jsonDateField["indexField"] == "due_date") ? DateTime(DateTime.now().year + 100) : DateTime.now(),
                        onDateChanged: (value) {
                          selectedDateMap["start_date"] = DateFormat(widget.strDateFormat).format(value);
                        }),
                    InkWell(
                      onTap: () {
                        selectedDateMap["start_date"] = DateFormat(widget.strDateFormat).format(DateTime.now());
                        widget.onDateChanged!(selectedDateMap, widget.index);
                        widget.onClose();
                      },
                      child: Text(
                        context.toLocale!.lbl_today,
                        style: TextStyle(fontFamily: AFonts.fontFamily, color: AColors.themeBlueColor),
                      ),
                    ),
                    const SizedBox(height: 2),
                    ADividerWidget(
                      thickness: 0.1,
                      color: AColors.themeBlueColor,
                    ),
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: () {
                        selectedDateMap = Utility.getWeekStartEndDate(DateTime.now(), dateFormat: widget.strDateFormat!);
                        widget.onDateChanged!(selectedDateMap, widget.index);
                        widget.onClose();
                      },
                      child: Text(
                        context.toLocale!.lbl_this_week,
                        style: TextStyle(fontFamily: AFonts.fontFamily, color: AColors.themeBlueColor),
                      ),
                    ),
                    const SizedBox(height: 2),
                    ADividerWidget(
                      thickness: 0.1,
                      color: AColors.themeBlueColor,
                    ),
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: () {
                        selectedDateMap = Utility.get2WeekStartEndDate(DateTime.now(), dateFormat: widget.strDateFormat!);
                        widget.onDateChanged!(selectedDateMap, widget.index);
                        widget.onClose();
                      },
                      child: Text(
                        context.toLocale!.lbl_the_last_2_weeks,
                        style: TextStyle(fontFamily: AFonts.fontFamily, color: AColors.themeBlueColor),
                      ),
                    ),
                    const SizedBox(height: 2),
                    ADividerWidget(
                      thickness: 0.1,
                      color: AColors.themeBlueColor,
                    ),
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: () {
                        selectedDateMap = Utility.getMonthStartEndDate(DateTime.now());
                        widget.onDateChanged!(selectedDateMap, widget.index);
                        widget.onClose();
                      },
                      child: Text(
                        context.toLocale!.lbl_the_last_month,
                        style: TextStyle(fontFamily: AFonts.fontFamily, color: AColors.themeBlueColor),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Column(
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
                          selectedDate = "";
                          selectedDateMap = {};
                          widget.onDateChanged!(selectedDateMap, widget.index);
                          widget.onClose();
                        },
                      ),
                      const SizedBox(width: 10),
                      AElevatedButtonWidget(
                        btnLabel: context.toLocale!.lbl_btn_apply,
                        fontFamily: AFonts.fontFamily,
                        fontSize: 14,
                        onPressed: () async {
                          if (selectedDateMap.isEmpty) {
                            selectedDateMap["start_date"] = DateFormat(widget.strDateFormat).format(widget.previousSelectedDate != null ? DateFormat(strDateFormat).parse(widget.previousSelectedDate!) : DateTime.now());
                            FireBaseEventAnalytics.setEvent(FireBaseEventType.filterCreatedDateApply, FireBaseFromScreen.siteFormListingSearch, bIncludeProjectName: true);
                          }
                          widget.onDateChanged!(selectedDateMap, widget.index);
                          widget.onClose();
                        },
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
