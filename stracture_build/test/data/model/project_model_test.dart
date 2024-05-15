import 'dart:convert';

import 'package:field/data/model/project_vo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  group("Project Model:", () {
    final project = Project();
    test("fromJson() method unit testing", () {
      Map<String, dynamic> jsonMap = {};
      final result = Project.fromJson(jsonMap);
      expect(result, project);
    });

    test("toJson() method unit testing", () {
      final result = project.toJson();
      Map<String, dynamic> jsonMap = jsonDecode(fixture("user_null_data.json"));
      expect(result, jsonMap);
    });
  });
}
