
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/parser_utility.dart';

import '../../database/dao.dart';
import '../model/form_message_vo.dart';

class FormMessageDao extends Dao<FormMessageVO> {
  static const tableName = 'FormMessageListTbl';

  static const projectIdField="ProjectId";
  static const formTypeIdField="FormTypeId";
  static const formIdField="FormId";
  static const msgIdField="MsgId";
  static const originatorField="Originator";
  static const originatorDisplayNameField="OriginatorDisplayName";
  static const msgCodeField="MsgCode";
  static const msgCreatedDateField="MsgCreatedDate";
  static const parentMsgIdField="ParentMsgId";
  static const msgOriginatorIdField="MsgOriginatorId";
  static const msgHasAssocAttachField="MsgHasAssocAttach";
  static const jsonDataField="JsonData";
  static const userRefCodeField="UserRefCode";
  static const updatedDateInMSField="UpdatedDateInMS";
  static const formCreationDateInMSField="FormCreationDateInMS";
  static const msgCreatedDateInMSField="MsgCreatedDateInMS";
  static const msgTypeIdField="MsgTypeId";
  static const msgTypeCodeField="MsgTypeCode";
  static const msgStatusIdField="MsgStatusId";
  static const sentNamesField="SentNames";
  static const sentActionsField="SentActions";
  static const draftSentActionsField="DraftSentActions";
  static const fixFieldDataField="FixFieldData";
  static const folderIdField="FolderId";
  static const latestDraftIdField="LatestDraftId";
  static const isDraftField="IsDraft";
  static const assocRevIdsField="AssocRevIds";
  static const responseRequestByField="ResponseRequestBy";
  static const delFormIdsField="DelFormIds";
  static const assocFormIdsField="AssocFormIds";
  static const assocCommIdsField="AssocCommIds";
  static const formUserSetField="FormUserSet";
  static const formPermissionsMapField="FormPermissionsMap";
  static const canOrigChangeStatusField="CanOrigChangeStatus";
  static const canControllerChangeStatusField="CanControllerChangeStatus";
  static const isStatusChangeRestrictedField="IsStatusChangeRestricted";
  static const hasOverallStatusField="HasOverallStatus";
  static const isCloseOutField="IsCloseOut";
  static const allowReopenFormField="AllowReopenForm";
  static const offlineRequestDataField="OfflineRequestData";
  static const isOfflineCreatedField="IsOfflineCreated";
  static const locationIdField="LocationId";
  static const observationIdField="ObservationId";
  static const msgNumField="MsgNum";
  static const msgContentField="MsgContent";
  static const actionCompleteField="ActionComplete";
  static const actionClearedField="ActionCleared";
  static const hasAttachField="HasAttach";
  static const totalActionsField="TotalActions";
  static const instanceGroupIdField="InstanceGroupId";
  static const attachFilesField="AttachFiles";
  static const hasViewAccessField="HasViewAccess";
  static const msgOriginImageField="MsgOriginImage";
  static const isForInfoIncompleteField="IsForInfoIncomplete";
  static const msgCreatedDateOfflineField="MsgCreatedDateOffline";
  static const lastModifiedTimeField="LastModifiedTime";
  static const lastModifiedTimeInMSField="LastModifiedTimeInMS";
  static const canViewDraftMsgField="CanViewDraftMsg";
  static const canViewOwnorgPrivateFormsField="CanViewOwnorgPrivateForms";
  static const isAutoSavedDraftField="IsAutoSavedDraft";
  static const msgStatusNameField="MsgStatusName";
  static const projectAPDFolderIdField="ProjectAPDFolderId";
  static const projectStatusIdField="ProjectStatusId";
  static const hasFormAccessField="HasFormAccess";
  static const canAccessHistoryField="CanAccessHistory";
  static const hasDocAssocationsField="HasDocAssocations";
  static const hasBimViewAssociationsField="HasBimViewAssociations";
  static const hasBimListAssociationsField="HasBimListAssociations";
  static const hasFormAssocationsField="HasFormAssocations";
  static const hasCommentAssocationsField="HasCommentAssocations";

