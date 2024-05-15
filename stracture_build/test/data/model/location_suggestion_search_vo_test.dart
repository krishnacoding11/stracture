import 'dart:convert';

import 'package:field/data/model/form_vo.dart';
import 'package:field/data/model/location_suggestion_search_vo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/fixture_reader.dart';

void main() {

  group("Location Suggestion Search Model Test :", () {
    test("fromJson() method unit testing", () {
      final jsonString = '{"searchKey": "Ahmedabad", "searchCount": "123"}';
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      SearchDropdownList searchDropdownList = SearchDropdownList.fromJson(jsonMap);
      expect(searchDropdownList.searchKey, equals("Ahmedabad"));
      expect(searchDropdownList.searchCount, equals("123"));
    });

    test("toJson() method unit testing", () {
      final searchDropdownList = SearchDropdownList("Ahmedabad","123");
      final jsonMap = searchDropdownList.toJson();
      expect(jsonMap["searchKey"], equals("Ahmedabad"));
      expect(jsonMap["searchCount"], equals("123"));
    });
  });
}
