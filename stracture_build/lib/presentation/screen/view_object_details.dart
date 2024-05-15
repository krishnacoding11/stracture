import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:field/bloc/view_file_association/view_file_association_cubit.dart';
import 'package:field/bloc/view_object_details/view_object_details_cubit.dart';
import 'package:field/data/model/file_association_model.dart';
import 'package:field/data/model/view_object_details_model.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/presentation/screen/bottom_navigation/models/models_list_screen.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../bloc/online_model_viewer/online_model_viewer_cubit.dart' as online_model_viewer;
import '../../injection_container.dart';
import '../managers/font_manager.dart';

class ViewObjectDetails extends StatefulWidget {
  @override
  _ViewObjectDetailsState createState() => _ViewObjectDetailsState();
}

class _ViewObjectDetailsState extends State<ViewObjectDetails> {
  final ViewObjectDetailsCubit _viewObjectDetailsCubit = getIt<ViewObjectDetailsCubit>();
  final FileAssociationCubit _fileAssociationCubit = getIt<FileAssociationCubit>();

  @override
  void initState() {
    super.initState();
    _viewObjectDetailsCubit.initUser();
    _viewObjectDetailsCubit.viewObjectDetailsModelList = getIt<online_model_viewer.OnlineModelViewerCubit>().detailsList;
    _fileAssociationCubit.viewFileAssociationList = getIt<online_model_viewer.OnlineModelViewerCubit>().fileAssociationList;
  }

