import 'package:field/data/local/homepage/homepage_local_repository_impl.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appconfig_test_data.dart';
import '../../../fixtures/fixture_reader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  late HomePageLocalRepository homePageLocalRepository;

  configureDependencies() {
    di.init(test: true);
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json"), "cloud_type_data": "1", "1_u1_project_": fixture("project.json")});
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
    AppConfigTestData().setupAppConfigTestData();
  }

  setUp(() {
    homePageLocalRepository = HomePageLocalRepository();
  });
  group("homepage_local_repository_impl_test", () {
    configureDependencies();
    test("getShortcutConfigList [Success] test", () async {
      Map<String, dynamic> request = {"projectId": "2116416"};
      final result = await homePageLocalRepository.getShortcutConfigList(request);
      expect(result, isA<SUCCESS>());
    });

    test("getShortcutConfigList [Fail] test", () async {
      Map<String, dynamic> request = {"projectId": "211416"};
      final result = await homePageLocalRepository.getShortcutConfigList(request);
      expect(result, isA<FAIL>());
    });

    test("getPendingShortcutConfigList Test", () {
      Map<String, dynamic> request = {"projectId": "211416"};
      expect(() => homePageLocalRepository.getPendingShortcutConfigList(request), throwsA(isA<UnimplementedError>()));
    });

    test("updateShortcutConfigList Test", () {
      Map<String, dynamic> request = {"projectId": "211416", "jsonData": fixture("homepage_item_config_data.json")};
      expect(() => homePageLocalRepository.updateShortcutConfigList(request), throwsA(isA<UnimplementedError>()));
    });
  });
}
