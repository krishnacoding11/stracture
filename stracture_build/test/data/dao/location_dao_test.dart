
import 'dart:convert';

import 'package:field/data/dao/location_dao.dart';
import 'package:field/data/model/site_location.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Location create table query test', () {
    LocationDao itemDao = LocationDao();
    String strLocationCreateQuery = 'CREATE TABLE IF NOT EXISTS LocationDetailTbl(ProjectId TEXT NOT NULL,FolderId TEXT NOT NULL,LocationId INTEGER NOT NULL,LocationTitle TEXT NOT NULL,ParentFolderId INTEGER NOT NULL,ParentLocationId INTEGER NOT NULL,PermissionValue INTEGER,LocationPath TEXT NOT NULL,SiteId INTEGER,DocumentId TEXT,RevisionId TEXT,AnnotationId TEXT,LocationCoordinate TEXT,PageNumber INTEGER NOT NULL DEFAULT 0,IsPublic INTEGER NOT NULL DEFAULT 0,IsFavorite INTEGER NOT NULL DEFAULT 0,IsSite INTEGER NOT NULL DEFAULT 0,IsCalibrated INTEGER NOT NULL DEFAULT 0,IsFileUploaded INTEGER NOT NULL DEFAULT 0,IsActive INTEGER NOT NULL DEFAULT 0,HasSubFolder INTEGER NOT NULL DEFAULT 0,CanRemoveOffline INTEGER NOT NULL DEFAULT 0,IsMarkOffline INTEGER NOT NULL DEFAULT 0,SyncStatus INTEGER NOT NULL DEFAULT 0,LastSyncTimeStamp TEXT,PRIMARY KEY(ProjectId,FolderId,LocationId))';
    expect(strLocationCreateQuery, itemDao.createTableQuery);
  });

  test('Location item to map test', () {
    LocationDao itemDao = LocationDao();
    //String strData = "{\"folder_title\":\"130402\",\"permission_value\":1023,\"isActive\":1,\"folderPath\":\"!!PIN_ANY_APP_TYPE_20_9\\\\130402\",\"folderId\":\"110431628\$\$R1OfZ4\",\"folderPublishPrivateRevPref\":0,\"clonedFolderId\":0,\"isPublic\":false,\"projectId\":\"2116416\$\$5Gjy6f\",\"hasSubFolder\":false,\"isFavourite\":true,\"fetchRuleId\":0,\"includePublicSubFolder\":false,\"parentFolderId\":0,\"childfolderTreeVOList\":[],\"pfLocationTreeDetail\":{\"locationId\":35687,\"siteId\":3444,\"isSite\":true,\"parentLocationId\":0,\"docId\":\"11489063\$\$U0Q0Mw\",\"revisionId\":\"20861935\$\$TZjzCo\",\"isFileUploaded\":true,\"annotationId\":\"9d5e12ea-326e-810a-a072-dcb8d556bbb2\",\"locationCoordinates\":\"{\\\"x1\\\":114.68,\\\"y1\\\":648.61,\\\"x2\\\":392.39,\\\"y2\\\":368.65}\",\"pageNumber\":1,\"isCalibrated\":true,\"generateURI\":true},\"isPFLocationTree\":true,\"isWatching\":false,\"permissionValue\":0,\"ownerName\":\"Dhaval Vekaria (5226)\",\"isPlanSelected\":false,\"isMandatoryAttribute\":false,\"isShared\":false,\"publisherId\":\"514806\$\$3d3gPh\",\"imgModifiedDate\":\"2022-07-05 05:45:05.6\",\"userImageName\":\"https://portalqa.asite.com/profilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000\",\"orgName\":\"Asite Solutions\",\"isSharedByOther\":false,\"permissionTypeId\":0,\"generateURI\":true}";
    String strData = "{\"folder_title\":\"1234\",\"permission_value\":1023,\"isActive\":1,\"folderPath\":\"!!PIN_ANY_APP_TYPE_20_9\\\\1234\",\"folderId\":\"112342369\$\$uVlTQW\",\"folderPublishPrivateRevPref\":0,\"clonedFolderId\":0,\"isPublic\":false,\"projectId\":\"2116416\$\$5Gjy6f\",\"hasSubFolder\":false,\"isFavourite\":false,\"fetchRuleId\":0,\"includePublicSubFolder\":false,\"parentFolderId\":0,\"childfolderTreeVOList\":[],\"pfLocationTreeDetail\":{\"locationId\":44053,\"siteId\":6307,\"isSite\":true,\"parentLocationId\":0,\"docId\":\"0\$\$SreGEv\",\"revisionId\":\"0\$\$XKEuyf\",\"isFileUploaded\":false,\"pageNumber\":0,\"isCalibrated\":false,\"generateURI\":true},\"isPFLocationTree\":true,\"isWatching\":false,\"permissionValue\":0,\"ownerName\":\"Dhaval Vekaria (5226)\",\"isPlanSelected\":false,\"isMandatoryAttribute\":false,\"isShared\":false,\"publisherId\":\"514806\$\$3d3gPh\",\"imgModifiedDate\":\"2022-07-05 05:45:05.6\",\"userImageName\":\"https://portalqa.asite.com/profilefiles/member_photos/photo_514806_thumbnail.jpg?v=1656996305000\",\"orgName\":\"Asite Solutions\",\"isSharedByOther\":false,\"permissionTypeId\":0,\"generateURI\":true}";
    SiteLocation item = SiteLocation.fromJson(json.decode(strData));
    var dataMap = itemDao.toMap(item);
    dataMap.then((value) {
      expect(25, value.length);
    });
  });

  test('Location item from map test', () {
    var dataMap = {
      "ProjectId": "2116416",
      "FolderId": "112342369",
      "LocationId": 44053,
      "LocationTitle": "1234",
      "ParentFolderId": 0,
      "ParentLocationId": 0,
      "PermissionValue": 0,
      "LocationPath": "!!PIN_ANY_APP_TYPE_20_9\\\\1234",
      "SiteId": 6307,
      "DocumentId": "0",
      "RevisionId": "0",
      "AnnotationId": "",
      "PageNumber": 0,
      "IsPublic": 0,
      "IsFavorite": 0,
      "IsSite": 1,
      "IsCalibrated": 0,
      "IsFileUploaded": 0,
      "IsActive": 1,
      "HasSubFolder": 0,
      "SyncStatus":1,
    };
    LocationDao itemDao = LocationDao();
    SiteLocation item = itemDao.fromMap(dataMap);
    expect(item.projectId,"2116416");
  });

  test('Location item list from list map test', () {
    var dataMap = [{
      "ProjectId": "2116416",
      "FolderId": "112342369",
      "LocationId": 44053,
      "LocationTitle": "1234",
      "ParentFolderId": 0,
      "ParentLocationId": 0,
      "PermissionValue": 0,
      "LocationPath": "!!PIN_ANY_APP_TYPE_20_9\\\\1234",
      "SiteId": 6307,
      "DocumentId": "0",
      "RevisionId": "0",
      "AnnotationId": "",
      "PageNumber": 0,
      "IsPublic": 0,
      "IsFavorite": 0,
      "IsSite": 1,
      "IsCalibrated": 0,
      "IsFileUploaded": 0,
      "IsActive": 1,
      "HasSubFolder": 0,
      "SyncStatus":1,
    },{
      "ProjectId": "2116416",
      "FolderId": "112342370",
      "LocationId": 44054,
      "LocationTitle": "12345",
      "ParentFolderId": 0,
      "ParentLocationId": 0,
      "PermissionValue": 0,
      "LocationPath": "!!PIN_ANY_APP_TYPE_20_9\\\\12345",
      "SiteId": 6308,
      "DocumentId": "0",
      "RevisionId": "0",
      "AnnotationId": "",
      "PageNumber": 0,
      "IsPublic": 0,
      "IsFavorite": 0,
      "IsSite": 1,
      "IsCalibrated": 0,
      "IsFileUploaded": 0,
      "IsActive": 1,
      "HasSubFolder": 0,
      "SyncStatus": 0,
    }];
    LocationDao itemDao = LocationDao();
    List<SiteLocation> itemList = itemDao.fromList(dataMap);
    expect(itemList.length, 2);
  });
}