import 'dart:convert';

import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/utils/app_config.dart';
import 'package:field/utils/utils.dart';
import 'package:storage_space/storage_space.dart';

import '../../data/model/download_size_vo.dart';
import '../../data/model/sync_size_vo.dart';
import '../../domain/use_cases/download_size/download_size_usecase.dart';
import '../../networking/network_response.dart';
import '../../presentation/base/state_renderer/state_render_impl.dart';
import '../../presentation/base/state_renderer/state_renderer.dart';
import '../../utils/store_preference.dart';
import 'download_size_state.dart';

class DownloadSizeCubit extends BaseCubit {
  DownloadSizeCubit({DownloadSizeUseCase? downloadSizeUseCase})
      : _downloadSizeUseCase = downloadSizeUseCase ?? di.getIt<DownloadSizeUseCase>(),
        super(InitialState(stateRendererType: StateRendererType.DEFAULT));
  final DownloadSizeUseCase _downloadSizeUseCase;
  int batchSize = di.getIt<AppConfig>().syncPropertyDetails!.fieldOfflineLocationSizeSyncLimit;

  Future<int?> getProjectOfflineSyncDataSize(String projectId, List<String?> locationId) async {
    emitState(SyncDownloadStartState());
    bool includeAttachments = await StorePreference.isIncludeAttachmentsSyncEnabled();

    var result;
    if (locationId.length > batchSize) {
      int index = 0;
      List<String> idList = [];
      while (index < locationId.length && result is! FAIL) {
        for (int i = index; i <= locationId.length; i++) {
          idList.add(locationId[i]!);
          if ((i + 1) == locationId.length) {
            if (result == null || result is! FAIL) result = await _downloadSizeUseCase.getOfflineSyncDataSize(getRequestedMap(projectId, idList, includeAttachments: includeAttachments));
            index = locationId.length;
            break;
          } else if (idList.length == batchSize) {
            if (result == null || result is! FAIL) result = await _downloadSizeUseCase.getOfflineSyncDataSize(getRequestedMap(projectId, idList, includeAttachments: includeAttachments));
            index = (index + (idList.length));
            idList.clear();
            break;
          }
        }
      }
    } else {
      result = await _downloadSizeUseCase.getOfflineSyncDataSize(getRequestedMap(projectId, locationId, includeAttachments: includeAttachments));
    }

    try {
      if (result is SUCCESS && result.data != null) {
        Map data = result.data;
        if (data.isNotEmpty) {
          int? totalSize = await getSyncProjectSize(projectId: projectId);
          int? displaySize;
          if (locationId[0] == "-1") {
            displaySize = totalSize;
          } else {
            displaySize = await getRequestedLocationSyncSize(projectId: projectId, locationIds: locationId);
          }
          StorageSpace storageSpace = await getStorageSpace(
            lowOnSpaceThreshold: totalSize!, // 2GB
            fractionDigits: 1,
          );
          bool lowOnSpace = storageSpace.lowOnSpace;
          if (!lowOnSpace) {
            emitState(SyncDownloadSizeState(displaySize!));
            return totalSize;
          } else {
            emitState(SyncDownloadLimitState(storageSpace, displaySize!));
          }
        } else {
          emitState(SyncDownloadSizeState(0));
        }
      } else {
        emitState(SyncDownloadErrorState(result.failureMessage ?? "", DateTime.now().millisecondsSinceEpoch.toString()));
      }
    } on Exception catch (e) {
      emitState(SyncDownloadErrorState(e.toString(), DateTime.now().millisecondsSinceEpoch.toString()));
    }
    return null;
  }

  Map<String, dynamic> getRequestedMap(String projectId, List<String?> locationId, {required bool includeAttachments}) {
    Map<String, dynamic> map = <String, dynamic>{};
    List<Map<String, dynamic>> requestedJson = [];
    locationId.forEach((element) {
      final Map<String, dynamic> projectRequestMap = {"projectId": projectId, "locationIds": element};
      requestedJson.add(projectRequestMap);
    });

    map["tabId"] = "1";
    map["requestDetailsJSON"] = jsonEncode(requestedJson);
    map["settingJSON"] = jsonEncode({"includeAttachments": includeAttachments, "includeAssociation": false, "includeClosedOutForms": false});
    map["batchSize"] = batchSize;
    return map;
  }

  Future<int?> getSyncProjectSize({required String projectId}) async {
    List<SyncSizeVo> syncSizeVoList = await _downloadSizeUseCase.getProjectSyncSize({"projectId": projectId});

    if (syncSizeVoList.isNotEmpty) {
      Map<String, int> syncSize = DownloadSizeVo.fromSyncVo(syncSizeVoList);
      int projectDownloadSize = syncSize["totalSize"]! + Utility.getTotalSizeOfMetaData(syncSize["totalLocationCount"]!);
      return projectDownloadSize;
    }
    return null;
  }

  Future<int?> getRequestedLocationSyncSize({required String projectId, required List<String?> locationIds}) async {
    List<SyncSizeVo> syncSizeVoList = await _downloadSizeUseCase.requestedLocationSyncSize({"projectId": projectId, "locationId": locationIds});
    if (syncSizeVoList.isNotEmpty) {
      Map<String, int> syncSize = DownloadSizeVo.fromSyncVo(syncSizeVoList);
      int projectDownloadSize = syncSize["totalSize"]! + Utility.getTotalSizeOfMetaData(syncSize["totalLocationCount"]!);
      return projectDownloadSize;
    }
    return null;
  }
}
