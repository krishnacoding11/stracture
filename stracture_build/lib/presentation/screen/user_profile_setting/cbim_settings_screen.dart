import 'package:field/bloc/cBim_settings/cBim_settings_cubit.dart';
import 'package:field/bloc/cBim_settings/cBim_settings_state.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../analytics/event_analytics.dart';

class CBimSettingsScreen extends StatefulWidget {
  const CBimSettingsScreen({Key? key}) : super(key: key);

  @override
  State<CBimSettingsScreen> createState() => _CBimSettingsScreenState();
}

class _CBimSettingsScreenState extends State<CBimSettingsScreen> {
  CBIMSettingsCubit _cBimSettingsCubit = getIt<CBIMSettingsCubit>();

  @override
  void initState() {
    _cBimSettingsCubit.initCBIMSettings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: Key("cBimSettingsScreen_padding_1"),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NormalTextWidget(
            context.toLocale!.lbl_models_settings,
            fontSize: 18,
            fontWeight: AFontWight.semiBold,
          ),
          SizedBox(
            height: 20,
          ),
          cBIMSettingListItem()
        ],
      ),
    );
  }

  Widget cBIMSettingListItem() {
    return Container(
      key: Key("cBimSettingsScreen_cBIMSettingListItem"),
      padding: const EdgeInsets.only(top: 4, left: 16),
      child: !Utility.isTablet
          ? SizedBox(
              height: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: tile,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: tile,
            ),
    );
  }

  List<Widget> get tile => [
        Expanded(
          child: NormalTextWidget(
            context.toLocale!.lbl_navigation_speed,
            fontWeight: AFontWight.medium,
            fontSize: 18,
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
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
                    FireBaseEventAnalytics.setEvent(
                        FireBaseEventType.settingNavigationSensitiveChanged,
                        FireBaseFromScreen.settingModelSetting,
                        bIncludeProjectName: true);
                    getIt<OnlineModelViewerCubit>().setNavigationSpeed(newValue: newValue);
                  },
                ),
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
