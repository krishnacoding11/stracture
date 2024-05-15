import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';

class AListTile extends StatelessWidget {
  final Function()? onTap;

  const AListTile(
      {Key? key, required this.title, this.onTap, this.isSelected = false})
      : super(key: key);
  final String title;
  final bool isSelected;


  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: AColors.menuSelectedColor,
      child: Container(
        alignment: Directionality.of(context) == TextDirection.rtl?Alignment.centerRight:Alignment.centerLeft,
        padding: const EdgeInsets.all(12.0),
        // margin: const EdgeInsets.only(left: 12.0),
        child: NormalTextWidget(title, fontWeight: AFontWight.regular, textAlign: TextAlign.left, color: isSelected ? AColors.iconGreyColor : AColors.textColor),
      ),
    );
  }
}

class ASearchListTile extends StatelessWidget {
  final Function()? onTap;
  final String? searchTitle;
  final String? locationPath;

  const ASearchListTile({Key? key, required this.searchTitle, required this.locationPath, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      highlightColor: AColors.menuSelectedColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          NormalTextWidget(searchTitle!, fontWeight: AFontWight.bold, fontSize: 17,textAlign: TextAlign.start,),
          const SizedBox(height: 6.0,),
          NormalTextWidget(locationPath!, fontWeight: AFontWight.medium, fontSize: 15,textAlign: TextAlign.start,),
        ],),
      ),
    );
  }
}

