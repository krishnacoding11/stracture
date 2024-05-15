import 'package:field/widgets/behaviors/custom_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeScrollableDetails extends ScrollableDetails {
  FakeScrollableDetails({required super.direction, required super.controller});

  @override
  double get overscroll => 0.0;
}

void main() {
  testWidgets('CustomScrollBehavior buildOverscrollIndicator returns child widget', (WidgetTester tester) async {
    // Ensure the test environment is initialized
    TestWidgetsFlutterBinding.ensureInitialized();

    // Create a CustomScrollBehavior instance
    final scrollBehavior = CustomScrollBehavior();

    // Create a child widget to be passed to buildOverscrollIndicator
    final child = Container(
      color: Colors.blue,
      height: 200,
      width: 200,
    );

    // Build the overscroll indicator using CustomScrollBehavior
    final result = scrollBehavior.buildOverscrollIndicator(
      createTestContext(tester),
      child,
      FakeScrollableDetails(direction: AxisDirection.up, controller: ScrollController()), // Provide a dummy ScrollableDetails object
    );

    // Verify that the returned widget is the same as the input child widget
    expect(result, equals(child));
  });
}

BuildContext createTestContext(WidgetTester tester) {
  final element = tester.element(find.byType(Container));
  return element;
}
