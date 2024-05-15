import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/data/model/datacenter_vo.dart';
import 'package:field/bloc/login/login_state.dart';
import 'package:field/logger/logger.dart';
import 'package:field/networking/network_info.dart';
import 'package:field/presentation/base/state_renderer/state_render_impl.dart';
import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/screen/onboarding_login_screen.dart';
import 'package:field/utils/constants.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/utils/store_preference.dart';
import 'package:field/widgets/backtologin_textbutton.dart';
import 'package:field/widgets/elevatedbutton.dart';
import 'package:field/widgets/headlinetext.dart';
import 'package:field/widgets/normaltext.dart';
import 'package:field/widgets/progressbar.dart';
import 'package:field/widgets/sso_webview.dart';
import 'package:field/injection_container.dart' as di;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../managers/font_manager.dart';

class DataCenterWidget extends StatefulWidget {
  final Function callback;
  Function? handleBackPress;
  final dynamic paramData;
  final String? screenName;
  Function? handleNavigation;

  DataCenterWidget(this.callback, {Key? key, this.paramData, this.screenName,this.handleBackPress,this.handleNavigation})
      : super(key: key);

  @override
  State<DataCenterWidget> createState() => _DataCenterWidgetState();
}

class _DataCenterWidgetState extends State<DataCenterWidget> {
  bool _btnEnabled = false;
  String? dropdownValue;
  DataCenters? dataCenters;
  DatacenterVo? selectedDatacenter;
  String? message;
  final loginCubit = di.getIt<LoginCubit>();

  List<DatacenterVo>? spinnerItems;

  @override
  void initState() {
    super.initState();
    //_bind();
    dataCenters = widget.paramData as DataCenters;
    spinnerItems = dataCenters?.clouds;
    loginCubit.updateDataCenterVisibility();
  }

  _validate() {
    setState(() {
      if (selectedDatacenter != null) {
        _btnEnabled = true;
      } else {
        _btnEnabled = false;
      }
    });
  }

