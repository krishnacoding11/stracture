import 'dart:convert';
import 'dart:core';

import '../../../utils/constants.dart';

class SyncManagerPropertyDetails {

  SyncManagerPropertyDetails({
    int? fieldFormListCount,
    int? maxThreadForMobileDevice,
    int? fieldOfflineLocationSizeSyncLimit,
    int? akamaiDownloadLimit,
    int? fieldBatchDownloadSize,
    int? fieldBatchDownloadFileLimit,
    int? fieldFormMessageListCount,
    int? maxHomePageShortcutConfigField,
  }) {
     _fieldFormListCount = fieldFormListCount ?? 25;
    _maxThreadForMobileDevice = maxThreadForMobileDevice ?? AConstants.maxThreadForMobileDevice;
    _fieldOfflineLocationSizeSyncLimit = fieldOfflineLocationSizeSyncLimit??100;
     _akamaiDownloadLimit=akamaiDownloadLimit ?? (1000 * 1000);
    _fieldBatchDownloadSize=fieldBatchDownloadSize ?? (250 * 1000);
    _fieldBatchDownloadFileLimit=fieldBatchDownloadFileLimit ?? 250;
    _fieldFormMessageListCount=fieldFormMessageListCount ?? 5;
    _maxHomePageShortcutConfigField=maxHomePageShortcutConfigField ?? 60;
  }

  int _fieldFormListCount=25;
  int _maxThreadForMobileDevice=AConstants.maxThreadForMobileDevice;
  int _fieldOfflineLocationSizeSyncLimit = 100;
  int _akamaiDownloadLimit=1000 * 1000;
  int _fieldBatchDownloadSize=250 * 1000;
  int _fieldBatchDownloadFileLimit=250;
  int _fieldFormMessageListCount=5;
  int _fieldCustomAttributeSetIdLimit=5;
  int _maxHomePageShortcutConfigField = 60;
  String _pdftronAndroidIosKey="";

  int get fieldFormListCount => _fieldFormListCount;
  int get maxThreadForMobileDevice => _maxThreadForMobileDevice;
  int get fieldOfflineLocationSizeSyncLimit => _fieldOfflineLocationSizeSyncLimit;
  int get akamaiDownloadLimit => _akamaiDownloadLimit;
  int get fieldBatchDownloadSize => _fieldBatchDownloadSize;
  int get fieldBatchDownloadFileLimit => _fieldBatchDownloadFileLimit;
  int get fieldFormMessageListCount => _fieldFormMessageListCount;
  int get fieldCustomAttributeSetIdLimit => _fieldCustomAttributeSetIdLimit;
  int get maxHomePageShortcutConfigField => _maxHomePageShortcutConfigField;
  String get pdftronAndroidIosKey => _pdftronAndroidIosKey;

  SyncManagerPropertyDetails.fromJson(dynamic json){
    json = jsonDecode(json);
    int? temp = int.tryParse(json['fieldFormListCount'].toString());
    if(temp != null && temp > 0){
      _fieldFormListCount= temp;
    }
    temp = int.tryParse(json['maxThreadForMobileDevice'].toString());
    if(temp != null && temp > 0){
      _maxThreadForMobileDevice = temp;
    }
    temp = int.tryParse(json['fieldOfflineLocationSizeSyncLimit'].toString());
    if(temp != null && temp>0){
      _fieldOfflineLocationSizeSyncLimit = temp;
    }
    temp = int.tryParse(json['akamaiDownloadLimit'].toString());
    if(temp != null && temp > 0){
      _akamaiDownloadLimit = (temp/1000).ceil();
    }
    temp = int.tryParse(json['fieldBatchDownloadSize'].toString());
    if(temp != null && temp > 0){
      _fieldBatchDownloadSize = temp * 1000;
    }
    temp = int.tryParse(json['fieldBatchDownloadFileLimit'].toString());
    if(temp != null && temp > 0){
      _fieldBatchDownloadFileLimit = temp;
    }
    temp = int.tryParse(json['fieldFormMessageListCount'].toString());
    if(temp != null && temp > 0){
      _fieldFormMessageListCount = temp;
    }
    temp = int.tryParse(json['fieldCustomAttributeSetIdLimit'].toString());
    if(temp != null && temp > 0){
      _fieldCustomAttributeSetIdLimit = temp;
    }
    temp = int.tryParse(json['maxHomePageShortcutConfigField'].toString());
    if(temp != null && temp > 0){
      _maxHomePageShortcutConfigField = temp;
    }
    String? pdfTronKey = json['pdftronAndroidIosKey'];
    if(pdfTronKey != null)
      {
        _pdftronAndroidIosKey = pdfTronKey;
      }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    return map;
  }
}