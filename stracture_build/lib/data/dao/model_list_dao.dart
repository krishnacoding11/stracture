import 'package:field/data/dao/calibration_list_dao.dart';
import 'package:field/data/dao/model_bim_models_dao.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/model_bim_model_vo.dart';
import 'package:field/data/model/model_vo.dart';
import 'package:field/utils/extensions.dart';

import '../../database/dao.dart';
import '../../database/db_manager.dart';
import '../../logger/logger.dart';
import '../../utils/app_path_helper.dart';

class ModelListDao extends Dao<Model> {
  static const tableName = 'ModelListTbl';

  static const modelIdField = "ModelId";
  static const bimModelId = "bimModelId";
  static const projectId = "projectId";
  static const projectName = "projectName";
  static const bimModelName = "bimModelName";
  static const modelDescription = "modelDescription";
  static const userModelName = "userModelName";
  static const modelCreatorUserId = "modelCreatorUserId";
  static const modelStatus = "modelStatus";
  static const modelCreationDate = "modelCreationDate";
  static const lastUpdateDate = "lastUpdateDate";
  static const mergeLevel = "mergeLevel";
  static const isFavoriteModel = "isFavoriteModel";
  static const dc = "dc";
  static const modelViewId = "modelViewId";
  static const revisionId = "revisionId";
  static const folderId = "folderId";
  static const revisionNumber = "revisionNumber";
  static const worksetId = "worksetId";
  static const docId = "docId";
  static const publisher = "publisher";
  static const lastUpdatedUserId = "lastUpdatedUserId";
  static const lastUpdatedBy = "lastUpdatedBy";
  static const lastAccessUserId = "lastAccessUserId";
  static const lastAccessBy = "lastAccessBy";
  static const lastAccessModelDate = "lastAccessModelDate";
  static const modelTypeId = "modelTypeId";
  static const generateUri = "generateUri";
  static const setAsOffline = "setAsOffline";
  static const modelSupportedOffline = "modelSupportedOffline";
  static const fileSize = "fileSize";

  String get fields => "$modelIdField TEXT NOT NULL,"
      "$bimModelId INTEGER NOT NULL,"
      "$projectId TEXT NOT NULL,"
      "$projectName TEXT NOT NULL,"
      "$bimModelName TEXT NOT NULL,"
      "$modelDescription TEXT NOT NULL,"
      "$userModelName TEXT NOT NULL,"
      "$modelCreatorUserId TEXT NOT NULL,"
      "$modelStatus TEXT NOT NULL,"
      "$modelCreationDate TEXT NOT NULL,"
      "$lastUpdateDate TEXT NOT NULL,"
      "$mergeLevel TEXT NOT NULL,"
      "$isFavoriteModel TEXT NOT NULL,"
      "$dc TEXT NOT NULL,"
      "$modelViewId TEXT NOT NULL,"
      "$revisionId TEXT NOT NULL,"
      "$folderId TEXT NOT NULL,"
      "$revisionNumber TEXT NOT NULL,"
      "$worksetId TEXT NOT NULL,"
      "$docId TEXT NOT NULL,"
      "$publisher TEXT NOT NULL,"
      "$lastUpdatedUserId TEXT NOT NULL,"
      "$lastUpdatedBy TEXT NOT NULL,"
      "$lastAccessUserId TEXT NOT NULL,"
      "$lastAccessBy TEXT NOT NULL,"
      "$lastAccessModelDate TEXT NOT NULL,"
      "$modelTypeId TEXT NOT NULL,"
      "$setAsOffline TEXT NOT NULL,"
      "$fileSize TEXT NOT NULL,"
      "$modelSupportedOffline INTEGER NOT NULL,"
      "$generateUri TEXT NOT NULL, ";

