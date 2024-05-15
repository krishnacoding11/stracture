import 'dart:convert';

/// user_id : 808581
/// user_name : "Mayur Raval (5372)"
/// org_id : 3
/// org_name : "Asite Solutions"
/// subscription_id : 1
/// subscriptionName : "Key Enterprise"
/// start_date : "20-oct-2015"
/// is_active_user : true
/// never_exp : true
/// userEmail : "mayurraval@asite.com"
/// create_workspace : false
/// user_type_id : 0
/// login_user_id : 0
/// login_user_org_id : 0
/// billToOrgId : 3
/// billToOrgName : "Asite Solutions"
/// userAppRoleId : 2177299
/// emailNotification : true
/// subscriptionPlanId : 5
/// contractNumber : ""
/// fName : "Mayur"
/// lName : "Raval (5372)"
/// mName : ""
/// prefixId : 11015
/// suffixId : 0
/// redirectViewId : 2
/// languageId : "es_ES"
/// enableAutoAcceptance : true
/// marketingPref : false
/// jobTitle : "TL"
/// isNeverExpiresChanged : false
/// comments : ""
/// timeZoneId : "Asia/Calcutta"
/// greeting : ""
/// chkSendLoginCredential : false
/// enableSecondaryEmail : false
/// secondaryEmailAddress : ""
/// dateFormatforLanguage : "dd-MMM-yyyy"
/// generateURI : true

class GetUserWithSubscriptionVo {
  GetUserWithSubscriptionVo({
    num? userId,
    String? userName,
    num? orgId,
    String? orgName,
    num? subscriptionId,
    String? subscriptionName,
    String? startDate,
    bool? isActiveUser,
    bool? neverExp,
    String? userEmail,
    bool? createWorkspace,
    num? userTypeId,
    num? loginUserId,
    num? loginUserOrgId,
    num? billToOrgId,
    String? billToOrgName,
    num? userAppRoleId,
    bool? emailNotification,
    num? subscriptionPlanId,
    String? contractNumber,
    String? fName,
    String? lName,
    String? mName,
    num? prefixId,
    num? suffixId,
    num? redirectViewId,
    String? languageId,
    bool? enableAutoAcceptance,
    bool? marketingPref,
    String? jobTitle,
    bool? isNeverExpiresChanged,
    String? comments,
    String? timeZoneId,
    String? greeting,
    bool? chkSendLoginCredential,
    bool? enableSecondaryEmail,
    String? secondaryEmailAddress,
    String? dateFormatforLanguage,
    bool? generateURI,
  }) {
    _userId = userId;
    _userName = userName;
    _orgId = orgId;
    _orgName = orgName;
    _subscriptionId = subscriptionId;
    _subscriptionName = subscriptionName;
    _startDate = startDate;
    _isActiveUser = isActiveUser;
    _neverExp = neverExp;
    _userEmail = userEmail;
    _createWorkspace = createWorkspace;
    _userTypeId = userTypeId;
    _loginUserId = loginUserId;
    _loginUserOrgId = loginUserOrgId;
    _billToOrgId = billToOrgId;
    _billToOrgName = billToOrgName;
    _userAppRoleId = userAppRoleId;
    _emailNotification = emailNotification;
    _subscriptionPlanId = subscriptionPlanId;
    _contractNumber = contractNumber;
    _fName = fName;
    _lName = lName;
    _mName = mName;
    _prefixId = prefixId;
    _suffixId = suffixId;
    _redirectViewId = redirectViewId;
    _languageId = languageId;
    _enableAutoAcceptance = enableAutoAcceptance;
    _marketingPref = marketingPref;
    _jobTitle = jobTitle;
    _isNeverExpiresChanged = isNeverExpiresChanged;
    _comments = comments;
    _timeZoneId = timeZoneId;
    _greeting = greeting;
    _chkSendLoginCredential = chkSendLoginCredential;
    _enableSecondaryEmail = enableSecondaryEmail;
    _secondaryEmailAddress = secondaryEmailAddress;
    _dateFormatforLanguage = dateFormatforLanguage;
    _generateURI = generateURI;
  }

