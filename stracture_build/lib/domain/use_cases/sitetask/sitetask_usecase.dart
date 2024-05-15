import 'package:field/data/local/sitetask/sitetask_local_repository_impl.dart';
import 'package:field/data/remote/sitetask/sitetask_remote_repository_impl.dart';
import 'package:field/data/repository/sitetask_repository.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/networking/network_response.dart';

class SiteTaskUseCase extends SiteTaskRepository<Map,Result> {
  SiteTaskRepository? _siteTaskRepository;
  Future<SiteTaskRepository?> getInstance() async {
      if (isNetWorkConnected()) {
        _siteTaskRepository = getIt<SiteTaskRemoteRepository>();
        return _siteTaskRepository;
      } else {
        _siteTaskRepository = getIt<SiteTaskLocalRepository>();
        return _siteTaskRepository;
      }
  }

  //final SiteTaskRemoteRepository _remoteRepository =  getIt<SiteTaskRemoteRepository>();

  @override
  Future<Result?> getSiteTaskList(Map<String,dynamic> request) async {
    await getInstance();
    return await _siteTaskRepository!.getSiteTaskList(request);
  }

  @override
  Future<Result?> getExternalAttachmentList(Map<String,dynamic> request) async {
    await getInstance();
    return await _siteTaskRepository!.getExternalAttachmentList(request);
  }

  @override
  Future<Result?>? getFilterSiteTaskList(Map<String, dynamic> request) async {
    await getInstance();
    return await _siteTaskRepository!.getFilterSiteTaskList(request);
  }

  @override
  Future<Result?> getUpdatedSiteTaskItem(String projectId,String formId) async {
    await getInstance();
    return await _siteTaskRepository!.getUpdatedSiteTaskItem(projectId, formId);
  }
}