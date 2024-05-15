import 'package:field/data/model/download_size_vo.dart';

/// projectId : "12345"
/// locationId : "12234"
/// pdfAndXfdfSize : "1267526572"
/// formTemplateSize : "329227"
/// totalSize : "1504971982"
/// countOfLocations : "270"
/// totalFormXmlSize : "53226"
/// attachmentsSize : "237392184"
/// associationsSize : "0"
/// countOfForms : "180"

class SyncSizeVo {
  SyncSizeVo({String? projectId, int? locationId, DownloadSizeVo? downloadSizeVo}) {
    this.projectId = projectId;
    this.locationId = locationId;
    this.downloadSizeVo = downloadSizeVo;
  }

  SyncSizeVo.fromJson(dynamic json) {
    this.projectId = json['projectId'];
    this.locationId = json['locationId'];
    this.downloadSizeVo = json['downloadSizeVo'];
  }

  String? projectId;
  int? locationId;
  DownloadSizeVo? downloadSizeVo;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['projectId'] = projectId;
    map['locationId'] = locationId;
    map['downloadSizeVo'] = downloadSizeVo;
    return map;
  }

  SyncSizeVo.downloadSizeVoJson(dynamic json){
    this.projectId = json['projectId'];
    this.locationId = json['locationId'];
    this.downloadSizeVo = DownloadSizeVo.fromJson(json['downloadSizeVo']);
  }
}
