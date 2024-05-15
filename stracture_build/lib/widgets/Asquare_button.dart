import 'package:field/utils/utils.dart';
import 'package:flutter/material.dart';

class AsquareButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  dynamic color;
  dynamic buttonIcon;

  AsquareButton(
      {Key? key,
      required this.label,
      required this.onPressed,
      this.buttonIcon,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color.fromRGBO(13, 39, 69, 1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      type: MaterialType.card,
      elevation: 0.0,
      child: InkWell(
        highlightColor: Colors.white24,
        onTap: onPressed,
        child: Padding(
          padding: Utility.isTablet
              ? const EdgeInsets.all(14)
              : const EdgeInsets.all(10),
          child: Text(label,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w400,
                  fontSize: Utility.isTablet ? 24 : 18)),
        ),
      ),
    );
  }
}
