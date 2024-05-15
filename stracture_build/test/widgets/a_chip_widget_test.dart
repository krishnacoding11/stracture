import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/widgets/a_chip_widget.dart';
import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
import 'package:field/widgets/textformfieldwithchipsinputwidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('chip test', (WidgetTester tester) async {
    const String lblText = "test";
    const Color dividerColor = Colors.red; // Replace this with the desired color

    // Build the ADividerWidget with the specified thickness and color
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AChipWidget(lblText: lblText, selectedChipList: [],
          ),
        ),
      ),
    );

    // Verify that the ADividerWidget creates a Divider widget with the specified thickness and color
    final divider = find.byType(AChipWidget).evaluate().single.widget as AChipWidget;
    expect(divider.lblText, lblText);
    // expect(divider.color, dividerColor);
  });

  testWidgets('chip test', (WidgetTester tester) async {
    const String lblText = "test";
    const Color dividerColor = Colors.red; // Replace this with the desired color
      List<ChipData> data = [ChipData("test",{})]; // Replace this with the desired color

    // Build the ADividerWidget with the specified thickness and color
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AChipWidget(lblText: lblText, selectedChipList:data ,
          ),
        ),
      ),
    );

    // Verify that the ADividerWidget creates a Divider widget with the specified thickness and color
    final divider = find.byType(AChipWidget).evaluate().single.widget as AChipWidget;
    expect(divider.lblText, lblText);
    expect(divider.selectedChipList, data);
    // expect(divider.color, dividerColor);
  });
  testWidgets('chip test', (WidgetTester tester) async {
    const String lblText = "test";
     Function onClick = (data){};

    // Build the ADividerWidget with the specified thickness and color
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AChipWidget(lblText: lblText, selectedChipList:[],onChipDeleted: onClick,
          ),
        ),
      ),
    );

    // Verify that the ADividerWidget creates a Divider widget with the specified thickness and color
    final divider = find.byType(AChipWidget).evaluate().single.widget as AChipWidget;
    expect(divider.lblText, lblText);
    expect(divider.onChipDeleted, onClick);
    // expect(divider.color, dividerColor);
  });
}