abstract class UploadRepository<REQUEST,RESPONSE> {
  Future<RESPONSE?>? getLockValidation(Map<String, dynamic> request);
  Future<RESPONSE?>? checkUploadEventValidation(Map<String, dynamic> request);
  Future<RESPONSE?>? simpleFileUploadToServer(Map<String, dynamic> request);
}