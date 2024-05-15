import 'package:field/enums.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_draggable_gridview/flutter_draggable_gridview.dart';

import '../../../bloc/task_action_count/task_action_count_cubit.dart';
import '../../../bloc/task_action_count/task_action_count_state.dart';
import '../../../data/model/home_page_model.dart';
import '../../../data/model/taskactioncount_vo.dart';
import '../../../networking/network_info.dart';
import '../../../widgets/normaltext.dart';
import '../../base/state_renderer/state_render_impl.dart';
import '../../managers/color_manager.dart';
import '../../managers/image_constant.dart';
import '../recent_location_widget.dart';

enum ShortcutAction { click, delete }

typedef OnShortcutTapListener = void Function(ShortcutAction shortcutAction, UserProjectConfigTabsDetails userProjectConfigTabsDetails);

class HomePageItemWidget {
  BuildContext context;
  UserProjectConfigTabsDetails userProjectConfigTabsDetails;
  OnShortcutTapListener? onShortcutTapListener;
  bool isDraggable = false;
  int? indexOfItem = -1;
  RecentLocationController recentLocationController = RecentLocationController();

  HomePageItemWidget(this.context, this.userProjectConfigTabsDetails, this.onShortcutTapListener, {this.isDraggable = false, this.indexOfItem});

  DraggableGridItem getRenderItem() {
    final homePageSortCutCategory = HomePageSortCutCategory.fromString(userProjectConfigTabsDetails.id!);
    switch (homePageSortCutCategory) {
      case HomePageSortCutCategory.createNewTask:
        return _createNewTaskItem(AImageConstants.createSiteTask, userProjectConfigTabsDetails.name.toString());
      case HomePageSortCutCategory.newTasks:
        return _taskCountItem(AImageConstants.newTasks, TaskActionType.newTask);
      case HomePageSortCutCategory.taskDueToday:
        return _taskCountItem(AImageConstants.tasksDueToday, TaskActionType.dueToday);
      case HomePageSortCutCategory.taskDueThisWeek:
        return _taskCountItem(AImageConstants.tasksDueThisWeek, TaskActionType.dueThisWeek);
      case HomePageSortCutCategory.overDueTasks:
        return _taskCountItem(AImageConstants.taskOverDue, TaskActionType.overDue);
      case HomePageSortCutCategory.jumpBackToSite:
        return _createBaseCardView(
            child: RecentLocationWidget(
          isEditModeEnable: isDraggable,
          recentLocationOnTap: recentLocationController,
        ));
      case HomePageSortCutCategory.createSiteForm:
      case HomePageSortCutCategory.createForm:
      case HomePageSortCutCategory.filter:
        return _createFormItem(userProjectConfigTabsDetails);
      default:
        return DraggableGridItem(isDraggable: isDraggable, child: Container(), dragData: null);
    }
  }

