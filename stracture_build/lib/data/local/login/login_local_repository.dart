import 'dart:convert';
import 'dart:io' as io;

import 'package:field/data/dao/login_dao.dart';
import 'package:field/data/dao/url_dao.dart';
import 'package:field/data/local/local_repository.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/constants.dart';

import '../../../utils/store_preference.dart';
import '../../../utils/url_config.dart';
import '../../repository/login_repository.dart';

class LogInLocalRepository extends LogInRepository with LocalRepository<User> {
  LogInLocalRepository();

  final dao = LoginDao();
  final urlDao = UrlDao();

  @override
  Future<User> delete(User note) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<List<User>> getData() async {
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userDbFile}");
    final userList = db.executeSelectFromTable(dao.tableName, "SELECT * FROM ${dao.tableName} ORDER BY ${dao.fieldTimeStamp} DESC;");
    List<User> tmpList = [];
    for (var element in userList) {
      tmpList.add(User.fromJson(jsonDecode(element[dao.fieldUserLoginJson])));
    }
    return tmpList;
  }

  @override
  Future<User> insert(User user) async {
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userDbFile}");

    try {
      List<Map<String, dynamic>> rowList = List.filled(1, await dao.toMap(user));
      await db.executeDatabaseBulkOperations(dao.tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
    return user;
  }

  @override
  Future<User> update(User user) async {
    return await insert(user);
  }

  @override
  Future<void> create() async {
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userDbFile}");

    try {
      db.executeTableRequest(dao.createTableQuery);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  @override
  Future<Result?> doLogin(Map<String, dynamic> request) {
    // TODO: implement doLogin
    throw UnimplementedError();
  }

  void insertLogin(User user) async {
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userDbFile}");

    try {
      await db.executeTableRequest(dao.createTableQuery);
      List<Map<String, dynamic>> rowList = List.filled(1, await dao.toMap(user));
      await db.executeDatabaseBulkOperations(dao.tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  Future<void> insertDcWiseUrl(String value) async {
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userDbFile}");
    List<Map<String, dynamic>> temp = await urlDao.toMapList(value);
    try {
      await db.executeTableRequest(urlDao.createTableQuery);
      await db.executeTableRequest(urlDao.deleteDataQuery);
      await db.executeDatabaseBulkOperations(urlDao.tableName, temp);
    } on Exception catch (e) {
      Log.d(e);
    }
  }

  @override
  Future? getUserSSODetails(Map<String, dynamic> request) {
    // TODO: implement getUserSSODetails
    throw UnimplementedError();
  }

  @override
  Future? login2FA(Map<String, dynamic> request) {
    // TODO: implement login2FA
    throw UnimplementedError();
  }

  //Fetch user from database if exist
  Future<List<User>> getExistingUser() async {
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userDbFile}");
    final userList = db.executeSelectFromTable(dao.tableName, "SELECT * FROM ${dao.tableName} WHERE ${dao.fieldIsActiveUser} = 1 ORDER BY ${dao.fieldTimeStamp} DESC LIMIT ${AConstants.userAccountLimit};");
    List<User> tmpList = [];
    for (var element in userList) {
      // jsonDecode(element['User_Login_Json']);
      User user = User.fromJson(jsonDecode(element[dao.fieldUserLoginJson]));
      var userCloud = int.parse(user.usersessionprofile!.userCloud);
      var dcId = await StorePreference.getDcId();
      var urlConfig = URLConfig(userCloud, AConstants.buildEnvironment, dcId);
      user.setBaseUrl = await urlConfig.getAdoddleUrl();
      String path = await AppPathHelper().getUserDatabasePath();
      final imagePath = "$path/${user.usersessionprofile?.userCloud}_${user.usersessionprofile?.userID}/${AConstants.userProfile}";
      if (io.File(imagePath).existsSync()) {
        user.userImageUrl = imagePath;
      }
      tmpList.add(user);
    }
    return tmpList;
  }

  //Fetch user from database if exist
  Future<void> clearAllAccountPreference() async {
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userDbFile}");
    await db.executeTableRequest("UPDATE ${dao.tableName} SET ${dao.fieldIsActiveUser} = 0");
  }

  Future<void> updateAcceptTermAndCondition(String user, String userId) async {
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userDbFile}");
    await db.executeTableRequest("UPDATE ${dao.tableName} SET ${dao.fieldUserLoginJson} = '$user' WHERE ${dao.fieldUserID} = '$userId'");
  }
}
