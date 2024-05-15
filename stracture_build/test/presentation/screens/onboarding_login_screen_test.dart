import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/onboarding_login_screen.dart';
import 'package:field/widgets/login_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../bloc/mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  configureLoginCubitDependencies() {
    di.init(test: true);
  }

  testWidgets("Find widget", (tester) async {
    configureLoginCubitDependencies();
    Widget testWidget = MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => di.getIt<LoginCubit>(),
          child: MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: OnBoardingLoginScreen()),
        )
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(testWidget);

    expect(find.byType(LoginBackgroundWidget), findsOneWidget);
  });
}