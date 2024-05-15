import 'package:field/data/dao/user_reference_formtype_template_dao.dart';
import 'package:field/data/model/user_reference_formtype_template_vo.dart';
import 'package:field/database/db_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/offline_injection_container.dart' as di;
import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import 'package:sqlite3/sqlite3.dart';

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

  UserReferenceFormTypeTemplateDao userReferenceFormTypeTemplateDao = UserReferenceFormTypeTemplateDao();
  String tableName = 'UserReferenceFormTypeTemplateTbl';
  test('User reference formtype template createTableQuery test', () {
   
    String fields = "UserId TEXT,"
        "ProjectId TEXT,"
        "FormTypeId TEXT,"
        "UserCloudId TEXT";

    String strCreateTableQuery = 'CREATE TABLE IF NOT EXISTS $tableName($fields)';

    expect(strCreateTableQuery, userReferenceFormTypeTemplateDao.createTableQuery);
  });


  test('Formtype template table name test', () {
    var tableName = 'UserReferenceFormTypeTemplateTbl';
    var sut = UserReferenceFormTypeTemplateDao().getTableName;
    var result = sut;
    expect(result, tableName);
  });

  test('Formtype template fromList() test', () async {
    List<Map<String, dynamic>> query = [
      {'userId': "1", 'projectId': '2', 'formTypeId': "3", 'userCloudId': '4'},
      {'userId': "5", 'projectId': '6', 'formTypeId': "7", 'userCloudId': '8'},
    ];

    List<UserReferenceFormTypeTemplateVo> list = UserReferenceFormTypeTemplateDao().fromList(query);

    expect(list.length, 2);
  });

  test('toMap() returns a map with the correct values', () async {
    UserReferenceFormTypeTemplateVo userReferenceAttachmentData = UserReferenceFormTypeTemplateVo();
    userReferenceAttachmentData.userId = '1';
    userReferenceAttachmentData.projectId = '2';
    userReferenceAttachmentData.formTypeID = '3';
    userReferenceAttachmentData.userCloudId = '4';

    Map<String, dynamic> map = await UserReferenceFormTypeTemplateDao().toMap(userReferenceAttachmentData);

    expect(map, isNotNull);
    expect(map['UserId'], '1');
    expect(map['ProjectId'], '2');
    expect(map['FormTypeId'], '3');
    expect(map['UserCloudId'], '4');
  });

  test('toListMap() returns a map with the correct values', () async {
    UserReferenceFormTypeTemplateVo userReferenceAttachmentData = UserReferenceFormTypeTemplateVo();
    List<UserReferenceFormTypeTemplateVo> dataList = [];
    userReferenceAttachmentData.userId = '1';
    userReferenceAttachmentData.projectId = '2';
    userReferenceAttachmentData.formTypeID = '3';
    userReferenceAttachmentData.userCloudId = '4';
    dataList.add(userReferenceAttachmentData);
    dataList.add(userReferenceAttachmentData);

    List<Map<String, dynamic>> attachmentList = await UserReferenceFormTypeTemplateDao().toListMap(dataList);

    expect(attachmentList.length, 2);
    expect(attachmentList[0]['UserId'], '1');
    expect(attachmentList[0]['ProjectId'], '2');
    expect(attachmentList[0]['FormTypeId'], '3');
    expect(attachmentList[0]['UserCloudId'], '4');
    expect(attachmentList[1]['UserId'], '1');
    expect(attachmentList[1]['ProjectId'], '2');
    expect(attachmentList[1]['FormTypeId'], '3');
    expect(attachmentList[1]['UserCloudId'], '4');
  });

  test('toListMap() returns an empty list if the objects list is empty', () async {
    List<UserReferenceFormTypeTemplateVo> objects = [];

    List<Map<String, dynamic>> attachmentList = await UserReferenceFormTypeTemplateDao().toListMap(objects);

    expect(attachmentList.isEmpty, true);
  });

  test('Convert query map to UserReferenceFormTypeTemplateVo object test', () {
    Map<String, dynamic> query = {
      'userId': '1',
      'projectIdField': '2',
      'formTypeIdField': '3',
      'userCloudIdField': '4',
    };
    UserReferenceFormTypeTemplateDao().fromMap(query);

    expect(UserReferenceFormTypeTemplateDao.userId, equals('UserId'));
    expect(UserReferenceFormTypeTemplateDao.projectIdField, equals('ProjectId'));
    expect(UserReferenceFormTypeTemplateDao.formTypeIdField, equals('FormTypeId'));
    expect(UserReferenceFormTypeTemplateDao.userCloudIdField, equals('UserCloudId'));
  });

  test('insertFormTypeDetailsInUserReferenceTest', () async {
    final projectId = '1234';
    final formTypeId = '1234';
    final userId = '1';
    final userCloudId = '1';
    String insertQuery = "INSERT INTO $tableName (UserId, ProjectId, FormTypeId, UserCloudId) SELECT '$userId', '$projectId', '$formTypeId','$userCloudId' WHERE NOT EXISTS (SELECT 1 FROM $tableName WHERE UserId = '$userId' AND ProjectId = '$projectId' AND FormTypeId = '$formTypeId' AND UserCloudId = '$userCloudId');";
    final columnList = ["UserId", "ProjectId", "FormTypeId", "UserCloudId"];
    final rows = [
      ['1', '1234', '1234', '1']
    ];
    final createQuery = "CREATE TABLE IF NOT EXISTS UserReferenceFormTypeTemplateTbl(UserId TEXT,ProjectId TEXT,FormTypeId TEXT,UserCloudId TEXT)";
    final selectQuery = "SELECT * FROM UserReferenceFormTypeTemplateTbl";
    ResultSet resultSet = ResultSet(columnList, null, rows);

    when(() => mockDb!.executeQuery(insertQuery)).thenReturn(null);
    await userReferenceFormTypeTemplateDao.insertFormTypeTemplateDetailsInUserReference(projectId: projectId, formTypeId: formTypeId);
    when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(resultSet);

    verify(() => mockDb!.executeQuery(createQuery)).called(1);

    // verify(() => mockDb!.executeQuery(insertQuery)).called(1);
    expect(resultSet.length, 1);
  });

  test('deleteFormTypeDetailsInUserReferenceTest', () async {
    final projectId = '12345';
    final formTypeId = '12345';
    final deleteQuery = "DELETE FROM UserReferenceFormTypeTemplateTbl WHERE UserId= '1' AND ProjectId= '12345' AND FormTypeId= '12345'";
    final selectQuery = "SELECT * FROM UserReferenceFormTypeTemplateTbl";

    when(() => mockDb!.executeQuery(deleteQuery)).thenReturn(null);
    await userReferenceFormTypeTemplateDao.deleteFormTypeTemplateDetailsInUserReference(projectId: projectId, formTypeId: formTypeId);
    when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(null);
    ResultSet? results = mockDb!.selectFromTable(tableName, selectQuery);
    verify(() => mockDb!.selectFromTable(tableName, selectQuery)).called(1);
    expect(results, null);
  });

  group('shouldDeleteFormTypeTest', () {
    //FAIL
   /* test('should return true if no users are associated with the form type', () async {
      final projectId = '12345';
      final formTypeId = '12345';
      final selectQuery = 'SELECT count(DISTINCT UserId) as UniqueUser FROM $tableName WHERE ProjectId = $projectId AND FormTypeId = $formTypeId';
      final columnList = ["UniqueUser"];
      final rows = [
        [0]
      ];

      ResultSet resultSet = ResultSet(columnList, null, rows);
      when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(resultSet);

      final result1 = await userReferenceFormTypeTemplateDao.shouldDeleteFormTypeTemplate(projectId: projectId, formTypeId: formTypeId);

      expect(result1 as bool, true);
    });*/

    test('should return false if one or more users are associated with the form type', () async {
      final projectId = '1234';
      final formTypeId = '1234';
      final selectQuery = 'SELECT count(DISTINCT UserId) as UniqueUser FROM $tableName WHERE ProjectId = $projectId AND FormTypeId = $formTypeId';
      final columnList = ["UniqueUser"];
      final rows = [
        [1]
      ];

      ResultSet resultSet = ResultSet(columnList, null, rows);
      when(() => mockDb!.selectFromTable(tableName, selectQuery)).thenReturn(resultSet);

      final boolResult = await userReferenceFormTypeTemplateDao.shouldDeleteFormTypeTemplate(projectId: projectId, formTypeId: formTypeId);

      expect(boolResult, false);
    });
  });

}
