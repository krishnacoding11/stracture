import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:asite_plugins/asite_plugins.dart';
import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/site/plan_loading_state.dart';
import 'package:field/data/model/pinsdata_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/domain/use_cases/Filter/filter_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/screen/site_routes/site_plan_viewer_screen.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/file_form_utility.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/url_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:pdftron_flutter/pdftron_flutter.dart';

import '../../analytics/event_analytics.dart';
import '../../data/local/site/site_local_repository.dart';
import '../../data/model/apptype_vo.dart';
import '../../data/model/form_vo.dart';
import '../../data/model/site_location.dart';
import '../../data/repository/site/location_tree_repository.dart';
import '../../domain/use_cases/site/site_use_case.dart';
import '../../domain/use_cases/sitetask/sitetask_usecase.dart';
import '../../injection_container.dart';
import '../../logger/logger.dart';
import '../../networking/network_response.dart';
import '../../pdftron/pdftron_config.dart';
import '../../pdftron/pdftron_document_view.dart';
import '../../pdftron/pdftron_events.dart';
import '../../presentation/screen/site_routes/site_end_drawer/site_item/site_item.dart';
import '../../utils/app_config.dart';
import '../../utils/constants.dart';
import '../../utils/download_service.dart';
import '../../utils/site_utils.dart';
import '../../utils/toolbar_mixin.dart';
import '../../utils/user_activity_preference.dart';
import '../../utils/utils.dart';
import '../sitetask/sitetask_state.dart';

class PlanCubit extends BaseCubit with ToolbarTitle {
  PlanCubit({SiteUseCase? siteUseCase, SiteTaskUseCase? siteTaskUseCase, FilterUseCase? filterUseCase})
      : _siteUseCase = siteUseCase ?? di.getIt<SiteUseCase>(),
        _siteTaskUseCase = siteTaskUseCase ?? di.getIt<SiteTaskUseCase>(),
        _filterUseCase = filterUseCase ?? di.getIt<FilterUseCase>(),
        super(InitialState(stateRendererType: StateRendererType.DEFAULT));

  final SiteUseCase _siteUseCase;
  final SiteTaskUseCase _siteTaskUseCase;
  final FilterUseCase _filterUseCase;

  final List<SiteLocation> _siteLocationList = [];

  List<ObservationData> _observationList = [];
  Project? _project;
  SiteLocation? _selectedLocation;
  String? _revisionId;
  String? _pdfPath;
  String? _xfdfPath;
  PdftronDocumentViewController? _pdftronDocumentViewController;
  final Config _config = getSiteTabConfig();
  bool isVisibleFormView = false;
  bool isFromQuality = false;

  Project? get project => _project;

  List<SiteLocation>? get siteLocationList => _siteLocationList;

  SiteLocation? get selectedLocation => _selectedLocation;
  List<dynamic> _listBreadCrumb = [];

  List<dynamic> get listBreadCrumb => _listBreadCrumb;
  LinkedHashMap<String, List<SiteLocation>?> _mapLocations = LinkedHashMap();
  final HashMap<String, List<SiteLocation>?> _mapAnnotationLocationList = HashMap();
  String? highLightFormId;
  String? _selectedFormCode;
  Pins? currentPinsType = Pins.all;
  dynamic isFromScreen;
  String? _searchSummaryValue;

  Future<void> _setCurrentSiteLocation(SiteLocation? location) async {
    _selectedLocation = location;
    _selectedLocation?.projectId = project?.projectID;
    if (_selectedLocation != null) {
      updateTitle(_selectedLocation!.folderTitle, NavigationMenuItemType.sites);
    } else {
      _setPlanErrorState();
    }
    refreshSiteTaskList();
    await saveLastLocationData();
  }

  Future<void> _setCurrentSiteProject(Project? proj) async {
    _selectedLocation = null;
    updateTitle(proj!.projectName, NavigationMenuItemType.sites);
    refreshSiteTaskList();
    await removeLastLocationData();
    _setPlanState(LastLocationChangeState());
  }

  refreshSiteTaskList() {
    _setPlanState(RefreshSiteTaskListState());
  }

  Future<void> saveLastLocationData() async {
    await setLastLocationData(_selectedLocation!);
    //added for recent location update
    _setPlanState(LastLocationChangeState());
  }

