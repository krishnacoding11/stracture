import 'dart:convert';

/// passwordModifiedDate : "1663939068547"
/// openId : ""
/// graceLoginCount : 0
/// greeting : "Welcome Field User1!"
/// passwordEncrypted : true
/// loginDate : "1664428756120"
/// screenName : "fielduser1"
/// lastLoginDate : "1664428431720"
/// uuid : "64490088-9a9e-4ef3-8fa1-7ef39af31f9f"
/// emailAddress : "fielduser1@asite.com"
/// passwordReset : false
/// defaultUser : false
/// createDate : "166  2534579163"
/// isSuccess : true
/// portraitId : 1955751
/// comments : ""
/// contactId : 1947608
/// timeZ  oneId : "America/New_York"
/// lastFailedLoginDate : ""
/// languageId : "en_US"
/// active : true
/// fai  ledLoginAttempts : 0
/// userId : 1947607
/// agreedToTermsOfUse : true
/// companyId : 300106
/// lockout   : false
/// lockoutDate : ""
/// rawOffset : -18000000
/// modifiedDate : "1664428772159"

class UpdateUserAvatarVo {
  UpdateUserAvatarVo({
    bool? isPortraitException,
    String? exceptionMessagePortrait,
    String? passwordModifiedDate,
    String? openId,
    num? graceLoginCount,
    String? greeting,
    bool? passwordEncrypted,
    String? loginDate,
    String? screenName,
    String? lastLoginDate,
    String? uuid,
    String? emailAddress,
    bool? passwordReset,
    bool? defaultUser,
    String? createDate,
    bool? isSuccess,
    num? portraitId,
    String? comments,
    num? contactId,
    String? timeZoneId,
    String? lastFailedLoginDate,
    String? languageId,
    bool? active,
    num? failedLoginAttempts,
    num? userId,
    bool? agreedToTermsOfUse,
    num? companyId,
    bool? lockout,
    String? lockoutDate,
    num? rawOffset,
    String? modifiedDate,
  }) {
    _isPortraitException = isPortraitException;
    _exceptionMessagePortrait = exceptionMessagePortrait;
    _passwordModifiedDate = passwordModifiedDate;
    _openId = openId;
    _graceLoginCount = graceLoginCount;
    _greeting = greeting;
    _passwordEncrypted = passwordEncrypted;
    _loginDate = loginDate;
    _screenName = screenName;
    _lastLoginDate = lastLoginDate;
    _uuid = uuid;
    _emailAddress = emailAddress;
    _passwordReset = passwordReset;
    _defaultUser = defaultUser;
    _createDate = createDate;
    _isSuccess = isSuccess;
    _portraitId = portraitId;
    _comments = comments;
    _contactId = contactId;
    _timeZoneId = timeZoneId;
    _lastFailedLoginDate = lastFailedLoginDate;
    _languageId = languageId;
    _active = active;
    _failedLoginAttempts = failedLoginAttempts;
    _userId = userId;
    _agreedToTermsOfUse = agreedToTermsOfUse;
    _companyId = companyId;
    _lockout = lockout;
    _lockoutDate = lockoutDate;
    _rawOffset = rawOffset;
    _modifiedDate = modifiedDate;
  }

  UpdateUserAvatarVo.fromJson(dynamic res) {
    var json = jsonDecode(res);

    _isPortraitException = json['isPortraitException'];
    _exceptionMessagePortrait = json['exceptionMessagePortrait'];
    _passwordModifiedDate = json['passwordModifiedDate'];
    _openId = json['openId'];
    _graceLoginCount = json['graceLoginCount'];
    _greeting = json['greeting'];
    _passwordEncrypted = json['passwordEncrypted'];
    _loginDate = json['loginDate'];
    _screenName = json['screenName'];
    _lastLoginDate = json['lastLoginDate'];
    _uuid = json['uuid'];
    _emailAddress = json['emailAddress'];
    _passwordReset = json['passwordReset'];
    _defaultUser = json['defaultUser'];
    _createDate = json['createDate'];
    _isSuccess = json['isSuccess'];
    _portraitId = json['portraitId'];
    _comments = json['comments'];
    _contactId = json['contactId'];
    _timeZoneId = json['timeZoneId'];
    _lastFailedLoginDate = json['lastFailedLoginDate'];
    _languageId = json['languageId'];
    _active = json['active'];
    _failedLoginAttempts = json['fai  ledLoginAttempts'];
    _userId = json['userId'];
    _agreedToTermsOfUse = json['agreedToTermsOfUse'];
    _companyId = json['companyId'];
    _lockout = json['lockout  '];
    _lockoutDate = json['lockoutDate'];
    _rawOffset = json['rawOffset'];
    _modifiedDate = json['modifiedDate'];
  }

  bool? _isPortraitException;
  String? _exceptionMessagePortrait;
  String? _passwordModifiedDate;
  String? _openId;
  num? _graceLoginCount;
  String? _greeting;
  bool? _passwordEncrypted;
  String? _loginDate;
  String? _screenName;
  String? _lastLoginDate;
  String? _uuid;
  String? _emailAddress;
  bool? _passwordReset;
  bool? _defaultUser;
  String? _createDate;
  bool? _isSuccess;
  num? _portraitId;
  String? _comments;
  num? _contactId;
  String? _timeZoneId;
  String? _lastFailedLoginDate;
  String? _languageId;
  bool? _active;
  num? _failedLoginAttempts;
  num? _userId;
  bool? _agreedToTermsOfUse;
  num? _companyId;
  bool? _lockout;
  String? _lockoutDate;
  num? _rawOffset;
  String? _modifiedDate;

