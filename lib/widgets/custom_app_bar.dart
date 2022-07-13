import 'package:flutter/material.dart';

Widget CustomAppBar(
    {BuildContext context,
    Widget title,
    Widget leading,
    bool centerTitle,
    List<Widget> actions,
    double elevation}) {
  return AppBar(
      backgroundColor: Color.fromRGBO(249, 249, 249, 1),
      centerTitle: centerTitle ?? true,
      shadowColor: Colors.black38,
      toolbarHeight: 60,
      elevation: elevation ?? 0,
      bottomOpacity: 0.5,
      title: title,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      leading: leading ?? null,
      actions: actions != null ? actions : []);
}
