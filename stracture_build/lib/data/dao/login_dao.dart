import 'dart:convert';

import 'package:field/data/model/user_vo.dart';
import 'package:field/database/dao.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/store_preference.dart';

import '../../logger/logger.dart';

class LoginDao extends Dao<User> {
  final tableName = 'UserLoginDataTbl';

  final fieldUserID = 'UserID';
  final fieldUserEmailid = 'User_emailid';
  final fieldUserFName = 'User_FName';
  final fieldUserLName = 'User_LName';
  final fieldUserName = 'User_Name';
  final fieldUserPassword = 'User_Password';
  final fieldSessionid = 'Sessionid';
  final fieldUserLoginJson = 'User_Login_Json';
  final fieldIsLastLogin = 'Is_Last_Login';
  final fieldUserCloud = 'UserCloud';
  final fieldLoginType = 'LoginType';
  final fieldTimeStamp = 'TimeStamp';
  final fieldIsActiveUser = 'IsActiveUser';

  String get fields => "$fieldUserID TEXT NOT NULL,"
      "$fieldUserEmailid TEXT NOT NULL,"
      "$fieldUserFName TEXT NOT NULL,"
      "$fieldUserLName TEXT,"
      "$fieldUserName TEXT NOT NULL,"
      "$fieldUserPassword TEXT,"
      "$fieldSessionid TEXT NOT NULL,"
      "$fieldUserLoginJson TEXT NOT NULL,"
      "$fieldIsLastLogin TEXT,"
      "$fieldUserCloud TEXT NOT NULL DEFAULT '1',"
      "$fieldLoginType INTEGER NOT NULL DEFAULT 1,"
      "$fieldTimeStamp TEXT NOT NULL,"
      "$fieldIsActiveUser INTEGER NOT NULL DEFAULT 0,";

  String get primaryKeys => "PRIMARY KEY($fieldUserID)";

  @override
  String get createTableQuery =>
      "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  String get getTableName => tableName;

  @override
  List<User> fromList(List<Map<String, dynamic>> query) {
    throw UnimplementedError();
  }

  @override
  fromMap(Map<String, dynamic> query) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> toMap(User user) async {
    int loginType = await StorePreference.getIntData(AConstants.keyLoginType, 1);
    String userCloud = await StorePreference.getStringData(AConstants.keyCloudTypeData, "1");

    user.usersessionprofile!.loginType = loginType;
    user.usersessionprofile!.userCloud = userCloud;
    Log.d("User session data ==>${user.usersessionprofile!.loginType}");

    return {
      fieldUserID: user.usersessionprofile!.userID,
      fieldUserEmailid: user.usersessionprofile!.email,
      fieldUserFName: user.usersessionprofile!.firstName,
      fieldUserLName: user.usersessionprofile!.lastName,
      fieldUserName: user.usersessionprofile!.screenName,
      fieldUserPassword: user.usersessionprofile!.email,
      fieldSessionid: user.usersessionprofile!.aSessionId,
      fieldUserLoginJson: jsonEncode(user.toJson()),
      fieldIsLastLogin: "1",
      fieldUserCloud: userCloud,
      fieldLoginType: loginType,
      fieldTimeStamp: user.loginTimeStamp,
      fieldIsActiveUser: 1,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<User> objects) {
    // TODO: implement toListMap
    throw UnimplementedError();
  }
}
