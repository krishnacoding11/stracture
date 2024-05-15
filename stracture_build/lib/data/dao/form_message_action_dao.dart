

import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';

import '../../database/dao.dart';
import '../model/site_form_action.dart';

class FormMessageActionDao extends Dao<SiteFormAction> {
  static const tableName = 'FormMsgActionListTbl';

  static const projectIdField="ProjectId";
  static const formIdField="FormId";
  static const msgIdField="MsgId";
  static const actionIdField="ActionId";
  static const actionNameField="ActionName";
  static const actionStatusField="ActionStatus";
  static const priorityIdField="PriorityId";
  static const actionDateField="ActionDate";
  static const actionDueDateField="ActionDueDate";
  static const distributorUserIdField="DistributorUserId";
  static const recipientUserIdField="RecipientUserId";
  static const remarksField="Remarks";
  static const distListIdField="DistListId";
  static const transNumField="TransNum";
  static const actionTimeField="ActionTime";
  static const actionCompleteDateField="ActionCompleteDate";
  static const actionNotesField="ActionNotes";
  static const entityTypeField="EntityType";
  static const modelIdField="ModelId";
  static const assignedByField="AssignedBy";
  static const recipientNameField="RecipientName";
  static const recipientOrgIdField="RecipientOrgId";
  static const idField="Id";
  static const viewDateField="ViewDate";
  static const isActiveField="IsActive";
  static const resourceIdField="ResourceId";
  static const resourceParentIdField="ResourceParentId";
  static const resourceCodeField="ResourceCode";
  static const commentMsgIdField="CommentMsgId";
  static const isActionCompleteField="IsActionComplete";
  static const isActionClearField="IsActionClear";
  static const actionStatusNameField="ActionStatusName";
  static const actionDueDateMilliSecondField="ActionDueDateMilliSecond";
  static const actionDateMilliSecondField="ActionDateMilliSecond";
  static const actionCompleteDateMilliSecondField="ActionCompleteDateMilliSecond";

  String get fields => "$projectIdField TEXT NOT NULL,"
      "$formIdField TEXT NOT NULL,"
      "$msgIdField TEXT NOT NULL,"
      "$actionIdField TEXT NOT NULL,"
      "$actionNameField TEXT,"
      "$actionStatusField TEXT,"
      "$priorityIdField TEXT,"
      "$actionDateField TEXT,"
      "$actionDueDateField TEXT,"
      "$distributorUserIdField TEXT,"
      "$recipientUserIdField TEXT,"
      "$remarksField TEXT,"
      "$distListIdField TEXT,"
      "$transNumField TEXT,"
      "$actionTimeField TEXT,"
      "$actionCompleteDateField TEXT,"
      "$actionNotesField TEXT,"
      "$entityTypeField TEXT,"
      "$modelIdField TEXT,"
      "$assignedByField TEXT,"
      "$recipientNameField TEXT,"
      "$recipientOrgIdField TEXT,"
      "$idField TEXT,"
      "$viewDateField TEXT,"
      "$isActiveField INTEGER NOT NULL DEFAULT 0,"
      "$resourceIdField TEXT,"
      "$resourceParentIdField TEXT,"
      "$resourceCodeField TEXT,"
      "$commentMsgIdField TEXT,"
      "$isActionCompleteField INTEGER NOT NULL DEFAULT 0,"
      "$isActionClearField INTEGER NOT NULL DEFAULT 0,"
      "$actionStatusNameField TEXT,"
      "$actionDueDateMilliSecondField INTEGER NOT NULL DEFAULT 0,"
      "$actionDateMilliSecondField INTEGER NOT NULL DEFAULT 0,"
      "$actionCompleteDateMilliSecondField INTEGER NOT NULL DEFAULT 0";

