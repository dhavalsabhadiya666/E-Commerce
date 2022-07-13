import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/global/variable/images.dart';
import 'package:prabodham/screen/container_page.dart';

class OrderSuccessScreen extends StatelessWidget {
  OrderSuccessScreen({Key key}) : super(key: key);

  String description = "Your order will be delivered soon. Thank you for choosing our app!";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
          child: Container(
            margin: EdgeInsets.symmetric(
              horizontal: 50,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    bottom: 40,
                  ),
                  child: Image.asset(Images.ORDER_SUCCESS_LOGO),
                ),
                Container(
                  child: Text(
                    "Success!",
                    style: Theme.of(context).textTheme.display2,
                  ),
                ),
                Container(
                  child: Text(
                    description,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.body2,
                  ),
                ),
              ],
            ),
          ),
          onWillPop: () {
            Navigator.pushAndRemoveUntil(context,
                MaterialPageRoute(builder: (context) => ContainerPage()), (route) => false);
          }),
      bottomSheet: GestureDetector(
        onTap: () {
          print("CONTINUE SHOPPING NOW");
          Navigator.pushAndRemoveUntil(
              context, MaterialPageRoute(builder: (context) => ContainerPage()), (route) => false);
        },
        child: Container(
          height: 50,
          margin: EdgeInsets.only(
            top: 40,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(25)),
          width: MediaQuery.of(context).size.width,
          child: Center(
              child: Text(
            "CONTINUE SHOPPING",
            style: Theme.of(context).textTheme.button,
          )),
        ),
      ),
    );
  }
}
