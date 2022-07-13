import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/user_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/screen/signin_screen.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class SignUpProvider extends ChangeNotifier {
  UserApi _userApi = UserApi();

  bool isLoading = false;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> singUp({@required FormData data, @required BuildContext context}) async {
    setLoading(true);
    try {
      print(data);
      ApiResponseModel apiResponse = await _userApi.signUp(data: data);
      print("SignUp Api response data :- ");
      print(apiResponse.response);

      if (apiResponse.success == true) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SignInScreen()));
        final snackBar = SnackBar(
          content: Text(apiResponse.message),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
