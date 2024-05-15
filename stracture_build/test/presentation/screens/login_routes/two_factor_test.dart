import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/login_routes/twofactor_login.dart';
import 'package:field/utils/sharedpreference.dart';
import 'package:field/widgets/elevatedbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../bloc/mock_method_channel.dart';

onPressed() {}
onTap() {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  configureLoginCubitDependencies() {
    di.init(test: true);
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({
      "2FA":DateTime.now().toString()
    });
    PreferenceUtils.init();
  });

  testWidgets("Find Two Factor Login widget", (tester) async {
    configureLoginCubitDependencies();
    Widget testWidget = MediaQuery(
      data: const MediaQueryData(),
      child: BlocProvider(
        create: (context) => di.getIt<LoginCubit>(),
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Material(
            child: TwoFactorAuthLoginWidget(
              onPressed,
              paramData: const {
                'userName': 'username',
                'email': 'mayurraval@asite.com',
                'password': 'm2',
                'JSESSIONID': 'askjdjkashdjk1jk23hjk12h3jk1h2jk3h1jk23hkj1'
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpWidget(testWidget);
    await tester.pump(const Duration(minutes: 6));

    Finder code = find.byKey(const Key('Verification code'));
    Finder continueButton = find.byKey(const Key('Continue Button'));
    Finder resendButton = find.byKey(const Key('Resend Button'));
    Finder errormessage = find.byKey(const Key('Error message'));

    await tester.enterText(code, "12345649687");
    await tester.pump();

    Finder formWidgetFinder = find.byType(Form);

    Form formWidget = tester.widget(formWidgetFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;

    expect(formKey.currentState?.validate(), isTrue);

    expect(continueButton, findsOneWidget);
    expect(errormessage, findsOneWidget);


    expect(resendButton, findsOneWidget);
    expect(tester.widget<AElevatedButtonWidget>(continueButton).onPressed,
        isNotNull);
    expect(tester.widget<BlocBuilder<LoginCubit, FlowState>>, isNotNull);
  });
}
