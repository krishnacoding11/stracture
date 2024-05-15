import 'dart:convert';

import 'package:equatable/equatable.dart';

import '../../presentation/screen/site_routes/site_end_drawer/site_item/site_item.dart';
//ignore: must_be_immutable
class ObservationData extends Equatable {
  int? observationId;
  int? locationId;
  String? folderId;
  String? msgId;
  String? formId;
  String? formTypeId;
  String? annotationId;
  String? revisionId;
  String? coordinates;
  bool? hasAttachment;
  StatusVO? statusVO;
  List<RecipientList>? recipientList;
  List<Actions>? actions;
  LocationDetailVO? locationDetailVO;
  bool? isActive;
  bool? isSyncIndexUpdate;
  bool? isSyncPending;
  String? commId;
  String? formTitle;
  int? formDueDays;
  int? pageNumber;
  int? templateType;
  String? formTypeCode;
  String? appBuilderID;
  String? creatorUserName;
  String? creatorOrgName;
  String? formCode;
  String? formCreationDate;
  int? appType;
  String? projectId;
  bool? generateURI;
  String? defectTypeName;
  String? expectedFinishDate;
  String? responseRequestBy;
  int? creatorUserId;
  bool? isCloseOut;
  String? statusUpdateDate;
  AttachmentItem? attachmentItem;
  String? workPackage;

  ObservationData({this.observationId, this.locationId, this.folderId, this.msgId, this.formId, this.formTypeId, this.annotationId, this.revisionId, this.coordinates, this.hasAttachment, this.statusVO, this.recipientList, this.actions, this.locationDetailVO, this.isActive, this.isSyncIndexUpdate, this.isSyncPending, this.commId, this.formTitle, this.formDueDays, this.pageNumber, this.templateType, this.formTypeCode, this.appBuilderID, this.creatorUserName, this.creatorOrgName, this.formCode, this.formCreationDate, this.appType, this.projectId, this.generateURI, this.defectTypeName, this.expectedFinishDate, this.creatorUserId, this.isCloseOut, this.statusUpdateDate, this.responseRequestBy, this.workPackage});

  ObservationData.fromJson(Map<String, dynamic> json) {
    observationId = json['observationId'];
    locationId = json['locationId'];
    folderId = json['folderId'];
    msgId = json['msgId'];
    formId = json['formId'];
    formTypeId = json['formTypeId'];
    annotationId = json['annotationId'];
    revisionId = json['revisionId'];
    coordinates = json['coordinates'];
    hasAttachment = json['hasAttachment'];
    statusVO = json['statusVO'] != null ? StatusVO.fromJson(json['statusVO']) : null;
    if (json['recipientList'] != null) {
      recipientList = <RecipientList>[];
      json['recipientList'].forEach((v) {
        recipientList!.add(RecipientList.fromJson(v));
      });
    }
    if (json['actions'] != null) {
      actions = <Actions>[];
      json['actions'].forEach((v) {
        actions!.add(Actions.fromJson(v));
      });
    }
    locationDetailVO = json['locationDetailVO'] != null ? LocationDetailVO.fromJson(json['locationDetailVO']) : null;
    isActive = json['isActive'];
    isSyncIndexUpdate = json['isSyncIndexUpdate'];
    isSyncPending = json['isSyncPending'];
    commId = json['commId'];
    formTitle = json['formTitle'] ?? json['title'];
    formDueDays = json['formDueDays'];
    pageNumber = json['pageNumber'];
    templateType = json['templateType'];
    formTypeCode = json['formTypeCode'];
    appBuilderID = json['appBuilderID'];
    creatorUserName = json['creatorUserName'];
    creatorOrgName = json['creatorOrgName'];
    formCode = json['formCode'] ?? json['code'];
    formCreationDate = json['formCreationDate'];
    appType = json['appType'].runtimeType == String ? int.parse(json['appType']) : json['appType'];
    projectId = json['projectId'];
    generateURI = json['generateURI'];
    defectTypeName = json['defectTypeName'];
    expectedFinishDate = json['expectedFinishDate'];
    responseRequestBy = json['responseRequestBy'];
    creatorUserId = json['creatorUserId'];
    isCloseOut = json['isCloseOut'];
    statusUpdateDate = json['statusUpdateDate'];
    workPackage = json['ObservationDefectType'];
  }

