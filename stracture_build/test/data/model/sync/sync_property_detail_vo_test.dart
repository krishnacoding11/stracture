import 'dart:convert';

import 'package:field/data/model/sync/sync_property_detail_vo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SyncManagerPropertyDetails', () {
    test('Default constructor should set default values', () {
      final propertyDetails = SyncManagerPropertyDetails();

      expect(propertyDetails.fieldFormListCount, 25);
      expect(propertyDetails.maxThreadForMobileDevice, 3);
      expect(propertyDetails.fieldOfflineLocationSizeSyncLimit, 100);
      expect(propertyDetails.akamaiDownloadLimit, 1000000);
      expect(propertyDetails.fieldBatchDownloadSize, 250000);
      expect(propertyDetails.fieldBatchDownloadFileLimit, 250);
      expect(propertyDetails.fieldFormMessageListCount, 5);
      expect(propertyDetails.fieldCustomAttributeSetIdLimit, 5);
    });

    test('fromJson should correctly parse JSON data', () {
      final jsonData = {
        'fieldFormListCount': 50,
        'maxThreadForMobileDevice': 5,
        'fieldOfflineLocationSizeSyncLimit': 200,
        'akamaiDownloadLimit': 2000000,
        'fieldBatchDownloadSize': 500,
        'fieldBatchDownloadFileLimit': 500,
        'fieldFormMessageListCount': 10,
        'fieldCustomAttributeSetIdLimit': 10,
      };

      final jsonString = jsonEncode(jsonData);
      final propertyDetails = SyncManagerPropertyDetails.fromJson(jsonString);

      expect(propertyDetails.fieldFormListCount, 50);
      expect(propertyDetails.maxThreadForMobileDevice, 5);
      expect(propertyDetails.fieldOfflineLocationSizeSyncLimit, 200);
      expect(propertyDetails.akamaiDownloadLimit, 2000);
      expect(propertyDetails.fieldBatchDownloadSize, 500000);
      expect(propertyDetails.fieldBatchDownloadFileLimit, 500);
      expect(propertyDetails.fieldFormMessageListCount, 10);
      expect(propertyDetails.fieldCustomAttributeSetIdLimit, 10);
    });

    test('fromJson should handle invalid or missing JSON fields', () {
      // Test case with missing JSON fields
      final jsonDataMissingFields = {
        'fieldFormListCount': 50,
        'akamaiDownloadLimit': 2000000,
      };

      final jsonStringMissingFields = jsonEncode(jsonDataMissingFields);
      final propertyDetailsMissingFields =
      SyncManagerPropertyDetails.fromJson(jsonStringMissingFields);

      expect(propertyDetailsMissingFields.fieldFormListCount, 50);
      expect(propertyDetailsMissingFields.maxThreadForMobileDevice, 3); // Default value
      expect(propertyDetailsMissingFields.fieldOfflineLocationSizeSyncLimit,
          100); // Default value
      expect(propertyDetailsMissingFields.akamaiDownloadLimit, 2000);
      expect(propertyDetailsMissingFields.fieldBatchDownloadSize, 250000);
      expect(propertyDetailsMissingFields.fieldBatchDownloadFileLimit, 250);
      expect(propertyDetailsMissingFields.fieldFormMessageListCount, 5);
      expect(propertyDetailsMissingFields.fieldCustomAttributeSetIdLimit, 5);

      // Test case with invalid JSON fields
      final jsonStringInvalidFields = '{"invalidField": "invalidValue"}';
      final propertyDetailsInvalidFields =
      SyncManagerPropertyDetails.fromJson(jsonStringInvalidFields);

      expect(propertyDetailsInvalidFields.fieldFormListCount, 25); // Default value
      expect(propertyDetailsInvalidFields.maxThreadForMobileDevice, 3); // Default value
      expect(propertyDetailsInvalidFields.fieldOfflineLocationSizeSyncLimit, 100); // Default value
      expect(propertyDetailsInvalidFields.akamaiDownloadLimit, 1000000);
      expect(propertyDetailsInvalidFields.fieldBatchDownloadSize, 250000);
      expect(propertyDetailsInvalidFields.fieldBatchDownloadFileLimit, 250);
      expect(propertyDetailsInvalidFields.fieldFormMessageListCount, 5);
      expect(propertyDetailsInvalidFields.fieldCustomAttributeSetIdLimit, 5);
    });


    test('toJson should return an empty map', () {
      final propertyDetails = SyncManagerPropertyDetails();

      final json = propertyDetails.toJson();

      expect(json, isMap);
      expect(json, isEmpty);
    });
  });
}
