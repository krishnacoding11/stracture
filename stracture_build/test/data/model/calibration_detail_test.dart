import 'dart:convert';

import 'package:field/data/model/calibrated.dart';
import 'package:test/test.dart';

void main() {
  test('fromJson should convert JSON map to CalibrationDetail object', () {
    final jsonString = '{"modelId": "12345", "revisionId": "form_123", "calibrationId": "calibration_567", "sizeOf2dFile": 0, "createdByUserid": "createdBy_123", "calibratedBy": "dist_456", "createdDate": "createdDate_here", "modifiedDate": "1630444800000", "point3d1": "1630444800000", "point3d2": "1630444800000", "point2d1": "1630845800000", "point2d2": "16304445252", "depth": 0.0, "fileName": "fileName_123", "fileType": "pdf", "documentId": "1630444500", "docRef": "1630444500", "folderPath": "folderPath", "calibrationImageId": "1630444500", "pageWidth": "1630444500", "pageHeight": "1630444500", "pageRotation": "16304", "calibrationName": "16364640","folderId" : "554158", "projectId": "8785411", "isChecked": false, "isDownloaded": false,"generateURI":false}';

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

    final calibrationDetailData = CalibrationDetails.fromJson(jsonMap);

    expect(calibrationDetailData.modelId, equals("12345"));
    expect(calibrationDetailData.revisionId, equals("form_123"));
    expect(calibrationDetailData.calibrationId, equals("calibration_567"));
    expect(calibrationDetailData.sizeOf2DFile, equals(0));
    expect(calibrationDetailData.createdByUserid, equals("createdBy_123"));
    expect(calibrationDetailData.calibratedBy, equals("dist_456"));
    expect(calibrationDetailData.createdDate, equals("createdDate_here"));
    expect(calibrationDetailData.modifiedDate, equals("1630444800000"));
    expect(calibrationDetailData.point3D1, equals("1630444800000"));
    expect(calibrationDetailData.point3D2, equals("1630444800000"));
    expect(calibrationDetailData.point2D1, equals("1630845800000"));
    expect(calibrationDetailData.point2D2, equals("16304445252"));
    expect(calibrationDetailData.depth, equals(0.0));
    expect(calibrationDetailData.fileName, equals("fileName_123"));
    expect(calibrationDetailData.fileType, equals("pdf"));
    expect(calibrationDetailData.documentId, equals("1630444500"));
    expect(calibrationDetailData.docRef, equals("1630444500"));
    expect(calibrationDetailData.folderPath, equals("folderPath"));
    expect(calibrationDetailData.calibrationImageId, equals("1630444500"));
    expect(calibrationDetailData.pageWidth, equals("1630444500"));
    expect(calibrationDetailData.pageHeight, equals("1630444500"));
    expect(calibrationDetailData.pageRotation, equals("16304"));
    expect(calibrationDetailData.folderId, equals("554158"));
    expect(calibrationDetailData.calibrationName, equals("16364640"));
    expect(calibrationDetailData.projectId, equals("8785411"));
    expect(calibrationDetailData.generateUri, equals(false));
    expect(calibrationDetailData.isChecked, equals(false));
    expect(calibrationDetailData.isDownloaded, equals(false));
  });

  test('toJson should convert CalibrationDetail object to JSON map', () {
    final calibrationDetail = CalibrationDetails(
      modelId: "12345",
      revisionId: "form_123",
      calibrationId: "calibration_567",
      sizeOf2DFile: 0,
      createdByUserid: "createdBy_123",
      calibratedBy: "dist_456",
      createdDate: "createdDate_here",
      modifiedDate: "1630444800000",
      point3D1: "1630444800000",
      point3D2: "1630444800000",
      point2D1: "1630845800000",
      point2D2: "16304445252",
      depth: 0.0,
      fileName: "fileName_123",
      fileType: "pdf",
      documentId: "1630444500",
      docRef: "1630444500",
      folderPath: "folderPath",
      calibrationImageId: "1630444500",
      pageWidth: "1630444500",
      pageHeight: "1630444500",
      pageRotation: "16304",
      folderId: "554158",
      calibrationName: "16364640",
      projectId: "8785411",
      generateUri: false,
      isChecked: false,
      isDownloaded: false,
    );

    final jsonMap = calibrationDetail.toJson();
expect(calibrationDetail.props.length,greaterThan(0) );
    expect(jsonMap['modelId'], equals("12345"));
    expect(jsonMap['revisionId'], equals("form_123"));
    expect(jsonMap['calibrationId'], equals("calibration_567"));
    expect(jsonMap['sizeOf2dFile'], equals(0));
    expect(jsonMap['createdByUserid'], equals("createdBy_123"));
    expect(jsonMap['calibratedBy'], equals("dist_456"));
    expect(jsonMap['createdDate'], equals("createdDate_here"));
    expect(jsonMap['modifiedDate'], equals("1630444800000"));
    expect(jsonMap['point3d1'], equals("1630444800000"));
    expect(jsonMap['point3d2'], equals("1630444800000"));
    expect(jsonMap['point2d1'], equals("1630845800000"));
    expect(jsonMap['point2d2'], equals("16304445252"));
    expect(jsonMap['depth'], equals(0.0));
    expect(jsonMap['fileName'], equals("fileName_123"));
    expect(jsonMap['fileType'], equals("pdf"));
    expect(jsonMap['documentId'], equals("1630444500"));
    expect(jsonMap['docRef'], equals("1630444500"));
    expect(jsonMap['folderPath'], equals("folderPath"));
    expect(jsonMap['calibrationImageId'], equals("1630444500"));
    expect(jsonMap['pageWidth'], equals("1630444500"));
    expect(jsonMap['pageHeight'], equals("1630444500"));
    expect(jsonMap['pageRotation'], equals("16304"));
    expect(jsonMap['calibrationName'], equals("16364640"));
    expect(jsonMap['folderId'], equals("554158"));
    expect(jsonMap['projectId'], equals("8785411"));
    expect(jsonMap['isChecked'], equals(false));
    expect(jsonMap['generateURI'], equals(false));
    expect(jsonMap['isDownloaded'], equals(false));

  });
}
