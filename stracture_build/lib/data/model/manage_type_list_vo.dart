/*class ManageTypeVO {
  int? _manageTypeId;
  String? _manageTypeName;
  bool? _isDeactive;
  String? _projectId;
  String? _userId;
  String? _userName;
  String? _orgId;
  String? _orgName;

  ManageTypeVO(
      {int? manageTypeId,
        String? manageTypeName,
        bool? isDeactive,
        String? projectId,
        String? userId,
        String? userName,
        String? orgId,
        String? orgName}) {
    if (manageTypeId != null) {
      _manageTypeId = manageTypeId;
    }
    if (manageTypeName != null) {
      _manageTypeName = manageTypeName;
    }
    if (isDeactive != null) {
      _isDeactive = isDeactive;
    }
    if (projectId != null) {
      _projectId = projectId;
    }
    if (userId != null) {
      _userId = userId;
    }
    if (userName != null) {
      _userName = userName;
    }
    if (orgId != null) {
      _orgId = orgId;
    }
    if (orgName != null) {
      _orgName = orgName;
    }
  }

  int? get manageTypeId => _manageTypeId;
  set setManageTypeId(int? manageTypeId) => _manageTypeId = manageTypeId;
  String? get manageTypeName => _manageTypeName;
  set setManageTypeName(String? manageTypeName) => _manageTypeName = manageTypeName;
  bool? get isDeactive => _isDeactive;
  set setIsDeactive(bool? isDeactive) => _isDeactive = isDeactive;
  String? get projectId => _projectId;
  set setProjectId(String? projectId) => _projectId = projectId;
  String? get userId => _userId;
  set setUserId(String? userId) => _userId = _userId;
  String? get userName => _userName;
  set setUserName(String? userName) => _userName = userName;
  String? get orgId => _orgId;
  set setOrgId(String? orgId) => _orgId = orgId;
  String? get orgName => _orgName;
  set setOrgName(String? orgName) => _orgName = orgName;

  ManageTypeVO.fromJson(List<Map<String, dynamic>> json) {
    _manageTypeId = json['id'];
    _manageTypeName = json['name'];
    _isDeactive = json['isDeactive'];
    _projectId = json['projectId'];
    _userId = json['userID'];
    _userName = json['userName'];
    _orgId = json['orgId'];
    _orgName = json['orgName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _manageTypeId;
    data['name'] = _manageTypeName;
    data['isDeactive'] = _isDeactive;
    data['projectId'] = _projectId;
    data['userID'] = _userId;
    data['userName'] = _userName;
    data['orgId'] = _orgId;
    data['orgName'] = _orgName;
    return data;
  }
}*/

import 'dart:convert';

class ManageTypeListVO {
  DistData? _distData;

  ManageTypeListVO({DistData? distData}) {
    if (distData != null) {
      _distData = distData;
    }
  }

  DistData? get distData => _distData;
  set distData(DistData? distData) => _distData = distData;

  ManageTypeListVO.fromJson(dynamic json) {
    json = jsonDecode(json);
    _distData = json['distData'] != null
        ? DistData.fromJson(json['distData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (_distData != null) {
      data['distData'] = _distData!.toJson();
    }
    return data;
  }
}

class DistData {
  List<ManageTypeVO>? _defTypeJson;

  DistData({List<ManageTypeVO>? defTypeJson}) {
    if (defTypeJson != null) {
      _defTypeJson = defTypeJson;
    }
  }

  List<ManageTypeVO>? get defTypeJson => _defTypeJson;
  set defTypeJson(List<ManageTypeVO>? defTypeJson) => _defTypeJson = defTypeJson;

  DistData.fromJson(Map<String, dynamic> json) {
    if (json['defTypeJson'] != null) {
      _defTypeJson = <ManageTypeVO>[];
      json['defTypeJson'].forEach((v) {
        _defTypeJson!.add(ManageTypeVO.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (_defTypeJson != null) {
      data['defTypeJson'] = _defTypeJson!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ManageTypeVO {
  String? _manageTypeId;
  String? _manageTypeName;
  bool? _isDeactive;
  String? _projectId;
  String? _userId;
  String? _userName;
  String? _orgId;
  String? _orgName;
  bool? _generateURI;

  ManageTypeVO({String? manageTypeId, String? manageTypeName, bool? isDeactive, String? projectId, String? userId, String? userName, String? orgId, String? orgName, bool? generateURI}) {
    if (manageTypeId != null) {
      _manageTypeId = manageTypeId;
    }
    if (manageTypeName != null) {
      _manageTypeName = manageTypeName;
    }
    if (isDeactive != null) {
      _isDeactive = isDeactive;
    }
    if (projectId != null) {
      _projectId = projectId;
    }
    if (userId != null) {
      _userId = userId;
    }
    if (userName != null) {
      _userName = userName;
    }
    if (orgId != null) {
      _orgId = orgId;
    }
    if (orgName != null) {
      _orgName = orgName;
    }
    if (generateURI != null) {
      _generateURI = generateURI;
    }
  }

  String? get manageTypeId => _manageTypeId;
  set setManageTypeId(String? manageTypeId) => _manageTypeId = manageTypeId;

  String? get manageTypeName => _manageTypeName;

  set setManageTypeName(String? name) => _manageTypeName = manageTypeName;

  bool? get isDeactive => _isDeactive;

  set setIsDeactive(bool? isDeactive) => _isDeactive = isDeactive;

  String? get projectId => _projectId;

  set setProjectId(String? projectId) => _projectId = projectId;

  String? get userId => _userId;

  set setUserId(String? userId) => _userId = userId;

  String? get userName => _userName;

  set setUserName(String? userName) => _userName = userName;

  String? get orgId => _orgId;

  set setOrgId(String? orgId) => _orgId = orgId;

  String? get orgName => _orgName;

  set setOrgName(String? orgName) => _orgName = orgName;

  ManageTypeVO.fromJson(Map<String, dynamic> json) {
    _manageTypeId = json['id'];
    _manageTypeName = json['name'];
    _isDeactive = json['isDeactive'];
    _projectId = json['projectId'];
    _userId = json['userID'];
    _userName = json['userName'];
    _orgId = (json['orgId'] ?? "").toString();
    _orgName = json['orgName'];
    _generateURI = json['generateURI'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = _manageTypeId;
    data['name'] = _manageTypeName;
    data['isDeactive'] = _isDeactive;
    data['projectId'] = _projectId;
    data['userID'] = _userId;
    data['userName'] = _userName;
    data['orgId'] = _orgId;
    data['orgName'] = _orgName;
    data['generateURI'] = _generateURI;
    return data;
  }
}
