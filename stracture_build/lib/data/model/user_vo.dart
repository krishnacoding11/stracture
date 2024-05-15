import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:field/data/model/login_exception.dart';
import 'package:xml2json/xml2json.dart';

/// usersessionprofile : {"isJSessionIdUpdated":"false","tpdOrgID":"3","proxyOrgID":"3","subscriptionPlanId":"5","isPasswordReset":"false","screenName":"mayurraval","isActive":"false","userAccessibleDCIds":["1","2"],"userID":"808581","tpdUserName":"Mayur Raval (5372)","proxyOrgName":"Asite Solutions","tpdOrgName":"Asite Solutions","proxy_user_id":"H4sIAAAAAAAAANsr0/BCYk2l1i595rvOGu6zANtItUsQAAAA","secondaryAuth":"false","sessionTimeoutDuration":"-2","currentJSessionID":"J5c_70dd9FNJzGqXdXBqjBIt2BLguvAmGqI_T_mR","tpdUserID":"808581","isProxyUserWorking":"false","orgID":"3","dateFormatforLanguage":"dd-MMM-yyyy","firstName":"Mayur","secondaryEmailAddress":null,"user_id":"H4sIAAAAAAAAANsr0/BCYk2l1i595rvOGu6zANtItUsQAAAA","org_id":"H4sIAAAAAAAAALusffY2w54wS91Gi88G4l+/AQAR3Q4gEAAAAA==","hUserID":"808581$$Dx6J3L","userTypeId":"1","lastName":"Raval (5372)","isAgreedToTermsAndCondition":"true","isShowAnnouncements":"false","userSessionState":"SESSION_ACTIVE","loginMethodType":"1","lastLoginDate":"Jul 22, 2022 8:15:14 AM","eGRNTimeoutDuration":"0","userImageName":"photo_808581_thumbnail.jpg?v=1651492434000","isMDMDeactivatedUser":"false","proxyUserName":"Mayur Raval (5372)","localeVO":{"editionId":"1","_timezone":{"dstSavings":"0","offsets":["32400000","30472000","30600000","36000000","3600000","34200000"],"rawOffset":"32400000","rawOffsetDiff":"0","checksum":"-1709296987","ID":"Asia/Seoul","transitions":["-9048018124799999","-7982213005311998","-7497378201600000","-2790236159999933","-2753445888000000","-2681944473599933","-2624982220800000","-2553480806399933","-2496164659200000","-2411923046399933","-2367347097600000","-2040333926399998","-1895229849599931","-1850300006399998","-1760396083199931","-1713342873599998","-1636533043199931","-1587002572799998","-1507715481599931","-1458185011199998","-1378897919999931","-1329367449599998","-1250080358399931","-1200549887999998","-1085165568000000","2242879488000067","2297379225600000","2371697049600067","2426196787200000","8660371046400000"],"willGMTOffsetChange":"false"},"generateURI":"true","_locale":"en_GB","_partnerBrandingId":"asite"},"email":"mayurraval@asite.com","isLoadWidgetAdoddle":"false","orgVisibility":"2","enableSecondaryEmail":"false","proxyDemoOrganization":"false","lastAccessTime":"Jul 22, 2022 8:18:11 AM","isFreeTrialUser":"false","languageId":"en_GB","proxyUserID":"808581","userSubscriptionId":"1","demoOrganization":"false","canAccessAPI":"false","generateURI":"true","billToOrg":"3","aSessionId":"g48jGTR2air1X3ZAWtYmwO9bhlMB8PgE83En69VCmzU=","isMultiSessionAllowed":"true","timezoneId":"Asia/Seoul","orgDCId":"1","userAccountType":"0","proxy_org_id":"H4sIAAAAAAAAALusffY2w54wS91Gi88G4l+/AQAR3Q4gEAAAAA=="}

class User extends Equatable{
  dynamic apiResponseFailure;

  User({Usersessionprofile? usersessionprofile, dynamic apiResponseFailure}) {
    _usersessionprofile = usersessionprofile;
    apiResponseFailure = apiResponseFailure;
  }

  User.fromJson(dynamic jsonData) {
    _usersessionprofile = jsonData['usersessionprofile'] != null
        ? Usersessionprofile.fromJson(jsonData['usersessionprofile'])
        : null;
  }

  User.parseXML(dynamic response) {
    Xml2Json xml2json = Xml2Json();
    xml2json.parse(response);
    var jsonResponseData = xml2json.toParkerWithAttrs();
    dynamic responseJson = json.decode(jsonResponseData);
    // User userData = User.fromJson(responseJson);

    if (responseJson['APIFailureResponseVo'] != null) {
      apiResponseFailure = responseJson['APIFailureResponseVo'];
    } else if (responseJson['AsiteAPIExceptionThrown'] != null) {
      apiResponseFailure = AsiteApiExceptionThrown.fromJson(
          responseJson['AsiteAPIExceptionThrown']);
    } else {
      _usersessionprofile = responseJson['usersessionprofile'] != null
          ? Usersessionprofile.fromJson(responseJson['usersessionprofile'])
          : null;
      if (_usersessionprofile != null) {
        _loginTimeStamp = DateTime.now().millisecondsSinceEpoch.toString();
      }
    }
  }

