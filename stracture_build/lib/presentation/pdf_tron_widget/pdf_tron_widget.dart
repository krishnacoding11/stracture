import 'package:field/bloc/pdf_tron/pdf_tron_cubit.dart';
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart' as side_tool_bar;
import 'package:field/networking/network_info.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/online_model_viewer/online_model_viewer_cubit.dart' as online_model_cubit;
import '../../injection_container.dart';
import '../../pdftron/pdftron_document_view.dart';
import '../../utils/actionIdConstants.dart';
import '../../utils/requestParamsConstants.dart';
import '../../utils/utils.dart';
import '../managers/color_manager.dart';
import '../managers/image_constant.dart';

class PdfTronWidget extends StatefulWidget {
  final ScrollController scrollController;
  final String pdfFileName;
  final online_model_cubit.OnlineModelViewerCubit onlineModelViewerCubit;
  final Orientation orientation;
  final String modelId;

  const PdfTronWidget({
    Key? key,
    required this.pdfFileName,
    required this.onlineModelViewerCubit,
    required this.orientation,
    required this.scrollController,
    required this.modelId,
  }) : super(key: key);

  @override
  State<PdfTronWidget> createState() => _PdfTronWidgetState();
}

class _PdfTronWidgetState extends State<PdfTronWidget> {
  TextEditingController searchController = TextEditingController();
  final side_tool_bar.SideToolBarCubit _sideToolBarCubit = getIt<side_tool_bar.SideToolBarCubit>();
  final PdfTronCubit pdfTronCubit = getIt<PdfTronCubit>();
  @override
  void initState() {
    super.initState();
    // widget.onlineModelViewerCubit.selectedCalibrationName = widget.pdfFileName;
  }

