
import 'package:field/data/model/site_form_action.dart';
import 'package:field/utils/field_enums.dart';

class SiteForm {
  SiteForm({
    this.projectId,
    this.projectName,
    this.code,
    this.commId,
    this.formId,
    this.title,
    this.userID,
    this.orgId,
    this.originator,
    this.originatorDisplayName,
    this.noOfActions,
    this.observationId,
    this.locationId,
    this.pfLocFolderId,
    this.locationName,
    this.locationPath,
    this.updated,
    this.hasAttachments,
    this.msgCode,
    this.docType,
    this.formTypeName,
    this.statusText,
    this.responseRequestBy,
    this.hasDocAssocations,
    this.hasBimViewAssociations,
    this.hasBimListAssociations,
    this.hasFormAssocations,
    this.hasCommentAssocations,
    this.formHasAssocAttach,
    this.msgHasAssocAttach,
    this.formCreationDate,
    this.msgCreatedDate,
    this.msgId,
    this.parentMsgId,
    this.msgTypeId,
    this.msgStatusId,
    this.formTypeId,
    this.templateType,
    this.instanceGroupId,
    this.noOfMessages,
    this.isDraft,
    this.dcId,
    this.statusid,
    this.originatorId,
    this.isCloseOut,
    this.isStatusChangeRestricted,
    this.allowReopenForm,
    this.hasOverallStatus,
    this.canOrigChangeStatus,
    this.canControllerChangeStatus,
    this.appType,
    this.msgTypeCode,
    this.formGroupName,
    this.id,
    this.appTypeId,
    this.lastmodified,
    this.appBuilderId,
    this.CFID_TaskType,
    this.CFID_DefectTyoe,
    this.CFID_Assigned,
    this.statusRecordStyle,
    this.statusUpdateDate,
    this.isSiteFormSelected,
    this.attachmentImageName,
    this.firstName,
    this.lastName,
    this.folderId,
    this.formCreationDateInMS,
    this.responseRequestByInMS,
    this.updatedDateInMS,
    this.typeImage,
    this.status,
    this.statusName,
    this.statusChangeUserId,
    this.statusChangeUserPic,
    this.statusChangeUserOrg,
    this.statusChangeUserName,
    this.statusChangeUserEmail,
    this.orgName,
    this.originatorEmail,
    this.msgOriginatorId,
    this.formNum,
    this.controllerUserId,
    this.userRefCode,
    this.flagTypeImageName,
    this.formTypeCode,
    this.latestDraftId,
    this.canAccessHistory,
    this.observationCoordinates,
    this.annotationId,
    this.pageNumber,
    this.isActive,
    this.formDueDays,
    this.formSyncDate,
    this.startDate,
    this.expectedFinishDate,
    this.assignedToUserId,
    this.assignedToUserName,
    this.assignedToUserOrgName,
    this.assignedToRoleName,
    this.lastResponderForAssignedTo,
    this.lastResponderForOriginator,
    this.manageTypeId,
    this.manageTypeName,
    this.hasActions,
    this.flagType,
    this.messageTypeImageName,
    this.formJsonData,
    this.attachedDocs,
    this.isUploadAttachmentInTemp,
    this.isSync,
    this.isSyncPending,
    this.canRemoveOffline,
    this.isMarkOffline,
    this.isOfflineCreated,
    this.syncStatus,
    this.isForDefect,
    this.isForApps,
    this.observationDefectTypeId,
    this.msgNum,
    this.revisionId,
    this.requestJsonForOffline,
    this.observationDefectType,
    this.taskTypeName,
    this.workPackage
  });

