import 'package:flutter/material.dart';
import 'package:prabodham/global/variable/text_strings.dart';
import 'package:prabodham/global/variable/text_style_decoration.dart';
import 'package:prabodham/widgets/custom_material_color.dart';

class CustomAppTheme {
  //Colors
  static Color canvasColor = Color(0xffF8F8F8);
  static Color primaryColor = Color(0xfffea00b);
  static Color splashScreenGrey = Colors.grey[200];
  static Color darkHeader = Color(0xFF271C6D);
  static Color black = Colors.black;
  static Color white = Colors.white;
  static Color grey = Colors.grey;
  static Color red = Colors.red;
  static Color green = Colors.green;
  static Color transparent = Colors.transparent;
  static Color lightBlack = Color(0xFF7F8798);
  static Color lightGrey = Color(0xFFCED2DA);

  static ThemeData lightTheme = ThemeData(
    primaryColor: Color(0xfffea00b),
    primarySwatch: createMaterialColor(Color(0xfffea00b)),
    accentColor: black,
    cardColor: Colors.white,
    canvasColor: canvasColor,
    backgroundColor: green,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(primary: primaryColor),
    textTheme: TextStyleDecoration.getheme,
    fontFamily: TextStrings.APP_FONT,
    buttonTheme: ButtonThemeData(
      textTheme: ButtonTextTheme.primary,
      height: 64.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      color: canvasColor,
      brightness: Brightness.light,
      iconTheme: IconThemeData(
        color: CustomAppTheme.black,
      ),
      textTheme: TextTheme(
        title: TextStyle(
          fontSize: 18,
          fontFamily: TextStrings.APP_FONT,
          color: CustomAppTheme.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
