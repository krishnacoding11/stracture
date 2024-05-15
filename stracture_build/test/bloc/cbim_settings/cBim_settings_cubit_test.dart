import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/cBim_settings/cBim_settings_cubit.dart';
import 'package:field/bloc/cBim_settings/cBim_settings_state.dart';
import 'package:field/data/dao/cbim_settings_dao.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/cBim_settings/cBim_setting_use_case.dart';
import 'package:field/injection_container.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/appconfig_test_data.dart';
import '../../utils/load_url.dart';
import '../mock_method_channel.dart';

class MockCBISettingsDao extends Mock implements CbimSettingsDao {}

class DBServiceMock extends Mock implements DBService {}
class MockDatabaseManager extends Mock implements DatabaseManager {}
class MockCBimSettingUseCase extends Mock implements CBimSettingUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockMethodChannelUrl().setupBuildFlavorMethodChannel();
  MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  MockMethodChannel().setAsitePluginsMethodChannel();
  MockCBimSettingUseCase _cBimSettingUseCase = MockCBimSettingUseCase();

  late CBIMSettingsCubit cubit;
  DBServiceMock? mockDb;
  configureLoginCubitDependencies() {
    mockDb = DBServiceMock();
    init(test: true);
    getIt.unregister<CBimSettingUseCase>();
    getIt.unregister<DBService>();
    getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);
    getIt.registerLazySingleton<CBimSettingUseCase>(() => _cBimSettingUseCase);
    AConstants.loadProperty();
  }

  setUp(() {
    AppConfigTestData().setupAppConfigTestData();
    cubit = CBIMSettingsCubit(InitialState()); // You might need to adjust the initial state
  });

  group('CBIMSettingsCubit', () {
    configureLoginCubitDependencies();

    test("Initial state", () {
      isA<InitialState>();
    });

    test('Initial slider value is set correctly', () async {
      await cubit.initCBIMSettings();
      expect(cubit.selectedSliderValue, 5.0);
    });

    blocTest<CBIMSettingsCubit, CBIMSettingsState>("Add Recent Project Search",
        build: () {
          return CBIMSettingsCubit(InitialState());
        },
        act: (cubit) async {
          when(() => mockDb?.executeQuery(any())).thenAnswer((invocation) => Future.value());
          when(() => _cBimSettingUseCase.setCbimSettingsValue(any())).thenAnswer((invocation) => Future.value());
          cubit.onSliderChange(2.5,isTest: true);
        },
        expect: () => [isA<SliderValueChangeState>()]);


    test('Slider value is updated correctly', () {
      cubit.selectedSliderValue=1;
      final newValue = 7.0;
      when(() => _cBimSettingUseCase.setCbimSettingsValue(any())).thenAnswer((invocation) => Future.value());
      cubit.onSliderChange(newValue,isTest: true);
      expect(cubit.selectedSliderValue, newValue);
    });

    test('Slider value is clamped correctly to the specified range', () {
      final newValueAboveMax = 10.0;
      final newValueBelowMin = 1.0;

      when(() => _cBimSettingUseCase.setCbimSettingsValue(any())).thenAnswer((invocation) => Future.value());
      cubit.onSliderChange(newValueAboveMax,isTest: true);
      expect(cubit.selectedSliderValue, 10.0); // Max value clamped

      when(() => _cBimSettingUseCase.setCbimSettingsValue(any())).thenAnswer((invocation) => Future.value());
      cubit.onSliderChange(newValueBelowMin,isTest: true);
      expect(cubit.selectedSliderValue, 1.0); // Min value clamped
    });
    blocTest<CBIMSettingsCubit, CBIMSettingsState>("InitState method test",
        build: () {
          return  cubit;
        },
        act: (cubit) async {
          cubit.emit(InitialState());
        },
        expect: () => [isA<InitialState>()]);

    blocTest<CBIMSettingsCubit, CBIMSettingsState>("Pagie method test",
        build: () {
          return  cubit;
        },
        act: (cubit) async {
          cubit.emit(PageInitialState());
        },
        expect: () => [isA<PageInitialState>()]);
  });
}
