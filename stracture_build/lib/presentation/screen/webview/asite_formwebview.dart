import 'package:field/presentation/managers/color_manager.dart';
import 'package:flutter/cupertino.dart';

import 'asite_webview.dart';

class AsiteFormWebView extends StatefulWidget {
  final String url;
  final Map<String, dynamic> data;
  final Color? headerIconColor;

  const AsiteFormWebView({Key? key, required this.url, this.headerIconColor, this.data = const {}}) : super(key: key);

  @override
  State<AsiteFormWebView> createState() => _AsiteFormWebViewState();
}

class _AsiteFormWebViewState extends State<AsiteFormWebView> {
  final GlobalKey webViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: widget.headerIconColor ?? AColors.iconGreyColor, width: 5),
        ),
      ),
      child: AsiteWebView(
        key: webViewKey,
        url: Uri.decodeFull(widget.url),
        title: "",
        data: widget.data,
        isAppbarRequired: false,
      ),
    );
  }
}
