import 'package:flutter/material.dart';

import '../presentation/managers/color_manager.dart';
import '../presentation/managers/font_manager.dart';

class HeadlineTextWidget extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const HeadlineTextWidget(this.text,
      {Key? key,
      this.textAlign,
      this.style,
      this.maxLines,
      this.overflow})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      // overflow: maxLines != null ? overflow : null,
      textAlign: textAlign?? TextAlign.center,
      textScaleFactor: 1.8,
      style: style ?? TextStyle(
        color: AColors.textColor,
        fontFamily: AFonts.fontFamily,
        fontWeight: AFontWight.semiBold,
        decoration: TextDecoration.none,
      ),
    );
  }
}
