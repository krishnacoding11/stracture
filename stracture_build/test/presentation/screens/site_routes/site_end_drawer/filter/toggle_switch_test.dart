import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/site_routes/site_end_drawer/filter/toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../../../bloc/mock_method_channel.dart';

GetIt getIt = GetIt.instance;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  late Widget aToggleSwitch;

  configureCubitDependencies() {
    di.init(test: true);
  }

  setUp(() {
    aToggleSwitch = MediaQuery(
      data: const MediaQueryData(),
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate
        ],
        home: Material(
          child: AToggleSwitch(
            value: true,
            onToggle: (bool value) {},
          ),
        ),
      ),
    );
  });

  group("Toggle Switch Test Cases", () {
    configureCubitDependencies();

    testWidgets('Text Widget Testing', (tester) async {
      await tester.pumpWidget(aToggleSwitch);

      final pdftronDocumentViewFinder = find.byType(Text);
      expect(pdftronDocumentViewFinder, findsWidgets);
    });

    testWidgets('AnimatedOpacity Widget Testing', (tester) async {
      await tester.pumpWidget(aToggleSwitch);

      final pdftronDocumentViewFinder = find.byType(AnimatedOpacity);
      expect(pdftronDocumentViewFinder, findsWidgets);
    });

    testWidgets('Opacity Widget Testing', (tester) async {
      await tester.pumpWidget(aToggleSwitch);

      final pdftronDocumentViewFinder = find.byType(Opacity);
      expect(pdftronDocumentViewFinder, findsWidgets);
    });

    testWidgets('Align Widget Testing', (tester) async {
      await tester.pumpWidget(aToggleSwitch);

      final pdftronDocumentViewFinder = find.byType(Align);
      expect(pdftronDocumentViewFinder, findsWidgets);
    });
  });
}
