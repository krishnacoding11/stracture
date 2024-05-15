import 'dart:convert';

import 'package:field/networking/network_response.dart';
import 'package:field/offline_injection_container.dart' as offline_di;

import '../../data_source/forms/form_local_data_source.dart';
import '../../domain/use_cases/site/create_form_use_case.dart';
import '../../logger/logger.dart';
import 'base_sync_task.dart';

class PushToServerFormOherActionTask extends BaseSyncTask {
  final CreateFormUseCase useCase = offline_di.getIt<CreateFormUseCase>();

  PushToServerFormOherActionTask(super.syncRequestTask, super.syncCallback);

  Future<void> formOtherActionTask(Map<String, dynamic> paramData) async {
    FormLocalDataSource frmDb = await getDatabaseManager();
    var result = await frmDb.getPushToServerRequestData(paramData);
    if (result.isNotEmpty) {
      var postDataNode = await _requestPostData(result);
      if (postDataNode.isNotEmpty) {
        Result response = await useCase.formOtherActionTaskToServer(postDataNode);
        if (response is SUCCESS) {
          try {
            var data = response.data;
            try {
              await parseFormOtherActionData(data, postDataNode);
            } catch (e) {
              Log.d("FormOtherActionTaskToServer exception $e");
            }
          } catch (e) {
            Log.d("FormOtherActionTaskToServer exception $e");
          }
        }
      }
    }
  }

  parseFormOtherActionData(var response, Map<String, dynamic> postDataNode) async {
    try {
      FormLocalDataSource frmDb = await getDatabaseManager();
      await frmDb.removeOfflineFormActivityForAction(response, postDataNode);
    } catch (e) {
      Log.e("CFieldFormDatabaseManager::", "parseFormDistributionAction strRequestData empty :: $e");
    }
  }

  Future<Map<String, dynamic>> _requestPostData(String result) async {
    Map<String, dynamic> postDataNode = {};
    var requestPostDataNode = jsonDecode(result);
    if (requestPostDataNode is Map) {
      postDataNode = requestPostDataNode as Map<String, dynamic>;
    }
    return postDataNode;
  }

  Future<FormLocalDataSource> getDatabaseManager() async {
    FormLocalDataSource db = FormLocalDataSource();
    await db.init();
    return db;
  }
}
