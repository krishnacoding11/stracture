import 'dart:convert';

import 'package:field/data/model/project_vo.dart';
import 'package:field/data/repository/project_list/project_list_repository.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/utils/constants.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../bloc/mock_method_channel.dart';
import '../../../fixtures/fixture_reader.dart';
import 'project_list_repository_impl_test.mocks.dart';

@GenerateMocks([ProjectListRepository])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MockMethodChannel().setNotificationMethodChannel();
  di.init(test: true);

  di.getIt.registerLazySingleton<MockProjectListRepository>(
      () => MockProjectListRepository());
  late MockProjectListRepository mockProjectListRepository;
  setUp(() async {
    mockProjectListRepository = di.getIt<MockProjectListRepository>();
  });

  final expectedResult = jsonDecode(fixture("project_list_data.json"));
  group("Project list repository implementation: ", () {
    test("instance of List<Project> or not", () async {
      when(mockProjectListRepository.getProjectList(
              1, 20, getRequestMapData(1, 20)))
          .thenAnswer((_) async => getData());
      var result = await mockProjectListRepository.getProjectList(
          1, 20, getRequestMapData(1, 20));
      expect(result, isA<List<Project>>());
    });
    test("Repository getData() success", () async {
      when(mockProjectListRepository.getProjectList(
              1, 20, getRequestMapData(1, 20)))
          .thenAnswer((_) async => getData());
      var result = await mockProjectListRepository.getProjectList(
          1, 20, getRequestMapData(1, 20));
      expect(result, getData());
    });
    test("projectId should be in hashed",(){
      final projectData = jsonDecode(fixture("get_form_list_data.json"));
      final projectId = projectData.toString();
      expect(projectId.contains(Utility.keyDollar), isTrue);

    });
  });
}

List<Project> getData() {
  List<Project> projectList = <Project>[];
  final expectedResult = jsonDecode(fixture("project_list_data.json"));
  for (var item in expectedResult["data"]) {
    projectList.add(Project.fromJson(item));
  }
  return projectList;
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