  Usersessionprofile? _usersessionprofile;

  String? _loginTimeStamp;
  String? _baseUrl;
  String? userImageUrl;

  set baseUrl(String? value) {
    _baseUrl = value;
  }

  User copyWith({
    Usersessionprofile? usersessionprofile,
  }) =>
      User(
        usersessionprofile: usersessionprofile ?? _usersessionprofile,
      );

  String? get loginTimeStamp => _loginTimeStamp;
  String? get baseUrl => _baseUrl ;
  set setBaseUrl(String? url) => _baseUrl = url;

  Usersessionprofile? get usersessionprofile => _usersessionprofile;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_usersessionprofile != null) {
      map['usersessionprofile'] = _usersessionprofile?.toJson();
    }
    return map;
  }
  
  @override
  List<Object?> get props => [];
}

/// isJSessionIdUpdated : "false"
/// tpdOrgID : "3"
/// proxyOrgID : "3"
/// subscriptionPlanId : "5"
/// isPasswordReset : "false"
/// screenName : "mayurraval"
/// isActive : "false"
/// userAccessibleDCIds : ["1","2"]
/// userID : "808581"
/// tpdUserName : "Mayur Raval (5372)"
/// proxyOrgName : "Asite Solutions"
/// tpdOrgName : "Asite Solutions"
/// proxy_user_id : "H4sIAAAAAAAAANsr0/BCYk2l1i595rvOGu6zANtItUsQAAAA"
/// secondaryAuth : "false"
/// sessionTimeoutDuration : "-2"
/// currentJSessionID : "J5c_70dd9FNJzGqXdXBqjBIt2BLguvAmGqI_T_mR"
/// tpdUserID : "808581"
/// isProxyUserWorking : "false"
/// orgID : "3"
/// dateFormatforLanguage : "dd-MMM-yyyy"
/// firstName : "Mayur"
/// secondaryEmailAddress : null
/// user_id : "H4sIAAAAAAAAANsr0/BCYk2l1i595rvOGu6zANtItUsQAAAA"
/// org_id : "H4sIAAAAAAAAALusffY2w54wS91Gi88G4l+/AQAR3Q4gEAAAAA=="
/// hUserID : "808581$$Dx6J3L"
/// userTypeId : "1"
/// lastName : "Raval (5372)"
/// isAgreedToTermsAndCondition : "true"
/// isShowAnnouncements : "false"
/// userSessionState : "SESSION_ACTIVE"
/// loginMethodType : "1"
/// lastLoginDate : "Jul 22, 2022 8:15:14 AM"
/// eGRNTimeoutDuration : "0"
/// userImageName : "photo_808581_thumbnail.jpg?v=1651492434000"
/// isMDMDeactivatedUser : "false"
/// proxyUserName : "Mayur Raval (5372)"
/// localeVO : {"editionId":"1","_timezone":{"dstSavings":"0","offsets":["32400000","30472000","30600000","36000000","3600000","34200000"],"rawOffset":"32400000","rawOffsetDiff":"0","checksum":"-1709296987","ID":"Asia/Seoul","transitions":["-9048018124799999","-7982213005311998","-7497378201600000","-2790236159999933","-2753445888000000","-2681944473599933","-2624982220800000","-2553480806399933","-2496164659200000","-2411923046399933","-2367347097600000","-2040333926399998","-1895229849599931","-1850300006399998","-1760396083199931","-1713342873599998","-1636533043199931","-1587002572799998","-1507715481599931","-1458185011199998","-1378897919999931","-1329367449599998","-1250080358399931","-1200549887999998","-1085165568000000","2242879488000067","2297379225600000","2371697049600067","2426196787200000","8660371046400000"],"willGMTOffsetChange":"false"},"generateURI":"true","_locale":"en_GB","_partnerBrandingId":"asite"}
/// email : "mayurraval@asite.com"
/// isLoadWidgetAdoddle : "false"
/// orgVisibility : "2"
/// enableSecondaryEmail : "false"
/// proxyDemoOrganization : "false"
/// lastAccessTime : "Jul 22, 2022 8:18:11 AM"
/// isFreeTrialUser : "false"
/// languageId : "en_GB"
/// proxyUserID : "808581"
/// userSubscriptionId : "1"
/// demoOrganization : "false"
/// canAccessAPI : "false"
/// generateURI : "true"
/// billToOrg : "3"
/// aSessionId : "g48jGTR2air1X3ZAWtYmwO9bhlMB8PgE83En69VCmzU="
/// isMultiSessionAllowed : "true"
/// timezoneId : "Asia/Seoul"
/// orgDCId : "1"
/// userAccountType : "0"
/// proxy_org_id : "H4sIAAAAAAAAALusffY2w54wS91Gi88G4l+/AQAR3Q4gEAAAAA=="

