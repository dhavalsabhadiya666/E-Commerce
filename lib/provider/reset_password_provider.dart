import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/user_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class ResetPasswordProvider extends ChangeNotifier {
  UserApi _userApi = UserApi();

  bool isLoading = false;
  bool get getIsLoading => isLoading;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> resetPassword(
      {@required FormData data, @required BuildContext context}) async {
    setLoading(true);
    try {
      ApiResponseModel apiResponse =
          await _userApi.resetPassword(context: context, data: data);
      print("Reset Password Api response data :- ");
      print(apiResponse.response);

      if (apiResponse.success == true) {
        setLoading(false);
        Navigator.of(context).pop();
        Functions.toast(apiResponse.message);
      } else {
        setLoading(false);
        print(apiResponse.message);
        //Navigator.of(context).pop();
        // showCustomDialog(context, 'Error', apiResponse.message);
        //Functions.toast(apiResponse.message);
      }
    } catch (e) {
      print(e.toString());
      setLoading(false);
      final errorMessage = DioExceptions.fromDioError(e).toString();
      showCustomDialog(context, 'Error', errorMessage);
    }
  }
}
