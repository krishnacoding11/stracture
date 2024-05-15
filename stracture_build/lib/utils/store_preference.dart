import 'dart:convert';

import 'package:field/bloc/userprofilesetting/user_profile_setting_offline_cubit.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/sharedpreference.dart';

import '../data/model/language_vo.dart';
import '../data/model/project_vo.dart';

class StorePreference {
  static AppConfig appConfig = di.getIt<AppConfig>();

  static getValueFromAppConfig(String key) {
    return appConfig.appConfigData!.entries.firstWhere((element) => element.key == key).value;
  }

  static setValueToAppConfig(key, value) {
    appConfig.appConfigData!.putIfAbsent(key, () => value);
  }

  static updateValueToAppConfig(key, currentValue) {
    if (appConfig.appConfigData!.containsKey(key)) {
      appConfig.appConfigData!.update(key, (value) => currentValue);
    }
  }

  //basic method of PREFERENCE UTILS
  static Future<bool> setBoolData(String key, bool value) async {
    updateValueToAppConfig(key, value);
    return PreferenceUtils.setBool(key, value);
  }

  static Future<bool> getBoolData(String key, [bool? defValue]) async {
    if (appConfig.appConfigData!.containsKey(key)) {
      return getValueFromAppConfig(key);
    } else {
      bool? stringValue = await PreferenceUtils.getBool(key);
      setValueToAppConfig(key, stringValue);
      return stringValue;
    }
  }

  static Future<bool> setStringData(String key, String value) async {
    updateValueToAppConfig(key, value);
    return PreferenceUtils.setString(key, value);
  }

  static Future<String> getStringData(String key, [String? defValue]) async {
    if (appConfig.appConfigData!.containsKey(key)) {
      return getValueFromAppConfig(key);
    } else {
      String? stringValue = await PreferenceUtils.getString(key, defValue);
      setValueToAppConfig(key, stringValue);
      return stringValue;
    }
  }

  static Future<bool> setIntData(String key, int value) async {
    updateValueToAppConfig(key, value);
    return PreferenceUtils.setInt(key, value);
  }

  static Future<int> getIntData(String key, [int? defValue]) async {
    if (appConfig.appConfigData!.containsKey(key)) {
      return getValueFromAppConfig(key);
    } else {
      int? value = await PreferenceUtils.getInt(key, defValue ?? 0);
      setValueToAppConfig(key, value);
      return value;
    }
  }

  static Future<bool> setStringListData(String key, [dynamic value]) async {
    updateValueToAppConfig(key, value);
    return PreferenceUtils.setString(key, value!);
  }

  static Future<String> getStringListData(String key, [dynamic defValue]) async {
    if (appConfig.appConfigData!.containsKey(key)) {
      return getValueFromAppConfig(key);
    } else {
      String? value = await PreferenceUtils.getString(key, defValue);
      if (value.isNotEmpty) {
        setValueToAppConfig(key, value);
      }
      return value.toString();
    }
  }

  static Future<void> setLastLocationData(String key, dynamic value) async {
    Map<String, dynamic> data = value.toJson();
    String lastLocation = jsonEncode(data);
    updateValueToAppConfig(key, data);
    await setPrefDataFromUtil(key, lastLocation);
  }

  static Future<void> setPrefDataFromUtil(String key, dynamic value) async {
    await PreferenceUtils.setString(key, value);
  }

  static Future<Map?> getPrefDataFromUtil(String key) async {
    if (appConfig.appConfigData!.containsKey(key)) {
      return getValueFromAppConfig(key);
    } else {
      Map? value = await PreferenceUtils.getPrefData(key);
      setValueToAppConfig(key, value);
      return value;
    }
  }

  static Future<bool> removeData(String key) async {
    appConfig.appConfigData!.remove(key);
    return PreferenceUtils.remove(key);
  }

  //User preference
  static Future<String?> getUserId() async {
    return (await getUserData() as User).usersessionprofile?.userID;
  }

  static Future<String?> getHashedUserId() async {
    return (await getUserData() as User).usersessionprofile?.hUserID;
  }

  static Future<String?> getUserCloud() async {
    String cloudKey = AConstants.keyCloudTypeData;
    if (appConfig.appConfigData!.containsKey(cloudKey)) {
      return getValueFromAppConfig(cloudKey);
    } else {
      String? stringValue = await getStringData(cloudKey, "1");
      setValueToAppConfig(cloudKey, stringValue);
      return stringValue;
    }
  }

  static Future<String?> getUserAsessionId() async {
    User? currUser = await getUserData();
    if (currUser != null) {
      return currUser.usersessionprofile?.aSessionId ?? "";
    }
    return "";
  }

