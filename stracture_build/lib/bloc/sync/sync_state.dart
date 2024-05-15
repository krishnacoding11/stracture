import 'package:field/data/model/sync/sync_status_data_vo.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';

import '../../utils/field_enums.dart';

abstract class SyncState extends FlowState {}

class SyncInitial extends SyncState {
  @override
  List<Object?> get props => [];
}
class SyncStartState extends SyncState {
  SyncStartState();
  @override
  List<Object?> get props => [];
}
class SyncCompleteState extends SyncState {
  bool? isNeedToRefreshData = false;
  SyncCompleteState({this.isNeedToRefreshData});
  @override
  List<Object?> get props => [DateTime.now().toString(),isNeedToRefreshData];
}
class SyncRunState extends SyncState {
  @override
  List<Object?> get props => [];
}

class SyncProgressState extends SyncState {
  final int progress;
  final String projectId;
  final String? time;
  final ESyncStatus? syncStatus;

  SyncProgressState(this.progress, this.projectId, this.syncStatus,{this.time});

  @override
  List<Object?> get props => [progress, projectId, syncStatus];
}

class SyncLocationProgressState extends SyncState {
  List<SiteSyncStatusDataVo> locationSitesSyncDataVo;

  SyncLocationProgressState(this.locationSitesSyncDataVo);

  @override
  List<Object?> get props => [DateTime.now().toString()];
}
