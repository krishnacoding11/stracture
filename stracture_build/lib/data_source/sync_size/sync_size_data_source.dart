import 'package:field/data_source/base/base_local_data_source.dart';
import 'package:field/utils/extensions.dart';

import '../../data/dao/sync/sync_size_dao.dart';
import '../../data/model/sync_size_vo.dart';
import '../../logger/logger.dart';

class SyncSizeDataSource extends BaseLocalDataSource {

  Future<void> updateSyncSize(List<SyncSizeVo> syncSizeList) async {
    SyncSizeDao syncSizeDaoObj = SyncSizeDao();
    await syncSizeDaoObj.insert(syncSizeList);
  }

  Future<List<SyncSizeVo>> getProjectSyncSize(Map<String, dynamic> request) async {
    List<SyncSizeVo> syncSizeVoList = [];
    String query = "SELECT * FROM ${SyncSizeDao.tableName} WHERE ${SyncSizeDao.projectIdField}=${request['projectId'].toString().plainValue()}  ORDER BY ${SyncSizeDao.projectIdField} COLLATE NOCASE ASC";
    try {
      var qurResult = databaseManager.executeSelectFromTable(SyncSizeDao.tableName, query);
      syncSizeVoList = SyncSizeDao().fromList(qurResult);
    } on Exception catch (e) {
      Log.d(e);
    }
    return syncSizeVoList;
  }

  Future<List<SyncSizeVo>> getRequestedLocationSyncSize(Map<String, dynamic> request) async {
    List<SyncSizeVo> syncSizeVoList = [];
    String query = "SELECT * FROM ${SyncSizeDao.tableName} WHERE ${SyncSizeDao.projectIdField}=${request['projectId'].toString().plainValue()}  AND ${SyncSizeDao.locationIdField} IN (${request['locationId'].toList().join(",")})";
    try {
      var qurResult = databaseManager.executeSelectFromTable(SyncSizeDao.tableName, query);
      syncSizeVoList = SyncSizeDao().fromList(qurResult);
    } on Exception catch (e) {
      Log.d(e);
    }
    return syncSizeVoList;
  }

  Future<List<SyncSizeVo>> deleteProjectSync(Map<String, dynamic> request) async {
    List<SyncSizeVo> syncSizeVoList = [];
    String query = "DELETE FROM ${SyncSizeDao.tableName} WHERE ${SyncSizeDao.projectIdField}=${request['projectId'].toString().plainValue()} AND ${SyncSizeDao.locationIdField}=${request['locationId'].toString()}";
    try {
      var qurResult = databaseManager.executeSelectFromTable(SyncSizeDao.tableName, query);
      syncSizeVoList = SyncSizeDao().fromList(qurResult);
    } on Exception catch (e) {
      Log.d(e);
    }
    return syncSizeVoList;
  }
}