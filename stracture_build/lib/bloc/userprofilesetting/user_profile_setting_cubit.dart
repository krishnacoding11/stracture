import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:dio/dio.dart';
import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_state.dart';
import 'package:field/data/model/get_user_with_subscription_vo.dart';
import 'package:field/data/model/language_vo.dart';
import 'package:field/data/model/user_profile_setting_vo.dart';
import 'package:field/data/remote/login/login_repository_impl.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/file_out_put.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/managers/routes_manager.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/file_utils.dart';
import 'package:field/utils/global.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/sharedpreference.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/url_helper.dart';
import 'package:field/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sprintf/sprintf.dart';

import '../../data/model/user_vo.dart';
import '../../domain/use_cases/user_profile_setting/user_profile_setting_usecase.dart';
import '../../logger/logger.dart';
import '../../networking/network_response.dart';
import '../language_change/language_change_cubit.dart';


enum UserProfileSetting {
  userprofilesettingdetailscreen,
  userlanguagelistscreen,
  usertimezonelistscreen,
  userchangepasswordscreen,
  usereditnotificationscreen,
  userFormSettingscreen,
  userprivacypolicyscreen,
  useraboutscreen,
  userOfflineSettingScreen,
  cBimSettingScreen,
  userOfflineSettingDateRangeScreen
}

enum InternalState { loading, success, failure }

class UserProfileSettingCubit extends BaseCubit {
  final UserProfileSettingUseCase _userProfileSettingUseCase;
  UserProfileSettingVo _userProfileSetting = UserProfileSettingVo();
  Language? _languageData;
  bool contactButtonEnabled = false;
  String? strUserImage;
  Map<String, String>? headersMap;
  bool obscureCurrentPwdText = true;
  bool obscureNewPwdText = true;
  bool obscureConfirmNewPwdText = true;
  bool saveButtonEnabled = false;
  bool isCancelTap = false;
  String? currentTimeZone;
  bool workOfflineEnabled = false;
  bool isWriteLogs = false;
  bool isSyncLogFileEmpty = false;
  File? file;

  UserProfileSetting _selectedScreen =
      UserProfileSetting.userprofilesettingdetailscreen;

  UserProfileSettingCubit({UserProfileSettingUseCase? userProfileSettingUseCase}) :_userProfileSettingUseCase = userProfileSettingUseCase??di.getIt<UserProfileSettingUseCase>(), super(FlowState());

