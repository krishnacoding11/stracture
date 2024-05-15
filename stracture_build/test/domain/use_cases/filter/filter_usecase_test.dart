

import 'package:field/data/remote/Filter/filter_repositroy_impl.dart';
import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/internet_cubit.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/file_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appconfig_test_data.dart';
import '../../../fixtures/fixture_reader.dart';

class MockFilterRepository extends Mock implements FilterRemoteRepository {}
class MockInternetCubit extends Mock implements InternetCubit {}
class FileUtilityMock extends Mock implements FileUtility {}
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  MockFilterRepository? mockFilterRepository;
  FilterUseCase? filterUseCase;
  final mockInternetCubit = MockInternetCubit();
  FileUtilityMock? mockFileUtility;
  di.init(test: true);
  AppConfigTestData().setupAppConfigTestData();
  SharedPreferences.setMockInitialValues(
      {"userData": fixture("user_data.json")});

  setUpAll(() => () async {
    MockMethodChannel().setConnectivityMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();
  });

  setUp(() async {
    filterUseCase = FilterUseCase();
    mockFilterRepository = MockFilterRepository();
    mockFileUtility = FileUtilityMock();
    di.getIt.unregister<FileUtility>();
    di.getIt.unregister<FilterRemoteRepository>();
    di.getIt.unregister<InternetCubit>();
    di.getIt.registerLazySingleton<FileUtility>(() => mockFileUtility!);
    di.getIt.registerLazySingleton<FilterRemoteRepository>(() => mockFilterRepository!);
    di.getIt.registerFactory<InternetCubit>(() => mockInternetCubit);
    when(() => mockInternetCubit.isNetworkConnected).thenReturn(true);
  });

  tearDown(() {
    reset(mockFileUtility);
    reset(mockFilterRepository);
    reset(mockInternetCubit);
  });


  group("Test Filter UseCase", () {
    test("getFilterDataForDefect success", () async {
      Result? result1 = SUCCESS(fixture('filter_data_for_defect.json'), null, 200);
      when(() => mockFilterRepository!.getFilterDataForDefect(any())).thenAnswer((_) => Future.value(result1));
      when(() => mockFileUtility!.getFilterFilePath(fileName: '2_filter_list.json')).thenAnswer((_) => Future.value("/test/fixtures/files/2_filter_list.json"));
      var response1 = await filterUseCase!.getFilterDataForDefect({});
      expect(response1, isA<Result>());
      when(() => mockFileUtility!.readDataFromFile(any())).thenAnswer((_) => Future.value(fixtureFileContent('files/2_filter_list.json')));
      var list = await filterUseCase!.readSiteFilterList();
      expect(list.isNotEmpty, true);
      when(() => mockFileUtility!.getFilterFilePath(fileName: 'siteList_filter.json')).thenAnswer((_) => Future.value("/test/fixtures/files/siteList_filter.json"));

      when(() => mockFileUtility!.readDataFromFile(any())).thenAnswer((_) => Future.value(fixtureFileContent('files/siteList_filter.json')));
      var map = await filterUseCase!.readSiteFilterData(curScreen: FilterScreen.screenSite);
      await filterUseCase!.saveSiteFilterData(map,curScreen: FilterScreen.screenSite);
      expect(map.isNotEmpty, true);
      var stringData = await filterUseCase!.getSiteFilterJson(map,list,curScreen:FilterScreen.screenSite,isNeedToSave: false);
      expect(stringData.isNotEmpty, true);
      var mapData = await filterUseCase!.getTaskDefaultFilterList(list);
      expect(mapData?.isNotEmpty, true);

       when(() => mockFileUtility!.getFilterFilePath(fileName: 'taskList_filter.json')).thenAnswer((_) => Future.value("/test/fixtures/files/taskList_filter.json"));
       when(() => mockFileUtility!.readDataFromFile(any())).thenAnswer((_) => Future.value(fixtureFileContent('files/taskList_filter.json')));
       var map2 = await filterUseCase!.readSiteFilterData(curScreen: FilterScreen.screenTask);
      when(() => mockFileUtility!.getFilterFilePath(fileName: '2_filter_list.json')).thenAnswer((_) => Future.value("/test/fixtures/files/2_filter_list.json"));
      when(() => mockFileUtility!.readDataFromFile(any())).thenAnswer((_) => Future.value(fixtureFileContent('files/2_filter_list.json')));
      var list2 = await filterUseCase!.readSiteFilterList();
      await filterUseCase!.saveSiteFilterData(map2,curScreen: FilterScreen.screenTask);
      var stringData1 = await filterUseCase!.getSiteFilterJson(map2,list2,curScreen:FilterScreen.screenTask,isNeedToSave: true);
      expect(stringData1.isNotEmpty, true);
      await filterUseCase!.applyDashboardNewTaskFilter();
      await filterUseCase!.applyDashboardDueTodayFilter();
      await filterUseCase!.applyDashboardDueThisWeekFilter();
      await filterUseCase!.applyDashboardOverDueFilter();
      expect(map2.isNotEmpty, true);
      expect(list2.isNotEmpty, true);
    });
    test(" getFilterSearchData success", () async {
      Result? result2 = SUCCESS(fixture('filter_search_data.json'), null, 200);
      when(() => mockFilterRepository!.getFilterSearchData(any())).thenAnswer((_) => Future.value(result2));
      var response2 = await filterUseCase!.getFilterSearchData({});
      expect(response2, isA<Result>());
    });
    test("getFilterDataForDefect fail", () async {
      Result? result3 = FAIL(null, 400);
      when(() => mockFilterRepository!.getFilterDataForDefect(any())).thenAnswer((_) => Future.value(result3));
      var response3 = await filterUseCase!.getFilterDataForDefect({});
      expect(response3!.data == null, true);
    });

    test("getFilterSearchData fail", () async {
      Result? result4 = FAIL(null, 400);
      when(() => mockFilterRepository!.getFilterSearchData(any())).thenAnswer((_) => Future.value(result4));
      var response4 = await filterUseCase!.getFilterSearchData({});
      expect(response4!.data == null, true);
    });
    test("getFilterFileName", () async {
      var array = [FilterScreen.screenSite,FilterScreen.screenTask,FilterScreen.screenUndefined];
      var value = ["siteList","taskList","unknownList"];
      for(int i=0;i < array.length;i++) {
        var data =  filterUseCase!.getFilterFileName(array[i]);
        expect(data == value[i], true);
      }
    });


  });
}