  ObservationData.fromJsonDB(Map<String, dynamic> json) {
    observationId = json['ObservationId'];
    locationId = json['LocationId'];
    folderId = json['FolderId'].toString();
    msgId = json['MessageId'].toString();
    formId = json['FormId'].toString();
    formTypeId = json['FormTypeId'].toString();
    annotationId = json['AnnotationId'].toString();
    revisionId = json['revisionId'].toString();
    coordinates = json['ObservationCoordinates'];
    hasAttachment = json['HasAttachments'] == 1 ? true : false;
    Map<String, dynamic> data = {};
    data['statusId'] = json['StatusId'];
    data['statusName'] = json['StatusName'];
    data['statusTypeId'] = json['StatusId'];
    data['statusCount'] = 0;
    data['bgColor'] = json['bgColor'] ?? '#808080';
    data['fontColor'] = json['fontColor'] ?? '#000000';
    data['generateURI'] = false;

    statusVO = StatusVO.fromJson(data);
    Map<String, dynamic> user = {};
    user['userID'] = json['AssignedToUserId'];
    user['recipientFullName'] = json['AssignedToUserName'] ?? json['StatusName'];
    user['userOrgName'] = json['OrgName'];
    user['projectId'] = json['ProjectId'];
    user['dueDays'] = json['FormDueDays'];
    user['distListId'] = '0';
    user['generateURI'] = false;

    recipientList = <RecipientList>[];
    //json['recipientList'].forEach((v) {
    recipientList!.add(RecipientList.fromJson(user));
    if (json['actions'] != null) {
      actions = <Actions>[];
      json['actions'].forEach((v) {
        actions!.add(Actions.fromJson(v));
      });
    }

    locationDetailVO = LocationDetailVO.fromJsonDB(json);
    isActive = json['IsActive'] == 1 ? true : false;
    isSyncIndexUpdate = json['IsSync'] == 1 ? true : false;
    isSyncPending = json['isSyncPending'] == false ? false : true;
    commId = json['FormId'].toString();
    formTitle = json['FormTitle'];
    formDueDays = int.tryParse(json['FormDueDays']) ?? 0;
    if(json.containsKey('page_number')){
      pageNumber = int.tryParse(json['page_number'].toString()) ?? 0;
    }else{
      pageNumber = int.tryParse(json['PageNumber'].toString()) ?? 0;
    }

    templateType = json['TemplateType'];
    formTypeCode = json['Code'].toString();
    appBuilderID = json['AppBuilderId'].toString();
    creatorUserName = '${json['FirstName']} ${json['LastName']}';
    creatorOrgName = json['OrgName'];
    formCode = json['Code'].toString();
    formCreationDate = json['FormCreationDate'];
    appType = json['AppTypeId'];
    projectId = json['ProjectId'].toString();
    generateURI = json['generateURI'] == 1 ? true : false;
    defectTypeName = json['ObservationDefectType'];
    expectedFinishDate = json['ExpectedFinishDate'];
    responseRequestBy = json['responseRequestBy'] ?? "";
    creatorUserId = int.tryParse(json['OriginatorId'].toString());
    isCloseOut = json['IsCloseOut'] == 1 ? true : false;
    statusUpdateDate = json['StatusUpdateDate'];
    workPackage = json['ObservationDefectType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['observationId'] = observationId;
    data['locationId'] = locationId;
    data['folderId'] = folderId;
    data['msgId'] = msgId;
    data['formId'] = formId;
    data['formTypeId'] = formTypeId;
    data['annotationId'] = annotationId;
    data['revisionId'] = revisionId;
    data['coordinates'] = coordinates;
    data['hasAttachment'] = hasAttachment;
    if (statusVO != null) {
      data['statusVO'] = statusVO!.toJson();
    }
    if (recipientList != null) {
      data['recipientList'] = recipientList!.map((v) => v.toJson()).toList();
    }
    if (actions != null) {
      data['actions'] = actions!.map((v) => v.toJson()).toList();
    }
    if (locationDetailVO != null) {
      data['locationDetailVO'] = locationDetailVO!.toJson();
    }
    data['isActive'] = isActive;
    data['isSyncIndexUpdate'] = isSyncIndexUpdate;
    data['isSyncPending'] = isSyncPending;
    data['commId'] = commId;
    data['formTitle'] = formTitle;
    data['formDueDays'] = formDueDays;
    data['pageNumber'] = pageNumber;
    data['templateType'] = templateType;
    data['formTypeCode'] = formTypeCode;
    data['appBuilderID'] = appBuilderID;
    data['creatorUserName'] = creatorUserName;
    data['creatorOrgName'] = creatorOrgName;
    data['formCode'] = formCode;
    data['formCreationDate'] = formCreationDate;
    data['appType'] = appType;
    data['projectId'] = projectId;
    data['generateURI'] = generateURI;
    data['defectTypeName'] = defectTypeName;
    data['expectedFinishDate'] = expectedFinishDate;
    data['responseRequestBy'] = responseRequestBy;
    data['creatorUserId'] = creatorUserId;
    data['isCloseOut'] = isCloseOut;
    data['statusUpdateDate'] = statusUpdateDate;
    data['ObservationDefectType'] = workPackage;
    return data;
  }

  static List<ObservationData> jsonToObservationList( dynamic response) {
    var jsonData = json.decode(response);
    return List<ObservationData>.from(jsonData.map((x) => ObservationData.fromJson(x))).toList();
  }

  @override
  List<Object?> get props => [];
}

class StatusVO {
  int? statusId;
  String? statusName;
  int? statusTypeId;
  int? statusCount;
  String? bgColor;
  String? fontColor;
  bool? generateURI;

