import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart' as online_model_viewer;
import 'package:field/bloc/site/create_form_selection_cubit.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/get_threed_type_list.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/presentation/screen/site_routes/create_form_dialog/create_form_dialog_threed.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/global.dart' as globals;
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../../../../widgets/normaltext.dart';
import '../../../../widgets/progressbar.dart';
import 'create_form_dialog.dart';

class TaskTypeDialogThreeD extends StatelessWidget {
  const TaskTypeDialogThreeD(
      {Key? key,
      required this.createFormSelectionCubit})
      : super(key: key);

  final CreateFormSelectionCubit createFormSelectionCubit;

  dialogContent(BuildContext context) {
    return Container(
      key: Key("key_dialog"),
      width: 375,
      height: 240,
      decoration: BoxDecoration(
        color: AColors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0.0, 10.0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // To make the card compact
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 50),
              const Spacer(),
              Align(
                alignment: Alignment.center,
                child: NormalTextWidget(
                  context.toLocale!.lbl_select_action,
                  textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.18),
                  style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Sofia"),
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8, 8, 0, 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, size: 25),
                        color: Colors.black54,
                        onPressed: () {
                          getIt<online_model_viewer.OnlineModelViewerCubit>().webviewController.evaluateJavascript(source: "PinManager.disablePinOperator()");
                          Navigator.of(context, rootNavigator: true).pop();
                        },
                        // onPressed: controller != null ? onFlashModeButtonPressed : null,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              createSiteTaskCard(context),
              createFormCard(context)
            ],
          )
        ],
      ),
    );
  }



  Widget createSiteTaskCard(BuildContext context) {
    return Flexible(
      key: Key("key_create_sitetask_card"),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        margin: const EdgeInsets.all(10),
        child: InkWell(
          onTap: () {
            for (AppType app in globals.appTypeList) {
              bool isEnabled = app.isMarkDefault!;
              if (isEnabled) {
                Navigator.pop(context, app);
                break;
              }
            }
          },
          child: SizedBox(
            key: Key("key_create_sitetask_item"),
            height: Utility.isTablet ? 150 : 120,
            width: Utility.isTablet ? 150 : 120,
            child: Column(
              children: [
                const SizedBox(height: 15),
                Image.asset(
                  AImageConstants.createSubTask,
                  fit: BoxFit.fitHeight,
                  width: Utility.isTablet ? 85 : 65,
                  height: Utility.isTablet ? 85 : 65,
                ),
                const Spacer(),
                NormalTextWidget(context.toLocale!.lbl_create_site_task,
                    fontWeight: FontWeight.normal,
                    textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.18),
                    fontSize: (Utility.isTablet ? 16 : 14)),
                SizedBox(height: Utility.isTablet ? 15 : 5)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget createFormCard(BuildContext context) {
    return Flexible(child: Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: InkWell(
        onTap: () {
          _showCreateFormDialog(context);
        },
        child: SizedBox(
          key: Key("key_create_form_card"),
          height: Utility.isTablet ? 150 : 120,
          width: Utility.isTablet ? 150 : 120,
          child: Column(
            children: [
              const SizedBox(height: 15),
              Image.asset(
                AImageConstants.createForm,
                fit: BoxFit.fitHeight,
                width: Utility.isTablet ? 85 : 65,
                height: Utility.isTablet ? 85 : 65,
              ),
              const Spacer(),
              NormalTextWidget(context.toLocale!.lbl_create_site_form,
                  fontWeight: FontWeight.normal,
                  textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.18),
                  fontSize: (Utility.isTablet ? 16 : 14)),
              SizedBox(height: Utility.isTablet ? 15 : 5)
            ],
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateFormSelectionCubit, FlowState>(
      bloc: createFormSelectionCubit,
        builder: (context, state) {
      return state is LoadingState
          ? const ACircularProgress(key: Key("key_loading"),)
          : Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0.0,
                  backgroundColor: Colors.transparent,
                  child: dialogContent(context),
                );
              //: createFormDialogWidget();
    });
  }

  Widget createFormDialogWidget() {
    return BlocProvider(
      create: (_) => createFormSelectionCubit,
      child: const CreateFormDialogThreeD(
        key: Key('key_show_create_form_dialog'),
      ),
    );
  }

  void _showCreateFormDialog(BuildContext context) async {
    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return createFormDialogWidget();
        }).then((value) {
      if (value is Datum) {
        Navigator.pop(context, value);
      } else {
        Navigator.pop(context);
      }
    });
  }
}
