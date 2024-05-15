import '../../data/local/project_list/project_list_local_repository.dart';
import '../../data/model/site_location.dart';
import '../../injection_container.dart';
import '../../networking/network_info.dart';
import '../../presentation/base/state_renderer/state_render_impl.dart';
import '../../presentation/base/state_renderer/state_renderer.dart';
import '../../utils/user_activity_preference.dart';
import '../base/base_cubit.dart';

class RecentLocationCubit extends BaseCubit {
  RecentLocationCubit() : super(InitialState(stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE));

  bool isProjectSelected = true;

  void initData() async {
    if (!isNetWorkConnected()) {
      isProjectSelected = await getIt<ProjectListLocalRepository>().isProjectMarkedOffline();
      if (!isProjectSelected) {
        emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
        return;
      }
    }
    emitState(LoadingState(stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE));
    SiteLocation? lastLocation = await getLastLocationData();
    emitState(SuccessState([lastLocation]));
  }

  updateLastLocationError() async {
    SiteLocation? lastLocation = await getLastLocationData();
    if (lastLocation != null) {
      lastLocation.hasPermissionError = true;
      await setLastLocationData(lastLocation);
    }
  }

  void permissionError(String errorMsg) {
    emitState(ErrorState(StateRendererType.CONTENT_SCREEN_STATE, errorMsg));
  }
}
