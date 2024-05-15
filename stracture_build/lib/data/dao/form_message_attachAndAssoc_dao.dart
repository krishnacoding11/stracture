import 'dart:io';

import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';

import '../../database/dao.dart';
import '../../utils/field_enums.dart';
import '../../utils/file_utils.dart';
import '../../utils/parser_utility.dart';
import '../../utils/utils.dart';
import '../model/form_message_attach_assoc_vo.dart';

class FormMessageAttachAndAssocDao extends Dao<FormMessageAttachAndAssocVO> {
  static const tableName = 'FormMsgAttachAndAssocListTbl';

  static const projectIdField = "ProjectId";
  static const formTypeIdField = "FormTypeId";
  static const formIdField = "FormId";
  static const msgIdField = "MsgId";
  static const attachmentTypeField = "AttachmentType";
  static const attachAssocDetailJsonField = "AttachAssocDetailJson";
  static const offlineUploadFilePath = "OfflineUploadFilePath";
  static const attachDocIdField = "AttachDocId";
  static const attachRevIdField = "AttachRevId";
  static const attachFileNameField = "AttachFileName";
  static const assocProjectIdField = "AssocProjectId";
  static const assocDocFolderIdField = "AssocDocFolderId";
  static const assocDocRevisionIdField = "AssocDocRevisionId";
  static const assocFormCommIdField = "AssocFormCommId";
  static const assocCommentMsgIdField = "AssocCommentMsgId";
  static const assocCommentIdField = "AssocCommentId";
  static const assocCommentRevisionIdField = "AssocCommentRevisionId";
  static const assocViewModelIdField = "AssocViewModelId";
  static const assocViewIdField = "AssocViewId";
  static const assocListModelIdField = "AssocListModelId";
  static const assocListIdField = "AssocListId";
  static const attachSizeField = "AttachSize";

  String get fields => "$projectIdField TEXT NOT NULL,"
      "$formTypeIdField TEXT NOT NULL,"
      "$formIdField TEXT NOT NULL,"
      "$msgIdField TEXT NOT NULL,"
      "$attachmentTypeField TEXT NOT NULL,"
      "$attachAssocDetailJsonField TEXT NOT NULL,"
      "$offlineUploadFilePath TEXT,"
      "$attachDocIdField TEXT,"
      "$attachRevIdField TEXT,"
      "$attachFileNameField TEXT,"
      "$assocProjectIdField TEXT,"
      "$assocDocFolderIdField TEXT,"
      "$assocDocRevisionIdField TEXT,"
      "$assocFormCommIdField TEXT,"
      "$assocCommentMsgIdField TEXT,"
      "$assocCommentIdField TEXT,"
      "$assocCommentRevisionIdField TEXT,"
      "$assocViewModelIdField TEXT,"
      "$assocViewIdField TEXT,"
      "$assocListModelIdField TEXT,"
      "$assocListIdField TEXT,"
      "$attachSizeField TEXT";

  String get primaryKeys => "";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  String get getAttachSizeField => attachSizeField;

