

import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';

import '../../database/dao.dart';
import '../model/form_vo.dart';

class FormDao extends Dao<SiteForm> {
  static const tableName = 'FormListTbl';

  static const projectIdField="ProjectId";
  static const formIdField="FormId";
  static const appTypeIdField="AppTypeId";
  static const formTypeIdField="FormTypeId";
  static const instanceGroupIdField="InstanceGroupId";
  static const formTitleField="FormTitle";
  static const codeField="Code";
  static const commentIdField="CommentId";
  static const messageIdField="MessageId";
  static const parentMessageIdField="ParentMessageId";
  static const orgIdField="OrgId";
  static const firstNameField="FirstName";
  static const lastNameField="LastName";
  static const orgNameField="OrgName";
  static const originatorField="Originator";
  static const originatorDisplayNameField="OriginatorDisplayName";
  static const noOfActionsField="NoOfActions";
  static const observationIdField="ObservationId";
  static const locationIdField="LocationId";
  static const pfLocFolderIdField="PfLocFolderId";
  static const updatedField="Updated";
  static const attachmentImageNameField="AttachmentImageName";
  static const msgCodeField="MsgCode";
  static const typeImageField="TypeImage";
  static const docTypeField="DocType";
  static const hasAttachmentsField="HasAttachments";
  static const hasDocAssocationsField="HasDocAssocations";
  static const hasBimViewAssociationsField="HasBimViewAssociations";
  static const hasFormAssocationsField="HasFormAssocations";
  static const hasCommentAssocationsField="HasCommentAssocations";
  static const formHasAssocAttachField="FormHasAssocAttach";
  static const formCreationDateField="FormCreationDate";
  static const folderIdField="FolderId";
  static const msgTypeIdField="MsgTypeId";
  static const msgStatusIdField="MsgStatusId";
  static const formNumberField="FormNumber";
  static const msgOriginatorIdField="MsgOriginatorId";
  static const templateTypeField="TemplateType";
  static const isDraftField="IsDraft";
  static const statusIdField="StatusId";
  static const originatorIdField="OriginatorId";
  static const isStatusChangeRestrictedField="IsStatusChangeRestricted";
  static const allowReopenFormField="AllowReopenForm";
  static const canOrigChangeStatusField="CanOrigChangeStatus";
  static const msgTypeCodeField="MsgTypeCode";
  static const idField="Id";
  static const statusChangeUserIdField="StatusChangeUserId";
  static const statusUpdateDateField="StatusUpdateDate";
  static const statusChangeUserNameField="StatusChangeUserName";
  static const statusChangeUserPicField="StatusChangeUserPic";
  static const statusChangeUserEmailField="StatusChangeUserEmail";
  static const statusChangeUserOrgField="StatusChangeUserOrg";
  static const originatorEmailField="OriginatorEmail";
  static const controllerUserIdField="ControllerUserId";
  static const updatedDateInMSField="UpdatedDateInMS";
  static const formCreationDateInMSField="FormCreationDateInMS";
  static const responseRequestByInMSField="ResponseRequestByInMS";
  static const flagTypeField="FlagType";
  static const latestDraftIdField="LatestDraftId";
  static const flagTypeImageNameField="FlagTypeImageName";
  static const messageTypeImageNameField="MessageTypeImageName";
  static const canAccessHistoryField="CanAccessHistory";
  static const formJsonDataField="FormJsonData";
  static const statusField="Status";
  static const attachedDocsField="AttachedDocs";
  static const isUploadAttachmentInTempField="IsUploadAttachmentInTemp";
  static const isSyncField="IsSync";
  static const userRefCodeField="UserRefCode";
  static const hasActionsField="HasActions";
  static const canRemoveOfflineField="CanRemoveOffline";
  static const isMarkOfflineField="IsMarkOffline";
  static const isOfflineCreatedField="IsOfflineCreated";
  static const syncStatusField="SyncStatus";
  static const isForDefectField="IsForDefect";
  static const isForAppsField="IsForApps";
  static const observationDefectTypeIdField="ObservationDefectTypeId";
  static const startDateField="StartDate";
  static const expectedFinishDateField="ExpectedFinishDate";
  static const isActiveField="IsActive";
  static const observationCoordinatesField="ObservationCoordinates";
  static const annotationIdField="AnnotationId";
  static const isCloseOutField="IsCloseOut";
  static const assignedToUserIdField="AssignedToUserId";
  static const assignedToUserNameField="AssignedToUserName";
  static const assignedToUserOrgNameField="AssignedToUserOrgName";
  static const msgNumField="MsgNum";
  static const revisionIdField="RevisionId";
  static const requestJsonForOfflineField="RequestJsonForOffline";
  static const formDueDaysField="FormDueDays";
  static const formSyncDateField="FormSyncDate";
  static const lastResponderForAssignedToField="LastResponderForAssignedTo";
  static const lastResponderForOriginatorField="LastResponderForOriginator";
  static const pageNumberField="PageNumber";
  static const observationDefectTypeField="ObservationDefectType";
  static const statusNameField="StatusName";
  static const appBuilderIdField="AppBuilderId";
  static const taskTypeNameField="TaskTypeName";
  static const assignedToRoleNameField="AssignedToRoleName";
  // static const workPackage="ObservationDefectType";

