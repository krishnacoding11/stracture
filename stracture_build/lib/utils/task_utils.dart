import 'package:field/utils/extensions.dart';

import '../data/model/site_form_action.dart';

class TaskUtils {

  static SiteFormAction? getMyTaskAction(List<SiteFormAction> itemAction) {
    if (itemAction.isNotEmpty) {
      for (var element in itemAction) {
        if (element.actionStatus == '0') {
          return element;
        }
      }
      //return itemAction[0];
    }
    return null;
  }

  static String getMyTaskName(SiteFormAction? itemAction) {
    String strMyTasks = "---";
    if (itemAction != null) {
      if (itemAction.actionTime.isNullOrEmpty()) {
        strMyTasks = itemAction.actionName.toString();
      } else {
        strMyTasks = "${itemAction.actionName} (${itemAction.actionTime})";
      }
    }
    return strMyTasks;
  }

  static String? getMyTaskId(SiteFormAction? itemAction) {
    if (itemAction != null) {
      return itemAction.actionId!;
    }
    return null;
  }
}