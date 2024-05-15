import 'dart:math';

import 'package:flutter/material.dart';

import '../presentation/managers/color_manager.dart';
import '../presentation/managers/font_manager.dart';

MaterialColor generateMaterialColor(Color color) {
  return MaterialColor(color.value, {
    50: tintColor(color, 0.9),
    100: tintColor(color, 0.8),
    200: tintColor(color, 0.6),
    300: tintColor(color, 0.4),
    400: tintColor(color, 0.2),
    500: color,
    600: shadeColor(color, 0.1),
    700: shadeColor(color, 0.2),
    800: shadeColor(color, 0.3),
    900: shadeColor(color, 0.4),
  });
}

int tintValue(int value, double factor) =>
    max(0, min((value + ((255 - value) * factor)).round(), 255));

Color tintColor(Color color, double factor) => Color.fromRGBO(
    tintValue(color.red, factor),
    tintValue(color.green, factor),
    tintValue(color.blue, factor),
    1);

int shadeValue(int value, double factor) =>
    max(0, min(value - (value * factor).round(), 255));

Color shadeColor(Color color, double factor) => Color.fromRGBO(
    shadeValue(color.red, factor),
    shadeValue(color.green, factor),
    shadeValue(color.blue, factor),
    1);

class ATheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: generateMaterialColor(AColors.aPrimaryColor),
      primaryColor: AColors.themeBlueColor,
      fontFamily: 'Sofia',
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(shape: MaterialStateProperty.resolveWith((states) {
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        );
      }))
          /*style: ButtonStyle(shape: MaterialStateProperty.resolveWith((states) {
          return RoundedRectangleBorder(
            //side: BorderSide(color: Colors.red, width: 2,),
            borderRadius: BorderRadius.circular(18),
          );
        })),*/
          ),
      textTheme: const TextTheme(
        headline1: TextStyle(
          fontSize: 50,
          fontFamily: AFonts.fontFamily,
          fontWeight: AFontWight.bold,
        ),
        headline4: TextStyle(
          fontSize: 25,
          fontFamily: AFonts.fontFamily,
        ),
        headline6: TextStyle(
          fontSize: 22,
          fontFamily: AFonts.fontFamily,
        ),
        bodyText1: TextStyle(
          fontSize: 20,
          fontFamily: 'Sofia',
          fontWeight: AFontWight.bold,
        ),
      ),
    );
  }

  static ThemeData get transparentDividerTheme{
    return lightTheme.copyWith(dividerColor: Colors.transparent);
  }
}
