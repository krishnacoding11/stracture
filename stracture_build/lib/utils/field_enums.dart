

enum EResponseCode {
  success(200),
  appException(999);

  const EResponseCode(this.value);

  final int value;

  static EResponseCode fromNumber(int i) {
    return EResponseCode.values.firstWhere((x) => x.value == i);
  }
}

enum ESyncStatus {
  failed(0),
  success(1),
  inProgress(2);

  const ESyncStatus(this.value);

  final int value;

  static ESyncStatus fromNumber(int i) {
    return ESyncStatus.values.firstWhere((x) => x.value == i);
  }

  static ESyncStatus fromString(String value) {
    int i = int.parse((value.isEmpty)?"0":value);
    return ESyncStatus.values.firstWhere((x) => x.value == i);
  }
}

enum ESystemPrivilege {
  canDownloadDocument(81),
  canBatchChangeStatusOfOwnForm(99),
  canReopenClosedForm(100),
  canBatchChangeStatusOfAllForms(111),
  canReopenAllClosedFormsAdmin(130);

  const ESystemPrivilege(this.value);

  final int value;

  static ESystemPrivilege fromNumber(int i) {
    return ESystemPrivilege.values.firstWhere((x) => x.value == i);
  }
}

enum EProjectStatus {
  undefined(0),
  open(5),
  closed(6),
  archived(7);

  const EProjectStatus(this.value);

  final int value;

  static EProjectStatus fromNumber(int i) {
    return EProjectStatus.values.firstWhere((x) => x.value == i);
  }
}

enum EOfflineSyncRequestType {
  invalid(0),
  CreateOrRespond(1),
  StatusChange(2),
  OtherAction(3),
  DistributeAction(4),
  BatchProcess(5);

  const EOfflineSyncRequestType(this.value);

  final int value;

  static EOfflineSyncRequestType fromNumber(int i) {
    return EOfflineSyncRequestType.values.firstWhere((x) => x.value == i,orElse: () => EOfflineSyncRequestType.invalid);
  }

  static EOfflineSyncRequestType fromString(String iValue) {
    int i = int.parse((iValue.isEmpty)?"0":iValue);
    return EOfflineSyncRequestType.values.firstWhere((x) => x.value == i,orElse: () => EOfflineSyncRequestType.invalid);
  }
}

enum EHtmlRequestType {
  create(0),
  respond(1),
  editDraft(2),
  editAndDistribute(3),
  reply(4),
  replyAll(5),
  editOri(6),
  viewForm(7);

  const EHtmlRequestType(this.value);

  final int value;

  static EHtmlRequestType fromNumber(int i) {
    return EHtmlRequestType.values.firstWhere((x) => x.value == i);
  }
}

enum ETemplateType {
  invalid(0),
  xsn(1),
  html(2);

  const ETemplateType(this.value);

  final int value;

  static ETemplateType fromNumber(int i) {
    return ETemplateType.values.firstWhere((x) => x.value == i);
  }

  static ETemplateType fromString(String iValue) {
    int i = int.parse((iValue.isEmpty)?"0":iValue);
    return ETemplateType.values.firstWhere((x) => x.value == i);
  }
}

enum EFormMessageType {
  ori(1, "ORI"),
  res(2, "RES"),
  fwd(3, "FWD");

  const EFormMessageType(this.value, this.name);

  final int value;
  final String name;

  static EFormMessageType fromNumber(int i) {
    return EFormMessageType.values.firstWhere((x) => x.value == i);
  }

  static EFormMessageType fromString(String iValue) {
    if (iValue.isEmpty) {
      iValue = "1";
    }
    return EFormMessageType.values.firstWhere((x) => x.value == int.parse(iValue));
  }
}
enum ESyncTaskType {
  projectAndLocationSyncTask("ProjectAndLocationSyncTask"),
  filterSyncTask("FilterSyncTask"),
  locationPlanSyncTask("LocationPlanSyncTask"),
  formTypeListSyncTask("FormTypeListSyncTask"),
  formListSyncTask("FormListSyncTask"),
  formTypeTemplateDownloadSyncTask("FormTypeTemplateDownloadSyncTask"),
  formTypeDistributionListSyncTask("FormTypeDistributionListSyncTask"),
  formTypeControllerUserListSyncTask("formTypeControllerUserListSyncTask"),
  formTypeStatusListSyncTask("FormTypeStatusListSyncTask"),
  formTypeCustomAttributeListSyncTask("FormTypeCustomAttributeListSyncTask"),
  formTypeFixFieldListSyncTask("FormTypeFixFieldListSyncTask"),
  formMessageBatchListSyncTask("FormMessageBatchListSyncTask"),
  formAttachmentDownloadBatchSyncTask("FormAttachmentDownloadBatchSyncTask"),
  columnHeaderListSyncTask("ColumnHeaderListSyncTask"),
  statusStyleListSyncTask("StatusStyleListSyncTask"),
  manageTypeListSyncTask("ManageTypeListSyncTask"),
  formTypeAttributeSetDetailSyncTask("FormTypeAttributeSetDetailSyncTask"),
  manageHomePageConfigurationTask("ManageHomePageConfigurationTask"),

  //Below are auto-sync/push-to-server sync tasks
  createOrRespondFormSyncTask("createOrRespondFormSyncTask"),
  distributionFormActionSyncTask("distributionFormActionSyncTask"),
  otherActionSyncTask("otherActionSyncTask"),
  formStatusChangeTask("formStatusChangeTask");

  const ESyncTaskType(this.value);

  final String value;
}

enum EAttachmentAndAssociationType {
  undefined(-1),
  files(0),
  discussions(1),
  apps(2),
  attachments(3),
  references(6),
  views(7),
  lists(9);

  const EAttachmentAndAssociationType(this.value);

  final int value;

  static EAttachmentAndAssociationType fromNumber(int i) {
    return EAttachmentAndAssociationType.values.firstWhere((x) => x.value == i);
  }

  static EAttachmentAndAssociationType fromString(String iValue) {
    if (iValue.isEmpty) {
      iValue = "-1";
    }
    return EAttachmentAndAssociationType.values.firstWhere((x) => x.value == int.parse(iValue));
  }
}

enum ESyncType {
  pushToServer,
  project,
  siteLocation
}

enum TaskSyncResponseType {
  success,
  failure,
  exception;
}

enum EDistributionLevel {
  roles(1),
  organisations(2),
  users(3),
  userGroups(4),
  distributionGroups(5);

  const EDistributionLevel(this.value);

  final int value;

}


enum EFormActionType {
  forRespond(3),
  forDistribution(6),
  forInformation(7),
  forAcknowledgement(37),
  forStatusChange(14),
  forReviewDraft(34),
  forAction(36),
  forAssignStatus(2),
  forAttachedDoc(5),
  releaseResponse(4);

  const EFormActionType(this.value);

  final int value;

  static EFormActionType fromString(String iValue) {
    if (iValue.isEmpty) {
      iValue = "1";
    }
    return EFormActionType.values.firstWhere((x) => x.value == int.parse(iValue));
  }
}