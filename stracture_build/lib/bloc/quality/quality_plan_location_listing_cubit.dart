import 'dart:convert';

import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/quality/quality_plan_location_listing_state.dart';
import 'package:field/domain/use_cases/quality/quality_plan_listing_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/widgets/a_file_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../../analytics/event_analytics.dart';
import '../../data/model/project_vo.dart';
import '../../data/model/qrcodedata_vo.dart';
import '../../data/model/quality_activity_list_vo.dart';
import '../../data/model/quality_location_breadcrumb.dart';
import '../../data/model/quality_plan_list_vo.dart';
import '../../data/model/quality_plan_location_listing_vo.dart';
import '../../data/model/simple_file_upload.dart';
import '../../data/model/updated_activity_list_vo.dart';
import '../../domain/use_cases/upload/upload_usecase.dart';
import '../../enums.dart';
import '../../exception/app_exception.dart';
import '../../utils/constants.dart';
import '../../utils/store_preference.dart';
import '../../utils/url_helper.dart';
import '../../utils/utils.dart';

enum InternalState { loading, refresh, success, failure, refreshError, hideLoader }

enum QualityListInternalState { locationList, activityList }

class QualityPlanLocationListingCubit extends BaseCubit {
  final QualityPlanListingUseCase _qualityPlanListingUseCase;
  final UploadUseCase _uploadUseCase;

  QualityPlanLocationListingCubit({QualityPlanListingUseCase? useCase, UploadUseCase? uploadUseCase})
      : _qualityPlanListingUseCase = useCase ?? di.getIt<QualityPlanListingUseCase>(),
        _uploadUseCase = uploadUseCase ?? di.getIt<UploadUseCase>(),
        super(InitialState(stateRendererType: StateRendererType.DEFAULT));

  late QualityPlanLocationListingVo? qualityPlanLocationListingVO;

  late QualityLocationBreadcrumb? qualityPlanBreadcrumbVo;

  num? planOrLocationPercentage;

  num? planPercentage;

  List<Locations> qualityLocationList = [];

  final List<dynamic> _locationBreadcrumbList = [];

  List<dynamic> get locationBreadcrumbList => _locationBreadcrumbList;

  Locations? selectedQualityLocation, traversedQualityLocation;

  QualityListInternalState _qualityListInternalState = QualityListInternalState.locationList;

  QualityListInternalState get qualityListInternalState => _qualityListInternalState; //Location
  String? projectId;
  String? planId;
  String? locationId;
  String? sitelocationId;
  num? planCompletedPercentage;
  num? dcId;
  String entityName = 'deliverableActivity';
  String operation = 'RemoveAssociation';

  // String? qiActivityId = ActivitiesList.qiActivityId;

  bool _hasActivityManageAccess = false;
  bool refreshPage = false;

  bool isPrivilegeLoaded = false;

  //Activity
  late QualityActivityList? activityListVo;
  int requestFor = 2;
  List<ActivitiesList> activityListData = [];

  //Remove Activity Data
  late UpdatedActivityListVo updateActivityDataVo;

  ActivitiesList? currentSelectedActivity;

  bool isAssociationRequired(deliverableActivities) {
    return deliverableActivities.isAssociationRequired!;
  }

  bool get hasActivityManageAccess {
    return _hasActivityManageAccess;
  }

  bool isNotBlockedAndAssocRequired(deliverableActivities) {
    return isNotBlocked(deliverableActivities) && isAssociationRequired(deliverableActivities);
  }

  bool isNotBlocked(deliverableActivities) {
    return deliverableActivities.isWorking!;
  }

  bool isActivityStatusInProgress(deliverableActivities) {
    return '${deliverableActivities.qiStatusId}'.plainValue() == ActivityStatusId.inProgress.value;
  }

  bool isActivityStatusComplete(deliverableActivities) {
    return '${deliverableActivities.qiStatusId}'.plainValue() == ActivityStatusId.complete.value;
  }

  bool isActivityStatusOpen(deliverableActivities) {
    return '${deliverableActivities.qiStatusId}'.plainValue() == ActivityStatusId.open.value;
  }

