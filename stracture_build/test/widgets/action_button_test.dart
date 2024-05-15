import 'package:field/widgets/action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test ActionButton with button click', (WidgetTester tester) async {
    bool buttonClicked = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ActionButton(
            text: 'Test Button',
            color: Colors.blue,
            buttonClickHandler: () {
              buttonClicked = true;
            },
          ),
        ),
      ),
    );

    // Find the ActionButton widget
    final actionButtonFinder = find.byType(ActionButton);
    expect(actionButtonFinder, findsOneWidget);

    // Perform a tap on the button
    await tester.tap(find.byKey(const Key("KeyActionButton")));
    await tester.pumpAndSettle();

    // Verify that buttonClickHandler was called
    expect(buttonClicked, true);
  });

  testWidgets('Test ActionButton with delete handler', (WidgetTester tester) async {
    bool deleteHandlerCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ActionButton(
            text: 'Delete Button',
            color: Colors.red,
            deleteHandler: () {
              deleteHandlerCalled = true;
            },
          ),
        ),
      ),
    );

    // Find the ActionButton widget
    final actionButtonFinder = find.byType(ActionButton);
    expect(actionButtonFinder, findsOneWidget);

    // Perform a tap on the delete icon button
    await tester.tap(find.byKey(const Key("CrossIconButton")));
    await tester.pumpAndSettle();

    // Verify that deleteHandler was called
    expect(deleteHandlerCalled, true);
  });

  // Add more test cases to cover other scenarios and edge cases
}
