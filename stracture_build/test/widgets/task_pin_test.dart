import 'package:field/widgets/task_pin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Test Task Pin widget", () {
    Widget testWidget() {
      return MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: TaskPin(isShowAnimation: true),
        ),
      );
    }
    testWidgets('Success', (WidgetTester tester) async {
      Widget testDrawerWidget = testWidget();

      await tester.pumpWidget(testDrawerWidget);
      Finder widget = find.byType(TaskPin);
      expect(widget, findsOneWidget);
    });
  });
}