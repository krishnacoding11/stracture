
import 'package:field/data/model/notification_detail_vo.dart';
import 'package:field/utils/url_helper.dart';

import '../bloc/navigation/navigation_cubit.dart';
import '../bloc/toolbar/toolbar_cubit.dart';
import '../injection_container.dart';
import '../presentation/managers/color_manager.dart';
import 'file_form_utility.dart';
import 'navigation_utils.dart';

Future<void> notificationNavigatorView(NotificationDetailVo frmData, dynamic data, int entityType)
async {
  String formViewUrl;
  if(entityType == 1)
    {
      formViewUrl = await UrlHelper.getORIFormURLByActionForNotification(frmData, frmData.actions![0]);
    }
    else
    {
      formViewUrl = await UrlHelper.getActionNameFromActionsForNotification(frmData, frmData.actions![0]);
    }
   dynamic result = await FileFormUtility.showFormActionViewDialog(
      NavigationUtils.mainNavigationKey.currentContext!,
      frmViewUrl: formViewUrl,
      data: data,
      color: AColors.white);
    print("result: $result");
  if (getIt<NavigationCubit>().currSelectedItem != NavigationMenuItemType.tasks) {
    getIt<NavigationCubit>().updateSelectedItemByType(NavigationMenuItemType.tasks);
    getIt<ToolbarCubit>().updateSelectedItemByPosition(NavigationMenuItemType.tasks);
  }
}
