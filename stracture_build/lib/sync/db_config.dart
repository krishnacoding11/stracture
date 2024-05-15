import 'package:field/data/dao/form_dao.dart';
import 'package:field/data/dao/form_message_action_dao.dart';
import 'package:field/data/dao/form_message_attachAndAssoc_dao.dart';
import 'package:field/data/dao/form_message_dao.dart';
import 'package:field/data/dao/formtype_dao.dart';
import 'package:field/data/dao/location_dao.dart';
import 'package:field/data/dao/offline_activity_dao.dart';
import 'package:field/data/dao/project_dao.dart';
import 'package:field/data/dao/status_style_dao.dart';
import 'package:field/data/dao/sync/site/site_sync_status_form_attachment_dao.dart';
import 'package:field/data/dao/sync/site/site_sync_status_form_dao.dart';
import 'package:field/data/dao/sync/site/site_sync_status_form_type_dao.dart';
import 'package:field/data/dao/sync/site/site_sync_status_location_dao.dart';
import 'package:field/data/dao/sync/site/site_sync_status_project_dao.dart';
import 'package:field/data/dao/sync/sync_size_dao.dart';
import 'package:field/database/dao.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/utils/app_path_helper.dart';

import '../data/dao/form_status_history_dao.dart';
import '../data/dao/manage_type_dao.dart';

class DBConfig {
  static DBConfig? _instance;

  DBConfig._();

  factory DBConfig() => _instance ??= DBConfig._();
  late DatabaseManager databaseManager;



  Future<void> init() async {
    await initDataBaseManager();
    List<Dao> daoList = [
      StatusStyleListDao(),
      ProjectDao(),
      ManageTypeDao(),
      LocationDao(),
      FormMessageAttachAndAssocDao(),
      FormMessageActionDao(),
      FormMessageDao(),
      FormDao(),
      FormTypeDao(),
      FormStatusHistoryDao(),
      OfflineActivityDao(),
      SyncSizeDao()
    ];
    await createTables(daoList);
    await removeAndCreateSyncStatusTables();
  }

  Future<void> createTables(List<Dao> daoList) async {
    for (var dao in daoList) {
      try {
        databaseManager.executeTableRequest(dao.createTableQuery);
      } catch (_) {}
    }
  }

  Future<void> removeTables(List<Dao> daoList) async {
    for (var dao in daoList) {
      try {
        databaseManager.executeTableRequest(dao.dropTable);
      } catch (_) {}
    }
  }

  Future<void> removeAndCreateSyncStatusTables() async {
    List<Dao> syncStatusDioList = [
      SiteSyncStatusProjectDao(),
      SiteSyncStatusLocationDao(),
      SiteSyncStatusFormTypeDao(),
      SiteSyncStatusFormDao(),
      SiteSyncStatusFormAttachmentDao(),
    ];
    await initDataBaseManager();
    await removeTables(syncStatusDioList);
    await createTables(syncStatusDioList);
  }

  Future<void> initDataBaseManager() async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    databaseManager = DatabaseManager(path);
  }
}
