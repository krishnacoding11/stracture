import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../presentation/managers/color_manager.dart';
import '../presentation/managers/font_manager.dart';

Widget highLightText({String? text, String? searchText}) {

  final style = TextStyle(fontSize: 16.5,
    fontWeight: AFontWight.semiBold,
    overflow: TextOverflow.ellipsis,
    color: AColors.themeBlueColor.withOpacity(0.8));
  final spans = _getSpans(text!, searchText!, style);

  return RichText(
    maxLines: 1,
    textAlign: TextAlign.start,
    text: TextSpan(
      style: TextStyle(fontSize: 15,
          fontWeight: AFontWight.medium,
          overflow: TextOverflow.ellipsis,
          color: AColors.textColor),
      children: spans,
    ),
  );
}

List<TextSpan> _getSpans(String text, String matchWord, TextStyle style) {

  List<TextSpan> spans = [];
  int spanBoundary = 0;

  do {

    // look for the next match
    final startIndex = text.toLowerCase().indexOf(matchWord.toLowerCase(), spanBoundary);

    // if no more matches then add the rest of the string without style
    if (startIndex == -1) {
      spans.add(TextSpan(text: text.substring(spanBoundary)));
      return spans;
    }

    // add any unstyled text before the next match
    if (startIndex > spanBoundary) {
      spans.add(TextSpan(text: text.substring(spanBoundary, startIndex)));
    }

    // style the matched text
    final endIndex = startIndex + matchWord.length;
    final spanText = text.substring(startIndex, endIndex);
    spans.add(TextSpan(text: spanText, style: style));

    // mark the boundary to start the next search from
    spanBoundary = endIndex;

    // continue until there are no more matches
  } while (spanBoundary < text.length);

  return spans;
}