  bool isInProgressOrCompleteState(deliverableActivities) {
    return (isActivityStatusInProgress(deliverableActivities) || isActivityStatusComplete(deliverableActivities));
  }

  //Location Listing API
  setArgument(Data qualityData) {
    if (qualityData.projectId == null) {
      throw AppException(message: "Project is not selected");
    }
    if (qualityData.planId == null) {
      throw AppException(message: "Plan is not selected");
    }
    projectId = qualityData.projectId;
    planId = qualityData.planId;
    currentSelectedActivity = null;
    locationId = null;
    sitelocationId = null;
    selectedQualityLocation = null;
    planCompletedPercentage = qualityData.percentageCompletion ?? 0;
    dcId = qualityData.dcId;
    setBreadcrumbDataLocal(qualityData);
  }

  getLocationListFromServer({String? currentLocationId, bool? isLoading = false}) async {
    _qualityListInternalState = QualityListInternalState.locationList;
    if (isLoading!) {
      qualityLocationList.clear();
      emitState(LocationListState(null, qualityListInternalState, InternalState.loading));
    }

    var request = getLocationListingDataMap(projectId!, planId!, currentLocationId ?? "");
    final result = await _qualityPlanListingUseCase.getQualityPlanLocationListingFromServer(request);
    if (result is SUCCESS) {
      try {
        qualityPlanLocationListingVO = result.data;
        setLocationsData(currentLocationId);
      } catch (e) {
        emitState(LocationListState(e.toString(), qualityListInternalState, InternalState.failure, time: DateTime.now().millisecondsSinceEpoch.toString()));
      }
    } else {
      emitState(LocationListState(result?.failureMessage ?? "", qualityListInternalState, InternalState.failure, stateRendererType: StateRendererType.FULL_SCREEN_ERROR_STATE, time: DateTime.now().millisecondsSinceEpoch.toString()));
    }
  }

  int? getCountQualityLocationList() {
    return qualityLocationList.length;
  }

  setLocationsData(String? locationsId) {
    if (qualityPlanLocationListingVO != null && qualityPlanLocationListingVO!.isSuccess!) {
      final currentLocationList = qualityPlanLocationListingVO!.response!.root!.locations ?? [];

      //Remove first parent location from list (Because it is not child of passed location)
      if(currentLocationList.isNotEmpty && (locationId == currentLocationList!.first.qiLocationId || currentLocationList!.first.qiParentId.isNullEmptyOrFalse())) {
        currentLocationList.removeAt(0);
      }

      if ((locationId == null || currentLocationList.isEmpty || locationId == currentLocationList!.first.qiParentId)) {
        if (locationsId == null) {
          setCurrentPlanOrLocationPercentage = qualityPlanLocationListingVO!.response!.root!.perCompletion;
          emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
        }
        qualityLocationList.clear();
        qualityLocationList.addAll(currentLocationList);
        emitState(LocationListState(qualityLocationList, qualityListInternalState, InternalState.success, time: DateTime.now().millisecondsSinceEpoch.toString()));
      } else {
        if (currentLocationList.isEmpty) {
          removeItemFromBreadCrumb(index: 2);
        } else {
          emitState(LocationListState("", qualityListInternalState, InternalState.failure, stateRendererType: StateRendererType.EMPTY_SCREEN_STATE, time: DateTime.now().millisecondsSinceEpoch.toString()));
        }
      }
    } else {
      emitState(LocationListState("", qualityListInternalState, InternalState.failure, stateRendererType: StateRendererType.FULL_SCREEN_ERROR_STATE, time: DateTime.now().millisecondsSinceEpoch.toString()));
    }
  }

  createQrObject() {
    return QRCodeDataVo(
      dcId: null,
      folderId: selectedQualityLocation?.siteFolderId,
      locationId: locationId,
      projectId: projectId,
      qrCodeType: QRCodeType.qrLocation,
    );
  }

