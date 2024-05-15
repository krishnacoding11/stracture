import 'package:field/analytics/service_analytics.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';


enum FireBaseScreenName {
  login(0, "Login"),
  twoFA(1, "Two Factor Authentication"),
  project(2, "Project List"),
  setting(3, "Settings"),
  home(4,"Home Screen"),
  quality(5,"Quality List"),
  menu(6, "Menu"),
  locationTree(7, "Location Tree"),
  taskList(8, "Task List"),
  twoDPlan(9, "Site 2D Plan"),
  siteFormListingSearch(10, "Site Form List");

  const FireBaseScreenName(this.type, this.value);

  final int type;
  final String value;
}


enum FireBaseFromScreen {
  login(0,"Login"),
  homePage(1, "Home Screen"),
  qrcode(2,"QR Code"),
  projectListing(3,"Project List"),
  quality(4,"Quality List"),
  settings(5, "Settings"),
  headerShortcut(6,"Header Shortcut"),
  twoFA(7, "Two Factor Authentication"),
  locationTree(8, "Location Tree"),
  twoDPlan(9, "Site 2D Plan"),
  taskList(10, "Task List"),
  siteFormListingSearch(12, "Site Form List"),
  settingLanguage(13, "Setting Language"),
  settingChangePassword(14, "Setting Change Password"),
  settingModelSetting(15, "Setting Model Setting");

  const FireBaseFromScreen(this.type, this.value);

  final int type;
  final String value;
}


enum FireBaseEventType {
  login(0, "Logged_In"),
  fView(1, "View_Form"),
  searchText(2,"Project_Search"),
  sort(3,"Sorting"),
  logOut(4,"Logout"),
  createSiteForm(5,"Create_Site_Form"),
  changeProject(6,"Select_Project"),
  jumpToLastLocation(7,"Jump_Back_To_Location"),
  shortcutMenu(8,"Task_Shortcut"),
  newTasks(9,"New_Tasks"),
  taskDueToday(10,"Task_Due_Today"),
  taskDueThisWeek(11,"Task_Due_This_Week"),
  overDueTasks(12,"Overdue_Tasks"),
  saveForm(13,"Save_Form"),
  writeLog(14,"Write_Log_On/Off"),
  uploadLogs(15,"Upload_Logs"),
  saveAvatar(16,"Save_Avatar"),
  includeClosedOutForm(17,"Include_Closed_Out_Forms_On/Off"),
  notifications(18,"Notification_On/Off"),
  workOnline(19,"Work_Online"),
  workOffline(20,"Work_Offline"),
  favoriteProject(21, "Star_Favourite"),
  sso(22, "SSO"),
  signIn(23, "Sing_In"),
  forgotPassword(24, "Forgot_Password"),
  resetPassword(25, "Reset_Password"),
  editProfile(26, "Edit _Profile"),
  languageChange(27, "Language_Change"),
  changePasswordSave(28, "Change_Password_Save"),
  settingNavigationSensitiveChanged(29, "Setting_Navigation_Sensitive_Changed"),
  selectLocation(30, "Select_Location"),
  locationTreeSearch(31, "Search"),
  locationTreeSelectAll(32, "Select_All"),
  locationTreeMarkOfflineSelect(33, "Mark_Offline_Select"),
  locationTreeDeleteClick(34, "Delete_Click"),
  locationTreeBreadCrumbsClick(35, "Bread_Crumbs_Click"),
  siteListingDrawerToggle(36, "Site_Listing_Drawer_Toggle"),
  qualityPlanSelect(37, "Plan_Select"),
  qualityLocationActivityToggle(38, "Location_Activity_Toggle"),
  qualityLocationNavigation(39, "Location_Navigation"),
  qualityActivityClick(40, "Activity_Click"),
  qualityBreadCrumbsNavigation(41, "Bread_Crumbs_Navigation"),
  qualityViewRefreshClick(42, "View_Refresh_Click"),
  qualityViewTwoDPlanNavigation(43, "View_2D_Plan_Navigation"),
  taskListingSelect(44, "Select"),
  taskListingFilterSave(45, "Listing_Filter_Save"),
  qrScan(46, "QR_Scan"),
  syncOfflineData(47, "Sync_Offline_Data"),
  createSiteTask(48, "Create_SiteTask"),
  filterApply(49, "Filter_Apply"),
  filterTaskOverdue(50, "Filter_Task_Overdue"),
  filterComplete(51, "Filter_Complete"),
  filterCreatedDateApply(52, "Filter_Created_Date_Apply"),
  filterFormTypeSelect(53, "Filter_Form_Type_Select"),
  filterOriginatorSelect(54, "Filter_Originator_Select"),
  filterOriginatorOrgSelect(55, "Filter_Originator_Org_Select"),
  filterRecipientSelect(56, "Filter_Recipient_Select"),
  filterRecipientOrgSelect(57, "Filter_Recipient_Org_Select"),
  filterStatusSelect(58, "Filter_Status_Select"),
  filterTaskStatusSelect(60, "Filter_Task_Status_Select"),
  createForm(65, "Create_Form"),
  editShortcut(66, "Edit_Shortcut"),
  filterFormsShortcut(67, "Filter_Forms_Shortcut"),
  shortcutsDrag(68, "Shortcuts_Drag");

