import 'package:field/data/model/sync_size_vo.dart';

/// pdfAndXfdfSize : "1267526572"
/// formTemplateSize : "329227"
/// totalSize : "1504971982"
/// countOfLocations : "270"
/// totalFormXmlSize : "53226"
/// attachmentsSize : "237392184"
/// associationsSize : "0"
/// countOfForms : "180"

class DownloadSizeVo {
  DownloadSizeVo({
      int? pdfAndXfdfSize, 
      int? formTemplateSize, 
      int? totalSize, 
      int? countOfLocations, 
      int? totalFormXmlSize, 
      int? attachmentsSize, 
      int? associationsSize, 
      int? countOfForms,}){
    _pdfAndXfdfSize = pdfAndXfdfSize;
    _formTemplateSize = formTemplateSize;
    _totalSize = totalSize;
    _countOfLocations = countOfLocations;
    _totalFormXmlSize = totalFormXmlSize;
    _attachmentsSize = attachmentsSize;
    _associationsSize = associationsSize;
    _countOfForms = countOfForms;
}

  DownloadSizeVo.fromJson(dynamic json) {
    _pdfAndXfdfSize = json['pdfAndXfdfSize'];
    _formTemplateSize = json['formTemplateSize'];
    _totalSize = json['totalSize'];
    _countOfLocations = json['countOfLocations'];
    _totalFormXmlSize = json['totalFormXmlSize'];
    _attachmentsSize = json['attachmentsSize'];
    _associationsSize = json['associationsSize'];
    _countOfForms = json['countOfForms'];
  }
  int? _pdfAndXfdfSize;
  int? _formTemplateSize;
  int? _totalSize;
  int? _countOfLocations;
  int? _totalFormXmlSize;
  int? _attachmentsSize;
  int? _associationsSize;
  int? _countOfForms;
DownloadSizeVo copyWith({  int? pdfAndXfdfSize,
  int? formTemplateSize,
  int? totalSize,
  int? countOfLocations,
  int? totalFormXmlSize,
  int? attachmentsSize,
  int? associationsSize,
  int? countOfForms,
}) => DownloadSizeVo(  pdfAndXfdfSize: pdfAndXfdfSize ?? _pdfAndXfdfSize,
  formTemplateSize: formTemplateSize ?? _formTemplateSize,
  totalSize: totalSize ?? _totalSize,
  countOfLocations: countOfLocations ?? _countOfLocations,
  totalFormXmlSize: totalFormXmlSize ?? _totalFormXmlSize,
  attachmentsSize: attachmentsSize ?? _attachmentsSize,
  associationsSize: associationsSize ?? _associationsSize,
  countOfForms: countOfForms ?? _countOfForms,
);
  int? get pdfAndXfdfSize => _pdfAndXfdfSize;
  int? get formTemplateSize => _formTemplateSize;
  int? get totalSize => _totalSize;
  int? get countOfLocations => _countOfLocations;
  int? get totalFormXmlSize => _totalFormXmlSize;
  int? get attachmentsSize => _attachmentsSize;
  int? get associationsSize => _associationsSize;
  int? get countOfForms => _countOfForms;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['pdfAndXfdfSize'] = _pdfAndXfdfSize;
    map['formTemplateSize'] = _formTemplateSize;
    map['totalSize'] = _totalSize;
    map['countOfLocations'] = _countOfLocations;
    map['totalFormXmlSize'] = _totalFormXmlSize;
    map['attachmentsSize'] = _attachmentsSize;
    map['associationsSize'] = _associationsSize;
    map['countOfForms'] = _countOfForms;
    return map;
  }

  static Map<String, List<Map<String, DownloadSizeVo>>> getDownloadSize(Map<String, dynamic> json) {
    Map<String, List<Map<String, DownloadSizeVo>>> attributeSetVOList = {};

    json.forEach((key, value) {
      List<Map<String, DownloadSizeVo>> downloadList = [];
      value.forEach((element) {
        Map<String, DownloadSizeVo> downloadSizeMap = {};
        element.forEach((key, value) {
          DownloadSizeVo downloadSizeVo = DownloadSizeVo.fromJson(value);
          downloadSizeMap.putIfAbsent(key, () => downloadSizeVo);
        });
        downloadList.add(downloadSizeMap);
      });
      attributeSetVOList.putIfAbsent(key, () => downloadList);
    });

    return attributeSetVOList;
  }

  static Map<String, int> fromSyncVo(List<SyncSizeVo> syncSizeVoList) {
    Map<String, int> attributeSetVOList = {};
    int totalSize = 0;
    int totalLocationCount = 0;

    syncSizeVoList.forEach((element) {
      Map<String, DownloadSizeVo> mapDownloadSizeVo = {};
      mapDownloadSizeVo.putIfAbsent(element.locationId.toString(), () => element.downloadSizeVo!);
      totalLocationCount += element.downloadSizeVo!.countOfLocations!;
      totalSize += element.downloadSizeVo!.totalSize!;
    });
    attributeSetVOList.putIfAbsent("totalSize", () => totalSize);
    attributeSetVOList.putIfAbsent("totalLocationCount", () => totalLocationCount);

    return attributeSetVOList;
  }

  static List<DownloadSizeVo>? getProjectDownloadSize(Map<String, List<Map<String, DownloadSizeVo>>> json){
    List<DownloadSizeVo>? downloadSizeVo = [];
    json.forEach((key, value) {
      value.forEach((element) {
        element.forEach((key, value) {
          downloadSizeVo.add(value);
        });
      });
    });
    return downloadSizeVo;
  }
}