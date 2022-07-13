import 'package:flutter/material.dart';
import 'package:prabodham/global/variable/text_strings.dart';

class TextStyleDecoration {
  static TextTheme get getheme => TextTheme(
        body1: _body1,
        body2: _body2,
        display1: _display1,
        display2: _display2,
        display3: _display3,
        display4: _display4,
        headline: _headline,
        subhead: _subHeadline,
        title: _title,
        subtitle: _subTitle,
        button: _button,
        caption: _caption,
        overline: _overline,
      );
  static TextStyle get textfieldContent => _body1;
  static TextStyle get placeholder => _body2;

  static const String fontFamily = TextStrings.APP_FONT;

//using normal text
  static TextStyle _body1 = TextStyle(
    fontFamily: fontFamily,
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

//using text in text cart screen
  static TextStyle _body2 = TextStyle(
    fontFamily: fontFamily,
    color: Colors.black,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

//using in title  New , Sales ,Beauty Trends
  static TextStyle _title = TextStyle(
    fontFamily: fontFamily,
    color: Colors.black,
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

//using title like my profile , my order ,Rewies and Rattings
  static TextStyle _subTitle = TextStyle(
    fontFamily: fontFamily,
    color: Colors.black,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

//using in heading like login ,signup ,forgot password
  static TextStyle _headline = TextStyle(
    fontFamily: fontFamily,
    color: Colors.black,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

//using in Appbar text
  static TextStyle _subHeadline = TextStyle(
    fontFamily: fontFamily,
    color: Colors.black,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

//using button text
  static TextStyle _button = TextStyle(
    fontFamily: fontFamily,
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );

//using in  very small texts
  static TextStyle _caption = TextStyle(
    fontFamily: fontFamily,
    color: Colors.grey,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle _display1 = TextStyle(
    fontFamily: fontFamily,
    color: Colors.black,
    fontSize: 30,
    fontWeight: FontWeight.w600,
  );

  static TextStyle _display2 = TextStyle(
    fontFamily: fontFamily,
    color: Colors.black,
    fontSize: 34,
    fontWeight: FontWeight.w700,
  );

  static TextStyle _display3 = TextStyle(
    fontFamily: fontFamily,
    color: Colors.black,
    fontSize: 45,
    fontWeight: FontWeight.w700,
  );

  static TextStyle _display4 = TextStyle(
    fontFamily: fontFamily,
    color: Colors.black,
    fontSize: 56,
    fontWeight: FontWeight.w100,
  );

  static TextStyle _overline = TextStyle(
    fontFamily: fontFamily,
    color: Colors.black,
    fontSize: 10,
    fontWeight: FontWeight.w400,
  );
}

// display4   112.0  thin     headline1
// display3   56.0   normal   headline2
// display2   45.0   normal   headline3
// display1   34.0   normal   headline4
// headline   24.0   normal   headline5
// title      20.0   medium   headline6
// subhead    16.0   normal   subtitle1
// body2      14.0   medium   body1
// body1      14.0   normal   body2
// caption    12.0   normal   caption
// button     14.0   medium   button
// subtitle   14.0   medium   subtitle2
// overline   10.0   normal   overline
