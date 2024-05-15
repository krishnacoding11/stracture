import 'dart:io';

import 'package:field/bloc/sidebar/sidebar_state.dart';
import 'package:field/data/dao/url_dao.dart';
import 'package:field/database/db_manager.dart';
import 'package:field/domain/use_cases/user_profile_setting/user_profile_setting_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/sync/db_config.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/url_helper.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';

import '../../data/model/user_vo.dart';
import '../../firebase/notification_service.dart';
import '../../utils/constants.dart';
import '../base/base_cubit.dart';
import '../login/login_cubit.dart';

enum SidebarMenuItemType {
  projects(Icons.business),
  tasks(Icons.ac_unit),
  settings(Icons.settings),
  help(Icons.help_outline),
  about(Icons.info_outline),
  logout(Icons.logout);

  const SidebarMenuItemType(this.icon);

  final IconData icon;
}

class SidebarCubit extends BaseCubit {
  bool _isOnline = false;
  String? userImgUrl;
  String? userFirstname;
  Map<String, String>? headersMap;
  User? user;
  int? lastStoreTimeStamp;
  AppConfig appConfig = di.getIt<AppConfig>();
  File? offlineUserImageFile;

  SidebarCubit()
      : super(InitialState(
            stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE));

  get isOnline => _isOnline;

  set setIsOnline(bool isTrue) {
    _isOnline = isTrue;
  }

  void initData() async {
    if(lastStoreTimeStamp == null || (lastStoreTimeStamp != appConfig.storedTimestamp)) {emitState(LoadingState(
        stateRendererType: StateRendererType.FULL_SCREEN_LOADING_STATE));
     user = await StorePreference.getUserData();
      if (user != null) {
        userFirstname  = user!.usersessionprofile!.firstName!;
        String baseURL = await UrlHelper.getAdoddleURL(null);
        userImgUrl = baseURL +
            sprintf(AConstants.userImageUri, [
              user!.usersessionprofile?.userID,
              appConfig.storedTimestamp
            ]);
        headersMap = {
          'Cookie':
          'ASessionID=${user!.usersessionprofile?.aSessionId};JSessionID=${user!
              .usersessionprofile?.currentJSessionID}'
        };
        _isOnline = isNetWorkConnected();
        if(!_isOnline){
          await getImageInOffline();
        }
        emitState(UserProfileSidebarState(userFirstname!, userImgUrl!, headersMap!));
        lastStoreTimeStamp = appConfig.storedTimestamp;
      } else {
        emitState(ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE,
            "Login issue, try with re-login"));
      }
    }
  }

  Future<void> getImageInOffline() async {
    String? strUserImage = await di.getIt<UserProfileSettingUseCase>().getImageInOffline();
    offlineUserImageFile = File(strUserImage!);
  }

  getSidebarMenuList() {
    List<SidebarMenuItemType> itemList = [
      SidebarMenuItemType.projects,
      //SidebarMenuItemType.tasks,
      SidebarMenuItemType.settings,
      SidebarMenuItemType.help,
      SidebarMenuItemType.about,
      SidebarMenuItemType.logout,
    ];
    return itemList;
  }

  onLogoutClick() async {
    await NotificationService.init();
    final loginCubit = di.getIt<LoginCubit>();
    await StorePreference.setPushNotificationEnable(false);
    await loginCubit.registerDeviceToServer();
    NotificationService.deleteToken();
    await loginCubit.doLogout();
    await DBConfig().removeAndCreateSyncStatusTables();
    await StorePreference.clearUserPreferenceData();
    final path = await DatabaseManager.getUserDBPath();
    final db = DatabaseManager("$path/${AConstants.userDbFile}");
    try {
      await db.executeTableRequest(UrlDao().deleteDataQuery);
    } on Exception catch (_) {
    }
    //Delete log sync file
    await Utility.deleteSyncLogFile();
  }
}
