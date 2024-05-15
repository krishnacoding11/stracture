import 'dart:io';

import 'package:field/data/local/userprofilesetting/userprofilesetting_local_repository_impl.dart';
import 'package:field/data/model/user_profile_setting_vo.dart';
import 'package:field/data/remote/userprofilesetting/userprofilesetting_repository_impl.dart';
import 'package:field/data/repository/userprofilesetting/userprofilesetting_repository.dart';
import 'package:field/domain/common/base_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';
import 'package:field/utils/store_preference.dart';
import 'package:sprintf/sprintf.dart';

import '../../../data/model/user_vo.dart';
import '../../../networking/network_response.dart';
import '../../../utils/app_path_helper.dart';
import '../../../utils/constants.dart';
import '../../../utils/url_helper.dart';

class UserProfileSettingUseCase extends BaseUseCase {

  UserProfileSettingRepository? _userProfileSettingRepository;

  Future<Result?> getUserProfileSetting(Map<String, dynamic> request) async {
    await getInstance();
    return await _userProfileSettingRepository!.getUserProfileSetting(request);
  }

  Future<Result?> updateLanguageOnServer(Map<String, dynamic> request) async {
    await getInstance();
    return await _userProfileSettingRepository!.updateLanguage(request);
  }

  Future<Result?> updateUserProfileSettingOnServer(UserProfileSettingVo request,
      {String? imagePath}) async {
    await getInstance();
    return await _userProfileSettingRepository!.updateUserProfileSetting(request, imagePath: imagePath);
  }

  Future<Result?> acceptTermOfUse(Map<String, dynamic> request) async {
    await getInstance();
    return await _userProfileSettingRepository!.acceptTermOfUse(request);
  }

  Future<Result?> getUserWithSubscription() async {
    Map<String, dynamic> request = {'user_id': await StorePreference.getHashedUserId()};
    await getInstance();
    return await _userProfileSettingRepository!.getUserWithSubscription(request);
  }

  void storeImageOffline() async {
    getInstance();
    User user = (await (StorePreference.getUserData())) as User;
    String baseURL = await UrlHelper.getAdoddleURL(null);
    String strUserImage = baseURL +
        sprintf(AConstants.userImageUri, [
          user.usersessionprofile?.userID,
          DateTime
              .now()
              .millisecondsSinceEpoch
        ]);
    final headersMap = {
      'Cookie':
      'ASessionID=${user.usersessionprofile?.aSessionId};JSessionID=${user.usersessionprofile?.currentJSessionID}'
    };

  List<int>? resultData = await _userProfileSettingRepository!.downloadUserImage(strUserImage, headersMap);
    String? offlineStorePath = await AppPathHelper().getUserDataProfilePath();
    // Download the image
    final imageFile = File(offlineStorePath);
    if(await imageFile.exists()){
      imageFile.deleteSync();
    }
    await imageFile.writeAsBytes(resultData!);
  }

  Future<String?> getImageInOffline()async{
    String? strUserImage = await AppPathHelper().getUserDataProfilePath();
    return strUserImage;
  }

  @override
  Future getInstance() async {
    if(isNetWorkConnected()){
      _userProfileSettingRepository =
          di.getIt<UserProfileSettingRemoteRepository>();
    }
    else {
        _userProfileSettingRepository =
            di.getIt<UserProfileSettingLocalRepository>();
      }
    return _userProfileSettingRepository;
  }

  Future<Result?> doLogin(Map<String, dynamic> request) async {
    final result = await _userProfileSettingRepository?.doLogin(request);
    if (result is SUCCESS) {
      final user = result.data;
      if (user is User && user.usersessionprofile != null) {
        await StorePreference.setLoggerUserASessionId(user.usersessionprofile?.aSessionId ?? '');
      }
    }
    return result;
  }

  Future<Result?> uploadSyncFile(Map<String, dynamic> request) async {
    await getInstance();
    final result = await _userProfileSettingRepository?.uploadSyncFile(request);
    return result;
  }

  Future<bool> doLogout() async {
    final result = await _userProfileSettingRepository?.doLogout();

    if (result != null) {
      await StorePreference.removeLoggerUserASessionId();
      return true;
    }
    return false;
  }
}
