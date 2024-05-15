import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';

import '../presentation/managers/color_manager.dart';
import '../presentation/managers/font_manager.dart';
import '../utils/utils.dart';

OverlayEntry overlayBanner(BuildContext context, String title, String message, IconData bannerIcon, Color bannerIconColor, {bool? isCloseManually, Function? onTap}) {

  return OverlayEntry(builder: (context) {
    return Positioned(
      width: MediaQuery.of(context).size.width,
      top: 0,
      left: 0,
      child: Semantics(
      label: "OverlayBanner",
      child : Container(
        decoration: BoxDecoration(shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(5), color: AColors.white, boxShadow: [BoxShadow(color: AColors.black.withOpacity(0.25), blurRadius: 10, offset: Offset(4, 4), spreadRadius: 2)]),
        height: Utility.isTablet ?70.0:85.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 5.0,
              height: Utility.isTablet ?70.0:85.0,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
                color: bannerIconColor,
              ),
            ),
            SizedBox(width: Utility.isTablet ? 20.0 : 10.0),
            Icon(
              bannerIcon,
              size: 24,
              color: bannerIconColor,
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: Utility.isTablet ? 20.0 : 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    NormalTextWidget(
                      title,
                      color: AColors.textColor,
                      fontSize: 16,
                      textScaleFactor: 1,
                      maxLines: 2,
                      textAlign: TextAlign.left,
                      fontWeight: AFontWight.semiBold,
                    ),
                    NormalTextWidget(
                      message,
                      textAlign: TextAlign.left,
                      fontSize: 13,
                      textScaleFactor: 1,
                      fontWeight: AFontWight.regular,
                      overflow: TextOverflow.ellipsis,
                      color: AColors.textColor,
                    ),
                  ],
                ),
              ),
            ),
            isCloseManually!
                ? InkWell(
                    onTap: () => onTap!(),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Icon(
                        Icons.clear,
                        color: AColors.iconGreyColor,
                      ),
                    ))
                : Container()
          ],
        ),
      ),)
    );
  });
}