  UpdateUserAvatarVo copyWith({
    bool? isPortraitException,
    String? exceptionMessagePortrait,
    String? passwordModifiedDate,
    String? openId,
    num? graceLoginCount,
    String? greeting,
    bool? passwordEncrypted,
    String? loginDate,
    String? screenName,
    String? lastLoginDate,
    String? uuid,
    String? emailAddress,
    bool? passwordReset,
    bool? defaultUser,
    String? createDate,
    bool? isSuccess,
    num? portraitId,
    String? comments,
    num? contactId,
    String? timeZoneId,
    String? lastFailedLoginDate,
    String? languageId,
    bool? active,
    num? failedLoginAttempts,
    num? userId,
    bool? agreedToTermsOfUse,
    num? companyId,
    bool? lockout,
    String? lockoutDate,
    num? rawOffset,
    String? modifiedDate,
  }) =>
      UpdateUserAvatarVo(
        isPortraitException: isPortraitException?? _isPortraitException,
        exceptionMessagePortrait: exceptionMessagePortrait ?? _exceptionMessagePortrait,
        passwordModifiedDate: passwordModifiedDate ?? _passwordModifiedDate,
        openId: openId ?? _openId,
        graceLoginCount: graceLoginCount ?? _graceLoginCount,
        greeting: greeting ?? _greeting,
        passwordEncrypted: passwordEncrypted ?? _passwordEncrypted,
        loginDate: loginDate ?? _loginDate,
        screenName: screenName ?? _screenName,
        lastLoginDate: lastLoginDate ?? _lastLoginDate,
        uuid: uuid ?? _uuid,
        emailAddress: emailAddress ?? _emailAddress,
        passwordReset: passwordReset ?? _passwordReset,
        defaultUser: defaultUser ?? _defaultUser,
        createDate: createDate ?? _createDate,
        isSuccess: isSuccess ?? _isSuccess,
        portraitId: portraitId ?? _portraitId,
        comments: comments ?? _comments,
        contactId: contactId ?? _contactId,
        timeZoneId: timeZoneId ?? _timeZoneId,
        lastFailedLoginDate: lastFailedLoginDate ?? _lastFailedLoginDate,
        languageId: languageId ?? _languageId,
        active: active ?? _active,
        failedLoginAttempts: failedLoginAttempts ?? _failedLoginAttempts,
        userId: userId ?? _userId,
        agreedToTermsOfUse: agreedToTermsOfUse ?? _agreedToTermsOfUse,
        companyId: companyId ?? _companyId,
        lockout: lockout ?? _lockout,
        lockoutDate: lockoutDate ?? _lockoutDate,
        rawOffset: rawOffset ?? _rawOffset,
        modifiedDate: modifiedDate ?? _modifiedDate,
      );
  bool? get isPortraitException => _isPortraitException;

  String? get exceptionMessagePortrait => _exceptionMessagePortrait;

  String? get passwordModifiedDate => _passwordModifiedDate;

  String? get openId => _openId;

  num? get graceLoginCount => _graceLoginCount;

  String? get greeting => _greeting;

  bool? get passwordEncrypted => _passwordEncrypted;

  String? get loginDate => _loginDate;

  String? get screenName => _screenName;

  String? get lastLoginDate => _lastLoginDate;

  String? get uuid => _uuid;

  String? get emailAddress => _emailAddress;

  bool? get passwordReset => _passwordReset;

  bool? get defaultUser => _defaultUser;

  String? get createDate => _createDate;

  bool? get isSuccess => _isSuccess;

  num? get portraitId => _portraitId;

  String? get comments => _comments;

  num? get contactId => _contactId;

  String? get timeZoneId => _timeZoneId;

  String? get lastFailedLoginDate => _lastFailedLoginDate;

  String? get languageId => _languageId;

  bool? get active => _active;

  num? get failedLoginAttempts => _failedLoginAttempts;

  num? get userId => _userId;

  bool? get agreedToTermsOfUse => _agreedToTermsOfUse;

  num? get companyId => _companyId;

  bool? get lockout => _lockout;

  String? get lockoutDate => _lockoutDate;

  num? get rawOffset => _rawOffset;

  String? get modifiedDate => _modifiedDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['passwordModifiedDate'] = _passwordModifiedDate;
    map['openId'] = _openId;
    map['graceLoginCount'] = _graceLoginCount;
    map['greeting'] = _greeting;
    map['passwordEncrypted'] = _passwordEncrypted;
    map['loginDate'] = _loginDate;
    map['screenName'] = _screenName;
    map['lastLoginDate'] = _lastLoginDate;
    map['uuid'] = _uuid;
    map['emailAddress'] = _emailAddress;
    map['passwordReset'] = _passwordReset;
    map['defaultUser'] = _defaultUser;
    map['createDate'] = _createDate;
    map['isSuccess'] = _isSuccess;
    map['portraitId'] = _portraitId;
    map['comments'] = _comments;
    map['contactId'] = _contactId;
    map['timeZ  oneId'] = _timeZoneId;
    map['lastFailedLoginDate'] = _lastFailedLoginDate;
    map['languageId'] = _languageId;
    map['active'] = _active;
    map['fai  ledLoginAttempts'] = _failedLoginAttempts;
    map['userId'] = _userId;
    map['agreedToTermsOfUse'] = _agreedToTermsOfUse;
    map['companyId'] = _companyId;
    map['lockout  '] = _lockout;
    map['lockoutDate'] = _lockoutDate;
    map['rawOffset'] = _rawOffset;
    map['modifiedDate'] = _modifiedDate;
    return map;
  }
}
