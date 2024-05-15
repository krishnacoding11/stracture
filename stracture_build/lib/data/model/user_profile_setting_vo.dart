import 'dart:convert';

import 'package:field/utils/extensions.dart';

/// lastName : "Banethia (5327)"
/// curPassword : ""
/// jobTitle : "C++ Developer"
/// phoneId : 960234
/// languageId : "en_GB"
/// marketingPref : false
/// timeZone : "Europe/Lisbon"
/// newPassword : ""
/// isUserImageExist : false
/// screenName : "sbanethia$$000KX1"
/// passwordMinLength : 9
/// phoneNo : "532785243"
/// firstName : "Saurabh"
/// emailAddress : "sbanethia@asite.com"
/// jsonTimZones : [{"timeZone":"(UTC -11:00)Samoa Standard Time","id":"Pacific/Midway"},{"timeZone":"(UTC -10:00)Hawaii Standard Time","id":"Pacific/Honolulu"},{"timeZone":"(UTC -09:00)Alaska Standard Time","id":"America/Anchorage"},{"timeZone":"(UTC -08:00)Pacific Standard Time","id":"America/Los_Angeles"},{"timeZone":"(UTC -07:00)Mountain Standard Time","id":"America/Denver"},{"timeZone":"(UTC -06:00)Central Standard Time","id":"America/Chicago"},{"timeZone":"(UTC -05:00)Eastern Standard Time","id":"America/New_York"},{"timeZone":"(UTC -04:00)Atlantic Standard Time","id":"America/Puerto_Rico"},{"timeZone":"(UTC -03:30)Newfoundland Standard Time","id":"America/St_Johns"},{"timeZone":"(UTC -03:00)Brasilia Time","id":"America/Sao_Paulo"},{"timeZone":"(UTC -02:00)Fernando de Noronha Time","id":"America/Noronha"},{"timeZone":"(UTC -01:00)Azores Time","id":"Atlantic/Azores"},{"timeZone":"(UTC )Western European Time","id":"Europe/Lisbon"},{"timeZone":"(UTC +01:00)Central European Time","id":"Europe/Paris"},{"timeZone":"(UTC +03:00)Eastern European Time","id":"Europe/Istanbul"},{"timeZone":"(UTC +02:00)Israel Standard Time","id":"Asia/Jerusalem"},{"timeZone":"(UTC +03:00)Arabia Standard Time","id":"Asia/Baghdad"},{"timeZone":"(UTC +03:30)Iran Standard Time","id":"Asia/Tehran"},{"timeZone":"(UTC +04:00)Gulf Standard Time","id":"Asia/Dubai"},{"timeZone":"(UTC +04:30)Afghanistan Time","id":"Asia/Kabul"},{"timeZone":"(UTC +05:00)Pakistan Time","id":"Asia/Karachi"},{"timeZone":"(UTC +05:30)India Standard Time","id":"Asia/Calcutta"},{"timeZone":"(UTC +05:45)Nepal Time","id":"Asia/Katmandu"},{"timeZone":"(UTC +06:00)Bangladesh Time","id":"Asia/Dhaka"},{"timeZone":"(UTC +06:30)Myanmar Time","id":"Asia/Rangoon"},{"timeZone":"(UTC +07:00)Indochina Time","id":"Asia/Saigon"},{"timeZone":"(UTC +08:00)China Standard Time","id":"Asia/Shanghai"},{"timeZone":"(UTC +09:00)Japan Standard Time","id":"Asia/Tokyo"},{"timeZone":"(UTC +09:00)Korea Standard Time","id":"Asia/Seoul"},{"timeZone":"(UTC +08:00)Australian Western Standard Time","id":"Australia/Perth"},{"timeZone":"(UTC +09:30)Australian Central Standard Time (South Australia)","id":"Australia/Adelaide"},{"timeZone":"(UTC +09:30)Australian Central Standard Time (Northern Territory)","id":"Australia/Darwin"},{"timeZone":"(UTC +10:00)Australian Eastern Standard Time (Queensland)","id":"Australia/Brisbane"},{"timeZone":"(UTC +10:00)Australian Eastern Standard Time (New South Wales)","id":"Australia/Canberra"},{"timeZone":"(UTC +10:00)Australian Eastern Standard Time (Tasmania)","id":"Australia/Hobart"},{"timeZone":"(UTC +10:00)Australian Eastern Standard Time (Victoria)","id":"Australia/Melbourne"},{"timeZone":"(UTC +10:00)Australian Eastern Standard Time (New South Wales)","id":"Australia/Sydney"},{"timeZone":"(UTC +11:00)Solomon Is. Time","id":"Pacific/Guadalcanal"},{"timeZone":"(UTC +12:00)New Zealand Standard Time","id":"Pacific/Auckland"},{"timeZone":"(UTC +13:00)Phoenix Is. Time","id":"Pacific/Enderbury"},{"timeZone":"(UTC +14:00)Line Is. Time","id":"Pacific/Kiritimati"}]
/// secondaryEmailAddress : ""
/// confirmPassword : ""
/// middleName : ""

