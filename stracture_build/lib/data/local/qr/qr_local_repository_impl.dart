import 'dart:convert';

import 'package:field/data/dao/location_dao.dart';
import 'package:field/data/dao/project_dao.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/qrcodedata_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/data/repository/qr_repository.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';

import '../../../networking/network_response.dart';
import '../../../networking/request_body.dart';
import '../../dao/formtype_dao.dart';

class QRLocalRepository extends QrRepository<Map, Result> {
  QRLocalRepository();

  FormTypeDao formTypeDao = FormTypeDao();

  @override
  Future<Result?> checkQRCodePermission(Map<String, dynamic> request) async {
    String projectId = request['projectId'].toString().plainValue();
    String folderId = request['folderIds'].toString().plainValue();
    String instanceGroupId = request['instanceGroupId'].toString().plainValue();
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    Object type = QRCodeType.values[int.parse(request["generateQRCodeFor"].toString()) - 1];
    if (type == QRCodeType.qrFormType) {
      String getFormQuery = "SELECT *, MAX(FormTypeId) FROM FormGroupAndFormTypeListTbl WHERE ProjectId =$projectId AND InstanceGroupId =$instanceGroupId;";
      String getProjectQuery = "SELECT ProjectId FROM ProjectDetailTbl WHERE ProjectId =$projectId;";

      Result? result;
      try {
        var getProjectResult = db.executeSelectFromTable(ProjectDao.tableName, getProjectQuery);
        if (getProjectResult.isNotEmpty) {
          var qurResult = db.executeSelectFromTable(FormTypeDao.tableName, getFormQuery);
          Map<String, dynamic> data = qurResult.first;
          if (data["CanCreateForms"] == 1) {
            result = SUCCESS(qurResult, null, 200, requestData: NetworkRequestBody.json(request));
          } else {
            result = FAIL("Sorry, You do not have permission to create this form. Please contact your Workspace Administrator.", 602);
          }
        } else {
          result = FAIL("Sorry, this is currently not available. Please make sure QR Code content has been previously downloaded for offline work. Contact your project administrator for more information.", 602);
        }
      } on Exception catch (e) {
        result = FAIL("failureMessage -----> $e", 602);
      }
      return result;
    } else {
      String locationTreeQuery = "SELECT locTbl.* FROM LocationDetailTbl locTbl\n"
          "INNER JOIN LocationDetailTbl cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.ParentLocationId=locTbl.ParentLocationId AND locTbl.IsActive=1 \n"
          "AND cteLoc.ProjectId=$projectId AND cteLoc.FolderId=$folderId\n"
          "ORDER BY LocationTitle COLLATE NOCASE ASC";
      try {
        var qurResult = db.executeSelectFromTable(ProjectDao.tableName, locationTreeQuery);
        List<SiteLocation> siteLocations = LocationDao().fromList(qurResult);
        if (siteLocations.isNotEmpty) {
          if (siteLocations.first.isActive == 1) {
            return SUCCESS(siteLocations.first, null, 200);
          } else {
            return FAIL("Sorry, you do not have access to this location. Please contact your Workspace Admin for more information.", -1);
          }
        } else {
          return FAIL("Sorry, this location is not available now. Please save content for offline working or contact your Workspace Admin for more information.", -1);
        }
      } on Exception catch (e) {
        Log.d("Map------>${e.toString()}");
      }
      return FAIL("Sorry, this location is not available now. Please save content for offline working or contact your Workspace Admin for more information.", -1);
    }
  }

