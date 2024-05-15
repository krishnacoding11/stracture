import 'package:field/utils/utils.dart';
import 'package:field/widgets/backtologin_textbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  group("Backtologin test widget", () {
    // Widget testWidget() {
    //   Utility.isTablet = false;
    //  return MaterialApp(
    //          home: Scaffold(
    //            body:ATextbuttonWidget(
    //              label: 'Test Button',
    //              buttonIcon: Icons.arrow_back,
    //              onPressed: () {},
    //            ),
    //          ),
    //      );
    // }

    testWidgets('Test ATextbuttonWidget with label - isTablet', (WidgetTester tester) async {

      Utility.isTablet = true;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ATextbuttonWidget(
              label: 'Test Button',
              buttonIcon: null,
              onPressed: () {},
            ),
          ),
        ),
      );


      final centerFinder = find.byType(Center);
      expect(centerFinder, findsOneWidget);

      final textButtonFinder = find.byType(TextButton);
      expect(textButtonFinder, findsOneWidget);

    });

    testWidgets('Test ATextbuttonWidget with label and null buttonIcon - !isTablet', (WidgetTester tester) async {
      // Mock the Utility.isTablet value
      Utility.isTablet = false;


      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ATextbuttonWidget(
              label: 'Test Button',
              buttonIcon: Icons.arrow_back,
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the Align widget
      // final alignFinder = find.byType(Align);
      // expect(alignFinder, findsOneWidget);

      // Find the TextButton
      // final textButtonFinder = find.byType(TextButton);
      // expect(textButtonFinder, findsOneWidget);

    });
  });

}
