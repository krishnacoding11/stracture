import 'package:field/utils/field_enums.dart';

abstract class SyncStatusDataVo {
  String? projectId;
  ESyncStatus? eSyncStatus;
  double? syncProgress;
}

class SiteSyncStatusDataVo extends SyncStatusDataVo {
  String? locationId;
  SiteSyncStatusDataVo();
  SiteSyncStatusDataVo.fromJson(Map<String, dynamic> json) {
    projectId = json['ProjectId'].toString();
    locationId = json['LocationId'].toString();
    eSyncStatus = ESyncStatus.fromNumber(json['SyncStatus'] ??  ESyncStatus.inProgress.value);
    syncProgress = json.containsKey('SyncProgress') && json['SyncProgress'] != null ? double.parse(json['SyncProgress'].toString()) : 0.0;
  }
  Map<String, dynamic> toJson() {
    return {
      'ProjectId': projectId,
      'SyncStatus': eSyncStatus?.value ?? ESyncStatus.inProgress,
      'SyncProgress': syncProgress,
      'LocationId':locationId
    };
  }

  List<SiteSyncStatusDataVo> toList(List<Map<String, dynamic>> list) {
    return List<SiteSyncStatusDataVo>.from(list.map((element) => SiteSyncStatusDataVo.fromJson(element))).toList();
  }
}