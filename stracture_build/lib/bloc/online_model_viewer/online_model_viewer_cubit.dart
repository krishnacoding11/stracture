import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:field/bloc/cBim_settings/cBim_settings_cubit.dart';
import 'package:field/bloc/pdf_tron/pdf_tron_cubit.dart';
import 'package:field/bloc/side_tool_bar/side_tool_bar_cubit.dart';
import 'package:field/data/model/bim_object_data.dart';
import 'package:field/data/model/bim_project_model_vo.dart';
import 'package:field/data/model/calibrated.dart';
import 'package:field/data/model/file_association_model.dart';
import 'package:field/data/model/get_threed_type_list.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/exception/app_exception.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/actionIdConstants.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../data/model/view_object_details_model.dart';
import '../../domain/use_cases/online_model_vewer_use_case.dart';
import '../../presentation/base/state_renderer/state_renderer.dart';
import '../../utils/file_form_utility.dart';
import '../../utils/requestParamsConstants.dart';
import '../../utils/url_helper.dart';
import '../../utils/utils.dart';

part 'online_model_viewer_state.dart';

class OnlineModelViewerCubit extends Cubit<OnlineModelViewerState> {
  final OnlineModelViewerUseCase _onlineModelViewerUseCase;

  OnlineModelViewerCubit({OnlineModelViewerUseCase? onlineModelViewerUseCase})
      : _onlineModelViewerUseCase = onlineModelViewerUseCase ?? getIt<OnlineModelViewerUseCase>(),
        super(PaginationListInitial());
  String totalNumbersOfModels = "1";
  String totalNumbersOfModelsLoad = "1";
  String totalNumbersOfModelsLoadFailed = "0";
  bool colorPopupVisible = false;
  bool isShowSideToolBar = false;
  double x = 0.0;
  double y = 0.0;
  double x1 = 0.0;
  double y1 = 0.0;
  bool widthFull = false;
  late InAppWebViewController webviewController;
  late InAppWebViewController animationWebviewController;
  List<String> bimModelListData = [];
  late Project selectedProject;
  double posX = 100.0;
  double posY = 100.0;
  double width = 0.0;
  double height = 0.0;
  late Offset tapXY;
  bool isEditMenuVisible = false;
  bool isRulerMenuVisible = false;
  bool is3DVisible = true;
  bool isCuttingPlaneMenuVisible = false;
  bool isMarkupMenuVisible = false;
  bool isPdfListingVisible = false;
  Color currentColor = const Color(0xff443a49);
  Color pickerColor = const Color.fromARGB(255, 255, 0, 0);
  bool isPictureInPictureMode = false;
  bool isFirstTime = true;
  bool isShowPdf = false;
  bool isFullPdf = false;
  bool isCalibListPressed = false;
  bool isModelLoaded = false;
  dynamic jsonDataForSaveColor;
  List<String> offlineFilePath = [];
  List<CalibrationDetails> calibList = [];
  String selectedPdfFileName = '';
  String selectedCalibrationName = '';
  bool isShowPdfView = false;
  bool isShowContextMenu = false;
  final PdfTronCubit _pdfTronCubit = getIt<PdfTronCubit>();
  String selectedModelId = "";
  late Map<String, dynamic> offlineParams;
  List<Uint8List> stringToBase64ModelList = [];
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  List<Detail> detailsList = [];
  List<FileAssociation> fileAssociationList = [];
  List<CalibrationDetails> calibrationList = [];
  final GlobalKey<ScaffoldState> modelScaffoldKey = GlobalKey<ScaffoldState>();
  bool isFileAssociation = false;
  bool _isModelTreeOpen = false;
  var fileNameList = [];
  bool isDialogShowing = false;
  bool isShowing = false;
  bool isUnitCalibrationDialogShowing = false;
  bool isSnaggingOpen = false;
  bool isSnaggingFilterOpen = false;
  bool isTaskFormListing = false;

  bool get isModelTreeOpen => _isModelTreeOpen;
  bool isCalibListShow = false;
  bool isCalibListEmptyFromApi = false;
  List<IfcObjects>? onlineCubitBimModelList = [];
  String snaggingCoordinatesX = "";
  String snaggingCoordinatesY = "";
  String snaggingCoordinatesZ = "";
  String snaggingGuId = "";
  List<Datum> datumAppTypeList = [];

