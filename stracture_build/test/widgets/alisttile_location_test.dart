import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/widgets/alisttile_location.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AListTile - Test Widget Rendering and Tap', (WidgetTester tester) async {
    final String title = 'Test Tile';
    bool onTapCalled = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AListTile(
          title: title,
          onTap: () {
            onTapCalled = true;
          },
        ),
      ),
    ));

    final aListTileFinder = find.byType(AListTile);
    expect(aListTileFinder, findsOneWidget);

    // Find the NormalTextWidget widget inside AListTile
    final normalTextFinder = find.descendant(
      of: aListTileFinder,
      matching: find.byType(NormalTextWidget),
    );
    expect(normalTextFinder, findsOneWidget);

    // Verify that the NormalTextWidget displays the correct title
    final NormalTextWidget normalTextWidget = tester.widget(normalTextFinder);
    expect(normalTextWidget.text, equals(title));

    // Verify that the onTap callback is called when tapping the AListTile
    await tester.tap(aListTileFinder);
    await tester.pump();

    expect(onTapCalled, isTrue);
  });

  testWidgets('AListTile - Test Widget Style for Selected and Unselected', (WidgetTester tester) async {
    // Build the widget tree with isSelected set to true
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AListTile(
          title: 'Selected Tile',
          isSelected: true,
        ),
      ),
    ));

    // Find the NormalTextWidget widget inside AListTile
    final normalTextFinder = find.descendant(
      of: find.byType(AListTile),
      matching: find.byType(NormalTextWidget),
    );
    expect(normalTextFinder, findsOneWidget);

    // Verify that the NormalTextWidget has the correct style for selected state
    final NormalTextWidget normalTextWidget = tester.widget(normalTextFinder);
    expect(normalTextWidget.color, equals(AColors.iconGreyColor));

    // Build the widget tree with isSelected set to false
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AListTile(
          title: 'Unselected Tile',
          isSelected: false,
        ),
      ),
    ));

    // Verify that the NormalTextWidget has the correct style for unselected state
    final NormalTextWidget normalTextWidgetUnselected = tester.widget(normalTextFinder);
    expect(normalTextWidgetUnselected.color, equals(AColors.textColor));
  });

  testWidgets('ASearchListTile - Test Widget Rendering and Tap', (WidgetTester tester) async {
    // Define test data
    final String searchTitle = 'Test Search Title';
    final String locationPath = 'Test Location Path';
    bool onTapCalled = false;

    // Build the widget tree
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ASearchListTile(
          searchTitle: searchTitle,
          locationPath: locationPath,
          onTap: () {
            onTapCalled = true;
          },
        ),
      ),
    ));

    // Find the ASearchListTile widget
    final aSearchListTileFinder = find.byType(ASearchListTile);
    expect(aSearchListTileFinder, findsOneWidget);

    // Find the NormalTextWidgets inside ASearchListTile
    final normalTextFinders = find.byWidgetPredicate((widget) => widget is NormalTextWidget);
    expect(normalTextFinders, findsNWidgets(2));

    // Verify that the NormalTextWidgets display the correct titles
    final Iterable<NormalTextWidget> normalTextWidgets = tester.widgetList(normalTextFinders).cast<NormalTextWidget>();
    expect(normalTextWidgets.first.text, equals(searchTitle));
    expect(normalTextWidgets.first.text, equals(searchTitle));

    // Verify that the onTap callback is called when tapping the ASearchListTile
    await tester.tap(aSearchListTileFinder);
    await tester.pump();

    expect(onTapCalled, isTrue);
  });

  testWidgets('ASearchListTile - Test Widget Style', (WidgetTester tester) async {
    // Define test data
    final String searchTitle = 'Test Search Title';
    final String locationPath = 'Test Location Path';

    // Build the widget tree with default style
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ASearchListTile(
          searchTitle: searchTitle,
          locationPath: locationPath,
          onTap: () {},
        ),
      ),
    ));

    // Find the NormalTextWidgets inside ASearchListTile
    final normalTextFinders = find.byWidgetPredicate((widget) => widget is NormalTextWidget);
    expect(normalTextFinders, findsNWidgets(2));

    // Verify that the NormalTextWidgets have the correct default styles
    final Iterable<NormalTextWidget> normalTextWidgets = tester.widgetList(normalTextFinders).cast<NormalTextWidget>();
    expect(normalTextWidgets.first.fontWeight, equals(AFontWight.bold));
    expect(normalTextWidgets.first.fontSize, equals(17));
    expect(normalTextWidgets.first.textAlign, equals(TextAlign.start));

    expect(normalTextWidgets.first.fontWeight, equals(FontWeight.w700));
    expect(normalTextWidgets.first.fontSize, equals(17.0));
    expect(normalTextWidgets.first.textAlign, equals(TextAlign.start));
  });

}
