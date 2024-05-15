import 'package:field/data/remote/notification/notification_repository_impl.dart';
import 'package:field/domain/use_cases/notification/notification_usecase.dart';
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/injection_container.dart' as di;

import '../../../bloc/mock_method_channel.dart';

class MockNotificationRemoteRepository extends Mock implements NotificationRemoteRepository {
  @override
  Future<Result> getNotificationList(Map<String, dynamic> request) async {
    return Future.value(SUCCESS("", null, 200));
  }

  // @override
  // Future<Result> sendTaskDetailRequest(Map<String, dynamic> request) {
  //   return Future.value(SUCCESS("", null, 200));
  // }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  di.getIt.unregister<NotificationRemoteRepository>();
  di.getIt.registerFactory<NotificationRemoteRepository>(() => MockNotificationRemoteRepository());
  late MockNotificationRemoteRepository mockNotificationRemoteRepository;
  late NotificationUseCase notificationUseCase;
  setUp(() {
    mockNotificationRemoteRepository = MockNotificationRemoteRepository();
    notificationUseCase = NotificationUseCase();
  });
  Map<String, dynamic> requestMap = {};
  group("Test Notification From Server", () {

  //   test("GetNotificationList Success response", () async {
  //     Map<String, dynamic> map = {"Hello": "123"};
  //     when(() => mockNotificationRemoteRepository.getNotificationList(any()));
  //
  //     final result = await notificationUseCase.getNotificationFromServer(map);
  //     expect(result, SUCCESS<dynamic>("", null, 200));
  //   });

    test("SendTaskDetailRequest Success response", () async {
      when(() => mockNotificationRemoteRepository.sendTaskDetailRequest(any()));
      var result = await notificationUseCase.sendTaskDetailRequest(requestMap);
      expect(result, SUCCESS<dynamic>("", null, 200));
    });
  });
}
