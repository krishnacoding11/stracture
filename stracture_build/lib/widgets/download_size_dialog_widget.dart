import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:storage_space/storage_space.dart';

import '../bloc/download_size/download_size_state.dart';
import '../presentation/managers/color_manager.dart';
import '../presentation/managers/font_manager.dart';
import '../presentation/managers/image_constant.dart';
import '../utils/utils.dart';
import 'normaltext.dart';

class DownloadSizeLimit extends StatelessWidget {
  final StorageSpace storage;
  final int displaySize;
  const DownloadSizeLimit({Key? key, required this.storage, required this.displaySize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = 200;
    if (Utility.isTablet) {
      if ((MediaQuery.of(context).orientation == Orientation.portrait)) {
        width = MediaQuery.of(context).size.width * 0.6;
      } else {
        width = MediaQuery.of(context).size.width * 0.4;
      }
    } else {
      width = MediaQuery.of(context).size.width * 0.9;
    }
    return Container(
      width: width,
      child: Column(
        key: Key("download_size_limit_state"),
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          SizedBox(
            child: ImageIcon(
              AssetImage(AImageConstants.vector),
              size: 50,
              color: Colors.red,
            )
          ),
          const SizedBox(height: 15),
          Container(
            // width: width,
            child: Column(
              children: [
                NormalTextWidget(
                  context.toLocale!.lbl_data_limit_title,
                  fontWeight: AFontWight.bold,
                  fontSize: 24,
                  color: AColors.textColor,
                ),
                const SizedBox(height: 17),
                Container(
                  width: Utility.isTablet ? width * 0.8 : width * 0.9,
                  child: NormalTextWidget(
                    context.toLocale!.lbl_data_limit_content("${Utility.getFileSizeString(bytes: double.parse(displaySize.toString()))}"),
                    textAlign: TextAlign.center,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w400,
                    color: AColors.grColorDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5),
            width: Utility.isTablet ? width * 0.7 : width * 0.8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                    child: ImageIcon(
                  AssetImage(AImageConstants.localStorage),
                  size: 30,
                  color: Colors.red,
                )),
                Expanded(
                  child: Container(
                    // width: 220,
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: NormalTextWidget(
                                context.toLocale!.lbl_local_storage,
                                fontWeight: FontWeight.w400,
                                fontSize: 14.0,
                                color: AColors.grColorDark,
                              ),
                            ),
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: NormalTextWidget(
                                      context.toLocale!.lbl_gb("${storage.usedSize}/"),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13.0,
                                      color: Colors.red,
                                    ),
                                  ),
                                  Flexible(
                                    child: NormalTextWidget(
                                     context.toLocale!.lbl_gb("${storage.totalSize}"),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 13.0,
                                      color: AColors.grColorDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 10,
                          padding: EdgeInsets.only(top: 4),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            child: LinearProgressIndicator(
                                value: double.parse(storage.usedSize.split(" ").first) / double.parse(storage.totalSize.split(" ").first),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.red),
                                backgroundColor: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 13),
          Container(
            width: Utility.isTablet ? width * 0.6 : width * 0.8,
            // width: width,
            child: Column(
              children: [
                const SizedBox(height: 10),
                NormalTextWidget(
                  context.toLocale!.lbl_selection_retry,
                  textAlign: TextAlign.center,
                  fontSize: 13.0,
                  fontWeight: FontWeight.w400,
                  color: AColors.grColorDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
              color: AColors.lightGreyColor, height: 2, width: width),
          TextButton(
            key: const Key('key_ok_button_limit'),
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: NormalTextWidget(
              context.toLocale!.lbl_ok,
              textAlign: TextAlign.center,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AColors.userOnlineColor,
            ),),
        ],
      ),
    );
  }
}

class DownloadSizeError extends StatelessWidget {
  final SyncDownloadErrorState state;

  const DownloadSizeError({Key? key, required this.state}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double width = 200;
    if (Utility.isTablet) {
      if ((MediaQuery.of(context).orientation == Orientation.portrait)) {
        width = MediaQuery.of(context).size.width * 0.6;
      } else {
        width = MediaQuery.of(context).size.width * 0.5;
      }
    } else {
      width = MediaQuery.of(context).size.width * 0.8;
    }
    return SizedBox(
      key: Key("download_size_error_state"),
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const SizedBox(
            child: Icon(
              Icons.cloud_download_outlined,
              color: Colors.green,
              size: 50,
            ),
          ),
          const SizedBox(height: 16),
          NormalTextWidget(context.toLocale!.lbl_download,
              fontWeight: AFontWight.bold, fontSize: 24),
          const SizedBox(height: 20),
          SizedBox(
            width: width - 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                    child: NormalTextWidget(!state.message.isNullOrEmpty() &&
                            state.message.trim() != "null"
                        ? state.message
                        : context.toLocale!.something_went_wrong)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(color: AColors.lightGreyColor, height: 2, width: width),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Center(
                  child: TextButton(
                    key: Key("key_ok_button_error"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: NormalTextWidget(context.toLocale!.lbl_btn_cancel,
                          color: AColors.lightGreyColor, fontSize: 18)),
                ),
              ),
              Container(color: AColors.lightGreyColor, height: 40, width: 2),
              Flexible(
                child: Center(
                  child: TextButton(
                      onPressed: null,
                      child: NormalTextWidget(context.toLocale!.btn_select,
                          color: AColors.lightGreyColor, fontSize: 18)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