  set isModelTreeOpen(bool value) {
    emit(NormalState());
    _isModelTreeOpen = value;
  }

  void isSnaggingClick() {
    emit(NormalState());
    isSnaggingOpen = true;
    if (isSnaggingFilterOpen) {
      isSnaggingFilterOpen = false;
    }
    emit(NormalWebState());
  }

  void closeSnaggingFilter() {
    emit(NormalState());
    isSnaggingOpen = false;
    if (isSnaggingFilterOpen) {
      isSnaggingFilterOpen = false;
    }
    emit(NormalWebState());
  }

  void isSnaggingFilterClick() {
    emit(NormalState());
    isSnaggingFilterOpen = !isSnaggingFilterOpen;
    // if (isSnaggingOpen) {
    //   isSnaggingOpen = false;
    // }
    emit(NormalWebState());
  }

  getModelFileData(List<IfcObjects>? bimModelList, String modelName) async {
    bimModelListData = [];
    selectedProject = (await StorePreference.getSelectedProjectData())!;
    for (int i = 0; i < bimModelList!.length; i++) {
      String modelDetails = selectedProject.projectID.toString().plainValue() + "/" + bimModelList[i].ifcObjects![0].folderId!.plainValue() + "/" + bimModelList[i].ifcObjects![0].revId.plainValue() + "/" + bimModelList[i].ifcObjects![0].revId.plainValue();
      bimModelListData.add(modelDetails);
    }
    if (isNetWorkConnected()) {
      totalNumbersOfModels = bimModelList.length.toString();
    }
  }

  Future<List<CalibrationDetails>> getCalibrationList(String projectId, String modelId, bool isPopup) async {
    isCalibListShow = true;
    if (!isPopup) {
      emit(CalibrationListLoadingState());
    } else {
      _pdfTronCubit.emit(PDFDownloading());
    }
    try {
      if (isNetWorkConnected()) {
        var result = await _onlineModelViewerUseCase.getCalibrationList(projectId, modelId);
        if (result != null) {
          calibrationList = List<CalibrationDetails>.from(result.data.map(
            (e) => CalibrationDetails.fromJson(e),
          ));
          isCalibListEmptyFromApi = calibrationList.isEmpty;
        }
      } else {
        calibrationList = calibrationList.isEmpty ? offlineParams[RequestConstants.calibrateList] ?? [] : calibrationList;
        isCalibListEmptyFromApi = calibrationList.isEmpty;
      }
      if (!isPopup) {
        emit(calibrationList.isNotEmpty ? CalibrationListResponseSuccessState(items: calibrationList) : CalibrationListResponseSuccessState(items: const []));
      } else {
        emit(LoadedState());
        _pdfTronCubit.emit(PDFDownloaded());
      }
    } on AppException catch (e) {
      emit(ErrorState(exception: e));
    }
    isFirstTime = false;
    return calibrationList.toList();
  }

  calibListPresentState() {
    calibList.clear();
    emit(CalibrationListPresentState());
  }

  togglePdfTronVisibility(bool isShow, String pdfFileName, bool isFullPdf1, bool isShowColorPopup) {
    if (isFullPdf1) {
      isFullPdf = !isFullPdf;
    }
    isShowPdfView = isShow;
    emit(MenuOptionLoadedState(isEditMenuVisible, isMarkupMenuVisible, isRulerMenuVisible, isCuttingPlaneMenuVisible, isShowPdfView, isFullPdf, isShowColorPopup, pdfFileName));
  }

  resetPdfTronVisibility(bool isShow, String pdfFileName, bool isFullPdf1) {
    isShowPdfView = isShow;
    emit(MenuOptionLoadedState(isEditMenuVisible, isMarkupMenuVisible, isRulerMenuVisible, isCuttingPlaneMenuVisible, isShow, isFullPdf1, false, pdfFileName));
  }

  toggleEditMenuVisibility() {
    isEditMenuVisible = !isEditMenuVisible;
    isMarkupMenuVisible = false;
    isRulerMenuVisible = false;
    isCuttingPlaneMenuVisible = false;
    isShowPdfView = false;
    emit(MenuOptionLoadedState(isEditMenuVisible, isMarkupMenuVisible, isRulerMenuVisible, isCuttingPlaneMenuVisible, isShowPdfView, false, false, ""));
  }

