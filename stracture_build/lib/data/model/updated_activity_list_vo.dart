
import 'package:field/data/model/quality_activity_list_vo.dart';

/// msg : "Success"
/// response : {"root":{"errorDesc":"Sucess","locPercentage":{"1519638":0,"1519649":0,"1519637":0,"1519648":0,"1519636":0,"1519647":0,"1519635":0,"1519657":0,"1519646":0,"1519656":0,"1519645":0,"1519655":0,"1519644":0,"1519654":0,"1519643":0,"1519653":0,"1519642":0,"1519652":0,"1519641":0,"1519651":0,"1519640":0,"1519650":0,"Plan":0,"1519639":0},"deliverableActivities":[{"activitySeq":1,"deliverableActivityId":"6199767$$eYFfCr","statusColor":"#F24043","qiActivityId":"6824$$uxEDjg","qiLocationId":"1519635$$gmWdRn","link":"","creationDate":"2023-05-04 11:56:00.56","updatedById":"1906453$$rznZbd","generateURI":true,"folderId":"0$$uflfrp","isAssociationRequired":true,"qiStatusId":"1$$rzoSL7","updationDate":"2023-05-05 12:41:11.977","statusName":"Not Started","isAccess":false,"activityType":0,"createdById":"1906453$$rznZbd","isWorking":true}],"errorCode":0}}
/// errorCode : "0"
/// isSuccess : true

class UpdatedActivityListVo {
  UpdatedActivityListVo({
      String? msg, 
      Response? response, 
      String? errorCode, 
      bool? isSuccess,}){
    _msg = msg;
    _response = response;
    _errorCode = errorCode;
    _isSuccess = isSuccess;
}

  UpdatedActivityListVo.fromJson(dynamic json) {
    _msg = json['msg'];
    _response = json['response'] != null ? Response.fromJson(json['response']) : null;
    _errorCode = json['errorCode'];
    _isSuccess = json['isSuccess'];
  }
  String? _msg;
  Response? _response;
  String? _errorCode;
  bool? _isSuccess;
UpdatedActivityListVo copyWith({  String? msg,
  Response? response,
  String? errorCode,
  bool? isSuccess,
}) => UpdatedActivityListVo(  msg: msg ?? _msg,
  response: response ?? _response,
  errorCode: errorCode ?? _errorCode,
  isSuccess: isSuccess ?? _isSuccess,
);
  String? get msg => _msg;
  Response? get response => _response;
  String? get errorCode => _errorCode;
  bool? get isSuccess => _isSuccess;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['msg'] = _msg;
    if (_response != null) {
      map['response'] = _response?.toJson();
    }
    map['errorCode'] = _errorCode;
    map['isSuccess'] = _isSuccess;
    return map;
  }

}

/// root : {"errorDesc":"Sucess","locPercentage":{"1519638":0,"1519649":0,"1519637":0,"1519648":0,"1519636":0,"1519647":0,"1519635":0,"1519657":0,"1519646":0,"1519656":0,"1519645":0,"1519655":0,"1519644":0,"1519654":0,"1519643":0,"1519653":0,"1519642":0,"1519652":0,"1519641":0,"1519651":0,"1519640":0,"1519650":0,"Plan":0,"1519639":0},"deliverableActivities":[{"activitySeq":1,"deliverableActivityId":"6199767$$eYFfCr","statusColor":"#F24043","qiActivityId":"6824$$uxEDjg","qiLocationId":"1519635$$gmWdRn","link":"","creationDate":"2023-05-04 11:56:00.56","updatedById":"1906453$$rznZbd","generateURI":true,"folderId":"0$$uflfrp","isAssociationRequired":true,"qiStatusId":"1$$rzoSL7","updationDate":"2023-05-05 12:41:11.977","statusName":"Not Started","isAccess":false,"activityType":0,"createdById":"1906453$$rznZbd","isWorking":true}],"errorCode":0}

class Response {
  Response({
      Root? root,}){
    _root = root;
}

  Response.fromJson(dynamic json) {
    _root = json['root'] != null ? Root.fromJson(json['root']) : null;
  }
  Root? _root;
Response copyWith({  Root? root,
}) => Response(  root: root ?? _root,
);
  Root? get root => _root;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_root != null) {
      map['root'] = _root?.toJson();
    }
    return map;
  }

}

/// errorDesc : "Sucess"
/// locPercentage : {"1519638":0,"1519649":0,"1519637":0,"1519648":0,"1519636":0,"1519647":0,"1519635":0,"1519657":0,"1519646":0,"1519656":0,"1519645":0,"1519655":0,"1519644":0,"1519654":0,"1519643":0,"1519653":0,"1519642":0,"1519652":0,"1519641":0,"1519651":0,"1519640":0,"1519650":0,"Plan":0,"1519639":0}
/// deliverableActivities : [{"activitySeq":1,"deliverableActivityId":"6199767$$eYFfCr","statusColor":"#F24043","qiActivityId":"6824$$uxEDjg","qiLocationId":"1519635$$gmWdRn","link":"","creationDate":"2023-05-04 11:56:00.56","updatedById":"1906453$$rznZbd","generateURI":true,"folderId":"0$$uflfrp","isAssociationRequired":true,"qiStatusId":"1$$rzoSL7","updationDate":"2023-05-05 12:41:11.977","statusName":"Not Started","isAccess":false,"activityType":0,"createdById":"1906453$$rznZbd","isWorking":true}]
/// errorCode : 0

