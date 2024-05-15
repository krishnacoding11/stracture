import 'package:flutter/material.dart';

import '../../presentation/managers/color_manager.dart';
import '../../presentation/managers/font_manager.dart';
import '../normaltext.dart';

class ASidebarMenuWidget extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isSelected;
  Color? selectedColor;
  Color? iconColor;
  void Function()? onTap;

  ASidebarMenuWidget({
    Key? key,
    required this.text,
    required this.icon,
    this.isSelected = false,
    this.selectedColor,
    this.iconColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        minLeadingWidth: 10,
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        selected: isSelected,
        selectedTileColor: selectedColor ?? AColors.menuSelectedColor,
        leading: Icon(
          icon,
          color: iconColor ?? AColors.white,
          size: 24.0,
        ),
        title: NormalTextWidget(
          text,
          fontWeight: AFontWight.regular,
          fontSize: 17.0,
          color: AColors.white,
          textAlign: TextAlign.left,
        ),
        onTap: onTap,
      ),
    );
  }
}