  @override
  Future<Result?>? getFormPrivilege(Map<String, dynamic> request) async {
    String projectId = request["projectId"].toString().plainValue();
    String instanceGroupId = request["instanceGroupId"].toString().plainValue();
    String selectQuery = "SELECT * FROM ${FormTypeDao.tableName} WHERE ${FormTypeDao.projectIdField}=$projectId AND ${FormTypeDao.instanceGroupIdField}=$instanceGroupId ORDER BY ${FormTypeDao.formTypeIdField} DESC";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(FormTypeDao.tableName, selectQuery);
      if (qurResult.isNotEmpty) {
        FormTypeDao formTypeDao = FormTypeDao();
        AppType temp = formTypeDao.fromList(qurResult).first;
        var dict = temp.toJson();
        dict = {
          "formTypeGroupList": [
            {
              "formType_List": [dict]
            }
          ]
        };
        return SUCCESS(json.encode(dict), null, 200, requestData: NetworkRequestBody.json(request));
      } else {
        return FAIL("Something Went Wrong", 999);
      }
    } on Exception catch (e) {
      return FAIL("failureMessage -----> $e", 999);
    }
  }

  @override
  Future<Result?>? getLocationDetails(Map<String, dynamic> request) async {
    String projectId = request["projectId"];
    String locationId = request["locationIds"];
    String selectQuery = "SELECT * FROM ${LocationDao.tableName} WHERE ${LocationDao.projectIdField}=$projectId AND ${LocationDao.locationIdField}=$locationId";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      var qurResult = db.executeSelectFromTable(FormTypeDao.tableName, selectQuery);
      LocationDao dao = LocationDao();
      if (qurResult.isNotEmpty) {
        SiteLocation temp = dao.fromList(qurResult).first;
        var arr = [temp];
        return SUCCESS(json.encode(arr), null, 200, requestData: NetworkRequestBody.json(request));
      } else {
        return FAIL("Something Went Wrong", 999);
      }
    } on Exception catch (e) {
      return FAIL("failureMessage -----> $e", 999);
    }
  }

  @override
  Future<Result?> getFieldEnableSelectedProjectsAndLocations(Map<String, dynamic> request) async {
    if (!request['projectId'].toString().contains(Utility.keyDollar) || !request['folder_id'].toString().contains(Utility.keyDollar)) {}
    String projectId = request['projectId'].toString().plainValue();
    String folderId = request['folder_id'].toString().plainValue();
    //request.remove("dcId");
    //Instantiate a service and keep it in your DI container:

    Result? result;

    List<Project> projectList = <Project>[];
    ProjectDao projectDao = ProjectDao();

    String query = "SELECT * FROM ${ProjectDao.tableName} WHERE ${ProjectDao.projectIdField}=$projectId  ORDER BY ${ProjectDao.projectNameField} COLLATE NOCASE ASC";
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    bool fetchMore = false;
    List<SiteLocation> sites = [];
    do {
      fetchMore = false;
      String locationTreeQuery = "SELECT locTbl.* FROM LocationDetailTbl locTbl\n"
          "INNER JOIN LocationDetailTbl cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.ParentLocationId=locTbl.ParentLocationId AND locTbl.IsActive=1 \n"
          "AND cteLoc.ProjectId=$projectId AND cteLoc.FolderId=$folderId\n"
          "ORDER BY LocationTitle COLLATE NOCASE ASC";
      try {
        var qurResult = db.executeSelectFromTable(ProjectDao.tableName, locationTreeQuery);
        List<SiteLocation> siteLocations = LocationDao().fromList(qurResult);
        if (siteLocations.isNotEmpty) {
          for (var element in siteLocations) {
            if (element.folderId == folderId) {
              element.childTree = sites;
              break;
            }
          }
          if (siteLocations[0].pfLocationTreeDetail?.parentLocationId != 0) {
            folderId = siteLocations[0].parentFolderId.toString();
            fetchMore = true;
          }
          sites = siteLocations;
        }
      } on Exception catch (e) {
        Log.d("Map------>${e.toString()}");
      }
    } while (fetchMore);
    // String locationTreeQuery = "WITH AllParentTree AS (\n"
    //     "SELECT ProjectId,LocationId,ParentLocationId,1 AS Level FROM ${LocationDao.tableName}\n"
    //     "WHERE ProjectId=$projectId AND FolderId=$folderId\n"
    //     "UNION\n"
    //     "SELECT locTbl.ProjectId,locTbl.LocationId,locTbl.ParentLocationId,cteLoc.Level + 1 AS Level FROM ${LocationDao.tableName} locTbl\n"
    //     "INNER JOIN AllParentTree cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.ParentLocationId=locTbl.LocationId\n"
    //     ")\n"
    //     "SELECT cteLoc.Level, locTbl.* FROM ${LocationDao.tableName} locTbl\n"
    //     "INNER JOIN AllParentTree cteLoc ON cteLoc.ProjectId=locTbl.ProjectId AND cteLoc.ParentLocationId=locTbl.ParentLocationId AND locTbl.IsActive = 1\n"
    //     "ORDER BY Level DESC, LocationTitle COLLATE NOCASE ASC";

    try {
      var qurResult = db.executeSelectFromTable(ProjectDao.tableName, query);
      projectList = projectDao.fromList(qurResult);
      Project project;
      List<Map<String, dynamic>> mapSites = [];

      if (projectList.isNotEmpty) {
        project = projectList.first;
        result = SUCCESS(projectList, null, 200, requestData: NetworkRequestBody.json(request));
        for (SiteLocation site in sites) {
          mapSites.add(site.toJson());
        }
        project.childfolderTreeVOList = mapSites;
      } else {
        result = FAIL("No data available", -1);
      }
    } on Exception catch (e) {
      result = FAIL("failureMessage -----> $e", 602);
    }
    return result;
  }

  List<SiteLocation> generateLocationTree(List<SiteLocation> sites) {
    List<SiteLocation> locationTreeSite = [];
    // SiteLocation().childLocation

    return locationTreeSite;
  }

  dynamic getVOFromResponse(dynamic response) {
    try {
      dynamic json = jsonDecode(response);
      var projectList = List<Project>.from(json.map((x) => Project.fromJson(x)));
      List<Project> outputList = projectList.where((o) => o.iProjectId == 0).toList();
      return outputList;
    } catch (error) {
      return null;
    }
    // return response;
  }
}
