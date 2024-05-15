import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:field/data/model/task_form_listing_reponse.dart';
import 'package:field/domain/use_cases/task_form_listing/task_form_use_case.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/requestParamsConstants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/get_threed_type_list.dart';
import '../../injection_container.dart';
import '../../presentation/base/state_renderer/state_renderer.dart';
import '../../utils/store_preference.dart';

part 'task_form_list_state.dart';

enum StackDrawerOptions { drawerBody, filter, datePicker }

class TaskFormListingCubit extends Cubit<TaskFormListingState> {
  final TaskFormListingUseCase _taskFormListingUseCase;
  List<ElementVoList> elementList = [];
  TaskFormListingCubit({TaskFormListingUseCase? taskFormListingUseCase})
      : _taskFormListingUseCase = taskFormListingUseCase ?? getIt<TaskFormListingUseCase>(),
        super(PaginationListInitial());

  bool isSnaggingOpen = false;
  bool isSnaggingOpenFullScreen = false;
  var selectedProject;
  bool isSorted = false;
  bool isFullScreen = false;

  getTaskFormListingList(String modelId) async {
    emit(TaskFormListingLoadingState());
    selectedProject = await StorePreference.getSelectedProjectData();
    Map<String, dynamic> request = {
      "projectId": selectedProject.projectID,
      "action_id": 121,
      "modelVersionID": -1,
      "viewType": "MODEL",
      "modelId": modelId,
      RequestConstants.recordBatchSize : "2",
      "model_id": modelId,
    };
    TaskFormListingResponse taskFormListingResponse = await _taskFormListingUseCase.getTaskFormListingList(request);
    elementList = taskFormListingResponse.elementVoList;
    Future.delayed(Duration(seconds: 2));
    emit(TaskFormListingLoadedState());
  }

  void emitPaginationListInitial() {
    emit(PaginationListInitial());
  }
}
