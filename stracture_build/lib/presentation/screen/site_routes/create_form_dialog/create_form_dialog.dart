import 'dart:async';

import 'package:field/bloc/site/create_form_selection_cubit.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../bloc/site/create_form_selection_state.dart';
import '../../../../widgets/normaltext.dart';
import '../../../../widgets/sidebar/sidebar_divider_widget.dart';

class CreateFormDialog extends StatefulWidget {
  const CreateFormDialog({Key? key}) : super(key: key);

  @override
  State<CreateFormDialog> createState() => _CreateFormDialogState();
}

class _CreateFormDialogState extends State<CreateFormDialog> {
  CreateFormSelectionCubit? createFormSelectionCubit;
  TextEditingController searchController = TextEditingController();
  Timer? _debounceTimer;
  Duration debounceDuration = const Duration(milliseconds: 400);

  @override
  void initState() {
    createFormSelectionCubit = BlocProvider.of<CreateFormSelectionCubit>(context);
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  dialogContent(BuildContext context) {
    return OrientationBuilder(builder: (_, orientation) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).size.width * 0.87,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AColors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // To make the card compact
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(width: 50),
                const Spacer(),
                Align(
                  alignment: Alignment.center,
                  child: NormalTextWidget(
                    textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.18),
                    context.toLocale!.lbl_create_site_form,
                    fontSize: 18.0,
                    fontWeight: AFontWight.semiBold,
                  ),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8,8,0,8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, size: 25),
                          color: Colors.black54,
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true).pop();
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ADividerWidget(
              thickness: 1,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    getSearchFormView(),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(child: appTypeListView(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget getSearchFormView() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(4.0)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(
            width: 14,
          ),
          const Icon(Icons.search),
          const SizedBox(
            width: 16,
          ),
          Flexible(
            child: TextFormField(
              key: Key("key_search_textformfield"),
              controller: searchController,
              onTap: () {
                createFormSelectionCubit!.onFocusChange(true);
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: context.toLocale!.text_search_for,
              ),
              onFieldSubmitted: (String value) async {
                context.closeKeyboard();
                if (value.isEmpty) {
                  createFormSelectionCubit!.onClearSearch();
                  createFormSelectionCubit!.onSearchClear();
                } else {
                  createFormSelectionCubit!.onSearchForm(value);
                }
              },
              onChanged: (value) {
                _debounceTimer?.cancel();
                _debounceTimer = Timer(debounceDuration, () {
                  if (_debounceTimer!.isActive)
                    return;

                  if (value.isEmpty) {
                    createFormSelectionCubit!.onClearSearch();
                  } else {
                    createFormSelectionCubit!.onSearchForm(value);
                  }
                });
              },
            ),
          ),
          BlocBuilder<CreateFormSelectionCubit, FlowState>(
            key: Key("key_clear_search_render"),
              buildWhen: (prev, current) => current is FormTypeExpandedState || current is FormTypeSearchClearState,
              builder: (context, state) {
                return (state is FormTypeExpandedState && state.isFormTypeExpanded)
                    ? InkWell(
                        onTap: () {
                          context.closeKeyboard();
                          searchController.clear();
                          createFormSelectionCubit!.onClearSearch();
                          createFormSelectionCubit!.onSearchClear();
                        },
                        child: const Icon(
                          key: Key("key_search_clear_icon"),
                            Icons.close))
                    : Container();
              }),
          const SizedBox(
            width: 14,
          ),
        ],
      ),
    );
  }

  Widget appTypeListView(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 20,
        ),
        Expanded(
          child: BlocBuilder<CreateFormSelectionCubit, FlowState>(builder: (context, state) {
            if (state is LoadingState) {
              return const ACircularProgress(key: Key("key_loading"),);
            } else if (state is NoProjectSelectedState) {
              return _emptyMsgWidget(context.toLocale!.lbl_no_project_data);
            } else {
              if (createFormSelectionCubit!.searchAppGroup!.isNotEmpty) {
                return ListView.builder(
                    key: const Key("AppTypeGroupListKey"),
                    itemCount: createFormSelectionCubit!.searchAppGroup!.length,
                    shrinkWrap: true,
                    itemBuilder: (context, int appTypeIndex) {
                      return Container(
                        /// Unique key for container widget..
                        key: GlobalObjectKey(appTypeIndex),
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(border: Border.all(color: AColors.lightGreyColor), borderRadius: BorderRadius.circular(4)),
                        child: Column(
                          children: [
                            InkWell(
                                onTap: () {
                                  createFormSelectionCubit!.onChangeExpansion(appTypeIndex);

                                  ///To scroll the view to make the expanded container visible..
                                  if (createFormSelectionCubit!.searchAppGroup![appTypeIndex].isExpanded!) {
                                    WidgetsBinding.instance.addPostFrameCallback((_) => Scrollable.ensureVisible(GlobalObjectKey(appTypeIndex).currentContext!));
                                  }
                                },
                                child: Padding(
                                  key: const Key("key_list_item"),
                                  padding: const EdgeInsets.only(left: 14.0, top: 16.0, right: 14.0, bottom: 14.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Flexible(
                                        child: Align(
                                          alignment: Directionality.of(context) == TextDirection.rtl?Alignment.centerRight:Alignment.centerLeft,
                                          child: NormalTextWidget(
                                            createFormSelectionCubit!.searchAppGroup![appTypeIndex].formTypeName! == AConstants.recentForm ? context.toLocale!.lbl_recent_forms : createFormSelectionCubit!.searchAppGroup![appTypeIndex].formTypeName!,
                                            textAlign: TextAlign.justify,
                                            maxLines: 2,
                                            fontWeight: AFontWight.medium,
                                            color: AColors.black,
                                          ),
                                        ),
                                      ),
                                      createFormSelectionCubit!.searchAppGroup![appTypeIndex].isExpanded!
                                          ? const Icon(
                                              Icons.keyboard_arrow_up,
                                              color: Colors.grey,
                                            )
                                          : const Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.grey,
                                            )
                                    ],
                                  ),
                                )),
                            createFormSelectionCubit!.searchAppGroup![appTypeIndex].isExpanded! ? appFormListView(createFormSelectionCubit!.searchAppGroup![appTypeIndex].formAppType!) : Container()
                          ],
                        ),
                      );
                    });
              } else if (createFormSelectionCubit!.searchAppGroup!.isEmpty && createFormSelectionCubit!.appList.isNotEmpty) {
                return _emptyMsgWidget(context.toLocale!.lbl_no_records_found);
              }
              return _emptyMsgWidget(context.toLocale!.lbl_can_not_create_forms);
            }
          }),
        ),
      ],
    );
  }

  Widget appFormListView(List<AppType>? appType) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return Container(
      key: Key("key_form_list_view"),
      height: getListHeight(appType!.length),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(4.0)),
      alignment: Alignment.topLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: double.infinity, height: 1, color: AColors.lightGreyColor),
          Expanded(
              child: GridView.builder(
                key: Key("key_gridview"),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: Utility.isTablet ? 6 : 2, childAspectRatio: Utility.isTablet ? (MediaQuery.of(context).size.width / 100) / deviceHeight : getChildAspectRationPhone(deviceHeight)),
                  shrinkWrap: true,
                  itemCount: appType.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, int appFormIndex) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, appType[appFormIndex]);
                      },
                      child: Padding(
                        key: Key("key_grid_item"),
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              AImageConstants.formType,
                              fit: BoxFit.fitHeight,
                              width: Utility.isTablet ? 65 : 58,
                              height: Utility.isTablet ? 65 : 58,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                                child: NormalTextWidget(appType[appFormIndex].formTypeName!, overflow: TextOverflow.ellipsis, fontWeight: AFontWight.medium, maxLines: 2, fontSize: (Utility.isTablet ? 18 : 16)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      insetPadding: const EdgeInsets.all(16.0),
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  Widget _emptyMsgWidget(String msg) {
    return Center(
      key: Key("key_empty_view_msg"),
      child: NormalTextWidget(msg),
    );
  }

  double getChildAspectRationPhone(deviceHeight) {
    return deviceHeight > 840 ? deviceHeight / (deviceHeight * 0.9) : deviceHeight / (deviceHeight * 1.15);
  }
}

double getListHeight(int length) {
  int deviceType = Utility.isTablet ? 6 : 2; // 2 for phone and
  double a = length / deviceType;
  return ((length % deviceType == 0) ? a.toInt() : (a + 1).toInt()) * 160.0;
}


