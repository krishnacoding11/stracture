import 'package:field/database/dao.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';

import '../model/offline_activity_vo.dart';

class OfflineActivityDao extends Dao<OfflineActivityVo> {
  static const tableName = 'OfflineActivityTbl';

  static const projectIdField = "ProjectId";
  static const formTypeIdField = "FormTypeId";
  static const formIdField = "FormId";
  static const msgIdField = "MsgId";
  static const actionIdField = "actionId";
  static const distListIdField = "DistListId";
  static const offlineRequestDataField = "OfflineRequestData";
  static const createdDateInMsField = "CreatedDateInMs";

  String get fields => "$projectIdField TEXT NOT NULL,"
      "$formTypeIdField TEXT NOT NULL,"
      "$formIdField TEXT NOT NULL,"
      "$msgIdField TEXT NOT NULL,"
      "$actionIdField TEXT NOT NULL,"
      "$distListIdField TEXT NOT NULL,"
      "$offlineRequestDataField TEXT NOT NULL,"
      "$createdDateInMsField TEXT NOT NULL";

  String get primaryKeys => ",PRIMARY KEY($projectIdField,$formIdField,$msgIdField,$actionIdField,$distListIdField)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<OfflineActivityVo> fromList(List<Map<String, dynamic>> query) {
    return List<OfflineActivityVo>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  OfflineActivityVo fromMap(Map<String, dynamic> query) {
    OfflineActivityVo item = OfflineActivityVo();
    item.projectId = query[projectIdField];
    item.formTypeId = query[formTypeIdField];
    item.formId = query[formIdField];
    item.msgId = query[msgIdField];
    item.actionId = query[actionIdField];
    item.distListId = query[distListIdField];
    item.offlineRequestData = query[offlineRequestDataField];
    item.createdDateInMs = query[createdDateInMsField];

    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(OfflineActivityVo object) {
    return Future.value({
      projectIdField: object.projectId.toString().plainValue(),
      formTypeIdField: object.formTypeId,
      formIdField: object.formId,
      msgIdField: object.msgId,
      actionIdField: object.actionId,
      distListIdField: object.distListId,
      offlineRequestDataField: object.offlineRequestData,
      createdDateInMsField: object.createdDateInMs,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<OfflineActivityVo> objects) async {
    List<Map<String, dynamic>> itemList = [];
    for (var element in objects) {
      itemList.add(await toMap(element));
    }
    return itemList;
  }

  Future<void> insert(List<OfflineActivityVo> list) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(list);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }
}
