import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';


class UserProfileSettingLabelItemWithIcon extends StatelessWidget {
  final BuildContext? context;
  final String strLabel;
  final bool bIsBorderRequired;
  final void Function()? onTap;

  const UserProfileSettingLabelItemWithIcon({super.key,
    this.context,
    required this.strLabel,
    this.bIsBorderRequired = false,
    this.onTap}
    );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key:const Key("User_Profile_Setting_Label_Item_With_Icon"),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        height: 40,
        decoration: BoxDecoration(
          border: bIsBorderRequired ? Border(bottom: BorderSide(width: 1, color: AColors.dividerColor)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            NormalTextWidget(
              strLabel,
              fontWeight: AFontWight.regular,
              fontSize: 16.0,
              color: AColors.iconGreyColor,
              textAlign: TextAlign.left,
            ),
            Icon(
              Icons.arrow_forward_ios_outlined,
              color: AColors.iconGreyColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}