  void getDataFromPreference() async{
    isWriteLogs = await StorePreference.isIncludeLogsEnable();
    emitState(ToggleWorkOfflineState(true,time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  Future<void> getUserImageFromServer() async {
    if(isNetWorkConnected()) {
      User user = (await (StorePreference.getUserData())) as User;
      String baseURL = await UrlHelper.getAdoddleURL(null);
      strUserImage = baseURL +
          sprintf(AConstants.userImageUri, [
            user.usersessionprofile?.userID,
            DateTime
                .now()
                .millisecondsSinceEpoch
          ]);
      headersMap = {
        'Cookie':
        'ASessionID=${user.usersessionprofile?.aSessionId};JSessionID=${user.usersessionprofile?.currentJSessionID}'
      };
      _userProfileSettingUseCase.storeImageOffline();
    }else{
     String? offlineImagePath = await _userProfileSettingUseCase.getImageInOffline();
     file = File(offlineImagePath!);
    }
    emitState(ImageUpdateState(InternalState.success,
        time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  void _setUserProfileSettingDetailState(FlowState flowState) {
    Future.delayed(Duration.zero).then((value) => emitState(flowState));
  }

  Future<void> getUserProfileSettingFromServer() async {
    _setUserProfileSettingDetailState(UserProfileSettingState(
        UserProfileSetting.userprofilesettingdetailscreen,
        InternalState.loading));
    Result? result;
    Map<String, dynamic> map = {};
    map["isOnline"] = isNetWorkConnected();
    result =
    await _userProfileSettingUseCase.getUserProfileSetting(map);
    if (result is SUCCESS) {
      _userProfileSetting = result.data;
      if(_userProfileSetting.jsonTimZones != null)
      {
        List<JsonTimZones> timeZone = _userProfileSetting.jsonTimZones!
            .where((element) => element.id == _userProfileSetting.timeZone)
            .toList();
        currentTimeZone = timeZone[0].timeZone;
      }
      _languageData = await StorePreference.getLanguageData(AConstants.keyLanguageData);
      if (null == _languageData) {
        final LogInRemoteRepository loginRemoteRepository =
        di.getIt<LogInRemoteRepository>();
        final languageListResult =
        await loginRemoteRepository.getLanguageList();
        if (languageListResult is SUCCESS) {
          final language = languageListResult.data;
          if ((language as Language).locales != null) {
            Log.d("Language Data ${languageListResult.data}");
            await StorePreference.setLanguageData(
                AConstants.keyLanguageData, language);
            _languageData = languageData;
          }
        }
      }
      _getSuccessState();
    } else {
      emitState(UserProfileSettingState(
          UserProfileSetting.userprofilesettingdetailscreen,
          InternalState.failure,
          message: "Error in getting user profile setting data."));
    }
  }

  void contactlableclick() {
    emitState(EditUserContact(InternalState.success));
  }

  Future<void> onContactButtonClick(String phoneNumber) async {
    emitState(EditUserContact(InternalState.loading, contactButtonEnabled: true));
    if (phoneNumber != _userProfileSetting.phoneNo) {
      _userProfileSetting.phoneNo = phoneNumber;
      final result = await updateUserProfileSettingOnServer();
      if (result is SUCCESS) {
        emitState(
            EditUserContact(InternalState.success, contactButtonEnabled: true));
        //getUserProfileSettingFromServer();
        _getSuccessState();
      } else {
        emitState(EditUserContact(InternalState.failure,
            contactButtonEnabled: false, message: "Contact is not updated."));
      }
    } else {
      emitState(EditUserContact(InternalState.success, contactButtonEnabled: false));
      _getSuccessState();
    }
  }

  Future<void> onLanguageSelectionChange(String newLanguageId) async {
    userProfileSetting.languageId = newLanguageId;
    Result? result;
    Map<String, dynamic> map = {};
    map["action_id"] = 219;
    map["languageId"] = newLanguageId;
    map["dcId"] = 1;
    emitState(LanguageUpdateState(InternalState.loading));
    result = await _userProfileSettingUseCase.updateLanguageOnServer(map);
    if (result is SUCCESS) {
      emitState(LanguageUpdateState(InternalState.success));
      await StorePreference.setUserCurrentLanguage(newLanguageId);
      di.getIt<LanguageChangeCubit>().setCurrentLanguageId();
      //getUserProfileSettingFromServer();
      _getSuccessState(isLanguageChange: true);
    } else {
      emitState(LanguageUpdateState(InternalState.loading,
          message: "Error in updating the language."));
    }
  }

  void onTimeZoneSelectionChange(String newTimeZoneId) async {
    emitState(TimeZoneUpdateState(InternalState.loading));
    userProfileSetting.timeZone = newTimeZoneId;
    final result = await updateUserProfileSettingOnServer();
    if (result is SUCCESS) {
      emitState(TimeZoneUpdateState(InternalState.success));
      _getSuccessState();
      //getUserProfileSettingFromServer();
    } else {
      emitState(TimeZoneUpdateState(InternalState.failure,
          message: "Timezone is not updated."));
    }
  }

  Future<Result?> updateUserProfileSettingOnServer() async {
    final result = await _userProfileSettingUseCase
        .updateUserProfileSettingOnServer(_userProfileSetting);
    return result;
  }

  String getProperLanguageName(
      UserProfileSettingVo userProfileSetting, Language? languageData) {
    String languageName = "";
    final jsonLocales = languageData?.jsonLocales;
    if (jsonLocales != null) {
      for (var v in jsonLocales) {
        if (v.languageId == userProfileSetting.languageId) {
          languageName = "${v.displayLanguage!} (${v.displayCountry!})";
          break;
        }
      }
    }
    return languageName;
  }

  UserProfileSettingVo get userProfileSetting => _userProfileSetting;

  Language? get languageData => _languageData;

  UserProfileSetting get selectedScreen => _selectedScreen;

  set selectedScreen(UserProfileSetting selectedScreen) {
    _selectedScreen = selectedScreen;
  }

  set userProfileSetting(UserProfileSettingVo userProfileSetting){
    _userProfileSetting = userProfileSetting;
  }

  void timezonelableclick() {
    _selectedScreen = UserProfileSetting.usertimezonelistscreen;
    emitState(UserProfileSettingState(_selectedScreen, InternalState.success));
    emitState(TimeZoneUpdateState(InternalState.loading));
    emitState(TimeZoneUpdateState(InternalState.success));
  }

  void languagelableclick() {
    _selectedScreen = UserProfileSetting.userlanguagelistscreen;
    emitState(UserProfileSettingState(_selectedScreen, InternalState.success));
    emitState(LanguageUpdateState(InternalState.loading));
    emitState(LanguageUpdateState(InternalState.success));
  }

  void onBackButtonClick() {
    isCancelTap = true;
    _getSuccessState();
  }

  void _getSuccessState({bool isLanguageChange = false}) {
    _selectedScreen = UserProfileSetting.userprofilesettingdetailscreen;
    emitState(UserProfileSettingState(_selectedScreen, InternalState.success,
        isLanguageChange: isLanguageChange));
  }

  void onChangePasswordClick() {
    _selectedScreen = UserProfileSetting.userchangepasswordscreen;
    emitState(UserProfileSettingState(_selectedScreen, InternalState.success));
    emitState(ChangePasswordState(InternalState.success));
  }

  void onCBimSettingClick() {
    _selectedScreen = UserProfileSetting.cBimSettingScreen;
    emitState(UserProfileSettingState(_selectedScreen, InternalState.success));
    emitState(ChangePasswordState(InternalState.success));
  }

  void onPrivacyPolicyButtonClick() {
    _selectedScreen = UserProfileSetting.userprivacypolicyscreen;
    emitState(UserProfileSettingState(_selectedScreen, InternalState.success));
  }

  void onEditNotificationButtonClick() {
    _selectedScreen = UserProfileSetting.usereditnotificationscreen;
    emitState(UserProfileSettingState(_selectedScreen, InternalState.success));
  }

  void onOfflineDataButtonClick() {
    _selectedScreen = UserProfileSetting.userOfflineSettingScreen;
    emitState(UserProfileSettingState(_selectedScreen, InternalState.success));
  }

  void onSelectDateRangeButtonClick() {
    _selectedScreen = UserProfileSetting.userOfflineSettingDateRangeScreen;
    emitState(UserProfileSettingState(_selectedScreen, InternalState.success));
  }

  void onFormSettingsButtonClick() {
    _selectedScreen = UserProfileSetting.userFormSettingscreen;
    emitState(UserProfileSettingState(_selectedScreen, InternalState.success));
  }

  void onCancelBtnClickOfChangePassword() {
    isCancelTap = true;
    _getSuccessState();
  }

  void onAboutBtnClick() {
    _selectedScreen = UserProfileSetting.useraboutscreen;
    emitState(UserProfileSettingState(_selectedScreen, InternalState.success));
  }

  void onSaveBtnClickOfChangePassword() async {
    emitState(ChangePasswordState(InternalState.loading));
    final result = await updateUserProfileSettingOnServer();

    if (result is SUCCESS) {
      if (jsonDecode(result.data)["isResetPassword"] == true) {
        emitState(ChangePasswordState(InternalState.success,
            message: "Password_changed_successfully",
            time: DateTime.now().millisecondsSinceEpoch.toString()));
        await StorePreference.clearUserPreferenceData();
        //Future.delayed(const Duration(milliseconds:300));
        NavigationUtils.mainPushNamedAndRemoveUntil(Routes.onboardingLogin);
        //getUserProfileSettingFromServer();
        //_getSuccessState();
      } else {
        emitState(ChangePasswordState(InternalState.failure,
            message: jsonDecode(result.data)["passwordExceptionMessage"],
            time: DateTime.now().millisecondsSinceEpoch.toString()));
      }
    }
  }

  void onCurrentPwdToggle() {
    obscureCurrentPwdText = !obscureCurrentPwdText;
    emitState(PasswordVisiblityToggle(obscureCurrentPwdText));
  }

  void onNewPwdToggle() {
    obscureNewPwdText = !obscureNewPwdText;
    emitState(PasswordVisiblityToggle(obscureNewPwdText));
  }

  void onConfirmNewPwdToggle() {
    obscureConfirmNewPwdText = !obscureConfirmNewPwdText;
    emitState(PasswordVisiblityToggle(obscureConfirmNewPwdText));
  }

  void onSaveButtonEnabled() {
    saveButtonEnabled = true;
    emitState(ChangePasswordState(InternalState.success,
        time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  void saveButtonDisabled() {
    saveButtonEnabled = false;
    emitState(ChangePasswordState(InternalState.success,
        time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  showEyeIcon() {
    emitState(ShowEyeIconState());
  }

  void enableContactTick(String phoneNumber) {
    if (phoneNumber != "" && (_userProfileSetting.phoneNo != phoneNumber)) {
      emitState(EditUserContact(InternalState.success, contactButtonEnabled: true));
    } else {
      emitState(EditUserContact(InternalState.failure, contactButtonEnabled: false));
    }
  }

  void getUserWithSubscription() async {
    final result = await _userProfileSettingUseCase.getUserWithSubscription();
    if (result != null) {
      GetUserWithSubscriptionVo userWithSubscriptionVo =
      result.data as GetUserWithSubscriptionVo;
      if (userWithSubscriptionVo != null) {
        String dateFormatForLanguage =
        userWithSubscriptionVo.dateFormatforLanguage!;
        String languageId = userWithSubscriptionVo.languageId!;
        if (languageId.isNotEmpty && dateFormatForLanguage.isNotEmpty) {
          StorePreference.setLocalLanguageDateFormat(
              languageId, dateFormatForLanguage);
        }
      }
    }
  }

  Future<void> toggleIncludeLogs(bool val) async {
    isWriteLogs = val;
    isLogEnable = val;
    await PreferenceUtils.setBool("includeLogs", val);
    emitState(ToggleWorkOfflineState(val,time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  Future<void> onUploadLogPress() async {
    emitState(LoadingState(
        stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE));
    try {
      final result = await _userLoginApiCall();
      if (result) {
        final uploadResult = await _uploadLogFile();
        if (uploadResult) {
          await _userLogOutApiCall();
          emitState(LogFileUploadedSuccess());
          return;
        }
      }
      emitState(LogFileUploadedFailure());
    } on Exception catch (_) {
      emitState(LogFileUploadedFailure());
    }
  }

  Future<bool> _userLoginApiCall() async {
    try {
      Map<String, dynamic> map = <String, dynamic>{};
      map["emailId"] = AConstants.logEmailId;
      map["password"] = AConstants.logPassword;
      map["applicationTypeId"] = "3";
      map["isFromField"] = "true";
      final loginResult = await _userProfileSettingUseCase.doLogin(map);
      if (loginResult is SUCCESS) {
        return true;
      } else {
        return false;
      }
    } on Exception catch (_) {
      return false;
    }
  }

  Future<bool> _uploadLogFile() async {
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final String path = await AppPathHelper().getSyncLogFilePath();
      final currentDateTime = DateTime.now().millisecondsSinceEpoch;
      User user = (await (StorePreference.getUserData())) as User;
      final String zipFilePath = directory.path + "/" + 'sync_log_${user.usersessionprofile?.firstName ?? ''}_$currentDateTime.zip';

      var encoder = ZipFileEncoder();
      encoder.create(zipFilePath);
      encoder.addFile(File(path));
      encoder.close();

      if (isNetWorkConnected()) {
        Map<String, dynamic> data = {};
        data['projId'] = AConstants.logProjId;
        data['folderId'] = Utility.getLogFileFolderID(AConstants.buildEnvironment);
        data['isMac'] = Platform.isMacOS;
        data['totalFiles'] = '1';
        data["upFile0"] = await MultipartFile.fromFile(zipFilePath);
        final result = await _userProfileSettingUseCase.uploadSyncFile(data);
        //Delete created zip file
        await deleteFileAtPath(zipFilePath);
        if (result is SUCCESS) {
          await Utility.deleteSyncLogFile();
          return true;
        }
      }
      return false;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<bool> _userLogOutApiCall() async {
    await _userProfileSettingUseCase.doLogout();
    try {
      final result = await _userProfileSettingUseCase.doLogout();
      return result;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<void> isSyncFileIsEmpty() async {
    try {
      final fileLog = await Utility.getSyncLogFileText();
      isSyncLogFileEmpty = fileLog.isEmpty;
    } catch (_) {
      isSyncLogFileEmpty = true;
    }
  }
}
