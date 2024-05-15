import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test ACircularProgress', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ACircularProgress(
          strokeWidth: 3,
          color: Colors.blue,
          progressValue: 0.5,
          backgroundColor: Colors.grey,
        ),
      ),
    ));

    final circularProgressFinder = find.byType(CircularProgressIndicator);

    expect(circularProgressFinder, findsOneWidget);

    final circularProgressWidget = tester.widget<CircularProgressIndicator>(circularProgressFinder);

    expect(circularProgressWidget.strokeWidth, 3);
    expect(circularProgressWidget.value, 0.5);
    expect(circularProgressWidget.color, Colors.blue);
    expect(circularProgressWidget.backgroundColor, Colors.grey);
  });
}
