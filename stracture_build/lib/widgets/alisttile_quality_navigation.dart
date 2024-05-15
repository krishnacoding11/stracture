import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';


class AListTileQualityNavigation extends StatelessWidget {
  final String title;
  final bool isSelected;
  final bool hasLocation;
  final num percentage;
  final Function()? onTap;

  const AListTileQualityNavigation(
      {Key? key, required this.title, this.percentage = 0, this.onTap, this.isSelected = false, this.hasLocation = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:Utility.isTablet ? const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0) : const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: ClipPath(
        clipper: ShapeBorderClipper(shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4))),
        child: Container(
            color: hasLocation ? AColors.locationBgColor : AColors.white,
            child: Column(
              children: [
                InkWell(
                  onTap: onTap,
                  highlightColor: AColors.menuSelectedColor,
                  child: Padding(
                    padding: Utility.isTablet?const EdgeInsetsDirectional.fromSTEB(8.0, 16.0, 16.0, 16.0) : const EdgeInsetsDirectional.fromSTEB(6.0, 12.0, 12.0, 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              hasLocation ? Icon(Icons.arrow_forward_ios_rounded, color: AColors.iconGreyColor, size: Utility.isTablet?17:13) : Icon(Icons.playlist_add_check_outlined, color: AColors.iconGreyColor, size: 22),
                              Flexible(
                                child: Container(
                                  color: isSelected ? AColors.listItemSelected : Colors.transparent,
                                  padding: const EdgeInsets.all(8.0),
                                  margin: const EdgeInsetsDirectional.only(start: 4.0),
                                  alignment: Directionality.of(context) == TextDirection.rtl?Alignment.centerRight:Alignment.centerLeft,
                                  child: NormalTextWidget(title,
                                      fontWeight: AFontWight.regular,
                                      textAlign: TextAlign.left,
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      color: isSelected ? AColors.iconGreyColor : AColors.textColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 12.0, 8.0),
                              child: NormalTextWidget(percentage.toString() + '%',color: AColors.iconGreyColor,fontWeight: AFontWight.regular,fontSize: 13,),
                            ),
                            ACircularProgress(color : AColors.lightGreenColor, strokeWidth: 7, progressValue: percentage/100, backgroundColor: AColors.progressBarBgColor),
                          ],)
                      ],
                    ),
                  ),
                ),
                hasLocation ? Container() : Divider(
                  color: AColors.dividerColor,
                  thickness: 1.0,
                  height: 1.0),
              ],
            ),
        ),
      )
    );
  }
}



class AQualityNavigationItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Function()? onTap;

  const AQualityNavigationItem(
      {Key? key, required this.title, this.onTap, this.isSelected = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: this.isSelected ? null : onTap,
      highlightColor: AColors.menuSelectedColor,
      child: NormalTextWidget(title,
          fontWeight: AFontWight.regular,
          textAlign: TextAlign.left,
          color: isSelected ? AColors.iconGreyColor : AColors.textColor
      ),
    );
  }
}
