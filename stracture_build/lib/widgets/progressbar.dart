import 'package:flutter/material.dart';

class ACircularProgress extends StatelessWidget {
  final Color? color;
  final double? strokeWidth;
  final double? progressValue;
  final Color? backgroundColor;

  const ACircularProgress({
    Key? key,
    this.strokeWidth = 2,
    this.color,
    this.progressValue,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth!,
        color: color,
        backgroundColor: backgroundColor,
        value: progressValue,
      ),
    );
  }
}
