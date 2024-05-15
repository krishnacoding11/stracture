import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/data/model/datacenter_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/login_routes/password.dart';
import 'package:field/widgets/elevatedbutton.dart';
import 'package:field/widgets/textformfieldwidget.dart';
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

  testWidgets("Find Login widget", (tester) async {
    configureLoginCubitDependencies();

    DatacenterVo datacenterVo = DatacenterVo();
    List<DatacenterVo> mList = <DatacenterVo>[];
    mList.add(datacenterVo);

    DataCenters dataCenters = DataCenters(mList);

    Widget testWidget = MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider(
          create: (context) => di.getIt<LoginCubit>(),
          child: MaterialApp(localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ], home: Material(child: PasswordWidget(onPressed,paramData: dataCenters))),
        ));

    await tester.pumpWidget(testWidget);
    await tester.pump(const Duration(seconds: 1));

    Finder password = find.byKey(const Key('Password'));
    Finder loginButton = find.byKey(const Key('LoginButton'));

    expect(tester.widget<AElevatedButtonWidget>(loginButton).onPressed, isNull);

    expect(tester.widget<ATextFormFieldWidget>(password).autofocus, isTrue);

    await tester.enterText(password, "m7");
    await tester.pump();

    Finder formWidgetFinder = find.byType(Form);

    Form formWidget = tester.widget(formWidgetFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;

    expect(formKey.currentState?.validate(), isTrue);
    expect(loginButton, findsOneWidget);
    expect(tester.widget<AElevatedButtonWidget>(loginButton).onPressed, isNotNull);
  });
}