class Usersessionprofile {

  Usersessionprofile({
    String? isJSessionIdUpdated,
    String? tpdOrgID,
    String? proxyOrgID,
    String? subscriptionPlanId,
    String? isPasswordReset,
    String? screenName,
    String? isActive,
    dynamic userAccessibleDCIds,
    String? userID,
    String? tpdUserName,
    String? proxyOrgName,
    String? tpdOrgName,
    String? proxyUserId,
    String? secondaryAuth,
    String? sessionTimeoutDuration,
    String? currentJSessionID,
    String? tpdUserID,
    String? isProxyUserWorking,
    String? orgID,
    String? dateFormatforLanguage,
    String? firstName,
    dynamic secondaryEmailAddress,
    String? userId,
    String? orgId,
    String? hUserID,
    String? userTypeId,
    String? lastName,
    String? isAgreedToTermsAndCondition,
    String? isShowAnnouncements,
    String? userSessionState,
    String? loginMethodType,
    String? lastLoginDate,
    String? eGRNTimeoutDuration,
    String? userImageName,
    String? isMDMDeactivatedUser,
    String? proxyUserName,
    LocaleVo? localeVO,
    String? email,
    String? isLoadWidgetAdoddle,
    String? orgVisibility,
    String? enableSecondaryEmail,
    String? proxyDemoOrganization,
    String? lastAccessTime,
    String? isFreeTrialUser,
    String? languageId,
    String? proxyUserID,
    String? userSubscriptionId,
    String? demoOrganization,
    String? canAccessAPI,
    String? generateURI,
    String? billToOrg,
    String? aSessionId,
    String? isMultiSessionAllowed,
    String? timezoneId,
    String? orgDCId,
    String? userAccountType,
    String? proxyOrgId,
    int loginType = 1,
    String? userCloud = "1",
  }) {
    _isJSessionIdUpdated = isJSessionIdUpdated;
    _tpdOrgID = tpdOrgID;
    _proxyOrgID = proxyOrgID;
    _subscriptionPlanId = subscriptionPlanId;
    _isPasswordReset = isPasswordReset;
    _screenName = screenName;
    _isActive = isActive;
    _userAccessibleDCIds = userAccessibleDCIds;
    _userID = userID;
    _tpdUserName = tpdUserName;
    _proxyOrgName = proxyOrgName;
    _tpdOrgName = tpdOrgName;
    _proxyUserId = proxyUserId;
    _secondaryAuth = secondaryAuth;
    _sessionTimeoutDuration = sessionTimeoutDuration;
    _currentJSessionID = currentJSessionID;
    _tpdUserID = tpdUserID;
    _isProxyUserWorking = isProxyUserWorking;
    _orgID = orgID;
    _dateFormatforLanguage = dateFormatforLanguage;
    _firstName = firstName;
    _secondaryEmailAddress = secondaryEmailAddress;
    _userId = userId;
    _orgId = orgId;
    _hUserID = hUserID;
    _userTypeId = userTypeId;
    _lastName = lastName;
    _isAgreedToTermsAndCondition = isAgreedToTermsAndCondition;
    _isShowAnnouncements = isShowAnnouncements;
    _userSessionState = userSessionState;
    _loginMethodType = loginMethodType;
    _lastLoginDate = lastLoginDate;
    _eGRNTimeoutDuration = eGRNTimeoutDuration;
    _userImageName = userImageName;
    _isMDMDeactivatedUser = isMDMDeactivatedUser;
    _proxyUserName = proxyUserName;
    _localeVO = localeVO;
    _email = email;
    _isLoadWidgetAdoddle = isLoadWidgetAdoddle;
    _orgVisibility = orgVisibility;
    _enableSecondaryEmail = enableSecondaryEmail;
    _proxyDemoOrganization = proxyDemoOrganization;
    _lastAccessTime = lastAccessTime;
    _isFreeTrialUser = isFreeTrialUser;
    _languageId = languageId;
    _proxyUserID = proxyUserID;
    _userSubscriptionId = userSubscriptionId;
    _demoOrganization = demoOrganization;
    _canAccessAPI = canAccessAPI;
    _generateURI = generateURI;
    _billToOrg = billToOrg;
    _aSessionId = aSessionId;
    _isMultiSessionAllowed = isMultiSessionAllowed;
    _timezoneId = timezoneId;
    _orgDCId = orgDCId;
    _userAccountType = userAccountType;
    _proxyOrgId = proxyOrgId;
    _loginType = loginType;
    _userCloud = userCloud;
  }

