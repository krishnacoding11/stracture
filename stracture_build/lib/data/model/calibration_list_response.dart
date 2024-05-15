// To parse this JSON data, do
//
//     final calibrationListResponse = calibrationListResponseFromJson(jsonString);

import 'dart:convert';

List<CalibrationListResponse> calibrationListResponseFromJson(String str) => List<CalibrationListResponse>.from(json.decode(str).map((x) => CalibrationListResponse.fromJson(x)));

String calibrationListResponseToJson(List<CalibrationListResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CalibrationListResponse {
  CalibrationListResponse({
    this.modelId,
    this.revisionId,
    this.calibrationId,
    this.sizeOf2DFile,
    this.calibratedBy,
    this.createdDate,
    this.modifiedDate,
    this.point3D1,
    this.point3D2,
    this.point2D1,
    this.point2D2,
    this.depth,
    this.fileName,
    this.fileType,
    this.imageUrl,
    this.documentId,
    this.docRef,
    this.folderPath,
    this.userImageUrl,
    this.calibrationImageId,
    this.folderId,
    this.generateUri,
  });

  String? modelId;
  String? revisionId;
  String? calibrationId;
  int? sizeOf2DFile;
  String? calibratedBy;
  DateTime? createdDate;
  DateTime? modifiedDate;
  String? point3D1;
  String? point3D2;
  String? point2D1;
  String? point2D2;
  double? depth;
  String? fileName;
  String? fileType;
  String? imageUrl;
  String? documentId;
  String? docRef;
  String? folderPath;
  String? userImageUrl;
  int? calibrationImageId;
  String? folderId;
  bool? generateUri;

  factory CalibrationListResponse.fromJson(Map<String, dynamic> json) => CalibrationListResponse(
    modelId: json["modelId"],
    revisionId: json["revisionId"],
    calibrationId: json["calibrationId"],
    sizeOf2DFile: json["sizeOf2dFile"],
    calibratedBy: json["calibratedBy"],
    createdDate: DateTime.parse(json["createdDate"]),
    modifiedDate: DateTime.parse(json["modifiedDate"]),
    point3D1: json["point3d1"],
    point3D2: json["point3d2"],
    point2D1: json["point2d1"],
    point2D2: json["point2d2"],
    depth: json["depth"].toDouble(),
    fileName: json["fileName"],
    fileType: json["fileType"],
    imageUrl: json["imageUrl"],
    documentId: json["documentId"],
    docRef: json["docRef"],
    folderPath: json["folderPath"],
    userImageUrl: json["userImageUrl"],
    calibrationImageId: json["calibrationImageId"],
    folderId: json["folderId"],
    generateUri: json["generateURI"],
  );

  Map<String, dynamic> toJson() => {
    "modelId": modelId,
    "revisionId": revisionId,
    "calibrationId": calibrationId,
    "sizeOf2dFile": sizeOf2DFile,
    "calibratedBy": calibratedBy,
    "createdDate": createdDate!.toIso8601String(),
    "modifiedDate": modifiedDate!.toIso8601String(),
    "point3d1": point3D1,
    "point3d2": point3D2,
    "point2d1": point2D1,
    "point2d2": point2D2,
    "depth": depth,
    "fileName": fileName,
    "fileType": fileType,
    "imageUrl": imageUrl,
    "documentId": documentId,
    "docRef": docRef,
    "folderPath": folderPath,
    "userImageUrl": userImageUrl,
    "calibrationImageId": calibrationImageId,
    "folderId": folderId,
    "generateURI": generateUri,
  };
}
