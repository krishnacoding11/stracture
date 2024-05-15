import 'package:flutter/material.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
//ignore: must_be_immutable
class TooltipDialog extends StatefulWidget {
   TooltipDialog(
      {Key? key,
      required this.child,
      required this.toolTipContent,
      required this.toolTipController,
      this.color,
      this.onDismiss,
      this.tailLength})
      : super(key: key);
  final Widget child;
  final Widget toolTipContent;
  final TooltipController toolTipController;
  final Color? color;
  final VoidCallback? onDismiss;
  double? tailLength;

  @override
  State<TooltipDialog> createState() => _TooltipDialogState();
}

class _TooltipDialogState extends State<TooltipDialog>
    with WidgetsBindingObserver {
  var key = GlobalKey();
  double? orientationHeight;

  @override
  void didChangeMetrics() {
    if (orientationHeight !=
        WidgetsBinding.instance.window.physicalSize.height) {
      if (widget.toolTipController.getTooltipStatus() ==
          TooltipStatus.isShowing) {
        key = GlobalKey();
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          widget.toolTipController.showTooltipDialog();
        });
        orientationHeight = WidgetsBinding.instance.window.physicalSize.height;
        //Use setstate to maintain position of tooltip.
        setState(() {});
      }
    }
    super.didChangeMetrics();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      orientationHeight = WidgetsBinding.instance.window.physicalSize.height;
    });
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return JustTheTooltip(
      key: key,
      isModal: true,
      preferredDirection: AxisDirection.down,
      borderRadius: BorderRadius.circular(16),
      controller: widget.toolTipController.justTheController,
      content: widget.toolTipContent,
      onDismiss: widget.onDismiss,
      tailLength: widget.tailLength ?? 16.0,
      child: widget.child,
    );
  }

}

class TooltipController {
  JustTheController justTheController = JustTheController();

  void showTooltipDialog() {
   justTheController.showTooltip();
  }

  TooltipStatus getTooltipStatus() {
    return justTheController.value;
  }

  void hideTooltipDialog() {
    if (justTheController.value == TooltipStatus.isShowing) {
      justTheController.hideTooltip();
    }
  }
}
