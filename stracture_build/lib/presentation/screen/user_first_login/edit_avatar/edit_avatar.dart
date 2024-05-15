import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:field/injection_container.dart';
import 'package:field/presentation/base/state_renderer/state_renderer.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:field/utils/app_config.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../../bloc/user_first_login_setup/user_first_login_setup_cubit.dart';
import '../../../../bloc/user_first_login_setup/user_first_login_setup_state.dart';
import '../../../../data/model/update_user_avatar_vo.dart';
import '../../../../utils/utils.dart';
import '../../../../widgets/app_permission_handler.dart';
import '../../../../widgets/normaltext.dart';
import '../../../base/state_renderer/state_render_impl.dart';
import '../../../managers/color_manager.dart';
import '../../../managers/image_constant.dart';
import '../../../managers/routes_manager.dart';

class EditAvatar extends StatelessWidget {
  final String? from;

  const EditAvatar({this.from, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown, DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);

    return PhoneEditAvatar(
      from: from,
    );
  }

  Widget getImageRow({String? imageFrom, IconData? icon, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: AColors.white, borderRadius: BorderRadius.circular(4.0), boxShadow: [
          BoxShadow(
            color: AColors.black.withOpacity(0.25),
            offset: const Offset(0, 4),
            blurRadius: 4.0,
          )
        ]),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon!,
              color: AColors.themeBlueColor,
              size: 20,
            ),
            const SizedBox(
              width: 10,
            ),
            NormalTextWidget(
              imageFrom!,
              fontSize: 15,
              fontWeight: AFontWight.semiBold,
              textAlign: TextAlign.start,
              color: AColors.themeBlueColor,
            )
          ],
        ),
      ),
    );
  }
}

class PhoneEditAvatar extends StatefulWidget {
  final String? from;

  const PhoneEditAvatar({this.from, Key? key}) : super(key: key);

  @override
  State<PhoneEditAvatar> createState() => _PhoneEditAvatarState();
}

class _PhoneEditAvatarState extends State<PhoneEditAvatar> {
  late UserFirstLoginSetupCubit firstUserLoginSetupCubit;
  bool isIncorrectFileSize = false;
  String? message;

  @override
  void initState() {
    firstUserLoginSetupCubit = BlocProvider.of<UserFirstLoginSetupCubit>(context);
    if (widget.from == "userSetting") {
      firstUserLoginSetupCubit.currentUserAvatar = null;
    }
    if (firstUserLoginSetupCubit.user == null) {
      getUserData();
    } else {
      getUserImage();
    }

    super.initState();
  }

  getUserData() async {
    await firstUserLoginSetupCubit.getUserDataFromLocal();
    getUserImage();
  }

  getUserImage() async {
    await firstUserLoginSetupCubit.getUserImageFromServer();
  }

