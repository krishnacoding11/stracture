import 'package:field/data/dao/floor_list_dao.dart';
import 'package:field/data/dao/model_bim_models_dao.dart';
import 'package:field/data/model/model_bim_model_vo.dart';
import 'package:field/utils/extensions.dart';

import '../../database/dao.dart';
import '../../database/db_manager.dart';
import '../../logger/logger.dart';
import '../../utils/app_path_helper.dart';
import '../model/bim_project_model_vo.dart';
import '../model/floor_details.dart';
import 'model_list_dao.dart';

class BimModelListDao extends Dao<BimModel> {
  final tableName = 'BimModelListTbl';

  static const bimModelIdField = "BimModelId";
  static const name = "name";
  static const fileName = "fileName";
  static const revId = "revId";
  static const isMerged = "isMerged";
  static const isChecked = "isChecked";
  static const disciplineId = "disciplineId";
  static const isLink = "isLink";
  static const filesize = "filesize";
  static const folderId = "folderId";
  static const fileLocation = "fileLocation";
  static const isLastUploaded = "isLastUploaded";
  static const bimIssueNumber = "bimIssueNumber";
  static const hsfChecksum = "hsfChecksum";
  static const bimIssueNumberModel = "bimIssueNumberModel";
  static const isDocAssociated = "isDocAssociated";
  static const docTitle = "docTitle";
  static const publisherName = "publisherName";
  static const orgName = "orgName";
  static const ifcName = "ifcName";

  String get fields => "$bimModelIdField INTEGER NOT NULL,"
      "$name TEXT NOT NULL,"
      "$fileName TEXT NOT NULL,"
      "$revId TEXT NOT NULL,"
      "$isMerged TEXT NOT NULL,"
      "$isChecked TEXT NOT NULL,"
      "$disciplineId TEXT NOT NULL,"
      "$isLink TEXT NOT NULL,"
      "$filesize TEXT NOT NULL,"
      "$folderId TEXT NOT NULL,"
      "$fileLocation TEXT NOT NULL,"
      "$isLastUploaded TEXT NOT NULL,"
      "$bimIssueNumber TEXT NOT NULL,"
      "$hsfChecksum TEXT NOT NULL,"
      "$bimIssueNumberModel TEXT NOT NULL,"
      "$isDocAssociated TEXT NOT NULL,"
      "$docTitle TEXT NOT NULL,"
      "$publisherName TEXT NOT NULL,"
      "$ifcName TEXT NOT NULL,"
      "$orgName TEXT NOT NULL,";

  String get primaryKeys => "PRIMARY KEY($revId)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<BimModel> fromList(List<Map<String, dynamic>> query) {
    return List<BimModel>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  fromMap(Map<String, dynamic> query) {
    BimModel item = BimModel();
    item.bimModelIdField = query[bimModelIdField].toString();
    item.name = query[name];
    item.fileName = query[fileName];
    item.revId = query[revId];
    item.isMerged = query[isMerged] == "1";
    item.isChecked = query[isChecked] == "1";
    item.disciplineId = int.parse(query[disciplineId] ?? "0");
    item.isLink = query[isLink] == "1";
    item.filesize = int.parse(query[filesize] ?? "0");
    item.folderId = query[folderId];
    item.fileLocation = query[fileLocation];
    item.isLastUploaded = query[isLastUploaded] == "1";
    item.bimIssueNumber = int.parse(query[bimIssueNumber] ?? "0");
    item.hsfChecksum = query[hsfChecksum] ?? "";
    item.bimIssueNumberModel = int.parse(query[bimIssueNumberModel] ?? "0");
    item.isDocAssociated = query[isDocAssociated] == "1";
    item.docTitle = query[docTitle];
    item.publisherName = query[publisherName];
    item.orgName = query[orgName];
    item.ifcName = query[ifcName] ?? "";

    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(BimModel object) {
    return Future.value({
      bimModelIdField: object.bimModelIdField?.plainValue() ?? "",
      name: '"${object.name}"',
      fileName: '"${object.fileName}"',
      revId: object.revId?.plainValue() ?? "",
      isMerged: object.isMerged!,
      isChecked: object.isChecked,
      disciplineId: object.disciplineId!,
      isLink: object.isLink!,
      filesize: object.filesize!,
      folderId: object.folderId!,
      fileLocation: object.fileLocation!,
      isLastUploaded: object.isLastUploaded!,
      bimIssueNumber: object.bimIssueNumber!,
      hsfChecksum: object.hsfChecksum != null ? object.hsfChecksum! : '',
      bimIssueNumberModel: object.bimIssueNumberModel!,
      isDocAssociated: object.isDocAssociated!,
      docTitle: object.docTitle!,
      publisherName: object.publisherName!,
      orgName: object.orgName!,
      ifcName: object.ifcName != null ? object.ifcName! : "",
    });
  }

  Future<void> insert(List<BimModel> bimModelList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(bimModelList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<List<BimModel>> fetch(String bimModelId) async {
    ModelBimModelDao dao = ModelBimModelDao();
    List<ModelBimModel> modelBimModelList = await dao.fetch(modelId: bimModelId);
    List<int> ids = modelBimModelList.map((obj) => int.parse(obj.bimModelId.plainValue())).toList();
    List<BimModel> list = [];
    String query = "SELECT * FROM $tableName WHERE $revId IN (${ids.join(",")})";
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
  Future<List<Map<String, dynamic>>> toListMap(List<BimModel> objects) async {
    List<Map<String, dynamic>> projectList = [];
    for (var element in objects) {
      projectList.add(await toMap(element));
    }
    return projectList;
  }

  Future<void> delete(String bimModel) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    String deleteQuery = "DELETE FROM $tableName WHERE revId = ${bimModel.plainValue()}";
    try {
      db.executeTableRequest(deleteQuery);
      ModelBimModelDao().deleteByRevId(bimModel.plainValue());
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

  static Future<void> deleteListCalibrate(String revId, {String? modelId}) async {
    List<FloorDetail> list = await FloorListDao().fetch(revId.plainValue());
    if (list.isEmpty) {
      await BimModelListDao().delete(revId);
      List<BimModel> bimList = await BimModelListDao().fetch(revId);

      if (bimList.isEmpty) {
        ModelListDao.deleteListCalibrate(modelId: modelId, revId: revId);
      }
    }
  }
}
