import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/overlay_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/injection_container.dart' as di;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  configureLoginCubitDependencies() {
    di.init(test: true);
  }

  OverlayEntry? overlay1;
  testWidgets('Test Overlay Banner', (WidgetTester tester) async {
    configureLoginCubitDependencies();
    final GlobalKey overlayKey = GlobalKey();
    bool didBuild = false;
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates:  const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: Scaffold(body: Builder(builder: (context) {
        didBuild = true;
        return Directionality(
            textDirection: TextDirection.ltr,
            child: Overlay(
              key: overlayKey,
              initialEntries: <OverlayEntry>[
                overlayBanner(context, context.toLocale!.lbl_location_plan_unavailable, context.toLocale!.lbl_location_does_not_plan_associated, Icons.warning, AColors.bannerWaringColor, isCloseManually: true, onTap: () {
                  overlay1!.remove();
                }),
              ],
            ));
      })),
    ));

    expect(didBuild, isTrue);
    final RenderObject theater = overlayKey.currentContext!.findRenderObject()!;

    expect(theater, hasAGoodToStringDeep);
  });


}
