import 'package:field/utils/utils.dart';
import 'package:field/widgets/imagewidget.dart';
import 'package:field/widgets/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Test LogoWidget', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: LogoWidget(),
      ),
    ));

    final aImageWidgetFinder = find.byType(AImageWidget);

    expect(aImageWidgetFinder, findsOneWidget);

    final aImageWidget = tester.widget<AImageWidget>(aImageWidgetFinder);

    if (Utility.isTablet) {
      expect(aImageWidget.imagePath, 'ic_logo_tablet.png');
    } else {
      expect(aImageWidget.imagePath, 'ic_logo.png');
    }
  });
}
