

abstract class Dao<T> {
  String get getTableName;
  //queries
  String get createTableQuery;

  String get dropTable => "DROP TABLE IF EXISTS $getTableName";

  //abstract mapping methods
  T fromMap(Map<String, dynamic> query);

  List<T> fromList(List<Map<String, dynamic>> query);

  Future<Map<String, dynamic>> toMap(T object);

  Future<List<Map<String, dynamic>>> toListMap(List<T> objects);
}