  Map<String, dynamic> getLocationListingDataMap(String projectId, String planId, String qiLocationId) {
    Map<String, dynamic> map = {};
    map["dcId"] = 1; //TOD: How to implement DC call
    map["projectId"] = projectId;
    map["planId"] = planId;
    map["requestFor"] = 1;
    if (qiLocationId.isNotEmpty) map["qiLocationId"] = qiLocationId;
    return map;
  }

  addLocationToBreadcrumb(Locations? locations) {
    if (locations != null && !_locationBreadcrumbList.contains(locations)) {
      _locationBreadcrumbList.add(locations);
      traversedQualityLocation = locations;
      locationId = locations.qiLocationId;
      sitelocationId = locations.siteLocationId;
    }
  }

  void removeItemFromBreadCrumb({int? index}) {
    (index == null) ? _locationBreadcrumbList.removeLast() : _locationBreadcrumbList.removeRange(index + 1, _locationBreadcrumbList.length);

    if (locationBreadcrumbList.length >= 4) {
      final lastLocation = locationBreadcrumbList.last as Locations;
      locationId = lastLocation.qiLocationId;
      sitelocationId = lastLocation.siteLocationId;
      selectedQualityLocation = lastLocation;
      setCurrentPlanOrLocationPercentage = lastLocation.percentageCompelition;
    } else {
      selectedQualityLocation = null;
      locationId = null;
      sitelocationId = null;
      setCurrentPlanOrLocationPercentage = planCompletedPercentage;
    }

    if (locationBreadcrumbList.last is Locations) {
      final lastLocation = locationBreadcrumbList.last as Locations;
      if (!lastLocation.hasLocation!) {
        getActivityList(true);
      } else {
        getLocationListFromServer(currentLocationId: locationId, isLoading: true);
      }
    } else {
      getLocationListFromServer(currentLocationId: locationId, isLoading: true);
    }
  }

  void navigateToActivityList([Locations? location]) {
    getActivityList(true);
  }

