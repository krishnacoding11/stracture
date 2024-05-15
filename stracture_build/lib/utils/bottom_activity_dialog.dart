import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';

import '../utils/navigation_utils.dart';

class BottomActivityDialog {
  static createDialog({required String title, List<Map<String, dynamic>>? actionList, BuildContext? ctx}) {
    ctx = ctx ?? NavigationUtils.mainNavigationKey.currentContext!;
    showDialog(
      context: ctx,
      builder: (BuildContext context) {
        double width = MediaQuery.of(context).size.width * 0.95;
        return AlertDialog(
          alignment: Utility.isTablet ? Alignment.bottomRight : Alignment.bottomCenter,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          insetPadding: EdgeInsets.zero,
          contentPadding: Utility.isTablet ? const EdgeInsets.only(right: 15) : EdgeInsets.zero,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          content: SizedBox(
            width: Utility.isTablet ? 350 : width,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(10.0))),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        child: NormalTextWidget(
                          title,
                          fontWeight: AFontWight.regular,
                          textAlign: TextAlign.center,
                          color: AColors.hintColor,
                          fontSize: 15,
                        ),
                      ),
                      const Divider(
                        height: 1.0,
                      ),
                      ListView.builder(
                        itemCount: actionList!.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext ctx, int index) {
                          // Create Inkwell based on the activity list
                          return getActionItems(actionList[index]);
                        },
                      ),

                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.only(bottom: 40.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10.0,
                      ),
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: NormalTextWidget(
                      context.toLocale!.lbl_btn_cancel,
                      fontWeight: AFontWight.medium,
                      textAlign: TextAlign.center,
                      color: AColors.grColorDark,
                      fontSize: 20,
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget getActionItems(Map<String, dynamic> actionList) {
  return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      InkWell(
        onTap: () {
          actionList['callback']();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
          ),
          child: NormalTextWidget(
            actionList['title'],
            fontWeight: AFontWight.medium,
            textAlign: TextAlign.center,
            color: AColors.textColor1,
            fontSize: 22,
          ),
        ),
      ),
      const Divider(
        height: 1.0,
      ),
    ],
  );
}
