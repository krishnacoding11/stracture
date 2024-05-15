import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/widgets/atheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/widgets/asquare_button.dart'; // Import the actual AsquareButton if needed

void main() {
  testWidgets('Test ATheme', (WidgetTester tester) async {
    const labelText = 'Test Button';
    final testColor = AColors.themeBlueColor;
    const buttonOneKey = Key("buttonOne");

    await tester.pumpWidget(MaterialApp(
      theme: ATheme.lightTheme,
      home: Scaffold(
        body: Center(
          child:TextButton(
            key: buttonOneKey,
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(testColor)
            ),
            child: const Text(labelText),
            onPressed: () {

            },
          ),
        ),
      ),
    ));

    final buttonFinder = find.byKey(buttonOneKey);

    expect(buttonFinder, findsOneWidget);

    final button = tester.widget<TextButton>(buttonFinder);
    expect(ATheme.lightTheme.primaryColor, Color(0xff085b90));

  });
}
