import 'package:field/data/model/form_status_history_vo.dart';
import 'package:field/database/dao.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/extensions.dart';

class FormStatusHistoryDao extends Dao<FormStatusHistoryVO>{
  static const tableName = 'FormStatusHistoryTbl';

  static const projectId = "ProjectId";
  static const formTypeId = "FormTypeId";
  static const formId = "FormId";
  static const messageId = "MessageId";
  static const actionUserId = "ActionUserId";
  static const actionUserName = "ActionUserName";
  static const actionUserOrgName = "ActionUserOrgName";
  static const actionProxyUserId = "ActionProxyUserId";
  static const actionProxyUserName = "ActionProxyUserName";
  static const actionProxyUserOrgName = "ActionProxyUserOrgName";
  static const actionUserTypeId = "ActionUserTypeId";
  static const actionId = "ActionId";
  static const actionDate = "ActionDate";
  static const description = "Description";
  static const remarks = "Remarks";
  static const createDateInMS = "CreateDateInMS";
  static const jsonData = "JsonData";

  String get fields => "$projectId TEXT NOT NULL,"
  "$formTypeId TEXT,"
  "$formId TEXT NOT NULL,"
  "$messageId TEXT,"
  "$actionUserId TEXT NOT NULL,"
  "$actionUserName TEXT,"
  "$actionUserOrgName TEXT,"
  "$actionProxyUserId TEXT NOT NULL,"
  "$actionProxyUserName TEXT,"
  "$actionProxyUserOrgName TEXT,"
  "$actionUserTypeId INTEGER NOT NULL,"
  "$actionId TEXT NOT NULL,"
  "$actionDate TEXT NOT NULL,"
  "$description TEXT DEFAULT \"\","
  "$remarks TEXT DEFAULT \"\","
  "$createDateInMS TEXT NOT NULL,"
  "$jsonData TEXT DEFAULT \"\"";

  String get primaryKeys => ",PRIMARY KEY($projectId,$formId,$createDateInMS)";

  @override
  String get createTableQuery => "CREATE TABLE IF NOT EXISTS $tableName($fields$primaryKeys)";

  @override
  List<FormStatusHistoryVO> fromList(List<Map<String, dynamic>> query) {
    return List<FormStatusHistoryVO>.from(query.map((element) => fromMap(element))).toList();
  }

  @override
  String get getTableName => tableName;

  @override
  Future<List<Map<String, dynamic>>> toListMap(List<FormStatusHistoryVO> objects) async{
    List<Map<String, dynamic>> itemList = [];
    for (var element in objects) {
      itemList.add(await toMap(element));
  }
    return itemList;
  }

  @override
  FormStatusHistoryVO fromMap(Map<String, dynamic> query) {
    FormStatusHistoryVO formStatusHistoryVO = FormStatusHistoryVO();
    formStatusHistoryVO.strProjectId = query[projectId];
    formStatusHistoryVO.strFormTypeId = query[formTypeId];
    formStatusHistoryVO.strFormId = query[formId];
    formStatusHistoryVO.strMessageId = query[messageId];
    formStatusHistoryVO.strActionUserId = query[actionUserId];
    formStatusHistoryVO.strActionUserName = query[actionUserName];
    formStatusHistoryVO.strActionUserOrgName = query[actionUserOrgName];
    formStatusHistoryVO.strActionProxyUserId = query[actionProxyUserId];
    formStatusHistoryVO.strActionProxyUserName = query[actionProxyUserName];
    formStatusHistoryVO.strActionProxyUserOrgName = query[actionProxyUserOrgName];
    formStatusHistoryVO.strActionUserTypeId = query[actionUserTypeId];
    formStatusHistoryVO.strActionId = query[actionId];
    formStatusHistoryVO.strActionDate = query[actionDate];
    formStatusHistoryVO.strDescription = query[description];
    formStatusHistoryVO.strRemarks = query[remarks];
    formStatusHistoryVO.strCreateDateInMS = query[createDateInMS];
    formStatusHistoryVO.strJsonData = query[jsonData];
    return formStatusHistoryVO;
  }

  @override
  Future<Map<String, dynamic>> toMap(FormStatusHistoryVO object) {
    return Future.value({
      projectId:object.strProjectId?.plainValue()??"",
      formTypeId:object.strFormTypeId?.plainValue()??"",
      formId:object.strFormId?.plainValue()??"",
      messageId:object.strMessageId?.plainValue()??"",
      actionUserId:object.strActionUserId?.plainValue()??"",
      actionUserName:object.strActionUserName??"",
      actionUserOrgName:object.strActionUserOrgName??"",
      actionProxyUserId:object.strActionProxyUserId?.plainValue()??"",
      actionProxyUserName:object.strActionProxyUserName??"",
      actionProxyUserOrgName:object.strActionProxyUserOrgName??"",
      actionUserTypeId:object.strActionUserTypeId?.plainValue()??"",
      actionId:object.strActionId?.plainValue()??"",
      actionDate:object.strActionDate??"",
      description:object.strDescription??"",
      remarks:object.strRemarks??"",
      createDateInMS:object.strCreateDateInMS??"",
      jsonData:object.strJsonData??"",
    });
  }

  Future<void> insert(List<FormStatusHistoryVO> formStatusHistoryList) async {
    final path = await AppPathHelper().getUserDataDBFilePath();
    final db = DatabaseManager(path);
    try {
      db.executeTableRequest(createTableQuery);
      List<Map<String, dynamic>> rowList = await toListMap(formStatusHistoryList);
      await db.executeDatabaseBulkOperations(tableName, rowList);
    } on Exception catch (e) {
      Log.d(e);
    }
  }
}