  toggleMarkerMenuVisibility() {
    isEditMenuVisible = true;
    isMarkupMenuVisible = !isMarkupMenuVisible;
    isRulerMenuVisible = false;
    isCuttingPlaneMenuVisible = false;
    isShowPdfView = false;
    emit(MenuOptionLoadedState(isEditMenuVisible, isMarkupMenuVisible, isRulerMenuVisible, isCuttingPlaneMenuVisible, isShowPdfView, false, false, ""));
  }

  toggleRulerMenuVisibility() {
    isRulerMenuVisible = !isRulerMenuVisible;
    isMarkupMenuVisible = false;
    isCuttingPlaneMenuVisible = false;
    isEditMenuVisible = true;
    isShowPdfView = false;
    emit(MenuOptionLoadedState(isEditMenuVisible, isMarkupMenuVisible, isRulerMenuVisible, isCuttingPlaneMenuVisible, isShowPdfView, false, false, ""));
  }

  toggleCuttingPlaneMenuVisibility() {
    isCuttingPlaneMenuVisible = !isCuttingPlaneMenuVisible;
    isMarkupMenuVisible = false;
    isEditMenuVisible = true;
    isRulerMenuVisible = false;
    isShowPdfView = false;
    emit(MenuOptionLoadedState(isEditMenuVisible, isMarkupMenuVisible, isRulerMenuVisible, isCuttingPlaneMenuVisible, isShowPdfView, false, false, ""));
  }

  toggleAllMenusVisibility() {
    isEditMenuVisible = false;
    isMarkupMenuVisible = false;
    isRulerMenuVisible = false;
    isCuttingPlaneMenuVisible = false;
    isShowPdfView = false;
    emit(MenuOptionLoadedState(isEditMenuVisible, isMarkupMenuVisible, isRulerMenuVisible, isCuttingPlaneMenuVisible, isShowPdfView, false, false, ""));
  }

