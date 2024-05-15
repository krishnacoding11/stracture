import 'package:field/data/dao/bim_model_list_dao.dart';
import 'package:field/data/dao/floor_bim_model_dao.dart';
import 'package:field/data/model/floor_bim_model_vo.dart';
import 'package:field/data/model/floor_details.dart';
import 'package:field/database/dao.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/extensions.dart';
import '../../database/db_manager.dart';
import '../../utils/app_path_helper.dart';

class FloorListDao extends Dao<FloorDetail> {
  final tableName = 'FloorListTbl';
  static const bimModelId = "bimModelId";
  static const id = "id";
  static const revisionId = "revisionId";
  static const fileName = "fileName";
  static const fileSize = "fileSize";
  static const floorNumber = "floorNumber";
  static const levelName = "levelName";
  static const isChecked = "isChecked";
  static const isDownloaded = "isDownloaded";
  static const projectId = "projectId";
  static const revName = "revName";

  String get fields => "$bimModelId TEXT NOT NULL,"
      "$revisionId INTEGER NOT NULL,"
      "$fileName TEXT NOT NULL,"
      "$floorNumber TEXT NOT NULL,"
      "$levelName TEXT NOT NULL,"
      "$fileSize TEXT NOT NULL,"
      "$isChecked INTEGER NOT NULL,"
      "$isDownloaded INTEGER NOT NULL,"
      "$projectId TEXT NOT NULL,"
      "$revName TEXT NOT NULL";

  String get primaryKeys => "PRIMARY KEY($fileName)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields)";

  @override
  List<FloorDetail> fromList(List<Map<String, dynamic>> query) {
    return List<FloorDetail>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  FloorDetail fromMap(Map<String, dynamic> query) {
    return FloorDetail(
      revisionId: int.parse(query[revisionId]?.toString() ?? "0"),
      fileName: query[fileName].toString(),
      floorNumber: int.parse(query[floorNumber]?.toString() ?? "0"),
      levelName: query[levelName].toString(),
      fileSize: query[fileSize] as dynamic,
      bimModelId: query[bimModelId].toString(),
      isChecked: query[isChecked] == 1,
      isDownloaded: query[isDownloaded] == 1,
      projectId: query[projectId].toString(),
      revName: query[revName].toString(),
    );
  }

  @override
  String get getTableName => tableName;

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<FloorDetail> objects) async {
    List<Map<String, dynamic>> projectList = [];
    for (var element in objects) {
      projectList.add(await toMap(element));
    }
    return projectList;
  }

  @override
  Future<Map<String, dynamic>> toMap(FloorDetail object) {
    return Future.value({
      bimModelId: object.bimModelId.toString(),
      revisionId: object.revisionId,
      fileName: object.fileName.toString(),
      floorNumber: object.floorNumber,
      levelName: object.levelName,
      fileSize: object.fileSize,
      isChecked: object.isChecked,
      isDownloaded: object.isDownloaded,
      projectId: object.projectId,
      revName: object.revName,
    });
  }

  Future<void> insert(List<FloorDetail> projectList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(projectList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<List<FloorDetail>> fetch(String bimModelId) async {
    FloorBimModelDao dao = FloorBimModelDao();

    List<FloorBimModel> _floorBimModel = await dao.fetch(bimModelId: bimModelId);

    List<String> ids = _floorBimModel.map((obj) => obj.bimModelId!).toList();

    List<FloorDetail> list = [];
    String query = "SELECT * FROM $tableName WHERE $revisionId IN (${ids.join(",")})";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(tableName, query);
      list = fromList(qurResult);
      return list;
    } catch (e) {
      return list;
    }
  }

  Future<List<FloorDetail>> fetchAll(String selectedProjectId) async {
    List<FloorDetail> list = [];
    String query = "SELECT * FROM $tableName WHERE $isDownloaded = 1 AND $projectId = ${selectedProjectId.plainValue()}";
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


  Future<void> delete(String revId, {String? floorNum, String? modelId,bool isTest=false}) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);

    String deleteQuery = floorNum != null ?
    "DELETE FROM $tableName WHERE $revisionId = $revId AND $floorNumber = $floorNum" :
    "DELETE FROM $tableName WHERE $bimModelId = $revId";
    try {
      db.executeTableRequest(deleteQuery);

      List<FloorDetail> list = await fetch(revId.plainValue());

      if (list.isEmpty && (!isTest)) {
        await BimModelListDao.deleteListCalibrate(revId, modelId: modelId);
      }
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<void> deleteModelWise(String modelId) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    String deleteQuery = "DELETE FROM $tableName WHERE $bimModelId = $modelId";
    try {
      db.executeTableRequest(deleteQuery);
      await FloorBimModelDao().delete(modelId);
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

  Future<void> updateIsDownloaded(FloorDetail floor) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);

    String query = 'UPDATE $tableName SET `$isDownloaded` = ${floor.isDownloaded ? 1 : 0} WHERE $revisionId = ${floor.revisionId} AND $floorNumber = ${floor.floorNumber}';

    try {
      db.executeTableRequest(query);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<List<FloorDetail>> fetchByBimModelIds(List<String> bimModelIds) async {
    List<FloorDetail> list = [];
    String query = "SELECT * FROM $tableName WHERE $revisionId IN (${bimModelIds.join(",")}) AND ${FloorListDao.isDownloaded} = 1";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(tableName, query);
      list = fromList(qurResult);
      return list;
    } catch(e){
      return list;
    }
  }
}
