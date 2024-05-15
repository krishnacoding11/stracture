import 'dart:convert';

import 'quality_plan_location_listing_vo.dart';

/// projectPlanDetailsVO : {"projectID":"2125007$$a3Dcem","planID":"5148","projectName":"Alda r HTML Defect - QA","planName":"test","perCompletion": 25,"generateURI":true}
/// locations : [{"qiLocationId":"15 08715$$xSFHlT","qiParentId":"1508572$$0aYX6E","name":"Aldar Site-3","percentageCompelition ":0,"hasLocation":true,"generateURI":true}]
/// generateURI : true

class QualityLocationBreadcrumb {
  QualityLocationBreadcrumb({
      ProjectPlanDetailsVo? projectPlanDetailsVO, 
      List<Locations>? locations, 
      bool? generateURI,}){
    _projectPlanDetailsVO = projectPlanDetailsVO;
    _locations = locations;
    _generateURI = generateURI;
}

  QualityLocationBreadcrumb.fromJson(dynamic value) {
    dynamic json = jsonDecode(value);
    _projectPlanDetailsVO = json['projectPlanDetailsVO'] != null ? ProjectPlanDetailsVo.fromJson(json['projectPlanDetailsVO']) : null;
    if (json['locations'] != null) {
      _locations = [];
      json['locations'].forEach((v) {
        _locations?.add(Locations.fromJson(v));
      });
    }
    _generateURI = json['generateURI'];
  }
  ProjectPlanDetailsVo? _projectPlanDetailsVO;
  List<Locations>? _locations;
  bool? _generateURI;
QualityLocationBreadcrumb copyWith({  ProjectPlanDetailsVo? projectPlanDetailsVO,
  List<Locations>? locations,
  bool? generateURI,
}) => QualityLocationBreadcrumb(  projectPlanDetailsVO: projectPlanDetailsVO ?? _projectPlanDetailsVO,
  locations: locations ?? _locations,
  generateURI: generateURI ?? _generateURI,
);
  ProjectPlanDetailsVo? get projectPlanDetailsVO => _projectPlanDetailsVO;
  List<Locations>? get locations => _locations;
  bool? get generateURI => _generateURI;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_projectPlanDetailsVO != null) {
      map['projectPlanDetailsVO'] = _projectPlanDetailsVO?.toJson();
    }
    if (_locations != null) {
      map['locations'] = _locations?.map((v) => v.toJson()).toList();
    }
    map['generateURI'] = _generateURI;
    return map;
  }

}

/// qiLocationId : "15 08715$$xSFHlT"
/// qiParentId : "1508572$$0aYX6E"
/// name : "Aldar Site-3"
/// percentageCompelition  : 0
/// hasLocation : true
/// generateURI : true


/// projectID : "2125007$$a3Dcem"
/// planID : "5148"
/// projectName : "Alda r HTML Defect - QA"
/// planName : "test"
/// perCompletion: 25
/// generateURI : true

class ProjectPlanDetailsVo {
  ProjectPlanDetailsVo({
    String? projectID,
    String? planID,
    String? projectName,
    String? planName,
    num? perCompletion,
    bool? generateURI,}){
    _projectID = projectID;
    _planID = planID;
    _projectName = projectName;
    _planName = planName;
    _perCompletion = perCompletion;
    _generateURI = generateURI;
  }

  ProjectPlanDetailsVo.fromJson(dynamic json) {
    _projectID = json['projectID'];
    _planID = json['planID'];
    _projectName = json['projectName'];
    _planName = json['planName'];
    _perCompletion = json['perCompletion'];
    _generateURI = json['generateURI'];
  }
  String? _projectID;
  String? _planID;
  String? _projectName;
  String? _planName;
  num? _perCompletion;
  bool? _generateURI;
  ProjectPlanDetailsVo copyWith({  String? projectID,
    String? planID,
    String? projectName,
    String? planName,
    num? perCompletion,
    bool? generateURI,
  }) => ProjectPlanDetailsVo(  projectID: projectID ?? _projectID,
    planID: planID ?? _planID,
    projectName: projectName ?? _projectName,
    planName: planName ?? _planName,
    perCompletion: perCompletion ?? _perCompletion,
    generateURI: generateURI ?? _generateURI,
  );
  String? get projectID => _projectID;
  String? get planID => _planID;
  String? get projectName => _projectName;
  String? get planName => _planName;
  num? get perCompletion => _perCompletion;
  bool? get generateURI => _generateURI;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['projectID'] = _projectID;
    map['planID'] = _planID;
    map['projectName'] = _projectName;
    map['planName'] = _planName;
    map['perCompletion'] = _perCompletion;
    map['generateURI'] = _generateURI;
    return map;
  }

}