  String get fields => "$projectIdField TEXT NOT NULL,"
      "$formTypeIdField TEXT NOT NULL,"
      "$formIdField TEXT NOT NULL,"
      "$msgIdField TEXT NOT NULL,"
      "$originatorField TEXT,"
      "$originatorDisplayNameField TEXT,"
      "$msgCodeField TEXT,"
      "$msgCreatedDateField TEXT,"
      "$parentMsgIdField TEXT,"
      "$msgOriginatorIdField TEXT,"
      "$msgHasAssocAttachField INTEGER NOT NULL DEFAULT 0,"
      "$jsonDataField TEXT,"
      "$userRefCodeField TEXT,"
      "$updatedDateInMSField TEXT,"
      "$formCreationDateInMSField TEXT,"
      "$msgCreatedDateInMSField TEXT,"
      "$msgTypeIdField TEXT,"
      "$msgTypeCodeField TEXT,"
      "$msgStatusIdField TEXT,"
      "$sentNamesField TEXT,"
      "$sentActionsField TEXT,"
      "$draftSentActionsField TEXT,"
      "$fixFieldDataField TEXT,"
      "$folderIdField TEXT,"
      "$latestDraftIdField TEXT,"
      "$isDraftField INTEGER NOT NULL DEFAULT 0,"
      "$assocRevIdsField TEXT,"
      "$responseRequestByField TEXT,"
      "$delFormIdsField TEXT,"
      "$assocFormIdsField TEXT,"
      "$assocCommIdsField TEXT,"
      "$formUserSetField TEXT,"
      "$formPermissionsMapField TEXT,"
      "$canOrigChangeStatusField INTEGER NOT NULL DEFAULT 0,"
      "$canControllerChangeStatusField INTEGER NOT NULL DEFAULT 0,"
      "$isStatusChangeRestrictedField INTEGER NOT NULL DEFAULT 0,"
      "$hasOverallStatusField INTEGER NOT NULL DEFAULT 0,"
      "$isCloseOutField INTEGER NOT NULL DEFAULT 0,"
      "$allowReopenFormField INTEGER NOT NULL DEFAULT 0,"
      "$offlineRequestDataField TEXT NOT NULL DEFAULT \"\","
      "$isOfflineCreatedField INTEGER NOT NULL DEFAULT 0,"
      "$locationIdField INTEGER,"
      "$observationIdField INTEGER,"
      "$msgNumField INTEGER,"
      "$msgContentField TEXT,"
      "$actionCompleteField INTEGER NOT NULL DEFAULT 0,"
      "$actionClearedField INTEGER NOT NULL DEFAULT 0,"
      "$hasAttachField INTEGER NOT NULL DEFAULT 0,"
      "$totalActionsField INTEGER,"
      "$instanceGroupIdField INTEGER,"
      "$attachFilesField TEXT,"
      "$hasViewAccessField INTEGER NOT NULL DEFAULT 0,"
      "$msgOriginImageField TEXT,"
      "$isForInfoIncompleteField INTEGER NOT NULL DEFAULT 0,"
      "$msgCreatedDateOfflineField TEXT,"
      "$lastModifiedTimeField TEXT,"
      "$lastModifiedTimeInMSField TEXT,"
      "$canViewDraftMsgField INTEGER NOT NULL DEFAULT 0,"
      "$canViewOwnorgPrivateFormsField INTEGER NOT NULL DEFAULT 0,"
      "$isAutoSavedDraftField INTEGER NOT NULL DEFAULT 0,"
      "$msgStatusNameField TEXT,"
      "$projectAPDFolderIdField TEXT,"
      "$projectStatusIdField TEXT,"
      "$hasFormAccessField INTEGER NOT NULL DEFAULT 0,"
      "$canAccessHistoryField INTEGER NOT NULL DEFAULT 0,"
      "$hasDocAssocationsField INTEGER NOT NULL DEFAULT 0,"
      "$hasBimViewAssociationsField INTEGER NOT NULL DEFAULT 0,"
      "$hasBimListAssociationsField INTEGER NOT NULL DEFAULT 0,"
      "$hasFormAssocationsField INTEGER NOT NULL DEFAULT 0,"
      "$hasCommentAssocationsField INTEGER NOT NULL DEFAULT 0";

