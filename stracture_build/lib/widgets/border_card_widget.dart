import 'package:flutter/material.dart';


class ABorderCardWidget extends StatelessWidget {
  final BorderDirectional border;
  final Widget child;
  final Color? cardColor;
  const ABorderCardWidget(
      {Key? key,
         required this.border,
         required this.child,
         this.cardColor
        })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: (cardColor!=null)?cardColor:Colors.white,
      elevation: 2,
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3))),
        child: Container(
              decoration: BoxDecoration(
              border: border),
              child: child),
        ),
      );
  }
}
