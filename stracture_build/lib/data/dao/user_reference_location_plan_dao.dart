
import 'package:field/data/model/user_reference_attachment_vo.dart';
import 'package:field/database/dao.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';

class UserReferenceLocationPlanDao extends Dao<UserReferenceAttachmentVo> {
  static const tableName = 'UserReferenceLocationPlanTbl';
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
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields)";

  @override
  List<UserReferenceAttachmentVo> fromList(List<Map<String, dynamic>> query) {
    return List<UserReferenceAttachmentVo>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  UserReferenceAttachmentVo fromMap(Map<String, dynamic> query) {
    UserReferenceAttachmentVo userReferenceLocationPlanVo = UserReferenceAttachmentVo();
    userReferenceLocationPlanVo.userId = query[userId].toString();
    userReferenceLocationPlanVo.projectId = query[projectIdField].toString();
    userReferenceLocationPlanVo.revisionId = query[revisionIdField].toString();
    userReferenceLocationPlanVo.userCloudId = query[userCloudIdField].toString();
    return userReferenceLocationPlanVo;
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<UserReferenceAttachmentVo> objects) async {
    List<Map<String, dynamic>> attachmentList = [];
    for (var element in objects) {
      attachmentList.add(await toMap(element));
    }
    return attachmentList;
  }

  @override
  Future<Map<String, dynamic>> toMap(UserReferenceAttachmentVo object) {
    return Future.value({userId: object.userId, projectIdField: object.projectId, revisionIdField: object.revisionId, userCloudIdField: object.userCloudId});
  }

  Future<void> insertLocationPlanDetailsInUserReference({required String projectId, required String revisionId}) async {
    final userId = await StorePreference.getUserId();
    print("projectId$projectId, $revisionId");
    final userCloudId = await StorePreference.getUserCloud();
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userReference}");
    String query = "INSERT INTO $tableName (UserId, ProjectId, RevisionId, UserCloudId) SELECT '$userId', '${projectId.plainValue()}', '${revisionId.plainValue()}','$userCloudId' WHERE NOT EXISTS (SELECT 1 FROM $tableName WHERE UserId = '$userId' AND ProjectId = '${projectId.plainValue()}' AND RevisionId = '${revisionId.plainValue()}' AND UserCloudId = '$userCloudId');";
    if (userId != null && userCloudId != null) {
      try {
        db.executeTableRequest(createTableQuery);
        await db.executeTableRequest(query);
      } on Exception catch (e) {
        Log.d(e);
      }
    }
  }

  Future<void> deleteLocationPlanDetailsInUserReference({required String? projectId, required String? revisionId}) async {
    final userId = await StorePreference.getUserId();
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userReference}");
    String query = "DELETE FROM $tableName WHERE UserId= $userId AND ProjectId= $projectId AND RevisionId= $revisionId";
    if (projectId != null && revisionId != null) {
      try {
        await db.executeTableRequest(query);
      } on Exception catch (e) {
        Log.d(e);
      }
    }
  }

  Future<bool> shouldDeleteLocationPlan({required String projectId, required String revisionId}) async {
    try {
      String selectQuery = "SELECT count(DISTINCT UserId) as UniqueUser FROM $tableName WHERE ProjectId = $projectId AND RevisionId = $revisionId";

      final path = await DatabaseManager.getUserDBPath();
      final db = DatabaseManager("$path/${AConstants.userReference}");

      var queryResult = db.executeSelectFromTable(tableName, selectQuery);
      for (var element in queryResult) {
        return element["UniqueUser"] < 1;
      }
    } catch (e, stacktrace) {
      Log.d("RemoveLocationDataFromTableByProjectId exception $e $stacktrace}");
    }
    return false;
  }
}