  DraggableGridItem _createNewTaskItem(String itemImage, String label) {
    return _createBaseCardView(
      child: LayoutBuilder(builder: (context, BoxConstraints boxConstraints) {
        return Padding(
          padding: EdgeInsets.only(
            top: boxConstraints.maxHeight * 0.2,
            bottom: boxConstraints.maxHeight * 0.2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                flex: 3,
                child: Container(
                  foregroundDecoration: BoxDecoration(color: Colors.black.withOpacity(0), backgroundBlendMode: BlendMode.saturation),
                  child: Image.asset(
                    itemImage,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Flexible(
                flex: Utility.isTablet ? 3 : 4,
                child: Center(
                  child: NormalTextWidget(label, key: const Key('create_site_task_normalTextWidget'), fontWeight: FontWeight.w500, color: Colors.black, textAlign: TextAlign.start, maxLines: 3, textScaleFactor: 1, fontSize: Utility.isTablet ? 18 : 13),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  DraggableGridItem _taskCountItem(String itemImage, TaskActionType taskType) {
    var isOnline = isNetWorkConnected();
    return _createBaseCardView(
      child: BlocBuilder<TaskActionCountCubit, FlowState>(
          buildWhen: (previous, current) => current is TaskActionCountState,
          builder: (context, state) {
            String taskActionCount = "0";
            if (state is TaskActionCountState && state.taskActionCount.actionsCount != null) {
              taskActionCount = _getTaskCount(state.taskActionCount.actionsCount!, taskType);
            }
            return LayoutBuilder(builder: (context, BoxConstraints boxConstraints) {
              return Padding(
                padding: EdgeInsets.only(top: boxConstraints.maxHeight * 0.2, bottom: boxConstraints.maxHeight * 0.2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Flexible(
                      flex: 3,
                      child: Container(
                        foregroundDecoration: BoxDecoration(color: !isOnline ? Colors.grey : Colors.black.withOpacity(0), backgroundBlendMode: BlendMode.saturation),
                        child: Image.asset(
                          itemImage,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    Flexible(
                      flex: Utility.isTablet ? 3 : 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            flex: 1,
                            child: NormalTextWidget(
                              (((int.tryParse(taskActionCount) == null) ? 0 : int.parse(taskActionCount)) > 99) ? "99+" : taskActionCount,
                              color: Colors.black,
                              fontSize: Utility.isTablet ? 32 : 28,
                              fontWeight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.left,
                              textScaleFactor: 1,
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: NormalTextWidget(
                              userProjectConfigTabsDetails.name!,
                              fontSize: Utility.isTablet ? 18 : 13,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w500,
                              textAlign: TextAlign.left,
                              textScaleFactor: 1,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
          }),
    );
  }

  DraggableGridItem _createFormItem(UserProjectConfigTabsDetails userProjectConfigTabsDetails) {
    return _createBaseCardView(
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 5,
                ),
                Expanded(
                  child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
                    final double defaultSize = Utility.isTablet ? 90 : 45;
                    final double height = constraints.maxHeight * 0.85 < defaultSize ? constraints.maxHeight * 0.85 : defaultSize * 0.85;
                    return Align(
                      alignment: Alignment.center,
                      child: Image.asset(
                        getConfigImage(userProjectConfigTabsDetails),
                        fit: BoxFit.contain,
                        height: height,
                      ),
                    );
                  }),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(8),
                  child: NormalTextWidget(
                    '${userProjectConfigTabsDetails.name.toString().trim()}\n',
                    key: Key('bottom_labeled_dashboard_item_text'),
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textScaleFactor: 1,
                    color: Colors.black,
                    textAlign: TextAlign.center,
                    fontSize: Utility.isTablet ? 18 : 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DraggableGridItem _createBaseCardView({required Widget child}) {
    final key = Key("onShortcutTapListener_$indexOfItem");
    return DraggableGridItem(
      isDraggable: isDraggable,
      dragData: userProjectConfigTabsDetails,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 10.0),
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: InkWell(
                  key: key,
                  borderRadius: BorderRadius.circular(8.0),
                  onTap: () {
                    if (!isDraggable) {
                      if (userProjectConfigTabsDetails.id == HomePageIconCategory.jumpBackToSite.value) {
                        recentLocationController.onTapRecentLocation!();
                      } else if (onShortcutTapListener != null) {
                        onShortcutTapListener!(ShortcutAction.click, userProjectConfigTabsDetails);
                      }
                    }
                  },
                  child: child),
            ),
          ),
          if (isDraggable)
            Positioned(
              top: (Utility.isTablet) ? 20 : 15,
              right: (Utility.isTablet) ? 10 : 5,
              child: Icon(
                Icons.touch_app,
                size: (Utility.isTablet) ? 24 : 16,
                color: AColors.grColorDark,
              ),
            ),
          if (isDraggable)
            Positioned(
              top: 0,
              left: 0,
              child: InkWell(
                key: Key("DeleteShortcutItemDialog_$indexOfItem"),
                onTap: () => _deleteShortcutItemDialog(),
                child: Container(
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AColors.themeBlueColor)),
                    padding: (Utility.isTablet) ? const EdgeInsets.all(2.0) : const EdgeInsets.all(0.0),
                    child: Icon(
                      color: AColors.themeBlueColor,
                      Icons.delete_outline_outlined,
                      size: Utility.isTablet ? 26 : 24,
                    )),
              ),
            )
        ],
      ),
    );
  }

  _deleteShortcutItemDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        key: Key("Delete Dialog"),
        contentPadding: EdgeInsets.only(top: 10),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
        title: NormalTextWidget(
          key: Key('delete_dialog_title'),
          context.toLocale!.shortcut_delete_dialogue_title,
          textAlign: TextAlign.center,
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: AColors.textColor,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: (Utility.isTablet) ? const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10) : const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  NormalTextWidget(
                    key: Key('delete_dialog_content'),
                    context.toLocale!.shortcut_delete_dialogue_description_first,
                    textAlign: TextAlign.center,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    color: AColors.textColor,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  NormalTextWidget(
                    context.toLocale!.shortcut_delete_dialogue_description_second,
                    textAlign: TextAlign.center,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    color: AColors.textColor,
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Divider(
              height: 1,
              thickness: 1,
              color: Colors.black,
            ),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(Utility.isTablet ? 15 : 10)),
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: (Utility.isTablet) ? const EdgeInsets.all(15) : const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: NormalTextWidget(
                          key: Key('cancel_delete_dialog'),
                          context.toLocale!.lbl_btn_cancel,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(8, 91, 144, 1),
                        ),
                      ),
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: Colors.black,
                  ),
                  Expanded(
                    flex: 1,
                    child: InkWell(
                      borderRadius: BorderRadius.only(bottomRight: Radius.circular(Utility.isTablet ? 15 : 10)),
                      onTap: () {
                        if (onShortcutTapListener != null) {
                          onShortcutTapListener!(ShortcutAction.delete, userProjectConfigTabsDetails);
                        }
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: (Utility.isTablet) ? const EdgeInsets.all(15) : const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                        child: NormalTextWidget(
                          key: Key('remove_widget_from_home'),
                          context.toLocale!.remove_from_home,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(244, 67, 54, 1),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _getTaskCount(ActionsCount actionsCount, TaskActionType taskActionType) {
    switch (taskActionType) {
      case TaskActionType.newTask:
        return actionsCount.newTasksAssignedToday.toString();

      case TaskActionType.dueToday:
        return actionsCount.tasksDueToday.toString();

      case TaskActionType.dueThisWeek:
        return actionsCount.tasksDueThisWeek.toString();

      case TaskActionType.overDue:
        return actionsCount.overDueTasks.toString();
    }
  }

  String getConfigImage(UserProjectConfigTabsDetails userProjectConfigTabsDetails) {
    Map<String, dynamic> map = {HomePageSortCutCategory.createForm.value: AImageConstants.formOutline, HomePageSortCutCategory.filter.value: AImageConstants.filterImage, HomePageSortCutCategory.createSiteForm.value: AImageConstants.createSiteForm};
    return map[userProjectConfigTabsDetails.id!] ?? AImageConstants.formOutline;
  }
}
