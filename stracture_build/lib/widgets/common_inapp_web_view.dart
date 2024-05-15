import 'package:field/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

Widget commonInAppWebView({String? url, String? fileAddress}) {
  InAppWebViewController? webView;

  return InAppWebView(
      initialUrlRequest: URLRequest(
        url: Uri.parse(url!),
      ),
      initialFile: fileAddress,
      onWebViewCreated: (InAppWebViewController controller) {
        webView = controller;
      },
      shouldOverrideUrlLoading: (controller, shouldOverrideUrlLoadingRequest) async {
        return;
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) async {
        String jsscript = "javascript:HTMLViewer.showHTML(document.getElementsByTagName('html')[0].innerHTML)";
        await controller.evaluateJavascript(source: jsscript);

        var html = await controller.evaluateJavascript(source: "window.document.getElementsByTagName('html')[0].outerHTML;");
        if (url.toString().contains("?SAMLRequest=")) {
          if (html != null && html.toString().isNotEmpty) {}
        }
      },
      gestureRecognizers: Set()
        ..add(Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer()))
        ..add(Factory<HorizontalDragGestureRecognizer>(() => HorizontalDragGestureRecognizer()))
        ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer())),
      onLoadStop: (InAppWebViewController controller, Uri? url) async {},
      initialOptions: InAppWebViewGroupOptions(
        ios: IOSInAppWebViewOptions(),
        android: AndroidInAppWebViewOptions(
          useHybridComposition: true,
          textZoom: Utility.isTablet ? 200 : 80,
          disableDefaultErrorPage: false,
          loadWithOverviewMode: true,
          supportMultipleWindows: false,
          cacheMode: AndroidCacheMode.LOAD_DEFAULT,
          defaultFontSize: 28,
          defaultFixedFontSize: 28,
          sansSerifFontFamily: 'Sofia',
          standardFontFamily: 'Sofia',
          useWideViewPort: true,
          builtInZoomControls: true,
        ),
        crossPlatform: InAppWebViewOptions(javaScriptEnabled: true, mediaPlaybackRequiresUserGesture: false, useShouldOverrideUrlLoading: true, clearCache: true),
      ),
      androidOnPermissionRequest: (InAppWebViewController controller, String origin, List<String> resources) async {
        return PermissionRequestResponse(resources: resources, action: PermissionRequestResponseAction.GRANT);
      });
}
