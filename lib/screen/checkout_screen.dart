import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prabodham/global/variable/images.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/model/address.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key key}) : super(key: key);

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  Address defaultAddress;

  List<Delivery> deliveryOption = [
    Delivery(url: Images.FB_LOGO, estimatedDays: "2-3 days"),
    Delivery(url: Images.FB_LOGO, estimatedDays: "2-3 days"),
    Delivery(url: Images.FB_LOGO, estimatedDays: "2-3 days"),
  ];

  @override
  Future<void> initState() async {
    super.initState();
    String addressjson = await PreferenceKeys.getDefaultAddress();
    defaultAddress = Address.fromJson(jsonDecode(addressjson));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: Text("Checkout"),
          centerTitle: true,
          elevation: 5,
        ),
        backgroundColor: Theme.of(context).canvasColor,
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(bottom: 30),
            margin: EdgeInsets.symmetric(vertical: 30, horizontal: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Text(
                    "Shipping Address",
                    style: Theme.of(context).textTheme.body2.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ),
                Container(
                  child: addressCard(address: defaultAddress),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: Text(
                    "Delivery Method",
                    style: Theme.of(context).textTheme.body2.copyWith(
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                ),
                Container(
                  height: 110,
                  child: deliveryList(),
                ),
                GestureDetector(
                  onTap: () {
                    print("Submitting Order");
                  },
                  child: Container(
                    height: 50,
                    margin: EdgeInsets.only(top: 40),
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(25)),
                    width: MediaQuery.of(context).size.width,
                    child: Center(
                        child: Text(
                      "SUBMIT ORDER",
                      style: Theme.of(context).textTheme.button,
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget addressCard({Address address}) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.only(top: 20),
      child: Container(
        margin: EdgeInsets.only(left: 25, right: 20, top: 20, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                        address.customerAddressName,
                        style: Theme.of(context)
                            .textTheme
                            .body2
                            .copyWith(fontWeight: FontWeight.w400),
                      ),
                    ),
                    Container(
                      child: Text(
                        address.customerAddressDetails,
                        style: Theme.of(context).textTheme.body2.copyWith(
                            fontWeight: FontWeight.w400, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                alignment: Alignment.centerRight,
                child: Text(
                  "Change",
                  style: Theme.of(context).textTheme.body2.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget deliveryList() {
    return GridView.count(
      crossAxisCount: 3,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        vertical: 15,
      ),
      crossAxisSpacing: 20,
      childAspectRatio: (100 / 70),
      children: deliveryOption.map((delivery) {
        return Card(
          child: Container(
            height: 70,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 15),
                  child: Image.asset(
                    delivery.url,
                    height: 20,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 5),
                  child: Text(
                    delivery.estimatedDays,
                    style: Theme.of(context)
                        .textTheme
                        .caption
                        .copyWith(fontWeight: FontWeight.w400),
                  ),
                ),
              ],
            ),
          ),
          elevation: 5,
        );
      }).toList(),
    );
  }
}

class demo_Address {
  String name;
  String address;

  demo_Address({this.name, this.address});
}

class Delivery {
  String url;
  String estimatedDays;

  Delivery({this.url, this.estimatedDays});
}