  String get fields => "$projectIdField INTEGER NOT NULL,"
      "$formIdField TEXT NOT NULL,"
      "$appTypeIdField INTEGER,"
      "$formTypeIdField INTEGER,"
      "$instanceGroupIdField INTEGER NOT NULL,"
      "$formTitleField TEXT,"
      "$codeField TEXT,"
      "$commentIdField INTEGER,"
      "$messageIdField INTEGER,"
      "$parentMessageIdField INTEGER,"
      "$orgIdField INTEGER,"
      "$firstNameField TEXT,"
      "$lastNameField TEXT,"
      "$orgNameField TEXT,"
      "$originatorField TEXT,"
      "$originatorDisplayNameField TEXT,"
      "$noOfActionsField INTEGER,"
      "$observationIdField INTEGER,"
      "$locationIdField INTEGER,"
      "$pfLocFolderIdField INTEGER,"
      "$updatedField TEXT,"
      "$attachmentImageNameField TEXT,"
      "$msgCodeField TEXT,"
      "$typeImageField TEXT,"
      "$docTypeField TEXT,"
      "$hasAttachmentsField INTEGER NOT NULL DEFAULT 0,"
      "$hasDocAssocationsField INTEGER NOT NULL DEFAULT 0,"
      "$hasBimViewAssociationsField INTEGER NOT NULL DEFAULT 0,"
      "$hasFormAssocationsField INTEGER NOT NULL DEFAULT 0,"
      "$hasCommentAssocationsField INTEGER NOT NULL DEFAULT 0,"
      "$formHasAssocAttachField INTEGER NOT NULL DEFAULT 0,"
      "$formCreationDateField TEXT,"
      "$folderIdField INTEGER,"
      "$msgTypeIdField INTEGER,"
      "$msgStatusIdField INTEGER,"
      "$formNumberField INTEGER,"
      "$msgOriginatorIdField INTEGER,"
      "$templateTypeField INTEGER,"
      "$isDraftField INTEGER NOT NULL DEFAULT 0,"
      "$statusIdField INTEGER,"
      "$originatorIdField INTEGER,"
      "$isStatusChangeRestrictedField INTEGER NOT NULL DEFAULT 0,"
      "$allowReopenFormField INTEGER NOT NULL DEFAULT 0,"
      "$canOrigChangeStatusField INTEGER NOT NULL DEFAULT 0,"
      "$msgTypeCodeField TEXT,"
      "$idField TEXT,"
      "$statusChangeUserIdField INTEGER,"
      "$statusUpdateDateField TEXT,"
      "$statusChangeUserNameField TEXT,"
      "$statusChangeUserPicField TEXT,"
      "$statusChangeUserEmailField TEXT,"
      "$statusChangeUserOrgField TEXT,"
      "$originatorEmailField TEXT,"
      "$controllerUserIdField INTEGER,"
      "$updatedDateInMSField INTEGER,"
      "$formCreationDateInMSField INTEGER,"
      "$responseRequestByInMSField INTEGER,"
      "$flagTypeField INTEGER,"
      "$latestDraftIdField INTEGER,"
      "$flagTypeImageNameField TEXT,"
      "$messageTypeImageNameField TEXT,"
      "$canAccessHistoryField INTEGER NOT NULL DEFAULT 0,"
      "$formJsonDataField TEXT,"
      "$statusField TEXT,"
      "$attachedDocsField TEXT,"
      "$isUploadAttachmentInTempField INTEGER NOT NULL DEFAULT 0,"
      "$isSyncField INTEGER NOT NULL DEFAULT 0,"
      "$userRefCodeField TEXT,"
      "$hasActionsField INTEGER NOT NULL DEFAULT 0,"
      "$canRemoveOfflineField INTEGER NOT NULL DEFAULT 0,"
      "$isMarkOfflineField INTEGER NOT NULL DEFAULT 0,"
      "$isOfflineCreatedField INTEGER NOT NULL DEFAULT 0,"
      "$syncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$isForDefectField INTEGER NOT NULL DEFAULT 0,"
      "$isForAppsField INTEGER NOT NULL DEFAULT 0,"
      "$observationDefectTypeIdField TEXT NOT NULL DEFAULT '0',"
      "$startDateField TEXT NOT NULL,"
      "$expectedFinishDateField TEXT NOT NULL,"
      "$isActiveField INTEGER NOT NULL DEFAULT 0,"
      "$observationCoordinatesField TEXT,"
      "$annotationIdField TEXT,"
      "$isCloseOutField INTEGER NOT NULL DEFAULT 0,"
      "$assignedToUserIdField INTEGER NOT NULL,"
      "$assignedToUserNameField TEXT,"
      "$assignedToUserOrgNameField TEXT,"
      "$msgNumField INTEGER,"
      "$revisionIdField INTEGER,"
      "$requestJsonForOfflineField TEXT,"
      "$formDueDaysField TEXT NOT NULL DEFAULT 0,"
      "$formSyncDateField TEXT NOT NULL DEFAULT 0,"
      "$lastResponderForAssignedToField TEXT NOT NULL DEFAULT '',"
      "$lastResponderForOriginatorField TEXT NOT NULL DEFAULT '',"
      "$pageNumberField TEXT NOT NULL DEFAULT 0,"
      "$observationDefectTypeField TEXT,"
      "$statusNameField TEXT,"
      "$appBuilderIdField TEXT,"
      "$taskTypeNameField TEXT,"
      "$assignedToRoleNameField TEXT";

