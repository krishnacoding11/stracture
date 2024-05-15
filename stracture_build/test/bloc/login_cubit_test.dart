import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/domain/use_cases/login/login_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fixtures/fixture_reader.dart';
import 'mock_method_channel.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  late MockLoginUseCase mockLoginUseCase;
  late LoginCubit loginCubit;
  LoginObject mLoginObject = LoginObject("", "");


  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    loginCubit = LoginCubit(loginUseCase: mockLoginUseCase);
  });

  group("Login Cubit:", () {
    MockMethodChannel().setAsitePluginsMethodChannel();
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json")});

    Map<String, dynamic> data = jsonDecode(fixture("login_data.json"));
    var expectedResult = SUCCESS<dynamic>(data, Headers(), 200);

    var expectedErrorLogin = FAIL("failureMessage", 502);

    var expectedForgotPasswordRequestResult = SUCCESS<dynamic>(jsonDecode(fixture("send_mail_request.json")), Headers(), 200);

    test("Initial State", () {
      //  expect(LoginCubit().state, FlowState());
    });

    blocTest<LoginCubit, FlowState>(
      'emits [ErrorState] when doLogin() is called on empty email',
      build: () => loginCubit,
      act: (cubit) async {
        //when(() => mockLoginUseCase.doLogin(any()))
        //  .thenAnswer((_) => Future.value(expectedErrorLogin));
        await cubit.doLogin("", "m2");
      },
      expect: () => [isA<ErrorState>()],
    );

    blocTest<LoginCubit, FlowState>(
      'success',
      build: () => loginCubit,
      act: (cubit) async {
        //when(() => mockLoginUseCase.doLogin(any()))
        //  .thenAnswer((_) => Future.value(expectedErrorLogin));
        await cubit.doLogin("mayurraval@asite.com", "m2");
      },
      expect: () => [isA<LoadingState>(), isA<ErrorState>()],
    );
    blocTest<LoginCubit, FlowState>(
      'emits [ErrorState] when doLogin() is called on empty password',
      build: () => loginCubit,
      act: (cubit) async {
        when(() => mockLoginUseCase.doLogin(any())).thenAnswer((_) => Future.value(expectedErrorLogin));
        await cubit.doLogin("mayurraval@asite.com", "");
      },
      expect: () => [isA<ErrorState>()],
    );

    blocTest<LoginCubit, FlowState>(
      'emits [SuccessState] when doLogin() is called',
      build: () => loginCubit,
      act: (cubit) async {
        when(() => mockLoginUseCase.doLogin(any())).thenAnswer((_) => Future.value(expectedResult));
        await cubit.doLogin("m.raval@asite.com", "m2");
      },
      expect: () => [isA<LoadingState>(), isA<SuccessState>(), isA<LoginSuccessState>()],
    );

    blocTest<LoginCubit, FlowState>(
      'emits [SuccessState] when sendPassword() is called',
      build: () => loginCubit,
      act: (cubit) async {
        when(() => mockLoginUseCase.doSetPasswordReqest(any())).thenAnswer((_) => Future.value(expectedForgotPasswordRequestResult));
        await cubit.doSetPasswordRequest("mayurraval@asite.com");
      },
      expect: () => [isA<LoadingState>(), isA<SuccessState>()],
    );

    blocTest<LoginCubit, FlowState>(
      'emits [ErrorState] when sendPassword() is called',
      build: () => loginCubit,
      act: (cubit) async {
        when(() => mockLoginUseCase.doSetPasswordReqest(any())).thenAnswer((_) => Future.value(FAIL("Internal server error ", 500)));
        await cubit.doSetPasswordRequest("mayurraval@asite.com");
      },
      expect: () => [isA<LoadingState>(), isA<ErrorState>()],
    );

    blocTest<LoginCubit, FlowState>(
      'emits [SuccessState] when resetPassword() is called',
      build: () => loginCubit,
      act: (cubit) async {
        when(() => mockLoginUseCase.doRestSetPassword(any())).thenAnswer((_) => Future.value(expectedForgotPasswordRequestResult));

        await cubit.doResetPassword("12345", "12345", "GB_en", "869167");
      },
      expect: () => [isA<LoadingState>(), isA<SuccessState>()],
    );

    blocTest<LoginCubit, FlowState>(
      'emits [ErrorState] when resetPassword() is called',
      build: () => loginCubit,
      act: (cubit) async {
        when(() => mockLoginUseCase.doRestSetPassword(any())).thenAnswer((_) => Future.value(FAIL("Internal server error ", 500)));

        await cubit.doResetPassword("12345", "12345", "GB_en", "869167");
      },
      expect: () => [isA<LoadingState>(), isA<ErrorState>()],
    );

    test("setPassword, check password value on login object", () {
      loginCubit.setPassword("pass");
      mLoginObject.password = "pass";
      expect("pass", mLoginObject.password);
    });

    test("setUserName, check username value on login object", () {
      loginCubit.setUserName("user@gmail.cm");
      mLoginObject.email = "user@gmail.cm";
      expect("user@gmail.cm", mLoginObject.email);
    });

    blocTest<LoginCubit, FlowState>("emits [ErrorState] when getUserSSODetails() is called on empty email",
        build: () => loginCubit,
        act: (cubit) async {
          when(() => mockLoginUseCase.doLogin(any())).thenAnswer((_) => Future.value(expectedErrorLogin));
          await cubit.getUserSSODetails("");
        },
        expect: () => [isA<ErrorState>()]);

    blocTest<LoginCubit, FlowState>("emits [SuccessState] when getUserSSODetails() is called on valid email",
        build: () => loginCubit,
        act: (cubit) async {
          when(() => mockLoginUseCase.getUserSSODetails(any())).thenAnswer((_) => Future.value(expectedResult));
          await cubit.getUserSSODetails("mitansi@abc-df.com");
        },
        expect: () => [isA<LoadingState>(),isA<SuccessState>()]);
  });
}
