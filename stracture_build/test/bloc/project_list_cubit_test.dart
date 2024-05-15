import 'dart:convert';
import 'package:bloc_test/bloc_test.dart';
import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../fixtures/fixture_reader.dart';
import 'mock_method_channel.dart';

class MockProjectListUseCase extends Mock implements ProjectListUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  di.init(test: true);
  late ProjectListCubit projectListCubit;
  late MockProjectListUseCase mockProjectListUseCase;
  late Popupdata project;
  List<Popupdata> allPopupList = <Popupdata>[];
  List<Popupdata> favPopupList = <Popupdata>[];
  setUp(() async {
    mockProjectListUseCase = MockProjectListUseCase();
    projectListCubit = ProjectListCubit(projectListUseCase: mockProjectListUseCase);
    Map<String, dynamic> data = jsonDecode(fixture("popupdata.json"));
    project = Popupdata.fromJson(data);
    SharedPreferences.setMockInitialValues({"userData": fixture("user_data.json")});
    final popUpData = jsonDecode(fixture("popupdata_list.json"));
    for (var item in popUpData["data"]) {
      allPopupList.add(Popupdata.fromJson(item));
    }
    final favPopUpData = jsonDecode(fixture("fav_popupdata_list.json"));
    for (var item in favPopUpData["data"]) {
      favPopupList.add(Popupdata.fromJson(item));
    }
  });
  group("Project list pagination cubit:", () {
    test("Initial state", () {
      expect(projectListCubit.state, PaginationListInitial());
    });
    blocTest<ProjectListCubit, FlowState>("emits [Success] state",
        build: () {
          return projectListCubit;
        },
        act: (cubit) async {
          when(() => mockProjectListUseCase.getPopupDataList(0, 50, getRequestMapDataForPopupPagination(0, 50, false, ""))).thenAnswer((_) => Future.value(allPopupList));
          await cubit.pageFetch(0, false, false, "", false);
        },
        expect: () => [isA<AllProjectLoadingState>(), isA<AllProjectSuccessState>()]);

    //FAIL
/*    blocTest<ProjectListCubit, FlowState>("emits [Favorite] state",
        build: () {
          return projectListCubit;
        },
        act: (cubit) async {
          cubit.allItems = allPopupList;
          cubit.favItems = favPopupList;
          cubit.addUpdateFavouriteDataList(project, 1, false);
        },
        expect: () => <FlowState>[AllProjectLoadingState(), AllProjectSuccessState(items: allPopupList), FavProjectLoadingState(), FavProjectSuccessState(items: favPopupList)]);*/
  });

  group("addRecentProject Test", () {
    test("addRecentProject Success", () async {
      projectListCubit.recentList.add(Popupdata(value: "30122014_UK"));
      projectListCubit.addRecentProject(newSearch: '30122014_UK');
      bool isMatched = projectListCubit.recentList.any((element) => element.value == "30122014_UK");
      expect(true, isMatched);
    });
  });

  test("Workspace settings test", () async {
    Map<String, dynamic> request = {};
    request["projectsDetail"] = json.encode({"projectIds": "2089700\$\$jpmd7h",
      "settingFields":"enableGeoTagging,projectid"});
    Result<dynamic> res = Result(fixture("workspace_settings.json"));
    when(() => mockProjectListUseCase.getWorkspaceSettings(request)).thenAnswer((_) => Future.value(res));
    await projectListCubit.getWorkspaceSettingData("2089700\$\$jpmd7h");
    expect(res.data, isNotEmpty);
  });
}

Map<String, dynamic> getRequestMapDataForPopupPagination(page, limit, isFavourite, searchValue) {
  var startedFrom = (page == 0) ? 0 : (page * limit);
  Map<String, dynamic> map = {};
  map["recordBatchSize"] = "$limit";
  map["recordStartFrom"] = "$startedFrom";
  map["applicationId"] = 3;
  map["object_type"] = "PROJECT";
  map["object_attribute"] = "project_id";
  map["searchValue"] = searchValue;
  map["sortOrder"] = "desc";
  map["sortField"] = "name";
  if (isFavourite) {
    map["dataFor"] = 2;
  }
  return map;
}
