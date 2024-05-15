import 'package:field/widgets/clickabletextwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('ClickableTextWidget - Enabled', (WidgetTester tester) async {
    bool onPressedCalled = false;
    final String text = "Click Me";
    final Widget widget = ClickableTextWidget(
      text,
      onPressed: () {
        onPressedCalled = true;
      },
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    final clickableTextFinder = find.byType(ClickableTextWidget);
    expect(clickableTextFinder, findsOneWidget);

    final textFinder = find.text(text);
    expect(textFinder, findsOneWidget);

    // Tap on the clickable text
    await tester.tap(textFinder);
    await tester.pump();

    expect(onPressedCalled, isTrue);
  });

  testWidgets('ClickableTextWidget - Disabled', (WidgetTester tester) async {
    bool onPressedCalled = false;
    final String text = "Click Me";
    final Widget widget = ClickableTextWidget(
      text,
      onPressed: () {
        onPressedCalled = true;
      },
      isEnable: false,
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    final clickableTextFinder = find.byType(ClickableTextWidget);
    expect(clickableTextFinder, findsOneWidget);

    final textFinder = find.text(text);
    expect(textFinder, findsOneWidget);

    // Tap on the clickable text (should have no effect as it is disabled)
    await tester.tap(textFinder);
    await tester.pump();

    expect(onPressedCalled, isFalse);
  });

  testWidgets('ClickableTextWidget - Custom Style', (WidgetTester tester) async {
    final String text = "Custom Style Text";
    final TextStyle customTextStyle = TextStyle(
      color: Colors.red,
      fontSize: 18,
      fontWeight: FontWeight.bold,
    );
    final Widget widget = ClickableTextWidget(
      text,
      onPressed: () {},
      style: customTextStyle,
    );

    await tester.pumpWidget(MaterialApp(home: Scaffold(body: widget)));

    final clickableTextFinder = find.byType(ClickableTextWidget);
    expect(clickableTextFinder, findsOneWidget);

    final textFinder = find.text(text);
    expect(textFinder, findsOneWidget);

    final Text textWidget = tester.widget(textFinder);
    expect(textWidget.style?.color, equals(Color(0xff085b90)));
    expect(textWidget.style?.fontSize, equals(16.0));
    expect(textWidget.style?.fontWeight, equals(FontWeight.w400));
  });
}
