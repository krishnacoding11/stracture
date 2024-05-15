import 'package:field/bloc/QR/navigator_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/widgets/barcodescanner.dart';
import 'package:field/widgets/imagewidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../bloc/mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  configureLoginCubitDependencies() {
    init(test: true);
  }

  group("Test barcode scan widget", ()
  {
    configureLoginCubitDependencies();

    Widget testWidget = MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => getIt<FieldNavigatorCubit>(),
          child: const MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Material(child: BarCodeScannerWidget())),
        ));

    testWidgets("Find qr button", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 5));

      Finder button = find.byType(FloatingActionButton);

      expect(button, findsOneWidget);
      expect(tester.widget<FloatingActionButton>(button).onPressed, isNotNull);
    });
  });
}