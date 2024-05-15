import 'package:field/data/model/form_message_attach_assoc_vo.dart';
import 'package:field/data/model/user_reference_attachment_vo.dart';
import 'package:field/database/dao.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';

class UserReferenceAttachmentDao extends Dao<UserReferenceAttachmentVo> {
  static const tableName = 'UserReferenceAttachmentTbl';
  static const userId = "UserId";
  static const projectIdField = "ProjectId";
  static const revisionIdField = "RevisionId";
  static const userCloudIdField = "UserCloudId";

  String get fields => "$userId TEXT,"
      "$projectIdField TEXT,"
      "$revisionIdField TEXT,"
      "$userCloudIdField TEXT";

  @override
  String get getTableName => tableName;

  @override
  String get createTableQuery =>
      "CREATE TABLE IF NOT EXISTS $tableName($fields)";

  @override
  List<UserReferenceAttachmentVo> fromList(List<Map<String, dynamic>> query) {
    return List<UserReferenceAttachmentVo>.from(
        query.map((element) => fromMap(element))).toList();
  }

  @override
  UserReferenceAttachmentVo fromMap(Map<String, dynamic> query) {
    UserReferenceAttachmentVo userReferenceAttachmentVo =
        UserReferenceAttachmentVo();
    userReferenceAttachmentVo.userId = query[userId].toString();
    userReferenceAttachmentVo.projectId = query[projectIdField].toString();
    userReferenceAttachmentVo.revisionId = query[revisionIdField].toString();
    userReferenceAttachmentVo.userCloudId = query[userCloudIdField].toString();
    return userReferenceAttachmentVo;
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(
      List<UserReferenceAttachmentVo> objects) async {
    List<Map<String, dynamic>> attachmentList = [];
    for (var element in objects) {
      attachmentList.add(await toMap(element));
    }
    return attachmentList;
  }

  @override
  Future<Map<String, dynamic>> toMap(UserReferenceAttachmentVo object) {
    return Future.value({
      userId: object.userId,
      projectIdField: object.projectId,
      revisionIdField: object.revisionId,
      userCloudIdField: object.userCloudId
    });
  }

  Future<void> insertAttachmentDetailsInUserReference(
      List<FormMessageAttachAndAssocVO> formMessageAttachAndAssocList) async {
    final userId = await StorePreference.getUserId();
    final userCloudId = await StorePreference.getUserCloud();
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userReference}");
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(
          await addDataToAttachmentList(
              formMessageAttachAndAssocList, userId.toString(), userCloudId.toString()));

      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<bool> shouldAddAttachmentData(
      String projectId, String revisionId, String userId, String userCloudId) async {
    var data = [];
    String query =
        "SELECT * FROM UserReferenceAttachmentTbl WHERE UserId = $userId AND ProjectId = $projectId AND RevisionId = $revisionId AND UserCloudId = $userCloudId";
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userReference}");
    try {
      data = db.executeSelectFromTable("UserReferenceAttachmentTbl", query);
    } on Exception catch (e) {
      Log.d(e);
    }
    return data.isEmpty;
  }

  Future<List<UserReferenceAttachmentVo>> addDataToAttachmentList(
      List<FormMessageAttachAndAssocVO> formMessageAttachAndAssocList,
      String userId, String userCloudId) async {
    List<UserReferenceAttachmentVo> attachmentList = [];
    for (FormMessageAttachAndAssocVO data in formMessageAttachAndAssocList) {
      UserReferenceAttachmentVo attachment = UserReferenceAttachmentVo();
      attachment.userId = userId;
      attachment.projectId = data.projectId?.plainValue();
      attachment.revisionId = data.attachRevId.plainValue();
      attachment.userCloudId = userCloudId;

      if (data.attachRevId != null) {
        final shouldDataAdd = await shouldAddAttachmentData(
            data.projectId?.plainValue(), data.attachRevId.plainValue(), userId, userCloudId);
        if (shouldDataAdd) {
          attachmentList.add(attachment);
        }
      }
    }
    return attachmentList;
  }
}