  StatusVO({this.statusId, this.statusName, this.statusTypeId, this.statusCount, this.bgColor, this.fontColor, this.generateURI});

  StatusVO.fromJson(Map<String, dynamic> json) {
    statusId = int.tryParse(json['statusId'].toString());
    statusName = json['statusName'];
    statusTypeId = int.tryParse(json['statusTypeId'].toString());
    statusCount = int.tryParse(json['statusCount'].toString());
    bgColor = json['bgColor'];
    fontColor = json['fontColor'];
    generateURI = json['generateURI'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusId'] = statusId;
    data['statusName'] = statusName;
    data['statusTypeId'] = statusTypeId;
    data['statusCount'] = statusCount;
    data['bgColor'] = bgColor;
    data['fontColor'] = fontColor;
    data['generateURI'] = generateURI;
    return data;
  }
}

class RecipientList {
  String? userID;
  String? recipientFullName;
  String? userOrgName;
  String? projectId;
  int? dueDays;
  int? distListId;
  bool? generateURI;

  RecipientList({this.userID, this.recipientFullName, this.userOrgName, this.projectId, this.dueDays, this.distListId, this.generateURI});

  RecipientList.fromJson(Map<String, dynamic> json) {
    userID = json['userID'].toString();
    projectId = json['projectId'].toString();
    dueDays = ((json['dueDays'].runtimeType == String) ? int.tryParse(json['dueDays'] ?? "0") : json['dueDays']) ?? 0;
    distListId = ((json['distListId'].runtimeType == String) ? int.tryParse(json['distListId'] ?? "0") : json['distListId']) ?? 0;
    generateURI = json['generateURI'] == "1" ? true : false;
    recipientFullName = json['recipientFullName'];
    userOrgName = json['userOrgName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userID'] = userID;
    data['projectId'] = projectId;
    data['recipientFullName'] = recipientFullName;
    data['userOrgName'] = userOrgName;
    data['dueDays'] = dueDays;
    data['distListId'] = distListId;
    data['generateURI'] = generateURI;
    return data;
  }
}

class Actions {
  String? projectId;
  int? resourceParentId;
  int? resourceId;
  String? resourceCode;
  int? resourceStatusId;
  String? msgId;
  String? commentMsgId;
  dynamic actionId;
  String? actionName;
  dynamic actionStatus;
  int? priorityId;
  String? actionDate;
  String? dueDate;
  int? distributorUserId;
  dynamic recipientId;
  String? remarks;
  int? distListId;
  String? actionTime;
  String? actionNotes;
  int? entityType;
  String? instanceGroupId;
  bool? isActive;
  String? modelId;
  String? assignedBy;
  String? recipientName;
  String? recipientOrgId;
  String? viewDate;
  dynamic dueDateInMS;
  dynamic actionCompleteDateInMS;
  bool? actionDelegated;
  bool? actionCleared;
  bool? actionCompleted;
  bool? generateURI;

