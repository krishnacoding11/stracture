import 'package:field/utils/utils.dart';
import 'package:field/widgets/common_inapp_web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group("Test webview widget", () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final mockController = MockInAppWebViewController();
    Widget inAppWebView = commonInAppWebView(
      url: "https://www.google.com",
      fileAddress: "",
    );
    testWidgets("Test webview widget", (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: inAppWebView),
      ));
      Finder formWidgetFinder = find.byType(InAppWebView);
      expect(formWidgetFinder, findsOneWidget);
      final webView = tester.widget(formWidgetFinder) as InAppWebView;

      final initialUrl = webView.initialUrlRequest?.url;
      expect(initialUrl, equals(Uri.parse('https://www.google.com')));

      final initialFile = webView.initialFile;
      expect(initialFile, equals(""));

      await tester.pumpAndSettle();
      webView.onWebViewCreated!(mockController);
      expect(webView, isNotNull);

      await tester.pumpAndSettle();
      NavigationAction navigationAction = NavigationAction(
        request: URLRequest(url: Uri.parse("")),
        isForMainFrame: true,
      );
      final shouldOverride = await webView.shouldOverrideUrlLoading!(
          mockController, navigationAction);
      expect(shouldOverride, isNull);

      expect(
          webView.initialOptions?.android.useHybridComposition, equals(true));
      expect(webView.initialOptions?.android.textZoom,
          equals(Utility.isTablet ? 200 : 80));
      expect(webView.initialOptions?.android.disableDefaultErrorPage,
          equals(false));
      expect(
          webView.initialOptions?.android.loadWithOverviewMode, equals(true));
      expect(webView.initialOptions?.android.supportMultipleWindows,
          equals(false));
      expect(webView.initialOptions?.android.cacheMode,
          equals(AndroidCacheMode.LOAD_DEFAULT));
      expect(webView.initialOptions?.android.defaultFontSize, equals(28));
      expect(webView.initialOptions?.android.defaultFixedFontSize, equals(28));
      expect(
          webView.initialOptions?.android.sansSerifFontFamily, equals('Sofia'));
      expect(
          webView.initialOptions?.android.standardFontFamily, equals('Sofia'));
      expect(webView.initialOptions?.android.useWideViewPort, equals(true));
      expect(webView.initialOptions?.android.builtInZoomControls, equals(true));
      expect(webView.initialOptions?.crossPlatform.javaScriptEnabled,
          equals(true));
      expect(
          webView
              .initialOptions?.crossPlatform.mediaPlaybackRequiresUserGesture,
          equals(false));
      expect(webView.initialOptions?.crossPlatform.useShouldOverrideUrlLoading,
          equals(true));
      expect(webView.initialOptions?.crossPlatform.clearCache, equals(true));

      await tester.pumpAndSettle();
      webView.onLoadStop!(mockController, Uri.parse(""));
      expect(webView, isNotNull);

      await tester.pumpAndSettle();
      final response =
      await webView.androidOnPermissionRequest!(mockController, "", []);
      expect(response, isNotNull);

      await tester.pumpAndSettle();
      final gestureRecognizers = webView.gestureRecognizers;
      expect(gestureRecognizers, isNotNull);

    });
  });
}

class MockInAppWebViewController extends Mock
    implements InAppWebViewController {}