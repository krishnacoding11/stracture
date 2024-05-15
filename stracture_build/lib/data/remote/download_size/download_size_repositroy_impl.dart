import '../../../data_source/sync_size/sync_size_data_source.dart';
import '../../../networking/network_request.dart';
import '../../../networking/network_response.dart';
import '../../../networking/network_service.dart';
import '../../../networking/request_body.dart';
import '../../../utils/constants.dart';
import '../../model/download_size_vo.dart';
import '../../model/sync_size_vo.dart';

class DownloadSizeRepository {
  SyncSizeDataSource syncSizeDataSource = SyncSizeDataSource();
  Future<Result?> getOfflineSyncDataSize(Map<String, dynamic> request,[dioInstance]) async {

    Result result = await NetworkService(
      dioClient: dioInstance,
      baseUrl: AConstants.adoddleUrl,
      headerType: HeaderType.APPLICATION_FORM_URL_ENCODE,
      mNetworkRequest: NetworkRequest(
        type: NetworkRequestType.POST,
        path: AConstants.getOfflineSyncDataSizeUrl,
        data: NetworkRequestBody.json(request),
      ),
    ).execute((response){
      return DownloadSizeVo.getDownloadSize(response);
    });
    return result;
  }

  Future<List<SyncSizeVo>> getProjectSyncSize(Map<String, dynamic> request) async {
    await syncSizeDataSource.init();
    return await syncSizeDataSource.getProjectSyncSize(request);
  }

  Future<List<SyncSizeVo>> requestLocationSyncSize(Map<String, dynamic> request) async {
    await syncSizeDataSource.init();
    return syncSizeDataSource.getRequestedLocationSyncSize(request);
  }

  Future<void> addSyncSize(Map<String, List<Map<String, DownloadSizeVo>>> downloadSizeResponse) async {

    List<SyncSizeVo> syncSizeList = [];
    if (downloadSizeResponse.isNotEmpty) {
      downloadSizeResponse.forEach((projectKey, value) {
        value.forEach((locationElement) {
          locationElement.forEach((key, value) {
            syncSizeList.add(SyncSizeVo(projectId: projectKey,locationId: int.parse(key),downloadSizeVo: value));
          });
        });
      });
    }

    await syncSizeDataSource.init();
    await syncSizeDataSource.updateSyncSize(syncSizeList);
  }
}
