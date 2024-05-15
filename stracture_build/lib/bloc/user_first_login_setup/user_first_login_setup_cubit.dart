import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/sync/db_config.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/url_helper.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';

import '../../data/local/login/login_local_repository.dart';
import '../../data/model/accept_termofuse_vo.dart';
import '../../data/model/user_profile_setting_vo.dart';
import '../../data/model/user_vo.dart';
import '../../domain/use_cases/user_profile_setting/user_profile_setting_usecase.dart';
import '../../logger/logger.dart';
import '../../networking/network_response.dart';
import '../../presentation/base/state_renderer/state_renderer.dart';
import '../../utils/constants.dart';
import '../../utils/image_compress_utils.dart';
import '../../widgets/a_file_picker.dart';
import '../login/login_cubit.dart';
import 'user_first_login_setup_state.dart';

enum UserFirstLoginSetup { privacyPolicy, editNotification, editProfileImage }

class UserFirstLoginSetupCubit extends BaseCubit {
  final UserProfileSettingUseCase _userProfileSettingUseCase;
  final LoginCubit loginCubit = di.getIt<LoginCubit>();

  UserFirstLoginSetupCubit({UserProfileSettingUseCase? userProfileSettingUseCase}) :
        _userProfileSettingUseCase = userProfileSettingUseCase ?? di.getIt<UserProfileSettingUseCase>(),
        super(InitialState(stateRendererType: StateRendererType.DEFAULT));
  UserFirstLoginSetup currentSetupScreen = UserFirstLoginSetup.privacyPolicy;
  final LogInLocalRepository _loginLocalRepository = di.getIt<LogInLocalRepository>();
  late UserProfileSettingVo _userProfileSetting = UserProfileSettingVo();

  XFile? currentUserAvatar;
  ImageProvider? provider;
  String? targetPath;
  File? tempFile;

  bool isPrivacyAccept = false;
  bool? isPushNotificationEnable;
  bool? includeCloseOutFormEnable;
  String? username;

  final GlobalKey cropperKey = GlobalKey(debugLabel: 'cropperKey');
  User? user;
  String? strUserImage;
  Map<String, String>? headersMap;

  File createFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  void deleteFile(String path) {
    final file = File(path);
    if (file.existsSync()) {
      file.delete();
      targetPath = null;
    }
  }

  getUserName() async {
  if(user != null) {
    username = user!.usersessionprofile!.firstName;
    emitState(GetUserName(userName: username!));
  }
    currentSetupScreen = UserFirstLoginSetup.privacyPolicy;
    isPrivacyAccept = false;
  }

  setupNotification() async {
    emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
    isPushNotificationEnable = await StorePreference.getPushNotificationEnable();
    emitState(EnablePushNotification(isPushNotificationEnable!, DateTime.now().millisecondsSinceEpoch.toString()));
  }

  setupCloseOutFormSetting() async {
    emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
    includeCloseOutFormEnable = await StorePreference.getIncludeCloseOutFormFlag();
    emitState(ChangeIncludeCloseOutForm(includeCloseOutFormEnable!));
  }

  getUserDataFromLocal() async {
    user = await StorePreference.getUserData();
  }

  getUserImageFromServer() async {
    if (user != null) {
      String baseURL = await UrlHelper.getAdoddleURL(null);
      strUserImage = baseURL + sprintf(AConstants.userImageUri, [user!.usersessionprofile?.userID, DateTime.now().millisecondsSinceEpoch]);
      headersMap = {'Cookie': 'ASessionID=${user!.usersessionprofile!.aSessionId};JSessionID=${user!.usersessionprofile!.currentJSessionID}'};
      emitState(UpdateNetworkImage(networkUserAvatar: strUserImage!));
    }
  }

