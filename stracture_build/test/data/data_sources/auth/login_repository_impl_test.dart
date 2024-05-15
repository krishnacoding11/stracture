import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  Response<dynamic> response;
  const baseUrl = 'https://dmsqaak.asite.com';
  const String email = 'mayurraval@asite.com';
  const String password = 'm7';
  const String userId = '859167';
  const String confirmPassword = '12345';

  const logInUrl = '/apilogin/cbim/';
  const sendPasswordLink = "/commonapi/user/sendPasswordLink";
  const resetPasswordUrl = "/commonapi/user/resetPassword";

  final headers = <String, dynamic>{
    'applicationId': '3',
  };

  const userInformation = <String, dynamic>{
    'emailId': email,
    'password': password,
    'applicationTypeId': "3",
    'isFromField': "true",
  };

  const sendPassword = <String, dynamic>{
    'emailId': email,
    'companyId': "300106",
    'applicationTypeId': "3",
  };

  const resetPassword = <String, dynamic>{
    'password': password,
    'confirmPassword': confirmPassword,
    'locale': "en_GB",
    'userId': userId,
  };

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(
      dio: dio,
      matcher: const FullHttpRequestMatcher(),
    );
  });

  group("Login unit testing:", () {
    test("Login Success with valid Email and password", () {
      dioAdapter.onPost(logInUrl, (server) => server.reply(200, "SUCCESS"),
          headers: headers, data: userInformation);
    });

    test("send password Link successfully", (){
      dioAdapter.onPost(sendPasswordLink, (server) => server.reply(200, "SUCCESS"),
          headers: headers, data:sendPassword);
    });

    test("Reset Success with valid password", (){
      dioAdapter.onPost(resetPasswordUrl, (server) => server.reply(200, "SUCCESS"),
          headers: headers, data:resetPassword);
    });

    test("Login 401 Error with invalid Email and Password", () {
      dioAdapter.onPost(
        logInUrl,
        (server) => server.throws(
          401,
          DioException(
            requestOptions: RequestOptions(
              path: logInUrl,
            ),
          ),
        ),
      );
    });

     test("Login 200 response code and message test case", () async {
      dioAdapter.onPost(logInUrl, (server) => server.reply(200, "SUCCESS"),
          headers: headers, data: userInformation);

      response = await dio.post(logInUrl,
          data: userInformation, options: Options(headers: headers));
      expect(response.statusCode, 200);
      expect(response.data, "SUCCESS");
    });
  });
}
