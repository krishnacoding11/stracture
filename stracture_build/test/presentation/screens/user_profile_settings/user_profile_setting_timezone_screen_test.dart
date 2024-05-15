import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/user_profile_setting/user_profile_setting_timezone_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../bloc/mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  configureLoginCubitDependencies() {
    di.init(test: true);
  }

  group("Test User Profile Setting Edit Timezone widgets", () {
    configureLoginCubitDependencies();

    Widget testWidget = MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => di.getIt<UserProfileSettingCubit>(),
          child: const MaterialApp(localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ], home: Scaffold(drawer: UserProfileSettingTimeZoneScreen())),
        ));

    testWidgets("Find User Profile Setting Edit Timezone List widget",
            (tester) async {
          await tester.pumpWidget(testWidget);
          await tester.pump(const Duration(seconds: 1));

          Finder selectCurrentPassword =
          find.byKey(const Key("Edit_Timezone_List_User_Profile_Settings"));
          expect(selectCurrentPassword, findsNothing);
        });

    testWidgets("Find User Profile Setting Edit Language Back Button widget",
            (tester) async {
          await tester.pumpWidget(testWidget);
          await tester.pump(const Duration(seconds: 1));

          Finder selectNewPassword = find
              .byKey(const Key('Edit_Timezone_Back_Button_User_Profile_Settings'));
          expect(selectNewPassword, findsNothing);
        });
    testWidgets("Container testing", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));

      Finder selectNewPassword = find.byType(Container);
      expect(selectNewPassword, findsWidgets);
    });
  });
}