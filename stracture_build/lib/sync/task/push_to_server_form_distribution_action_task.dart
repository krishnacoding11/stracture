import 'dart:convert';

import 'package:field/networking/network_response.dart';
import 'package:field/offline_injection_container.dart' as offline_di;

import '../../data_source/forms/form_local_data_source.dart';
import '../../domain/use_cases/site/create_form_use_case.dart';
import '../../logger/logger.dart';
import 'base_sync_task.dart';

class PushToServerFormDistributionActionTask extends BaseSyncTask {
  final CreateFormUseCase useCase = offline_di.getIt<CreateFormUseCase>();

  PushToServerFormDistributionActionTask(super.syncRequestTask, super.syncCallback);

  Future<void> formDistributionActionTask(Map<String,dynamic> paramData) async {
    FormLocalDataSource frmDb = await getDatabaseManager();
    var result = await frmDb.getPushToServerRequestData(paramData);
    if (result.isNotEmpty) {
      var postDataNode = await _requestPostData(result);
      if (postDataNode.isNotEmpty) {
        if (postDataNode.containsKey("url")) {
          postDataNode.remove("url");
        }
        Result response = await useCase.formDistActionTaskToServer(postDataNode);
        if (response is SUCCESS) {
          try {
            var data = response.data;
            await parseFormDistributionAction(data, postDataNode);
          } catch (e) {
            Log.d("formDistActionTaskToServer exception $e");
          }
        }
      }
    }
  }

  parseFormDistributionAction(var response, Map<String, dynamic> postDataNode) async {
    try {
      FormLocalDataSource frmDb = await getDatabaseManager();
      await frmDb.removeOfflineFormDistributionAction(response, postDataNode);
    } catch (e) {
      Log.e("CFieldFormDatabaseManager::", "parseFormDistributionAction strRequestData empty :: $e");
    }
  }

  Future<Map<String, dynamic>> _requestPostData(String result) async {
    Map<String, dynamic> postDataNode = {};
    try {
      var requestPostDataNode = jsonDecode(result);
      if (requestPostDataNode is Map) {
        postDataNode = requestPostDataNode as Map<String, dynamic>;
        postDataNode["isFromAndroidApp"] = true;
        String strOfflineCreatedDate = requestPostDataNode["CreateDateInMS"];
        if (strOfflineCreatedDate.isNotEmpty) {
          postDataNode["offlineFormCreatedDateInMS"] = strOfflineCreatedDate.toString();
        }
      }
    } catch (e) {
      Log.d("_requestPostData exception :: $e");
    }
    return postDataNode;
  }

  Future<FormLocalDataSource> getDatabaseManager() async {
    FormLocalDataSource db = FormLocalDataSource();
    await db.init();
    return db;
  }
}