  String get primaryKeys => ",PRIMARY KEY($projectIdField,$formIdField)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<SiteForm> fromList(List<Map<String, dynamic>> query) {
    return List<SiteForm>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  SiteForm fromMap(Map<String, dynamic> query) {
    SiteForm object = SiteForm();
    object.projectId = query[projectIdField].toString();
    object.formId = query[formIdField].toString();
    object.appTypeId = int.parse(query[appTypeIdField].toString());
    object.formTypeId = query[formTypeIdField].toString();
    object.instanceGroupId = query[instanceGroupIdField].toString();
    object.title = query[formTitleField];
    object.code = query[codeField].toString();
    object.commId = query[commentIdField].toString();
    object.msgId = query[messageIdField].toString();
    object.parentMsgId = query[parentMessageIdField].toString();
    object.orgId = query[orgIdField].toString();
    object.firstName = query[firstNameField];
    object.lastName = query[lastNameField];
    object.orgName = query[orgNameField];
    object.originator = query[originatorField].toString();
    object.originatorDisplayName = query[originatorDisplayNameField];
    object.noOfActions = query[noOfActionsField];
    object.observationId = query[observationIdField];
    object.locationId = query[locationIdField];
    object.pfLocFolderId = query[pfLocFolderIdField].toString().isNullOrEmpty()?0:query[pfLocFolderIdField];
    object.updated = query[updatedField];
    object.attachmentImageName = query[attachmentImageNameField];
    object.msgCode = query[msgCodeField];
    object.typeImage = query[typeImageField];
    object.docType = query[docTypeField];
    object.hasAttachments = query[hasAttachmentsField].runtimeType == bool ? query[hasAttachmentsField] : (int.parse(query[hasAttachmentsField].toString()) == 1 ? true : false);
    object.hasDocAssocations = query[hasDocAssocationsField].runtimeType == bool ? query[hasDocAssocationsField] : (int.parse(query[hasDocAssocationsField].toString()) == 1 ? true : false);
    object.hasBimViewAssociations = query[hasBimViewAssociationsField].runtimeType == bool ? query[hasBimViewAssociationsField] : (int.parse(query[hasBimViewAssociationsField].toString()) == 1 ? true : false);
    object.hasFormAssocations = query[hasFormAssocationsField].runtimeType == bool ? query[hasFormAssocationsField] : (int.parse(query[hasFormAssocationsField].toString()) == 1 ? true : false);
    object.hasCommentAssocations = query[hasCommentAssocationsField].runtimeType == bool ? query[hasCommentAssocationsField] : (int.parse(query[hasCommentAssocationsField].toString()) == 1 ? true : false);
    object.formHasAssocAttach = query[formHasAssocAttachField].runtimeType == bool ? query[formHasAssocAttachField] : (int.parse(query[formHasAssocAttachField].toString()) == 1 ? true : false);
    object.formCreationDate = query[formCreationDateField];
    object.folderId = query[folderIdField].toString();
    object.msgTypeId = query[msgTypeIdField].toString();
    object.msgStatusId = query[msgStatusIdField].toString();
    object.formNum = int.tryParse(query[formNumberField].toString())??0;
    object.msgOriginatorId = int.tryParse(query[msgOriginatorIdField].toString())??0;
    object.templateType = query[templateTypeField];
    object.isDraft = query[isDraftField].runtimeType == bool ? query[isDraftField] : (int.parse(query[isDraftField].toString()) == 1 ? true : false);
    object.statusid = query[statusIdField].toString();
    object.originatorId = query[originatorIdField].toString();
    object.isStatusChangeRestricted = query[isStatusChangeRestrictedField].runtimeType == bool ? query[isStatusChangeRestrictedField] : (int.parse(query[isStatusChangeRestrictedField].toString()) == 1 ? true : false);
    object.allowReopenForm = query[allowReopenFormField].runtimeType == bool ? query[allowReopenFormField] : (int.parse(query[allowReopenFormField].toString()) == 1 ? true : false);
    object.canOrigChangeStatus = query[canOrigChangeStatusField].runtimeType == bool ? query[canOrigChangeStatusField] : (int.parse(query[canOrigChangeStatusField].toString()) == 1 ? true : false);
    object.msgTypeCode = query[msgTypeCodeField].toString();
    object.id = query[idField].toString();
    object.statusChangeUserId = int.tryParse(query[statusChangeUserIdField].toString())??0;
    object.statusUpdateDate = query[statusUpdateDateField];
    object.statusChangeUserName = query[statusChangeUserNameField];
    object.statusChangeUserPic = query[statusChangeUserPicField];
    object.statusChangeUserEmail = query[statusChangeUserEmailField];
    object.statusChangeUserOrg = query[statusChangeUserOrgField];
    object.originatorEmail = query[originatorEmailField];
    object.controllerUserId = query[controllerUserIdField].toString();
    object.updatedDateInMS = query[updatedDateInMSField].toString();
    object.formCreationDateInMS = query[formCreationDateInMSField].toString();
    object.responseRequestByInMS = query[responseRequestByInMSField].toString();
    object.flagType = int.tryParse(query[flagTypeField].toString())??0;
    object.latestDraftId = query[latestDraftIdField].toString();
    object.flagTypeImageName = query[flagTypeImageNameField];
    object.messageTypeImageName = query[messageTypeImageNameField];
    object.canAccessHistory = query[canAccessHistoryField].runtimeType == bool ? query[canAccessHistoryField] : (int.parse(query[canAccessHistoryField].toString()) == 1 ? true : false);
    object.formJsonData = query[formJsonDataField];
    object.status = query[statusField];
    object.attachedDocs = query[attachedDocsField];
    object.isUploadAttachmentInTemp=query[isUploadAttachmentInTempField]==1?true:false;
    object.isSync=query[isSyncField]==1?true:false;
    object.userRefCode = query[userRefCodeField];
    object.hasActions =  query[hasActionsField].runtimeType == bool ? query[hasActionsField] : (int.parse(query[hasActionsField].toString()) == 1 ? true : false);
    object.canRemoveOffline=query[canRemoveOfflineField]==1?true:false;
    object.isMarkOffline=query[isMarkOfflineField]==1?true:false;
    object.isOfflineCreated=query[isOfflineCreatedField]==1?true:false;
    object.syncStatus = ESyncStatus.fromNumber(query[syncStatusField]);
    object.isForDefect=query[isForDefectField]==1?true:false;
    object.isForApps=query[isForAppsField]==1?true:false;
    object.observationDefectTypeId = int.tryParse(query[observationDefectTypeIdField].toString())??0;
    object.startDate = query[startDateField];
    object.expectedFinishDate = query[expectedFinishDateField];
    object.isActive = query[isActiveField].runtimeType == bool ? query[isActiveField] : (int.parse(query[isActiveField].toString()) == 1 ? true : false);//BOOL
    object.observationCoordinates = query[observationCoordinatesField];
    object.annotationId = query[annotationIdField];
    object.isCloseOut = query[isCloseOutField].runtimeType == bool ? query[isCloseOutField] : (int.parse(query[isCloseOutField].toString()) == 1 ? true : false);//bool
    object.assignedToUserId = query[assignedToUserIdField].toString();//int
    object.assignedToUserName = query[assignedToUserNameField];
    object.assignedToUserOrgName = query[assignedToUserOrgNameField];
    object.msgNum = int.tryParse(query[msgNumField].toString())??0;//int
    object.revisionId = query[revisionIdField].toString();//int
    object.requestJsonForOffline = query[requestJsonForOfflineField];
    object.formDueDays = int.tryParse(query[formDueDaysField].toString())??0;//string
    object.formSyncDate = query[formSyncDateField];//string
    object.lastResponderForAssignedTo = query[lastResponderForAssignedToField];
    object.lastResponderForOriginator = query[lastResponderForOriginatorField];
    object.pageNumber = int.tryParse(query[pageNumberField].toString())??0;//String
    object.observationDefectType = query[observationDefectTypeField];
    object.statusName = query[statusNameField];
    object.appBuilderId = query[appBuilderIdField];//String
    object.taskTypeName = query[taskTypeNameField];//String
    object.assignedToRoleName = query[assignedToRoleNameField];
    return object;
  }
  SiteForm offlineFromMap(Map<String, dynamic> query) {
    SiteForm object = SiteForm();
    object.projectId = query[projectIdField];
    object.formId = query[formIdField];
    object.appTypeId = query[appTypeIdField];
    object.formTypeId = query[formTypeIdField];
    object.instanceGroupId = query[instanceGroupIdField].toString();
    object.title = query[formTitleField];
    object.code = query[codeField];
    object.commId = query[commentIdField];
    object.msgId = query[messageIdField];
    object.parentMsgId = query[parentMessageIdField];
    object.orgId = query[orgIdField];
    object.firstName = query[firstNameField];
    object.lastName = query[lastNameField];
    object.orgName = query[orgNameField];
    object.originator = query[originatorField];
    object.originatorDisplayName = query[originatorDisplayNameField];
    object.noOfActions = query[noOfActionsField];
    object.observationId = query[observationIdField];
    object.locationId = query[locationIdField];
    object.pfLocFolderId = query[pfLocFolderIdField];
    object.updated = query[updatedField];
    object.attachmentImageName = query[attachmentImageNameField];
    object.msgCode = query[msgCodeField];
    object.typeImage = query[typeImageField];
    object.docType = query[docTypeField];
    object.hasAttachments = query[hasAttachmentsField];
    object.hasDocAssocations = (query[hasDocAssocationsField] ?? 0) == 0 ? false : true;
    object.hasBimViewAssociations = (query[hasBimViewAssociationsField] ?? 0) == 0 ? false : true;
    object.hasFormAssocations = (query[hasFormAssocationsField] ?? 0) == 0 ? false : true;
    object.hasCommentAssocations = (query[hasCommentAssocationsField] ?? 0) == 0 ? false : true;
    object.formHasAssocAttach = (query[formHasAssocAttachField] ?? 0) == 0 ? false : true;
    object.formCreationDate = query[formCreationDateField];
    object.folderId = query[folderIdField];
    object.msgTypeId = query[msgTypeIdField];
    object.msgStatusId = query[msgStatusIdField];
    object.formNum = query[formNumberField];
    object.msgOriginatorId = int.parse(query[msgOriginatorIdField]);
    object.templateType = query[templateTypeField];
    object.isDraft = (query[isDraftField] ?? 0) == 0 ? false : true;
    object.statusid = query[statusIdField];
    object.originatorId = query[originatorIdField];
    object.isStatusChangeRestricted = (query[isStatusChangeRestrictedField] ?? 0) == 0 ? false : true;
    object.allowReopenForm = (query[allowReopenFormField]?? 0) == 0 ? false : true;
    object.canOrigChangeStatus = (query[canOrigChangeStatusField]?? 0) == 0 ? false : true;
    object.msgTypeCode = query[msgTypeCodeField];
    object.id = query[idField];
    object.statusChangeUserId = query[statusChangeUserIdField];
    object.statusUpdateDate = query[statusUpdateDateField];
    object.statusChangeUserName = query[statusChangeUserNameField];
    object.statusChangeUserPic = query[statusChangeUserPicField];
    object.statusChangeUserEmail = query[statusChangeUserEmailField];
    object.statusChangeUserOrg = query[statusChangeUserOrgField];
    object.originatorEmail = query[originatorEmailField];
    object.controllerUserId = query[controllerUserIdField];
    object.updatedDateInMS = query[updatedDateInMSField];
    object.formCreationDateInMS = query[formCreationDateInMSField];
    object.responseRequestByInMS = query[responseRequestByInMSField];
    object.flagType = query[flagTypeField];
    object.latestDraftId = query[latestDraftIdField];
    object.flagTypeImageName = query[flagTypeImageNameField];
    object.messageTypeImageName = query[messageTypeImageNameField];
    object.canAccessHistory = (query[canAccessHistoryField]?? 0) == 0 ? false : true;
    object.formJsonData = query[formJsonDataField];
    object.status = query[statusField];
    object.attachedDocs = query[attachedDocsField];
    object.isUploadAttachmentInTemp=query[isUploadAttachmentInTempField]==1?true:false;
    object.isSync=query[isSyncField]==1?true:false;
    object.userRefCode = query[userRefCodeField];
    object.hasActions = query[hasActionsField];
    object.canRemoveOffline=query[canRemoveOfflineField]==1?true:false;
    object.isMarkOffline=query[isMarkOfflineField]==1?true:false;
    object.isOfflineCreated=query[isOfflineCreatedField]==1?true:false;
    object.syncStatus = ESyncStatus.success;
    object.isForDefect=query[isForDefectField]==1?true:false;
    object.isForApps=query[isForAppsField]==1?true:false;
    object.observationDefectTypeId = query[observationDefectTypeIdField];
    object.startDate = query[startDateField];
    object.expectedFinishDate = query[expectedFinishDateField];
    object.isActive = query[isActiveField];
    object.observationCoordinates = query[observationCoordinatesField];
    object.annotationId = query[annotationIdField];
    object.isCloseOut = (query[isCloseOutField]?? 0) == 0 ? false : true;
    object.assignedToUserId = query[assignedToUserIdField];
    object.assignedToUserName = query[assignedToUserNameField];
    object.assignedToUserOrgName = query[assignedToUserOrgNameField];
    object.msgNum = query[msgNumField].toString().isEmpty ? 0 : int.parse(query[msgNumField].toString());
    object.revisionId = query[revisionIdField].toString();
    object.requestJsonForOffline = query[requestJsonForOfflineField].toString();
    object.formDueDays = query[formDueDaysField];
    object.formSyncDate = query[formSyncDateField];
    object.lastResponderForAssignedTo = query[lastResponderForAssignedToField];
    object.lastResponderForOriginator = query[lastResponderForOriginatorField];
    object.pageNumber = query[pageNumberField];
    object.observationDefectType = query[observationDefectTypeField];
    object.statusName = query[statusNameField];
    object.appBuilderId = query[appBuilderIdField];
    object.taskTypeName = query[taskTypeNameField];
    object.assignedToRoleName = query[assignedToRoleNameField];
    return object;
  }

