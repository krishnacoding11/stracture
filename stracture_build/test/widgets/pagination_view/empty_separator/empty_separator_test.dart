import 'package:field/widgets/pagination_view/empty_separator/empty_separator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('EmptySeparator test', (WidgetTester tester) async {
    // Build the EmptySeparator widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptySeparator(),
        ),
      ),
    );

    // Verify that SizedBox is present
    expect(find.byType(SizedBox), findsOneWidget);

    // Verify the height and width of the SizedBox
    final sizedBox = find.byType(SizedBox).evaluate().single.widget as SizedBox;
    expect(sizedBox.height, 0.0);
    expect(sizedBox.width, 0.0);
  });
}
