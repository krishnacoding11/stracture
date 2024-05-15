

import 'package:field/data/model/site_location.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';
import 'package:flutter/material.dart';

import '../../database/dao.dart';
import '../model/pflocationtreedetail.dart';

class LocationDao extends Dao<SiteLocation> {

  static const tableName = 'LocationDetailTbl';

  static const projectIdField = "ProjectId";
  static const folderIdField = "FolderId";
  static const locationIdField = "LocationId";
  static const locationTitleField = "LocationTitle";
  static const parentFolderIdField = "ParentFolderId";
  static const parentLocationIdField = "ParentLocationId";
  static const permissionValueField = "PermissionValue";
  static const locationPathField = "LocationPath";
  static const siteIdField = "SiteId";
  static const documentIdField = "DocumentId";
  static const revisionIdField = "RevisionId";
  static const annotationIdField = "AnnotationId";
  static const locationCoordinateField = "LocationCoordinate";
  static const pageNumberField = "PageNumber";
  static const isPublicField = "IsPublic";
  static const isFavoriteField = "IsFavorite";
  static const isSiteField = "IsSite";
  static const isCalibratedField = "IsCalibrated";
  static const isFileUploadedField = "IsFileUploaded";
  static const isActiveField = "IsActive";
  static const hasSubFolderField = "HasSubFolder";
  static const canRemoveOfflineField="CanRemoveOffline";
  static const isMarkOfflineField="IsMarkOffline";
  static const syncStatusField="SyncStatus";
  static const lastSyncTimeStampField="LastSyncTimeStamp";

  String get fields => "$projectIdField TEXT NOT NULL,"
      "$folderIdField TEXT NOT NULL,"
      "$locationIdField INTEGER NOT NULL,"
      "$locationTitleField TEXT NOT NULL,"
      "$parentFolderIdField INTEGER NOT NULL,"
      "$parentLocationIdField INTEGER NOT NULL,"
      "$permissionValueField INTEGER,"
      "$locationPathField TEXT NOT NULL,"
      "$siteIdField INTEGER,"
      "$documentIdField TEXT,"
      "$revisionIdField TEXT,"
      "$annotationIdField TEXT,"
      "$locationCoordinateField TEXT,"
      "$pageNumberField INTEGER NOT NULL DEFAULT 0,"
      "$isPublicField INTEGER NOT NULL DEFAULT 0,"
      "$isFavoriteField INTEGER NOT NULL DEFAULT 0,"
      "$isSiteField INTEGER NOT NULL DEFAULT 0,"
      "$isCalibratedField INTEGER NOT NULL DEFAULT 0,"
      "$isFileUploadedField INTEGER NOT NULL DEFAULT 0,"
      "$isActiveField INTEGER NOT NULL DEFAULT 0,"
      "$hasSubFolderField INTEGER NOT NULL DEFAULT 0,"
      "$canRemoveOfflineField INTEGER NOT NULL DEFAULT 0,"
      "$isMarkOfflineField INTEGER NOT NULL DEFAULT 0,"
      "$syncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$lastSyncTimeStampField TEXT"
  ;

