import 'dart:convert';

import 'package:field/bloc/base/base_cubit.dart';
import 'package:field/bloc/project_list/project_list_cubit.dart';
import 'package:field/data/model/apptype_vo.dart';
import 'package:field/data/model/popupdata_vo.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/qrcodedata_vo.dart';
import 'package:field/domain/use_cases/qr/qr_usecase.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/presentation/navigation/field_navigator.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

import '../../analytics/event_analytics.dart';
import '../../data/local/project_list/project_list_local_repository.dart';
import '../../data/model/site_location.dart';
import '../../injection_container.dart';
import '../../logger/logger.dart';
import '../../networking/network_response.dart';
import '../../presentation/base/state_renderer/state_render_impl.dart';
import '../../presentation/base/state_renderer/state_renderer.dart';
import '../../utils/qrcode_utils.dart';
import '../../utils/user_activity_preference.dart';
import '../../utils/utils.dart';
import '../navigation/navigation_cubit.dart';

class FieldNavigatorCubit extends BaseCubit {
  final QrUseCase _qrUseCase;

  Result? result;
  final FieldNavigator _fieldNavigation;
  bool isProjectSelected = true;

  FieldNavigatorCubit({QrUseCase? qrUseCase, FieldNavigator? objNavigator})
      : _qrUseCase = qrUseCase ?? di.getIt<QrUseCase>(),
        _fieldNavigation = objNavigator ?? di.getIt<FieldNavigator>(),
        super(FlowState());

