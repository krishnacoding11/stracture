/*
import 'package:field/bloc/task_action_count/task_action_count_cubit.dart';
import 'package:field/bloc/task_action_count/task_action_count_state.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/event_analytics.dart';
import '../../../bloc/navigation/navigation_cubit.dart';
import '../../../bloc/toolbar/toolbar_cubit.dart';
import '../../../injection_container.dart';
import '../../../networking/network_info.dart';
import '../../../utils/navigation_utils.dart';
import '../../../widgets/normaltext.dart';
import '../../managers/color_manager.dart';
import '../bottom_navigation/tab_navigator.dart';
import '../project_dashboard.dart';
import '../recent_location_widget.dart';

class TaskActionCountWidget extends StatefulWidget {
  const TaskActionCountWidget({Key? key}) : super(key: key);

  @override
  State<TaskActionCountWidget> createState() => _TaskActionCountWidgetState();
}

class _TaskActionCountWidgetState extends State<TaskActionCountWidget> {
  final TaskActionCountCubit _taskActionCountCubit = getIt<TaskActionCountCubit>();
  late ScrollController _animatedScrollController;
  bool isOnline = true;

  @override
  void initState() {
    super.initState();

    _animatedScrollController = getIt<ScrollController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initTaskActionCountCubit();
    });
  }

  void _initTaskActionCountCubit() async {
    await _taskActionCountCubit.getTaskActionCount();
  }

  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var deviceWidth = MediaQuery.of(context).size.width;
    var orientationType = MediaQuery.of(context).orientation;
    isOnline = isNetWorkConnected();
    if (!Utility.isTablet) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }

    return BlocBuilder<TaskActionCountCubit, FlowState>(
      buildWhen: (previous, current) => current is TaskActionCountState,
      builder: (context, state) {
        return Container(
          key: Key('new_dashboard_background_container'),
            color: AColors.backgroundBlueColor,
            child: SingleChildScrollView(
              physics: ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsetsDirectional.only(top:(Utility.isTablet && (deviceHeight < deviceWidth)) || (orientationType == Orientation.landscape)?deviceHeight*0.02:(Utility.isTablet)?deviceHeight*0.016:deviceHeight*0.02,start:(Utility.isTablet && (deviceHeight < deviceWidth)) || (orientationType == Orientation.landscape)?deviceWidth*0.06:Utility.isTablet?deviceHeight*0.05:deviceHeight*0.035),
                    child: NormalTextWidget( key: Key('home_text_widget_key'),context.toLocale!.home, fontSize: (Utility.isTablet)?20:15,fontWeight: FontWeight.w500,color: Colors.black,),
                  ),
                  getBasicTaskActionCountSetup(context, state),
                ],
              ),
            ));
      },
    );
  }

  Widget getBasicTaskActionCountSetup(BuildContext context, FlowState state) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var deviceWidth = MediaQuery.of(context).size.width;
    var orientationType = MediaQuery.of(context).orientation;
    var taskList = [];
    bool isProjectSelected = true;
    if (state is TaskActionCountState) {
      if (state.taskActionCount != null) {
        taskList = state.taskActionCount;
      }
    }
    return (Utility.isTablet && (deviceHeight < deviceWidth)) || (orientationType == Orientation.landscape)
        ? allTaskInfoForTablet(taskList, isProjectSelected)
        : allTaskInfoForPhone(taskList, isProjectSelected);
  }

  allTaskInfoForPhone(taskList, isProjectSelected) {
    var deviceWidth = MediaQuery.of(context).size.width;
    if ((taskList as List).isNotEmpty) {
      List tmpTaskList = (taskList[0] as List).sublist(0, 2);
      tmpTaskList.addAll((taskList[1] as List).sublist(0, 2));
      return Padding(
        padding: EdgeInsets.symmetric(vertical:Utility.isTablet?deviceWidth*0.012:deviceWidth*0.01, horizontal:Utility.isTablet?deviceWidth*0.03:8),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: (Utility.isTablet)?4:3, crossAxisSpacing: deviceWidth*0.01, mainAxisSpacing:deviceWidth*0.01),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          //children: createListOfWidgets(context, isProjectSelected, tmpTaskList),
        ),
      );
    }
  }

  allTaskInfoForTablet(taskList, isProjectSelected) {
    var deviceHeight = MediaQuery.of(context).size.height;
    var deviceWidth = MediaQuery.of(context).size.width;
    if ((taskList as List).isNotEmpty) {
      List tmpTaskList = (taskList[0] as List).sublist(0, 2);
      tmpTaskList.addAll((taskList[1] as List).sublist(0, 2));
      return Padding(
        padding: EdgeInsets.symmetric(horizontal:deviceWidth*0.04, vertical:deviceWidth*0.01),
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5, crossAxisSpacing: deviceWidth*0.015, mainAxisSpacing: deviceWidth*0.025),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
         // children: createListOfWidgets(context, isProjectSelected, tmpTaskList),
        ),
      );
    }
  }

*/
/*  List<Widget> createListOfWidgets(BuildContext context, isProjectSelected, tmpTaskList){
    List<Widget> list =  List.generate(
      tmpTaskList.length,
      (index) => InkWell(
          onTap: () => onCardItemClicked(tmpTaskList[index], screenName: FireBaseFromScreen.homePage),
          key: Key('inkwell_numbered_dashboard_item_${index+1}'),
          child: numberedDashboardItem(context, getItemImage(tmpTaskList[index]), tmpTaskList[index]["pendingTask"].toString(), tmpTaskList[index]["taskType"].toString())));
    list.insert(0, createNewTask(context, isProjectSelected));
    list.add(RecentLocationWidget());
    list.add(bottomLabelDashboardItem(context, AImageConstants.createSiteForm, context.toLocale!.lbl_create_site_form,isProjectSelected));
    return list;
  }*//*


  onCardItemClicked(dynamic taskItem, {FireBaseFromScreen screenName = FireBaseFromScreen.homePage}) async {
    var eventName = "";
    if (isOnline) {
      _resetAnimation();
      switch (taskItem["actionType"]) {
        case TaskActionType.newTask:
          eventName = FireBaseEventType.newTasks.value;
          break;
        case TaskActionType.dueToday:
          eventName = FireBaseEventType.taskDueToday.value;
          break;
        case TaskActionType.dueThisWeek:
          eventName = FireBaseEventType.taskDueThisWeek.value;
          break;
        case TaskActionType.overDue:
          {
            if (getIt<NavigationCubit>().currSelectedItem != NavigationMenuItemType.tasks) {
              getIt<NavigationCubit>().updateSelectedItemByType(NavigationMenuItemType.tasks);
              getIt<ToolbarCubit>().updateSelectedItemByPosition(NavigationMenuItemType.tasks);
            }
            NavigationUtils.pushNamedAndRemoveUntil(TabNavigatorRoutes.tasks, argument: {"isFrom": taskItem["actionType"]});
          }
          eventName = FireBaseEventType.overDueTasks.value;
          break;
      }
    }
  }

  getItemImage(dynamic taskItem) {
    switch (taskItem["actionType"]) {
      case TaskActionType.newTask:
        return AImageConstants.newTasks;
      case TaskActionType.dueToday:
        return AImageConstants.tasksDueToday;
      case TaskActionType.dueThisWeek:
        return AImageConstants.tasksDueThisWeek;
      case TaskActionType.overDue:
        return AImageConstants.overdueTasks;
    }
  }

  _resetAnimation() {
    if (!Utility.isTablet) {
      if (_animatedScrollController.hasClients) {
        _animatedScrollController?.animateTo(_animatedScrollController!.position.minScrollExtent,
          duration: const Duration(seconds: 1),
          curve: Curves.fastOutSlowIn,
        );
      }
    }
  }
}
*/