  List<dynamic> createLocationListBreadCrumb(dynamic args) {
    SiteLocation? selectedLocation = args[0];
    List<dynamic> originalListBreadCrumb = args[1];
    LinkedHashMap<String, List<SiteLocation>?>? mapLocations = args[2];
    final HashMap<String, List<SiteLocation>?> mapAnnotationLocationList = args[3];
    List<dynamic> listBreadCrumb = [];
    //Add Project at first Position
    if (originalListBreadCrumb.isNotEmpty) {
      listBreadCrumb.add(originalListBreadCrumb[0]);
    }

    try {
      int parentLocationId = selectedLocation?.pfLocationTreeDetail?.parentLocationId ?? 0;
      while (parentLocationId > 0) {
        SiteLocation? siteLocation;
        for (int i = originalListBreadCrumb.length - 1; i > 0; i--) {
          if (originalListBreadCrumb[i] is SiteLocation) {
            List<SiteLocation> siteLocationList = [originalListBreadCrumb[i]];
            siteLocation = SiteUtility.getLocationFromLocationId(parentLocationId, siteLocationList);
            if (siteLocation != null) {
              break;
            }
          }
        }
        if (siteLocation == null) {
          for (var item in mapAnnotationLocationList.values) {
            siteLocation = SiteUtility.getLocationFromLocationId(parentLocationId, item);
            if (siteLocation != null) {
              break;
            }
          }
        }
        siteLocation ??= SiteUtility.getLocationFromLocationId(parentLocationId, null, mapSiteLocation: mapLocations);
        if (siteLocation != null) {
          listBreadCrumb.insert(1, siteLocation);
          parentLocationId = siteLocation.pfLocationTreeDetail?.parentLocationId ?? 0;
        } else {
          parentLocationId = 0;
        }
      }
      if (selectedLocation != null && selectedLocation.hasSubFolder != null && selectedLocation.hasSubFolder!) {
        listBreadCrumb.add(selectedLocation);
      }
    } catch (e) {
      Log.d(e);
    }
    return listBreadCrumb;
  }

  Future<SiteLocation?>? getLocationFromAnnotationId(dynamic args) async {
    String selectedAnnotationId = args[0];
    final List<SiteLocation>? siteLocationList = args[1];
    LinkedHashMap<String, List<SiteLocation>?>? mapLocations = args[2];
    return await SiteUtility.getLocationFromAnnotationId(selectedAnnotationId, siteLocationList, mapSiteLocation: mapLocations);
  }

  void _setPlanState(FlowState flowState) {
    emitState(flowState);
  }

  Future<void> intializePDFTron() async {
    AppConfig appConfig = di.getIt<AppConfig>();
    String? pdfKey = appConfig.syncPropertyDetails?.pdftronAndroidIosKey;
    await _pdftronDocumentViewController?.getPDFTronLicenseKey(pdfKey);
  }

  /// Download Pdf and Xfdf if location has plan
  /// Check if current plan is already loaded with this revision Id then just highlight location if location is calibrated
  Future<void> loadPlan() async {
    if (SiteUtility.isLocationHasPlan(_selectedLocation)) {
      setSummaryFilterValue("");
      setFormCodeFilterValue("");
      // check plan already loaded with this revision
      if (_pdftronDocumentViewController != null && _selectedLocation!.pfLocationTreeDetail!.revisionId!.toString().plainValue() == _revisionId.toString().plainValue()) {
        await _pdftronDocumentViewController?.requestResetRenderingPdftron();
        await _highlightLocation(_selectedLocation);
        setHistoryLocationData();
      } else {
        _pdftronDocumentViewController?.closeAllTabs();
        _mapAnnotationLocationList.clear();
        _revisionId = null;
        _pdfPath = null;
        _xfdfPath = null;
        _pdftronDocumentViewController = null;
        _setPlanState(LoadingState(stateRendererType: StateRendererType.POPUP_LOADING_STATE));
        Map<String, dynamic> request = {"projectId": _selectedLocation!.projectId, "folderId": _selectedLocation!.folderId, "revisionId": _selectedLocation!.pfLocationTreeDetail?.revisionId};
        final downloadPdfXfdfResponse = await Future.wait<DownloadResponse>([_siteUseCase.downloadPdf(request, checkFileExist: true), _siteUseCase.downloadXfdf(request, checkFileExist: true)]);
        DownloadResponse downloadPdfResponse = downloadPdfXfdfResponse[0];
        DownloadResponse downloadXdfResponse = downloadPdfXfdfResponse[1];
        _xfdfPath = downloadXdfResponse.outputFilePath;
        if (downloadPdfResponse.isSuccess) {
          _pdfPath = downloadPdfResponse.outputFilePath;
          _revisionId = _selectedLocation!.pfLocationTreeDetail?.revisionId;
          if (_pdfPath != null && _xfdfPath != null) {
            //Sometimes pdftron widget is not created/rebuild mostly when loading from offline so added delay
            await Future.delayed(const Duration(milliseconds: 10));
            _setPlanState(PlanLoadingState(PlanStatus.loadingPlan));
          } else {
            _setPlanErrorState();
          }
        } else {
          _setPlanErrorState();
        }
      }
    } else {
      _setPlanErrorState();
    }
  }

