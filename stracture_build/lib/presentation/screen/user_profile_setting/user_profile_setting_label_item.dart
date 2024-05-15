import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';


class UserProfileSettingLabelItem extends StatelessWidget {
  final BuildContext? context;
  final String strLabel;
  final String strValue;
  final bool bIsBorderRequired;
  final bool bIsInfoIconRequired;
  final void Function()? onTap;
  final Widget? widget;

  const UserProfileSettingLabelItem({super.key,
    this.context,
    required this.strLabel,
    required this.strValue,
    this.bIsBorderRequired = false,
    this.bIsInfoIconRequired = false,
    this.onTap,
    this.widget
  }
    );

  @override
  Widget build(BuildContext context) {
    return Container(
      key:const Key("User_Profile_Setting_Label_Item"),
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      height: 50,
      decoration: BoxDecoration(
        border: bIsBorderRequired ? Border(bottom: BorderSide(width: 1, color: AColors.lightGreyColor)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: NormalTextWidget(
              strLabel,
              fontWeight: FontWeight.normal,
              fontSize: 16.0,
              color: AColors.iconGreyColor,
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(width: 10,),
          Flexible(
            child: widget??GestureDetector(
              onTap: onTap,
              child: NormalTextWidget(
                strValue,
                fontWeight: FontWeight.normal,
                fontSize: 16.0,
                maxLines: 1,
                color: AColors.textColor,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
  }
}