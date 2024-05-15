import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';

import '../../database/dao.dart';
import '../../utils/field_enums.dart';
import '../model/project_vo.dart';

class ProjectDao extends Dao<Project> {
  static const tableName = 'ProjectDetailTbl';

  static const projectIdField = "ProjectId";
  static const projectNameField = "ProjectName";
  static const dcIdField = "DcId";
  static const privilegeField = "Privilege";
  static const projectAdminsField = "ProjectAdmins";
  static const ownerOrgIdField = "OwnerOrgId";
  static const statusIdField = "StatusId";
  static const projectSubscriptionTypeIdField = "ProjectSubscriptionTypeId";
  static const isFavoriteField = "IsFavorite";
  static const bimEnabledField = "BimEnabled";
  static const isUserAdminForProjectField = "IsUserAdminForProject";
  static const canRemoveOfflineField = "CanRemoveOffline";
  static const isMarkOfflineField = "IsMarkOffline";
  static const syncStatusField = "SyncStatus";
  static const lastSyncTimeStampField = "LastSyncTimeStamp";
  static const projectSizeInByte = "projectSizeInByte";

  String get fields => "$projectIdField TEXT NOT NULL,"
      "$projectNameField TEXT NOT NULL,"
      "$dcIdField INTEGER NOT NULL,"
      "$privilegeField TEXT,"
      "$projectAdminsField TEXT,"
      "$ownerOrgIdField INTEGER,"
      "$statusIdField INTEGER,"
      "$projectSubscriptionTypeIdField INTEGER,"
      "$isFavoriteField INTEGER NOT NULL DEFAULT 0,"
      "$bimEnabledField INTEGER NOT NULL DEFAULT 0,"
      "$isUserAdminForProjectField INTEGER NOT NULL DEFAULT 0,"
      "$canRemoveOfflineField INTEGER NOT NULL DEFAULT 0,"
      "$isMarkOfflineField INTEGER NOT NULL DEFAULT 0,"
      "$syncStatusField INTEGER NOT NULL DEFAULT 0,"
      "$lastSyncTimeStampField TEXT,"
      "$projectSizeInByte INTEGER NOT NULL DEFAULT 0";

  String get primaryKeys => ",PRIMARY KEY($projectIdField)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<Project> fromList(List<Map<String, dynamic>> query) {
    return List<Project>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  fromMap(Map<String, dynamic> query) {
    Project item = Project();
    item.iProjectId = 0;
    item.projectName = query[projectNameField];
    item.projectID = query[projectIdField];
    item.parentId = -1;
    item.isWorkspace = 1;
    item.projectBaseUrl = "";
    item.projectBaseUrlForCollab = "";
    item.isUserAdminforProj = (query[isUserAdminForProjectField] == 1) ? true : false;
    item.bimEnabled = (query[bimEnabledField] == 1) ? true : false;
    item.isFavorite = (query[isFavoriteField] == 1) ? true : false;
    item.canManageWorkspaceRoles = false;
    item.canManageWorkspaceFormStatus = false;
    item.isFromExchange = false;
    item.spaceTypeId = "";
    item.isTemplate = false;
    item.isCloned = false;
    item.activeFilesCount = 0;
    item.formsCount = 0;
    item.statusId = query[statusIdField];
    item.users = 0;
    item.fetchRuleId = 0;
    item.canManageWorkspaceDocStatus = false;
    item.canCreateAutoFetchRule = false;
    item.ownerOrgId = query[ownerOrgIdField];
    item.canManagePurposeOfIssue = false;
    item.canManageMailBox = false;
    item.editWorkspaceFormSettings = false;
    item.canAssignApps = false;
    item.canManageDistributionGroup = false;
    item.defaultpermissiontypeid = 0;
    item.checkoutPref = false;
    item.restrictDownloadOnCheckout = false;
    item.canManageAppSetting = false;
    item.projectsubscriptiontypeid = query[projectSubscriptionTypeIdField];
    item.canManageCustomAttribute = false;
    item.isAdminAccess = false;
    item.isUseAccess = false;
    item.canManageWorkflowRules = false;
    item.canAccessAuditInformation = false;
    item.countryId = 0;
    item.projectSpaceTypeId = 0;
    item.isWatching = false;
    item.canManageRolePrivileges = false;
    item.canManageFormPermissions = false;
    item.canManageProjectInvitations = false;
    item.enableCommentReview = false;
    item.projectViewerId = 0;
    item.isShared = false;
    item.insertInStorageSpace = false;
    item.colorid = 0;
    item.iconid = 0;
    item.businessid = 0;
    item.generateURI = false;
    item.canRemoveOffline = query[canRemoveOfflineField] == 1 ? true : false;
    item.isMarkOffline = query[isMarkOfflineField] == 1 ? true : false;
    item.syncStatus = ESyncStatus.fromNumber(query[syncStatusField]);
    item.lastSyncTimeStamp = query[lastSyncTimeStampField];
    item.projectSizeInByte = query[projectSizeInByte].toString();
    item.dcId = query[dcIdField];
    return item;
  }

  @override
  Future<Map<String, dynamic>> toMap(Project item) {
    return Future.value({projectIdField: item.projectID?.plainValue() ?? "", projectNameField: item.projectName ?? "", dcIdField: item.dcId ?? 1, privilegeField: item.privilege ?? "", projectAdminsField: "", ownerOrgIdField: item.ownerOrgId ?? 0, statusIdField: item.statusId ?? 0, projectSubscriptionTypeIdField: item.projectsubscriptiontypeid ?? 0, isFavoriteField: (item.isFavorite ?? false) ? 1 : 0, bimEnabledField: (item.bimEnabled ?? false) ? 1 : 0, isUserAdminForProjectField: (item.isFavorite ?? false) ? 1 : 0, canRemoveOfflineField: (item.canRemoveOffline ?? false) ? 1 : 0, isMarkOfflineField: (item.isMarkOffline ?? false) ? 1 : 0, syncStatusField: (item.syncStatus ?? ESyncStatus.failed).value, lastSyncTimeStampField: item.lastSyncTimeStamp ?? "", projectSizeInByte: item.projectSizeInByte ?? "0"});
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<Project> objects) async {
    List<Map<String, dynamic>> projectList = [];
    for (var element in objects) {
      projectList.add(await toMap(element));
    }
    return projectList;
    //return Future.value(List<Map<String, dynamic>>.from(objects.map((element) async => await toMap(element))).toList());
  }

  Future<void> insert(List<Project> projectList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(projectList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<Project> fetchProjectId(String projectId, bool isSetOffline) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    List<Project> list = [];
    String fetchProjectIdQuery = "SELECT * FROM $tableName";
    try {
      var qurResult = db.executeSelectFromTable(tableName, fetchProjectIdQuery);
      list = fromList(qurResult);
      return list.isNotEmpty ? list.first : Project();
    } on Exception catch (e) {
      return list.isNotEmpty ? list.first : Project();
    }
  }

  popupDataFromMap(Map<dynamic, dynamic> query) {
    Popupdata item = Popupdata();
    item.value = query[projectNameField];
    item.dataCenterId = query[dcIdField];
    item.id = query[projectIdField];
    item.isSelected = false;
    item.imgId = query[isFavoriteField];
    item.isActive = true;
    item.projectSizeInByte = query[projectSizeInByte].toString();
    return item;
  }
}