  Future<void> setPinsType(Pins? type) async {
    currentPinsType = type;
    _setPlanState(PinsLoadedState(type: type));
    List<ObservationData> tempList = [..._observationList];
    List<ObservationData> filterList = [];
    if (type == Pins.all) {
      filterList = [...tempList];
    } else if (type == Pins.my) {
      var userId = await StorePreference.getUserId();
      for (var element in tempList) {
        bool isAssigned = false;
        var recipientList = element.recipientList ?? [];
        for (var e in recipientList) {
          if (e.userID.plainValue() == userId.plainValue()) {
            isAssigned = true;
            break;
          }
        }
        var actions = element.actions ?? [];
        if (isAssigned == false) {
          for (var e in actions) {
            if (e.recipientId == int.parse(userId.plainValue())) {
              isAssigned = true;
              break;
            }
          }
        }
        if (isAssigned == true) {
          filterList.add(element);
        }
      }
    }

    if (highLightFormId != null) {
      List<ObservationData> afterHighlightedList = [];
      ObservationData? observationData;
      await _pdftronDocumentViewController?.renderPinsFromObservationList(jsonEncode(afterHighlightedList), highLightFormId: highLightFormId);
      if (filterList.length > 0) {
        int index = filterList.indexWhere((element) => element.formId == highLightFormId);
        if (index > -1) {
          observationData = filterList[index];
          filterList.removeAt(index);
          afterHighlightedList = [...filterList];
          await _pdftronDocumentViewController?.renderPinsFromObservationList(jsonEncode(filterList), highLightFormId: highLightFormId);
          afterHighlightedList.add(observationData);
          await _pdftronDocumentViewController?.renderPinsFromObservationList(jsonEncode(afterHighlightedList), highLightFormId: highLightFormId);
        } else {
          await _pdftronDocumentViewController?.renderPinsFromObservationList(jsonEncode(filterList), highLightFormId: highLightFormId);
        }
      }
    } else {
      await _pdftronDocumentViewController?.renderPinsFromObservationList(jsonEncode(filterList), highLightFormId: highLightFormId);
    }
  }

  void onDocumentViewCreated(PdftronDocumentViewController controller) async {
    _pdftronDocumentViewController = controller;
    intializePDFTron();
    startDocumentLoadedListener((path) async {
      await controller.setBackgroundColor(255, 255, 255);
      await controller.requestResetRenderingPdftron();
      await _mergeXfdf().then((_) async {
        await _deleteAllAnnotationExcludingLocation().then((_) async {
          await _highlightLocation(_selectedLocation);
        });
      });
      _setPlanState(PlanLoadingState(PlanStatus.loadedPlan));
      await controller.setDocumentEventListener(currentTab: AConstants.siteTab);
      refreshPins();
    });

    onAnnotationSelectedListener((selectedAnnotationId, isLocationAnnot) async {
      _setPlanState(CloseKeyBoardState());
      if (isLocationAnnot) {
        if (selectedLocation != null && selectedLocation!.pfLocationTreeDetail!.annotationId != selectedAnnotationId) {
          setSummaryFilterValue("");
          await _setCurrentLocationByAnnotationId(selectedAnnotationId);
          if (selectedLocation!.pfLocationTreeDetail!.annotationId == selectedAnnotationId) {
            await _highlightLocation(selectedLocation);
          }
        }
      }else{
        if(selectedLocation?.pfLocationTreeDetail?.isFileUploaded == true){
          return;
        }
        List<SiteLocation> siteLocationList = [];
        for(dynamic location in listBreadCrumb){
          if(location is SiteLocation){
            siteLocationList.add(location);
          }
        }

        SiteLocation? location = getParentLocation(selectedLocation!,siteLocationList);
        print("Selected parent location title ----> ${location?.folderTitle}");
        if(location != null) {
          _setCurrentSiteLocation(location);
          await _pdftronDocumentViewController?.requestResetRenderingPdftron();
          await _highlightLocation(selectedLocation);
          setHistoryLocationData();
        }

      }
    });

    onPinTapListener((formId, width, height) async {
      _setPlanState(CloseKeyBoardState());
      ObservationData? observationData = _observationList.firstWhere((element) => element.formId == formId);
      var coordinate = jsonDecode(observationData.coordinates ?? "");
      if (coordinate != null && coordinate is Map && coordinate.isNotEmpty) {
        setFormCodeFilterValue(observationData.formCode.toString());
        _setPlanState(SelectedFormDataState(observationData));
        highLightFormId = observationData.formId;
        List<ObservationData> tempList = [..._observationList];
        await _pdftronDocumentViewController?.renderPinsFromObservationList(jsonEncode(tempList), highLightFormId: highLightFormId);
        // var pagePoint = await _pdftronDocumentViewController?.convertPagePtToScreenPt(double.parse(coordinate["x1"].toString()), double.parse(coordinate["y1"].toString()));
        // _setPlanState(ShowObservationDialogState(observationData, pagePoint!['X'], pagePoint['Y'], width, height, true));
        // if (observationData.attachmentItem == null) {
        //   _getExternalAttachmentList(observationData);
        // } else {
        //   _setPlanState(RefreshObservationDialogState(observationData));
        // }
        // _pdftronDocumentViewController?.setInteractionEnabled(false);
      }
    });
    onLongPressDocumentListener((x, y) async {
      _setPlanState(CloseKeyBoardState());
      String? annotationId = await _pdftronDocumentViewController?.getAnnotationIdAt(x, y);
      if (!annotationId.isNullOrEmpty() && selectedLocation != null && selectedLocation!.pfLocationTreeDetail!.annotationId != annotationId) {
        await _setCurrentLocationByAnnotationId(annotationId!);
        await _highlightLocation(selectedLocation, isShowRect: false);
      }

      _setPlanState(LongPressCreateTaskState(x, y, isShowingPin: true));
    });

    _openDocument();
  }

