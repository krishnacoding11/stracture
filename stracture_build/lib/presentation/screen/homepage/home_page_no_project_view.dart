import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';

import '../../../widgets/normaltext.dart';

class HomePageNoProjectView extends StatelessWidget {
  final bool isOnline;

  const HomePageNoProjectView({required this.isOnline, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          isOnline
              ? NormalTextWidget(
                  context.toLocale!.lbl_select_project,
                  fontSize: 20,
                )
              : NormalTextWidget(
                  context.toLocale!.nothing_mark_offline,
                  fontSize: 20,
                ),
        ],
      ),
    );
  }
}