  Future<void> scanQR(String cancelLabel) async {
    String barcodeScanRes;
    var platform = const MethodChannel('flutter.native/flashAvailable');
    final bool showFlash = await platform.invokeMethod('flashAvailable');
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', cancelLabel, showFlash, ScanMode.QR);
      if (barcodeScanRes.isNotEmpty && QrCodeUtility.isAsiteQrCodeUrl(barcodeScanRes) == true) {
        String result = barcodeScanRes.split("data=").last;
        String data = await result.decrypt();
        Log.d("Qrcode decrypted Data = $data");
        QRCodeDataVo? qrObj = QrCodeUtility.getQrCodeDataVo(barcodeScanRes, data);

        if (qrObj != null) {
          //use qrObj Data VO as per needs
          if (qrObj.qrCodeType == QRCodeType.qrFormType) {
            if (getIt<NavigationCubit>().currSelectedItem == NavigationMenuItemType.sites) {
              SiteLocation? siteLocation = await getLastLocationData();
              qrObj.setLocationId = siteLocation?.pfLocationTreeDetail?.locationId?.toString() ?? "";
            }
            checkQRCodePermission(qrObj);
          } else {
            checkQRCodePermission(qrObj);
          }
          FireBaseEventAnalytics.setEvent(FireBaseEventType.qrScan, FireBaseFromScreen.qrcode, bIncludeProjectName:true);
        }
      } else {
        if (barcodeScanRes != "-2") {
          Log.d("Qrcode Result = $barcodeScanRes \nInvalid Qrcode");
          emitState(ErrorState(StateRendererType.isValid, "", time: DateTime.now().millisecondsSinceEpoch.toString(), code: 401));
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }

  Future<void> checkQRCodePermission(QRCodeDataVo voObject) async {
    emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
    Project? prj = await di.getIt<ProjectListCubit>().getProjectDetailQr(voObject.projectId ?? "");
    voObject.setDcId = prj?.dcId ?? 1;
    try {
      Map<String, dynamic> map = <String, dynamic>{};
      map["projectId"] = voObject.projectId;
      map["dcId"] = voObject.dcId;
      switch (voObject.qrCodeType) {
        case QRCodeType.qrLocation:
          {
            map["folderIds"] = voObject.folderId;
            map["generateQRCodeFor"] = "1";
          }
          break;
        case QRCodeType.qrFormType:
          {
            map["instanceGroupId"] = voObject.instanceGroupId;
            map["generateQRCodeFor"] = "3";
          }
          break;
        case QRCodeType.qrFolder:
          {
            map["folderIds"] = voObject.folderId;
            map["generateQRCodeFor"] = "2";
          }
          break;
        default:
          {}
      }

      final result = await _qrUseCase.checkQRCodePermission(map);
      if (result is SUCCESS) {
        switch (voObject.qrCodeType) {
          case QRCodeType.qrLocation:
            {
              Project? project = await StorePreference.getSelectedProjectData();
              if (project == null || (project.projectID != voObject.projectId)) {
                Popupdata data = Popupdata(id: voObject.projectId ?? "", dataCenterId: voObject.dcId);
                await di.getIt<ProjectListCubit>().getProjectDetail(data, false);
              }
              getFieldEnableSelectedProjectsAndLocations(voObject);
            }
            break;
          case QRCodeType.qrFormType:
            {
              getFormPrivilege(voObject);
            }
            break;
          default:
            {}
        }
      } else {
        emitState(ErrorState(StateRendererType.isValid, result?.failureMessage ?? "Something went wrong", code: result?.responseCode, time: DateTime.now().millisecondsSinceEpoch.toString()));
      }
    } on Exception catch (e) {
      emitState(ErrorState(StateRendererType.DEFAULT, e.toString()));
    }
  }

  void getLocationDetails(String locId, String projectId) async {
    try {
      Map<String, dynamic> map = <String, dynamic>{};
      map["projectId"] = projectId;
      map["locationIds"] = locId;
      map["isObservationCountRequired"] = false;
      final result = await _qrUseCase.getLocationDetails(map);
      if (result is SUCCESS) {
        String jsonString = result.data.toString();
        var data = jsonDecode(jsonString).first;
        String folderId = data['folderId'];
        Map<String, dynamic> mapObject = {};
        mapObject['folId'] = folderId;
        mapObject['projId'] = projectId;
        mapObject['QRCodeType'] = QRCodeType.qrLocation;
        QRCodeDataVo voObject = QRCodeDataVo.fromMap(mapObject);
        getFieldEnableSelectedProjectsAndLocations(voObject);
      } else {
        emitState(ErrorState(StateRendererType.isValid, result?.failureMessage ?? "Something went wrong", time: DateTime.now().millisecondsSinceEpoch.toString()));
      }
    } on Exception catch (e) {
      emitState(ErrorState(StateRendererType.DEFAULT, e.toString()));
    }
  }

  getFormPrivilege(QRCodeDataVo voObject, {bool isShowLoading = false, FromScreen fromScreen = FromScreen.qrCode}) async {
    try {
      if (isShowLoading) {
        emitState(LoadingState(stateRendererType: StateRendererType.DEFAULT));
      }
      Map<String, dynamic> map = <String, dynamic>{};
      map["projectId"] = voObject.projectId;
      map["instanceGroupId"] = voObject.instanceGroupId;
      map["dcId"] = voObject.dcId;
      final result = await _qrUseCase.getFormPrivilege(map);
      if (result is SUCCESS) {
        var arguments = await _fieldNavigation.navigate(voObject, result);
        // emitState(SuccessState({"qrDataVo": voObject, "response": result}));
        emitState(SuccessState({"qrCodeType": QRCodeType.qrFormType, "arguments": arguments, "formData": result.data}));
      } else {
        emitState(ErrorState(StateRendererType.isValid, result?.failureMessage ?? "Something went wrong", time: DateTime.now().millisecondsSinceEpoch.toString(),data: fromScreen));
      }
    } on Exception catch (e) {
      emitState(ErrorState(StateRendererType.DEFAULT, e.toString(),data: fromScreen));
    }
  }

  Future<void> getFieldEnableSelectedProjectsAndLocations(QRCodeDataVo voObject) async {
    Map<String, dynamic> map = getWorkspaceMapData(voObject.projectId, voObject.folderId, voObject.dcId);
    try {
      final result = await _qrUseCase.getFieldEnableSelectedProjectsAndLocations(map);

      // QRCodeDataVo voObj = state.response['qrDataVo'];
      // _qrCodeNavigation.setArgument(voObject, result);
      // if (voObj.qrCodeType == QRCodeType.qrLocation) {
      //   if(widget.qrFromProject != null && widget.qrFromProject == true) {
      //     await NavigationUtils.mainPopUntil();
      //   }
      // }
      var arguments = await _fieldNavigation.navigate(voObject, result);

      if (result is SUCCESS) {
        // emitState(SuccessState({"qrDataVo": voObject, "response": result}));
        emitState(SuccessState({"qrCodeType": QRCodeType.qrLocation, "arguments": arguments}));
      } else {
        emitState(ErrorState(StateRendererType.isValid, result?.failureMessage ?? "Something went wrong", time: DateTime.now().millisecondsSinceEpoch.toString()));
      }
    } on Exception catch (e) {
      emitState(ErrorState(StateRendererType.DEFAULT, e.toString()));
    }
  }

  Map<String, dynamic> getWorkspaceMapData(projectId, folderId, dcId) {
    Map<String, dynamic> map = {};
    map["isfromfieldfolder"] = "true";
    map["projectId"] = projectId;
    map["folder_id"] = folderId;
    map["folderTypeId"] = "1";
    map["projectIds"] = projectId;
    map["checkHashing"] = "false";
    map["dcId"] = dcId;
    return map;
  }

  setSelectedProject() async {
    isProjectSelected = await getIt<ProjectListLocalRepository>().isProjectMarkedOffline();
    emitState(ContentState(time: DateTime.now().millisecondsSinceEpoch.toString()));
    return isProjectSelected;
  }

  List<AppType> getAppTypeList(String formData) {
    List<AppType> appTypeList = [];
    try {
      if (!formData.isNullOrEmpty()) {
        var jsonObject = json.decode(formData);
        jsonObject = jsonObject['formTypeGroupList'].first;
        appTypeList = AppType.fromJsonListSync(jsonObject['formType_List'] ?? []);
      }
    } catch (e) {}
    return appTypeList;
  }
}
