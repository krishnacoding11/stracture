import 'dart:convert';
import 'dart:math';

import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/data/model/notification_detail_vo.dart';
import 'package:field/domain/use_cases/notification/notification_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/utils/extensions.dart';

import '../../data/model/popupdata_vo.dart';
import '../../data/model/project_vo.dart';
import '../../logger/logger.dart';
import '../../networking/network_response.dart';
import '../../presentation/base/state_renderer/state_render_impl.dart';
import '../../utils/app_config.dart';
import '../../utils/store_preference.dart';
import '../../utils/utils.dart';
import '../project_list/project_list_cubit.dart';
import 'notification_state.dart';

class NotificationCubit extends BaseCubit {
  final NotificationUseCase _notificationUsecase;
  AppConfig appConfig = di.getIt<AppConfig>();

  final ProjectListCubit _cubit = di.getIt<ProjectListCubit>();

  NotificationCubit({NotificationUseCase? notificationUseCase}): _notificationUsecase = notificationUseCase ?? di.getIt<NotificationUseCase>(),
        super(FlowState());

  getTaskDetailRequest(Map<String,dynamic> requestData) async{
    emitState(NotificationLoading());
    await getTaskDetailRequestFromNotification(requestData);
  }

  Future<void> getTaskDetailRequestFromNotification(Map<String,dynamic> requestData) async {
    Log.d("getTaskDetailRequest start");
    String? appType = requestData["appType"];
    if (appType != null) {
      appType = requestData["appType"].toString();
    } else {
      appType = "0";
    }
    int entityType = int.parse(requestData["entity_type"]);
    String projectId = requestData["project_id"].toString();
    String resourceParentId = requestData["resource_parent_id"].toString();
    String updateData = ('$projectId#$resourceParentId');

    Map<String, dynamic> requestMap = {};
    requestMap["action_id"] = "174";
    requestMap["appType"] = appType;
    requestMap["entityTypeId"] = entityType;
    requestMap["updateData"] = updateData;
    final result = await _notificationUsecase.sendTaskDetailRequest(requestMap);
    Log.d("getTaskDetailResult:$result");
    if (result is SUCCESS) {
      String jsonString = result.data ?? "";
      var object = jsonDecode(jsonString);
      if (object != null) {
        Map<String, dynamic> map = object[0];
        Log.d("getTaskDetailObject:${map["projectId"]}");
        Project? temp = await StorePreference.getSelectedProjectData();
        String pid = temp?.projectID ?? "";
        if (projectId.plainValue() != pid.plainValue()) {
          Popupdata project = Popupdata(id: projectId);
          await _cubit.getProjectDetail(project, false);
        }
        NotificationDetailVo notificationDetailVoRequest = NotificationDetailVo.fromJson(map);
        final data = {"projectId": notificationDetailVoRequest.projectId, "locationId": notificationDetailVoRequest.locationId.toString(), "isForm": FromScreen.task};
        emitState(NotificationDetailSuccessState(notificationDetailVo: notificationDetailVoRequest, data: data, entityType: entityType));
        StorePreference.removeSelectedPinFilter();
      } else {
        emitState(NotificationErrorState("Something went wrong"));
      }
    }
    else{
      emitState(NotificationErrorState("Something went wrong"));
    }
  }
}



