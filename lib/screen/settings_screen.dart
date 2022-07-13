import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/model/customer.dart';
import 'package:prabodham/provider/reset_password_provider.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settingForm = GlobalKey<FormState>();
  Customer userDetail;
  TextEditingController nameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _salesNotificationSelected = false;
  bool _newArrivalNotificationSelected = false;
  bool _deliveryStatusChangeNotificationSelected = false;
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    Functions.checkConnectivity().then((value) async {
      String userjson = await PreferenceKeys.getUserDetail();
      userDetail = Customer.fromJson(jsonDecode(userjson));
      nameController.text = userDetail.customerName;
      dobController.text = userDetail.customerDateOfBirth.toString();
      passwordController.text = "";
    });
  }

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<ResetPasswordProvider>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).canvasColor,
        appBar: CustomAppBar(
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                }),
            actions: [IconButton(icon: Icon(Icons.search), onPressed: () {})]),
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.only(bottom: 20),
                      alignment: Alignment.centerLeft,
                      child: Text("Settings",
                          style: Theme.of(context).textTheme.subtitle),
                    ),
                    Container(
                      padding: EdgeInsets.only(bottom: 20),
                      alignment: Alignment.centerLeft,
                      child: Text("Personal Information",
                          style: Theme.of(context).textTheme.body1),
                    ),
                    settingsForm(),
                    // Container(
                    //   padding: EdgeInsets.only(top: 50, bottom: 20),
                    //   alignment: Alignment.centerLeft,
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child:
                    //             Text("Change Password", style: Theme.of(context).textTheme.body2),
                    //       ),
                    //       GestureDetector(
                    //         onTap: () {
                    //           print("Request password change");
                    //           changePasswordPopUp();
                    //         },
                    //         child: Container(
                    //           child: Text(
                    //             "Change",
                    //             style: Theme.of(context)
                    //                 .textTheme
                    //                 .body2
                    //                 .copyWith(fontWeight: FontWeight.w400, color: Colors.grey),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Container(
                    //   child: CustomInputField(
                    //       controller: passwordController,
                    //       validator: passwordValidator,
                    //       label: "Password",
                    //       obscureText: true,
                    //       readOnly: true),
                    // ),
                    // Container(
                    //   padding: EdgeInsets.only(top: 50, bottom: 10),
                    //   alignment: Alignment.centerLeft,
                    //   child: Text("Notifications", style: Theme.of(context).textTheme.body2),
                    // ),
                    // Container(
                    //   child: Column(
                    //     children: [
                    //       Container(
                    //         child: CustomSwitch(
                    //             label: "Sales",
                    //             isSelected: salesNotifySelected,
                    //             value: _salesNotificationSelected),
                    //       ),
                    //       Container(
                    //         child: CustomSwitch(
                    //             label: "New arrivals",
                    //             isSelected: newArrivalNotificationSelected,
                    //             value: _newArrivalNotificationSelected),
                    //       ),
                    //       Container(
                    //         child: CustomSwitch(
                    //             label: "Delivery Status Changes",
                    //             isSelected: deliveryStatusChangeNotificationSelected,
                    //             value: _deliveryStatusChangeNotificationSelected),
                    //       ),
                    //     ],
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
        bottomSheet: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () {
              print("Update Profile");
              if (_settingForm.currentState.validate()) {
                Navigator.pop(context);
              }
            },
            child: Container(
              height: 50,
              margin: EdgeInsets.only(top: 25, bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5.0,
                  )
                ],
              ),
              child: Center(
                  child: Text(
                "UPDATE",
                style: Theme.of(context).textTheme.button,
              )),
            ),
          ),
        ),
      ),
    );
  }

  Widget settingsForm() {
    return Container(
      child: Form(
        key: _settingForm,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: CustomInputField(
                controller: nameController,
                validator: nameValidator,
                label: "Full Name",
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: CustomInputField(
                controller: dobController,
                validator: dobValidator,
                label: "Date of Birth",
                onFieldTap: datePicker,
                readOnly: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget CustomInputField(
      {TextEditingController controller,
      ValueChanged<String> validator,
      String label,
      bool obscureText = false,
      bool readOnly = false,
      VoidCallback onFieldTap}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 5),
      color: Colors.white,
      child: Container(
        child: TextFormField(
          style: Theme.of(context).textTheme.body2,
          controller: controller,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: true,
          validator: validator,
          onTap: onFieldTap,
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

  Widget CustomSwitch({
    ValueChanged<bool> isSelected,
    bool value = false,
    String label,
  }) {
    return GestureDetector(
      onTap: () {
        isSelected(!value);
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.body2.copyWith(
                      fontWeight: FontWeight.w400,
                    ),
              ),
            ),
            Container(
              child: CupertinoSwitch(
                value: value ?? false,
                onChanged: isSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> datePicker() async {
    final DateTime pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      if (pickedDate.isBefore(DateTime.now())) {
        setState(() {
          String date = pickedDate.toIso8601String();
          dobController.text =
              DateFormat("dd-MM-yyyy").format(DateTime.parse(date)).toString();
        });
      } else {
        Functions.toast("Future Date Not Allowed");
      }
    }
  }

  Future<dynamic> changePasswordPopUp() {
    Future<void> resetPassword({@required BuildContext context}) async {
      Functions.checkConnectivity().then((value) async {
        if (value != null && value == true) {
          FormData data = new FormData.fromMap({
            'customer_id': userDetail.customerId,
            'current_password': oldPasswordController.text,
            'new_password': newPasswordController.text,
          });
          await context
              .read<ResetPasswordProvider>()
              .resetPassword(data: data, context: context);
        }
      });
    }

    return showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 40),
                      child: Text(
                        "Password Change",
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Column(
                        children: [
                          Container(
                            child: CustomInputField(
                              controller: oldPasswordController,
                              validator: oldPasswordValidator,
                              label: "Old Password",
                              obscureText: true,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    print("Forgot Password");
                                  },
                                  child: Container(
                                    child: Text(
                                      "Forgot Password?",
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .copyWith(
                                            fontWeight: FontWeight.w400,
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: CustomInputField(
                              controller: newPasswordController,
                              validator: newPasswordValidator,
                              label: "New Password",
                              obscureText: true,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            child: CustomInputField(
                              controller: confirmPasswordController,
                              validator: confirmPasswordValidator,
                              label: "Repeat New Password",
                              obscureText: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                          top: 30, bottom: 30, left: 0, right: 0),
                      margin: EdgeInsets.only(top: 30),
                      child: GestureDetector(
                        onTap: () {
                          print("Save Password");
                          //Change Password Call
                          Navigator.pop(context);
                          resetPassword(context: context);
                        },
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(25)),
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                              child: Text(
                            "SAVE PASSWORD",
                            style: Theme.of(context).textTheme.button,
                          )),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String nameValidator(value) {
    if (value.length == 0) {
      return "Name Empty";
    }
  }

  String dobValidator(value) {
    print("DateOfB : " + value);
    if (value.length == 0 && false) {
      return "Date of Birth Empty";
    }
  }

  String passwordValidator(value) {
    if (value.length == 0) {
      return "Email Empty";
    }
  }

  String oldPasswordValidator(value) {
    if (value.length == 0) {
      return "Email Empty";
    }
  }

  String newPasswordValidator(value) {
    if (value.length == 0) {
      return "Email Empty";
    }
  }

  String confirmPasswordValidator(value) {
    if (value.length == 0) {
      return "Email Empty";
    }
  }

  void salesNotifySelected(bool isSelected) {
    setState(() {
      _salesNotificationSelected = isSelected;
    });
  }

  void newArrivalNotificationSelected(bool isSelected) {
    setState(() {
      _newArrivalNotificationSelected = isSelected;
    });
  }

  void deliveryStatusChangeNotificationSelected(bool isSelected) {
    setState(() {
      _deliveryStatusChangeNotificationSelected = isSelected;
    });
  }
}
