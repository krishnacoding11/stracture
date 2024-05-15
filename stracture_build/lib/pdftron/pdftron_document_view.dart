import 'dart:convert';
import 'dart:io';

import 'package:field/pdftron/pdftron_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';

import '../logger/logger.dart';

typedef DocumentViewCreatedCallback = void Function(PdftronDocumentViewController controller);

const String viewType = 'asite/pdftron_flutter/documentview';

class PdftronDocumentView extends StatefulWidget {
  const PdftronDocumentView({Key? key, required this.onCreated}) : super(key: key);

  /// This function initialises the [DocumentView] widget after its creation.
  ///
  /// Within this function, the features of the PDFTron SDK are accessed.
  final DocumentViewCreatedCallback onCreated;

  @override
  State<StatefulWidget> createState() => _DocumentViewState();
}

class _DocumentViewState extends State<PdftronDocumentView> {
  @override
  Widget build(BuildContext context) {
    if (Platform.isAndroid) {
      return PlatformViewLink(
          viewType: viewType,
          surfaceFactory: (BuildContext context, PlatformViewController controller) {
            return AndroidViewSurface(controller: controller as AndroidViewController, hitTestBehavior: PlatformViewHitTestBehavior.opaque, gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{});
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            Log.d("Pdftron DocumentView Created Param ${params.id}");
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: viewType,
              layoutDirection: TextDirection.ltr,
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
              ..create();
          });
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    }
    return const Text('coming soon');
  }

  void _onPlatformViewCreated(int id) {
    widget.onCreated(PdftronDocumentViewController._(id));
  }
}

class PdftronDocumentViewController extends DocumentViewController {
  PdftronDocumentViewController._(int id)
      : _asiteChannel = MethodChannel("${viewType}_$id"),
        super(id);

  final MethodChannel _asiteChannel;

  @override
  Future<void> deleteAllAnnotations({int? annotType = -1, bool? isExcludingLocationAnnot = false}) {
    return _asiteChannel.invokeMethod(AFunctions.deleteAllAnnotations, <String, dynamic?>{MethodParameters.annotType: annotType, MethodParameters.isExcludingLocationAnnot: isExcludingLocationAnnot});
  }

  Future<void> getPDFTronLicenseKey(String? pdfKey) {
    return _asiteChannel.invokeMethod(AFunctions.getPDFTronKey, <String, dynamic>{
      MethodParameters.licenseKey: pdfKey
    });
  }

  Future<void> setDocumentEventListener({int currentTab = -1}) {
    return _asiteChannel.invokeMethod(AFunctions.setDocumentEventListener, <String, int>{MethodParameters.tab: currentTab});
  }

  Future<void> requestResetRenderingPdftron() {
    return _asiteChannel.invokeMethod(AFunctions.requestResetRenderingPdftron);
  }

  Future<void> highlightSelectedLocation({required String? annotationId, required bool isShowRect}) {
    return _asiteChannel.invokeMethod(AFunctions.highlightSelectedLocation, <String, dynamic>{MethodParameters.annotationId: annotationId, MethodParameters.isShowRect: isShowRect});
  }

  Future<void> createTempPin(double x, double y) {
    var param = <String, double>{MethodParameters.X: x, MethodParameters.Y: y};
    return _asiteChannel.invokeMethod(AFunctions.createTempPin, <String, dynamic>{MethodParameters.param: jsonEncode(param)});
  }

  Future<void> renderPinsFromObservationList(dynamic observationList, {String? highLightFormId}) {
    return _asiteChannel.invokeListMethod(AFunctions.renderPinsFromObservationList, <String, dynamic>{MethodParameters.observationList: observationList, MethodParameters.highLightFormId: highLightFormId});
  }

  Future<String?>? generateThumbnail(int pageNumber, String thumbnailFilePath) {
    var param = <String, dynamic>{MethodParameters.pageNumber: pageNumber, MethodParameters.thumbFilePath: thumbnailFilePath};
    return _asiteChannel.invokeMethod(AFunctions.generateThumbnail, <String, dynamic>{MethodParameters.param: jsonEncode(param)});
  }

  Future<String?>? getAnnotationIdAt(double x, double y) async {
    var param = <String, double>{MethodParameters.X: x, MethodParameters.Y: y};
    String? annotationId = await _asiteChannel.invokeMethod(AFunctions.getAnnotationIdAt, param);
    return annotationId;
  }

  Future<Map<String, dynamic>?>? convertScreenPtToPagePt(double x, double y) async {
    var param = <String, double>{MethodParameters.X: x, MethodParameters.Y: y};
    var response = await _asiteChannel.invokeMethod(AFunctions.convertScreenPtToPagePt, param);
    if (response != null) {
      var jsonObj = jsonDecode(response);
      Map<String, double> map = {};
      map["X"] = double.parse(jsonObj["X"].toString());
      map["Y"] = double.parse(jsonObj["Y"].toString());
      return map;
    }
    return null;
  }

  Future<Map<String, dynamic>?>? convertPagePtToScreenPt(double x, double y) async {
    var param = <String, double>{MethodParameters.X: x, MethodParameters.Y: y};
    var response = await _asiteChannel.invokeMethod(AFunctions.convertPagePtToScreenPt, param);
    if (response != null) {
      var jsonObj = jsonDecode(response);
      Map<String, double> map = {};
      map["X"] = double.parse(jsonObj["X"].toString());
      map["Y"] = double.parse(jsonObj["Y"].toString());
      return map;
    }
    return null;
  }

  Future<int>? getCurrentPageNumber() async {
    return await _asiteChannel.invokeMethod(AFunctions.getCurrentPageNumber);
  }

  Future<String>? getUniqueAnnotationID() async {
    return await _asiteChannel.invokeMethod(AFunctions.getUniqueAnnotationId);
  }

  Future<bool>? setInteractionEnabled(bool interactionEnabled) async {
    var param = <String, bool>{MethodParameters.interactionEnabled: interactionEnabled};
    return await _asiteChannel.invokeMethod(AFunctions.interactionEnabled, param) ?? false;
  }

  Future<void> polygonAnnotation(double x1, double y1, double locationAngle, double annotId) {
    var param = <String, double>{PolygonParameters.x1: x1, PolygonParameters.y1: y1, PolygonParameters.locationAngle: locationAngle, PolygonParameters.annotationId: annotId};
    return _asiteChannel.invokeMethod(AFunctions.polygonAnnotation, <String, dynamic>{MethodParameters.param: jsonEncode(param)});
  }
}
