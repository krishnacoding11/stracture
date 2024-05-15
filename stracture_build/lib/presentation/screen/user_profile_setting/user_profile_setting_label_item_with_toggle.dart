import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/filter/toggle_switch.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';

class UserProfileSettingLabelItemWithToggle extends StatelessWidget {
  final BuildContext? context;
  final String strLabel;
  final bool bIsBorderRequired;
  final bool toggleValue;
  final Function(bool) onToggle;
  final Widget? childWidget;

  const UserProfileSettingLabelItemWithToggle({super.key, this.context, required this.strLabel, this.bIsBorderRequired = false, this.toggleValue = false, required this.onToggle, this.childWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      height: 40,
      decoration: BoxDecoration(
        border: bIsBorderRequired ? Border(bottom: BorderSide(width: 1, color: AColors.dividerColor)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: NormalTextWidget(
              strLabel,
              fontWeight: AFontWight.regular,
              fontSize: 16.0,
              color: AColors.iconGreyColor,
              textAlign: TextAlign.left,
            ),
          ),
          if(childWidget != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: childWidget!,
          ),
          AToggleSwitch(
            width: 48.0,
            height: 28.0,
            toggleSize: 24.0,
            value: toggleValue,
            borderRadius: 40.0,
            padding: 1.8,
            activeToggleColor: AColors.white,
            inactiveToggleColor: AColors.white,
            activeIcon: Icon(
              Icons.check,
              color: AColors.themeBlueColor,
              size: 30,
            ),
            inactiveIcon: Icon(
              Icons.close,
              color: AColors.hintColor,
              size: 30,
            ),
            toggleColor: const Color.fromRGBO(225, 225, 225, 1),
            activeColor: AColors.themeBlueColor,
            inactiveColor: AColors.hintColor,
            onToggle: (val) => onToggle(val),
          ),
        ],
      ),
    );
  }
}
