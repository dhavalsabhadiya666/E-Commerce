import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/user_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/helper/regular_expression.dart';
import 'package:prabodham/screen/signin_screen.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  UserApi _userApi = UserApi();
  final _forgetPasswordForm = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    print("Forgot Password");
  }

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  Future<void> forgetPassword({@required BuildContext context}) async {
    setLoading(true);
    try {
      FormData data =
          new FormData.fromMap({'customer_email': emailController.text});
      ApiResponseModel apiResponse =
          await _userApi.forgetPassword(data: data, context: context);
      print("Forget Password Api response data :- ");
      print(apiResponse.response);

      if (apiResponse.success == true) {
        setLoading(false);
        Functions.toast(apiResponse.message);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => SignInScreen()));
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        print("Back");
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.only(top: 30),
                        alignment: Alignment.topLeft,
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 25,
                        ),
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 6,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Forgot password",
                        style: Theme.of(context).textTheme.headline,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: Form(
                        key: _forgetPasswordForm,
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: CustomInputField(
                                controller: emailController,
                                validator: emailValidator,
                                label: "Email",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () async {
                        FocusScope.of(context).unfocus();
                        print("Forgetting Password");
                        if (_forgetPasswordForm.currentState.validate()) {
                          await forgetPassword(
                            context: context,
                          );
                        }
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(25)),
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                            child: Text(
                          "SEND",
                          style: Theme.of(context).textTheme.button,
                        )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                print("Back");
                Navigator.pop(context);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                alignment: Alignment.topLeft,
                child: Icon(
                  Icons.arrow_back_ios,
                  size: 25,
                ),
              ),
            ),
            Container(
              child: isLoading
                  ? Loader(
                      bgColor: Colors.black54,
                      loaderColor: Colors.white,
                    )
                  : Container(),
            )
          ],
        ),
      ),
    );
  }

  Widget CustomInputField({
    TextEditingController controller,
    ValueChanged<String> validator,
    String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      color: Colors.white,
      child: Container(
        child: TextFormField(
          style: Theme.of(context).textTheme.body2,
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: true,
          validator: validator,
          onTap: () {},
          onChanged: (value) {},
          decoration: InputDecoration(
            labelText: label,
            labelStyle: Theme.of(context)
                .textTheme
                .body1
                .copyWith(color: CustomAppTheme.grey),
            contentPadding: EdgeInsets.all(15),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget CustomButtonWidget({
    Text ButtonIcon,
    int buttonPadding,
    Null Function() onPress,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 5,
      ),
      width: MediaQuery.of(context).size.width,
      child: TextButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(15)),
          backgroundColor:
              MaterialStateProperty.all<Color>(Theme.of(context).primaryColor),
          foregroundColor:
              MaterialStateProperty.all<Color>(CustomAppTheme.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          )),
        ),
        onPressed: onPress,
        child: ButtonIcon,
      ),
    );
  }

  String emailValidator(value) {
    if (value.length == 0) {
      return "Email Empty";
    } else if (!Regex.email_expression.hasMatch(value)) {
      return "Invalid Email Format";
    }
  }
}
