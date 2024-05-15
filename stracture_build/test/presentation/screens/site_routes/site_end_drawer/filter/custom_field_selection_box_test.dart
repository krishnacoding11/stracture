import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/site_routes/site_end_drawer/filter/custom_selectiobox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../../../bloc/mock_method_channel.dart';

GetIt getIt = GetIt.instance;

void main() {
  late Widget customFiledSectionBox;
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  configureCubitDependencies() {
    di.init(test: true);
  }

  setUp(() {
    customFiledSectionBox = const MediaQuery(
        data: MediaQueryData(),
        child: MaterialApp(localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate
        ], home: Material(child: CustomFiledSectionBox(textLabel: "textLabel", hintText: "hintText"))));
  });

  group("Custom Filed Section Box Cases", () {
    configureCubitDependencies();

    testWidgets('Text Widget Testing', (tester) async {

      await tester.pumpWidget(customFiledSectionBox);

      final pdftronDocumentViewFinder = find.byType(Text);
      expect(pdftronDocumentViewFinder, findsWidgets);
    });

    testWidgets('Text Widget testing for textLabel: ', (tester) async {

      await tester.pumpWidget(customFiledSectionBox);

      var textFind = find.text('textLabel');
      expect(textFind, findsOneWidget);

      Text text = tester.firstWidget(textFind);
      expect(text.style?.color, Colors.black);
      expect(text.style?.fontSize, 16.0);
    });


    testWidgets('Text Widget testing for hintText: ', (tester) async {

      await tester.pumpWidget(customFiledSectionBox);

      var textFind = find.text('hintText');
      expect(textFind, findsOneWidget);

      Text text = tester.firstWidget(textFind);
      expect(text.style?.color, const Color(0xff757575));
      expect(text.style?.fontSize, 14.0);
    });
  });
}
