
import 'package:field/database/dao.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';

import '../model/custom_attribute_set_vo.dart';

class CustomAttributeSetDao extends Dao<CustomAttributeSetVo> {
  static const tableName = 'AttributeSetDetailTbl';

  static const projectIdField="ProjectId";
  static const attributeSetIdField="AttributeSetId";
  static const serverResponseField="jsonResponse";

  String get fields => "$projectIdField TEXT NOT NULL,"
      "$attributeSetIdField TEXT NOT NULL,"
      "$serverResponseField TEXT NOT NULL";

  String get primaryKeys => ",PRIMARY KEY($attributeSetIdField,$projectIdField)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<CustomAttributeSetVo> fromList(List<Map<String, dynamic>> query) {
    return List<CustomAttributeSetVo>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  CustomAttributeSetVo fromMap(Map<String, dynamic> query) {
    CustomAttributeSetVo item = CustomAttributeSetVo();
    "$projectIdField TEXT NOT NULL,"
    "$attributeSetIdField TEXT NOT NULL,"
    "$serverResponseField TEXT NOT NULL";

    item.projectId=query[projectIdField];
    item.attributeSetId=query[attributeSetIdField];
    item.serverResponse = query[serverResponseField];

    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(CustomAttributeSetVo object) {
    return Future.value({
      projectIdField:object.projectId.toString().plainValue()??"",
      attributeSetIdField:object.attributeSetId??"",
      serverResponseField:object.serverResponse??"",
    });
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<CustomAttributeSetVo> objects) async {
    List<Map<String, dynamic>> itemList = [];
    for (var element in objects) {
      itemList.add(await toMap(element));
    }
    return itemList;
  }

  Future<void> insert(List<CustomAttributeSetVo> manageTypeList) async {
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
