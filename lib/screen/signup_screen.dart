import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/helper/regular_expression.dart';
import 'package:prabodham/provider/signup_provider.dart';
import 'package:prabodham/screen/signin_screen.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _signupForm = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController referrerCodeController = TextEditingController();
  @override
  void initState() {
    super.initState();
    print("SignUp Screen");
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SignUpProvider>();

    Future<void> signUp({@required BuildContext context}) async {
      Functions.checkConnectivity().then((value) async {
        if (value != null && value == true) {
          FormData data = new FormData.fromMap({
            'customer_name': nameController.text,
            'customer_password': passwordController.text,
            'customer_email': emailController.text,
            'customer_mobile_number': mobileController.text,
            'customer_referrer_code': referrerCodeController.text
          });
          await context
              .read<SignUpProvider>()
              .singUp(context: context, data: data);
        }
      });
    }

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
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).viewPadding.top + 20),
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
                      child: Text("Sign Up",
                          style: Theme.of(context).textTheme.headline),
                    ),
                    Container(
                      child: Form(
                        key: _signupForm,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: CustomInputField(
                                controller: nameController,
                                validator: nameValidator,
                                label: "Name",
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: CustomInputField(
                                  controller: mobileController,
                                  validator: mobileValidator,
                                  label: "Mobile Number",
                                  inputType: TextInputType.number),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: CustomInputField(
                                controller: emailController,
                                validator: emailValidator,
                                label: "Email",
                                inputType: TextInputType.emailAddress,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: CustomInputField(
                                  controller: passwordController,
                                  validator: passwordValidator,
                                  label: "Password",
                                  obscureText: true),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: CustomInputField(
                                  controller: confirmPasswordController,
                                  validator: confirmPasswordValidator,
                                  label: "Confirm Password",
                                  obscureText: true),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 5),
                              child: CustomInputField(
                                  controller: referrerCodeController,
                                  label: "Referrer Code (optional)",
                                  obscureText: true),
                            ),
                            GestureDetector(
                              onTap: () {
                                _signupForm.currentState.reset();
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SignInScreen()),
                                    (Route<dynamic> route) => false);
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  top: 10,
                                ),
                                alignment: Alignment.centerRight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "Already have an account ?",
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        print("Signing Up");
                        if (_signupForm.currentState.validate()) {
                          signUp(context: context);
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
                          "SIGN UP",
                          style: Theme.of(context).textTheme.button,
                        )),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // Column(
                    //   mainAxisSize: MainAxisSize.min,
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Container(
                    //       child: Text("Or login with social account",
                    //           style: Theme.of(context).textTheme.body2),
                    //     ),
                    //     Container(
                    //       margin: EdgeInsets.only(top: 10),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           GestureDetector(
                    //             onTap: () {},
                    //             child: Container(
                    //               height: 64,
                    //               width: 92,
                    //               decoration: BoxDecoration(
                    //                   color: CustomAppTheme.white,
                    //                   borderRadius: BorderRadius.circular(24)),
                    //               padding: EdgeInsets.all(15),
                    //               margin: EdgeInsets.all(5),
                    //               child: Image.asset(
                    //                 Images.GOOGLE_LOGO,
                    //               ),
                    //             ),
                    //           ),
                    //           GestureDetector(
                    //             onTap: () {},
                    //             child: Container(
                    //               height: 64,
                    //               width: 92,
                    //               decoration: BoxDecoration(
                    //                   color: CustomAppTheme.white,
                    //                   borderRadius: BorderRadius.circular(24)),
                    //               padding: EdgeInsets.all(12),
                    //               margin: EdgeInsets.all(5),
                    //               child: Image.asset(
                    //                 Images.FB_LOGO,
                    //               ),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
            Container(
              child: model.isLoading
                  ? Loader(
                      bgColor: CustomAppTheme.black,
                      loaderColor: CustomAppTheme.white,
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget CustomInputField({
    TextEditingController controller,
    ValueChanged<String> validator,
    bool obscureText = false,
    String label,
    TextInputType inputType = TextInputType.text,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      color: Colors.white,
      child: Container(
        child: TextFormField(
          style: Theme.of(context).textTheme.body2,
          controller: controller,
          keyboardType: inputType,
          textInputAction: TextInputAction.next,
          enabled: true,
          obscureText: obscureText,
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

  String nameValidator(value) {
    if (value.length == 0) {
      return "Please enter name !";
    }
  }

  String mobileValidator(value) {
    if (value.length == 0) {
      return "Please enter mobile number !";
    } else if (value.length < 10) {
      return "Mobile number is not valid !";
    } else if (value.length > 10) {
      return "Invalid mobile number !";
    }
  }

  String emailValidator(value) {
    if (value.length == 0) {
      return "Please enter email !";
    } else if (!Regex.email_expression.hasMatch(value)) {
      return "Enter valid email !";
    }
  }

  String passwordValidator(value) {
    if (value.length == 0) {
      return "Please enter password !";
    } else if (value.length < 8) {
      return "Password is too short !";
    }
  }

  String confirmPasswordValidator(value) {
    if (value.length == 0) {
      return "Please enter password !";
    } else if (confirmPasswordController.text != passwordController.text) {
      return "Password and Confirm password are not same!";
    }
  }
}
