import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:camera/camera.dart';
import 'package:field/bloc/user_first_login_setup/user_first_login_setup_cubit.dart';
import 'package:field/bloc/user_first_login_setup/user_first_login_setup_state.dart';
import 'package:field/data/model/accept_termofuse_vo.dart';
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

class MockUserProfileSettingUseCase extends Mock implements UserProfileSettingUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserFirstLoginSetupCubit userProfileSetting;
  late AcceptTermofuseVo result;
  late MockUserProfileSettingUseCase mockUserProfileSettingUseCase;

  setUp(() {
    mockUserProfileSettingUseCase = MockUserProfileSettingUseCase();
    userProfileSetting = UserFirstLoginSetupCubit(userProfileSettingUseCase: mockUserProfileSettingUseCase);
    userProfileSetting.currentUserAvatar = XFile('assets/images/ic_logo_tablet.png');

    MockMethodChannel().setAsitePluginsMethodChannel();

    SharedPreferences.setMockInitialValues({
      "userData": fixture("user_data.json")
    });

    //static targetpath
    userProfileSetting.targetPath = '/Users/nikita/Library/Developer/CoreSimulator/Devices/373F4808-8F34-498F-BB55-00D5359CDB98/data/Containers/Data/Application/';
  });

  tearDown(() {
    userProfileSetting.close();
  });
  configureCubitDependencies() {
    MockMethodChannel().setNotificationMethodChannel();
    di.init(test: true);
    AppConfigTestData().setupAppConfigTestData();
    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AConstants.loadProperty();

  }

  group("User Accept Terms and Privacy", () {
    configureCubitDependencies();

    test("Initial State", () {
      expect(UserFirstLoginSetupCubit().state, isA<FlowState>());
    });
    blocTest<UserFirstLoginSetupCubit, FlowState>(
      'emits [SuccessState] accept term and condition',
      build: () {
        return userProfileSetting;
      },
      act: (cubit) async {
        when(() => mockUserProfileSettingUseCase.acceptTermOfUse(any())).thenAnswer((invocation) => Future.value(Result.success(result)));
        dynamic data = fixture("accept_termofuse_success.json");
        result = AcceptTermofuseVo.fromJson(data);
        cubit.onAcceptTermsOfUses();
      },
      expect: () => [isA<LoadingState>(), isA<SuccessState>()],
    );

    blocTest<UserFirstLoginSetupCubit, FlowState>(
      'emits [ErrorState] accept term and condition',
      build: () {
        return userProfileSetting;
      },
      act: (cubit) async {
        when(() => mockUserProfileSettingUseCase.acceptTermOfUse(any())).thenAnswer((invocation) => Future.value(Result.success(result)));
        dynamic data = fixture("accept_termofuse_failure.json");
        result = AcceptTermofuseVo.fromJson(data);
        cubit.onAcceptTermsOfUses();
      },
      expect: () => [isA<LoadingState>(), isA<ErrorState>()],
    );

    blocTest<UserFirstLoginSetupCubit, FlowState>(
      'emits [SuccessState] current screen',
      build: () {
        return userProfileSetting;
      },
      act: (cubit) async {
        cubit.onChangePrivacyAccept();
      },
      expect: () => <FlowState>[AcceptPrivacyState(userProfileSetting.isPrivacyAccept)],
    );
  });
}
