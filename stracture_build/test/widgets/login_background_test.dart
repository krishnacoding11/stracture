// import 'package:field/presentation/managers/color_manager.dart';
// import 'package:field/widgets/a_chip_widget.dart';
// import 'package:field/widgets/login_background.dart';
// import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
// import 'package:field/widgets/textformfieldwithchipsinputwidget.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// void main() {
//   testWidgets('LoginBackgroundWidget', (WidgetTester tester) async {
//     const Widget child = SizedBox(); // Replace this with the desired color
//
//     // Build the LoginBackgroundWidget with the specified thickness and color
//     await tester.pumpWidget(
//       MaterialApp(
//         home: Scaffold(
//           body: LoginBackgroundWidget(child: child,
//           ),
//         ),
//       ),
//     );
//
//     final divider = find.byType(LoginBackgroundWidget).evaluate().single.widget as LoginBackgroundWidget;
//     expect(divider.child, child);
//     expect(find.byType(LoginBackgroundWidget), findsOneWidget);
//   });
//
// }
import 'package:field/widgets/login_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockInAppWebViewController extends Mock implements InAppWebViewController {}

void main() {
  group('PrivacyPolicyWebview', () {
    late PrivacyPolicyWebview privacyPolicyWebview;
    late MockInAppWebViewController mockWebViewController;
    late String url;

    setUp(() {
      mockWebViewController = MockInAppWebViewController();
      privacyPolicyWebview = PrivacyPolicyWebview(url: 'https://example.com');
      url =  'https://example.com';
      privacyPolicyWebview.webView = mockWebViewController;
    });

    testWidgets('renders InAppWebView with specified URL', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: PrivacyPolicyWebview(url: url,))));

      final inAppWebView = find.byType(InAppWebView);
      final inAppWebViewWidget = tester.widget<InAppWebView>(inAppWebView);

      // expect(inAppWebView, findsOneWidget);
      final divider = find.byType(PrivacyPolicyWebview).evaluate().single.widget as PrivacyPolicyWebview;
      expect(divider.url, url);
      // expect(inAppWebViewWidget.initialUrlRequest.url, equals(Uri.parse('https://example.com')));
    });

    // testWidgets('handles Android geolocation permissions show prompt', (WidgetTester tester) async {
    //   await tester.pumpWidget(MaterialApp(home: Scaffold(body: privacyPolicyWebview)));
    //
    //   final showPromptResponse = await privacyPolicyWebview;
    //
    //   expect(showPromptResponse, equals('origin'));
    //   // expect(showPromptResponse.allow, isTrue);
    //   // expect(showPromptResponse.retain, isTrue);
    // });
    //
    // testWidgets('handles Android permission request', (WidgetTester tester) async {
    //   await tester.pumpWidget(MaterialApp(home: Scaffold(body: privacyPolicyWebview)));
    //
    //   final resources = ['resource1', 'resource2'];
    //   final permissionRequestResponse = await privacyPolicyWebview;
    //
    //   expect(permissionRequestResponse, equals(resources));
    //   expect(permissionRequestResponse, equals(PermissionRequestResponseAction.GRANT));
    // });
  });
}