  @override
  Widget build(BuildContext context) {
    var placeHolder = Image.asset(AImageConstants.profileAvatarPlaceholder).image;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<ViewObjectDetailsCubit>()),
        BlocProvider(create: (context) => getIt<FileAssociationCubit>()),
      ],
      child: !getIt<online_model_viewer.OnlineModelViewerCubit>().isFileAssociation
          ? BlocListener<ViewObjectDetailsCubit, ViewObjectDetailsState>(
              listener: (context, state) {
                if (state is ViewFullScreenObjectDetails) {}
              },
              child: BlocProvider.value(
                value: _viewObjectDetailsCubit,
                child: BlocBuilder<ViewObjectDetailsCubit, ViewObjectDetailsState>(
                  builder: (context, state) {
                    return OrientationBuilder(
                      key: Key('key_orientation_builder_view_object_details'),
                      builder: (BuildContext context, Orientation orientation) {
                        return GestureDetector(
                          key: Key('key_gesture_detector_view_object_details'),
                          onHorizontalDragEnd: (_) {},
                          child: Container(
                            key: Key('key_container_view_object_details'),
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  key: Key('key_sixed_box_view_object_details'),
                                  width: (state is ViewFullScreenObjectDetails && state.isShow) || !Utility.isTablet || _viewObjectDetailsCubit.isFullViewObjectDetails
                                      ? MediaQuery.of(context).size.width
                                      : orientation == Orientation.landscape
                                          ? MediaQuery.of(context).size.width * 0.4
                                          : MediaQuery.of(context).size.width * 0.55,
                                  child: Drawer(
                                    key: Key('key_drawer_view_object_details'),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          key: Key('key_sized_box_full_view_object_details'),
                                          height: 50,
                                          width: (state is ViewFullScreenObjectDetails && state.isShow) || !Utility.isTablet || _viewObjectDetailsCubit.isFullViewObjectDetails
                                              ? MediaQuery.of(context).size.width
                                              : orientation == Orientation.landscape
                                                  ? MediaQuery.of(context).size.width * 0.4
                                                  : MediaQuery.of(context).size.width * 0.55,
                                          child: Row(
                                            children: [
                                              Flexible(
                                                flex: 0,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 8.0),
                                                  child: NormalTextWidget(
                                                    context.toLocale!.lbl_properties,
                                                    key: Key('key_properties_text_widget_view_object_details'),
                                                    fontWeight: AFontWight.bold,
                                                    fontSize: 25,
                                                    textAlign: TextAlign.start,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              Spacer(
                                                key: Key('key_spacer_view_object_details'),
                                              ),
                                              Visibility(
                                                key: Key('key_visibility_view_object_details'),
                                                visible: Utility.isTablet,
                                                child: IconButton(
                                                  icon: Image.asset((state is ViewFullScreenObjectDetails && state.isShow) || (state is ExpandedDropdownState && _viewObjectDetailsCubit.isFullViewObjectDetails) ? AImageConstants.collapseIcon : AImageConstants.expandIcon),
                                                  onPressed: () {
                                                    _viewObjectDetailsCubit.isFullViewObjectDetails = !_viewObjectDetailsCubit.isFullViewObjectDetails;
                                                    _viewObjectDetailsCubit.emitFullWidth(_viewObjectDetailsCubit.isFullViewObjectDetails);
                                                    for (var item in _viewObjectDetailsCubit.viewObjectDetailsModelList) {
                                                      item.isExpanded = false;
                                                    }
                                                  },
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ),
                                              IconButton(
                                                  key: Key('key_icon_close_button_view_object_details'),
                                                  icon: Icon(Icons.close),
                                                  onPressed: () {
                                                    String deviceType = Utility.isTablet ? "Tablet" : "Mobile";
                                                    if (orientation == Orientation.portrait) {
                                                      getIt<online_model_viewer.OnlineModelViewerCubit>().webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '${Orientation.portrait}', view : ${state is online_model_viewer.MenuOptionLoadedState && getIt<online_model_viewer.OnlineModelViewerCubit>().isShowPdfView ? "'3D/2D'" : "'3D'"},device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
                                                    } else {
                                                      getIt<online_model_viewer.OnlineModelViewerCubit>().webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '${Orientation.landscape}', view : ${state is online_model_viewer.MenuOptionLoadedState && getIt<online_model_viewer.OnlineModelViewerCubit>().isShowPdfView ? "'3D/2D'" : "'3D'"},device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
                                                    }
                                                    getIt<online_model_viewer.OnlineModelViewerCubit>().key.currentState?.closeEndDrawer();
                                                    getIt<online_model_viewer.OnlineModelViewerCubit>().emitNormalWebState();
                                                  },
                                                  padding: EdgeInsets.zero),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          key: Key('key_divider_view_object_details'),
                                          color: Colors.grey,
                                          height: 1,
                                          thickness: 1,
                                        ),
                                        Expanded(
                                          key: Key('key_expanded_list_view_view_object_details'),
                                          child: _viewObjectDetailsCubit.viewObjectDetailsModelList.isEmpty
                                              ? Center(
                                                  child: NormalTextWidget(context.toLocale!.no_record_available),
                                                )
                                              : ListView.builder(
                                                  itemCount: _viewObjectDetailsCubit.viewObjectDetailsModelList.length,
                                                  padding: EdgeInsets.zero,
                                                  shrinkWrap: true,
                                                  physics: ScrollPhysics(),
                                                  itemBuilder: (context, index) {
                                                    Detail selectedSectionItem = _viewObjectDetailsCubit.viewObjectDetailsModelList[index];
                                                    return Column(
                                                      children: [
                                                        Container(
                                                          color: AColors.filterBgColor,
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                  child: Padding(
                                                                padding: const EdgeInsets.only(left: 16.0),
                                                                child: NormalTextWidget(selectedSectionItem.sectionName, textAlign: TextAlign.left),
                                                              )),
                                                              IconButton(
                                                                icon: Icon(
                                                                  selectedSectionItem.isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                                                ),
                                                                onPressed: () {
                                                                  _viewObjectDetailsCubit.normalState();
                                                                  selectedSectionItem.isExpanded = !selectedSectionItem.isExpanded;
                                                                  _viewObjectDetailsCubit.isExpandedState(selectedSectionItem.isExpanded);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        if (selectedSectionItem.isExpanded)
                                                          Container(
                                                            key: Key('key_container_expanded_view_object_details'),
                                                            color: Colors.transparent,
                                                            child: Padding(
                                                              padding: EdgeInsets.only(left: 16.0, bottom: 8, top: 8, right: 16),
                                                              child: ListView.separated(
                                                                key: Key('key_list_view_view_object_details'),
                                                                itemCount: selectedSectionItem.property.length,
                                                                physics: NeverScrollableScrollPhysics(),
                                                                shrinkWrap: true,
                                                                itemBuilder: (BuildContext context, int index) {
                                                                  Property selectedSectionProperty = selectedSectionItem.property[index];
                                                                  return Column(
                                                                    children: [
                                                                      Container(
                                                                        child: Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: NormalTextWidget(
                                                                                selectedSectionProperty.propertyName,
                                                                                color: Colors.grey,
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.w500,
                                                                                textAlign: TextAlign.start,
                                                                              ),
                                                                              flex: 1,
                                                                            ),
                                                                            Expanded(
                                                                              child: NormalTextWidget(
                                                                                selectedSectionProperty.propertyValue,
                                                                                color: Colors.black,
                                                                                fontSize: 15,
                                                                                fontWeight: FontWeight.w500,
                                                                                textAlign: TextAlign.start,
                                                                              ),
                                                                              flex: 2,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        padding: EdgeInsets.symmetric(vertical: 8),
                                                                      ),
                                                                    ],
                                                                  );
                                                                },
                                                                separatorBuilder: (BuildContext context, int index) {
                                                                  return Divider(
                                                                    color: Colors.grey, // Customize the color of the divider line
                                                                    thickness: .5, // Customize the thickness of the divider line
                                                                  );
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            )
          : BlocListener<FileAssociationCubit, FileAssociationState>(
              listener: (context, state) {
                if (state is ViewFullScreenFileAssociation) {}
              },
              child: BlocProvider.value(
                value: _fileAssociationCubit,
                child: BlocBuilder<FileAssociationCubit, FileAssociationState>(
                  builder: (context, state) {
                    return OrientationBuilder(
                      key: Key('key_orientation_builder_file_association'),
                      builder: (BuildContext context, Orientation orientation) {
                        return GestureDetector(
                          key: Key('key_gesture_detector_file_association'),
                          onHorizontalDragEnd: (_) {},
                          child: Container(
                            key: Key('key_container_file_association'),
                            color: Colors.transparent,
                            child: Row(
                              key: Key('key_row_file_association'),
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  key: Key('key_sized_box_file_association'),
                                  width: (state is ViewFullScreenFileAssociation && state.isShow) || !Utility.isTablet || _viewObjectDetailsCubit.isFullViewObjectDetails
                                      ? MediaQuery.of(context).size.width
                                      : orientation == Orientation.landscape
                                          ? MediaQuery.of(context).size.width * 0.4
                                          : MediaQuery.of(context).size.width * 0.55,
                                  child: Drawer(
                                    key: Key('key_drawer_file_association'),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          key: Key('key_sized_box_file_association'),
                                          height: 50,
                                          width: (state is ViewFullScreenFileAssociation && state.isShow) || !Utility.isTablet || _viewObjectDetailsCubit.isFullViewObjectDetails
                                              ? MediaQuery.of(context).size.width
                                              : orientation == Orientation.landscape
                                                  ? MediaQuery.of(context).size.width * 0.4
                                                  : MediaQuery.of(context).size.width * 0.55,
                                          child: Row(
                                            children: [
                                              Flexible(
                                                flex: 0,
                                                key: Key('key_flexible_file_association'),
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 8.0),
                                                  child: NormalTextWidget(
                                                    context.toLocale!.lbl_associations,
                                                    fontWeight: AFontWight.bold,
                                                    fontSize: 25,
                                                    textAlign: TextAlign.start,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              Spacer(
                                                key: Key('key_spacer_file_association'),
                                              ),
                                              Visibility(
                                                key: Key('key_visibility_file_association'),
                                                visible: Utility.isTablet,
                                                child: IconButton(
                                                  icon: Image.asset((state is ViewFullScreenFileAssociation && state.isShow) || (state is ExpandedDropdownState && _viewObjectDetailsCubit.isFullViewObjectDetails) ? AImageConstants.collapseIcon : AImageConstants.expandIcon),
                                                  onPressed: () {
                                                    _fileAssociationCubit.isFullViewObjectDetails = !_fileAssociationCubit.isFullViewObjectDetails;
                                                    _fileAssociationCubit.emitFullWidth(_fileAssociationCubit.isFullViewObjectDetails);
                                                  },
                                                  padding: EdgeInsets.zero,
                                                ),
                                              ),
                                              IconButton(
                                                  key: Key('key_icon_button_file_association'),
                                                  icon: Icon(Icons.close),
                                                  onPressed: () {
                                                    _fileAssociationCubit.isFullViewObjectDetails = false;
                                                    getIt<online_model_viewer.OnlineModelViewerCubit>().key.currentState?.closeEndDrawer();
                                                    String deviceType = Utility.isTablet ? "Tablet" : "Mobile";
                                                    if (orientation == Orientation.portrait) {
                                                      getIt<online_model_viewer.OnlineModelViewerCubit>().webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '${Orientation.portrait}', view : ${state is online_model_viewer.MenuOptionLoadedState && getIt<online_model_viewer.OnlineModelViewerCubit>().isShowPdfView ? "'3D/2D'" : "'3D'"},device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
                                                    } else {
                                                      getIt<online_model_viewer.OnlineModelViewerCubit>().webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '${Orientation.landscape}', view : ${state is online_model_viewer.MenuOptionLoadedState && getIt<online_model_viewer.OnlineModelViewerCubit>().isShowPdfView ? "'3D/2D'" : "'3D'"},device : '$deviceType', isIOS : '${Utility.isIos ? 1 : 0}'})");
                                                    }
                                                    getIt<online_model_viewer.OnlineModelViewerCubit>().emitNormalWebState();
                                                  },
                                                  padding: EdgeInsets.zero),
                                            ],
                                          ),
                                        ),
                                        Divider(
                                          key: Key('key_divider_file_association'),
                                          color: Colors.grey,
                                          height: 1,
                                          thickness: 1,
                                        ),
                                        state is ViewFullScreenFileAssociation && !_fileAssociationCubit.isFullViewObjectDetails
                                            ? Expanded(
                                                child: _fileAssociationCubit.viewFileAssociationList.isNotEmpty
                                                    ? ListView.builder(
                                                        key: Key('key_list_view_association'),
                                                        itemCount: _fileAssociationCubit.viewFileAssociationList.length,
                                                        padding: EdgeInsets.zero,
                                                        shrinkWrap: true,
                                                        itemBuilder: (context, index) {
                                                          FileAssociation fileAssociationItem = _fileAssociationCubit.viewFileAssociationList[index];
                                                          print(jsonEncode(fileAssociationItem));
                                                          return Padding(
                                                            padding: const EdgeInsets.all(2.0),
                                                            child: Column(
                                                              key: Key('key_column_file_association'),
                                                              children: [
                                                                Container(
                                                                  padding: EdgeInsets.all(12),
                                                                  color: index % 2 != 0 ? AColors.filterBgColor : AColors.white,
                                                                  width: MediaQuery.of(context).size.width,
                                                                  child: Row(
                                                                    children: [
                                                                      Image.asset(
                                                                        setTypeIcon(fileAssociationItem.filename.toLowerCase().split(".").last),
                                                                        width: 42,
                                                                        height: 42,
                                                                      ),
                                                                      Expanded(
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 4.0, bottom: 4),
                                                                              child: NormalTextWidget(
                                                                                fileAssociationItem.filename.split(".").first,
                                                                                textAlign: TextAlign.start,
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.only(left: 4.0),
                                                                              child: Text(fileAssociationItem.filename),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(right: 8.0),
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                                          children: [
                                                                            Text(formattedDate(fileAssociationItem.publishDate), textAlign: TextAlign.end),
                                                                            Text(formatPdfFileSize(double.parse(fileAssociationItem.fileSize)), textAlign: TextAlign.end),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      )
                                                    : Center(
                                                        child: NormalTextWidget(context.toLocale!.no_record_available),
                                                      ),
                                              )
                                            : Expanded(
                                                key: Key('key_expanded_half_view_file_association'),
                                                child: SizedBox(
                                                  height: MediaQuery.of(context).size.height,
                                                  width: MediaQuery.of(context).size.width,
                                                  child: _fileAssociationCubit.viewFileAssociationList.isNotEmpty
                                                      ? ListView(
                                                          children: [
                                                            SingleChildScrollView(
                                                              scrollDirection: Axis.horizontal,
                                                              child: DataTable(
                                                                columns: [
                                                                  DataColumn(
                                                                    label: NormalTextWidget(
                                                                      context.toLocale!.lbl_type,
                                                                      fontWeight: FontWeight.w500,
                                                                      fontSize: 15,
                                                                    ),
                                                                  ),
                                                                  DataColumn(
                                                                      label: NormalTextWidget(
                                                                    context.toLocale!.lbl_document_title + "/" + context.toLocale!.name,
                                                                    maxLines: 1,
                                                                    fontWeight: FontWeight.w500,
                                                                    fontSize: 15,
                                                                  )),
                                                                  DataColumn(
                                                                      label: NormalTextWidget(
                                                                    context.toLocale!.lbl_document_revision,
                                                                    maxLines: 1,
                                                                    fontWeight: FontWeight.w500,
                                                                    fontSize: 15,
                                                                  )),
                                                                  DataColumn(
                                                                      label: NormalTextWidget(
                                                                    context.toLocale!.lbl_published_date,
                                                                    maxLines: 1,
                                                                    fontWeight: FontWeight.w500,
                                                                    fontSize: 15,
                                                                  )),
                                                                  DataColumn(
                                                                      label: NormalTextWidget(
                                                                    context.toLocale!.lbl_published_by,
                                                                    maxLines: 1,
                                                                    fontWeight: FontWeight.w500,
                                                                    fontSize: 15,
                                                                  )),
                                                                  DataColumn(
                                                                      label: NormalTextWidget(
                                                                    context.toLocale!.lbl_folder_path,
                                                                    maxLines: 1,
                                                                    fontWeight: FontWeight.w500,
                                                                    fontSize: 15,
                                                                  )),
                                                                ],
                                                                rows: _fileAssociationCubit.viewFileAssociationList.map((fileAssociationItem) {
                                                                  int index = _fileAssociationCubit.viewFileAssociationList.indexOf(fileAssociationItem);
                                                                  return DataRow(
                                                                    color: index % 2 != 0 ? MaterialStateProperty.all<Color>(AColors.grColorLight) : MaterialStateProperty.all<Color>(AColors.deleteBannerBgGrey),
                                                                    cells: [
                                                                      DataCell(
                                                                        Image.asset(
                                                                          setTypeIcon(fileAssociationItem.filename.toLowerCase().split(".").last),
                                                                          width: 36,
                                                                          height: 36,
                                                                        ),
                                                                      ),
                                                                      DataCell(Column(
                                                                        children: [
                                                                          NormalTextWidget(
                                                                            fileAssociationItem.documentTitle ?? "NA",
                                                                            color: AColors.textColor,
                                                                            fontSize: 16,
                                                                            fontWeight: FontWeight.w400,
                                                                            key: const Key('key_display_size_text_widget'),
                                                                          ),
                                                                          NormalTextWidget(
                                                                            fileAssociationItem.filename,
                                                                            color: AColors.grColorDark,
                                                                            fontSize: 14,
                                                                            fontWeight: FontWeight.w400,
                                                                            key: const Key('key_display_size_text_name'),
                                                                          ),
                                                                        ],
                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                      )),
                                                                      DataCell(Center(child: NormalTextWidget(fileAssociationItem.documentRevision, color: AColors.textColor, fontSize: 16, fontWeight: FontWeight.w400, key: const Key('key_display_size_text_widget')))),
                                                                      DataCell(NormalTextWidget(formattedDate(fileAssociationItem.publishDate), color: AColors.textColor, fontSize: 16, fontWeight: FontWeight.w400, key: const Key('key_display_size_text_widget'))),
                                                                      DataCell(
                                                                        Row(
                                                                          children: [
                                                                            SizedBox(
                                                                              child: ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(100.0),
                                                                                  child: CachedNetworkImage(
                                                                                    imageUrl: fileAssociationItem.publisherImage.split("#").first,
                                                                                    httpHeaders: _viewObjectDetailsCubit.headersMap,
                                                                                    useOldImageOnUrlChange: false,
                                                                                    imageBuilder: (context, imageProvider) => Container(
                                                                                        decoration: BoxDecoration(
                                                                                      border: Border.all(
                                                                                        color: Colors.white,
                                                                                        width: 2.0,
                                                                                      ),
                                                                                      shape: BoxShape.circle,
                                                                                      image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                                    )),
                                                                                    placeholder: (context, url) => Image(image: placeHolder, fit: BoxFit.cover),
                                                                                    errorWidget: (context, url, error) => Image(
                                                                                      image: placeHolder,
                                                                                      fit: BoxFit.cover,
                                                                                    ),
                                                                                  )),
                                                                              height: 30,
                                                                              width: 30,
                                                                            ),
                                                                            const SizedBox(width: 4),
                                                                            NormalTextWidget(
                                                                              fileAssociationItem.publisherName,
                                                                              color: AColors.textColor,
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight.w400,
                                                                              key: const Key('key_display_size_text_widget'),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      DataCell(NormalTextWidget(fileAssociationItem.filepath, color: AColors.textColor, fontSize: 16, fontWeight: FontWeight.w400, key: const Key('key_attached_date_text_widget'))),
                                                                    ],
                                                                  );
                                                                }).toList(),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : Center(
                                                          child: Text(context.toLocale!.no_record_available),
                                                        ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
    );
  }

  String formattedDate(String originalDateStr) {
    var splitDate = originalDateStr.split("#").first;
    DateFormat inputFormat = DateFormat('MMM dd, yyyy');
    if (splitDate.contains("-")) {
      inputFormat = DateFormat('dd-MMM-yyyy');
    }

    DateFormat outputFormat = DateFormat('MM/dd/yyyy');

    DateTime originalDate = inputFormat.parse(splitDate);

    return outputFormat.format(originalDate);
  }

  String setTypeIcon(String type) {
    switch (type) {
      case AConstants.pdf:
        return AImageConstants.pdfIcon;
      case AConstants.bcf:
        return AImageConstants.bcfIcon;
      case AConstants.csv:
        return AImageConstants.csvIcon;
      case AConstants.jpeg:
        return AImageConstants.jpegIcon;
      case AConstants.jpg:
        return AImageConstants.jpgIcon;
      case AConstants.png:
        return AImageConstants.pngIcon;
      case AConstants.ppsx:
        return AImageConstants.ppsxIcon;
      case AConstants.pptm:
        return AImageConstants.pptmIcon;
      case AConstants.pptx:
        return AImageConstants.pptxIcon;
      case AConstants.rar:
        return AImageConstants.rarIcon;
      case AConstants.rfa:
        return AImageConstants.rfaIcon;
      case AConstants.rft:
        return AImageConstants.rftIcon;
      case AConstants.rte:
        return AImageConstants.rteIcon;
      case AConstants.rvt:
        return AImageConstants.rvtIcon;
      case AConstants.ifc:
        return AImageConstants.ifcIcon;
      case AConstants.vcf:
        return AImageConstants.vcfIcon;
      case AConstants.xls:
        return AImageConstants.xlsIcon;
      case AConstants.zip:
        return AImageConstants.zipIcon;
      default:
        return AImageConstants.pdfIcon;
    }
  }
}
