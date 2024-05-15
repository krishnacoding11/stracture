import 'package:dio/dio.dart';
import 'package:field/data/model/user_profile_setting_vo.dart';
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;

  Response<dynamic> response;

  const baseUrl = 'https://dmsqaak.asite.com';

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(
      dio: dio,
      matcher: const FullHttpRequestMatcher(),
    );
  });

  test('Get User Profile Details test', () async {
    const userProfileSettingURL = '/adoddle/dashboard?action_id=205&_=1661412229863';

    const responseData = "{\"lastName\":\"Banethia (5327)\",\"curPassword\":\"\",\"jobTitle\":\"C++ Developer\",\"phoneId\":960234,\"languageId\":\"en_GB\",\"marketingPref\":false,\"timeZone\":\"Europe/Lisbon\",\"newPassword\":\"\",\"isUserImageExist\":false,\"screenName\":\"sbanethia\$\$000KX1\",\"passwordMinLength\":9,\"phoneNo\":\"532785243\",\"firstName\":\"Saurabh\",\"emailAddress\":\"sbanethia@asite.com\",\"jsonTimZones\":[{\"timeZone\":\"(UTC -11:00)Samoa Standard Time\",\"id\":\"Pacific/Midway\"},{\"timeZone\":\"(UTC -10:00)Hawaii Standard Time\",\"id\":\"Pacific/Honolulu\"},{\"timeZone\":\"(UTC -09:00)Alaska Standard Time\",\"id\":\"America/Anchorage\"},{\"timeZone\":\"(UTC -08:00)Pacific Standard Time\",\"id\":\"America/Los_Angeles\"},{\"timeZone\":\"(UTC -07:00)Mountain Standard Time\",\"id\":\"America/Denver\"},{\"timeZone\":\"(UTC -06:00)Central Standard Time\",\"id\":\"America/Chicago\"},{\"timeZone\":\"(UTC -05:00)Eastern Standard Time\",\"id\":\"America/New_York\"},{\"timeZone\":\"(UTC -04:00)Atlantic Standard Time\",\"id\":\"America/Puerto_Rico\"},{\"timeZone\":\"(UTC -03:30)Newfoundland Standard Time\",\"id\":\"America/St_Johns\"},{\"timeZone\":\"(UTC -03:00)Brasilia Time\",\"id\":\"America/Sao_Paulo\"},{\"timeZone\":\"(UTC -02:00)Fernando de Noronha Time\",\"id\":\"America/Noronha\"},{\"timeZone\":\"(UTC -01:00)Azores Time\",\"id\":\"Atlantic/Azores\"},{\"timeZone\":\"(UTC )Western European Time\",\"id\":\"Europe/Lisbon\"},{\"timeZone\":\"(UTC +01:00)Central European Time\",\"id\":\"Europe/Paris\"},{\"timeZone\":\"(UTC +03:00)Eastern European Time\",\"id\":\"Europe/Istanbul\"},{\"timeZone\":\"(UTC +02:00)Israel Standard Time\",\"id\":\"Asia/Jerusalem\"},{\"timeZone\":\"(UTC +03:00)Arabia Standard Time\",\"id\":\"Asia/Baghdad\"},{\"timeZone\":\"(UTC +03:30)Iran Standard Time\",\"id\":\"Asia/Tehran\"},{\"timeZone\":\"(UTC +04:00)Gulf Standard Time\",\"id\":\"Asia/Dubai\"},{\"timeZone\":\"(UTC +04:30)Afghanistan Time\",\"id\":\"Asia/Kabul\"},{\"timeZone\":\"(UTC +05:00)Pakistan Time\",\"id\":\"Asia/Karachi\"},{\"timeZone\":\"(UTC +05:30)India Standard Time\",\"id\":\"Asia/Calcutta\"},{\"timeZone\":\"(UTC +05:45)Nepal Time\",\"id\":\"Asia/Katmandu\"},{\"timeZone\":\"(UTC +06:00)Bangladesh Time\",\"id\":\"Asia/Dhaka\"},{\"timeZone\":\"(UTC +06:30)Myanmar Time\",\"id\":\"Asia/Rangoon\"},{\"timeZone\":\"(UTC +07:00)Indochina Time\",\"id\":\"Asia/Saigon\"},{\"timeZone\":\"(UTC +08:00)China Standard Time\",\"id\":\"Asia/Shanghai\"},{\"timeZone\":\"(UTC +09:00)Japan Standard Time\",\"id\":\"Asia/Tokyo\"},{\"timeZone\":\"(UTC +09:00)Korea Standard Time\",\"id\":\"Asia/Seoul\"},{\"timeZone\":\"(UTC +08:00)Australian Western Standard Time\",\"id\":\"Australia/Perth\"},{\"timeZone\":\"(UTC +09:30)Australian Central Standard Time (South Australia)\",\"id\":\"Australia/Adelaide\"},{\"timeZone\":\"(UTC +09:30)Australian Central Standard Time (Northern Territory)\",\"id\":\"Australia/Darwin\"},{\"timeZone\":\"(UTC +10:00)Australian Eastern Standard Time (Queensland)\",\"id\":\"Australia/Brisbane\"},{\"timeZone\":\"(UTC +10:00)Australian Eastern Standard Time (New South Wales)\",\"id\":\"Australia/Canberra\"},{\"timeZone\":\"(UTC +10:00)Australian Eastern Standard Time (Tasmania)\",\"id\":\"Australia/Hobart\"},{\"timeZone\":\"(UTC +10:00)Australian Eastern Standard Time (Victoria)\",\"id\":\"Australia/Melbourne\"},{\"timeZone\":\"(UTC +10:00)Australian Eastern Standard Time (New South Wales)\",\"id\":\"Australia/Sydney\"},{\"timeZone\":\"(UTC +11:00)Solomon Is. Time\",\"id\":\"Pacific/Guadalcanal\"},{\"timeZone\":\"(UTC +12:00)New Zealand Standard Time\",\"id\":\"Pacific/Auckland\"},{\"timeZone\":\"(UTC +13:00)Phoenix Is. Time\",\"id\":\"Pacific/Enderbury\"},{\"timeZone\":\"(UTC +14:00)Line Is. Time\",\"id\":\"Pacific/Kiritimati\"}],\"secondaryEmailAddress\":\"\",\"confirmPassword\":\"\",\"middleName\":\"\"}";

    dioAdapter.onGet(userProfileSettingURL, (server)  => server.reply(200, responseData));

    response = await dio.get(userProfileSettingURL);

    expect(response.statusCode, 200);
    expect(response.data, responseData);
    if(response is SUCCESS) {
      var userProfileObj = response.data;
      expect(userProfileObj, isInstanceOf<UserProfileSettingVo>());
    } else {
      expect(
            () async => await dio.post(userProfileSettingURL),
        throwsA(isA<DioException>()),
      );
    }
  });

  test('Update user contact information test', () async {
    const updateUserProfileURL = '/adoddle/dashboard';

    final headers = <String, dynamic>{
      'applicationId': '3',
    };

    final params = <String, dynamic>{
      "action_id": 206,
      "applicationId": "3",
      "extra": "{\"lastName\":\"Banethia (5327)\",\"curPassword\":\"\",\"jobTitle\":\"C++ Developer\",\"phoneId\":960234,\"languageId\":\"en_AU\",\"marketingPref\":false,\"newPassword\":\"\",\"timeZone\":\"Asia/Kabul\",\"screenName\":\"sbanethia\$\$U1Oncx\",\"phoneNo\":\"123456\",\"firstName\":\"Saurabh\",\"emailAddress\":\"sbanethia@asite.com\",\"secondaryEmailAddress\":\"\",\"confirmPassword\":\"\",\"middleName\":\"\"}"
    };

    const responseData = "";

    dioAdapter.onPost(updateUserProfileURL, (server) => server.reply(200, responseData),
        headers: headers, data: responseData, queryParameters: params);

    response = await dio.post(updateUserProfileURL,
        queryParameters: params,
        data: responseData,
        options: Options(headers: headers));
    expect(response.statusCode, 200);
  });

  test('Update user selected language information test', () async {
    const updateUserProfileURL = '/adoddle/dashboard';

    final headers = <String, dynamic>{
      'applicationId': '3',
    };

    final params = <String, dynamic>{
      "action_id": 206,
      "applicationId": "3",
      "extra": "{\"lastName\":\"Banethia (5327)\",\"curPassword\":\"\",\"jobTitle\":\"C++ Developer\",\"phoneId\":960234,\"languageId\":\"en_CA\",\"marketingPref\":false,\"newPassword\":\"\",\"timeZone\":\"Asia/Kabul\",\"screenName\":\"sbanethia\$\$U1Oncx\",\"phoneNo\":\"123456\",\"firstName\":\"Saurabh\",\"emailAddress\":\"sbanethia@asite.com\",\"secondaryEmailAddress\":\"\",\"confirmPassword\":\"\",\"middleName\":\"\"}"
    };

    const responseData = "";

    dioAdapter.onPost(updateUserProfileURL, (server) => server.reply(200, responseData),
        headers: headers, data: responseData, queryParameters: params);

    response = await dio.post(updateUserProfileURL,
        queryParameters: params,
        data: responseData,
        options: Options(headers: headers));
    expect(response.statusCode, 200);
  });

  test('Update user selected timezone information test', () async {
    const updateUserProfileURL = '/adoddle/dashboard';

    final headers = <String, dynamic>{
      'applicationId': '3',
    };

    final params = <String, dynamic>{
      "action_id": 206,
      "applicationId": "3",
      "extra": "{\"lastName\":\"Banethia (5327)\",\"curPassword\":\"\",\"jobTitle\":\"C++ Developer\",\"phoneId\":960234,\"languageId\":\"en_CA\",\"marketingPref\":false,\"newPassword\":\"\",\"timeZone\":\"America/Anchorage\",\"screenName\":\"sbanethia\$\$U1Oncx\",\"phoneNo\":\"123456\",\"firstName\":\"Saurabh\",\"emailAddress\":\"sbanethia@asite.com\",\"secondaryEmailAddress\":\"\",\"confirmPassword\":\"\",\"middleName\":\"\"}"
    };

    const responseData = "";

    dioAdapter.onPost(updateUserProfileURL, (server) => server.reply(200, responseData),
        headers: headers, data: responseData, queryParameters: params);

    response = await dio.post(updateUserProfileURL,
        queryParameters: params,
        data: responseData,
        options: Options(headers: headers));
    expect(response.statusCode, 200);
  });

  test('Update user password change successfully test', () async {
    const updateUserProfileURL = '/adoddle/dashboard';

    final headers = <String, dynamic>{
      'applicationId': '3',
    };

    final params = <String, dynamic>{
      "action_id": 206,
      "applicationId": "3",
      "extra": "{\"lastName\":\"Banethia (5327)\",\"curPassword\":\"abc\",\"jobTitle\":\"C++ Developer\",\"phoneId\":960234,\"languageId\":\"en_CA\",\"marketingPref\":false,\"newPassword\":\"abcd\",\"timeZone\":\"America/Anchorage\",\"screenName\":\"sbanethia\$\$U1Oncx\",\"phoneNo\":\"123456\",\"firstName\":\"Saurabh\",\"emailAddress\":\"sbanethia@asite.com\",\"secondaryEmailAddress\":\"\",\"confirmPassword\":\"abcd\",\"middleName\":\"\"}"
    };

    const responseData = "{\"passwordModifiedDate\":\"1665403511860\",\"openId\":\"\",\"graceLoginCount\":0,\"greeting\":\"\",\"passwordEncrypted\":true,\"loginDate\":\"1665403361817\",\"isResetPassword\":true,\"screenName\":\"sbanethia\",\"lastLoginDate\":\"1665402829087\",\"uuid\":\"3c78681f-15fa-442f-9152-8845602d3fe2\",\"emailAddress\":\"sbanethia@asite.com\",\"passwordReset\":false,\"defaultUser\":false,\"createDate\":\"1475648773360\",\"isSuccess\":true,\"portraitId\":975067,\"comments\":\"\",\"contactId\":859156,\"timeZoneId\":\"America/Anchorage\",\"lastFailedLoginDate\":\"\",\"languageId\":\"en_CA\",\"active\":true,\"failedLoginAttempts\":0,\"userId\":859155,\"agreedToTermsOfUse\":true,\"companyId\":300106,\"lockout\":false,\"lockoutDate\":\"\",\"rawOffset\":-32400000,\"modifiedDate\":\"1665403511849\"}";

    dioAdapter.onPost(updateUserProfileURL, (server) => server.reply(200, responseData),
        headers: headers, data: responseData, queryParameters: params);

    response = await dio.post(updateUserProfileURL,
        queryParameters: params,
        data: responseData,
        options: Options(headers: headers));
    expect(response.statusCode, 200);
  });

  test('Update user password with wrong current password test', () async {
    const updateUserProfileURL = '/adoddle/dashboard';

    final headers = <String, dynamic>{
      'applicationId': '3',
    };

    final params = <String, dynamic>{
      "action_id": 206,
      "applicationId": "3",
      "extra": "{\"lastName\":\"Banethia (5327)\",\"curPassword\":\"abc\",\"jobTitle\":\"C++ Developer\",\"phoneId\":960234,\"languageId\":\"en_CA\",\"marketingPref\":false,\"newPassword\":\"abcd\",\"timeZone\":\"America/Anchorage\",\"screenName\":\"sbanethia\$\$U1Oncx\",\"phoneNo\":\"123456\",\"firstName\":\"Saurabh\",\"emailAddress\":\"sbanethia@asite.com\",\"secondaryEmailAddress\":\"\",\"confirmPassword\":\"abcd\",\"middleName\":\"\"}"
    };

    const responseData = "{\"isPasswordException\":true,\"passwordExceptionMessage\":\"Current password validation failed. Please enter the correct password.\",\"exceptionMessage\":\"Current password validation failed. Please enter the correct password.\"}";

    dioAdapter.onPost(updateUserProfileURL, (server) => server.reply(200, responseData),
        headers: headers, data: responseData, queryParameters: params);

    response = await dio.post(updateUserProfileURL,
        queryParameters: params,
        data: responseData,
        options: Options(headers: headers));
    expect(response.statusCode, 200);
  });
}