import 'package:field/database/db_service.dart';
import 'package:field/sync/db_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:field/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/mock_method_channel.dart';
import '../fixtures/appconfig_test_data.dart';
import '../fixtures/fixture_reader.dart';

class DBServiceMock extends Mock implements DBService {}

void main(){
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  DBServiceMock mockDb = DBServiceMock();
  DBConfig dbConfig = DBConfig();

  di.init(test: true);
  di.getIt.unregister<DBService>();
  di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb);
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  AppConfigTestData().setupAppConfigTestData();
  SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json"), "cloud_type_data": "1", "1_u1_project_": fixture("project.json")});

  group("DB Config Test", () {
    test("Init Function Test", ()async{
      when(()=>mockDb.executeQuery(any())).thenReturn({});
      await dbConfig.init();
      verify(()=>mockDb.executeQuery(any())).called(22);
    });
  });
}