  Usersessionprofile.fromJson(dynamic json) {
    _isJSessionIdUpdated = json['isJSessionIdUpdated'];
    _tpdOrgID = json['tpdOrgID'];
    _proxyOrgID = json['proxyOrgID'];
    _subscriptionPlanId = json['subscriptionPlanId'];
    _isPasswordReset = json['isPasswordReset'];
    _screenName = json['screenName'];
    _isActive = json['isActive'];
    _userAccessibleDCIds = json['userAccessibleDCIds'] ?? "";
    _userID = json['userID'];
    _tpdUserName = json['tpdUserName'];
    _proxyOrgName = json['proxyOrgName'];
    _tpdOrgName = json['tpdOrgName'];
    _proxyUserId = json['proxy_user_id'];
    _secondaryAuth = json['secondaryAuth'];
    _sessionTimeoutDuration = json['sessionTimeoutDuration'];
    _currentJSessionID = json['currentJSessionID'];
    _tpdUserID = json['tpdUserID'];
    _isProxyUserWorking = json['isProxyUserWorking'];
    _orgID = json['orgID'];
    _dateFormatforLanguage = json['dateFormatforLanguage'];
    _firstName = json['firstName'];
    _secondaryEmailAddress = json['secondaryEmailAddress'];
    _userId = json['user_id'];
    _orgId = json['org_id'];
    _hUserID = json['hUserID'];
    _userTypeId = json['userTypeId'];
    _lastName = json['lastName'];
    _isAgreedToTermsAndCondition = json['isAgreedToTermsAndCondition'];
    _isShowAnnouncements = json['isShowAnnouncements'];
    _userSessionState = json['userSessionState'];
    _loginMethodType = json['loginMethodType'];
    _lastLoginDate = json['lastLoginDate'];
    _eGRNTimeoutDuration = json['eGRNTimeoutDuration'];
    _userImageName = json['userImageName'];
    _isMDMDeactivatedUser = json['isMDMDeactivatedUser'];
    _proxyUserName = json['proxyUserName'];
    _localeVO =
        json['localeVO'] != null ? LocaleVo.fromJson(json['localeVO']) : null;
    _email = json['email'];
    _isLoadWidgetAdoddle = json['isLoadWidgetAdoddle'];
    _orgVisibility = json['orgVisibility'];
    _enableSecondaryEmail = json['enableSecondaryEmail'];
    _proxyDemoOrganization = json['proxyDemoOrganization'];
    _lastAccessTime = json['lastAccessTime'];
    _isFreeTrialUser = json['isFreeTrialUser'];
    _languageId = json['languageId'];
    _proxyUserID = json['proxyUserID'];
    _userSubscriptionId = json['userSubscriptionId'];
    _demoOrganization = json['demoOrganization'];
    _canAccessAPI = json['canAccessAPI'];
    _generateURI = json['generateURI'];
    _billToOrg = json['billToOrg'];
    _aSessionId = json['aSessionId'];
    _isMultiSessionAllowed = json['isMultiSessionAllowed'];
    _timezoneId = json['timezoneId'];
    _orgDCId = json['orgDCId'];
    _userAccountType = json['userAccountType'];
    _proxyOrgId = json['proxy_org_id'];
    _userCloud = json['userCloud'] ?? "1";
    _loginType = json['loginType'] ?? 1;
  }

  String? _isJSessionIdUpdated;
  String? _tpdOrgID;
  String? _proxyOrgID;
  String? _subscriptionPlanId;
  String? _isPasswordReset;
  String? _screenName;
  String? _isActive;
  dynamic? _userAccessibleDCIds;
  String? _userID;
  String? _tpdUserName;
  String? _proxyOrgName;
  String? _tpdOrgName;
  String? _proxyUserId;
  String? _secondaryAuth;
  String? _sessionTimeoutDuration;
  String? _currentJSessionID;
  String? _tpdUserID;
  String? _isProxyUserWorking;
  String? _orgID;
  String? _dateFormatforLanguage;
  String? _firstName;
  dynamic _secondaryEmailAddress;
  String? _userId;
  String? _orgId;
  String? _hUserID;
  String? _userTypeId;
  String? _lastName;
  String? _isAgreedToTermsAndCondition;

  set isAgreedToTermsAndCondition(String? value) {
    _isAgreedToTermsAndCondition = value;
  }

  String? _isShowAnnouncements;
  String? _userSessionState;
  String? _loginMethodType;
  String? _lastLoginDate;
  String? _eGRNTimeoutDuration;
  String? _userImageName;
  String? _isMDMDeactivatedUser;
  String? _proxyUserName;
  LocaleVo? _localeVO;
  String? _email;
  String? _isLoadWidgetAdoddle;
  String? _orgVisibility;
  String? _enableSecondaryEmail;
  String? _proxyDemoOrganization;
  String? _lastAccessTime;
  String? _isFreeTrialUser;
  String? _languageId;
  String? _proxyUserID;
  String? _userSubscriptionId;
  String? _demoOrganization;
  String? _canAccessAPI;
  String? _generateURI;
  String? _billToOrg;
  String? _aSessionId;
  String? _isMultiSessionAllowed;
  String? _timezoneId;
  String? _orgDCId;
  String? _userAccountType;
  String? _proxyOrgId;
  int _loginType = 1;
  String? _userCloud = "1";

