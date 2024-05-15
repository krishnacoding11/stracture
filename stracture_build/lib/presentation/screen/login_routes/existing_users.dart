import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/data/model/datacenter_vo.dart';
import 'package:field/data/model/user_vo.dart';
import 'package:field/injection_container.dart' as di;
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/utils/app_path_helper.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/widgets/a_progress_dialog.dart';
import 'package:field/widgets/behaviors/custom_scroll_behavior.dart';
import 'package:field/widgets/sso_webview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sprintf/sprintf.dart';

import '../../../widgets/headlinetext.dart';
import '../../../widgets/imagewidget.dart';
import '../../../widgets/normaltext.dart';
import '../../base/state_renderer/state_renderer.dart';
import '../../managers/color_manager.dart';
import '../../managers/font_manager.dart';
import '../onboarding_login_screen.dart';

class ExistingAccountWidget extends StatefulWidget {
  final Function callback;
  Function? handleBackPress;
  Function? handleNavigation;
  final List<User> existingUserList;

  ExistingAccountWidget(this.callback, this.existingUserList, {Key? key,this.handleBackPress,this.handleNavigation})
      : super(key: key);

  @override
  State<ExistingAccountWidget> createState() => _ExistingAccountWidgetState();
}

class _ExistingAccountWidgetState extends State<ExistingAccountWidget> {
  final LoginCubit _loginCubit = di.getIt<LoginCubit>();
  late ScrollController scrollController;
  String? message;
  String? userName;
  String basePath="";
  late AProgressDialog? aProgressDialog;

  @override
  void initState() {
    scrollController = ScrollController();
    super.initState();
    aProgressDialog = AProgressDialog(context, isAnimationRequired: true);
    getBasePath();
  }

  getBasePath() async {
    basePath = await AppPathHelper().getUserDatabasePath();
  }

