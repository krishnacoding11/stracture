import 'package:field/data/remote/download_size/download_size_repositroy_impl.dart';

import '../../../data/model/download_size_vo.dart';
import '../../../data/model/sync_size_vo.dart';
import '../../../injection_container.dart' as di;
import '../../../networking/network_response.dart';

class DownloadSizeUseCase {
  DownloadSizeUseCase({DownloadSizeRepository? downloadSizeRepository}) : _downloadSizeRepository = downloadSizeRepository ?? di.getIt<DownloadSizeRepository>();

  DownloadSizeRepository _downloadSizeRepository;

  Future<Result?> getOfflineSyncDataSize(Map<String, dynamic> request) async {
    final responseMap = await _downloadSizeRepository.getOfflineSyncDataSize(request);
    if (responseMap != null && responseMap.data is Map<String, List<Map<String, DownloadSizeVo>>>) {
      await _downloadSizeRepository.addSyncSize(responseMap.data);
    }
    return responseMap;
  }

  Future<List<SyncSizeVo>> getProjectSyncSize(Map<String, dynamic> request) async {
    return await _downloadSizeRepository.getProjectSyncSize(request);
  }
  Future<List<SyncSizeVo>> requestedLocationSyncSize(Map<String, dynamic> request) async {
    return await _downloadSizeRepository.requestLocationSyncSize(request);
  }
}