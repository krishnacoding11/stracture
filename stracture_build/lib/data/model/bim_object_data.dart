import 'dart:convert';

List<BimData> bimDataFromJson(String str) => List<BimData>.from(json.decode(str).map((x) => BimData.fromJson(x)));

String bimDataToJson(List<BimData> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BimData {
  List<BimObjectsDatum> bimObjectsData;

  BimData({
    required this.bimObjectsData,
  });

  factory BimData.fromJson(Map<String, dynamic> json) => BimData(
        bimObjectsData: List<BimObjectsDatum>.from(json["BimObjectsData"].map((x) => BimObjectsDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "BimObjectsData": List<dynamic>.from(bimObjectsData.map((x) => x.toJson())),
      };
}

class BimObjectsDatum {
  String guid;
  String objectName;
  String objType;
  int fileType;
  String revisionId;
  String treeRevisionId;
  String revisionIdModel;
  String docId;
  String fileName;

  BimObjectsDatum({
    required this.guid,
    required this.objectName,
    required this.objType,
    required this.docId,
    required this.fileName,
    required this.fileType,
    required this.revisionId,
    required this.treeRevisionId,
    required this.revisionIdModel,
  });

  factory BimObjectsDatum.fromJson(Map<String, dynamic> json) => BimObjectsDatum(
        guid: json["GUID"],
        objectName: json["object_name"],
        objType: json["obj_type"],
        fileType: json["file_type"],
        docId: json["docId"] ?? "",
    fileName: json["fileName"] ?? "",
        revisionId: json["revision_id"],
        treeRevisionId: json["tree_revision_id"],
        revisionIdModel: json["revision_id_model"],
      );

  Map<String, dynamic> toJson() => {
        "GUID": guid,
        "object_name": objectName,
        "obj_type": objType,
        "docId": docId,
        "file_type": fileType,
        "fileName": fileName,
        "revision_id": revisionId,
        "tree_revision_id": treeRevisionId,
        "revision_id_model": revisionIdModel,
      };
}
