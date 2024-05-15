import 'dart:async';

import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/extensions.dart';
import 'package:meta/meta.dart';

import '../../sync/task/offline_project_mark.dart';

part 'project_item_state.dart';

class ProjectItemCubit extends BaseCubit {
  ProjectItemCubit() : super(ProjectItemInitial());

  void itemDeleteRequest({String projectId = "", bool isProcessing = false}) {
    emitState(ItemDeleteRequestState(projectId: projectId, isProcessing: false));
  }

  void itemDeleteRequestCancel({String projectId = ""}) {
    emitState(ItemDeleteRequestCancelState(projectId: projectId));
  }

  ///old function for utilizing Storage space but not released when deleted
  // void itemDeleteRequestSuccess({String projectId = "", bool isProcessing = true}) {
  //   emitState(ItemDeleteRequestState(projectId: projectId, isProcessing: true));
  //   removingProjectItem(projectId).whenComplete(() {
  //     emitState(ItemDeleteRequestSuccessState(projectId: projectId));
  //   });
  // }
  ///New function for utilizing Storage space and storage also released when deleted
  void itemDeleteRequestSuccess({String projectId = "", bool isProcessing = true}) async {
    emitState(ItemDeleteRequestState(projectId: projectId, isProcessing: true));
    await removingProjectItem(projectId);
    emitState(ItemDeleteRequestSuccessState(projectId: projectId));
    emitState(ProjectItemInitial());
  }

  Future<void> removingProjectItem(String projectId) async {
    final offlineProjectMark = OfflineProjectMark();
    /// added await here for utilizing Storage space and storage also released when deleted
    await offlineProjectMark.deleteProjectDetails(projectId: projectId.plainValue());
  }
}