  GetUserWithSubscriptionVo.fromJson(dynamic result) {
    var json = jsonDecode(result);

    _userId = json['user_id'];
    _userName = json['user_name'];
    _orgId = json['org_id'];
    _orgName = json['org_name'];
    _subscriptionId = json['subscription_id'];
    _subscriptionName = json['subscriptionName'];
    _startDate = json['start_date'];
    _isActiveUser = json['is_active_user'];
    _neverExp = json['never_exp'];
    _userEmail = json['userEmail'];
    _createWorkspace = json['create_workspace'];
    _userTypeId = json['user_type_id'];
    _loginUserId = json['login_user_id'];
    _loginUserOrgId = json['login_user_org_id'];
    _billToOrgId = json['billToOrgId'];
    _billToOrgName = json['billToOrgName'];
    _userAppRoleId = json['userAppRoleId'];
    _emailNotification = json['emailNotification'];
    _subscriptionPlanId = json['subscriptionPlanId'];
    _contractNumber = json['contractNumber'];
    _fName = json['fName'];
    _lName = json['lName'];
    _mName = json['mName'];
    _prefixId = json['prefixId'];
    _suffixId = json['suffixId'];
    _redirectViewId = json['redirectViewId'];
    _languageId = json['languageId'];
    _enableAutoAcceptance = json['enableAutoAcceptance'];
    _marketingPref = json['marketingPref'];
    _jobTitle = json['jobTitle'];
    _isNeverExpiresChanged = json['isNeverExpiresChanged'];
    _comments = json['comments'];
    _timeZoneId = json['timeZoneId'];
    _greeting = json['greeting'];
    _chkSendLoginCredential = json['chkSendLoginCredential'];
    _enableSecondaryEmail = json['enableSecondaryEmail'];
    _secondaryEmailAddress = json['secondaryEmailAddress'];
    _dateFormatforLanguage = json['dateFormatforLanguage'];
    _generateURI = json['generateURI'];
  }

  num? _userId;
  String? _userName;
  num? _orgId;
  String? _orgName;
  num? _subscriptionId;
  String? _subscriptionName;
  String? _startDate;
  bool? _isActiveUser;
  bool? _neverExp;
  String? _userEmail;
  bool? _createWorkspace;
  num? _userTypeId;
  num? _loginUserId;
  num? _loginUserOrgId;
  num? _billToOrgId;
  String? _billToOrgName;
  num? _userAppRoleId;
  bool? _emailNotification;
  num? _subscriptionPlanId;
  String? _contractNumber;
  String? _fName;
  String? _lName;
  String? _mName;
  num? _prefixId;
  num? _suffixId;
  num? _redirectViewId;
  String? _languageId;
  bool? _enableAutoAcceptance;
  bool? _marketingPref;
  String? _jobTitle;
  bool? _isNeverExpiresChanged;
  String? _comments;
  String? _timeZoneId;
  String? _greeting;
  bool? _chkSendLoginCredential;
  bool? _enableSecondaryEmail;
  String? _secondaryEmailAddress;
  String? _dateFormatforLanguage;
  bool? _generateURI;

  GetUserWithSubscriptionVo copyWith({
    num? userId,
    String? userName,
    num? orgId,
    String? orgName,
    num? subscriptionId,
    String? subscriptionName,
    String? startDate,
    bool? isActiveUser,
    bool? neverExp,
    String? userEmail,
    bool? createWorkspace,
    num? userTypeId,
    num? loginUserId,
    num? loginUserOrgId,
    num? billToOrgId,
    String? billToOrgName,
    num? userAppRoleId,
    bool? emailNotification,
    num? subscriptionPlanId,
    String? contractNumber,
    String? fName,
    String? lName,
    String? mName,
    num? prefixId,
    num? suffixId,
    num? redirectViewId,
    String? languageId,
    bool? enableAutoAcceptance,
    bool? marketingPref,
    String? jobTitle,
    bool? isNeverExpiresChanged,
    String? comments,
    String? timeZoneId,
    String? greeting,
    bool? chkSendLoginCredential,
    bool? enableSecondaryEmail,
    String? secondaryEmailAddress,
    String? dateFormatforLanguage,
    bool? generateURI,
  }) =>
      GetUserWithSubscriptionVo(
        userId: userId ?? _userId,
        userName: userName ?? _userName,
        orgId: orgId ?? _orgId,
        orgName: orgName ?? _orgName,
        subscriptionId: subscriptionId ?? _subscriptionId,
        subscriptionName: subscriptionName ?? _subscriptionName,
        startDate: startDate ?? _startDate,
        isActiveUser: isActiveUser ?? _isActiveUser,
        neverExp: neverExp ?? _neverExp,
        userEmail: userEmail ?? _userEmail,
        createWorkspace: createWorkspace ?? _createWorkspace,
        userTypeId: userTypeId ?? _userTypeId,
        loginUserId: loginUserId ?? _loginUserId,
        loginUserOrgId: loginUserOrgId ?? _loginUserOrgId,
        billToOrgId: billToOrgId ?? _billToOrgId,
        billToOrgName: billToOrgName ?? _billToOrgName,
        userAppRoleId: userAppRoleId ?? _userAppRoleId,
        emailNotification: emailNotification ?? _emailNotification,
        subscriptionPlanId: subscriptionPlanId ?? _subscriptionPlanId,
        contractNumber: contractNumber ?? _contractNumber,
        fName: fName ?? _fName,
        lName: lName ?? _lName,
        mName: mName ?? _mName,
        prefixId: prefixId ?? _prefixId,
        suffixId: suffixId ?? _suffixId,
        redirectViewId: redirectViewId ?? _redirectViewId,
        languageId: languageId ?? _languageId,
        enableAutoAcceptance: enableAutoAcceptance ?? _enableAutoAcceptance,
        marketingPref: marketingPref ?? _marketingPref,
        jobTitle: jobTitle ?? _jobTitle,
        isNeverExpiresChanged: isNeverExpiresChanged ?? _isNeverExpiresChanged,
        comments: comments ?? _comments,
        timeZoneId: timeZoneId ?? _timeZoneId,
        greeting: greeting ?? _greeting,
        chkSendLoginCredential:
            chkSendLoginCredential ?? _chkSendLoginCredential,
        enableSecondaryEmail: enableSecondaryEmail ?? _enableSecondaryEmail,
        secondaryEmailAddress: secondaryEmailAddress ?? _secondaryEmailAddress,
        dateFormatforLanguage: dateFormatforLanguage ?? _dateFormatforLanguage,
        generateURI: generateURI ?? _generateURI,
      );

