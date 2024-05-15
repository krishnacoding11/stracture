import 'package:field/widgets/border_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('ABorderCardWidget - Default Card Color', (WidgetTester tester) async {
    final border = BorderDirectional(start: BorderSide(color: Colors.red, width: 2.0));
    final child = Container(); // Replace this with your actual child widget

    await tester.pumpWidget(
      MaterialApp(
        home: ABorderCardWidget(
          border: border,
          child: child,
        ),
      ),
    );

    final cardFinder = find.byType(Card);
    final containerFinder = find.descendant(
      of: cardFinder,
      matching: find.byType(Container),
    );

    expect(cardFinder, findsOneWidget);
    expect(containerFinder, findsWidgets);

    final Card card = tester.firstWidget(cardFinder);
    final Container container = tester.firstWidget(containerFinder);

    expect(card.color, equals(Colors.white));
    expect(card.elevation, 2.0);
    expect(container.decoration, null);
  });

  testWidgets('ABorderCardWidget - Custom Card Color', (WidgetTester tester) async {
    final border = BorderDirectional(start: BorderSide(color: Colors.green, width: 1.0));
    final child = Container(); // Replace this with your actual child widget
    final cardColor = Colors.blue;

    await tester.pumpWidget(
      MaterialApp(
        home: ABorderCardWidget(
          border: border,
          child: child,
          cardColor: cardColor,
        ),
      ),
    );

    final cardFinder = find.byType(Card);
    final containerFinder = find.descendant(
      of: cardFinder,
      matching: find.byType(Container),
    );

    expect(cardFinder, findsOneWidget);
    expect(containerFinder, findsWidgets);

    final Card card = tester.firstWidget(cardFinder);
    final Container container = tester.firstWidget(containerFinder);

    expect(card.color, equals(cardColor));
    expect(card.elevation, 2.0);
    expect(container.decoration, null);
  });
}
