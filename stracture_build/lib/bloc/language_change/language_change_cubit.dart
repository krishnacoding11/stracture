import 'package:field/bloc/base/base_cubit.dart';

import '../../data/model/get_user_with_subscription_vo.dart';
import '../../data/model/user_vo.dart';
import '../../domain/use_cases/user_profile_setting/user_profile_setting_usecase.dart';
import '../../networking/network_response.dart';
import '../../utils/constants.dart';
import '../../utils/store_preference.dart';
import 'language_change_state.dart';
import 'package:field/injection_container.dart' as di;

class LanguageChangeCubit extends BaseCubit {
  String? _langId = "en_GB";

  LanguageChangeCubit() : super(LanguageChangeState("en_GB"));

   setCurrentLanguageId() async {
    _langId = await StorePreference.getUserCurrentLanguage();
    emitState(LanguageChangeState(_langId!));
  }

  String get langId => _langId!;

  Future<void> getUserWithSubscription() async {
    UserProfileSettingUseCase _userProfileSettingUseCase = di.getIt<UserProfileSettingUseCase>();
    final result = await _userProfileSettingUseCase.getUserWithSubscription();
    if (result != null && result is SUCCESS) {
      GetUserWithSubscriptionVo userWithSubscriptionVo =
      result.data as GetUserWithSubscriptionVo;
      if (userWithSubscriptionVo != null) {
        String dateFormatForLanguage =
        userWithSubscriptionVo.dateFormatforLanguage!;
        String languageId = userWithSubscriptionVo.languageId!;
        String timeZoneId = userWithSubscriptionVo.timeZoneId!;
        if (languageId.isNotEmpty && dateFormatForLanguage.isNotEmpty) {
          User? userData = await StorePreference.getUserData();
          String oldLangId = userData!.usersessionprofile!.languageId!;
          userData!.usersessionprofile!.languageId = languageId;
          userData.usersessionprofile!.timezoneId = timeZoneId;
          userData.usersessionprofile!.dateFormatforLanguage = dateFormatForLanguage;
          StorePreference.setUserData(userData);
          bool isLangChange= (oldLangId != languageId);
          StorePreference.setBoolData(AConstants.keyisLanguageChange,isLangChange);
          StorePreference.setUserCurrentLanguage(languageId);
          StorePreference.setLocalLanguageDateFormat(
              languageId, dateFormatForLanguage);
          emitState(LanguageChangeState(languageId));
        }
      }
    }
  }
}