  loadModelOnline(String projectId, String modelId, String revId, List<IfcObjects>? bimModelList) async {
    onlineCubitBimModelList = bimModelList;
    emit(LoadingState());
    if (!isNetWorkConnected()) {
      stringToBase64ModelList.clear();
      Future.delayed(const Duration(seconds: 4), () async {
        for (int i = 0; i < offlineFilePath.length; i++) {
          Future<Uint8List> fileHtmlContents = File(offlineFilePath[i]).readAsBytes();
          stringToBase64ModelList.add(await fileHtmlContents);
        }
        Future.delayed(Duration(seconds: 2));
        for (int i = 0; i < stringToBase64ModelList.length; ++i) {
          webviewController.evaluateJavascript(source: 'javascript:nCircle.Model.loadFile({fileName : `${fileNameList[i]}`,scsBuffer : `${base64Encode(stringToBase64ModelList[i])}`});');
        }
        if (stringToBase64ModelList.isNotEmpty) {
          stringToBase64ModelList.removeAt(0);
        }
        emit(LoadedState());
      }).then((value) {});
    } else {
      if (bimModelListData.isNotEmpty) {
        Future.delayed(const Duration(seconds: 3), () {
          webviewController.evaluateJavascript(
            source: 'javascript:LoadOnlineModel(`${bimModelListData.toString().replaceAll("[", "").replaceAll("]", "")}`,"${AConstants.streamingServerUrl}");',
          );
          if (bimModelListData.isNotEmpty) {
            bimModelListData.removeAt(0);
          }
          emit(LoadedState());
        }).then((value) {
          Future.delayed(const Duration(seconds: 1), () {
            if (bimModelListData.isNotEmpty) {
              emit(LoadedState());
            }
          });
        });
      } else {
        emit(ErrorState(exception: AppException(message: "No current project assigned")));
      }
    }

    webviewController.addJavaScriptHandler(
        handlerName: 'failedModels',
        callback: (args) {
          emit(LoadingModelsState());
          totalNumbersOfModelsLoadFailed = args.toString().replaceAll("[", "").replaceAll("]", "");
          emit(FailedModelState());
        });

    webviewController.addJavaScriptHandler(
        handlerName: 'setBimObjectData',
        callback: (args) async {
          List<BimData> bimdata = [];

          if (args.isNotEmpty) {
            var docId = onlineCubitBimModelList?.first.docId;
            bimdata = bimDataFromJson(args.toString());
            bimdata.first.bimObjectsData.first.docId = docId.plainValue();
          }

          snaggingGuId = '${jsonEncode(bimdata.first)}';
        });

    webviewController.addJavaScriptHandler(
        handlerName: 'getBimObjectColorStatus',
        callback: (args) {
          String value = args.toString().replaceAll("[", "").replaceAll("]", "");
          if (value.trim().isNotEmpty) {
            Color color = fromHex(value);
            pickerColor = Color.fromARGB(color.alpha, color.red, color.green, color.blue);
          }
          getIt<SideToolBarCubit>().isColorAppliedToObject = value;
        });

    webviewController.addJavaScriptHandler(
        handlerName: 'saveBimObjectColor',
        callback: (args) {
          jsonDataForSaveColor = args;
          saveColor(projectId, modelId, "", true);
        });

    webviewController.addJavaScriptHandler(
        handlerName: 'removeBimObjectColor',
        callback: (args) {
          jsonDataForSaveColor = args;
          saveColor(projectId, modelId, "", false);
        });

    webviewController.addJavaScriptHandler(
        handlerName: 'webGlContextLost',
        callback: (args) {
          emit(WebGlContextLostState());
        });

    webviewController.addJavaScriptHandler(
        handlerName: 'timeoutWarning',
        callback: (args) {
          emit(TimeoutWarningState());
        });

    webviewController.addJavaScriptHandler(
        handlerName: 'timeout',
        callback: (args) {
          emit(TimeOutState());
        });

    webviewController.addJavaScriptHandler(
        handlerName: 'websocketConnectionClosed',
        callback: (args) {
          emit(WebsocketConnectionClosedState());
        });

    webviewController.addJavaScriptHandler(
        handlerName: 'modelLoadFailure',
        callback: (args) {
          emit(ModelLoadFailureState());
        });

    webviewController.addJavaScriptHandler(
        handlerName: 'getModelsLoaded',
        callback: (args) {
          emit(LoadingModelsState());
          totalNumbersOfModelsLoad = args.toString().replaceAll("[", "").replaceAll("]", "");
          Future.delayed(const Duration(seconds: 2));
          emit(LoadedModelState());

          if (totalNumbersOfModels == totalNumbersOfModelsLoad) {
            emit(LoadedAllModelState());
            Future.delayed(const Duration(seconds: 1), () {
              emit(LoadedSuccessfullyState());
            });
            if (!isNetWorkConnected()) {
              Future.delayed(const Duration(seconds: 2), () {
                emit(LoadedSuccessfulAllModelState());
              });
            }
          }
        });

    webviewController.addJavaScriptHandler(
        handlerName: 'getModelsDeleted',
        callback: (args) {
          emit(DeletedModelState());
          Future.delayed(const Duration(seconds: 2));
          emit(LoadedAllModelState());
          Future.delayed(const Duration(seconds: 1), () {
            emit(LoadedSuccessfullyState());
          });
          if (!isNetWorkConnected()) {
            Future.delayed(const Duration(seconds: 2), () {
              emit(LoadedSuccessfulAllModelState());
            });
          }
        });

    webviewController.addJavaScriptHandler(
        handlerName: 'streamingDeactivated',
        callback: (args) {
          if (totalNumbersOfModels == totalNumbersOfModelsLoad) {
            Future.delayed(const Duration(seconds: 2), () {
              emit(LoadedSuccessfulAllModelState());
            });
          }
        });

    webviewController.addJavaScriptHandler(
        handlerName: 'getJoystickCoordinates',
        callback: (args) {
          emit(GetJoystickCoordinatesState(args[0].toString().split(',')[0], args[0].toString().split(',')[1]));
        });

    webviewController.addJavaScriptHandler(
        handlerName: 'getObjectDetails',
        callback: (args) {
          if (args.isNotEmpty) {
            detailsList = viewObjectDetailsModelFromJson(args[0]).details;
            isFileAssociation = false;
            if (Utility.isIos) {
              callViewObjectFileAssociationDetails();
            }
            key.currentState?.openEndDrawer();
          }
        });
  }

