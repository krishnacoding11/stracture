import 'package:field/widgets/textformfieldwithchipsinputwidget.dart';
import 'package:flutter/material.dart';

import '../presentation/managers/color_manager.dart';
import '../presentation/managers/font_manager.dart';
import 'normaltext.dart';

class AChipWidget extends StatefulWidget {
  const AChipWidget({
    Key? key,
    required this.lblText,
    required this.selectedChipList,
    this.onChipDeleted,
  }) : super(key: key);
  final String lblText;
  final List<ChipData> selectedChipList;
  final Function? onChipDeleted;

  @override
  State<AChipWidget> createState() => _AChipWidgetState();
}

class _AChipWidgetState extends State<AChipWidget> {
  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical:10, horizontal: 15),
        suffixIcon: const Icon(Icons.add),
        labelText: widget.selectedChipList.isNotEmpty ? widget.lblText : "",
        fillColor: AColors.white,
        filled: true,
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black38, width: 1.0)),
        disabledBorder: InputBorder.none,
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black38, width: 1.0)),
      ),
      child: widget.selectedChipList.isNotEmpty
          ? Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: _chipsChildren(),
            )
          : Text(
              widget.lblText,
              style: TextStyle(
                color: AColors.hintColor,
                fontFamily: AFonts.fontFamily,
                fontSize: 16,
                fontWeight: AFontWight.regular,
              ),
            ),
    );
  }

  void deleteChip(ChipData data) {
    setState(() {
      widget.selectedChipList.remove(data);
    });
  }

  List<Widget> _chipsChildren() {
    return widget.selectedChipList
        .map<Widget>(
          (data) => InputChip(
            key: ObjectKey(data),
            backgroundColor: AColors.white,
            shape: StadiumBorder(side: BorderSide(color: AColors.themeBlueColor)),
            deleteIconColor: AColors.themeBlueColor,
            label: NormalTextWidget(
              data.displayLabel.split(",").first,
              textAlign: TextAlign.start,
              fontWeight: AFontWight.regular,
              fontSize: 10.0,
              color: AColors.themeBlueColor,
            ),
            labelStyle: TextStyle(color: AColors.textColor1),
            onDeleted: () {
              deleteChip(data);
              if (widget.onChipDeleted != null) {
                widget.onChipDeleted!(data);
              }
            },
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        )
        .toList();
  }
}
