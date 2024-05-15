import 'package:field/utils/extensions.dart';
import 'package:field/widgets/normaltext.dart';

import 'package:flutter/material.dart';

class HomePageEmptyView extends StatelessWidget {
  const HomePageEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        NormalTextWidget(context.toLocale!.no_shortcut_config),
      ],
    );
  }
}
