import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SiteDescription extends StatelessWidget {
  final String title;
  final String description;

  const SiteDescription({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: AFontWight.semiBold,
                  fontStyle: FontStyle.normal,
                  fontSize: 15,
                  color: AColors.iconGreyColor,
                ),
                maxLines: 1,
              ),
              Expanded(
                child: Text(
                  description,
                  style: const TextStyle(
                    fontFamily: AFonts.fontFamily,
                    fontSize: 15,
                    color: AColors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
