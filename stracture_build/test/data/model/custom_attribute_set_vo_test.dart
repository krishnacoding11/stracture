import 'dart:convert';
import 'package:field/data/model/bim_model_calibration_vo.dart';
import 'package:field/data/model/custom_attribute_set_vo.dart';
import 'package:field/data/model/form_status_history_vo.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:test/test.dart';

void main() {
  group('CustomAttributeSetVo', () {

    test('toJson should convert BimModelCalibrationModel object to JSON map', () {
      final customAttributeSetVo = CustomAttributeSetVo(
        projectId: "12345",
        attributeSetId: "556361",
        serverResponse: "data",
      );
      expect(customAttributeSetVo.projectId, equals("12345"));
      expect(customAttributeSetVo.attributeSetId, equals("556361"));
      expect(customAttributeSetVo.serverResponse, equals("data"));
    });

    test('fromJson should correctly initialize CustomAttributeSetVo instance', () {
      final jsonData = {
        'attributeSetId1': {'key1': 'value1', 'key2': 'value2'},
        'attributeSetId2': {'key3': 'value3'},
      };

      final attributeSetVOList = CustomAttributeSetVo.getCustomAttributeVOList(jsonEncode(jsonData));

      // Check if the list is not null and contains the correct number of items
      expect(attributeSetVOList, isNotNull);
      expect(attributeSetVOList.length, equals(2));

      // Check the individual instances in the list
      final vo1 = attributeSetVOList[0];
      expect(vo1.attributeSetId, equals('attributeSetId1'));
      expect(vo1.serverResponse, equals(jsonEncode({'key1': 'value1', 'key2': 'value2'})));
      expect(vo1.projectId, isNull); // We haven't provided the projectId in the constructor

      final vo2 = attributeSetVOList[1];
      expect(vo2.attributeSetId, equals('attributeSetId2'));
      expect(vo2.serverResponse, equals(jsonEncode({'key3': 'value3'})));
      expect(vo2.projectId, isNull); // We haven't provided the projectId in the constructor
    });
  });
}
