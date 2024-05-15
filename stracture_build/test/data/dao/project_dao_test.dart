
import 'package:field/data/dao/project_dao.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Project create table query test', () {
    ProjectDao itemDao = ProjectDao();
    String strProjectCreateQuery = 'CREATE TABLE IF NOT EXISTS ProjectDetailTbl(ProjectId TEXT NOT NULL,ProjectName TEXT NOT NULL,DcId INTEGER NOT NULL,Privilege TEXT,ProjectAdmins TEXT,OwnerOrgId INTEGER,StatusId INTEGER,ProjectSubscriptionTypeId INTEGER,IsFavorite INTEGER NOT NULL DEFAULT 0,BimEnabled INTEGER NOT NULL DEFAULT 0,IsUserAdminForProject INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,LastSyncTimeStamp TEXT,projectSizeInByte INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId))';
    expect(strProjectCreateQuery, itemDao.createTableQuery);
  });
}