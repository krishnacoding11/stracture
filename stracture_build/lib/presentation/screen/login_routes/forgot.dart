import 'package:field/bloc/login/login_cubit.dart';
import 'package:field/injection_container.dart';
import 'package:field/networking/network_response.dart';
import 'package:field/utils/extensions.dart';
import 'package:field/widgets/backtologin_textbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:open_mail_app/open_mail_app.dart';

import '../../../analytics/event_analytics.dart';
import '../../../data/model/forgotpassword_vo.dart';
import '../../../logger/logger.dart';
import '../../../widgets/elevatedbutton.dart';
import '../../../widgets/headlinetext.dart';
import '../../../widgets/normaltext.dart';
import '../../../widgets/progressbar.dart';
import '../../../widgets/textformfieldwidget.dart';
import '../../base/state_renderer/state_render_impl.dart';
import '../../managers/color_manager.dart';

class ForgotPasswordWidget extends StatefulWidget {
  final Function callback;
  Function? handleBackPress;
  ForgotPasswordWidget(this.callback, {Key? key, this.handleBackPress})
      : super(key: key);

  @override
  State<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  TextEditingController nameController = TextEditingController();
  bool _btnEnabled = false;
  final LoginCubit _loginCubit = getIt<LoginCubit>();

  get chooserTitle => null;

  @override
  void initState() {
    nameController.text = _loginCubit.mLoginObject.email;
    if (nameController.text.isNotEmpty) {
      _btnEnabled = true;
    }
    nameController.addListener(() {
      if (nameController.text.isNotEmpty) {
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
              color: Colors.white,
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

  resetOpenMailBox() async {
    var result = await OpenMailApp.openMailApp(
        nativePickerTitle: context.toLocale!.choose_mail_app);
    // If no mail apps found, show error
    if (!result.didOpen && !result.canOpen) {
      return showNoMailAppsDialog(context);

      // iOS: if multiple mail apps found, show dialog to select.
      // There is no native intent/default app system in iOS so
      // you have to do it yourself.
    } else if (!result.didOpen && result.canOpen) {
      return showDialog(
        context: context,
        builder: (_) {
          return MailAppPickerDialog(
            mailApps: result.options,
            // onOpenMail: (){
            //
            // },
          );
        },
      );
    }
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Open Mail App"),
          content: const Text("No mail apps installed"),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lblEmailDesc = Align(
      alignment: Alignment.center,
      child: NormalTextWidget(
        context.toLocale!.lbl_forgot_password_desc,
      ),
    );

    final lblEmail = Align(
      alignment: Alignment.centerLeft,
      child: NormalTextWidget(
        context.toLocale!.lbl_email_address,
      ),
    );

    final txtForgot = HeadlineTextWidget(
      context.toLocale!.lbl_forgot_password,
    );

    final containerEmail = _containerTextFields(
      lblEmail,
      ATextFormFieldWidget(
        key: const Key('Emailfield'),
          isPassword: false,
          obscureText: false,
          controller: nameController,
          hintText: context.toLocale!.login_et_user_email),
    );

    final containerResetPassword = BlocBuilder<LoginCubit, FlowState>(
      builder: (context,state) {
        return  (state is LoadingState)
            ? const ACircularProgress()
            : FractionallySizedBox(
          widthFactor: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AElevatedButtonWidget(
              btnLabel: context.toLocale!.lbl_reset_password,
              btnLabelClr: _btnEnabled ? Colors.white : AColors.lightGreyColor,
              btnBackgroundClr:
                  _btnEnabled ? AColors.themeBlueColor : AColors.btnDisableClr,
              onPressed: _btnEnabled
                  ? () {
                      // widget.callback(LoginWidgetState.createPassword);
                      doresetPassword();
                      FireBaseEventAnalytics.setEvent(FireBaseEventType.resetPassword, FireBaseFromScreen.login);
                    }
                  : null,
            ),
          ),
        );
      }
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        txtForgot,
        const SizedBox(
          height: 30,
        ),
        lblEmailDesc,
        const SizedBox(
          height: 30,
        ),
        containerEmail,
        const SizedBox(
          height: 20,
        ),
        containerResetPassword,
        ATextbuttonWidget(
            label: context.toLocale!.lbl_back_sign_in,
            buttonIcon: Icons.arrow_back,
            onPressed: () {
              widget.handleBackPress!();
            }),
      ],
    );
  }

  doresetPassword() async {
    FocusManager.instance.primaryFocus?.unfocus();
    Result? result =
        await _loginCubit.doSetPasswordRequest(nameController.text);

    if (result is SUCCESS) {
      ForgotPasswordVo forgotPasswordVo = result.data;
      Log.d("reset call response ${forgotPasswordVo.status}");
      if (forgotPasswordVo.status == 'success') {
        final snackBar = SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 25),
            content: Text(
                context.toLocale!.lbl_password_desc),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
                textColor: Colors.white,
                label: context.toLocale!.lbl_ok,
                onPressed: () {
                  resetOpenMailBox();
                }));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        _loginCubit.isForgotPassword = true;
        Log.d("isCreatePassword: ${_loginCubit.isForgotPassword}");
      } else {
        if (forgotPasswordVo.errorMsg != null) {
          context.showSnack(forgotPasswordVo.errorMsg.toString());
        }
      }
    }
  }
}
