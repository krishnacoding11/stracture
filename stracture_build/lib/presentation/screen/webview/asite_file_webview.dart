import 'package:flutter/cupertino.dart';

import 'asite_webview.dart';

class AsiteFileWebView extends StatefulWidget {
  final String url;
  final Map<String, dynamic> data;

  const AsiteFileWebView({Key? key, required this.url, this.data = const {}}) : super(key: key);

  @override
  State<AsiteFileWebView> createState() => _AsiteFileWebViewState();
}

class _AsiteFileWebViewState extends State<AsiteFileWebView> {
  final GlobalKey webViewKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return AsiteWebView(
      key: webViewKey,
      url: Uri.decodeFull(widget.url),
      title: "",
      data: widget.data,
      isAppbarRequired: false,
    );
  }
}
