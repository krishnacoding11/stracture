
import 'dart:convert';

import 'package:field/data/dao/sync/sync_size_dao.dart';
import 'package:field/data/model/sync_size_vo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/injection_container.dart' as di;

import '../../../bloc/mock_method_channel.dart';
import '../../../data_source/form/create_form_local_data_source_test.dart';
import '../../../fixtures/appconfig_test_data.dart';
import '../../../fixtures/fixture_reader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  di.init(test: true);
  AppConfigTestData().setupAppConfigTestData();
  List<SyncSizeVo> response = [];
  late MockDatabaseManager mockDatabaseManager;


  setUpAll(() {
    mockDatabaseManager = MockDatabaseManager();
    List<dynamic> expectedData = json.decode(fixture("sync_size_vo.json"));
    expectedData.forEach((element) {
      response.add(SyncSizeVo.downloadSizeVoJson(element));
    });
  });

  test('SyncSize create table query test', () {
    SyncSizeDao itemDao = SyncSizeDao();
    String strLocationCreateQuery = 'CREATE TABLE IF NOT EXISTS SyncSizeTbl(ProjectId TEXT NOT NULL,LocationId INTEGER NOT NULL,PdfAndXfdfSize INTEGER NOT NULL DEFAULT 0,FormTemplateSize INTEGER NOT NULL DEFAULT 0,TotalSize INTEGER NOT NULL DEFAULT 0,CountOfLocations INTEGER NOT NULL DEFAULT 0,TotalFormXmlSize INTEGER NOT NULL DEFAULT 0,AttachmentsSize INTEGER NOT NULL DEFAULT 0,AssociationsSize INTEGER NOT NULL DEFAULT 0,CountOfForms INTEGER NOT NULL DEFAULT 0,PRIMARY KEY(ProjectId,LocationId))';
    expect(strLocationCreateQuery, itemDao.createTableQuery);
  });

  test('Syncsize item to map test', () {
    SyncSizeDao itemDao = SyncSizeDao();
    //String strData = "{\"folder_title\":\"130402\",\"permission_value\":1023,\"isActive\":1,\"folderPath\":\"!!PIN_ANY_APP_TYPE_20_9\\\\130402\",\"folderId\":\"110431628\$\$R1OfZ4\",\"folderPublishPrivateRevPref\":0,\"clonedFolderId\":0,\"isPublic\":false,\"projectId\":\"2116416\$\$5Gjy6f\",\"hasSubFolder\":false,\"isFavourite\":true,\"fetchRuleId\":0,\"includePublicSubFolder\":false,\"parentFolderId\":0,\"childfolderTreeVOList\":[],\"pfLocationTreeDetail\":{\"locationId\":35687,\"siteId\":3444,\"isSite\":true,\"parentLocationId\":0,\"docId\":\"11489063\$\$U0Q0Mw\",\"revisionId\":\"20861935\$\$TZjzCo\",\"isFileUploaded\":true,\"annotationId\":\"9d5e12ea-326e-810a-a072-dcb8d556bbb2\",\"locationCoordinates\":\"{\\\"x1\\\":114.68,\\\"y1\\\":648.61,\\\"x2\\\":392.39,\\\"y2\\\":368.65}\",\"pageNumber\":1,\"isCalibrated\":true,\"generateURI\":true},\"isPFLocationTree\":true,\"isWatching\":false,\"permissionValue\":0,\"ownerName\":\"Dhaval Vekaria (5226)\",\"isPlanSelected\":false,\"isMandatoryAttribute\":false,\"isShared\":false,\"publisherId\":\"514806\$\$3d3gPh\",\"imgModifiedDate\":\"2022-07-05 05:45:05.6\",\"userImageName\":\"https://portalqa.asite.com/profilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000\",\"orgName\":\"Asite Solutions\",\"isSharedByOther\":false,\"permissionTypeId\":0,\"generateURI\":true}";
    String strData = "{\"projectId\":\"2130192\",\"locationId\":-1,\"downloadSizeVo\":{\"pdfAndXfdfSize\": 1651716,\"formTemplateSize\": 789029,\"totalSize\": 104762212,\"countOfLocations\": 47,\"totalFormXmlSize\": 4256765,\"attachmentsSize\": 67896652,\"associationsSize\": 30957079,\"countOfForms\": 790}}";
    SyncSizeVo item = SyncSizeVo.downloadSizeVoJson(json.decode(strData));
    var dataMap = itemDao.toMap(item);
    dataMap.then((value) {
      expect(10, value.length);
    });
  });

  test('Syncsize item from map test', () {
    var dataMap = {
      "ProjectId": "2116416",
      "LocationId": -1,
      "pdfAndXfdfSize": 1651716,
      "formTemplateSize": 789029,
      "totalSize": 104762212,
      "countOfLocations": 47,
      "totalFormXmlSize": 4256765,
      "attachmentsSize": 67896652,
      "associationsSize": 30957079,
      "countOfForms": 790
    };
    SyncSizeDao itemDao = SyncSizeDao();
    SyncSizeVo item = itemDao.fromMap(dataMap);
    expect(item.projectId, "2116416");
  });

  test('SyncSize item list from list map test', () {
    var dataMap = [{
      "ProjectId": "2116416",
      "FolderId": "112342369",
      "pdfAndXfdfSize": 1651716,
      "formTemplateSize": 789029,
      "totalSize": 104762212,
      "countOfLocations": 47,
      "totalFormXmlSize": 4256765,
      "attachmentsSize": 67896652,
      "associationsSize": 30957079,
      "countOfForms": 790
    }, {
      "ProjectId": "2116416",
      "FolderId": "112342370",
      "pdfAndXfdfSize": 1651716,
      "formTemplateSize": 789029,
      "totalSize": 104762212,
      "countOfLocations": 47,
      "totalFormXmlSize": 4256765,
      "attachmentsSize": 67896652,
      "associationsSize": 30957079,
      "countOfForms": 790
    }
    ];
    SyncSizeDao itemDao = SyncSizeDao();
    List<SyncSizeVo> itemList = itemDao.fromList(dataMap);
    expect(itemList.length, 2);
  });

  test('SyncSize item list from toListMap test', () async {
    List<dynamic> expectedData = json.decode(fixture("sync_size_vo.json"));
    List<SyncSizeVo> response = [];
    expectedData.forEach((element) {
      response.add(SyncSizeVo.downloadSizeVoJson(element));
    });
    SyncSizeDao itemDao = SyncSizeDao();
    List<Map<String, dynamic>> obj = await itemDao.toListMap(response);
    expect(obj.length, 3);
  });

  test('SyncSize item list from toListMap test', () async {
    SyncSizeDao itemDao = SyncSizeDao();
    List<Map<String, dynamic>> obj = await itemDao.toListMap(response);
    expect(obj.length, 3);
  });

  test("Sync size insert [Success] test", () async {
    SyncSizeDao itemDao = SyncSizeDao();
    final result = itemDao.insert(response);
    expect(result, isA<Future<void>>());
  });
}