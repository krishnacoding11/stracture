import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('NormalTextWidget - Test Widget Rendering', (WidgetTester tester) async {
    final String text = 'Test Text';

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NormalTextWidget(text),
      ),
    ));

    final textWidgetFinder = find.byType(NormalTextWidget);
    expect(textWidgetFinder, findsOneWidget);

    final textFinder = find.text(text);
    expect(textFinder, findsOneWidget);
  });

  testWidgets('NormalTextWidget - Test With Custom Font Size and Color', (WidgetTester tester) async {
    final String text = 'Test Text';
    final double customFontSize = 20.0;
    final Color customColor = Colors.blue;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NormalTextWidget(
          text,
          fontSize: customFontSize,
          color: customColor,
        ),
      ),
    ));

    final textWidgetFinder = find.byType(Text);
    expect(textWidgetFinder, findsOneWidget);

    final textFinder = find.text(text);
    expect(textFinder, findsOneWidget);

    final textWidget = tester.widget<Text>(textFinder);
    expect(textWidget.style?.fontSize, customFontSize);
    expect(textWidget.style?.color, customColor);
  });

  testWidgets('NormalTextWidget - Test With Custom Font Weight', (WidgetTester tester) async {
    final String text = 'Test Text';
    final FontWeight customFontWeight = FontWeight.w700;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NormalTextWidget(
          text,
          fontWeight: customFontWeight,
        ),
      ),
    ));

    final textWidgetFinder = find.byType(Text);
    expect(textWidgetFinder, findsOneWidget);

    final textFinder = find.text(text);
    expect(textFinder, findsOneWidget);

    final textWidget = tester.widget<Text>(textFinder);
    expect(textWidget.style?.fontWeight, customFontWeight);
  });

  testWidgets('NormalTextWidget - Test Custom Style', (WidgetTester tester) async {
    final String text = 'Test Text';
    final TextStyle customStyle = TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.bold,
      fontSize: 20.0,
      letterSpacing: 1.2,
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NormalTextWidget(
          text,
          style: customStyle,
        ),
      ),
    ));

    final textWidgetFinder = find.byType(Text);
    expect(textWidgetFinder, findsOneWidget);

    final textFinder = find.text(text);
    expect(textFinder, findsOneWidget);

    final textWidget = tester.widget<Text>(textFinder);
    expect(textWidget.style?.color, Color(0xff263238));
    expect(textWidget.style?.fontWeight, customStyle.fontWeight);
    expect(textWidget.style?.fontSize, 16.0);
    expect(textWidget.style?.letterSpacing, customStyle.letterSpacing);
  });
}
