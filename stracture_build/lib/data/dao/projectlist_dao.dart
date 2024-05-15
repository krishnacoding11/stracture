import 'package:field/data/model/popupdata_vo.dart';

import '../../database/dao.dart';

class ProjectListDao extends Dao<Popupdata> {
  final tableName = 'ProjectListTbl';

  static const idField = "id";
  static const projectIdField = "projectId";
  static const projectValueField = "projectValue";
  static const dcIdField = "dcId";
  static const isSelectedField = "isSelected";
  static const imgIdField = "imagesId";
  static const isActiveField = "isActive";

  String get fields => "$idField INTEGER NOT NULL,"
      "$projectIdField TEXT NOT NULL,"
      "$projectValueField TEXT NOT NULL,"
      "$dcIdField INTEGER NOT NULL,"
      "$isSelectedField NUMERIC NOT NULL DEFAULT 0,"
      "$imgIdField NUMERIC NOT NULL,"
      "$isActiveField NUMERIC NOT NULL DEFAULT 0,";

  String get primaryKeys => "PRIMARY KEY($idField)";

  @override
  String get createTableQuery =>
      "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<Popupdata> fromList(List<Map<String, dynamic>> query) {
    return List<Popupdata>.from(query.map((element) => fromMap(element)))
        .toList();
  }

  @override
  fromMap(Map<String, dynamic> query) {
    Popupdata item = Popupdata();
    item.id = query[idField];
    item.value = query[projectValueField];
    item.dataCenterId = query[dcIdField];
    item.isSelected = (query[isSelectedField] == 1) ? true : false;
    item.imgId = query[imgIdField];
    item.isActive = (query[isActiveField] == 1) ? true : false;

    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(Popupdata item) {
    return Future.value({
      projectIdField: '"${item.id}"',
      projectValueField: '"${item.value}"',
      dcIdField: item.dataCenterId,
      isSelectedField: (item.isSelected!) ? 1 : 0,
      imgIdField: item.imgId,
      isActiveField: (item.isActive!) ? 1 : 0,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<Popupdata> objects) {
    return Future.value(List<Map<String, dynamic>>.from(objects.map((element) => toMap(element))).toList());
  }
}
