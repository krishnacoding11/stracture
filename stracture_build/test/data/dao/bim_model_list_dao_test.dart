import 'dart:convert';

import 'package:field/data/dao/bim_model_list_dao.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Bim Model create table query test', () {
    BimModelListDao bimModelListDao = BimModelListDao();
    String strBimModelListCreateQuery = 'CREATE TABLE IF NOT EXISTS BimModelListTbl(BimModelId INTEGER NOT NULL,name TEXT NOT NULL,fileName TEXT NOT NULL,revId TEXT NOT NULL,isMerged TEXT NOT NULL,isChecked TEXT NOT NULL,disciplineId TEXT NOT NULL,isLink TEXT NOT NULL,filesize TEXT NOT NULL,folderId TEXT NOT NULL,fileLocation TEXT NOT NULL,isLastUploaded TEXT NOT NULL,bimIssueNumber TEXT NOT NULL,hsfChecksum TEXT NOT NULL,bimIssueNumberModel TEXT NOT NULL,isDocAssociated TEXT NOT NULL,docTitle TEXT NOT NULL,publisherName TEXT NOT NULL,ifcName TEXT NOT NULL,orgName TEXT NOT NULL,PRIMARY KEY(revId))';
    expect(strBimModelListCreateQuery, bimModelListDao.createTableQuery);
  });

  test('Bim Model item to map test', () {
    BimModelListDao bimModelListDao = BimModelListDao();
    String strData = "{\"bimModelIdField\":\"${"1234"}\",\"name\":\"${"46312\$\$17KRZw"}\",\"ifcName\":\"test\",\"fileName\":\"00_2022_vivek mishra\",\"revId\":\"asiteBim_46312\",\"isMerged\":true,\"isChecked\":true,\"isDownloaded\":false,\"disciplineId\":2,\"is_link\":true,\"filesize\":123,\"folderId\":\"2\",\"fileLocation\":\"0\",\"dc\":\"UK\",\"is_last_uploaded\":true,\"bimIssueNumber\":6,\"hsfChecksum\":\"0\$\$tYgTOy\",\"bimIssueNumberModel\":0,\"isDocAssociated\":true,\"docTitle\":\"0\$\$Zh6QIW\",\"publisherName\":\"Vivek#Mishra#Asite Solutions\",\"orgName\":\"1832155\$\$nXozJq\",\"floorList\":[]}";
    BimModel bimModel = BimModel.fromJson(json.decode(strData));
    var dataMap = bimModelListDao.toMap(bimModel);
    dataMap.then((value) {
      expect(20, value.length);
    });
  });

  test('Bim Model from map test', () {
    var dataMap = {"BimModelId": "46312\$\$17KRZw", "name": "2134298\$\$4Dizau", "ifcName": "00_2022_vivek mishra", "fileName": "asiteBim_46312", "revId": "Test", "isMerged": "Test BW inaccurate 230623", "isChecked": "0", "isDownloaded": "1832155\$\$nXozJq", "disciplineId": "2", "is_link": "true", "filesize": "123", "folderId": "2", "fileLocation": "0", "dc": "UK", "is_last_uploaded": "0", "bimIssueNumber": "0", "hsfChecksum": "0", "bimIssueNumberModel": "0", "isDocAssociated": "true", "docTitle": ""};
    BimModelListDao bimModelListDao = BimModelListDao();
    BimModel bimModel = bimModelListDao.fromMap(dataMap);
    expect(bimModel.bimModelIdField, "46312\$\$17KRZw");
  });

  test('Bim Model list from list map test', () {
    var dataMap = [
      {"BimModelId": "46312\$\$17KRZw", "name": "2134298\$\$4Dizau", "ifcName": "00_2022_vivek mishra", "fileName": "asiteBim_46312", "revId": "Test", "isMerged": "Test BW inaccurate 230623", "isChecked": "0", "isDownloaded": "1832155\$\$nXozJq", "disciplineId": "2", "is_link": "true", "filesize": "123", "folderId": "2", "fileLocation": "0", "dc": "UK", "is_last_uploaded": "0", "bimIssueNumber": "0", "hsfChecksum": "0", "bimIssueNumberModel": "0", "isDocAssociated": "true", "docTitle": ""},
      {"BimModelId": "46312\$\$17KRZw", "name": "2134298\$\$4Dizau", "ifcName": "00_2022_vivek mishra", "fileName": "asiteBim_46312", "revId": "Test", "isMerged": "Test BW inaccurate 230623", "isChecked": "0", "isDownloaded": "1832155\$\$nXozJq", "disciplineId": "2", "is_link": "true", "filesize": "123", "folderId": "2", "fileLocation": "0", "dc": "UK", "is_last_uploaded": "0", "bimIssueNumber": "0", "hsfChecksum": "0", "bimIssueNumberModel": "0", "isDocAssociated": "true", "docTitle": ""}
    ];
    BimModelListDao bimModelListDao = BimModelListDao();
    List<BimModel> bimModelList = bimModelListDao.fromList(dataMap);
    expect(bimModelList.length, 2);
  });

  test('Bim Model from map test', () async {
    var dataMap = {"BimModelId": "46312\$\$17KRZw", "name": "2134298\$\$4Dizau", "ifcName": "00_2022_vivek mishra", "fileName": "asiteBim_46312", "revId": "Test", "isMerged": "Test BW inaccurate 230623", "isChecked": "0", "isDownloaded": "1832155\$\$nXozJq", "disciplineId": "2", "is_link": "true", "filesize": "123", "folderId": "2", "fileLocation": "0", "dc": "UK", "is_last_uploaded": "0", "bimIssueNumber": "0", "hsfChecksum": "0", "bimIssueNumberModel": "0", "isDocAssociated": "true", "docTitle": ""};
    BimModelListDao bimModelListDao = BimModelListDao();
    BimModel bimModel = bimModelListDao.fromMap(dataMap);
    expect(bimModel.bimModelIdField, "46312\$\$17KRZw");
  });


  test('Test toListMap with missing bim data', () async {
    final dao = BimModelListDao();
    final emptyList = <BimModel>[];

    try {
      final userList = await dao.toListMap(emptyList);
      expect(userList, isEmpty);
    } catch (e) {
      expect(e, isUnimplementedError);
    }
  });
}
