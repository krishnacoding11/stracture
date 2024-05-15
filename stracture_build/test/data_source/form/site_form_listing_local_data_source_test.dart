import 'package:field/database/db_manager.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/sync/calculation/site_form_listing_local_data_soruce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDatabaseManager extends Mock implements DatabaseManager {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SiteFormListingLocalDataSource? dbManager = SiteFormListingLocalDataSource();
  MockDatabaseManager mockDatabaseManager = MockDatabaseManager();

  group("SiteFormListingLocalDataSource",() {

    test("getOfflineObservationListJson",() async {
      
      var map = Map<String,dynamic>();
      map["projectId"] = "123234";
      map["locationId"] = "41232";
      map["appType"] = "2";
      map["applicationId"] = "3";
      map["checkHashing"] = "false";
      map["isRequiredTemplateData"] = "true";
      map["requiredCustomAttributes"] =
      "CFID_Assigned,CFID_DefectTyoe,CFID_TaskType";
      map["customAttributeFieldPresent"] = "true";
      map["sortField"] = "title";
      map["sortFieldType"] = "text";
      map["sortOrder"] = "desc";

      var res = await dbManager.getOfflineObservationListJson(map);
      expect(res, isA<FAIL>());
    });
  });
}