import 'package:field/utils/field_enums.dart';

class SyncStatusResult {
  late ESyncType eSyncType;
  late ESyncStatus eSyncStatus;
  String? data;

  SyncStatusResult();

  SyncStatusResult.fromJson(Map<String, dynamic> json) {
    eSyncType = ESyncType.values[json['syncType']];
    eSyncStatus = ESyncStatus.fromNumber(json['syncStatus']);
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    return {'syncType': eSyncType.index, 'syncStatus': eSyncStatus.value, 'data': data};
  }
}