  const FireBaseEventType(this.type, this.value);

  final int type;
  final String value;
}

Future<String> getCurrentProjectName() async {
  String projectName = "---";
  Project? project = await StorePreference.getSelectedProjectData();
  if(project != null) {
    projectName = "${project.projectName ?? ""} (${project.projectID.plainValue})";
  }
  return projectName;
}
Future<String> getUserId() async {
  String projectName = "---";
  Project? project = await StorePreference.getSelectedProjectData();
  if(project != null) {
    projectName = "${project.projectName ?? ""} (${project.projectID.plainValue})";
  }
  return projectName;
}


Future<String> getCurrentUserName() async {
  String userName = "Normal User";
  User? user = await StorePreference.getUserData();
  if (user != null) {
    userName = "${user.usersessionprofile!.screenName!} (${user.usersessionprofile?.hUserID.plainValue()})";
  }
  return userName;
}
Future<String> getUserOrganization() async {
  String orgName = "N/A";
  User? user = await StorePreference.getUserData();
  orgName = user?.usersessionprofile?.tpdOrgName?.plainValue() ?? "N/A";
  return orgName;
}


class FireBaseEventAnalytics{
  static setEvent(FireBaseEventType obj, FireBaseFromScreen fromScreen,{bool bIncludeProjectName = false}) async{
    if(obj.value.isNotEmpty) {
      var parameters = <String, dynamic>{
        'from': fromScreen.value,
        'user': await getCurrentUserName(),
        'organization': await getUserOrganization()
      };

      if (bIncludeProjectName == true) {
        parameters['project'] = await getCurrentProjectName();
      }
      String screenName = "";
      if(fromScreen.value.isNotEmpty) {
        screenName = fromScreen.value.replaceAll(" ", "_");
      }
      await ServiceAnalytics.fireEvent("${screenName}_${obj.value}", parameters);
    }
  }
  static setLogin()async{
    await ServiceAnalytics.doLogin();
  }

  static setCurrentScreen(String screenName) async{
    await ServiceAnalytics.fireCurrentScreen(screenName);
  }
  static setUserProperties()async{
    User? user = await StorePreference.getUserData();
    Map<String,dynamic> map = {};
    map["name"] = user?.usersessionprofile?.screenName ?? "Guest";
    map["userId"] = user?.usersessionprofile?.hUserID.plainValue() ?? "0";
    map["organisaton"] = user?.usersessionprofile?.tpdOrgName ?? "";
    await ServiceAnalytics.fireUserProperties(map);
    await ServiceAnalytics.doLogin();
  }
}