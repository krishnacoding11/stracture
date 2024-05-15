import 'dart:ffi';
import 'dart:io';

import 'package:field/database/db_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

import 'package:sqlite3/open.dart';
import 'package:path/path.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DBService dbService;
  DynamicLibrary _openOnWindows() {
    final scriptDir = File('test${separator}fixtures${separator}database').absolute;
    final libraryNextToScript = File(join(scriptDir.absolute.path, 'sqlite3.dll'));
    return DynamicLibrary.open(libraryNextToScript.path);
  }

  setUpAll(() {
    open.overrideFor(OperatingSystem.windows, _openOnWindows);
    try {
      dbService = DBService(d.path('db_test_case.db'));
    } finally {}
  });

  tearDownAll(() => dbService.close());

  group('Test Case: Execute Query', () {
    test("Execute Query: Success", () async {
      String sqlQuery = 'CREATE TABLE IF NOT EXISTS ProjectDetailTbl(ProjectId TEXT NOT NULL,ProjectName TEXT NOT NULL,DcId INTEGER NOT NULL,Privilege TEXT,ProjectAdmins TEXT,OwnerOrgId INTEGER,StatusId INTEGER,ProjectSubscriptionTypeId INTEGER,IsFavorite INTEGER NOT NULL DEFAULT 0,BimEnabled INTEGER NOT NULL DEFAULT 0,IsUserAdminForProject INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,LastSyncTimeStamp TEXT,projectSizeInByte INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId))';
      dbService.executeQuery(sqlQuery);
    });
    test("Execute Query: Exception", () async {
      String sqlQuery = 'CREATEs TABLE IF NOT EXISTS ProjectDetailTbl(ProjectId TEXT NOT NULL,ProjectName TEXT NOT NULL,DcId INTEGER NOT NULL,Privilege TEXT,ProjectAdmins TEXT,OwnerOrgId INTEGER,StatusId INTEGER,ProjectSubscriptionTypeId INTEGER,IsFavorite INTEGER NOT NULL DEFAULT 0,BimEnabled INTEGER NOT NULL DEFAULT 0,IsUserAdminForProject INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,LastSyncTimeStamp TEXT,projectSizeInByte INTEGERS NOT NULL ,PRIMARY KEY(ProjectId))';
      dbService.executeQuery(sqlQuery);
    });
  });

  group('Database service : Data Insert & Get data from table', () {
    setUpAll(() => dbService.executeQuery('CREATE TABLE IF NOT EXISTS ProjectDetailTbl(ProjectId TEXT NOT NULL,ProjectName TEXT NOT NULL,DcId INTEGER NOT NULL,Privilege TEXT,ProjectAdmins TEXT,OwnerOrgId INTEGER,StatusId INTEGER,ProjectSubscriptionTypeId INTEGER,IsFavorite INTEGER NOT NULL DEFAULT 0,BimEnabled INTEGER NOT NULL DEFAULT 0,IsUserAdminForProject INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,LastSyncTimeStamp TEXT,projectSizeInByte INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId))'));
    test("Execute Bulk Insert", () async {
      String sqlQuery = 'INSERT INTO ProjectDetailTbl (ProjectId,ProjectName,DcId,Privilege,ProjectAdmins,OwnerOrgId,StatusId,ProjectSubscriptionTypeId,IsFavorite,BimEnabled,IsUserAdminForProject,CanRemoveOffline,IsMarkOffline,SyncStatus,LastSyncTimeStamp,projectSizeInByte) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
      String tableName = 'ProjectDetailTbl';
      List<List<dynamic>> insertValues = <List<dynamic>>[
        ["78303", "sample project 2", 2, ",4,5,6,53,54,55,56,57,58,63,64,65,66,68,73,76,85,86,87,88,89,90,91,92,93,94,95,96,97,98,103,104,105,106,107,108,113,123,127,128,", "", 3, 5, 0, 0, 1, 0, 1, 1, 0, "", "148000"]
      ];
      dbService.executeBulk(tableName, sqlQuery, insertValues);
    });
    test("Get Primary Keys", () async {
      String tableName = 'ProjectDetailTbl';
      dbService.getPrimaryKeys(tableName);
    });
    test("Get Primary Keys : Empty", () async {
      dbService.getPrimaryKeys("");
    });
    test("Select From Table", () async {
      String tableName = 'ProjectDetailTbl';
      String sqlQuery = 'SELECT COUNT(*) FROM ProjectDetailTbl';
      final result = dbService.selectFromTable(tableName, sqlQuery);
      expect(
          result,
          ResultSet([
            "COUNT(*)"
          ], [
            null
          ], [
            [1]
          ]));
    });
  });
}
