import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/site/create_form_selection_cubit.dart';
import 'package:field/data/model/apptype_group_vo.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/screen/site_routes/create_form_dialog/task_type_dialog.dart';
import 'package:flutter/material.dart';
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
  late TaskTypeDialog taskDialog;

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

 taskDialog = TaskTypeDialog(
   createFormSelectionCubit: mockSelectFormCubit,
   key: Key('key_task_type_dialog'),
 );

    selectFormDialog = MediaQuery(
        data: const MediaQueryData(),
        child: MaterialApp(
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate
            ],
            home: Material(
                child: taskDialog)));
  });

  group("Test create form selection dialog", () {
    configureCubitDependencies();

    testWidgets('Test create form selection dialog [LoadingState]', (tester) async {
      mocktail.when(() => mockSelectFormCubit.state).thenAnswer((invocation) => LoadingState(stateRendererType: StateRendererType.DEFAULT));

      await tester.pumpWidget(selectFormDialog);

      Finder taskTypeDialogLoading = find.byKey(Key("key_loading"));
      expect(taskTypeDialogLoading, findsOneWidget);

    //  mocktail.when(() => taskDialog.checkSiteTaskEnabled()).thenReturn(true);

    });

    testWidgets('Task Dialog',(tester) async {
      mocktail.when(() => mockSelectFormCubit.state).thenAnswer((invocation) => FlowState());
      mocktail.when(() => mockSelectFormCubit.checkSiteTaskEnabled()).thenAnswer((invocation) => true);

      await tester.pumpWidget(selectFormDialog);

      Finder taskTypeDialog = find.byKey(Key("key_dialog"));
      expect(taskTypeDialog, findsOneWidget);


      Finder createSiteTask = find.byKey(Key("key_create_sitetask_item"));
      expect(createSiteTask, findsOneWidget);
      await tester.tap(createSiteTask);

      Finder createFormCard = find.byKey(Key("key_create_form_card"));
      expect(createFormCard, findsOneWidget);
      await tester.tap(createFormCard);
    });


    testWidgets('createFormDialogWidget',(tester) async {
      mocktail.when(() => mockSelectFormCubit.state).thenAnswer((invocation) => FlowState());
      mocktail.when(() => mockSelectFormCubit.checkSiteTaskEnabled()).thenAnswer((invocation) => false);
      mocktail.when(() => mockSelectFormCubit.searchAppGroup).thenAnswer((invocation) => searchList);
      mocktail.when(() => mockSelectFormCubit.appList).thenAnswer((invocation) => apptypeList);

      await tester.pumpWidget(selectFormDialog);
      Finder createSiteTask = find.byKey( Key("key_show_create_form_dialog"));
      expect(createSiteTask, findsOneWidget);

      /*Finder createFormCard = find.byKey(Key("key_create_form_card"));
      expect(createFormCard, findsOneWidget);
      await tester.tap(createFormCard);*/
    });
  });
}
