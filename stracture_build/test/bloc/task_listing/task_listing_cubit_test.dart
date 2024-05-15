import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/sitetask/sitetask_state.dart';
import 'package:field/bloc/task_listing/task_listing_cubit.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/domain/use_cases/tasklisting/task_listing_usecase.dart';
import 'package:field/injection_container.dart' as container;
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';
import '../mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // MockMethodChannel().setNotificationMethodChannel();
  // container.init(test: true);

  final mockUseCase = MockTaskListingUseCase();
  late TaskListingCubit taskListingCubit;
  SiteForm form;

  setUp(() {
    taskListingCubit = TaskListingCubit(useCase: mockUseCase);
    SharedPreferences.setMockInitialValues({
      "userData":fixture("user_data.json"),
      "1_808581_project":fixture("project.json")
    });
  });

  configureCubitDependencies() {
    MockMethodChannel().setNotificationMethodChannel();
    container.init(test: true);
    AppConfigTestData().setupAppConfigTestData();
  }

  group("Task listing cubit:", () {
    configureCubitDependencies();
    test("Initial state", () {
      expect(taskListingCubit.state, isA<InitialState>());
    });


    blocTest<TaskListingCubit, FlowState>(
        "Success State on server response",
        build: () {
          return taskListingCubit;
        },
        act: (c) async {
          when(() => mockUseCase.getTaskDetail(any()))
              .thenAnswer((_) async => Future(() => SUCCESS<dynamic>(fixture("sitetaskslist.json"), null,200)));

          String jsonDataString = fixture("sitetaskslist.json").toString();
          final json = jsonDecode(jsonDataString);
          final dataNode = json['data'];
          form = SiteForm.fromJson(dataNode[0]);
          await c.getTaskDetail(form);
        },
        expect: () => [isA<RefreshPaginationItemState>()]
    );

    blocTest<TaskListingCubit, FlowState>(
        "Change Filter icon state",
        build: () {
          return taskListingCubit;
        },
        act: (c) async {
          await c.changeFilterStatus(fixture('apply_filter_list.json'));
        },
        expect: () => [isA<ApplyFilterState>()]
    );
  });
}

class MockTaskListingUseCase extends Mock implements TaskListingUseCase {}