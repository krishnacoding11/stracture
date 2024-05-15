import '../../../../utils/field_enums.dart';


class SiteSyncLocationVo {
  String? projectId;
  String? locationId;
  String? parentLocationId;
  String? docId;
  String? revisionId;
  ESyncStatus? ePdfSyncStatus = ESyncStatus.failed;
  ESyncStatus? eXfdfSyncStatus = ESyncStatus.failed;
  ESyncStatus? eFormListSyncStatus = ESyncStatus.failed;
  String? newSyncTimeStamp;
  ESyncStatus? eSyncStatus = ESyncStatus.failed;
  double syncProgress = 0.0;
}
