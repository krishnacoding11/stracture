import 'package:field/presentation/screen/site_routes/site_end_drawer/filter/site_end_drawer_filter.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/dashboard/home_page_cubit.dart';
import '../../../data/model/home_page_model.dart';
import '../../../domain/use_cases/Filter/filter_usecase.dart';
import '../../../utils/utils.dart';
import '../../../widgets/normaltext.dart';
import '../../managers/color_manager.dart';
import '../../managers/font_manager.dart';

class ShortcutFormFilterDialog extends StatefulWidget {
  final Function onConfirm;
  final List<UserProjectConfigTabsDetails> addedShortcutList;
  final Map data;

  ShortcutFormFilterDialog({super.key, required this.onConfirm, required this.addedShortcutList, required this.data});

  @override
  State<ShortcutFormFilterDialog> createState() => _ShortcutFormFilterDialogState();
}

class _ShortcutFormFilterDialogState extends State<ShortcutFormFilterDialog> {
  late HomePageCubit _homePageCubit;
  late final ScrollController paginationScrollController;
  late GlobalKey filterKey;

  @override
  void initState() {
    paginationScrollController = ScrollController();
    _homePageCubit = context.read<HomePageCubit>();
    filterKey = GlobalKey();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var isTablet = context.width() > context.height();
    return Dialog(
      key: Key('filtered_view_dialog_key'),
      insetPadding: EdgeInsets.zero,
      elevation: 8,
      backgroundColor: AColors.white,
      child: Container(
        height: isTablet ? context.height() * 0.85 : context.height() * 0.65,
        width: isTablet ? context.width() * 0.6 : context.width() * 0.85,
        child: Padding(
          padding: EdgeInsets.only(top: 15, right: Utility.isTablet ? 20 : 10, bottom: Utility.isTablet ? 15 : 10, left: Utility.isTablet ? 30 : 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: Utility.isTablet ? const EdgeInsets.all(14.0) : const EdgeInsets.all(5.5),
                        decoration: BoxDecoration(
                            border: Border.all(
                              color: AColors.lightGreyColor,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(4)),
                        child: Icon(
                          color: AColors.iconGreyColor,
                          Icons.arrow_back,
                          size: Utility.isTablet ? 20 : 18,
                        ),
                      ),
                    ),
                    Expanded(
                        child: NormalTextWidget(
                      color: AColors.black,
                      context.toLocale!.lbl_filtered_view,
                      fontSize: Utility.isTablet ? 22 : 20,
                      fontWeight: AFontWight.semiBold,
                      textAlign: TextAlign.center,
                      //style: TextStyle(a),
                    )),
                  ],
                ),
              ),
              Expanded(
                  child: Padding(
                padding: Utility.isTablet ? const EdgeInsets.fromLTRB(30, 5, 5, 5) : const EdgeInsets.all(0),
                child: SiteEndDrawerFilter(
                  curScreen: FilterScreen.screenHome,
                  key: filterKey,
                  animationScrollController: paginationScrollController,
                  onClose: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  onApply: onApplyFilter,
                  data: widget.data,
                ),
              ))
            ],
          ),
        ),
      ),
    );
  }

  onApplyFilter(data) {
    UserProjectConfigTabsDetails newFilterShortCut = UserProjectConfigTabsDetails.fromJson(data);
    widget.addedShortcutList.add(newFilterShortCut);
    widget.onConfirm(widget.addedShortcutList);
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
