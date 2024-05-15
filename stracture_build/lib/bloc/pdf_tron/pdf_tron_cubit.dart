import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:field/bloc/online_model_viewer/online_model_viewer_cubit.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/exception/app_exception.dart';
import 'package:field/injection_container.dart';
import 'package:field/pdftron/pdftron_events.dart';
import 'package:field/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';

import '../../logger/logger.dart';
import '../../pdftron/pdftron_config.dart';
import '../../pdftron/pdftron_document_view.dart';
import '../../utils/download_service.dart';

part 'pdf_tron_state.dart';

class PdfTronCubit extends Cubit<PdfTronState> {
  PdfTronCubit() : super(PaginationListInitial());
  late PdftronDocumentViewController pdftronDocumentViewController;
  double inputX1 = 0.0;
  double inputY1 = 0.0;
  double locationAngle = 0.0;
  double markupAnnotId = 0.0;
  late File pdfFile;
  final _config = getSiteTabConfig();
  CalibrationDetails? selectedCalibration;
  dynamic selectedCalibrationHandle;
  late InAppWebViewController webviewController;
  bool isFullViewPdfTron = false;
  String hCStartPoint = '';
  String hCEndPoint = '';
  String pdfTronStartPoint = '';
  String pdfTronEndPoint = '';
  String pdfDepth = '';
  bool pdfLoaded = false;
  List<CalibrationDetails> filteredCalibList = [];
  bool isFullViewPdf = false;

  double lastSavedXPoint = -99999;
  double lastSavedYPoint = -99999;

  void onDocumentViewCreated(PdftronDocumentViewController controller) async {
    pdftronDocumentViewController = controller;
    startDocumentLoadedListener((path) async {
      await controller.setBackgroundColor(255, 255, 255);
      await controller.setDocumentEventListener(currentTab: AConstants.siteTab);
    });

    onLongPressDocumentListener((x, y) async {
      var pagePoint = await pdftronDocumentViewController.convertScreenPtToPagePt(x, y);
      if (pagePoint != null) {
        var xPoint = pagePoint['X'];
        var yPoint = pagePoint['Y'];
        Log.d(xPoint);
        Log.d(yPoint);
      }
    });

    onPressDocumentListener((x, y) async {
      /* Change this to event.*/
      webviewController.evaluateJavascript(source: 'window.calibrationManager.getPageNavigationTool().setPosition(new Communicator.Point2($x,$y));');
      lastSavedXPoint = x;
      lastSavedYPoint = y;
    });
    if (Platform.isIOS) {
      onZoomDocumentListener((x, y) async {
        pdftronDocumentViewController.polygonAnnotation(inputX1, inputY1, locationAngle, markupAnnotId);
        markupAnnotId++;
      });
    }
    openDocument();
  }

  Future openDocument() async {
    try {
      pdfLoaded = false;
      await pdftronDocumentViewController.openDocument(pdfFile.uri.toString(), config: _config).then((value) {
        pdfLoaded = true;
        Future.delayed(Duration(seconds: 2));
        newCalibrationData();
        updateMarker();
      }).catchError((error) {
        Log.e("Plan Load Error ->$error");
        emitState(ErrorState(exception: error));
      });
    } catch (e) {
      Log.e(e);
    }
  }

  void updateCalibrationLocation() async {
    if (pdfLoaded) {
      if (state is PDFDownloaded) {
        pdftronDocumentViewController.polygonAnnotation(inputX1, inputY1, locationAngle, markupAnnotId);
        markupAnnotId++;
      }
    }
  }

  Future newCalibrationData() async {
    if (selectedCalibration != null) {
      hCStartPoint = selectedCalibration!.point3D1;
      hCEndPoint = selectedCalibration!.point3D2;
      pdfTronStartPoint = selectedCalibration!.point2D1;
      pdfTronEndPoint = selectedCalibration!.point2D2;
      pdfDepth = selectedCalibration!.depth.toString();
      if (state is PDFDownloaded && pdfLoaded) {
        pdftronDocumentViewController.getZoom();
        pdftronDocumentViewController.requestResetRenderingPdftron();
        /* Change this to calibrationManager.setCalibrationPoint.*/
        webviewController.evaluateJavascript(source: 'window.calibrationManager.setCalibrationPoints({fPoint3 : $hCStartPoint, sPoint3 : $hCEndPoint, fPoint2:  $pdfTronStartPoint,sPoint2 : $pdfTronEndPoint});');
        webviewController.evaluateJavascript(source: 'window.calibrationManager.setHeight($pdfDepth);');

        if (lastSavedXPoint != -99999 && lastSavedYPoint != -99999) {
          /* Change this to event.*/
          webviewController.evaluateJavascript(source: 'window.calibrationManager.getPageNavigationTool().setPosition(new Communicator.Point2($lastSavedXPoint,$lastSavedYPoint));');
        }
      }
    }
  }

  void updateMarker() {
    webviewController.addJavaScriptHandler(
        handlerName: 'getCalibrationPoints',
        callback: (args) {
          print('Calibration $args');
          final inputPoints = args.toString().replaceAll("[", "").replaceAll("]", "").split(" ");
          inputX1 = double.tryParse(inputPoints[0].toString()) ?? 0;
          inputY1 = double.tryParse(inputPoints[1].toString()) ?? 0;
          locationAngle = double.tryParse(inputPoints[2].toString()) ?? 0;
          updateCalibrationLocation();
        });
  }

  Future downloadPdf(Map<String, dynamic> request) async {
    emit(PDFDownloading());
    final downloadPdfXfdfResponse = await Future.wait<DownloadResponse>([DownloadPdfFile().downloadPdf(request)]).then((value) {
      if (value[0].isSuccess) {
        pdfFile = File(value[0].outputFilePath!);
        emit(PDFDownloaded());
        openDocument();
      }
    });
    Log.d(downloadPdfXfdfResponse);
  }

  onSearchTextChanged(String searchString) async {
    filteredCalibList.clear();
    emitState(PDFDownloading());
    if (searchString.isEmpty) {
      emitState(EmptyFilteredListState());
    } else {
      for (var calibListChild in getIt<OnlineModelViewerCubit>().calibList) {
        if (calibListChild.calibrationName.toString().toLowerCase().contains(searchString.toLowerCase())) {
          filteredCalibList.add(calibListChild);
        }
      }
      emitState(FilteredListState());
    }
  }

  togglePdfTronFullViewVisibility({bool isTest = false}) {
    isFullViewPdfTron = !isFullViewPdfTron;
    emitState(FullPdfTronVIew(isFullViewPdfTron));
    emitState(PDFDownloaded());
    pdftronDocumentViewController.requestResetRenderingPdftron();
  }

  resetPdfTronFullViewVisibility({bool isTest = false}) {
    isFullViewPdfTron = !isFullViewPdfTron;
    emitState(FullPdfTronVIew(isFullViewPdfTron));
    emitState(PDFDownloaded());
    pdftronDocumentViewController.requestResetRenderingPdftron();
  }

  toggleScrollController(ScrollController scrollController) {
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.minScrollExtent);
    }
    emitState(FullPdfTronVIew(isFullViewPdfTron));
  }

  onCancelClick() {
    emitState(EmptyFilteredListState());
    emitState(PDFDownloaded());
  }

  errorStateEmit(String message) {
    emitState(ErrorState(exception: AppException(message: '$message')));
  }

  emitState(PdfTronState state) {
    if (!isClosed) {
      Future.delayed(Duration.zero).then((value) => emit(state));
    }
  }
}
