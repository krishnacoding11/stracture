import 'package:field/data/model/user_profile_setting_vo.dart';

import '../../../networking/network_response.dart';

abstract class UserProfileSettingRepository <REQUEST,RESPONSE> {
  Future<Result> getUserProfileSetting(Map<String, dynamic> request);
  Future<Result> updateLanguage(Map<String, dynamic> request);
  Future<Result> updateUserProfileSetting(UserProfileSettingVo userProfileSetting,{String? imagePath});
  Future<Result> acceptTermOfUse(Map<String, dynamic> request);
  Future<Result> getUserWithSubscription(Map<String, dynamic> request);
  Future<List<int>>? downloadUserImage(String? imageUrl,Map<String, dynamic>? header);
  Future<Result?> doLogin(Map<String, dynamic> request);
  // Future<Result?> uploadLogFile(Map<String, dynamic> request);
  Future<Result?> doLogout();
  Future<Result> uploadSyncFile(Map<String, dynamic> request);
}