  Usersessionprofile copyWith({
    String? isJSessionIdUpdated,
    String? tpdOrgID,
    String? proxyOrgID,
    String? subscriptionPlanId,
    String? isPasswordReset,
    String? screenName,
    String? isActive,
    dynamic? userAccessibleDCIds,
    String? userID,
    String? tpdUserName,
    String? proxyOrgName,
    String? tpdOrgName,
    String? proxyUserId,
    String? secondaryAuth,
    String? sessionTimeoutDuration,
    String? currentJSessionID,
    String? tpdUserID,
    String? isProxyUserWorking,
    String? orgID,
    String? dateFormatforLanguage,
    String? firstName,
    dynamic secondaryEmailAddress,
    String? userId,
    String? orgId,
    String? hUserID,
    String? userTypeId,
    String? lastName,
    String? isAgreedToTermsAndCondition,
    String? isShowAnnouncements,
    String? userSessionState,
    String? loginMethodType,
    String? lastLoginDate,
    String? eGRNTimeoutDuration,
    String? userImageName,
    String? isMDMDeactivatedUser,
    String? proxyUserName,
    LocaleVo? localeVO,
    String? email,
    String? isLoadWidgetAdoddle,
    String? orgVisibility,
    String? enableSecondaryEmail,
    String? proxyDemoOrganization,
    String? lastAccessTime,
    String? isFreeTrialUser,
    String? languageId,
    String? proxyUserID,
    String? userSubscriptionId,
    String? demoOrganization,
    String? canAccessAPI,
    String? generateURI,
    String? billToOrg,
    String? aSessionId,
    String? isMultiSessionAllowed,
    String? timezoneId,
    String? orgDCId,
    String? userAccountType,
    String? proxyOrgId,
    int loginType = 1,
    String? userCloud = "1",
  }) =>
      Usersessionprofile(
        isJSessionIdUpdated: isJSessionIdUpdated ?? _isJSessionIdUpdated,
        tpdOrgID: tpdOrgID ?? _tpdOrgID,
        proxyOrgID: proxyOrgID ?? _proxyOrgID,
        subscriptionPlanId: subscriptionPlanId ?? _subscriptionPlanId,
        isPasswordReset: isPasswordReset ?? _isPasswordReset,
        screenName: screenName ?? _screenName,
        isActive: isActive ?? _isActive,
        userAccessibleDCIds: userAccessibleDCIds ?? _userAccessibleDCIds,
        userID: userID ?? _userID,
        tpdUserName: tpdUserName ?? _tpdUserName,
        proxyOrgName: proxyOrgName ?? _proxyOrgName,
        tpdOrgName: tpdOrgName ?? _tpdOrgName,
        proxyUserId: proxyUserId ?? _proxyUserId,
        secondaryAuth: secondaryAuth ?? _secondaryAuth,
        sessionTimeoutDuration:
            sessionTimeoutDuration ?? _sessionTimeoutDuration,
        currentJSessionID: currentJSessionID ?? _currentJSessionID,
        tpdUserID: tpdUserID ?? _tpdUserID,
        isProxyUserWorking: isProxyUserWorking ?? _isProxyUserWorking,
        orgID: orgID ?? _orgID,
        dateFormatforLanguage: dateFormatforLanguage ?? _dateFormatforLanguage,
        firstName: firstName ?? _firstName,
        secondaryEmailAddress: secondaryEmailAddress ?? _secondaryEmailAddress,
        userId: userId ?? _userId,
        orgId: orgId ?? _orgId,
        hUserID: hUserID ?? _hUserID,
        userTypeId: userTypeId ?? _userTypeId,
        lastName: lastName ?? _lastName,
        isAgreedToTermsAndCondition:
            isAgreedToTermsAndCondition ?? _isAgreedToTermsAndCondition,
        isShowAnnouncements: isShowAnnouncements ?? _isShowAnnouncements,
        userSessionState: userSessionState ?? _userSessionState,
        loginMethodType: loginMethodType ?? _loginMethodType,
        lastLoginDate: lastLoginDate ?? _lastLoginDate,
        eGRNTimeoutDuration: eGRNTimeoutDuration ?? _eGRNTimeoutDuration,
        userImageName: userImageName ?? _userImageName,
        isMDMDeactivatedUser: isMDMDeactivatedUser ?? _isMDMDeactivatedUser,
        proxyUserName: proxyUserName ?? _proxyUserName,
        localeVO: localeVO ?? _localeVO,
        email: email ?? _email,
        isLoadWidgetAdoddle: isLoadWidgetAdoddle ?? _isLoadWidgetAdoddle,
        orgVisibility: orgVisibility ?? _orgVisibility,
        enableSecondaryEmail: enableSecondaryEmail ?? _enableSecondaryEmail,
        proxyDemoOrganization: proxyDemoOrganization ?? _proxyDemoOrganization,
        lastAccessTime: lastAccessTime ?? _lastAccessTime,
        isFreeTrialUser: isFreeTrialUser ?? _isFreeTrialUser,
        languageId: languageId ?? _languageId,
        proxyUserID: proxyUserID ?? _proxyUserID,
        userSubscriptionId: userSubscriptionId ?? _userSubscriptionId,
        demoOrganization: demoOrganization ?? _demoOrganization,
        canAccessAPI: canAccessAPI ?? _canAccessAPI,
        generateURI: generateURI ?? _generateURI,
        billToOrg: billToOrg ?? _billToOrg,
        aSessionId: aSessionId ?? _aSessionId,
        isMultiSessionAllowed: isMultiSessionAllowed ?? _isMultiSessionAllowed,
        timezoneId: timezoneId ?? _timezoneId,
        orgDCId: orgDCId ?? _orgDCId,
        userAccountType: userAccountType ?? _userAccountType,
        proxyOrgId: proxyOrgId ?? _proxyOrgId,
        loginType: loginType,
          userCloud: userCloud
      );

