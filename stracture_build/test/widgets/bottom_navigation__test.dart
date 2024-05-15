import 'package:field/bloc/download_size/download_size_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/widgets/bottom_navigation_item/ABottomNavigationItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../bloc/mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  late Widget bottomnavigationWidget;

  configureLoginCubitDependencies() {
    di.init(test: true);
  }

  setUp(() {
    List<ABottomNavigationItem> menuItems = List.empty(growable: true);
    menuItems.add(ABottomNavigationItem(
        key: const Key("Home"),
        icon: const Icon(Icons.dashboard),
        label: "Home"));
    menuItems.add(ABottomNavigationItem(
        key: const Key("Sites"),
        icon: const Icon(Icons.gps_fixed),
        label: "Sites"));
    menuItems.add(ABottomNavigationItem(
        key: const Key("Tasks"),
        icon: const Icon(Icons.task_alt_sharp),
        label: "Tasks"));
    bottomnavigationWidget = MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(
          localizationsDelegates:  const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: BottomNavigationBar(items: menuItems),
          ),
        ));
  });
  group("Bottom Navigation Page Testing", () {
    configureLoginCubitDependencies();
    testWidgets("Find Home navigation widget", (tester) async {
      await tester.pumpWidget(bottomnavigationWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text("Home"),findsOneWidget);
    });

    testWidgets("Find Sites navigation widget", (tester) async {
      await tester.pumpWidget(bottomnavigationWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text("Sites"),findsOneWidget);
    });

    testWidgets("Find Tasks navigation widget", (tester) async {
      await tester.pumpWidget(bottomnavigationWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text("Tasks"),findsOneWidget);
    });

  });
}