  String get primaryKeys => ",PRIMARY KEY($projectIdField,$formIdField,$msgIdField)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<FormMessageVO> fromList(List<Map<String, dynamic>> query) {
    return List<FormMessageVO>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  FormMessageVO fromMap(Map<String, dynamic> query) {
    FormMessageVO item = FormMessageVO();
    item.setProjectId = query[projectIdField];
    item.setFormTypeId = query[formTypeIdField];
    item.setFormId = query[formIdField];
    item.setMsgId = query[msgIdField];
    item.setOriginator = query[originatorField];
    item.setMsgOriginDisplayUserName = query[originatorDisplayNameField];
    item.setMsgCode = query[msgCodeField];
    item.setMsgCreatedDate = query[msgCreatedDateField];
    item.setParentMsgId = query[parentMsgIdField];
    item.setMsgOriginatorId = query[msgOriginatorIdField];
    item.setMsgHasAssocAttach = (query[msgHasAssocAttachField]==1) ? true:false;
    item.setJsonData = query[jsonDataField];
    item.setUserRefCode = query[userRefCodeField];
    item.setUpdatedDateInMS = query[updatedDateInMSField];
    item.setFormCreationDateInMS = query[formCreationDateInMSField];
    item.setMsgCreatedDateInMS = query[msgCreatedDateInMSField];
    item.setMsgTypeId = query[msgTypeIdField];
    item.setMsgTypeCode = query[msgTypeCodeField];
    item.setMsgStatusId = query[msgStatusIdField];
    item.setSentNames = query[sentNamesField];
    item.setSentActions = query[sentActionsField];
    item.setDraftSentActions = query[draftSentActionsField];
    item.setFixFieldData = query[fixFieldDataField];
    item.setFolderId = query[folderIdField];
    item.setLatestDraftId = query[latestDraftIdField];
    item.setIsDraft = (query[isDraftField]==1) ? true:false;
    item.setAssocRevIds = query[assocRevIdsField];
    item.setResponseRequestBy = query[responseRequestByField];
    item.setDelFormIds = query[delFormIdsField];
    item.setAssocFormIds = query[assocFormIdsField];
    item.setAssocCommIds = query[assocCommIdsField];
    item.setFormUserSet = query[formUserSetField];
    item.setFormPermissionsMap = query[formPermissionsMapField];
    item.setCanOrigChangeStatus = (query[canOrigChangeStatusField]==1) ? true:false;
    item.setCanControllerChangeStatus = (query[canControllerChangeStatusField]==1) ? true:false;
    item.setIsStatusChangeRestricted = (query[isStatusChangeRestrictedField]==1) ? true:false;
    item.setHasOverallStatus = (query[hasOverallStatusField]==1) ? true:false;
    item.setIsCloseOut = (query[isCloseOutField]==1) ? true:false;
    item.setAllowReopenForm = (query[allowReopenFormField]==1) ? true:false;
    item.setOfflineRequestData = query[offlineRequestDataField];
    item.setIsOfflineCreated = (query[isOfflineCreatedField]==1) ? true:false;
    item.setLocationId = (query[locationIdField].runtimeType==String)?query[locationIdField]:query[locationIdField].toString();
    item.setObservationId = (query[observationIdField].runtimeType==String)?query[observationIdField]:query[observationIdField].toString();
    item.setMsgNum = query[msgNumField].toString();
    item.setMsgContent = query[msgContentField];
    item.setActionComplete = (query[actionCompleteField]==1) ? true:false;
    item.setActionCleared = (query[actionClearedField]==1) ? true:false;
    item.setHasAttach = (query[hasAttachField]==1) ? true:false;
    item.setTotalActions = query[totalActionsField].toString();
    item.setInstanceGroupId = (query[instanceGroupIdField].runtimeType==String)?query[instanceGroupIdField]:query[instanceGroupIdField].toString();
    item.setAttachFiles = query[attachFilesField];
    item.setHasViewAccess = (query[hasViewAccessField]==1) ? true:false;
    item.setMsgOriginImage = query[msgOriginImageField];
    item.setIsForInfoIncomplete = (query[isForInfoIncompleteField]==1) ? true:false;
    item.setMsgCreatedDateOffline = query[msgCreatedDateOfflineField];
    item.setLastModifiedTime = query[lastModifiedTimeField];
    item.setLastModifiedTimeInMS = query[lastModifiedTimeInMSField];
    item.setCanViewDraftMsg = (query[canViewDraftMsgField]==1) ? true:false;
    item.setCanViewOwnorgPrivateForms = (query[canViewOwnorgPrivateFormsField]==1) ? true:false;
    item.setIsAutoSavedDraft = (query[isAutoSavedDraftField]==1) ? true:false;
    item.setMsgStatusName = query[msgStatusNameField];
    item.setProjectAPDfolderId = query[projectAPDFolderIdField];
    item.setProjectStatusId = query[projectStatusIdField];
    item.setHasFormAccess = (query[hasFormAccessField]==1) ? true:false;
    item.setCanAccessHistory = (query[canAccessHistoryField]==1) ? true:false;
    item.setHasDocAssocations = (query[hasDocAssocationsField]==1) ? true:false;
    item.setHasBimViewAssociations = (query[hasBimViewAssociationsField]==1) ? true:false;
    item.setHasBimListAssociations = (query[hasBimListAssociationsField]==1) ? true:false;
    item.setHasFormAssocations = (query[hasFormAssocationsField]==1) ? true:false;
    item.setHasCommentAssocations = (query[hasCommentAssocationsField]==1) ? true:false;
    return item;
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<FormMessageVO> objects) async {
    List<Map<String, dynamic>> itemList = [];
    for (var element in objects) {
      itemList.add(await toMap(element));
    }
    return itemList;
  }

