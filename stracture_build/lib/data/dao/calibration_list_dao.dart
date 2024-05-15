import 'package:field/data/dao/bim_model_calibration_dao.dart';
import 'package:field/data/dao/model_list_dao.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/database/dao.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';

class CalibrationListDao extends Dao<CalibrationDetails> {
  final tableName = 'CalibrateTbl';
  static const modelId = "ModelId";
  static const revisionId = "revisionId";
  static const calibrationId = "calibrationId";
  static const sizeOf2DFile = "sizeOf2dFile";
  static const createdByUserid = "createdByUserid";
  static const calibratedBy = "calibratedBy";
  static const createdDate = "createdDate";
  static const modifiedDate = "modifiedDate";
  static const point3D1 = "point3d1";
  static const point3D2 = "point3d2";
  static const point2D1 = "point2d1";
  static const point2D2 = "point2d2";
  static const depth = "depth";
  static const fileName = "fileName";
  static const fileType = "fileType";
  static const documentId = "documentId";
  static const docRef = "docRef";
  static const folderPath = "folderPath";
  static const calibrationImageId = "calibrationImageId";
  static const pageWidth = "pageWidth";
  static const pageHeight = "pageHeight";
  static const pageRotation = "pageRotation";
  static const folderId = "folderId";
  static const calibrationName = "calibrationName";
  static const generateUri = "generateURI";
  static const isChecked = "isChecked";
  static const isDownloaded = "isDownloaded";
  static const projectId = "projectId";

  String get fields => "$modelId INTEGER NOT NULL,"
      "$revisionId	INTEGER NOT NULL,"
      "$calibrationId TEXT NOT NULL,"
      "$sizeOf2DFile TEXT NOT NULL,"
      "$createdByUserid TEXT NOT NULL,"
      "$calibratedBy TEXT NOT NULL,"
      "$createdDate TEXT NOT NULL,"
      "$modifiedDate TEXT NOT NULL,"
      "$point3D1 TEXT NOT NULL,"
      "$point3D2 TEXT NOT NULL,"
      "$point2D1 TEXT NOT NULL,"
      "$point2D2 TEXT NOT NULL,"
      "$depth TEXT NOT NULL,"
      "$fileName TEXT NOT NULL,"
      "$fileType TEXT NOT NULL,"
      "$documentId TEXT NOT NULL,"
      "$docRef TEXT NOT NULL,"
      "$folderPath TEXT NOT NULL,"
      "$calibrationImageId TEXT NOT NULL,"
      "$pageWidth TEXT NOT NULL,"
      "$pageHeight TEXT NOT NULL,"
      "$pageRotation TEXT NOT NULL,"
      "$folderId TEXT NOT NULL,"
      "$calibrationName TEXT NOT NULL,"
      "$isChecked INTEGER NOT NULL,"
      "$isDownloaded INTEGER NOT NULL,"
      "$generateUri TEXT NOT NULL,"
      "$projectId TEXT NOT NULL,";

  String get primaryKeys => "PRIMARY KEY($calibrationId)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  List<CalibrationDetails> fromList(List<Map<String, dynamic>> query) {
    return List<CalibrationDetails>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  CalibrationDetails fromMap(Map<String, dynamic> query) {
    CalibrationDetails item = CalibrationDetails(
      modelId: query[modelId].toString(),
      revisionId: query[revisionId].toString(),
      calibrationId: query[calibrationId],
      sizeOf2DFile: int.parse(query[sizeOf2DFile]),
      createdByUserid: query[createdByUserid],
      calibratedBy: query[calibratedBy],
      createdDate: query[createdDate],
      modifiedDate: query[modifiedDate],
      point3D1: query[point3D1],
      point3D2: query[point3D2],
      point2D1: query[point2D1],
      point2D2: query[point2D2],
      depth: double.parse(query[depth] ?? "0.0"),
      fileName: query[fileName],
      fileType: query[fileType],
      documentId: query[documentId],
      docRef: query[docRef],
      folderPath: query[folderPath],
      calibrationImageId: query[calibrationImageId],
      pageWidth: query[pageWidth],
      pageHeight: query[pageHeight],
      pageRotation: query[pageRotation],
      folderId: query[folderId],
      calibrationName: query[calibrationName],
      isChecked: query[isChecked] == 1,
      isDownloaded: query[isDownloaded] == 1,
      generateUri: query[generateUri] == "1",
      projectId: query[projectId] ?? "",
    );

    return item;
  }

