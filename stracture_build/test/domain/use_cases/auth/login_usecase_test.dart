import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:field/domain/use_cases/login/login_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';
import 'login_usecase_test.mocks.dart';

@GenerateMocks([
  LoginUseCase,
])
void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  await di.init(test: true);
  di.getIt.registerLazySingleton<MockLoginUseCase>(() => MockLoginUseCase());
  late MockLoginUseCase mockLoginUseCase;

  group("Login use case:", () {
    setUp(() {
      mockLoginUseCase = di.getIt<MockLoginUseCase>();
    });

    test("Result is a instance of result or not", () async {
      Map<String, dynamic> map = jsonDecode(fixture("login_request.json"));
      Map<String, dynamic> data = jsonDecode(fixture("login_data.json"));
      when(mockLoginUseCase.doLogin(map)).thenAnswer(
          (_) async => Result<dynamic>(SUCCESS(data, Headers(), 200)));
      final result = await mockLoginUseCase.doLogin(map);
      expect(result, isA<Result>());
    });
  });
}
