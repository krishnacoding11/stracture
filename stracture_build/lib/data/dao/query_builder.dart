
class TableField {
  String fieldName;
  String dataType;
  String extra;
  bool isPrimaryKey;

  TableField({
    required this.fieldName,
    required this.dataType,
    this.extra = "",
    this.isPrimaryKey = false,
  });
}

class QueryBuilder {
  final String tableName;
  late List<TableField> _columns;

  QueryBuilder(this.tableName) {
    _columns = [];
  }

  addColumn(TableField column) {
    _columns.add(column);
  }

  String getCreateTableQuery() {
    String query = "";
    if (_columns.isNotEmpty) {
      List<String> fields = [],
          primaryKeys = [];
      for (var element in _columns) {
        fields.add("${element.fieldName} ${element.dataType}${(element.extra.isNotEmpty) ? " ${element.extra}" : ""}");
        if (element.isPrimaryKey) {
          primaryKeys.add(element.fieldName);
        }
      }
      query = "CREATE TABLE IF NOT EXISTS $tableName(${fields.join(",")}${(primaryKeys.isNotEmpty) ? ",PRIMARY KEY(${primaryKeys.join(",")})" : ""})";
    }
    return query;
  }

  String getInsertDataQuery() {
    String query = "";
    if (_columns.isNotEmpty) {
      int count = 1;
      List<String> fields = [],
          values = [];
      for (var element in _columns) {
        fields.add(element.fieldName);
        values.add("?$count");
        count++;
      }
      query = "INSERT INTO $tableName(${fields.join(",")}) VALUES (${values.join(",")})";
    }
    return query;
  }

  String getUpdateDataQuery() {
    String query = "";
    if (_columns.isNotEmpty) {
      int count = 1;
      List<String> fields = [],
          wheres = [];
      for (var element in _columns) {
        (element.isPrimaryKey)
            ? wheres.add("${element.fieldName}=?$count")
            : fields.add("${element.fieldName}=?$count");
        count++;
      }
      query = "UPDATE $tableName SET ${fields.join(",")} WHERE ${wheres.join(" AND ")}";
    }
    return query;
  }
}