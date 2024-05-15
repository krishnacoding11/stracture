// To parse this JSON data, do
//
//     final fileAssociation = fileAssociationFromJson(jsonString);

import 'dart:convert';

List<FileAssociation> fileAssociationFromJson(String str) => List<FileAssociation>.from(json.decode(str).map((x) => FileAssociation.fromJson(x)));

String fileAssociationToJson(List<FileAssociation> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FileAssociation {
  String revisionId;
  String filename;
  String filepath;
  String documentRevision;
  String publisherName;
  String publisherOrganization;
  String revisionCounter;
  String projectId;
  String publishDate;
  String documentId;
  String folderId;
  String fileSize;
  String associatedDate;
  String publisherImage;
  int documentTypeId;
  bool generateUri;
  String? documentTitle;

  FileAssociation({
    required this.revisionId,
    required this.filename,
    required this.filepath,
    required this.documentRevision,
    required this.publisherName,
    required this.publisherOrganization,
    required this.revisionCounter,
    required this.projectId,
    required this.publishDate,
    required this.documentId,
    required this.folderId,
    required this.associatedDate,
    required this.documentTypeId,
    required this.generateUri,
    required this.fileSize,
    required this.publisherImage,
    this.documentTitle,
  });

  factory FileAssociation.fromJson(Map<String, dynamic> json) => FileAssociation(
    revisionId: json["revision_id"],
    filename: json["filename"],
    filepath: json["filepath"],
    documentRevision: json["documentRevision"],
    publisherName: json["publisherName"],
    publisherOrganization: json["publisherOrganization"],
    revisionCounter: json["revision_counter"],
    projectId: json["projectId"],
    publishDate: json["publishDate"],
    documentId: json["documentId"],
    folderId: json["folderId"],
    associatedDate: json["associatedDate"],
    documentTypeId: json["documentTypeId"],
    generateUri: json["generateURI"],
    documentTitle: json["documentTitle"],
    publisherImage: json["publisherImage"],
    fileSize: json["associatedFilesize"]??"0.0",
  );

  Map<String, dynamic> toJson() => {
    "revision_id": revisionId,
    "filename": filename,
    "filepath": filepath,
    "documentRevision": documentRevision,
    "publisherName": publisherName,
    "publisherOrganization": publisherOrganization,
    "revision_counter": revisionCounter,
    "projectId": projectId,
    "publishDate": publishDate,
    "documentId": documentId,
    "folderId": folderId,
    "associatedDate": associatedDate,
    "documentTypeId": documentTypeId,
    "generateURI": generateUri,
    "documentTitle": documentTitle,
    "fileSize": fileSize,
    "publisherImage": publisherImage,
  };
}
