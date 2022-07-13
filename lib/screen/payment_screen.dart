import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prabodham/data/api_response_model.dart';
import 'package:prabodham/data/exceptions.dart';
import 'package:prabodham/data/services/dashboard_api.dart';
import 'package:prabodham/data/services/order_api.dart';
import 'package:prabodham/global/functions/global_functions.dart';
import 'package:prabodham/global/variable/custom_app_theme.dart';
import 'package:prabodham/global/variable/images.dart';
import 'package:prabodham/global/variable/text_strings.dart';
import 'package:prabodham/helper/preference_keys.dart';
import 'package:prabodham/model/customer.dart';
import 'package:prabodham/screen/order_success_screen.dart';
import 'package:prabodham/widgets/component_widgets/loader.dart';
import 'package:prabodham/widgets/custom_app_bar.dart';
import 'package:prabodham/widgets/dialog_widget/show_custom_dialog.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  double cartTotalAmount;
  double cartDiscountAmount;
  double cartNetAmount;
  int cartId;
  int customerAddressId;

  PaymentScreen({
    Key key,
    @required this.cartTotalAmount,
    @required this.cartDiscountAmount,
    @required this.cartNetAmount,
    @required this.cartId,
    @required this.customerAddressId,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Razorpay _razorpay = Razorpay();
  OrderApi _orderApi = OrderApi();
  DashboardApi _dashboardApi = DashboardApi();
  bool isLoading = false;
  bool useWallet = false;
  bool useWalletOnly = false;
  double netAmountPayable;
  List<PaymentMethod> paymentMode = [
    // PaymentMethod(
    //   "Cash On Delivery",
    //   false,
    // ),
    PaymentMethod(
      "RazorPay",
      false,
    ),
  ];
  double totalWalletBalance;
  double netWalletBalance;
  double WalletPay;
  Customer userDetail;
  PaymentMethod _paymentMethod;

  @override
  void initState() {
    super.initState();
    // getWalletBalance();
    getWalletAmount(context: context);
    netAmountPayable = widget.cartNetAmount;
    // _paymentMethod = paymentMode[1];
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _paymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _paymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _paymentExternalWallet);
    WalletPay = 0.0;
  }

  void setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void getWalletBalance() {
    //TO BE MADE AFTER WALLET CREATED
    totalWalletBalance = 1000.0;
  }

  void _paymentSuccess(PaymentSuccessResponse response) {
    print("Payment Successful");
    postOrder(context: context, successResponse: response);
  }

  void _paymentError(PaymentFailureResponse response) {
    print("Payment Failed");
  }

  void _paymentExternalWallet(ExternalWalletResponse response) {
    print("Payment Extenal Wallet");
  }

  void startPayment(double amount) {
    print("Initiating Payment Now....");
    double paymentAmount = 0;
    paymentAmount = amount * 100;
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        String userjson = await PreferenceKeys.getUserDetail();
        userDetail = Customer.fromJson(jsonDecode(userjson));
        ByteData bytes = await rootBundle.load(Images.LOGO);
        if (_paymentMethod != null) {
          if (_paymentMethod.paymentType == "RazorPay") {
            print("Initiating RazorPay Now....");
            var options = {
              'key': TextStrings.RAZORPAY_KEY,
              'amount':
                  paymentAmount.round(), //in the smallest currency sub-unit.
              'name': 'Prabodham',
              // 'image': base64Encode(bytes.buffer.asInt64List()),
              // 'order_id': 'order_EMBFqjDHEEn80l', // Generate order_id using Orders API
              // 'description': 'Fine T-Shirt',
              'timeout': 120, // in seconds
              'prefill': {
                'contact': userDetail.customerMobileNumber,
                'email': userDetail.customerEmail,
              }
            };
            print("Redirecting to RazorPay Now....");
            await _razorpay.open(options);
            print("RazorPay Payment Done....");
          } else if (_paymentMethod.paymentType == "Cash On Delivery") {
            print("Cash On Delivery Now....");
            postOrder(context: context);
          }
        } else {
          print("Wallet Payment Now....");
          postOrder(context: context);
        }
      }
    });
  }

  Future<void> postOrder(
      {@required BuildContext context,
      PaymentSuccessResponse successResponse}) async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        String pay_method;
        if (useWalletOnly) {
          pay_method = "Wallet";
        } else {
          if (useWallet) {
            pay_method = "Wallet," + _paymentMethod.paymentType;
          } else if (_paymentMethod != null) {
            pay_method = _paymentMethod.paymentType;
          } else {
            pay_method = "N/A";
          }
        }
        String userjson = await PreferenceKeys.getUserDetail();
        userDetail = Customer.fromJson(jsonDecode(userjson));
        FormData data = new FormData.fromMap({
          'cart_id': widget.cartId,
          'order_payment_method': pay_method,
          'customer_address_id': widget.customerAddressId,
          'order_discount': widget.cartDiscountAmount,
          'razorpay_order_id':
              successResponse != null ? successResponse.orderId : null,
          'razorpay_payment_id':
              successResponse != null ? successResponse.paymentId : null,
          'razorpay_signature':
              successResponse != null ? successResponse.signature : null,
          'wallet_pay': WalletPay,
          'order_final_price': widget.cartTotalAmount,
        });

        setLoading(true);
        try {
          print(data);
          ApiResponseModel apiResponse =
              await _orderApi.postOrder(context: context, data: data);
          print("Post Order Api response data :- ");
          print(apiResponse.response);

          if (apiResponse.success == true) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => OrderSuccessScreen()),
            );
            setLoading(false);
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

  Future<void> checkAvailability({@required BuildContext context}) async {
    Functions.checkConnectivity().then((value) async {
      if (value != null && value == true) {
        String userjson = await PreferenceKeys.getUserDetail();
        userDetail = Customer.fromJson(jsonDecode(userjson));
        FormData data = new FormData.fromMap({
          'cart_id': widget.cartId,
        });

        setLoading(true);
        try {
          print(data);
          ApiResponseModel apiResponse =
              await _orderApi.getAvailability(context: context, data: data);
          print("Check Availability Api response data :- ");
          print(apiResponse.response);

          if (apiResponse.success == true) {
            setLoading(false);
            startPayment(netAmountPayable);
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
              totalWalletBalance = double.parse(
                  apiResponse.response["wallet_amount"].toString());
              netWalletBalance = totalWalletBalance;
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: CustomAppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.arrow_back_ios)),
          title: Text("Payment"),
          centerTitle: true,
          elevation: 2,
        ),
        backgroundColor: Theme.of(context).canvasColor,
        body: Stack(
          children: [
            isLoading
                ? Container()
                : SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Payment Info',
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 15),
                            child: Row(
                              children: [
                                Container(
                                  child: Text("Order Amount",
                                      style: Theme.of(context).textTheme.body2),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '\u{20B9} ${widget.cartTotalAmount.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Container(
                                  child: Text("Discount",
                                      style: Theme.of(context).textTheme.body2),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '\u{20B9} ${widget.cartDiscountAmount.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          useWallet
                              ? Container(
                                  margin: EdgeInsets.only(top: 10),
                                  child: Row(
                                    children: [
                                      Container(
                                        child: Text("Wallet Pay:",
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2),
                                      ),
                                      Expanded(
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            '\u{20B9}${WalletPay.toStringAsFixed(2)}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                Container(
                                  child: Text("Net Amount",
                                      style: Theme.of(context).textTheme.body2),
                                ),
                                Expanded(
                                  child: Container(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '\u{20B9} ${widget.cartNetAmount.toStringAsFixed(2)}',
                                      style: Theme.of(context).textTheme.body2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Divider(
                          //   thickness: 5,
                          //   height: 50,
                          // ),
                          SizedBox(
                            height: 20,
                          ),
                          DottedLine(
                            direction: Axis.horizontal,
                            lineLength: double.infinity,
                            lineThickness: 1.0,
                            dashLength: 12.0,
                            dashColor: Colors.grey,
                            dashRadius: 0.0,
                            dashGapLength: 4.0,
                            dashGapColor: Colors.transparent,
                            dashGapRadius: 0.0,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Select Payment',
                              style: Theme.of(context).textTheme.body1.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Card(
                            elevation: 2,
                            margin: EdgeInsets.all(0),
                            child: Container(
                              margin: EdgeInsets.only(top: 5),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: CheckboxListTile(
                                      title: Text("Use Wallet Amount",
                                          style: Theme.of(context)
                                              .textTheme
                                              .body2),
                                      contentPadding: EdgeInsets.all(0),
                                      value: useWallet,
                                      onChanged: (value) {
                                        setState(() {
                                          useWallet = value;
                                          if (!value) {
                                            useWalletOnly = value;
                                          }
                                          if (value) {
                                            if (netAmountPayable >
                                                netWalletBalance) {
                                              WalletPay = netWalletBalance;
                                            } else {
                                              WalletPay = netAmountPayable;
                                              useWalletOnly = true;
                                              clearPaymentMethod();
                                            }
                                            netWalletBalance -= WalletPay;
                                            netAmountPayable -= WalletPay;
                                          } else {
                                            netWalletBalance =
                                                totalWalletBalance;
                                            netAmountPayable =
                                                widget.cartNetAmount;
                                            WalletPay = 0.0;
                                          }
                                        });
                                        print("Using Wallet : ${useWallet}");
                                      },
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '\u{20B9} ${netWalletBalance != null ? netWalletBalance.toStringAsFixed(2) : ""}',
                                        style:
                                            Theme.of(context).textTheme.body2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: paymentMode.length,
                              itemBuilder: (context, index) {
                                return paymentOptionCard(
                                    paymentMethod: paymentMode[index]);
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: GestureDetector(
                              onTap: () {
                                print("Paying");
                                print("Payment Meth : " +
                                    (_paymentMethod != null).toString());
                                print("Wallet Only : " +
                                    (useWalletOnly).toString());
                                if (_paymentMethod != null || useWalletOnly) {
                                  if (!useWalletOnly) {
                                    if (_paymentMethod.paymentType ==
                                            "Cash On Delivery" &&
                                        useWallet) {
                                      Functions.toast(
                                          "Cannot use wallet with COD");
                                    } else {
                                      checkAvailability(context: context);
                                    }
                                  } else {
                                    checkAvailability(context: context);
                                  }
                                } else {
                                  final snackBar = SnackBar(
                                      content: Text(
                                    "Please select payment method !",
                                    textAlign: TextAlign.center,
                                  ));
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              },
                              child: Container(
                                height: 45,
                                margin: EdgeInsets.only(top: 25, bottom: 20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: Center(
                                  child: Text(
                                    "PAY NOW",
                                    style: Theme.of(context).textTheme.button,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            Container(
              child: isLoading
                  ? Loader(
                      bgColor: CustomAppTheme.white,
                      loaderColor: Theme.of(context).primaryColor,
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }

  Widget paymentOptionCard({PaymentMethod paymentMethod}) {
    return Column(
      children: [
        Card(
          elevation: 2,
          margin: EdgeInsets.all(0),
          child: Container(
            child: CheckboxListTile(
              title: Text(paymentMethod.paymentType,
                  style: Theme.of(context).textTheme.body2),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              value: paymentMethod.isSelected,
              onChanged: (value) {
                print("Wallet Only : " + useWalletOnly.toString());
                if (!useWalletOnly) {
                  if (!paymentMethod.isSelected) {
                    updatePaymentMethod();
                    paymentMethod.isSelected = value;
                    setState(() {
                      _paymentMethod = paymentMethod;
                      print("Selected Option For Payment Now : " +
                          _paymentMethod.paymentType);
                    });
                    print("Using Method : ${paymentMethod.paymentType}");
                  }
                }
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  updatePaymentMethod() {
    int oldDefaultAddressIndex =
        paymentMode.indexWhere((element) => element.isSelected == true);
    setState(() {
      if (oldDefaultAddressIndex != -1) {
        paymentMode[oldDefaultAddressIndex].isSelected = false;
      }
    });
  }

  clearPaymentMethod() {
    print("Clear Payment Method");
    _paymentMethod = null;
    setState(() {
      for (var element in paymentMode) {
        element.isSelected = false;
      }
    });
  }
}

class PaymentMethod {
  String paymentType;
  bool isSelected;

  PaymentMethod(
    this.paymentType,
    this.isSelected,
  );
}
