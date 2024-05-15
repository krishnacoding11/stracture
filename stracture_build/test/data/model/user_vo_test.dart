import 'package:field/data/model/user_vo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Timezone', () {
    test('fromJson should create Timezone object from JSON data', () {
      final json = {
        'dstSavings': '1 hour',
        'offsets': ['-08:00', '-07:00'],
        'rawOffset': '-08:00',
        // Add other properties and their values for your test JSON data
      };

      final timezone = Timezone.fromJson(json);

      expect(timezone.dstSavings, equals('1 hour'));
      expect(timezone.offsets, equals(['-08:00', '-07:00']));
      // Add more expect statements to validate other properties
    });

    test('toJson should convert Timezone object to JSON data', () {
      final timezone = Timezone(
        dstSavings: '1 hour',
        offsets: ['-08:00', '-07:00'],
        // Add other properties and their values for your test Timezone object
      );

      final json = timezone.toJson();

      expect(json['dstSavings'], equals('1 hour'));
      expect(json['offsets'], equals(['-08:00', '-07:00']));
      // Add more expect statements to validate other properties
    });

    test('copyWith should create a copy of Timezone object with updated properties', () {
      var originalTimezone = Timezone(
        dstSavings: '1 hour',
        offsets: ['-08:00', '-07:00'],
      );

      var updatedTimezone = originalTimezone.copyWith(dstSavings: '2 hours');

      expect(updatedTimezone.dstSavings, equals('2 hours'));
      expect(updatedTimezone.offsets, equals(['-08:00', '-07:00']));

      originalTimezone = Timezone(dstSavings: null);
      updatedTimezone = originalTimezone.copyWith(dstSavings: null);

      expect(updatedTimezone.dstSavings, equals(null));
    });
  });

  test('fromJson should create LocaleVo object from JSON data', () {
    final json = {
      'editionId': '12345',
      '_timezone': {
        'dstSavings': '1 hour',
        'offsets': ['-08:00', '-07:00'],
        'rawOffset': '-08:00',
        // Add other properties and their values for your test timezone JSON data
      },
      'generateURI': 'true',
      '_locale': 'en_US',
      '_partnerBrandingId': 'partner123',
      // Add other properties and their values for your test JSON data
    };

    final localeVo = LocaleVo.fromJson(json);

    expect(localeVo.editionId, equals('12345'));
    expect(localeVo.timezone, isA<Timezone>());
    expect(localeVo.generateURI, equals('true'));
    expect(localeVo.locale, equals('en_US'));
    expect(localeVo.partnerBrandingId, equals('partner123'));
    // Add more expect statements to validate other properties and nested objects
  });

  test('toJson should convert LocaleVo object to JSON data', () {
    final timezone = Timezone(
      dstSavings: '1 hour',
      offsets: ['-08:00', '-07:00'],
    );

    final localeVo = LocaleVo(
      editionId: '12345',
      timezone: timezone,
      generateURI: 'true',
      locale: 'en_US',
      partnerBrandingId: 'partner123',
    );

    final json = localeVo.toJson();

    expect(json['editionId'], equals('12345'));
    expect(json['_timezone'], isA<Map<String, dynamic>>());
    expect(json['generateURI'], equals('true'));
    expect(json['_locale'], equals('en_US'));
    expect(json['_partnerBrandingId'], equals('partner123'));
  });

  test('copyWith should create a copy of LocaleVo object with updated properties', () {
    final originalTimezone = Timezone(
      dstSavings: '1 hour',
      offsets: ['-08:00', '-07:00'],
    );

    final originalLocaleVo = LocaleVo(
      editionId: '12345',
      timezone: originalTimezone,
      generateURI: 'true',
      locale: 'en_US',
      partnerBrandingId: 'partner123',
    );

    var updatedLocaleVo = originalLocaleVo.copyWith(editionId: '12345');

    expect(updatedLocaleVo.editionId, equals('12345'));
    expect(updatedLocaleVo.timezone, equals(originalTimezone));
    expect(updatedLocaleVo.generateURI, equals('true'));
    expect(updatedLocaleVo.locale, equals('en_US'));
    expect(updatedLocaleVo.partnerBrandingId, equals('partner123'));

    updatedLocaleVo = originalLocaleVo.copyWith(generateURI: 'false');
    expect(updatedLocaleVo.generateURI, equals('false'));
  });

  group('User class', () {
    test('fromJson should create a valid User object from JSON data', () {
      final jsonData = {
        'usersessionprofile': {},
      };

      final user = User.fromJson(jsonData);

      expect(user.usersessionprofile, isNotNull);
    });

    test('parseXML should create a valid User object from XML data', () {
      final xmlData = '''
        <?xml version="1.0" encoding="UTF-8"?>
        <root>
          <!-- Add your XML data here -->
        </root>
      ''';

      final user = User.parseXML(xmlData);

      expect(user.usersessionprofile, null);
    });

    test('parseXML should create a valid User object from XML data APIFailureResponseVo', () {
      final xmlData = '''
        <?xml version="1.0" encoding="UTF-8"?>
        <root>
          <!-- Add your XML data here -->
        </root>
      ''';

      final user = User.parseXML(xmlData);

      expect(user.usersessionprofile, null);
    });

    test('copyWith should return a new User object with updated properties', () {
      final user = User(
        usersessionprofile: Usersessionprofile(),
      );

      final updatedUser = user.copyWith(
        usersessionprofile: Usersessionprofile(),
      );

      expect(updatedUser.usersessionprofile, isNotNull);
    });

    test('getters and setters should work as expected', () {
      final user = User(
        usersessionprofile: Usersessionprofile(),
      );

      expect(user.loginTimeStamp, isNull);
      expect(user.baseUrl, isNull);
      expect(user.usersessionprofile, isNotNull);

      user.baseUrl = 'https://example.com';
      expect(user.baseUrl, 'https://example.com');
    });
  });

  group('Usersessionprofile class', () {
    test('getters and setters should work as expected', () {
      final usersessionprofile = Usersessionprofile();

      expect(usersessionprofile.isJSessionIdUpdated, isNull);
      expect(usersessionprofile.tpdOrgID, isNull);
      expect(usersessionprofile.proxyOrgID, isNull);

      expect(usersessionprofile.isJSessionIdUpdated, isNull);
    });
  });

  test('Usersessionprofile constructor and fromJson should work correctly', () {
    final Map<String, dynamic> sampleJson = {
      "isJSessionIdUpdated": "true",
      "tpdOrgID": "org123",
    };

    var usersessionprofile = Usersessionprofile(
      isJSessionIdUpdated: "true",
      tpdOrgID: "org123",
    );

    var usersessionprofileFromJson = Usersessionprofile.fromJson(sampleJson);

    expect(usersessionprofile.isJSessionIdUpdated, usersessionprofileFromJson.isJSessionIdUpdated);
    expect(usersessionprofile.tpdOrgID, usersessionprofileFromJson.tpdOrgID);

    expect(usersessionprofile.userAccessibleDCIds, null);

    expect(usersessionprofile.loginType, 1);
    expect(usersessionprofile.userCloud, "1");
    expect(usersessionprofileFromJson.loginType, 1);
    expect(usersessionprofileFromJson.userCloud, "1");
  });

  test('isAgreedToTermsAndCondition setter sets the value correctly', () {
    var userProfile = Usersessionprofile();

    userProfile.isAgreedToTermsAndCondition = "true";

    expect(userProfile.isAgreedToTermsAndCondition, "true");
  });

  test('copyWith creates a new instance with updated values', () {
    var userProfile = Usersessionprofile(
      isJSessionIdUpdated: "initialValue",
      tpdOrgID: "initialValue",
      proxyOrgID: "initialValue",
    );

    var updatedProfile = userProfile.copyWith(
      isJSessionIdUpdated: "newValue",
      tpdOrgID: "newValue",
      proxyOrgID: "newValue",
    );

    expect(updatedProfile.isJSessionIdUpdated, "newValue");
    expect(updatedProfile.tpdOrgID, "newValue");
    expect(updatedProfile.proxyOrgID, "newValue");

    expect(userProfile.isJSessionIdUpdated, "initialValue");
    expect(userProfile.tpdOrgID, "initialValue");
    expect(userProfile.proxyOrgID, "initialValue");
  });

  test('copyWith creates a new instance with updated values', () {
    var userProfile = Usersessionprofile(
      isJSessionIdUpdated: "initialValue",
      tpdOrgID: "initialValue",
      proxyOrgID: "initialValue",
    );

    var updatedProfile = userProfile.copyWith(
      isJSessionIdUpdated: "newValue",
      tpdOrgID: "newValue",
      proxyOrgID: "newValue",
    );

    expect(updatedProfile.isJSessionIdUpdated, "newValue");
    expect(updatedProfile.tpdOrgID, "newValue");
    expect(updatedProfile.proxyOrgID, "newValue");

    expect(userProfile.isJSessionIdUpdated, "initialValue");
    expect(userProfile.tpdOrgID, "initialValue");
    expect(userProfile.proxyOrgID, "initialValue");
  });

  test('subscriptionPlanId getter returns correct value', () {
    var userProfile = Usersessionprofile(
      subscriptionPlanId: "exampleSubscriptionPlanId",
    );

    expect(userProfile.subscriptionPlanId, "exampleSubscriptionPlanId");

    userProfile = Usersessionprofile(
      isJSessionIdUpdated: "isJSessionIdUpdated",
    );

    expect(userProfile.isJSessionIdUpdated, "isJSessionIdUpdated");

    userProfile = Usersessionprofile(
      tpdOrgID: "tpdOrgID",
    );

    expect(userProfile.tpdOrgID, "tpdOrgID");
    userProfile = Usersessionprofile(
      proxyOrgID: "proxyOrgID",
    );

    expect(userProfile.proxyOrgID, "proxyOrgID");
  });

  test('isPasswordReset getter returns correct value', () {
    var userProfile = Usersessionprofile(
      isPasswordReset: "exampleIsPasswordReset",
    );

    expect(userProfile.isPasswordReset, "exampleIsPasswordReset");
  });

  test('screenName getter returns correct value', () {
    var userProfile = Usersessionprofile(
      screenName: "exampleScreenName",
    );

    expect(userProfile.screenName, "exampleScreenName");
  });

  test('isActive getter returns correct value', () {
    var userProfile = Usersessionprofile(
      isActive: "exampleIsActive",
    );

    expect(userProfile.isActive, "exampleIsActive");
  });

  test('userID getter returns correct value', () {
    var userProfile = Usersessionprofile(
      userID: "exampleUserID",
    );

    expect(userProfile.userID, "exampleUserID");
  });

  test('tpdUserName getter returns correct value', () {
    var userProfile = Usersessionprofile(
      tpdUserName: "exampleTPDUserName",
    );

    expect(userProfile.tpdUserName, "exampleTPDUserName");
  });

  test('proxyOrgName getter returns correct value', () {
    var userProfile = Usersessionprofile(
      proxyOrgName: "exampleProxyOrgName",
      tpdOrgName: "exampleProxyOrgName",
      proxyUserId: "exampleProxyOrgName",
      secondaryAuth: "exampleProxyOrgName",
      sessionTimeoutDuration: "exampleProxyOrgName",
      tpdUserID: "exampleProxyOrgName",
      currentJSessionID: "exampleProxyOrgName",
      orgID: "exampleProxyOrgName",
      isProxyUserWorking: "exampleProxyOrgName",
    );

    expect(userProfile.proxyOrgName, "exampleProxyOrgName");
    expect(userProfile.tpdOrgName, "exampleProxyOrgName");
    expect(userProfile.proxyUserId, "exampleProxyOrgName");
    expect(userProfile.secondaryAuth, "exampleProxyOrgName");
    expect(userProfile.sessionTimeoutDuration, "exampleProxyOrgName");
    expect(userProfile.tpdOrgID, null);
    expect(userProfile.currentJSessionID, "exampleProxyOrgName");
    expect(userProfile.orgId, null);
    expect(userProfile.isProxyUserWorking, "exampleProxyOrgName");
  });

  test('languageId setter updates the value correctly', () {
    var userProfile = Usersessionprofile(
      languageId: "initialValue",
    );

    userProfile.languageId = "newValue";

    expect(userProfile.languageId, "newValue");
  });

  test('dateFormatforLanguage setter updates the value correctly', () {
    var userProfile = Usersessionprofile(
      dateFormatforLanguage: "initialValue",
    );

    userProfile.dateFormatforLanguage = "newValue";

    expect(userProfile.dateFormatforLanguage, "newValue");
  });

  test('toJson method returns the correct JSON map', () {
    // Create an instance of Usersessionprofile with specific values
    var userProfile = Usersessionprofile(isJSessionIdUpdated: "updated", tpdOrgID: "orgId123", proxyOrgID: "proxyOrgId456", subscriptionPlanId: "plan123", isPasswordReset: "reset", screenName: "JohnDoe", isActive: "true");

    // Expected JSON map with the same specific values
    var expectedJson = {
      "isJSessionIdUpdated": "updated",
      "tpdOrgID": "orgId123",
      "proxyOrgID": "proxyOrgId456",
      "subscriptionPlanId": "plan123",
      "isPasswordReset": "reset",
      "screenName": "JohnDoe",
      "isActive": "true",
      'userAccessibleDCIds': null,
      'userID': null,
      'tpdUserName': null,
      'proxyOrgName': null,
      'tpdOrgName': null,
      'proxy_user_id': null,
      'secondaryAuth': null,
      'sessionTimeoutDuration': null,
      'currentJSessionID': null,
      'tpdUserID': null,
      'isProxyUserWorking': null,
      'orgID': null,
      'dateFormatforLanguage': null,
      'firstName': null,
      'secondaryEmailAddress': null,
      'user_id': null,
      'org_id': null,
      'hUserID': null,
      'userTypeId': null,
      'lastName': null,
      'isAgreedToTermsAndCondition': null,
      'isShowAnnouncements': null,
      'userSessionState': null,
      'loginMethodType': null,
      'lastLoginDate': null,
      'eGRNTimeoutDuration': null,
      'userImageName': null,
      'isMDMDeactivatedUser': null,
      'proxyUserName': null,
      'email': null,
      'isLoadWidgetAdoddle': null,
      'orgVisibility': null,
      'enableSecondaryEmail': null,
      'proxyDemoOrganization': null,
      'lastAccessTime': null,
      'isFreeTrialUser': null,
      'languageId': null,
      'proxyUserID': null,
      'userSubscriptionId': null,
      'demoOrganization': null,
      'canAccessAPI': null,
      'generateURI': null,
      'billToOrg': null,
      'aSessionId': null,
      'isMultiSessionAllowed': null,
      'timezoneId': null,
      'orgDCId': null,
      'userAccountType': null,
      'proxy_org_id': null,
      'userCloud': '1',
      'loginType': 1
    };

    // Get the JSON map using the toJson method
    var jsonMap = userProfile.toJson();

    // Verify that the resulting JSON map matches the expected output
    expect(jsonMap, expectedJson);
  });

  test('get methods return correct values Timezone', () {
    var userProfile = Timezone(
      rawOffset: "UTC+05:30",
      rawOffsetDiff: "UTC+06:00",
      checksum: "abc123",
      id: "user123",
      transitions: ["transition1", "transition2", "transition3"],
      willGMTOffsetChange: "true",
    );

    expect(userProfile.rawOffset, "UTC+05:30");
    expect(userProfile.rawOffsetDiff, "UTC+06:00");
    expect(userProfile.checksum, "abc123");
    expect(userProfile.id, "user123");
    expect(userProfile.transitions, ["transition1", "transition2", "transition3"]);
    expect(userProfile.willGMTOffsetChange, "true");
  });

  test('Properties should have correct initial values', () {
    // Initialize UserSettings with some values for the properties
    final userSettings = Usersessionprofile(
      isShowAnnouncements: 'true',
      userSessionState: 'active',
      loginMethodType: 'email',
      lastLoginDate: '2023-08-01',
      eGRNTimeoutDuration: '60',
      userImageName: 'user_image.jpg',
      isMDMDeactivatedUser: 'false',
      proxyUserName: 'proxy_user',
      localeVO: LocaleVo(
        editionId: '12345',
        timezone: Timezone(
          dstSavings: '1 hour',
          offsets: ['-08:00', '-07:00'],
        ),
        generateURI: 'true',
        locale: 'en_US',
        partnerBrandingId: 'partner123',
      ),
      email: 'user@example.com',
      isLoadWidgetAdoddle: 'true',
      orgVisibility: 'public',
      enableSecondaryEmail: 'true',
      proxyDemoOrganization: 'demo_org',
      lastAccessTime: '2023-08-01T12:34:56',
      isFreeTrialUser: 'true',
    );

    expect(userSettings.isShowAnnouncements, 'true');
    expect(userSettings.userSessionState, 'active');
    expect(userSettings.loginMethodType, 'email');
    expect(userSettings.lastLoginDate, '2023-08-01');
    expect(userSettings.eGRNTimeoutDuration, '60');
    expect(userSettings.userImageName, 'user_image.jpg');
    expect(userSettings.isMDMDeactivatedUser, 'false');
    expect(userSettings.proxyUserName, 'proxy_user');
    expect(userSettings.localeVO, isA<LocaleVo>());
    expect(userSettings.email, 'user@example.com');
    expect(userSettings.isLoadWidgetAdoddle, 'true');
    expect(userSettings.orgVisibility, 'public');
    expect(userSettings.enableSecondaryEmail, 'true');
    expect(userSettings.proxyDemoOrganization, 'demo_org');
    expect(userSettings.lastAccessTime, '2023-08-01T12:34:56');
    expect(userSettings.isFreeTrialUser, 'true');
  });

  test('Properties should have correct initial values', () {
    final userDetails = Usersessionprofile(proxyUserID: 'proxy_user_id', userSubscriptionId: 'subscription_id', demoOrganization: 'demo_org', canAccessAPI: 'true', generateURI: 'false', billToOrg: 'bill_org', aSessionId: 'session_id', isMultiSessionAllowed: 'true', timezoneId: 'timezone_id', orgDCId: 'org_dc_id', userAccountType: 'user_account_type', proxyOrgId: 'proxy_org_id', tpdUserID: 'tpd_user_id', isProxyUserWorking: 'true', orgID: 'org_id', dateFormatforLanguage: 'dd/MM/yyyy', firstName: 'John', secondaryEmailAddress: 'john.doe@example.com', userId: 'user_id', orgId: 'org_id', hUserID: 'h_user_id', userTypeId: 'user_type_id', lastName: 'Doe');

    expect(userDetails.proxyUserID, 'proxy_user_id');
    expect(userDetails.userSubscriptionId, 'subscription_id');
    expect(userDetails.demoOrganization, 'demo_org');
    expect(userDetails.canAccessAPI, 'true');
    expect(userDetails.generateURI, 'false');
    expect(userDetails.billToOrg, 'bill_org');
    expect(userDetails.aSessionId, 'session_id');
    expect(userDetails.isMultiSessionAllowed, 'true');
    expect(userDetails.timezoneId, 'timezone_id');
    expect(userDetails.orgDCId, 'org_dc_id');
    expect(userDetails.userAccountType, 'user_account_type');
    expect(userDetails.proxyOrgId, 'proxy_org_id');
    expect(userDetails.tpdUserID, 'tpd_user_id');
    expect(userDetails.isProxyUserWorking, 'true');
    expect(userDetails.orgID, 'org_id');
    expect(userDetails.dateFormatforLanguage, 'dd/MM/yyyy');
    expect(userDetails.firstName, 'John');
    expect(userDetails.secondaryEmailAddress, 'john.doe@example.com');
    expect(userDetails.userId, 'user_id');
    expect(userDetails.orgId, 'org_id');
    expect(userDetails.hUserID, 'h_user_id');
    expect(userDetails.userTypeId, 'user_type_id');
    expect(userDetails.lastName, 'Doe');
  });

  test('userCloud setter should set the correct value', () {
    final userSettings = Usersessionprofile();

    userSettings.userCloud = 'cloud_value';

    expect(userSettings.userCloud, 'cloud_value');
  });

  test('loginType getter and setter should work correctly', () {
    final userSettings = Usersessionprofile();

    // Getter should return the initial value
    expect(userSettings.loginType, 1);

    // Setter should update the value
    userSettings.loginType = 1;
    expect(userSettings.loginType, 1);

    // Setter should update the value again
    userSettings.loginType = 2;
    expect(userSettings.loginType, 2);
  });

  test('currentJSessionID setter should set the correct value', () {
    final userSettings = Usersessionprofile();

    userSettings.currentJSessionID = 'session_id';

    expect(userSettings.currentJSessionID, 'session_id');
  });
}
