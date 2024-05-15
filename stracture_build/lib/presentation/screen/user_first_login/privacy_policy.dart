import 'package:field/utils/extensions.dart';
import 'package:field/widgets/common_inapp_web_view.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants.dart';
import '../../managers/font_manager.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({Key? key}) : super(key: key);

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (BuildContext context, Orientation orientation) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: const EdgeInsets.only(bottom: 16),
              child: NormalTextWidget(
                context.toLocale!.lbl_terms_and_condition,
                fontSize: 18,
                fontWeight: AFontWight.semiBold,
              ),
            ),
            Expanded(child: commonInAppWebView(url: '', fileAddress: AConstants.termConditionPath)),
          ],
        ),
      );
    });
  }
}
