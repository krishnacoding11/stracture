import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';

class ModelUpdateDialog extends StatefulWidget {
  final VoidCallback onTapSelect;

  const ModelUpdateDialog({Key? key, required this.onTapSelect})
      : super(key: key);

  @override
  State<ModelUpdateDialog> createState() => _ModelUpdateDialogState();
}

class _ModelUpdateDialogState extends State<ModelUpdateDialog> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return  Center(
          child: Container(
            width: Utility.isTablet
                ? orientation==Orientation.landscape?MediaQuery.of(context).size.width * .40:MediaQuery.of(context).size.width * .60
                : MediaQuery.of(context).size.width * .90,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Material(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 16),
                  const Icon(Icons.offline_pin_outlined,
                      size: 46, color: Colors.green),
                  const SizedBox(height: 8),
                  NormalTextWidget(
                    context.toLocale!.update,
                    fontWeight: AFontWight.bold,
                    textAlign: TextAlign.start,
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  NormalTextWidget(
                    context.toLocale!.are_sure_update,  fontWeight: AFontWight.regular,
                    textAlign: TextAlign.center,
                    color: AColors.iconGreyColor,
                    fontSize: 15,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      NormalTextWidget(
                        "Remove 260MB of model data",
                        fontWeight: AFontWight.semiBold,
                        textAlign: TextAlign.start,
                        color: AColors.black,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      NormalTextWidget(
                        "Remove 20MB of calibrated drawing data",
                        fontWeight: AFontWight.semiBold,
                        textAlign: TextAlign.start,
                        color: AColors.black,
                        fontSize: 14,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.grey,
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  NormalTextWidget(
                    context.toLocale!.please_note_download,
                    fontWeight: AFontWight.regular,
                    textAlign: TextAlign.start,
                    color: AColors.iconGreyColor,
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
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
                            child:  NormalTextWidget(
                              context.toLocale!.lbl_btn_cancel,
                              color: AColors.black,
                              fontWeight: AFontWight.semiBold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(

                        child: InkWell(
                          onTap: (){
                            Navigator.pop(context);
                            widget.onTapSelect();
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
                              context.toLocale!.lbl_btn_yes,
                              color: AColors.themeBlueColor,
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