  String getFileRevId(List<IfcObjects>? bimModelList, List<dynamic> args, String fileRevisionId) {
    for (int i = 0; i < bimModelList!.length; i++) {
      if (args.toString().replaceAll("[", "").replaceAll("]", "").split(",")[1] == bimModelList[i].ifcObjects![0].revId!.toString().plainValue()) {
        fileRevisionId = bimModelList[i].ifcObjects![0].revId!;
      }
    }
    return fileRevisionId;
  }

  Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  refreshUI(bool showState) {
    if (showState == true) {
      colorPopupVisible = true;
      emit(ShowPopUpState());
    } else {
      colorPopupVisible = false;
      emit(HIdePopUpState());
    }
  }

  void getFileAssociation(projectId, modelId, revisionId, guid) async {
    emit(FileAssociationLoadingState());
    Map<String, dynamic> map = {};
    map[RequestConstants.actionId] = ActionConstants.actionId1013;
    map[RequestConstants.projectId] = projectId;
    map[RequestConstants.model_id] = modelId;
    map[RequestConstants.revisionId] = revisionId;
    map[RequestConstants.guid] = guid;
    dynamic result = await _onlineModelViewerUseCase.getFileAssociationList(map);
    if (result is SUCCESS) {
      fileAssociationList = List<FileAssociation>.from(json.decode(result.data).map((x) => FileAssociation.fromJson(x)));
      isFileAssociation = true;
      emit(GetFileAssociationListState());
      if (Utility.isIos) {
        callViewObjectFileAssociationDetails();
      }
      key.currentState?.openEndDrawer();
    } else {
      emit(NormalState());
    }
  }

  insufficientStorage() {
    emit(InsufficientStorageState());
  }

  Future<void> setParallelViewAuditTrail(String projectId, String accessedValue, String accessedType, String actionId, String modelId, String objectId) async {
    await _onlineModelViewerUseCase.setParallelViewAuditTrail(getRequestMapDataForAuditTrail(projectId, accessedValue, accessedType, actionId, modelId, objectId), projectId);
  }

  Map<String, dynamic> getRequestMapDataForAuditTrail(projectId, accessedValue, accessedType, actionId, modelId, objectId) {
    Map<String, dynamic> map = {};
    map[RequestConstants.project_id] = projectId;
    map[RequestConstants.model_id] = modelId;
    map[RequestConstants.actionId] = actionId;
    if (accessedType.toString().toLowerCase() != "Set Offline".toLowerCase()) {
      map[RequestConstants.objectId] = objectId;
      map[RequestConstants.remarks] = "Accessed From:$accessedValue,Accessed Type:$accessedType";
    }
    return map;
  }

  Map<String, dynamic> getRequestBodyForSaveColor(projectId, modelId, isAssign) {
    Map<String, dynamic> map = {};
    map[RequestConstants.modelId] = modelId;
    map[RequestConstants.projectId] = projectId;
    map[RequestConstants.operation] = isAssign ? "assign" : "remove";
    map[RequestConstants.jsonData] = jsonDataForSaveColor.toString();
    return map;
  }

  Future<dynamic> saveColor(String projectId, String modelId, String colorId, bool isAssign) async {
    var result;
    try {
      if (isNetWorkConnected()) {
        result = await _onlineModelViewerUseCase.saveColor(getRequestBodyForSaveColor(projectId, modelId, isAssign), projectId);
      }
    } on AppException catch (e) {
      emit(ErrorState(exception: e));
    }
    return result;
  }

  Future<dynamic> getColor(String projectId, String modelId) async {
    var result;
    try {
      if (isNetWorkConnected()) {
        result = await _onlineModelViewerUseCase.getColor(projectId, modelId);
        var responseString = result.data.toString();
        var objectList = responseString.replaceAll('[', '').replaceAll(']', '').replaceAll('}', '').replaceAll('{', '').split(',');
        var primaryList = [];
        var secondaryList = [];
        for (int i = 0; i < objectList.length; ++i) {
          if (objectList[i].contains('color')) {
            primaryList.add(objectList[i].split(":")[1].removeWhitespace());
          }
          if (objectList[i].contains('uniqueId')) {
            secondaryList.add(objectList[i].split(":")[1].removeWhitespace());
          }
        }
        String colorString = '[';
        for (int i = 0; i < primaryList.length; ++i) {
          if (i == primaryList.length - 1) {
            colorString += '{uniqueId : "${secondaryList[i]}" , color : "${primaryList[i]}"}]';
          } else {
            colorString += '{uniqueId : "${secondaryList[i]}" , color : "${primaryList[i]}"},';
          }
        }
        webviewController.evaluateJavascript(source: "nCircle.Ui.ContextMenu.getBimObjectColor($colorString);");
      }
    } on AppException catch (e) {
      emit(ErrorState(exception: e));
    }
    return result;
  }