  @override
  // TODO: implement getTableName
  String get getTableName => tableName;

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<CalibrationDetails> objects) async {
    List<Map<String, dynamic>> projectList = [];
    for (var element in objects) {
      projectList.add(await toMap(element));
    }
    return projectList;
  }

  @override
  Future<Map<String, dynamic>> toMap(CalibrationDetails object) {
    return Future.value({
      modelId: object.modelId.plainValue() ?? "",
      revisionId: object.revisionId.plainValue() ?? "",
      calibrationId: object.calibrationId.plainValue() ?? "",
      sizeOf2DFile: object.sizeOf2DFile,
      createdByUserid: object.createdByUserid,
      calibratedBy: object.calibratedBy,
      createdDate: object.createdDate,
      modifiedDate: object.modifiedDate,
      point3D1: object.point3D1,
      point3D2: object.point3D2,
      point2D1: object.point2D1,
      point2D2: object.point2D2,
      depth: object.depth,
      fileName: object.fileName,
      fileType: object.fileType,
      documentId: object.documentId,
      docRef: object.docRef,
      folderPath: object.folderPath,
      calibrationImageId: object.calibrationImageId ?? "",
      pageWidth: object.pageWidth,
      pageHeight: object.pageHeight,
      pageRotation: object.pageRotation,
      folderId: object.folderId,
      calibrationName: object.calibrationName,
      isChecked: object.isChecked,
      isDownloaded: object.isDownloaded,
      generateUri: object.generateUri,
      projectId: object.projectId,
    });
  }

  Future<void> insert(List<CalibrationDetails> projectList) async {
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

  Future<List<CalibrationDetails>> fetchAll(String selectedProjectId) async {
    List<CalibrationDetails> list = [];
    String query = "SELECT * FROM $tableName WHERE $isDownloaded = 1 AND $projectId = $selectedProjectId";
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

  Future<List<CalibrationDetails>> fetchModelWise(String modelId) async {
    List<CalibrationDetails> list = [];
    String query = "SELECT * FROM $tableName where ModelId = $modelId AND $isDownloaded = 1";
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

  Future<List<CalibrationDetails>> fetch({
    String? modelId,
    String? revId,
  }) async {
    List<CalibrationDetails> list = [];
    String query = revId != null ? "SELECT * FROM $tableName WHERE $revisionId = $revId" : "SELECT * FROM $tableName WHERE ModelId = $modelId";
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

  Future<void> updateIsDownloaded(
    CalibrationDetails calibrate,
  ) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);

    String query = 'UPDATE $tableName SET `$isDownloaded` = ${calibrate.isDownloaded ? 1 : 0} WHERE $revisionId = ${calibrate.revisionId.plainValue()}';

    try {
      db.executeTableRequest(query);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<void> delete(String bimModel, {String? caliId, String? modelId,bool isTest =false}) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    String deleteQuery = caliId != null ? "DELETE FROM $tableName WHERE $revisionId = $bimModel" : "DELETE FROM $tableName WHERE $revisionId = $bimModel";
    try {
      db.executeTableRequest(deleteQuery);
      List<CalibrationDetails> caliList = await fetch(revId: bimModel.plainValue());
      if (caliList.isEmpty && (!isTest)) {
        ModelListDao.deleteListCalibrate(modelId: modelId, revId: "");
      }
    } on Exception catch (e) {
      Log.d(e);
    }
  }



  Future<void> deleteModelWise(String modelId) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);

    String deleteQuery = "DELETE FROM $tableName WHERE ModelId = $modelId";
    try {
      db.executeTableRequest(deleteQuery);
      BimModelCalibrationModelDao().delete(modelId);
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
