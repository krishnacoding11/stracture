import 'package:flutter/widgets.dart';

class ABottomNavigationItem extends BottomNavigationBarItem {
  final Key? key;

  ABottomNavigationItem({
    this.key,
    required super.icon,
    super.label,
    super.activeIcon,
    super.backgroundColor,
    super.tooltip,
  });
}