class UserProfileSettingVo {
  UserProfileSettingVo({
      String? lastName, 
      String? curPassword, 
      String? jobTitle, 
      int? phoneId, 
      String? languageId, 
      bool? marketingPref, 
      String? timeZone, 
      String? newPassword, 
      bool? isUserImageExist, 
      String? screenName, 
      int? passwordMinLength, 
      String? phoneNo, 
      String? firstName, 
      String? emailAddress, 
      List<JsonTimZones>? jsonTimZones, 
      String? secondaryEmailAddress, 
      String? confirmPassword, 
      String? middleName,}){
    _lastName = lastName;
    _curPassword = curPassword;
    _jobTitle = jobTitle;
    _phoneId = phoneId;
    _languageId = languageId;
    _marketingPref = marketingPref;
    _timeZone = timeZone;
    _newPassword = newPassword;
    _isUserImageExist = isUserImageExist;
    _screenName = screenName;
    _passwordMinLength = passwordMinLength;
    _phoneNo = phoneNo;
    _firstName = firstName;
    _emailAddress = emailAddress;
    _jsonTimZones = jsonTimZones;
    _secondaryEmailAddress = secondaryEmailAddress;
    _confirmPassword = confirmPassword;
    _middleName = middleName;
}

  UserProfileSettingVo.fromJson(dynamic data) {
    final json = jsonDecode(data);
    _lastName = json['lastName'];
    _curPassword = json['curPassword'];
    _jobTitle = json['jobTitle'];
    _phoneId = json['phoneId'];
    _languageId = json['languageId'];
    _marketingPref = json['marketingPref'];
    _timeZone = json['timeZone'];
    _newPassword = json['newPassword'];
    _isUserImageExist = json['isUserImageExist'];
    _screenName = json['screenName'];
    _passwordMinLength = json['passwordMinLength'];
    _phoneNo = json['phoneNo'];
    _firstName = json['firstName'];
    _emailAddress = json['emailAddress'];
    if(_emailAddress.isNullOrEmpty()){
      _emailAddress = json['email'];
    }
    if (json['jsonTimZones'] != null) {
      _jsonTimZones = [];
      json['jsonTimZones'].forEach((v) {
        _jsonTimZones?.add(JsonTimZones.fromJson(v));
      });
    }
    _secondaryEmailAddress = json['secondaryEmailAddress'];
    _confirmPassword = json['confirmPassword'];
    _middleName = json['middleName'];
  }
  String? _lastName;
  String? _curPassword;
  String? _jobTitle;
  int? _phoneId;
  String? _languageId;
  bool? _marketingPref;
  String? _timeZone;
  String? _newPassword;
  bool? _isUserImageExist;
  String? _screenName;
  int? _passwordMinLength;
  String? _phoneNo;
  String? _firstName;
  String? _emailAddress;
  List<JsonTimZones>? _jsonTimZones;
  String? _secondaryEmailAddress;
  String? _confirmPassword;
  String? _middleName;
UserProfileSettingVo copyWith({  String? lastName,
  String? curPassword,
  String? jobTitle,
  int? phoneId,
  String? languageId,
  bool? marketingPref,
  String? timeZone,
  String? newPassword,
  bool? isUserImageExist,
  String? screenName,
  int? passwordMinLength,
  String? phoneNo,
  String? firstName,
  String? emailAddress,
  List<JsonTimZones>? jsonTimZones,
  String? secondaryEmailAddress,
  String? confirmPassword,
  String? middleName,
}) => UserProfileSettingVo(  lastName: lastName ?? _lastName,
  curPassword: curPassword ?? _curPassword,
  jobTitle: jobTitle ?? _jobTitle,
  phoneId: phoneId ?? _phoneId,
  languageId: languageId ?? _languageId,
  marketingPref: marketingPref ?? _marketingPref,
  timeZone: timeZone ?? _timeZone,
  newPassword: newPassword ?? _newPassword,
  isUserImageExist: isUserImageExist ?? _isUserImageExist,
  screenName: screenName ?? _screenName,
  passwordMinLength: passwordMinLength ?? _passwordMinLength,
  phoneNo: phoneNo ?? _phoneNo,
  firstName: firstName ?? _firstName,
  emailAddress: emailAddress ?? _emailAddress,
  jsonTimZones: jsonTimZones ?? _jsonTimZones,
  secondaryEmailAddress: secondaryEmailAddress ?? _secondaryEmailAddress,
  confirmPassword: confirmPassword ?? _confirmPassword,
  middleName: middleName ?? _middleName,
);
  String? get lastName => _lastName;
  String? get curPassword => _curPassword;
  String? get jobTitle => _jobTitle;
  int? get phoneId => _phoneId;
  String? get languageId => _languageId;
  bool? get marketingPref => _marketingPref;
  String? get timeZone => _timeZone;
  String? get newPassword => _newPassword;
  bool? get isUserImageExist => _isUserImageExist;
  String? get screenName => _screenName;
  int? get passwordMinLength => _passwordMinLength;
  String? get phoneNo => _phoneNo;
  String? get firstName => _firstName;
  String? get emailAddress => _emailAddress;
  List<JsonTimZones>? get jsonTimZones => _jsonTimZones;
  String? get secondaryEmailAddress => _secondaryEmailAddress;
  String? get confirmPassword => _confirmPassword;
  String? get middleName => _middleName;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['lastName'] = _lastName;
    map['curPassword'] = _curPassword;
    map['jobTitle'] = _jobTitle;
    map['phoneId'] = _phoneId;
    map['languageId'] = _languageId;
    map['marketingPref'] = _marketingPref;
    map['timeZone'] = _timeZone;
    map['newPassword'] = _newPassword;
    map['isUserImageExist'] = _isUserImageExist;
    map['screenName'] = _screenName;
    map['passwordMinLength'] = _passwordMinLength;
    map['phoneNo'] = _phoneNo;
    map['firstName'] = _firstName;
    map['emailAddress'] = _emailAddress;
    if (_jsonTimZones != null) {
      map['jsonTimZones'] = _jsonTimZones?.map((v) => v.toJson()).toList();
    }
    map['secondaryEmailAddress'] = _secondaryEmailAddress;
    map['confirmPassword'] = _confirmPassword;
    map['middleName'] = _middleName;
    return map;
  }

  set languageId(String? languageId) {
    _languageId = languageId;
  }

  set timeZone(String? timeZone) {
    _timeZone = timeZone;
  }

  set phoneNo(String? phoneNo) {
    _phoneNo = phoneNo;
  }

  set curPassword(String? curPassword) {
    _curPassword = curPassword;
  }

  set newPassword(String? newPassword) {
    _newPassword = newPassword;
  }

  set confirmPassword(String? confirmPassword) {
    _confirmPassword = confirmPassword;
  }
}

/// timeZone : "(UTC -11:00)Samoa Standard Time"
/// id : "Pacific/Midway"

class JsonTimZones {
  JsonTimZones({
      String? timeZone, 
      String? id,}){
    _timeZone = timeZone;
    _id = id;
}

  JsonTimZones.fromJson(dynamic json) {
    _timeZone = json['timeZone'];
    _id = json['id'];
  }
  String? _timeZone;
  String? _id;
JsonTimZones copyWith({  String? timeZone,
  String? id,
}) => JsonTimZones(  timeZone: timeZone ?? _timeZone,
  id: id ?? _id,
);
  String? get timeZone => _timeZone;
  String? get id => _id;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['timeZone'] = _timeZone;
    map['id'] = _id;
    return map;
  }

}