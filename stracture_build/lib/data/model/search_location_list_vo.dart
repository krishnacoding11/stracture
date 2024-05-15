import 'dart:convert';

/// totalDocs : 17
/// recordBatchSize : 0
/// data : [{"id":"111550321$$OhC2Ou#2116416$$Ko7BJg","value":"!!PIN_ANY_APP_TYPE_20_9\\130401\\DV04\\Balcony","dataCenterId":0,"isSelected":false,"imgId":-1,"isActive":true},{"id":"111550793$$J9vD32#2116416$$Ko7BJg","value":"!!PIN_ANY_APP_TYPE_20_9\\130401\\DV04\\Bath","dataCenterId":0,"isSelected":false,"imgId":-1,"isActive":true},{"id":"112402477$$IFj7mK#2116416$$Ko7BJg","value":"!!PIN_ANY_APP_TYPE_20_9\\1_Chandresh_Site\\First Floor\\Balcony","dataCenterId":0,"isSelected":false,"imgId":-1,"isActive":true},{"id":"111619616$$EQmR7M#2116416$$Ko7BJg","value":"!!PIN_ANY_APP_TYPE_20_9\\batchAttachmentTest","dataCenterId":0,"isSelected":false,"imgId":-1,"isActive":true},{"id":"112280186$$3Ajo8Z#2116416$$Ko7BJg","value":"!!PIN_ANY_APP_TYPE_20_9\\Site 9\\Shivalik\\Block A","dataCenterId":0,"isSelected":false,"imgId":-1,"isActive":true},{"id":"112280187$$ZoQ3v1#2116416$$Ko7BJg","value":"!!PIN_ANY_APP_TYPE_20_9\\Site 9\\Shivalik\\Block B","dataCenterId":0,"isSelected":false,"imgId":-1,"isActive":true},{"id":"109729752$$YCUdNn#2116416$$Ko7BJg","value":"!!PIN_ANY_APP_TYPE_20_9\\Site Big","dataCenterId":0,"isSelected":false,"imgId":1,"isActive":true},{"id":"109729759$$8alpFY#2116416$$Ko7BJg","value":"!!PIN_ANY_APP_TYPE_20_9\\Site Big\\BL 1","dataCenterId":0,"isSelected":false,"imgId":-1,"isActive":true},{"id":"109729760$$mV0LxI#2116416$$Ko7BJg","value":"!!PIN_ANY_APP_TYPE_20_9\\Site Big\\BL 2","dataCenterId":0,"isSelected":false,"imgId":-1,"isActive":true},{"id":"109729814$$i2AIrd#2116416$$Ko7BJg","value":"!!PIN_ANY_APP_TYPE_20_9\\Site Big\\BL 3","dataCenterId":0,"isSelected":false,"imgId":-1,"isActive":true},{"id":"100191907$$Oy6QSd#2116416$$Ko7BJg","value":"!!PIN_ANY_APP_TYPE_20_9\\Site Task 4\\Barlut","dataCenterId":0,"isSelected":false,"imgId":-1,"isActive":true},{"id":"112891538$$pYWeWz#2116416$$Ko7BJg","value":"!!PIN_ANY_APP_TYPE_20_9\\Zone-1\\Cluster01\\Villa ADM No.1355 -C1M\\Balcony","dataCenterId":0,"isSelected":false,"imgId":-1,"isActive":true},{"id":"112891541$$GkbTmg#2116416$$Ko7BJg","value":"!!PIN_ANY_APP_TYPE_20_9\\Zone-1\\Cluster01\\Villa ADM No.1355 -C1M\\Bedroom","dataCenterId":0,"isSelected":false,"imgId":-1,"isActive":true},{"id":"112891548$$W5CFA7#2116416$$Ko7BJg","value":"!!PIN_ANY_APP_TYPE_20_9\\Zone-1\\Cluster01\\Villa ADM No.1355 -C2M\\Balcony","dataCenterId":0,"isSelected":false,"imgId":-1,"isActive":true},{"id":"112891550$$QeLTjQ#2116416$$Ko7BJg","value":"!!PIN_ANY_APP_TYPE_20_9\\Zone-1\\Cluster01\\Villa ADM No.1355 -C2M\\Bedroom","dataCenterId":0,"isSelected":false,"imgId":-1,"isActive":true}]
/// isSortRequired : true
/// isReviewEnableProjectSelected : false
/// isAmessageProjectSelected : false
/// generateURI : true

class SearchLocationListVo {
  SearchLocationListVo({
    num? totalDocs,
    num? recordBatchSize,
    List<SearchLocationData>? data,
    bool? isSortRequired,
    bool? isReviewEnableProjectSelected,
    bool? isAmessageProjectSelected,
    bool? generateURI,
  }) {
    _totalDocs = totalDocs;
    _recordBatchSize = recordBatchSize;
    _data = data;
    _isSortRequired = isSortRequired;
    _isReviewEnableProjectSelected = isReviewEnableProjectSelected;
    _isAmessageProjectSelected = isAmessageProjectSelected;
    _generateURI = generateURI;
  }

