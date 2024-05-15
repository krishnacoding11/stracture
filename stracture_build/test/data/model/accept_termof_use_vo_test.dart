import 'package:field/data/model/accept_termofuse_vo.dart';
import 'package:field/data/model/apptype_group_vo.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:test/test.dart';

void main() {
  group('AcceptTermofuseVo Tests', () {
    test('AcceptTermofuseVo.fromJson should create a AcceptTermofuseVo object from JSON', () {
      // Sample JSON data representing a FloorData object
      final json = '{"passwordModifiedDate": "1661780526723", "openId": "", "graceLoginCount": 0, "greeting": "", "passwordEncrypted": true, "loginDate": "1663320790603", "screenName": "mayurraval", "lastLoginDate": "1663320737960", "uuid": "ac70294f-c242-4d2f-a939-74d291825016", "password": "{SHA2}7xozcaPcOcQBSDp72rmLehVmuSo1dxLYbtEuSM6xVxPs0Lf6z0eLcQ==", "emailAddress": "mayurraval@asite.com", "passwordReset": false, "defaultUser": false, "createDate": "1445411848170", "isSuccess": true, "portraitId": 817294, "comments": "", "contactId": 808582, "timeZoneId": "Asia/Seoul", "lastFailedLoginDate": "", "languageId": "en_US", "active": true, "failedLoginAttempts": 0, "userId": 808581, "lastLoginIP": "10.50.24.5", "agreedToTermsOfUse": true, "companyId": 300106, "lockout": false, "lockoutDate": "", "loginIP": "10.50.24.5", "modifiedDate": "1662976953443"}';

      // Create a FloorData object from the JSON data
      final acceptTermofuseVo = AcceptTermofuseVo.fromJson(json);

      // Check if the properties are correctly set
      expect(acceptTermofuseVo.passwordModifiedDate, "1661780526723");
      expect(acceptTermofuseVo.openId, "");
      expect(acceptTermofuseVo.graceLoginCount, 0);
      expect(acceptTermofuseVo.greeting, "");
      expect(acceptTermofuseVo.passwordEncrypted, true);
      expect(acceptTermofuseVo.loginDate, "1663320790603");
      expect(acceptTermofuseVo.screenName, "mayurraval");
      expect(acceptTermofuseVo.lastLoginDate, "1663320737960");
      expect(acceptTermofuseVo.uuid, "ac70294f-c242-4d2f-a939-74d291825016");
      expect(acceptTermofuseVo.password, "{SHA2}7xozcaPcOcQBSDp72rmLehVmuSo1dxLYbtEuSM6xVxPs0Lf6z0eLcQ==");
      expect(acceptTermofuseVo.emailAddress, "mayurraval@asite.com");
      expect(acceptTermofuseVo.passwordReset, false);
      expect(acceptTermofuseVo.defaultUser, false);
      expect(acceptTermofuseVo.createDate, "1445411848170");
      expect(acceptTermofuseVo.isSuccess, true);
      expect(acceptTermofuseVo.portraitId, 817294);
      expect(acceptTermofuseVo.comments, "");
      expect(acceptTermofuseVo.contactId, 808582);
      expect(acceptTermofuseVo.timeZoneId, "Asia/Seoul");
      expect(acceptTermofuseVo.lastFailedLoginDate, "");
      expect(acceptTermofuseVo.languageId, "en_US");
      expect(acceptTermofuseVo.active, true);
      expect(acceptTermofuseVo.failedLoginAttempts, 0);
      expect(acceptTermofuseVo.userId, 808581);
      expect(acceptTermofuseVo.lastLoginIP, "10.50.24.5");
      expect(acceptTermofuseVo.agreedToTermsOfUse, true);
      expect(acceptTermofuseVo.companyId, 300106);
      expect(acceptTermofuseVo.lockout, false);
      expect(acceptTermofuseVo.lockoutDate, "");
      expect(acceptTermofuseVo.loginIP, "10.50.24.5");
      expect(acceptTermofuseVo.modifiedDate, "1662976953443");
    });

    test('AcceptTermofuseVo.toJson should convert a AppType object to JSON', () {
      // Create sample FloorDetail objects

      // Create a sample FloorData object
      final acceptTermofuseVo = AcceptTermofuseVo(
        passwordModifiedDate: "1661780526723",
        openId: "",
        graceLoginCount: 0,
        greeting: "",
        passwordEncrypted: true,
        loginDate: "1663320790603",
        screenName: "mayurraval",
        lastLoginDate: "1663320737960",
        uuid: "ac70294f-c242-4d2f-a939-74d291825016",
        password: "{SHA2}7xozcaPcOcQBSDp72rmLehVmuSo1dxLYbtEuSM6xVxPs0Lf6z0eLcQ==",
        emailAddress: "mayurraval@asite.com",
        passwordReset: false,
        defaultUser: false,
        createDate: "1445411848170",
        isSuccess: true,
        portraitId: 817294,
        comments: "",
        contactId: 808582,
        timeZoneId: "Asia/Seoul",
        lastFailedLoginDate: "",
        languageId: "en_US",
        active: true,
        failedLoginAttempts: 0,
        userId: 808581,
        lastLoginIP: "10.50.24.5",
        agreedToTermsOfUse: true,
        companyId: 300106,
        lockout: false,
        lockoutDate: "",
        loginIP: "10.50.24.5",
        modifiedDate: "1662976953443",
      );

      // Convert the FloorData object to JSON
      final json = acceptTermofuseVo.copyWith();

      expect(json.passwordModifiedDate, "1661780526723");
      expect(json.openId, "");
      expect(json.graceLoginCount, 0);
      expect(json.greeting, "");
      expect(json.passwordEncrypted, true);
      expect(json.loginDate, "1663320790603");
      expect(json.screenName, "mayurraval");
      expect(json.lastLoginDate, "1663320737960");
      expect(json.uuid, "ac70294f-c242-4d2f-a939-74d291825016");
      expect(json.password, "{SHA2}7xozcaPcOcQBSDp72rmLehVmuSo1dxLYbtEuSM6xVxPs0Lf6z0eLcQ==");
      expect(json.emailAddress, "mayurraval@asite.com");
      expect(json.passwordReset, false);
      expect(json.defaultUser, false);
      expect(json.createDate, "1445411848170");
      expect(json.isSuccess, true);
      expect(json.portraitId, 817294);
      expect(json.comments, "");
      expect(json.contactId, 808582);
      expect(json.timeZoneId, "Asia/Seoul");
      expect(json.lastFailedLoginDate, "");
      expect(json.languageId, "en_US");
      expect(json.active, true);
      expect(json.failedLoginAttempts, 0);
      expect(json.userId, 808581);
      expect(json.lastLoginIP, "10.50.24.5");
      expect(json.agreedToTermsOfUse, true);
      expect(json.companyId, 300106);
      expect(json.lockout, false);
      expect(json.lockoutDate, "");
      expect(json.loginIP, "10.50.24.5");
      expect(json.modifiedDate, "1662976953443");
    });

    test('AcceptTermofuseVo.toJson should convert a AppType object to JSON', () {
      // Create sample FloorDetail objects

      // Create a sample FloorData object
      final acceptTermofuseVo = AcceptTermofuseVo(
        passwordModifiedDate: "1661780526723",
        openId: "",
        graceLoginCount: 0,
        greeting: "",
        passwordEncrypted: true,
        loginDate: "1663320790603",
        screenName: "mayurraval",
        lastLoginDate: "1663320737960",
        uuid: "ac70294f-c242-4d2f-a939-74d291825016",
        password: "{SHA2}7xozcaPcOcQBSDp72rmLehVmuSo1dxLYbtEuSM6xVxPs0Lf6z0eLcQ==",
        emailAddress: "mayurraval@asite.com",
        passwordReset: false,
        defaultUser: false,
        createDate: "1445411848170",
        isSuccess: true,
        portraitId: 817294,
        comments: "",
        contactId: 808582,
        timeZoneId: "Asia/Seoul",
        lastFailedLoginDate: "",
        languageId: "en_US",
        active: true,
        failedLoginAttempts: 0,
        userId: 808581,
        lastLoginIP: "10.50.24.5",
        agreedToTermsOfUse: true,
        companyId: 300106,
        lockout: false,
        lockoutDate: "",
        loginIP: "10.50.24.5",
        modifiedDate: "1662976953443",
      );

      // Convert the FloorData object to JSON
      final json = acceptTermofuseVo.toJson();

      expect(json["passwordModifiedDate"], "1661780526723");
      expect(json["openId"], "");
      expect(json["graceLoginCount"], 0);
      expect(json["greeting"], "");
      expect(json["passwordEncrypted"], true);
      expect(json["loginDate"], "1663320790603");
      expect(json["screenName"], "mayurraval");
      expect(json["lastLoginDate"], "1663320737960");
      expect(json["uuid"], "ac70294f-c242-4d2f-a939-74d291825016");
      expect(json["password"], "{SHA2}7xozcaPcOcQBSDp72rmLehVmuSo1dxLYbtEuSM6xVxPs0Lf6z0eLcQ==");
      expect(json["emailAddress"], "mayurraval@asite.com");
      expect(json["passwordReset"], false);
      expect(json["defaultUser"], false);
      expect(json["createDate"], "1445411848170");
      expect(json["isSuccess"], true);
      expect(json["portraitId"], 817294);
      expect(json["comments"], "");
      expect(json["contactId"], 808582);
      expect(json["timeZoneId"], "Asia/Seoul");
      expect(json["lastFailedLoginDate"], "");
      expect(json["languageId"], "en_US");
      expect(json["active"], true);
      expect(json["failedLoginAttempts"], 0);
      expect(json["userId"], 808581);
      expect(json["lastLoginIP"], "10.50.24.5");
      expect(json["agreedToTermsOfUse"], true);
      expect(json["companyId"], 300106);
      expect(json["lockout"], false);
      expect(json["lockoutDate"], "");
      expect(json["loginIP"], "10.50.24.5");
      expect(json["modifiedDate"], "1662976953443");
    });

  });
}
