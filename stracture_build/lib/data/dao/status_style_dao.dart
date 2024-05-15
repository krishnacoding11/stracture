import 'package:field/data/model/status_style_list_vo.dart';
import 'package:field/database/dao.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';

class StatusStyleListDao extends Dao<StatusStyleVO> {
  static const tableName = 'StatusStyleListTbl';

  static const projectIdField="ProjectId";
  static const statusIdField="StatusId";
  static const statusNameField="StatusName";
  static const fontColorField="FontColor";
  static const backGrounColorField = "BackgroundColor";
  static const fontEffectField = "FontEffect";
  static const fontTypeField = "FontType";
  static const statusTypeIdField = "StatusTypeId";
  static const isActiveField = "IsActive";

  String get fields => "$projectIdField TEXT NOT NULL,"
                        "$statusIdField INTEGER NOT NULL,"
                        "$statusNameField TEXT NOY NULL,"
                        "$fontColorField TEXT,"
                        "$backGrounColorField TEXT NOT NULL,"
                        "$fontEffectField TEXT,"
                        "$fontTypeField TEXT,"
                        "$statusTypeIdField INTEGER NOT NULL DEFAULT 0,"
                        "$isActiveField  INTEGER NOT NULL DEFAULT  0";

  String get primaryKeys => ",PRIMARY KEY($projectIdField,$statusIdField)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<StatusStyleVO> fromList(List<Map<String, dynamic>> query) {
    return List<StatusStyleVO>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  StatusStyleVO fromMap(Map<String, dynamic> query) {
    StatusStyleVO item = StatusStyleVO();

    item.setProjectId=query[projectIdField];
    item.setStatusId=query[statusIdField];
    item.setStatusName=query[statusNameField];
    item.setBackgroundColor=query[backGrounColorField];
    item.setFontColor=query[fontColorField];
    item.setFontEffect=query[fontEffectField];
    item.setFontType=query[fontTypeField];
    item.setStatusTypeId=query[statusIdField];
    item.setIsActive=(query[isActiveField]==1)?true:false;

    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(StatusStyleVO object) {
    return Future.value({
      projectIdField:object.projectId?.toString().plainValue()??"",
      statusIdField:object.statusId?.toString().plainValue()??"",
      statusNameField:object.statusName??"",
      fontColorField:object.fontColor??"",
      backGrounColorField:object.backgroundColor??"",
      fontEffectField:object.fontEffect??"",
      fontTypeField:object.fontType??"",
      statusTypeIdField:object.statusTypeId??"",
      isActiveField:(object.isActive??false) ? 1 : 0,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<StatusStyleVO> objects) async {
    List<Map<String, dynamic>> itemList = [];
    for (var element in objects) {
      itemList.add(await toMap(element));
    }
    return itemList;
  }

  Future<void> insert(List<StatusStyleVO> statusStypeList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(statusStypeList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }
}