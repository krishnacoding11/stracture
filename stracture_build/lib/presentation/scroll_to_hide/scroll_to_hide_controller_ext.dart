import 'package:flutter/widgets.dart';

import 'scroll_to_hide_controller.dart';

extension ScrollToHideControllerExt on ScrollController {
  static final controllerMap = <int, ScrollToHideController>{};

  ScrollToHideController getController(size) {
    if (controllerMap.containsKey(hashCode)) {
      return controllerMap[hashCode]!;
    }

    return controllerMap[hashCode] = ScrollToHideController(
      scrollController: this,
      size: size,
    );
  }
}