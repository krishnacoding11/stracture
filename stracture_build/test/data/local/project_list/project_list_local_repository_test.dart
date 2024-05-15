import 'dart:convert';

import 'package:field/data/local/project_list/project_list_local_repository.dart';
import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/injection_container.dart' as di;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../fixtures/fixture_reader.dart';

class MockProjectListLocalRepository extends Mock implements ProjectListLocalRepository {}

class MockDatabaseManager extends Mock implements DatabaseManager {}

void main() {
  di.getIt.registerLazySingleton<MockProjectListLocalRepository>(() => MockProjectListLocalRepository());
  late MockProjectListLocalRepository mockProjectListLocalRepository;

  setUpAll(() {
    mockProjectListLocalRepository = di.getIt<MockProjectListLocalRepository>();
  });

  test('Offline project List', () async {
    Map<String, dynamic> data = {};

    Map<String, dynamic> map = {};
    map["recordBatchSize"] = "25";
    map["recordStartFrom"] = "0";
    map["applicationId"] = 3;
    map["object_type"] = "PROJECT";
    map["object_attribute"] = "project_id";
    map["searchValue"] = "";
    map["dataFor"] = 2;
    map["sortOrder"] = "asc";
    map["sortField"] = "name";

    /*String query = "SELECT * FROM ${ProjectDao.tableName}";
    if (map.containsKey("dataFor")) {
      query = "$query WHERE ${ProjectDao.isFavoriteField}=${map["dataFor"] == 2 ? 1 : 0}";
      if (map["searchValue"].toString().isNotEmpty) {
        query = "$query AND ${ProjectDao.projectNameField} LIKE '%${map["searchValue"].toString()}%'";
      }
    } else if (map["searchValue"].toString().isNotEmpty) {
      query = "$query WHERE ${ProjectDao.projectNameField} LIKE '%${map["searchValue"].toString()}%'";
    }
    String sortOrder = "ASC";
    if (map.containsKey("sortOrder")) {
      sortOrder = map["sortOrder"].toString();
    }
    query = "$query ORDER BY ${ProjectDao.projectNameField} COLLATE NOCASE $sortOrder";*/

    when(() => mockProjectListLocalRepository.getPopupDataList(0, 25, map))
        .thenAnswer((_) => data = jsonDecode(fixture("popupdata.json")));

    Popupdata project = Popupdata.fromJson(data);
    expect(project, isA<Popupdata>());
  });
}
