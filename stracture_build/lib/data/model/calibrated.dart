import 'package:equatable/equatable.dart';

class CalibrationDetails extends Equatable{
  String modelId;
  String revisionId;
  String calibrationId;
  int sizeOf2DFile;
  String createdByUserid;
  String calibratedBy;
  String createdDate;
  String modifiedDate;
  String point3D1;
  String point3D2;
  String point2D1;
  String point2D2;
  double depth;
  String fileName;
  String fileType;
  String documentId;
  String docRef;
  String folderPath;
  var calibrationImageId;
  var pageWidth;
  var pageHeight;
  var pageRotation;
  String folderId;
  String calibrationName;
  String projectId;
  bool generateUri;
  bool isChecked;
  bool isDownloaded;

  CalibrationDetails({
    required this.modelId,
    required this.revisionId,
    required this.calibrationId,
    required this.sizeOf2DFile,
    required this.createdByUserid,
    required this.calibratedBy,
    required this.createdDate,
    required this.modifiedDate,
    required this.point3D1,
    required this.point3D2,
    required this.point2D1,
    required this.point2D2,
    required this.depth,
    required this.fileName,
    required this.fileType,
    required this.isChecked,
    required this.documentId,
    required this.docRef,
    required this.folderPath,
    required this.calibrationImageId,
    required this.pageWidth,
    required this.pageHeight,
    required this.pageRotation,
    required this.folderId,
    required this.calibrationName,
    required this.generateUri,
    required this.isDownloaded,
    required this.projectId,
  });

  factory CalibrationDetails.fromJson(Map<String, dynamic> json) => CalibrationDetails(
        modelId: json["modelId"],
        revisionId: json["revisionId"],
        calibrationId: json["calibrationId"],
        sizeOf2DFile: json["sizeOf2dFile"] ?? 0,
        createdByUserid: json["createdByUserid"],
        calibratedBy: json["calibratedBy"],
        createdDate: json["createdDate"],
        modifiedDate: json["modifiedDate"],
        point3D1: json["point3d1"],
        point3D2: json["point3d2"],
        point2D1: json["point2d1"],
        point2D2: json["point2d2"],
        depth: json["depth"]?.toDouble(),
        fileName: json["fileName"],
        fileType: json["fileType"],
        documentId: json["documentId"],
        docRef: json["docRef"],
        folderPath: json["folderPath"],
        calibrationImageId: json["calibrationImageId"],
        pageWidth: json["pageWidth"],
        pageHeight: json["pageHeight"],
        pageRotation: json["pageRotation"],
        folderId: json["folderId"],
        calibrationName: json["calibrationName"],
        generateUri: json["generateURI"],
        projectId: json["projectId"] ?? "",
        isChecked: json['isChecked'] ?? false,
        isDownloaded: json['isDownloaded'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "modelId": modelId,
        "revisionId": revisionId,
        "calibrationId": calibrationId,
        "sizeOf2dFile": sizeOf2DFile,
        "createdByUserid": createdByUserid,
        "calibratedBy": calibratedBy,
        "createdDate": createdDate,
        "modifiedDate": modifiedDate,
        "point3d1": point3D1,
        "point3d2": point3D2,
        "point2d1": point2D1,
        "point2d2": point2D2,
        "depth": depth,
        "fileName": fileName,
        "fileType": fileType,
        "documentId": documentId,
        "docRef": docRef,
        "folderPath": folderPath,
        "calibrationImageId": calibrationImageId,
        "pageWidth": pageWidth,
        "pageHeight": pageHeight,
        "pageRotation": pageRotation,
        "folderId": folderId,
        "calibrationName": calibrationName,
        "generateURI": generateUri,
        "isChecked": isChecked,
        "isDownloaded": isDownloaded,
        "projectId": projectId,
      };

  @override

  List<Object?> get props => [
    modelId,
    revisionId,
    calibrationId,
    sizeOf2DFile,
    createdByUserid,
    calibratedBy,
    createdDate,
    modifiedDate,
    point3D1,
    point3D2,
    point2D1,
    point2D2,
    depth,
    fileName,
    fileType,
    documentId,
    docRef,
    folderPath,
    calibrationImageId,
    pageWidth,
    pageHeight,
    pageRotation,
    folderId,
    calibrationName,
    projectId,
    generateUri,
    isChecked,
    isDownloaded,
  ];
}
