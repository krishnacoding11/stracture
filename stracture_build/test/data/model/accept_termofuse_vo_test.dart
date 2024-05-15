import 'dart:convert';

import 'package:field/data/model/accept_termofuse_vo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  late AcceptTermofuseVo acceptTermofuseVo;

  setUp(() async {
    dynamic data = fixture("accept_termofuse_success.json");
    acceptTermofuseVo = AcceptTermofuseVo.fromJson(data);
  });

  group("test AcceptTermofuseVo", () {
    test("test with copyWith expected AcceptTermofuseVo", () async {
      AcceptTermofuseVo acceptTermofuseVoCopy = acceptTermofuseVo.copyWith();
      expect(acceptTermofuseVoCopy, isA<AcceptTermofuseVo>());
    });

    test("test with toJson expected map with exact key and data", () async {
      Map<String, dynamic> map = acceptTermofuseVo.toJson();
      AcceptTermofuseVo result = AcceptTermofuseVo.fromJson(jsonEncode(map));
      expect(result.passwordModifiedDate, map["passwordModifiedDate"]);
    });

    test("test with getter function", () async {
      expect(acceptTermofuseVo.passwordModifiedDate, "1663939068547");
      expect(acceptTermofuseVo.openId, "");
      expect(acceptTermofuseVo.graceLoginCount, 0);
      expect(acceptTermofuseVo.greeting, "Welcome Field User1!");
      expect(acceptTermofuseVo.passwordEncrypted, true);
      expect(acceptTermofuseVo.loginDate, "1665062198827");
      expect(acceptTermofuseVo.screenName, "fielduser1");
      expect(acceptTermofuseVo.lastLoginDate, "1665061343367");
      expect(acceptTermofuseVo.uuid, "64490088-9a9e-4ef3-8fa1-7ef39af31f9f");
      expect(acceptTermofuseVo.password, "{SHA2}gsH19pgAE/FmxNcbseGwgEYgc0fxqDfvdDeyHDAsmqyjiQLHs74RPg==");
      expect(acceptTermofuseVo.emailAddress, "fielduser1@asite.com");
      expect(acceptTermofuseVo.passwordReset, false);
      expect(acceptTermofuseVo.defaultUser, false);
      expect(acceptTermofuseVo.createDate, "1662534579163");
      expect(acceptTermofuseVo.isSuccess, true);
      expect(acceptTermofuseVo.portraitId, 1955751);
      expect(acceptTermofuseVo.comments, "");
      expect(acceptTermofuseVo.contactId, 1947608);
      expect(acceptTermofuseVo.timeZoneId, "America/New_York");
      expect(acceptTermofuseVo.lastFailedLoginDate, "");
      expect(acceptTermofuseVo.languageId, "en_US");
      expect(acceptTermofuseVo.active, true);
      expect(acceptTermofuseVo.failedLoginAttempts, 0);
      expect(acceptTermofuseVo.userId, 1947607);
      expect(acceptTermofuseVo.lastLoginIP, "10.50.24.4");
      expect(acceptTermofuseVo.agreedToTermsOfUse, true);
      expect(acceptTermofuseVo.companyId, 300106);
      expect(acceptTermofuseVo.lockout, false);
      expect(acceptTermofuseVo.lockoutDate, "");
      expect(acceptTermofuseVo.loginIP, "10.50.24.4");
      expect(acceptTermofuseVo.modifiedDate, "1665062217913");
    });
  });
}
