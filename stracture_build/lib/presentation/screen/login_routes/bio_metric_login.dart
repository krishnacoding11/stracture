import 'package:field/presentation/screen/dashboard.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/imagewidget.dart';
import 'package:flutter/material.dart';

import '../../../widgets/elevatedbutton.dart';
import '../../../widgets/headlinetext.dart';
import '../../../widgets/normaltext.dart';
import '../../managers/color_manager.dart';

class BioMetricWidget extends StatefulWidget {
  final Function callback;
  final String? icon, title, desc;

  const BioMetricWidget(this.callback, {Key? key, this.icon, this.title, this.desc})
      : super(key: key);

  @override
  State<BioMetricWidget> createState() => _BioMetricWidgetState();
}

class _BioMetricWidgetState extends State<BioMetricWidget> {
  @override
  Widget build(BuildContext context) {
    final iconTouchId = Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: AImageWidget(imagePath: widget.icon ?? 'ic_fingerprint.png'),
    );

    final lblTitle = HeadlineTextWidget(
      widget.title ?? context.toLocale!.lbl_touch_id,
    );

    final lblDescription = Align(
      alignment: Alignment.center,
      child: NormalTextWidget(
        widget.desc ?? context.toLocale!.lbl_touch_id_desc,
      ),
    );

    final containerEnable = FractionallySizedBox(
      widthFactor: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AElevatedButtonWidget(
          btnLabel: context.toLocale!.text_enable,
          btnBackgroundClr: AColors.themeBlueColor,
          btnLabelClr: Colors.white,
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const DashboardWidget()));
          },
        ),
      ),
    );

    final txtSkip = Center(
      heightFactor: 1,
      child: TextButton(
        onPressed: () {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const DashboardWidget()));
        },
        child: NormalTextWidget(
          context.toLocale!.text_skip,
          color: AColors.themeBlueColor,
        ),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        iconTouchId,
        lblTitle,
        const SizedBox(
          height: 30,
        ),
        lblDescription,
        const SizedBox(
          height: 20,
        ),
        containerEnable,
        txtSkip
      ],
    );
  }
}
