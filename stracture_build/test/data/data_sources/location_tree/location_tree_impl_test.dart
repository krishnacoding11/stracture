import 'package:dio/dio.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/domain/use_cases/site/site_use_case.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockLocationTree extends Mock implements SiteUseCase {}

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  Response<dynamic> response;
  const baseUrl = 'https://adoddleqaak.asite.com';
  MockLocationTree mockLocationTree;
  List<Project> locationTree = <Project>[];

  Map<String, dynamic> getRequestMapData(page, limit) {
    Map<String, dynamic> map = {};
    map["action_id"] = "2";
    map["appType"] = "2";
    map["folderId"] = "0";
    map["isRequiredTemplateData"] = "true";
    map["isWorkspace"] = '1';
    map["projectId"] = r"2116416$$MPHAvl";
    map["projectIds"] = "-2";
    map["checkHashing"] = "false";
    return map;
  }

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(
      dio: dio,
      matcher: const FullHttpRequestMatcher(),
    );
    mockLocationTree = MockLocationTree();
  });

  group("Location Tree unit Testing", () {
    const locationTreeUrl =
        '/commonapi/pflocationservice/getLocationTree';

    final userInformation = getRequestMapData(1, 20);
    test("Location Tree Success with valid request", () {
      dioAdapter.onPost(
          locationTreeUrl, (server) => server.reply(200, "SUCCESS"),
          data: userInformation);
    });
    test("Location Tree 401 Error with invalid request", () {
      dioAdapter.onPost(
        locationTreeUrl,
            (server) => server.throws(
          401,
          DioException(
            requestOptions: RequestOptions(
              path: locationTreeUrl,
            ),
          ),
        ),
      );

      expect(
            () async => await dio.post(locationTreeUrl),
        throwsA(isA<DioException>()),
      );
    });
    test("Location Tree 200 response code and message test case", () async {
      dioAdapter.onPost(
          locationTreeUrl, (server) => server.reply(200, "SUCCESS"),
          data: userInformation);

      dioAdapter.onPost(
        locationTreeUrl,
            (server) => server.throws(
          401,
          DioException(
            requestOptions: RequestOptions(
              path: locationTreeUrl,
            ),
          ),
        ),
      );

      expect(
            () async => await dio.post(locationTreeUrl),
        throwsA(isA<DioException>()),
      );

      response = await dio.post(locationTreeUrl, data: userInformation);
      expect(response.statusCode, 200);
      expect(response.data, "SUCCESS");
    });
  });
}
