import 'dart:convert';

/// passwordModifiedDate : "1661780526723"
/// openId : ""
/// graceLoginCount : 0
/// greeting : ""
/// passwordEncrypted : true
/// loginDate : "1663320790603"
/// screenName : "mayurraval"
/// lastLoginDate : "1663320737960"
/// uuid : "ac70294f-c242-4d2f-a939-74d291825016"
/// password : "{SHA2}7xozcaPcOcQBSDp72rmLehVmuSo1dxLYbtEuSM6xVxPs0Lf6z0eLcQ=="
/// emailAddress : "mayurraval@asite.com"
/// passwordReset : false
/// defaultUser : false
/// createDate : "1445411848170"
/// isSuccess : true
/// portraitId : 817294
/// comments : ""
/// contactId : 808582
/// timeZoneId : "Asia/Seoul"
/// lastFailedLoginDate : ""
/// languageId : "en_US"
/// active : true
/// failedLoginAttempts : 0
/// userId : 808581
/// lastLoginIP : "10.50.24.5"
/// agreedToTermsOfUse : true
/// companyId : 300106
/// lockout : false
/// lockoutDate : ""
/// loginIP : "10.50.24.5"
/// modifiedDate : "1662976953443"

class AcceptTermofuseVo {
  AcceptTermofuseVo({
      String? passwordModifiedDate, 
      String? openId, 
      num? graceLoginCount, 
      String? greeting, 
      bool? passwordEncrypted, 
      String? loginDate, 
      String? screenName, 
      String? lastLoginDate, 
      String? uuid, 
      String? password, 
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
      String? lastLoginIP, 
      bool? agreedToTermsOfUse, 
      num? companyId, 
      bool? lockout, 
      String? lockoutDate, 
      String? loginIP, 
      String? modifiedDate,}){
    _passwordModifiedDate = passwordModifiedDate;
    _openId = openId;
    _graceLoginCount = graceLoginCount;
    _greeting = greeting;
    _passwordEncrypted = passwordEncrypted;
    _loginDate = loginDate;
    _screenName = screenName;
    _lastLoginDate = lastLoginDate;
    _uuid = uuid;
    _password = password;
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
    _lastLoginIP = lastLoginIP;
    _agreedToTermsOfUse = agreedToTermsOfUse;
    _companyId = companyId;
    _lockout = lockout;
    _lockoutDate = lockoutDate;
    _loginIP = loginIP;
    _modifiedDate = modifiedDate;
}

  AcceptTermofuseVo.fromJson(dynamic res) {
    var json = jsonDecode(res);
    _passwordModifiedDate = json['passwordModifiedDate'];
    _openId = json['openId'];
    _graceLoginCount = json['graceLoginCount'];
    _greeting = json['greeting'];
    _passwordEncrypted = json['passwordEncrypted'];
    _loginDate = json['loginDate'];
    _screenName = json['screenName'];
    _lastLoginDate = json['lastLoginDate'];
    _uuid = json['uuid'];
    _password = json['password'];
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
    _failedLoginAttempts = json['failedLoginAttempts'];
    _userId = json['userId'];
    _lastLoginIP = json['lastLoginIP'];
    _agreedToTermsOfUse = json['agreedToTermsOfUse'];
    _companyId = json['companyId'];
    _lockout = json['lockout'];
    _lockoutDate = json['lockoutDate'];
    _loginIP = json['loginIP'];
    _modifiedDate = json['modifiedDate'];
  }
  String? _passwordModifiedDate;
  String? _openId;
  num? _graceLoginCount;
  String? _greeting;
  bool? _passwordEncrypted;
  String? _loginDate;
  String? _screenName;
  String? _lastLoginDate;
  String? _uuid;
  String? _password;
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
  String? _lastLoginIP;
  bool? _agreedToTermsOfUse;
  num? _companyId;
  bool? _lockout;
  String? _lockoutDate;
  String? _loginIP;
  String? _modifiedDate;
AcceptTermofuseVo copyWith({  String? passwordModifiedDate,
  String? openId,
  num? graceLoginCount,
  String? greeting,
  bool? passwordEncrypted,
  String? loginDate,
  String? screenName,
  String? lastLoginDate,
  String? uuid,
  String? password,
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
  String? lastLoginIP,
  bool? agreedToTermsOfUse,
  num? companyId,
  bool? lockout,
  String? lockoutDate,
  String? loginIP,
  String? modifiedDate,
}) => AcceptTermofuseVo(  passwordModifiedDate: passwordModifiedDate ?? _passwordModifiedDate,
  openId: openId ?? _openId,
  graceLoginCount: graceLoginCount ?? _graceLoginCount,
  greeting: greeting ?? _greeting,
  passwordEncrypted: passwordEncrypted ?? _passwordEncrypted,
  loginDate: loginDate ?? _loginDate,
  screenName: screenName ?? _screenName,
  lastLoginDate: lastLoginDate ?? _lastLoginDate,
  uuid: uuid ?? _uuid,
  password: password ?? _password,
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
  lastLoginIP: lastLoginIP ?? _lastLoginIP,
  agreedToTermsOfUse: agreedToTermsOfUse ?? _agreedToTermsOfUse,
  companyId: companyId ?? _companyId,
  lockout: lockout ?? _lockout,
  lockoutDate: lockoutDate ?? _lockoutDate,
  loginIP: loginIP ?? _loginIP,
  modifiedDate: modifiedDate ?? _modifiedDate,
);
  String? get passwordModifiedDate => _passwordModifiedDate;
  String? get openId => _openId;
  num? get graceLoginCount => _graceLoginCount;
  String? get greeting => _greeting;
  bool? get passwordEncrypted => _passwordEncrypted;
  String? get loginDate => _loginDate;
  String? get screenName => _screenName;
  String? get lastLoginDate => _lastLoginDate;
  String? get uuid => _uuid;
  String? get password => _password;
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
  String? get lastLoginIP => _lastLoginIP;
  bool? get agreedToTermsOfUse => _agreedToTermsOfUse;
  num? get companyId => _companyId;
  bool? get lockout => _lockout;
  String? get lockoutDate => _lockoutDate;
  String? get loginIP => _loginIP;
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
    map['password'] = _password;
    map['emailAddress'] = _emailAddress;
    map['passwordReset'] = _passwordReset;
    map['defaultUser'] = _defaultUser;
    map['createDate'] = _createDate;
    map['isSuccess'] = _isSuccess;
    map['portraitId'] = _portraitId;
    map['comments'] = _comments;
    map['contactId'] = _contactId;
    map['timeZoneId'] = _timeZoneId;
    map['lastFailedLoginDate'] = _lastFailedLoginDate;
    map['languageId'] = _languageId;
    map['active'] = _active;
    map['failedLoginAttempts'] = _failedLoginAttempts;
    map['userId'] = _userId;
    map['lastLoginIP'] = _lastLoginIP;
    map['agreedToTermsOfUse'] = _agreedToTermsOfUse;
    map['companyId'] = _companyId;
    map['lockout'] = _lockout;
    map['lockoutDate'] = _lockoutDate;
    map['loginIP'] = _loginIP;
    map['modifiedDate'] = _modifiedDate;
    return map;
  }

}