import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/language_change/language_change_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_state.dart';
import 'package:field/data/model/user_profile_setting_vo.dart';
import 'package:field/domain/use_cases/user_profile_setting/user_profile_setting_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../fixtures/appconfig_test_data.dart';
import '../fixtures/fixture_reader.dart';
import '../utils/load_url.dart';
import 'mock_method_channel.dart';

class MockUserProfileSettingUseCase extends Mock
    implements UserProfileSettingUseCase {}

class MockLanguageChangeCubit extends Mock implements LanguageChangeCubit{}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannel().setAsitePluginsMethodChannel();
  late UserProfileSettingCubit userProfileSettingCubit;
  late MockUserProfileSettingUseCase mockUserProfileSettingUseCase;
  late MockLanguageChangeCubit langChangeCubit;
  SharedPreferences.setMockInitialValues(
      {"userData": fixture("user_data.json")});
  setUp(() {
    mockUserProfileSettingUseCase = MockUserProfileSettingUseCase();
    langChangeCubit = MockLanguageChangeCubit();
    userProfileSettingCubit = UserProfileSettingCubit(
        userProfileSettingUseCase: mockUserProfileSettingUseCase);
  });

  group("User Profile Cubit:", () {
    di.init(test: true);
    AppConfigTestData().setupAppConfigTestData();
    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    MockMethodChannel().setConnectivityMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AConstants.loadProperty();
    var newLanguageId = "en_CA";
    var newTimeZoneId = "America/Anchorage";
    var mobileNumber = "123456789";

    const responseData =
        "{\"passwordModifiedDate\":\"1665403511860\",\"openId\":\"\",\"graceLoginCount\":0,\"greeting\":\"\",\"passwordEncrypted\":true,\"loginDate\":\"1665403361817\",\"isResetPassword\":true,\"screenName\":\"sbanethia\",\"lastLoginDate\":\"1665402829087\",\"uuid\":\"3c78681f-15fa-442f-9152-8845602d3fe2\",\"emailAddress\":\"sbanethia@asite.com\",\"passwordReset\":false,\"defaultUser\":false,\"createDate\":\"1475648773360\",\"isSuccess\":true,\"portraitId\":975067,\"comments\":\"\",\"contactId\":859156,\"timeZoneId\":\"America/Anchorage\",\"lastFailedLoginDate\":\"\",\"languageId\":\"en_CA\",\"active\":true,\"failedLoginAttempts\":0,\"userId\":859155,\"agreedToTermsOfUse\":true,\"companyId\":300106,\"lockout\":false,\"lockoutDate\":\"\",\"rawOffset\":-32400000,\"modifiedDate\":\"1665403511849\"}";

    test("Initial State", () {
      expect(UserProfileSettingCubit().state, isA<FlowState>());
    });

    blocTest<UserProfileSettingCubit, FlowState>(
      'emits [SuccessState] when getuserprofilesettingfromserver is called',
      build: () {
        return userProfileSettingCubit;
      },
      act: (cubit) async {
        when(() => mockUserProfileSettingUseCase.getUserProfileSetting(any())).thenAnswer((invocation) => Future.value(Result(UserProfileSettingVo.fromJson(fixture("user_profile_setting.json")))));

       await cubit.getUserProfileSettingFromServer();
      },
      expect: () => [isA<UserProfileSettingState>(), isA<UserProfileSettingState>()],
    );

    blocTest<UserProfileSettingCubit, FlowState>(
      'emits [SuccessState] when update contact called',
      build: () => userProfileSettingCubit,
      setUp: () {
        when(() =>
            mockUserProfileSettingUseCase.updateUserProfileSettingOnServer(
                userProfileSettingCubit.userProfileSetting))
            .thenAnswer((_) => Future.value(SUCCESS(responseData, null, null)));
      },
      act: (cubit) => cubit.onContactButtonClick(mobileNumber),
      expect: () => [
        isA<EditUserContact>(),
        isA<EditUserContact>(),
        isA<UserProfileSettingState>()
      ],
    );

    blocTest<UserProfileSettingCubit, FlowState>(
      'emits [SuccessState] when language update called',
      build: () => userProfileSettingCubit,
      setUp: () {
        when(() => langChangeCubit.setCurrentLanguageId())
            .thenAnswer((_) =>
            Future.value());
        when(() => mockUserProfileSettingUseCase.updateLanguageOnServer(any()))
            .thenAnswer((_) =>
            Future.value(SUCCESS(fixture('user_data.json'), null, null)));
      },
      act: (cubit) => cubit.onLanguageSelectionChange(newLanguageId),
      expect: () => [
        isA<LanguageUpdateState>(),
        isA<LanguageUpdateState>(),
        isA<UserProfileSettingState>()
      ],
    );

    blocTest<UserProfileSettingCubit, FlowState>(
      'emits [SuccessState] when timezone update called',
      build: () => userProfileSettingCubit,
      setUp: () {
        when(() =>
            mockUserProfileSettingUseCase.updateUserProfileSettingOnServer(
                userProfileSettingCubit.userProfileSetting))
            .thenAnswer((_) => Future.value(SUCCESS(responseData, null, null)));
      },
      act: (cubit) => cubit.onTimeZoneSelectionChange(newTimeZoneId),
      expect: () => [
        isA<TimeZoneUpdateState>(),
        isA<TimeZoneUpdateState>(),
        isA<UserProfileSettingState>()
      ],
    );

    blocTest<UserProfileSettingCubit, FlowState>(
      'emits [SuccessState] when about update called',
      build: () => userProfileSettingCubit,
      act: (cubit) => cubit.onAboutBtnClick(),
      expect: () => [isA<UserProfileSettingState>()],
    );

  });
}
