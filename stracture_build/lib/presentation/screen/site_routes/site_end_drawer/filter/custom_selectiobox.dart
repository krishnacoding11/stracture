import 'package:flutter/material.dart';

import '../../../../managers/color_manager.dart';

class CustomFiledSectionBox extends StatelessWidget {
  final String textLabel, hintText;
  const CustomFiledSectionBox(
      {super.key, required this.textLabel, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          textLabel,
          textAlign: TextAlign.start,
          style: const TextStyle(fontSize: 16, color: AColors.black),
        ),
        const SizedBox(height: 10),
        Container(
          height: 45,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(width: 1.5, color: AColors.dividerColor)),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: Row(
              children: [
                Text(
                  hintText,
                  style: TextStyle(fontSize: 14, color: AColors.iconGreyColor),
                ),
                const Spacer(),
                Icon(
                  Icons.add,
                  color: AColors.iconGreyColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
