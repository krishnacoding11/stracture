import '../../../../utils/field_enums.dart';

class SiteSyncFormTypeVo {
  String? projectId;
  String? formTypeId;
  ESyncStatus? eTemplateDownloadSyncStatus = ESyncStatus.failed;
  ESyncStatus? eDistributionListSyncStatus = ESyncStatus.failed;
  ESyncStatus? eStatusListSyncStatus = ESyncStatus.failed;
  ESyncStatus? eCustomAttributeListSyncStatus = ESyncStatus.failed;
  ESyncStatus? eControllerUserListSyncStatus = ESyncStatus.failed;
  ESyncStatus? eFixFieldListSyncStatus = ESyncStatus.failed;

}
