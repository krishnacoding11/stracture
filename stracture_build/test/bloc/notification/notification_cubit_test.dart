import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/notification/notification_cubit.dart';
import 'package:field/bloc/notification/notification_state.dart';
import 'package:field/domain/use_cases/notification/notification_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';
import '../../utils/load_url.dart';
import '../mock_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mockUseCase = MockNotificationUseCase();
  late NotificationCubit notificationCubit;

  setUp(() {
    AppConfigTestData().setupAppConfigTestData();
    notificationCubit = NotificationCubit(notificationUseCase: mockUseCase);
    MockMethodChannel().setAsitePluginsMethodChannel();
  });

  configureCubitDependencies() {
    MockMethodChannel().setNotificationMethodChannel();
    di.init(test: true);
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json"), "1_u1_project_": fixture("project.json")});
    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AConstants.loadProperty();
  }

  group("Notification cubit test", () {
    configureCubitDependencies();
    Map<String, dynamic> requestMap = {};
    requestMap["resource_parent_id"] = "11581743";
    requestMap["appType"] = '2';
    requestMap["entity_type"] = '1';
    requestMap["project_id"] = '2089700';
    test("Initial state", () {
      isA<FlowState>();
    });

    blocTest<NotificationCubit, FlowState>("Assume that Project is selected which notification as received. NotificationDetailSuccessState in case of server api success",
        build: () {
          return notificationCubit;
        },
        act: (c) async {
          when(() => mockUseCase.sendTaskDetailRequest(any())).thenAnswer((_) => Future.value(SUCCESS(fixture("notification_detail.json"), null, null)));
          await c.getTaskDetailRequestFromNotification(requestMap);
        },
        expect: () => [isA<NotificationDetailSuccessState>()]);

    blocTest<NotificationCubit, FlowState>("Error State in case of server api fail",
        build: () {
          return notificationCubit;
        },
        act: (c) async {
          when(() => mockUseCase.sendTaskDetailRequest(any())).thenAnswer((_) => Future.value(FAIL('Server Error', 600)));
          await c.getTaskDetailRequestFromNotification(requestMap);
        },
        expect: () => [isA<ErrorState>()]);
  });
}

class MockNotificationUseCase extends Mock implements NotificationUseCase {}