class Root {
  Root({
      String? errorDesc, 
      LocPercentage? locPercentage,
      List<DeliverableActivities>? deliverableActivities,
      num? errorCode,}){
    _errorDesc = errorDesc;
    _locPercentage = locPercentage;
    _deliverableActivities = deliverableActivities;
    _errorCode = errorCode;
}

  Root.fromJson(dynamic json) {
    _errorDesc = json['errorDesc'];
    _locPercentage = json['locPercentage'] != null ? LocPercentage.fromJson(json['locPercentage']) : null;
    if (json['deliverableActivities'] != null) {
      _deliverableActivities = [];
      json['deliverableActivities'].forEach((v) {
        _deliverableActivities?.add(DeliverableActivities.fromJson(v));
      });
    }
    _errorCode = json['errorCode'];
  }
  String? _errorDesc;
  LocPercentage? _locPercentage;
  List<DeliverableActivities>? _deliverableActivities;
  num? _errorCode;
Root copyWith({  String? errorDesc,
  // LocPercentage? locPercentage,
  List<DeliverableActivities>? deliverableActivities,
  num? errorCode,
}) => Root(  errorDesc: errorDesc ?? _errorDesc,
  locPercentage: locPercentage ?? _locPercentage,
  deliverableActivities: deliverableActivities ?? _deliverableActivities,
  errorCode: errorCode ?? _errorCode,
);
  String? get errorDesc => _errorDesc;
  LocPercentage? get locPercentage => _locPercentage;
  List<DeliverableActivities>? get deliverableActivities => _deliverableActivities;
  num? get errorCode => _errorCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['errorDesc'] = _errorDesc;
    if (_locPercentage != null) {
      map['locPercentage'] = _locPercentage?.toJson();
    }
    if (_deliverableActivities != null) {
      map['deliverableActivities'] = _deliverableActivities?.map((v) => v.toJson()).toList();
    }
    map['errorCode'] = _errorCode;
    return map;
  }

}

/// activitySeq : 1
/// deliverableActivityId : "6199767$$eYFfCr"
/// statusColor : "#F24043"
/// qiActivityId : "6824$$uxEDjg"
/// qiLocationId : "1519635$$gmWdRn"
/// link : ""
/// creationDate : "2023-05-04 11:56:00.56"
/// updatedById : "1906453$$rznZbd"
/// generateURI : true
/// folderId : "0$$uflfrp"
/// isAssociationRequired : true
/// qiStatusId : "1$$rzoSL7"
/// updationDate : "2023-05-05 12:41:11.977"
/// statusName : "Not Started"
/// isAccess : false
/// activityType : 0
/// createdById : "1906453$$rznZbd"
/// isWorking : true

