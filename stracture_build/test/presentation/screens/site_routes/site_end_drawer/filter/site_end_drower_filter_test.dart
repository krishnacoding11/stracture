import 'dart:developer';

import 'package:field/bloc/Filter/filter_cubit.dart';
import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/bloc/sitetask/sitetask_state.dart';
import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/filter/custom_drop_down.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/filter/site_end_drawer_filter.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/filter/toggle_switch.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

import '../../../../../bloc/mock_method_channel.dart';
import '../../../../../fixtures/appConfig_test_data.dart';

// GetIt getIt = GetIt.instance;
class MockFilterCubit extends Mock implements FilterCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  late Widget siteEndDrawerFilter;
  MockFilterCubit mockFilterCubit = MockFilterCubit();
  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<FilterCubit>();
    di.getIt.registerFactory<MockFilterCubit>(() => mockFilterCubit);
    AppConfigTestData().setupAppConfigTestData();
  }

  setUp(() {
    siteEndDrawerFilter = MediaQuery(
      data: const MediaQueryData(),
      child: MaterialApp(
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate
        ],
        home: BlocProvider.value(
          value: mockFilterCubit,
          child: BlocBuilder<FilterCubit, FlowState>(
            builder: (context, state) {
              return Scaffold(
                body: SiteEndDrawerFilter(
                  onClose: () {},
                  onApply: () {},
                  curScreen: FilterScreen.screenSite,
                ),
              );
            },
          ),
        ),
      ),
    );
  });

  group("Site End Drawer Filter Cases", () {
    configureCubitDependencies();

    testWidgets('Stack Widget Testing', (tester) async {
      await tester.pumpWidget(siteEndDrawerFilter);
      final testStack = find.byType(Stack);
      debugDumpApp();
      expect(testStack, findsWidgets);
    });

    testWidgets('Dropdown Widget Testing', (tester) async {
      when(mockFilterCubit.state).thenReturn(FlowState());
      await tester.pumpWidget(siteEndDrawerFilter);
      await tester.pump();
      final dropdownFinder = find.byType(ACircularProgress);
      debugDumpApp();
      expect(dropdownFinder, findsWidgets);
    });
    //
    // testWidgets('AToggleSwitch Widget Testing', (tester) async {
    //   await tester.pumpWidget(siteEndDrawerFilter);
    //   final pdftronDocumentViewFinder = find.byType(AToggleSwitch);
    //   expect(pdftronDocumentViewFinder, findsWidgets);
    // });
  });
}