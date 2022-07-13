import 'dart:convert';

import 'package:prabodham/model/customer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceKeys {
  //PREFERENCE KEYS
  static final String isLoggedIn_key = "isLoggedIn";
  static final String defaultAddress_key = "defaultAddress";
  static final String vendorID_key = "vendorId";

  //PREFERENCE OBJECT
  static Future<SharedPreferences> get getPref async => await SharedPreferences.getInstance();

  // //PREFERENCE ACCESS FOR SETTING VALUE
  static Future<bool> setUserDetail(String userDetail) async {
    final SharedPreferences prefs = await getPref;
    Customer _user = Customer.fromJson(jsonDecode(userDetail));
    setUserId(_user.customerId);
    return prefs.setString(isLoggedIn_key, userDetail);
  }

  // //PREFERENCE ACCESS FOR FETCHING VALUE
  static Future<String> getUserDetail() async {
    final SharedPreferences prefs = await getPref;
    return prefs.getString(isLoggedIn_key) ?? null;
  }

  // //PREFERENCE ACCESS FOR SETTING VALUE
  static Future<bool> setDefaultAddress(String defaultAddress) async {
    print("Setting Address IN PREF : " + defaultAddress);
    final SharedPreferences prefs = await getPref;
    return prefs.setString(defaultAddress_key, defaultAddress);
  }

  // //PREFERENCE ACCESS FOR FETCHING VALUE
  static Future<String> getDefaultAddress() async {
    final SharedPreferences prefs = await getPref;
    return prefs.getString(defaultAddress_key) ?? null;
  }

  // //PREFERENCE ACCESS FOR SETTING VALUE
  static Future<bool> setUserId(int userId) async {
    final SharedPreferences prefs = await getPref;
    return prefs.setString(vendorID_key, userId.toString());
  }

  // //PREFERENCE ACCESS FOR FETCHING VALUE
  static Future<String> getUserId() async {
    final SharedPreferences prefs = await getPref;
    return prefs.getString(vendorID_key) ?? "";
  }

  //PREFERENCE CLEARANCE

  static Future<bool> removeCacheDetail() async {
    final SharedPreferences prefs = await getPref;
    return prefs.clear();
  }

  //Check if key is in sharedprefrence or not
  static Future<bool> containsKey(String key) async {
    final SharedPreferences prefs = await getPref;
    if (prefs.containsKey(key)) {
      return true;
    } else {
      return false;
    }
  }
}
