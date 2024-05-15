import 'package:field/presentation/managers/font_manager.dart';
import 'package:flutter/material.dart';

import '../presentation/managers/color_manager.dart';

class ClickableTextWidget extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final TextStyle? style;
  final int? maxLines;
  final double? fontSize;
  final dynamic color;
  final FontWeight? fontWeight;
  final TextOverflow? overflow;
  final VoidCallback onPressed;
  final bool isEnable;

  const ClickableTextWidget(this.text, {required this.onPressed, Key? key, this.textAlign, this.style, this.maxLines, this.fontSize, this.color, this.fontWeight, this.overflow, this.isEnable = true})
      : assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnable ? onPressed : null,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Text(text,
            maxLines: maxLines,
            overflow: maxLines != null ? overflow : null,
            textAlign: textAlign ?? TextAlign.center,
            style: style != null
                ? style?.copyWith(
                    color: isEnable ? color ?? AColors.themeBlueColor : AColors.lightGreyColor,
                    fontFamily: AFonts.fontFamily,
                    fontWeight: fontWeight ?? AFontWight.regular,
                    fontSize: fontSize ?? 16,
                  )
                : TextStyle(
                    decoration: TextDecoration.none,
                    color: isEnable ? color ?? AColors.themeBlueColor : AColors.lightGreyColor,
                    fontFamily: AFonts.fontFamily,
                    fontWeight: fontWeight ?? AFontWight.regular,
                    fontSize: fontSize ?? 16,
                  )),
      ),
    );
  }
}
