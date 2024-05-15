import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/site_routes/site_end_drawer/search_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../../bloc/mock_method_channel.dart';

GetIt getIt = GetIt.instance;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  late Widget searchTaskWidget;
  configureCubitDependencies() {
    di.init(test: true);
  }

  setUp(() {
    searchTaskWidget = MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizations.delegate
          ],
          home: Material(
              child: Row(
            children: const [
              Expanded(child: SearchTask()),
            ],
          )),
        ));
  });

  group("Search task Widget Test Cases", () {
    configureCubitDependencies();

    testWidgets('Test Search By Form Title Widget Finding', (tester) async {
      await tester.pumpWidget(searchTaskWidget);
      final searchWidget = find.byType(SearchTask);
      expect(searchWidget, findsWidgets);
    });

    testWidgets('Test Search By Form Title RawAutocomplete Widget Finding',
        (tester) async {
      await tester.pumpWidget(searchTaskWidget);
      final rawAutocomplete = find.byType(RawAutocomplete<String>);
      expect(rawAutocomplete, findsWidgets);
    });

    testWidgets(
        'Test set Search By Form Title value to RawAutocomplete Widget ',
        (tester) async {
      await tester.pumpWidget(searchTaskWidget);
      final rawAutocomplete = find.byType(RawAutocomplete<String>);
      await tester.enterText(rawAutocomplete, 'hi');
      expect(find.text('hi'), findsOneWidget);
    });

    testWidgets('Test finding Clear button after set value', (tester) async {
      await tester.pumpWidget(searchTaskWidget);
      final rawAutocomplete = find.byType(RawAutocomplete<String>);
      await tester.enterText(rawAutocomplete, 'hi');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('Test finding Clear button after set value perform Click event',
        (tester) async {
      await tester.pumpWidget(searchTaskWidget);
      final rawAutocomplete = find.byType(RawAutocomplete<String>);
      await tester.enterText(rawAutocomplete, 'hi');
      await tester.pump(const Duration(milliseconds: 400));
      final clearSearchWidget = find.byType(InkWell);
      await tester.tap(clearSearchWidget);
      expect(find.text('hi'), findsNothing);
    });
  });
}
