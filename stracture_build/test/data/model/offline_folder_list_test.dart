import 'dart:convert';
import 'package:field/data/model/offline_folder_list.dart';
import 'package:test/test.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  group('OfflineFolderList Test', () {

    test('fromJson should convert JSON map to OfflineFolderList object', () {
      final Map<String,dynamic> jsonMap = jsonDecode(fixture("project_and_location_list.json"));

      final offlineFolderListVo = OfflineFolderList.fromJson(jsonMap);
      expect(offlineFolderListVo.responseData[0].workspaceList![0].projectId, equals("2130192\$\$fIdR2g"));
      expect(offlineFolderListVo.responseData[0].workspaceList![0].projectName, equals('Site Quality Demo'));
      expect(offlineFolderListVo.responseData[0].workspaceList![0].projectAdmins, equals('859155'));

    });

    test('toJson should convert OfflineFolderList object to JSON map', () {
      final Map<String,dynamic> jsonMap = jsonDecode(fixture("project_and_location_list.json"));

      final offlineFolderListVo = OfflineFolderList.fromJson(jsonMap);
      final Map<String,dynamic> convertedJsonMap=offlineFolderListVo.toJson();
      expect(convertedJsonMap["ResponseData"][0]["workspaceList"][0]["projectID"], equals("2130192\$\$fIdR2g"));
      expect(convertedJsonMap["ResponseData"][0]["workspaceList"][0]["projectName"], equals('Site Quality Demo'));
      expect(convertedJsonMap["ResponseData"][0]["workspaceList"][0]["projectAdmins"], equals('859155'));

    });

  });
}
