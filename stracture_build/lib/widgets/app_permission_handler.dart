import 'dart:io' show Platform;

import 'package:asite_plugins/asite_plugins_method_channel.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/utils.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/store_preference.dart';

class PermissionHandlerPermissionService {
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  Future<PermissionStatus> requestLocationPermission() async {
    return await Permission.location.request();
  }

  Future<PermissionStatus> requestPhotosPermission() async {
    return await Permission.photos.request();
  }

  Future<bool> isDeniedCameraPermission() async {
    if (Platform.isIOS) {
      return await Permission.camera.isPermanentlyDenied;
    }
    return await Permission.camera.isDenied || await Permission.camera.isPermanentlyDenied;
  }

  Future<bool> isDeniedLocationPermission() async {
    if (Platform.isIOS) {
      return await Permission.location.isPermanentlyDenied;
    }
    return await Permission.location.isDenied || await Permission.location.isPermanentlyDenied;
  }

  Future<bool> isGrantedCameraPermission() async {
    return Permission.camera.isGranted;
  }

  Future<bool> isGrantedLocationPermission() async {
    return Permission.location.isGranted;
  }

  Future<bool> isDeniedStoragePermission() async {
    if (Platform.isIOS) {
      return await Permission.storage.isPermanentlyDenied;
    }
    return await Permission.storage.isDenied || await Permission.storage.isPermanentlyDenied;
  }

  Future<bool> isGrantedStoragePermission() async {
    return Permission.storage.isGranted;
  }

  Future<void> checkAndRequestCameraPermission(Function onPermissionStatus) async {
    bool isPermissionGranted = await Permission.camera.isGranted;
    var shouldShowRequestRationale = await Permission.camera.shouldShowRequestRationale;
    List<Permission> permissions;
    if (isPermissionGranted) {
      onPermissionStatus(true);
    } else {
      var isGeoTagEnabled = await StorePreference.getProjectGeoTagSettings();
      if(isGeoTagEnabled == "true") {
        permissions = [Permission.camera,Permission.location];
      } else {
        permissions = [Permission.camera];
      }
      if (!shouldShowRequestRationale) {
        Map<Permission,PermissionStatus> statuses = await permissions.request();
        PermissionStatus permissionStatus = statuses[Permission.camera]!;
        if (permissionStatus.isPermanentlyDenied || permissionStatus.isDenied) {
          onPermissionStatus(false);
        } else {
          onPermissionStatus(true);
        }
      } else {
        Map<Permission,PermissionStatus> statuses = await permissions.request();
        PermissionStatus permissionStatus = statuses[Permission.camera]!;
        if (permissionStatus.isGranted) {
          onPermissionStatus(true);
        } else {
          onPermissionStatus(false);
        }
      }
    }
  }

  Future<bool> checkAndRequestPhotosPermission(BuildContext context) async {
    if(!Utility.isIos){
      var deviceSdkInt = await MethodChannelAsitePlugins().deviceSdkInt();
      if(deviceSdkInt > 31){
        bool isPermissionGranted = await Permission.photos.isGranted;
        bool isPermissionLimited = await Permission.photos.isLimited;

        if (isPermissionGranted || isPermissionLimited) {
          return true;
        } else {
          PermissionStatus permissionStatus = await Permission.photos.request();
          if (permissionStatus == PermissionStatus.denied || permissionStatus == PermissionStatus.permanentlyDenied || permissionStatus == PermissionStatus.restricted) {
            showPermissionMessageDialog(context);
            return false;
          }
        }
      }
    }
    return true;
  }

  showCustomDialog({BuildContext? context, String? title, String? des}) {
    Utility.isIos
        ? showCupertinoDialog(
            context: context!,
            builder: (context) {
              return CupertinoAlertDialog(
                title: NormalTextWidget(title!),
                content: NormalTextWidget(
                  des!,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                actions: <Widget>[
                  CupertinoDialogAction(
                    onPressed: () => openAppSettings(),
                    child: Text(context.toLocale!.open_setting),
                  ),
                  CupertinoDialogAction(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.toLocale!.lbl_btn_cancel),
                  )
                ],
              );
            })
        : showDialog(
            context: context!,
            builder: (context) {
              return AlertDialog(
                actionsAlignment: MainAxisAlignment.spaceAround,
                contentPadding: const EdgeInsets.all(20.0),
                title: NormalTextWidget(title!),
                content: NormalTextWidget(
                  des!,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                actions: [
                  InkWell(
                    onTap: () {
                      openAppSettings().then((value) {
                        Navigator.pop(context);
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NormalTextWidget(
                        context.toLocale!.open_setting,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NormalTextWidget(
                        context.toLocale!.lbl_btn_cancel,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                ],
              );
            });
  }

  showPermissionMessageDialog(BuildContext context) {
    showCustomDialog(context: context, title: context.toLocale!.custom_photos_permission_title, des: context.toLocale!.custom_photos_permission_des);
  }
}