  String? get isJSessionIdUpdated => _isJSessionIdUpdated;

  String? get tpdOrgID => _tpdOrgID;

  String? get proxyOrgID => _proxyOrgID;

  String? get subscriptionPlanId => _subscriptionPlanId;

  String? get isPasswordReset => _isPasswordReset;

  String? get screenName => _screenName;

  String? get isActive => _isActive;

  dynamic? get userAccessibleDCIds => _userAccessibleDCIds;

  String? get userID => _userID;

  String? get tpdUserName => _tpdUserName;

  String? get proxyOrgName => _proxyOrgName;

  String? get tpdOrgName => _tpdOrgName;

  String? get proxyUserId => _proxyUserId;

  String? get secondaryAuth => _secondaryAuth;

  String? get sessionTimeoutDuration => _sessionTimeoutDuration;

  String? get currentJSessionID => _currentJSessionID;

  String? get tpdUserID => _tpdUserID;

  String? get isProxyUserWorking => _isProxyUserWorking;

  String? get orgID => _orgID;

  String? get dateFormatforLanguage => _dateFormatforLanguage;

  set dateFormatforLanguage(String? value) {
    _dateFormatforLanguage = value;
  }

  String? get firstName => _firstName;

  dynamic get secondaryEmailAddress => _secondaryEmailAddress;

  String? get userId => _userId;

  String? get orgId => _orgId;

  String? get hUserID => _hUserID;

  String? get userTypeId => _userTypeId;

  String? get lastName => _lastName;

  String? get isAgreedToTermsAndCondition => _isAgreedToTermsAndCondition;

  String? get isShowAnnouncements => _isShowAnnouncements;

  String? get userSessionState => _userSessionState;

  String? get loginMethodType => _loginMethodType;

  String? get lastLoginDate => _lastLoginDate;

  String? get eGRNTimeoutDuration => _eGRNTimeoutDuration;

  String? get userImageName => _userImageName;

  String? get isMDMDeactivatedUser => _isMDMDeactivatedUser;

  String? get proxyUserName => _proxyUserName;

  LocaleVo? get localeVO => _localeVO;

  String? get email => _email;

  String? get isLoadWidgetAdoddle => _isLoadWidgetAdoddle;

  String? get orgVisibility => _orgVisibility;

  String? get enableSecondaryEmail => _enableSecondaryEmail;

  String? get proxyDemoOrganization => _proxyDemoOrganization;

  String? get lastAccessTime => _lastAccessTime;

  String? get isFreeTrialUser => _isFreeTrialUser;

  String? get languageId => _languageId;

  set languageId(String? value) {
    _languageId = value;
  }

  String? get proxyUserID => _proxyUserID;

  String? get userSubscriptionId => _userSubscriptionId;

  String? get demoOrganization => _demoOrganization;

  String? get canAccessAPI => _canAccessAPI;

  String? get generateURI => _generateURI;

  String? get billToOrg => _billToOrg;

  String? get aSessionId => _aSessionId;

  String? get isMultiSessionAllowed => _isMultiSessionAllowed;

  String? get timezoneId => _timezoneId;

  set timezoneId(String? value) {
    _timezoneId = value;
  }

  String? get orgDCId => _orgDCId;

  String? get userAccountType => _userAccountType;

