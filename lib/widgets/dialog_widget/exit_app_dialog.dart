import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/screen/signin_screen.dart';

exitAppDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Do you want to exit application?',
        style: Theme.of(context).textTheme.body2,
      ),
      actions: <Widget>[
        GestureDetector(
          onTap: () {
            print("you choose no");
            Navigator.of(context).pop(false);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 5),
            width: 60,
            height: 30,
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Text(
                'No',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        GestureDetector(
          onTap: () async {
            PreferenceKeys.removeCacheDetail();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignInScreen()),
            );
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 5, right: 10),
            width: 60,
            height: 30,
            color: Theme.of(context).primaryColor,
            child: Center(
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
