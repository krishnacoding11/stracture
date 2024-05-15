import 'package:equatable/equatable.dart';
import 'package:field/data/model/floor_details.dart';

class BimProjectModel {
  BimProjectModelVO? bIMProjectModelVO;

  BimProjectModel({this.bIMProjectModelVO});

  BimProjectModel.fromJson(Map<String, dynamic> json) {
    bIMProjectModelVO = json['BIMProjectModelVO'] != null ? BimProjectModelVO.fromJson(json['BIMProjectModelVO']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (bIMProjectModelVO != null) {
      data['BIMProjectModelVO'] = bIMProjectModelVO!.toJson();
    }
    return data;
  }
}

class BimProjectModelVO {
  IfcObject? ifcObject;
  String? userPrivilege;
  String? hasViews;
  String? hasDiscussions;
  String? projectId;
  String? modelId;
  String? projectName;
  String? modelCreationDate;
  String? publisherFullName;
  int? modelTypeId;
  String? lastAccessedDateTime;
  int? isFavourite;
  String? lastUpdateDateTime;
  bool? generateURI;

  BimProjectModelVO({this.ifcObject, this.userPrivilege, this.hasViews, this.hasDiscussions, this.projectId, this.modelId, this.projectName, this.modelCreationDate, this.publisherFullName, this.modelTypeId, this.lastAccessedDateTime, this.isFavourite, this.lastUpdateDateTime, this.generateURI});

  @override
  List<Object?> get props => [];

  BimProjectModelVO.fromJson(Map<String, dynamic> json) {
    ifcObject = json['ifcObject'] != null ? IfcObject.fromJson(json['ifcObject']) : null;
    userPrivilege = json['user_privilege'];
    hasViews = json['has_views'];
    hasDiscussions = json['has_discussions'];
    projectId = json['project_id'];
    modelId = json['model_id'];
    projectName = json['project_name'];
    modelCreationDate = json['model_creation_date'];
    publisherFullName = json['publisher_full_name'];
    modelTypeId = json['model_type_id'];
    lastAccessedDateTime = json['last_accessed_date_time'];
    isFavourite = json['is_favourite'];
    lastUpdateDateTime = json['last_update_date_time'];
    generateURI = json['generateURI'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (ifcObject != null) {
      data['ifcObject'] = ifcObject!.toJson();
    }
    data['user_privilege'] = userPrivilege;
    data['has_views'] = hasViews;
    data['has_discussions'] = hasDiscussions;
    data['project_id'] = projectId;
    data['model_id'] = modelId;
    data['project_name'] = projectName;
    data['model_creation_date'] = modelCreationDate;
    data['publisher_full_name'] = publisherFullName;
    data['model_type_id'] = modelTypeId;
    data['last_accessed_date_time'] = lastAccessedDateTime;
    data['is_favourite'] = isFavourite;
    data['last_update_date_time'] = lastUpdateDateTime;
    data['generateURI'] = generateURI;
    return data;
  }
}

class IfcObject {
  String? name;
  List<IfcObjects>? ifcObjects;
  int? disciplineId;
  String? fileLocation;

  IfcObject({this.name, this.ifcObjects, this.disciplineId, this.fileLocation});

  IfcObject.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['ifcObjects'] != null) {
      ifcObjects = <IfcObjects>[];
      json['ifcObjects'].forEach((v) {
        ifcObjects!.add(IfcObjects.fromJson(v));
      });
    }
    disciplineId = json['disciplineId'];
    fileLocation = json['fileLocation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (ifcObjects != null) {
      data['ifcObjects'] = ifcObjects!.map((v) => v.toJson()).toList();
    }
    data['disciplineId'] = disciplineId;
    data['fileLocation'] = fileLocation;
    return data;
  }
}

class IfcObjects {
  String? name;
  List<BimModel>? ifcObjects;
  String? docId;
  int? disciplineId;
  bool? isDownload;
  bool? isDownloadCompleted;
  bool? isDownloading;
  bool? isQueue;
  bool? isClicked;
  String size = '';
  int? tReceived;
  int? tTotal;

  IfcObjects({this.name, this.ifcObjects, this.docId, this.disciplineId, this.isDownloadCompleted, this.isDownloading, this.isQueue, this.isClicked, required this.size, this.tReceived, this.tTotal});

