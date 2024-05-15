import 'package:field/bloc/cBim_settings/cBim_settings_cubit.dart';
import 'package:field/bloc/cBim_settings/cBim_settings_state.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart';
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/sidebar/sidebar_divider_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CBimSettingsDialog extends StatefulWidget {
  const CBimSettingsDialog({Key? key}) : super(key: key);

  @override
  State<CBimSettingsDialog> createState() => _CBimSettingsDialogState();
}

class _CBimSettingsDialogState extends State<CBimSettingsDialog> {
  CBIMSettingsCubit _cBimSettingsCubit = getIt<CBIMSettingsCubit>();

  @override
  void initState() {
    _cBimSettingsCubit.initCBIMSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnlineModelViewerCubit, OnlineModelViewerState>(builder: (context, state) {
      return OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          return Dialog(
            child: Container(
              width: Utility.isTablet
                  ? orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.width / 1.3
                      : MediaQuery.of(context).size.width / 1.8
                  : MediaQuery.of(context).size.width,
              key: Key("cBimSettingDialog_padding_1"),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                key: Key("cBimSettingDialog_Column_1"),
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    key: Key("cBimSettingDialog_row_1"),
                    children: <Widget>[
                      SizedBox(
                        width: (IconTheme.of(context).size! + 16),
                      ),
                      Expanded(
                        key: Key("cBimSettingDialog_expanded_1"),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: NormalTextWidget(
                            context.toLocale!.lbl_models_settings,
                            fontSize: 20,
                            fontWeight: AFontWight.semiBold,
                          ),
                        ),
                      ),
                      IconButton(
                          key: Key("cBimSettingDialog_iconButton"),
                          onPressed: () {
                            getIt<OnlineModelViewerCubit>().emitNormalWebState();
                            String deviceType = Utility.isTablet ? "Tablet" : "Mobile";
                            if (orientation == Orientation.portrait) {
                              getIt<OnlineModelViewerCubit>().webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '${Orientation.portrait}', view : ${getIt<OnlineModelViewerCubit>().isShowPdfView ? "'3D/2D'" : "'3D'"},device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
                            } else {
                              getIt<OnlineModelViewerCubit>().webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '${Orientation.landscape}', view : ${getIt<OnlineModelViewerCubit>().isShowPdfView ? "'3D/2D'" : "'3D'"},device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
                            }
                            getIt<SideToolBarCubit>().isWhite = false;
                            getIt<OnlineModelViewerCubit>().isShowPdfView = false;
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close))
                    ],
                  ),
                  ADividerWidget(
                    thickness: 1,
                    color: AColors.lightGreyColor,
                  ),
                  cBIMSettingListItem()
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget cBIMSettingListItem() {
    return Container(
      key: Key("cBimSettingDialog_cBIMSettingListItem"),
      padding: const EdgeInsets.only(top: 16, left: 16, bottom: 16),
      child: !Utility.isTablet ? SizedBox(height: 60, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: tile)) : Row(mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: tile),
    );
  }

  List<Widget> get tile => [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              AImageConstants.cameraControl,
              scale: .8,
            ),
            const SizedBox(width: 16),
            NormalTextWidget(
              context.toLocale!.lbl_navigation_speed,
              fontWeight: AFontWight.semiBold,
              fontSize: 19,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SizedBox(width: 16),
        Expanded(
          child: BlocBuilder<CBIMSettingsCubit, CBIMSettingsState>(
            builder: (context, state) {
              return SliderTheme(
                data: SliderThemeData(
                  tickMarkShape: LineSliderTickMarkShape(),
                  thumbShape: ValueDisplaySliderThumb(
                    value: _cBimSettingsCubit.selectedSliderValue,
                    color: AColors.themeBlueColor,
                  ),
                  inactiveTickMarkColor: Colors.white,
                  // Custom SliderThumbShape
                  trackHeight: 10.0,
                  activeTrackColor: AColors.lightGreyColor,
                  inactiveTrackColor: AColors.lightGreyColor,
                ),
                child: Slider(
                    divisions: 9,
                    min: _cBimSettingsCubit.min,
                    max: _cBimSettingsCubit.max,
                    value: _cBimSettingsCubit.selectedSliderValue,
                    onChanged: (newValue) {
                      _cBimSettingsCubit.onSliderChange(newValue);
                      getIt<OnlineModelViewerCubit>().setNavigationSpeed(newValue: newValue);
                    }),
              );
            },
          ),
        )
      ];
}

class LineSliderTickMarkShape extends SliderTickMarkShape {
  const LineSliderTickMarkShape({
    this.tickMarkRadius,
  });

  final double? tickMarkRadius;

  @override
  Size getPreferredSize({
    required SliderThemeData sliderTheme,
    required bool isEnabled,
  }) {
    return Size.fromRadius(tickMarkRadius ?? sliderTheme.trackHeight! / 4);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    required bool isEnabled,
  }) {
    final Paint paint = Paint()
      ..color = Colors.white // Adjust the color of the tick marks.
      ..strokeWidth = .7
      ..strokeCap = StrokeCap.round;

    final double tickHeight = 8.0; // Adjust the height of the tick mark.

    context.canvas.drawLine(
      center.translate(0, -tickHeight / 2),
      center.translate(0, tickHeight / 2),
      paint,
    );
  }
}

class ValueDisplaySliderThumb extends SliderComponentShape {
  final double thumbRadius;
  final Color color;
  final double value;

  ValueDisplaySliderThumb({
    this.thumbRadius = 18.0,
    this.color = Colors.blue,
    required this.value,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double>? activationAnimation,
    Animation<double>? enableAnimation,
    bool? isDiscrete,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    SliderThemeData? sliderTheme,
    TextDirection? textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    TextSpan span = new TextSpan(
      style: TextStyle(
        fontSize: thumbRadius,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      text: '${this.value.toInt()}',
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    tp.layout();
    Offset textCenter = center - Offset(tp.width / 2, tp.height / 2);

    canvas.drawCircle(center, thumbRadius, paint);
    tp.paint(canvas, textCenter);
  }
}
