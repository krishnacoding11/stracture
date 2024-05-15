import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/dashboard/home_page_cubit.dart';
import 'package:field/bloc/dashboard/home_page_state.dart';
import 'package:field/data/model/home_page_model.dart';
import 'package:field/enums.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/homepage/add_more_to_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';

class MockHomePageCubit extends MockCubit<FlowState> implements HomePageCubit {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockHomePageCubit mockHomePageCubit = MockHomePageCubit();
  late HomePageModel homePageModel;
  List<UserProjectConfigTabsDetails> pendingList = [];

  configureHomePageDependencies() {
    di.getIt.unregister<HomePageCubit>();
    di.getIt.registerFactory<HomePageCubit>(() => mockHomePageCubit);
  }

  setUpAll(() {
    di.init(test: true);
    registerFallbackValue(UserProjectConfigTabsDetails());
  });

  setUp(() {
    configureHomePageDependencies();
    homePageModel = HomePageModel.fromJson(jsonDecode(fixture('homepage_pending_list_config_data.json')));
    pendingList = homePageModel.configJsonData!.userProjectConfigTabsDetails!;
  });
  Widget makeTestableWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.getIt<HomePageCubit>(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: AddMoreToHomeScreen(
          pendingShortCutList: pendingList,
          onConfirm: (addedShortcutList) {
          try {
            if (addedShortcutList != null && addedShortcutList is List<UserProjectConfigTabsDetails> && addedShortcutList.isNotEmpty) {
              mockHomePageCubit.updateHomePageAfterDialogDismiss(addedShortcutList);
            }
          } catch (_) {}
        },
        ),
      ),
    );
  }

  group("Add More to Home Screen Test", () {
    testWidgets("Tap on ShortCut Item Test ", (tester) async {
      tester.view.physicalSize = Size(950, 1000);
      addTearDown(() => tester.view.resetPhysicalSize());
      pendingList[1].isAdded = true;
      when(() => mockHomePageCubit.state).thenReturn(ItemToggleState(pendingList));
      when(() => mockHomePageCubit.addedShortcutList).thenReturn([pendingList[1]]);
      when(() => mockHomePageCubit.canConfigureMoreShortcuts()).thenReturn(true);
      await tester.pumpWidget(makeTestableWidget());

      Finder finder = find.byIcon(Icons.check_circle);
      expect(finder, findsOneWidget);
      await tester.tap(finder);

      Finder item = find.byKey(Key("AddMoreGridViewItem 2"));
      expect(item, findsOneWidget);
      await tester.tap(item);
      verify(() => mockHomePageCubit.handleOnTapAddMoreShortcutItem(any(), any())).called(2);
    });

    testWidgets("No matches found Test", (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(AddMoreSearchState([]));
      await tester.pumpWidget(makeTestableWidget());
      Finder finder = find.byKey(Key("No Matches Found"));
      expect(finder, findsOneWidget);
    });

    testWidgets("Tap On Confirm Button Test", (tester) async {
      pendingList[1].isAdded = true;
      when(() => mockHomePageCubit.state).thenReturn(PendingShortcutItemState(pendingList));
      await tester.pumpWidget(makeTestableWidget());
      Finder finder = find.byKey(Key("Add More To Home Dialog"));
      expect(finder, findsOneWidget);

      Finder confirmButton = find.text("Confirm");
      expect(confirmButton, findsOneWidget);

      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      expect(finder, findsNothing);
    });

    testWidgets("Tap On Exit Button Test", (tester) async {
      when(() => mockHomePageCubit.state).thenReturn(PendingShortcutItemState(pendingList));
      when(() => mockHomePageCubit.addedShortcutList).thenReturn(pendingList);
      await tester.pumpWidget(makeTestableWidget());
      Finder finder = find.byKey(Key("Add More To Home Dialog"));
      expect(finder, findsOneWidget);

      Finder exitButton = find.text("Exit");
      expect(exitButton, findsOneWidget);

      await tester.tap(exitButton);
      await tester.pumpAndSettle();

      expect(finder, findsNothing);
    });

    testWidgets("Click on form filter", (tester)  async{
      when(() => mockHomePageCubit.state).thenReturn(PendingShortcutItemState(pendingList));
      when(()=>mockHomePageCubit.canConfigureMoreShortcuts()).thenReturn(true);
      await tester.pumpWidget(makeTestableWidget());
      Finder finder = find.byKey(Key("AddMoreToHomeItem ${HomePageIconCategory.filter.value}"));
      expect(finder, findsOneWidget);
      await tester.tap(finder);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(Key('filtered_view_dialog_key')), findsOneWidget);
      Finder backArrow = find.byIcon(Icons.arrow_back);
      expect(backArrow, findsOneWidget);
      await tester.tap(backArrow);
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(Key('filtered_view_dialog_key')), findsNothing);
    });
  });
}
