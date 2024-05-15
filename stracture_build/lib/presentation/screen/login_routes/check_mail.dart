import 'package:field/utils/extensions.dart';
import 'package:flutter/material.dart';

import '../../../widgets/backtologin_textbutton.dart';
import '../../../widgets/elevatedbutton.dart';
import '../../../widgets/headlinetext.dart';
import '../../../widgets/normaltext.dart';
import '../../managers/color_manager.dart';
import '../onboarding_login_screen.dart';

class CheckMailWidget extends StatefulWidget {
  final Function callback;
  final String? title, desc, btnText;

  const CheckMailWidget(this.callback,
      {Key? key, this.title, this.desc, this.btnText})
      : super(key: key);

  @override
  State<CheckMailWidget> createState() => _CheckMailWidgetState();
}

class _CheckMailWidgetState extends State<CheckMailWidget> {
  @override
  Widget build(BuildContext context) {
    final lblCheckMail = HeadlineTextWidget(
      widget.title ?? context.toLocale!.lbl_check_mail,
    );

    final lblInstruction = Align(
      alignment: Alignment.center,
      child: NormalTextWidget(
        widget.desc ?? context.toLocale!.lbl_password_desc,
      ),
    );

    final containerOpenMail = FractionallySizedBox(
      widthFactor: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: AElevatedButtonWidget(
          btnLabel: widget.btnText ?? context.toLocale!.lbl_open_mail_app,
          btnLabelClr: Colors.white,
          btnBackgroundClr: AColors.themeBlueColor,
          onPressed: () {
            if (widget.title != null) {
              widget.callback(LoginWidgetState.login);
            } else {
              widget.callback(LoginWidgetState.createPassword);
            }
          },
        ),
      ),
    );

    final backToSign = ATextbuttonWidget(
        label: context.toLocale!.lbl_back_sign_in,
        buttonIcon: Icons.arrow_back,
        onPressed: () {
          widget.callback(LoginWidgetState.login);
        });

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        lblCheckMail,
        const SizedBox(
          height: 50,
        ),
        lblInstruction,
        const SizedBox(
          height: 50,
        ),
        containerOpenMail,
        Visibility(
            visible: widget.title != null ? false : true,
            child: backToSign)
      ],
    );
  }
}
