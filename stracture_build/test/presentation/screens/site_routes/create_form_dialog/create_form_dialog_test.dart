import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/site/create_form_selection_cubit.dart';
import 'package:field/bloc/site/create_form_selection_state.dart';
import 'package:field/data/model/apptype_group_vo.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/screen/site_routes/create_form_dialog/create_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart' as mocktail;

import '../../../../bloc/mock_method_channel.dart';
import '../../../../fixtures/fixture_reader.dart';

class MockCreateFormSelectionCubit extends MockCubit<FlowState>
    implements CreateFormSelectionCubit {}

GetIt getIt = GetIt.instance;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockCreateFormSelectionCubit mockSelectFormCubit = MockCreateFormSelectionCubit();
  List<AppType>? apptypeList = [];
  List<AppTypeGroup>? searchList = [];
  late Widget selectFormDialog;

  configureCubitDependencies() {
    di.init(test: true);
    di.getIt.unregister<CreateFormSelectionCubit>();
    di.getIt.registerFactory<CreateFormSelectionCubit>(() => mockSelectFormCubit);
  }

  setUp(() {
    final appTypeListData = jsonDecode(fixture("app_type_list.json"));
    for (var item in appTypeListData["data"]) {
      apptypeList.add(AppType.fromJson(item));
    }

    final searchListData = jsonDecode(fixture("app_type_group_list.json"));
    for (var item in searchListData) {
      searchList.add(AppTypeGroup.fromJson(item));
    }



    selectFormDialog = MediaQuery(
        data: const MediaQueryData(),
        child: BlocProvider<CreateFormSelectionCubit>(
            create: (BuildContext context) => mockSelectFormCubit,
            child: const MaterialApp(
                localizationsDelegates: [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  AppLocalizations.delegate
                ],
                home: Material(
                    child: CreateFormDialog(
                  key: Key('key_show_create_form_dialog'),
                )))));
  });

  group("Test create form selection dialog", () {
    configureCubitDependencies();

    testWidgets('Test create form selection dialog', (tester) async {
      mocktail.when(() => mockSelectFormCubit.searchAppGroup).thenAnswer((invocation) => searchList);
      mocktail.when(() => mockSelectFormCubit.state).thenAnswer((invocation) => ContentState());

      await tester.pumpWidget(selectFormDialog);

      Finder appTypeList = find.byKey(const Key("AppTypeGroupListKey"));
      expect(appTypeList, findsOneWidget);
    });

    testWidgets('Test click on item box', (tester) async {
      mocktail.when(() => mockSelectFormCubit.searchAppGroup).thenAnswer((invocation) => searchList);
      mocktail.when(() => mockSelectFormCubit.state).thenAnswer((invocation) => ContentState());

      await tester.pumpWidget(selectFormDialog);

      Finder appTypeListItem = find.byKey(const Key("key_list_item")).first;
      expect(appTypeListItem, findsOneWidget);
      await tester.tap(appTypeListItem,warnIfMissed: false);
      await tester.pumpAndSettle();
    });

    testWidgets('Test create form selection dialog [loading] ', (tester) async {
      mocktail.when(() => mockSelectFormCubit.state).thenAnswer((invocation) => LoadingState(stateRendererType: StateRendererType.DEFAULT));
      await tester.pumpWidget(selectFormDialog);

      Finder appTypeList = find.byKey(Key("key_loading"));
      expect(appTypeList, findsOneWidget);
    });

    testWidgets('Test create form selection dialog [Empty view] ', (tester) async {
      mocktail.when(() => mockSelectFormCubit.state).thenAnswer((invocation) => NoProjectSelectedState());
      await tester.pumpWidget(selectFormDialog);

      Finder appTypeList = find.byKey(Key("key_empty_view_msg"));
      expect(appTypeList, findsOneWidget);
    });

    testWidgets('Test create form selection dialog [Empty view] when search list empty', (tester) async {
      mocktail.when(() => mockSelectFormCubit.state).thenAnswer((invocation) => ContentState());
      mocktail.when(() => mockSelectFormCubit.searchAppGroup).thenAnswer((invocation) => []);
      mocktail.when(() => mockSelectFormCubit.appList).thenAnswer((invocation) => apptypeList);
      await tester.pumpWidget(selectFormDialog);

      Finder appTypeList = find.byKey(Key("key_empty_view_msg"));
      expect(appTypeList, findsOneWidget);
    });

    testWidgets('Test create form selection dialog [Empty view] when search list apptypelist empty', (tester) async {

      mocktail.when(() => mockSelectFormCubit.state).thenAnswer((invocation) => ContentState());
      mocktail.when(() => mockSelectFormCubit.searchAppGroup).thenAnswer((invocation) => []);
      mocktail.when(() => mockSelectFormCubit.appList).thenAnswer((invocation) => []);
      await tester.pumpWidget(selectFormDialog);

      Finder appTypeList = find.byKey(Key("key_empty_view_msg"));
      expect(appTypeList, findsOneWidget);
    });

    testWidgets('Test create form appFormListView and Gridview', (tester) async {
      mocktail.when(() => mockSelectFormCubit.state).thenAnswer((invocation) => ContentState());
      mocktail.when(() => mockSelectFormCubit.searchAppGroup).thenAnswer((invocation) => searchList);
      await tester.pumpWidget(selectFormDialog);

      Finder appTypeList = find.byKey(Key("key_form_list_view"));
      expect(appTypeList, findsOneWidget);

      Finder gridViewItem = find.byKey(Key("key_grid_item")).first;
      expect(gridViewItem, findsOneWidget);
      tester.tap(gridViewItem,warnIfMissed: false);
    });

    testWidgets('Test create form searchTap', (tester) async {
      mocktail.when(() => mockSelectFormCubit.state).thenAnswer((invocation) => FlowState());
      mocktail.when(() => mockSelectFormCubit.searchAppGroup).thenAnswer((invocation) => searchList);
      await tester.pumpWidget(selectFormDialog);

      Finder appTypeList = find.byKey(Key("key_search_textformfield"));
      expect(appTypeList, findsOneWidget);

      await tester.enterText(find.byType(TextField), 'abc');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('abc'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text(''), findsOneWidget);
    });

    testWidgets('Test navigate back', (tester) async {
      mocktail.when(() => mockSelectFormCubit.state).thenAnswer((invocation) => FlowState());
      mocktail.when(() => mockSelectFormCubit.searchAppGroup).thenAnswer((invocation) => searchList);
      await tester.pumpWidget(selectFormDialog);

      Finder closeIcon = find.byIcon(Icons.close);
      tester.tap(closeIcon);
    });

    testWidgets('Test clear search render', (tester) async {
      mocktail.when(() => mockSelectFormCubit.state).thenAnswer((invocation) => FormTypeSearchClearState());
      mocktail.when(() => mockSelectFormCubit.searchAppGroup).thenAnswer((invocation) => searchList);
      await tester.pumpWidget(selectFormDialog);

      Finder clearSearchIcon = find.byKey(Key("key_clear_search_render"));
      expect(clearSearchIcon, findsOneWidget);

    });

    testWidgets('Test search clear', (tester) async {
      mocktail.when(() => mockSelectFormCubit.state).thenAnswer((invocation) => FormTypeExpandedState(true));
      mocktail.when(() => mockSelectFormCubit.searchAppGroup).thenAnswer((invocation) => searchList);
      await tester.pumpWidget(selectFormDialog);

      Finder clearSearchIcon = find.byKey(Key("key_search_clear_icon"));
      expect(clearSearchIcon, findsOneWidget);
      tester.tap(clearSearchIcon);
    });
  });
}