  SiteLocation? getParentLocation(SiteLocation siteLocation, List<SiteLocation> siteLocationList) {
    int locationId = siteLocation.pfLocationTreeDetail?.parentLocationId ?? 0;
    var revisionId = siteLocation.pfLocationTreeDetail?.revisionId ?? 0;
    SiteLocation? location;
    bool isContinue = false;
    do {
      _listBreadCrumb.remove(location);
      location = siteLocationList?.firstWhere((element) => element.pfLocationTreeDetail?.locationId == locationId);
      locationId = location?.pfLocationTreeDetail?.parentLocationId ?? 0;
      bool isPlanUploaded = location?.pfLocationTreeDetail?.isFileUploaded ?? false;
      isContinue = (isPlanUploaded == false && revisionId == location?.pfLocationTreeDetail?.revisionId);

    } while (isContinue);
    return location;
  }

  Future<List<ObservationData>?> _getObservationListByPlan(SiteLocation location) async {
    Map<String, dynamic> request = {
      "projectId": location.projectId,
      "revisionId": location.pfLocationTreeDetail?.revisionId,
      "FromTab": 3,
      "checkHashing": "false",
      "includeDraft": "true",
      "isRequiredTemplateData": "true",
      "viewAlwaysFormAssociation": "false",
    };

    if (await StorePreference.getIncludeCloseOutFormFlag() == false) {
      request['isExcludeClosesOutForms'] = "true";
    }

    String appliedFilterJson = await _filterUseCase.getFilterJsonByIndexField({'summary': isSearchSummaryFilterApplied() ? _searchSummaryValue : null}, curScreen: FilterScreen.screenSite, isNeedToSave: false);
    if (!appliedFilterJson.isNullOrEmpty()) {
      request["jsonData"] = appliedFilterJson;
    }
    List<ObservationData>? observationList = [];
    if (isNetWorkConnected()) {
      request["onlyOfflineCreatedDataReq"] = true;
      List<ObservationData>? offlineResult = await getIt<SiteLocalRepository>().getObservationListByPlan(request);
      if (offlineResult != null) {
        for (int i = 0; i < offlineResult.length; i++) {
          offlineResult[i].isSyncPending = true;
          observationList.insert(i, offlineResult[i]);
        }
      }
    }
    final result = await _siteUseCase.getObservationListByPlan(request);
    observationList.addAll(result as Iterable<ObservationData>);
    return observationList;
  }

