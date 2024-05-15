import 'package:field/presentation/managers/color_manager.dart';
import 'package:flutter/material.dart';

import '../presentation/managers/font_manager.dart';

class ATextFormFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  bool? autofocus;
  bool isPassword = false;
  bool obscureText = false;
  final InputBorder? border;
  final InputBorder? focusBorder;
  final dynamic keyboardType;
  final VoidCallback? onShowPasswordClick;
  final dynamic prefixIcon;

  ATextFormFieldWidget(
      {required Key? key,
      required this.controller,
      required this.hintText,
      this.errorText,
      this.autofocus,
      required this.isPassword,
      required this.obscureText,
      this.keyboardType,
      this.border,
      this.focusBorder,
      this.onShowPasswordClick,
      this.prefixIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child:
        Semantics(
        label: key.toString(),
    child: TextFormField(
        keyboardType: keyboardType ?? TextInputType.text,
        obscureText: obscureText,
        autofocus: autofocus ?? false,
        controller: controller,
        style: TextStyle(
          color: controller.text.isNotEmpty && obscureText ? AColors.grColorDark : AColors.black,
          fontSize: controller.text.isNotEmpty && obscureText ? 30 : 16.0,
          fontFamily: 'Sofia',
          fontWeight: AFontWight.regular,
        ),
        textAlignVertical: TextAlignVertical.center,
        maxLines: 1,
        onSaved: (val) => controller.text = val!,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsetsDirectional.only(start: 8.0),
          border: border ?? InputBorder.none,
          focusedBorder: focusBorder ?? InputBorder.none,
          hintText: hintText,
          errorText: errorText,
          prefixIcon: (prefixIcon != null) ? prefixIcon : null,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isPassword && controller.text.isNotEmpty)
                IconButton(
                    onPressed: () {
                      onShowPasswordClick?.call();
                    },
                    icon: Icon(
                        obscureText ? Icons.visibility : Icons.visibility_off)),
              if (controller.text.isNotEmpty)
                IconButton(
                  onPressed: controller.clear,
                  icon: const Icon(Icons.clear),
                ),
            ],
          ),
        ),
      ),),
    );
  }
}
