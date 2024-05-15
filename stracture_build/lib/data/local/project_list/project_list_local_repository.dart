import 'package:field/data/dao/location_dao.dart';
import 'package:field/data/dao/project_dao.dart';
import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/sync_size_vo.dart';
import 'package:field/data/repository/project_list/project_list_repository.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';


class ProjectListLocalRepository extends ProjectListRepository {
  ProjectListLocalRepository();

  ProjectDao projectDao = ProjectDao();

  @override
  Future<List<Project>> getProjectList(int page, int batchSize, Map<String, dynamic> request) async {
    List<Project> projectList = <Project>[];
    String query = "SELECT * FROM ${ProjectDao.tableName} WHERE ${ProjectDao.projectIdField}=${request["projectIds"].toString().plainValue()}  ORDER BY ${ProjectDao.projectNameField} COLLATE NOCASE ASC";
    try {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
      var qurResult = db.executeSelectFromTable(ProjectDao.tableName, query);
      projectList = projectDao.fromList(qurResult);
    } on Exception catch (e) {
      Log.d(e.toString());
    }
    return projectList;
  }

  // Future<List<String>> getAllProjectIdList() async {
  //   List<String> projectList = [];
  //   final path = await AppPathHelper().getUserDataDBFilePath();
  //   final db = DatabaseManager(path);
  //   try {
  //     String query = "SELECT ${ProjectDao.projectIdField} FROM ${ProjectDao.tableName}";
  //     var qurResult = db.executeSelectFromTable(ProjectDao.tableName, query);
  //     for (var element in qurResult) {
  //       projectList.add(element[ProjectDao.projectIdField].toString());
  //     }
  //   } on Exception catch (e) {
  //     Log.d(e.toString());
  //   }
  //   return projectList;
  // }

  Future<List<Map<String,dynamic>>> getSyncProjectList() async {
    List<Map<String,dynamic>> qurResult = [];
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      String query = "SELECT prjTbl.ProjectId,prjTbl.CanRemoveOffline,prjTbl.IsMarkOffline,IFNULL(syncPrjTbl.SyncStatus,prjTbl.SyncStatus) AS SyncStatus,IFNULL(syncPrjTbl.SyncProgress,100) AS SyncProgress,prjTbl.LastSyncTimeStamp,prjTbl.projectSizeInByte FROM ProjectDetailTbl prjTbl\n"
      "LEFT JOIN SyncProjectTbl syncPrjTbl ON prjTbl.ProjectId=syncPrjTbl.ProjectId";
      qurResult = db.executeSelectFromTable(ProjectDao.tableName, query);
    } on Exception catch (e) {
      Log.d(e.toString());
    }
    return qurResult;
  }


  Future<bool> isProjectMarkedOffline() async {
    String query = "SELECT COUNT(*) FROM ${ProjectDao.tableName}";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(ProjectDao.tableName, query);
      if (qurResult.isNotEmpty) {
        return (qurResult[0][0] > 0);
      }
      return false;
    } on Exception catch (e) {
      Log.d(e.toString());
      return false;
    }
  }
  Future<bool> isSiteDataMarkedOffline() async {
    String query = "SELECT SUM(OfflineCount) AS TotalCount FROM (\n"
        "SELECT COUNT(${ProjectDao.projectIdField}) AS OfflineCount FROM ${ProjectDao.tableName}\n"
        "WHERE ${ProjectDao.canRemoveOfflineField}=1\n"
        "UNION\n"
        "SELECT COUNT(${LocationDao.locationIdField})AS OfflineCount FROM ${LocationDao.tableName}\n"
        "WHERE ${LocationDao.canRemoveOfflineField}=1\n"
        ")";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(ProjectDao.tableName, query);
      if (qurResult.isNotEmpty) {
        return (int.parse(qurResult.first["TotalCount"].toString()) > 0);
      }
      return false;
    } on Exception catch (e) {
      Log.d(e.toString());
      return false;
    }
  }

  Future<List<Project>> getMarkedOfflineProjects() async {
    List<Project> projectList = <Project>[];
    String query = "SELECT * FROM ${ProjectDao.tableName}";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(ProjectDao.tableName, query);
      projectList = projectDao.fromList(qurResult);
    } on Exception catch (e) {
      Log.d(e.toString());
    }
    return projectList;
  }

  @override
  Future setFavProject(Map<String, dynamic> request) {
    throw UnimplementedError();
  }

  @override
  Future<List<Popupdata>> getPopupDataList(int page, int batchSize, Map<String, dynamic> request) async {
    List<Popupdata> projectList = <Popupdata>[];

    String query = "SELECT * FROM ${ProjectDao.tableName}";
    if (request.containsKey("dataFor")) {
      query = "$query WHERE ${ProjectDao.isFavoriteField}=${request["dataFor"] == 2 ? 1 : 0}";
      if (request["searchValue"].toString().isNotEmpty) {
        query = "$query AND ${ProjectDao.projectNameField} LIKE '%${request["searchValue"].toString()}%'";
      }
    } else if (request["searchValue"].toString().isNotEmpty) {
      query = "$query WHERE ${ProjectDao.projectNameField} LIKE '%${request["searchValue"].toString()}%'";
    }
    String sortOrder = "ASC";
    if(request.containsKey("sortOrder")) {
      sortOrder = request["sortOrder"].toString();
    }
    query = "$query ORDER BY ${ProjectDao.projectNameField} COLLATE NOCASE $sortOrder";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(ProjectDao.tableName, query);
      for (Map res in qurResult) {
        Popupdata popupdata = projectDao.popupDataFromMap(res);
        popupdata.isMarkOffline = true;
        projectList.add(popupdata);
      }
    } on Exception catch (e) {
      Log.d(e.toString());
    }
    return projectList;
  }

  @override
  Future<Result> getProjectAndLocationList(Map<String, dynamic> request) async {
    throw UnimplementedError();
  }

  @override
  Future<Result> getColumnHeaderList(Map<String, dynamic> request) async {
    throw UnimplementedError();
  }

  @override
  Future<Result> getFormList(Map<String, dynamic> request) async {
    throw UnimplementedError();
  }

  @override
  Future<Result> getFormMessageBatchList(Map<String, dynamic> request) async {
    throw UnimplementedError();
  }

  @override
  Future<Result> downloadFormAttachmentInBatch(Map<String, dynamic> request, {bool bAkamaiDownload = true}) async {
    throw UnimplementedError();
  }

  @override
  Future<Result> getServerTime(Map<String, dynamic> request) async {
    throw UnimplementedError();
  }

  @override
  Future<Result> getHashedValue(Map<String, dynamic> request) async {
    throw UnimplementedError();
  }

  @override
  Future<Result> getStatusStyle(Map<String, dynamic> request) async {
    throw UnimplementedError();
  }

  @override
  Future<Result> getManageTypeList(Map<String, dynamic> request) async {
    throw UnimplementedError();
  }

  @override
  Future<List<SyncSizeVo>> deleteItemFromSyncTable(Map<String, dynamic> request) {
    // TODO: implement deleteItemFromSyncTable
    throw UnimplementedError();
  }

  @override
  Future<Result> getWorkspaceSettings(Map<String, dynamic> request) {
    // TODO: implement getWorkspaceSettings
    throw UnimplementedError();
  }

  @override
  Future<Result> getDiscardedFormIds(Map<String, dynamic> request) async {
    throw UnimplementedError();
  }
}
