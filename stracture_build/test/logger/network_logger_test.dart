import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:field/logger/logger.dart';
import 'package:field/logger/network_logger.dart';
import 'package:field/networking/network_request.dart';
import 'package:field/utils/sharedpreference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fixtures/fixture_reader.dart';

class MockRequestHandler extends Mock implements RequestInterceptorHandler {}

class MockResponse<T> extends Mock implements Response<T> {}

class MockResponseInterceptorHandler extends Mock implements ResponseInterceptorHandler {}

class MockErrorHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  const authKey = 'Authorization';
  late MockResponseInterceptorHandler mockResponseInterceptorHandler;
  late MockRequestHandler mockRequestInterceptorHandler;
  late MockErrorHandler mockErrorInterceptorHandler;
  late NetworkLogger loggingInterceptor;
  late Map<String, dynamic> responseData;

  setUp(() async {
    mockResponseInterceptorHandler = MockResponseInterceptorHandler();
    mockRequestInterceptorHandler = MockRequestHandler();
    mockErrorInterceptorHandler = MockErrorHandler();
    loggingInterceptor = NetworkLogger(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      cURLRequest: true,
      networkExecutionType: NetworkExecutionType.SYNC,
      taskNumber: 123456,
    );
    responseData = jsonDecode(fixture("sitetaskslist.json"));
    SharedPreferences.setMockInitialValues({
      'includeLogs': true,
    });
    await PreferenceUtils.init();
  });

  group('onRequest', () {
    test(
      'Request authorization header should be null when email and token are not provided',
      () async {
        final options = RequestOptions(path: 'http://path.com');
        loggingInterceptor.onRequest(options, mockRequestInterceptorHandler);

        expect(options.headers[authKey], isNull);
        verify(() => mockRequestInterceptorHandler.next(options)).called(1);
      },
    );

    test(
      'Request authorization header should be method post with requestBody when email and token are not provided',
      () async {
        final options = RequestOptions(path: 'http://path.com');
        options.headers['requestTime'] = DateTime.now().toString();
        options.headers['networkExecutionType'] = 'NetworkExecutionType.MAIN';
        options.headers['taskNumber'] = '1234455';
        options.method = "POST";
        options.data = {"projectID": "1234567"};
        loggingInterceptor.onRequest(options, mockRequestInterceptorHandler);

        expect(options.headers[authKey], isNull);
        verify(() => mockRequestInterceptorHandler.next(options)).called(1);
      },
    );

    test(
      'Request authorization header should be method post with requestbody when email and token are not provided',
      () async {
        final options = RequestOptions(path: 'http://path.com');
        options.method = "POST";
        final requestBody = {'username': 'example@mail.com', 'password': 'ABC1234563Af88jesKxPLVirJRW8wXvj3D'};
        FormData formData = FormData.fromMap(requestBody);
        options.data = formData;
        loggingInterceptor.onRequest(options, mockRequestInterceptorHandler);

        expect(options.headers[authKey], isNull);
        verify(() => mockRequestInterceptorHandler.next(options)).called(1);
      },
    );

    test(
      'Authorization header should be encoded with email and token when they are provided',
      () async {
        final options = RequestOptions(path: 'http://path.com');
        const token = 'authToken';
        const email = 'email@email.com';
        final encoded = base64Encode(utf8.encode('$email:$token'));
        final expected = 'Basic $encoded';
        options.headers = {'Authorization': expected};

        loggingInterceptor.onRequest(options, mockRequestInterceptorHandler);

        expect(options.headers[authKey], expected);
        verify(() => mockRequestInterceptorHandler.next(options)).called(1);
      },
    );
  });

  group('onResponse', () {
    test(
      'response data should be in Map type',
      () async {
        // GIVEN
        final tResponse = Response<dynamic>(requestOptions: RequestOptions());
        tResponse.requestOptions.headers = {
          'requestTime': DateTime.now().toString(),
          'networkExecutionType': 'NetworkExecutionType.MAIN',
          'taskNumber': '1234455',
        };
        tResponse.data = responseData;
        tResponse.headers = Headers.fromMap({
          'accept': ['application/json', 'application/javascript'],
        });
        // WHEN
        loggingInterceptor.onResponse(
          tResponse,
          mockResponseInterceptorHandler,
        );
        // THEN
        verify(() => mockResponseInterceptorHandler.next(tResponse)).called(1);
        verifyNoMoreInteractions(mockResponseInterceptorHandler);
      },
    );

    test(
      'response data should be in List type',
          () async {
        // GIVEN
        final tResponse = Response<dynamic>(requestOptions: RequestOptions());
        tResponse.requestOptions.headers = {
          'requestTime': DateTime.now().toString(),
          'networkExecutionType': 'NetworkExecutionType.MAIN',
          'taskNumber': '1234455',
        };
        tResponse.data = [responseData];
        tResponse.headers = Headers.fromMap({
          'accept': ['application/json', 'application/javascript'],
        });
        // WHEN
        loggingInterceptor.onResponse(
          tResponse,
          mockResponseInterceptorHandler,
        );
        // THEN
        verify(() => mockResponseInterceptorHandler.next(tResponse)).called(1);
        verifyNoMoreInteractions(mockResponseInterceptorHandler);
      },
    );
  });

  group('onError', () {
    test('Error type bad response', () async {
      // GIVEN
      final requestOption = RequestOptions(path: 'http://path.com');
      final tError = DioException(
        requestOptions: requestOption,
        type: DioExceptionType.badResponse,
        response: Response(
          statusCode: 403,
          requestOptions: requestOption,
          statusMessage: 'server not responding',
          data: {
            'message': 'Something went wrong'
          },
        ),
      );

      // WHEN
      loggingInterceptor.onError(tError, mockErrorInterceptorHandler);
      // THEN
      verify(() => mockErrorInterceptorHandler.next(tError)).called(1);
      verifyNoMoreInteractions(mockErrorInterceptorHandler);
    });

    test('Error type unknown', () async {
      // GIVEN
      final requestOption = RequestOptions(path: 'http://path.com');
      final tError = DioException(
        requestOptions: requestOption,
        type: DioExceptionType.unknown,
        response: Response(
          statusCode: 501,
          requestOptions: requestOption,
          statusMessage: 'server not responding',
        ),
      );

      // WHEN
      loggingInterceptor.onError(tError, mockErrorInterceptorHandler);
      // THEN
      verify(() => mockErrorInterceptorHandler.next(tError)).called(1);
      verifyNoMoreInteractions(mockErrorInterceptorHandler);
    });
  });


  test('loggerNoStack', () {
    loggerNoStack.d('print loggerNoStack');
  });
}
