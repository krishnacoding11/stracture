
import 'package:field/data/repository/sitetask_repository.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/calculation/site_form_listing_local_data_soruce.dart';


class SiteTaskLocalRepository extends SiteTaskRepository<Map,Result> {
  final SiteFormListingLocalDataSource _siteFormListingLocalDataSource = getIt<SiteFormListingLocalDataSource>();
  SiteTaskLocalRepository();

  @override
  Future<Result?> getSiteTaskList(Map<String, dynamic> request) async {
    return _siteFormListingLocalDataSource.getOfflineObservationListJson(request);
  }

  @override
  Future<Result?> getExternalAttachmentList(Map<String, dynamic> request) async {
    return _siteFormListingLocalDataSource.getOfflineAttachmentListJson(request);
  }

  @override
  Future<Result?>? getFilterSiteTaskList(Map<String, dynamic> request) async {
    return _siteFormListingLocalDataSource.getOfflineObservationListJson(request);
  }

  @override
  Future<Result?> getUpdatedSiteTaskItem(String projectId, String formId) async {
    Map<String,dynamic> request = {};
    request["projectId"] = projectId;
    request["formId"] = formId;

    return _siteFormListingLocalDataSource.getUpdatedObservationListItemData(request);
  }
}