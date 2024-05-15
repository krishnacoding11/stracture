import 'package:field/data/remote/userprofilesetting/userprofilesetting_repository_impl.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../bloc/mock_method_channel.dart';


class MockUserProfileRemoteRepository extends Mock implements UserProfileSettingRemoteRepository {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  di.getIt.registerLazySingleton<MockUserProfileRemoteRepository>(
          () => MockUserProfileRemoteRepository());
  late MockUserProfileRemoteRepository mockSiteRemoteRepository;

  setUpAll(() {
    mockSiteRemoteRepository = di.getIt<MockUserProfileRemoteRepository>();
  });

  group("Site Remote repository Implementation: ", () {
    Map<String, dynamic> request = {
      "action_id": "221",
      "extra":
      {"agreedToTermsOfUse":false,"marketingPref":false}
    };
    test("test download pdf file", () async {
      when(() => mockSiteRemoteRepository.acceptTermOfUse(request))
          .thenAnswer(
              (_) async => Future(() => Result(null)));
      final result =
      await mockSiteRemoteRepository.acceptTermOfUse(request);
      expect(result, isA<Result>());
    });
  });
}
