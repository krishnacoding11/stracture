class PfLocationTreeDetail {
  PfLocationTreeDetail({
      this.locationId,
      this.siteId,
      this.isSite, 
      this.parentLocationId, 
      this.docId, 
      this.revisionId, 
      this.annotationId,
      this.locationCoordinates,
      this.isFileUploaded,
      this.pageNumber, 
      this.isCalibrated,
      this.generateURI,});

  PfLocationTreeDetail.fromJson(dynamic json) {
    locationId = json['locationId'];
    siteId = json['siteId'];
    isSite = json['isSite'];
    parentLocationId = json['parentLocationId'];
    docId = json['docId'];
    revisionId = json['revisionId'];
    annotationId = json['annotationId'];
    locationCoordinates = json['locationCoordinates'];
    isFileUploaded = json['isFileUploaded'];
    pageNumber = json['pageNumber'];
    isCalibrated = json['isCalibrated'];
    generateURI = json['generateURI'];
  }
  int? locationId;
  int? siteId;
  bool? isSite;
  int? parentLocationId;
  String? docId;
  String? revisionId;
  String? annotationId;
  String? locationCoordinates;
  bool? isFileUploaded;
  int? pageNumber;
  bool? isCalibrated;
  bool? generateURI;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['locationId'] = locationId;
    map['siteId'] = siteId;
    map['isSite'] = isSite;
    map['parentLocationId'] = parentLocationId;
    map['docId'] = docId;
    map['revisionId'] = revisionId;
    map['annotationId'] = annotationId;
    map['locationCoordinates'] = locationCoordinates;
    map['isFileUploaded'] = isFileUploaded;
    map['pageNumber'] = pageNumber;
    map['isCalibrated'] = isCalibrated;
    map['generateURI'] = generateURI;
    return map;
  }

}