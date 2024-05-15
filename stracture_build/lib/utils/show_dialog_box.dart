import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:flutter/material.dart';

import 'custom_session_timeout_dialog.dart';

class ShowAlertDialogBox {
  static setOfflineDialogBox({
    required BuildContext context,
    required String title,
    required Function() onSetOffline,
    required Function() onProperties,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: AColors.black,
                      fontFamily: "Sofia",
                      fontWeight: AFontWight.medium,
                      fontSize: 14),
                ),
                const Divider(
                  thickness: 0.4,
                  color: Colors.black,
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                        onTap: onSetOffline,
                        child: SizedBox(
                            height: 80.0,
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.wifi_off,
                                  size: 50.0,
                                ),
                                Text(
                                  'Set Offline',
                                  style: TextStyle(
                                      color: AColors.black,
                                      fontFamily: "Sofia",
                                      fontWeight: AFontWight.medium,
                                      fontSize: 12),
                                ),
                              ],
                            ))),
                    const VerticalDivider(
                      color: Colors.black,
                      thickness: 0.4,
                    ),
                    GestureDetector(
                        onTap: onProperties,
                        child: SizedBox(
                            height: 80.0,
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.note_alt_outlined,
                                  size: 50.0,
                                ),
                                Text(
                                  'Properties',
                                  style: TextStyle(
                                      color: AColors.black,
                                      fontFamily: "Sofia",
                                      fontWeight: AFontWight.medium,
                                      fontSize: 12),
                                ),
                              ],
                            ))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static issueWhileLoadingModels({
    required BuildContext context,
    required String totalNumbersOfModel,
    required String totalNumbersOfModelLoadFailed,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Ok"))
          ],
          content: SingleChildScrollView(
            child: Column(
              children: [
                const Center(
                  child: Text(
                    'Missing Model!',
                    style: TextStyle(
                        color: AColors.black,
                        fontFamily: "Sofia",
                        fontWeight: AFontWight.bold,
                        fontSize: 14),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                const Divider(),
                Center(
                  child: Text(
                    'Load ${int.parse(totalNumbersOfModel) - int.parse(totalNumbersOfModelLoadFailed)} models out of $totalNumbersOfModel',
                    style: const TextStyle(
                        color: AColors.black,
                        fontFamily: "Sofia",
                        fontWeight: AFontWight.medium,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static modelLoadingFailed({
    required BuildContext context,
  }) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => CustomSessionTimeOutDialogBox(context: context,));
  }

  static inSufficientStorage({
    required BuildContext context,
  }) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => InsufficientStorageDialogBox(context: context,));
  }
}
