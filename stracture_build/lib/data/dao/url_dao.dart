import 'dart:convert';

import 'package:field/data/model/user_vo.dart';
import 'package:field/database/dao.dart';
import 'package:flutter/foundation.dart';

class UrlDao extends Dao<dynamic> {
  final tableName = 'NetworkDataTbl';

  final fieldCloud = 'CloudID';
  final fieldDcId = 'DcID';
  final fieldType = 'Type';
  final fieldUrl = 'URL';

  String get fields => "$fieldDcId TEXT NOT NULL,"
      "$fieldType TEXT NOT NULL,"
      "$fieldUrl TEXT NOT NULL";

  @override
  String get createTableQuery =>
      "CREATE TABLE IF NOT EXISTS $tableName($fields)";

  String get deleteDataQuery => "DELETE FROM $tableName";

  @override
  String get getTableName => tableName;

  @override
  List<User> fromList(List<Map<String, dynamic>> query) {
    throw UnimplementedError();
  }

  @override
  fromMap(Map<String, dynamic> query) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> toMap(object) async {
    // TODO: implement toMap
    throw UnimplementedError();
  }

  Future<List<Map<String, dynamic>>> toMapList(String data) async {
    List<Map<String, dynamic>> insertData = [];
    try {
      Map<String, dynamic> map = json.decode(data);
      Map<String, dynamic> dcMap = map["dataCenterDetails"];
      map.remove("dataCenterDetails");
      Iterable<String> mainKeys = map.keys;
      Iterable<String> keys = dcMap.keys;
      for (String mainKey in mainKeys) {
        Map<String, dynamic> temp = map[mainKey];
        for (String key in keys) {
          String url = temp[key].toString();
          if (url.endsWith("/")) {
            url = url.substring(0, url.length - 1);
          }
          url = url.replaceAll("/api", "");
          insertData.add({
            fieldDcId: dcMap[key].toString(),
            fieldType: mainKey,
            fieldUrl: url,
          });
        }
      }
    } on Exception catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return insertData;
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List objects) {
    // TODO: implement toListMap
    throw UnimplementedError();
  }
}
