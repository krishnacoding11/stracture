import 'package:field/database/db_manager.dart';
import 'package:field/utils/app_path_helper.dart';

import '../../data/model/user_vo.dart';
import '../../database/dao.dart';
import '../../utils/store_preference.dart';

abstract class BaseLocalDataSource {
  late DatabaseManager databaseManager;

  init() async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    databaseManager = DatabaseManager(path);
  }

  void createTables(List<Dao> daoList) {
    for (var dao in daoList) {
      databaseManager.executeTableRequest(dao.createTableQuery);
    }
  }

  void removeTables(List<Dao> daoList) {
    for (var dao in daoList) {
      databaseManager.executeTableRequest(dao.dropTable);
    }
  }

  Future<User?> get user async => await StorePreference.getUserData();

  Future<String?> get currentUserId async => await StorePreference.getUserId();
}
