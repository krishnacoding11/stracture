import 'package:field/bloc/Filter/filter_cubit.dart';
import 'package:field/bloc/dashboard/home_page_cubit.dart';
import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/task_action_count/task_action_count_cubit.dart';
import 'package:field/data/local/project_list/project_list_local_repository.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/injection_container.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/screen/drawer_page.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/global.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/toolbar_mixin.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/project_list/project_list_cubit.dart';
import '../../bloc/recent_location/recent_location_cubit.dart';
import '../../bloc/sync/sync_cubit.dart';
import '../../data/model/popupdata_vo.dart';
import '../../data/model/user_vo.dart';
import '../../networking/internet_cubit.dart';
import '../../utils/constants.dart';
import '../../utils/utils.dart';
import '../managers/color_manager.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({Key? key}) : super(key: key);

  @override
  State<DashboardWidget> createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> with WidgetsBindingObserver, ToolbarTitle {
  String? userName = ' ';
  late ScrollController scrollController;
  AProgressDialog? _aProgressDialog;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // getIt<SyncCubit>().getNotification();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    scrollController = ScrollController();
    _displayUserName();
    Future.delayed(Duration.zero, () {
      setData();
    });
    getIt<NavigationCubit>().initData();
    getIt<RecentLocationCubit>().initData();
  }

  setData() async {
    await _setSelectedDefaultProjectOffline();
    Future.delayed(Duration(milliseconds: 700), () async {
      if (await StorePreference.getBoolData(AConstants.keyisLanguageChange) == true) {
        Utility.showAlertWithOk(NavigationUtils.mainNavigationKey.currentContext!, NavigationUtils.mainNavigationKey.currentContext!.toLocale!.preferred_language_change);
        StorePreference.setBoolData(AConstants.keyisLanguageChange, false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: AColors.white));
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AColors.black,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
    return MultiBlocListener(
      listeners: [
        BlocListener<InternetCubit, InternetState>(listenWhen: (previous, current) {
          return previous.runtimeType != current.runtimeType;
        }, listener: (context, state) async {
          bool workOffline = await StorePreference.isWorkOffline();
          if (!workOffline) {
            if (state is InternetDisconnected) {
              await Utility.showNetworkLostBanner(context);
              NavigationUtils.reloadApp();
              getIt<TaskActionCountCubit>().getTaskActionCount();
              try {
                if (!localhostServer.isRunning()) {
                  await localhostServer.start();
                  isOnlineButtonSyncClicked = true;
                }
              } catch (e) {
                Log.d(e);
              }
            } else {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              await StorePreference.checkAndSetSelectedProjectIdHash();
              NavigationUtils.reloadApp();
              getIt<TaskActionCountCubit>().getTaskActionCount();
              await localhostServer.close();
              isOnlineButtonSyncClicked = true;
            }
          } else {
            NavigationUtils.reloadApp();
            getIt<TaskActionCountCubit>().getTaskActionCount();
            try {
              await localhostServer.start();
            } catch (e) {
              Log.d(e);
            }
            isOnlineButtonSyncClicked = true;
          }
        }),
        BlocListener<ProjectListCubit, FlowState>(
          listener: (_, state) async {
            if (state is LoadedState) {
              if (state.isLoading) {
                _aProgressDialog?.show();
              } else {
                _aProgressDialog?.dismiss();
              }
            } else if (state is ProjectErrorState) {
              context.showSnack(context.toLocale!.something_went_wrong);
            }
          },
        ),
      ],
      child: const DrawerPage(),
    );
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.removeObserver(this);
    _aProgressDialog?.dismiss();
    // getIt<SyncCubit>().stopIsolate();
    super.dispose();
  }

  _displayUserName() async {
    User? user = await StorePreference.getUserData();
    setState(() {
      userName = user?.usersessionprofile!.firstName;
    });
  }

  Future<void> _setSelectedDefaultProjectOffline() async {
    if (!isNetWorkConnected()) {
      Future.delayed(const Duration(milliseconds: 500)).then((value) async {
        if (await getIt<ProjectListLocalRepository>().isProjectMarkedOffline() && await getIt<ProjectListLocalRepository>().isSiteDataMarkedOffline()) {
          List<Project>? prj = await getIt<ProjectListLocalRepository>().getMarkedOfflineProjects();
          if (prj.isNotEmpty) {
            await setDefaultOfflineProject(prj.first);
          }
        } else {
          updateTitle(context.toLocale!.home, NavigationMenuItemType.home);
        }
      });
    } else {
      await _updateSelectedProjectDetail();
      Project? project = await StorePreference.getSelectedProjectData();
      getIt<FilterCubit>().getFilterAttributeList("2");
      //MAKE A CALL FOR AUTO-SYNC DATA OFFLINE TO ONLINE.
      if (isOnlineButtonSyncClicked! && project != null) {
        getIt<SyncCubit>().autoSyncOfflineToOnline();
        isOnlineButtonSyncClicked = false;
      }
    }
  }

  Future<void> setDefaultOfflineProject(Project project) async {
    await StorePreference.setSelectedProjectData(project);

    getIt<RecentLocationCubit>().initData();
    getIt<TaskActionCountCubit>().getTaskActionCount();
    getIt<FilterCubit>().getFilterAttributeList("2");
    updateTitle(project.projectName, NavigationMenuItemType.home);
  }

  /// if ProjectId value is plain then need to update ProjectId with hash value
  /// while going to online mode.
  Future<void> _updateSelectedProjectDetail() async {
    Project? project = await StorePreference.getSelectedProjectData();
    if (project != null && !project.projectID.toString().isHashValue()) {
      if (context.mounted) {
        _aProgressDialog ??= AProgressDialog(context);
      }
      Popupdata data = Popupdata(id: project?.projectID ?? "");
      await getIt<ProjectListCubit>().getProjectDetail(data, false, fromScreen: FromScreen.dashboard);
    } else {
      getIt<TaskActionCountCubit>().getTaskActionCount();
      if (project != null) {
        updateTitle(project.projectName, NavigationMenuItemType.home);
      } else {
        updateTitle(context.toLocale!.home, NavigationMenuItemType.home);
      }
    }
  }
}
