import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/data/services/user_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/images.dart';
import 'package:prabodham/global/variable/text_strings.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/provider/country_provider.dart';
import 'package:prabodham/screen/container_page.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'signin_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  UserApi userApi = UserApi();

  @override
  void initState() {
    super.initState();
    print("Splash Screen");
    Future.delayed(Duration(seconds: 1), () async {
      Functions.checkConnectivity().then((value) async {
        if (value == true && value != null) {
          bool updateRequired = await userApi.appVersion(context: context);
          if (updateRequired) {
            showUpdateDialog();
          } else {
            // await context
            //     .read<PromoCodeProvider>()
            //     .getPromocode(context: context);
            await context.read<CountryProvider>().getCountry(context: context);
            bool contains =
                await PreferenceKeys.containsKey(PreferenceKeys.isLoggedIn_key);
            var userDetails = await PreferenceKeys.getUserDetail();
            print("Contains: " + contains.toString());
            print("UserDetails: " + (userDetails != null).toString());
            if (contains && userDetails != null) {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ContainerPage()));
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => SignInScreen()));
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(
                              Images.SPLASH_BG,
                            ),
                            fit: BoxFit.cover))),
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: MediaQuery.of(context).viewPadding.top,
                    child: Image.asset(
                      Images.LOGO,
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  showUpdateDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'New version of App is available. Please, update it now!',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.body2,
        ),
        actions: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  print("Update App");
                  if (Platform.isAndroid) {
                    await canLaunch(TextStrings.ANDROID_PLAYSTORE_URL)
                        ? await launch(TextStrings.ANDROID_PLAYSTORE_URL)
                        : throw 'Could not launch $TextStrings.ANDROID_PLAYSTORE_URL';
                  } else if (Platform.isIOS) {
                    await canLaunch(TextStrings.IOS_APPSTORE_URL)
                        ? await launch(TextStrings.IOS_APPSTORE_URL)
                        : throw 'Could not launch $TextStrings.IOS_APPSTORE_URL';
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 5),
                  width: 80,
                  height: 30,
                  color: Theme.of(context).primaryColor,
                  child: Center(
                    child: Text(
                      'Update',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
