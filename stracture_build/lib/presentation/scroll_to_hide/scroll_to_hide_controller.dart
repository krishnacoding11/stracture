import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ScrollToHideController {
  ScrollController scrollController;

  double size;

  ScrollToHideController({
    required this.scrollController,
    required this.size,
  }) {
    scrollController.addListener(listener);
  }

  double li = 0.0, lastOffset = 0.0;

  final sizeNotifier = ValueNotifier<double>(1.0);

  final stickinessNotifier = ValueNotifier<bool>(false);

  void setStickinessState(bool state) => stickinessNotifier.value = state;

  double sizeFactor() => 1.0 - (li / size);

  void listener() {
    final p = scrollController.position;

    li = (li + p.pixels - lastOffset).clamp(0.0, size);
    lastOffset = p.pixels;

    if (p.axisDirection == AxisDirection.down && p.extentAfter == 0.0) {
      if (sizeNotifier.value == 0.0) return;

      sizeNotifier.value = 0.0;
      return;
    }

    if (p.axisDirection == AxisDirection.up && p.extentBefore == 0.0) {
      if (sizeNotifier.value == 1.0) return;

      sizeNotifier.value = 1.0;
      return;
    }

    sizeNotifier.value = sizeFactor();
  }

  void close() {
    stickinessNotifier.dispose();
    sizeNotifier.dispose();
  }
}