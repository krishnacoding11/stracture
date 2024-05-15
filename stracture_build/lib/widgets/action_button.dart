import 'package:flutter/material.dart';

import '../presentation/managers/color_manager.dart';
import '../presentation/managers/font_manager.dart';
import '../widgets/normaltext.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final Function? deleteHandler;
  final Function? buttonClickHandler;

  const ActionButton(
      {Key? key,
      required this.text,
      required this.color,
      this.deleteHandler,
      this.buttonClickHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0.0),
      width: 100,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          color: color,),
      child: Row(
        children: [
          InkWell(
            key: const Key("KeyActionButton"),
            onTap: () {
              buttonClickHandler!();
            },
            child: Container(
              width: 85,
              padding:
                  const EdgeInsets.symmetric(vertical: 15.5, horizontal: 7),
              decoration: const BoxDecoration(
                border:
                    Border(right: BorderSide(width: 1, color: Colors.white30)),
              ),
              child: NormalTextWidget(
                text,
                color: AColors.white,
                fontWeight: AFontWight.regular,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(
              width: 24,
              child: IconButton(
                key: const Key("CrossIconButton"),
                padding: const EdgeInsets.all(4),
                alignment: Alignment.center,
                icon: const Icon(Icons.clear, size: 17, color: AColors.white),
                onPressed: () {
                  deleteHandler!();
                },
              )),
        ],
      ),
    );
  }
}