  @override
  Widget build(BuildContext context) {
    final textIncorrectLogin = AnimatedOpacity(
      duration: const Duration(seconds: 1),
      opacity: isIncorrectFileSize ? 1 : 0,
      onEnd: () {
        if (!isIncorrectFileSize) {
          setState(() {
            isIncorrectFileSize = false;
          });
        }
      },
      child: Visibility(
        visible: isIncorrectFileSize,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 15, 8, 15),
          child: SizedBox(
            child: Align(
              alignment: Alignment.center,
              child: NormalTextWidget(
                message ?? "",
                //    maxLines: 2,
                color: Colors.red,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
    final userAvatar = BlocBuilder<UserFirstLoginSetupCubit, FlowState>(
        buildWhen: (prev, current) => current is UpdateImageFromLocal || current is UpdateNetworkImage,
        builder: (context, state) {
          var placeHolder = Image.asset(AImageConstants.profileAvatarPlaceholder).image;
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: 150,
                  padding: EdgeInsets.all(1.0),
                  margin: EdgeInsets.only(bottom: 8.0),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AColors.themeBlueColor),
                  child: BlocBuilder<UserFirstLoginSetupCubit, FlowState>(
                    builder: (context, state) {
                      return ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: firstUserLoginSetupCubit.currentUserAvatar != null
                              ? Image.file(
                                  File(
                                    firstUserLoginSetupCubit.currentUserAvatar!.path,
                                  ),
                                  fit: BoxFit.cover,
                                )
                              : widget.from != AConstants.userFirstLogin && firstUserLoginSetupCubit.strUserImage != null
                                  ? CachedNetworkImage(
                                      imageUrl: firstUserLoginSetupCubit.strUserImage!,
                                      httpHeaders: firstUserLoginSetupCubit.headersMap,
                                      useOldImageOnUrlChange: false,
                                      imageBuilder: (context, imageProvider) => Container(
                                          decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2.0,
                                        ),
                                        shape: BoxShape.circle,
                                        image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
                                      )),
                                      placeholder: (context, url) => Image(image: placeHolder, fit: BoxFit.cover),
                                      errorWidget: (context, url, error) => Image(
                                        image: placeHolder,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      AImageConstants.userAvatarLogo,
                                      fit: BoxFit.contain,
                                    ));
                    },
                  ),
                ),
                getImageRow(
                    key: const Key('SelectFromCamera'),
                    icon: Icons.photo_camera,
                    imageFrom: context.toLocale!.take_a_picture,
                    onTap: () async {
                      setState(() {
                        isIncorrectFileSize = false;
                      });
                      var permissionHandlerPermissionService = PermissionHandlerPermissionService();
                      permissionHandlerPermissionService.checkAndRequestCameraPermission((bool isGranted) {
                        if (isGranted) {
                          Navigator.pushNamed(context, Routes.aCamera, arguments: {"allowMultiple": "false", "onlyImage": "true"}).then((dynamic capturedImage) {
                            if (capturedImage != null) {
                              List<XFile> imageList = capturedImage as List<XFile>;
                              if (imageList.isNotEmpty) {
                                _cropImage(context, imageList[0]);
                              }
                            }
                          });
                        } else {
                          permissionHandlerPermissionService.showPermissionMessageDialog(context);
                        }
                      });
                    }),
                const SizedBox(
                  height: 7.0,
                ),
                getImageRow(
                    key: const Key('SelectFromGallery'),
                    icon: Icons.collections,
                    imageFrom: context.toLocale!.select_a_photo,
                    onTap: () async {
                      setState(() {
                        isIncorrectFileSize = false;
                      });
                      bool isPermissionGranted = await PermissionHandlerPermissionService().checkAndRequestPhotosPermission(context);
                      if (isPermissionGranted) {
                        firstUserLoginSetupCubit.getImageFromGallery(context, (error, stackTrace) {
                          if (error is PlatformException) {
                            PermissionHandlerPermissionService().showPermissionMessageDialog(context);
                          }
                        }, (Map files) {
                          if (files["validFiles"] != null) {
                            _cropImage(context, XFile(files["validFiles"][0].path!));
                          } else if (files["inValidFiles"] != null) {
                            Utility.showAlertWithOk(context, files["inValidFiles"]);
                          }
                        });
                      }
                    }),
                textIncorrectLogin
              ],
            ),
          );
        });

    return BlocListener<UserFirstLoginSetupCubit, FlowState>(
        listener: (context, state) {
          if (state is SuccessState && state.stateRendererType == StateRendererType.DEFAULT) {
            manageRedirection(state.response);
          }
        },
        child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                    alignment: Alignment.centerLeft,
                    child: NormalTextWidget(
                      context.toLocale!.edit_image,
                      fontSize: 18,
                      fontWeight: AFontWight.medium,
                      color: AColors.themeBlueColor,
                      textAlign: TextAlign.left,
                    )),
                const SizedBox(
                  height: 16,
                ),
                userAvatar
              ],
            )));
  }

  manageRedirection(dynamic result) {
    if (result != null && result.runtimeType != List<Object>) {
      dynamic data = result.data;
      if (data is UpdateUserAvatarVo && data.isPortraitException != null) {
        setState(() {
          isIncorrectFileSize = true;
          message = context.toLocale!.lbl_image_error_message;
        });
      } else {
        AppConfig appConfig = getIt<AppConfig>();
        appConfig.storedTimestamp = DateTime.now().millisecondsSinceEpoch;
        if (widget.from == AConstants.userFirstLogin) {
          Navigator.pushNamedAndRemoveUntil(context, Routes.dashboard, (route) => false);
          Navigator.pushNamed(context, Routes.projectList, arguments: AConstants.userFirstLogin);
        } else {
          Navigator.pop(context, true);
        }
      }
    }
  }

  Future<void> _cropImage(BuildContext? context, XFile? currentImage) async {
    if (currentImage != null) {
      final croppedFile = await ImageCropper().cropImage(sourcePath: currentImage.path!, aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), aspectRatioPresets: [CropAspectRatioPreset.square], compressFormat: ImageCompressFormat.jpg, maxHeight: 500, maxWidth: 500, cropStyle: CropStyle.circle, compressQuality: 100, uiSettings: [AndroidUiSettings(toolbarTitle: context!.toLocale!.lbl_move_scale, showCropGrid: false, hideBottomControls: false, toolbarColor: AColors.themeBlueColor, cropGridColumnCount: 2, cropGridRowCount: 2, toolbarWidgetColor: Colors.white, activeControlsWidgetColor: AColors.themeBlueColor, statusBarColor: AColors.themeBlueColor, initAspectRatio: CropAspectRatioPreset.square, lockAspectRatio: true), IOSUiSettings(title: context.toLocale!.lbl_move_scale, aspectRatioLockDimensionSwapEnabled: false, aspectRatioLockEnabled: true, resetAspectRatioEnabled: false)]);
      if (croppedFile != null) {
        XFile image = XFile(croppedFile.path);
        firstUserLoginSetupCubit.updateCurrentAvatarFromFile(image);
      } else {
        firstUserLoginSetupCubit.currentUserAvatar = null;
      }
    }
  }
}

Widget getImageRow({Key? key, String? imageFrom, IconData? icon, VoidCallback? onTap}) {
  return InkWell(
    key: key,
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(color: AColors.white, borderRadius: BorderRadius.circular(4.0), boxShadow: [
        BoxShadow(
          color: AColors.black.withOpacity(0.25),
          offset: const Offset(0, 4),
          blurRadius: 4.0,
        )
      ]),
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon!,
            color: AColors.themeBlueColor,
            size: 20,
          ),
          const SizedBox(
            width: 10,
          ),
          NormalTextWidget(
            imageFrom!,
            fontSize: 15,
            fontWeight: AFontWight.semiBold,
            textAlign: TextAlign.start,
            color: AColors.themeBlueColor,
          )
        ],
      ),
    ),
  );
}
