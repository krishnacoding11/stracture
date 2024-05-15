import 'package:field/bloc/user_first_login_setup/user_first_login_setup_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/user_profile_setting/user_avatar_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appConfig_test_data.dart';
import '../site_routes/site_plan_viewer_screen_test.dart';
import 'package:field/utils/constants.dart' as constant;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setBuildFlavorMethodChannel();
  configureLoginCubitDependencies() async{
    await di.init(test: true);
    AppConfigTestData().setupAppConfigTestData();
    constant.AConstants.loadProperty();
  }

  group("Test User Avatar Setting Screen widgets", () {

    configureLoginCubitDependencies();
    Widget testWidget = MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => di.getIt<UserFirstLoginSetupCubit>(),
          child: const MaterialApp(localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ], home: Material(child: UserAvatarSettingScreen())),
        ));

    testWidgets("Find User Avatar Setting Screen widget", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));

      Finder selectFromCameraWidget = find.byKey(const Key('SelectFromCamera'));
      expect(selectFromCameraWidget, findsOneWidget);

      Finder selectFromGalleryWidget = find.byKey(const Key('SelectFromGallery'));
      expect(selectFromGalleryWidget, findsOneWidget);
    });

  });
}