import 'package:field/presentation/managers/font_manager.dart';
import 'package:flutter/material.dart';

import '../presentation/managers/color_manager.dart';

class NormalTextWidget extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final TextStyle? style;
  final int? maxLines;
  final double? fontSize;
  final double? textScaleFactor;
  final dynamic color;
  final FontWeight? fontWeight;
  final TextOverflow? overflow;
  final TextDirection? textDirection;

  const NormalTextWidget(this.text, {Key? key, this.textAlign, this.style, this.maxLines, this.fontSize, this.textScaleFactor, this.color, this.fontWeight, this.overflow, this.textDirection})
      : assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        textDirection: textDirection ?? Directionality.of(context),
        maxLines: maxLines,
        strutStyle: StrutStyle(
          fontFamily: AFonts.fontFamily,
          forceStrutHeight: true,
          fontSize: fontSize ?? 16,
          fontStyle: FontStyle.normal
        ),
        overflow: maxLines != null ? overflow : null,
        textAlign: textAlign != null
            ? Directionality.of(context) == TextDirection.rtl && textAlign == TextAlign.left
            ? TextAlign.right
                : textAlign
            : TextAlign.center,
        textScaleFactor: textScaleFactor,
        style: style != null
            ? style?.copyWith(
                color: color ?? AColors.textColor,
                fontFamily: AFonts.fontFamily,
                fontWeight: fontWeight ?? AFontWight.bold,
                fontSize: fontSize ?? 16,
                fontStyle: FontStyle.normal
              )
            : TextStyle(
                decoration: TextDecoration.none,
                color: color ?? AColors.textColor,
                fontFamily: AFonts.fontFamily,
                fontWeight: fontWeight ?? AFontWight.bold,
                fontSize: fontSize ?? 16,
            fontStyle: FontStyle.normal
              ));
  }
}