  SearchLocationListVo.fromJson(dynamic response) {
    dynamic json = jsonDecode(response);
    _totalDocs = json['totalDocs'];
    _recordBatchSize = json['recordBatchSize'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(SearchLocationData.fromJson(v));
      });
    }
    _isSortRequired = json['isSortRequired'];
    _isReviewEnableProjectSelected = json['isReviewEnableProjectSelected'];
    _isAmessageProjectSelected = json['isAmessageProjectSelected'];
    _generateURI = json['generateURI'];
  }
  SearchLocationListVo.fromDBJson(dynamic response) {
    dynamic json = jsonDecode(response);
    _totalDocs = json['totalDocs'];
    _recordBatchSize = json['recordBatchSize'];
    if (json['data'] != null) {
      _data = [];
      json['data'].forEach((v) {
        _data?.add(SearchLocationData.fromDBJson(v));
      });
    }
    _isSortRequired = json['isSortRequired'];
    _isReviewEnableProjectSelected = json['isReviewEnableProjectSelected'];
    _isAmessageProjectSelected = json['isAmessageProjectSelected'];
    _generateURI = json['generateURI'];
  }

  num? _totalDocs;
  num? _recordBatchSize;
  List<SearchLocationData>? _data;
  bool? _isSortRequired;
  bool? _isReviewEnableProjectSelected;
  bool? _isAmessageProjectSelected;
  bool? _generateURI;

  SearchLocationListVo copyWith({
    num? totalDocs,
    num? recordBatchSize,
    List<SearchLocationData>? data,
    bool? isSortRequired,
    bool? isReviewEnableProjectSelected,
    bool? isAmessageProjectSelected,
    bool? generateURI,
  }) =>
      SearchLocationListVo(
        totalDocs: totalDocs ?? _totalDocs,
        recordBatchSize: recordBatchSize ?? _recordBatchSize,
        data: data ?? _data,
        isSortRequired: isSortRequired ?? _isSortRequired,
        isReviewEnableProjectSelected:
            isReviewEnableProjectSelected ?? _isReviewEnableProjectSelected,
        isAmessageProjectSelected: isAmessageProjectSelected ?? _isAmessageProjectSelected,
        generateURI: generateURI ?? _generateURI,
      );

  num? get totalDocs => _totalDocs;

  num? get recordBatchSize => _recordBatchSize;

  List<SearchLocationData>? get data => _data;

  bool? get isSortRequired => _isSortRequired;

  bool? get isReviewEnableProjectSelected => _isReviewEnableProjectSelected;

  bool? get isAmessageProjectSelected => _isAmessageProjectSelected;

  bool? get generateURI => _generateURI;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['totalDocs'] = _totalDocs;
    map['recordBatchSize'] = _recordBatchSize;
    if (_data != null) {
      map['data'] = _data?.map((v) => v.toJson()).toList();
    }
    map['isSortRequired'] = _isSortRequired;
    map['isReviewEnableProjectSelected'] = _isReviewEnableProjectSelected;
    map['isAmessageProjectSelected'] = _isAmessageProjectSelected;
    map['generateURI'] = _generateURI;
    return map;
  }
}

/// id : "111550321$$OhC2Ou#2116416$$Ko7BJg"
/// value : "!!PIN_ANY_APP_TYPE_20_9\\130401\\DV04\\Balcony"
/// dataCenterId : 0
/// isSelected : false
/// imgId : -1
/// isActive : true

class SearchLocationData {
  SearchLocationData({
    String? id,
    String? value,
    num? dataCenterId,
    bool? isSelected,
    num? imgId,
    bool? isActive,
    String? searchTitle,
  }) {
    _id = id;
    _value = value;
    _dataCenterId = dataCenterId;
    _isSelected = isSelected;
    _imgId = imgId;
    _isActive = isActive;
    _searchTitle = searchTitle;
  }

  SearchLocationData.fromJson(dynamic json) {
    _id = json['id'];
    _value = json['value'];
    _dataCenterId = json['dataCenterId'];
    _isSelected = json['isSelected'];
    _imgId = json['imgId'];
    _isActive = json['isActive'];
  }
  SearchLocationData.fromDBJson(dynamic json){
    _id = '${json['FolderId'].toString()}#${json['ProjectId'].toString()}';
    _value = json['LocationPath'];
    _dataCenterId = 0;
    _isSelected = false;
    _imgId = json['IsFavorite'];
    _isActive = json['isActive'];
  }
  String? _id;
  String? _value;
  num? _dataCenterId;
  bool? _isSelected;
  num? _imgId;
  bool? _isActive;
  String? _searchTitle;

  SearchLocationData copyWith({
    String? id,
    String? value,
    num? dataCenterId,
    bool? isSelected,
    num? imgId,
    bool? isActive,
    String? searchTitle,
  }) =>
      SearchLocationData(
          id: id ?? _id,
          value: value ?? _value,
          dataCenterId: dataCenterId ?? _dataCenterId,
          isSelected: isSelected ?? _isSelected,
          imgId: imgId ?? _imgId,
          isActive: isActive ?? _isActive,
          searchTitle: searchTitle ?? _searchTitle);

  String? get id => _id;

  String? get value => _value;

  set value(String? value) {
    _value = value;
  }

  String? get searchTitle => _searchTitle;

  set searchTitle(String? value) {
    _searchTitle = value;
  }

  num? get dataCenterId => _dataCenterId;

  bool? get isSelected => _isSelected;

  num? get imgId => _imgId;

  bool? get isActive => _isActive;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['value'] = _value;
    map['dataCenterId'] = _dataCenterId;
    map['isSelected'] = _isSelected;
    map['imgId'] = _imgId;
    map['isActive'] = _isActive;
    return map;
  }
}
