import 'dart:convert';

import 'package:field/networking/network_info.dart';

/// userId : 643944
/// projectId : "2155406$$u5Jx8z"
/// configJsonData : {"defaultTabs":[{"id":"1","values":"Create New Task"},{"id":"2","values":"New Tasks"},{"id":"3","values":"Task Due Today"},{"id":"4","values":"Task Due This Week"},{"id":"5","values":"Overdue Tasks"},{"id":"6","values":"Jump Back to Site"},{"id":"7","values":"Create Site Form"},{"id":"8","values":"Filter"},{"id":"9","values":"CreateForm"}],"userProjectConfigTabsDetails":[{"id":"1","name":"Create New Task","config":{}},{"id":"2","name":"New Tasks","config":{}},{"id":"3","name":"Task Due Today","config":{}},{"id":"4","name":"Task Due This Week","config":{}},{"id":"5","name":"Overdue Tasks","config":{}},{"id":"6","name":"Jump Back to Site","config":{}},{"id":"7","name":"Create Site Form","config":{}}]}
/// createdDate : "2023-10-06 06:45:02.563"
/// updatedDate : "2023-10-06 06:45:02.563"

class HomePageModel {
  HomePageModel({
    num? userId,
    String? projectId,
    ConfigJsonData? configJsonData,
    String? createdDate,
    String? updatedDate,
  }) {
    _userId = userId;
    _projectId = projectId;
    _configJsonData = configJsonData;
    _createdDate = createdDate;
    _updatedDate = updatedDate;
  }

  HomePageModel.fromJson(dynamic json) {
    _userId = json['userId'];
    _projectId = json['projectId'];
    _configJsonData = json['configJsonData'] != null ? ConfigJsonData.fromJson(json['configJsonData']) : null;
    _createdDate = json['createdDate'];
    _updatedDate = json['updatedDate'];
  }

  num? _userId;
  String? _projectId;
  ConfigJsonData? _configJsonData;
  String? _createdDate;
  String? _updatedDate;

  HomePageModel copyWith({
    num? userId,
    String? projectId,
    ConfigJsonData? configJsonData,
    String? createdDate,
    String? updatedDate,
  }) =>
      HomePageModel(
        userId: userId ?? _userId,
        projectId: projectId ?? _projectId,
        configJsonData: configJsonData ?? _configJsonData,
        createdDate: createdDate ?? _createdDate,
        updatedDate: updatedDate ?? _updatedDate,
      );

  num? get userId => _userId;

  String? get projectId => _projectId;

  ConfigJsonData? get configJsonData => _configJsonData;

  String? get createdDate => _createdDate;

  String? get updatedDate => _updatedDate;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userId'] = _userId;
    map['projectId'] = _projectId;
    if (_configJsonData != null) {
      map['configJsonData'] = _configJsonData?.toJson();
    }
    map['createdDate'] = _createdDate;
    map['updatedDate'] = _updatedDate;
    return map;
  }
}

/// defaultTabs : [{"id":"1","values":"Create New Task"},{"id":"2","values":"New Tasks"},{"id":"3","values":"Task Due Today"},{"id":"4","values":"Task Due This Week"},{"id":"5","values":"Overdue Tasks"},{"id":"6","values":"Jump Back to Site"},{"id":"7","values":"Create Site Form"},{"id":"8","values":"Filter"},{"id":"9","values":"CreateForm"}]
/// userProjectConfigTabsDetails : [{"id":"1","name":"Create New Task","config":{}},{"id":"2","name":"New Tasks","config":{}},{"id":"3","name":"Task Due Today","config":{}},{"id":"4","name":"Task Due This Week","config":{}},{"id":"5","name":"Overdue Tasks","config":{}},{"id":"6","name":"Jump Back to Site","config":{}},{"id":"7","name":"Create Site Form","config":{}}]

class ConfigJsonData {
  ConfigJsonData({
    List<DefaultTabs>? defaultTabs,
    List<UserProjectConfigTabsDetails>? userProjectConfigTabsDetails,
  }) {
    _defaultTabs = defaultTabs;
    _userProjectConfigTabsDetails = userProjectConfigTabsDetails;
  }

  ConfigJsonData.fromJson(dynamic json) {
    if (json['defaultTabs'] != null) {
      _defaultTabs = [];
      json['defaultTabs'].forEach((v) {
        _defaultTabs?.add(DefaultTabs.fromJson(v));
      });
    }
    if (json['userProjectConfigTabsDetails'] != null) {
      _userProjectConfigTabsDetails = [];
      json['userProjectConfigTabsDetails'].forEach((v) {
        _userProjectConfigTabsDetails?.add(UserProjectConfigTabsDetails.fromJson(v));
      });
    }
  }

  List<DefaultTabs>? _defaultTabs;
  List<UserProjectConfigTabsDetails>? _userProjectConfigTabsDetails;

  ConfigJsonData copyWith({
    List<DefaultTabs>? defaultTabs,
    List<UserProjectConfigTabsDetails>? userProjectConfigTabsDetails,
  }) =>
      ConfigJsonData(
        defaultTabs: defaultTabs ?? _defaultTabs,
        userProjectConfigTabsDetails: userProjectConfigTabsDetails ?? _userProjectConfigTabsDetails,
      );

  List<DefaultTabs>? get defaultTabs => _defaultTabs;

  List<UserProjectConfigTabsDetails>? get userProjectConfigTabsDetails => _userProjectConfigTabsDetails;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_defaultTabs != null) {
      map['defaultTabs'] = _defaultTabs?.map((v) => v.toJson()).toList();
    }
    if (_userProjectConfigTabsDetails != null) {
      map['userProjectConfigTabsDetails'] = _userProjectConfigTabsDetails?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : "1"
/// name : "Create New Task"
/// config : {}

class UserProjectConfigTabsDetails {
  UserProjectConfigTabsDetails({
    String? id,
    String? name,
    dynamic config,
  }) {
    _id = id;
    _name = name;
    _config = config;
  }

  UserProjectConfigTabsDetails.fromJson(dynamic json) {
    _id = json['id'];
    _name = json['name'];
    _config = json['config'];
  }

  String? _id;
  String? _name;
  dynamic _config;
  bool _isAdded = false;

  bool get isAdded => _isAdded;

  set isAdded(bool value) {
    _isAdded = value;
  }

  UserProjectConfigTabsDetails copyWith({
    String? id,
    String? name,
    dynamic config,
  }) =>
      UserProjectConfigTabsDetails(
        id: id ?? _id,
        name: name ?? _name,
        config: config ?? _config,
      );

  String? get id => _id;

  String? get name => _name;

  dynamic get config => _config;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['name'] = _name;
    map['config'] = _config;
    return map;
  }
}

/// id : "1"
/// values : "Create New Task"

class DefaultTabs {
  DefaultTabs({
    String? id,
    String? values,
  }) {
    _id = id;
    _values = values;
  }

  DefaultTabs.fromJson(dynamic json) {
    _id = json['id'];
    _values = json['values'];
  }

  String? _id;
  String? _values;

  DefaultTabs copyWith({
    String? id,
    String? values,
  }) =>
      DefaultTabs(
        id: id ?? _id,
        values: values ?? _values,
      );

  String? get id => _id;

  String? get values => _values;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['values'] = _values;
    return map;
  }
}
