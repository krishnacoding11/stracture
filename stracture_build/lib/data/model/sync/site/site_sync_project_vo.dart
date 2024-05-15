import 'package:field/utils/field_enums.dart';

class SiteSyncProjectVo {
  String? projectId;
  ESyncStatus? eStatusStyleSyncStatus = ESyncStatus.failed;
  ESyncStatus? eManageTypeSyncStatus = ESyncStatus.failed;
  ESyncStatus? eFormTypeListSyncStatus = ESyncStatus.failed;
  ESyncStatus? eFormListSyncStatus = ESyncStatus.failed;
  ESyncStatus? eFilterSyncStatus = ESyncStatus.failed;
  ESyncStatus? eSyncStatus = ESyncStatus.failed;
  int syncProgress = 0;
  String? newSyncTimeStamp;
}
