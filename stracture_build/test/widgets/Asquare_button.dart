import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/widgets/imagewidget.dart'; // Import the actual ImageWidget if needed
import 'package:field/widgets/logo.dart'; // Import the actual LogoWidget if needed
import 'package:field/widgets/asquare_button.dart'; // Import the actual AsquareButton if needed
import 'package:field/utils/utils.dart';

void main() {
  testWidgets('Test AsquareButton', (WidgetTester tester) async {
    bool onPressedCalled = false;
    const labelText = 'Test Button';
    const testColor = Colors.blue;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: AsquareButton(
            label: labelText,
            onPressed: () {
              onPressedCalled = true;
            },
            color: testColor,
          ),
        ),
      ),
    ));

    final buttonFinder = find.byType(AsquareButton);

    expect(buttonFinder, findsOneWidget);

    final button = tester.widget<AsquareButton>(buttonFinder);

    expect(button.label, labelText);
    expect(button.color, testColor);

    // Simulate button press
    await tester.tap(buttonFinder);
    await tester.pump();

    expect(onPressedCalled, isTrue);
  });
}
