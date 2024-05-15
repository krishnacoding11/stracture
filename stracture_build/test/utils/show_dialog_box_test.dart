import 'package:field/presentation/managers/routes_manager.dart';
import 'package:field/utils/custom_session_timeout_dialog.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/show_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:field/injection_container.dart' as di;

import '../bloc/mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  late GlobalKey key = GlobalKey();
  Widget getTestWidget() => MediaQuery(
    data: MediaQueryData(),
    child: MaterialApp(
      navigatorKey: NavigationUtils.mainNavigationKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        key: key,
      ),
      onGenerateRoute: RouteGenerator.generateRoute,
    ),
  );

  testWidgets('Set Offline Dialog Box', (WidgetTester tester) async {
    await tester.pumpWidget(getTestWidget());
    ShowAlertDialogBox.setOfflineDialogBox(context: key.currentContext!, title: 'Show Dialog Box', onSetOffline: () {}, onProperties: () {});
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Show Dialog Box'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    expect(find.text('Set Offline'), findsOneWidget);
    expect(find.byIcon(Icons.note_alt_outlined), findsOneWidget);
    expect(find.text('Properties'), findsOneWidget);
  });

  testWidgets('Issue dialog box while loading models', (WidgetTester tester) async {
    await tester.pumpWidget(getTestWidget());
    ShowAlertDialogBox.issueWhileLoadingModels(context: key.currentContext!, totalNumbersOfModel: '5', totalNumbersOfModelLoadFailed: '2');
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
    final findOkButton = find.text('Ok');
    expect(findOkButton, findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.text('Missing Model!'), findsOneWidget);
    expect(find.text('Load 3 models out of 5'), findsOneWidget);
    await tester.tap(findOkButton);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Dialog box for model loading failed', (WidgetTester tester) async {
    await tester.pumpWidget(getTestWidget());
    ShowAlertDialogBox.modelLoadingFailed(context: key.currentContext!);
    await tester.pump();
    expect(find.byType(CustomSessionTimeOutDialogBox), findsOneWidget);
  });

  testWidgets('Dialog box for insufficient storage', (WidgetTester tester) async {
    await tester.pumpWidget(getTestWidget());
    ShowAlertDialogBox.inSufficientStorage(context: key.currentContext!);
    await tester.pump();
    expect(find.byType(InsufficientStorageDialogBox), findsOneWidget);
  });

}