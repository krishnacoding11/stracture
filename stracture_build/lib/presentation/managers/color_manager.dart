import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';

class AColors {
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  // Button disable color
  static Color btnDisableClr = "#EEEEEE".toColor();
  static Color greyColor = "#DCE9F3".toColor();
  static Color grColor = "#80263238".toColor();
  static Color grColorLight = "#E0E0E0".toColor();
  static Color grColorDark = "#757575".toColor();
  static Color greyColor1 = "#BDBDBD".toColor();
  // Button enable color
  static Color themeBlueColor = "#085B90".toColor();
  static Color aPrimaryColor = "#0D2745".toColor();
  static Color enableColor = "#085B90".toColor();
  static Color greenColor = "#4CAF50".toColor();
  // Disable button text color
  static Color lightGreyColor = "#BDBDBD".toColor();
  static Color darkGreyColor = "#D9D9D9".toColor();
  // common black text color
  static Color textColor = "#263238".toColor();
  static Color textColorDialog = "#263238".toColor();
  static Color textColor1 = "#3A5872".toColor();
  static Color hintColor = "#9E9E9E".toColor();
  static Color shadowColor = "#40000000".toColor();
  static Color iconGreyColor = "#757575".toColor();
  static Color themeLightColor = "#EEF7FF".toColor();

  static Color menuSelectedColor = "#7898B8".toColor();

  static Color userOnlineColor = "#F44336".toColor();
  static Color listItemSelected = "#D5EAFF".toColor();
  static Color dividerColor = "#E0E0E0".toColor();
  static Color blueColor = "#4CB0F0".toColor();
  static Color taskListGreyColor = "#F7F7F7".toColor();

  static Color filterBgColor = "#EEEEEE".toColor();

  static Color bannerWaringColor = "#FF9800".toColor();
  static Color warningIconColor = "#FF9800".toColor();
  static Color sideToolBarColor = "#E0E0E0".toColor();

  static Color locationBgColor = "#EEEEEE".toColor();

  // circle progress bar color
  static Color lightGreenColor = "#4CAF50".toColor();
  static Color progressBarBgColor = "#E0E0E0".toColor();

  static Color offlineSyncProgressBarColor = "#D4EAFF".toColor();
  static Color offlineSyncProgressColor = "#4CB0F0".toColor();
  static Color offlineSyncDoneColor = "#4CAF50".toColor();

  static Color deleteBannerBgGrey = "#F6F6F6".toColor();
  static Color modelColorForStorage = "#9260ff".toColor();
  static Color lightBlueColor = "#d4eaff".toColor();
  static Color optionMenuBottomBar = aPrimaryColor.withOpacity(0.8);
  static Color lightBlue = "#085B90".toColor();
  static Color splashBgBlue = "#42a5f5".toColor();

  //dashboard task color

  static Color newTasks = "#4EAFEE".toColor();
  static Color tasksDueToday = "#50B057".toColor();
  static Color taskDueThisWeek = "#FE991B".toColor();
  static Color taskOverDue = "#F24235".toColor();


  //New dashboard background color
  static Color backgroundBlueColor = "#eef7ff".toColor();

  // Color state for button.
  static Color buttonStateColor(Set<MaterialState> states) => states.any(<MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      }.contains)
          ? AColors.aPrimaryColor
          : AColors.themeBlueColor;
}