  SiteForm.fromJson(dynamic json) {
    projectId = json['projectId'];
    projectName = json['projectName'];
    code = json['code'];
    commId = json['commId'];
    formId = json['formId'];
    title = json['title'];
    userID = json['userID'];
    orgId = json['orgId'];
    originator = json['originator'];
    originatorDisplayName = json['originatorDisplayName'];
    noOfActions = int.tryParse(json['noOfActions'].toString())??0;
    observationId = int.parse(json['observationId'].toString());
    locationId = int.parse(json['locationId'].toString());
    pfLocFolderId = int.tryParse(json['pfLocFolderId'].toString())??0;
    locationName = json['locationName'];
    locationPath = json['locationPath'];
    updated = json['updated'];
    hasAttachments = json['hasAttachments'];
    msgCode = json['msgCode'];
    docType = json['docType'];
    formTypeName = json['formTypeName'];
    taskTypeName = json['taskTypeName'];
    workPackage = json['workPackage'];
    statusText = json['statusText'];
    responseRequestBy = json['responseRequestBy'];
    hasDocAssocations = json['hasDocAssocations'];
    hasBimViewAssociations = json['hasBimViewAssociations'];
    hasBimListAssociations = json['hasBimListAssociations'];
    hasFormAssocations = json['hasFormAssocations'];
    hasCommentAssocations = json['hasCommentAssocations'];
    formHasAssocAttach = json['formHasAssocAttach'];
    msgHasAssocAttach = json['msgHasAssocAttach'];
    formCreationDate = json['formCreationDate'];
    msgCreatedDate = json['msgCreatedDate'];
    msgId = json['msgId'];
    parentMsgId = json['parentMsgId'].toString();
    msgTypeId = json['msgTypeId'].toString();
    msgStatusId = json['msgStatusId'].toString();
    formTypeId = json['formTypeId'];
    templateType = int.parse(json['templateType'].toString());
    instanceGroupId = json['instanceGroupId'];
    noOfMessages = json['noOfMessages'].toString();
    isDraft = json['isDraft'];
    dcId = json['dcId'].toString();
    statusid = json['statusid'].toString();
    originatorId = json['originatorId'].toString();
    isCloseOut = json['isCloseOut'] ?? false;
    isStatusChangeRestricted = json['isStatusChangeRestricted'];
    allowReopenForm = json['allowReopenForm'];
    hasOverallStatus = json['hasOverallStatus'];
    canOrigChangeStatus = json['canOrigChangeStatus'];
    canControllerChangeStatus = json['canControllerChangeStatus'];
    appType = json['appType'];
    msgTypeCode = json['msgTypeCode'];
    formGroupName = json['formGroupName'];
    id = json['id'] ?? "";
    appTypeId = int.parse(json['appTypeId'].toString());
    lastmodified = json['lastmodified'];
    appBuilderId = json['appBuilderId'];
    CFID_TaskType = json['CFID_TaskType'];
    CFID_DefectTyoe = json['CFID_DefectTyoe'];
    CFID_Assigned = json['CFID_Assigned'];
    statusRecordStyle = json['statusRecordStyle'];
    statusUpdateDate = json['statusUpdateDate'] ?? "";
    if (json['actions'] != null) {
      for (dynamic siteFormActionObj in json['actions']) {
        actions?.add(SiteFormAction.fromJson(siteFormActionObj));
      }
    }
    if (json["observationVO"] != null) {
      dynamic observationVONode = json["observationVO"];
      assignedToUserId = observationVONode['assignedToUserId'].toString();
      assignedToUserName = observationVONode['assignedToUserName'];
      assignedToUserOrgName = observationVONode['assignedToUserOrgName'];
      if (observationVONode['manageTypeVo'] != null) {
        Map<String,dynamic> manageTypeVoNode = observationVONode["manageTypeVo"];
        manageTypeId = manageTypeVoNode['id'];
        manageTypeName = manageTypeVoNode['name'];
         CFID_DefectTyoe = manageTypeVoNode['name'];
      }
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['projectId'] = projectId;
    map['projectName'] = projectName;
    map['code'] = code;
    map['commId'] = commId;
    map['formId'] = formId;
    map['title'] = title;
    map['userID'] = userID;
    map['orgId'] = orgId;
    map['firstName'] = firstName;
    map['lastName'] = lastName;
    map['orgName'] = orgName;
    map['originator'] = originator;
    map['originatorDisplayName'] = originatorDisplayName;
    map['noOfActions'] = noOfActions;
    map['observationId'] = observationId;
    map['locationId'] = locationId;
    map['pfLocFolderId'] = pfLocFolderId;
    map['updated'] = updated;
    map['hasAttachments'] = hasAttachments;
    map['attachmentImageName'] = attachmentImageName;
    map['msgCode'] = msgCode;
    map['typeImage'] = typeImage;
    map['docType'] = docType;
    map['formTypeName'] = formTypeName;
    map['status'] = status;
    map['responseRequestBy'] = responseRequestBy;
    map['responseRequestByInMS'] = responseRequestByInMS;
    map['hasDocAssocations'] = hasDocAssocations;
    map['hasBimViewAssociations'] = hasBimViewAssociations;
    map['hasBimListAssociations'] = hasBimListAssociations;
    map['hasFormAssocations'] = hasFormAssocations;
    map['hasCommentAssocations'] = hasCommentAssocations;
    map['formHasAssocAttach'] = formHasAssocAttach;
    map['msgHasAssocAttach'] = msgHasAssocAttach;
    map['formCreationDate'] = formCreationDate;
    map['folderId'] = folderId;
    map['msgId'] = msgId;
    map['parentMsgId'] = parentMsgId;
    map['msgTypeId'] = msgTypeId;
    map['msgStatusId'] = msgStatusId;
    map['formTypeId'] = formTypeId;
    map['formNum'] = formNum;
    map['msgOriginatorId'] = msgOriginatorId;
    map['templateType'] = templateType;
    map['instanceGroupId'] = instanceGroupId;
    map['noOfMessages'] = noOfMessages;
    map['isDraft'] = isDraft;
    map['dcId'] = dcId;
    map['statusid'] = statusid;
    map['originatorId'] = originatorId;
    map['isCloseOut'] = isCloseOut;
    map['isStatusChangeRestricted'] = isStatusChangeRestricted;
    map['allowReopenForm'] = allowReopenForm;
    map['hasOverallStatus'] = hasOverallStatus;
    map['canOrigChangeStatus'] = canOrigChangeStatus;
    map['canControllerChangeStatus'] = canControllerChangeStatus;
    map['appType'] = appType;
    map['msgTypeCode'] = msgTypeCode;
    map['formGroupName'] = formGroupName;
    map['id'] = id;
    map['statusText'] = statusText;
    map['statusChangeUserId'] = statusChangeUserId;
    map['statusUpdateDate'] = statusUpdateDate;
    map['statusChangeUserName'] = statusChangeUserName;
    map['statusChangeUserPic'] = statusChangeUserPic;
    map['statusChangeUserEmail'] = statusChangeUserEmail;
    map['statusChangeUserOrg'] = statusChangeUserOrg;
    map['originatorEmail'] = originatorEmail;
    if (statusRecordStyle != null) {
      map['statusRecordStyle'] = statusRecordStyle;
    }
    map['controllerUserId'] = controllerUserId;
    map['updatedDateInMS'] = updatedDateInMS;
    map['formCreationDateInMS'] = formCreationDateInMS;
    map['responseRequestByInMS'] = responseRequestByInMS;
    map['flagType'] = flagType;
    map['appTypeId'] = appTypeId;
    map['latestDraftId'] = latestDraftId;
    map['flagTypeImageName'] = flagTypeImageName;
    map['messageTypeImageName'] = messageTypeImageName;
    map['lastmodified'] = lastmodified;
    map['canAccessHistory'] = canAccessHistory;
    map['isSyncPending'] = isSyncPending;
    return map;
  }

  static List<SiteForm> offlineformListFromSyncJson(dynamic json) {
    return List<SiteForm>.from(json.map((element) => SiteForm.offlineformSyncJson(element))).toList();
  }


  SiteForm.offlineformSyncJson(dynamic json){
    projectId = json['projectId'];
    locationId = json['locationId'];
    commId = json['commId'];
    formId = json['formId'];
    formTypeId = json['formTypeId'];
    msgId = json['msgId'];
    observationId = json['observationId'];
    instanceGroupId = json['instanceGroupId'];
    appTypeId = int.parse(json['appTypeId']);
    code = json['code'];
    attachmentImageName = json['attachmentImageName'];
    docType = json['docType'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    folderId = json['folderId'];
    formCreationDate = json['formCreationDate'];
    formCreationDateInMS = json['formCreationDateInMS'].toString();
    responseRequestByInMS = json['responseRequestByInMS'].toString();
    updated = json['updated'];
    updatedDateInMS = json['updatedDateInMS'].toString();
    lastmodified = json['lastmodified'];
    typeImage = json['typeImage'];
    title = json['title'];
    statusid = json['statusid'].toString();
    status = json['status']??json['statusText'];
    statusName = status;
    statusChangeUserId = json['statusChangeUserId'];
    statusUpdateDate = json['statusUpdateDate'];
    statusChangeUserPic = json['statusChangeUserPic'];
    statusChangeUserOrg = json['statusChangeUserOrg'];
    statusChangeUserName = json['statusChangeUserName'];
    statusChangeUserEmail = json['statusChangeUserEmail'];
    msgCode = json['msgCode'];
    msgTypeCode = json['msgTypeCode'];
    orgId = json['orgId'];
    orgName = json['orgName'];
    originator = json['originator'];
    originatorId = json['originatorId'].toString();
    originatorDisplayName = json['originatorDisplayName'];
    originatorEmail = json['originatorEmail'];
    noOfActions = json['noOfActions'];
    msgTypeId = json['msgTypeId'].toString();
    msgStatusId = json['msgStatusId'].toString();
    msgOriginatorId = json['msgOriginatorId'];
    formNum = json['formNum'];
    templateType = json['templateType'];
    parentMsgId = json['parentMsgId'].toString();

    controllerUserId = json['controllerUserId'].toString();
    userRefCode = json['userRefCode'];
    pfLocFolderId = json['pfLocFolderId'];
    flagTypeImageName = json['flagTypeImageName'];
    appBuilderId = json['appBuilderId'];
    formTypeCode = json['formTypeCode'];
    formTypeName = json['formTypeName'];
    taskTypeName = json['taskTypeName'];
    workPackage = json['workPackage'];
    latestDraftId = json['latestDraftId'];
    isStatusChangeRestricted = json['isStatusChangeRestricted'];
    isDraft = json['isDraft'];
    CFID_TaskType = json['CFID_TaskType'];
    CFID_DefectTyoe = json['CFID_DefectTyoe'];
    CFID_Assigned = json['CFID_Assigned'];
    hasAttachments = json['hasAttachments'];
    formHasAssocAttach = json['formHasAssocAttach'];
    canOrigChangeStatus = json['canOrigChangeStatus'];
    canAccessHistory = json['canAccessHistory'];
    allowReopenForm = json['allowReopenForm'];
    hasDocAssocations = json['hasDocAssocations'];
    hasBimViewAssociations = json['hasBimViewAssociations'];
    hasBimListAssociations = json['hasBimListAssociations'];
    hasFormAssocations = json['hasFormAssocations'];
    hasCommentAssocations = json['hasCommentAssocations'];
    msgHasAssocAttach = json['msgHasAssocAttach'];
    isCloseOut = json['isCloseOut'];
    flagType = json['flagType'];

    messageTypeImageName = json['messageTypeImageName'];
    isSyncPending = json['isSyncPending'];
    if (json["observationVO"] != null) {
      dynamic observationVONode = json["observationVO"];
      observationCoordinates = observationVONode['observationCoordinates'];
      annotationId = observationVONode['annotationId'];
      pageNumber = observationVONode['pageNumber'];

      isActive = observationVONode['isActive'];
      formDueDays = observationVONode['formDueDays'];
      formSyncDate = observationVONode['formSyncDate'];

      startDate = observationVONode['startDate'];
      expectedFinishDate = observationVONode['expectedFinishDate'];
      assignedToUserId = observationVONode['assignedToUserId'].toString();
      assignedToUserName = observationVONode['assignedToUserName'];
      assignedToUserOrgName = observationVONode['assignedToUserOrgName'];
      assignedToRoleName = observationVONode['assignedToRoleName'];
      lastResponderForAssignedTo = observationVONode['lastResponderForAssignedTo'];
      lastResponderForOriginator = observationVONode['lastResponderForOriginator'];


      if (observationVONode['manageTypeVo'] != null) {
        Map<String,dynamic> manageTypeVoNode = observationVONode["manageTypeVo"];
        manageTypeId = manageTypeVoNode['id'];
        manageTypeName = manageTypeVoNode['name'];
        CFID_DefectTyoe = manageTypeVoNode['name'];
      }
    }
    hasActions = (((json["actions"]??[]) as List).isNotEmpty);
  }

  updateDisplayingContent(SiteForm obj) {
    projectId = obj.projectId;
    projectName = obj.projectName;
    code = obj.code;
    commId = obj.commId;
    formId = obj.formId;
    title = obj.title;
    userID = obj.userID;
    orgId = obj.orgId;
    originator = obj.originator;
    originatorDisplayName = obj.originatorDisplayName;
    noOfActions = obj.noOfActions;
    observationId = obj.observationId;
    locationId = obj.locationId;
    pfLocFolderId = obj.pfLocFolderId;
    updated = obj.updated;
    hasAttachments = obj.hasAttachments;
    msgCode = obj.msgCode;
    docType = obj.docType;
    formTypeName = obj.formTypeName;
    taskTypeName = obj.taskTypeName;
    workPackage = obj.workPackage;
    statusText = obj.statusText;
    responseRequestBy = obj.responseRequestBy;
    hasDocAssocations = obj.hasDocAssocations;
    hasBimViewAssociations = obj.hasBimViewAssociations;
    hasBimListAssociations = obj.hasBimListAssociations;
    hasFormAssocations = obj.hasFormAssocations;
    hasCommentAssocations = obj.hasCommentAssocations;
    formHasAssocAttach = obj.formHasAssocAttach;
    msgHasAssocAttach = obj.msgHasAssocAttach;
    formCreationDate = obj.formCreationDate;
    msgCreatedDate = obj.msgCreatedDate;
    msgId = obj.msgId;
    parentMsgId = obj.parentMsgId;
    msgTypeId = obj.msgTypeId;
    msgStatusId = obj.msgStatusId;
    formTypeId = obj.formTypeId;
    templateType = obj.templateType;
    instanceGroupId = obj.instanceGroupId;
    noOfMessages = obj.noOfMessages;
    isDraft = obj.isDraft;
    dcId = obj.dcId;
    statusid = obj.statusid;
    originatorId = obj.originatorId;
    isCloseOut = obj.isCloseOut;
    isStatusChangeRestricted = obj.isStatusChangeRestricted;
    allowReopenForm = obj.allowReopenForm;
    hasOverallStatus = obj.hasOverallStatus;
    canOrigChangeStatus = obj.canOrigChangeStatus;
    canControllerChangeStatus = obj.canControllerChangeStatus;
    appType = obj.appType;
    msgTypeCode = obj.msgTypeCode;
    formGroupName = obj.formGroupName;
    id = obj.id;
    appTypeId = obj.appTypeId;
    lastmodified = obj.lastmodified;
    appBuilderId = obj.appBuilderId;
    CFID_TaskType = obj.CFID_TaskType;
    CFID_DefectTyoe = obj.CFID_DefectTyoe;
    CFID_Assigned = obj.CFID_Assigned;
    statusRecordStyle = obj.statusRecordStyle;
    statusUpdateDate = obj.statusUpdateDate;
    actions = obj.actions;
  }

  String? projectId;
  String? projectName;
  String? code;
  String? commId;
  String? formId;
  String? title;
  String? userID;
  String? orgId;
  String? originator;
  String? originatorDisplayName;
  int? noOfActions;
  int? observationId;
  int? locationId;
  int? pfLocFolderId;
  String? locationName;
  String? locationPath;
  String? updated;
  bool? hasAttachments;
  String? msgCode;
  String? docType;
  String? formTypeName;
  String? statusText;
  String? responseRequestBy;
  bool? hasDocAssocations;
  bool? hasBimViewAssociations;
  bool? hasBimListAssociations;
  bool? hasFormAssocations;
  bool? hasCommentAssocations;
  bool? formHasAssocAttach;
  bool? msgHasAssocAttach;
  String? formCreationDate;
  String? msgCreatedDate;
  String? msgId;
  String? parentMsgId;
  String? msgTypeId;
  String? msgStatusId;
  String? formTypeId;
  int? templateType;
  String? instanceGroupId;
  String? noOfMessages;
  bool? isDraft;
  String? dcId;
  String? statusid;
  String? originatorId;
  bool? isCloseOut;
  bool? isStatusChangeRestricted;
  bool? allowReopenForm;
  bool? hasOverallStatus;
  bool? canOrigChangeStatus;
  bool? canControllerChangeStatus;
  String? appType;
  String? msgTypeCode;
  String? formGroupName;
  String? id;
  int? appTypeId;
  String? lastmodified;
  String? appBuilderId;
  String? CFID_TaskType;
  String? CFID_DefectTyoe;
  String? CFID_Assigned;
  dynamic statusRecordStyle;
  bool? isSiteFormSelected = false;
  String? statusUpdateDate;
  List<SiteFormAction> actions = [];
  String? attachmentImageName;
  String? firstName;
  String? lastName;
  String? folderId;
  String? formCreationDateInMS;
  String? responseRequestByInMS;
  String? updatedDateInMS;
  String? typeImage;
  String? status;
  String? statusName;
  int? statusChangeUserId;
  String? statusChangeUserPic;
  String? statusChangeUserOrg;
  String? statusChangeUserName;
  String? statusChangeUserEmail;
  String? orgName;
  String? originatorEmail;
  int? msgOriginatorId;
  int? formNum;
  String? controllerUserId;
  String? userRefCode;
  String? flagTypeImageName;
  String? formTypeCode;
  String? latestDraftId;
  bool? canAccessHistory;
  String? observationCoordinates;
  String? annotationId;
  int? pageNumber;
  bool? isActive;
  int? formDueDays;
  String? formSyncDate;
  String? startDate;
  String? expectedFinishDate;
  String? assignedToUserId;
  String? assignedToUserName;
  String? assignedToUserOrgName;
  String? assignedToRoleName;
  String? lastResponderForAssignedTo;
  String? lastResponderForOriginator;
  String? manageTypeId;
  String? manageTypeName;
  bool? hasActions = false;
  int? flagType;
  String? messageTypeImageName;
  String? formJsonData;
  String? attachedDocs;
  bool? isUploadAttachmentInTemp;
  bool? isSync;
  bool? isSyncPending;
  bool? canRemoveOffline;
  bool? isMarkOffline;
  bool? isOfflineCreated;
  ESyncStatus? syncStatus = ESyncStatus.failed;
  bool? isForDefect;
  bool? isForApps;
  int? observationDefectTypeId;
  int? msgNum;
  String? revisionId;
  String? requestJsonForOffline;
  String? observationDefectType;
  String? taskTypeName;
  String? workPackage;
  EHtmlRequestType? eHtmlRequestType;
}