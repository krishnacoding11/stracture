import 'package:flutter/material.dart';

class AImageWidget extends StatelessWidget {
  final String imagePath;

  const AImageWidget({Key? key, required this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Image(
        image: AssetImage("assets/images/$imagePath"));
  }
}
