import 'dart:async';
import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/Filter/filter_cubit.dart';
import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/database/db_service.dart';
import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mocktail/mocktail.dart';
// import 'package:field/offline_injection_container.dart' as di;
import 'package:field/injection_container.dart' as di;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/appconfig_test_data.dart';
import '../../../fixtures/fixture_reader.dart';
import '../../../utils/load_url.dart';

class MockFilterCubit extends MockCubit<FlowState>
    implements FilterCubit {}

class DBServiceMock extends Mock implements DBService {}

class ProjectListUseCaseMock  extends Mock implements ProjectListUseCase{}
class FilterUserCaseMock extends Mock implements FilterUseCase{}


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  DBServiceMock? mockDb;
  ProjectListUseCaseMock? mockUseCase;
  MockFilterCubit? filterCubit;
  FilterUserCaseMock? filterUsecase;
  ProjectListCubit? projectListCubit;



  Map<String, dynamic>? map;
  final popUpData = json.decode(fixture('popupdata_list.json'));

  Map<String, dynamic> projectData = jsonDecode(fixture("popupdata.json"));
  final projectpopupData = Popupdata.fromJson(projectData);
  Project? mockProject;
  var apptypeList = [];
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);
  configureDependencies() {
    mockDb = DBServiceMock();
    mockUseCase = ProjectListUseCaseMock();
    filterUsecase = FilterUserCaseMock();
    filterCubit = MockFilterCubit();
    mockProject = mockProjectListData().last;
    MockMethodChannel().setAsitePluginsMethodChannel();
    // SharedPreferences.cle
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json"), "cloud_type_data": "1", "1_u1_project_": fixture("project.json"),AConstants.recentProject : jsonEncode(['project'])});
    // SharedPreferences.setMockInitialValues({
    //   "1_u1_project_":fixture("project.json"),
    //   AConstants.recentProject : jsonEncode(['project'])
    // });

    // di.getIt.unregister<DBService>();
    // di.getIt.registerFactoryParam<DBService, String, void>((filePath, _) => mockDb!);

    di.getIt.unregister<ProjectListUseCase>();
    di.getIt.registerLazySingleton<ProjectListUseCase>(() => mockUseCase!);

    di.getIt.unregister<FilterUseCase>();
    di.getIt.registerLazySingleton<FilterUseCase>(() => filterUsecase!);

    di.getIt.unregister<FilterCubit>();
    di.getIt.registerFactory<FilterCubit>(
            () => filterCubit!); //mockProjectListCubit

    projectListCubit = ProjectListCubit();
    map = projectListCubit!.getRequestMapDataForPopupPagination(
        0, 50, false, "");
    map?["sortOrder"] = 'asc';
    map?["sortField"] = "name";


    final appTypeListData = jsonDecode(fixture("app_type_list.json"));
    for (var item in appTypeListData["data"]) {
      apptypeList.add(AppType.fromJson(item));
    }
    AppConfigTestData().setupAppConfigTestData();
    MockMethodChannelUrl().setupBuildFlavorMethodChannel();
    MockMethodChannel().setUpGetApplicationDocumentsDirectory();

    AConstants.loadProperty();
  }
  setUp(() {
    configureDependencies();
  });

  tearDown(() {
    mockDb = null;
    mockUseCase = null;
    filterCubit = null;
    projectListCubit = null;
  });

  group("Offline project list Test", () {
    test('Project list test', () async {
      when(()=> mockUseCase?.getPopupDataList(0, 50, map!)).thenAnswer((_) => Future.value((List<Popupdata>.from(popUpData['data'].map((x) => Popupdata.fromJson(x))))));

      await projectListCubit?.pageFetch(0, false, true, "", true);

      verify(() => mockUseCase?.getPopupDataList(0, 50, map!)).called(1);

      // verify(() => mockUseCase!.formOtherActionTaskToServer(any())).called(1);
      // verify(() => mockDb!.executeQuery(removeQuery)).called(1);
    });

    test('Project detail from QR',() async{
      //await _projectListUseCase.getProjectList(0, 2, projectId)
      when(()=>mockUseCase?.getProjectList(0, 2,'2093447\$\$RGFbr7')).thenAnswer((_) => Future.value([mockProject!]));
      await projectListCubit?.getProjectDetailQr('2093447\$\$RGFbr7');
      verify(() => mockUseCase?.getProjectList(0, 2,'2093447\$\$RGFbr7')).called(1);
    });
    blocTest<ProjectListCubit, FlowState>("emits [Success] state",
        build: () {
          return projectListCubit!;
        },
        act: (cubit) async {
          when(() => mockUseCase?.getPopupDataList(0, 50, map!)).thenAnswer((_) => Future.value(List<Popupdata>.from(popUpData['data'].map((x) => Popupdata.fromJson(x)))));
          await cubit.pageFetch(0, false, false, "", true);
        },
        expect: () => [isA<AllProjectLoadingState>(), isA<AllProjectSuccessState>()]);
    blocTest<ProjectListCubit, FlowState>("emits [Favorite] state success",
        build: () {
          return projectListCubit!;
        },
        act: (cubit) async {
          cubit.allItems = List<Popupdata>.from(popUpData['data'].map((x) => Popupdata.fromJson(x)));
          List<Popupdata> favPopupList = cubit.allItems.where((element) => element.imgId == 1).toList();
          cubit.favItems = favPopupList;
          when(() => mockUseCase?.setFavProject(cubit.getFavouriteProjectMapData(projectpopupData, 1))).thenAnswer((_) async => Future.value(SUCCESS('SUCCESS',null,200)));

          await cubit.favouriteProject(projectpopupData, 1, false);
          verify(() => mockUseCase?.setFavProject(cubit.getFavouriteProjectMapData(projectpopupData, 1))).called(1);
          // cubit.addUpdateFavouriteDataList(projectpopupData, 1, false);
        },
        expect: () => [isA<AllProjectLoadingState>(), isA<AllProjectSuccessState>(), isA<FavProjectLoadingState>(), isA<FavProjectSuccessState>()]);
    blocTest<ProjectListCubit, FlowState>("emits [Favorite] state failure",
        build: () {
          return projectListCubit!;
        },
        act: (cubit) async {
          cubit.allItems = List<Popupdata>.from(popUpData['data'].map((x) => Popupdata.fromJson(x)));
          List<Popupdata> favPopupList = cubit.allItems.where((element) => element.imgId == 1).toList();
          cubit.favItems = favPopupList;
          when(() => mockUseCase?.setFavProject(cubit.getFavouriteProjectMapData(projectpopupData, 1))).thenAnswer((_) async => Future.value(FAIL('FAIL',204)));

          await cubit.favouriteProject(projectpopupData, 1, false);
          verify(() => mockUseCase?.setFavProject(cubit.getFavouriteProjectMapData(projectpopupData, 1))).called(1);
          // cubit.addUpdateFavouriteDataList(projectpopupData, 1, false);
        },
        expect: () => [isA<AllProjectLoadingState>(), isA<AllProjectSuccessState>(), isA<FavProjectLoadingState>(), isA<FavProjectSuccessState>(),isA<AllProjectLoadingState>(), isA<AllProjectSuccessState>(), isA<FavProjectLoadingState>(), isA<FavProjectSuccessState>()]);

    blocTest<ProjectListCubit, FlowState>("get project detail success state",
        build: () {
          return projectListCubit!;
        },
        act: (cubit) async {
            when(()=> filterCubit?.getFilterAttributeList('2')).thenAnswer((_) async => Future.value(SUCCESS(apptypeList, null, 200)));
            await filterCubit?.getFilterAttributeList('2');
            verify(() => filterCubit?.getFilterAttributeList('2')).called(1);
            // verify(() => mockUseCase!.formOtherActionTaskToServer(any())).called(1);
            // verify(() => mockDb!.executeQuery(removeQuery)).called(1);
          when(() => mockUseCase?.getProjectList(0, 2, projectpopupData.id ?? "0")).thenAnswer((_) => Future.value([mockProject!]));
          await cubit.getProjectDetail(projectpopupData, false);
        },
        expect: () => [isA<ProjectDetailSuccessState>()]);
    test("addRecentProject Success", () async {
      projectListCubit?.recentList.add(Popupdata(value: "30122014_UK"));
      projectListCubit?.addRecentProject(newSearch: '30122014_UK');
      bool? isMatched = projectListCubit?.recentList.any((element) => element.value == "30122014_UK");
      expect(false, !isMatched!);
    });

    test("Project is marked offline Success", () async {
      when(()=> mockUseCase?.isProjectMarkedOffline()).thenAnswer((_) async => Future.value(true));
      bool? isMatched = await projectListCubit?.isProjectMarkedOffline();
      expect(false, !isMatched!);
    });
    test("Project locations are marked offline Success", () async {
      bool? isMatched = await projectListCubit?.isProjectLocationMarkedOffline(false);
      expect(true, isMatched!);
    });
    blocTest<ProjectListCubit, FlowState>("emits [Success] suggested project list state",
        build: () {
          return projectListCubit!;
        },
        act: (cubit) async {
          when(() => mockUseCase?.getPopupDataList(0, 10, cubit.getRequestMapDataForPopupPagination(0, 10, false, 'abc'))).thenAnswer((_) => Future.value([projectpopupData]));
          await cubit.getSuggestedSearchList(0, false, false, 'abc');
        });
    // test('Get recent project list',() async{
    //
    //   //await _projectListUseCase.getProjectList(0, 2, projectId)
    //   var recentList = await projectListCubit?.getRecentProject();
    //   expect((recentList?.length!),0);
    // });
  });
}
List<Project> mockProjectListData() {
  List<Project> projectList = <Project>[];
  final expectedResult = jsonDecode(fixture("project_list_data.json"));
  for (var item in expectedResult["data"]) {
    projectList.add(Project.fromJson(item));
  }
  return projectList;
}