  @override
  Widget build(BuildContext context) {
    final txtAccount = HeadlineTextWidget(
      context.toLocale!.lbl_choose_account,
      style: TextStyle(
        color: AColors.textColor,
        fontFamily: AFonts.fontFamily,
        fontWeight: AFontWight.medium,
        decoration: TextDecoration.none,
      ),
    );

    final clearAllAccounts = Center(
      heightFactor: 1,
      child: TextButton(
        onPressed: () async {
          _loginCubit.mLoginObject.email = '';
          await _loginCubit.clearAllAccountPreference();
          widget.handleBackPress!();
        },
        child: NormalTextWidget(
          context.toLocale!.lbl_clear_acc,
          color: AColors.themeBlueColor,
          fontSize: 15,
          fontWeight: AFontWight.medium,

        ),
      ),
    );

    return BlocListener<LoginCubit, FlowState>(
      listener: (context, state) {
        aProgressDialog?.dismiss();
        if (state is LoadingState) {
          aProgressDialog?.show();
        } else if (state is SuccessState) {
          _manageLoginResult(state.response);
        } else if (state is ErrorState) {
          context.showSnack(state.message);
        }
      },
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        txtAccount,
        const SizedBox(
          height: 30,
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 270),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: RawScrollbar(
              thickness: 3,
              controller: scrollController,
              trackVisibility: true,
              trackColor: Colors.white60,
              thumbColor: AColors.white,
              thumbVisibility: true,
              child: ScrollConfiguration(
                behavior: CustomScrollBehavior(),
                child: ListView.separated(
                    shrinkWrap: true,
                    controller: scrollController,
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 1,
                        thickness: 1,
                        endIndent: 30,
                        indent: 0,
                        color: Colors.white54,
                      );
                    },
                    itemCount: widget.existingUserList.length,
                    itemBuilder: (context, position) {
                      User user = widget.existingUserList[position];
                      var placeHolder =
                          Image.asset("assets/images/ic_profile_avatar.png");

                      return ListTile(
                        contentPadding: EdgeInsets.all(0),
                        horizontalTitleGap: 10,
                        dense: true,
                        leading: Container(
                          width: 40,
                          height: 40,
                          clipBehavior: Clip.antiAlias,
                          decoration:  BoxDecoration(
                              borderRadius: BorderRadius.circular(20) // Adjust the radius as needed
                          ),
                          child: user.userImageUrl.isNullOrEmpty() ? placeHolder : Image.file(File(user.userImageUrl!)),
                        ),
                        title: NormalTextWidget(
                          "${user.usersessionprofile?.firstName} ${user.usersessionprofile?.lastName}",
                          textAlign: TextAlign.start,
                          fontWeight: AFontWight.regular,
                        ),
                        subtitle: NormalTextWidget(
                          user.usersessionprofile?.email ?? "",
                          textAlign: TextAlign.start,
                          fontWeight: AFontWight.regular,
                          fontSize: 13,
                        ),
                        onTap: () {
                          if(isNetWorkConnected()) {
                            _loginCubit
                                .setUserName(user.usersessionprofile?.email ?? "");
                            userName = "${user.usersessionprofile?.firstName} ${user.usersessionprofile?.lastName}";
                            _loginCubit.ssoLogin =
                                user.usersessionprofile?.loginType == 2;
                            print("LIGIN CUBIT ${user.usersessionprofile?.loginType}");
                            _loginCubit.getUserSSODetails(
                                user.usersessionprofile?.email ?? "");
                          } else{
                            _loginCubit.emitState(ErrorState(StateRendererType.isValid,context.toLocale!.login_nt_supported_offline_mode,time: DateTime.now().millisecondsSinceEpoch.toString() ));
                          }
                        },
                      );
                    }),
              ),
            ),
          ),
        ),
        const Divider(
          height: 1,
          thickness: 1,
          endIndent: 30,
          indent: 0,
          color: Colors.white54,
        ),
        const SizedBox(
          height: 30,
        ),
        ListTile(
          key: const Key("loginAccount"),
          leading: const AImageWidget(
            imagePath: "ic_another_account.png",
          ),
          contentPadding: EdgeInsets.all(0),
          dense: true,
          title: NormalTextWidget(
            context.toLocale!.lbl_another_acc,
            textAlign: TextAlign.start,
            fontWeight: AFontWight.regular,
          ),
          onTap: () {
            _loginCubit.mLoginObject.email = '';
            widget.handleBackPress!();
          },
        ),
        const SizedBox(
          height: 30,
        ),
        clearAllAccounts
      ]),
    );
  }

  _manageLoginResult(Result result) {
    dynamic data = result.data;

    //var cloudList = DataCenters.jsonToList(AConstants.clouds);
    if (data is List<DatacenterVo>) {
      DataCenters dataCenters = DataCenters(data);

      dataCenters.email = _loginCubit.mLoginObject.email;
      dataCenters.isFromSSO = _loginCubit.isSSOLogin;

      List<DatacenterVo>? availableCloudList;

      if (dataCenters.isFromSSO == true) {
        // Filter data based on available clouds & SSO login
        availableCloudList = dataCenters.clouds
            ?.where((i) => i.isUserAvailable == "true" && i.ssoEnabled == "true")
            .toList();

        dataCenters.clouds = availableCloudList;
      } else {
        // Filters data based on available clouds & Normal login
        availableCloudList =
            dataCenters.clouds?.where((i) => i.isUserAvailable == "true").toList();
        dataCenters.clouds = availableCloudList;
      }

      if (dataCenters.clouds!.isNotEmpty) {
        if (dataCenters.isFromSSO == true) {
          if (dataCenters.clouds!.length == 1 &&
              dataCenters.clouds![0].ssoEnabled == "true") {
            StorePreference.setStringData(AConstants.keyCloudTypeData,
                dataCenters.clouds![0].cloudId.toString());
              Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (context) => SSOWebView(
                            url: SSOWebView.getWebViewUrl(dataCenters.clouds![0]),
                            emailId: dataCenters.email ?? "",
                          )))
                  .then((value) {
                if (value is String) {
                  context.showSnack(value);
                } else {
                  if (value != null && (value as List).isNotEmpty) {
                    dynamic successResult =
                        SSOWebView.onSSOLoginResponse(value, dataCenters.email!);
                    if (successResult is String) {
                      context.showSnack(successResult); //error message
                    } else if (successResult is Map) {
                      widget.callback(LoginWidgetState.twoFactorLogin,
                          data: successResult,screenName:userName);
                    } else {
                      // navigate to dashboard screen
                      Log.d("user in login screen");
                      /*Navigator.pushNamedAndRemoveUntil(
                          context, Routes.dashboard, (route) => false);*/
                      widget.handleNavigation!(value[0]);
                    }
                  }
                }
              });
          } else if (dataCenters.clouds!.length > 1) {
            widget.callback(LoginWidgetState.dataCenter, data: dataCenters,screenName:userName);
          } else {
            context.showSnack("SSO not enabled for this user");
          }
        } else {
          if (dataCenters.clouds!.length > 1) {
            widget.callback(LoginWidgetState.dataCenter, data: dataCenters,screenName:userName);
          } else {
            StorePreference.setStringData(AConstants.keyCloudTypeData,
                dataCenters.clouds![0].cloudId.toString());
            widget.callback(LoginWidgetState.passwordLogin, data: dataCenters,screenName:userName);
          }
        }
      } else {
        if (dataCenters.isFromSSO == true) {
          context.showSnack("SSO not enabled for this user");
        } else {
          context.showSnack("User doesn't exist");
        }
      }
    }
  }
}
