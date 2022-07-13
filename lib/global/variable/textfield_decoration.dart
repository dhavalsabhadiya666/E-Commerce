import 'package:flutter/material.dart';

import 'custom_app_theme.dart';
import 'text_strings.dart';
import 'text_style_decoration.dart';

class TextFieldDecoration {
  static get cursorColor => _cursorColor;
  static BorderRadius get textBorderRadius => BorderRadius.circular(20.0);
  static double get borderWidth => 1.5;

  static InputDecorationTheme get getInputDecoration => InputDecorationTheme(
        filled: true,
        errorMaxLines: 2,
        fillColor: Colors.transparent,
        focusColor: Colors.transparent,
        hintStyle: TextStyleDecoration.placeholder,
        errorStyle: TextStyle(
          fontFamily: TextStrings.APP_FONT,
          color: Colors.red,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        // focusedErrorBorder: _focusedErrorBorder,
        // errorBorder: _errorBorder,
        // focusedBorder: _focusedBorder,
        // border: _border,

        // enabledBorder: _enabledBorder,
        // disabledBorder: _disabledBorder,
        contentPadding: EdgeInsets.only(
          top: 20.0,
          bottom: 20.0,
          right: 5.0,
          left: 10.0,
        ), // use to set textfield height...
      );
  static OutlineInputBorder _border = OutlineInputBorder(
    borderSide: BorderSide(
      color: CustomAppTheme.lightGrey,
      width: borderWidth,
    ),
  );

  static OutlineInputBorder _enabledBorder = OutlineInputBorder(
    borderRadius: textBorderRadius,
    borderSide: BorderSide(
      color: CustomAppTheme.lightGrey,
      width: borderWidth,
    ),
  );

  static OutlineInputBorder _disabledBorder = OutlineInputBorder(
    borderRadius: textBorderRadius,
    borderSide: BorderSide(
      color: CustomAppTheme.lightGrey,
      width: borderWidth,
    ),
  );

  // static OutlineInputBorder _focusedBorder = OutlineInputBorder(
  //   borderRadius: textBorderRadius,
  //   borderSide: BorderSide(
  //     color: CustomAppTheme.secondaryColor,
  //     width: borderWidth,
  //   ),
  // );

  static OutlineInputBorder _errorBorder = OutlineInputBorder(
    borderRadius: textBorderRadius,
    borderSide: BorderSide(
      color: Colors.red,
      width: borderWidth,
    ),
  );

  static OutlineInputBorder _focusedErrorBorder = OutlineInputBorder(
    borderRadius: textBorderRadius,
    borderSide: BorderSide(
      color: Colors.red,
      width: borderWidth,
    ),
  );

  static Color _cursorColor = CustomAppTheme.black;
}
