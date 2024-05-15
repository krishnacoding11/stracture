import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';

import '../../data/model/model_vo.dart';

class ModelRequestSetOfflineDialog extends StatefulWidget {
  BuildContext mContext;
  final VoidCallback onTap;
  final Model model;

  ModelRequestSetOfflineDialog(
    this.mContext, {
    required this.onTap,
    Key? key,
    required this.model,
  }) : super(key: key);

  @override
  State<ModelRequestSetOfflineDialog> createState() => _ModelRequestSetOfflineDialogState();
}

class _ModelRequestSetOfflineDialogState extends State<ModelRequestSetOfflineDialog> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      key: Key('key_orientation_builder'),
      builder: (BuildContext context, Orientation orientation) {
        return Center(
          key: Key('key_center_model_set_request_dialog'),
          child: Container(
            key: Key('key_container_model_set_request_dialog'),
            width: Utility.isTablet
                ? orientation == Orientation.landscape
                    ? MediaQuery.of(context).size.width * .40
                    : MediaQuery.of(context).size.width * .60
                : MediaQuery.of(context).size.width * .90,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Material(
              child: Column(
                key: Key('key_column_model_set_request_dialog'),
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 16),
                  Image.asset(
                    AImageConstants.requestCloud,
                    key: Key('key_image_asset_model_set_request_dialog'),
                    scale: 1,
                    height: 46,
                    width: 46,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  NormalTextWidget(
                    context.toLocale!.model_request,
                    key: Key('key_model_request_model_set_request_dialog'),
                    fontWeight: AFontWight.bold,
                    textAlign: TextAlign.start,
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    key: Key('key_padding_model_set_request_dialog'),
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: NormalTextWidget(
                      context.toLocale!.offline_viewing,
                      fontWeight: AFontWight.regular,
                      textAlign: TextAlign.center,
                      color: AColors.iconGreyColor,
                      fontSize: 15,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    key: Key('key_row_model_set_request_dialog'),
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop(AConstants.cancel);
                          },
                          child: Ink(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AColors.iconGreyColor, width: 1),
                                right: BorderSide(color: AColors.iconGreyColor, width: .5),
                              ),
                            ),
                            child: NormalTextWidget(
                              context.toLocale!.lbl_btn_cancel,
                              color: AColors.iconGreyColor,
                              fontWeight: AFontWight.semiBold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        key: Key('key_expanded_continue_model_set_request_dialog'),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop(AConstants.ok);
                          },
                          child: Ink(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(color: AColors.iconGreyColor, width: 1),
                                left: BorderSide(color: AColors.iconGreyColor, width: .5),
                              ),
                            ),
                            child: NormalTextWidget(
                              context.toLocale!.lbl_btn_continue,
                              color: AColors.black,
                              fontWeight: AFontWight.semiBold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
