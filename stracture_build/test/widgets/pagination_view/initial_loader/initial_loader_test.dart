import 'package:field/widgets/pagination_view/initial_loader/initial_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('InitialLoader test', (WidgetTester tester) async {
    const double strokeWidth = 2.0;

    // Build the InitialLoader widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InitialLoader(),
        ),
      ),
    );

    // Verify that CircularProgressIndicator is present
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Verify the strokeWidth of the CircularProgressIndicator
    final progressIndicator = find.byType(CircularProgressIndicator).evaluate().single.widget as CircularProgressIndicator;
    expect(progressIndicator.strokeWidth, strokeWidth);

    // Optional: You can also check if the CircularProgressIndicator is inside a Center widget
    expect(find.byType(Center), findsOneWidget);
  });
}
