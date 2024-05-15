import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/userprofilesetting/user_profile_setting_state.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/internet_cubit.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/sharedpreference.dart';
import 'package:field/utils/store_preference.dart';

enum SyncDateRange {
  lastWeek,
  last2Weeks,
  lastMonth,
  last2Months,
  last6Months
}

class UserProfileSettingOfflineCubit extends BaseCubit {
  bool workOffline = false;
  bool imageCompression = false;
  bool syncOnMobileData = false;
  bool includeAttachments = true;
  bool includeAssociations = false;
  bool includeSubLocationData = false;
  bool includeClosedOutTasks = false;
  SyncDateRange selectedDateRange = SyncDateRange.values[0];
  UserProfileSettingOfflineCubit() : super(FlowState());
  AppConfig appConfig = getIt<AppConfig>();

  void getDataFromPreference() async{
    emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
    workOffline = await StorePreference.isWorkOffline();
    imageCompression = await StorePreference.isImageCompressionEnabled();
    syncOnMobileData = await StorePreference.isSyncOnMobileDataEnabled();
    includeAttachments = await StorePreference.isIncludeAttachmentsSyncEnabled();
    includeAssociations = await StorePreference.isIncludeAssociationsSyncEnabled();
    includeSubLocationData = await StorePreference.isIncludeSubLocationDataSyncEnabled();
    includeClosedOutTasks = await StorePreference.isIncludeClosedOutTasksSyncEnabled();
    selectedDateRange = await StorePreference.getSelectedDateRangeSync();
    emitState(ToggleWorkOfflineState(true,time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  Future<void> toggleWorkOffline(bool val) async {
    workOffline = val;
    await PreferenceUtils.setBool(AConstants.workOffline, val);
    await getIt<InternetCubit>().updateConnectionStatus();
    emitState(ToggleWorkOfflineState(val,time: DateTime.now().millisecondsSinceEpoch.toString()));
    PreferenceUtils.setBool("reloadOffline", true);
  }

  Future<void> toggleImageCompression(bool val) async {
    imageCompression = val;
    await PreferenceUtils.setBool("imageCompression", val);
    emitState(ToggleWorkOfflineState(val,time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  /*Future<void> toggleSyncOnMobileData(bool val) async {
    syncOnMobileData = val;
    await PreferenceUtils.setBool("syncOnMobileData", val);
    emitState(ToggleWorkOfflineState(val,time: DateTime.now().millisecondsSinceEpoch.toString()));
  }*/

  /*Future<void> toggleIncludeAttachments(bool val) async {
    includeAttachments = val;
    await PreferenceUtils.setBool("includeAttachments", !val);
    emitState(ToggleWorkOfflineState(val,time: DateTime.now().millisecondsSinceEpoch.toString()));
  }*/

  Future<void> toggleIncludeAssociations(bool val) async {
    includeAssociations = val;
    await PreferenceUtils.setBool("includeAssociations", val);
    emitState(ToggleWorkOfflineState(val,time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  Future<void> toggleIncludeSubLocationData(bool val) async {
    includeSubLocationData = val;
    await PreferenceUtils.setBool("includeSubLocationData", val);
    emitState(ToggleWorkOfflineState(val,time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  Future<void> toggleIncludeClosedOutTasks(bool val) async {
    includeClosedOutTasks = val;
    await PreferenceUtils.setBool("includeClosedOutTasks", val);
    emitState(ToggleWorkOfflineState(val,time: DateTime.now().millisecondsSinceEpoch.toString()));
  }

  Future<void> setSelectedDateRange(int val) async {
    selectedDateRange = SyncDateRange.values[val];
    await PreferenceUtils.setInt("selectedDateRange", val);
    emitState(ToggleWorkOfflineState(true,time: DateTime.now().millisecondsSinceEpoch.toString()));
  }
}