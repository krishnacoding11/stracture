import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:equatable/equatable.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/download_size/download_size_cubit.dart';
import '../bloc/download_size/download_size_state.dart';
import '../injection_container.dart';
import 'download_size_dialog_widget.dart';

class ProjectDownloadSizeWidget extends StatefulWidget {
  final String strProjectId;
  final List<String?> locationId;

  const ProjectDownloadSizeWidget(
      {super.key,
      required this.strProjectId,
      required this.locationId});

  @override
  State<ProjectDownloadSizeWidget> createState() => _ProjectDownloadSizeState();
}

class _ProjectDownloadSizeState extends State<ProjectDownloadSizeWidget> {

 late DownloadSizeCubit downloadSizeCubit;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadSizeCubit = getIt<DownloadSizeCubit>();
    downloadSizeCubit.getProjectOfflineSyncDataSize(widget.strProjectId, widget.locationId);
  }

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
    return BlocProvider(create:(_) => downloadSizeCubit, child:
      BlocBuilder<DownloadSizeCubit, Equatable>(builder: (context, state) {
      if (state is SyncDownloadSizeState) {
        String size = Utility.getFileSizeWithMetaData(bytes: state.totalBytes);
            return Semantics(
              label: "ProjectDownloadSizeDialog",
              child: SizedBox(
                key: Key("download_size_success_state"),
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
                    NormalTextWidget(context.toLocale!.lbl_download, fontWeight: AFontWight.bold, fontSize: 24),
                    const SizedBox(height: 20),
                    Flexible(
                        child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: NormalTextWidget(
                        context.toLocale!.lbl_project_size_confirm_message(size),
                        maxLines: 3,
                        textScaleFactor: 1,
                      ),
                    )),
                    const SizedBox(height: 20),
                    Container(color: AColors.lightGreyColor, height: 2, width: width),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Center(
                            child: TextButton(
                                key: Key("key_cancel_button"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: NormalTextWidget(context.toLocale!.lbl_btn_cancel, color: AColors.lightGreyColor, fontSize: 18)),
                          ),
                        ),
                        Container(color: AColors.lightGreyColor, height: 40, width: 2),
                        Flexible(
                          child: Center(
                            child: TextButton(
                                key: Key("key_select_button"),
                                onPressed: () {
                                  NavigationUtils.mainPopWithResult(state.totalBytes);
                                },
                                child: NormalTextWidget(context.toLocale!.btn_select, color: AColors.greenColor, fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
      } else if(state is SyncDownloadLimitState){
        return  DownloadSizeLimit(storage: state.storage, displaySize: state.displaySize,);
      } else if (state is SyncDownloadErrorState) {
        return DownloadSizeError(state: state,);
      } else {
        return SizedBox(
          key: Key("download_size_loading_state"),
          width: width*1.2,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                NormalTextWidget(context.toLocale!.lbl_calculating_download_size),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const NormalTextWidget("("),
                    DefaultTextStyle(
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        color: AColors.textColor,
                        fontFamily: AFonts.fontFamily,
                        fontWeight: AFontWight.bold,
                        fontSize: 18,
                      ),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          WavyAnimatedText('.....'),
                        ],
                        isRepeatingAnimation: true,
                        onTap: null,
                        repeatForever: true,
                      ),
                    ),
                    const NormalTextWidget(")"),
                  ],
                ),
              ],)
              ,
              const SizedBox(height: 20),
              Container(
                  color: AColors.lightGreyColor, height: 2, width: width*1.2),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Center(
                      child: TextButton(
                        key: Key("key_loading_cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: NormalTextWidget(
                              context.toLocale!.lbl_btn_cancel,
                              color: AColors.lightGreyColor,
                              fontSize: 18)),
                    ),
                  ),
                  Container(
                      color: AColors.lightGreyColor, height: 40, width: 2),
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
    }));
  }

/* int getTotalSizeOfLocation(Map<String,List<Map<String,DownloadSizeVo>>> downloadItems){
   int totalDownloadSize =0;

   downloadItems.forEach((key, value) {
     value.forEach((element) {
       element.forEach((key, value) {
         totalDownloadSize += int.parse(value.totalSize.toString());
       });
     });
   });

   return totalDownloadSize;
 }*/

/* int getTotalSizeOfMetaData(Map<String, List<Map<String, DownloadSizeVo>>> downloadItems) {
    int totalMetaDataSize = 0;

    downloadItems.forEach((key, value) {
      value.forEach((element) {
        element.forEach((key, value) {
          int metadataSize = value.countOfLocations! * 500;
          totalMetaDataSize += int.parse(metadataSize.toString());
        });
      });
    });

    return totalMetaDataSize;
  }*/
}

class ProjectAlreadyMarkOffline extends StatelessWidget {
  const ProjectAlreadyMarkOffline({Key? key}) : super(key: key);

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

    return Column(
      key: Key("key_project_already_download"),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        Container(
          width: width,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              NormalTextWidget(
                context.toLocale!.lbl_offline_data_already_exists,
                fontWeight: AFontWight.bold,
                fontSize: 24,
                color: AColors.textColor,
              ),
              const SizedBox(height: 20),
              NormalTextWidget(
                context.toLocale!.lbl_offline_project_data_already_exists,
                textAlign: TextAlign.center,
                fontSize: 16.0,
                fontWeight: FontWeight.w400,
                color: AColors.grColorDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(color: AColors.lightGreyColor, height: 2, width: width),
        InkWell(
          key: Key("key_ok_button"),
          onTap: ()=>Navigator.of(context).pop(),
          child: Container(
            height: 50,
            width: width,
            alignment: Alignment.center,
            child: NormalTextWidget(
              context.toLocale!.lbl_ok,
              textAlign: TextAlign.center,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: AColors.userOnlineColor,
            ),
          ),
        ),
      ],
    );
  }
}
