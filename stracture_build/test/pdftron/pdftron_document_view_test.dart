import 'package:field/injection_container.dart' as di;
import 'package:field/pdftron/pdftron_constants.dart';
import 'package:field/pdftron/pdftron_document_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../bloc/mock_method_channel.dart';

onCreated(PdftronDocumentViewController pdftronDocumentViewController) {}
void main() {
  configureDependencies() {
    TestWidgetsFlutterBinding.ensureInitialized();
    MockMethodChannel().setNotificationMethodChannel();
    di.init(test: true);
  }

  setPdfTronMethodChannel() {
    const channel = MethodChannel('asite/pdftron_flutter/documentview');

    channel.setMockMethodCallHandler((methodCall) {
      switch (methodCall.method) {
        case AFunctions.requestResetRenderingPdftron:
          // Reset the zoom view only so no need to return anything
          break;
        default:
      }
      return;
    });
  }

  group("pdftron test",() {
    configureDependencies();

    Widget testWidget = MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('en')],
        home: PdftronDocumentView(key: Key("test_pdftron_key"),onCreated:onCreated),
    );

    testWidgets("Find pdftron widget", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(milliseconds: 1000));
      expect(find.byType(PdftronDocumentView), findsOneWidget);
    });

    test("Method channel pdftron", () {
      setPdfTronMethodChannel();
    });
  });

}