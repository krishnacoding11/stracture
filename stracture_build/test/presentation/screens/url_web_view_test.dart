import 'package:field/presentation/screen/url_web_view.dart';
import 'package:field/utils/constants.dart';
import 'package:field/widgets/web_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:field/injection_container.dart' as di;
import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../utils/load_url.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  configureDependencies() {
    di.init(test: true);
    AppConfigTestData().setupAppConfigTestData();
    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AConstants.loadProperty();
  }

  Widget getTestWidget(navigatorKey) {
    return  MediaQuery(
      data: const MediaQueryData(),
      child:  MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: UrlWebView(url: AConstants.urlHelp, title: "Help"),
        navigatorKey: navigatorKey,
      ),
    );
  }

  group('UrlWebView test', () {
    configureDependencies();

    testWidgets('UrlWebView title and webViewWidget test', (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      Widget testWidget = getTestWidget(navigatorKey);
      await tester.pumpWidget((testWidget));
      final titleFinder = find.text("Help");
      expect(titleFinder, findsOneWidget);
      final webViewWidget = find.byType(WebViewWidget);
      expect(webViewWidget, findsOneWidget);
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(titleFinder, findsNothing);
    });

    testWidgets('Tests WillPopSCope allows route popping', (WidgetTester tester) async {
      final navigatorKey = GlobalKey<NavigatorState>();
      Widget testWidget = getTestWidget(navigatorKey);
      await tester.pumpWidget(testWidget);
      final titleFinder = find.text("Help");
      expect(titleFinder, findsOneWidget);
      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      expect(titleFinder, findsNothing);
    });
  });
}