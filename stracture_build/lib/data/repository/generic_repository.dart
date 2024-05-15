abstract class GenericRepository<REQUEST,RESPONSE> {
  Future<RESPONSE?>? getHashValue(Map<String, dynamic> request);
  Future<RESPONSE?>? getDeviceConfiguration();
}