  void _openDocument() async {
    try {
      if (_pdfPath != null && File(_pdfPath!).existsSync()) {
        File pdfFile = File(_pdfPath!);
        final startTime = DateTime.now();
        if (kDebugMode) {
          print("PlanCubit _openDocument openDocument start=${startTime.toString()}");
        }

        await _pdftronDocumentViewController?.openDocument(pdfFile.uri.toString(), config: _config).catchError((error) {
          Log.e("Plan Load Error ->$error");
          _setPlanErrorState();
        });
        if (kDebugMode) {
          final endTime = DateTime.now();
          print("PlanCubit _openDocument openDocument end=${endTime.toString()}");
          print("PlanCubit _openDocument openDocument total time=${endTime.difference(startTime).inMilliseconds} Milliseconds");
        }
      }
    } catch (e) {
      Log.e(e);
    }
  }

  /// Highlight location
  Future<void> _highlightLocation(SiteLocation? selectedLocation, {bool isShowRect = true}) async {
    if (selectedLocation != null && selectedLocation.pfLocationTreeDetail != null) {
      String? annotationId = selectedLocation.pfLocationTreeDetail!.annotationId?.toString();
      await _pdftronDocumentViewController?.highlightSelectedLocation(annotationId: annotationId, isShowRect: isShowRect);
    }
  }

  Future<void> _mergeXfdf() async {
    if (!_xfdfPath.isNullOrEmpty()) {
      String? contents = await SiteUtility.getContentXfdfFile(_xfdfPath!);
      if (!contents.isNullOrEmpty()) {
        await _pdftronDocumentViewController?.importAnnotations(contents!);
      }
    }
  }

  Future<void> _deleteAllAnnotationExcludingLocation() async {
    await _pdftronDocumentViewController?.deleteAllAnnotations(isExcludingLocationAnnot: true); //12 means Stamp Annot
  }

  Future<void> setArgumentData(Object? arguments) async {
    if (arguments != null) {
      arguments as Map<String, dynamic>;
      _project = arguments['projectDetail'];
      if (arguments.containsKey("mapLocations")) {
        _mapLocations = arguments["mapLocations"];
      }
      if (arguments.containsKey("listBreadCrumb")) {
        _listBreadCrumb = (arguments["listBreadCrumb"] as List<dynamic>).toList();
      }
      if (arguments.containsKey("createdFormDetails")) {
        highLightFormId = arguments["createdFormDetails"]?['formId']?.toString();
      }
      if (arguments.containsKey("isFrom")) {
        isFromScreen = arguments["isFrom"];
      }
      if (arguments.containsKey("selectedLocation")) {
        await _setCurrentSiteLocation(arguments['selectedLocation']);
      }else {
        await _setCurrentSiteProject(_project);
      }
    }
  }

  Map<String, dynamic> getArgumentData() {
    Map<String, dynamic> arguments = {};
    arguments['projectDetail'] = _project;
    arguments['mapLocations'] = _mapLocations;
    arguments['selectedLocation'] = selectedLocation;
    arguments['listBreadCrumb'] = _listBreadCrumb;
    arguments['isFrom'] = LocationTreeViewFrom.sitePlanView;
    return arguments;
  }

  _setPlanErrorState({String errorMsg = ""}) async {
    _revisionId = null;
    _setPlanState(ErrorState(StateRendererType.POPUP_ERROR_STATE, errorMsg));
    setHistoryLocationData();
  }

  Future<SiteLocation?> _getLocationFromAnnotationLocationMap(String selectedAnnotationId) async {
    SiteLocation? siteLocation;
    List<SiteLocation>? siteLocationList = _mapAnnotationLocationList.containsKey(selectedAnnotationId) ? _mapAnnotationLocationList[selectedAnnotationId] : null;
    if (siteLocationList != null && siteLocationList.isNotEmpty) {
      siteLocation = await getLocationFromAnnotationId([selectedAnnotationId, siteLocationList, null]);
    }
    if (siteLocation == null) {
      _setPlanState(ProgressDialogState(true));
      List<SiteLocation> siteLocationList = [];
      SiteLocation? location = await _getLocationTreeByAnnotationId(selectedAnnotationId);
      if (location != null) {
        siteLocationList.add(location);
      }
      if (siteLocationList.isNotEmpty) {
        if (siteLocationList.isNotEmpty) {
          siteLocation = await getLocationFromAnnotationId([selectedAnnotationId, siteLocationList, null]);
          _mapAnnotationLocationList[selectedAnnotationId] = siteLocationList;
        }
      }
      _setPlanState(ProgressDialogState(false));
    }

    return siteLocation;
  }

  Future<SiteLocation?> _getLocationTreeByAnnotationId(String selectedAnnotationId) async {
    Map<String, dynamic> map = {};
    map["projectId"] = project!.projectID;
    map["annotationId"] = selectedAnnotationId;
    SiteLocation? siteLocation = await _siteUseCase.getLocationTreeByAnnotationId(map);
    return siteLocation;
  }

