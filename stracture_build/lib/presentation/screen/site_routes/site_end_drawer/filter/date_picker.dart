import 'package:field/presentation/managers/color_manager.dart';
import 'package:field/presentation/managers/font_manager.dart';
import 'package:flutter/material.dart';

class CustomDateField extends StatefulWidget {
  final String textLabel;
  final int index;
  String date;

  CustomDateField(
      {super.key,
      required this.index,
      required this.textLabel,
      required this.date});

  @override
  State<CustomDateField> createState() => _CustomDateFieldState();
}

class _CustomDateFieldState extends State<CustomDateField> {

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom:0),
      child: TextFormField(
        initialValue: widget.date,
        textAlignVertical: TextAlignVertical.center,
        enabled: false,
        onTap: () {},
        onChanged: (value) {},
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal:15),
          focusColor: AColors.themeBlueColor,
          fillColor: AColors.white,
          filled: true,
          //add prefix icon
          prefixIcon: widget.date.isNotEmpty ? null:const Icon(
            Icons.date_range_sharp,
            color: Colors.black12,
          ),
          hintText: "dd-MMM-yyyy",
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black38, width: 1.0),
            borderRadius: BorderRadius.circular(5.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black38, width: 1.0),
            borderRadius: BorderRadius.circular(5.0),
          ),
          border: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black38, width: 1.0),
            borderRadius: BorderRadius.circular(5.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black38, width: 1.0),
            borderRadius: BorderRadius.circular(5.0),
          ),
          //make hint text
          hintStyle: const TextStyle(
            color: Colors.black12,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          labelText: widget.textLabel,
          labelStyle: TextStyle(
            color: AColors.hintColor,
            fontFamily: AFonts.fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
