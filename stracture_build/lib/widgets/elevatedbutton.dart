import 'package:flutter/material.dart';

import '../presentation/managers/color_manager.dart';
import 'normaltext.dart';

class AElevatedButtonWidget extends StatelessWidget {
  final String btnLabel;
  final VoidCallback? onPressed;
  final dynamic btnLabelClr;
  final dynamic btnBackgroundClr;
  final dynamic btnBorderClr;
  final FontWeight? fontWeight;
  final double? height;
  final double? width;
  final double? letterSpacing;
  final double? borderRadius;
  final double? borderWidth;
  final double? textScaleFactor;

  final String? fontFamily;

  final double? fontSize;
  final BorderRadius? borderRadiusObject;

  const AElevatedButtonWidget(
      {Key? key,
      required this.btnLabel,
      required this.onPressed,
      this.btnLabelClr,
      this.btnBorderClr,
      this.btnBackgroundClr,
      this.fontWeight,
      this.height,
        this.letterSpacing,
      this.borderRadius,
      this.borderWidth,
      this.fontFamily,
      this.fontSize,
      this.width,
      this.borderRadiusObject,
      this.textScaleFactor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 40,
      width: width,
      child: Semantics(
        label: "ElevatedButton",
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            shape: MaterialStateProperty.resolveWith<OutlinedBorder>((_) {
              return RoundedRectangleBorder(side: BorderSide(color: btnBorderClr ?? btnBackgroundClr ?? AColors.themeBlueColor), borderRadius: borderRadiusObject ?? BorderRadius.circular(borderRadius ?? 5));
            }),
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return btnBackgroundClr ?? AColors.themeBlueColor;
                } else if (states.contains(MaterialState.disabled)) {
                  return btnBackgroundClr ?? AColors.themeBlueColor;
                }
                return btnBackgroundClr ?? AColors.themeBlueColor;
              },
            ),
          ),
          child: NormalTextWidget(
            btnLabel,
            color: btnLabelClr ?? AColors.white,
            style: TextStyle(letterSpacing: letterSpacing, fontFamily: fontFamily),
            fontWeight: fontWeight ?? FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}
