import 'package:field/widgets/circular_progress/circular_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CircularMenuItem without badge', (WidgetTester tester) async {
    bool isTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CircularMenuItem(
            onTap: () {
              isTapped = true;
            },
            icon: Icons.add,
          ),
        ),
      ),
    );

    expect(isTapped, isFalse);
    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();
    expect(isTapped, isTrue);

    expect(find.byType(Badge), findsNothing);
  });

  testWidgets('CircularMenuItem with badge', (WidgetTester tester) async {
    bool isTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CircularMenuItem(
            onTap: () {
              isTapped = true;
            },
            icon: Icons.add,
            enableBadge: true,
            badgeLabel: 'New',
          ),
        ),
      ),
    );

    expect(isTapped, isFalse);
    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();
    expect(isTapped, isTrue);

    expect(find.byType(CBadge), findsOneWidget);
    expect(find.text('New'), findsOneWidget);
  });
}
