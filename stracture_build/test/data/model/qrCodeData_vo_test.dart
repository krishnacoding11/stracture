import 'dart:convert';
import 'package:field/data/model/bim_model_calibration_vo.dart';
import 'package:field/data/model/form_status_history_vo.dart';
import 'package:field/data/model/qrcodedata_vo.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:test/test.dart';

void main() {
  group('QRCodeDataVo', () {
    test('Constructor should initialize QRCodeDataVo instance with valid input', () {
      final vo = QRCodeDataVo(
        qrCodeType: QRCodeType.qrLocation,
        projectId: '12345',
        parentLocationId: 'parentLocId',
        locationId: 'locId',
        parentFolderId: 'parentFolId',
        folderId: 'folId',
        revisionId: 'revId',
        instanceGroupId: null,
        dcId: 1,
      );

      expect(vo.qrCodeType, equals(QRCodeType.qrLocation));
      expect(vo.projectId, equals('12345'));
      expect(vo.parentLocationId, equals('parentLocId'));
      expect(vo.locationId, equals('locId'));
      expect(vo.parentFolderId, equals('parentFolId'));
      expect(vo.folderId, equals('folId'));
      expect(vo.revisionId, equals('revId'));
      expect(vo.instanceGroupId, isNull);
      expect(vo.dcId, equals(1));
    });

    test('fromMap should initialize QRCodeDataVo instance with valid input for qrLocation', () {
      final mapData = {
        'QRCodeType': QRCodeType.qrLocation,
        'projId': '12345',
        'pLocId': 'parentLocId',
        'locId': 'locId',
        'revId': 'revId',
      };

      final vo = QRCodeDataVo.fromMap(mapData);

      expect(vo.qrCodeType, equals(QRCodeType.qrLocation));
      expect(vo.projectId, equals('12345'));
      expect(vo.parentLocationId, equals('parentLocId'));
      expect(vo.locationId, equals('locId'));
      expect(vo.parentFolderId, isEmpty);
      expect(vo.folderId, isEmpty);
      expect(vo.revisionId, equals('revId'));
      expect(vo.instanceGroupId, isNull);
      expect(vo.dcId, isNull);
    });

    test('fromMap should initialize QRCodeDataVo instance with valid input for qrFormType', () {
      final mapData = {
        'QRCodeType': QRCodeType.qrFormType,
        'projId': '12345',
        'instGrpId': 'instanceGrpId',
      };

      final vo = QRCodeDataVo.fromMap(mapData);

      expect(vo.qrCodeType, equals(QRCodeType.qrFormType));
      expect(vo.projectId, equals('12345'));
      expect(vo.parentLocationId, isNull);
      expect(vo.locationId, isNull);
      expect(vo.parentFolderId, isNull);
      expect(vo.folderId, isNull);
      expect(vo.revisionId, isNull);
      expect(vo.instanceGroupId, equals('instanceGrpId'));
      expect(vo.dcId, isNull);
    });

    test('fromMap should initialize QRCodeDataVo instance with valid input for qrFolder', () {
      final mapData = {
        'QRCodeType': QRCodeType.qrFolder,
        'projId': '12345',
        'pFolId': 'parentFolId',
        'folId': 'folId',
      };

      final vo = QRCodeDataVo.fromMap(mapData);

      expect(vo.qrCodeType, equals(QRCodeType.qrFolder));
      expect(vo.projectId, equals('12345'));
      expect(vo.parentLocationId, isNull);
      expect(vo.locationId, isNull);
      expect(vo.parentFolderId, equals('parentFolId'));
      expect(vo.folderId, equals('folId'));
      expect(vo.revisionId, isNull);
      expect(vo.instanceGroupId, isNull);
      expect(vo.dcId, isNull);
    });

    test('copyWith should return a new QRCodeDataVo object with updated values', () {
      final original = QRCodeDataVo(
        qrCodeType: QRCodeType.qrLocation,
        projectId: '12345',
        parentLocationId: 'parentLocId',
        locationId: 'locId',
        parentFolderId: 'parentFolId',
        folderId: 'folId',
        revisionId: 'revId',
        instanceGroupId: null,
        dcId: 1,
      );

      final updated = original.copyWith();

      expect(updated.qrCodeType, equals(QRCodeType.qrLocation));
      expect(updated.projectId, equals('12345'));
      expect(updated.parentLocationId, equals('parentLocId'));
      expect(updated.locationId, equals('locId'));
      expect(updated.parentFolderId, equals('parentFolId'));
      expect(updated.folderId, equals('folId'));
      expect(updated.revisionId, equals('revId'));
      expect(updated.instanceGroupId, equals(null));
      expect(updated.dcId, equals(1));
    });

    test('copyWith should return a new QRCodeDataVo object with set Type', () {
      final original = QRCodeDataVo(
        qrCodeType: QRCodeType.qrLocation,
        projectId: '12345',
        parentLocationId: 'parentLocId',
        locationId: 'locId',
        parentFolderId: 'parentFolId',
        folderId: 'folId',
        revisionId: 'revId',
        instanceGroupId: null,
        dcId: 1,
      );
      original.setLocationId = "locId";
      original.setDcId = 2;
      original.setQrCodeType =QRCodeType.qrLocation;
    });

  });
}
