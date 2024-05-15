import 'package:camera/camera.dart';
import 'package:field/bloc/quality/quality_plan_location_listing_cubit.dart';
import 'package:field/bloc/quality/quality_plan_location_listing_state.dart';
import 'package:field/data/model/quality_activity_list_vo.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/routes_manager.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/file_form_utility.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:field/widgets/app_permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/event_analytics.dart';
import '../../../enums.dart';
import '../../../utils/bottom_activity_dialog.dart';
import '../../../utils/utils.dart';
import '../../../widgets/action_button.dart';
import '../../../widgets/elevatedbutton.dart';
import '../../../widgets/normaltext.dart';
import '../../../widgets/progressbar.dart';
import '../../managers/color_manager.dart';
import '../../managers/font_manager.dart';

class ActivityListingScreen extends StatefulWidget {
  const ActivityListingScreen({key}) : super(key: key);

  @override
  State<ActivityListingScreen> createState() => _ActivityListingScreenState();
}

class _ActivityListingScreenState extends State<ActivityListingScreen> {
  late QualityPlanLocationListingCubit _qualityPlanLocationListingCubit;
  late AProgressDialog? aProgressDialog;
  late ScrollController animatedScrollController;
  late ScrollController listScrollController;

  @override
  void initState() {
    super.initState();
    _qualityPlanLocationListingCubit = context.read<QualityPlanLocationListingCubit>();

    aProgressDialog = AProgressDialog(context, isAnimationRequired: true, isWillPopScope: true);

    listScrollController = ScrollController();
    _scrollingAnimation();

    animatedScrollController = getIt<ScrollController>();
  }

