import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:field/injection_container.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/Filter/filter_cubit.dart';
import '../../bloc/Filter/filter_state.dart';
import '../../bloc/online_model_viewer/task_form_list_cubit.dart';
import '../../data/model/task_form_listing_reponse.dart';
import '../../domain/use_cases/Filter/filter_usecase.dart';
import '../../presentation/base/state_renderer/state_render_impl.dart';
import '../../presentation/managers/color_manager.dart';
import '../../presentation/managers/font_manager.dart';
import '../../presentation/managers/image_constant.dart';
import '../../presentation/screen/online_model_viewer/snagging/create_filterdialog.dart';
import '../../presentation/screen/site_routes/site_end_drawer/filter/custom_drop_down.dart';
import '../../presentation/screen/site_routes/site_end_drawer/filter/site_end_drawer_filter.dart';
import '../../presentation/screen/site_routes/site_end_drawer/filter/snagging_filter_end_drawer.dart';
import '../../presentation/screen/site_routes/site_end_drawer/filter/toggle_switch.dart';
import '../../utils/utils.dart';
import '../elevatedbutton.dart';
import '../normaltext.dart';
import '../progressbar.dart';
import '../sidebar/sidebar_divider_widget.dart';
import '../task_form_listing_widget/task_form_listing_widget.dart';

class SnaggingFilterWidget extends StatefulWidget {
  const SnaggingFilterWidget({super.key});

  @override
  State<SnaggingFilterWidget> createState() => _SnaggingFilterWidgetState();
}

class _SnaggingFilterWidgetState extends State<SnaggingFilterWidget> {
  List<String> status = ["Open", "Verified", "Resolved"];
  TextEditingController statusController = TextEditingController();
  TextEditingController taskStatusController = TextEditingController();
  TextEditingController createDateController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();
  TextEditingController taskTypeController = TextEditingController();
  TextEditingController workpackageController = TextEditingController();
  TextEditingController issueTypeController = TextEditingController();
  TextEditingController organizationAssignedToController = TextEditingController();
  TextEditingController assignedToController = TextEditingController();
  TextEditingController createdByController = TextEditingController();
  TextEditingController organizationcreatedByController = TextEditingController();

  late final ScrollController paginationScrollController;
  late final ScrollController animatedScrollController;
  late GlobalKey filterKey;
  TaskFormListingCubit taskFormListingCubit = getIt<TaskFormListingCubit>();
  final _filterCubit = FilterCubit();

  @override
  void initState() {
    animatedScrollController = getIt<ScrollController>();
    paginationScrollController = ScrollController();
    filterKey = GlobalKey();
    getFilterData();

    // TODO: implement initState
    paginationScrollController.addListener(() {
      if (!Utility.isTablet) {
        if (paginationScrollController.position.userScrollDirection == ScrollDirection.reverse) {
          if (animatedScrollController.hasClients) {
            animatedScrollController.animateTo(
              animatedScrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear,
            );
          }
        }
        if (paginationScrollController.position.userScrollDirection == ScrollDirection.forward) {
          if (animatedScrollController.hasClients) {
            animatedScrollController.animateTo(
              animatedScrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear,
            );
          }
        }
      }
    });
    super.initState();
  }

