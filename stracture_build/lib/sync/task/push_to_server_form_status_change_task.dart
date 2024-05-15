import 'dart:convert';

import 'package:field/networking/network_response.dart';
import 'package:field/offline_injection_container.dart' as offline_di;

import '../../data_source/forms/form_local_data_source.dart';
import '../../domain/use_cases/site/create_form_use_case.dart';
import '../../logger/logger.dart';
import 'base_sync_task.dart';

class PushToServerFormStatusChangeTask extends BaseSyncTask {
  final CreateFormUseCase useCase = offline_di.getIt<CreateFormUseCase>();

  PushToServerFormStatusChangeTask(super.syncRequestTask, super.syncCallback);

  Future<void> formStatusChangeTask(Map<String,dynamic> paramData) async {
    FormLocalDataSource frmDb = await getDatabaseManager();
    var result = await frmDb.getPushToServerRequestData(paramData);
    if (result.isNotEmpty) {
      var postDataNode = jsonDecode(result);
      if (postDataNode.isNotEmpty) {
        if (postDataNode.containsKey("url")) {
          postDataNode.remove("url");
        }
        Result response = await useCase.formStatusChangeTaskToServer(postDataNode);
        if (response is SUCCESS) {
          try {
            var data = response.data;
            try {
              await parseFormStatusChangeData(data, postDataNode);
            } catch (e) {
              Log.d("FormStatusChangeSyncTask _getFormStatusChangeTask exception $e");
            }
          } catch (e) {
            Log.d("FormStatusChangeSyncTask _getFormStatusChangeTask exception $e");
          }
        }
      }
    }
  }

  parseFormStatusChangeData(var response, Map<String, dynamic> postDataNode) async {
    try {
      FormLocalDataSource frmDb = await getDatabaseManager();
      await frmDb.updateOfflineFormStatusChangedData(response, postDataNode);
    } catch (e) {
      Log.e("CFieldFormDatabaseManager::", "parseFormStatusChangeData strRequestData empty :: $e");
    }
  }

  Future<FormLocalDataSource> getDatabaseManager() async {
    FormLocalDataSource db = FormLocalDataSource();
    await db.init();
    return db;
  }
}
