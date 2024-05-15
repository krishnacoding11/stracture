
import 'package:field/data/model/manage_type_list_vo.dart';
import 'package:field/database/dao.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';

class ManageTypeDao extends Dao<ManageTypeVO> {
  static const tableName = 'ManageTypeListTbl';

  static const projectIdField="ProjectId";
  static const manageTypeIdField="ManageTypeId";
  static const manageTypeNameField="ManageTypeName";
  static const userIdField="UserId";
  static const userNameField = "UserName";
  static const orgIdField = "OrgId";
  static const orgNameField = "OrgName";
  static const isDeactiveField = "IsDeactive";

  String get fields => "$projectIdField TEXT NOT NULL,"
                        "$manageTypeIdField INTEGER,"
                        "$manageTypeNameField TEXT NOT NULL,"
                        "$userIdField TEXT,"
                        "$userNameField TEXT,"
                        "$orgIdField TEXT,"
                        "$orgNameField TEXT,"
                        "$isDeactiveField  INTEGER NOT NULL DEFAULT 0";

  String get primaryKeys => ",PRIMARY KEY($projectIdField,$manageTypeIdField)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<ManageTypeVO> fromList(List<Map<String, dynamic>> query) {
    return List<ManageTypeVO>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  ManageTypeVO fromMap(Map<String, dynamic> query) {
    ManageTypeVO item = ManageTypeVO();
    "$projectIdField TEXT NOT NULL,"
        "$manageTypeIdField INTEGER,"
        "$manageTypeNameField TEXT NOT NULL,"
        "$userIdField TEXT,"
        "$userNameField TEXT,"
        "$orgIdField TEXT,"
        "$orgNameField TEXT,"
        "$isDeactiveField  INTEGER NOT NULL DEFAULT 0";

    item.setProjectId=query[projectIdField];
    item.setManageTypeId=query[manageTypeIdField];
    item.setManageTypeName=query[manageTypeNameField];
    item.setUserId=query[userIdField];
    item.setUserName=query[userNameField];
    item.setOrgId=query[orgIdField];
    item.setOrgName=query[orgNameField];
    item.setIsDeactive=(query[isDeactiveField]==1)?true:false;

    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(ManageTypeVO object) {
    return Future.value({
      projectIdField: object.projectId?.toString().plainValue() ?? "",
      manageTypeIdField: object.manageTypeId?.toString().plainValue() ?? "",
      manageTypeNameField: object.manageTypeName ?? "",
      userIdField: object.userId?.toString().plainValue() ?? "",
      userNameField: object.userName ?? "",
      orgIdField: object.orgId.plainValue() ?? "",
      orgNameField: object.orgName ?? "",
      isDeactiveField: (object.isDeactive ?? false) ? 1 : 0,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<ManageTypeVO> objects) async {
    List<Map<String, dynamic>> itemList = [];
    for (var element in objects) {
      itemList.add(await toMap(element));
    }
    return itemList;
  }

  Future<void> insert(List<ManageTypeVO> manageTypeList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(manageTypeList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }
}
