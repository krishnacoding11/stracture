import 'package:flutter/material.dart';
import 'package:sqlite3/sqlite3.dart';

import '../logger/logger.dart';
//import 'package:mutex/mutex.dart';

class DBService {
  Database? _db;
  String? filePath;

  DBService(this.filePath) {
    _db = sqlite3.open(filePath!, mutex: true);
  }

  //Mutex _mtx = Mutex();

  executeQuery(String query) {
    //await _mtx.protect(() async {
    try {
      _db?.execute(query);
    } on Exception catch (e) {
      //exception msg using logger
      Log.e("DBService:executeQuery ${e.toString()}");
    }
    //});
  }

 Future<void> executeBulk(String tableName, String query, List<List<dynamic>> rowList) async {
    //await _mtx.protect(() async {
    if (_db != null) {
      try {
        _db?.execute("BEGIN TRANSACTION");
        final stmt = _db?.prepare(query);
        for (var element in rowList) {
          stmt?.execute(element.toList());
        }
        stmt?.dispose();
      } on Exception catch (e) {
        //exception msg using logger
        Log.e("DBService:executeBulk ${e.toString()}");
      } finally {
        _db?.execute("COMMIT TRANSACTION");
      }
    }
    //});
  }

//// Put on Comment the below Unused Code
  /*bulkInsert(String tableName, List<Map<String, dynamic>> rowList) {
    //await _mtx.protect(() async {
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
      Log.d("insertMultiple Query=$sqlQuery");
      //TODO put below code in try catch
      _db?.execute("BEGIN TRANSACTION");
      final stmt = _db?.prepare(sqlQuery);
      for (var element in rowList) {
        stmt?.execute(element.values.toList());
      }
      stmt?.dispose();
      try {
        _db?.execute("COMMIT TRANSACTION");
      } catch (e) {
        Log.e("DBService:bulkInsert ${e.toString()}");
      }
    } else {
      Log.d("something is wrong");
    }
    //});
  }

  bulkUpdate(String tableName, List<Map<String, dynamic>> rowList) {
    //UPDATE Defect_LocationAndStatusMappingTable SET StatusCount=?4 WHERE ProjectId=?1 AND LocationId=?2 AND StatusId=?3;
    //await _mtx.protect(() async {
    dynamic primaryKeys = getPrimaryKeys(tableName);
    String setFields = "";
    String whereFields = "";
    if (rowList.isNotEmpty) {
      int index = 1;
      rowList[0].forEach((key, value) {
        if (primaryKeys.contains(key)) {
          if (whereFields.isNotEmpty) {
            whereFields += " AND ";
          }

          whereFields += "$key=?$index";
        } else {
          if (setFields.isNotEmpty) {
            setFields += ",";
          }

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
        //TODO following code should be in try catch block
        _db?.execute("BEGIN TRANSACTION");
        final stmt = _db?.prepare(sqlQuery);
        for (var element in rowList) {
          stmt?.execute(element.values.toList());
        }
        stmt?.dispose();
        try {
          _db?.execute("COMMIT TRANSACTION");
        } catch (e) {
          Log.e("DBService:bulkUpdate ${e.toString()}");
        }
      }
    }
    //});
  }*/

  List<String> getPrimaryKeys(@required String tableName) {
    if (tableName != "") {
      final results = _db?.select("SELECT l.name FROM pragma_table_info(\'$tableName\') as l WHERE l.pk <> 0;");
      var finalList = List<String>.filled(results!.length, "");

      int index = 0;
      for (var element in results) {
        finalList[index++] = element["name"];
      }
      if (finalList.isNotEmpty) {
        return finalList;
      }
    }
    return [];
  }

  ResultSet? selectFromTable(String tableName, String query) {
    //await _mtx.protect<ResultSet?>(() async {
    if (tableName.isNotEmpty && query.isNotEmpty) {
      try {
        return _db?.select(query);
      } on Exception catch (e) {
        Log.e("DBService:selectFromTable ${e.toString()}");
        return null;
      }
    }
    return null;
    //});
  }

  close() async {
    //await _mtx.protect(() async {
    _db?.dispose();
    //});
  }
}