  Widget dataCenterDropDown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Colors.white, spreadRadius: 3),
        ],
      ),
      height: 36,
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: DropdownButton<DatacenterVo>(
          key: const Key('datacenter_dropdown'),
          isExpanded: true,
          value: selectedDatacenter,
          hint: NormalTextWidget(
            context.toLocale!.lbl_select_dc,
            fontWeight: AFontWight.medium,
            color: AColors.hintColor,
          ),
          icon: const Icon(Icons.arrow_drop_down),
          underline: const SizedBox(),
          onChanged: (DatacenterVo? data) {
            setState(() {
              selectedDatacenter = data!;
              var selectedCloud = selectedDatacenter?.cloudId ?? "1";
              StorePreference.setStringData(
                  AConstants.keyCloudTypeData, selectedCloud.toString());
              _validate();
            });
          },
          items: spinnerItems
              ?.map<DropdownMenuItem<DatacenterVo>>((DatacenterVo value) {
            return DropdownMenuItem<DatacenterVo>(
              value: value,
              alignment: Alignment.centerLeft,
              child: NormalTextWidget(
                value.cloudName!,
                fontWeight: AFontWight.regular,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  doLogin(BuildContext context) {
    context.closeKeyboard();
    if (dataCenters?.isFromSSO ?? false) {
        Navigator.of(context)
            .push(MaterialPageRoute(
                builder: (context) => SSOWebView(
                      url: SSOWebView.getWebViewUrl(selectedDatacenter!),
                      emailId: dataCenters?.email ?? "",
                    )))
            .then((value) {
          if (value is String) {
            context.showSnack(value);
          } else {
            if (value != null && (value as List).isNotEmpty) {
              dynamic successResult =
                  SSOWebView.onSSOLoginResponse(value, (dataCenters?.email)!);
              if (successResult is String) {
                context.showSnack(successResult); //error message
              } else if (successResult is Map) {
                widget.callback(LoginWidgetState.twoFactorLogin,
                    data: successResult,screenName:widget.screenName);
              } else {
                // navigate to dashboard screen
                Log.d("user in login screen");
                loginCubit.updateDataCenterVisibility(true);
                /*Navigator.pushNamedAndRemoveUntil(
                    context, Routes.dashboard, (route) => false);*/
                widget.handleNavigation!(value[0]);
              }
            }
          }
        });
    } else {
      widget.callback(LoginWidgetState.passwordLogin, data: dataCenters,screenName:widget.screenName);
    }
    // }
  }

  @override
  Widget build(BuildContext context) {
    final txtName = (widget.screenName != null && widget.screenName!.isNotEmpty)
        ? HeadlineTextWidget(
            "Welcome \n ${widget.screenName}",
            style: TextStyle(
              color: AColors.textColor,
              fontFamily: AFonts.fontFamily,
              fontWeight: AFontWight.medium,
              decoration: TextDecoration.none,
            ),
          )
        : HeadlineTextWidget(
            context.toLocale!.lbl_sign_in,
            style: TextStyle(
              color: AColors.textColor,
              fontFamily: AFonts.fontFamily,
              fontWeight: AFontWight.medium,
              decoration: TextDecoration.none,
            ),
          );

    // final lblVerify = Padding(
    //   padding: const EdgeInsets.only(top:30),
    //   child: Align(
    //     alignment: Alignment.center,
    //     child: NormalTextWidget(
    //       context.toLocale!.lbl_account_desc,
    //     ),
    //   ),
    // );

    final lblDatacenterDesc = Align(
      alignment: Alignment.center,
      child: NormalTextWidget(
        context.toLocale!.lbl_data_center_desc,
        fontWeight: AFontWight.regular,
      ),
    );

    final lblDataCenter = Padding(
        padding: const EdgeInsets.all(3),
        child: Align(
          alignment: Alignment.centerLeft,
          child: NormalTextWidget(
            context.toLocale!.lbl_data_center,
            fontSize: 15,
            fontWeight: AFontWight.medium,
          ),
        ));

    final containerContinue =
        BlocBuilder<LoginCubit, FlowState>(builder: (context, state) {
      return (state is LoadingState)
          ? const ACircularProgress()
          : FractionallySizedBox(
              widthFactor: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AElevatedButtonWidget(
                  key: const Key('ContinueButton'),
                  btnLabel: context.toLocale!.lbl_btn_continue,
                  fontSize: 15,
                  fontWeight: AFontWight.medium,
                  btnLabelClr: _btnEnabled ? Colors.white : AColors.lightGreyColor,
                  btnBackgroundClr:
                      _btnEnabled ? AColors.themeBlueColor : AColors.btnDisableClr,
                  onPressed: _btnEnabled
                      ? () async {
                          if (isNetWorkConnected()) {
                            doLogin(context);
                          } else {
                            context.showSnack('No network available');
                          }
                        }
                      : null,
                ),
              ),
            );
    });

    return BlocListener<LoginCubit, FlowState>(
      listener: (context, state) {
        if (state is SuccessState) {
          // _manageLoginResult(state.result);
        } else if (state is ErrorState) {
          context.showSnack(state.message);
        }
      },
      child: BlocBuilder<LoginCubit, FlowState>(
        builder: (context, state) {
          return (state is UpdateDataCenterVisibility && !state.dataCenterdisabled)
            ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              txtName,
              const SizedBox(
                height: 30,
              ),
              lblDatacenterDesc,
              const SizedBox(
                height: 30,
              ),
              lblDataCenter,
              dataCenterDropDown(),
              // const SizedBox(
              //   height: 10,
              // ),
              const SizedBox(
                height: 15,
              ),
              containerContinue,
              ATextbuttonWidget(
                  label: context.toLocale!.lbl_back_sign_in,
                  buttonIcon: Icons.arrow_back,
                  fontSize: 15,
                  fontWeight: AFontWight.medium,
                  onPressed: () {
                    // widget.callback(LoginWidgetState.login);
                    widget.handleBackPress!();
                  }),
            ],
          ) : Center(
            child: Column(
              children: [
                const ACircularProgress(),
                const SizedBox(height: 30,),
                NormalTextWidget(context.toLocale!.warning_title_please_wait),
              ],
            ),
          );
        }
      ),
    );
  }
}
