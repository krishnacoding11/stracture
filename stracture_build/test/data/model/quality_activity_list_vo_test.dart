import 'dart:convert';
import 'package:field/data/model/offline_folder_list.dart';
import 'package:field/data/model/quality_activity_list_vo.dart';
import 'package:test/test.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  group('QualityActivityList Test', () {

    test('fromJson should convert JSON map to QualityActivityList object', () {
      final Map<String,dynamic> jsonMap = jsonDecode(fixture("quality_activity_listing_response.json"));

      final qualityActivityList = QualityActivityList.fromJson(jsonMap);
      expect(qualityActivityList.response?.root?.activitiesList![0].qiActivityId, equals("6680\$\$mv8AZu"));
      expect(qualityActivityList.response?.root?.activitiesList![0].activityName, equals('logo'));
      expect(qualityActivityList.response?.root?.activitiesList![0].activitySeq, equals(4));

    });

    test('toJson should convert QualityActivityList object to JSON map', () {
      final Map<String,dynamic> jsonMap = jsonDecode(fixture("quality_activity_listing_response.json"));

      final qualityActivityList = QualityActivityList.fromJson(jsonMap);
      final Map<String,dynamic> convertedJsonMap=qualityActivityList.toJson();
      expect(convertedJsonMap["response"]["root"]["activitiesList"][0]["qiActivityId"], equals("6680\$\$mv8AZu"));
      expect(convertedJsonMap["response"]["root"]["activitiesList"][0]["activityName"], equals('logo'));
      expect(convertedJsonMap["response"]["root"]["activitiesList"][0]["activitySeq"], equals(4));

    });

    test('fromJson should convert JSON map to QualityActivityListResponse object', () {
      final Map<String,dynamic> jsonMap = jsonDecode(fixture("quality_activity_listing_response.json"));

      final qualityActivityListResponse = Response.fromJson(jsonMap["response"]);
      expect(qualityActivityListResponse?.root?.activitiesList![0].qiActivityId, equals("6680\$\$mv8AZu"));
      expect(qualityActivityListResponse?.root?.activitiesList![0].activityName, equals('logo'));
      expect(qualityActivityListResponse?.root?.activitiesList![0].activitySeq, equals(4));

    });

    test('toJson should convert QualityActivityListResponse object to JSON map', () {
      final Map<String,dynamic> jsonMap = jsonDecode(fixture("quality_activity_listing_response.json"));

      final qualityActivityListResponse = Response.fromJson(jsonMap["response"]);
      final Map<String,dynamic> convertedJsonMap=qualityActivityListResponse.toJson();
      expect(convertedJsonMap["root"]["activitiesList"][0]["qiActivityId"], equals("6680\$\$mv8AZu"));
      expect(convertedJsonMap["root"]["activitiesList"][0]["activityName"], equals('logo'));
      expect(convertedJsonMap["root"]["activitiesList"][0]["activitySeq"], equals(4));

    });

    test('fromJson should convert JSON map to QualityActivityList object', () {
      final Map<String,dynamic> jsonMap = jsonDecode(fixture("quality_activity_listing_response.json"));

      final qualityActivityList = ActivitiesList.fromJson(jsonMap["response"]["root"]["activitiesList"][0]);
      expect(qualityActivityList.qiActivityId, equals("6680\$\$mv8AZu"));
      expect(qualityActivityList.activityName, equals('logo'));
      expect(qualityActivityList.associationType ,equals(1));
      expect(qualityActivityList.creationDate, equals("2023-04-21 09:53:42.31"));
      expect(qualityActivityList.updatedById,equals("643944\$\$tWd9hd"));
      expect(qualityActivityList.generateURI,equals(true));
      expect(qualityActivityList.isDeleted,equals(false));
      expect(qualityActivityList.updationDate,equals("2023-04-26 12:03:12.603"));
      expect(qualityActivityList.appTypeId,equals(0));
      expect(qualityActivityList.templateTypeId,equals(0));
      expect(qualityActivityList.formTypeName,equals(null));
      expect(qualityActivityList.instanceGroupId,equals(null));
      expect(qualityActivityList.isAccess,equals(true));
      expect(qualityActivityList.subOperation,equals(""));
      expect(qualityActivityList.isCalibrated,equals(false));
      expect(qualityActivityList.activityType,equals(0));
      expect(qualityActivityList.appBuilderCode,equals(null));
      expect(qualityActivityList.createdById,equals("643944\$\$tWd9hd"));


    });

    test('toJson should convert QualityActivityList object to JSON map', () {
      final Map<String,dynamic> jsonMap = jsonDecode(fixture("quality_activity_listing_response.json"));

      final qualityActivityList = ActivitiesList.fromJson(jsonMap["response"]["root"]["activitiesList"][0]);
      final Map<String,dynamic> convertedJsonMap=qualityActivityList.toJson();
      expect(convertedJsonMap["qiActivityId"], equals("6680\$\$mv8AZu"));
      expect(convertedJsonMap["activityName"], equals('logo'));
      expect(convertedJsonMap["associationType"] ,equals(1));
      expect(convertedJsonMap["creationDate"], equals("2023-04-21 09:53:42.31"));
      expect(convertedJsonMap["updatedById"],equals("643944\$\$tWd9hd"));
      expect(convertedJsonMap["generateURI"],equals(true));
      expect(convertedJsonMap["isDeleted"],equals(false));
      expect(convertedJsonMap["updationDate"],equals("2023-04-26 12:03:12.603"));
      expect(convertedJsonMap["appTypeId"],equals(0));
      expect(convertedJsonMap["template_type_id"],equals(0));
      expect(convertedJsonMap["formTypeName"],equals(null));
      expect(convertedJsonMap["instanceGroupId"],equals(null));
      expect(convertedJsonMap["isAccess"],equals(true));
      expect(convertedJsonMap["subOperation"],equals(""));
      expect(convertedJsonMap["isCalibrated"],equals(false));
      expect(convertedJsonMap["activityType"],equals(0));
      expect(convertedJsonMap["appBuilderCode"],equals(null));
      expect(convertedJsonMap["createdById"],equals("643944\$\$tWd9hd"));

    });

  });
}
