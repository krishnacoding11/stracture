import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/user_profile_setting/user_profile_setting_changepwd_screen.dart';
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

  group("Test User Profile Setting Change Password widgets", () {

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
          ], home: Material(child: UserProfileSettingChangePwdScreen())),
        ));

    testWidgets("Find User Profile Setting Current Password widget", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));

      Finder selectCurrentPassword = find.byKey(const Key('CurrentPassword'));
      expect(selectCurrentPassword, findsOneWidget);
    });

    testWidgets("Find User Profile Setting Label New Password widget", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));

      Finder selectNewPassword = find.byKey(const Key('NewPassword'));
      expect(selectNewPassword, findsOneWidget);
    });

    testWidgets("Find User Profile Setting Confirm Password widget", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));

      Finder selectUPSLabelItem = find.byKey(const Key('ConfirmPassword'));
      expect(selectUPSLabelItem, findsOneWidget);
    });

    testWidgets("Find User Profile Setting Cancel Button widget", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));

      Finder selectUPSLabelItem = find.byKey(const Key('Cancel_Button_Change_Pwd'));
      expect(selectUPSLabelItem, findsOneWidget);
    });

    testWidgets("Find User Profile Setting Save Button widget", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));

      Finder selectUPSLabelItem = find.byKey(const Key('Save_Button_Change_Pwd'));
      expect(selectUPSLabelItem, findsOneWidget);
    });
  });
}