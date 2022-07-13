import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ComingSoon extends StatefulWidget {
  const ComingSoon({Key key}) : super(key: key);

  @override
  _ComingSoonState createState() => _ComingSoonState();
}

class _ComingSoonState extends State<ComingSoon> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Container(
          color: Colors.white,
          child: Center(
            child: Text(
              "Coming Soon",
              style: Theme.of(context).textTheme.display4,
            ),
          ),
        ),
        onWillPop: () {
          Navigator.pop(context);
        });
  }
}
