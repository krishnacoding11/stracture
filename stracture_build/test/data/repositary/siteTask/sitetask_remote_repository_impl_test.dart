import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:field/data/remote/sitetask/sitetask_remote_repository_impl.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';


class MockSiteTaskRemoteRepository extends Mock implements SiteTaskRemoteRepository {
  @override
  Future<Result?> getSiteTaskList(Map<String, dynamic> request) {
    Map<String, dynamic> data = jsonDecode(fixture("sitetaskslist.json"));
    return Future.value(Result<dynamic>(SUCCESS(data, Headers(), 200)));
  }

  @override
  Future<Result?> getExternalAttachmentList(Map<String, dynamic> request) {
    Map<String, dynamic> data = jsonDecode(fixture("sitetaskslist.json"));
    return Future.value(Result<dynamic>(SUCCESS(data, Headers(), 200)));
  }

  @override
  Future<Result?>? getFilterSiteTaskList(Map<String, dynamic> request) {
    Map<String, dynamic> data = jsonDecode(fixture("sitetaskslist.json"));
    return Future.value(Result<dynamic>(SUCCESS(data, Headers(), 200)));
  }

  @override
  Future<Result?> getUpdatedSiteTaskItem(String projectId, String formId) {
    Map<String, dynamic> data = jsonDecode(fixture("sitetaskslist.json"));
    return Future.value(Result<dynamic>(SUCCESS(data, Headers(), 200)));
  }
}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  di.getIt.registerLazySingleton<MockSiteTaskRemoteRepository>(
          () => MockSiteTaskRemoteRepository());
  late MockSiteTaskRemoteRepository mockSiteTaskRemoteRepository;

  setUpAll(() {
    mockSiteTaskRemoteRepository = di.getIt<MockSiteTaskRemoteRepository>();
  });

  group("Site task repository Implementation: ", () {
    test("Get site task list", () async {
      final result = await mockSiteTaskRemoteRepository.getSiteTaskList({});
      expect(result, isA<Result>());
    });

    test("Get external attachment list", () async {
      final result = await mockSiteTaskRemoteRepository.getExternalAttachmentList({});
      expect(result, isA<Result>());
    });

    test("Get filter site task list", () async {
      final result = await mockSiteTaskRemoteRepository.getFilterSiteTaskList({});
      expect(result, isA<Result>());
    });

    test("Get update side task list", () async {
      final result = await mockSiteTaskRemoteRepository.getUpdatedSiteTaskItem('12345', '1234');
      expect(result, isA<Result>());
    });
  });
}

