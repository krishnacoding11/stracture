import 'dart:convert';
import 'package:field/data/model/get_user_with_subscription_vo.dart';
import 'package:field/data/model/offline_activity_vo.dart';
import 'package:test/test.dart';

void main() {
  test('fromJson should convert JSON map to OfflineActivityVo object', () {
    final jsonString = '{"user_id": 808581, "user_name": "Mayur Raval (5372)", "org_id": 3, "org_name": "Asite Solutions", "subscription_id": 1, "subscriptionName": "Key Enterprise", "start_date": "20-oct-2015", "is_active_user": true, "never_exp": true, "userEmail": "mayurraval@asite.com", "create_workspace": false, "user_type_id": 0, "login_user_id": 0, "login_user_org_id": 0, "billToOrgId": 3, "billToOrgName": "Asite Solutions", "userAppRoleId": 2177299, "emailNotification": true, "subscriptionPlanId": 5, "contractNumber": "", "fName": "Mayur", "lName": "Raval (5372)", "mName": "", "prefixId": 11015, "suffixId": 0, "redirectViewId": 2, "languageId": "es_ES", "enableAutoAcceptance": true, "marketingPref": false, "jobTitle": "TL", "isNeverExpiresChanged": false, "comments": "", "timeZoneId": "Asia/Calcutta", "greeting": "", "chkSendLoginCredential": false, "enableSecondaryEmail": false, "secondaryEmailAddress": "", "dateFormatforLanguage": "dd-MMM-yyyy", "generateURI": true}';
    // final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final getUserWithSubscription = GetUserWithSubscriptionVo.fromJson(jsonString);

    expect(getUserWithSubscription.userId, equals(808581));
    expect(getUserWithSubscription.userName, equals("Mayur Raval (5372)"));
    expect(getUserWithSubscription.orgId, equals(3));
    expect(getUserWithSubscription.orgName, equals("Asite Solutions"));
    expect(getUserWithSubscription.subscriptionId, equals(1));
    expect(getUserWithSubscription.subscriptionName, equals("Key Enterprise"));
    expect(getUserWithSubscription.startDate, equals("20-oct-2015"));
    expect(getUserWithSubscription.isActiveUser, equals(true));
    expect(getUserWithSubscription.neverExp, equals(true));
    expect(getUserWithSubscription.userEmail, equals("mayurraval@asite.com"));
    expect(getUserWithSubscription.createWorkspace, equals(false));
    expect(getUserWithSubscription.userTypeId, equals(0));
    expect(getUserWithSubscription.loginUserId, equals(0));
    expect(getUserWithSubscription.loginUserOrgId, equals(0));
    expect(getUserWithSubscription.billToOrgId, equals(3));
    expect(getUserWithSubscription.billToOrgName, equals("Asite Solutions"));
    expect(getUserWithSubscription.userAppRoleId, equals(2177299));
    expect(getUserWithSubscription.emailNotification, equals(true));
    expect(getUserWithSubscription.subscriptionPlanId, equals(5));
    expect(getUserWithSubscription.contractNumber, equals(""));
    expect(getUserWithSubscription.fName, equals("Mayur"));
    expect(getUserWithSubscription.lName, equals("Raval (5372)"));
    expect(getUserWithSubscription.mName, equals(""));
    expect(getUserWithSubscription.prefixId, equals(11015));
    expect(getUserWithSubscription.suffixId, equals(0));
    expect(getUserWithSubscription.redirectViewId, equals(2));
    expect(getUserWithSubscription.languageId, equals("es_ES"));
    expect(getUserWithSubscription.enableAutoAcceptance, equals(true));
    expect(getUserWithSubscription.marketingPref, equals(false));
    expect(getUserWithSubscription.jobTitle, equals("TL"));
    expect(getUserWithSubscription.isNeverExpiresChanged, equals(false));
    expect(getUserWithSubscription.comments, equals(""));
    expect(getUserWithSubscription.timeZoneId, equals("Asia/Calcutta"));
    expect(getUserWithSubscription.greeting, equals(""));
    expect(getUserWithSubscription.chkSendLoginCredential, equals(false));
    expect(getUserWithSubscription.enableSecondaryEmail, equals(false));
    expect(getUserWithSubscription.secondaryEmailAddress, equals(""));
    expect(getUserWithSubscription.dateFormatforLanguage, equals("dd-MMM-yyyy"));
    expect(getUserWithSubscription.generateURI, equals(true));
  });

  test('toJson should convert getUserWithSubscription object to JSON map', () {
    final getUserWithSubscription = GetUserWithSubscriptionVo(
      userId: 808581,
      userName: "Mayur Raval (5372)",
      orgId: 3,
      orgName: "Asite Solutions",
      subscriptionId: 1,
      subscriptionName: "Key Enterprise",
      startDate: "20-oct-2015",
      isActiveUser: true,
      neverExp: true,
      userEmail: "mayurraval@asite.com",
      createWorkspace: false,
      userTypeId: 0,
      loginUserId: 0,
      loginUserOrgId: 0,
      billToOrgId: 3,
      billToOrgName: "Asite Solutions",
      userAppRoleId: 2177299,
      emailNotification: true,
      subscriptionPlanId: 5,
      contractNumber: "",
      fName: "Mayur",
      lName: "Raval (5372)",
      mName: "",
      prefixId: 11015,
      suffixId: 0,
      redirectViewId: 2,
      languageId: "es_ES",
      enableAutoAcceptance: true,
      marketingPref: false,
      jobTitle: "TL",
      isNeverExpiresChanged: false,
      comments: "",
      timeZoneId: "Asia/Calcutta",
      greeting: "",
      chkSendLoginCredential: false,
      enableSecondaryEmail: false,
      secondaryEmailAddress: "",
      dateFormatforLanguage: "dd-MMM-yyyy",
      generateURI: true,
    );

    final jsonMap = getUserWithSubscription.toJson();

    expect(jsonMap['user_id'], equals(808581));
    expect(jsonMap['user_name'], equals("Mayur Raval (5372)"));
    expect(jsonMap['org_id'], equals(3));
    expect(jsonMap['org_name'], equals("Asite Solutions"));
    expect(jsonMap['subscription_id'], equals(1));
    expect(jsonMap['subscriptionName'], equals("Key Enterprise"));
    expect(jsonMap['start_date'], equals("20-oct-2015"));
    expect(jsonMap['is_active_user'], equals(true));
    expect(jsonMap['never_exp'], equals(true));
    expect(jsonMap['userEmail'], equals("mayurraval@asite.com"));
    expect(jsonMap['create_workspace'], equals(false));
    expect(jsonMap['user_type_id'], equals(0));
    expect(jsonMap['login_user_id'], equals(0));
    expect(jsonMap['login_user_org_id'], equals(0));
    expect(jsonMap['billToOrgId'], equals(3));
    expect(jsonMap['billToOrgName'], equals("Asite Solutions"));
    expect(jsonMap['userAppRoleId'], equals(2177299));
    expect(jsonMap['emailNotification'], equals(true));
    expect(jsonMap['subscriptionPlanId'], equals(5));
    expect(jsonMap['contractNumber'], equals(""));
    expect(jsonMap['fName'], equals("Mayur"));
    expect(jsonMap['lName'], equals("Raval (5372)"));
    expect(jsonMap['mName'], equals(""));
    expect(jsonMap['prefixId'], equals(11015));
    expect(jsonMap['suffixId'], equals(0));
    expect(jsonMap['redirectViewId'], equals(2));
    expect(jsonMap['languageId'], equals("es_ES"));
    expect(jsonMap['enableAutoAcceptance'], equals(true));
    expect(jsonMap['marketingPref'], equals(false));
    expect(jsonMap['jobTitle'], equals("TL"));
    expect(jsonMap['isNeverExpiresChanged'], equals(false));
    expect(jsonMap['comments'], equals(""));
    expect(jsonMap['timeZoneId'], equals("Asia/Calcutta"));
    expect(jsonMap['greeting'], equals(""));
    expect(jsonMap['chkSendLoginCredential'], equals(false));
    expect(jsonMap['enableSecondaryEmail'], equals(false));
    expect(jsonMap['secondaryEmailAddress'], equals(""));
    expect(jsonMap['dateFormatforLanguage'], equals("dd-MMM-yyyy"));
    expect(jsonMap['generateURI'], equals(true));
  });


  test('toJson should convert getUserWithSubscription object to copyWith map', () {
    final getUserWithSubscription = GetUserWithSubscriptionVo(
      userId: 808581,
      userName: "Mayur Raval (5372)",
      orgId: 3,
      orgName: "Asite Solutions",
      subscriptionId: 1,
      subscriptionName: "Key Enterprise",
      startDate: "20-oct-2015",
      isActiveUser: true,
      neverExp: true,
      userEmail: "mayurraval@asite.com",
      createWorkspace: false,
      userTypeId: 0,
      loginUserId: 0,
      loginUserOrgId: 0,
      billToOrgId: 3,
      billToOrgName: "Asite Solutions",
      userAppRoleId: 2177299,
      emailNotification: true,
      subscriptionPlanId: 5,
      contractNumber: "",
      fName: "Mayur",
      lName: "Raval (5372)",
      mName: "",
      prefixId: 11015,
      suffixId: 0,
      redirectViewId: 2,
      languageId: "es_ES",
      enableAutoAcceptance: true,
      marketingPref: false,
      jobTitle: "TL",
      isNeverExpiresChanged: false,
      comments: "",
      timeZoneId: "Asia/Calcutta",
      greeting: "",
      chkSendLoginCredential: false,
      enableSecondaryEmail: false,
      secondaryEmailAddress: "",
      dateFormatforLanguage: "dd-MMM-yyyy",
      generateURI: true,
    );

    final updated = getUserWithSubscription.copyWith();

    expect(updated.userId, equals(808581));
    expect(updated.userName, equals("Mayur Raval (5372)"));
    expect(updated.orgId, equals(3));
    expect(updated.orgName, equals("Asite Solutions"));
    expect(updated.subscriptionId, equals(1));
    expect(updated.subscriptionName, equals("Key Enterprise"));
    expect(updated.startDate, equals("20-oct-2015"));
    expect(updated.isActiveUser, equals(true));
    expect(updated.neverExp, equals(true));
    expect(updated.userEmail, equals("mayurraval@asite.com"));
    expect(updated.createWorkspace, equals(false));
    expect(updated.userTypeId, equals(0));
    expect(updated.loginUserId, equals(0));
    expect(updated.loginUserOrgId, equals(0));
    expect(updated.billToOrgId, equals(3));
    expect(updated.billToOrgName, equals("Asite Solutions"));
    expect(updated.userAppRoleId, equals(2177299));
    expect(updated.emailNotification, equals(true));
    expect(updated.subscriptionPlanId, equals(5));
    expect(updated.contractNumber, equals(""));
    expect(updated.fName, equals("Mayur"));
    expect(updated.lName, equals("Raval (5372)"));
    expect(updated.mName, equals(""));
    expect(updated.prefixId, equals(11015));
    expect(updated.suffixId, equals(0));
    expect(updated.redirectViewId, equals(2));
    expect(updated.languageId, equals("es_ES"));
    expect(updated.enableAutoAcceptance, equals(true));
    expect(updated.marketingPref, equals(false));
    expect(updated.jobTitle, equals("TL"));
    expect(updated.isNeverExpiresChanged, equals(false));
    expect(updated.comments, equals(""));
    expect(updated.timeZoneId, equals("Asia/Calcutta"));
    expect(updated.greeting, equals(""));
    expect(updated.chkSendLoginCredential, equals(false));
    expect(updated.enableSecondaryEmail, equals(false));
    expect(updated.secondaryEmailAddress, equals(""));
    expect(updated.dateFormatforLanguage, equals("dd-MMM-yyyy"));
    expect(updated.generateURI, equals(true));
  });
}
