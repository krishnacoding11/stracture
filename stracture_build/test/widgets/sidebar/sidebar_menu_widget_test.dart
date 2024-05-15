import 'package:field/widgets/sidebar/sidebar_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ASidebarMenuWidget test', (WidgetTester tester) async {
    // Define test data
    const String menuText = 'Menu Item';
    const IconData menuIcon = Icons.menu;
    const bool isSelected = true;
    final Color selectedColor = Colors.blue;
    final Color iconColor = Colors.green;

    // Build the ASidebarMenuWidget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ASidebarMenuWidget(
            text: menuText,
            icon: menuIcon,
            isSelected: isSelected,
            selectedColor: selectedColor,
            iconColor: iconColor,
            onTap: () {
              // Test onTap functionality here if needed
            },
          ),
        ),
      ),
    );

    // Verify that the ASidebarMenuWidget correctly displays the provided text, icon,
    // and selected state based on the provided properties.
    // Use find.text to locate the displayed menu text.
    expect(find.text(menuText), findsOneWidget);

    // Use find.byWidgetPredicate to locate the Icon widget displaying the provided icon.
    final menuIconWidget = find.byWidgetPredicate(
          (widget) =>
      widget is Icon &&
          widget.icon == menuIcon &&
          widget.color == iconColor,
    );
    expect(menuIconWidget, findsOneWidget);

    // Use find.byWidgetPredicate to locate the ListTile widget with the specified properties.
    final menuTile = find.byWidgetPredicate(
          (widget) =>
      widget is ListTile &&
          widget.selected &&
          widget.selectedTileColor == selectedColor,
    );
    expect(menuTile, findsOneWidget);
  });
}