  Actions({this.projectId, this.resourceParentId, this.resourceId, this.resourceCode, this.resourceStatusId, this.msgId, this.commentMsgId, this.actionId, this.actionName, this.actionStatus, this.priorityId, this.actionDate, this.dueDate, this.distributorUserId, this.recipientId, this.remarks, this.distListId, this.actionTime, this.actionNotes, this.entityType, this.instanceGroupId, this.isActive, this.modelId, this.assignedBy, this.recipientName, this.recipientOrgId, this.viewDate, this.dueDateInMS, this.actionCompleteDateInMS, this.actionDelegated, this.actionCleared, this.actionCompleted, this.generateURI});

  Actions.fromJson(Map<String, dynamic> json) {
    projectId = json['projectId'];
    resourceParentId = json['resourceParentId'];
    resourceId = json['resourceId'];
    resourceCode = json['resourceCode'];
    resourceStatusId = json['resourceStatusId'];
    msgId = json['msgId'];
    commentMsgId = json['commentMsgId'];
    actionId = json['actionId'];
    actionName = json['actionName'];
    actionStatus = json['actionStatus'];
    priorityId = json['priorityId'];
    actionDate = json['actionDate'];
    dueDate = json['dueDate'];
    distributorUserId = json['distributorUserId'];
    recipientId = json['recipientId'];
    remarks = json['remarks'];
    distListId = json['distListId'];
    actionTime = json['actionTime'];
    actionNotes = json['actionNotes'];
    entityType = json['entityType'];
    instanceGroupId = json['instanceGroupId'];
    isActive = json['isActive'];
    modelId = json['modelId'];
    assignedBy = json['assignedBy'];
    recipientName = json['recipientName'];
    recipientOrgId = json['recipientOrgId'];
    viewDate = json['viewDate'];
    dueDateInMS = json['dueDateInMS'];
    actionCompleteDateInMS = json['actionCompleteDateInMS'];
    actionDelegated = json['actionDelegated'];
    actionCleared = json['actionCleared'];
    actionCompleted = json['actionCompleted'];
    generateURI = json['generateURI'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['projectId'] = projectId;
    data['resourceParentId'] = resourceParentId;
    data['resourceId'] = resourceId;
    data['resourceCode'] = resourceCode;
    data['resourceStatusId'] = resourceStatusId;
    data['msgId'] = msgId;
    data['commentMsgId'] = commentMsgId;
    data['actionId'] = actionId;
    data['actionName'] = actionName;
    data['actionStatus'] = actionStatus;
    data['priorityId'] = priorityId;
    data['actionDate'] = actionDate;
    data['dueDate'] = dueDate;
    data['distributorUserId'] = distributorUserId;
    data['recipientId'] = recipientId;
    data['remarks'] = remarks;
    data['distListId'] = distListId;
    data['actionTime'] = actionTime;
    data['actionNotes'] = actionNotes;
    data['entityType'] = entityType;
    data['instanceGroupId'] = instanceGroupId;
    data['isActive'] = isActive;
    data['modelId'] = modelId;
    data['assignedBy'] = assignedBy;
    data['recipientName'] = recipientName;
    data['recipientOrgId'] = recipientOrgId;
    data['viewDate'] = viewDate;
    data['dueDateInMS'] = dueDateInMS;
    data['actionCompleteDateInMS'] = actionCompleteDateInMS;
    data['actionDelegated'] = actionDelegated;
    data['actionCleared'] = actionCleared;
    data['actionCompleted'] = actionCompleted;
    data['generateURI'] = generateURI;
    return data;
  }
}

class LocationDetailVO {
  int? siteId;
  int? locationId;
  String? folderId;
  String? docId;
  String? revisionId;
  String? annotationId;
  String? coordinates;
  bool? isFileAssociated;
  bool? hasChildLocation;
  int? parentLocationId;
  String? locationPath;
  bool? isPFSite;
  bool? isCalibrated;
  bool? isLocationActive;
  String? projectId;
  bool? generateURI;

