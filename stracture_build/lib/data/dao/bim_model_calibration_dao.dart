import 'package:field/utils/extensions.dart';

import '../../database/dao.dart';
import '../../database/db_manager.dart';
import '../../logger/logger.dart';
import '../../utils/app_path_helper.dart';
import '../model/bim_model_calibration_vo.dart';

class BimModelCalibrationModelDao extends Dao<BimModelCalibrationModel> {
  final tableName = 'BimModelCalibrationModelListTbl';
  static const bimModelId = "bimModelId";
  static const calibrationId = "calibrationId";

  String get fields => "$bimModelId INTEGER NOT NULL,"
      "$calibrationId INTEGER NOT NULL";

  @override
  String get createTableQuery =>
      "CREATE TABLE IF NOT EXISTS $tableName($fields)";



  @override
  String get getTableName => tableName;

  @override
  List<BimModelCalibrationModel> fromList(List<Map<String, dynamic>> query) {
    return List<BimModelCalibrationModel>.from(
        query.map((element) => fromMap(element))).toList();
  }

  @override
  fromMap(Map<String, dynamic> query) {
    BimModelCalibrationModel item = BimModelCalibrationModel();
    item.bimModelId = query[bimModelId].toString();
    item.calibrationId = query[calibrationId].toString();
    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(BimModelCalibrationModel object) {
    return Future.value({
      bimModelId: object.bimModelId?.plainValue() ?? "",
      calibrationId: '${object.calibrationId}',
    });
  }

  Future<void> insert(
      List<BimModelCalibrationModel> bimModelCalibrationModelList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList =
          await toListMap(bimModelCalibrationModelList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<List<BimModelCalibrationModel>> fetch() async {
    List<BimModelCalibrationModel> list = [];
    String query = "SELECT * FROM $tableName";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult =
      db.executeSelectFromTable(tableName, query);
      list = fromList(qurResult);
      return list;
    } on Exception catch (e) {
      Log.d(e);
      return list;
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

  Future<void> delete(String bimModel,{String? caliId}) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
       final db = DatabaseManager(path);

    String deleteQuery = caliId != null
        ? "DELETE FROM $tableName WHERE $bimModelId = $bimModel AND $calibrationId = $caliId"
        : "DELETE FROM $tableName WHERE $bimModelId = $bimModel";
    try {
      db.executeTableRequest(deleteQuery);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(
      List<BimModelCalibrationModel> objects) async {
    List<Map<String, dynamic>> projectList = [];
    for (var element in objects) {
      projectList.add(await toMap(element));
    }
    return projectList;
  }
}
