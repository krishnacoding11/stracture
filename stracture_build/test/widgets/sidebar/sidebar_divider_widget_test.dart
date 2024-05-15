import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ADividerWidget test', (WidgetTester tester) async {
    const double thickness = 2.0;
    const Color dividerColor = Colors.red; // Replace this with the desired color

    // Build the ADividerWidget with the specified thickness and color
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ADividerWidget(
            thickness: thickness,
            color: dividerColor,
          ),
        ),
      ),
    );

    // Verify that the ADividerWidget creates a Divider widget with the specified thickness and color
    final divider = find.byType(Divider).evaluate().single.widget as Divider;
    expect(divider.thickness, thickness);
    expect(divider.color, dividerColor);
  });

  testWidgets('ADividerWidget test with default color', (WidgetTester tester) async {
    const double thickness = 2.0;

    // Build the ADividerWidget with only the thickness provided
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ADividerWidget(
            thickness: thickness,
          ),
        ),
      ),
    );

    // Verify that the ADividerWidget creates a Divider widget with the specified thickness
    // and uses the default color (AColors.dividerColor) since color is not provided.
    final divider = find.byType(Divider).evaluate().single.widget as Divider;
    expect(divider.thickness, thickness);
    expect(divider.color, AColors.dividerColor);
  });
}
