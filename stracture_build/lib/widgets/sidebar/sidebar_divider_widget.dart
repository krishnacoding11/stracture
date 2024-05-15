import 'package:flutter/material.dart';

import '../../presentation/managers/color_manager.dart';

class ADividerWidget extends StatelessWidget {
  final double thickness;
  final double? height;
  Color? color;

  ADividerWidget({Key? key,
    required this.thickness,
    this.height,
    this.color,}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: color ?? AColors.dividerColor,
      thickness: thickness,
      height: height,
    );
  }
}