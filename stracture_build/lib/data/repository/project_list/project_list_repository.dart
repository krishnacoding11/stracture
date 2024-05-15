import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/sync_size_vo.dart';
import 'package:field/networking/network_response.dart';

abstract class ProjectListRepository {
  Future<List<Project>> getProjectList(int page, int batchSize, Map<String, dynamic> request);
  Future<List<Popupdata>> getPopupDataList(int page, int batchSize, Map<String, dynamic> request);
  Future<dynamic> setFavProject(Map<String, dynamic> request);
  Future<Result> getProjectAndLocationList(Map<String, dynamic> request);
  Future<Result> getColumnHeaderList(Map<String, dynamic> request);
  Future<Result> getFormList(Map<String, dynamic> request);
  Future<Result> getFormMessageBatchList(Map<String, dynamic> request);
  Future<Result> downloadFormAttachmentInBatch(Map<String, dynamic> request,{bool bAkamaiDownload=true});
  Future<Result> getServerTime(Map<String, dynamic> request);
  Future<Result> getHashedValue(Map<String, dynamic> request);
  Future<Result> getStatusStyle(Map<String, dynamic> request);
  Future<Result> getManageTypeList(Map<String, dynamic> request);
  Future<Result> getWorkspaceSettings(Map<String, dynamic> request);
  Future<List<SyncSizeVo>> deleteItemFromSyncTable(Map<String, dynamic> request);

  Future<Result> getDiscardedFormIds(Map<String, dynamic> request);
}