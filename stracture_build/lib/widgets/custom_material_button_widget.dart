import 'package:flutter/material.dart';

import '../presentation/managers/color_manager.dart';

class CustomMaterialButtonWidget extends StatelessWidget {
  final double height;
  final double width;
  final double elevation;
  final VoidCallback onPressed;
  final dynamic color;
  final ShapeBorder? shape;
  final Widget child;

  const CustomMaterialButtonWidget({
    Key? key,
    required this.onPressed,
    required this.child,
    this.height = 50,
    this.width = 50,
    this.color = AColors.white,
    this.elevation = 0.0,
    this.shape,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: color,
      elevation: elevation,
      onPressed: onPressed,
      height: height,
      minWidth: width,
      shape: shape ??
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: BorderSide(color: AColors.iconGreyColor),
          ),
      padding: EdgeInsets.zero,
      child: child,
    );
  }
}
