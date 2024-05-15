import 'dart:io';

import 'package:camera/camera.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/elevatedbutton.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


// A widget that displays the picture taken by the user.
class ImagePreviewWidget extends StatefulWidget {
  final dynamic arguments;
  const ImagePreviewWidget({super.key, required this.arguments});

  @override
  State<ImagePreviewWidget> createState() => _ImagePreviewWidgetState();
}

class _ImagePreviewWidgetState extends State<ImagePreviewWidget> {

  late XFile capturedFile;

  @override
  void initState() {
    super.initState();

    capturedFile = widget.arguments["capturedFile"];

    Utility.isTablet
        ? SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeRight,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ])
        : SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AColors.btnDisableClr,
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.white,
        title: NormalTextWidget(
          context.toLocale!.image_preview,
          fontSize: 16,
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
              child:Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  children: [
                    Expanded(child: _previewList()),
                  ],
                ),
              )
          ),
          widgetBottomAttach(),
        ],
      ),
    );
  }

  Widget widgetBottomAttach() {
    return Container(
      width: double.maxFinite,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
          color: Colors.white, border: Border(top: BorderSide(color: AColors.dividerColor))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AElevatedButtonWidget(
            height: 40,
            width: 110,
            fontWeight: AFontWight.medium,
            borderRadius: 4,
            fontFamily: AFonts.fontFamily,
            fontSize: 16,
            btnLabelClr: AColors.aPrimaryColor,
            btnBackgroundClr: AColors.white,
            btnLabel: context.toLocale!.retake,
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(
            width: 15,
          ),
          AElevatedButtonWidget(
            height: 40,
            width: 115,
            fontWeight: AFontWight.medium,
            borderRadius: 4,
            fontFamily: AFonts.fontFamily,
            fontSize: 16,
            btnLabel: context.toLocale!.lbl_btn_continue,
            onPressed: () {
              Navigator.of(context).pop(capturedFile);
            },
          ),
        ],
      ),
    );
  }



  Widget _previewList() {
    return Container(
      margin: const EdgeInsets.all(12.0),
      child: Image.file(
        File(capturedFile.path),
        fit: BoxFit.contain,
      ),
    );
  }

}
