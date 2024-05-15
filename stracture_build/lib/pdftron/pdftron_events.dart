import 'dart:convert';

import 'package:field/pdftron/pdftron_constants.dart';
import 'package:flutter/services.dart';

typedef OnLongPressDocumentListener = void Function(double x, double y);
typedef OnPressDocumentListener = void Function(double x, double y);
typedef OnZoomDocumentListener = void Function(double x, double y);
typedef OnAnnotationSelectedListener = void Function(
    String selectedAnnotationId, bool isLocationAnnot);
typedef OnPinTapListener = void Function(
    String formId, double width, double height);
typedef CancelListener = void Function();

enum EventSinkId {
  onAnnotationSelected,
  onLongPressDocument,
  onPinTap,
  onPressDocument,
  onZoomDocument
}

const EventChannel _channelOnAnnotationSelectedListener =
    EventChannel(EventConstant.onAnnotationSelectedListener);
const EventChannel _channelOnLongPressDocumentListener =
    EventChannel(EventConstant.onLongPressDocumentListener);
const EventChannel _channelOnPressDocumentListener =
    EventChannel(EventConstant.onPressDocumentListener);

const EventChannel _channelOnZoomDocumentListener =
    EventChannel(EventConstant.onZoomDocumentListener);

const EventChannel _channelOnPinTapListener =
    EventChannel(EventConstant.onPinTapListener);

CancelListener onAnnotationSelectedListener(
    OnAnnotationSelectedListener listener) {
  var subscription = _channelOnAnnotationSelectedListener
      .receiveBroadcastStream(EventSinkId.onAnnotationSelected.index)
      .listen((dataJson) {
    dynamic selectedAnnotationJson = jsonDecode(dataJson);
    String selectedAnnotationId = selectedAnnotationJson["annotationId"];
    bool isLocationAnnot = selectedAnnotationJson["isLocationAnnot"];
    listener(selectedAnnotationId, isLocationAnnot);
  }, cancelOnError: true);
  return () {
    subscription.cancel();
  };
}

CancelListener onLongPressDocumentListener(
    OnLongPressDocumentListener listener) {
  var subscription = _channelOnLongPressDocumentListener
      .receiveBroadcastStream(EventSinkId.onLongPressDocument.index)
      .listen((dataJson) {
    dynamic longPressObject = jsonDecode(dataJson);
    double x = double.parse(longPressObject[MethodParameters.X].toString());
    double y = double.parse(longPressObject[MethodParameters.Y].toString());
    listener(x, y);
  }, cancelOnError: true);
  return () {
    subscription.cancel();
  };
}

CancelListener onPressDocumentListener(OnPressDocumentListener listener) {
  var subscription = _channelOnPressDocumentListener
      .receiveBroadcastStream(EventSinkId.onPressDocument.index)
      .listen((dataJson) {
    dynamic longPressObject = jsonDecode(dataJson);
    double x = double.parse(longPressObject[MethodParameters.X].toString());
    double y = double.parse(longPressObject[MethodParameters.Y].toString());
    listener(x, y);
  }, cancelOnError: true);
  return () {
    subscription.cancel();
  };
}

CancelListener onZoomDocumentListener(OnZoomDocumentListener listener) {
  var subscription = _channelOnZoomDocumentListener
      .receiveBroadcastStream(EventSinkId.onZoomDocument.index)
      .listen((dataJson) {
    dynamic zoomObject = jsonDecode(dataJson);
    double x = double.parse(zoomObject[MethodParameters.X].toString());
    double y = double.parse(zoomObject[MethodParameters.Y].toString());
    listener(x, y);
  }, cancelOnError: true);
  return () {
    subscription.cancel();
  };
}

CancelListener onPinTapListener(OnPinTapListener listener) {
  var subscription = _channelOnPinTapListener
      .receiveBroadcastStream(EventSinkId.onPinTap.index)
      .listen((dataJson) {
    dynamic selectedAnnotationJson = jsonDecode(dataJson);
    String formId = selectedAnnotationJson["formId"];
    double width = double.parse(selectedAnnotationJson["width"].toString());
    double height = double.parse(selectedAnnotationJson["height"].toString());
    listener(formId, width, height);
  }, cancelOnError: true);
  return () {
    subscription.cancel();
  };
}