// class DeliverableActivities {
//   DeliverableActivities({
//       num? activitySeq,
//       String? deliverableActivityId,
//       String? statusColor,
//       String? qiActivityId,
//       String? qiLocationId,
//       String? link,
//       String? creationDate,
//       String? updatedById,
//       bool? generateURI,
//       String? folderId,
//       bool? isAssociationRequired,
//       String? qiStatusId,
//       String? updationDate,
//       String? statusName,
//       bool? isAccess,
//       num? activityType,
//       String? createdById,
//       bool? isWorking,}){
//     _activitySeq = activitySeq;
//     _deliverableActivityId = deliverableActivityId;
//     _statusColor = statusColor;
//     _qiActivityId = qiActivityId;
//     _qiLocationId = qiLocationId;
//     _link = link;
//     _creationDate = creationDate;
//     _updatedById = updatedById;
//     _generateURI = generateURI;
//     _folderId = folderId;
//     _isAssociationRequired = isAssociationRequired;
//     _qiStatusId = qiStatusId;
//     _updationDate = updationDate;
//     _statusName = statusName;
//     _isAccess = isAccess;
//     _activityType = activityType;
//     _createdById = createdById;
//     _isWorking = isWorking;
// }
//
//   DeliverableActivities.fromJson(dynamic json) {
//     _activitySeq = json['activitySeq'];
//     _deliverableActivityId = json['deliverableActivityId'];
//     _statusColor = json['statusColor'];
//     _qiActivityId = json['qiActivityId'];
//     _qiLocationId = json['qiLocationId'];
//     _link = json['link'];
//     _creationDate = json['creationDate'];
//     _updatedById = json['updatedById'];
//     _generateURI = json['generateURI'];
//     _folderId = json['folderId'];
//     _isAssociationRequired = json['isAssociationRequired'];
//     _qiStatusId = json['qiStatusId'];
//     _updationDate = json['updationDate'];
//     _statusName = json['statusName'];
//     _isAccess = json['isAccess'];
//     _activityType = json['activityType'];
//     _createdById = json['createdById'];
//     _isWorking = json['isWorking'];
//   }
//   num? _activitySeq;
//   String? _deliverableActivityId;
//   String? _statusColor;
//   String? _qiActivityId;
//   String? _qiLocationId;
//   String? _link;
//   String? _creationDate;
//   String? _updatedById;
//   bool? _generateURI;
//   String? _folderId;
//   bool? _isAssociationRequired;
//   String? _qiStatusId;
//   String? _updationDate;
//   String? _statusName;
//   bool? _isAccess;
//   num? _activityType;
//   String? _createdById;
//   bool? _isWorking;
// DeliverableActivities copyWith({  num? activitySeq,
//   String? deliverableActivityId,
//   String? statusColor,
//   String? qiActivityId,
//   String? qiLocationId,
//   String? link,
//   String? creationDate,
//   String? updatedById,
//   bool? generateURI,
//   String? folderId,
//   bool? isAssociationRequired,
//   String? qiStatusId,
//   String? updationDate,
//   String? statusName,
//   bool? isAccess,
//   num? activityType,
//   String? createdById,
//   bool? isWorking,
// }) => DeliverableActivities(  activitySeq: activitySeq ?? _activitySeq,
//   deliverableActivityId: deliverableActivityId ?? _deliverableActivityId,
//   statusColor: statusColor ?? _statusColor,
//   qiActivityId: qiActivityId ?? _qiActivityId,
//   qiLocationId: qiLocationId ?? _qiLocationId,
//   link: link ?? _link,
//   creationDate: creationDate ?? _creationDate,
//   updatedById: updatedById ?? _updatedById,
//   generateURI: generateURI ?? _generateURI,
//   folderId: folderId ?? _folderId,
//   isAssociationRequired: isAssociationRequired ?? _isAssociationRequired,
//   qiStatusId: qiStatusId ?? _qiStatusId,
//   updationDate: updationDate ?? _updationDate,
//   statusName: statusName ?? _statusName,
//   isAccess: isAccess ?? _isAccess,
//   activityType: activityType ?? _activityType,
//   createdById: createdById ?? _createdById,
//   isWorking: isWorking ?? _isWorking,
// );
//   num? get activitySeq => _activitySeq;
//   String? get deliverableActivityId => _deliverableActivityId;
//   String? get statusColor => _statusColor;
//   String? get qiActivityId => _qiActivityId;
//   String? get qiLocationId => _qiLocationId;
//   String? get link => _link;
//   String? get creationDate => _creationDate;
//   String? get updatedById => _updatedById;
//   bool? get generateURI => _generateURI;
//   String? get folderId => _folderId;
//   bool? get isAssociationRequired => _isAssociationRequired;
//   String? get qiStatusId => _qiStatusId;
//   String? get updationDate => _updationDate;
//   String? get statusName => _statusName;
//   bool? get isAccess => _isAccess;
//   num? get activityType => _activityType;
//   String? get createdById => _createdById;
//   bool? get isWorking => _isWorking;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['activitySeq'] = _activitySeq;
//     map['deliverableActivityId'] = _deliverableActivityId;
//     map['statusColor'] = _statusColor;
//     map['qiActivityId'] = _qiActivityId;
//     map['qiLocationId'] = _qiLocationId;
//     map['link'] = _link;
//     map['creationDate'] = _creationDate;
//     map['updatedById'] = _updatedById;
//     map['generateURI'] = _generateURI;
//     map['folderId'] = _folderId;
//     map['isAssociationRequired'] = _isAssociationRequired;
//     map['qiStatusId'] = _qiStatusId;
//     map['updationDate'] = _updationDate;
//     map['statusName'] = _statusName;
//     map['isAccess'] = _isAccess;
//     map['activityType'] = _activityType;
//     map['createdById'] = _createdById;
//     map['isWorking'] = _isWorking;
//     return map;
//   }
//
// }

/// 1519638 : 0
/// 1519649 : 0
/// 1519637 : 0
/// 1519648 : 0
/// 1519636 : 0
/// 1519647 : 0
/// 1519635 : 0
/// 1519657 : 0
/// 1519646 : 0
/// 1519656 : 0
/// 1519645 : 0
/// 1519655 : 0
/// 1519644 : 0
/// 1519654 : 0
/// 1519643 : 0
/// 1519653 : 0
/// 1519642 : 0
/// 1519652 : 0
/// 1519641 : 0
/// 1519651 : 0
/// 1519640 : 0
/// 1519650 : 0
/// Plan : 0
/// 1519639 : 0

class LocPercentage {
  LocPercentage({
      num? plan,
}){
    _plan = plan;
}

  LocPercentage.fromJson(dynamic json) {
    _plan = json['Plan'];
  }
  num? _plan;

LocPercentage copyWith({
  num? plan,
}) => LocPercentage(
  plan: plan ?? _plan,
);

  num? get plan => _plan;


  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['Plan'] = _plan;
    return map;
  }

}