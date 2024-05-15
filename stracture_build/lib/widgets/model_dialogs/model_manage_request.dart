import 'package:field/bloc/model_list/model_list_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';

import '../../bloc/online_model_viewer/online_model_viewer_cubit.dart';
import '../../data/model/user_vo.dart';
import '../../utils/actionIdConstants.dart';
import '../../utils/store_preference.dart';

class ModelManageRequestDialog extends StatefulWidget {
  final String projectId;
  final String modelId;
  const ModelManageRequestDialog({
    Key? key,
    required this.projectId,
    required this.modelId,
  }) : super(key: key);

  @override
  State<ModelManageRequestDialog> createState() => _ModelManageRequestDialogState();
}

class _ModelManageRequestDialogState extends State<ModelManageRequestDialog> {
  final ModelListCubit _modelListCubit = getIt<ModelListCubit>();
  OnlineModelViewerCubit onlineModelViewerCubit = getIt<OnlineModelViewerCubit>();
  User? user;

  @override
  void initState() {
    _modelListCubit.selectedOption = "latest";
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      key: Key('key_manage_request_orientation_builder'),
      builder: (BuildContext context, Orientation orientation) {
        return Center(
          key: Key('key_manage_request_center'),
          child: Container(
            key: Key('key_manage_request_container'),
            width: Utility.isTablet
                ? orientation == Orientation.landscape
                    ? MediaQuery.of(context).size.width * .40
                    : MediaQuery.of(context).size.width * .60
                : MediaQuery.of(context).size.width * .90,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
            child: Material(
              child: Column(
                key: Key('key_manage_request_column'),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 16),
                  Image.asset(
                    AImageConstants.requestCloud,
                    scale: 1,
                    height: 36,
                    width: 36,
                  ),
                  const SizedBox(height: 8),
                  NormalTextWidget(
                    context.toLocale!.set_model_offline,
                    key: Key('key_manage_request_offline_text_widget'),
                    fontWeight: AFontWight.bold,
                    textAlign: TextAlign.start,
                    fontSize: 18,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  NormalTextWidget(
                    context.toLocale!.please_select_revision,
                    key: Key('key_manage_request_revision_text_widget'),
                    fontWeight: AFontWight.regular,
                    textAlign: TextAlign.center,
                    color: AColors.iconGreyColor,
                    fontSize: 13,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Align(
                    key: Key('key_manage_request_align'),
                    alignment: Alignment.center,
                    child: RadioTile(
                        title: "Latest",
                        value: "latest",
                        selectedValue: _modelListCubit.selectedOption,
                        onChange: (String? v) {
                          _modelListCubit.selectedOption = v!;
                          setState(() {});
                        }),
                  ),
                  Align(
                    key: Key('key_manage_request_align_superseded'),
                    alignment: Alignment.center,
                    child: RadioTile(
                        title: "Superseded",
                        value: "superseded",
                        selectedValue: _modelListCubit.selectedOption,
                        onChange: (String? v) {
                          _modelListCubit.selectedOption = v!;
                          setState(() {});
                        }),
                  ),
                  Align(
                    key: Key('key_manage_request_align_all'),
                    alignment: Alignment.center,
                    child: RadioTile(
                        title: "All",
                        value: "all",
                        selectedValue: _modelListCubit.selectedOption,
                        onChange: (String? v) {
                          _modelListCubit.selectedOption = v!;
                          setState(() {});
                        }),
                  ),
                  const SizedBox(height: 2),
                  NormalTextWidget(
                    context.toLocale!.please_note_model_manage,
                    key: Key('key_manage_request_model_manage'),
                    fontWeight: AFontWight.regular,
                    textAlign: TextAlign.center,
                    color: AColors.iconGreyColor,
                    fontSize: 11,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    key: Key('key_manage_request_row'),
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pop("cancel");
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
                              color: AColors.black,
                              fontWeight: AFontWight.semiBold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        key: Key('key_manage_request_expanded'),
                        child: InkWell(
                          onTap: () async {
                            user = await StorePreference.getUserData();
                            onlineModelViewerCubit.setParallelViewAuditTrail(widget.projectId, "${user!.usersessionprofile!.firstName! + " " + user!.usersessionprofile!.lastName!}", "Set Offline", ActionConstants.actionId97, widget.modelId, "");
                            Navigator.of(context).pop("ok");
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
                              context.toLocale!.button_text_select,
                              key: Key('key_button_text_select_widget'),
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

class RadioTile<T> extends StatelessWidget {
  final String title;
  final T value;
  final T selectedValue;
  final Function(T) onChange;

  const RadioTile({super.key, required this.title, required this.value, required this.selectedValue, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onChange(value);
      },
      child: Container(
        width: 120,
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              value == selectedValue ? Icons.radio_button_checked : Icons.radio_button_off,
              color: Colors.grey,
              size: 26,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: NormalTextWidget(
                title,
                fontWeight: AFontWight.regular,
                textAlign: TextAlign.start,
                color: AColors.black,
                fontSize: 14,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
