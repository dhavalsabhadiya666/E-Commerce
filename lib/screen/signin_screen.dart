import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/global/variable/images.dart';
import 'package:prabodham/helper/regular_expression.dart';
import 'package:prabodham/provider/signin_provider.dart';
import 'package:prabodham/screen/forgot_password_screen.dart';
import 'package:prabodham/screen/signup_screen.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:provider/provider.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _signinForm = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SignInProvider>();

    Future<void> signIn({@required BuildContext context}) async {
      Functions.checkConnectivity().then((value) async {
        String deviceToken = await firebaseMessaging.getToken();
        if (value != null && value == true) {
          FormData data = new FormData.fromMap({
            'customer_email': emailController.text,
            'customer_password': passwordController.text,
            'customer_device_token': deviceToken
          });

          await context
              .read<SignInProvider>()
              .singIn(context: context, data: data);
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
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).viewPadding.top + 30,
                    ),

                    loginHeader(),
                    SizedBox(height: 30),
                    loginForm(),
                    SizedBox(height: 40),
                    Container(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              print("Logging In");
                              if (_signinForm.currentState.validate()) {
                                signIn(context: context);
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
                                "LOGIN",
                                style: Theme.of(context).textTheme.button,
                              )),
                            ),
                          ),
                          SizedBox(height: 25),
                          GestureDetector(
                            onTap: () {
                              _signinForm.currentState.reset();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SignUpScreen(),
                                ),
                              );
                            },
                            child: Container(
                              child: Text("New User ? Register Here",
                                  style: Theme.of(context)
                                      .textTheme
                                      .body1
                                      .copyWith(fontWeight: FontWeight.w600)),
                            ),
                          )
                        ],
                      ),
                    ),
                    // Expanded(
                    //   child: Align(
                    //     alignment: Alignment.bottomCenter,
                    //     child: Column(
                    //       mainAxisSize: MainAxisSize.max,
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Container(
                    //           child: Text("Or login with social account",
                    //               style: Theme.of(context).textTheme.body2),
                    //         ),
                    //         Container(
                    //           margin: EdgeInsets.only(top: 10),
                    //           child: Row(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               GestureDetector(
                    //                 onTap: () {},
                    //                 child: Container(
                    //                   height: 64,
                    //                   width: 92,
                    //                   decoration: BoxDecoration(
                    //                       color: CustomAppTheme.white,
                    //                       borderRadius:
                    //                           BorderRadius.circular(24)),
                    //                   padding: EdgeInsets.all(15),
                    //                   margin: EdgeInsets.all(5),
                    //                   child: Image.asset(
                    //                     Images.GOOGLE_LOGO,
                    //                   ),
                    //                 ),
                    //               ),
                    //               GestureDetector(
                    //                 onTap: () {},
                    //                 child: Container(
                    //                   height: 64,
                    //                   width: 92,
                    //                   decoration: BoxDecoration(
                    //                       color: CustomAppTheme.white,
                    //                       borderRadius:
                    //                           BorderRadius.circular(24)),
                    //                   padding: EdgeInsets.all(12),
                    //                   margin: EdgeInsets.all(5),
                    //                   child: Image.asset(
                    //                     Images.FB_LOGO,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
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

  Widget loginHeader() {
    return Column(
      children: [
        Container(
            height: MediaQuery.of(context).size.height / 4.5,
            child: Image.asset(Images.LOGO)),
      ],
    );
  }

  Widget loginForm() {
    return Container(
      child: Form(
        key: _signinForm,
        child: Column(
          children: [
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
                obscureText: true,
                label: "Password",
              ),
            ),
            GestureDetector(
              onTap: () {
                _signinForm.currentState.reset();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ForgotPasswordScreen(),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.only(
                  top: 10,
                ),
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Forgot Your Password ?",
                        style: Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print("SignIn Screen");
  }

  String emailValidator(value) {
    if (value.length == 0) {
      return "Email Empty";
    } else if (!Regex.email_expression.hasMatch(value)) {
      return "Please entre valid email !";
    }
  }

  String passwordValidator(value) {
    if (value.length == 0) {
      return "Please entre password !";
    }
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
}