  _setCurrentLocationByAnnotationId(String selectedAnnotationId) async {
    SiteLocation? selectedLocation = await getLocationFromAnnotationId([selectedAnnotationId, siteLocationList, _mapLocations]);
    selectedLocation ??= await _getLocationFromAnnotationLocationMap(selectedAnnotationId);
    if (selectedLocation != null) {
      _listBreadCrumb = createLocationListBreadCrumb([selectedLocation, listBreadCrumb, _mapLocations, _mapAnnotationLocationList]);
      await _setCurrentSiteLocation(selectedLocation);
    }
  }

  void removeTempCreatePin() {
    _setPlanState(LongPressCreateTaskState(-1, -1, isShowingPin: false));
  }

  Future<void> navigateToCreateTask({double? x, double? y, AppType? appType, String? from}) async {
    Map<String, double> coordinateRectMap = {};
    String uniqueAnnotationId = await AsitePlugins().getUniqueAnnotationId() ?? "";
    int pageNumber = 1;
    if (from != "site_end_drawer") {
      var pagePoint = await _pdftronDocumentViewController?.convertScreenPtToPagePt(x!, y!);
      if (pagePoint != null) {
        coordinateRectMap["x1"] = pagePoint['X'];
        coordinateRectMap["y1"] = pagePoint['Y'];
        coordinateRectMap["x2"] = pagePoint['X'] + 10.0;
        coordinateRectMap["y2"] = pagePoint['Y'] + 10.0;
      }
      pageNumber = await _pdftronDocumentViewController?.getCurrentPageNumber() ?? 1;
    }
    var projectId = project!.projectID.toString();
    var formTypeId = appType!.formTypeID;
    String createTaskUrl = "";
    Map<String, dynamic> param = {};
    param['projectId'] = projectId;
    if(selectedLocation != null) {
      param['locationId'] = selectedLocation!.pfLocationTreeDetail!.locationId.toString();
    }
    param['coordinates'] = json.encode(coordinateRectMap);
    param['annotationId'] = uniqueAnnotationId;
    param['isFromMapView'] = true;
    param['isCalibrated'] = true;
    param['page_number'] = pageNumber;
    param['appTypeId'] = appType.appTypeId;
    param['formSelectRadiobutton'] = "${project!.dcId ?? "1"}_${projectId}_$formTypeId";
    if (isNetWorkConnected()) {
      createTaskUrl = await UrlHelper.getCreateFormURL(param,screenName: FireBaseFromScreen.twoDPlan);
    } else {
      param['formTypeId'] = formTypeId;
      param['instanceGroupId'] = appType.instanceGroupId;
      param['templateType'] = appType.templateType;
      param['appBuilderId'] = appType.appBuilderCode;
      if(selectedLocation != null) {
        param['revisionId'] = selectedLocation!.pfLocationTreeDetail!.revisionId.toString();
      }
      param['offlineFormId'] = DateTime.now().millisecondsSinceEpoch;
      param['isUploadAttachmentInTemp'] = true;
      createTaskUrl = await FileFormUtility.getOfflineCreateFormPath(param);
    }
    param['url'] = createTaskUrl;
    param['isFrom'] = FromScreen.longPress;
    _setPlanState(CreateTaskNavigationState(createTaskUrl, param, appType));
  }

  Future<void> refreshPinsAndHighLight(response, {bool refreshTaskList = true, bool isShowProgressDialog = true}) async {
    if (response is Map && response.containsKey("formId")) {
      highLightFormId = response['formId'].toString();
      await refreshPins();
      if (refreshTaskList) {
        refreshSiteTaskList();
      }
    }
  }

  Future<void> refreshPins({bool isShowProgressDialog = true}) async {
    if(selectedLocation == null) {
      return;
    }
    if (isShowProgressDialog) {
      _setPlanState(ProgressDialogState(true));
    }
    if (currentPinsType != Pins.hide) {
      _observationList = (await _getObservationListByPlan(selectedLocation!)) ?? [];
    } else {
      _observationList = [];
    }

    setPinsType(currentPinsType);
    if (isShowProgressDialog) {
      _setPlanState(ProgressDialogState(false));
    }
    setHistoryLocationData();
  }

