import 'dart:convert';
import 'package:field/data/model/bim_model_calibration_vo.dart';
import 'package:field/data/model/custom_attribute_set_vo.dart';
import 'package:field/data/model/form_status_history_vo.dart';
import 'package:field/data/model/manage_type_list_vo.dart';
import 'package:field/data/model/status_style_list_vo.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:test/test.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  group('ManageTypeListVo', () {

    test('fromJson should convert JSON map to ManageTypeVo object', () {
      final Map<String,dynamic> jsonMap = jsonDecode(fixture("manage_type_list.json"));

      final manageTypeListVO = ManageTypeListVO.fromJson(jsonEncode(jsonMap));
      DistData? distData= manageTypeListVO.distData;

      expect(distData?.defTypeJson![0].manageTypeId, equals("218898"));
      expect(distData?.defTypeJson![0].manageTypeName, equals("Architectural"));
      expect(distData?.defTypeJson![0].isDeactive, equals(false));
      expect(distData?.defTypeJson![0].projectId, equals('2116416\$\$w15HZa'));
      expect(distData?.defTypeJson![0].userId, equals(isNull));
      expect(distData?.defTypeJson![0].userName, equals(isNull));
      expect(distData?.defTypeJson![0].orgId, equals(''));
      expect(distData?.defTypeJson![0].orgName, equals(isNull));

      expect(distData?.defTypeJson![1].manageTypeId, equals("218900"));
      expect(distData?.defTypeJson![1].manageTypeName, equals("Civil"));
      expect(distData?.defTypeJson![1].isDeactive, equals(false));
      expect(distData?.defTypeJson![1].projectId, equals('2116416\$\$w15HZa'));
      expect(distData?.defTypeJson![1].userId, equals(isNull));
      expect(distData?.defTypeJson![1].userName, equals(isNull));
      expect(distData?.defTypeJson![1].orgId, equals(''));
      expect(distData?.defTypeJson![1].orgName, equals(isNull));

    });
    test('toJson should convert ManageTypeVo object to JSON map', () {
      final Map<String,dynamic> jsonMap = jsonDecode(fixture("manage_type_list.json"));

      final manageTypeListVO = ManageTypeListVO.fromJson(jsonEncode(jsonMap));
      DistData? distData= manageTypeListVO.distData;

      Map<String, dynamic>? jsonData=distData?.toJson();

      expect(jsonData!["defTypeJson"][0]['id'], equals('218898'));
      expect(jsonData["defTypeJson"][0]['name'], equals('Architectural'));
      expect(jsonData["defTypeJson"][0]['isDeactive'], equals(false));
      expect(jsonData["defTypeJson"][0]['projectId'], equals('2116416\$\$w15HZa'));
    });
  });


  group('ManageTypeVo', () {

    test('fromJson should convert JSON map to StatusStyleVO object', () {
      final Map<String,dynamic> jsonMap = jsonDecode(fixture("manage_type_list.json"));

      final manageTypeVO = ManageTypeVO.fromJson(jsonMap["distData"]["defTypeJson"][0]);

      expect(manageTypeVO.manageTypeId, equals("218898"));
      expect(manageTypeVO.manageTypeName, equals("Architectural"));
      expect(manageTypeVO.isDeactive, equals(false));
      expect(manageTypeVO.projectId, equals('2116416\$\$w15HZa'));
      expect(manageTypeVO.userId, equals(isNull));
      expect(manageTypeVO.userName, equals(isNull));
      expect(manageTypeVO.orgId, equals(''));
      expect(manageTypeVO.orgName, equals(isNull));


    });

    test('toJson should convert StatusStyleVO object to JSON map', () {
      final manageTypeVO=ManageTypeVO(
          manageTypeId:'218898',
          manageTypeName:'Architectural',
          isDeactive:false,
          projectId:'2116416\$\$w15HZa',
      );
      manageTypeVO.setIsDeactive=false;
      manageTypeVO.setOrgId=null;
      manageTypeVO.setOrgName=null;
      manageTypeVO.setProjectId='2116416\$\$w15HZa';
      manageTypeVO.setManageTypeId='218898';
      manageTypeVO.setManageTypeName='Architectural';

      Map<String, dynamic> jsonData=manageTypeVO.toJson();

      expect(jsonData['id'], equals('218898'));
      expect(jsonData['name'], equals('Architectural'));
      expect(jsonData['isDeactive'], equals(false));
      expect(jsonData['projectId'], equals('2116416\$\$w15HZa'));

    });
  });
}