  Future<void> getFilterData() async {
    _filterCubit.getFilterColumnData("2", curScreen: FilterScreen.screenSite);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => _filterCubit,
        child: BlocConsumer<FilterCubit, FlowState>(
            builder: (context, state) {
              if (state is LoadingState || state is InitialState) {
                return const Center(child: ACircularProgress());
              } else {
                return Column(
                  children: [
                    Expanded(
                      child: SnaggingFilterEndDrawer(
                        animationScrollController: paginationScrollController,
                        //key: filterKey,
                        curScreen: FilterScreen.screenSite,
                        onClose: () {
                          //s _siteTaskCubit.setDrawerValue(StackDrawerOptions.drawerBody);
                        },
                        onApply: (value) async {
                          // _planCubit.refreshPins(isShowProgressDialog: false);
                          // await _siteTaskCubit.isFilterApplied();
                          // _siteTaskCubit.setDrawerValue(StackDrawerOptions.drawerBody);
                          // refreshPagination();
                        },
                      ),
                    ),
                    _filterBottomBar()
                  ],
                );
              }
            },
            listener: (_, state) async {
              if (state is ShowDropDownState) {
                screenList.add(_dropDown(state));
              }
            },
            buildWhen: (previous, current) => current is! FilterAttributeValueState));
  }

  Widget _filterBottomBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 100),
      child: Column(
        children: [
          ADividerWidget(thickness: 1, color: AColors.lightGreyColor),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AElevatedButtonWidget(
                btnLabel: context.toLocale!.lbl_btn_clear,
                fontFamily: AFonts.fontFamily,
                fontWeight: FontWeight.normal,
                btnBorderClr: AColors.themeBlueColor,
                btnBackgroundClr: AColors.white,
                btnLabelClr: AColors.themeBlueColor,
                borderRadius: 5,
                fontSize: 14,
                onPressed: () async {
                  await _filterCubit.clearFilterData(curScreen: FilterScreen.screenSite);
                  // widget.onApply(false);
                },
              ),
              const SizedBox(width: 10),
              AElevatedButtonWidget(
                btnLabel: context.toLocale!.lbl_btn_apply,
                fontFamily: AFonts.fontFamily,
                fontWeight: FontWeight.normal,
                fontSize: 14,
                onPressed: () async {
                  // await _filterCubit.saveSiteFilterData(curScreen: widget.curScreen);
                  // widget.onApply(true);
                },
              )
            ],
          )
        ],
      ),
    );
  }

  Widget getTextEditorFormView(IconData? iconData, String hintText, bool isDropdown, bool isLeadingIcon, TextEditingController textController, List<String> list) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4.0), color: Colors.white),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SizedBox(
            width: isLeadingIcon ? 14 : 0,
          ),
          isLeadingIcon ? Icon(iconData) : Container(),
          const SizedBox(
            width: 16,
          ),
          Flexible(
            child: TextFormField(
              controller: textController,
              key: Key("key_recently_added_task_textformfield"),
              onTap: () {
                addFilterPopup(hintText, list, context, textController);
              },
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(top: 16, bottom: 4),
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(fontSize: 18),
                suffixIcon: isDropdown
                    ? Icon(
                        Icons.add,
                        color: AColors.iconGreyColor,
                      )
                    : Icon(null),
              ),
              onFieldSubmitted: (String value) async {
                context.closeKeyboard();
              },
              onChanged: (value) {},
            ),
          ),
          const SizedBox(
            width: 14,
          ),
        ],
      ),
    );
  }

  List<Widget> screenList = [];

  Widget _dropDown(ShowDropDownState state) {
    var arr = state.props;
    int index = int.tryParse(arr.first.toString()) ?? 0;
    var temp = _filterCubit.widgetList[index];
    String jsonString = "";
    if (temp["dataType"] != "Dropdown") {
      jsonString = json.encode(temp);
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 28, 0, 8),
      child: BlocProvider.value(
        value: _filterCubit,
        child: CustomDropDown(
          onClose: (emitState) {
            screenList.removeLast();
            if (emitState) {
              _filterCubit.dismissDropDown();
            }
          },
          dropDownList: _filterCubit.currentSelectedDropdown,
          title: arr[1].toString(),
          titleFilter:  arr[2].toString(),
          index: index,
          jsonString: jsonString,
        ),
      ),
    );
  }

  Future<void> addFilterPopup(title, listItems, context, controller) async {
    await showDialog(
        context: context,
        builder: (context) {
          var height = MediaQuery.of(context).size.height * 0.85;
          var width = MediaQuery.of(context).size.width * 0.87;
          return CreateFilterDialog(
            title: title,
            listItems: listItems,
          );
        }).then((value) {
      controller.text = value;
      print(value);
    });
  }
}
