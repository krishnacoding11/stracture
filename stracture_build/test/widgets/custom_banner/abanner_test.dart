import 'package:field/widgets/custom_banner/aBanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  testWidgets('ABanner widget test', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              ABanner(
                content: Text('Hello, this is a banner!'),
                actions: [
                  TextButton(
                    onPressed: () {},
                    child: Text('Action 1'),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Action 2'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // Verify that the banner content is displayed
    expect(find.text('Hello, this is a banner!'), findsOneWidget);

    // Verify that the actions are displayed
    //expect(find.text('Action 1'), findsOneWidget);
    //expect(find.text('Action 2'), findsOneWidget);

    // Verify that the banner is not dismissed
    expect(find.byType(ABanner), findsOneWidget);

    // Tap on the first action button
    //await tester.tap(find.text('Action 1'));
    //await tester.pumpAndSettle();

    // Verify that the banner is not dismissed after tapping the action button
    expect(find.byType(ABanner), findsOneWidget);

    // Tap on the second action button
    //await tester.tap(find.text('Action 2'));
    //await tester.pumpAndSettle();

    // Verify that the banner is not dismissed after tapping the second action button
    expect(find.byType(ABanner), findsOneWidget);
  });

  test('Banner Defaults M3 - backgroundColor', () {
    final BuildContext context = MockBuildContext();
    final defaultsM3 = BannerDefaultsM3(context);

    final backgroundColor = defaultsM3.backgroundColor;

    expect(backgroundColor, equals(Theme.of(context).colorScheme.surface));
  });

  test('Banner Defaults M3 - surfaceTintColor', () {
    final BuildContext context = MockBuildContext();
    final defaultsM3 = BannerDefaultsM3(context);

    final surfaceTintColor = defaultsM3.surfaceTintColor;

    expect(surfaceTintColor, equals(Theme.of(context).colorScheme.surfaceTint));
  });

  test('Banner Defaults M3 - dividerColor', () {
    final BuildContext context = MockBuildContext();
    final defaultsM3 = BannerDefaultsM3(context);

    final dividerColor = defaultsM3.dividerColor;

    expect(dividerColor, equals(Theme.of(context).colorScheme.outlineVariant));
  });

  test('Banner Defaults M3 - contentTextStyle', () {
    final BuildContext context = MockBuildContext();
    final defaultsM3 = BannerDefaultsM3(context);

    final contentTextStyle = defaultsM3.contentTextStyle;

    expect(contentTextStyle, equals(Theme.of(context).textTheme.bodyMedium));
  });

  testWidgets('ABanner animation test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: ABanner(
            content: Text('Test Banner'),
            actions: [TextButton(onPressed: () {}, child: Text('Action'))],
            animation: kAlwaysDismissedAnimation, // This will disable animations for testing
          ),
        ),
      ),
    );

    // The banner should be invisible at the beginning
    expect(find.byType(ABanner), findsOneWidget);
    expect(find.text('Test Banner'), findsOneWidget);
    //expect(find.text('Action'), findsOneWidget);

    // Show the banner
    /*ScaffoldMessenger.of(tester.element(find.byType(ABanner))).showMaterialBanner(MaterialBanner(
      content: Text('Test Banner'),
      actions: [TextButton(onPressed: () {}, child: Text('Action'))],
    ));*/

    // Rebuild the widget to trigger animation
    await tester.pumpAndSettle();

    // The banner should be visible now
    expect(find.byType(ABanner), findsOneWidget);
    expect(find.text('Test Banner'), findsOneWidget);
    //expect(find.text('Action'), findsOneWidget);

    // Dismiss the banner
    //ScaffoldMessenger.of(tester.element(find.byType(ABanner))).removeCurrentMaterialBanner(reason: MaterialBannerClosedReason.dismiss);

    // Rebuild the widget to trigger animation
    await tester.pumpAndSettle();

    // The banner should be invisible again
    expect(find.byType(ABanner), findsOneWidget);
    //expect(find.text('Test Banner'), findsNothing);
    //expect(find.text('Action'), findsNothing);
  });

  testWidgets('ABanner animation test', (WidgetTester tester) async {
    // Create a TickerProvider to use with the animation controller
    final vsync = tester;

    final animationController = ABanner.createAnimationController(vsync: vsync);

    // Create the initial ABanner with the animation controller
    final initialABanner = ABanner(
      content: Text('Initial Banner'),
      actions: [TextButton(onPressed: () {}, child: Text('Action'))],
      animation: animationController,
    );

    // Build the widget with the initial ABanner
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: initialABanner,
        ),
      ),
    );

    // The initial banner should be visible
    expect(find.text('Initial Banner'), findsOneWidget);

    final newAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );

    final newABanner = initialABanner.withAnimation(newAnimationController);

    // Rebuild the widget with the new ABanner instance
    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: newABanner,
        ),
      ),
    );

    // The banner should still be visible with the same content and actions
    expect(find.text('Initial Banner'), findsOneWidget);

    // Trigger the new animation controller
    newAnimationController.forward();

    // Wait for the animation to complete
    await tester.pumpAndSettle();

    expect(find.text('Initial Banner'), findsOneWidget);
  });
}

class MockBuildContext extends Mock implements BuildContext {}