  static Future<String?> getUserJsessionId() async {
    User? currUser = await getUserData();
    if (currUser != null) {
      // Log.d(" ==== ${currUser.usersessionprofile?.currentJSessionID}");
      return currUser.usersessionprofile?.currentJSessionID ?? "";
    }
    return "";
  }

  static Future<int> getLastAppVersion([int defaultValue = -1]) async {
    return await PreferenceUtils.getInt(AConstants.keyLastAppVersionCode, defaultValue);
  }

  static Future<bool> setLastAppVersion(int value) async {
    return await PreferenceUtils.setInt(AConstants.keyLastAppVersionCode, value);
  }

  static Future<User?> getUserData() async {
    if (appConfig.currentUser != null) {
      return appConfig.currentUser;
    } else {
      Map<String, dynamic>? json = (await PreferenceUtils.getPrefData(AConstants.keyUserData))?.cast<String, dynamic>();
      if (json == null) return null;
      var user = User.fromJson(json);
      appConfig.currentUser = user;
      return user;
    }
  }

  static Future<void> setUserData(dynamic value) async {
    Map<String, dynamic> data = value.toJson();
    String user = jsonEncode(data);
    return await setPrefDataFromUtil(AConstants.keyUserData, user);
  }

  static Future<void> setDeviceToken(dynamic value) async {
    return await setPrefDataFromUtil(AConstants.deviceToken, value);
  }

  static Future<Object> getDeviceToken() async {
    var token = AConstants.deviceToken;
    return await getStringData(token);
  }

  static Future<bool> setResendNowBool(String key, bool currentValue) async {
    return setBoolData(key, currentValue);
  }

  static Future<bool> getResendNowBool(String key, [bool? defValue]) async {
    if (appConfig.appConfigData!.containsKey(key)) {
      return getValueFromAppConfig(key);
    } else {
      bool? value = await getBoolData(key, defValue);
      setValueToAppConfig(key, value);
      return value;
    }
  }

  static Future<String?> getUserKey() async {
    try {
      var userId = await getUserId();
      var cloudId = await getUserCloud();
      return '${cloudId}_$userId';
    } catch (e) {
      Log.d(e.toString());
    }
    return null;
  }

  static Future<void> setLanguageData(String key, dynamic value) async {
    String language = jsonEncode(value);
    await setStringData(key, language);
  }

  static Future<Language?> getLanguageData(String key) async {
    String? language;
    if (appConfig.appConfigData!.containsKey(key)) {
      language = getValueFromAppConfig(key);
    } else {
      language = await getStringData(key);
      setValueToAppConfig(key, language);
    }

    if (language != null && language.isNotEmpty) {
      Map<String, dynamic> json = await jsonDecode(language);
      if (json.isNotEmpty) {
        var language = Language.fromJson(json);
        return language;
      }
    }
    return null;
  }

  //project preference
  static Future<String?> getSelectedProjectKey() async {
    var userKey = await getUserKey();
    return '${userKey}_${AConstants.keyProjectData}';
  }

  static Future<void> setSelectedProjectData(dynamic value) async {
    var projectKey = await StorePreference.getSelectedProjectKey();
    Map<String, dynamic> data = value.toJson();
    String user = jsonEncode(data);
    if (appConfig.currentSelectedProject != null) {
      appConfig.currentSelectedProject!.clear();
      appConfig.currentSelectedProject = data;
    }
    await storeHashProjectId(value);
    return await setPrefDataFromUtil(projectKey!, user);
  }

  static Future<bool> setSelectedProjectsTab(dynamic selectedValue) async {
    var projectTab = AConstants.projectsTab;
    return await setIntData(projectTab, selectedValue);
  }

  static Future<int> getSelectedProjectTab() async {
    var projectTab = AConstants.projectsTab;
    return await getIntData(projectTab, 0);
  }

  static Future<bool> setSelectedPinFilterType(dynamic value) async {
    var pinType = AConstants.selectedPinFilter;
    return await setIntData(pinType, value);
  }

  static Future<int> getSelectedPinFilterType() async {
    var pinType = AConstants.selectedPinFilter;
    return await getIntData(pinType, 0);
  }

  static void removeSelectedPinFilter() {
    String key = AConstants.selectedPinFilter;
    if (appConfig.appConfigData!.containsKey(key)) {
      appConfig.appConfigData!.remove(key);
    }
    PreferenceUtils.remove(key);
  }

