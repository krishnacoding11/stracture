import 'package:field/data/dao/location_dao.dart';
import 'package:field/data/local/project_list/project_list_local_repository.dart';
import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/remote/generic/generic_repository_impl.dart';
import 'package:field/data/remote/project_list/project_list_repository_impl.dart';
import 'package:field/data/repository/project_list/project_list_repository.dart';
import 'package:field/domain/common/base_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/field_enums.dart';

import '../../../data/model/sync_size_vo.dart';
import '../../../networking/network_response.dart';

class ProjectListUseCase extends BaseUseCase {
  ProjectListRepository? _projectListRepository;

  Future<List<Project>> getProjectList(int page, int batchSize, String? projectID) async {
    Map<String, dynamic> map = {};
    map["isPrivilegesRequired"] = "true";
    map["projectIds"] = projectID;
    map["checkHashing"] = "false";
    map["searchProjectIds"] = "";
    // map["appType"] = "2";
    await getInstance();
    return await _projectListRepository!.getProjectList(page, batchSize, map);
  }
  Future<List<Popupdata>> getPopupDataList(int page, int batchSize, Map<String,dynamic> request) async {
    await getInstance();
    var projectList = await _projectListRepository!.getPopupDataList(page, batchSize, request);
    ProjectListLocalRepository repo = ProjectListLocalRepository();
    List<Map<String, dynamic>> offlineSyncProject = await repo.getSyncProjectList();
    for(Popupdata item in projectList){
      if (offlineSyncProject.isNotEmpty) {
        Map<String, dynamic> syncProject = {};
        for (var element in offlineSyncProject) {
          syncProject.putIfAbsent(element['ProjectId'], () => element);
        }
        if (syncProject.isNotEmpty && syncProject.containsKey(item.id.plainValue())) {
          item.isMarkOffline = syncProject.values.first["IsMarkOffline"] == 1 ? true : false;
          item.projectSizeInByte = syncProject.values.first["projectSizeInByte"].toString();
          item.syncStatus = ESyncStatus.fromString((syncProject.values.first["SyncStatus"]??ESyncStatus.failed.value).toString());
          if (syncProject.values.first["SyncProgress"] != null && item.syncStatus == ESyncStatus.inProgress) {
            item.progress = double.tryParse(syncProject.values.first["SyncProgress"]?.toString() ?? "");
          }
        } else {
          item.isMarkOffline = false;
          item.projectSizeInByte ="";
        }
      } else {
        item.isMarkOffline = false;
        item.projectSizeInByte ="";
      }
    }
    await checkLocationStatus(projectList);
    return projectList;
  }

  Future<List<Popupdata>> checkLocationStatus(List<Popupdata> projectList) async {
    LocationDao locDao = LocationDao();
    Map<String,List<ESyncStatus>> data = await locDao.isLocationMarkedOfflineForProject();
    for(Popupdata item in projectList){
      item.hasLocationMarkOffline = data.containsKey(item.id.plainValue());
      if((item.hasLocationMarkOffline ?? false)){
        ESyncStatus locationStatus = ESyncStatus.success;
        List<ESyncStatus> arr =  data[item.id.plainValue()] ?? [];
        for(ESyncStatus status in arr){
          if(status == ESyncStatus.inProgress){
            locationStatus = status;
            break;
          }
          else if(status == ESyncStatus.failed){
            locationStatus = status;
          }
        }
        item.locationSyncStatus = locationStatus;
        if(locationStatus == ESyncStatus.success){
          item.hasLocationSyncedSuccessfully =  true;
        }
        else{
          item.hasLocationSyncedSuccessfully =  false;
        }
      }
      else{
        item.hasLocationSyncedSuccessfully =  false;
      }
    }
    return projectList;
  }

  Future<bool> isProjectMarkedOffline() async {
    ProjectListLocalRepository repo = ProjectListLocalRepository();
    return await repo.isProjectMarkedOffline();
  }

  Future<dynamic> setFavProject(Map<String,dynamic> request) async {
    await getInstance();
    return await _projectListRepository!.setFavProject(request);
  }

  Future<Result> getProjectAndLocationList(Map<String, dynamic> request) async{
    await getInstance();
    return await _projectListRepository!.getProjectAndLocationList(request);
  }

  Future<Result> getColumnHeaderList(Map<String, dynamic> request) async{
    await getInstance();
    return await _projectListRepository!.getColumnHeaderList(request);
  }

  Future<Result> getFormList(Map<String, dynamic> request) async{
    await getInstance();
    return await _projectListRepository!.getFormList(request);
  }

  Future<Result> getFormMessageBatchList(Map<String, dynamic> request) async{
    await getInstance();
    return await _projectListRepository!.getFormMessageBatchList(request);
  }

  Future<Result> downloadFormAttachmentInBatch(Map<String, dynamic> request,{bool bAkamaiDownload=true}) async{
    await getInstance();
    return await _projectListRepository!.downloadFormAttachmentInBatch(request, bAkamaiDownload: bAkamaiDownload);
  }

  Future<Result> getServerTime(Map<String, dynamic> request) async{
    await getInstance();
    return await _projectListRepository!.getServerTime(request);
  }

  Future<Result> getDeviceConfigurationFromServer() async{
    return di.getIt<GenericRemoteRepository>().getDeviceConfiguration();
  }

  Future<Result> getHashedValueFromServer(Map<String, dynamic> request) async{
    await getInstance();
    return await _projectListRepository!.getHashedValue(request);
  }
  Future<Result> getStatusStyleFromServer(Map<String, dynamic> request) async{
    await getInstance();
    return await _projectListRepository!.getStatusStyle(request);
  }
  Future<Result> getManageTypeListFromServer(Map<String, dynamic> request) async{
    await getInstance();
    return await _projectListRepository!.getManageTypeList(request);
  }

  Future<List<SyncSizeVo>> deleteItemFromSyncTable(Map<String,dynamic> request) async {
    await getInstance();
    return await _projectListRepository!.deleteItemFromSyncTable(request);
  }

  Future<Result> getWorkspaceSettings(Map<String,dynamic> request) async {
    await getInstance();
    return await _projectListRepository!.getWorkspaceSettings(request);
  }

  @override
  Future<ProjectListRepository?> getInstance() async {
    if(isNetWorkConnected()){
      _projectListRepository = di.getIt<ProjectListRemoteRepository>();
    }
    else{
      _projectListRepository = di.getIt<ProjectListLocalRepository>();
    }
    return _projectListRepository;
  }

  Future<Result> getDiscardedFormIds(Map<String, dynamic> request) async  {
    await getInstance();
    return await _projectListRepository!.getDiscardedFormIds(request);
  }
}