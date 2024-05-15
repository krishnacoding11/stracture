import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';

class CbimSettingsDao {
  static const navigationSpeed = "NavigationSpeed";
  static const id = "id";

  static String get fields => "$navigationSpeed INTEGER NOT NULL,"
      "$id INTEGER NOT NULL, ";

  static const tableName = 'BimSettingTbl';

  static String get primaryKeys => "PRIMARY KEY(id)";

  static String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  static Future<void> insert(int value) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = [
        {
          navigationSpeed: value,
          id: 1,
        }
      ];
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  static Future<Map<String, dynamic>> fetch() async {
    String query = "SELECT * FROM $tableName WHERE $id = 1 LIMIT 1";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(tableName, query);
      if(qurResult.isNotEmpty){
        return qurResult.first;
      }else{
        return {
          navigationSpeed: -1,
          id: 1,
        };
      }
    } on Exception catch (e) {
      Log.d(e);
      return {
        navigationSpeed: 1,
        id: 1,
      };
    }
  }
}
