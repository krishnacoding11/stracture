import 'package:field/data/model/user_reference_formtype_template_vo.dart';
import 'package:field/database/dao.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';

import '../model/apptype_vo.dart';

class UserReferenceFormTypeTemplateDao extends Dao<UserReferenceFormTypeTemplateVo> {
  static const tableName = 'UserReferenceFormTypeTemplateTbl';
  static const userId = "UserId";
  static const projectIdField = "ProjectId";
  static const formTypeIdField = "FormTypeId";
  static const userCloudIdField = "UserCloudId";

  String get fields => "$userId TEXT,"
      "$projectIdField TEXT,"
      "$formTypeIdField TEXT,"
      "$userCloudIdField TEXT";

  @override
  String get getTableName => tableName;

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields)";

  @override
  List<UserReferenceFormTypeTemplateVo> fromList(List<Map<String, dynamic>> query) {
    return List<UserReferenceFormTypeTemplateVo>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  UserReferenceFormTypeTemplateVo fromMap(Map<String, dynamic> query) {
    UserReferenceFormTypeTemplateVo userReferenceFormTypeVo = UserReferenceFormTypeTemplateVo();
    userReferenceFormTypeVo.userId = query[userId].toString();
    userReferenceFormTypeVo.projectId = query[projectIdField].toString();
    userReferenceFormTypeVo.formTypeID = query[formTypeIdField].toString();
    userReferenceFormTypeVo.userCloudId = query[userCloudIdField].toString();
    return userReferenceFormTypeVo;
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<UserReferenceFormTypeTemplateVo> objects) async {
    List<Map<String, dynamic>> attachmentList = [];
    for (var element in objects) {
      attachmentList.add(await toMap(element));
    }
    return attachmentList;
  }

  @override
  Future<Map<String, dynamic>> toMap(UserReferenceFormTypeTemplateVo object) {
    return Future.value({userId: object.userId, projectIdField: object.projectId, formTypeIdField: object.formTypeID, userCloudIdField: object.userCloudId});
  }

  Future<void> insertFormTypeTemplateDetailsInUserReference({required String projectId, required String formTypeId}) async {
    final userId = await StorePreference.getUserId();
    final userCloudId = await StorePreference.getUserCloud();
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userReference}");
    String query = "INSERT INTO $tableName (UserId, ProjectId, FormTypeId, UserCloudId) SELECT '$userId', '${projectId.plainValue()}', '${formTypeId.plainValue()}','$userCloudId' WHERE NOT EXISTS (SELECT 1 FROM $tableName WHERE UserId = '$userId' AND ProjectId = '${projectId.plainValue()}' AND FormTypeId = '${formTypeId.plainValue()}' AND UserCloudId = '$userCloudId');";
    if (userId != null && userCloudId != null) {
      try {
        db.executeTableRequest(createTableQuery);
        await db.executeTableRequest(query);
      } on Exception catch (e) {
        Log.d(e);
      }
    }
  }

  Future<void> insertFormTypeTemplateDetailsInUserReferenceBulk(List<AppType> objects) async {
    final userId = await StorePreference.getUserId();
    final userCloudId = await StorePreference.getUserCloud();
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userReference}");
    try {
      db.executeTableRequest(createTableQuery);
      List<UserReferenceFormTypeTemplateVo> list = objects.map((element) => UserReferenceFormTypeTemplateVo(userId: userId,projectId:  element.projectID.plainValue(),formTypeID:  element.formTypeID.plainValue(),userCloudId:  userCloudId)).toList();
      List<Map<String, dynamic>> rowList = await toListMap(list);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<void> deleteFormTypeTemplateDetailsInUserReference({required String? projectId, required String? formTypeId}) async {
    final userId = await StorePreference.getUserId();
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userReference}");
    String query = "DELETE FROM $tableName WHERE UserId= $userId AND ProjectId= $projectId AND FormTypeId= $formTypeId";
    if (projectId != null && formTypeId != null) {
      try {
        await db.executeTableRequest(query);
      } on Exception catch (e) {
        Log.d(e);
      }
    }
  }



  Future<bool> shouldDeleteFormTypeTemplate({required String projectId, required String formTypeId}) async {
    try {
      String selectQuery = "SELECT count(DISTINCT UserId) as UniqueUser FROM $tableName WHERE ProjectId = $projectId AND FormTypeId = $formTypeId";

      final path = await DatabaseManager.getUserDBPath();
      final db = DatabaseManager("$path/${AConstants.userReference}");

      var queryResult = db.executeSelectFromTable(tableName, selectQuery);
      for (var element in queryResult) {
        return element["UniqueUser"] < 1;
      }
    } catch (e, stacktrace) {
      Log.d("RemoveFormTypeFromTableByProjectId exception $e $stacktrace}");
    }
    return false;
  }
}