  setNavigationSpeed({double? newValue}) {
    if (isModelLoaded) {
      var value = newValue != null ? newValue : getIt<CBIMSettingsCubit>().selectedSliderValue.toInt();
      webviewController.evaluateJavascript(source: "nCircle.Ui.Toolbar.setNavigationMultiplier($value);");
    }
  }

  callViewObjectFileAssociationDetails() {
    emit(ShowBackGroundWebviewState());
  }

  emitNormalWebState() {
    emit(NormalWebState());
  }

  emitUnitCalibrationUpdateState() {
    emit(UnitCalibrationUpdateState());
  }

  emitLoadedSuccessfulAllModelState() {
    emit(LoadedSuccessfulAllModelState());
  }

  emitAddPinOnModelState() {
    emit(AddPinOnModelState());
  }

  void removePdfListView() {
    isCalibListShow = false;
    getIt<SideToolBarCubit>().isWhite = false;
    calibListPresentState();
    emit(NormalWebState());
  }

  Future<void> navigateToCreateTask({double? x, double? y, Datum? appType, String? from, required String bimModelId, required String dcId}) async {
    var projectId = selectedProject.projectID.toString();
    var formTypeId = appType!.formTypeId;
    String createTaskUrl = "";
    Map<String, dynamic> param = {};
    var strFormSelectRadiobutton = dcId + '_' + projectId + '_' + formTypeId + '_';
    param['formSelectRadiobutton'] = strFormSelectRadiobutton;
    param['screen'] = "new";
    param['isAndroid'] = Platform.isAndroid;
    param['application_id'] = "3";
    param['applicationId'] = "3";
    param['isFromApps'] = "true";
    param['isFromCbim'] = "true";
    param['isNewUI'] = "true";
    param['bim_model_id'] = bimModelId;
    param['isFromWhere'] = "4";
    if (isNetWorkConnected()) {
      createTaskUrl = await UrlHelper.getCreateFormURLForCBim(param);
    } else {
      param['formTypeId'] = formTypeId;
      param['instanceGroupId'] = appType.instanceGroupId;
      param['templateType'] = appType.templateType;
      param['appBuilderId'] = appType.appBuilderCode;
      param['revisionId'] = onlineCubitBimModelList![0].ifcObjects![0].revId.toString();
      param['offlineFormId'] = DateTime.now().millisecondsSinceEpoch;
      param['isUploadAttachmentInTemp'] = true;
      createTaskUrl = await FileFormUtility.getOfflineCreateFormPath(param);
    }
    param['url'] = createTaskUrl;

    param['isFrom'] = FromScreen.longPress;

    callViewObjectFileAssociationDetails();
    _setPlanState(CreateTaskNavigationState(createTaskUrl, param, appType));
  }

  void _setPlanState(OnlineModelViewerState onlineModelViewerState) {
    emit(onlineModelViewerState);
  }

  Future<dynamic> getThreeDAppTypeList(String projectId) async {
    var result;
    try {
      if (isNetWorkConnected()) {
        Map<String, dynamic> map = {};
        map[RequestConstants.actionId] = ActionConstants.actionId118;
        map[RequestConstants.projectId] = projectId;
        map["isFromWhere"] = "4";
        map["recordBatchSize"] = "250";
        map["appType"] = "1";
        result = await _onlineModelViewerUseCase.getThreeDAppTypeList(map);
        if (result is SUCCESS) {}
        datumAppTypeList = getThreedAppTypeFromJson(result.data).data;
      }
    } on AppException catch (e) {
      emit(ErrorState(exception: e));
    }
    return result;
  }
}
