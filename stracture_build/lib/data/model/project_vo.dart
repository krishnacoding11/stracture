import 'package:equatable/equatable.dart';

import '../../utils/field_enums.dart';

class Project extends Equatable {
  int? iProjectId;
  int? dcId;
  String? projectName;
  String? privilege;
  String? projectID;
  int? parentId;
  int? isWorkspace;
  String? projectBaseUrl;
  String? projectBaseUrlForCollab;
  bool? isUserAdminforProj;
  bool? bimEnabled;
  bool? isFavorite;
  bool? canManageWorkspaceRoles;
  bool? canManageWorkspaceFormStatus;
  bool? isFromExchange;
  String? spaceTypeId;
  bool? isTemplate;
  bool? isCloned;
  int? activeFilesCount;
  int? formsCount;
  int? statusId;
  int? users;
  int? fetchRuleId;
  bool? canManageWorkspaceDocStatus;
  bool? canCreateAutoFetchRule;
  int? ownerOrgId;
  bool? canManagePurposeOfIssue;
  bool? canManageMailBox;
  bool? editWorkspaceFormSettings;
  bool? canAssignApps;
  bool? canManageDistributionGroup;
  int? defaultpermissiontypeid;
  bool? checkoutPref;
  bool? restrictDownloadOnCheckout;
  bool? canManageAppSetting;
  int? projectsubscriptiontypeid;
  bool? canManageCustomAttribute;
  bool? isAdminAccess;
  bool? isUseAccess;
  bool? canManageWorkflowRules;
  bool? canAccessAuditInformation;
  int? countryId;
  int? projectSpaceTypeId;
  bool? isWatching;
  bool? canManageRolePrivileges;
  bool? canManageFormPermissions;
  bool? canManageProjectInvitations;
  bool? enableCommentReview;
  int? projectViewerId;
  bool? isShared;
  bool? insertInStorageSpace;
  int? colorid;
  int? iconid;
  int? businessid;
  dynamic childfolderTreeVOList;
  bool? generateURI;
  String? postalCode;
  bool? canRemoveOffline;
  bool? isMarkOffline;
  ESyncStatus? syncStatus;
  String? lastSyncTimeStamp;
  String? newSyncTimeStamp;
  String? projectSizeInByte;
  double? progress;

  Project(
      {this.iProjectId,
        this.dcId,
        this.projectName,
        this.projectID,
        this.parentId,
        this.isWorkspace,
        this.projectBaseUrl,
        this.projectBaseUrlForCollab,
        this.isUserAdminforProj,
        this.bimEnabled,
        this.isFavorite,
        this.canManageWorkspaceRoles,
        this.canManageWorkspaceFormStatus,
        this.isFromExchange,
        this.spaceTypeId,
        this.isTemplate,
        this.isCloned,
        this.activeFilesCount,
        this.formsCount,
        this.statusId,
        this.users,
        this.fetchRuleId,
        this.canManageWorkspaceDocStatus,
        this.canCreateAutoFetchRule,
        this.ownerOrgId,
        this.canManagePurposeOfIssue,
        this.canManageMailBox,
        this.editWorkspaceFormSettings,
        this.canAssignApps,
        this.canManageDistributionGroup,
        this.defaultpermissiontypeid,
        this.checkoutPref,
        this.restrictDownloadOnCheckout,
        this.canManageAppSetting,
        this.projectsubscriptiontypeid,
        this.canManageCustomAttribute,
        this.isAdminAccess,
        this.isUseAccess,
        this.canManageWorkflowRules,
        this.canAccessAuditInformation,
        this.countryId,
        this.projectSpaceTypeId,
        this.isWatching,
        this.canManageRolePrivileges,
        this.canManageFormPermissions,
        this.canManageProjectInvitations,
        this.enableCommentReview,
        this.projectViewerId,
        this.isShared,
        this.insertInStorageSpace,
        this.colorid,
        this.iconid,
        this.businessid,
        this.childfolderTreeVOList,
        this.generateURI,
        this.postalCode,
        this.projectSizeInByte,
        this.progress
      });

