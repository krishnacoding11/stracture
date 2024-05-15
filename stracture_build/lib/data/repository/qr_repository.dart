enum ResponseStatus { unknown, success, failure}

abstract class QrRepository<REQUEST,RESPONSE> {
  Future<RESPONSE?>? checkQRCodePermission(Map<String, dynamic> request);
  Future<RESPONSE?>? getFormPrivilege(Map<String, dynamic> request);
  Future<RESPONSE?>? getFieldEnableSelectedProjectsAndLocations(Map<String, dynamic> request);
  Future<RESPONSE?>? getLocationDetails(Map<String, dynamic> request);
}