import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/screen/bottom_navigation/tab_navigator.dart';
import 'package:field/utils/navigation_utils.dart';

import '../../domain/use_cases/notification/notification_usecase.dart';
import 'toolbar_state.dart';

class ToolbarCubit extends BaseCubit {

  final NotificationUseCase _notificationUseCase;

  bool isKeyboardOpen = false;

  ToolbarCubit({NotificationUseCase? useCase})
      : _notificationUseCase = useCase ?? di.getIt<NotificationUseCase>(),
        super(ToolbarNavigationItemSelectedState(NavigationMenuItemType.home,'Home'));

  Future updateSelectedItemByPosition(
      NavigationMenuItemType navigationMenuItemType) async {
    String navigationTitle = navigationItems[navigationMenuItemType]?.title ??
        navigationMenuItemType.value;
    updateTitleFromItemType(
        currentSelectedItem: navigationMenuItemType,
        title: navigationTitle);
    emitState(ToolbarNavigationItemSelectedState(navigationMenuItemType,navigationTitle));
  }

  String _updateTitleFromRoute(
      String? routeName, NavigationMenuItemType currentSelectedItem) {
    switch (routeName) {
      case TabNavigatorRoutes.home:
        return navigationItems[NavigationMenuItemType.home]?.title ?? "Home";
      case TabNavigatorRoutes.folder:
        return "Folder";
      case TabNavigatorRoutes.folderSub:
        return "Sub Folder";
      default:
        return navigationItems[currentSelectedItem]?.title ?? "";
    }
  }

  notificationIconClicked () async {
    // emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
    //
    // Map<String, dynamic> requestMap = {};
    // final result = await _notificationUseCase.getNotificationFromServer(requestMap);
    //
    // if (result is SUCCESS) {
    //   try {
    //     emitState(SuccessState(result.data,));
    //   } catch (e) {
    //     emitState(ErrorState(StateRendererType.DEFAULT, result?.failureMessage ?? "Something went wrong"));
    //   }
    // } else {
    //   emitState(ErrorState(StateRendererType.DEFAULT, result?.failureMessage ?? "Something went wrong"));
    // }
  }


  updateTitleFromItemType(
      {required NavigationMenuItemType currentSelectedItem,
      String? routeName,
      String? title}) async {
    if (routeName != null) {
      navigationItems[currentSelectedItem]
          ?.setTitle(_updateTitleFromRoute(routeName, currentSelectedItem));
    } else if (title != null) {
      if (!NavigationUtils.canPop()) {
        if (currentSelectedItem == NavigationMenuItemType.home ||
            currentSelectedItem == NavigationMenuItemType.sites ||
            currentSelectedItem == NavigationMenuItemType.models) {
          navigationItems[currentSelectedItem]?.setTitle(title);
        } else if (currentSelectedItem == NavigationMenuItemType.files) {
          navigationItems[currentSelectedItem]?.setTitle("Files");
        } else if (currentSelectedItem == NavigationMenuItemType.quality) {
          navigationItems[currentSelectedItem]?.setTitle("Quality Plans");
        }
      } else {
        navigationItems[currentSelectedItem]?.setTitle(title);
      }
    } else {
      navigationItems[currentSelectedItem]?.setTitle(currentSelectedItem.value);
    }
  }
}
