import 'package:field/bloc/dashboard/home_page_cubit.dart';
import 'package:field/data/model/home_page_model.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/screen/homepage/add_more_shortcuts_to_home_item.dart';
import 'package:field/presentation/screen/homepage/shortcut_form_filter_dialog_widget.dart';
import 'package:field/presentation/screen/site_routes/site_end_drawer/search_task.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/dashboard/home_page_state.dart';
import '../../../enums.dart';
import '../../../utils/constants.dart';
import '../../../widgets/elevatedbutton.dart';

class AddMoreToHomeScreen extends StatefulWidget {
  final List<UserProjectConfigTabsDetails>? pendingShortCutList;
  final Function onConfirm;

  const AddMoreToHomeScreen({Key? key, required this.pendingShortCutList, required this.onConfirm}) : super(key: key);

  @override
  State<AddMoreToHomeScreen> createState() => _AddMoreToHomeScreenState();
}

class _AddMoreToHomeScreenState extends State<AddMoreToHomeScreen> {
  late bool isTablet;
  List<UserProjectConfigTabsDetails>? searchTempList;
  late HomePageCubit _homePageCubit;
  final searchKey = GlobalKey();

  @override
  void initState() {
    _homePageCubit = context.read<HomePageCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    isTablet = context.width() > context.height();
    return Dialog(
      key: Key("Add More To Home Dialog"),
      elevation: 12,
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.zero,
      child: Container(
        height: isTablet ? context.height() * 0.85 : context.height() * 0.65,
        width: isTablet ? context.width() * 0.6 : context.width() * 0.85,
        child: Padding(
          padding: EdgeInsets.only(top: 15, right: Utility.isTablet ? 20 : 10, bottom: Utility.isTablet ? 15 : 10, left: Utility.isTablet ? 30 : 10),
          child: Column(
            children: [
              Container(
                height: isTablet
                    ? context.height() * 0.08
                    : context.height() > 600
                        ? context.height() * 0.1
                        : context.height() * 0.15,
                child: _getTitleAndSearchWidget(),
              ),
              const SizedBox(
                height: 18,
              ),
              Expanded(
                  child: BlocBuilder<HomePageCubit, FlowState>(
                      buildWhen: (prev, current) => current is PendingShortcutItemState || current is AddMoreSearchState || current is ItemToggleState,
                      builder: (context, state) {
                        if (state is AddMoreSearchState && state.searchShortCutList!.isEmpty) {
                          return Center(
                            child: NormalTextWidget(
                              context.toLocale!.no_matches_found,
                              key: Key("No Matches Found"),
                            ),
                          );
                        } else if (state is AddMoreSearchState || state is PendingShortcutItemState || state is ItemToggleState) {
                          List<UserProjectConfigTabsDetails> shortCutList = [];
                          if (state is AddMoreSearchState) {
                            shortCutList.addAll(state.searchShortCutList!);
                          } else if (state is PendingShortcutItemState) {
                            shortCutList.addAll(state.pendingShortCutList!);
                          } else if (state is ItemToggleState) {
                            shortCutList.addAll(state.pendingShortCutList!);
                          }
                          return getGridViewWidget(shortCutList);
                        }
                        return Container();
                      })),
              const SizedBox(
                height: 15,
              ),
              getSaveAndExitButton()
            ],
          ),
        ),
      ),
    );
  }

  Widget getTitleWidget() {
    return Flexible(
      flex: 1,
      child: NormalTextWidget(
        context.toLocale!.lbl_add_more_to_home,
        fontSize: 22,
        fontWeight: AFontWight.semiBold,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textScaleFactor: 1,
      ),
    );
  }

