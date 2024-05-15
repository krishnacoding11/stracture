import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/data/model/datacenter_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/login_routes/datacenter.dart';
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

  testWidgets("Find data center", (tester) async {
    configureLoginCubitDependencies();

    DatacenterVo datacenterVo = DatacenterVo(cloudName: 'Asite Cloud');
    DatacenterVo datacenterVo1 = DatacenterVo(cloudName: 'Asite UAE Cloud');
    List<DatacenterVo> mList = <DatacenterVo>[];
    mList.add(datacenterVo);
    mList.add(datacenterVo1);

    DataCenters dataCenters = DataCenters(mList);

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
                  child: DataCenterWidget(
                onPressed,
                paramData: dataCenters,
              ))),
        ));

    await tester.pumpWidget(testWidget);
    await tester.pump(const Duration(seconds: 10));

    Finder continueButton = find.byKey(const Key('ContinueButton'));
    Finder dataCenterDropdown = find.byKey(const Key('datacenter_dropdown'));

    expect(tester.widget<AElevatedButtonWidget>(continueButton).onPressed, isNull);

    await tester.pump();

    expect(continueButton, findsOneWidget);
    expect(dataCenterDropdown, findsOneWidget);

    await tester.tap(dataCenterDropdown);
    await tester.pumpAndSettle();

    final dropdownItem = find.text('Asite Cloud').last;

    await tester.tap(dropdownItem);
    await tester.pumpAndSettle();

    expect(tester.widget<AElevatedButtonWidget>(continueButton).onPressed, isNotNull);
  });
}
