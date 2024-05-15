import 'package:field/data/local/project_list/project_list_local_repository.dart';
import 'package:field/data/local/site/site_local_repository.dart';
import 'package:field/data/model/pinsdata_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/domain/common/base_usecase.dart';
import 'package:field/injection_container.dart' as di;

import '../../../data/model/sync_size_vo.dart';
import '../../../data/remote/site/site_remote_repository.dart';
import '../../../data/repository/site/site_repository.dart';
import '../../../networking/network_info.dart';
import '../../../networking/network_response.dart';
import '../../../utils/download_service.dart';

class SiteUseCase extends BaseUseCase<SiteRepository>{
  SiteRepository? _siteRepository;

  @override
  Future<SiteRepository?> getInstance() async {
    //if(_siteRepository == null) {
      if (isNetWorkConnected()) {
        _siteRepository = di.getIt<SiteRemoteRepository>();
        // _siteRepository = di.getIt<SiteLocalRepository>();
      } else {
        _siteRepository = di.getIt<SiteLocalRepository>();
      }
      return _siteRepository;
    //}
  }
  Future<DownloadResponse> downloadPdf(Map<String, dynamic> request,
      {DownloadProgressCallback? onReceiveProgress,
      bool checkFileExist = true}) async {
    await getInstance();
    return _siteRepository!.downloadPdf(request,
        onReceiveProgress: onReceiveProgress, checkFileExist: checkFileExist);
  }

  Future<DownloadResponse> downloadXfdf(Map<String, dynamic> request,
      {DownloadProgressCallback? onReceiveProgress,
      bool checkFileExist = false}) async {
    await getInstance();
    return _siteRepository!.downloadXfdf(request,
        onReceiveProgress: onReceiveProgress, checkFileExist: checkFileExist);
  }

  Future<Result> getLocationTree(Map<String, dynamic> request) async {
    await getInstance();
    return _siteRepository!.getLocationTree(request);
  }

  Future<SiteLocation?> getLocationTreeByAnnotationId(
      Map<String, dynamic> request) async {
    await getInstance();
      return _siteRepository!.getLocationTreeByAnnotationId(request);
  }

  Future<List<SiteLocation>?> getLocationDetailsByLocationIds(
      Map<String, dynamic> request) async {
    await getInstance();
    return _siteRepository!.getLocationDetailsByLocationIds(request);
  }

  Future<List<ObservationData>?> getObservationListByPlan(
      Map<String, dynamic> request) async {
    await getInstance();
    return _siteRepository!.getObservationListByPlan(request);
  }

  Future<Result> getSearchList(Map<String, dynamic> request) async {
    await getInstance();
    return _siteRepository!.getSearchList(request);
  }

  Future<Result?> getSuggestedSearchList(Map<String, dynamic> request) async {
    await getInstance();
    return _siteRepository!.getSuggestedSearchList(request);
  }

  Future<bool> isProjectLocationMarkedOffline(String? projectId) async {
    ProjectListLocalRepository repo = ProjectListLocalRepository();
    bool isProjectMarkOffline = await repo.isProjectMarkedOffline();

    if (!isProjectMarkOffline) {
      return isProjectMarkOffline;
    }

    SiteLocalRepository siteLocalRepository = SiteLocalRepository();
    return await siteLocalRepository.isProjectLocationMarkedOffline(projectId);
  }

  Future<bool> canRemoveOfflineLocation(String? projectId, List<String> locationIds) async {
    SiteLocalRepository siteLocalRepository = SiteLocalRepository();
    return await siteLocalRepository.canRemoveOfflineLocation(projectId, locationIds);
  }

  Future<List<SyncSizeVo>> deleteItemFromSyncTable(Map<String,dynamic> request) async {
    SiteLocalRepository siteLocalRepository = SiteLocalRepository();
    return await siteLocalRepository.deleteItemFromSyncTable(request);
  }
}
