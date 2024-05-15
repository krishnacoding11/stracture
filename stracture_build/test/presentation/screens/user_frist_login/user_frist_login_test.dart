import 'package:field/bloc/user_first_login_setup/user_first_login_setup_cubit.dart';
import 'package:field/bloc/user_first_login_setup/user_first_login_setup_state.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/user_first_login/user_first_login_screen.dart';
import 'package:field/widgets/elevatedbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../bloc/mock_method_channel.dart';

onPressed() {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  configureLoginCubitDependencies() {
    di.init(test: true);
  }

  group("Test User First widget", () {
    configureLoginCubitDependencies();
    setUp((){
      MockMethodChannel().setAsitePluginsMethodChannel();
      MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    });


    Widget testWidget = MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => di.getIt<UserFirstLoginSetupCubit>(),
          child: const MaterialApp(localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ], home: Material(child: UserFirstLogin(onPressed))),
        ));

    testWidgets("Find User First Login widget", (tester) async {
      UserFirstLoginSetupCubit userProfileSettingCubit =
      di.getIt<UserFirstLoginSetupCubit>();

      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));

      Finder checkBox = find.byKey(const Key('CheckBoxClick'));
      Finder continueButton = find.byKey(const Key('ContinueButton'));
      Finder skipButton = find.byKey(const Key('SkipButton'));
      Finder cancelButton = find.byKey(const Key('CancelButton'));
      Finder backButton = find.byKey(const Key('BackButton'));

      //privacy policy
      await tester.tap(checkBox);
      await tester.pump();
      expect(continueButton, findsOneWidget);
      expect(tester.widget<AElevatedButtonWidget>(continueButton).onPressed,
          isNotNull);
      expect(cancelButton, findsOneWidget);
      expect(tester.widget<InkWell>(cancelButton).onTap, isNotNull);

      //edit notification
      await tester.pump();
      userProfileSettingCubit.currentSetupScreen =
          UserFirstLoginSetup.editNotification;
      userProfileSettingCubit
          .emitState(UserFirstLoginState(UserFirstLoginSetup.editNotification));
      await tester.pumpWidget(testWidget);

      //edit avatar
      await tester.pump();
      userProfileSettingCubit.currentSetupScreen =
          UserFirstLoginSetup.editProfileImage;
      userProfileSettingCubit
          .emitState(UserFirstLoginState(UserFirstLoginSetup.editProfileImage));
      await tester.pumpWidget(testWidget);
      expect(continueButton, findsOneWidget);
      expect(tester.widget<AElevatedButtonWidget>(continueButton).onPressed,
          isNotNull);
      await tester.pump();
      expect(tester.widget<AElevatedButtonWidget>(continueButton).onPressed,
          isNotNull);
      await tester.pump();
    });
  });
}