  LocationDetailVO({this.siteId, this.locationId, this.folderId, this.docId, this.revisionId, this.annotationId, this.coordinates, this.isFileAssociated, this.hasChildLocation, this.parentLocationId, this.locationPath, this.isPFSite, this.isCalibrated, this.isLocationActive, this.projectId, this.generateURI});

  LocationDetailVO.fromJson(Map<String, dynamic> json) {
    siteId = json['siteId'];
    locationId = json['locationId'];
    folderId = json['folderId'];
    docId = json['docId'];
    revisionId = json['revisionId'];
    annotationId = json['annotationId'];
    coordinates = json['coordinates'];
    isFileAssociated = json['isFileAssociated'];
    hasChildLocation = json['hasChildLocation'];
    parentLocationId = json['parentLocationId'];
    locationPath = json['locationPath'];
    isPFSite = json['isPFSite'];
    isCalibrated = json['isCalibrated'];
    isLocationActive = json['isLocationActive'];
    projectId = json['projectId'];
    generateURI = json['generateURI'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['siteId'] = siteId;
    data['locationId'] = locationId;
    data['folderId'] = folderId;
    data['docId'] = docId;
    data['revisionId'] = revisionId;
    data['annotationId'] = annotationId;
    data['coordinates'] = coordinates;
    data['isFileAssociated'] = isFileAssociated;
    data['hasChildLocation'] = hasChildLocation;
    data['parentLocationId'] = parentLocationId;
    data['locationPath'] = locationPath;
    data['isPFSite'] = isPFSite;
    data['isCalibrated'] = isCalibrated;
    data['isLocationActive'] = isLocationActive;
    data['projectId'] = projectId;
    data['generateURI'] = generateURI;
    return data;
  }

  LocationDetailVO.fromJsonDB(Map<String, dynamic> json) {
    siteId = json['SiteId'] ?? 0;
    locationId = json['LocationId'];
    folderId = json['FolderId']?.toString();
    docId = json['DocId'];
    revisionId = json['RevisionId'];
    annotationId = json['AnnotationId'];
    coordinates = json['ObservationCoordinates'];
    isFileAssociated = json['IsFileAssociated'] ?? false;
    hasChildLocation = json['HasChildLocation'] ?? false;
    parentLocationId = json['ParentLocationId'];
    locationPath = json['LocationPath'];
    isPFSite = json['IsPFSite'] ?? false;
    isCalibrated = json['IsCalibrated'] == 1;
    isLocationActive = json['IsActive'] == 1;
    projectId = json['ProjectId']?.toString();
    generateURI = json['GenerateURI'] ?? false;
  }
}
