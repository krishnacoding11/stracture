import 'package:flutter/material.dart';

class ImageSequenceAnimation extends StatefulWidget {
  const ImageSequenceAnimation({super.key, required this.imagePath, required this.currentIndex});
  final String imagePath;
  final int currentIndex;

  @override
  State<ImageSequenceAnimation> createState() => _ImageSequenceAnimationState();
}

class _ImageSequenceAnimationState extends State<ImageSequenceAnimation> {

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      fit: BoxFit.fill,
      width: 20,
      widget.imagePath,
      key: ValueKey<int>(widget.currentIndex),
    );
  }
}