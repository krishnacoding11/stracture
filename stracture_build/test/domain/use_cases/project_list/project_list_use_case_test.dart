import 'dart:convert';

import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/domain/use_cases/project_list/project_list_use_case.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';

class MockProjectListUseCase extends Mock implements ProjectListUseCase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();

  di.init(test: true);

  di.getIt.registerLazySingleton<MockProjectListUseCase>(
      () => MockProjectListUseCase());
  late MockProjectListUseCase mockProjectListUseCase;
  setUp(() async {
    mockProjectListUseCase = di.getIt<MockProjectListUseCase>();
  });

  group("Project list use case:", () {
    test("Project list is instance of List<Project> or not", () async {
      when(() => mockProjectListUseCase.getProjectList(1, 20, AConstants.allProjectsItemId)).thenAnswer((_) {
        return Future.value(mockProjectListData());
      });
      var result =
      await mockProjectListUseCase.getProjectList(1, 20, AConstants.allProjectsItemId);
      expect(result, isA<List<Project>>());
    });
    test("use case mockProjectListData() success", () async {
      when(() => mockProjectListUseCase.getProjectList(1, 20, AConstants.allProjectsItemId)).thenAnswer((_) {
        return Future.value(mockProjectListData());
      });
      var result =
      await mockProjectListUseCase.getProjectList(1, 20, AConstants.allProjectsItemId);
      expect(result, mockProjectListData());
    });
    test("use case Workspace settings test", () async{
      Map<String, dynamic> request = {};
      request["projectsDetail"] = json.encode({"projectIds": "2089700\$\$jpmd7h",
        "settingFields":"enableGeoTagging,projectid"});
      when(() => mockProjectListUseCase.getWorkspaceSettings(request)).thenAnswer((_) {
        return Future.value(Result(fixture("workspace_settings.json")));
      });
      var result = await mockProjectListUseCase.getWorkspaceSettings(request);
      expect(result, isA<Result>());
    });
  });

  group("Popup list list use case:", () {
    test("Popup list is instance of List<Project> or not", () async {
      when(() => mockProjectListUseCase.getPopupDataList(1, 20, getRequestMapDataForPopupPagination(1, 20, false, ""))).thenAnswer((_) {
        return Future.value(mockPopupListData());
      });
      var result = await mockProjectListUseCase.getPopupDataList(1, 20, getRequestMapDataForPopupPagination(1, 20, false, ""));
      expect(result, isA<List<Popupdata>>());
    });
    test("use case mockPopupListData() success", () async {
      when(() => mockProjectListUseCase.getPopupDataList(1, 20, getRequestMapDataForPopupPagination(1, 20, false, ""))).thenAnswer((_) {
        return Future.value(mockPopupListData());
      });
      var result = await mockProjectListUseCase.getPopupDataList(1, 20, getRequestMapDataForPopupPagination(1, 20, false, ""));
      expect(result, mockPopupListData());
    });
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

List<Popupdata> mockPopupListData() {
  List<Popupdata> list = <Popupdata>[];
  final expectedResult = jsonDecode(fixture("popupdata_list.json"));
  for (var item in expectedResult["data"]) {
    list.add(Popupdata.fromJson(item));
  }
  return list;
}

Map<String, dynamic> getRequestMapData(page, limit) {
  var startedFrom = (page == 0) ? 0 : (page * limit) - 1;
  Map<String, dynamic> map = {};
  map["isPrivilegesRequired"] = "true";
  map["recordBatchSize"] = "$limit";
  map["recordStartFrom"] = "$startedFrom";
  map["projectIds"] = AConstants.allProjectsItemId;
  map["checkHashing"] = "false";
  map["searchProjectIds"] = "";
  map["appType"] = "2";
  return map;
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
  if (isFavourite) {
    map["dataFor"] = 2;
  }
  return map;
}