  String? get proxyOrgId => _proxyOrgId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['isJSessionIdUpdated'] = _isJSessionIdUpdated;
    map['tpdOrgID'] = _tpdOrgID;
    map['proxyOrgID'] = _proxyOrgID;
    map['subscriptionPlanId'] = _subscriptionPlanId;
    map['isPasswordReset'] = _isPasswordReset;
    map['screenName'] = _screenName;
    map['isActive'] = _isActive;
    map['userAccessibleDCIds'] = _userAccessibleDCIds;
    map['userID'] = _userID;
    map['tpdUserName'] = _tpdUserName;
    map['proxyOrgName'] = _proxyOrgName;
    map['tpdOrgName'] = _tpdOrgName;
    map['proxy_user_id'] = _proxyUserId;
    map['secondaryAuth'] = _secondaryAuth;
    map['sessionTimeoutDuration'] = _sessionTimeoutDuration;
    map['currentJSessionID'] = _currentJSessionID;
    map['tpdUserID'] = _tpdUserID;
    map['isProxyUserWorking'] = _isProxyUserWorking;
    map['orgID'] = _orgID;
    map['dateFormatforLanguage'] = _dateFormatforLanguage;
    map['firstName'] = _firstName;
    map['secondaryEmailAddress'] = _secondaryEmailAddress;
    map['user_id'] = _userId;
    map['org_id'] = _orgId;
    map['hUserID'] = _hUserID;
    map['userTypeId'] = _userTypeId;
    map['lastName'] = _lastName;
    map['isAgreedToTermsAndCondition'] = _isAgreedToTermsAndCondition;
    map['isShowAnnouncements'] = _isShowAnnouncements;
    map['userSessionState'] = _userSessionState;
    map['loginMethodType'] = _loginMethodType;
    map['lastLoginDate'] = _lastLoginDate;
    map['eGRNTimeoutDuration'] = _eGRNTimeoutDuration;
    map['userImageName'] = _userImageName;
    map['isMDMDeactivatedUser'] = _isMDMDeactivatedUser;
    map['proxyUserName'] = _proxyUserName;
    if (_localeVO != null) {
      map['localeVO'] = _localeVO?.toJson();
    }
    map['email'] = _email;
    map['isLoadWidgetAdoddle'] = _isLoadWidgetAdoddle;
    map['orgVisibility'] = _orgVisibility;
    map['enableSecondaryEmail'] = _enableSecondaryEmail;
    map['proxyDemoOrganization'] = _proxyDemoOrganization;
    map['lastAccessTime'] = _lastAccessTime;
    map['isFreeTrialUser'] = _isFreeTrialUser;
    map['languageId'] = _languageId;
    map['proxyUserID'] = _proxyUserID;
    map['userSubscriptionId'] = _userSubscriptionId;
    map['demoOrganization'] = _demoOrganization;
    map['canAccessAPI'] = _canAccessAPI;
    map['generateURI'] = _generateURI;
    map['billToOrg'] = _billToOrg;
    map['aSessionId'] = _aSessionId;
    map['isMultiSessionAllowed'] = _isMultiSessionAllowed;
    map['timezoneId'] = _timezoneId;
    map['orgDCId'] = _orgDCId;
    map['userAccountType'] = _userAccountType;
    map['proxy_org_id'] = _proxyOrgId;
    map['userCloud'] = _userCloud;
    map['loginType'] = _loginType;
    return map;
  }

  String get userCloud => _userCloud ?? "1";

  set userCloud(String value) {
    _userCloud = value;
  }

  int get loginType => _loginType;

  set loginType(int value) {
    _loginType = value;
  }

  set currentJSessionID(String? value) {
    _currentJSessionID = value;
  }
}

/// editionId : "1"
/// _timezone : {"dstSavings":"0","offsets":["32400000","30472000","30600000","36000000","3600000","34200000"],"rawOffset":"32400000","rawOffsetDiff":"0","checksum":"-1709296987","ID":"Asia/Seoul","transitions":["-9048018124799999","-7982213005311998","-7497378201600000","-2790236159999933","-2753445888000000","-2681944473599933","-2624982220800000","-2553480806399933","-2496164659200000","-2411923046399933","-2367347097600000","-2040333926399998","-1895229849599931","-1850300006399998","-1760396083199931","-1713342873599998","-1636533043199931","-1587002572799998","-1507715481599931","-1458185011199998","-1378897919999931","-1329367449599998","-1250080358399931","-1200549887999998","-1085165568000000","2242879488000067","2297379225600000","2371697049600067","2426196787200000","8660371046400000"],"willGMTOffsetChange":"false"}
/// generateURI : "true"
/// _locale : "en_GB"
/// _partnerBrandingId : "asite"

class LocaleVo {
  LocaleVo({
    String? editionId,
    Timezone? timezone,
    String? generateURI,
    String? locale,
    String? partnerBrandingId,
  }) {
    _editionId = editionId;
    _timezone = timezone;
    _generateURI = generateURI;
    _locale = locale;
    _partnerBrandingId = partnerBrandingId;
  }

  LocaleVo.fromJson(dynamic json) {
    _editionId = json['editionId'];
    _timezone =
        json['_timezone'] != null ? Timezone.fromJson(json['_timezone']) : null;
    _generateURI = json['generateURI'];
    _locale = json['_locale'];
    _partnerBrandingId = json['_partnerBrandingId'];
  }

