import 'package:field/data/model/apptype_vo.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/presentation/screen/online_model_viewer/snagging/create_site_task.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/global.dart' as globals;
import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';

import '../../../../../widgets/normaltext.dart';
import '../../../../utils/navigation_utils.dart';
import '../../webview/asite_webview.dart';

class PinTypeDialog extends StatelessWidget {
  const PinTypeDialog({Key? key}) : super(key: key);

  // CreateFormDialog(this.appTypeList);

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
                child: Text(
                  context.toLocale!.lbl_select_action,
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, fontFamily: "Sofia"),
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, size: 25),
                        color: Colors.black54,
                        onPressed: () {
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
            children: [createSiteTaskCard(context), createFormCard(context)],
          )
        ],
      ),
    );
  }

  Widget createSiteTaskCard(BuildContext context) {
    return Flexible(
      key: Key("key_create_pin_card"),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 5,
        margin: const EdgeInsets.all(10),
        child: InkWell(
          onTap: () {
            createSiteTaskOrForm(context);
            // for (AppType app in globals.appTypeList) {
            //   bool isEnabled = app.isMarkDefault!;
            //   if (isEnabled) {
            //     Navigator.pop(context, app);
            //     break;
            //   }
            // }
          },
          child: SizedBox(
            key: Key("key_create_pin_item"),
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
                NormalTextWidget(context.toLocale!.lbl_create_site_task, fontWeight: FontWeight.normal, fontSize: (Utility.isTablet ? 16 : 14)),
                SizedBox(height: Utility.isTablet ? 15 : 5)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget createFormCard(BuildContext context) {
    return Flexible(
        child: Card(
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
              NormalTextWidget(context.toLocale!.lbl_create_site_form, fontWeight: FontWeight.normal, fontSize: (Utility.isTablet ? 16 : 14)),
              SizedBox(height: Utility.isTablet ? 15 : 5)
            ],
          ),
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  Widget createFormDialogWidget(context) {
    return CreateSiteTask(
      key: Key('key_show_create_form_dialog'),
    );
  }

  void _showCreateFormDialog(BuildContext context) async {
    await showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return createFormDialogWidget(context);
        }).then((value) {
      if (value is AppType) {
        Navigator.pop(context, value);
      } else {
        Navigator.pop(context);
      }
    });
  }

  Future<void> createSiteTaskOrForm(context) async {
    if (Utility.isTablet) {
      await showDialog(
          context: context,
          builder: (context) {
            var height = MediaQuery.of(context).size.height * 0.85;
            var width = MediaQuery.of(context).size.width * 0.87;
            return Dialog(
              insetPadding: EdgeInsets.zero,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: SizedBox(
                width: width,
                height: height,
                child: AsiteWebView(
                  url: "https://adoddleqaak.asite.com/adoddle/apps?action_id=903&formSelectRadiobutton=1_2155366\$\$sYuF3p_11301405\$\$Ot5UvH_&screen=new&isFromCbim=true&bim_model_id=46781\$\$3HSjoM&isFromWhere=3&uniqueId=3&bimObjectsData=assocObjects",
                  title: "${context.toLocale!.lbl_create} Defect",
                  data: {"projectId": "12345", "locationId": "2344443", "commId": "132234", "appTypeId": 1},
                ),
              ),
            );
          }).then((value) {});
    } else {
      await NavigationUtils.mainPushWithResult(
        context,
        MaterialPageRoute(
          builder: (context) => AsiteWebView(
            url: "https://adoddleqaak.asite.com/adoddle/apps?action_id=903&formSelectRadiobutton=1_2155366\$\$sYuF3p_11301405\$\$Ot5UvH_&screen=new&isFromCbim=true&bim_model_id=46781\$\$3HSjoM&isFromWhere=3&uniqueId=3&bimObjectsData=assocObjects",
            title: "${context.toLocale!.lbl_create} Defect",
            data: {"projectId": "12345", "locationId": "2344443", "commId": "132234", "appTypeId": 1},
          ),
        ),
      )?.then((value) {});
    }
  }
}
