import 'dart:convert';

import 'package:field/utils/field_enums.dart';

class SyncRequestTask {
  ESyncType? eSyncType;
  bool? isMarkOffline;
  int? syncRequestId;
  bool? isMediaSyncEnable;
  String? projectId;
  String? projectName;
  String? lastSyncTime;
  String? projectSizeInByte;
  int? thresholdCompletedTask;
  bool isReSync = false;

  Map<String, dynamic> toJson() {
    return {'projectId': projectId, 'projectName': projectName, 'syncRequestId': syncRequestId, 'syncType': eSyncType?.index, 'isMarkOffline': isMarkOffline, 'isMediaSyncEnable': isMediaSyncEnable, 'lastSyncTime':lastSyncTime, "projectSizeInByte":projectSizeInByte, "thresholdCompletedTask":thresholdCompletedTask, 'isReSync' : isReSync};
  }
}

class SiteSyncRequestTask extends SyncRequestTask {
  List<SyncRequestLocationVo>? syncRequestLocationList;


  SiteSyncRequestTask();

  SiteSyncRequestTask.fromJson(Map<String, dynamic> json) {
    eSyncType = ESyncType.values[json['syncType']];
    syncRequestId = json['syncRequestId'];
    projectId = json['projectId'];
    projectName = json['projectName'];
    if (json['syncRequestLocationList'] != null) {
      syncRequestLocationList = _jsonListToSyncRequestLocationList(jsonDecode(json['syncRequestLocationList']));
    } else {
      syncRequestLocationList = [];
    }
    isMarkOffline = json['isMarkOffline'];
    isMediaSyncEnable = json['isMediaSyncEnable'];
    if(json.containsKey('lastSyncTime') && json['lastSyncTime'] != null){
      lastSyncTime = json['lastSyncTime'];
    }
    projectSizeInByte = json['projectSizeInByte'];
    thresholdCompletedTask = json['thresholdCompletedTask'];
    isReSync = json['isReSync'] ?? false;
  }

  List<SyncRequestLocationVo> _jsonListToSyncRequestLocationList(dynamic response) {
    if (response != null) {
      return List<SyncRequestLocationVo>.from(response.map((x) => SyncRequestLocationVo.fromJson(x))).toList();
    }
    return [];
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data['syncRequestLocationList'] = syncRequestLocationList != null && syncRequestLocationList!.isNotEmpty ? jsonEncode(syncRequestLocationList) : null;
    return data;
  }
}

class SyncRequestLocationVo {
  String? locationId;
  String? folderTitle;
  String? folderId;
  String? lastSyncTime;
  bool isPlanOnly = false;
  bool isMediaSyncEnable = true;
  String? locationSizeInByte;

  SyncRequestLocationVo();

  SyncRequestLocationVo.fromJson(Map<String, dynamic> json) {
    locationId = json['locationId'].toString();
    folderTitle = json['folderTitle'].toString();
    folderId = json['folderId'].toString();
    lastSyncTime = json['lastSyncTime'];
    isPlanOnly = json['isPlanOnly'];
    isMediaSyncEnable = json['isMediaSyncEnable'];
    locationSizeInByte = json['locationSizeInByte'];
  }

  Map<String, dynamic> toJson() {
    return {'locationId': locationId, 'folderTitle': folderTitle, 'folderId': folderId, 'lastSyncTime': lastSyncTime, 'isPlanOnly': isPlanOnly, 'isMediaSyncEnable': isMediaSyncEnable,'locationSizeInByte':locationSizeInByte};
  }
}

class AutoSyncRequestTask extends SyncRequestTask {
  AutoSyncRequestTask();


}
