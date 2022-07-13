import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:prabodham/helper/regular_expression.dart';

class Functions {
  //Check Internet...
  static Future<bool> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      } else {
        print("Please check your internet connectivity!");
        Functions.toast("Please check your internet connectivity!");
        return false;
      }
    } on SocketException catch (_) {
      print("No Internet !");
      Functions.toast("Please check your internet connectivity!");
      return false;
    }
  }

  static bool isEmail(String email) {
    RegExp regExp = Regex.email_expression;
    return regExp.hasMatch(email);
  }

  static void toast(String info) {
    Fluttertoast.showToast(
      msg: info,
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  static void showSnackBar(String info) {
    SnackBar(
      content: Text(info),
    );
  }

  static Future<String> getDeviceId() async {
    final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
    String device_id;

    try {
      if (Platform.isAndroid) {
        var build = await deviceInfoPlugin.androidInfo;
        print("Android ID : " + build.androidId);
        device_id = build.androidId;
      } else if (Platform.isIOS) {
        var build = await deviceInfoPlugin.iosInfo;
        print("Apple ID : " + build.identifierForVendor);
        device_id = build.identifierForVendor;
      }
      return device_id;
    } on PlatformException {
      print("Platform version cannot be found");
    }
  }
}
