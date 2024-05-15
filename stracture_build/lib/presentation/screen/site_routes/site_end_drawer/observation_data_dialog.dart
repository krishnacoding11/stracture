import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:field/bloc/site/plan_loading_state.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/site_item/site_item.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/site_item/site_item_description/site_description.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/exttype_image_utils.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/url_helper.dart';
import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/site/plan_cubit.dart';
import '../../../../data/model/pinsdata_vo.dart';
import '../../../../utils/constants.dart';
import '../../../../widgets/normaltext.dart';
import '../../../base/state_renderer/state_render_impl.dart';

typedef OnTooltipClick = Function(ObservationData observationData);

class ObservationDataDialog extends StatefulWidget {
  final ObservationData? observationData;
  final OnTooltipClick? onTooltipClick;

  const ObservationDataDialog({Key? key, required this.observationData, this.onTooltipClick}) : super(key: key);

  @override
  State<ObservationDataDialog> createState() => _ObservationDataDialogState();
}

class _ObservationDataDialogState extends State<ObservationDataDialog> {
  Map<String, String> headersMap = {};
  String baseURL = "";

  @override
  void initState() {
    super.initState();
    _setBaseURL();
  }

  Future<void> _setBaseURL() async {
    if (baseURL.isEmpty) {
      baseURL = await UrlHelper.getAdoddleURL(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: _addSessionToHeader(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _getHeader(context),
              ADividerWidget(thickness: 1),
              InkWell(
                onTap: () {
                  if (widget.onTooltipClick != null && widget.observationData != null) {
                    widget.onTooltipClick!(widget.observationData!);
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 5, top: 5, right: 5, bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        flex: 8,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                widget.observationData?.formTitle ?? "",
                                style: const TextStyle(fontFamily: "Sofia", fontSize: 16, fontWeight: AFontWight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SiteDescription(title: "${context.toLocale?.placeholder_task_location}: ", description: ((widget.observationData?.locationDetailVO?.locationPath?.split('\\').last.isEmpty) ?? true) ? '--' : widget.observationData?.locationDetailVO?.locationPath?.split('\\').last ?? '--'),
                            SiteDescription(
                              title: "${context.toLocale?.lbl_assign_to}: ",
                              description: widget.observationData?.recipientList?.first.recipientFullName.isNullOrEmpty() == false ? "${widget.observationData?.recipientList?.first.recipientFullName}" : "----",
                            ),
                            SiteDescription(
                              title: "${context.toLocale?.lbl_org}: ",
                              description: widget.observationData?.recipientList?.first.userOrgName?.trim() ?? "----",
                            ),
                          ],
                        ),
                      ),
                      BlocBuilder<PlanCubit, FlowState>(
                          buildWhen: (previous, current) => current is RefreshObservationDialogState,
                          builder: (_, state) {
                            AttachmentItem? attachmentItem = widget.observationData?.attachmentItem;
                            if (state is RefreshObservationDialogState) {
                              attachmentItem = state.observationData.attachmentItem;
                            }

                            return Expanded(flex: 2, child: (attachmentItem != null) ? (snapshot.connectionState == ConnectionState.done) ? _getImage(attachmentItem, headersMap) : const SizedBox.shrink() : const SizedBox.shrink());
                          }),
                      // (widget.observationData?.attachmentItem != null) ? Expanded(flex : 2,child: _getimage(widget.observationData?.attachmentItem, headersMap)) : const SizedBox(width: 1)
                    ],
                  ),
                ),
              ),
            ],
          );
        });
  }

  Future<void> _addSessionToHeader() async {
    await _setBaseURL();
    var user = await StorePreference.getUserData();
    if ((user?.usersessionprofile!.aSessionId?.length)! > 0 && (user?.usersessionprofile!.currentJSessionID?.length)! > 0) {
      headersMap[AConstants.cookie] = 'ASessionID=${user?.usersessionprofile!.aSessionId};JSESSIONID=${user?.usersessionprofile!.currentJSessionID}';
    }
  }

  Widget _getImage(AttachmentItem? externalImage, Map<String, String> headers) {
    bool isOnline = isNetWorkConnected();
    if (externalImage != null && (isOnline || TypeImageUtility.extTypeMap.values.first.contains(externalImage.extType) == false)) {
      String extType = externalImage?.extType ?? "";
      try {
        return Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 18, right: 3),
            child: TypeImageUtility.isThumbnailTypeImage(extType) == true
                ? CachedNetworkImage(
                    height: 65,
                    width: 55,
                    imageUrl: "$baseURL${AConstants.viewThumbUrl}?projectId=${widget.observationData?.projectId.plainValue()}&attachmentId=${externalImage?.revisionId.plainValue()}",
                    httpHeaders: headersMap,
                    useOldImageOnUrlChange: false,
                    errorWidget: (context, url, error) => TypeImageUtility.getImage(extType, rect: const SizedBox(height: 65, width: 55)),
                    imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
                    )),
                  )
                : TypeImageUtility.getImage(extType, rect: const SizedBox(height: 65, width: 55)),
          ),
        );
      } catch (e) {
        return Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 18, right: 3),
            child: TypeImageUtility.getImage(extType, rect: const SizedBox(height: 65, width: 55)),
          ),
        );
      }
    } else if (externalImage != null && !isNetWorkConnected()) {
      String extType = externalImage?.extType ?? "";
      return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 18, right: 3),
          child: Image.file(
            File("${externalImage?.realPath}"),
            height: 65,
            width: 50,
            fit: BoxFit.fill,
            errorBuilder: (context, error, _) {
              return TypeImageUtility.getImage(extType, rect: const SizedBox(height: 60, width: 50));
            },
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  // Widget _getHeader() {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 5, left: 10),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         Image.asset(
  //           height: 20,
  //           width: 20,
  //           widget.observationData?.appBuilderID != null &&
  //                   widget.observationData?.appBuilderID!.toLowerCase() ==
  //                       AConstants.siteTaskType
  //               ? AImageConstants.accountHardHat
  //               : AImageConstants.otherTask,
  //           color: getStatusColor(),
  //         ),
  //         const SizedBox(width: 8),
  //         Column(
  //           // mainAxisSize: MainAxisSize.min,
  //           // mainAxisAlignment: MainAxisAlignment.start,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Padding(
  //               padding: const EdgeInsets.symmetric(horizontal: 8),
  //               child: Text(
  //                 widget.observationData?.formCode ?? "--",
  //                 style: TextStyle(
  //                   fontFamily: AFonts.fontFamily,
  //                   fontWeight: AFontWight.semiBold,
  //                   color: AColors.grColor,
  //                   fontSize: 16,
  //                 ),
  //                 maxLines: 1,
  //                 overflow: TextOverflow.ellipsis,
  //               ),
  //             ),
  //             getTitleWithDescriptionLabel("${context.toLocale?.lbl_due}: ",
  //                 widget.observationData?.responseRequestBy?.split('#').first ?? "--")
  //           ],
  //         ),
  //         const Spacer(),
  //         TextButton(
  //           style: TextButton.styleFrom(
  //             padding: EdgeInsets.zero,
  //             minimumSize: const Size(10, 10),
  //             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //           ),
  //           onPressed: () {},
  //           child: Row(
  //             children: [
  //               Text(
  //                 widget.observationData?.statusVO?.statusName ?? "--",
  //                 style: TextStyle(
  //                   fontStyle: FontStyle.normal,
  //                   fontSize: 15,
  //                   color: AColors.iconGreyColor,
  //                 ),
  //               ),
  //               Icon(Icons.keyboard_arrow_down, color: AColors.iconGreyColor)
  //             ],
  //           ),
  //         ),
  //         IconButton(
  //           icon: const Icon(Icons.more_vert),
  //           alignment: Alignment.center,
  //           padding: EdgeInsets.zero,
  //           color: AColors.iconGreyColor,
  //           iconSize: 20,
  //           onPressed: () {},
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _getHeader(BuildContext context) {
    String dueOrCompletedDate = '';
    if (widget.observationData?.isCloseOut == true) {
      dueOrCompletedDate = "${context.toLocale!.lbl_task_completed}: ";
      if (widget.observationData?.statusUpdateDate != null) {
        dueOrCompletedDate += '${widget.observationData?.statusUpdateDate?.split('#').first}';
      }
    } else {
      dueOrCompletedDate = "${context.toLocale?.lbl_due}: ";
      if (widget.observationData?.responseRequestBy != null) {
        dueOrCompletedDate += '${widget.observationData?.responseRequestBy?.split('#').first}';
      }
    }
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 8, right: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            height: 20,
            width: 20,
            widget.observationData?.appBuilderID != null && AConstants.siteAppBuilderIds.contains(widget.observationData?.appBuilderID?.toLowerCase()) ? AImageConstants.accountHardHat : AImageConstants.otherTask,
            color: getStatusColor(),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 5,
            fit: FlexFit.tight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NormalTextWidget(
                  widget.observationData?.formCode ?? "--",
                  color: AColors.iconGreyColor,
                  fontSize: 16,
                  fontWeight: AFontWight.semiBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                ),
                NormalTextWidget(
                  dueOrCompletedDate,
                  color: AColors.iconGreyColor,
                  fontSize: 12,
                  fontWeight: AFontWight.regular,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.left,
                )
              ],
            ),
          ),
          const Spacer(),
          Flexible(
            flex: 3,
            //fit: FlexFit.tight,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(100, 10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {},
              child: Text(
                widget.observationData?.statusVO?.statusName ?? "--",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontStyle: FontStyle.normal,
                  fontSize: 15,
                  color: AColors.iconGreyColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getStatusColor() {
    if (widget.observationData?.statusVO != null) {
      return widget.observationData?.statusVO?.bgColor.toColor();
    }
    return AColors.iconGreyColor;
  }

  Widget getTitleWithDescriptionLabel(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          const SizedBox(height: 2),
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: AFontWight.regular,
                  fontStyle: FontStyle.normal,
                  fontSize: 12,
                  color: AColors.grColor,
                ),
                textAlign: TextAlign.left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                description,
                style: TextStyle(fontFamily: AFonts.fontFamily, fontSize: 12, color: AColors.grColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          // const SizedBox(height: 4),
        ],
      ),
    );
  }
}
