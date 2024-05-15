import 'package:field/utils/extensions.dart';

import '../../database/dao.dart';
import '../../database/db_manager.dart';
import '../../logger/logger.dart';
import '../../utils/app_path_helper.dart';
import '../model/floor_calibration_model_vo.dart';

class FloorCalibrationModelDao extends Dao<FloorCalibrationModel> {
  final tableName = 'FloorCalibratedListTbl';
  static const calibrationId = "calibrationId";
  static const floorId = "floorId";

  String get fields => "$calibrationId INTEGER NOT NULL,"
      "$floorId INTEGER NOT NULL";

  @override
  String get createTableQuery =>
      "CREATE TABLE IF NOT EXISTS $tableName($fields)";

  @override
  String get getTableName => tableName;

  @override
  List<FloorCalibrationModel> fromList(List<Map<String, dynamic>> query) {
    return List<FloorCalibrationModel>.from(
        query.map((element) => fromMap(element))).toList();
  }

  @override
  fromMap(Map<String, dynamic> query) {
    FloorCalibrationModel item = FloorCalibrationModel();
    item.floorId = query[calibrationId];
    item.floorId = query[floorId];
    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(FloorCalibrationModel object) {
    return Future.value({
      calibrationId: object.floorId?.plainValue() ?? "",
      floorId: '"${object.floorId}"',
    });
  }

  Future<void> insert(List<FloorCalibrationModel> floorCalibrationModelList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(floorCalibrationModelList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(
      List<FloorCalibrationModel> objects) async {
    List<Map<String, dynamic>> projectList = [];
    for (var element in objects) {
      projectList.add(await toMap(element));
    }
    return projectList;
  }
}