  @override
  void dispose() {
    listScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<QualityPlanLocationListingCubit, FlowState>(
      listener: (_, state) async {
        if (aProgressDialog?.isShowing == true) {
          aProgressDialog?.dismiss();
        }
      },
      child: BlocBuilder<QualityPlanLocationListingCubit, FlowState>(
        builder: (_, state) {
          final activityState = state as ActivityListState;
          if (activityState.internalState == InternalState.loading) {
            _forwardAnimation();
            return const Center(
              child: ACircularProgress(
                key: Key("key_activity_listing_progressbar"),
              ),
            );
          } else if (activityState.internalState == InternalState.failure) {
            return Center(
              child: NormalTextWidget(activityState.response),
            );
          } else {
            final activityList = activityState.response;
            return activityList.isEmpty
                ? Center(
                    child: NormalTextWidget(context.toLocale!.no_activity_found),
                  )
                : RefreshIndicator(
                    color: AColors.blueColor,
                    onRefresh: () async {
                      if (state.internalState != InternalState.loading) {
                       _qualityPlanLocationListingCubit.updateAndRefreshData();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      child: ListView.builder(
                        key: const PageStorageKey<String>("activity_listing"),
                        controller: listScrollController,
                        padding: EdgeInsets.zero,
                        itemBuilder: (ctx, i) => Column(
                          children: [
                            if (i != 0 && activityList[i].activityType != ActivityTypeEnum.holdPoint.value && activityList[i - 1].activityType != ActivityTypeEnum.holdPoint.value) const Divider(),
                            activityList[i].activityType == ActivityTypeEnum.holdPoint.value ? getHoldPoint(activityList[i].activityName) : getListTile(activityList[i], context),
                          ],
                        ),
                        itemCount: activityList.length,
                      ),
                    ));
          }
        },
      ),
    );
  }

  openViewFormFile(ctx, ActivitiesList activityData) async {

    await FileFormUtility.showFileFormViewDialog(
        ctx,
        frmViewUrl: await _qualityPlanLocationListingCubit.getUrlBasedOnAssociationType(activityData),
        associationType: activityData.associationType,
        data: _qualityPlanLocationListingCubit.getDataToViewFormFile(),
        color: activityData.associationType == AssociationTypeEnum.form.value
            ? '${activityData.deliverableActivities![0].statusColor}'.toColor() : null,
        callback: (value) {
          _updateActivityData(value, activityData);
        }
    );
  }

  Widget getListTile(ActivitiesList activityData, ctx) {
    if (activityData.deliverableActivities == null) {
      _qualityPlanLocationListingCubit.removeItemFromBreadCrumb(index: 2);
      return const ListTile();
    }
    final deliverableActivities = activityData.deliverableActivities![0];

    return ListTile(
      contentPadding: Utility.isTablet ? null : EdgeInsets.zero,
      trailing: SizedBox(
          width: 110,
          child: (_qualityPlanLocationListingCubit.isAssociationRequired(deliverableActivities) &&
                  _qualityPlanLocationListingCubit.isInProgressOrCompleteState(deliverableActivities) &&
                  _qualityPlanLocationListingCubit.hasActivityManageAccess)
              ? ActionButton(
                  color: '${deliverableActivities.statusColor}'.toColor(),
                  text: '${deliverableActivities.statusName}',
                  buttonClickHandler: () {
                    if (!deliverableActivities.isAccess!) {
                      context.showSnack(context.toLocale!.quality_content_no_view_permission);
                      return;
                    }
                    openViewFormFile(ctx, activityData);
                  },
                  deleteHandler: () {
                    return showDialog<void>(
                      context: context,
                      barrierDismissible: false, // u// ser must tap button!
                      builder: (BuildContext context) {
                        return AlertDialog(
                          contentPadding: EdgeInsets.zero,
                          content: SingleChildScrollView(
                            child:
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                      size: 60,
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    NormalTextWidget(
                                      context.toLocale!.lbl_msg_to_clear_activity,
                                      fontSize: 20,
                                      color: Colors.black87,
                                      fontWeight: AFontWight.semiBold,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    FractionallySizedBox(
                                      widthFactor:(Utility.isTablet) ? 0.8 : 0.9,
                                      child: NormalTextWidget(
                                        context.toLocale!.lbl_msg_to_remove_activity,
                                        color: Colors.black54,
                                        textAlign: TextAlign.center,
                                        fontSize: 17,
                                        fontWeight: AFontWight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 18,
                                    ),
                                      const Divider(
                                        height: 2,
                                        thickness: 2,
                                      ),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 50.0,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: TextButton(
                                                child: NormalTextWidget(
                                                  context.toLocale!.lbl_btn_continue,
                                                  color: Colors.red,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  aProgressDialog?.show();
                                                  _qualityPlanLocationListingCubit.clearActivityData(deliverableActivities);
                                                },
                                              ),
                                            ),
                                            const VerticalDivider(
                                              width: 5,
                                              thickness: 1,
                                              color: Colors.grey,
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: TextButton(
                                                child: NormalTextWidget(
                                                  context.toLocale!.lbl_btn_cancel,
                                                  color: Colors.black54,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black54,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                )
                            ),
                        );
                      },
                    );
                  },
                )
              : AElevatedButtonWidget(
                  btnLabel: _qualityPlanLocationListingCubit.isNotBlockedAndAssocRequired(deliverableActivities)
                      ? (_qualityPlanLocationListingCubit.isActivityStatusOpen(deliverableActivities))
                          ? context.toLocale!.open
                          : '${deliverableActivities.statusName}'
                      : (_qualityPlanLocationListingCubit.isAssociationRequired(deliverableActivities))
                          ? context.toLocale!.blocked
                          : context.toLocale!.na,
                  btnBackgroundClr: _qualityPlanLocationListingCubit.isNotBlockedAndAssocRequired(deliverableActivities)
                      ? (!activityData.isAccess! && _qualityPlanLocationListingCubit.isActivityStatusOpen(deliverableActivities))
                        ? '${deliverableActivities.statusColor}'.toColor().withOpacity(0.5)
                        : '${deliverableActivities.statusColor}'.toColor()
                      : AColors.btnDisableClr,
                  btnLabelClr:
                      _qualityPlanLocationListingCubit.isNotBlockedAndAssocRequired(deliverableActivities) ? AColors.white : AColors.greyColor1,
                  onPressed: (!_qualityPlanLocationListingCubit.isNotBlocked(deliverableActivities) ||
                          !_qualityPlanLocationListingCubit.isAssociationRequired(deliverableActivities))
                      ? null
                      : () {
                          if (!activityData.isAccess! && _qualityPlanLocationListingCubit.isActivityStatusOpen(deliverableActivities)) {
                            FireBaseEventAnalytics.setEvent(FireBaseEventType.qualityActivityClick, FireBaseFromScreen.quality, bIncludeProjectName: true);
                            if (activityData.associationType == AssociationTypeEnum.file.value) {
                              context.showSnack(context.toLocale!.quality_no_create_file_permission);
                            }
                            if (activityData.associationType == AssociationTypeEnum.form.value) {
                              context.showSnack(context.toLocale!.quality_no_create_form_permission);
                            }
                            return;
                          }
                          if (_qualityPlanLocationListingCubit.isActivityStatusComplete(deliverableActivities) ||
                              _qualityPlanLocationListingCubit.isActivityStatusInProgress(deliverableActivities)) {
                            FireBaseEventAnalytics.setEvent(FireBaseEventType.qualityActivityClick, FireBaseFromScreen.quality, bIncludeProjectName: true);
                            if (!deliverableActivities.isAccess!) {
                              context.showSnack(context.toLocale!.quality_content_no_view_permission);
                              return;
                            }
                            openViewFormFile(ctx, activityData);
                            return;
                          }
                          _qualityPlanLocationListingCubit.setCurrentSelectedActivity(activityData);
                          if (activityData.associationType == AssociationTypeEnum.form.value &&
                              _qualityPlanLocationListingCubit.isNotBlockedAndAssocRequired(deliverableActivities) &&
                              _qualityPlanLocationListingCubit.isActivityStatusOpen(deliverableActivities)) {
                            // Pass Map in the createDialog
                            List<Map<String, dynamic>> actionList = [
                              {
                                "title": context.toLocale!.create_form,
                                "callback": () => _openCreateFormDialog(activityData),
                              }
                            ];
                            // Open Activity Dialog
                            BottomActivityDialog.createDialog(ctx: context, title: context.toLocale!.lbl_select_form_action, actionList: actionList);
                          }
                          if (activityData.associationType == AssociationTypeEnum.file.value &&
                              _qualityPlanLocationListingCubit.isNotBlockedAndAssocRequired(deliverableActivities) &&
                              _qualityPlanLocationListingCubit.isActivityStatusOpen(deliverableActivities)) {
                            // Pass Map in the createDialog
                            List<Map<String, dynamic>> actionList = [
                              {
                                "title": context.toLocale!.take_a_picture,
                                "callback": () => _openCamera(activityData),
                              },
                              {
                                "title": context.toLocale!.select_a_photo,
                                "callback": () => _openGalleryOrFile(activityData, AConstants.gallery, FileType.image),
                              },
                              {
                                "title": context.toLocale!.select_a_file,
                                "callback": () => _openGalleryOrFile(activityData, AConstants.gallery, FileType.any),
                              }
                            ];
                            BottomActivityDialog.createDialog(ctx: context, title: context.toLocale!.lbl_select_file_action, actionList: actionList);
                          }
                        },
                  borderRadius: 4,
                  fontSize: 13,
                  fontWeight: AFontWight.regular,
                  fontFamily: AFonts.fontFamily,
                  height: 44,
                  width: 100,
                )),
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Text('${activityData.activityName}'),
      ),
    );
  }

  _openCreateFormDialog(activityData,{FireBaseFromScreen screenName = FireBaseFromScreen.quality}) async {
    Map<String, dynamic> map = await _qualityPlanLocationListingCubit.navigateToCreateForm(activityData);
    String url = map['url'];
    Navigator.of(NavigationUtils.mainNavigationKey.currentContext!).pop();
    await FileFormUtility.showFormCreateDialog(NavigationUtils.mainNavigationKey.currentContext!,
        frmViewUrl: url, data: map, title: map['name'], function: _updateActivityData, screenName: FireBaseFromScreen.quality);
    FireBaseEventAnalytics.setEvent(FireBaseEventType.saveForm, screenName,bIncludeProjectName: true);
  }


  //Update Deliverable Details
  _updateActivityData(value, dynamic data)  {
    if (value != null && value["isActionCompleted"] == true) {
      aProgressDialog?.show();
      Future.delayed(const Duration(milliseconds: 400), () {
        _qualityPlanLocationListingCubit.updateAndRefreshData(isReloadRequired: true,data: data);      });
    }
  }


  _openCamera(activityData) {
    Navigator.of(NavigationUtils.mainNavigationKey.currentContext!).pop();

    var permissionHandlerPermissionService = PermissionHandlerPermissionService();
    permissionHandlerPermissionService.checkAndRequestCameraPermission((bool isGranted) {
      if (isGranted) {
        Navigator.pushNamed(NavigationUtils.mainNavigationKey.currentContext!, Routes.aCamera, arguments : {"allowMultiple": "false", "onlyImage": "false"}).then((dynamic capturedImage) {
          if(capturedImage != null) {
            XFile file = capturedImage[0];
            _uploadFile(file);
          }
        });
      } else {
        permissionHandlerPermissionService.showPermissionMessageDialog(context);
      }
    });
  }

  _openGalleryOrFile(activityData, String imagesFrom, FileType fileType) async {
    Navigator.of(NavigationUtils.mainNavigationKey.currentContext!).pop();

    var permissionHandlerPermissionService = PermissionHandlerPermissionService();
    bool isPermissionGranted = await permissionHandlerPermissionService.checkAndRequestPhotosPermission(context);
    if(isPermissionGranted) {
      aProgressDialog?.show();
      _qualityPlanLocationListingCubit.getFileFromGallery((error, stackTrace) {
        aProgressDialog?.dismiss();
        permissionHandlerPermissionService.showPermissionMessageDialog(context);
      }, fileType, (Map files) {
          aProgressDialog?.dismiss();
          if (files["validFiles"] != null) {
            _uploadFile(files["validFiles"][0]);
          } else if (files["inValidFiles"] != null) {
            Utility.showAlertWithOk(context, files["inValidFiles"]);
          }
      });
    }
  }

  _uploadFile(dynamic capturedFile) {
    if (capturedFile is XFile || capturedFile is PlatformFile) {
      String filePath = capturedFile.path;
      String fileName = capturedFile.name;
      _qualityPlanLocationListingCubit.uploadFileToServer(filePath: filePath, fileName: fileName);
    }
  }

  Widget getHoldPoint(activityName) {
    return Container(
      key: const Key("Hold_Point"),
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: Utility.isTablet ? const EdgeInsets.symmetric(horizontal: 16) : null,
      decoration: BoxDecoration(border: Border(top: BorderSide(width: 5, color: AColors.btnDisableClr))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AElevatedButtonWidget(
            btnLabel: '$activityName',
            btnBackgroundClr: AColors.btnDisableClr,
            btnLabelClr: AColors.iconGreyColor,
            onPressed: null,
            fontSize: 13,
            fontWeight: AFontWight.regular,
            fontFamily: AFonts.fontFamily,
            height: 44,
            width: 110,
            borderRadiusObject:
                const BorderRadius.only(topLeft: Radius.zero, topRight: Radius.zero, bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
          ),
        ],
      ),
    );
  }


  _scrollingAnimation() {
    if (Utility.isTablet) {
      return;
    }

    listScrollController.addListener(() {
      _filterAnimationController();
    });
  }

  _filterAnimationController() {
    if (!Utility.isTablet) {
      if (listScrollController.position.userScrollDirection == ScrollDirection.reverse) {
        _reverseAnimation();
      }
    }
    if (listScrollController.position.userScrollDirection == ScrollDirection.forward) {
      _forwardAnimation();
    }
  }

  _reverseAnimation() {
    if (Utility.isTablet || !animatedScrollController.hasClients) {
      return;
    }

    animatedScrollController.animateTo(
      animatedScrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.linear,
    );
  }

  _forwardAnimation() {
    if(animatedScrollController.hasClients) {
      animatedScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.linear,
      );
    }
  }
}
