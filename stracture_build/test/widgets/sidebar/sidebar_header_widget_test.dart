import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
import 'package:field/widgets/sidebar/sidebar_header_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Test Sidebar Header widget", () {
    TestWidgetsFlutterBinding.ensureInitialized();
    testWidgets("Test ASidebarHeaderWidget with isOnline = true",
            (tester) async {
          File offlineFile = File("");
          bool isOnline = true;
          ASidebarHeaderWidget aSidebarHeaderWidget = ASidebarHeaderWidget(
            imageUrl: '',
            username: '',
            offlineFile: offlineFile,
            isOnline: isOnline,
            httpHeaders: {},
          );
          await tester.pumpWidget(MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: Scaffold(body: aSidebarHeaderWidget),
          ));
          Finder containerWidgetFinder = find.byType(Container);
          expect(containerWidgetFinder, findsWidgets);

          Finder columnWidgetFinder = find.byType(Column);
          expect(columnWidgetFinder, findsOneWidget);

          Finder cachedNetworkImageWidgetFinder = find.byType(CachedNetworkImage);
          expect(cachedNetworkImageWidgetFinder, findsOneWidget);

          Finder imageWidgetFinder = find.byType(Positioned);
          expect(imageWidgetFinder, findsWidgets);

          Finder sizedBoxWidgetFinder = find.byType(SizedBox);
          expect(sizedBoxWidgetFinder, findsWidgets);

          Finder normalTextWidgetFinder = find.byType(NormalTextWidget);
          expect(normalTextWidgetFinder, findsOneWidget);

          Finder dividerWidgetFinder = find.byType(ADividerWidget);
          expect(dividerWidgetFinder, findsOneWidget);
        });

    testWidgets("Test ASidebarHeaderWidget with isOnline = false",
            (tester) async {
          File offlineFile = File("");
          bool isOnline = false;
          ASidebarHeaderWidget aSidebarHeaderWidget = ASidebarHeaderWidget(
            imageUrl: '',
            username: 'Username',
            offlineFile: offlineFile,
            isOnline: isOnline,
            httpHeaders: {},
          );
          await tester.pumpWidget(MaterialApp(
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: [Locale('en')],
            home: Scaffold(body: aSidebarHeaderWidget),
          ));

          Finder containerWidgetFinder = find.byType(Container);
          expect(containerWidgetFinder, findsWidgets);

          Finder columnWidgetFinder = find.byType(Column);
          expect(columnWidgetFinder, findsOneWidget);

          Finder stackWidgetFinder = find.byType(Stack);
          expect(stackWidgetFinder, findsWidgets);

          Finder sizedBoxWidgetFinder = find.byType(SizedBox);
          expect(sizedBoxWidgetFinder, findsWidgets);

          Finder normalTextWidgetFinder = find.byType(NormalTextWidget);
          expect(normalTextWidgetFinder, findsOneWidget);

          Finder dividerWidgetFinder = find.byType(ADividerWidget);
          expect(dividerWidgetFinder, findsOneWidget);
        });
  });
}