  void removeItemFromBreadCrumb() async {
    int parentLocationId = selectedLocation?.pfLocationTreeDetail?.parentLocationId ?? 0;
    try {
      if (parentLocationId != 0) {
        SiteLocation? siteLocation;
        for (int i = listBreadCrumb.length - 1; i > 0; i--) {
          if (listBreadCrumb[i] is SiteLocation && parentLocationId == listBreadCrumb[i].pfLocationTreeDetail!.locationId) {
            siteLocation = listBreadCrumb[i];
            break;
          }
        }
        if (siteLocation != null) {
          if (siteLocation.pfLocationTreeDetail!.parentLocationId == 0) {
            _setPlanState(HistoryLocationBtnState(false));
          }
          listBreadCrumb.removeLast();
          await _setCurrentSiteLocation(siteLocation);
          await loadPlan();
        } else {
          _setPlanState(HistoryLocationBtnState(false));
        }
      } else {
        _setPlanState(HistoryLocationBtnState(false));
      }
    } catch (e) {
      Log.d("Error$e");
    }
  }

  setHistoryLocationData() {
    int parentLocationId = selectedLocation?.pfLocationTreeDetail?.parentLocationId ?? 0;
    if (parentLocationId == 0) {
      _setPlanState(HistoryLocationBtnState(false));
    } else {
      _setPlanState(HistoryLocationBtnState(true));
    }
  }

  onDismissPinDialog(ObservationData observationData) {
    _setPlanState(ShowObservationDialogState(observationData, 0, 0, 0, 0, false));
    _pdftronDocumentViewController?.setInteractionEnabled(true);
  }

  onFormItemClicked(ObservationData frmData) async {
    String formId = frmData.formId ?? "";
    String formTitle = "${frmData.formCode?.split('(')[0]}: ${frmData.formTitle}";
    String appBuilderId = frmData.appBuilderID ?? "";
    String frmStatusColor = frmData.statusVO?.bgColor ?? "";
    Map<String, dynamic> param = {
      "projectId": frmData.projectId,
      "projectids": frmData.projectId?.plainValue(),
      //"isDraft":frmData.isDraft,
      "checkHashing": false,
      "formID": frmData.formId,
      "formTypeId": frmData.formTypeId,
      "folderId": frmData..folderId,
      "dcId": "1",
      "statusId": frmData.statusVO?.statusId,
      //"parentmsgId":frmData.parentMsgId,
      //"msgTypeCode":frmData.msgTypeCode,
      //"msgCode":frmData.msgCode,
      "originatorId": frmData.observationId,
      "msgId": frmData.msgId,
      "toOpen": "FromForms",
      "commId": frmData.commId,
      "numberOfRecentDefect": "5",
      "appTypeId": frmData.appType,
    };
    final data = {"projectId": frmData.projectId, "locationId": (frmData.locationDetailVO?.locationId ?? frmData.locationId).toString(), "isFrom": FromScreen.planView, "commId": frmData.commId, "formId": frmData.formId, "formTypeId": frmData.formTypeId, "templateType": frmData.templateType, "appBuilderId": frmData.appBuilderID, "appTypeId": frmData.appType, "formSelectRadiobutton": "${_project?.dcId ?? "1"}_${frmData.projectId}_${frmData.formTypeId}", "isUploadAttachmentInTemp": true};
    if (isNetWorkConnected()) {
      String formViewUrl = await UrlHelper.getViewFormURL(param,screenName: FireBaseFromScreen.twoDPlan);
      _setPlanState(FormItemViewState(formId, frmStatusColor, appBuilderId, formTitle, formViewUrl, data));
    } else {
      final offlineParams = {
        "projectId": frmData.projectId,
        "locationId": frmData.locationId.toString(),
        // "isFrom": FromScreen.siteTakListing,
        "commId": frmData.commId,
        "toOpen": "FromForms",
        "observationId": frmData.observationId.toString(),
        "formId": frmData.formId,
        "formTypeId": frmData.formTypeId,
        "msgId": frmData.msgId
      };
      String filePath = await FileFormUtility.getOfflineViewFormPath(offlineParams);
      _setPlanState(FormItemViewState(formId, frmStatusColor, appBuilderId, formTitle, filePath, data));
    }
  }

  Future<void> _getExternalAttachmentList(ObservationData observationData) async {
    try {
      Map<String, String> map = {"formIds": observationData.formId.toString(), "projectId": observationData.projectId.toString()};
      final result = await _siteTaskUseCase.getExternalAttachmentList(map);
      if (result is SUCCESS) {
        String jsonDataString = result.data.toString();
        List<dynamic> jsonObj = jsonDecode(jsonDataString);
        for (Map<String, dynamic> taskItem in jsonObj) {
          String formId = taskItem['formId'];
          if (observationData.formId.plainValue() == formId.plainValue()) {
            observationData.attachmentItem = AttachmentItem(taskItem['formId'], taskItem['revisionId'], taskItem['attachmentCount'], taskItem['fileExtensionType'], realPath: taskItem["realPath"] ?? "");
            _setPlanState(RefreshObservationDialogState(observationData));
          }
        }
      }
    } on Exception {
      // emitState(ErrorState(StateRendererType.DEFAULT, e.toString()));
    }
  }

