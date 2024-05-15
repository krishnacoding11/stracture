//used for DB operation
import 'dart:io';

import 'package:field/utils/store_preference.dart';
import 'package:sqlite3/common.dart';

import '../injection_container.dart' as di;
import '../logger/logger.dart';
import '../utils/app_path_helper.dart';
import 'db_service.dart';

class DatabaseManager {
  final DBService _dbService;

  static final Map<String, DatabaseManager> _dbManagerMapObjects = <String, DatabaseManager>{};

  DatabaseManager._internal(this._dbService);

  factory DatabaseManager(String filePath) {
    return _dbManagerMapObjects.putIfAbsent(filePath, () => DatabaseManager._internal(di.getIt<DBService>(param1: filePath)));
  }

  static Future<String> getUserDBPath() async {
    String basePath = await AppPathHelper().getBasePath();
    final Directory dbDir = Directory('$basePath/database');
    if (await dbDir.exists()) {
      //if folder already exists return path
      return dbDir.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory dbDirNew = await dbDir.create(recursive: true);
      return dbDirNew.path;
    }
  }

  static Future<String> getUserDataDBPath() async {
    String path = await DatabaseManager.getUserDBPath();
    path = "$path/${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}";
    final Directory dbDir = Directory(path);
    if (await dbDir.exists()) {
      //if folder already exists return path
      return dbDir.path;
    } else {
      //if folder not exists create folder and then return its path
      final Directory dbDirNew = await dbDir.create(recursive: true);
      return dbDirNew.path;
    }
  }

  close() => _dbService.close();

  List<Map<String, dynamic>> executeSelectFromTable(String tableName, String query) {
    dynamic dbSet = _dbService.selectFromTable(tableName, query);
    if (dbSet != null) {
      List<Map<String, dynamic>> resultSet = <Map<String, dynamic>>[];
      for (final Row row in dbSet) {
        resultSet.add(row);
      }
      return resultSet;
    }
    return List.empty();
  }

  Future<void> executeDatabaseBulkOperations(String tableName, List<Map<String, dynamic>> rowList, {bool isNeedToUpdate = true}) async {
    List<List<dynamic>> insertValues = <List<dynamic>>[], updateValues = <List<dynamic>>[];
    List<String>? primaryKeys = _dbService.getPrimaryKeys(tableName);
    for (var row1 in rowList) {
      String whereClause = "";
      if (primaryKeys.isEmpty) {
        insertValues.add(row1.values.toList());
      } else {
        for (var element in primaryKeys) {
          if (whereClause.isNotEmpty) {
            whereClause = "$whereClause AND ";
          }
          var value = row1[element];
          whereClause = "$whereClause$element='$value'";
        }
        String tmpSelectQuery = "SELECT ${primaryKeys.first} FROM $tableName WHERE ";
        tmpSelectQuery = tmpSelectQuery + whereClause;
        final dbSet = _dbService.selectFromTable(tableName, tmpSelectQuery);
        if (dbSet == null || dbSet!.isEmpty) {
          insertValues.add(row1.values.toList());
        } else if (isNeedToUpdate) {
          updateValues.add(row1.values.toList());
        }
      }
    }
    if (insertValues.isNotEmpty) {
      String sqlFields = "";
      String sqlValues = "";
      if (rowList.isNotEmpty) {
        for (var n in rowList[0].keys) {
          if (sqlFields.isNotEmpty) {
            sqlFields += ",";
            sqlValues += ",";
          }
          sqlFields += n;
          sqlValues += "?";
        }
      }
      if (sqlFields.isNotEmpty && tableName.isNotEmpty) {
        var sqlQuery = "INSERT INTO $tableName ($sqlFields) VALUES ($sqlValues)";
        Log.d("bulkInsert Query=$sqlQuery");
        await _dbService.executeBulk(tableName, sqlQuery, insertValues);
      }
    }
    if (updateValues.isNotEmpty) {
      String setFields = "";
      String whereFields = "";
      if (rowList.isNotEmpty) {
        int index = 1;
        rowList[0].forEach((key, value) {
          if (primaryKeys.contains(key)) {
            if (whereFields.isNotEmpty) whereFields += " AND ";

            whereFields += "$key=?$index";
          } else {
            if (setFields.isNotEmpty) setFields += ",";

            setFields += "$key=?$index";
          }
          index++;
        });
        if (setFields.isNotEmpty && tableName.isNotEmpty) {
          var sqlQuery = "UPDATE $tableName SET $setFields";
          if (whereFields.isNotEmpty) {
            sqlQuery += " WHERE $whereFields";
          }
          Log.d("updateBulk Query=$sqlQuery");
          await _dbService.executeBulk(tableName, sqlQuery, updateValues);
        }
      }
    }
  }

  executeTableRequest(String query) {
    Log.d("QUERY $query");
    _dbService.executeQuery(query);
  }

  List<String> getTableFields(String tableName) {
    String query = "SELECT l.name FROM pragma_table_info('$tableName') as l;";
    dynamic dbSet = _dbService.selectFromTable(tableName, query);
    if (dbSet != null) {
      List<String> resultSet = <String>[];
      for (final Row row in dbSet) {
        resultSet.add(row['name']);
      }
      return resultSet;
    }
    return List.empty();
  }
}

class DatabaseManagerFactory {
  //static Map<String,DatabaseManager> _mapOfDBObjects = Map();
  static DatabaseManager getUserDBInstance(String filePath) {
    return DatabaseManager(filePath);
  }
}
