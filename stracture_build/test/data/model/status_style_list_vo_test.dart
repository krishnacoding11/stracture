import 'dart:convert';
import 'package:field/data/model/bim_model_calibration_vo.dart';
import 'package:field/data/model/custom_attribute_set_vo.dart';
import 'package:field/data/model/form_status_history_vo.dart';
import 'package:field/data/model/status_style_list_vo.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:test/test.dart';

import '../../fixtures/fixture_reader.dart';

void main() {
  group('StatusStyleListVo', () {

    test('fromJson should convert JSON map to StatusStyleVO object', () {
      final Map<String, dynamic> jsonMap = jsonDecode(fixture("status_style_list.json"));

      final statusStyleListVo = StatusStyleListVo.fromJson(jsonMap);
      List<StatusStyleVO>? statusStyleVoList= statusStyleListVo.statusStyleVO;

      // Check if the list is not null and contains the correct number of items
      expect(statusStyleVoList, isNotNull);
      expect(statusStyleVoList?.length, equals(2));

      // Check the individual instances in the list
      final vo1 = statusStyleVoList![0];
      expect(vo1.fontEffect, equals('0#0#0#0'));
      expect(vo1.isActive, equals(true));
      expect(vo1.projectId, equals('2116416'));
      expect(vo1.fontColor, equals('#f0e6f0'));
      expect(vo1.statusId, equals('1004'));
      expect(vo1.statusName, equals('Approve'));
      expect(vo1.fontType, equals('PT Sans'));
      expect(vo1.statusTypeId, equals('1'));
      expect(vo1.backgroundColor, equals('#d633d6'));

      final vo2 = statusStyleVoList[1];
      expect(vo2.fontEffect, equals('0#0#0#0'));
      expect(vo2.isActive, equals(true));
      expect(vo2.projectId, equals('2116416'));
      expect(vo2.fontColor, equals('#359e08'));
      expect(vo2.statusId, equals('3'));
      expect(vo2.statusName, equals('Closed'));
      expect(vo2.fontType, equals('PT Sans'));
      expect(vo2.statusTypeId, equals('1'));
      expect(vo2.backgroundColor, equals('#156fab'));

    });

    test('toJson should convert StatusStyleVO object to JSON map', () {
      final Map<String, dynamic> jsonMap = jsonDecode(fixture("status_style_list.json"));

      final statusStyleListVo = StatusStyleListVo.fromJson(jsonMap);
      List<StatusStyleVO>? statusStyleVoList= statusStyleListVo.statusStyleVO;

      Map<String, dynamic> jsonData=statusStyleListVo.toJson();

      expect(jsonData["statusStyleVO"][0]['FontEffect'], equals('0#0#0#0'));
      expect(jsonData["statusStyleVO"][0]['IsActive'], equals(true));
      expect(jsonData["statusStyleVO"][0]['ProjectId'], equals('2116416'));
      expect(jsonData["statusStyleVO"][0]['FontColor'], equals('#f0e6f0'));
      expect(jsonData["statusStyleVO"][0]['StatusId'], equals('1004'));
      expect(jsonData["statusStyleVO"][0]['StatusName'], equals('Approve'));
      expect(jsonData["statusStyleVO"][0]['FontType'], equals('PT Sans'));
      expect(jsonData["statusStyleVO"][0]['StatusTypeId'], equals('1'));
      expect(jsonData["statusStyleVO"][0]['BackgroundColor'], equals('#d633d6'));
    });
  });


  group('StatusStyleVo', () {

    test('fromJson should convert JSON map to StatusStyleVO object', () {
      final Map<String, dynamic> jsonMap = jsonDecode(fixture("status_style_list.json"));

      final statusStyleVo = StatusStyleVO.fromJson(jsonMap["statusStyleVO"][0]);

      expect(statusStyleVo.fontEffect, equals('0#0#0#0'));
      expect(statusStyleVo.isActive, equals(true));
      expect(statusStyleVo.projectId, equals('2116416'));
      expect(statusStyleVo.fontColor, equals('#f0e6f0'));
      expect(statusStyleVo.statusId, equals('1004'));
      expect(statusStyleVo.statusName, equals('Approve'));
      expect(statusStyleVo.fontType, equals('PT Sans'));
      expect(statusStyleVo.statusTypeId, equals('1'));
      expect(statusStyleVo.backgroundColor, equals('#d633d6'));


    });

    test('toJson should convert StatusStyleVO object to JSON map', () {
      final statusStyleVo=StatusStyleVO(
          fontEffect:'0#0#0#0',
          isActive:true,
          projectId:'2116416',
          fontColor:'#f0e6f0',
          statusId:'1004',
          statusName: 'Approve',
          fontType:'PT Sans',
          statusTypeId: '1',
          backgroundColor:'#d633d6'
      );

      Map<String, dynamic> jsonData=statusStyleVo.toJson();

      expect(jsonData['FontEffect'], equals('0#0#0#0'));
      expect(jsonData['IsActive'], equals(true));
      expect(jsonData['ProjectId'], equals('2116416'));
      expect(jsonData['FontColor'], equals('#f0e6f0'));
      expect(jsonData['StatusId'], equals('1004'));
      expect(jsonData['StatusName'], equals('Approve'));
      expect(jsonData['FontType'], equals('PT Sans'));
      expect(jsonData['StatusTypeId'], equals('1'));
      expect(jsonData['BackgroundColor'], equals('#d633d6'));

    });
  });
}
