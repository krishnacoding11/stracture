import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/user_first_login/edit_formsetting/edit_formsetting.dart';
import 'package:field/widgets/behaviors/switch_with_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../bloc/mock_method_channel.dart';

onPressed() {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  configureLoginCubitDependencies() {
    di.init(test: true);
  }

  group("Test Edit FormSettings widget", () {

    configureLoginCubitDependencies();

    Widget testWidget = MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => di.getIt<UserProfileSettingCubit>(),
          child:  MaterialApp(localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ], home: Material(child: EditFormSetting())),
        ));

    testWidgets("Find Edit FormSettings widget", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));


      Finder changeNotificationSetting = find.byKey(const Key('includeCloseOutForm'));

      expect(changeNotificationSetting, findsOneWidget);

      expect(tester.widget<SwitchWithIcon>(changeNotificationSetting).onToggle, isNotNull);


    });
  });
}
