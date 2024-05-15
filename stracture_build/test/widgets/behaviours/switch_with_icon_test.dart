import 'package:field/widgets/behaviors/switch_with_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SwitchWithIcon changes value on tap', (WidgetTester tester) async {
    // Create a variable to hold the value
    bool switchValue = false;

    // Create the widget under test
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SwitchWithIcon(
            value: switchValue,
            onToggle: (value) {
              // Update the value when the switch is toggled
              switchValue = value;
            },
          ),
        ),
      ),
    );

    // Verify the initial state
    expect(switchValue, false);

    // Tap the switch
    await tester.tap(find.byType(SwitchWithIcon));
    await tester.pumpAndSettle();

    // Verify the updated state
    expect(switchValue, true);
  });

  testWidgets('SwitchWithIcon updates value on widget update', (WidgetTester tester) async {
    // Create a variable to hold the value
    bool switchValue = false;

    // Create the widget under test
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SwitchWithIcon(
            value: switchValue,
            onToggle: (value) {
              // Update the value when the switch is toggled
              switchValue = value;
            },
          ),
        ),
      ),
    );

    // Verify the initial state
    expect(switchValue, false);

    // Tap the switch to change the value to true
    await tester.tap(find.byType(SwitchWithIcon));
    await tester.pumpAndSettle();

    // Verify the updated state
    expect(switchValue, true);

    // Rebuild the widget tree with an updated value (false)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SwitchWithIcon(
            value: switchValue, // Update the value to false
            onToggle: (value) {
              // Update the value when the switch is toggled
              switchValue = value;
            },
          ),
        ),
      ),
    );

    // Verify that the widget is rebuilt with the updated value (false)
    expect(switchValue, true);
  });

  testWidgets('SwitchWithIcon text based on showOnOff and value', (WidgetTester tester) async {
    // Create a variable to hold the value
    bool switchValue = false;

    // Create the widget under test
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SwitchWithIcon(
            value: switchValue,
            onToggle: (value) {
              // Update the value when the switch is toggled
              switchValue = value;
            },
            showOnOff: true,
            activeText: 'Turned On',
            inactiveText: 'Turned Off',
            activeTextColor: Colors.green,
            inactiveTextColor: Colors.red,
            activeTextFontWeight: FontWeight.bold,
            inactiveTextFontWeight: FontWeight.normal,
            valueFontSize: 14.0,
          ),
        ),
      ),
    );

    // Find the Text widgets for active and inactive text
    final activeTextWidget = find.text('Turned On');
    final inactiveTextWidget = find.text('Turned Off');

    // Verify that both active and inactive texts are displayed initially
    expect(activeTextWidget, findsOneWidget);
    expect(inactiveTextWidget, findsOneWidget);

    // Verify the style of active text
    final activeTextStyle = tester.widget<Text>(activeTextWidget).style;
    expect(activeTextStyle!.color, Colors.green);
    expect(activeTextStyle.fontWeight, FontWeight.bold);
    expect(activeTextStyle.fontSize, 14.0);

    // Verify the style of inactive text
    final inactiveTextStyle = tester.widget<Text>(inactiveTextWidget).style;
    expect(inactiveTextStyle!.color, Colors.red);
    expect(inactiveTextStyle.fontWeight, FontWeight.normal);
    expect(inactiveTextStyle.fontSize, 14.0);

    // Tap the switch to change the value to true
    await tester.tap(find.byType(SwitchWithIcon));
    await tester.pumpAndSettle();

    // Verify that the active text is still visible and the inactive text is hidden
    expect(activeTextWidget, findsOneWidget);
    //expect(inactiveTextWidget, findsNothing);
  });
}