  @override
  List<FormMessageAttachAndAssocVO> fromList(List<Map<String, dynamic>> query) {
    return List<FormMessageAttachAndAssocVO>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  FormMessageAttachAndAssocVO fromMap(Map<String, dynamic> query) {
    FormMessageAttachAndAssocVO item = FormMessageAttachAndAssocVO();
    item.setProjectId = query[projectIdField];
    item.setFormTypeId = query[formTypeIdField];
    item.setFormId = query[formIdField];
    item.setFormMsgId = query[msgIdField];
    item.setAttachType = query[attachmentTypeField];
    item.setAttachAssocDetailJson = query[attachAssocDetailJsonField];
    item.setOfflineUploadFilePath = query[offlineUploadFilePath];
    item.setAttachDocId = query[attachDocIdField];
    item.setAttachRevId = query[attachRevIdField];
    item.setAttachFileName = query[attachFileNameField];
    item.setAssocProjectId = query[assocProjectIdField];
    item.setAssocDocFolderId = query[assocDocFolderIdField];
    item.setAssocDocRevisionId = query[assocDocRevisionIdField];
    item.setAssocFormCommId = query[assocFormCommIdField];
    item.setAssocCommentMsgId = query[assocCommentMsgIdField];
    item.setAssocCommentId = query[assocCommentIdField];
    item.setAssocCommentRevisionId = query[assocCommentRevisionIdField];
    item.setAssocViewModelId = query[assocViewModelIdField];
    item.setAssocViewId = query[assocViewIdField];
    item.setAssocListModelId = query[assocListModelIdField];
    item.setAssocListId = query[assocListIdField];
    item.setAttachSize = int.parse(query[attachSizeField]);
    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(FormMessageAttachAndAssocVO object) {
    return Future.value({
      projectIdField: object.projectId?.plainValue() ?? "",
      formTypeIdField: object.formTypeId?.plainValue() ?? "",
      formIdField: object.formId?.plainValue() ?? "",
      msgIdField: object.formMsgId?.plainValue() ?? "",
      attachmentTypeField: object.attachType ?? "",
      attachAssocDetailJsonField: ParserUtility.formAttachAndAssociationJsonDeHashed(jsonData: object.attachAssocDetailJson ?? ""),
      offlineUploadFilePath: object.offlineUploadFilePath ?? "",
      attachDocIdField: object.attachDocId?.plainValue() ?? "",
      attachRevIdField: object.attachRevId?.plainValue() ?? "",
      attachFileNameField: object.attachFileName ?? "",
      assocProjectIdField: object.assocProjectId?.plainValue() ?? "",
      assocDocFolderIdField: object.assocDocFolderId?.plainValue() ?? "",
      assocDocRevisionIdField: object.assocDocRevisionId?.plainValue() ?? "",
      assocFormCommIdField: object.assocFormCommId?.plainValue() ?? "",
      assocCommentMsgIdField: object.assocCommentMsgId?.plainValue() ?? "",
      assocCommentIdField: object.assocCommentId?.plainValue() ?? "",
      assocCommentRevisionIdField: object.assocCommentRevisionId?.plainValue() ?? "",
      assocViewModelIdField: object.assocViewModelId?.plainValue() ?? "",
      assocViewIdField: object.assocViewId?.plainValue() ?? "",
      assocListModelIdField: object.assocListModelId?.plainValue() ?? "",
      assocListIdField: object.assocListId?.plainValue() ?? "",
      attachSizeField: object.attachSize?.toString() ?? '0'
    });
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<FormMessageAttachAndAssocVO> objects) async {
    List<Map<String, dynamic>> itemList = [];
    for (var element in objects) {
      itemList.add(await toMap(element));
    }
    return itemList;
  }

  Future<void> insert(List<FormMessageAttachAndAssocVO> formMessageAttachAndAssocList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(formMessageAttachAndAssocList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<List<FormMessageAttachAndAssocVO>> getValidDownloadAttachmentList(List<FormMessageAttachAndAssocVO> formMessageAttachList) async {
    List<FormMessageAttachAndAssocVO> tmpListOfFormMessageAttachment = [];
    await Future.forEach(formMessageAttachList, (FormMessageAttachAndAssocVO formMessageAttachAndAssocVOObj) async {
      if (!formMessageAttachAndAssocVOObj.attachType.isNullOrEmpty() && EAttachmentAndAssociationType.fromNumber(int.parse(formMessageAttachAndAssocVOObj.attachType!)) == EAttachmentAndAssociationType.attachments && !(formMessageAttachAndAssocVOObj.attachRevId.plainValue().toString().isNullOrEmpty())) {
        String attachFilePath = await AppPathHelper().getAttachmentFilePath(projectId: formMessageAttachAndAssocVOObj.projectId.toString().plainValue(), revisionId: formMessageAttachAndAssocVOObj.attachRevId.toString().plainValue(), fileExtention: Utility.getFileExtension(formMessageAttachAndAssocVOObj.attachFileName));
        if (!(await isFileExists(File(attachFilePath)))) {
          tmpListOfFormMessageAttachment.add(formMessageAttachAndAssocVOObj);
        }
      }
    });
    return tmpListOfFormMessageAttachment;
  }
}
