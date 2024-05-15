import 'package:field/utils/extensions.dart';

import '../../database/dao.dart';
import '../../database/db_manager.dart';
import '../../logger/logger.dart';
import '../../utils/app_path_helper.dart';
import '../model/model_bim_model_vo.dart';

class ModelBimModelDao extends Dao<ModelBimModel> {
  final tableName = 'ModelBimModelListTbl';
  static const modelId = "ModelId";
  static const bimModelId = "BimModelId";

  String get fields => "$modelId INTEGER NOT NULL,"
      "$bimModelId INTEGER NOT NULL";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields)";

  @override
  String get getTableName => tableName;

  @override
  List<ModelBimModel> fromList(List<Map<String, dynamic>> query) {
    return List<ModelBimModel>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  fromMap(Map<String, dynamic> query) {
    ModelBimModel item = ModelBimModel();
    item.modelId = query[modelId].toString();
    item.bimModelId = query[bimModelId].toString();
    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(ModelBimModel object) {
    return Future.value({
      modelId: object.modelId?.plainValue() ?? 0,
      bimModelId: object.bimModelId ?? 0,
    });
  }

  Future<void> insert(List<ModelBimModel> modelBimModelList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(modelBimModelList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<List<ModelBimModel>> fetch({String? modelId}) async {
    List<ModelBimModel> list = [];
    String query = modelId != null ? "SELECT * FROM $tableName WHERE ModelId = ${modelId.plainValue()}" : "SELECT * FROM $tableName";
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

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<ModelBimModel> objects) async {
    List<Map<String, dynamic>> projectList = [];
    for (var element in objects) {
      projectList.add(await toMap(element));
    }
    return projectList;
  }

  Future<void> delete(String model) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    String deleteQuery = "DELETE FROM $tableName WHERE ModelId = $model";
    try {
      db.executeTableRequest(deleteQuery);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<void> deleteByRevId(String revId) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    String deleteQuery = "DELETE FROM $tableName WHERE $bimModelId = $revId";
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
