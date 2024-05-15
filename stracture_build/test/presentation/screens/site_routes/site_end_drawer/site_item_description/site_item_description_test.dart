import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/site_routes/site_end_drawer/site_item/site_item_description/site_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../bloc/mock_method_channel.dart';

void main() {
  late Widget siteDescription;
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  configureCubitDependencies() {
    di.init(test: true);
  }

  setUp(() {

    siteDescription = const MediaQuery(
      data: MediaQueryData(),
      child: MaterialApp(localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ], home: Material(child: SiteDescription(
        description: 'description',
        title: 'title',
      ))),
    );
  });

  group("Test Site Item Viewer Cases", () {
    configureCubitDependencies();

    testWidgets('Padding Widget Testing', (tester) async {
      await tester.pumpWidget(siteDescription);
      final paddingWidget = find.byType(Padding);
      expect(paddingWidget, findsOneWidget);
    });
    testWidgets('Column Widget Testing', (tester) async {
      await tester.pumpWidget(siteDescription);
      final columnWidget = find.byType(Column);
      expect(columnWidget, findsOneWidget);
    });
    testWidgets('SizedBox Widget Testing', (tester) async {
      await tester.pumpWidget(siteDescription);
      final sizedBoxWidget = find.byType(SizedBox);
      expect(sizedBoxWidget, findsWidgets);
    });
    testWidgets('Row Widget Testing', (tester) async {
      await tester.pumpWidget(siteDescription);
      final rowWidget = find.byType(Row);
      expect(rowWidget, findsOneWidget);
    });
    testWidgets('Expanded Widget Testing', (tester) async {
      await tester.pumpWidget(siteDescription);
      final expandedWidget = find.byType(Expanded);
      expect(expandedWidget, findsWidgets);
    });
    testWidgets('Text Widget Testing', (tester) async {
      await tester.pumpWidget(siteDescription);
      final textWidget = find.byType(Text);
      expect(textWidget, findsWidgets);
    });
  });
}
