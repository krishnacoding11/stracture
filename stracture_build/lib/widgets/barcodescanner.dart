import 'dart:convert';
import 'dart:math';

import 'package:field/bloc/QR/navigator_cubit.dart';
import 'package:field/bloc/deeplink/deeplink_cubit.dart';
import 'package:field/bloc/navigation/navigation_cubit.dart';
import 'package:field/bloc/toolbar/toolbar_cubit.dart';
import 'package:field/data/model/project_vo.dart';
import 'package:field/data/model/qrcodedata_vo.dart';
import 'package:field/injection_container.dart';
import 'package:field/logger/logger.dart';
import 'package:field/presentation/managers/image_constant.dart';
import 'package:field/presentation/screen/bottom_navigation/tab_navigator.dart';
import 'package:field/presentation/screen/dashboard.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/file_form_utility.dart';
import 'package:field/utils/navigation_utils.dart';
import 'package:field/utils/qrcode_utils.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../presentation/base/state_renderer/state_render_impl.dart';

class BarCodeScannerWidget extends StatefulWidget {
  final bool? qrFromProject;

  const BarCodeScannerWidget({this.qrFromProject, Key? key}) : super(key: key);

  @override
  State<BarCodeScannerWidget> createState() => _BarCodeScannerWidgetState();
}

class _BarCodeScannerWidgetState extends State<BarCodeScannerWidget> {
  late FieldNavigatorCubit _navigatorCubit;
  AProgressDialog? aProgressDialog;

  @override
  void initState() {
    _navigatorCubit = getIt<FieldNavigatorCubit>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => checkInitialUrlAndRedirect());
    return BlocProvider(
      create: (_) => _navigatorCubit,
      child: BlocListener<FieldNavigatorCubit, FlowState>(
        listener: (_, state) async {
          if (state is SuccessState) {
            aProgressDialog?.dismiss();
            if (state.response["qrCodeType"] == QRCodeType.qrLocation) {
              if (widget.qrFromProject != null && widget.qrFromProject == true) {
                await NavigationUtils.mainPopUntil();
              }
              if (getIt<NavigationCubit>().currSelectedItem != NavigationMenuItemType.sites) {
                getIt<NavigationCubit>().updateSelectedItemByType(NavigationMenuItemType.sites);
                getIt<ToolbarCubit>().updateSelectedItemByPosition(NavigationMenuItemType.sites);
              }
              await Future.delayed(const Duration(milliseconds: 100));
              NavigationUtils.pushNamedAndRemoveUntil(TabNavigatorRoutes.sitePlanView, argument: state.response["arguments"]);
            } else {
              var map = state.response["arguments"];
              map['isFrom'] = FromScreen.qrCode;
              if (widget.qrFromProject != null && widget.qrFromProject == true) {
                Project? project = await StorePreference.getSelectedProjectData();
                if (project == null) {
                  await NavigationUtils.mainPushAndRemoveUntilWithoutAnimation(const DashboardWidget());
                } else {
                  Navigator.popUntil(NavigationUtils.mainNavigationKey.currentState!.context, (route) => route.isFirst);
                  await getIt<NavigationCubit>().updateSelectedItemByType(NavigationMenuItemType.home);
                  getIt<ToolbarCubit>().updateSelectedItemByPosition(NavigationMenuItemType.home);
                }
              }
              await FileFormUtility.showFormCreateDialog(context, frmViewUrl: map["url"], data: map, title: map["name"] ?? "");
            }
          } else if (state is ErrorState) {
            aProgressDialog?.dismiss();
            Log.d(state.message);
            if (state.code == 601 || state.code == 404) {
              dynamic jsonResponse = jsonDecode(state.message);
              String errorMsg = jsonResponse['msg'];
              errorMsg = errorMsg.isNullOrEmpty() ? QrCodeUtility.getQrError(jsonResponse['key']) : errorMsg;
              Utility.showAlertWithOk(context, errorMsg);
            } else {
              //context.showSnack(state.message);
              //show error dialog

              Utility.showQRAlertDialog(context, state.message.isNullOrEmpty() ? context.toLocale!.lbl_invalid_qr : state.message);
            }
          } else if (state is LoadingState) {
            aProgressDialog ??= AProgressDialog(context, useSafeArea: true, isWillPopScope: true);
            aProgressDialog?.show();
          }
        },
        child: FloatingActionButton(
          key: const Key("qrCodeButton"),
          heroTag: Text("ic_qr_code_${widget.qrFromProject} - ${Random().nextInt(5000)}"),
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed:() => _navigatorCubit.scanQR(context.toLocale!.lbl_btn_cancel),
          child: Image.asset(AImageConstants.icScanner),
        ),
      ),
    );
  }

  /*static Future<void> scanQR(BuildContext context) async {
    String barcodeScanRes;
    var platform = const MethodChannel('flutter.native/flashAvailable');
    final bool showFlash = await platform.invokeMethod('flashAvailable');
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode('#ff6666', context.toLocale!.lbl_cancel, showFlash, ScanMode.QR);
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
            _navigatorCubit.checkQRCodePermission(qrObj);
          } else {
            _navigatorCubit.checkQRCodePermission(qrObj);
          }
        }
      } else {
        if (barcodeScanRes != "-2") {
          Log.d("Qrcode Result = $barcodeScanRes \nInvalid Qrcode");
          _navigatorCubit.emitState(ErrorState(StateRendererType.isValid, "", time: DateTime.now().millisecondsSinceEpoch.toString(), code: 401));
        }
      }
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
  }*/

  checkInitialUrlAndRedirect() async {
    QRCodeDataVo? qrObj = await QrCodeUtility.extractDataFromLink();
    if (qrObj != null) {
      getIt<DeepLinkCubit>().uri = "";
      _navigatorCubit.checkQRCodePermission(qrObj);
    }
  }
}
