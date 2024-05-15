import 'package:test/test.dart';
import 'package:field/data/model/user_profile_setting_vo.dart';

void main() {
  group('UserProfileSettingVo', () {
    test('fromJson', () {
      final jsonData = '''
      {
        "lastName": "Banethia (5327)",
        "curPassword": "",
        "jobTitle": "C++ Developer",
        "phoneId": 960234,
        "languageId": "en_GB",
        "marketingPref": false,
        "timeZone": "Europe/Lisbon",
        "newPassword": "",
        "isUserImageExist": false,
        "screenName": "sbanethia\$\$000KX1",
        "passwordMinLength": 9,
        "phoneNo": "532785243",
        "firstName": "Saurabh",
        "emailAddress": "sbanethia@asite.com",
        "jsonTimZones": [
          {"timeZone": "(UTC -11:00)Samoa Standard Time", "id": "Pacific/Midway"},
          {"timeZone": "(UTC +01:00)Central European Time", "id": "Europe/Paris"}
        ],
        "secondaryEmailAddress": "",
        "confirmPassword": "",
        "middleName": ""
      }
      ''';

      final userProfile = UserProfileSettingVo.fromJson(jsonData);

      expect(userProfile.lastName, equals('Banethia (5327)'));
      expect(userProfile.jobTitle, equals('C++ Developer'));
      expect(userProfile.phoneId, equals(960234));
      expect(userProfile.languageId, equals('en_GB'));
      expect(userProfile.marketingPref, isFalse);
      expect(userProfile.timeZone, equals('Europe/Lisbon'));
      expect(userProfile.newPassword, equals(''));
      expect(userProfile.isUserImageExist, isFalse);
      expect(userProfile.screenName, equals('sbanethia\$\$000KX1'));
      expect(userProfile.passwordMinLength, equals(9));
      expect(userProfile.phoneNo, equals('532785243'));
      expect(userProfile.firstName, equals('Saurabh'));
      expect(userProfile.emailAddress, equals('sbanethia@asite.com'));

      expect(userProfile.jsonTimZones, isNotNull);
      expect(userProfile.jsonTimZones!.length, equals(2));
      expect(userProfile.jsonTimZones![0].timeZone, equals('(UTC -11:00)Samoa Standard Time'));
      expect(userProfile.jsonTimZones![0].id, equals('Pacific/Midway'));
      expect(userProfile.jsonTimZones![1].timeZone, equals('(UTC +01:00)Central European Time'));
      expect(userProfile.jsonTimZones![1].id, equals('Europe/Paris'));

      expect(userProfile.secondaryEmailAddress, equals(''));
      expect(userProfile.confirmPassword, equals(''));
      expect(userProfile.middleName, equals(''));
    });

    test('toJson', () {
      final userProfile = UserProfileSettingVo(
        lastName: 'Doe',
        jobTitle: 'Software Engineer',
        phoneId: 123456,
        languageId: 'en_US',
        marketingPref: true,
        timeZone: 'America/New_York',
        passwordMinLength: 8,
        phoneNo: '9876543210',
        firstName: 'John',
        emailAddress: 'john.doe@example.com',
      );

      final json = userProfile.toJson();

      expect(json['lastName'], equals('Doe'));
      expect(json['jobTitle'], equals('Software Engineer'));
      expect(json['phoneId'], equals(123456));
      expect(json['languageId'], equals('en_US'));
      expect(json['marketingPref'], isTrue);
      expect(json['timeZone'], equals('America/New_York'));
      expect(json['passwordMinLength'], equals(8));
      expect(json['phoneNo'], equals('9876543210'));
      expect(json['firstName'], equals('John'));
      expect(json['emailAddress'], equals('john.doe@example.com'));
    });

    test('setter methods', () {
      final userProfile = UserProfileSettingVo();

      userProfile.languageId = 'en_US';
      expect(userProfile.languageId, equals('en_US'));

      userProfile.timeZone = 'America/New_York';
      expect(userProfile.timeZone, equals('America/New_York'));

      userProfile.phoneNo = '1234567890';
      expect(userProfile.phoneNo, equals('1234567890'));

      userProfile.curPassword = 'old_password';
      expect(userProfile.curPassword, equals('old_password'));

      userProfile.newPassword = 'new_password';
      expect(userProfile.newPassword, equals('new_password'));

      userProfile.confirmPassword = 'new_password';
      expect(userProfile.confirmPassword, equals('new_password'));
    });

    test('copyWith', () {
      final userProfile = UserProfileSettingVo(
        lastName: 'Doe',
        jobTitle: 'Software Engineer',
        phoneId: 123456,
        languageId: 'en_US',
        marketingPref: true,
        timeZone: 'America/New_York',
        passwordMinLength: 8,
        phoneNo: '9876543210',
        firstName: 'John',
        emailAddress: 'john.doe@example.com',
      );

      final updatedUserProfile = userProfile.copyWith(
        timeZone: 'Europe/London',
        phoneNo: '1234567890',
      );

      expect(updatedUserProfile.lastName, equals('Doe'));
      expect(updatedUserProfile.timeZone, equals('Europe/London'));
      expect(updatedUserProfile.phoneNo, equals('1234567890'));
      // Add more assertions for other fields...
    });

  });

  group('JsonTimZones', () {
    test('fromJson', () {
      final jsonData = {
        'timeZone': '(UTC -11:00)Samoa Standard Time',
        'id': 'Pacific/Midway',
      };

      final jsonTimZone = JsonTimZones.fromJson(jsonData);

      expect(jsonTimZone.timeZone, equals('(UTC -11:00)Samoa Standard Time'));
      expect(jsonTimZone.id, equals('Pacific/Midway'));
    });

    test('copyWith', () {
      final jsonTimZone = JsonTimZones(
        timeZone: '(UTC -11:00)Samoa Standard Time',
        id: 'Pacific/Midway',
      );

      final copiedJsonTimZone = jsonTimZone.copyWith(
        timeZone: '(UTC -10:00)Hawaii Standard Time',
        id: 'Pacific/Honolulu',
      );

      expect(copiedJsonTimZone.timeZone, equals('(UTC -10:00)Hawaii Standard Time'));
      expect(copiedJsonTimZone.id, equals('Pacific/Honolulu'));
    });

    test('toJson', () {
      final jsonTimZone = JsonTimZones(
        timeZone: '(UTC -11:00)Samoa Standard Time',
        id: 'Pacific/Midway',
      );

      final jsonData = jsonTimZone.toJson();

      expect(jsonData['timeZone'], equals('(UTC -11:00)Samoa Standard Time'));
      expect(jsonData['id'], equals('Pacific/Midway'));
    });
  });



}
