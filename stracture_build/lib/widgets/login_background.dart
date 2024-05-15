import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../utils/constants.dart';
import 'normaltext.dart';

class LoginBackgroundWidget extends StatelessWidget {
  final Widget child;

  const LoginBackgroundWidget({required this.child, Key? key})
      : super(key: key);

  Widget _txtTerms(String text, BuildContext context, String url) => GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => PrivacyPolicyWebview(
                      url: url)));
        },
        child: NormalTextWidget(
          text,
          fontSize: 13.0,
          fontWeight: AFontWight.regular,
          color: AColors.textColor.withOpacity(0.5),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final txtCopyRight = NormalTextWidget(
      context.toLocale!.lbl_copyrights,
      fontSize: 13.0,
      fontWeight: AFontWight.regular,
      color: AColors.textColor.withOpacity(0.5),
    );

    final txtTerms = _txtTerms(context.toLocale!.lbl_terms,context,AConstants.urlTermsOfUse);

    final txtPrivacy = _txtTerms(context.toLocale!.lbl_privacy_policy,context,AConstants.urlPrivacyPolicy);

    return Container(
      decoration: BoxDecoration(
        color: AColors.splashBgBlue,
        image: DecorationImage(
            image: AssetImage((Utility.isTablet &&
                    MediaQuery.of(context).orientation == Orientation.landscape)
                ? AImageConstants.loginbgImagepath
                : AImageConstants.loginbgImagepathPhone),
            fit: BoxFit
                .fill), /*gradient: LinearGradient(
        colors: [const Color(0xff91C3E0), const Color(0xffE0F1F8)],
      )*/
      ),
      child: Stack(alignment: Alignment.center, children: [
        child,
        Positioned(
          bottom: 30.0,
          child: Column(
            children: [
              txtCopyRight,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  txtTerms,
                  const NormalTextWidget(
                    " | ",
                    fontSize: 13,
                    fontWeight: AFontWight.regular,
                  ),
                  txtPrivacy,
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class PrivacyPolicyWebview extends StatelessWidget {
  final String url;
  PrivacyPolicyWebview({Key? key, required this.url}) : super(key: key);

  late InAppWebViewController? webView;

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(url),
        ),
        androidOnGeolocationPermissionsShowPrompt:
            (InAppWebViewController controller, String origin) async {
          return GeolocationPermissionShowPromptResponse(
              origin: origin, allow: true, retain: true);
        },
        onWebViewCreated: (InAppWebViewController controller) {
          webView = controller;
        },
        androidOnPermissionRequest: (InAppWebViewController controller,
            String origin, List<String> resources) async {
          return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT);
        });
  }
}
