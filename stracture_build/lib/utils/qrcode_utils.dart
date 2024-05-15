
import 'package:field/bloc/deeplink/deeplink_cubit.dart';
import 'package:field/data/model/qrcodedata_vo.dart';
import 'package:field/injection_container.dart';
import 'package:field/logger/logger.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/navigation_utils.dart';

import '../data/model/site_location.dart';

class QrCodeUtility{
  static bool isAsiteQrCodeUrl(String requestUrl){
    if(requestUrl.isNotEmpty) {
      Uri url = Uri.dataFromString(requestUrl);
      if (url.path.contains("qrcode") && url.queryParameters.keys.contains("QRCodeType") == true) {
        return true;
      }
    }
    return false;
  }

  static String? getEncryptedData(String qrCodeResult){
    if(qrCodeResult.isNotEmpty && isAsiteQrCodeUrl(qrCodeResult)==true){
      return qrCodeResult.substring(qrCodeResult.indexOf("data=") + 5);
    }
    return null;
  }

  static QRCodeType getQrCodeType(String qrCodeResult){
    if(qrCodeResult.isNotEmpty && isAsiteQrCodeUrl(qrCodeResult)==true){
      Uri url = Uri.dataFromString(qrCodeResult);
      return QRCodeType.values[int.parse(url.queryParameters['QRCodeType']!)-1];
    }
    return QRCodeType.qrUnKnown;
  }

  static QRCodeDataVo? getQrCodeDataVo(String qrCodeResult, String decryptedData){
    if(decryptedData.isNotEmpty){
      QRCodeType crType = getQrCodeType(qrCodeResult);
      if(crType != QRCodeType.qrUnKnown){
        Map<String,dynamic> mapObject = {};
        mapObject['QRCodeType'] = crType;
        List<String> list1 = decryptedData.replaceAll("{", "").replaceAll("}", "").split(',');
        for (var element in list1) {
          List<String> tmpList = element.trim().split('=');
          mapObject[tmpList[0]] = tmpList[1];
        }
        return QRCodeDataVo.fromMap(mapObject);
      }
    }
    return null;
  }

  static QRCodeDataVo? getQrCodeDataVoFormLocation(SiteLocation? lastLocation){
    if (lastLocation != null) {
      String? projectId = lastLocation.projectId.plainValue();
      String? parentLocationId = lastLocation.pfLocationTreeDetail?.parentLocationId.toString();
      String? locationId = lastLocation.pfLocationTreeDetail?.locationId.toString();
      String? revisionId = lastLocation.pfLocationTreeDetail?.revisionId.plainValue();
      String? folderId = lastLocation.folderId.plainValue();
      String? parentFolderId = lastLocation.parentFolderId.toString();
      return QRCodeDataVo(
        qrCodeType: QRCodeType.qrLocation,
        projectId: projectId,
        parentLocationId: parentLocationId,
        locationId: locationId,
        parentFolderId: parentFolderId,
        folderId: folderId,
        revisionId: revisionId,
      );
    }
    return null;
  }

  static String getQrError(String key) {
    switch (key) {
      case 'location-removed':
        return NavigationUtils
            .mainNavigationKey.currentContext!.toLocale!.location_removed;
      case 'do-not-have-permission-project':
        return NavigationUtils.mainNavigationKey.currentContext!.toLocale!
            .do_not_have_permission_project;
      case 'folder-removed':
        return NavigationUtils
            .mainNavigationKey.currentContext!.toLocale!.folder_removed;
      case 'form-removed':
        return NavigationUtils
            .mainNavigationKey.currentContext!.toLocale!.form_removed;
      case 'lbl_invalid_qr':
        return NavigationUtils
            .mainNavigationKey.currentContext!.toLocale!.lbl_invalid_qr;
      default:
        return "";
    }
  }

  static Future<QRCodeDataVo?> extractDataFromLink() async {
    final lnkCubit = getIt<DeepLinkCubit>();
    String currentUrl = lnkCubit.uri;
    if (currentUrl != "" &&QrCodeUtility.isAsiteQrCodeUrl(currentUrl) == true) {
      // lnkCubit.uri = "";
      String result = QrCodeUtility.getEncryptedData(currentUrl)!;
      String data = await result.decrypt();
      Log.d("Qrcode decrypted Data = $data");
      QRCodeDataVo? qrObj = QrCodeUtility.getQrCodeDataVo(currentUrl, data);
      return qrObj;
    }
    return null;
  }
}