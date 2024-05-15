import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart' as side_tool_bar;
import 'package:field/injection_container.dart' as di;
import 'package:field/utils/constants.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../bloc/online_model_viewer/online_model_viewer_cubit.dart';
import '../../managers/color_manager.dart';

class CustomColorPicker extends StatelessWidget {
  CustomColorPicker({super.key});

  final side_tool_bar.SideToolBarCubit _sideToolBarCubit = di.getIt<side_tool_bar.SideToolBarCubit>();
  final OnlineModelViewerCubit _onlineModelViewerCubit = di.getIt<OnlineModelViewerCubit>();

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (BuildContext context, Orientation orientation) {
        return Dialog(
          child: SizedBox(
            width: _getWidth(orientation, context),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NormalTextWidget(
                        AConstants.colorPicker,
                        fontSize: 18,
                        color: AColors.black,
                      ),
                      IconButton(
                        onPressed: () {
                          _onlineModelViewerCubit.emitNormalWebState();
                          Navigator.pop(context);
                          _onlineModelViewerCubit.emitNormalWebState();
                        },
                        icon: Icon(
                          Icons.close,
                        ),
                        iconSize: 24,
                        color: AColors.iconGreyColor,
                      )
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ColorPicker(
                      portraitOnly: true,
                      pickerAreaBorderRadius: BorderRadius.circular(8),
                      pickerColor: _onlineModelViewerCubit.pickerColor,
                      onColorChanged: (color) {
                        _onlineModelViewerCubit.pickerColor = color;
                      },
                      colorPickerWidth: Utility.isTablet ? MediaQuery.of(context).size.width / 2.5 : MediaQuery.of(context).size.width,
                      pickerAreaHeightPercent: orientation == Orientation.landscape ? 0.6 : 0.8,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: <Widget>[
                      if (_sideToolBarCubit.isColorAppliedToObject.trim().isNotEmpty) ...[
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(side: BorderSide(color: AColors.greyColor1), disabledForegroundColor: AColors.greyColor),
                            child: SizedBox(height: 50, child: Center(child: NormalTextWidget('Remove', color: AColors.grColorDark))),
                            onPressed: _sideToolBarCubit.isColorAppliedToObject.trim().isEmpty
                                ? null
                                : () {
                                    _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.ContextMenu.handle({ x : ${_onlineModelViewerCubit.posX} , y : ${_onlineModelViewerCubit.posY}, width : ${_onlineModelViewerCubit.width}, height : ${_onlineModelViewerCubit.height}},'removeColor')");
                                    _onlineModelViewerCubit.emitNormalWebState();
                                    Navigator.of(context).pop();
                                  },
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(side: BorderSide(color: AColors.greyColor1)),
                          child: SizedBox(height: 50, child: Center(child: NormalTextWidget(_sideToolBarCubit.isColorAppliedToObject.trim().isNotEmpty ? 'Update' : 'Apply', color: AColors.grColorDark))),
                          onPressed: () {
                            _onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.ContextMenu.handle({ x : ${_onlineModelViewerCubit.posX} , y : ${_onlineModelViewerCubit.posY}, width : ${_onlineModelViewerCubit.width}, height : ${_onlineModelViewerCubit.height}},'setColor,${_onlineModelViewerCubit.pickerColor.red},${_onlineModelViewerCubit.pickerColor.green},${_onlineModelViewerCubit.pickerColor.blue}')");
                            _onlineModelViewerCubit.emitNormalWebState();
                            _onlineModelViewerCubit.currentColor = _onlineModelViewerCubit.pickerColor;
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  double _getWidth(Orientation orientation, BuildContext context) {
    if (orientation == Orientation.landscape && Utility.isTablet) {
      return MediaQuery.of(context).size.width / 3;
    }
    return Utility.isTablet ? MediaQuery.of(context).size.width / 2.5 : MediaQuery.of(context).size.width / 1.2;
  }
}