  @override
  Future<Map<String, dynamic>> toMap(FormMessageVO object) async {
    return Future.value({
      projectIdField:object.projectId?.plainValue()??"",
      formTypeIdField:object.formTypeId?.plainValue()??"",
      formIdField:object.formId?.plainValue()??"",
      msgIdField:object.msgId?.plainValue()??"",
      originatorField:object.originator??"",
      originatorDisplayNameField:object.msgOriginDisplayUserName??"",
      msgCodeField:object.msgCode??"",
      msgCreatedDateField:object.msgCreatedDate??"",
      parentMsgIdField:object.parentMsgId?.plainValue()??"",
      msgOriginatorIdField:object.msgOriginatorId?.plainValue()??"",
      msgHasAssocAttachField:(object.msgHasAssocAttach??false) ? 1 : 0,
      jsonDataField:object.jsonData??"",
      userRefCodeField:object.userRefCode??"",
      updatedDateInMSField:object.updatedDateInMS??"",
      formCreationDateInMSField:object.formCreationDateInMS??"",
      msgCreatedDateInMSField:object.msgCreatedDateInMS??"",
      msgTypeIdField:object.msgTypeId??"",
      msgTypeCodeField:object.msgTypeCode??"",
      msgStatusIdField:object.msgStatusId??"",
      sentNamesField:object.sentNames??"",
      sentActionsField:ParserUtility.sentActionsJsonDeHashed(jsonData: object.sentActions??""),
      draftSentActionsField:ParserUtility.draftSentActionsJsonDeHashed(jsonData: object.draftSentActions??""),
      fixFieldDataField:object.fixFieldData??"",
      folderIdField:object.folderId?.plainValue()??"",
      latestDraftIdField:object.latestDraftId?.plainValue()??"",
      isDraftField:(object.isDraft??false) ? 1 : 0,
      assocRevIdsField:object.assocRevIds??"",
      responseRequestByField:object.responseRequestBy??"",
      delFormIdsField:object.delFormIds??"",
      assocFormIdsField:object.assocFormIds??"",
      assocCommIdsField:object.assocCommIds??"",
      formUserSetField:object.formUserSet??"",
      formPermissionsMapField:object.formPermissionsMap??"",
      canOrigChangeStatusField:(object.canOrigChangeStatus??false) ? 1 : 0,
      canControllerChangeStatusField:(object.canControllerChangeStatus??false) ? 1 : 0,
      isStatusChangeRestrictedField:(object.isStatusChangeRestricted??false) ? 1 : 0,
      hasOverallStatusField:(object.hasOverallStatus??false) ? 1 : 0,
      isCloseOutField:(object.isCloseOut??false) ? 1 : 0,
      allowReopenFormField:(object.allowReopenForm??false) ? 1 : 0,
      offlineRequestDataField:object.offlineRequestData??"",
      isOfflineCreatedField:(object.isOfflineCreated??false) ? 1 : 0,
      locationIdField:object.locationId?.plainValue()??"",
      observationIdField:object.observationId?.plainValue()??"",
      msgNumField:object.msgNum??"",
      msgContentField:object.msgContent??"",
      actionCompleteField:(object.actionComplete??false) ? 1 : 0,
      actionClearedField:(object.actionCleared??false) ? 1 : 0,
      hasAttachField:(object.hasAttach??false) ? 1 : 0,
      totalActionsField:object.totalActions??"",
      instanceGroupIdField:object.instanceGroupId?.plainValue()??"",
      attachFilesField:object.attachFiles??"",
      hasViewAccessField:(object.hasViewAccess??false) ? 1 : 0,
      msgOriginImageField:object.msgOriginImage??"",
      isForInfoIncompleteField:(object.isForInfoIncomplete??false) ? 1 : 0,
      msgCreatedDateOfflineField:object.msgCreatedDateOffline??"",
      lastModifiedTimeField:object.lastModifiedTime??"",
      lastModifiedTimeInMSField:object.lastModifiedTimeInMS??"",
      canViewDraftMsgField:(object.canViewDraftMsg??false) ? 1 : 0,
      canViewOwnorgPrivateFormsField:(object.canViewOwnorgPrivateForms??false) ? 1 : 0,
      isAutoSavedDraftField:(object.isAutoSavedDraft??false) ? 1 : 0,
      msgStatusNameField:object.msgStatusName??"",
      projectAPDFolderIdField:object.projectAPDfolderId?.plainValue()??"",
      projectStatusIdField:object.projectStatusId?.plainValue()??"",
      hasFormAccessField:(object.hasFormAccess??false) ? 1 : 0,
      canAccessHistoryField:(object.canAccessHistory??false) ? 1 : 0,
      hasDocAssocationsField:(object.hasDocAssocations??false) ? 1 : 0,
      hasBimViewAssociationsField:(object.hasBimViewAssociations??false) ? 1 : 0,
      hasBimListAssociationsField:(object.hasBimListAssociations??false) ? 1 : 0,
      hasFormAssocationsField:(object.hasFormAssocations??false) ? 1 : 0,
      hasCommentAssocationsField:(object.hasCommentAssocations??false) ? 1 : 0,
    });
  }

  Future<void> insert(List<FormMessageVO> formMessageList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(formMessageList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

}