// To parse this JSON data, do
//
//     final taskFormListingReponse = taskFormListingReponseFromJson(jsonString);

import 'dart:convert';

TaskFormListingResponse taskFormListingReponseFromJson(String str) => TaskFormListingResponse.fromJson(json.decode(str));

String taskFormListingReponseToJson(TaskFormListingResponse data) => json.encode(data.toJson());

class TaskFormListingResponse {
  List<ElementVoList> elementVoList;
  List<CommonAttribute> commonAttributes;

  TaskFormListingResponse({
    required this.elementVoList,
    required this.commonAttributes,
  });

  factory TaskFormListingResponse.fromJson(Map<String, dynamic> json) => TaskFormListingResponse(
    elementVoList: List<ElementVoList>.from(json["elementVOList"].map((x) => ElementVoList.fromJson(x))),
    commonAttributes: List<CommonAttribute>.from(json["commonAttributes"].map((x) => CommonAttribute.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "elementVOList": List<dynamic>.from(elementVoList.map((x) => x.toJson())),
    "commonAttributes": List<dynamic>.from(commonAttributes.map((x) => x.toJson())),
  };
}

class CommonAttribute {
  String? collection;
  String? results;
  String? resultsTotal;

  CommonAttribute({
    this.collection,
    this.results,
    this.resultsTotal,
  });

  factory CommonAttribute.fromJson(Map<String, dynamic> json) => CommonAttribute(
    collection: json["collection"],
    results: json["results"],
    resultsTotal: json["results-total"],
  );

  Map<String, dynamic> toJson() => {
    "collection": collection,
    "results": results,
    "results-total": resultsTotal,
  };
}

class ElementVoList {
  String projectId;
  String projectName;
  String code;
  String commId;
  String formId;
  String title;
  String userId;
  String orgId;
  String firstName;
  String lastName;
  String orgName;
  String originator;
  String originatorDisplayName;
  int noOfActions;
  int observationId;
  int locationId;
  int pfLocFolderId;
  DateTime updated;
  String duration;
  bool hasAttachments;
  String attachmentImageName;
  String msgCode;
  String typeImage;
  String docType;
  String formTypeName;
  String userRefCode;
  String status;
  String responseRequestBy;
  bool hasDocAssocations;
  bool hasBimViewAssociations;
  bool hasBimListAssociations;
  bool hasFormAssocations;
  bool hasCommentAssocations;
  bool formHasAssocAttach;
  bool msgHasAssocAttach;
  String formCreationDate;
  String msgCreatedDate;
  String folderId;
  String msgId;
  int parentMsgId;
  int msgTypeId;
  int msgStatusId;
  int indent;
  String formTypeId;
  int formNum;
  int msgOriginatorId;
  bool formPrintEnabled;
  int showPrintIcon;
  int templateType;
  String instanceGroupId;
  int noOfMessages;
  bool isDraft;
  int dcId;
  int statusid;
  int originatorId;
  bool isCloseOut;
  bool isStatusChangeRestricted;
  String projectApdFolderId;
  bool allowReopenForm;
  bool hasOverallStatus;
  List<dynamic> formUserSet;
  bool canOrigChangeStatus;
  bool canControllerChangeStatus;
  String appType;
  String formGroupName;
  String id;
  String statusText;
  int statusChangeUserId;
  String statusUpdateDate;
  String statusChangeUserName;
  String statusChangeUserPic;
  String statusChangeUserEmail;
  String statusChangeUserOrg;
  String originatorEmail;
  StatusRecordStyle statusRecordStyle;
  String invoiceCountAgainstOrder;
  String invoiceColourCode;
  int controllerUserId;
  String offlineFormId;
  CustomFieldsValueVOs customFieldsValueVOs;
  int updatedDateInMs;
  int formCreationDateInMs;
  int msgCreatedDateInMs;
  int flagType;
  String latestDraftId;
  String messageTypeImageName;
  bool hasFormAccess;
  String ownerOrgName;
  int ownerOrgId;
  int originatorOrgId;
  int msgUserOrgId;
  String msgUserOrgName;
  String msgUserName;
  String originatorName;
  bool isPublic;
  int responseRequestByInMs;
  int actionDateInMs;
  String formGroupCode;
  bool isThumbnailSupports;
  bool canAccessHistory;
  int projectStatusId;
  bool generateUri;

  ElementVoList({
    required this.projectId,
    required this.projectName,
    required this.code,
    required this.commId,
    required this.formId,
    required this.title,
    required this.userId,
    required this.orgId,
    required this.firstName,
    required this.lastName,
    required this.orgName,
    required this.originator,
    required this.originatorDisplayName,
    required this.noOfActions,
    required this.observationId,
    required this.locationId,
    required this.pfLocFolderId,
    required this.updated,
    required this.duration,
    required this.hasAttachments,
    required this.attachmentImageName,
    required this.msgCode,
    required this.typeImage,
    required this.docType,
    required this.formTypeName,
    required this.userRefCode,
    required this.status,
    required this.responseRequestBy,
    required this.hasDocAssocations,
    required this.hasBimViewAssociations,
    required this.hasBimListAssociations,
    required this.hasFormAssocations,
    required this.hasCommentAssocations,
    required this.formHasAssocAttach,
    required this.msgHasAssocAttach,
    required this.formCreationDate,
    required this.msgCreatedDate,
    required this.folderId,
    required this.msgId,
    required this.parentMsgId,
    required this.msgTypeId,
    required this.msgStatusId,
    required this.indent,
    required this.formTypeId,
    required this.formNum,
    required this.msgOriginatorId,
    required this.formPrintEnabled,
    required this.showPrintIcon,
    required this.templateType,
    required this.instanceGroupId,
    required this.noOfMessages,
    required this.isDraft,
    required this.dcId,
    required this.statusid,
    required this.originatorId,
    required this.isCloseOut,
    required this.isStatusChangeRestricted,
    required this.projectApdFolderId,
    required this.allowReopenForm,
    required this.hasOverallStatus,
    required this.formUserSet,
    required this.canOrigChangeStatus,
    required this.canControllerChangeStatus,
    required this.appType,
    required this.formGroupName,
    required this.id,
    required this.statusText,
    required this.statusChangeUserId,
    required this.statusUpdateDate,
    required this.statusChangeUserName,
    required this.statusChangeUserPic,
    required this.statusChangeUserEmail,
    required this.statusChangeUserOrg,
    required this.originatorEmail,
    required this.statusRecordStyle,
    required this.invoiceCountAgainstOrder,
    required this.invoiceColourCode,
    required this.controllerUserId,
    required this.offlineFormId,
    required this.customFieldsValueVOs,
    required this.updatedDateInMs,
    required this.formCreationDateInMs,
    required this.msgCreatedDateInMs,
    required this.flagType,
    required this.latestDraftId,
    required this.messageTypeImageName,
    required this.hasFormAccess,
    required this.ownerOrgName,
    required this.ownerOrgId,
    required this.originatorOrgId,
    required this.msgUserOrgId,
    required this.msgUserOrgName,
    required this.msgUserName,
    required this.originatorName,
    required this.isPublic,
    required this.responseRequestByInMs,
    required this.actionDateInMs,
    required this.formGroupCode,
    required this.isThumbnailSupports,
    required this.canAccessHistory,
    required this.projectStatusId,
    required this.generateUri,
  });

  factory ElementVoList.fromJson(Map<String, dynamic> json) => ElementVoList(
    projectId: json["projectId"],
    projectName: json["projectName"],
    code: json["code"],
    commId: json["commId"],
    formId: json["formId"],
    title: json["title"] ?? "",
    userId: json["userID"],
    orgId: json["orgId"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    orgName: json["orgName"],
    originator: json["originator"],
    originatorDisplayName: json["originatorDisplayName"],
    noOfActions: json["noOfActions"],
    observationId: json["observationId"],
    locationId: json["locationId"],
    pfLocFolderId: json["pfLocFolderId"],
    updated: DateTime.parse(json["updated"]),
    duration: json["duration"],
    hasAttachments: json["hasAttachments"],
    attachmentImageName: json["attachmentImageName"],
    msgCode: json["msgCode"],
    typeImage: json["typeImage"],
    docType: json["docType"],
    formTypeName: json["formTypeName"],
    userRefCode: json["userRefCode"] ?? "",
    status: json["status"] ?? "",
    responseRequestBy: json["responseRequestBy"] ??"",
    hasDocAssocations: json["hasDocAssocations"]??"",
    hasBimViewAssociations: json["hasBimViewAssociations"]??"",
    hasBimListAssociations: json["hasBimListAssociations"]??"",
    hasFormAssocations: json["hasFormAssocations"] ??"",
    hasCommentAssocations: json["hasCommentAssocations"] ?? "",
    formHasAssocAttach: json["formHasAssocAttach"]??"",
    msgHasAssocAttach: json["msgHasAssocAttach"] ??"",
    formCreationDate: json["formCreationDate"]??"",
    msgCreatedDate: json["msgCreatedDate"]??"",
    folderId: json["folderId"],
    msgId: json["msgId"],
    parentMsgId: json["parentMsgId"],
    msgTypeId: json["msgTypeId"],
    msgStatusId: json["msgStatusId"],
    indent: json["indent"],
    formTypeId: json["formTypeId"],
    formNum: json["formNum"],
    msgOriginatorId: json["msgOriginatorId"],
    formPrintEnabled: json["formPrintEnabled"],
    showPrintIcon: json["showPrintIcon"],
    templateType: json["templateType"],
    instanceGroupId: json["instanceGroupId"],
    noOfMessages: json["noOfMessages"],
    isDraft: json["isDraft"],
    dcId: json["dcId"],
    statusid: json["statusid"],
    originatorId: json["originatorId"],
    isCloseOut: json["isCloseOut"],
    isStatusChangeRestricted: json["isStatusChangeRestricted"],
    projectApdFolderId: json["project_APD_folder_id"],
    allowReopenForm: json["allowReopenForm"],
    hasOverallStatus: json["hasOverallStatus"],
    formUserSet: List<dynamic>.from(json["formUserSet"].map((x) => x)),
    canOrigChangeStatus: json["canOrigChangeStatus"],
    canControllerChangeStatus: json["canControllerChangeStatus"],
    appType: json["appType"],
    formGroupName: json["formGroupName"],
    id: json["id"],
    statusText: json["statusText"] ?? "",
    statusChangeUserId: json["statusChangeUserId"] ?? "",
    statusUpdateDate: json["statusUpdateDate"] ?? '',
    statusChangeUserName: json["statusChangeUserName"] ?? '',
    statusChangeUserPic: json["statusChangeUserPic"] ?? "",
    statusChangeUserEmail: json["statusChangeUserEmail"] ?? "",
    statusChangeUserOrg: json["statusChangeUserOrg"] ?? "",
    originatorEmail: json["originatorEmail"] ?? "",
    statusRecordStyle: json["statusRecordStyle"] != null ? StatusRecordStyle.fromJson(json["statusRecordStyle"]):StatusRecordStyle(settingApplyOn: 1, fontType: "fontType", fontEffect: "fontEffect", fontColor: "fontColor", backgroundColor: "#45ffff", isForOnlyStyleUpdate: true, alwaysActive: false, userId: 44, isDeactive: true, defaultPermissionId: 1, statusName: "statusName", statusId: 34, statusTypeId: 44, projectId: "", orgId: "33", proxyUserId: 22, isEnableForReviewComment: true, generateUri: true),
    invoiceCountAgainstOrder: json["invoiceCountAgainstOrder"] ?? "",
    invoiceColourCode: json["invoiceColourCode"]??"",
    controllerUserId: json["controllerUserId"]??"",
    offlineFormId: json["offlineFormId"]??"",
    customFieldsValueVOs: CustomFieldsValueVOs.fromJson(json["customFieldsValueVOs"]),
    updatedDateInMs: json["updatedDateInMS"],
    formCreationDateInMs: json["formCreationDateInMS"],
    msgCreatedDateInMs: json["msgCreatedDateInMS"],
    flagType: json["flagType"],
    latestDraftId: json["latestDraftId"],
    messageTypeImageName: json["messageTypeImageName"],
    hasFormAccess: json["hasFormAccess"],
    ownerOrgName: json["ownerOrgName"],
    ownerOrgId: json["ownerOrgId"],
    originatorOrgId: json["originatorOrgId"],
    msgUserOrgId: json["msgUserOrgId"],
    msgUserOrgName: json["msgUserOrgName"],
    msgUserName: json["msgUserName"],
    originatorName: json["originatorName"],
    isPublic: json["isPublic"],
    responseRequestByInMs: json["responseRequestByInMS"],
    actionDateInMs: json["actionDateInMS"],
    formGroupCode: json["formGroupCode"],
    isThumbnailSupports: json["isThumbnailSupports"],
    canAccessHistory: json["canAccessHistory"],
    projectStatusId: json["projectStatusId"],
    generateUri: json["generateURI"],
  );

  Map<String, dynamic> toJson() => {
    "projectId": projectId,
    "projectName": projectName,
    "code": code,
    "commId": commId,
    "formId": formId,
    "title": title,
    "userID": userId,
    "orgId": orgId,
    "firstName": firstName,
    "lastName": lastName,
    "orgName": orgName,
    "originator": originator,
    "originatorDisplayName": originatorDisplayName,
    "noOfActions": noOfActions,
    "observationId": observationId,
    "locationId": locationId,
    "pfLocFolderId": pfLocFolderId,
    "updated": updated.toIso8601String(),
    "duration": duration,
    "hasAttachments": hasAttachments,
    "attachmentImageName": attachmentImageName,
    "msgCode": msgCode,
    "typeImage": typeImage,
    "docType": docType,
    "formTypeName": formTypeName,
    "userRefCode": userRefCode,
    "status": status,
    "responseRequestBy": responseRequestBy,
    "hasDocAssocations": hasDocAssocations,
    "hasBimViewAssociations": hasBimViewAssociations,
    "hasBimListAssociations": hasBimListAssociations,
    "hasFormAssocations": hasFormAssocations,
    "hasCommentAssocations": hasCommentAssocations,
    "formHasAssocAttach": formHasAssocAttach,
    "msgHasAssocAttach": msgHasAssocAttach,
    "formCreationDate": formCreationDate,
    "msgCreatedDate": msgCreatedDate,
    "folderId": folderId,
    "msgId": msgId,
    "parentMsgId": parentMsgId,
    "msgTypeId": msgTypeId,
    "msgStatusId": msgStatusId,
    "indent": indent,
    "formTypeId": formTypeId,
    "formNum": formNum,
    "msgOriginatorId": msgOriginatorId,
    "formPrintEnabled": formPrintEnabled,
    "showPrintIcon": showPrintIcon,
    "templateType": templateType,
    "instanceGroupId": instanceGroupId,
    "noOfMessages": noOfMessages,
    "isDraft": isDraft,
    "dcId": dcId,
    "statusid": statusid,
    "originatorId": originatorId,
    "isCloseOut": isCloseOut,
    "isStatusChangeRestricted": isStatusChangeRestricted,
    "project_APD_folder_id": projectApdFolderId,
    "allowReopenForm": allowReopenForm,
    "hasOverallStatus": hasOverallStatus,
    "formUserSet": List<dynamic>.from(formUserSet.map((x) => x)),
    "canOrigChangeStatus": canOrigChangeStatus,
    "canControllerChangeStatus": canControllerChangeStatus,
    "appType": appType,
    "formGroupName": formGroupName,
    "id": id,
    "statusText": statusText,
    "statusChangeUserId": statusChangeUserId,
    "statusUpdateDate": statusUpdateDate,
    "statusChangeUserName": statusChangeUserName,
    "statusChangeUserPic": statusChangeUserPic,
    "statusChangeUserEmail": statusChangeUserEmail,
    "statusChangeUserOrg": statusChangeUserOrg,
    "originatorEmail": originatorEmail,
    "statusRecordStyle": statusRecordStyle.toJson(),
    "invoiceCountAgainstOrder": invoiceCountAgainstOrder,
    "invoiceColourCode": invoiceColourCode,
    "controllerUserId": controllerUserId,
    "offlineFormId": offlineFormId,
    "customFieldsValueVOs": customFieldsValueVOs.toJson(),
    "updatedDateInMS": updatedDateInMs,
    "formCreationDateInMS": formCreationDateInMs,
    "msgCreatedDateInMS": msgCreatedDateInMs,
    "flagType": flagType,
    "latestDraftId": latestDraftId,
    "messageTypeImageName": messageTypeImageName,
    "hasFormAccess": hasFormAccess,
    "ownerOrgName": ownerOrgName,
    "ownerOrgId": ownerOrgId,
    "originatorOrgId": originatorOrgId,
    "msgUserOrgId": msgUserOrgId,
    "msgUserOrgName": msgUserOrgName,
    "msgUserName": msgUserName,
    "originatorName": originatorName,
    "isPublic": isPublic,
    "responseRequestByInMS": responseRequestByInMs,
    "actionDateInMS": actionDateInMs,
    "formGroupCode": formGroupCode,
    "isThumbnailSupports": isThumbnailSupports,
    "canAccessHistory": canAccessHistory,
    "projectStatusId": projectStatusId,
    "generateURI": generateUri,
  };
}

class CustomFieldsValueVOs {
  CustomFieldsValueVOs();

  factory CustomFieldsValueVOs.fromJson(Map<String, dynamic> json) => CustomFieldsValueVOs(
  );

  Map<String, dynamic> toJson() => {
  };
}

class StatusRecordStyle {
  int settingApplyOn;
  String fontType;
  String fontEffect;
  String fontColor;
  String backgroundColor;
  bool isForOnlyStyleUpdate;
  bool alwaysActive;
  int userId;
  bool isDeactive;
  int defaultPermissionId;
  String statusName;
  int statusId;
  int statusTypeId;
  String projectId;
  String orgId;
  int proxyUserId;
  bool isEnableForReviewComment;
  bool generateUri;

  StatusRecordStyle({
    required this.settingApplyOn,
    required this.fontType,
    required this.fontEffect,
    required this.fontColor,
    required this.backgroundColor,
    required this.isForOnlyStyleUpdate,
    required this.alwaysActive,
    required this.userId,
    required this.isDeactive,
    required this.defaultPermissionId,
    required this.statusName,
    required this.statusId,
    required this.statusTypeId,
    required this.projectId,
    required this.orgId,
    required this.proxyUserId,
    required this.isEnableForReviewComment,
    required this.generateUri,
  });

  factory StatusRecordStyle.fromJson(Map<String, dynamic> json) => StatusRecordStyle(
    settingApplyOn: json["settingApplyOn"],
    fontType: json["fontType"],
    fontEffect: json["fontEffect"],
    fontColor: json["fontColor"],
    backgroundColor: json["backgroundColor"],
    isForOnlyStyleUpdate: json["isForOnlyStyleUpdate"],
    alwaysActive: json["always_active"],
    userId: json["userId"],
    isDeactive: json["isDeactive"],
    defaultPermissionId: json["defaultPermissionId"],
    statusName: json["statusName"],
    statusId: json["statusID"],
    statusTypeId: json["statusTypeID"],
    projectId: json["projectId"],
    orgId: json["orgId"],
    proxyUserId: json["proxyUserId"],
    isEnableForReviewComment: json["isEnableForReviewComment"],
    generateUri: json["generateURI"],
  );

  Map<String, dynamic> toJson() => {
    "settingApplyOn": settingApplyOn,
    "fontType": fontType,
    "fontEffect": fontEffect,
    "fontColor": fontColor,
    "backgroundColor": backgroundColor,
    "isForOnlyStyleUpdate": isForOnlyStyleUpdate,
    "always_active": alwaysActive,
    "userId": userId,
    "isDeactive": isDeactive,
    "defaultPermissionId": defaultPermissionId,
    "statusName": statusName,
    "statusID": statusId,
    "statusTypeID": statusTypeId,
    "projectId": projectId,
    "orgId": orgId,
    "proxyUserId": proxyUserId,
    "isEnableForReviewComment": isEnableForReviewComment,
    "generateURI": generateUri,
  };
}