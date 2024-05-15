import 'package:flutter/material.dart';

import '../presentation/managers/color_manager.dart';
import '../presentation/managers/font_manager.dart';
import '../utils/utils.dart';
import 'normaltext.dart';

class ATextbuttonWidget extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final dynamic color;
  final dynamic buttonIcon;
  final dynamic alignment;
  final dynamic textStyle;
  final double? fontSize;
  final FontWeight? fontWeight;

  const ATextbuttonWidget({
    Key? key,
    required this.label,
    required this.onPressed,
    this.color,
    this.fontSize,
    this.buttonIcon,
    this.alignment,
    this.textStyle,
    this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Utility.isTablet || buttonIcon == null
        ? Center(
            heightFactor: 1,
            child: TextButton(
              onPressed: onPressed,
              child: NormalTextWidget(
                label,
                color: color ?? AColors.themeBlueColor,
                fontSize: fontSize ?? 16.0,
                fontWeight: fontWeight,
                style: textStyle != null
                    ? const TextStyle(decoration: TextDecoration.underline)
                    : null,
              ),
            ),
          )
        : Align(
            alignment: alignment ?? Alignment.centerLeft,
            child: buttonIcon != null
                ? TextButton.icon(
                    onPressed: onPressed,
                    icon: Icon(
                      buttonIcon,
                      color: color ?? AColors.themeBlueColor,
                    ),
                    label: NormalTextWidget(
                      label,
                      fontWeight: fontWeight,
                      fontSize: fontSize ?? 16.0,
                      color: color ?? AColors.themeBlueColor,
                    ))
                : TextButton(
                    onPressed: onPressed,
                    child: NormalTextWidget(
                      label,
                      fontWeight: fontWeight,
                      fontSize: fontSize ?? 16.0,
                      color: color ?? AColors.themeBlueColor,
                    ),
                  ));
  }
}
