import 'package:field/data/dao/cbim_settings_dao.dart';
import 'package:field/data_source/cBim_settings_data_source/cBim_settings_data_source.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/constants.dart';

class CbimSettingsLocalDataSourceImpl extends CbimSettingsDataSource{
  @override
  Future<Map<String, dynamic>> getCbimSettingsValue() async {
    String query = "SELECT * FROM ${CbimSettingsDao.tableName} WHERE ${CbimSettingsDao.id} = 1 LIMIT 1";

    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userDbFile}");
    try {
      var qurResult = db.executeSelectFromTable(CbimSettingsDao.tableName, query);
      if (qurResult.isNotEmpty) {
        return qurResult.first;
      } else {
        return Future(() =>
        {
          CbimSettingsDao.navigationSpeed: -1,
          CbimSettingsDao.id: 1,
        });
      }
    } on Exception catch (e) {
      Log.d(e);
      return Future(() =>
      {
        CbimSettingsDao.navigationSpeed: -1,
        CbimSettingsDao.id: 1,
      });
    }
  }

  @override
  Future setCbimSettingsValue(int value) async {
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userDbFile}");
    try {
      db.executeTableRequest(CbimSettingsDao.createTableQuery);
      List<Map<String, dynamic>> rowList = [
        {
          CbimSettingsDao.navigationSpeed: value,
          CbimSettingsDao.id: 1,
        }
      ];
      await db.executeDatabaseBulkOperations(CbimSettingsDao.tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

}