import 'package:field/presentation/scroll_to_hide/scroll_to_hide_controller.dart';
import 'package:field/presentation/scroll_to_hide/scroll_to_hide_controller_ext.dart';
import 'package:flutter/material.dart';

import '../../bloc/navigation/navigation_cubit.dart';
import '../../injection_container.dart';

enum AnimationType { UP, DOWN }

class ScrollToHideWidget extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final ScrollController controller;
  final bool enableOpacity;
  final Size preferredWidgetSize;
  final AnimationType animationType;

  const ScrollToHideWidget({
    Key? key,
    required this.child,
    required this.controller,
    this.enableOpacity = false,
    this.animationType = AnimationType.UP,
    this.preferredWidgetSize = const Size.fromHeight(kToolbarHeight),
  }) : super(key: key);

  @override
  Size get preferredSize => preferredWidgetSize;

  @override
  Widget build(BuildContext context) {
    final hidableController = controller.getController(preferredWidgetSize.height);

    return ValueListenableBuilder<bool>(
      valueListenable: hidableController.stickinessNotifier,
      builder: (_, isStickinessEnabled, __) {
        return ValueListenableBuilder<double>(
          valueListenable: hidableController.sizeNotifier,
          builder: (_, height, __) => widgetToHideOnScroll(height, hidableController),
        );
      },
    );
  }

  Widget widgetToHideOnScroll(double factor, ScrollToHideController hidableController) {
    return Align(
      heightFactor: getIt<NavigationCubit>().currSelectedItem == NavigationMenuItemType.models ? 1 : factor,
      alignment: animationType == AnimationType.UP ? const Alignment(0, 1) : const Alignment(0, -2),
      child: SizedBox(
        height: hidableController.size,
        child: enableOpacity
            ? Wrap(
                children: [
                  Opacity(opacity: getIt<NavigationCubit>().currSelectedItem == NavigationMenuItemType.models ? 1 : factor, child: child),
                ],
              )
            : child,
      ),
    );
  }
}