  static Future<bool> setPushNotificationEnable(dynamic value) async {
    var userKey = await getUserKey();
    return await setBoolData('${userKey}_${AConstants.keyIsPushNotificationEnable}', value);
  }

  static Future<bool> getPushNotificationEnable() async {
    var userKey = await getUserKey();
    return await getBoolData('${userKey}_${AConstants.keyIsPushNotificationEnable}');
  }

  static Future<bool> setIncludeCloseOutFormFlag(dynamic value) async {
    var userKey = await getUserKey();
    return await setBoolData('${userKey}_${AConstants.keyIncludeCloseOutForm}', value);
  }

  static Future<bool> getIncludeCloseOutFormFlag() async {
    var userKey = await getUserKey();
    return await getBoolData('${userKey}_${AConstants.keyIncludeCloseOutForm}', false);
  }

  static Future<Project?> getSelectedProjectData() async {
    Map<String, dynamic>? json;
    var projectKey = await getSelectedProjectKey();
    if (appConfig.currentSelectedProject != null) {
      json = appConfig.currentSelectedProject;
    } else {
      json = (await PreferenceUtils.getPrefData(projectKey!))?.cast<String, dynamic>();
      if (json == null) {
        return null;
      } else {
        appConfig.currentSelectedProject = json;
      }
    }
    var project = Project.fromJson(json!);
    return project;
  }

  static Future<int> getDcId() async {
    var project = await StorePreference.getSelectedProjectData();
    return project?.dcId ?? 1;
  }

  static Future<bool> setLocalLanguageDateFormat(languageId, dateFormatForLanguage) async {
    String storeValue = "$languageId#$dateFormatForLanguage";
    return setStringData(AConstants.localLanguageDateFormatStorage, storeValue);
  }

  static Future<String?> getLocalLanguageDateFormat() async {
    return getStringData(AConstants.localLanguageDateFormatStorage);
  }

  static Future<bool> setUserCurrentDateFormatForLanguage(dynamic dateFormatForLanguage) async {
    return setStringData(AConstants.userCurrentDateFormat, dateFormatForLanguage);
  }

  static Future<String?> getUserCurrentDateFormatForLanguage() async {
    return getStringData(AConstants.userCurrentDateFormat);
  }

  static Future<bool> setUserCurrentLanguage(dynamic languageId) async {
    return setStringData(AConstants.userCurrentLanguage, languageId);
  }

  static Future<String?> getUserCurrentLanguage() async {
    return getStringData(AConstants.userCurrentLanguage);
  }

  static Future<void> setTemperatureUnit(String tempUnit) async {
    String key = "${await getUserKey()}_${AConstants.temperatureUnit}";
    await setStringData(key, tempUnit);
  }

  static Future<String> getTemperatureUnit() async {
    String key = "${await getUserKey()}_${AConstants.temperatureUnit}";
    String? unit = await getStringData(key);
    if (unit.isEmpty) {
      unit = "C";
    }
    return unit;
  }

  static Future<bool> setRecentLocationSearchPrefData(String key, dynamic value) async {
    return setStringData(key, value);
  }

  static Future<bool> setRecentQualitySearchPrefData(String key, dynamic value) async {
    return setStringData(key, value);
  }

  static Future<String?> getRecentLocationSearchPrefData(String key) async {
    return getStringData(key);
  }

  static Future<bool> setRecentProjectPrefData(String key, dynamic value) async {
    return setStringData(key, value);
  }

  static Future<bool> setRecentModelPrefData(String key, dynamic value) async {
    return setStringData(key, value);
  }

  static Future<String?> getRecentProjectPrefData(String key) async {
    var prefs = await getStringData(key);
    if (prefs.isNotEmpty) {
      return prefs;
    }
    return null;
  }

  static Future<String?> getRecentModelPrefData(String key) async {
    var prefs = await getStringData(key);
    if (prefs.isNotEmpty) {
      return prefs;
    }
    return null;
  }

  static Future<String?> getRecentQualityPrefData(String key) async {
    var prefs = await getStringData(key);
    if (prefs.isNotEmpty) {
      return prefs;
    }
    return null;
  }

  //Call this to remove user data on logout
  static Future<void> clearUserPreferenceData() async {
    //await removeLastLocationData();
    //await removeSelectedProjectData();
    await removeHashProjectIdMapData();
    await PreferenceUtils.remove(AConstants.recentProject);
    await PreferenceUtils.remove(AConstants.recentSearchLocation);
    await PreferenceUtils.remove(AConstants.recentForm);
    await PreferenceUtils.remove(AConstants.keyUserData);
    await PreferenceUtils.remove(AConstants.keyLoginType);
    await PreferenceUtils.remove(AConstants.keyCloudTypeData);
    await PreferenceUtils.remove(AConstants.projectsTab);
    await PreferenceUtils.remove(AConstants.workOffline);
    await PreferenceUtils.remove(AConstants.keyisLanguageChange);

    appConfig.currentUser = null;
    appConfig.appConfigData!.clear();
    appConfig.currentSelectedProject = null;
    appConfig.storedTimestamp = null;
    appConfig.isOnBoarding = true;
  }