  Project.fromJson(Map<String, dynamic> json) {
    iProjectId = json['iProjectId'];
    dcId = json['dcId'];
    projectName = json['projectName'];
    privilege = json['privilege'];
    projectID = json['projectID'];
    parentId = json['parentId'];
    isWorkspace = json['isWorkspace'];
    projectBaseUrl = json['projectBaseUrl'];
    projectBaseUrlForCollab = json['projectBaseUrlForCollab'];
    isUserAdminforProj = json['isUserAdminforProj'];
    bimEnabled = json['bimEnabled'];
    isFavorite = json['isFavorite'];
    canManageWorkspaceRoles = json['canManageWorkspaceRoles'];
    canManageWorkspaceFormStatus = json['canManageWorkspaceFormStatus'];
    isFromExchange = json['isFromExchange'];
    spaceTypeId = json['space_type_id'];
    isTemplate = json['isTemplate'];
    isCloned = json['isCloned'];
    activeFilesCount = json['activeFilesCount'];
    formsCount = json['formsCount'];
    statusId = json['statusId'];
    users = json['users'];
    fetchRuleId = json['fetchRuleId'];
    canManageWorkspaceDocStatus = json['canManageWorkspaceDocStatus'];
    canCreateAutoFetchRule = json['canCreateAutoFetchRule'];
    ownerOrgId = json['ownerOrgId'];
    canManagePurposeOfIssue = json['canManagePurposeOfIssue'];
    canManageMailBox = json['canManageMailBox'];
    editWorkspaceFormSettings = json['editWorkspaceFormSettings'];
    canAssignApps = json['canAssignApps'];
    canManageDistributionGroup = json['canManageDistributionGroup'];
    defaultpermissiontypeid = json['defaultpermissiontypeid'];
    checkoutPref = json['checkoutPref'];
    restrictDownloadOnCheckout = json['restrictDownloadOnCheckout'];
    canManageAppSetting = json['canManageAppSetting'];
    projectsubscriptiontypeid = json['projectsubscriptiontypeid'];
    canManageCustomAttribute = json['canManageCustomAttribute'];
    isAdminAccess = json['isAdminAccess'];
    isUseAccess = json['isUseAccess'];
    canManageWorkflowRules = json['canManageWorkflowRules'];
    canAccessAuditInformation = json['canAccessAuditInformation'];
    countryId = json['countryId'];
    projectSpaceTypeId = json['projectSpaceTypeId'];
    isWatching = json['isWatching'];
    canManageRolePrivileges = json['canManageRolePrivileges'];
    canManageFormPermissions = json['canManageFormPermissions'];
    canManageProjectInvitations = json['canManageProjectInvitations'];
    enableCommentReview = json['enableCommentReview'];
    projectViewerId = json['projectViewerId'];
    isShared = json['isShared'];
    insertInStorageSpace = json['insertInStorageSpace'];
    colorid = json['colorid'];
    iconid = json['iconid'];
    businessid = json['businessid'];
    generateURI = json['generateURI'];
    childfolderTreeVOList = json['childfolderTreeVOList'];
    postalCode = json["postalCode"];
    projectSizeInByte = json['projectSizeInByte'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['iProjectId'] = iProjectId;
    data['dcId'] = dcId;
    data['projectName'] = projectName;
    data['projectID'] = projectID;
    data['parentId'] = parentId;
    data['isWorkspace'] = isWorkspace;
    data['projectBaseUrl'] = projectBaseUrl;
    data['projectBaseUrlForCollab'] = projectBaseUrlForCollab;
    data['isUserAdminforProj'] = isUserAdminforProj;
    data['bimEnabled'] = bimEnabled;
    data['isFavorite'] = isFavorite;
    data['canManageWorkspaceRoles'] = canManageWorkspaceRoles;
    data['canManageWorkspaceFormStatus'] = canManageWorkspaceFormStatus;
    data['isFromExchange'] = isFromExchange;
    data['space_type_id'] = spaceTypeId;
    data['isTemplate'] = isTemplate;
    data['isCloned'] = isCloned;
    data['activeFilesCount'] = activeFilesCount;
    data['formsCount'] = formsCount;
    data['statusId'] = statusId;
    data['users'] = users;
    data['fetchRuleId'] = fetchRuleId;
    data['canManageWorkspaceDocStatus'] = canManageWorkspaceDocStatus;
    data['canCreateAutoFetchRule'] = canCreateAutoFetchRule;
    data['ownerOrgId'] = ownerOrgId;
    data['canManagePurposeOfIssue'] = canManagePurposeOfIssue;
    data['canManageMailBox'] = canManageMailBox;
    data['editWorkspaceFormSettings'] = editWorkspaceFormSettings;
    data['canAssignApps'] = canAssignApps;
    data['canManageDistributionGroup'] = canManageDistributionGroup;
    data['defaultpermissiontypeid'] = defaultpermissiontypeid;
    data['checkoutPref'] = checkoutPref;
    data['restrictDownloadOnCheckout'] = restrictDownloadOnCheckout;
    data['canManageAppSetting'] = canManageAppSetting;
    data['projectsubscriptiontypeid'] = projectsubscriptiontypeid;
    data['canManageCustomAttribute'] = canManageCustomAttribute;
    data['isAdminAccess'] = isAdminAccess;
    data['isUseAccess'] = isUseAccess;
    data['canManageWorkflowRules'] = canManageWorkflowRules;
    data['canAccessAuditInformation'] = canAccessAuditInformation;
    data['countryId'] = countryId;
    data['projectSpaceTypeId'] = projectSpaceTypeId;
    data['isWatching'] = isWatching;
    data['canManageRolePrivileges'] = canManageRolePrivileges;
    data['canManageFormPermissions'] = canManageFormPermissions;
    data['canManageProjectInvitations'] = canManageProjectInvitations;
    data['enableCommentReview'] = enableCommentReview;
    data['projectViewerId'] = projectViewerId;
    data['isShared'] = isShared;
    data['insertInStorageSpace'] = insertInStorageSpace;
    data['colorid'] = colorid;
    data['iconid'] = iconid;
    data['businessid'] = businessid;
    data['generateURI'] = generateURI;
    data['postalCode'] = postalCode;
    data['projectSizeInByte'] = projectSizeInByte;
    return data;
  }

  @override
  List<Object?> get props => [];
}