  getLocationBreadCrumbFromServer() async {
    Map<String, dynamic> request = {
      "planId": "$planId",
      "projectId": "$projectId",
    };

    if (locationId != null) {
      request["qiLocationId"] = locationId;
    }

    Result? result = await _qualityPlanListingUseCase.getQualityPlanBreadcrumbFromServer(request);
    if (result is SUCCESS) {
      try {
        qualityPlanBreadcrumbVo = result.data;
        setBreadcrumbData();
      } catch (e) {
        emitState(ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE, e.toString()));
      }
    } else {
      emitState(ErrorState(StateRendererType.FULL_SCREEN_ERROR_STATE, result?.failureMessage ?? ""));
    }
  }

  setBreadcrumbData() {
    if (qualityPlanBreadcrumbVo != null) {
      _locationBreadcrumbList.clear();

      final projectPlanDetails = qualityPlanBreadcrumbVo!.projectPlanDetailsVO;
      _locationBreadcrumbList.insert(0, {
        "projectName": projectPlanDetails!.projectName,
      });
      _locationBreadcrumbList.insert(1, "");
      _locationBreadcrumbList.insert(2, {
        "planName": projectPlanDetails.planName,
      });
      setPlanPercentage = qualityPlanBreadcrumbVo!.projectPlanDetailsVO?.perCompletion;
      _locationBreadcrumbList.addAll(qualityPlanBreadcrumbVo!.locations!.toList());
      if (qualityPlanBreadcrumbVo!.locations!.toList().isNotEmpty) {
        setCurrentPlanOrLocationPercentage = qualityPlanBreadcrumbVo!.locations!.toList().last.percentageCompelition;
      }
      if(qualityListInternalState == QualityListInternalState.activityList){
        emitState(ActivityListState(activityListData, qualityListInternalState, InternalState.success));
      }else{
        emitState(LocationListState(qualityLocationList, qualityListInternalState, InternalState.success));
      }
    }
  }

  setBreadcrumbDataLocal(Data qualityData) {
    _locationBreadcrumbList.clear();
    _locationBreadcrumbList.insert(0, {
      "projectName": qualityData.projectName,
    });
    _locationBreadcrumbList.insert(1, "");
    _locationBreadcrumbList.insert(2, {
      "planName": qualityData.planTitle,
    });
  }

  set setCurrentPlanOrLocationPercentage(num? percentage) {
    planOrLocationPercentage = percentage ?? 0;
  }

  num? get getCurrentPlanOrLocationPercentage {
    return planOrLocationPercentage ?? 0;
  }

  set setPlanPercentage(num? percentage) {
    planPercentage = percentage;
  }

  num? get getPlanPercentage {
    return planPercentage;
  }

  getUserPrivilegeByProjectId() async {
    Map<String, dynamic> requestMap = {};
    requestMap["projectId"] = projectId;
    requestMap["action_id"] = '207';

    try {
      final result = await _qualityPlanListingUseCase.getUserPrivilegeByProjectId(requestMap);

      if (result is SUCCESS) {
        final accessData = jsonDecode(result.data);

        _hasActivityManageAccess = accessData["privileges"] != null && accessData["privileges"].split(',').contains(PRIVILEGES.manageQuality.value);
        isPrivilegeLoaded = true;
      }
    } catch (e) {
      _hasActivityManageAccess = false;
    }
  }

  //Activity Listing API
  Future<void> getActivityList(bool? isLoading) async {
    _qualityListInternalState = QualityListInternalState.activityList;
    if (isLoading!) {
      activityListData.clear();
      emitState(ActivityListState(null, _qualityListInternalState, InternalState.loading));
    }

    if(!isPrivilegeLoaded) {
      await getUserPrivilegeByProjectId();
    }
    var lastApiCallTimeStamp = DateTime.now().millisecondsSinceEpoch;
    Map<String, dynamic> requestMap = {};
    requestMap["projectId"] = projectId;
    requestMap["planId"] = planId;
    requestMap["requestFor"] = 2;
    requestMap["qiLocationId"] = locationId;
    requestMap[AConstants.keyLastApiCallTimestamp] = lastApiCallTimeStamp;

    final result = await _qualityPlanListingUseCase.getActivityListingFromServer(requestMap);

    if (result is SUCCESS) {
      try {
        activityListVo = result.data;

        if (activityListVo != null && activityListVo!.isSuccess! && activityListVo!.response!.root!.activitiesList!.isNotEmpty) {
          var actListData = activityListVo!.response!.root!.activitiesList!;
          actListData.sort((val1, val2) => val1.activitySeq!.compareTo(val2.activitySeq!));
          activityListData.clear();
          activityListData.addAll(actListData);
          emitState(ActivityListState(activityListData, _qualityListInternalState, InternalState.success, stateRendererType: StateRendererType.DEFAULT, time: DateTime.now().millisecondsSinceEpoch.toString()));
        } else {
          emitState(ActivityListState(activityListData, _qualityListInternalState, InternalState.success, stateRendererType: StateRendererType.DEFAULT, time: DateTime.now().millisecondsSinceEpoch.toString()));
        }
      } catch (e) {
        emitState(ActivityListState(e.toString(), _qualityListInternalState, InternalState.failure, stateRendererType: StateRendererType.FULL_SCREEN_ERROR_STATE, time: DateTime.now().millisecondsSinceEpoch.toString()));
      }
    } else {
      emitState(ActivityListState(result.failureMessage, _qualityListInternalState, InternalState.failure, stateRendererType: StateRendererType.FULL_SCREEN_ERROR_STATE, time: DateTime.now().millisecondsSinceEpoch.toString()));
    }
  }

  clearActivityData(DeliverableActivities deliverableActivities) async {
    Map<String, dynamic> requestMap = {};
    Map<String, dynamic> jsonData = {
      "root": {
        "deliverableActivity": [
          <String, dynamic>{
            "deliverableActivityId": deliverableActivities.deliverableActivityId,
            "associateProjectId": "",
            "associateFormId": "",
            "link": "",
            "activityType": deliverableActivities.activityType,
            "qiActivityId": deliverableActivities.qiActivityId,
            "qiLocationId": deliverableActivities.qiLocationId,
            "isAssociationRequired": true,
          }
        ]
      },
    };
    requestMap["projectId"] = projectId;
    requestMap["planId"] = planId;
    requestMap['entityName'] = "deliverableActivity";
    requestMap['operation'] = "RemoveAssociation";
    requestMap['dcId'] = dcId;
    requestMap["jsonData"] = jsonEncode(jsonData);

    final result = await _qualityPlanListingUseCase.clearActivityData(requestMap);

    if (result is SUCCESS) {
      try {
        updateActivityDataVo = result.data;
        if(updateActivityDataVo.isSuccess!) {
          num? qualityPercentage = updateActivityDataVo.response?.root?.locPercentage?.plan;
          setCurrentPlanOrLocationPercentage = qualityPercentage;
          var updatedId = updateActivityDataVo.response?.root?.deliverableActivities![0].qiActivityId;
          activityListData.firstWhere((element) => element.qiActivityId == updatedId).deliverableActivities = updateActivityDataVo.response?.root?.deliverableActivities;
          updateAndRefreshData();
        } else {
          emitState(ActivityListState(activityListData, qualityListInternalState, InternalState.hideLoader));
          NavigationUtils.mainNavigationKey.currentContext?.showSnack("Something went wrong");
        }
      } catch (e) {
        emitState(ActivityListState(activityListData, qualityListInternalState, InternalState.hideLoader, message: e.toString()));
        NavigationUtils.mainNavigationKey.currentContext?.showSnack(e.toString());
      }
    } else {
      emitState(ActivityListState(activityListData, qualityListInternalState, InternalState.hideLoader, message: result?.failureMessage ?? "Something went wrong"));
      NavigationUtils.mainNavigationKey.currentContext?.showSnack(result?.failureMessage ?? "Something went wrong");
    }
  }

  Future<Map<String, dynamic>> navigateToCreateForm(ActivitiesList data) async {
    String formTypeId = data.formTypeId ?? "";
    String appBuilderCode = data.appBuilderCode ?? "";
    // appBuilderCode --- id
    Map<String, dynamic> obj = {};
    obj['projectId'] = projectId;
    obj['locationId'] = sitelocationId ?? "";
    obj['appTypeId'] = data.appTypeId.toString();

    if (appBuilderCode.isNotEmpty) {
      obj['formSelectRadiobutton'] = "1_${projectId}_${formTypeId}_$appBuilderCode";
    } else {
      obj['formSelectRadiobutton'] = "1_${projectId}_$formTypeId";
    }

    obj['planId'] = planId;
    obj['deliverableActivityId'] = data.deliverableActivities![0].deliverableActivityId;
    String url = await UrlHelper.getCreateFormURL(obj,screenName: FireBaseFromScreen.quality);
    Map<String, dynamic> map = <String, dynamic>{};
    map['projectId'] = projectId;
    map['locationId'] = sitelocationId ?? "";
    map['appTypeId'] = data.appTypeId.toString();
    map['planId'] = planId;
    map['deliverableActivityId'] = data.deliverableActivities![0].deliverableActivityId;
    map['isCalibrated'] = true;
    map['isFromMapView'] = true;
    map['url'] = url;
    map['name'] = data.formTypeName;
    map['isFrom'] = FromScreen.quality;
    return map;
  }

  Future<void> getFileFromGallery([Function? onError, FileType? fileType, Function? selectedFileCallBack]) async {
    await AFilePicker().getSingleFile((error, stackTrace) {
      if (onError != null){
        onError(error, stackTrace);
      }
    }, fileType, (selectedFile){
      if (selectedFileCallBack != null){
        selectedFileCallBack(selectedFile);
      }
     });
  }

  Map<String, dynamic> getDataToViewFormFile() {
    return {
      "projectId": projectId,
      "locationId": locationId.toString(),
      "isFrom": FromScreen.quality,
    };
  }

  Future<String> getUrlBasedOnAssociationType(activityData) async {
    if (activityData.associationType == AssociationTypeEnum.form.value) {
      return await getViewFormUrl(activityData.deliverableActivities![0]);
    } else {
      return await getViewFileUrl(activityData.deliverableActivities![0]);
    }
  }

  Future<String> getViewFileUrl(DeliverableActivities activity) async {
    Map<String, dynamic> map = {};
    map['projectId'] = activity.associateProjectId;
    map['revisionId'] = activity.associateRevId;
    map['folderId'] = activity.associateFolderId;
    Project? temp = await StorePreference.getSelectedProjectData();
    map['dcId'] = temp!.dcId;
    map['toOpen'] = 'FromFile';
    map['documentId'] = null;
    map['fldV'] = '2';

    final url = await UrlHelper.getViewFileURL(map);
    return url;
  }

  Future<String> getViewFormUrl(DeliverableActivities activity) async {
    Map<String, dynamic> map = {};
    map['projectId'] = activity.associateProjectId;
    map['isDraft'] = false;
    map['checkHashing'] = false;
    map['formID'] = activity.associateFormId;
    map['formTypeId'] = activity.formTypeId;
    Project? temp = await StorePreference.getSelectedProjectData();
    map['dcId'] = temp!.dcId;
    map['originatorId'] = activity.createdById;
    map['msgId'] = activity.msgId;
    map['toOpen'] = 'FromForms';

    final url = await UrlHelper.getViewFormURL(map,screenName: FireBaseFromScreen.quality);
    return url;
  }

  setCurrentSelectedActivity(ActivitiesList? activitiesList) {
    currentSelectedActivity = activitiesList;
  }

  emitRefreshState(){
    if(qualityListInternalState == QualityListInternalState.locationList){
      emitState(LocationListState(qualityLocationList, qualityListInternalState, InternalState.refresh));
    }else{
      emitState(ActivityListState(activityListData, qualityListInternalState, InternalState.refresh));
    }

  }

  updateAndRefreshData({bool? isReloadRequired=false, dynamic data}) async{
    if(qualityListInternalState == QualityListInternalState.locationList){
      await Future.wait(<Future<void>>[getLocationBreadCrumbFromServer(), getLocationListFromServer(isLoading: false, currentLocationId: locationId)]);
    }else {
      await Future.wait(<Future<void>>[getLocationBreadCrumbFromServer(), getActivityList(false)]);
      if(isReloadRequired==true && data!=null)
      {
        reloadActivityData(data,0);
      }
    }
  }

  reloadActivityData(dynamic data, num count)
  {
    if(count==3)
    {
      return;
    }
    var dActivityIdData = activityListData.firstWhere((element) => element.deliverableActivities![0].deliverableActivityId==data['deliverableActivityId']);
    if(!dActivityIdData.deliverableActivities![0].isAccess!) {
      Future.delayed(const Duration(milliseconds: 400), () async {
        await getActivityList(false);
        count++;
        reloadActivityData(data, count);
      });
    }
  }


  Future<void> uploadFileToServer({required String? filePath, required String? fileName}) async {
    emitRefreshState();
    Result? result = await _uploadUseCase.uploadFileToServer(filePath, fileName, projectId, currentSelectedActivity!.folderId, planId: planId, deliverableActivityId: currentSelectedActivity!.deliverableActivities!.first.deliverableActivityId);
    if(result is SUCCESS && result.data is List<SimpleFileUpload>){
      List<SimpleFileUpload> uploadedFileList = result.data;
      if(uploadedFileList.isNotEmpty && uploadedFileList.first.sucessFiles!.isNotEmpty && uploadedFileList.first.sucessFiles!.first.isNotEmpty){
        updateAndRefreshData();
        return;
      }else{
        emitState(ActivityListState(activityListData, qualityListInternalState, InternalState.refreshError, message : "ErrorInSimpleUpload"));
      }
    }else{
      var failureMessage = result!.failureMessage ?? "";
      if(failureMessage.isNullOrEmpty()) {
        failureMessage = "SomethingWentWrong";
      }
      emitState(ActivityListState(activityListData, qualityListInternalState, InternalState.refreshError, message : failureMessage));
    }
  }

}