  bool isNeedtoOpenListingDrawer() {
    if (!SiteUtility.isLocationHasPlan(selectedLocation)) {
      return true;
    }
    return (isFromScreen != null && (isFromScreen == FromScreen.dashboard || isFromScreen == FromScreen.qrCode || isFromScreen == FromScreen.quality) && selectedLocation != null && (selectedLocation?.pfLocationTreeDetail == null || selectedLocation!.pfLocationTreeDetail!.annotationId.isNullOrEmpty()));
  }

  Future<void> clearSiteTaskFilter() async {
    setSummaryFilterValue("");
    _filterUseCase.saveSiteFilterData({}, curScreen: FilterScreen.screenSite);
    await refreshPins();
  }

  void setSummaryFilterValue(String value) {
    _searchSummaryValue = value;
  }

  void setFormCodeFilterValue(String value) {
    _selectedFormCode = value;
  }

  String? getFormCodeFilterValue() {
    return _selectedFormCode;
  }

  String? getSummaryFilterValue() {
    return _searchSummaryValue;
  }

  bool isSearchSummaryFilterApplied() {
    return !_searchSummaryValue.isNullOrEmpty();
  }

  Future<Result?> getUpdatedSiteTaskItem(String projectId, String formId) async {
    try {
      final result = await _siteTaskUseCase.getUpdatedSiteTaskItem(projectId, formId);
      highLightFormId = formId;
      if (result is SUCCESS) {
        String jsonDataString = result.data.toString();
        final jsonObj = jsonDecode(jsonDataString);
        List<dynamic>? siteFormList = jsonObj["data"];
        if (siteFormList != null) {
          SiteForm siteForm = SiteForm.fromJson(siteFormList.first);
          refreshPinAfterFormStatusChanged(siteForm);
          _setPlanState(RefreshSiteTaskListItemState(siteForm));
        }
      }
    } on Exception catch (e) {
      Log.d(e);
    }
    return null;
  }

  refreshPinAfterFormStatusChanged(SiteForm siteForm) {
    for (var observation in _observationList) {
      if (observation.formId == siteForm.formId) {
        observation.locationId = siteForm.locationId;
        observation.folderId = siteForm.folderId;
        observation.formId = siteForm.formId;
        observation.formTypeId = siteForm.formTypeId;
        observation.hasAttachment = siteForm.hasAttachments;
        observation.actions = <Actions>[];
        siteForm.actions.forEach((v) {
          observation.actions!.add(Actions.fromJson(v.toJson()));
        });
        observation.recipientList?.first.userID = siteForm.assignedToUserId;
        observation.recipientList?.first.recipientFullName = siteForm.assignedToUserName ?? ((siteForm.CFID_Assigned?.split(',').first.isNullOrEmpty() ?? true) ? "--" : siteForm.CFID_Assigned?.split(',').first);
        observation.recipientList?.first.userOrgName = siteForm.assignedToUserOrgName ?? ((siteForm.CFID_Assigned?.split(',').last.isNullOrEmpty() ?? true) ? '--' : siteForm.CFID_Assigned?.split(',').last);
        observation.commId = siteForm.commId;
        observation.formDueDays = siteForm.formDueDays;
        observation.formCode = siteForm.code;
        observation.defectTypeName = siteForm.manageTypeName;
        observation.expectedFinishDate = siteForm.expectedFinishDate;
        observation.responseRequestBy = siteForm.responseRequestBy;
        observation.isCloseOut = siteForm.isCloseOut;
        observation.statusUpdateDate = siteForm.statusUpdateDate;
        observation.workPackage = siteForm.observationDefectType ?? siteForm.workPackage;
        observation.statusVO?.bgColor = siteForm.statusRecordStyle != null ? siteForm.statusRecordStyle['backgroundColor'] : AConstants.defaultFormStatusColor;
        observation.statusVO?.statusId = int.parse(siteForm.statusid.plainValue() ?? "0");
        observation.statusVO?.statusName = siteForm.statusText;
        observation.msgId = siteForm.msgId;
        observation.formTitle = siteForm.title;
        observation.formCode = siteForm.code;
        highLightFormId = observation.formId;
        break;
      }
    }
    setPinsType(currentPinsType);
  }
}
