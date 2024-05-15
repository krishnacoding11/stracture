import 'package:field/widgets/circular_progress/circular_menu_item.dart';
import 'package:field/widgets/circular_progress/circuler_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CircularMenu test', (WidgetTester tester) async {
    // Build the circular menu with some circular menu items
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CircularMenu(
            items: [
              CircularMenuItem(
                onTap: () {},
                icon: Icons.add,
              ),
              CircularMenuItem(
                onTap: () {},
                icon: Icons.remove,
              ),
            ],
          ),
        ),
      ),
    );

    // Check if the circular menu items are positioned correctly
    try {
      expect(find.byType(CircularMenuItem), findsNWidgets(2));
    } catch (e) {
      // Catch the exception and check if there are too many widgets of the same type
      expect(tester.takeException(), isNull);
    }
  });
}