  String get primaryKeys => "PRIMARY KEY($modelIdField)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<Model> fromList(List<Map<String, dynamic>> query) {
    return List<Model>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  fromMap(Map<String, dynamic> query) {
    Model model = Model();
    model.bimModelId = query[bimModelId];
    model.modelId = query[modelIdField];
    model.projectId = query[projectId];
    model.projectName = query[projectName];
    model.bimModelName = query[bimModelName];
    model.modelDescription = query[modelDescription];
    model.userModelName = query[userModelName];
    model.modelCreatorUserId = query[modelCreatorUserId];
    model.modelStatus = query[modelStatus].toString() == "1";
    model.modelCreationDate = query[modelCreationDate];
    model.lastUpdateDate = query[lastUpdateDate];
    model.mergeLevel = int.parse(query[mergeLevel]);
    model.isFavoriteModel = int.parse(query[isFavoriteModel]);
    model.dc = query[dc];
    model.modelViewId = int.parse(query[modelViewId]);
    model.revisionId = query[revisionId];
    model.folderId = query[folderId];
    model.revisionNumber = int.parse(query[revisionNumber]);
    model.worksetId = query[worksetId];
    model.docId = query[docId];
    model.publisher = query[publisher];
    model.lastUpdatedUserId = query[lastUpdatedUserId];
    model.lastUpdatedBy = query[lastUpdatedBy];
    model.lastAccessUserId = query[lastAccessUserId];
    model.lastAccessBy = query[lastAccessBy];
    model.lastAccessModelDate = query[lastAccessModelDate];
    model.fileSize = query[fileSize];
    model.modelTypeId = int.parse(query[modelTypeId]);
    model.generateUri = query[generateUri] == "true";
    model.setAsOffline = query[setAsOffline].toString() == "1";
    model.modelSupportedOffline = query[modelSupportedOffline].toString() == "1";

    return model;
  }

  @override
  Future<Map<String, dynamic>> toMap(Model model) {
    return Future.value({
      modelIdField: model.bimModelId?.plainValue() ?? "",
      bimModelId: '${model.bimModelId}',
      projectId: '${model.projectId.plainValue()}',
      projectName: model.projectName,
      bimModelName: model.bimModelName!,
      modelDescription: model.modelDescription,
      userModelName: model.userModelName!,
      modelCreatorUserId: model.modelCreatorUserId!,
      modelStatus: model.modelStatus!,
      modelCreationDate: model.modelCreationDate!,
      lastUpdateDate: model.lastUpdateDate!,
      mergeLevel: model.mergeLevel!,
      isFavoriteModel: model.isFavoriteModel!,
      dc: model.dc!,
      modelViewId: model.modelViewId!,
      revisionId: model.revisionId!,
      folderId: model.folderId!,
      revisionNumber: model.revisionNumber!,
      worksetId: model.worksetId!,
      docId: model.docId!,
      publisher: model.publisher!,
      lastUpdatedUserId: model.lastUpdatedUserId!,
      lastUpdatedBy: model.lastUpdatedBy!,
      lastAccessUserId: model.lastAccessUserId!,
      lastAccessBy: model.lastAccessBy!,
      lastAccessModelDate: model.lastAccessModelDate!,
      modelTypeId: model.modelTypeId!,
      generateUri: model.generateUri!,
      setAsOffline: model.setAsOffline!,
      fileSize: model.fileSize ?? "",
      modelSupportedOffline: model.modelSupportedOffline ?? "",
    });
  }

  Future<void> insert(List<Model> modelList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(modelList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<List<Model>> fetch({String? modelId}) async {
    List<Model> list = [];
    String query = modelId != null ? "SELECT * FROM $tableName WHERE $modelIdField = $modelId" : "SELECT * FROM $tableName";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(tableName, query);
      list = fromList(qurResult);
      Log.d("Length of Model List--->${list.length}");
      return list;
    } on Exception catch (e) {
      Log.d(e);
      return list;
    }
  }

  Future<List<Model>> fetchSingleModel({required String modelId}) async {
    late List<Model> list;
    String query = "SELECT * FROM $tableName WHERE $modelIdField = $modelId LIMIT 1";
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
  Future<List<Map<String, dynamic>>> toListMap(List<Model> modelList) async {
    List<Map<String, dynamic>> projectList = [];
    for (var element in modelList) {
      projectList.add(await toMap(element));
    }
    return projectList;
  }

  Future<void> delete(String modelId) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);

    String deleteQuery = "DELETE FROM $tableName WHERE ModelId = ${modelId.plainValue()}";
    try {
      db.executeTableRequest(deleteQuery);
      await ModelBimModelDao().delete(modelId);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<void> updateFileSize(Model model) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);

    String query = 'UPDATE $tableName SET fileSize = ${model.fileSize} WHERE $modelIdField = ${model.bimModelId.plainValue()}';

    try {
      db.executeTableRequest(query);
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

  static Future<void> deleteListCalibrate({String? modelId, required String revId}) async {
    List<ModelBimModel> bimList = await ModelBimModelDao().fetch(modelId: modelId);
    List<CalibrationDetails> calibList = await CalibrationListDao().fetchModelWise(modelId!);
    if (calibList.isEmpty && bimList.isEmpty) {
      ModelListDao().delete(modelId);
    }
  }
}
