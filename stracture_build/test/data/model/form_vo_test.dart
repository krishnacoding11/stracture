import 'dart:convert';

import 'package:field/data/model/form_vo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  dynamic formResponse;
  late List<SiteForm> siteFormList;
  setUp(() {
    formResponse = jsonDecode(fixture("form_vo_list.json"));
    siteFormList = List<SiteForm>.from(formResponse.map((x) => SiteForm.fromJson(x))).toList();
  });

  group("Form Model:", () {
    test("fromJson() method unit testing", () {
      SiteForm siteForm = siteFormList.first;
      Map<String, dynamic> jsonMap = siteForm.toJson();
      final result = SiteForm.fromJson(jsonMap);
      expect(result.projectId, equals("2116416\$\$soEFSz"));
      expect(result.projectName, equals("!!PIN_ANY_APP_TYPE_20_9"));
      expect(result.formId, equals("11599419\$\$H1XUFB"));
      expect(result.commId, equals("11599419\$\$UXDKQE"));
      expect(result.orgId, equals("5763307\$\$lEEdAj"));
      expect(result.originatorDisplayName, equals("Mayur Raval m., Asite Solutions Ltd"));
    });

    test("toJson() method unit testing", () {
      SiteForm siteForm = siteFormList.first;
      Map<String, dynamic> jsonMap = siteForm.toJson();
      expect(jsonMap["projectId"], equals("2116416\$\$soEFSz"));
      expect(jsonMap["projectName"], equals("!!PIN_ANY_APP_TYPE_20_9"));
      expect(jsonMap["formId"], equals("11599419\$\$H1XUFB"));
      expect(jsonMap["commId"], equals("11599419\$\$UXDKQE"));
      expect(jsonMap["orgId"], equals("5763307\$\$lEEdAj"));
      expect(jsonMap["originatorDisplayName"], equals("Mayur Raval m., Asite Solutions Ltd"));
    });

    test("offlineformSyncJson method unit testing", () {
      SiteForm siteForm = siteFormList.first;
      Map<String, dynamic> jsonMap = siteForm.toJson();
      expect(jsonMap["projectId"], equals("2116416\$\$soEFSz"));
      expect(jsonMap["projectName"], equals("!!PIN_ANY_APP_TYPE_20_9"));
      expect(jsonMap["formId"], equals("11599419\$\$H1XUFB"));
      expect(jsonMap["commId"], equals("11599419\$\$UXDKQE"));
      expect(jsonMap["orgId"], equals("5763307\$\$lEEdAj"));
      expect(jsonMap["originatorDisplayName"], equals("Mayur Raval m., Asite Solutions Ltd"));
    });

    test("offlineformListFromSyncJson method unit testing", () {
      final result= SiteForm.offlineformListFromSyncJson(formResponse);
      // Check the individual instances in the list
      final vo1 = result[0];
      Map<String, dynamic> jsonMap = vo1.toJson();
      expect(jsonMap["projectId"], equals("2116416\$\$soEFSz"));
      expect(jsonMap["projectName"], equals(null));
      expect(jsonMap["formId"], equals("11599419\$\$H1XUFB"));
      expect(jsonMap["commId"], equals("11599419\$\$UXDKQE"));
      expect(jsonMap["orgId"], equals("5763307\$\$lEEdAj"));
      expect(jsonMap["originatorDisplayName"], equals("Mayur Raval m., Asite Solutions Ltd"));// We haven't provided the projectId in the constructor

      final vo2 = result[1];
       Map<String, dynamic> jsonMap2 = vo2.toJson();
       expect(jsonMap2["projectId"], equals("2116416\$\$soEFSz"));
       expect(jsonMap2["projectName"], equals(null));
       expect(jsonMap2["formId"], equals("11599419\$\$H1XUFB"));
       expect(jsonMap2["commId"], equals("11599419\$\$UXDKQE"));
       expect(jsonMap2["orgId"], equals("5763307\$\$lEEdAj"));
       expect(jsonMap2["originatorDisplayName"], equals("Mayur Raval m., Asite Solutions Ltd"));
    });

  });
}
