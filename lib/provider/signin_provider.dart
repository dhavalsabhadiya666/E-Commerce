import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/user_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/screen/container_page.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class SignInProvider extends ChangeNotifier {
  UserApi _userApi = UserApi();

  bool isLoading = false;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> singIn(
      {@required FormData data, @required BuildContext context}) async {
    setLoading(true);
    try {
      ApiResponseModel apiResponse = await _userApi.signIn(data: data);
      print("SignIn Api response data :- ");
      print(apiResponse.response);

      if (apiResponse.success == true && apiResponse.response != null) {
        PreferenceKeys.setUserDetail(jsonEncode(apiResponse.response));
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => ContainerPage()));
        setLoading(false);
      } else {
        setLoading(false);
        Functions.toast(apiResponse.message);
      }
    } catch (e) {
      print(e.toString());
      setLoading(false);
      final errorMessage = DioExceptions.fromDioError(e).toString();
      showCustomDialog(context, 'Error', errorMessage);
    }
  }
}
