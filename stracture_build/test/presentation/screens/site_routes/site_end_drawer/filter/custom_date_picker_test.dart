import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/filter/custom_datepicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../../../bloc/mock_method_channel.dart';

GetIt getIt = GetIt.instance;

void main() {
  late Widget customDatePicker;
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  configureCubitDependencies() {
    di.init(test: true);
  }

  setUp(() {

    customDatePicker = MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate
        ], home: Material(child: CustomDatePicker(
            index: 1,
            onClose: () {},
            title: "title",
            jsonDateField: {},
              previousSelectedDate: null,
              strDateFormat: "",
        ))));
  });

  group("Custom Date Picker Cases", () {
    configureCubitDependencies();

    testWidgets('InkWell Widget Finding: ', (tester) async {
      await tester.pumpWidget(customDatePicker);
      final pdftronDocumentViewFinder = find.byType(InkWell);
      expect(pdftronDocumentViewFinder, findsWidgets);

      final childFinder = find.descendant(of: find.byWidget(customDatePicker), matching: find.byType(Text));
      expect(childFinder, findsWidgets);
    });

    testWidgets('Text Widget Testing for "Today": ', (tester) async {
      await tester.pumpWidget(customDatePicker);
      final pdftronDocumentViewFinder = find.byType(Text);
      expect(pdftronDocumentViewFinder, findsWidgets);

      await tester.pumpWidget(customDatePicker);

      var textFind = find.text('Today');
      expect(textFind, findsOneWidget);

      Text text = tester.firstWidget(textFind);
      expect(text.style?.color, AColors.themeBlueColor);
      expect(text.style?.fontFamily, AFonts.fontFamily);
    });

    testWidgets('Text Widget Testing for "This week": ', (tester) async {
      await tester.pumpWidget(customDatePicker);
      final pdftronDocumentViewFinder = find.byType(Text);
      expect(pdftronDocumentViewFinder, findsWidgets);

      await tester.pumpWidget(customDatePicker);

      var textFind = find.text('This week');
      expect(textFind, findsOneWidget);

      Text text = tester.firstWidget(textFind);
      expect(text.style?.color, AColors.themeBlueColor);
      expect(text.style?.fontFamily, AFonts.fontFamily);
    });

    testWidgets('Text Widget Testing for "The last 2 weeks": ', (tester) async {
      await tester.pumpWidget(customDatePicker);
      final pdftronDocumentViewFinder = find.byType(Text);
      expect(pdftronDocumentViewFinder, findsWidgets);

      await tester.pumpWidget(customDatePicker);

      var textFind = find.text('The last 2 weeks');
      expect(textFind, findsOneWidget);

      Text text = tester.firstWidget(textFind);
      expect(text.style?.color, AColors.themeBlueColor);
      expect(text.style?.fontFamily, AFonts.fontFamily);
    });

    testWidgets('Text Widget Testing for "The last month": ', (tester) async {
      await tester.pumpWidget(customDatePicker);
      final pdftronDocumentViewFinder = find.byType(Text);
      expect(pdftronDocumentViewFinder, findsWidgets);

      await tester.pumpWidget(customDatePicker);

      var textFind = find.text('The last month');
      expect(textFind, findsOneWidget);

      Text text = tester.firstWidget(textFind);
      expect(text.style?.color, AColors.themeBlueColor);
      expect(text.style?.fontFamily, AFonts.fontFamily);
    });
  });
}
