import 'package:flutter/material.dart';

import '../presentation/managers/font_manager.dart';
import 'normaltext.dart';

class DropDownWidget extends StatefulWidget {
  String? hintText;
  double? height;
  List<dynamic> contents = [];
  String? dropdownvalue;
  bool? hideUnderline = true;

  DropDownWidget({Key? key, required this.hintText, required this.contents, this.height, this.hideUnderline}) : super(key: key);

  @override
  State<DropDownWidget> createState() => _DropDownWidgetState();
}

class _DropDownWidgetState extends State<DropDownWidget> {
  @override
  Widget build(BuildContext context) {
    final dropDownItem = DropdownButton(
        value: widget.dropdownvalue ?? null,
        hint: NormalTextWidget("  ${widget.hintText}", color: Colors.black54, fontWeight: AFontWight.regular),
        isExpanded: true,
        items: widget.contents.map((e) {
          return DropdownMenuItem(
            value: '  $e',
            child: NormalTextWidget('  $e'),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            widget.dropdownvalue = newValue as String;
          });
        });
    return Container(
      height: widget.height ?? 38,
      child: widget.hideUnderline == true ? DropdownButtonHideUnderline(
        child: dropDownItem,
      ) : dropDownItem,
    );
  }
}
