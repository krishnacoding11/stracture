// To parse this JSON data, do
//
//     final offlineFolderList = offlineFolderListFromJson(jsonString);

import 'dart:convert';

OfflineFolderList offlineFolderListFromJson(String str) => OfflineFolderList.fromJson(json.decode(str));

String offlineFolderListToJson(OfflineFolderList data) => json.encode(data.toJson());

class OfflineFolderList {
  List<ResponseDatum> responseData;

  OfflineFolderList({
    required this.responseData,
  });

  factory OfflineFolderList.fromJson(Map<String, dynamic> json) => OfflineFolderList(
    responseData: List<ResponseDatum>.from(json["ResponseData"].map((x) => ResponseDatum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "ResponseData": List<dynamic>.from(responseData.map((x) => x.toJson())),
  };
}

class ResponseDatum {
  List<WorkspaceList>? workspaceList;
  List<ParentFolderList>? parentFolderList;
  List<dynamic>? childFolderList;

  ResponseDatum({
    this.workspaceList,
    this.parentFolderList,
    this.childFolderList,
  });

  factory ResponseDatum.fromJson(Map<String, dynamic> json) => ResponseDatum(
    workspaceList: json["workspaceList"] == null ? [] : List<WorkspaceList>.from(json["workspaceList"]!.map((x) => WorkspaceList.fromJson(x))),
    parentFolderList: json["parentFolderList"] == null ? [] : List<ParentFolderList>.from(json["parentFolderList"]!.map((x) => ParentFolderList.fromJson(x))),
    childFolderList: json["childFolderList"] == null ? [] : List<dynamic>.from(json["childFolderList"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "workspaceList": workspaceList == null ? [] : List<dynamic>.from(workspaceList!.map((x) => x.toJson())),
    "parentFolderList": parentFolderList == null ? [] : List<dynamic>.from(parentFolderList!.map((x) => x.toJson())),
    "childFolderList": childFolderList == null ? [] : List<dynamic>.from(childFolderList!.map((x) => x)),
  };
}

class ParentFolderList {
  String folderId;
  String folderTitle;
  int permissionId;
  int parentFolderId;
  List<dynamic> icFolderVo;
  bool isFavourite;
  bool isPublic;
  bool enableSimpleUpload;
  bool enableQrCode;
  bool enableAutoFetchRule;
  int navigatorAutoSyncType;
  bool isFolderStructureInherited;
  bool isActive;
  bool generateUri;

  ParentFolderList({
    required this.folderId,
    required this.folderTitle,
    required this.permissionId,
    required this.parentFolderId,
    required this.icFolderVo,
    required this.isFavourite,
    required this.isPublic,
    required this.enableSimpleUpload,
    required this.enableQrCode,
    required this.enableAutoFetchRule,
    required this.navigatorAutoSyncType,
    required this.isFolderStructureInherited,
    required this.isActive,
    required this.generateUri,
  });

  factory ParentFolderList.fromJson(Map<String, dynamic> json) => ParentFolderList(
    folderId: json["folderId"],
    folderTitle: json["folderTitle"],
    permissionId: json["permissionId"],
    parentFolderId: json["parentFolderId"],
    icFolderVo: List<dynamic>.from(json["ICFolderVO"].map((x) => x)),
    isFavourite: json["isFavourite"],
    isPublic: json["isPublic"],
    enableSimpleUpload: json["enableSimpleUpload"],
    enableQrCode: json["enableQRCode"],
    enableAutoFetchRule: json["enableAutoFetchRule"],
    navigatorAutoSyncType: json["navigatorAutoSyncType"],
    isFolderStructureInherited: json["isFolderStructureInherited"],
    isActive: json["isActive"],
    generateUri: json["generateURI"],
  );

  Map<String, dynamic> toJson() => {
    "folderId": folderId,
    "folderTitle": folderTitle,
    "permissionId": permissionId,
    "parentFolderId": parentFolderId,
    "ICFolderVO": List<dynamic>.from(icFolderVo.map((x) => x)),
    "isFavourite": isFavourite,
    "isPublic": isPublic,
    "enableSimpleUpload": enableSimpleUpload,
    "enableQRCode": enableQrCode,
    "enableAutoFetchRule": enableAutoFetchRule,
    "navigatorAutoSyncType": navigatorAutoSyncType,
    "isFolderStructureInherited": isFolderStructureInherited,
    "isActive": isActive,
    "generateURI": generateUri,
  };
}

class WorkspaceList {
  int iProjectId;
  int dcId;
  String projectName;
  String projectId;
  int parentId;
  int isWorkspace;
  String projectBaseUrl;
  String projectBaseUrlForCollab;
  String projectAdmins;
  bool isUserAdminforProj;
  bool bimEnabled;
  String? projectLogoPath;
  bool isFavorite;
  String privilege;
  bool canManageWorkspaceRoles;
  bool canManageWorkspaceFormStatus;
  bool isFromExchange;

  bool isTemplate;
  bool isCloned;
  int activeFilesCount;
  int formsCount;
  int statusId;
  int users;
  String clonedFrom;
  String? projectDescription;
  int fetchRuleId;
  bool canManageWorkspaceDocStatus;
  bool canCreateAutoFetchRule;
  int ownerOrgId;
  bool canManagePurposeOfIssue;
  bool canManageMailBox;
  bool editWorkspaceFormSettings;
  bool canAssignApps;
  bool canManageDistributionGroup;
  int defaultpermissiontypeid;
  bool checkoutPref;
  bool restrictDownloadOnCheckout;
  bool canManageAppSetting;
  int projectsubscriptiontypeid;
  bool canManageCustomAttribute;
  bool isAdminAccess;
  bool isUseAccess;
  bool canManageWorkflowRules;
  bool canAccessAuditInformation;
  int countryId;
  int projectSpaceTypeId;
  bool isWatching;
  bool canManageRolePrivileges;
  bool canManageFormPermissions;
  bool canManageProjectInvitations;
  bool enableCommentReview;
  int projectViewerId;
  bool isShared;
  bool insertInStorageSpace;
  int colorid;
  int iconid;
  int businessid;
  bool generateUri;
  String? postalCode;
  DateTime? logoUpdateDateTime;

  WorkspaceList({
    required this.iProjectId,
    required this.dcId,
    required this.projectName,
    required this.projectId,
    required this.parentId,
    required this.isWorkspace,
    required this.projectBaseUrl,
    required this.projectBaseUrlForCollab,
    required this.projectAdmins,
    required this.isUserAdminforProj,
    required this.bimEnabled,
    this.projectLogoPath,
    required this.isFavorite,
    required this.privilege,
    required this.canManageWorkspaceRoles,
    required this.canManageWorkspaceFormStatus,
    required this.isFromExchange,
    required this.isTemplate,
    required this.isCloned,
    required this.activeFilesCount,
    required this.formsCount,
    required this.statusId,
    required this.users,
    required this.clonedFrom,
    this.projectDescription,
    required this.fetchRuleId,
    required this.canManageWorkspaceDocStatus,
    required this.canCreateAutoFetchRule,
    required this.ownerOrgId,
    required this.canManagePurposeOfIssue,
    required this.canManageMailBox,
    required this.editWorkspaceFormSettings,
    required this.canAssignApps,
    required this.canManageDistributionGroup,
    required this.defaultpermissiontypeid,
    required this.checkoutPref,
    required this.restrictDownloadOnCheckout,
    required this.canManageAppSetting,
    required this.projectsubscriptiontypeid,
    required this.canManageCustomAttribute,
    required this.isAdminAccess,
    required this.isUseAccess,
    required this.canManageWorkflowRules,
    required this.canAccessAuditInformation,
    required this.countryId,
    required this.projectSpaceTypeId,
    required this.isWatching,
    required this.canManageRolePrivileges,
    required this.canManageFormPermissions,
    required this.canManageProjectInvitations,
    required this.enableCommentReview,
    required this.projectViewerId,
    required this.isShared,
    required this.insertInStorageSpace,
    required this.colorid,
    required this.iconid,
    required this.businessid,
    required this.generateUri,
    this.postalCode,
    this.logoUpdateDateTime,
  });

  factory WorkspaceList.fromJson(Map<String, dynamic> json) => WorkspaceList(
    iProjectId: json["iProjectId"],
    dcId: json["dcId"],
    projectName: json["projectName"],
    projectId: json["projectID"],
    parentId: json["parentId"],
    isWorkspace: json["isWorkspace"],
    projectBaseUrl: json["projectBaseUrl"],
    projectBaseUrlForCollab: json["projectBaseUrlForCollab"],
    projectAdmins: json["projectAdmins"],
    isUserAdminforProj: json["isUserAdminforProj"],
    bimEnabled: json["bimEnabled"],
    projectLogoPath: json["projectLogoPath"],
    isFavorite: json["isFavorite"],
    privilege: json["privilege"],
    canManageWorkspaceRoles: json["canManageWorkspaceRoles"],
    canManageWorkspaceFormStatus: json["canManageWorkspaceFormStatus"],
    isFromExchange: json["isFromExchange"],
    isTemplate: json["isTemplate"],
    isCloned: json["isCloned"],
    activeFilesCount: json["activeFilesCount"],
    formsCount: json["formsCount"],
    statusId: json["statusId"],
    users: json["users"],
    clonedFrom: json["clonedFrom"],
    projectDescription: json["projectDescription"],
    fetchRuleId: json["fetchRuleId"],
    canManageWorkspaceDocStatus: json["canManageWorkspaceDocStatus"],
    canCreateAutoFetchRule: json["canCreateAutoFetchRule"],
    ownerOrgId: json["ownerOrgId"],
    canManagePurposeOfIssue: json["canManagePurposeOfIssue"],
    canManageMailBox: json["canManageMailBox"],
    editWorkspaceFormSettings: json["editWorkspaceFormSettings"],
    canAssignApps: json["canAssignApps"],
    canManageDistributionGroup: json["canManageDistributionGroup"],
    defaultpermissiontypeid: json["defaultpermissiontypeid"],
    checkoutPref: json["checkoutPref"],
    restrictDownloadOnCheckout: json["restrictDownloadOnCheckout"],
    canManageAppSetting: json["canManageAppSetting"],
    projectsubscriptiontypeid: json["projectsubscriptiontypeid"],
    canManageCustomAttribute: json["canManageCustomAttribute"],
    isAdminAccess: json["isAdminAccess"],
    isUseAccess: json["isUseAccess"],
    canManageWorkflowRules: json["canManageWorkflowRules"],
    canAccessAuditInformation: json["canAccessAuditInformation"],
    countryId: json["countryId"],
    projectSpaceTypeId: json["projectSpaceTypeId"],
    isWatching: json["isWatching"],
    canManageRolePrivileges: json["canManageRolePrivileges"],
    canManageFormPermissions: json["canManageFormPermissions"],
    canManageProjectInvitations: json["canManageProjectInvitations"],
    enableCommentReview: json["enableCommentReview"],
    projectViewerId: json["projectViewerId"],
    isShared: json["isShared"],
    insertInStorageSpace: json["insertInStorageSpace"],
    colorid: json["colorid"],
    iconid: json["iconid"],
    businessid: json["businessid"],
    generateUri: json["generateURI"],
    postalCode: json["postalCode"],
    logoUpdateDateTime: json["logoUpdateDateTime"] == null ? null : DateTime.parse(json["logoUpdateDateTime"]),
  );

  Map<String, dynamic> toJson() => {
    "iProjectId": iProjectId,
    "dcId": dcId,
    "projectName": projectName,
    "projectID": projectId,
    "parentId": parentId,
    "isWorkspace": isWorkspace,
    "projectBaseUrl": projectBaseUrl,
    "projectBaseUrlForCollab": projectBaseUrlForCollab,
    "projectAdmins": projectAdmins,
    "isUserAdminforProj": isUserAdminforProj,
    "bimEnabled": bimEnabled,
    "projectLogoPath": projectLogoPath,
    "isFavorite": isFavorite,
    "privilege": privilege,
    "canManageWorkspaceRoles": canManageWorkspaceRoles,
    "canManageWorkspaceFormStatus": canManageWorkspaceFormStatus,
    "isFromExchange": isFromExchange,
    "isTemplate": isTemplate,
    "isCloned": isCloned,
    "activeFilesCount": activeFilesCount,
    "formsCount": formsCount,
    "statusId": statusId,
    "users": users,
    "clonedFrom": clonedFrom,
    "projectDescription": projectDescription,
    "fetchRuleId": fetchRuleId,
    "canManageWorkspaceDocStatus": canManageWorkspaceDocStatus,
    "canCreateAutoFetchRule": canCreateAutoFetchRule,
    "ownerOrgId": ownerOrgId,
    "canManagePurposeOfIssue": canManagePurposeOfIssue,
    "canManageMailBox": canManageMailBox,
    "editWorkspaceFormSettings": editWorkspaceFormSettings,
    "canAssignApps": canAssignApps,
    "canManageDistributionGroup": canManageDistributionGroup,
    "defaultpermissiontypeid": defaultpermissiontypeid,
    "checkoutPref": checkoutPref,
    "restrictDownloadOnCheckout": restrictDownloadOnCheckout,
    "canManageAppSetting": canManageAppSetting,
    "projectsubscriptiontypeid": projectsubscriptiontypeid,
    "canManageCustomAttribute": canManageCustomAttribute,
    "isAdminAccess": isAdminAccess,
    "isUseAccess": isUseAccess,
    "canManageWorkflowRules": canManageWorkflowRules,
    "canAccessAuditInformation": canAccessAuditInformation,
    "countryId": countryId,
    "projectSpaceTypeId": projectSpaceTypeId,
    "isWatching": isWatching,
    "canManageRolePrivileges": canManageRolePrivileges,
    "canManageFormPermissions": canManageFormPermissions,
    "canManageProjectInvitations": canManageProjectInvitations,
    "enableCommentReview": enableCommentReview,
    "projectViewerId": projectViewerId,
    "isShared": isShared,
    "insertInStorageSpace": insertInStorageSpace,
    "colorid": colorid,
    "iconid": iconid,
    "businessid": businessid,
    "generateURI": generateUri,
    "postalCode": postalCode,
    "logoUpdateDateTime": logoUpdateDateTime?.toIso8601String(),
  };
}


