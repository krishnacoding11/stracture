import 'dart:convert';

import 'package:field/bloc/sitetask/sitetask_cubit.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/site_routes/site_end_drawer/site_item/site_item.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/site_item/site_item_description/site_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import '../../../../../bloc/mock_method_channel.dart';
import '../../../../../fixtures/fixture_reader.dart';

GetIt getIt = GetIt.instance;
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  late Widget siteItemWidget;
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  configureCubitDependencies() {
    di.init(test: true);
  }

  setUp(() {
    String jsonDataString = fixture("sitetaskslist.json").toString();
    final json = jsonDecode(jsonDataString);
    final dataNode = json['data'];
    SiteItem siteItem = SiteItem(SiteForm.fromJson(dataNode[0]));

    siteItemWidget = MediaQuery(
        data: const MediaQueryData(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider<SiteTaskCubit>(
              create: (context) => SiteTaskCubit(),
            ),
          ],
          child: MaterialApp(localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppLocalizations.delegate
          ], home: Material(child: siteItem)),
        ));
  });

  group("Test Site Item Viewer Cases", () {
    configureCubitDependencies();
    testWidgets('Test Site Item cubit Testing', (tester) async {
      await tester.pumpWidget(siteItemWidget);
      expect(find.byType(Container), findsWidgets);
    });
    testWidgets('Card Widget Testing', (tester) async {
      await tester.pumpWidget(siteItemWidget);
      final cardWidget = find.byType(Card);
      expect(cardWidget, findsOneWidget);
    });
    testWidgets('ClipPath Widget Testing', (tester) async {
      await tester.pumpWidget(siteItemWidget);
      final cardWidget = find.byType(ClipPath);
      expect(cardWidget, findsOneWidget);
    });
    testWidgets('Container Widget Testing', (tester) async {
      await tester.pumpWidget(siteItemWidget);
      final containerWidget = find.byType(Container);
      expect(containerWidget, findsWidgets);
    });
    testWidgets('Column Widget Testing', (tester) async {
      await tester.pumpWidget(siteItemWidget);
      final columnWidget = find.byType(Column);
      expect(columnWidget, findsWidgets);
    });
    testWidgets('Site Description Widget Testing', (tester) async {
      await tester.pumpWidget(siteItemWidget);
      final siteDescriptionWidget = find.byType(SiteDescription);
      expect(siteDescriptionWidget, findsWidgets);
    });
  });
}