import 'package:bloc_test/bloc_test.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/requestParamsConstants.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/circular_progress/circular_menu_item.dart';
import 'package:field/widgets/circular_progress/circuler_menu.dart';
import 'package:field/widgets/model_dialogs/model_manage_request.dart';
import 'package:field/widgets/model_dialogs/model_request_set_offline_dialog.dart';
import 'package:field/widgets/model_tree.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  Map<String, dynamic> arguments = {};
  MockBuildContext context = MockBuildContext();

  configureLoginCubitDependencies() {
    init(test: true);
  }

  setUp(() async {

  });

  void onIconClicked() async {}

  Widget getTestWidget() {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en')],
      home: CircularMenu(
        items: [
          CircularMenuItem(
            enableBadge: false,
            color: AColors.white,
            iconSize: 18,
            imageIcon: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Image.asset(
                AImageConstants.focus,
                width: 22,
                height: 22,
              ),
            ),
            onTap: () {},
          ),
          CircularMenuItem(
            enableBadge: false,
            color: AColors.white,
            iconSize: 35,
            imageIcon: Image.asset(
              AImageConstants.palette,
              width: 40,
              height: 40,
              color: Colors.grey,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget getTestWidgetWithEnableBadgeTrue() {
    return MaterialApp(
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('en')],
      home: CircularMenu(
        items: [
          CircularMenuItem(
            enableBadge: true,
            color: AColors.white,
            iconSize: 18,
            imageIcon: Padding(
              padding: const EdgeInsets.all(9.0),
              child: Image.asset(
                AImageConstants.focus,
                width: 22,
                height: 22,
              ),
            ),
            onTap: () {},
          ),
          CircularMenuItem(
            enableBadge: true,
            color: AColors.white,
            iconSize: 35,
            imageIcon: Image.asset(
              AImageConstants.palette,
              width: 40,
              height: 40,
              color: Colors.grey,
            ),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  group('Circular Menu Item Tree Test', () {
    configureLoginCubitDependencies();
    testWidgets('should show circular menu', (WidgetTester tester) async {
      await tester.pumpWidget(getTestWidget());
      expect(find.byKey(Key('key_stack_circular_menu_item')), findsNWidgets(0));
      expect(find.byKey(Key('key_positioned_circular_menu_item')), findsNWidgets(0));
      expect(find.byKey(Key('key_circle_avatar_circular_menu_item')), findsNWidgets(0));
      expect(find.byKey(Key('key_label_text_circular_menu_item')), findsNWidgets(0));
      expect(find.byKey(Key('key_container')), findsNWidgets(3));
      expect(find.byKey(Key('key_clip_oval')), findsNWidgets(3));
    });

    testWidgets('should show circular menu', (WidgetTester tester) async {
      await tester.pumpWidget(getTestWidgetWithEnableBadgeTrue());
      expect(find.byKey(Key('key_stack_circular_menu_item')), findsNWidgets(2));
      expect(find.byKey(Key('key_positioned_circular_menu_item')), findsNWidgets(2));
      expect(find.byKey(Key('key_circle_avatar_circular_menu_item')), findsNWidgets(2));
      expect(find.byKey(Key('key_label_text_circular_menu_item')), findsNWidgets(0));
      expect(find.byKey(Key('key_container')), findsNWidgets(3));
      expect(find.byKey(Key('key_clip_oval')), findsNWidgets(3));
    });
  });
}
