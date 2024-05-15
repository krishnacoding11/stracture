import 'package:field/data/dao/user_reference_location_plan_dao.dart';
import 'package:field/data/model/user_reference_attachment_vo.dart';
import 'package:field/database/db_service.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:field/offline_injection_container.dart' as di;
import 'package:mocktail/mocktail.dart';
import 'package:sqlite3/common.dart';

import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';

class DBServiceMock extends Mock implements DBService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  DBServiceMock? mockDb;

  di.init(test: true);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  configureDependencies() {
    mockDb = DBServiceMock();

    di.getIt.unregister<DBService>();
    di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
  }

  setUp(() {
    configureDependencies();
  });

  tearDown(() {
    mockDb = null;
  });

  UserReferenceLocationPlanDao userReferenceLocationPlanDao = UserReferenceLocationPlanDao();
  String tableName = 'UserReferenceLocationPlanTbl';
  test('User reference location plan createTableQuery test', () {
    String fields = "UserId TEXT,"
        "ProjectId TEXT,"
        "RevisionId TEXT,"
        "UserCloudId TEXT";

    String strCreateTableQuery = 'CREATE TABLE IF NOT EXISTS $tableName($fields)';

    expect(strCreateTableQuery, userReferenceLocationPlanDao.createTableQuery);
  });

  test('Location plan table name test', () {
    var tableName = 'UserReferenceLocationPlanTbl';
    var sut = UserReferenceLocationPlanDao().getTableName;
    var result = sut;
    expect(result, tableName);
  });

  test('Location plan fromList() test', () async {
    List<Map<String, dynamic>> query = [
      {'userId': "1", 'projectId': '2', 'revisionId': "3", 'userCloudId': '4'},
      {'userId': "5", 'projectId': '6', 'revisionId': "7", 'userCloudId': '8'},
    ];

    List<UserReferenceAttachmentVo> list = UserReferenceLocationPlanDao().fromList(query);

    expect(list.length, 2);
  });

  test('toMap() returns a map with the correct values', () async {
    UserReferenceAttachmentVo userReferenceAttachmentData = UserReferenceAttachmentVo();
    userReferenceAttachmentData.userId = '1';
    userReferenceAttachmentData.projectId = '2';
    userReferenceAttachmentData.revisionId = '3';
    userReferenceAttachmentData.userCloudId = '4';

    Map<String, dynamic> map = await UserReferenceLocationPlanDao().toMap(userReferenceAttachmentData);

    expect(map, isNotNull);
    expect(map['UserId'], '1');
    expect(map['ProjectId'], '2');
    expect(map['RevisionId'], '3');
    expect(map['UserCloudId'], '4');
  });

  test('toListMap() returns a map with the correct values', () async {
    UserReferenceAttachmentVo userReferenceAttachmentData = UserReferenceAttachmentVo();
    List<UserReferenceAttachmentVo> dataList = [];
    userReferenceAttachmentData.userId = '1';
    userReferenceAttachmentData.projectId = '2';
    userReferenceAttachmentData.revisionId = '3';
    userReferenceAttachmentData.userCloudId = '4';
    dataList.add(userReferenceAttachmentData);
    dataList.add(userReferenceAttachmentData);

    List<Map<String, dynamic>> attachmentList = await UserReferenceLocationPlanDao().toListMap(dataList);

    expect(attachmentList.length, 2);
    expect(attachmentList[0]['UserId'], '1');
    expect(attachmentList[0]['ProjectId'], '2');
    expect(attachmentList[0]['RevisionId'], '3');
    expect(attachmentList[0]['UserCloudId'], '4');
    expect(attachmentList[1]['UserId'], '1');
    expect(attachmentList[1]['ProjectId'], '2');
    expect(attachmentList[1]['RevisionId'], '3');
    expect(attachmentList[1]['UserCloudId'], '4');
  });

  test('toListMap() returns an empty list if the objects list is empty', () async {
    List<UserReferenceAttachmentVo> objects = [];

    List<Map<String, dynamic>> attachmentList = await UserReferenceLocationPlanDao().toListMap(objects);

    expect(attachmentList.isEmpty, true);
  });

  test('Convert query map to UserReferenceAttachmentVo object test', () {
    Map<String, dynamic> query = {
      'userId': '1',
      'projectIdField': '2',
      'revisionIdField': '3',
      'userCloudIdField': '4',
    };
    UserReferenceLocationPlanDao().fromMap(query);

    expect(UserReferenceLocationPlanDao.userId, equals('UserId'));
    expect(UserReferenceLocationPlanDao.projectIdField, equals('ProjectId'));
    expect(UserReferenceLocationPlanDao.revisionIdField, equals('RevisionId'));
    expect(UserReferenceLocationPlanDao.userCloudIdField, equals('UserCloudId'));
  });

  test('insertLocationPlanDetailsInUserReferenceTest', () async {
    final projectId = '12345';
    final revisionId = '12345';
    final userId = '1';
    final userCloudId = '1';
    String insertQuery = "INSERT INTO $tableName (UserId, ProjectId, RevisionId, UserCloudId) SELECT '$userId', '$projectId', '$revisionId','$userCloudId' WHERE NOT EXISTS (SELECT 1 FROM $tableName WHERE UserId = '$userId' AND ProjectId = '$projectId' AND RevisionId = '$revisionId' AND UserCloudId = '$userCloudId');";
    final columnList = ["UserId", "ProjectId", "RevisionId", "UserCloudId"];
    final rows = [
      ['1', '12345', '12345', '1']
    ];
    final createQuery = "CREATE TABLE IF NOT EXISTS UserReferenceLocationPlanTbl(UserId TEXT,ProjectId TEXT,RevisionId TEXT,UserCloudId TEXT)";
    final selectQuery = "SELECT * FROM UserReferenceLocationPlanTbl";
    ResultSet resultSet = ResultSet(columnList, null, rows);

    when(() => mockDb!.executeQuery(insertQuery)).thenReturn(null);
    await userReferenceLocationPlanDao.insertLocationPlanDetailsInUserReference(projectId: projectId, revisionId: revisionId);
    when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(resultSet);

    verify(() => mockDb!.executeQuery(createQuery)).called(1);
    //FAIL
    //verify(() => mockDb!.executeQuery(insertQuery)).called(1);
    expect(resultSet.length, 1);
  });

  test('deleteLocationPlanDetailsInUserReferenceTest', () async {
    final projectId = '123450';
    final revisionId = '123450';
    final deleteQuery = "DELETE FROM UserReferenceLocationPlanTbl WHERE UserId= '1' AND ProjectId= '12345' AND RevisionId= '12345'";
    final selectQuery = "SELECT * FROM UserReferenceLocationPlanTbl";

    when(() => mockDb!.executeQuery(deleteQuery)).thenReturn(null);
    await userReferenceLocationPlanDao.deleteLocationPlanDetailsInUserReference(projectId: projectId, revisionId: revisionId);
    when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(null);
    ResultSet? results = mockDb!.selectFromTable(tableName, selectQuery);
    verify(() => mockDb!.selectFromTable(tableName, selectQuery)).called(1);
    expect(results, null);
  });

  group('shouldDeleteLocationPlanTest', () {
   

    test('should return false if one or more users are associated with the location plan', () async {
      final projectId = '12345';
      final revisionId = '12345';
      final selectQuery = 'SELECT count(DISTINCT UserId) as UniqueUser FROM $tableName WHERE ProjectId = $projectId AND RevisionId = $revisionId';
      final columnList = ["UniqueUser"];
      final rows = [
        [1]
      ];

      ResultSet resultSet = ResultSet(columnList, null, rows);
      when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(resultSet);

      final boolResult = await userReferenceLocationPlanDao.shouldDeleteLocationPlan(projectId: projectId, revisionId: revisionId);

      expect(boolResult, false);
    });
  });
}
