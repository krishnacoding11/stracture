import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';

class ModelRequestDialog extends StatefulWidget {
  BuildContext mContext;
  final VoidCallback onTap;

  ModelRequestDialog(
    this.mContext, {
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  State<ModelRequestDialog> createState() => _ModelRequestDialogState();
}

class _ModelRequestDialogState extends State<ModelRequestDialog> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      key: Key('key_orientation_builder'),
      builder: (BuildContext context, Orientation orientation) {
        return  Center(
          key: Key('key_center'),
          child: Container(
            key: Key('key_request_dialog_container'),
            width: Utility.isTablet
                ? orientation==Orientation.landscape?MediaQuery.of(context).size.width * .40:MediaQuery.of(context).size.width * .60
                : MediaQuery.of(context).size.width * .90,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Material(
              child: Column(
                key: Key('key_request_dialog_column'),
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 16),
                  Image.asset(
                    AImageConstants.requestCloud,
                    key: Key('key_request_dialog_image_request_cloud'),
                    scale: 1,
                    height: 46,
                    width: 46,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 8),
                  NormalTextWidget(
                    context.toLocale!.model_request,
                    key: Key('key_request_dialog_model_request_text'),
                    fontWeight: AFontWight.bold,
                    textAlign: TextAlign.start,
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 16),
                    child: NormalTextWidget(
                      context.toLocale!.send_a_request,
                      key: Key('key_request_dialog_send_a_request_text'),
                      fontWeight: AFontWight.regular,
                      textAlign: TextAlign.center,
                      color: AColors.iconGreyColor,
                      fontSize: 15,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    key: Key('key_request_dialog_buttons_row'),
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Ink(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    color: AColors.iconGreyColor, width: 1),
                                right: BorderSide(
                                    color: AColors.iconGreyColor, width: .5),
                              ),
                            ),
                            child: NormalTextWidget(
                              context.toLocale!.lbl_btn_cancel,
                              key: Key('key_request_dialog_btn_cancel'),
                              color: AColors.iconGreyColor,
                              fontWeight: AFontWight.semiBold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        key: Key('key_request_dialog_expanded'),
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            widget.onTap();
                          },
                          child: Ink(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    color: AColors.iconGreyColor, width: 1),
                                left: BorderSide(
                                    color: AColors.iconGreyColor, width: .5),
                              ),
                            ),
                            child: NormalTextWidget(
                              context.toLocale!.request,
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
