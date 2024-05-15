import 'package:field/data/model/datacenter_vo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DatacenterVo', () {
    test('fromJson() should correctly parse JSON data', () {
      final json = {
        'ssoIdentityProvider': 'provider1',
        'ssoEnabled': 'true',
        'isUserAvailable': 'true',
        'msgTitle': 'Title 1',
        'cloudName': 'Cloud 1',
        'cloudId': 'cloud_id_1',
        'msgDescription': 'Description 1',
        'ssoTargetURL': 'target_url',
        'enableCloudLogin': 'true',
      };
      final datacenterVo = DatacenterVo.fromJson(json);
      expect(datacenterVo.ssoIdentityProvider, equals('provider1'));
      expect(datacenterVo.ssoEnabled, equals('true'));
      expect(datacenterVo.isUserAvailable, equals('true'));
      expect(datacenterVo.msgTitle, equals('Title 1'));
      expect(datacenterVo.cloudName, equals('Cloud 1'));
      expect(datacenterVo.cloudId, equals('cloud_id_1'));
      expect(datacenterVo.msgDescription, equals('Description 1'));
      expect(datacenterVo.ssoTargetURL, equals('target_url'));
      expect(datacenterVo.enableCloudLogin, equals('true'));
    });
    test('toJson() should correctly convert DatacenterVo to JSON', () {
      final datacenterVo = DatacenterVo(
        ssoIdentityProvider: 'provider1',
        ssoEnabled: 'true',
        isUserAvailable: 'true',
        msgTitle: 'Title 1',
        cloudName: 'Cloud 1',
        cloudId: 'cloud_id_1',
        msgDescription: 'Description 1',
        ssoTargetURL: 'target_url',
        enableCloudLogin: 'true',
      );
      final json = datacenterVo.toJson();
      expect(json['ssoIdentityProvider'], equals('provider1'));
      expect(json['ssoEnabled'], equals('true'));
      expect(json['isUserAvailable'], equals('true'));
      expect(json['msgTitle'], equals('Title 1'));
      expect(json['cloudName'], equals('Cloud 1'));
      expect(json['cloudId'], equals('cloud_id_1'));
      expect(json['msgDescription'], equals('Description 1'));
      expect(json['ssoTargetURL'], equals('target_url'));
      expect(json['enableCloudLogin'], equals('true'));
    });
    test('copyWith() should create a copy of DatacenterVo with updated values', () {
      final datacenterVo = DatacenterVo(
        ssoIdentityProvider: 'provider1',
        ssoEnabled: 'true',
        isUserAvailable: 'true',
        msgTitle: 'Title 1',
        cloudName: 'Cloud 1',
        cloudId: 'cloud_id_1',
        msgDescription: 'Description 1',
        ssoTargetURL: 'target_url',
        enableCloudLogin: 'true',
      );
      final updatedDatacenterVo = datacenterVo.copyWith(
        ssoIdentityProvider: 'provider2',
        cloudName: 'Cloud 2',
        cloudId: 'cloud_id_2',
      );
      expect(updatedDatacenterVo.ssoIdentityProvider, equals('provider2'));
      expect(updatedDatacenterVo.ssoEnabled, equals('true'));
      expect(updatedDatacenterVo.isUserAvailable, equals('true'));
      expect(updatedDatacenterVo.msgTitle, equals('Title 1'));
      expect(updatedDatacenterVo.cloudName, equals('Cloud 2'));
      expect(updatedDatacenterVo.cloudId, equals('Cloud 2'));
      expect(updatedDatacenterVo.msgDescription, equals('Description 1'));
      expect(updatedDatacenterVo.ssoTargetURL, equals('target_url'));
      expect(updatedDatacenterVo.enableCloudLogin, equals('true'));
    });
  });
  group('DataCenters', () {
    test('jsonToList() should convert JSON list to List<DatacenterVo>', () {
      final jsonList = [
        {
          'ssoIdentityProvider': 'provider1',
          'ssoEnabled': 'true',
          'isUserAvailable': 'true',
          'msgTitle': 'Title 1',
          'cloudName': 'Cloud 1',
          'cloudId': 'cloud_id_1',
          'msgDescription': 'Description 1',
          'ssoTargetURL': 'target_url',
          'enableCloudLogin': 'true',
        },
        {
          'ssoIdentityProvider': 'provider2',
          'ssoEnabled': 'false',
          'isUserAvailable': 'false',
          'msgTitle': 'Title 2',
          'cloudName': 'Cloud 2',
          'cloudId': 'cloud_id_2',
          'msgDescription': 'Description 2',
          'ssoTargetURL': 'target_url2',
          'enableCloudLogin': 'false',
        },
      ];
      final datacenterList = DataCenters.jsonToList(jsonList);
      expect(datacenterList, isA<List<DatacenterVo>>());
      expect(datacenterList.length, equals(2));
      expect(datacenterList[0].ssoIdentityProvider, equals('provider1'));
      expect(datacenterList[0].cloudName, equals('Cloud 1'));
      expect(datacenterList[1].ssoIdentityProvider, equals('provider2'));
      expect(datacenterList[1].cloudName, equals('Cloud 2'));
    });
    test('DataCenters constructor should set clouds and email correctly', () {
      final datacenterList = [
        DatacenterVo.fromJson({
          'ssoIdentityProvider': 'provider1',
          'ssoEnabled': 'true',
          'isUserAvailable': 'true',
          'msgTitle': 'Title 1',
          'cloudName': 'Cloud 1',
          'cloudId': 'cloud_id_1',
          'msgDescription': 'Description 1',
          'ssoTargetURL': 'target_url',
          'enableCloudLogin': 'true',
        }),
        DatacenterVo.fromJson({
          'ssoIdentityProvider': 'provider2',
          'ssoEnabled': 'false',
          'isUserAvailable': 'false',
          'msgTitle': 'Title 2',
          'cloudName': 'Cloud 2',
          'cloudId': 'cloud_id_2',
          'msgDescription': 'Description 2',
          'ssoTargetURL': 'target_url2',
          'enableCloudLogin': 'false',
        }),
      ];
      final dataCenters = DataCenters(datacenterList);
      expect(dataCenters.clouds, equals(datacenterList));
      expect(dataCenters.email, isNull);
      expect(dataCenters.isFromSSO, isFalse);
    });
    test('DataCenters email setter should update the email value', () {
      final dataCenters = DataCenters([]);
      dataCenters.email = 'test@example.com';
      expect(dataCenters.email, equals('test@example.com'));
    });
    test('DataCenters isFromSSO setter should update the isFromSSO value', () {
      final dataCenters = DataCenters([]);
      // Initially, isFromSSO should be false
      expect(dataCenters.isFromSSO, isFalse);
      // Update isFromSSO to true
      dataCenters.isFromSSO = true;
      expect(dataCenters.isFromSSO, isTrue);
      // Update isFromSSO back to false
      dataCenters.isFromSSO = false;
      expect(dataCenters.isFromSSO, isFalse);
      dataCenters.isFromSSO = null;
      expect(dataCenters.isFromSSO, null);
    });
    test('DataCenters clouds setter should update the clouds value', () {
      final datacenterList = [
        DatacenterVo.fromJson({
          'ssoIdentityProvider': 'provider1',
          'ssoEnabled': 'true',
          'isUserAvailable': 'true',
          'msgTitle': 'Title 1',
          'cloudName': 'Cloud 1',
          'cloudId': 'cloud_id_1',
          'msgDescription': 'Description 1',
          'ssoTargetURL': 'target_url',
          'enableCloudLogin': 'true',
        }),
      ];
      final dataCenters = DataCenters([]);
      // Initially, clouds should be an empty list
      expect(dataCenters.clouds, isEmpty);
      // Update clouds with a new list
      dataCenters.clouds = datacenterList;
      expect(dataCenters.clouds, equals(datacenterList));
      // Update clouds with another list
      final datacenterList2 = [
        DatacenterVo.fromJson({
          'ssoIdentityProvider': 'provider2',
          'ssoEnabled': 'false',
          'isUserAvailable': 'false',
          'msgTitle': 'Title 2',
          'cloudName': 'Cloud 2',
          'cloudId': 'cloud_id_2',
          'msgDescription': 'Description 2',
          'ssoTargetURL': 'target_url2',
          'enableCloudLogin': 'false',
        }),
      ];
      dataCenters.clouds = datacenterList2;
      expect(dataCenters.clouds, equals(datacenterList2));
      dataCenters.clouds = null;
      expect(dataCenters.clouds, equals(null));
    });
  });
}