  String get primaryKeys => ",PRIMARY KEY($projectIdField,$folderIdField,$locationIdField)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<SiteLocation> fromList(List<Map<String, dynamic>> query) {
    return List<SiteLocation>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  SiteLocation fromMap(Map<String, dynamic> query) {
    SiteLocation item = SiteLocation(globalKey: GlobalKey(debugLabel: 'site_location'));
    item.projectId = query[projectIdField];
    item.folderId = query[folderIdField];
    item.folderTitle = query[locationTitleField];
    item.parentFolderId = query[parentFolderIdField];
    item.permissionValue = query[permissionValueField];
    item.folderPath = query[locationPathField];
    item.isPublic = (query[isPublicField]==1)?true:false;
    item.isFavourite = (query[isFavoriteField]==1)?true:false;
    item.isActive = query[isActiveField];
    item.hasSubFolder = (query[hasSubFolderField]==1)?true:false;
    PfLocationTreeDetail pfLocationTreeDetail = PfLocationTreeDetail();
    pfLocationTreeDetail.locationId = query[locationIdField];
    pfLocationTreeDetail.parentLocationId = query[parentLocationIdField];
    pfLocationTreeDetail.siteId = query[siteIdField];
    pfLocationTreeDetail.docId = query[documentIdField];
    pfLocationTreeDetail.revisionId = query[revisionIdField];
    pfLocationTreeDetail.annotationId = query[annotationIdField];
    pfLocationTreeDetail.pageNumber = query[pageNumberField];
    pfLocationTreeDetail.isSite = (query[isSiteField]==1)?true:false;
    pfLocationTreeDetail.isCalibrated = (query[isCalibratedField]==1)?true:false;
    pfLocationTreeDetail.isFileUploaded = (query[isFileUploadedField]==1)?true:false;
    item.canRemoveOffline=query[canRemoveOfflineField]==1?true:false;
    item.isMarkOffline=query[isMarkOfflineField]==1?true:false;
    item.syncStatus = ESyncStatus.fromNumber(query[syncStatusField]);
    item.pfLocationTreeDetail = pfLocationTreeDetail;
    item.lastSyncTimeStamp = query[lastSyncTimeStampField];
    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(SiteLocation item) {
    return Future.value({
      projectIdField:item.projectId?.plainValue()??"",
      folderIdField:item.folderId?.plainValue()??"",
      locationIdField:item.pfLocationTreeDetail?.locationId??0,
      locationTitleField:item.folderTitle??"",
      parentFolderIdField:item.parentFolderId??0,
      parentLocationIdField:item.pfLocationTreeDetail?.parentLocationId??0,
      permissionValueField:item.permissionValue??"",
      locationPathField:item.folderPath??"",
      siteIdField:item.pfLocationTreeDetail?.siteId??0,
      documentIdField:item.pfLocationTreeDetail?.docId?.plainValue()??"",
      revisionIdField:item.pfLocationTreeDetail?.revisionId?.plainValue()??"",
      annotationIdField:item.pfLocationTreeDetail?.annotationId ?? "",
      locationCoordinateField:item.pfLocationTreeDetail?.locationCoordinates,
      pageNumberField:item.pfLocationTreeDetail?.pageNumber??0,
      isPublicField:(item.isPublic??false) ? 1 : 0,
      isFavoriteField:(item.isFavourite??false) ? 1 : 0,
      isSiteField:(item.pfLocationTreeDetail?.isSite??false) ? 1 : 0,
      isCalibratedField:(item.pfLocationTreeDetail?.isCalibrated??false) ? 1 : 0,
      isFileUploadedField:(item.pfLocationTreeDetail?.isFileUploaded??false) ? 1 : 0,
      isActiveField:((item.isActive??0)==1) ? 1 : 0,
      hasSubFolderField:(item.hasSubFolder??false) ? 1 : 0,
      canRemoveOfflineField:(item.canRemoveOffline??false) ? 1 : 0,
      isMarkOfflineField:(item.isMarkOffline??false) ? 1 : 0,
      syncStatusField:(item.syncStatus??ESyncStatus.failed).value,
      lastSyncTimeStampField:item.lastSyncTimeStamp??"",
    });
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<SiteLocation> objects) async{
    List<Map<String, dynamic>> projectList = [];
    for (var element in objects) {
      projectList.add(await toMap(element));
    }
    return projectList;
  }

  Future<void> insert(List<SiteLocation> siteLocationList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(siteLocationList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<Map<String,List<ESyncStatus>>> isLocationMarkedOfflineForProject() async {
    List<Map<String,dynamic>> qurResult = [];
    Map<String,List<ESyncStatus>> data = {};
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      String query = "SELECT locTbl.ProjectId, IFNULL(syncLocTbl.SyncStatus,locTbl.SyncStatus) AS SyncStatus FROM LocationDetailTbl locTbl LEFT JOIN SyncLocationTbl syncLocTbl ON locTbl.ProjectId=syncLocTbl.ProjectId AND locTbl.LocationId=syncLocTbl.LocationId WHERE locTbl.CanRemoveOffline=1";
      qurResult = db.executeSelectFromTable(tableName, query);

      if (qurResult.isNotEmpty) {
        for (Map res in qurResult) {
          List<ESyncStatus> temp = data[res['ProjectId'].toString()] ?? [];
          temp.add(ESyncStatus.fromNumber(res['SyncStatus']));
          data[res['ProjectId'].toString()] = temp;
        }
      }
      return data;
    } on Exception catch (e) {
      Log.d(e.toString());
    }
    return data;
  }

}