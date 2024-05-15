
/// ssoIdentityProvider : ""
/// ssoEnabled : "false"
/// isUserAvailable : "false"
/// msgTitle : "ABC"
/// cloudName : "Asite Cloud"
/// msgDescription : ""
/// ssoTargetURL : null
/// enableCloudLogin : "true"

class DatacenterVo {
  DatacenterVo({
    String? ssoIdentityProvider,
    String? ssoEnabled,
    String? isUserAvailable,
    String? msgTitle,
    String? cloudName,
    String? cloudId,
    String? msgDescription,
    dynamic ssoTargetURL,
    String? enableCloudLogin,
  }) {
    _ssoIdentityProvider = ssoIdentityProvider;
    _ssoEnabled = ssoEnabled;
    _isUserAvailable = isUserAvailable;
    _msgTitle = msgTitle;
    _cloudName = cloudName;
    _cloudId = cloudId;
    _msgDescription = msgDescription;
    _ssoTargetURL = ssoTargetURL;
    _enableCloudLogin = enableCloudLogin;
  }

  DatacenterVo.fromJson(dynamic json) {
    _ssoIdentityProvider = json['ssoIdentityProvider'];
    _ssoEnabled = json['ssoEnabled'];
    _isUserAvailable = json['isUserAvailable'];
    _msgTitle = json['msgTitle'];
    _cloudName = json['cloudName'];
    _cloudId = json['cloudId'];
    _msgDescription = json['msgDescription'];
    _ssoTargetURL = json['ssoTargetURL'];
    _enableCloudLogin = json['enableCloudLogin'];
  }

  String? _ssoIdentityProvider;
  String? _ssoEnabled;
  String? _isUserAvailable;
  String? _msgTitle;
  String? _cloudName;
  String? _cloudId;
  String? _msgDescription;
  dynamic _ssoTargetURL;
  String? _enableCloudLogin;

  DatacenterVo copyWith({
    String? ssoIdentityProvider,
    String? ssoEnabled,
    String? isUserAvailable,
    String? msgTitle,
    String? cloudName,
    String? cloudId,
    String? msgDescription,
    dynamic ssoTargetURL,
    String? enableCloudLogin,
  }) =>
      DatacenterVo(
        ssoIdentityProvider: ssoIdentityProvider ?? _ssoIdentityProvider,
        ssoEnabled: ssoEnabled ?? _ssoEnabled,
        isUserAvailable: isUserAvailable ?? _isUserAvailable,
        msgTitle: msgTitle ?? _msgTitle,
        cloudName: cloudName ?? _cloudName,
        cloudId: cloudName ?? _cloudId,
        msgDescription: msgDescription ?? _msgDescription,
        ssoTargetURL: ssoTargetURL ?? _ssoTargetURL,
        enableCloudLogin: enableCloudLogin ?? _enableCloudLogin,
      );

  String? get ssoIdentityProvider => _ssoIdentityProvider;

  String? get ssoEnabled => _ssoEnabled;

  String? get isUserAvailable => _isUserAvailable;

  String? get msgTitle => _msgTitle;

  String? get cloudName => _cloudName;

  String? get cloudId => _cloudId;

  String? get msgDescription => _msgDescription;

  dynamic get ssoTargetURL => _ssoTargetURL;

  String? get enableCloudLogin => _enableCloudLogin;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['ssoIdentityProvider'] = _ssoIdentityProvider;
    map['ssoEnabled'] = _ssoEnabled;
    map['isUserAvailable'] = _isUserAvailable;
    map['msgTitle'] = _msgTitle;
    map['cloudName'] = _cloudName;
    map['cloudId'] = _cloudId;
    map['msgDescription'] = _msgDescription;
    map['ssoTargetURL'] = _ssoTargetURL;
    map['enableCloudLogin'] = _enableCloudLogin;
    return map;
  }
}

class DataCenters {
  String? _email;
  bool? _isFromSSO = false;
  List<DatacenterVo>? _clouds;

  String? get email => _email;

  set email(String? value) {
    _email = value;
  }

  DataCenters(List<DatacenterVo>? clouds) {
    _clouds = clouds;
    _email = email;
    _isFromSSO = isFromSSO;
  }

  static List<DatacenterVo> jsonToList(dynamic response) {
    // var jsonData = json.decode(response);
    return List<DatacenterVo>.from(response.map((x) => DatacenterVo.fromJson(x)))
        .toList();
  }

  bool? get isFromSSO => _isFromSSO;

  set isFromSSO(bool? value) {
    _isFromSSO = value;
  }

  List<DatacenterVo>? get clouds => _clouds;

  set clouds(List<DatacenterVo>? value) {
    _clouds = value;
  }
}
