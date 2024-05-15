import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';

import '../../../widgets/web_view_widget.dart';
import '../managers/color_manager.dart';
import '../managers/font_manager.dart';


class UrlWebView extends StatefulWidget {
  final String url;
  final String title;

  const UrlWebView({
    Key? key,
    required this.url,
    this.title = "",
  }) : super(key: key);

  @override
  State<UrlWebView> createState() => _UrlWebViewState();
}

class _UrlWebViewState extends State<UrlWebView> {

  final GlobalKey webViewKey = GlobalKey();
  bool isBackPress = false;
  bool isTapped = false;


  @override
  Widget build(BuildContext context) {
    return Center(
      child: WillPopScope(
        onWillPop: () async {
          goBack();
          return true;
        },
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                _buildTitle(widget.title,context),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              titleTextStyle: const TextStyle(
                  color: AColors.black,
                  fontFamily: "Sofia",
                  fontWeight: AFontWight.medium,
                  fontSize: 20),
              // toolbarHeight: 25,
              backgroundColor: AColors.white,
              elevation: 1,
              //automaticallyImplyLeading: true,
              leading: InkWell(
                onTap: () {
                  if (!isTapped) {
                    isTapped = true;
                    goBack(canBack: true);
                  }
                },
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black54,
                ),
              ),
            ),
            body: SafeArea(
                child: (!isBackPress)
                    ? Stack(
                  children: [
                    WebViewWidget(
                      key: webViewKey,
                      url: widget.url,
                    ),
                  ],
                )
                    : Container())),
      ),
    );
  }

  void goBack({bool canBack = false}) {
    setState(() {
      isBackPress = true;
    });
    if (canBack) {
      Future.delayed(
          const Duration(milliseconds: 500), () => Navigator.pop(context));
    }
  }
  String _buildTitle(String title, BuildContext context){
    switch (title) {
      case "Help":
        return context.toLocale!.help;
      case "About":
        return context.toLocale!.lbl_about;
      default:
        return title;

    }
  }

}