  String? _editionId;
  Timezone? _timezone;
  String? _generateURI;
  String? _locale;
  String? _partnerBrandingId;

  LocaleVo copyWith({
    String? editionId,
    Timezone? timezone,
    String? generateURI,
    String? locale,
    String? partnerBrandingId,
  }) =>
      LocaleVo(
        editionId: editionId ?? _editionId,
        timezone: timezone ?? _timezone,
        generateURI: generateURI ?? _generateURI,
        locale: locale ?? _locale,
        partnerBrandingId: partnerBrandingId ?? _partnerBrandingId,
      );

  String? get editionId => _editionId;

  Timezone? get timezone => _timezone;

  String? get generateURI => _generateURI;

  String? get locale => _locale;

  String? get partnerBrandingId => _partnerBrandingId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['editionId'] = _editionId;
    if (_timezone != null) {
      map['_timezone'] = _timezone?.toJson();
    }
    map['generateURI'] = _generateURI;
    map['_locale'] = _locale;
    map['_partnerBrandingId'] = _partnerBrandingId;
    return map;
  }
}

/// dstSavings : "0"
/// offsets : ["32400000","30472000","30600000","36000000","3600000","34200000"]
/// rawOffset : "32400000"
/// rawOffsetDiff : "0"
/// checksum : "-1709296987"
/// ID : "Asia/Seoul"
/// transitions : ["-9048018124799999","-7982213005311998","-7497378201600000","-2790236159999933","-2753445888000000","-2681944473599933","-2624982220800000","-2553480806399933","-2496164659200000","-2411923046399933","-2367347097600000","-2040333926399998","-1895229849599931","-1850300006399998","-1760396083199931","-1713342873599998","-1636533043199931","-1587002572799998","-1507715481599931","-1458185011199998","-1378897919999931","-1329367449599998","-1250080358399931","-1200549887999998","-1085165568000000","2242879488000067","2297379225600000","2371697049600067","2426196787200000","8660371046400000"]
/// willGMTOffsetChange : "false"

class Timezone {
  Timezone({
    String? dstSavings,
    List<String>? offsets,
    String? rawOffset,
    String? rawOffsetDiff,
    String? checksum,
    String? id,
    List<String>? transitions,
    String? willGMTOffsetChange,
  }) {
    _dstSavings = dstSavings;
    _offsets = offsets;
    _rawOffset = rawOffset;
    _rawOffsetDiff = rawOffsetDiff;
    _checksum = checksum;
    _id = id;
    _transitions = transitions;
    _willGMTOffsetChange = willGMTOffsetChange;
  }

  Timezone.fromJson(dynamic json) {
    _dstSavings = json['dstSavings'];
    _offsets = json['offsets'] != null ? json['offsets'].cast<String>() : [];
    _rawOffset = json['rawOffset'];
    _rawOffsetDiff = json['rawOffsetDiff'];
    _checksum = json['checksum'];
    _id = json['ID'];
    _transitions =
        json['transitions'] != null ? json['transitions'].cast<String>() : [];
    _willGMTOffsetChange = json['willGMTOffsetChange'];
  }

  String? _dstSavings;
  List<String>? _offsets;
  String? _rawOffset;
  String? _rawOffsetDiff;
  String? _checksum;
  String? _id;
  List<String>? _transitions;
  String? _willGMTOffsetChange;

  Timezone copyWith({
    String? dstSavings,
    List<String>? offsets,
    String? rawOffset,
    String? rawOffsetDiff,
    String? checksum,
    String? id,
    List<String>? transitions,
    String? willGMTOffsetChange,
  }) =>
      Timezone(
        dstSavings: dstSavings ?? _dstSavings,
        offsets: offsets ?? _offsets,
        rawOffset: rawOffset ?? _rawOffset,
        rawOffsetDiff: rawOffsetDiff ?? _rawOffsetDiff,
        checksum: checksum ?? _checksum,
        id: id ?? _id,
        transitions: transitions ?? _transitions,
        willGMTOffsetChange: willGMTOffsetChange ?? _willGMTOffsetChange,
      );

  String? get dstSavings => _dstSavings;

  List<String>? get offsets => _offsets;

  String? get rawOffset => _rawOffset;

  String? get rawOffsetDiff => _rawOffsetDiff;

  String? get checksum => _checksum;

  String? get id => _id;

  List<String>? get transitions => _transitions;

  String? get willGMTOffsetChange => _willGMTOffsetChange;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['dstSavings'] = _dstSavings;
    map['offsets'] = _offsets;
    map['rawOffset'] = _rawOffset;
    map['rawOffsetDiff'] = _rawOffsetDiff;
    map['checksum'] = _checksum;
    map['ID'] = _id;
    map['transitions'] = _transitions;
    map['willGMTOffsetChange'] = _willGMTOffsetChange;
    return map;
  }
}