  static Future<bool> isWorkOffline() async {
    bool isOffline = await PreferenceUtils.getBool(AConstants.workOffline);
    return isOffline;
  }

  static Future<bool> isImageCompressionEnabled() async {
    return await PreferenceUtils.getBool("imageCompression");
  }

  static Future<bool> isSyncOnMobileDataEnabled() async {
    return await PreferenceUtils.getBool("syncOnMobileData");
  }

  static Future<bool> isIncludeAttachmentsSyncEnabled() async {
    return !await PreferenceUtils.getBool("includeAttachments");
  }

  static Future<bool> isIncludeAssociationsSyncEnabled() async {
    return await PreferenceUtils.getBool("includeAssociations");
  }

  static Future<bool> isIncludeSubLocationDataSyncEnabled() async {
    return await PreferenceUtils.getBool("includeSubLocationData");
  }

  static Future<bool> isIncludeClosedOutTasksSyncEnabled() async {
    return await PreferenceUtils.getBool("includeClosedOutTasks");
  }

  static Future<SyncDateRange> getSelectedDateRangeSync() async {
    int temp = await PreferenceUtils.getInt("selectedDateRange", 2);
    return SyncDateRange.values[temp];
  }

  static Future<bool> isIncludeLogsEnable() async {
    return await PreferenceUtils.getBool("includeLogs");
  }

  static Future<bool> setLoggerUserASessionId(String value) async {
    String logSessionId = AConstants.logSessionId;
    return await PreferenceUtils.setString(logSessionId, value);
  }

  static Future<bool> setProjectGeoTagSettings(String value) async {
    String geoTagEnabled = AConstants.keyGeoTagEnabled;
    return await PreferenceUtils.setString(geoTagEnabled, value);
  }

  static Future<String> getProjectGeoTagSettings() async {
    String geoTagEnabled = AConstants.keyGeoTagEnabled;
    return PreferenceUtils.getString(geoTagEnabled, "false");
  }

  static Future<String?> getLoggerUserASessionId() async {
    String logSessionId = AConstants.logSessionId;
    return PreferenceUtils.getString(logSessionId);
  }

  static Future<void> removeLoggerUserASessionId() async {
    String logSessionId = AConstants.logSessionId;
    await removeData(logSessionId);
  }

  static Future<void> storeHashProjectId(Project project) async {
    var projectKey = await StorePreference.getSelectedProjectKey();
    if (projectKey != null && project.projectID.toString().isHashValue()) {
      projectKey = projectKey + "_Hash";
      Map mapData = await getPrefDataFromUtil(projectKey) ?? {};
      mapData[project.projectID.plainValue()] = project.projectID;
      String jsonData = jsonEncode(mapData);
      return await setPrefDataFromUtil(projectKey, jsonData);
    }
  }

  /// get Project id with Hash value.
  /// Calling this method in online mode only and have project id is plain value.
  static Future<String> getHashProjectId(Project project) async {
    var projectKey = await StorePreference.getSelectedProjectKey();
    if (projectKey != null) {
      String projectIdPlain = project.projectID.plainValue();
      projectKey = projectKey + "_Hash";
      Map mapData = await getPrefDataFromUtil(projectKey) ?? {};
      if (mapData.isNotEmpty && mapData.containsKey(projectIdPlain)) {
        return mapData[projectIdPlain];
      }
    }
    return "";
  }

  static Future<void> removeHashProjectIdMapData() async {
    var projectKey = await StorePreference.getSelectedProjectKey();
    if (projectKey != null) {
      projectKey = projectKey + "_Hash";
      await PreferenceUtils.remove(projectKey);
    }
  }

  /// set ProjectId hash value if It's plain value.
  static Future<void> checkAndSetSelectedProjectIdHash() async {
    Project? project = await StorePreference.getSelectedProjectData();
    if (project != null && !project.projectID.toString().isHashValue()) {
      String projectIdHash = await StorePreference.getHashProjectId(project);
      if (projectIdHash.isNotEmpty) {
        project.projectID = projectIdHash;
        await StorePreference.setSelectedProjectData(project);
      }
    }
  }
}
