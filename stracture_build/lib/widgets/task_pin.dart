import 'package:flutter/material.dart';

import '../presentation/managers/color_manager.dart';

class TaskPin extends StatefulWidget {
  const TaskPin({Key? key, required this.isShowAnimation, this.iconSize})
      : super(key: key);
  final bool isShowAnimation;
  final double? iconSize;

  @override
  State<TaskPin> createState() => _TaskPinState();
}

class _TaskPinState extends State<TaskPin> with SingleTickerProviderStateMixin {
  AnimationController? controller;
  Animation? offsetAnimation;
  late double iconSize;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    iconSize = widget.iconSize ?? 40;
    if (widget.isShowAnimation) {
      controller = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 500));
      offsetAnimation = Tween<double>(begin: -5, end: 2).animate(controller!);
      controller?.addListener(() {
        setState(() {});
      });

      controller?.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.isShowAnimation
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: BoxConstraints.tight(Size(iconSize, iconSize)),
                child: Transform.translate(
                    offset: Offset(0,
                        offsetAnimation != null ? -offsetAnimation!.value : 0),
                    child: Icon(
                      Icons.location_on_sharp,
                      color: AColors.aPrimaryColor,
                      size: iconSize - 5,
                    )),
              ),
              Container(
                color: AColors.aPrimaryColor,
                height: 3,
                width: iconSize / 2,
              )
            ],
          )
        : Icon(
            Icons.pin_drop,
            color: AColors.aPrimaryColor,
            size: iconSize,
          );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
