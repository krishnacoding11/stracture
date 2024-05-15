import 'package:field/widgets/tooltip_dialog/tooltip_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

void main() {
  testWidgets('Test TooltipDialog', (WidgetTester tester) async {
    final tooltipController = TooltipController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: TooltipDialog(
              child: const Text('Button'),
              toolTipContent: const Text('Tooltip Content'),
              toolTipController: tooltipController,
            ),
          ),
        ),
      ),
    );

    final tooltipDialogFinder = find.byType(TooltipDialog);

    expect(tooltipDialogFinder, findsOneWidget);

    final tooltipDialog = tester.widget<TooltipDialog>(tooltipDialogFinder);

    // Verify that the TooltipDialog properties are set correctly
    expect((tooltipDialog.child as Text).data, 'Button');
    expect((tooltipDialog.toolTipContent as Text).data, 'Tooltip Content');

    // Simulate showing and hiding the tooltip
    tooltipController.showTooltipDialog();
    await tester.pumpAndSettle();

    expect(tooltipController.getTooltipStatus(), TooltipStatus.isShowing);

    tooltipController.hideTooltipDialog();
    await tester.pumpAndSettle();

    expect(tooltipController.getTooltipStatus(), TooltipStatus.isHidden);
  });
}
