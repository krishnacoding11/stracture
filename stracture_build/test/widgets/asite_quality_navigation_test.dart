import 'package:field/widgets/alisttile_quality_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AListTileQualityNavigation widget test', (WidgetTester tester) async {
    // Define test data
    const String title = 'Test Item';
    const bool isSelected = false;
    const bool hasLocation = true;
    const num percentage = 75;

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AListTileQualityNavigation(
            title: title,
            isSelected: isSelected,
            hasLocation: hasLocation,
            percentage: percentage,
            onTap: () {},
          ),
        ),
      ),
    );

    // Find widgets in the tree
    final titleTextFinder = find.text(title);
    final percentageTextFinder = find.text('$percentage%');
    final hasLocationIconFinder = find.byIcon(Icons.arrow_forward_ios_rounded);
    final isSelectedIconFinder = find.byIcon(Icons.playlist_add_check_outlined);

    // Verify that the widgets are correctly rendered
    expect(titleTextFinder, findsOneWidget);
    expect(percentageTextFinder, findsOneWidget);
    expect(hasLocation ? hasLocationIconFinder : isSelectedIconFinder, findsOneWidget);
  });

  testWidgets('AQualityNavigationItem widget test', (WidgetTester tester) async {
    // Define test data
    const String title = 'Test Item';
    const bool isSelected = true;

    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AQualityNavigationItem(
            title: title,
            isSelected: isSelected,
            onTap: () {},
          ),
        ),
      ),
    );

    // Find widgets in the tree
    final titleTextFinder = find.text(title);

    // Verify that the widgets are correctly rendered
    expect(titleTextFinder, findsOneWidget);
  });
}