  @override
  Widget build(BuildContext context) {
    widget.onlineModelViewerCubit.selectedCalibrationName = widget.pdfFileName;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: BlocListener<PdfTronCubit, PdfTronState>(
        listener: (context, state) {
          if (state is ErrorState) {
            context.showSnack(state.exception.message);
          }
        },
        child: BlocBuilder<PdfTronCubit, PdfTronState>(
          builder: (context, state) {
            if ((state is FullPdfTronVIew && state.isShowPdfViewFullScreen) || (widget.orientation == Orientation.landscape && state is MenuOptionLoadedState)) {
              pdfTronCubit.isFullViewPdf = true;
            } else if (state is FullPdfTronVIew && !state.isShowPdfViewFullScreen) {
              pdfTronCubit.isFullViewPdf = false;
            }
            return Stack(
              children: [PdftronDocumentView(key: const Key("key_pdf_tron_widget"), onCreated: pdfTronCubit.onDocumentViewCreated), Positioned(top: (AppBar().preferredSize.height + 12) * 0.01, left: 0, right: 0, child: dropDownWidget(context, state, pdfTronCubit))],
            );
          },
        ),
      ),
    );
  }

  Widget dropDownWidget(context, state, pdfTronCubit) {
    return Row(
      key: Key('key_drop_down_widget_row'),
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
            key: Key('key_drop_down_widget_flexible'),
            child: GestureDetector(
              onTap: () async {
                showPdfFiles(context, pdfTronCubit);
                widget.onlineModelViewerCubit.calibList = await widget.onlineModelViewerCubit.getCalibrationList(widget.onlineModelViewerCubit.selectedProject.projectID!, widget.onlineModelViewerCubit.selectedModelId, true);
              },
              child: Container(
                key: const Key("key_drop_down_container"),
                height: 50,
                width: Utility.isTablet && widget.orientation == Orientation.portrait
                    ? MediaQuery.of(context).size.width * 0.3
                    : Utility.isTablet && widget.orientation == Orientation.landscape
                        ? MediaQuery.of(context).size.width * 0.22
                        : MediaQuery.of(context).size.width * 0.63,
                margin: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  border: Border.all(color: AColors.grColor),
                  color: AColors.white,
                  borderRadius: BorderRadius.circular(5),
                  shape: BoxShape.rectangle,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Flexible(
                      child: Container(
                        key: const Key("Column Container"),
                        transform: Matrix4.translationValues(20.0, -8.0, 0.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                        ),
                        child: Container(
                          padding: const EdgeInsets.only(left: 8.0, top: 1.0, bottom: 0.0),
                          color: Colors.white,
                          child: RichText(
                            text: const TextSpan(text: "Select Calibrated Location", style: TextStyle(color: Colors.black), children: [
                              TextSpan(
                                text: ' * ',
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              )
                            ]),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: Utility.isTablet && widget.orientation == Orientation.portrait
                          ? MediaQuery.of(context).size.width * 0.82
                          : Utility.isTablet && widget.orientation == Orientation.landscape
                              ? MediaQuery.of(context).size.width * 0.400
                              : MediaQuery.of(context).size.width * 0.65,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            key: const Key("Expanded Text"),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0, top: 0.0),
                              child: Text(
                                widget.onlineModelViewerCubit.selectedCalibrationName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ),
                          ),
                          Padding(
                            key: const Key("Arrow Drop Down"),
                            padding: const EdgeInsets.only(left: 16.0, right: 12.0, bottom: 4.0),
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: AColors.grColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
        GestureDetector(
          onTap: () {
            pdfTronCubit.togglePdfTronFullViewVisibility();
            widget.onlineModelViewerCubit.webviewController.evaluateJavascript(source: "nCircle.Ui.Joystick.updatePosition({orientation : '${Orientation.portrait}', view : ${state is MenuOptionLoadedState && state.isShowPdfView ? "'3D/2D'" : "'3D'"},reload : 1, device : '${Utility.isTablet ? "Tablet" : "Mobile"}', isIOS : '${Utility.isIos ? 1 : 0}'})");
            widget.onlineModelViewerCubit.togglePdfTronVisibility(true, widget.onlineModelViewerCubit.selectedPdfFileName, true, false);
          },
          child: Padding(
            key: const Key("Padding Image Asset"),
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(border: Border.all(color: AColors.grColor), borderRadius: const BorderRadius.all(Radius.circular(5)), color: AColors.white),
              child: Image.asset(widget.onlineModelViewerCubit.isFullPdf ? AImageConstants.fullScreenExit : AImageConstants.fullScreen),
            ),
          ),
        ),
      ],
    );
  }

  void showPdfFiles(BuildContext context, PdfTronCubit pdfTronCubit) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return BlocProvider<PdfTronCubit>.value(
              value: pdfTronCubit,
              child: Dialog(
                key: const Key('key_pdf_dialog'),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                child: dialogContent(context, pdfTronCubit),
              ));
        });
  }

  Widget dialogContent(BuildContext context, PdfTronCubit pdfTronCubit) {
    return BlocBuilder<PdfTronCubit, PdfTronState>(builder: (context, state) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: [
            BoxShadow(
              color: AColors.lightGreyColor,
              offset: const Offset(0, 1),
              blurRadius: 1,
              spreadRadius: 0,
            )
          ],
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: state is PDFDownloading
                        ? () {}
                        : () {
                            Navigator.of(context).pop();
                            pdfTronCubit.newCalibrationData();
                            searchController.clear();
                            widget.onlineModelViewerCubit.togglePdfTronVisibility(true, pdfTronCubit.selectedCalibration!.fileName, false, false);
                          },
                    icon: const Icon(Icons.arrow_back_ios_new),
                  ),
                  const Text(
                    'Select Floor',
                    style: TextStyle(fontSize: 18),
                  ),
                  IconButton(
                    onPressed: state is PDFDownloading
                        ? () {}
                        : () {
                            Navigator.of(context).pop();
                            searchController.clear();
                            widget.onlineModelViewerCubit.togglePdfTronVisibility(true, pdfTronCubit.selectedCalibration!.fileName, false, false);
                            pdfTronCubit.onCancelClick();
                          },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              Divider(
                thickness: 2,
                color: AColors.lightGreyColor,
              ),
              const SizedBox(
                height: 4.0,
              ),
              Container(
                margin: const EdgeInsets.all(8),
                width: Utility.isTablet ? MediaQuery.of(context).size.width * 0.90 : MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(border: Border.all(color: Colors.black45), borderRadius: const BorderRadius.all(Radius.circular(4.0))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 52, width: 52, child: const Icon(Icons.search)),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        textInputAction: TextInputAction.search,
                        onChanged: (value) async {},
                        onSubmitted: (value) async {
                          pdfTronCubit.onSearchTextChanged(value.trim());
                        },
                        decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                            suffixIcon: GestureDetector(
                                onTap: () {
                                  searchController.text = "";
                                  pdfTronCubit.onCancelClick();
                                },
                                child: searchController.text != "" ? const Icon(Icons.close) : const Icon(null)),
                            hintText: context.toLocale!.search_calibration,
                            border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: state is PDFDownloading
                          ? const Center(child: CircularProgressIndicator())
                          : state is PDFDownloaded || state is EmptyFilteredListState
                              ? ListView.builder(
                                  key: Key('key_empty_filtered_list_view'),
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  itemCount: widget.onlineModelViewerCubit.calibList.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    return Container(
                                      color: pdfTronCubit.selectedCalibration!.fileName == widget.onlineModelViewerCubit.calibList[index].fileName && pdfTronCubit.selectedCalibration!.calibrationId == widget.onlineModelViewerCubit.calibList[index].calibrationId ? AColors.lightBlueColor : Colors.transparent,
                                      child: ListTile(
                                        title: Text(widget.onlineModelViewerCubit.calibList[index].calibrationName),
                                        onTap: () async {
                                          widget.onlineModelViewerCubit.isCalibListShow = false;
                                          if (pdfTronCubit.selectedCalibration!.fileName != widget.onlineModelViewerCubit.calibList[index].fileName) {
                                            widget.onlineModelViewerCubit.emitLoadedSuccessfulAllModelState();
                                            widget.onlineModelViewerCubit.selectedPdfFileName = widget.onlineModelViewerCubit.calibList[index].fileName;
                                            Map<String, dynamic> map = {};
                                            map[RequestConstants.projectId] = widget.onlineModelViewerCubit.selectedProject.projectID;
                                            map[RequestConstants.folderId] = widget.onlineModelViewerCubit.calibList[index].folderId;
                                            map[RequestConstants.revisionId] = widget.onlineModelViewerCubit.calibList[index].revisionId;
                                            pdfTronCubit.downloadPdf(map).then((value) {
                                              pdfTronCubit.selectedCalibration = widget.onlineModelViewerCubit.calibList[index];
                                              pdfTronCubit.newCalibrationData();
                                              widget.onlineModelViewerCubit.togglePdfTronVisibility(true, widget.onlineModelViewerCubit.calibList[index].calibrationName, false, false);
                                              widget.onlineModelViewerCubit.selectedPdfFileName = widget.onlineModelViewerCubit.calibList[index].calibrationName;
                                            });
                                            Navigator.of(
                                              context,
                                            ).pop(widget.onlineModelViewerCubit.calibList[index]);
                                            searchController.clear();
                                          } else {
                                            pdfTronCubit.selectedCalibration = widget.onlineModelViewerCubit.calibList[index];
                                            pdfTronCubit.newCalibrationData();
                                            widget.onlineModelViewerCubit.togglePdfTronVisibility(true, widget.onlineModelViewerCubit.calibList[index].calibrationName, false, false);
                                            widget.onlineModelViewerCubit.selectedPdfFileName = widget.onlineModelViewerCubit.calibList[index].calibrationName;
                                            searchController.clear();
                                            Navigator.of(
                                              context,
                                            ).pop(widget.onlineModelViewerCubit.calibList[index]);
                                            widget.onlineModelViewerCubit.emitNormalWebState();
                                          }
                                          if (isNetWorkConnected()) {
                                            widget.onlineModelViewerCubit.setParallelViewAuditTrail(widget.onlineModelViewerCubit.selectedProject.projectID!, "Field", "Coordinate View", ActionConstants.actionId98, widget.modelId, pdfTronCubit.selectedCalibration!.calibrationId);
                                          }
                                        },
                                      ),
                                    );
                                  },
                                )
                              : state is FilteredListState
                                  ? pdfTronCubit.filteredCalibList.isNotEmpty
                                      ? ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: pdfTronCubit.filteredCalibList.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return Container(
                                              color: pdfTronCubit.selectedCalibration!.fileName == pdfTronCubit.filteredCalibList[index].fileName && pdfTronCubit.selectedCalibration!.calibrationId == pdfTronCubit.filteredCalibList[index].calibrationId ? AColors.lightBlueColor : Colors.transparent,
                                              child: ListTile(
                                                title: Text(pdfTronCubit.filteredCalibList[index].calibrationName),
                                                onTap: () async {
                                                  widget.onlineModelViewerCubit.isCalibListShow = false;
                                                  if (pdfTronCubit.selectedCalibration!.fileName != pdfTronCubit.filteredCalibList[index].fileName) {
                                                    _sideToolBarCubit.isWhite = false;
                                                    widget.onlineModelViewerCubit.selectedPdfFileName = pdfTronCubit.filteredCalibList[index].fileName;
                                                    Map<String, dynamic> map = {};
                                                    map[RequestConstants.projectId] = widget.onlineModelViewerCubit.selectedProject.projectID;
                                                    map[RequestConstants.folderId] = pdfTronCubit.filteredCalibList[index].folderId;
                                                    map[RequestConstants.revisionId] = pdfTronCubit.filteredCalibList[index].revisionId;
                                                    pdfTronCubit.downloadPdf(map).then((value) {
                                                      pdfTronCubit.selectedCalibration = pdfTronCubit.filteredCalibList[index];
                                                      pdfTronCubit.newCalibrationData();
                                                      widget.onlineModelViewerCubit.togglePdfTronVisibility(true, pdfTronCubit.filteredCalibList[index].calibrationName, false, false);
                                                      widget.onlineModelViewerCubit.selectedPdfFileName = pdfTronCubit.filteredCalibList[index].calibrationName;
                                                    });
                                                    searchController.clear();
                                                    Navigator.of(
                                                      context,
                                                    ).pop(pdfTronCubit.filteredCalibList[index]);
                                                  } else {
                                                    pdfTronCubit.selectedCalibration = pdfTronCubit.filteredCalibList[index];
                                                    pdfTronCubit.newCalibrationData();
                                                    widget.onlineModelViewerCubit.togglePdfTronVisibility(true, pdfTronCubit.filteredCalibList[index].calibrationName, false, false);
                                                    widget.onlineModelViewerCubit.selectedPdfFileName = pdfTronCubit.filteredCalibList[index].calibrationName;
                                                    searchController.clear();
                                                    Navigator.of(
                                                      context,
                                                    ).pop(pdfTronCubit.filteredCalibList[index]);
                                                    widget.onlineModelViewerCubit.emitNormalWebState();
                                                  }
                                                  if (isNetWorkConnected()) {
                                                    widget.onlineModelViewerCubit.setParallelViewAuditTrail(widget.onlineModelViewerCubit.selectedProject.projectID!, "Field", "Coordinate View", ActionConstants.actionId98, widget.modelId, pdfTronCubit.selectedCalibration!.calibrationId);
                                                  }
                                                },
                                              ),
                                            );
                                          },
                                        )
                                      : const Center(
                                          child: Text('No Matches Found.'),
                                        )
                                  : Container())),
            ],
          ),
        ),
      );
    });
  }
}