  num? get userId => _userId;

  String? get userName => _userName;

  num? get orgId => _orgId;

  String? get orgName => _orgName;

  num? get subscriptionId => _subscriptionId;

  String? get subscriptionName => _subscriptionName;

  String? get startDate => _startDate;

  bool? get isActiveUser => _isActiveUser;

  bool? get neverExp => _neverExp;

  String? get userEmail => _userEmail;

  bool? get createWorkspace => _createWorkspace;

  num? get userTypeId => _userTypeId;

  num? get loginUserId => _loginUserId;

  num? get loginUserOrgId => _loginUserOrgId;

  num? get billToOrgId => _billToOrgId;

  String? get billToOrgName => _billToOrgName;

  num? get userAppRoleId => _userAppRoleId;

  bool? get emailNotification => _emailNotification;

  num? get subscriptionPlanId => _subscriptionPlanId;

  String? get contractNumber => _contractNumber;

  String? get fName => _fName;

  String? get lName => _lName;

  String? get mName => _mName;

  num? get prefixId => _prefixId;

  num? get suffixId => _suffixId;

  num? get redirectViewId => _redirectViewId;

  String? get languageId => _languageId;

  bool? get enableAutoAcceptance => _enableAutoAcceptance;

  bool? get marketingPref => _marketingPref;

  String? get jobTitle => _jobTitle;

  bool? get isNeverExpiresChanged => _isNeverExpiresChanged;

  String? get comments => _comments;

  String? get timeZoneId => _timeZoneId;

  String? get greeting => _greeting;

  bool? get chkSendLoginCredential => _chkSendLoginCredential;

  bool? get enableSecondaryEmail => _enableSecondaryEmail;

  String? get secondaryEmailAddress => _secondaryEmailAddress;

  String? get dateFormatforLanguage => _dateFormatforLanguage;

  bool? get generateURI => _generateURI;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['user_id'] = _userId;
    map['user_name'] = _userName;
    map['org_id'] = _orgId;
    map['org_name'] = _orgName;
    map['subscription_id'] = _subscriptionId;
    map['subscriptionName'] = _subscriptionName;
    map['start_date'] = _startDate;
    map['is_active_user'] = _isActiveUser;
    map['never_exp'] = _neverExp;
    map['userEmail'] = _userEmail;
    map['create_workspace'] = _createWorkspace;
    map['user_type_id'] = _userTypeId;
    map['login_user_id'] = _loginUserId;
    map['login_user_org_id'] = _loginUserOrgId;
    map['billToOrgId'] = _billToOrgId;
    map['billToOrgName'] = _billToOrgName;
    map['userAppRoleId'] = _userAppRoleId;
    map['emailNotification'] = _emailNotification;
    map['subscriptionPlanId'] = _subscriptionPlanId;
    map['contractNumber'] = _contractNumber;
    map['fName'] = _fName;
    map['lName'] = _lName;
    map['mName'] = _mName;
    map['prefixId'] = _prefixId;
    map['suffixId'] = _suffixId;
    map['redirectViewId'] = _redirectViewId;
    map['languageId'] = _languageId;
    map['enableAutoAcceptance'] = _enableAutoAcceptance;
    map['marketingPref'] = _marketingPref;
    map['jobTitle'] = _jobTitle;
    map['isNeverExpiresChanged'] = _isNeverExpiresChanged;
    map['comments'] = _comments;
    map['timeZoneId'] = _timeZoneId;
    map['greeting'] = _greeting;
    map['chkSendLoginCredential'] = _chkSendLoginCredential;
    map['enableSecondaryEmail'] = _enableSecondaryEmail;
    map['secondaryEmailAddress'] = _secondaryEmailAddress;
    map['dateFormatforLanguage'] = _dateFormatforLanguage;
    map['generateURI'] = _generateURI;
    return map;
  }
}
