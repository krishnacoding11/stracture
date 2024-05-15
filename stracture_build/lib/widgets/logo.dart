import 'package:field/utils/utils.dart';
import 'package:field/widgets/imagewidget.dart';
import 'package:flutter/material.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AImageWidget(
      imagePath: Utility.isTablet ? 'ic_logo_tablet.png' : 'ic_logo.png',
    );
  }
}
