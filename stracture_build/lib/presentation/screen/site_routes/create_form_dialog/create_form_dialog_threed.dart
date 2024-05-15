import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart' as online_model_viewer;
import 'package:field/bloc/site/create_form_selection_cubit.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/logger/logger.dart';
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
import '../../../../data/model/get_threed_type_list.dart';
import '../../../../injection_container.dart';
import '../../../../widgets/normaltext.dart';
import '../../../../widgets/sidebar/sidebar_divider_widget.dart';

class CreateFormDialogThreeD extends StatefulWidget {
  const CreateFormDialogThreeD({Key? key}) : super(key: key);

  @override
  State<CreateFormDialogThreeD> createState() => _CreateFormDialogThreeDState();
}

class _CreateFormDialogThreeDState extends State<CreateFormDialogThreeD> {
  CreateFormSelectionCubit? createFormSelectionCubit;
  TextEditingController searchController = TextEditingController();
  List<Datum> filteredDatumList = [];

  @override
  void initState() {
    createFormSelectionCubit = BlocProvider.of<CreateFormSelectionCubit>(context);
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
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
                    padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
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
                  filteredDatumList.clear();
                  createFormSelectionCubit?.emit(NormalState());
                } else {
                  for (var datum in getIt<online_model_viewer.OnlineModelViewerCubit>().datumAppTypeList) {
                    if (datum.formTypeName.toLowerCase().contains(value.toLowerCase())) {
                      filteredDatumList.add(datum);
                    }
                  }
                  Log.d(getIt<online_model_viewer.OnlineModelViewerCubit>().datumAppTypeList.length);
                }
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
                          filteredDatumList.clear();
                          createFormSelectionCubit?.emit(NormalState());
                        },
                        child: const Icon(key: Key("key_search_clear_icon"), Icons.close))
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
              return const ACircularProgress(
                key: Key("key_loading"),
              );
            } else if (state is NoProjectSelectedState) {
              return _emptyMsgWidget(context.toLocale!.lbl_no_project_data);
            } else {
              if (getIt<online_model_viewer.OnlineModelViewerCubit>().datumAppTypeList.isNotEmpty) {
                double deviceHeight = MediaQuery.of(context).size.height;
                return Container(
                  key: Key("key_form_list_view"),
                  height: getListHeight(getIt<online_model_viewer.OnlineModelViewerCubit>().datumAppTypeList.length),
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
                              itemCount: filteredDatumList.isEmpty ? getIt<online_model_viewer.OnlineModelViewerCubit>().datumAppTypeList.length : filteredDatumList.length,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, int appFormIndex) {
                                return InkWell(
                                  onTap: () {
                                    Navigator.pop(context, getIt<online_model_viewer.OnlineModelViewerCubit>().datumAppTypeList[appFormIndex]);
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
                                            child: NormalTextWidget(getIt<online_model_viewer.OnlineModelViewerCubit>().datumAppTypeList[appFormIndex].formTypeName!, overflow: TextOverflow.ellipsis, fontWeight: AFontWight.medium, maxLines: 2, fontSize: (Utility.isTablet ? 18 : 16)),
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
              } else if (getIt<online_model_viewer.OnlineModelViewerCubit>().datumAppTypeList.isEmpty && createFormSelectionCubit!.appList.isNotEmpty) {
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
      height: getListHeight(getIt<online_model_viewer.OnlineModelViewerCubit>().datumAppTypeList.length),
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
                  itemCount: getIt<online_model_viewer.OnlineModelViewerCubit>().datumAppTypeList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, int appFormIndex) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, getIt<online_model_viewer.OnlineModelViewerCubit>().datumAppTypeList[appFormIndex]);
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
                                child: NormalTextWidget(getIt<online_model_viewer.OnlineModelViewerCubit>().datumAppTypeList[appFormIndex].formTypeName!, overflow: TextOverflow.ellipsis, fontWeight: AFontWight.medium, maxLines: 2, fontSize: (Utility.isTablet ? 18 : 16)),
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
