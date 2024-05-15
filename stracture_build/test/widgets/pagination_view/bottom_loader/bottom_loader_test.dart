import 'package:field/widgets/pagination_view/bottom_loader/bottom_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BottomLoader test', (WidgetTester tester) async {
    // Build the BottomLoader widget
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BottomLoader(),
        ),
      ),
    );

    // Verify that CircularProgressIndicator is present
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(SizedBox), findsOneWidget);
    expect(find.byType(Padding), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);

    // Verify the height and width of the CircularProgressIndicator
    final circularProgressIndicator = find.byType(CircularProgressIndicator).evaluate().single.widget as CircularProgressIndicator;
    expect(circularProgressIndicator.strokeWidth, 2.0);
    expect(find.byKey(Key('bottom_loader_key')), findsNothing);
  });
}