  IfcObjects.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    if (json['ifcObjects'] != null) {
      ifcObjects = <BimModel>[];
      json['ifcObjects'].forEach((v) {
        ifcObjects!.add(BimModel.fromJson(v, ifcName: name));
      });
    }
    docId = json['docId'];
    disciplineId = json['disciplineId'];
    isDownload = json['isDownload'] = false;
    isDownloadCompleted = json['isDownloadCompleted'] = false;
    isDownloading = json['isDownloading'] = false;
    isQueue = json['isQueue'] = false;
    isClicked = json['isClicked'] = false;
    tReceived = json['tReceived'] = 8191;
    tTotal = json['tTotal'] = 1371452;
    size = json['size'] = '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    if (ifcObjects != null) {
      data['ifcObjects'] = ifcObjects!.map((v) => v.toJson()).toList();
    }
    data['docId'] = docId;
    data['disciplineId'] = disciplineId;
    data['isDownload'] = isDownload;
    data['isDownloadCompleted'] = isDownloadCompleted;
    data['isDownloading'] = isDownloading;
    data['isQueue'] = isQueue;
    data['isClicked'] = isClicked;
    data['size'] = size;
    data['tReceived'] = tReceived;
    data['tTotal'] = tTotal;
    return data;
  }
}

class BimModel extends Equatable {
  String? bimModelIdField;
  String? name;
  String? ifcName;
  String? fileName;
  String? revId;
  bool? isMerged;
  bool? isChecked;
  bool? isDownloaded;
  int? disciplineId;
  bool? isLink;
  int? filesize;
  String? folderId;
  String? fileLocation;
  bool? isLastUploaded;
  int? bimIssueNumber;
  String? hsfChecksum;
  int? bimIssueNumberModel;
  bool? isDocAssociated;
  String? docTitle;
  String? publisherName;
  String? orgName;
  List<FloorDetail> floorList = [];
  bool isDeleteExpanded = false;

  BimModel({this.bimModelIdField, this.name, this.fileName, this.ifcName, this.revId, this.isMerged, this.disciplineId, this.isLink, this.filesize, this.folderId, this.fileLocation, this.isLastUploaded, this.bimIssueNumber, this.hsfChecksum, this.isChecked = false, this.floorList = const [], this.bimIssueNumberModel, this.isDocAssociated, this.docTitle, this.publisherName, this.orgName, this.isDownloaded, this.isDeleteExpanded = false});

  BimModel.fromJson(Map<String, dynamic> json, {String? ifcName}) {
    bimModelIdField = json['bimModelIdField'] ?? "1";
    name = json['name'];
    fileName = json['fileName'];
    floorList = [];
    revId = json['revId'];
    isMerged = json['isMerged'];
    disciplineId = json['disciplineId'];
    isLink = json['is_link'];
    filesize = json['filesize'];
    folderId = json['folderId'];
    fileLocation = json['fileLocation'];
    isLastUploaded = json['is_last_uploaded'];
    bimIssueNumber = json['bimIssueNumber'];
    hsfChecksum = json['hsf_checksum'];
    bimIssueNumberModel = json['bimIssueNumberModel'];
    isDocAssociated = json['isDocAssociated'];
    docTitle = json['docTitle'];
    publisherName = json['publisherName'];
    orgName = json['orgName'];
    isChecked = false;
    isDownloaded = false;
    this.ifcName = ifcName;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bimModelIdField'] = bimModelIdField;
    data['name'] = name;
    data['fileName'] = fileName;
    data['revId'] = revId;
    data['isMerged'] = isMerged;
    data['disciplineId'] = disciplineId;
    data['is_link'] = isLink;
    data['filesize'] = filesize;
    data['folderId'] = folderId;
    data['fileLocation'] = fileLocation;
    data['is_last_uploaded'] = isLastUploaded;
    data['bimIssueNumber'] = bimIssueNumber;
    data['hsf_checksum'] = hsfChecksum;
    data['bimIssueNumberModel'] = bimIssueNumberModel;
    data['isDocAssociated'] = isDocAssociated;
    data['docTitle'] = docTitle;
    data['publisherName'] = publisherName;
    data['orgName'] = orgName;
    data['floorList'] = floorList;
    data['isChecked'] = isChecked;
    data['ifcName'] = ifcName;
    data['isDownloaded'] = isDownloaded;
    return data;
  }

  @override
  List<Object?> get props => [];
}
