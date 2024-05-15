import 'dart:convert';
import 'package:field/data/local/site/create_form_local_repository.dart';
import 'package:field/data/local/sitetask/sitetask_local_repository_impl.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';

class MockSiteCreateFormLocalRepository extends Mock implements CreateFormLocalRepository {}

class MockDatabaseManager extends Mock implements DatabaseManager {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  late MockSiteCreateFormLocalRepository mockSiteCreateFormLocalRepository;
  late CreateFormLocalRepository createFormLocalRepository;

  setUpAll(() {
    di.init(test: true);
    di.getIt.registerLazySingleton<MockSiteCreateFormLocalRepository>(() => MockSiteCreateFormLocalRepository());
    mockSiteCreateFormLocalRepository = di.getIt<MockSiteCreateFormLocalRepository>();
    createFormLocalRepository = di.getIt<CreateFormLocalRepository>();
  });

  test('createFormLocalRepository downloadInLineAttachment : ', () async {
    Map<String, dynamic> requestMap = <String, dynamic>{'key': 'value'};
    final result = await createFormLocalRepository.downloadInLineAttachment(requestMap);
    expect(result, isA<Result<dynamic>>());
  });
  test('createFormLocalRepository uploadAttachment : ', () async {
    Map<String, dynamic> requestMap = <String, dynamic>{'key': 'value'};
    final result = await createFormLocalRepository.uploadAttachment(requestMap);
    expect(result, isA<Result<dynamic>>());
  });
  test('createFormLocalRepository uploadInlineAttachment : ', () async {
    Map<String, dynamic> requestMap = <String, dynamic>{'key': 'value'};
    final result = await createFormLocalRepository.uploadInlineAttachment(requestMap);
    expect(result, isA<Result<dynamic>>());
  });
  test('throws UnimplementedError in saveFormToServer', () async {
    final request = <String, dynamic>{'key': 'value'};

    expect(() async => await createFormLocalRepository.saveFormToServer(request), throwsA(isA<UnimplementedError>()));
  });
  test('throws UnimplementedError in formDistActionTaskToServer', () async {
    final request = <String, dynamic>{'key': 'value'};

    expect(() async => await createFormLocalRepository.formDistActionTaskToServer(request), throwsA(isA<UnimplementedError>()));
  });
  test('throws UnimplementedError in formOtherActionTaskToServer', () async {
    final request = <String, dynamic>{'key': 'value'};

    expect(() async => await createFormLocalRepository.formOtherActionTaskToServer(request), throwsA(isA<UnimplementedError>()));
  });
  test('throws UnimplementedError in formStatusChangeTaskToServer', () async {
    final request = <String, dynamic>{'key': 'value'};

    expect(() async => await createFormLocalRepository.formStatusChangeTaskToServer(request), throwsA(isA<UnimplementedError>()));
  });
}
