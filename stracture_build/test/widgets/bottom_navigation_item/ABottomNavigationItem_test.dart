import 'package:field/widgets/bottom_navigation_item/ABottomNavigationItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  test('ABottomNavigationItem properties', () {
    final icon = Icon(Icons.home);
    final activeIcon = Icon(Icons.home_filled);
    final label = 'Home';
    final backgroundColor = Colors.blue;
    final tooltip = 'Navigate to Home';

    final aBottomNavItem = ABottomNavigationItem(
      icon: icon,
      label: label,
      activeIcon: activeIcon,
      backgroundColor: backgroundColor,
      tooltip: tooltip,
    );

    expect(aBottomNavItem.icon, equals(icon));
    expect(aBottomNavItem.label, equals(label));
    expect(aBottomNavItem.activeIcon, equals(activeIcon));
    expect(aBottomNavItem.backgroundColor, equals(backgroundColor));
    expect(aBottomNavItem.tooltip, equals(tooltip));
  });
}

