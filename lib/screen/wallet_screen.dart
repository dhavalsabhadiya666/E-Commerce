import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/dashboard_api.dart';
import 'package:prabodham/data/services/wallet_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/model/customer.dart';
import 'package:prabodham/model/referrral_transaction.dart';
import 'package:prabodham/model/wallet_transaction.dart';
import 'package:prabodham/widgets/component_widgets/smal_loader.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key key}) : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  DashboardApi _dashboardApi = DashboardApi();
  WalletApi _walletApi = WalletApi();

  List<WalletTransaction> walletTransactions = [];
  List<ReferralTransaction> referralTransactions = [];
  int selectedListIndex = 0;
  bool isLoading = false;
  Customer userDetail;
  double totalWalletAmount = 0.0;

  @override
  void initState() {
    super.initState();
    getWalletAmount(context: context);
    getReferralTransaction(context: context);
    getWalletTransaction(context: context);
  }

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  Future<void> getWalletAmount({@required BuildContext context}) async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        String userjson = await PreferenceKeys.getUserDetail();
        userDetail = Customer.fromJson(jsonDecode(userjson));
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
        });

        setLoading(true);
        try {
          print(data);
          ApiResponseModel apiResponse =
              await _dashboardApi.getWallet(context: context, data: data);
          print("Get Wallet Amount Api response data :- ");
          print(apiResponse.response);

          if (apiResponse.success == true) {
            setLoading(false);
            setState(() {
              totalWalletAmount = double.parse(
                  apiResponse.response["wallet_amount"].toString());
            });
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
    });
  }

  Future<void> getWalletTransaction({@required BuildContext context}) async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
        });

        setLoading(true);
        try {
          print(data);
          List<WalletTransaction> response = await _walletApi
              .getWalletTransaction(context: context, data: data);

          print("Get Wallet Amount Api response data :- ");

          List<WalletTransaction> temp = [];
          for (int i = 0; i < response.length; i++) {
            if (response[i].walletPay.toInt() != 0) {
              temp.add(response[i]);
            }
          }
          walletTransactions = temp;
          setLoading(false);
        } catch (e) {
          print(e.toString());
          setLoading(false);
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
        }
      }
    });
  }

  Future<void> getReferralTransaction({@required BuildContext context}) async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        FormData data = new FormData.fromMap({
          'customer_id': userDetail.customerId,
        });
        setLoading(true);
        try {
          print(data);
          List<ReferralTransaction> response = await _walletApi
              .getReferralTransaction(context: context, data: data);
          print("Get Wallet Amount Api response data :- ");

          List<ReferralTransaction> temp = [];
          for (int i = 0; i < response.length; i++) {
            if (response[i].referralTransactionAmount.toInt() != 0) {
              temp.add(response[i]);
            }
          }
          referralTransactions = temp;
          setLoading(false);
        } catch (e) {
          print(e.toString());
          setLoading(false);
          final errorMessage = DioExceptions.fromDioError(e).toString();
          showCustomDialog(context, 'Error', errorMessage);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> tabs = [walletTransaction(), referralTransaction()];
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        child: Scaffold(
          backgroundColor: Theme.of(context).canvasColor,
          appBar: CustomAppBar(
            elevation: 2,
            leading: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                }),
            title: Text("My Wallet"),
            centerTitle: true,
          ),
          body: isLoading
              ? smallLoader(context: context)
              : Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 40),
                        width: MediaQuery.of(context).size.width,
                        height: 100,
                        child: walletCard(),
                      ),
                      Container(
                        height: 35,
                        child: DefaultTabController(
                          length: 2,
                          initialIndex: selectedListIndex,
                          child: TabBar(
                            onTap: (index) {
                              print("Index : " + index.toString());
                              setState(() {
                                selectedListIndex = index;
                              });
                            },
                            tabs: [
                              Tab(
                                child: FittedBox(
                                    child: Text("Wallet Transaction")),
                              ),
                              Tab(
                                child: Text("Referral"),
                              ),
                            ],
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black,
                            unselectedLabelStyle: Theme.of(context)
                                .textTheme
                                .body1
                                .copyWith(fontWeight: FontWeight.bold),
                            labelStyle: Theme.of(context)
                                .textTheme
                                .body1
                                .copyWith(fontWeight: FontWeight.bold),
                            indicator: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(16),
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      tabs[selectedListIndex]
                    ],
                  ),
                ),
        ),
        onWillPop: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget walletTransaction() {
    //print(walletTransactions[2].toString());

    return walletTransactions.length == 0
        ? Container(
            height: MediaQuery.of(context).size.height / 2.8,
            child: Center(
              child: Text("No Transactions !"),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            itemCount: walletTransactions.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  walletReceiptCard(transaction: walletTransactions[index]),
                  Divider()
                ],
              );
            });
  }

  Widget walletReceiptCard({WalletTransaction transaction}) {
    Color amountColor = Colors.black;
    if (transaction.walletPay > 0 && transaction.orderStatusId != 5) {
      amountColor = Colors.red;
    }
    if ((transaction.orderStatusId == 5) &&
        (transaction.walletPay > 0 || transaction.razorpayPaymentId != null)) {
      amountColor = Colors.green;
    }

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  right: 6,
                  left: 12,
                  top: 5,
                  bottom: 5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              child: Text(
                                "Order ID : " + transaction.orderId.toString(),
                                style:
                                    Theme.of(context).textTheme.body1.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                              ),
                            ),
                          ),
                          Container(
                            child: Text(
                              '\u{20B9} ${transaction.walletPay.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: amountColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      child: Text(
                        DateFormat("dd , MMMM yyyy")
                            .format(DateTime.parse(transaction.orderCreatedAt))
                            .toString(),
                        style: Theme.of(context).textTheme.body2.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget referralTransaction() {
    return referralTransactions.length == 0
        ? Container(
            height: MediaQuery.of(context).size.height / 2.8,
            child: Center(
              child: Text("No Transactions !"),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            itemCount: referralTransactions.length,
            itemBuilder: (context, index) {
              return referralReceiptCard(
                  transaction: referralTransactions[index]);
            });
  }

  Widget referralReceiptCard({ReferralTransaction transaction}) {
    Color amountColor = Colors.black;

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: EdgeInsets.all(0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                  right: 6,
                  left: 12,
                  top: 5,
                  bottom: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Referral code used by : ",
                              style: Theme.of(context).textTheme.body1.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Container(
                            child: Text(
                              '\u{20B9} ${transaction.referralTransactionAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: amountColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "${transaction.referredCustomer.customerName}",
                      style: Theme.of(context).textTheme.body1.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      child: Text(
                        DateFormat("dd , MMMM yyyy")
                            .format(DateTime.parse(
                                transaction.referralTransactionCreatedAt))
                            .toString(),
                        style: Theme.of(context).textTheme.body2.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget walletCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      margin: EdgeInsets.only(top: 0),
      child: Container(
        margin: EdgeInsets.only(left: 25, right: 20, top: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              child: Text("Wallet Balance"),
            ),
            Container(
              child: Text(
                "\u{20B9} ${totalWalletAmount.toStringAsFixed(2)}",
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
