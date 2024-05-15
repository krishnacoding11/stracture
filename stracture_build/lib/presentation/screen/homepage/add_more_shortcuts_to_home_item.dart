import 'package:field/data/model/home_page_model.dart';
import 'package:field/enums.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';

import '../../managers/image_constant.dart';

class AddMoreShortcutsToHomeItem extends StatefulWidget {
  final UserProjectConfigTabsDetails item;
  final Function onPressed;

  const AddMoreShortcutsToHomeItem({Key? key, required this.item, required this.onPressed}) : super(key: key);

  @override
  State<AddMoreShortcutsToHomeItem> createState() => _AddMoreShortcutsToHomeItemState();
}

class _AddMoreShortcutsToHomeItemState extends State<AddMoreShortcutsToHomeItem> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = context.width();
    double deviceHeight = context.height();
    bool isTablet = deviceHeight < deviceWidth;
    return Stack(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  top: 10,
                  right: 10,
                ),
                child: Card(
                  //margin: isTablet ? EdgeInsets.symmetric(vertical: 15, horizontal: 5) : EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    key: Key("AddMoreToHomeItem ${widget.item.id}"),
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      widget.onPressed(widget.item);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: Utility.isTablet ? 10 : 6),
                      child: Column(
                        mainAxisAlignment: isTablet ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Flexible(flex: 1, child: Align(alignment: Alignment.bottomCenter, child: addToMoreItemImage())),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.loose,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: NormalTextWidget(
                                  widget.item.name ?? "",
                                  color: AColors.black,
                                  fontWeight: FontWeight.w500,
                                  maxLines: 2,
                                  fontSize: Utility.isTablet ? 16 : 14,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              widget.onPressed(widget.item);
            },
            child: Visibility(
              visible: widget.item.id != HomePageIconCategory.filter.value,
              child: widget.item.isAdded
                  ? Icon(
                      Icons.check_circle,
                      color: AColors.themeBlueColor,
                      size: 26,
                    )
                  : Container(
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AColors.themeBlueColor, width: 1)),
                      padding: (Utility.isTablet) ? const EdgeInsets.all(1.0) : const EdgeInsets.all(0.0),
                      child: Icon(
                        Icons.add,
                        color: AColors.themeBlueColor,
                        size: 22,
                      ),
                    ),
            ),
          ),
        )
      ],
    );
  }

  Widget addToMoreItemImage() {
    final homePageSortCutCategory = HomePageIconCategory.fromString(widget.item.id!);
    double iconsSize = Utility.isTablet ? 63.0 : 40.0;
    switch (homePageSortCutCategory) {
      case HomePageIconCategory.newTasks:
        return Icon(
          HomePageIconCategory.fromString(widget.item.id!).icon,
          color: AColors.newTasks,
          size: iconsSize,
        );
      case HomePageIconCategory.taskDueToday:
        return Icon(
          HomePageIconCategory.fromString(widget.item.id!).icon,
          color: AColors.tasksDueToday,
          size: iconsSize,
        );
      case HomePageIconCategory.taskDueThisWeek:
        return Icon(
          HomePageIconCategory.fromString(widget.item.id!).icon,
          color: AColors.taskDueThisWeek,
          size: iconsSize,
        );
      case HomePageIconCategory.overDueTasks:
        return Icon(
          HomePageIconCategory.fromString(widget.item.id!).icon,
          color: AColors.taskOverDue,
          size: iconsSize,
        );
      case HomePageIconCategory.jumpBackToSite:
        return Image.asset(AImageConstants.jumpBackIntoSite);
      case HomePageIconCategory.createForm:
      case HomePageIconCategory.createSiteForm:
      case HomePageIconCategory.filter:
        return Image.asset(
          getConfigImage(widget.item),
        );
      case HomePageIconCategory.createNewTask:
      default:
        return Icon(
          HomePageIconCategory.fromString(widget.item.id!).icon,
          color: AColors.themeBlueColor,
          size: iconsSize,
        );
    }
  }

  String getConfigImage(UserProjectConfigTabsDetails userProjectConfigTabsDetails) {
    Map<String, dynamic> map = {HomePageSortCutCategory.createForm.value: AImageConstants.formOutline, HomePageSortCutCategory.filter.value: AImageConstants.filterImage, HomePageSortCutCategory.createSiteForm.value: AImageConstants.createSiteForm};
    return map[userProjectConfigTabsDetails.id!] ?? AImageConstants.formOutline;
  }
}
