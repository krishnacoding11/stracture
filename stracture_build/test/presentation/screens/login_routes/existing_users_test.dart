
import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/login_routes/existing_users.dart';
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

  testWidgets("Find Account Login widget", (tester) async {
    configureLoginCubitDependencies();

    // var localRepo = getIt<LogInLocalRepository>();
    // localRepo.getExistingUser().then((value) => print("====${value.length}"));

    User u = User();
    u.baseUrl = "https://www.google.com";
    List<User> mList = <User>[];//await userData.getExistingUser();
    mList.add(u);

    Widget testWidget = MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => di.getIt<LoginCubit>(),
          child: MaterialApp(localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ], home: Material(child: ExistingAccountWidget(onPressed, mList))),
        ));

    await tester.pumpWidget(testWidget);
    await tester.pump(const Duration(seconds: 10));

    Finder accountText = find.text("Choose an Account");
    expect(accountText, findsOneWidget);

    // Finder loginAccount = find.byKey(Key("loginAccount"));
    // expect(loginAccount, findsOneWidget);
    // expect(formKey.currentState?.validate(), isTrue);
  });
}