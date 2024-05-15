import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/login_routes/login.dart';
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

  group("Test login widget", () {
    configureLoginCubitDependencies();

    Widget testWidget = MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => di.getIt<LoginCubit>(),
          child: const MaterialApp(localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ], home: Material(child: LoginWidget(onPressed))),
        ));

    testWidgets("Find Login widget", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));

      Finder email = find.byKey(const Key('Email'));
      Finder loginButton = find.byKey(const Key('LoginButton'));
      Finder errorMessage = find.byKey(const Key('Error message'));

      expect(tester.widget<AElevatedButtonWidget>(loginButton).onPressed, isNull);

      await tester.enterText(email, "mayurraval@asite.com");
      await tester.pump();

      Finder formWidgetFinder = find.byType(Form);

      expect(find.text("Don’t have an account?"), findsNothing);
      expect(find.text("Sign Up"), findsNothing);

      Form formWidget = tester.widget(formWidgetFinder) as Form;
      GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;

      expect(formKey.currentState?.validate(), isTrue);

      expect(loginButton, findsOneWidget);

      expect(errorMessage, findsOneWidget);

      expect(tester.widget<AElevatedButtonWidget>(loginButton).onPressed, isNotNull);
      expect(tester.widget<BlocBuilder<LoginCubit, FlowState>>, isNotNull);
    });

    testWidgets("Find Continue Button Widget", (tester) async {
      await tester.pumpWidget(testWidget);
      await tester.pump(const Duration(seconds: 1));
      Finder continueText = find.text("Continue");
      expect(continueText, findsOneWidget);
    });

      });


}
