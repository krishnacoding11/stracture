
abstract class SiteTaskRepository<REQUEST,RESPONSE> {
  Future<RESPONSE?>? getSiteTaskList(Map<String, dynamic> request);
  Future<RESPONSE?>? getExternalAttachmentList(Map<String, dynamic> request);
  Future<RESPONSE?>? getFilterSiteTaskList(Map<String, dynamic> request);
  Future<RESPONSE?> getUpdatedSiteTaskItem(String projectId, String formId);
}