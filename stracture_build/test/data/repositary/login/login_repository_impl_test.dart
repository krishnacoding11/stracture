import 'dart:convert';

import 'package:field/data/model/datacenter_vo.dart';
import 'package:field/data/model/language_vo.dart';
import 'package:field/data/remote/login/login_repository_impl.dart';
import 'package:field/database/db_service.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/networking/network_service.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/sharedpreference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appconfig_test_data.dart';
import '../../../fixtures/fixture_reader.dart';
import '../../remote/mock_dio_adpater.dart';
import 'package:field/data/model/user_vo.dart';

class DBServiceMock extends Mock implements DBService {}

class MockNetworkService extends Mock implements NetworkService {}
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setBuildFlavorMethodChannel();
  MockMethodChannel().setAsitePluginsMethodChannel();
  AppConfigTestData().setupAppConfigTestData();

  DBServiceMock? mockDb;

  late MockDioAdapter mockDioAdapter;
  late MockBuildContext mockContext;
  AConstants.loadProperty();
  LogInRemoteRepository logInRemoteRepository = LogInRemoteRepository();

  const String email = 'mayurraval@asite.com';
  const String password = 'm2';

  setUp(() {
    mockContext = MockBuildContext();
    registerFallbackValue(mockContext);
    mockDioAdapter = MockDioAdapter();
    SharedPreferences.setMockInitialValues({"userData": ""});
    PreferenceUtils.init();
    mockDb = DBServiceMock();
    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
  });

  group("logIn", () {
    const logInUrl = '/apilogin/cbim/';

    final headers = <String, dynamic>{
      'applicationId': '3',
    };

    final params = <String, dynamic>{
      'email': 'm.raval@asite.com',
      'password': 'm2',
      'applicationTypeId': "3",
      'isFromField': "true",
    };

    const ssoParam = <String, dynamic>{
      'emailId': email,
      'SAMLResponse': "PHNhbWxwOlJlc3BvbnNlIElEPSJfNjcwZDhiZWQtYTE3Yy00MTFkLWJhMTUtZGZlYTYxOGVkNzlkIiBWZXJzaW9uPSIyLjAiIElzc3VlSW5zdGFudD0iMjAyMi0wOC0xMlQwNjo1MjoyNy45NzBaIiBEZXN0aW5hdGlvbj0iaHR0cHM6Ly9wb3J0YWxxYS5hc2l0ZS5jb20vc3NvL3NhbWwvU0FNTEFzc2VydGlvbkNvbnN1bWVyIiB4bWxuczpzYW1scD0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOnByb3RvY29sIj48SXNzdWVyIHhtbG5zPSJ1cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YXNzZXJ0aW9uIj5odHRwczovL3N0cy53aW5kb3dzLm5ldC81NGI5MGNmMC04ODE3LTQyZGUtODkzZi05ZDMyMDc2YjRhOWIvPC9Jc3N1ZXI+PHNhbWxwOlN0YXR1cz48c2FtbHA6U3RhdHVzQ29kZSBWYWx1ZT0idXJuOm9hc2lzOm5hbWVzOnRjOlNBTUw6Mi4wOnN0YXR1czpTdWNjZXNzIi8+PC9zYW1scDpTdGF0dXM+PEFzc2VydGlvbiBJRD0iX2EzZTY4MGYxLTM1OTUtNGI2NS1hMzI3LTgwNGQ0MTZlMjAwMCIgSXNzdWVJbnN0YW50PSIyMDIyLTA4LTEyVDA2OjUyOjI3Ljk1NFoiIFZlcnNpb249IjIuMCIgeG1sbnM9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDphc3NlcnRpb24iPjxJc3N1ZXI+aHR0cHM6Ly9zdHMud2luZG93cy5uZXQvNTRiOTBjZjAtODgxNy00MmRlLTg5M2YtOWQzMjA3NmI0YTliLzwvSXNzdWVyPjxTaWduYXR1cmUgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvMDkveG1sZHNpZyMiPjxTaWduZWRJbmZvPjxDYW5vbmljYWxpemF0aW9uTWV0aG9kIEFsZ29yaXRobT0iaHR0cDovL3d3dy53My5vcmcvMjAwMS8xMC94bWwtZXhjLWMxNG4jIi8+PFNpZ25hdHVyZU1ldGhvZCBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvMDQveG1sZHNpZy1tb3JlI3JzYS1zaGEyNTYiLz48UmVmZXJlbmNlIFVSST0iI19hM2U2ODBmMS0zNTk1LTRiNjUtYTMyNy04MDRkNDE2ZTIwMDAiPjxUcmFuc2Zvcm1zPjxUcmFuc2Zvcm0gQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwLzA5L3htbGRzaWcjZW52ZWxvcGVkLXNpZ25hdHVyZSIvPjxUcmFuc2Zvcm0gQWxnb3JpdGhtPSJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzEwL3htbC1leGMtYzE0biMiLz48L1RyYW5zZm9ybXM+PERpZ2VzdE1ldGhvZCBBbGdvcml0aG09Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvMDQveG1sZW5jI3NoYTI1NiIvPjxEaWdlc3RWYWx1ZT42UmFUSnBDY2gwOGVHMytGbHluTHVFbm9icmJpVWRhZllBdTZHM1pobUVvPTwvRGlnZXN0VmFsdWU+PC9SZWZlcmVuY2U+PC9TaWduZWRJbmZvPjxTaWduYXR1cmVWYWx1ZT5qTmNUSWo4QWxzdUNBOHo4MEZhYjhidjUvaEh3aFRKaDYzcHI4VE9hM1B5N01pVGphSFZIN1FBazIwWE04WktmbWwxbEZrNEpyWUlBVVRGbVBOeW56aFc2c0JYcjdvaExmcWQ2YkhrK1VoeUpGMkplZTlhYTF3QWNGT2JNVnRDcjgvdmlFLzRVYUNpeThxVXRKWnlwOHhXRnRrWk4vQm9ydkRmL0g3K0Qzc2FaK3ROanFidWR3dTQxSm9jS1ZHaG90V3FGOXhkZUNZS2dKZW5HZy9sUXZCSkVGc1lpL2did0RFTXJWdnVMSGtZT3k2RVBrZHJtTVllV25TOEdjN3M4Zk9QMXBmVWQwKzFVUUlPNzlkdWh2djloMGVLMThXOVpKN0pmcWtnQnNTcXpDYUEybkl0a29SZm5iQWs1cU5KNGZhTFdFL0MwMzIvaEh4SWRiR0NySEE9PTwvU2lnbmF0dXJlVmFsdWU+PEtleUluZm8+PFg1MDlEYXRhPjxYNTA5Q2VydGlmaWNhdGU+TUlJQzhEQ0NBZGlnQXdJQkFnSVFjb25HMHNOWUtZeEYxYWxVRk1BNGpUQU5CZ2txaGtpRzl3MEJBUXNGQURBME1USXdNQVlEVlFRREV5bE5hV055YjNOdlpuUWdRWHAxY21VZ1JtVmtaWEpoZEdWa0lGTlRUeUJEWlhKMGFXWnBZMkYwWlRBZUZ3MHlNakF5TURFd05qSTFOVGxhRncweU5UQXlNREV3TmpJMU5UQmFNRFF4TWpBd0JnTlZCQU1US1UxcFkzSnZjMjltZENCQmVuVnlaU0JHWldSbGNtRjBaV1FnVTFOUElFTmxjblJwWm1sallYUmxNSUlCSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQVE4QU1JSUJDZ0tDQVFFQXZqSmxmNVROUi83ZHVZdXpvWGRsbzNGVTdjN2kzNncrQVRzQ3d5dkxsYlExTWMrT2U1d2wzaWU3OHZOKzI0cjNSV1g0Vmo3RnpoeWxvSUc2Tng1YWFHYTBISUFiYjBIRktkMVQ2cXJyTmo3ZGduVWVvSzZOVWIzLzJSNTdPMGdFaTZtcnF6SGx4eEJoMmxxZ2N1K2JuenRTTTV5dmo5S0VNN0RFeS9kQWYzU1p6Mm5OOE9yM1Q2ZC8vbVNacTlBRmR5SzV2OVFlbHJNenovamFRYnNkcWpvZGxnZ2RubUdhdXVUNlMxOHBTdnV4TEsvTDFmNmlZMGF5WG9xOEFJcXpuSU5RQldHZG5kd3ArQzNNKzZ0ZGEzVS9QRnFKYWZyZzR3bWlQT0dwQjVNQ3Npc3pUeURMN3ZpSnM3Z3gyMWtoSjRSREVvQ3k2RXBkQ1hsSFk0NzFWUUlEQVFBQk1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQ2tPT3MrMlZLU0NPOURsOXY1RWhTWExIMzlsVk4rOCt6d0JOR1hHaXRUWUZkU3FaZGI4RkplOVRVNGtjNERRVmRoWXRiMHozR1MxaHAvdzlRc0g2aXV0S2hQdGJxYm1hdDFkZkh0OUIxS3RZMzk0VXMzUlBvVVBpOHNxNEg4RlRwMGFFQjZTQzlSdHE5RzQ5ZU9XelNRN1Q0UENLK2lSbU4yYkhCSHhUMjdTZDZYbWFnalVQeWFPYW00eWZGL3htK2JsV2c0RStNTE9RalNKejZOd3d0K0VOY2oxQlVEV2N3Vk03NmNramNWdWM5TjNSc1BRMFoxT04wMmtrMHVLQWt2cHVYZEFGMG5WWnhCVkI0ZzkxVDI3MDFIRjE2aExVTXp3L2JVN2pqN0l1WHN5TkxFMzNOM2M4SFhmd3R1SldZTG9hVE5kK21WbVhDVUxrbHpuSEdoPC9YNTA5Q2VydGlmaWNhdGU+PC9YNTA5RGF0YT48L0tleUluZm8+PC9TaWduYXR1cmU+PFN1YmplY3Q+PE5hbWVJRCBGb3JtYXQ9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjEuMTpuYW1laWQtZm9ybWF0OmVtYWlsQWRkcmVzcyI+amRpeW9yYUBhc2l0ZS5jb208L05hbWVJRD48U3ViamVjdENvbmZpcm1hdGlvbiBNZXRob2Q9InVybjpvYXNpczpuYW1lczp0YzpTQU1MOjIuMDpjbTpiZWFyZXIiPjxTdWJqZWN0Q29uZmlybWF0aW9uRGF0YSBOb3RPbk9yQWZ0ZXI9IjIwMjItMDgtMTJUMDc6NTI6MjcuODYwWiIgUmVjaXBpZW50PSJodHRwczovL3BvcnRhbHFhLmFzaXRlLmNvbS9zc28vc2FtbC9TQU1MQXNzZXJ0aW9uQ29uc3VtZXIiLz48L1N1YmplY3RDb25maXJtYXRpb24+PC9TdWJqZWN0PjxDb25kaXRpb25zIE5vdEJlZm9yZT0iMjAyMi0wOC0xMlQwNjo0NzoyNy44NjBaIiBOb3RPbk9yQWZ0ZXI9IjIwMjItMDgtMTJUMDc6NTI6MjcuODYwWiI+PEF1ZGllbmNlUmVzdHJpY3Rpb24+PEF1ZGllbmNlPmh0dHBzOi8vcG9ydGFscWEuYXNpdGUuY29tL3Nzby9zYW1sL21ldGFkYXRhPC9BdWRpZW5jZT48L0F1ZGllbmNlUmVzdHJpY3Rpb24+PC9Db25kaXRpb25zPjxBdHRyaWJ1dGVTdGF0ZW1lbnQ+PEF0dHJpYnV0ZSBOYW1lPSJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL2lkZW50aXR5L2NsYWltcy90ZW5hbnRpZCI+PEF0dHJpYnV0ZVZhbHVlPjU0YjkwY2YwLTg4MTctNDJkZS04OTNmLTlkMzIwNzZiNGE5YjwvQXR0cmlidXRlVmFsdWU+PC9BdHRyaWJ1dGU+PEF0dHJpYnV0ZSBOYW1lPSJodHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL2lkZW50aXR5L2NsYWltcy9vYmplY3RpZGVudGlmaWVyIj48QXR0cmlidXRlVmFsdWU+ZmZlMjExMDItODhlYy00YTEwLWJiMzktYWRjOTgxYmIwYzNlPC9BdHRyaWJ1dGVWYWx1ZT48L0F0dHJpYnV0ZT48QXR0cmlidXRlIE5hbWU9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vaWRlbnRpdHkvY2xhaW1zL2lkZW50aXR5cHJvdmlkZXIiPjxBdHRyaWJ1dGVWYWx1ZT5odHRwczovL3N0cy53aW5kb3dzLm5ldC81NGI5MGNmMC04ODE3LTQyZGUtODkzZi05ZDMyMDc2YjRhOWIvPC9BdHRyaWJ1dGVWYWx1ZT48L0F0dHJpYnV0ZT48QXR0cmlidXRlIE5hbWU9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vY2xhaW1zL2F1dGhubWV0aG9kc3JlZmVyZW5jZXMiPjxBdHRyaWJ1dGVWYWx1ZT5odHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL3dzLzIwMDgvMDYvaWRlbnRpdHkvYXV0aGVudGljYXRpb25tZXRob2QvcGFzc3dvcmQ8L0F0dHJpYnV0ZVZhbHVlPjxBdHRyaWJ1dGVWYWx1ZT5odHRwOi8vc2NoZW1hcy5taWNyb3NvZnQuY29tL2NsYWltcy9tdWx0aXBsZWF1dGhuPC9BdHRyaWJ1dGVWYWx1ZT48L0F0dHJpYnV0ZT48QXR0cmlidXRlIE5hbWU9Imh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL2dpdmVubmFtZSI+PEF0dHJpYnV0ZVZhbHVlPkphdGluPC9BdHRyaWJ1dGVWYWx1ZT48L0F0dHJpYnV0ZT48QXR0cmlidXRlIE5hbWU9Imh0dHA6Ly9zY2hlbWFzLnhtbHNvYXAub3JnL3dzLzIwMDUvMDUvaWRlbnRpdHkvY2xhaW1zL3N1cm5hbWUiPjxBdHRyaWJ1dGVWYWx1ZT5EaXlvcmE8L0F0dHJpYnV0ZVZhbHVlPjwvQXR0cmlidXRlPjxBdHRyaWJ1dGUgTmFtZT0iaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvZW1haWxhZGRyZXNzIj48QXR0cmlidXRlVmFsdWU+amRpeW9yYUBhc2l0ZS5jb208L0F0dHJpYnV0ZVZhbHVlPjwvQXR0cmlidXRlPjxBdHRyaWJ1dGUgTmFtZT0iaHR0cDovL3NjaGVtYXMueG1sc29hcC5vcmcvd3MvMjAwNS8wNS9pZGVudGl0eS9jbGFpbXMvbmFtZS9uYW1lIj48QXR0cmlidXRlVmFsdWU+amRpeW9yYUBhc2l0ZS5jb208L0F0dHJpYnV0ZVZhbHVlPjwvQXR0cmlidXRlPjwvQXR0cmlidXRlU3RhdGVtZW50PjxBdXRoblN0YXRlbWVudCBBdXRobkluc3RhbnQ9IjIwMjItMDgtMTJUMDY6NTI6MTEuNDExWiIgU2Vzc2lvbkluZGV4PSJfYTNlNjgwZjEtMzU5NS00YjY1LWEzMjctODA0ZDQxNmUyMDAwIj48QXV0aG5Db250ZXh0PjxBdXRobkNvbnRleHRDbGFzc1JlZj51cm46b2FzaXM6bmFtZXM6dGM6U0FNTDoyLjA6YWM6Y2xhc3NlczpQYXNzd29yZDwvQXV0aG5Db250ZXh0Q2xhc3NSZWY+PC9BdXRobkNvbnRleHQ+PC9BdXRoblN0YXRlbWVudD48L0Fzc2VydGlvbj48L3NhbWxwOlJlc3BvbnNlPg==",
      'applicationTypeId': "3",
      'URL': "https://portalqa.asite.com/sso/saml/SAMLAssertionConsumer",
      'loginType': "2",
      'UserAgent': "Mozilla/5.0 (Linux; Android 11; sdk_gphone_x86_arm Build/RPB1.200504.020; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.44 Safari/537.36",
      'userCloud': "0",
    };

    final userInformation = User.fromJson(jsonDecode(fixture("user_data.json")));

    test('logIn Success', () async {

      mockDioAdapter.dioAdapter.onPost(logInUrl, (server) => server.reply(200, userInformation),
          headers: headers, data: params);

      final result = await logInRemoteRepository.doLogin(params);
      expect(result?.data, isA<User>());
    });

    test('logIn', () async {

      mockDioAdapter.dioAdapter.onPost(logInUrl, (server) => server.reply(200, userInformation),
          headers: headers, data: params);

      final result = await logInRemoteRepository.logIn(params);
      expect(result?.data, isA<User>());
    });

    test('logIn 2FA', () async {

      mockDioAdapter.dioAdapter.onPost(logInUrl, (server) => server.reply(200, userInformation),
          headers: headers, data: params);

      final result = await logInRemoteRepository.login2FA(params);
      expect(result?.data, isA<User>());
    });

    test('logInSSO', () async {

      mockDioAdapter.dioAdapter.onPost(logInUrl, (server) => server.reply(200, userInformation),
          headers: headers, data: userInformation, queryParameters: ssoParam);

      final result = await logInRemoteRepository.doLogin(params);
      expect(result?.data, isA<User>());
    });

    test('logIn Fail', () async {
      mockDioAdapter.dioAdapter.onPost(logInUrl, (server) => server.reply(217, userInformation),
          headers: headers, data: params);

      final result = await logInRemoteRepository.doLogin(params);
      expect(result?.responseCode, 217);
    });
  });

  test('User SSO Details test', () async {
    const ssoDetailURL = '/login/getLoginCloudsDetail?emailId=m.raval@asite.com';
    const responseData = "[{\"ssoIdentityProvider\":\"\",\"ssoEnabled\":\"false\",\"isUserAvailable\":\"false\",\"msgTitle\":\"ABC\",\"cloudName\":\"AsiteCloud\",\"msgDescription\":\"\",\"ssoTargetURL\":null,\"enableCloudLogin\":\"true\"},{\"ssoIdentityProvider\":\"\",\"ssoEnabled\":\"false\",\"msgTitle\":null,\"isUserAvailable\":\"false\",\"cloudName\":\"AsiteSandboxCloud\",\"msgDescription\":\"\",\"ssoTargetURL\":\"https://portalsb.asite.com/sso/saml/metadata\",\"enableCloudLogin\":\"true\"},{\"ssoIdentityProvider\":\"\",\"ssoEnabled\":\"false\",\"isUserAvailable\":\"false\",\"msgTitle\":null,\"cloudName\":\"AsiteUSGov.Cloud\",\"msgDescription\":\"\",\"ssoTargetURL\":\"https://portalusgov.asite.com/sso/saml/metadata\",\"enableCloudLogin\":\"true\"},{\"ssoIdentityProvider\":\"\",\"ssoEnabled\":\"false\",\"isUserAvailable\":\"false\",\"msgTitle\":null,\"cloudName\":\"AsiteUAECloud\",\"msgDescription\":\"\",\"ssoTargetURL\":\"https://portaluae.asite.com/sso/saml/metadata\",\"enableCloudLogin\":\"true\"},{\"ssoIdentityProvider\":\"\",\"ssoEnabled\":\"false\",\"msgTitle\":null,\"isUserAvailable\":\"false\",\"cloudName\":\"AsiteKSACloud\",\"msgDescription\":\"\",\"ssoTargetURL\":\"https://portalksa.asite.com/sso/saml/metadata\",\"enableCloudLogin\":\"true\"}]";

    Map<String, dynamic> map = <String, dynamic>{};
    map["emailId"] = email;

    mockDioAdapter.dioAdapter.onGet(ssoDetailURL, (server) => server.reply(200, responseData));

    var response = await logInRemoteRepository.getUserSSODetails(map);
    expect(response?.responseCode, 200);
    if(response != null) {
      expect(response.data, isA<List<DatacenterVo>>());
    }
  });

  test('Get Language Lists Details test', () async {
    String loginTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    var userProfileSettingURL = '/commonapi/language/languageList?t=$loginTimeStamp';

    const responseData = "{\"jsonLocales\":[{\"displayCountry\":\"United Kingdom\",\"languageId\":\"en_GB\",\"displayLanguage\":\"English\"},{\"displayCountry\":\"United States\",\"languageId\":\"en_US\",\"displayLanguage\":\"English\"},{\"displayCountry\":\"Canada\",\"languageId\":\"en_CA\",\"displayLanguage\":\"English\"},{\"displayCountry\":\"France\",\"languageId\":\"fr_FR\",\"displayLanguage\":\"Français\"},{\"displayCountry\":\"Russia\",\"languageId\":\"ru_RU\",\"displayLanguage\":\"Русский\"},{\"displayCountry\":\"Spain\",\"languageId\":\"es_ES\",\"displayLanguage\":\"Español\"},{\"displayCountry\":\"Australia\",\"languageId\":\"en_AU\",\"displayLanguage\":\"English\"},{\"displayCountry\":\"China\",\"languageId\":\"zh_CN\",\"displayLanguage\":\"中文\"},{\"displayCountry\":\"Germany\",\"languageId\":\"de_DE\",\"displayLanguage\":\"Deutsch\"},{\"displayCountry\":\"Ireland\",\"languageId\":\"ga_IE\",\"displayLanguage\":\"Gaeilge\"},{\"displayCountry\":\"South Africa\",\"languageId\":\"en_ZA\",\"displayLanguage\":\"English\"},{\"displayCountry\":\"Saudi Arabia\",\"languageId\":\"ar_SA\",\"displayLanguage\":\"العربية\"},{\"displayCountry\":\"Japan\",\"languageId\":\"ja_JP\",\"displayLanguage\":\"日本語\"},{\"displayCountry\":\"Ireland\",\"languageId\":\"en_IE\",\"displayLanguage\":\"English\"},{\"displayCountry\":\"Italy\",\"languageId\":\"it_IT\",\"displayLanguage\":\"Italiano\"},{\"displayCountry\":\"Netherlands\",\"languageId\":\"nl_NL\",\"displayLanguage\":\"Nederlands\"},{\"displayCountry\":\"Czech Republic\",\"languageId\":\"cs_CZ\",\"displayLanguage\":\"Čeština\"},{\"displayCountry\":\"Turkey\",\"languageId\":\"tr_TR\",\"displayLanguage\":\"Türkçe\"}],\"locales\":\"en_GB,en_US,en_CA,fr_FR,ru_RU,es_ES,en_AU,zh_CN,de_DE,ga_IE,en_ZA,ar_SA,ja_JP,en_IE,it_IT,nl_NL,cs_CZ,tr_TR\"}";

    mockDioAdapter.dioAdapter.onGet(userProfileSettingURL, (server)  => server.reply(200, responseData));

    var response = await logInRemoteRepository.getLanguageList();

    switch(response.responseCode){
      case 200 :
        expect(response.responseCode, 200);
        break;
      case 401:
        expect(response.responseCode, 401);
    }

    if(response is SUCCESS) {
      var languageObj = response.data;
      expect(languageObj, isInstanceOf<Language>());
    }
  });
}