  @override
  Future<Map<String, dynamic>> toMap(SiteForm object) {
    return Future.value({
      projectIdField:object.projectId?.plainValue()??"",
      formIdField:object.formId?.plainValue()??"",
      appTypeIdField:object.appTypeId?.toString()??"",
      formTypeIdField:object.formTypeId?.plainValue()??"",
      instanceGroupIdField:object.instanceGroupId?.plainValue()??"",
      formTitleField:object.title??"",
      codeField:object.code??"",
      commentIdField:object.commId?.plainValue()??"",
      messageIdField:object.msgId?.plainValue()??"",
      parentMessageIdField:object.parentMsgId??"",
      orgIdField:object.orgId?.plainValue()??"",
      firstNameField:object.firstName??"",
      lastNameField:object.lastName??"",
      orgNameField:object.orgName??"",
      originatorField:object.originator??"",
      originatorDisplayNameField:object.originatorDisplayName??"",
      noOfActionsField:object.noOfActions?.toString()??"",
      observationIdField:object.observationId?.toString()??"",
      locationIdField:object.locationId?.toString()??"",
      pfLocFolderIdField:object.pfLocFolderId?.toString()??"",
      updatedField:object.updated??"",
      attachmentImageNameField:object.attachmentImageName??"",
      msgCodeField:object.msgCode??"",
      typeImageField:object.typeImage??"",
      docTypeField:object.docType??"",
      hasAttachmentsField:(object.hasAttachments??false) ? 1 : 0,
      hasDocAssocationsField:(object.hasDocAssocations??false) ? 1 : 0,
      hasBimViewAssociationsField:(object.hasBimViewAssociations??false) ? 1 : 0,
      hasFormAssocationsField:(object.hasFormAssocations??false) ? 1 : 0,
      hasCommentAssocationsField:(object.hasCommentAssocations??false) ? 1 : 0,
      formHasAssocAttachField:(object.formHasAssocAttach??false) ? 1 : 0,
      formCreationDateField:object.formCreationDate??"",
      folderIdField:object.folderId?.plainValue()??"",
      msgTypeIdField:object.msgTypeId??"",
      msgStatusIdField:object.msgStatusId??"",
      formNumberField:object.formNum?.toString()??"",
      msgOriginatorIdField:object.msgOriginatorId?.toString()??"",
      templateTypeField:object.templateType?.toString()??"",
      isDraftField:(object.isDraft??false) ? 1 : 0,
      statusIdField:object.statusid??"",
      originatorIdField:object.originatorId??"",
      isStatusChangeRestrictedField:(object.isStatusChangeRestricted??false) ? 1 : 0,
      allowReopenFormField:(object.allowReopenForm??false) ? 1 : 0,
      canOrigChangeStatusField:(object.canOrigChangeStatus??false) ? 1 : 0,
      msgTypeCodeField:object.msgTypeCode??"",
      idField:object.id??"",
      statusChangeUserIdField:object.statusChangeUserId?.toString()??"",
      statusUpdateDateField:object.statusUpdateDate??"",
      statusChangeUserNameField:object.statusChangeUserName??"",
      statusChangeUserPicField:object.statusChangeUserPic??"",
      statusChangeUserEmailField:object.statusChangeUserEmail??"",
      statusChangeUserOrgField:object.statusChangeUserOrg??"",
      originatorEmailField:object.originatorEmail??"",
      controllerUserIdField:object.controllerUserId??"",
      updatedDateInMSField:object.updatedDateInMS??"",
      formCreationDateInMSField:object.formCreationDateInMS??"",
      responseRequestByInMSField:object.responseRequestByInMS??"",
      flagTypeField:object.flagType?.toString()??"",
      latestDraftIdField:object.latestDraftId?.plainValue()??"",
      flagTypeImageNameField:object.flagTypeImageName??"",
      messageTypeImageNameField:object.messageTypeImageName??"",
      canAccessHistoryField:(object.canAccessHistory??false) ? 1 : 0,
      formJsonDataField:object.formJsonData??"",
      statusField:object.status??"",
      attachedDocsField:object.attachedDocs??"",
      isUploadAttachmentInTempField:(object.isUploadAttachmentInTemp??false) ? 1 : 0,
      isSyncField:(object.isSync??false) ? 1 : 0,
      userRefCodeField:object.userRefCode??"",
      hasActionsField:(object.hasActions??false) ? 1 : 0,
      canRemoveOfflineField:(object.canRemoveOffline??false) ? 1 : 0,
      isMarkOfflineField:(object.isMarkOffline??false) ? 1 : 0,
      isOfflineCreatedField:(object.isOfflineCreated??false) ? 1 : 0,
      syncStatusField:object.syncStatus?.value??ESyncStatus.failed.value,
      isForDefectField:(object.isForDefect??false) ? 1 : 0,
      isForAppsField:(object.isForApps??false) ? 1 : 0,
      observationDefectTypeIdField:object.manageTypeId?.toString()??object.observationDefectTypeId?.toString()??"",
      startDateField:object.startDate??"",
      expectedFinishDateField:object.expectedFinishDate??"",
      isActiveField:(object.isActive??false) ? 1 : 0,
      observationCoordinatesField:object.observationCoordinates??"",
      annotationIdField:object.annotationId??"",
      isCloseOutField:(object.isCloseOut??false) ? 1 : 0,
      assignedToUserIdField:object.assignedToUserId??"",
      assignedToUserNameField:object.assignedToUserName??"",
      assignedToUserOrgNameField:object.assignedToUserOrgName??"",
      msgNumField:object.msgNum?.toString()??"",
      revisionIdField:object.revisionId??"",
      requestJsonForOfflineField:object.requestJsonForOffline??"",
      formDueDaysField:object.formDueDays?.toString()??"",
      formSyncDateField:object.formSyncDate??"",
      lastResponderForAssignedToField:object.lastResponderForAssignedTo??"",
      lastResponderForOriginatorField:object.lastResponderForOriginator??"",
      pageNumberField:object.pageNumber?.toString()??"",
      observationDefectTypeField:object.manageTypeName??object.observationDefectType??object.workPackage??"",
      statusNameField:object.statusName??"",
      appBuilderIdField:object.appBuilderId??"",
      taskTypeNameField:object.taskTypeName??"",
      assignedToRoleNameField:object.assignedToRoleName??"",
    });
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<SiteForm> objects) async {
    List<Map<String, dynamic>> siteFormList = [];
    for (var element in objects) {
      Map<String,dynamic> map = await toMap(element);
      siteFormList.add(map);
    }
    return siteFormList;
  }

  Future<void> insert(List<SiteForm> formList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(formList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

}