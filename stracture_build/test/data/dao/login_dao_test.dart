import 'dart:convert';

import 'package:field/data/dao/login_dao.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/store_preference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../bloc/mock_method_channel.dart';
import '../../fixtures/appconfig_test_data.dart';
import '../../fixtures/fixture_reader.dart';

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setAsitePluginsMethodChannel();
  AppConfigTestData().setupAppConfigTestData();
  SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json")});

  test('Test table creation query', () {
    final dao = LoginDao();
    expect(
      dao.createTableQuery,
      equals('CREATE TABLE IF NOT EXISTS UserLoginDataTbl('
          'UserID TEXT NOT NULL,'
          'User_emailid TEXT NOT NULL,'
          'User_FName TEXT NOT NULL,'
          'User_LName TEXT,'
          'User_Name TEXT NOT NULL,'
          'User_Password TEXT,'
          'Sessionid TEXT NOT NULL,'
          'User_Login_Json TEXT NOT NULL,'
          'Is_Last_Login TEXT,'
          'UserCloud TEXT NOT NULL DEFAULT \'1\','
          'LoginType INTEGER NOT NULL DEFAULT 1,'
          'TimeStamp TEXT NOT NULL,'
          'IsActiveUser INTEGER NOT NULL DEFAULT 0,'
          'PRIMARY KEY(UserID))'),
    );
  });

  test('Primary Keys', () {
    final dao = LoginDao();
    expect(dao.primaryKeys, contains(dao.fieldUserID));
  });

  test('Test Table Name', () {
    final dao = LoginDao();
    expect(dao.tableName, contains(dao.getTableName));
  });

  test('Test toMap with valid user data', () async {
    final dao = LoginDao();
    final user = User.fromJson(jsonDecode(fixture('user_data.json')));
    final map = await dao.toMap(user);

    expect(map, containsPair('UserID', user.usersessionprofile!.userID));
    expect(map, containsPair('User_emailid', user.usersessionprofile!.email));
  });

  test('Test fromList with missing user data', () {
    final dao = LoginDao();
    final emptyList = <Map<String, dynamic>>[];

    try {
      final userList = dao.fromList(emptyList);
      expect(userList, isEmpty);
    } catch (e) {
      expect(e, isUnimplementedError);
    }
  });

  test('Test toMap with different login type and user cloud', () async {
    final dao = LoginDao();
    final user = User.fromJson(jsonDecode(fixture('user_data.json')));
    await StorePreference.setIntData(AConstants.keyLoginType, 2);
    await StorePreference.setStringData(AConstants.keyCloudTypeData, "2");

    final map = await dao.toMap(user);

    expect(map, containsPair('LoginType', 2));
    expect(map, containsPair('UserCloud', '2'));
  });

  test('Test fromMap with missing user data', () {
    final dao = LoginDao();
    final Map<String,dynamic>emptyMap = {};

    try {
      final userList = dao.fromMap(emptyMap);
      expect(userList, isEmpty);
    } catch (e) {
      expect(e, isUnimplementedError);
    }
  });

  test('Test toListMap with missing user data', () {
    final dao = LoginDao();
    final emptyList = <User>[];

    try {
      final userList = dao.toListMap(emptyList);
      expect(userList, isEmpty);
    } catch (e) {
      expect(e, isUnimplementedError);
    }
  });

}