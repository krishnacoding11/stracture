import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:field/bloc/sitetask/sitetask_cubit.dart';
import 'package:field/data/model/form_vo.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/site_item/site_item_description/site_description.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/exttype_image_utils.dart';
import 'package:field/utils/url_helper.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../bloc/sitetask/sitetask_state.dart';
import '../../../../../logger/logger.dart';
import '../../../../../networking/network_info.dart';
import '../../../../../utils/store_preference.dart';

class AttachmentItem {
  String? formId;
  int? count;
  String? revisionId;
  String? extType;
  String? realPath;

  AttachmentItem(this.formId, this.revisionId, this.count, this.extType, {this.realPath = ""});
}

class SiteItem extends StatelessWidget {
  SiteForm item;
  AttachmentItem? externalImage;

  SiteItem(this.item, {Key? key}) : super(key: key);
  Map<String, String> headersMap = {};
  //double? RenderHeight = 0;
  String baseURL = "";

  addAttachment(AttachmentItem attachItem) async {
    externalImage = attachItem;
    await _addSessionToHeader();
  }

  @override
  Widget build(BuildContext context) {
    /*WidgetsBinding.instance.addPostFrameCallback((_) {
      RenderBox box = context.findRenderObject() as RenderBox;
      RenderHeight = box.size.height;
    });*/
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 12, end: 12, bottom: 3),
      child: Semantics(
    label: "Site item",
     child: Card(
        elevation: 4,
        child: ClipPath(
          clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
          ),
          child: BlocBuilder<SiteTaskCubit, FlowState>(
            buildWhen: (prev, current) => current is RefreshPaginationItemState,
            builder: (context, state) {
              return Container(
                decoration: BoxDecoration(
                  color: item.isSiteFormSelected! ? AColors.themeLightColor : null,
                  border: Border(
                    left: BorderSide(color: getStatusColor(), width: 5),
                  ),
                ),
                child: Column(
                  children: [
                    _getHeader(context),
                    ADividerWidget(thickness: 1),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 5, top: 5, end: 5, bottom: 5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            flex: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  child: NormalTextWidget(
                                    item.title ?? "--",
                                    fontWeight: AFontWight.semiBold,
                                    fontSize: 16,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SiteDescription(
                                  title: "${context.toLocale?.placeholder_task_location}: ",
                                  description: ((item.locationPath?.split('\\').last.isEmpty) ?? true) ? '--' : item.locationPath?.split('\\').last ?? '--',
                                ),
                                SiteDescription(
                                  title: "${context.toLocale?.lbl_assign_to}: ",
                                  description: (item.CFID_Assigned.isNullOrEmpty())
                                      ? (item.assignedToUserName.isNullOrEmpty())
                                          ? "----"
                                          : item.assignedToUserName!
                                      : item.CFID_Assigned!.split(",").first,
                                ),
                                SiteDescription(
                                  title: "${context.toLocale?.lbl_org}: ",
                                  description: (item.CFID_Assigned.isNullOrEmpty())
                                      ? (item.assignedToUserOrgName.isNullOrEmpty())
                                          ? "----"
                                          : item.assignedToUserOrgName!
                                      : item.CFID_Assigned!.split(", ").last,
                                ),
                              ],
                            ),
                          ),
                          Expanded(flex: 2, child: _getImage(context))
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),)
    );
  }

  Future<void> _addSessionToHeader() async {
    if (baseURL.isEmpty) {
      baseURL = await UrlHelper.getAdoddleURL(null);
    }
    var user = await StorePreference.getUserData();
    if ((user?.usersessionprofile!.aSessionId?.length)! > 0 && (user?.usersessionprofile!.currentJSessionID?.length)! > 0) {
      headersMap[AConstants.cookie] = 'ASessionID=${user?.usersessionprofile!.aSessionId};JSESSIONID=${user?.usersessionprofile!.currentJSessionID}';
    }
  }

  Widget _getImage(BuildContext context) {
    bool isOnline = isNetWorkConnected();
    if (externalImage != null && item.formHasAssocAttach == true && (isOnline || TypeImageUtility.extTypeMap.values.first.contains(externalImage?.extType) == false)) {
      try {
        String extType = externalImage?.extType ?? "";
        return Align(
          alignment: Directionality.of(context) == TextDirection.rtl ? Alignment.bottomLeft : Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(top: 18, end: 3),
            child: TypeImageUtility.isThumbnailTypeImage(extType) == true
                ? CachedNetworkImage(
                    height: 65,
                    width: 50,
                    imageUrl: "$baseURL${AConstants.viewThumbUrl}?projectId=${item.projectId.plainValue()}&attachmentId=${externalImage?.revisionId.plainValue()}",
                    httpHeaders: headersMap,
                    useOldImageOnUrlChange: false,
                    errorWidget: (context, url, error) => TypeImageUtility.getImage(extType, rect: const SizedBox(height: 60, width: 50)),
                    imageBuilder: (context, imageProvider) => Container(
                        decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
                    )),
                  )
                : TypeImageUtility.getImage(extType, rect: const SizedBox(height: 60, width: 50)),
          ),
        );
      } catch (e) {
        Log.d(e);
      }
    } else if (externalImage != null && !isOnline) {
      String extType = externalImage?.extType ?? "";
      return Align(
        alignment: Directionality.of(context) == TextDirection.rtl ? Alignment.bottomLeft : Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsetsDirectional.only(top: 18, end: 3),
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
    }
    return const SizedBox();
  }

  Color getStatusColor() {
    if (item.statusRecordStyle != null) {
      if ((item.statusRecordStyle['backgroundColor'] as String) != "") {
        return (item.statusRecordStyle['backgroundColor'] as String).toColor();
      }
    }
    return AColors.iconGreyColor;
  }

  Widget _getHeader(BuildContext context) {
    String dueOrCompletedDate = '';
    if (item.isCloseOut == true) {
      dueOrCompletedDate = "${context.toLocale!.lbl_task_completed}: ";
      if (item.statusUpdateDate != null) {
        dueOrCompletedDate += '${item.statusUpdateDate?.split('#').first}';
      }
    } else {
      dueOrCompletedDate = "${context.toLocale?.lbl_due}: ";
      if (item.responseRequestBy != null) {
        dueOrCompletedDate += '${item.responseRequestBy?.split('#').first}';
      }
    }
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 10, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            height: 20,
            width: 20,
            item.appBuilderId != null && AConstants.siteAppBuilderIds.contains(item.appBuilderId?.toLowerCase()) ? AImageConstants.accountHardHat : AImageConstants.otherTask,
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
                  (item.id?.isNullOrEmpty() ?? true) ? item.code! : item.id!,
                  color: AColors.iconGreyColor,
                  fontSize: 16,
                  fontWeight: AFontWight.semiBold,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ),
                NormalTextWidget(
                  dueOrCompletedDate,
                  color: AColors.iconGreyColor,
                  fontSize: 12,
                  fontWeight: AFontWight.regular,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                )
              ],
            ),
          ),
          const Spacer(),
          Flexible(
            flex: 3,
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(10, 10),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Semantics(
                      label: "Item status",
                      child: NormalTextWidget(
                        item.statusText ?? "--",
                        fontSize: 13,
                        fontWeight: AFontWight.light,
                        color: AColors.iconGreyColor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  // Icon(Icons.keyboard_arrow_down, color: AColors.iconGreyColor)
                ],
              ),
            ),
          ),
          const SizedBox(width: 30),
        ],
      ),
    );
  }
}