  void getuserprofilesettingfromserver() async {
    emitState(LoadingState(stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE));
    Result? result;
    Map<String, dynamic> map = {};
    map["isOnline"] = isNetWorkConnected();
    result = await _userProfileSettingUseCase.getUserProfileSetting(map);
    if (result is SUCCESS) {
      _userProfileSetting = result.data;
      emitState(SuccessState(result));
    } else {
      emitState(ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE, "Error in getting user profile setting data."));
    }
  }

  Future<void> updateUserProfileSettingOnServer() async {
    emitState(LoadingState(stateRendererType: StateRendererType.POPUP_LOADING_STATE));
    File currentImage = File(currentUserAvatar!.path);
    final imageBytes = await currentImage.readAsBytes();
    final imageSize = imageBytes.lengthInBytes / 1024; // convert into Kb
    int maxImageSize = 300; // In Kb

    try {
      var compressedImagePath = currentImage.path.toString();
      if (imageSize > maxImageSize) {
        compressedImagePath = await compressImageFile(currentImage.path,
            maxFileSize: maxImageSize, imageType: "Profile");
      }
      if (!compressedImagePath.isNullOrEmpty()) {
        final result = await _userProfileSettingUseCase
            .updateUserProfileSettingOnServer(_userProfileSetting,
                imagePath: compressedImagePath);
        if (result is SUCCESS) {
          emitState(SuccessState(result,
              stateRendererType: StateRendererType.DEFAULT));
        } else {
          emitState(ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE,
              "Something went wrong"));
        }
      } else {
        emitState(ErrorState(
            StateRendererType.FULL_SCREEN_ERROR_STATE, "Something went wrong"));
      }
    } catch (e) {
     Log.e(e.toString());
    }
  }

  continueToNext({UserFirstLoginSetup? userFirstLoginCurrentScreen, BuildContext? context, Function? onFinish}) async {
    if (currentSetupScreen == UserFirstLoginSetup.privacyPolicy) {
      currentSetupScreen = UserFirstLoginSetup.editNotification;
      emitState(UserFirstLoginState(currentSetupScreen));
    } else if (currentSetupScreen == UserFirstLoginSetup.editNotification) {
      currentSetupScreen = UserFirstLoginSetup.editProfileImage;
      getuserprofilesettingfromserver();
      emitState(UserFirstLoginState(currentSetupScreen));
    } else if (currentSetupScreen == UserFirstLoginSetup.editProfileImage) {
      if (currentUserAvatar != null) {
        await setAcceptedTermLocal();
        await updateUserProfileSettingOnServer();
      } else {
        if (onFinish != null) onFinish();
      }
    }
  }

  backToCurrent({UserFirstLoginSetup? userFirstLoginCurrentScreen}) {
    if (currentSetupScreen == UserFirstLoginSetup.editNotification) {
      currentSetupScreen = UserFirstLoginSetup.privacyPolicy;
    } else if (currentSetupScreen == UserFirstLoginSetup.editProfileImage) {
      currentSetupScreen = UserFirstLoginSetup.editNotification;
    }

    emitState(UserFirstLoginState(currentSetupScreen));
  }

  onChangePrivacyAccept() {
    isPrivacyAccept = !isPrivacyAccept;
    emitState(AcceptPrivacyState(isPrivacyAccept));
  }

  onChangePushNotificationEnable() async {
    isPushNotificationEnable = !isPushNotificationEnable!;
    await StorePreference.setPushNotificationEnable(isPushNotificationEnable);
    emitState(EnablePushNotification(isPushNotificationEnable!, DateTime.now().millisecondsSinceEpoch.toString()));
    await loginCubit.registerDeviceToServer();
  }

  onChangeIncludeCloseOutForm() async {
    includeCloseOutFormEnable = !includeCloseOutFormEnable!;
    await StorePreference.setIncludeCloseOutFormFlag(includeCloseOutFormEnable);
    emitState(ChangeIncludeCloseOutForm(includeCloseOutFormEnable!));
  }

  Future<bool?> setAcceptedTermLocal() async {
    User? userFromSharedPref = await StorePreference.getUserData();
    List<User> userFormLocalDb = await _loginLocalRepository.getData();
    List<User> findUserFromDb;

    if (userFormLocalDb.isNotEmpty && userFormLocalDb.isNotEmpty) {
      findUserFromDb = userFormLocalDb.where((User dbUser) => (dbUser.usersessionprofile!.userID == userFromSharedPref!.usersessionprofile!.userID)).toList();

      if (findUserFromDb.isNotEmpty) {
        if (findUserFromDb[0].usersessionprofile!.isAgreedToTermsAndCondition == "false") {
          onAcceptTermsOfUses().then((value) async {
            if (value!) {
              findUserFromDb[0].usersessionprofile!.isAgreedToTermsAndCondition = "true";
              await _loginLocalRepository.updateAcceptTermAndCondition(jsonEncode(findUserFromDb[0].toJson()), findUserFromDb[0].usersessionprofile!.userID!);
              await StorePreference.setUserData(findUserFromDb[0]);
              await DBConfig().init();
              return value;
            }
          });
        } else {
          return true;
        }
      } else {
        return false;
      }
    }
    return null;
  }

  Future<bool?> onAcceptTermsOfUses() async {
    emitState(
        LoadingState(stateRendererType: StateRendererType.POPUP_LOADING_STATE));
    Result? result;
    Map<String, dynamic> map = {};
    Map<String, dynamic> extraMap = {};

    extraMap[json.encode('agreedToTermsOfUse')] = "true";
    extraMap[json.encode('marketingPref')] = "false";

    map["action_id"] = "221";
    map["extra"] = extraMap.toString();

    result = await _userProfileSettingUseCase.acceptTermOfUse(map);
    if (result!.data != null) {
      AcceptTermofuseVo termofUseVo = result.data as AcceptTermofuseVo;
      if (termofUseVo.agreedToTermsOfUse!) {
        emitState(SuccessState([result]));
        return true;
      } else {
        emitState(ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE,
            "Error in accept terms of uses."));
        return false;
      }
    }
    return null;
  }

  Future<void> getImageFromGallery(BuildContext context, [Function? onError, Function? selectedFileCallBack]) async {
    await AFilePicker().getSingleImage((error, stackTrace) {
      if (onError != null) {
        onError(error,stackTrace);
      }
    }, (selectImage) {
      if (selectedFileCallBack != null) {
        selectedFileCallBack(selectImage);
      }
    });
  }

  updateCurrentAvatarFromFile(XFile? image) {
    currentUserAvatar = image;
    emitState(UpdateImageFromLocal(currentUserAvatar: currentUserAvatar));
  }

  void cancelTermOfUse() async {
    await StorePreference.clearUserPreferenceData();
  }
}
