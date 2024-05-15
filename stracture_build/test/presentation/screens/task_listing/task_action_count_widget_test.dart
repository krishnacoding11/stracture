/*
import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/QR/navigator_cubit.dart';
import 'package:field/bloc/recent_location/recent_location_cubit.dart';
import 'package:field/bloc/task_action_count/task_action_count_cubit.dart';
import 'package:field/data/remote/task_action_count/taskactioncount_repository_impl.dart';
import 'package:field/domain/use_cases/task_action_count/task_action_count_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/task_action_count/task_action_count_widget.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../data/remote/mock_dio_adpater.dart';
import '../../../domain/use_cases/task_action_count/task_action_count_usecase_test.dart';
import '../../../fixtures/appconfig_test_data.dart';
import '../../../fixtures/fixture_reader.dart';

class MockTaskActionCountCubit extends MockCubit<FlowState>
    implements TaskActionCountCubit {}

class MockTaskActionUseCase extends Mock implements TaskActionCountUseCase{}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  late Widget taskActionCountWidget;
  late TaskActionCountCubit mockTaskActionCountCubit;
  late MockTaskActionCountUseCase mockTaskActionCountUseCase;

  configureCubitDependencies() {
    mockTaskActionCountUseCase = MockTaskActionCountUseCase();
    di.init(test: true);
    di.getIt.unregister<TaskActionCountCubit>();
    di.getIt.unregister<TaskActionCountUseCase>();
    di.getIt.registerLazySingleton<TaskActionCountUseCase>(() => mockTaskActionCountUseCase);
    // TaskActionCountRemoteRepository taskRepository = TaskActionCountRemoteRepository();
    di.getIt.registerFactory<TaskActionCountCubit>(() => mockTaskActionCountCubit);
    AppConfigTestData().setupAppConfigTestData();
  }

  setUp(() {
   mockTaskActionCountCubit = TaskActionCountCubit();
    var mockDioAdapter = MockDioAdapter();

    taskActionCountWidget = MediaQuery(
      data: MediaQueryData(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<FieldNavigatorCubit>(
              create: (context) => di.getIt<FieldNavigatorCubit>()),
          BlocProvider<TaskActionCountCubit>(create: (context) => mockTaskActionCountCubit),
          BlocProvider<RecentLocationCubit>(
              create: (context) => di.getIt<RecentLocationCubit>()),
        ],
        // create: (context) => TaskActionCountCubit(),
        child: MaterialApp(localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ], home: Material(child: TaskActionCountWidget())),

      ),
    );
  });

  group('Recent Location Test', () {
    configureCubitDependencies();

    setUp(() {
      var jsonDataString = fixture("task_action_count_list.json");
      when(() => mockTaskActionCountUseCase.getTaskActionCount(any())).thenAnswer(
            (_) => Future.value(Result(jsonDataString)),
      );    });

    testWidgets('Test background of dashboard', (WidgetTester tester) async {
      Widget testWidget = taskActionCountWidget;
      await tester.pumpWidget(testWidget);

      Finder backgroundWidget = find.byKey(Key('new_dashboard_background_container'));
      expect(backgroundWidget, findsOneWidget);
    });

    testWidgets('Test numbered dashboard items', (WidgetTester tester) async {
      Widget testWidget = taskActionCountWidget;
      await tester.pumpWidget(testWidget);

      Finder numberedWidget = find.byKey(Key('numbered_dashboard_item'));
      expect(numberedWidget, findsNWidgets(4));
    });

    testWidgets('Test recent location widget', (WidgetTester tester) async {
      Widget testWidget = taskActionCountWidget;
      await tester.pumpWidget(testWidget);

      Finder recentLocationWidget = find.byKey(Key("key_recent_location_widget_title"));
      expect(recentLocationWidget, findsOneWidget);
    });

    testWidgets('Test bottom labeled dashboard item', (WidgetTester tester) async {
      Widget testWidget = taskActionCountWidget;
      await tester.pumpWidget(testWidget);
      Finder bottomLabeledWidget = find.byKey(Key('bottom_label_dashboard_item'));
      expect(bottomLabeledWidget, findsOneWidget);
    });

    testWidgets('Test bottom labeled dashboard item text', (WidgetTester tester) async {
      Widget testWidget = taskActionCountWidget;
      await tester.pumpWidget(testWidget);
      Finder bottomLabeledWidget = find.byKey(Key('bottom_labeled_dashboard_item_text'));
      expect(bottomLabeledWidget, findsOneWidget);
      expect((bottomLabeledWidget.evaluate().single.widget as NormalTextWidget).text,"Create Site Form");
    });

    testWidgets('Test onClick New Tasks button', (WidgetTester tester) async {
      Widget testWidget = taskActionCountWidget;
      await tester.pumpWidget(testWidget);
      Finder numberedWidget = find.byKey(Key('inkwell_numbered_dashboard_item_1'));
      expect(numberedWidget, findsOneWidget);
      expect(tester.widget<InkWell>(numberedWidget).onTap, isNotNull);
    });

    testWidgets('Test onClick Tasks Due Today button', (WidgetTester tester) async {
      Widget testWidget = taskActionCountWidget;
      await tester.pumpWidget(testWidget);
      Finder numberedWidget = find.byKey(Key('inkwell_numbered_dashboard_item_2'));
      expect(numberedWidget, findsOneWidget);
      expect(tester.widget<InkWell>(numberedWidget).onTap, isNotNull);
    });

    testWidgets('Test onClick Tasks Due This Week button', (WidgetTester tester) async {
      Widget testWidget = taskActionCountWidget;
      await tester.pumpWidget(testWidget);
      Finder numberedWidget = find.byKey(Key('inkwell_numbered_dashboard_item_3'));
      expect(numberedWidget, findsOneWidget);
      expect(tester.widget<InkWell>(numberedWidget).onTap, isNotNull);
    });

    testWidgets('Test onClick Overdue Tasks button', (WidgetTester tester) async {
      Widget testWidget = taskActionCountWidget;
      await tester.pumpWidget(testWidget);
      Finder numberedWidget = find.byKey(Key('inkwell_numbered_dashboard_item_4'));
      expect(numberedWidget, findsOneWidget);
      expect(tester.widget<InkWell>(numberedWidget).onTap, isNotNull);
    });

  });
}*/