  String get primaryKeys => ",PRIMARY KEY($projectIdField,$formIdField,$msgIdField,$actionIdField)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<SiteFormAction> fromList(List<Map<String, dynamic>> query) {
    return List<SiteFormAction>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  SiteFormAction fromMap(Map<String, dynamic> query) {
    SiteFormAction item = SiteFormAction();
    item.setActionId = query[actionIdField];
    item.setActionName = query[actionNameField];
    item.setActionStatus = query[actionStatusField];
    item.setActionDate = query[actionDateField];
    item.setDueDate = query[actionDueDateField];
    item.setRecipientId = query[recipientUserIdField];
    item.setRemarks = query[remarksField];
    item.setActionTime = query[actionTimeField];
    item.setActionCompleteDate = query[actionCompleteDateField];
    item.setIsActive = (query[isActiveField]==1)?true:false;
    item.setAssignedBy = query[assignedByField];
    item.setRecipientName = query[recipientNameField];
    item.setDueDateInMS = query[actionDueDateMilliSecondField];
    item.setActionCleared = (query[isActionClearField]==1)?true:false;
    item.setActionCompleted = (query[isActionCompleteField]==1)?true:false;

    item.setProjectId = query[projectIdField];
    item.setFormId = query[formIdField];
    item.setMsgId = query[msgIdField];
    item.setActionNotes = query[actionNotesField];
    item.setPriorityId = query[priorityIdField];
    item.setDistributorUserId = query[distributorUserIdField];
    item.setDistListId = query[distListIdField];
    item.setTransNum = query[transNumField];
    item.setEntityType = query[entityTypeField];
    item.setModelId = query[modelIdField];
    item.setRecipientOrgId = query[recipientOrgIdField];
    item.setId = query[idField];
    item.setViewDate = query[viewDateField];
    item.setResourceId = query[resourceIdField];
    item.setResourceParentId = query[resourceParentIdField];
    item.setResourceCode = query[resourceCodeField];
    item.setCommentMsgId = query[commentMsgIdField];
    item.setActionStatusName = query[actionStatusNameField];
    item.setActionDueDateMilliSecond = query[actionDueDateMilliSecondField];
    item.setActionCompleteDateInMS = query[actionCompleteDateMilliSecondField];
    item.setActionDateInMS = query[actionDateMilliSecondField];
    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(SiteFormAction object) {
    return Future.value({
      projectIdField:object.projectId?.plainValue()??"",
      formIdField:object.formId?.plainValue()??"",
      msgIdField:object.msgId?.plainValue()??"",
      actionIdField:object.actionId?.plainValue()??"",
      actionNameField:object.actionName??"",
      actionStatusField:object.actionStatus?.plainValue()??"",
      priorityIdField:object.priorityId?.plainValue()??"",
      actionDateField:object.actionDate??"",
      actionDueDateField:object.dueDate??"",
      distributorUserIdField:object.distributorUserId??"",
      recipientUserIdField:object.recipientId??"",
      remarksField:object.remarks??"",
      distListIdField:object.distListId??"",
      transNumField:object.transNum??"",
      actionTimeField:object.actionTime??"",
      actionCompleteDateField:object.actionCompleteDate??"",
      actionNotesField:object.actionNotes??"",
      entityTypeField:object.entityType??"",
      modelIdField:object.modelId?.plainValue()??"",
      assignedByField:object.assignedBy??"",
      recipientNameField:object.recipientName??"",
      recipientOrgIdField:object.recipientOrgId??"",
      idField:object.id??"",
      viewDateField:object.viewDate??"",
      isActiveField:(object.isActive??false) ? 1 : 0,
      resourceIdField:object.resourceId??"",
      resourceParentIdField:object.resourceParentId??"",
      resourceCodeField:object.resourceCode??"",
      commentMsgIdField:object.commentMsgId?.plainValue()??"",
      isActionCompleteField:(object.actionCompleted??false) ? 1 : 0,
      isActionClearField:(object.actionCleared??false) ? 1 : 0,
      actionStatusNameField:object.actionStatusName??"",
      actionDueDateMilliSecondField:object.actionDueDateMilliSecond??"0",
      actionCompleteDateMilliSecondField:object.actionCompleteDateInMS??"0",
      actionDateMilliSecondField:object.actionDateInMS??"0",
    });
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<SiteFormAction> objects) async {
    List<Map<String, dynamic>> itemList = [];
    for (var element in objects) {
      itemList.add(await toMap(element));
    }
    return itemList;
  }

  Future<void> insert(List<SiteFormAction> siteFormActionList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(siteFormActionList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }
}