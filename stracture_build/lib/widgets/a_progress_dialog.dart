import 'dart:ui';

import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';

/// Progress Dialog
class AProgressDialog {
  /// BuildContext to show dialog in
  final BuildContext context;

  /// Main widget of dialog,
  final Widget? loadingWidget;

  /// Whether dialog can dismiss by touching outside or not
  final bool? dismissable;

  /// This function will trigger when user dismisses dialog
  final Function? onDismiss;

  /// Amount of background blur
  final double blur;

  /// Dialog's background color
  final Color backgroundColor;

  /// Using safe area, dialog will keep padding from status bar, navigation bar and ...
  final bool useSafeArea;

  /// Duration of blur and background color animation
  final Duration animationDuration;

  /// Is dialog showing or not
  bool _isShowing = false;

  // Is Animation with custom icon required or not
  bool isAnimationRequired = false;

  /// Dialog widget instance
  _AProgressDialogWidget? _progressDialogWidget;

  /// back button disable if true
  bool isWillPopScope = false;

  /// Getter for _isShowing
  bool get isShowing => _isShowing;

  AProgressDialog(
    this.context, {
    this.backgroundColor = const Color(0x99000000),
    this.blur = 0,
    this.dismissable = true,
    this.isAnimationRequired = true,
    this.onDismiss,
    this.loadingWidget,
    this.useSafeArea = false,
    this.animationDuration = const Duration(milliseconds: 300),
        this.isWillPopScope = false
  }) {
    _initProgress();
  }

  /// Initialize dialog's instance
  void _initProgress() {
    _progressDialogWidget = _AProgressDialogWidget(
      blur: blur,
      dismissable: dismissable ?? true,
      backgroundColor: isAnimationRequired?Colors.transparent:backgroundColor,
      onDismiss: onDismiss,
      isAnimationRequired: isAnimationRequired,
      loadingWidget: loadingWidget,
      animationDuration: animationDuration,
    );
  }

  /// Show progress dialog
  void show() async {
    if (!_isShowing) {
      _isShowing = true;
      if (_progressDialogWidget == null) _initProgress();
      await showDialog(
        useSafeArea: useSafeArea,
        context: context,
        barrierDismissible: dismissable ?? true,
        builder: (context) {
          return isWillPopScope == true ? WillPopScope(onWillPop: () async => false, child:_progressDialogWidget!) : _progressDialogWidget!;
          },
        barrierColor: Colors.transparent,
      );
      _isShowing = false;
    }
  }

  /// Dismiss progress dialog
  void dismiss() {
    if (_isShowing) {
      _isShowing = false;
      Navigator.of(context,rootNavigator: true).pop();
    }
  }
}

// ignore: must_be_immutable
class _AProgressDialogWidget extends StatefulWidget {
  /// Main widget of dialog,
  Widget? loadingWidget;

  /// This function will trigger when user dismisses dialog
  final Function? onDismiss;

  /// Amount of background blur
  final double? blur;

  /// Dialog's background color
  final Color backgroundColor;

  /// Whether dialog can dismiss by touching outside or not
  final bool? dismissable;

  // Whether to add custom icon with animation required or not
  final bool? isAnimationRequired;

  /// Duration of blur and background color animation
  final Duration animationDuration;

  _AProgressDialogWidget({
    this.dismissable,
    this.onDismiss,
    required this.backgroundColor,
    this.loadingWidget,
    this.isAnimationRequired,
    this.blur,
    this.animationDuration = const Duration(milliseconds: 300),
  }) {
    loadingWidget = loadingWidget ??
        Container(
          padding: const EdgeInsets.all(10.0),
          height: 100.0,
          width: 100.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: const ACircularProgress(),
        );
  }

  @override
  State<_AProgressDialogWidget> createState() => _AProgressDialogWidgetState();
}

class _AProgressDialogWidgetState extends State<_AProgressDialogWidget>
    with TickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isAnimationRequired == true) {
      widget.loadingWidget = const ACircularProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _DialogBackground(
      blur: widget.blur,
      dismissable: widget.dismissable ?? true,
      onDismiss: widget.onDismiss,
      color: widget.backgroundColor,
      animationDuration: widget.animationDuration,
      dialog: Padding(
        padding: MediaQuery.of(context).viewInsets +
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Center(
          child: widget.loadingWidget,
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class _DialogBackground extends StatelessWidget {
  /// Widget of dialog, you can use NDialog, Dialog, AlertDialog or Custom your own Dialog
  final Widget? dialog;

  /// Because blur dialog cover the barrier, you have to declare here
  final bool? dismissable;

  /// Action before dialog dismissed
  final Function? onDismiss;

  /// Creates an background filter that applies a Gaussian blur.
  /// Default = 0
  final double? blur;

  /// Background color
  final Color color;

  /// Animation Duration
  final Duration animationDuration;

  /// Color Opacity
  double _colorOpacity = 0.0;

  _DialogBackground(
      {this.dialog,
      this.dismissable,
      this.blur,
      this.onDismiss,
      this.animationDuration = const Duration(milliseconds: 300),
      required this.color}) {
    _colorOpacity = color.opacity;
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: animationDuration,
        builder: (context, val, child) {
          return Material(
            type: MaterialType.canvas,
            color: color.withOpacity(_colorOpacity),
            child: WillPopScope(
              onWillPop: () async {
                if (dismissable ?? true) {
                  if (onDismiss != null) onDismiss!();
                  Navigator.pop(context);
                }
                return true;
              },
              child: Stack(
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                children: <Widget>[
                  GestureDetector(
                      onTap: dismissable ?? true
                          ? () {
                              if (onDismiss != null) {
                                onDismiss!();
                              }
                              Navigator.pop(context);
                            }
                          : () {},
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: blur ?? 0,
                          sigmaY: blur ?? 0,
                        ),
                        child: Container(
                          color: Colors.transparent,
                        ),
                      )),
                  dialog!
                ],
              ),
            ),
          );
        });
  }
}
