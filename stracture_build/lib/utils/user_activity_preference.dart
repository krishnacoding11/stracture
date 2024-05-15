import 'dart:convert';

import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/site_location.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';

import 'utils.dart';

const String keyLastLocation = "LastLocation";
const String locationFolderName = "location";
const String thumbFolderName = "Thumb"; // FolderName For Saving Thumbnail of plan
const String recentSearchSiteTaskList = "recentSearchSiteTaskList"; /// Site Tab
const String recentSearchTaskList = "recentSearchTaskList"; /// Task Tab

Future<String> getKeyName(String keyName) async {
  return "${await StorePreference.getUserCloud()}_${await StorePreference.getUserId()}_$keyName";
}

Future<String> getLastLocationKeyName() async {
  Project? project = await StorePreference.getSelectedProjectData();
  if (project != null) {
    return "${await StorePreference.getUserKey()}_${project.projectID?.plainValue()}_$keyLastLocation";
  }
  return "";
}

Future<void> setLastLocationData(dynamic value) async {
  String keyName = await getLastLocationKeyName();
  await StorePreference.setLastLocationData(keyName, value);
}

Future<String?> getLastLocationThumbPath() async {
  Project? project = await StorePreference.getSelectedProjectData();
  SiteLocation? location = await getLastLocationData();
  if (project != null && location != null) {
    String strProjectId = project.projectID?.plainValue() ?? "";
    String strDocId = location.pfLocationTreeDetail?.docId?.plainValue();
    String strRevId = location.pfLocationTreeDetail?.revisionId?.plainValue();
    if (!strDocId.isNullOrEmpty() &&
        strDocId != "0" &&
        !strRevId.isNullOrEmpty() &&
        strRevId != "0") {
      String? path =
      await Utility.getAppDirPath(path: "$thumbFolderName/$strDocId");
      if (path != null) {
        return "$path/${strProjectId}_$strRevId.jpeg";
      }
    }
  }
  return null;
}

Future<SiteLocation?> getLastLocationData() async {
  Project? project = await StorePreference.getSelectedProjectData();
  if (project == null) {
    return null;
  }
  String keyName = await getLastLocationKeyName();
  Map<String, dynamic>? json =
  (await StorePreference.getPrefDataFromUtil(keyName))?.cast<String, dynamic>();
  if (json == null) return null;
  SiteLocation siteLocation = SiteLocation.fromJson(json);
  if (siteLocation.projectId.plainValue() == project.projectID.plainValue()) {
    return siteLocation;
  }
  return null;
}

Future<void> removeSelectedProjectData() async {
  var projectKey = await StorePreference.getSelectedProjectKey();
  await StorePreference.removeData(projectKey!);
}

Future<void> removeLastLocationData() async {
  String keyName = await getLastLocationKeyName();
  await StorePreference.removeData(keyName);
}

Future<void> setRecentSearchSiteTaskListData(List<String> value) async {
  String keyName = await getKeyName(recentSearchSiteTaskList);
  await StorePreference.setStringListData(keyName, jsonEncode(value));
}

Future<List<String>> getRecentSearchSiteTaskListData() async {
  String keyName = await getKeyName(recentSearchSiteTaskList);
  String list = await StorePreference.getStringListData(keyName);
  if (list.isNotEmpty) {
    final recentList = jsonDecode(list) as List<dynamic>;
    return recentList.cast<String>();
  }
  return [];
}

Future<String> getCurrentProjectId() async {
  Project? temp = await StorePreference.getSelectedProjectData();
  return temp?.projectID ?? "";
}

Future<void> setRecentSearchTaskListData(List<String> value) async {
  String keyName = await getKeyName(recentSearchTaskList);
  StorePreference.setStringListData(keyName, jsonEncode(value));
}

Future<List<String>> getRecentSearchTaskListData() async {
  String keyName = await getKeyName(recentSearchTaskList);
  String list = await StorePreference.getStringListData(keyName);
  if (list.isNotEmpty) {
    final recentList = jsonDecode(list) as List<dynamic>;
    return recentList.cast<String>();
  }
  return [];
}

