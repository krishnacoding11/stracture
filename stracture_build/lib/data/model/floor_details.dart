import 'dart:convert';

import 'package:equatable/equatable.dart';

List<FloorData> floorDataFromJson(String str) => List<FloorData>.from(json.decode(str).map((x) => FloorData.fromJson(x)));

String floorDataToJson(List<FloorData> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class FloorData {
  int revisionId;
  String? bimModelId;
  List<FloorDetail> floorDetails;

  FloorData({required this.revisionId, required this.floorDetails, this.bimModelId = ""});

  factory FloorData.fromJson(Map<String, dynamic> json) => FloorData(
        revisionId: json["revisionId"],
        bimModelId: json["bimModelId"] ?? "",
        floorDetails: List<FloorDetail>.from(json["floorDetails"].map((x) => FloorDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "revisionId": revisionId,
        "bimModelId": bimModelId,
        "floorDetails": List<dynamic>.from(floorDetails.map((x) => x.toJson())),
      };
}

class FloorDetail extends Equatable {
  String fileName;
  var fileSize;
  var floorNumber;
  String levelName;
  bool isChecked;
  bool isDownloaded;
  bool isDeleteExpanded;
  int revisionId;
  String? bimModelId;
  String? revName;
  String? projectId;

  FloorDetail({
    required this.fileName,
    required this.revisionId,
    required this.bimModelId,
    required this.fileSize,
    required this.floorNumber,
    required this.revName,
    this.isChecked = false,
    this.isDeleteExpanded = false,
    this.isDownloaded = false,
    required this.levelName,
    required this.projectId,
  });

  factory FloorDetail.fromJson(Map<String, dynamic> json) => FloorDetail(
        fileName: json["fileName"],
        fileSize: json["fileSize"],
        floorNumber: json["floorNumber"],
        levelName: json["levelName"],
        revisionId: json["revisionId"] ?? -1,
        bimModelId: json["bimModelId"] ?? "",
        isChecked: json["isChecked"] ?? false,
        isDownloaded: json["isDownloaded"] ?? false,
        projectId: json["projectId"],
        revName: json["revName"],
      );

  Map<String, dynamic> toJson() => {
        "fileName": fileName,
        "fileSize": fileSize,
        "floorNumber": floorNumber,
        "levelName": levelName,
        "isChecked": isChecked,
        "revisionId": revisionId,
        "bimModelId": bimModelId,
        "isDownloaded": isDownloaded,
        "projectId": projectId,
        "revName": revName,
      };

  @override
  List<Object?> get props => [
        fileName,
        fileSize,
        floorNumber,
        levelName,
        isChecked,
        isDownloaded,
        isDeleteExpanded,
        revisionId,
        bimModelId,
        revName,
        projectId,
      ];
}
