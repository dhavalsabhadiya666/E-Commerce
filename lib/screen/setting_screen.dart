import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/endpoints.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/user_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/model/customer.dart';
import 'package:prabodham/provider/reset_password_provider.dart';
import 'package:prabodham/screen/coming_soon.dart';
import 'package:prabodham/screen/order_screen.dart';
import 'package:prabodham/screen/settings_screen.dart';
import 'package:prabodham/screen/shipping_addresses_screen.dart';
import 'package:prabodham/screen/wallet_screen.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:prabodham/widgets/component_widgets/smal_loader.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:prabodham/widgets/custom_image.dart';
import 'package:prabodham/widgets/dialog_widget/exit_app_dialog.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  UserApi _userApi = UserApi();
  Customer userDetail;
  final _passwordForm = GlobalKey<FormState>();

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  int totalOrders = 0;
  int totalAddress = 0;
  int totalReview = 0;
  double wallet = 0.0;
  List<ProfileMenuItem> profileMenuItem;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    print("Profile Screen");
    getUserDetail(context: context);
  }

  getProfileData() {
    Functions.checkConnectivity().then((value) async {
      String userjson = await PreferenceKeys.getUserDetail();
      setState(() {
        userDetail = Customer.fromJson(jsonDecode(userjson));
      });
    });
  }

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  Future<void> getUserDetail({@required BuildContext context}) async {
    Functions.checkConnectivity().then((value) async {
      setLoading(true);
      // getUserDetail(context: context);
      if (value != null && value == true) {
        String userjson = await PreferenceKeys.getUserDetail();
        userDetail = Customer.fromJson(jsonDecode(userjson));
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
        });
        try {
          ApiResponseModel apiResponse =
              await _userApi.getUserDetails(context: context, data: data);
          print("User Details Api response data :- ");

          if (apiResponse.success == true && apiResponse.response != null) {
            setState(() {
              wallet = apiResponse.response['wallet'] != Null
                  ? double.tryParse(apiResponse.response['wallet'].toString())
                  : 0.00;
              totalAddress = apiResponse.response['address_count'] ?? 0;
              totalOrders = apiResponse.response['order_count'] ?? 0;
              totalReview = apiResponse.response['review_count'] ?? 0;
            });
            setLoading(false);
          } else {
            setLoading(false);
            Functions.toast(apiResponse.message);
          }
        } catch (e) {
          if (mounted) {
            setLoading(false);
          }
          print(e.toString());
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    profileMenuItem = [
      ProfileMenuItem(
          menuTitle: "My Orders",
          menuSubTitle: "${totalOrders}  Orders",
          icon: Icons.shopping_bag),
      ProfileMenuItem(
          menuTitle: "Shipping Address",
          menuSubTitle: "${totalAddress} Addresses",
          icon: Icons.house),
      // ProfileMenuItem(menuTitle: "Promocodes", menuSubTitle: "You have special promocodes"),
      // ProfileMenuItem(menuTitle: "My Reviews", menuSubTitle: "Reviews for ${totalReview} items"),
      ProfileMenuItem(
          menuTitle: "Change Password",
          menuSubTitle: "Change password",
          icon: Icons.edit),
      // ProfileMenuItem(
      //     menuTitle: "Settings", menuSubTitle: "Notifications, Passwords"),
      ProfileMenuItem(
          menuTitle: "Wallet",
          menuSubTitle: "\u{20B9} ${wallet.toStringAsFixed(2)}",
          icon: Icons.account_balance_wallet),
      ProfileMenuItem(
          menuTitle: "Privacy Policy",
          menuSubTitle: "Must read privacy policies.",
          icon: Icons.privacy_tip),
      ProfileMenuItem(
          menuTitle: "Terms & Conditions",
          menuSubTitle: "Must read all terms and conditions.",
          icon: Icons.insert_drive_file),
      ProfileMenuItem(
          menuTitle: "Sign Out",
          menuSubTitle: "You will be directly logged out of app.",
          icon: Icons.power_settings_new_sharp),
    ];

    return userDetail != null
        ? GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).canvasColor,
              appBar: CustomAppBar(
                title: Text("Settings"),
                centerTitle: true,
                elevation: 2,
                leading: Container(),
              ),
              body: Stack(
                children: [
                  isLoading
                      ? smallLoader(context: context)
                      : SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                profileMenuList(),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
          )
        : Container();
  }

  Widget profileHeader() {
    return Row(
      children: [
        Text(
          "My Profile",
          style: Theme.of(context).textTheme.subtitle,
        ),
      ],
    );
  }

  Widget profileCard() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(35),
            child: CustomImage(
              height: 70,
              width: 70,
              imgURL: userDetail.customerProfileImage ?? "",
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    userDetail.customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.body1,
                  ),
                ),
                Container(
                  child: Text(
                    userDetail.customerEmail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption.copyWith(
                          fontSize: 12,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      enableDrag: true,
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        bool isLoading =
            Provider.of<ResetPasswordProvider>(context, listen: true)
                .getIsLoading;
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: Container(
            height: MediaQuery.of(context).size.height / 1.2,
            width: double.infinity,
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 30),
                    child: Form(
                      key: _passwordForm,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 40),
                            child: Text(
                              "Change Password",
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
                                top: 10, bottom: 0, left: 0, right: 0),
                            margin: EdgeInsets.only(top: 30),
                            child: GestureDetector(
                              onTap: () async {
                                FocusScope.of(context).unfocus();
                                if (_passwordForm.currentState.validate()) {
                                  print("Sending ....");
                                  print("Save Password");
                                  //Change Password Call
                                  //Navigator.pop(context);

                                  await resetPassword(context: context);

                                  print("Done");
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
                                  "CHANGE PASSWORD",
                                  style: Theme.of(context).textTheme.button,
                                )),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  child: isLoading
                      ? Loader(
                          bgColor: Colors.black87,
                          loaderColor: Colors.white,
                        )
                      : Container(),
                ),
              ],
            ),
          ),
        );
      },
    ).whenComplete(() {
      confirmPasswordController.clear();
      oldPasswordController.clear();
      newPasswordController.clear();
    });
  }

  Widget CustomInputField({
    TextEditingController controller,
    ValueChanged<String> validator,
    String label,
    bool obscureText = false,
    bool readOnly = false,
  }) {
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

  Widget profileMenuList() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: profileMenuItem.length,
        physics: NeverScrollableScrollPhysics(),
        // separatorBuilder: (context, index) {
        //   return Divider(
        //     height: 0,
        //   );
        // },
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              print(profileMenuItem[index].menuTitle);
              navigateTo(menuName: profileMenuItem[index].menuTitle);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 3),
              child: ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      Theme.of(context).primaryColor.withAlpha(1075),
                  child: Icon(
                    profileMenuItem[index].icon,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                title: Text(profileMenuItem[index].menuTitle),
                subtitle: Text(
                  profileMenuItem[index].menuSubTitle ?? "",
                  style: TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                    onPressed: () {
                      print(profileMenuItem[index].menuTitle);
                      navigateTo(menuName: profileMenuItem[index].menuTitle);
                    },
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                    )),
              ),
            ),
          );
          // return GestureDetector(
          //   onTap: () {
          //     print(profileMenuItem[index].menuTitle);
          //     navigateTo(menuName: profileMenuItem[index].menuTitle);
          //   },
          //   child: Container(
          //     color: Colors.transparent,
          //     margin: EdgeInsets.symmetric(vertical: 1),
          //     padding: EdgeInsets.symmetric(vertical: 5),
          //     child: Row(
          //       crossAxisAlignment: CrossAxisAlignment.center,
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Expanded(
          //           child: Container(
          //             margin: EdgeInsets.symmetric(vertical: 10),
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               mainAxisAlignment: MainAxisAlignment.center,
          //               children: [
          //                 Container(
          //                   child: Text(
          //                     profileMenuItem[index].menuTitle,
          //                     maxLines: 1,
          //                     overflow: TextOverflow.ellipsis,
          //                     style: Theme.of(context).textTheme.body1,
          //                   ),
          //                 ),
          //                 SizedBox(
          //                   height: 8,
          //                 ),
          //                 Container(
          //                   child: Text(
          //                     profileMenuItem[index].menuSubTitle ?? "",
          //                     maxLines: 1,
          //                     overflow: TextOverflow.ellipsis,
          //                     style:
          //                         Theme.of(context).textTheme.caption.copyWith(
          //                               fontSize: 12,
          //                             ),
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //         ),
          //         Row(
          //           mainAxisSize: MainAxisSize.min,
          //           mainAxisAlignment: MainAxisAlignment.end,
          //           crossAxisAlignment: CrossAxisAlignment.center,
          //           children: [
          //             Container(
          //               child: Icon(
          //                 Icons.arrow_forward_ios,
          //                 size: 16,
          //                 color: Colors.grey,
          //               ),
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // );
        },
      ),
    );
  }

  void navigateTo({String menuName}) {
    switch (menuName) {
      case "My Orders":
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderScreen(),
            ),
          );
        }
        break;
      case "Shipping Address":
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShippingAddressScreen(),
            ),
          ).then((value) => getUserDetail(context: context));
        }
        break;
      case "Promocodes":
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComingSoon(),
            ),
          );
        }
        break;
      case "My Reviews":
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ComingSoon(),
            ),
          );
        }
        break;
      case "Settings":
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsScreen(),
            ),
          );
        }
        break;
      case "Wallet":
        {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WalletScreen(),
            ),
          );
        }
        break;
      case "Change Password":
        {
          changePasswordPopUp();
        }
        break;
      case "Sign Out":
        {
          exitAppDialog(context);
          break;
        }
        break;
      case "Privacy Policy":
        {
          _launchURL(Endpoints.privacyPolicy);
        }
        break;
      case "Terms & Conditions":
        {
          _launchURL(Endpoints.termsAndCondition);
        }
        break;
    }
  }

  void _launchURL(String _url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  String oldPasswordValidator(value) {
    if (value.length == 0) {
      return "Password Empty";
    }
  }

  String newPasswordValidator(value) {
    if (value.length == 0) {
      return "New Password Empty";
    } else if (value.length < 8) {
      return "New Password Too Short";
    }
  }

  String confirmPasswordValidator(value) {
    if (value.length == 0) {
      return "Confirm Password Empty";
    } else if (newPasswordController.text != value) {
      return "Password Mismatched";
    }
  }
}

class ProfileMenuItem {
  String menuTitle;
  String menuSubTitle;
  IconData icon;

  ProfileMenuItem({@required this.menuTitle, this.menuSubTitle, this.icon});
}
