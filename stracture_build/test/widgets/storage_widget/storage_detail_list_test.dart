import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/widgets/storage_widget/storage_details_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test StorageDetailsList and StorageDetailsWidget', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StorageDetailsList(),
        ),
      ),
    );

    // Find both StorageDetailsWidget instances
    final Finder modelsWidgetFinder = find.byWidgetPredicate((widget) => widget is StorageDetailsWidget && widget.storageName == "Models");
    final Finder filesWidgetFinder = find.byWidgetPredicate((widget) => widget is StorageDetailsWidget && widget.storageName == "Files");

    // Verify that both StorageDetailsWidget instances are found
    expect(modelsWidgetFinder, findsOneWidget);
    expect(filesWidgetFinder, findsOneWidget);

    // Verify the colors of the two StorageDetailsWidget instances
    final modelsWidget = tester.widget<StorageDetailsWidget>(modelsWidgetFinder);
    final filesWidget = tester.widget<StorageDetailsWidget>(filesWidgetFinder);

    expect(modelsWidget.color, AColors.modelColorForStorage);
    expect(filesWidget.color, AColors.blueColor);

    // Verify the text in the StorageDetailsWidget instances
    final modelsTextFinder = find.text("Models");
    final filesTextFinder = find.text("Files");

    expect(modelsTextFinder, findsOneWidget);
    expect(filesTextFinder, findsOneWidget);
  });
}
