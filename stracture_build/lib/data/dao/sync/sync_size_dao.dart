import 'package:field/data/model/download_size_vo.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';

import '../../../database/dao.dart';
import '../../model/sync_size_vo.dart';

class SyncSizeDao extends Dao<SyncSizeVo> {
  static const tableName = 'SyncSizeTbl';

  static const projectIdField = "ProjectId";
  static const locationIdField = "LocationId";
  static const pdfAndXfdfSize = "PdfAndXfdfSize";
  static const formTemplateSize = "FormTemplateSize";
  static const totalSize = "TotalSize";
  static const countOfLocations = "CountOfLocations";
  static const totalFormXmlSize = "TotalFormXmlSize";
  static const attachmentsSize = "AttachmentsSize";
  static const associationsSize = "AssociationsSize";
  static const countOfForms = "CountOfForms";

  String get fields => "$projectIdField TEXT NOT NULL,"
      "$locationIdField INTEGER NOT NULL,"
      "$pdfAndXfdfSize INTEGER NOT NULL DEFAULT 0,"
      "$formTemplateSize INTEGER NOT NULL DEFAULT 0,"
      "$totalSize INTEGER NOT NULL DEFAULT 0,"
      "$countOfLocations INTEGER NOT NULL DEFAULT 0,"
      "$totalFormXmlSize INTEGER NOT NULL DEFAULT 0,"
      "$attachmentsSize INTEGER NOT NULL DEFAULT 0,"
      "$associationsSize INTEGER NOT NULL DEFAULT 0,"
      "$countOfForms INTEGER NOT NULL DEFAULT 0";

  String get primaryKeys => ",PRIMARY KEY($projectIdField,$locationIdField)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<SyncSizeVo> fromList(List<Map<String, dynamic>> query) {
    return List<SyncSizeVo>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  SyncSizeVo fromMap(Map<String, dynamic> query) {
    SyncSizeVo item = SyncSizeVo();
    item.projectId = query[projectIdField];
    item.locationId = query[locationIdField];
    item.downloadSizeVo = DownloadSizeVo(
      pdfAndXfdfSize: query[pdfAndXfdfSize],
      formTemplateSize:query[formTemplateSize],
      totalSize: query[totalSize],
      countOfLocations: query[countOfLocations],
      totalFormXmlSize: query[totalFormXmlSize],
      attachmentsSize: query[attachmentsSize],
      associationsSize: query[associationsSize],
      countOfForms: query[countOfForms],
    );
    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(SyncSizeVo item) {
    return Future.value({
      projectIdField: item.projectId?.plainValue() ?? "",
      locationIdField: item.locationId! ?? "",
      pdfAndXfdfSize: item.downloadSizeVo!.pdfAndXfdfSize ?? "0",
      formTemplateSize: item.downloadSizeVo!.formTemplateSize ?? "0",
      totalSize: item.downloadSizeVo!.totalSize ?? "0",
      countOfLocations: item.downloadSizeVo!.countOfLocations ?? "0",
      totalFormXmlSize: item.downloadSizeVo!.totalFormXmlSize ?? "0",
      attachmentsSize: item.downloadSizeVo!.attachmentsSize ?? "0",
      associationsSize: item.downloadSizeVo!.associationsSize ?? "0",
      countOfForms: item.downloadSizeVo!.countOfForms ?? "0",
    });
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<SyncSizeVo> objects) async{
    List<Map<String, dynamic>> syncSizeList = [];
    for (var element in objects) {
      syncSizeList.add(await toMap(element));
    }
    return syncSizeList;
  }

  Future<void> insert(List<SyncSizeVo> syncSizeList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(syncSizeList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }
}
