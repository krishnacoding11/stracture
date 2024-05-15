import 'package:dio/dio.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

class MockDioAdapter {

  Dio dio = Dio()
    ..options.baseUrl = "https://adoddleqaak.asite.com/adoddle"
    ..options.headers =<String, dynamic>{
    'applicationId': '3',
  };


  late DioAdapter dioAdapter = DioAdapter(
    dio: dio,
    matcher: const FullHttpRequestMatcher(),
  );
}