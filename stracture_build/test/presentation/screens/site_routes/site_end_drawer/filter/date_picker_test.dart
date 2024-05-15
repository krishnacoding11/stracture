import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/site_routes/site_end_drawer/filter/date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../../../bloc/mock_method_channel.dart';

GetIt getIt = GetIt.instance;

void main() {
  late Widget customDateFiled;
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  configureCubitDependencies() {
    di.init(test: true);
  }

  setUp(() {
    customDateFiled = MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate
        ], home: Material(child: CustomDateField(
            index: 1,
            date: "02/12/2022",
            textLabel: "textLabel"
        ))));
  });

  group("Custom Date Filed Cases", () {
    configureCubitDependencies();

    testWidgets('Text Widget Testing', (tester) async {

      await tester.pumpWidget(customDateFiled);

      final pdftronDocumentViewFinder = find.byType(Text);
      expect(pdftronDocumentViewFinder, findsWidgets);
    });

    testWidgets('Text Widget testing for hintText: ', (tester) async {

      await tester.pumpWidget(customDateFiled);

      var textFind = find.text('dd-MMM-yyyy');
      expect(textFind, findsOneWidget);

      Text text = tester.firstWidget(textFind);
      expect(text.style?.color, Colors.black12);
      expect(text.style?.fontSize, 16.0);
    });
  });
}
