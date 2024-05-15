import 'package:field/utils/extensions.dart';

import '../../database/dao.dart';
import '../../database/db_manager.dart';
import '../../logger/logger.dart';
import '../../utils/app_path_helper.dart';
import '../model/floor_bim_model_vo.dart';

class FloorBimModelDao extends Dao<FloorBimModel> {
  final tableName = 'FloorBimModelListTbl';
  static const bimModelId = "bimModelId";
  static const floorId = "FloorId";

  String get fields => "$bimModelId INTEGER NOT NULL,"
      "$floorId TEXT NOT NULL";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields)";

  @override
  String get getTableName => tableName;

  @override
  List<FloorBimModel> fromList(List<Map<String, dynamic>> query) {
    return List<FloorBimModel>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  fromMap(Map<String, dynamic> query) {
    FloorBimModel item = FloorBimModel();
    item.floorId = query[floorId].toString();
    item.bimModelId = query[bimModelId].toString();
    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(FloorBimModel object) {
    return Future.value({bimModelId: object.bimModelId?.plainValue() ?? 0, floorId: object.floorId ?? ""});
  }

  Future<void> insert(List<FloorBimModel> floorBimModelList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(floorBimModelList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<FloorBimModel> objects) async {
    List<Map<String, dynamic>> projectList = [];
    for (var element in objects) {
      projectList.add(await toMap(element));
    }
    return projectList;
  }

  Future<List<FloorBimModel>> fetch({String? bimModelId}) async {
    List<FloorBimModel> list = [];
    String query = bimModelId != null ? "SELECT * FROM $tableName WHERE ${FloorBimModelDao.bimModelId} = $bimModelId" : "SELECT * FROM $tableName";

    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(tableName, query);
      list = fromList(qurResult);
      return list;
    } on Exception catch (e) {
      Log.d(e);
      return list;
    }
  }

  Future<void> delete(String bimMoId, {String? floorNum}) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    String deleteQuery = floorNum != null ?
    "DELETE FROM $tableName WHERE $bimModelId = $bimMoId AND $floorId = $floorNum" :
    "DELETE FROM $tableName WHERE $bimModelId = $bimMoId";
    try {
      db.executeTableRequest(deleteQuery);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<void> deleteAllQuery() async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    String deleteQuery = "DELETE FROM $tableName";
    try {
      db.executeTableRequest(deleteQuery);
    } on Exception catch (e) {
      Log.d(e);
    }
  }


}
