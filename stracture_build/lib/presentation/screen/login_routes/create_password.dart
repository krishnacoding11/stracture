
import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/login/login_cubit.dart';
import '../../../data/model/forgotpassword_vo.dart';
import '../../../logger/logger.dart';
import '../../../networking/network_response.dart';
import '../../../widgets/elevatedbutton.dart';
import '../../../widgets/headlinetext.dart';
import '../../../widgets/normaltext.dart';
import '../../../widgets/textformfieldwidget.dart';
import '../../managers/color_manager.dart';
import '../../managers/font_manager.dart';


class CreatePasswordWidget extends StatefulWidget {
  final Function callback;
 final dynamic paramData;
 Function? handleBackPress;
 CreatePasswordWidget(this.callback, {Key? key, this.paramData, this.handleBackPress}) : super(key: key);

  @override
  State<CreatePasswordWidget> createState() => _CreatePasswordWidgetState();
}

class _CreatePasswordWidgetState extends State<CreatePasswordWidget> {
  String encryptedData = '';
  String decryptedData = '';
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _btnEnabled = false;

  @override
  void initState() {
    print("User id ${widget.paramData.toString()}");
    newPasswordController.addListener(() {
      if (newPasswordController.text.isNotEmpty &&
          confirmPasswordController.text.isNotEmpty) {
        setState(() {
          _btnEnabled = true;
        });
      } else {
        setState(() {
          _btnEnabled = false;
        });
      }
    });

    confirmPasswordController.addListener(() {
      if (confirmPasswordController.text.isNotEmpty &&
          newPasswordController.text.isNotEmpty) {
        setState(() {
          _btnEnabled = true;
        });
      } else {
        setState(() {
          _btnEnabled = false;
        });
      }
    });
    super.initState();
  }

  var iconInValid = Icons.close;

  var activeIcon = Icons.done;

  var validationList = [
    "At least 6 characters",
    "At least 1 uppercase letter",
    "At least 1 lower case letter",
    "At least 1 number"
  ];

  Widget _containerTextFields(Widget lblChild, Widget inputChild) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: lblChild,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: AColors.white,
              boxShadow: const [
                BoxShadow(color: Colors.white, spreadRadius: 2),
              ],
            ),
            child: inputChild,
          ),
        ),
      ],
    );
  }

  bool _obscureText = true;

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final txtForgot = HeadlineTextWidget(
      context.toLocale!.lbl_create_password,
    );

    final lblNewPassword = Align(
      alignment: Alignment.centerLeft,
      child: NormalTextWidget(
        context.toLocale!.lbl_new_password,
      ),
    );

    final containerNewPassword = _containerTextFields(
      lblNewPassword,
      ATextFormFieldWidget(
        key: const Key('NewPasswordField'),
          isPassword: true,
          obscureText: _obscureText,
          controller: newPasswordController,
          hintText: context.toLocale!.login_et_new_password,
          onShowPasswordClick: _toggle
      ),
    );

    final lblConfirmPassword = Align(
      alignment: Alignment.centerLeft,
      child: NormalTextWidget(
        context.toLocale!.lbl_confirm_password,
      ),
    );

    final containerConfirmPassword = _containerTextFields(
      lblConfirmPassword,
      ATextFormFieldWidget(
        key: const Key('ConfirmPasswordField'),
          isPassword: true,
          obscureText: _obscureText,
          controller: confirmPasswordController,
          hintText: context.toLocale!.login_et_confirm_password,
          onShowPasswordClick: _toggle),
    );

  /*  final lblPasswordContain = Align(
      alignment: Alignment.centerLeft,
      child: NormalTextWidget(
        context.toLocale!.lbl_password_contain,
      ),
    );*/

    final listValidationWidget = Visibility(
      visible: false,
      child: ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(3),
          physics: const NeverScrollableScrollPhysics(),
          itemCount: validationList.length,
          itemBuilder: (context, count) {
            return RichText(
                text: TextSpan(children: [
              WidgetSpan(
                child: Icon(
                  _btnEnabled ? activeIcon : iconInValid,
                  size: 18,
                  color: _btnEnabled ? Colors.green : Colors.red,
                ),
              ),
              TextSpan(
                  text: validationList[count],
                  style: TextStyle(
                      color: AColors.textColor,
                      fontFamily: 'Sofia',
                      fontWeight: AFontWight.semiBold)),
            ]));
          }),
    );

    final containerReset = FractionallySizedBox(
      widthFactor: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AElevatedButtonWidget(
          btnLabel: context.toLocale!.lbl_btn_reset_password,
          btnLabelClr: _btnEnabled ? Colors.white : Colors.grey,
          btnBackgroundClr:
              _btnEnabled ? AColors.themeBlueColor : AColors.btnDisableClr,
          onPressed: _btnEnabled ?() {
            // Future.delayed(Duration(seconds: 2),(){
              doNewSetPassword();
            // });
          } : null,
        ),
      ),
    );

    final containerCancel = FractionallySizedBox(
      widthFactor: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AElevatedButtonWidget(
          btnLabel: context.toLocale!.lbl_btn_cancel,
          btnBackgroundClr: AColors.white,
          btnLabelClr: AColors.themeBlueColor,
          btnBorderClr: AColors.themeBlueColor,
          onPressed: () {
            widget.handleBackPress!();
          },
        ),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        txtForgot,
        const SizedBox(
          height: 30,
        ),
        containerNewPassword,
        containerConfirmPassword,
        const SizedBox(
          height: 20,
        ),
        /*Padding(
          padding: const EdgeInsets.all(4.0),
          child: lblPasswordContain,
        ),
        listValidationWidget,*/
        containerReset,
        containerCancel,
      ],
    );
  }

  doNewSetPassword() async {
     dynamic userStr = '${widget.paramData.toString()}';
    // dynamic userStr = await getInitialUri();
    if(userStr.isNotEmpty)
    {
      Uri url = Uri.parse(userStr);
      List<String> nlid = url.queryParameters['nlid']!.split('_');
      print(nlid[2]);
      String userIdStr = nlid[2];
      context.closeKeyboard();
      LoginCubit _loginBloc = BlocProvider.of<LoginCubit>(context);
      String newPass = await newPasswordController.text.encrypt();
      String confirmPass = await confirmPasswordController.text.encrypt();
      Result? result = await _loginBloc.doResetPassword(newPass, confirmPass, "en_GB", userIdStr);
      _loginBloc.isForgotPassword = false;
      // PreferenceUtils.setBool(AConstants.keyCreatePasswordLink,false);
      if(result is SUCCESS) {
        ForgotPasswordVo forgotPasswordVo = result.data;
        Log.d("reset call response ${forgotPasswordVo.status}");
        if (forgotPasswordVo.status == 'Success') {
          context.showSnack("Your password has been reset successfully");
          Future.delayed(const Duration(seconds: 2),(){
            widget.handleBackPress!();
          });
        }
        else {
          if (forgotPasswordVo.errorMsg != null) {
            context.showSnack(forgotPasswordVo.errorMsg.toString());
          }
        }
      }
    }
    else
    {
      context.showSnack('Something get wrong! Please try again');
    }
  }
}
