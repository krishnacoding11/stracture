import 'package:field/widgets/headlinetext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('HeadlineTextWidget - Test Widget Rendering', (WidgetTester tester) async {
    // Define test data
    final String headlineText = 'Test Headline';

    // Build the widget tree
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: HeadlineTextWidget(headlineText),
      ),
    ));

    // Find the HeadlineTextWidget
    final headlineTextFinder = find.byType(HeadlineTextWidget);
    expect(headlineTextFinder, findsOneWidget);

    // Verify that the Text widget is rendered with the correct text and style
    final textFinder = find.text(headlineText);
    expect(textFinder, findsOneWidget);

    final Text textWidget = tester.widget(textFinder);
    expect(textWidget.textAlign, equals(TextAlign.center));
    expect(textWidget.textScaleFactor, equals(1.8));

    // Verify the default style of the HeadlineTextWidget
    expect(textWidget.style?.color, equals(Color(0xff263238))); // Replace with the actual default color from your project
    expect(textWidget.style?.fontFamily, equals('Sofia')); // Replace with the actual default font family from your project
    expect(textWidget.style?.fontWeight, equals(FontWeight.w600)); // Replace with the actual default font weight from your project
    expect(textWidget.style?.decoration, equals(TextDecoration.none));
  });

  testWidgets('HeadlineTextWidget - Test Custom Style', (WidgetTester tester) async {
    final String headlineText = 'Test Headline';
    final TextStyle customStyle = TextStyle(
      color: Colors.red,
      fontFamily: 'CustomFont',
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    );

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: HeadlineTextWidget(headlineText, style: customStyle),
      ),
    ));

    final headlineTextFinder = find.byType(HeadlineTextWidget);
    expect(headlineTextFinder, findsOneWidget);

    final textFinder = find.text(headlineText);
    expect(textFinder, findsOneWidget);

    final Text textWidget = tester.widget(textFinder);
    expect(textWidget.style, equals(customStyle));
  });
}
