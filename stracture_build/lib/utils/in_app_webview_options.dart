import 'package:flutter_inappwebview/flutter_inappwebview.dart';

InAppWebViewGroupOptions inAppWebViewGroupOptions(Uri? path) {
  return InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(allowFileAccessFromFileURLs: true, allowUniversalAccessFromFileURLs: true, useShouldOverrideUrlLoading: true, useOnLoadResource: true, javaScriptEnabled: true, cacheEnabled: true, clearCache: false, incognito: false),
    ios: IOSInAppWebViewOptions(
      sharedCookiesEnabled: true,
      allowingReadAccessTo: path,
      disallowOverScroll: true,
      alwaysBounceVertical: false,
    ),
    android: AndroidInAppWebViewOptions(thirdPartyCookiesEnabled: true, useShouldInterceptRequest: true, useHybridComposition: true, allowContentAccess: true, mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW),
  );
}
