import 'package:field/data/model/site_location.dart';
import 'package:field/utils/sharedpreference.dart';
import 'package:field/utils/store_preference.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:field/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/mock_method_channel.dart';
import '../fixtures/appconfig_test_data.dart';
import '../fixtures/fixture_reader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  MockMethodChannel().setAsitePluginsMethodChannel();
  AppConfigTestData().setupAppConfigTestData();
  SharedPreferences.setMockInitialValues(
      {"userData": fixture("user_data.json")});

  //basic method of PREFERENCE UTILS
  test('set Data String Data', () async {
    // ignore: non_constant_identifier_names
    bool StringValue = await StorePreference.setStringData(
        "cloud_type_data", "2");
    expect(true, StringValue);
  });
  test('get String Data', () async {
    // ignore: non_constant_identifier_names
    String StringValue = await StorePreference.getStringData("cloud_type_data");
    expect(true, StringValue == "2");
  });

  test('set String List Data', () async {
    bool stringListValue = await StorePreference.setStringListData(
        "cloud_type_data", '["abed", "dart"]');
    expect(true, stringListValue);
  });
  test('get String List Data', () async {
    String stringListValue = await StorePreference.getStringListData(
        "cloud_type_data");
    expect(true, stringListValue == '["abed", "dart"]');
  });
  test('set Last Location Data', () async {
    List<SiteLocation>? locations = SiteLocation.jsonToList(fixture("site_location.json"));
    await StorePreference.setLastLocationData("_2017529_2089700_LastLocation", locations![0]);
  });
  test('set Int Data', () async {
    bool boolValue = await StorePreference.setIntData("login_type", 2);
    expect(true, boolValue);
  });

  test('get Int Data', () async {
    final boolValue = await StorePreference.getIntData("login_type");
    if(boolValue.runtimeType == int){
      expect(2, boolValue);
    } else {
      String decryptValue = await PreferenceUtils.decryptGetValue(boolValue);
      expect(true, decryptValue == "2");
    }
  });

  group("Bool Data Testing", () {
    test('set Bool Data', () async {
      bool boolValue = await StorePreference.setBoolData("resendEnabled", false);
      expect(true, boolValue);
    });
    test('get Bool Data', () async {
      bool getboolValue = await StorePreference.getBoolData("resendEnabled");
      expect(true, getboolValue == false);
    });
    test('set Resend Now Bool', () async {
      bool resendBoolValue = await StorePreference.setResendNowBool(
          "resendEnabled", false);
      expect(true, resendBoolValue);
    });
    test('get Resend Now Bool', () async {
      bool enableBoolValue = await StorePreference.getResendNowBool("resendEnabled");
      expect(true, enableBoolValue == false);
    });
    test('get Resend Now Bool', () async {
      bool keyValue = await StorePreference.getResendNowBool("key");
      expect(true, keyValue == false);
    });
  });
  test('get User Asession Id', () async {
    dynamic userAsession = await StorePreference.getUserAsessionId();
    expect(true, userAsession == "kAkpCyCs0jovoiNDntPqDhIjG9l729fBH6gwoXVWVQw=");
  });
  test('get User Jsession Id', () async {
    dynamic userJsession = await StorePreference.getUserJsessionId();
    expect(true, userJsession == "LyX79RHUx8YMrAHpQ1F_dVo8QkmmsfxWGEiC1aCi.Portal");
  });
  test('set Last App Version', () async {
    // ignore: non_constant_identifier_names
    bool LastVersion = await StorePreference.setLastAppVersion(1);
    expect(LastVersion, true);
  });
  test('get Last App Version', () async {
    int lastApp = await StorePreference.getLastAppVersion(1);
    expect(lastApp == 1, true);
  });
  test('set Selected Projects Tab', () async {
    dynamic projectsTab = await StorePreference.setSelectedProjectsTab(3);
    expect(projectsTab, true);
  });
  test('get Selected Project Tab', () async {
    dynamic projectsTab = await StorePreference.setSelectedProjectsTab(3);
    expect(projectsTab == 3, false);
  });
  test('set Recent Project Pref Data', () async {
    dynamic recentPrefData = await StorePreference.setRecentProjectPrefData("recentProject", "true");
    expect(recentPrefData, true);
  });
  test('get Recent Project Pref Data', () async {
    dynamic recentPrefData = await StorePreference.getRecentProjectPrefData("recentProject");
    expect(recentPrefData == true, false);
  });
  test('set Recent Model Pref Data', () async {
    dynamic recentModelPrefData = await StorePreference.setRecentModelPrefData("recentModel", "true");
    expect(recentModelPrefData,true);
  });
  test('get Recent Model Pref Data', () async {
    dynamic recentModelPrefData = await StorePreference.getRecentModelPrefData("recentModel");
    expect(recentModelPrefData == "true", true);
  });
  test('set Local Language Date Format', () async {
    dynamic localLanguageDateFormate = await StorePreference.setLocalLanguageDateFormat("languageId", "dateFormatForLanguage");
    expect(localLanguageDateFormate,true);
  });
  test('getLocalLanguageDateFormate', () async {
    dynamic localLanguageDateFormate = await StorePreference.getLocalLanguageDateFormat();
    expect(localLanguageDateFormate == "languageId", false);
  });
  test('set Recent Location Search Pref Data', () async {
    dynamic recentLocationPrefData = await StorePreference.setRecentLocationSearchPrefData("recentSearchLocation", "true");
    expect(recentLocationPrefData, true);
  });
  test('get Recent Location Search Pref Data', () async {
    dynamic recentLocationPrefData = await StorePreference.getRecentLocationSearchPrefData("recentSearchLocation");
    expect(recentLocationPrefData == "true", true);
  });
  test('setRecentQualitySearchPrefData', () async {
    dynamic recentQualitySearchData = await StorePreference.setRecentQualitySearchPrefData("recentSearchQualityPlan", "true");
    expect(recentQualitySearchData, true);
  });
  test('get Recent Quality Pref Data', () async {
    dynamic recentQualityPrefData = await StorePreference.getRecentQualityPrefData("recentSearchQualityPlan");
    expect(recentQualityPrefData == "true", true);
  });
  test('set User Current Date Format For Language', () async {
    dynamic userCurrentDateFormateLanguage = await StorePreference.setUserCurrentDateFormatForLanguage("true");
    expect(userCurrentDateFormateLanguage, true);
  });
  test('get User Current Date Format For Language', () async {
    dynamic userCurrentDateFormateLanguage = await StorePreference.getUserCurrentDateFormatForLanguage();
    expect(userCurrentDateFormateLanguage == "true", true);
  });
  test('set User Current Language', () async {
    dynamic userCurrentLanguage = await StorePreference.setUserCurrentLanguage("languageId");
    expect(userCurrentLanguage, true);
  });
  test('get User Current Language', () {
    dynamic userCurrentLanguage = StorePreference.getUserCurrentLanguage();
    expect(userCurrentLanguage == "languageId", false);
  });
  test('get Selected Project Key', () {
    dynamic projectKey = StorePreference.getSelectedProjectKey();
    expect(projectKey == "2", false);
   });
  test('remove Data', () {
    dynamic removeData = StorePreference.removeData("cloud_type_data");
    expect(removeData == "cloud_type_data", false);
  });
  test('get Hashed User Id', () {
    dynamic hashedUserId = StorePreference.getHashedUserId();
    expect(hashedUserId == "2", false);
  });
  test('is Image Compression Enabled', () {
    dynamic imageCompressionEnabled = StorePreference.isImageCompressionEnabled();
    expect(imageCompressionEnabled == true, false);
  });
  test('is Sync On Mobile Data Enabled', () {
    dynamic mobileDataEnabled = StorePreference.isSyncOnMobileDataEnabled();
    expect(mobileDataEnabled == true, false);
  });
  test('is Include Associations Sync Enabled', () {
    dynamic associationSyncEnabled = StorePreference.isIncludeAssociationsSyncEnabled();
    expect(associationSyncEnabled == true, false);
  });
  test('is Include Sub Location Data Sync Enabled', () {
    dynamic dataSyncEnabled = StorePreference.isIncludeSubLocationDataSyncEnabled();
    expect(dataSyncEnabled == true, false);
  });
  test('is Include Closed Out Tasks Sync Enabled', () {
    dynamic tasksSyncEnabled = StorePreference.isIncludeClosedOutTasksSyncEnabled();
    expect(tasksSyncEnabled == true, false);
  });
}