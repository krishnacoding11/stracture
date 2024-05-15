import 'dart:convert';

import 'package:field/data/dao/login_dao.dart';
import 'package:field/data/model/user_profile_setting_vo.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/data/repository/userprofilesetting/userprofilesetting_repository.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';

class UserProfileSettingLocalRepository extends UserProfileSettingRepository {
  UserProfileSettingLocalRepository();

  @override
  Future<Result> acceptTermOfUse(Map<String, dynamic> request) async{
    return FAIL("", -1);
  }

  @override
  Future<Result> getUserProfileSetting(Map<String, dynamic> request) async{
    //return FAIL("", -1);
    final dao = LoginDao();
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userDbFile}");
    final userList = db.executeSelectFromTable(dao.tableName,
        "SELECT * FROM ${dao.tableName} WHERE ${dao.fieldIsActiveUser} = 1 ORDER BY ${dao.fieldTimeStamp} DESC LIMIT ${AConstants.userAccountLimit};");
    User usr =  User.fromJson(jsonDecode(userList.first[dao.fieldUserLoginJson])) ;
    var jsonString = jsonEncode(usr.usersessionprofile);
    UserProfileSettingVo user = UserProfileSettingVo.fromJson(jsonString);
    return SUCCESS(user, null, null);
  }

  @override
  Future<Result> getUserWithSubscription(Map<String, dynamic> request) async{
    return FAIL("", -1);
  }

  @override
  Future<Result> updateLanguage(Map<String, dynamic> request) async{
    return FAIL("", -1);
  }

  @override
  Future<Result> updateUserProfileSetting(UserProfileSettingVo userProfileSetting, {String? imagePath}) async{
    return FAIL("", -1);
  }

  @override
  Future<List<int>>? downloadUserImage(String? imageUrl, Map<String, dynamic>? header) {
    return null;
  }

  @override
  Future<Result?> doLogin(Map<String, dynamic> request) async {
    return null;
  }

  @override
  Future<Result?> doLogout() async {
    return null;
  }

  @override
  Future<Result> uploadSyncFile(Map<String, dynamic> request) {
    // TODO: implement uploadSyncFile
    throw UnimplementedError();
  }
}