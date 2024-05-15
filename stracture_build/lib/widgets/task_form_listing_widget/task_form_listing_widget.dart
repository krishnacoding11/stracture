import 'package:cached_network_image/cached_network_image.dart';
import 'package:field/analytics/event_analytics.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart';
import 'package:field/bloc/online_model_viewer/task_form_list_cubit.dart';
import 'package:field/data/model/task_form_listing_reponse.dart';
import 'package:field/injection_container.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../networking/network_info.dart';
import '../../presentation/managers/color_manager.dart';
import '../../presentation/managers/font_manager.dart';
import '../../presentation/screen/webview/asite_formwebview.dart';
import '../../utils/constants.dart';
import '../../utils/url_helper.dart';
import '../../utils/utils.dart';
import '../snagging_widget/snagging_filter_widget.dart';

class TaskFormListingWidget extends StatefulWidget {
  final String modelId;
  const TaskFormListingWidget({super.key, required this.modelId});

  @override
  State<TaskFormListingWidget> createState() => _TaskFormListingWidgetState();
}

class _TaskFormListingWidgetState extends State<TaskFormListingWidget> {
  TaskFormListingCubit taskFormListingCubit = getIt<TaskFormListingCubit>();

  @override
  void initState() {
    super.initState();
    taskFormListingCubit.isSorted = false;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TaskFormListingCubit, TaskFormListingState>(
          listener: (context, state) {},
        ),
      ],
      child: BlocBuilder<TaskFormListingCubit, TaskFormListingState>(builder: (context, state) {
        return Row(
          mainAxisAlignment: state is FullScreenFormViewState && state.isFullScreen ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            Container(
                padding: EdgeInsets.only(top: (AppBar().preferredSize.height + 12) * 0.4),
                width: MediaQuery.of(context).size.width * 0.55,
                height: MediaQuery.of(context).size.height,
                color: AColors.grColorLight,
                child: !getIt<OnlineModelViewerCubit>().isSnaggingFilterOpen
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              (state is FullScreenFormViewState && !state.isFullScreen) || !taskFormListingCubit.isFullScreen
                                  ? Container(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 45,
                                          width: 45,
                                          decoration: BoxDecoration(
                                            borderRadius: const BorderRadius.only(
                                              bottomRight: Radius.circular(6),
                                              topRight: Radius.circular(6),
                                            ),
                                            color: AColors.lightBlue,
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                color: Colors.white,
                                                width: 0.0,
                                                height: 48.0,
                                              ),
                                              SizedBox(
                                                width: 8.0,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  getIt<OnlineModelViewerCubit>().closeSnaggingFilter();

                                                  getIt<OnlineModelViewerCubit>().isTaskFormListing = false;
                                                  getIt<OnlineModelViewerCubit>().key.currentState?.closeDrawer();
                                                  getIt<OnlineModelViewerCubit>().emitNormalWebState();
                                                },
                                                child: Icon(
                                                  Icons.close,
                                                  size: 30,
                                                  color: AColors.white,
                                                ),
                                              ),
                                            ],
                                          )),
                                    )
                                  : SizedBox.shrink(),
                              SizedBox(width: 16),
                              GestureDetector(
                                onTap: () async {
                                  taskFormListingCubit.isFullScreen = !taskFormListingCubit.isFullScreen;
                                  if (taskFormListingCubit.isFullScreen) {
                                    String formId = taskFormListingCubit.elementList[0].formId ?? "";
                                    String formTitle = "${taskFormListingCubit.elementList[0].formGroupCode.split('(')[0]}: ${taskFormListingCubit.elementList[0].formTypeName}";
                                    String appBuilderId = "";
                                    String frmStatusColor = "#000000";
                                    Map<String, dynamic> param = {
                                      "projectId": taskFormListingCubit.elementList[0].projectId,
                                      "projectids": taskFormListingCubit.elementList[0].projectId.plainValue(),
                                      "checkHashing": false,
                                      "formID": taskFormListingCubit.elementList[0].formId,
                                      "formTypeId": taskFormListingCubit.elementList[0].formTypeId,
                                      "folderId": taskFormListingCubit.elementList[0]..folderId,
                                      "dcId": "1",
                                      "statusId": taskFormListingCubit.elementList[0].statusid,
                                      "originatorId": taskFormListingCubit.elementList[0].observationId,
                                      "msgId": taskFormListingCubit.elementList[0].msgId,
                                      "toOpen": "FromForms",
                                      "commId": taskFormListingCubit.elementList[0].commId,
                                      "numberOfRecentDefect": "5",
                                      "appTypeId": taskFormListingCubit.elementList[0].appType,
                                    };
                                    final data = {"projectId": taskFormListingCubit.elementList[0].projectId, "locationId": (taskFormListingCubit.elementList[0].locationId).toString(), "isFrom": FromScreen.planView, "commId": taskFormListingCubit.elementList[0].commId, "formId": taskFormListingCubit.elementList[0].formId, "formTypeId": taskFormListingCubit.elementList[0].formTypeId, "templateType": taskFormListingCubit.elementList[0].templateType, "appBuilderId": '', "appTypeId": taskFormListingCubit.elementList[0].appType, "formSelectRadiobutton": "${"1"}_${taskFormListingCubit.elementList[0].projectId}_${taskFormListingCubit.elementList[0].formTypeId}", "isUploadAttachmentInTemp": true};
                                    if (isNetWorkConnected()) {
                                      String formViewUrl = await UrlHelper.getViewFormURL(param, screenName: FireBaseFromScreen.taskList);
                                      taskFormListingCubit.emit(FullScreenFormViewState(true, formId, frmStatusColor, appBuilderId, formTitle, formViewUrl, data));
                                    }
                                  }
                                  taskFormListingCubit.emit(FullScreenFormViewState(taskFormListingCubit.isFullScreen, "", "", "", "", "", {}));
                                },
                                child: Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: AColors.white,
                                      border: Border.all(
                                        color: AColors.lightGreyColor,
                                        width: 2.0,
                                      )),
                                  child: Icon(
                                    state is FullScreenFormViewState && !state.isFullScreen ? Icons.fullscreen : Icons.fullscreen_exit,
                                    color: AColors.iconGreyColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        height: 45,
                                        width: MediaQuery.of(context).size.width * 0.35,
                                        decoration: BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                color: AColors.grColorDark,
                                              ),
                                              bottom: BorderSide(
                                                color: AColors.grColorDark,
                                              ),
                                              left: BorderSide(
                                                color: AColors.grColorDark,
                                              ),
                                              right: BorderSide(
                                                color: AColors.grColorDark,
                                              ),
                                            ),
                                            color: AColors.white,
                                            borderRadius: BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6), topRight: Radius.circular(0), bottomRight: Radius.circular(0))),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 8.0),
                                            child: TextField(
                                              controller: TextEditingController(),
                                              decoration: InputDecoration(hintText: 'Search Forms', contentPadding: EdgeInsets.only(top: 12), prefixIcon: Icon(Icons.search)),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0, top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    taskFormListingCubit.isSorted = !taskFormListingCubit.isSorted;
                                    if (taskFormListingCubit.isSorted) {
                                      taskFormListingCubit.elementList.sort((a, b) => a.formCreationDate.compareTo(b.formCreationDate));
                                      taskFormListingCubit.emit(UpdatedSortedListState(taskFormListingCubit.elementList));
                                    } else {
                                      taskFormListingCubit.elementList.sort((a, b) => b.formCreationDate.compareTo(a.formCreationDate));
                                      taskFormListingCubit.emit(ResetSortedListState(taskFormListingCubit.elementList));
                                    }
                                  },
                                  child: NormalTextWidget(
                                    'Creation Date',
                                    fontWeight: AFontWight.medium,
                                  ),
                                ),
                                IconButton(
                                  icon: taskFormListingCubit.isSorted ? const Icon(Icons.keyboard_arrow_down) : const Icon(Icons.keyboard_arrow_up),
                                  color: AColors.iconGreyColor,
                                  iconSize: 25,
                                  onPressed: () {
                                    context.closeKeyboard();
                                    taskFormListingCubit.isSorted = !taskFormListingCubit.isSorted;
                                    if (taskFormListingCubit.isSorted) {
                                      taskFormListingCubit.elementList.sort((a, b) => a.formCreationDate.compareTo(b.formCreationDate));
                                      taskFormListingCubit.emit(UpdatedSortedListState(taskFormListingCubit.elementList));
                                    } else {
                                      taskFormListingCubit.elementList.sort((a, b) => b.formCreationDate.compareTo(a.formCreationDate));
                                      taskFormListingCubit.emit(ResetSortedListState(taskFormListingCubit.elementList));
                                    }
                                  },
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                state is TaskFormListingLoadingState ? CircularProgressIndicator() : SizedBox.shrink(),
                                state is TaskFormListingLoadedState || state is UpdatedSortedListState || state is FullScreenFormViewState || state is ResetSortedListState
                                    ? Expanded(
                                        child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: taskFormListingCubit.elementList.length > 0
                                            ? ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection: Axis.vertical,
                                                physics: ClampingScrollPhysics(),
                                                padding: const EdgeInsets.only(top: 10, left: 10),
                                                itemCount: taskFormListingCubit.elementList.length,
                                                itemBuilder: (context, index) {
                                                  ElementVoList elementVoList = taskFormListingCubit.elementList[index];
                                                  return pinCards(elementVoList);
                                                })
                                            : Center(
                                                child: NormalTextWidget('No Records Available.'),
                                              ),
                                      ))
                                    : SizedBox.shrink()
                              ]),
                            ),
                          )
                        ],
                      )
                    : SnaggingFilterWidget()),
            state is FullScreenFormViewState && state.isFullScreen
                ? Expanded(
                  child: AnimatedContainer(
                      duration: Duration(milliseconds: AConstants.siteEndDrawerDuration),
                      color: AColors.filterBgColor,
                      child: AnimatedOpacity(
                        opacity: 1.0,
                        duration: const Duration(milliseconds: 700),
                        child: Card(
                          elevation: 8,
                          child: ClipPath(
                            clipper: ShapeBorderClipper(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
                            ),
                            child: AsiteFormWebView(
                              key: Key(""),
                              url: state.frmViewUrl,
                              headerIconColor: Colors.red,
                              data: state.webviewData,
                            ),
                          ),
                        ),
                      )),
                )
                : SizedBox.shrink(),
          ],
        );
      }),
    );
  }

  Widget pinCards(ElementVoList elementVoList) {
    DateTime currentDate = DateTime.now();
    Duration duration = currentDate.difference(DateTime.parse(elementVoList.formCreationDate));
    String durationString = formatDuration(duration);
    if (duration.inHours > 24) {
      durationString = duration.inDays.toString() + ' Days ago';
    } else if (duration.inMinutes > 59) {
      durationString = duration.inHours.toString() + ' ${duration.inHours == 1 ? 'Hour ago' : 'Hours ago'}';
    } else {
      durationString = duration.inMinutes.toString() + ' Minutes ago';
    }
    return GestureDetector(
      onTap: () async {
        String formId = elementVoList.formId;
        String formTitle = "${elementVoList.formGroupCode.split('(')[0]}: ${elementVoList.formTypeName}";
        String appBuilderId = "";
        String frmStatusColor = "#000000";
        Map<String, dynamic> param = {
          "projectId": elementVoList.projectId,
          "projectids": elementVoList.projectId.plainValue(),
          "checkHashing": false,
          "formID": elementVoList.formId,
          "formTypeId": elementVoList.formTypeId,
          "folderId": elementVoList..folderId,
          "dcId": "1",
          "statusId": elementVoList.statusid,
          "originatorId": elementVoList.observationId,
          "msgId": elementVoList.msgId,
          "toOpen": "FromForms",
          "commId": elementVoList.commId,
          "numberOfRecentDefect": "5",
          "appTypeId": elementVoList.appType,
        };
        final data = {"projectId": elementVoList.projectId, "locationId": (elementVoList.locationId).toString(), "isFrom": FromScreen.planView, "commId": elementVoList.commId, "formId": elementVoList.formId, "formTypeId": elementVoList.formTypeId, "templateType": elementVoList.templateType, "appBuilderId": '', "appTypeId": elementVoList.appType, "formSelectRadiobutton": "${"1"}_${elementVoList.projectId}_${elementVoList.formTypeId}", "isUploadAttachmentInTemp": true};
        if (isNetWorkConnected()) {
          taskFormListingCubit.emit(FullLoadScreenFormViewState(true, formId, frmStatusColor, appBuilderId, formTitle, "", data));
          getIt<OnlineModelViewerCubit>().emitNormalWebState();
          String formViewUrl = await UrlHelper.getViewFormURL(param, screenName: FireBaseFromScreen.taskList);
          taskFormListingCubit.emit(FullScreenFormViewState(true, formId, frmStatusColor, appBuilderId, formTitle, formViewUrl, data));
        }
      },
      child: Card(
        child: ClipPath(
          child: Container(
              padding: EdgeInsets.only(left: 0, top: 8, bottom: 8),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: elementVoList.statusRecordStyle != null ? elementVoList.statusRecordStyle.backgroundColor.toColor() : Colors.red, width: 5),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person_3_outlined,
                        color: Colors.red,
                        size: 36,
                      ),
                      SizedBox(
                        width: 4.0,
                      ),
                      Expanded(
                        flex: 6,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              elementVoList.formId.toString().plainValue(),
                              style: TextStyle(color: AColors.grColorDark, fontFamily: "Sofia", fontWeight: AFontWight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 6.0,
                            ),
                            Text(
                              durationString,
                              style: TextStyle(color: AColors.grColorDark, fontFamily: "Sofia", fontWeight: AFontWight.medium, fontSize: 16),
                            )
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            elementVoList.status,
                            style: TextStyle(color: AColors.grColorDark, fontFamily: "Sofia", fontWeight: AFontWight.light, fontSize: 20),
                          ),
                          Icon(Icons.keyboard_arrow_down_rounded)
                        ],
                      ),
                      Expanded(child: Icon(Icons.more_vert_rounded))
                    ],
                  ),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              elementVoList.title,
                              style: TextStyle(color: AColors.black, fontFamily: "Sofia", fontWeight: AFontWight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            RichText(
                              text: TextSpan(
                                text: 'Workpackage: ',
                                style: TextStyle(color: AColors.grColorDark, fontFamily: "Sofia", fontWeight: AFontWight.bold, fontSize: 18),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: elementVoList.formGroupCode,
                                    style: TextStyle(color: AColors.black, fontFamily: "Sofia", fontWeight: AFontWight.regular, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 8.0,
                            ),
                            RichText(
                              text: TextSpan(
                                text: 'Assigned to: ',
                                style: TextStyle(color: AColors.grColorDark, fontFamily: "Sofia", fontWeight: AFontWight.bold, fontSize: 18),
                                children: <TextSpan>[
                                  TextSpan(
                                    text: elementVoList.firstName + " " + elementVoList.lastName,
                                    style: TextStyle(color: AColors.black, fontFamily: "Sofia", fontWeight: AFontWight.regular, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        elementVoList.originator.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: elementVoList.originator,
                                placeholder: (context, url) => new CircularProgressIndicator(),
                                errorWidget: (context, url, error) => new Icon(Icons.image),
                                height: 80,
                                width: 80,
                              )
                            : Icon(
                                Icons.image,
                                color: Colors.black12,
                                size: 80,
                              ),
                      ],
                    ),
                  )
                ],
              )),
          clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3))),
        ),
      ),
    );
  }

  String formatDuration(Duration duration) {
    int years = duration.inDays ~/ 365;
    int months = (duration.inDays % 365) ~/ 30;
    int days = duration.inDays % 30;
    int hours = duration.inHours % 24;
    int minutes = duration.inMinutes % 60;

    String yearsString = years > 0 ? '$years years ' : '';
    String monthsString = months > 0 ? '$months months ' : '';
    String daysString = days > 0 ? '$days days ' : '';
    String hoursString = hours > 0 ? '$hours hours ' : '';
    String minutesString = minutes > 0 ? '$minutes minutes ' : '';

    return '$yearsString$monthsString$daysString$hoursString$minutesString';
  }
}