  Widget getSearchWidget() {
    return Flexible(
      flex: 2,
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: SearchTask(
          key: searchKey,
          textLimitLength: 25,
          setInitialOptionsValue: (List<String> options) {
            searchTempList = [...widget.pendingShortCutList!];
          },
          onSearchChanged: (searchValue, isFromCloseButton) {
            if (searchValue.toString().isNullOrEmpty()) {
              _homePageCubit.emitAddMoreSearchState(widget.pendingShortCutList);
            } else {
              searchTempList = widget.pendingShortCutList?.where((element) => (element.name!.toLowerCase().contains(searchValue.toString().toLowerCase()))).toList();
              _homePageCubit.emitAddMoreSearchState(searchTempList);
            }
          },
          placeholder: context.toLocale!.text_search_for,
        ),
      ),
    );
  }

  Widget getGridViewWidget(List<UserProjectConfigTabsDetails> shortCutList) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      int crossAxisCount = constraints.maxWidth ~/ (Utility.isTablet ? 130 : 100);
      if (crossAxisCount <= 2) {
        crossAxisCount = 3;
      }
      return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount, childAspectRatio: 1, mainAxisSpacing: Utility.isTablet ? 10 : 0, crossAxisSpacing: 0),
          itemCount: shortCutList.length,
          physics: ClampingScrollPhysics(),
          itemBuilder: (_, index) {
            UserProjectConfigTabsDetails item = shortCutList[index];
            return LayoutBuilder(builder: (context, box) {
              return AddMoreShortcutsToHomeItem(
                  key: Key("AddMoreGridViewItem $index"),
                  item: item,
                  onPressed: (item) {
                    if (item.id == HomePageIconCategory.filter.value) {
                      List<UserProjectConfigTabsDetails> addedShortcutList = getAddedShortcutList();
                      showFilterView(widget.onConfirm, addedShortcutList, {
                        "initialFilterName": AConstants.filterFormInitialValue,
                      });
                    } else {
                      _homePageCubit.handleOnTapAddMoreShortcutItem(shortCutList, item);
                    }
                  });
            });
          });
    });
  }

  Widget getSaveAndExitButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AElevatedButtonWidget(
            fontSize: isTablet ? 18 : 14,
            height: isTablet ? 40 : 35,
            width: isTablet ? 70 : 55,
            btnLabel: context.toLocale!.lbl_exit,
            letterSpacing: -1,
            fontWeight: AFontWight.semiBold,
            btnLabelClr: AColors.themeBlueColor,
            btnBackgroundClr: AColors.white,
            btnBorderClr: AColors.themeBlueColor,
            onPressed: () {
              Navigator.of(context).pop();
            }),
        const SizedBox(
          width: 15,
        ),
        BlocBuilder<HomePageCubit, FlowState>(buildWhen: (prev, current) {
          return current is ItemToggleState;
        }, builder: (context, state) {
          List<UserProjectConfigTabsDetails> addedShortcutList = getAddedShortcutList();
          bool isNeedToEnableConfirmButton = addedShortcutList.length > 0;
          return AElevatedButtonWidget(
              fontSize: isTablet ? 18 : 14,
              height: isTablet ? 40 : 35,
              width: 110,
              letterSpacing: -1,
              btnLabel: context.toLocale!.lbl_confirm_shortcut,
              fontWeight: AFontWight.semiBold,
              btnLabelClr: isNeedToEnableConfirmButton ? AColors.white : AColors.lightGreyColor,
              btnBackgroundClr: isNeedToEnableConfirmButton ? AColors.themeBlueColor : AColors.btnDisableClr,
              onPressed: isNeedToEnableConfirmButton
                  ? () {
                      List<UserProjectConfigTabsDetails> addedShortcutList = getAddedShortcutList();
                      widget.onConfirm(addedShortcutList);
                      Navigator.of(context).pop();
                    }
                  : null);
        }),
      ],
    );
  }

  Widget _getTitleAndSearchWidget() {
    if (isTablet) {
      return Row(
        children: [
          getTitleWidget(),
          const SizedBox(
            width: 25,
          ),
          getSearchWidget()
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        getTitleWidget(),
        const SizedBox(
          height: 12,
        ),
        getSearchWidget()
      ],
    );
  }

  showFilterView(Function onConfirm, List<UserProjectConfigTabsDetails> addedShortcutList, Map data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BlocProvider.value(
            value: _homePageCubit,
            child: ShortcutFormFilterDialog(onConfirm: onConfirm, addedShortcutList: addedShortcutList, data: data));
      },
    );
  }

  List<UserProjectConfigTabsDetails> getAddedShortcutList() {
    return widget.pendingShortCutList!.where((element) => (element.isAdded == true)).toList();
  }
}
